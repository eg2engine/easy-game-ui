"""提取生产普通运动方法，在项目 UCC VM 内用可控物理接口执行回归。

只在隔离 stage 增加测试包。Pawn/时钟为对象替身，不代表真实地图、碰撞或联网验证。
"""

import argparse
import json
from pathlib import Path
import re
import subprocess


SDK_KEY = bytes.fromhex(
    '15 79 98 A8 29 B9 D9 8E 8F 7A 98 23 98 58 39 10 E0 F8 B8 C8 A8 D8 F8 39 '
    '20 E8 39 A0 92 57 81 90 DF 8B 82 83 D9 F7 98 C9 73 25 03 98 91 27 A8 78 '
    'E8 D8 B7 83 28 C8 34 8F 87 39 F7 83 9A 9E 87 89 F9 C9 E8 F7 23 61 78 '
    '57 9A 78 B9 8C 87 23 90 18 38 34 82 98 48 39 7A 87 B8 7C 8D 89 E8 F7 '
    '38 29 19 82 73 84')


def extract(source, name):
    """按函数体括号提取实际生产实现，不在测试中重写运动公式。"""
    match = re.search(r'(?m)^(?:private )?function (?:bool |float )?' + name + r'\(', source)
    if not match:
        raise ValueError(name)
    start = source.index('{', match.start())
    depth, end = 1, start+1
    while depth:
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return source[match.start():end]


def run(stage, output, source):
    """编译并执行真实 VM 方法，保留构建日志、测试记录和测试适配范围。"""
    stage, output = Path(stage).resolve(), Path(output).resolve()
    classes = stage/'RemoteMotionTests/Classes'
    classes.mkdir(parents=True, exist_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    source_path = Path(source)
    source = source_path.read_text('utf-8')
    names = ['CanPrepareRemoteMotion', 'ResetRemoteMotion', 'CheckRemoteMotionContext',
             'RemoteMotionLimit', 'RecordRemoteMotion', 'RecoverRemoteGroundMotion',
             'PrepareRemoteMotion']
    functions = '\n\n'.join(extract(source, name) for name in names)
    assert 'ResetRemoteMotion();' in extract(source, 'Possess').split('Super.Possess', 1)[0]
    # 仅替换真实角色/状态查询边界，公式、待跳消费、清理和恢复函数原样进入 VM。
    functions = functions.replace('Character(Pawn)', 'Pawn')
    functions = functions.replace('Hero(Pawn)', 'Pawn')
    functions = functions.replace('IsInState(', 'TestIsInState(')
    start = source.index('var bool bRemoteMotionSample')
    end = source.index('var name RemoteMotionPawnName;', start)+len('var name RemoteMotionPawnName;')
    fields = source[start:end]
    driver = '''class DriverProbe extends Object;
const PHYS_Walking=1;
const PHYS_Falling=2;
var PawnStub Pawn;
var InfoStub PSI;
var ClockStub Level;
var vector Destination, LastSyncLocation;
var float OriginalGroundSpeed, StuckCheckTime, StuckThreshold, StuckTimeLimit;
var float SyncCloseDistance, SyncSpeedMultiplier;
var bool bSyncingPosition, Controlled, LocalPlayer, DashLocked;
var name TestState;
''' + fields + '''
function bool IsRemotePlayerPawn() { return !LocalPlayer; }
function bool IsRemoteHardControlActive() { return Controlled; }
function bool IsRemoteSkillDashLockActive() { return DashLocked; }
function bool TestIsInState(name StateName) { return TestState==StateName; }
''' + functions + '''
function Init()
{
    Pawn=new(None) class'PawnStub';
    Pawn.PhysicsVolume=new(None) class'ClockStub';
    Pawn.PhysicsVolume.Gravity.Z=-1000;
    PSI=new(None) class'InfoStub';
    Level=new(None) class'ClockStub';
    Level.TimeSeconds=10;
    TestState='Navigating';
}
function bool Check(bool Condition,string Label)
{
    if (!Condition) Log("REMOTE_SCRIPT_FAIL " $ Label);
    return Condition;
}
function int Verify()
{
    local float BeforeZ;
    local int Failures;
    local int FrameIndex,FpsIndex,Fps;
    // 同周期普通包更新位置，但不能覆盖首个跳跃参数；下一帧仅消费一次。
    Init(); Pawn.Velocity.X=200;
    Log("REMOTE_SCRIPT_INIT alive=" $ PSI.bIsAlive $ " physics=" $ Pawn.Physics $ " permitted=" $ CanPrepareRemoteMotion());
    RecordRemoteMotion(vect(100,0,0),vect(1,0,0),True,600);
    RecordRemoteMotion(vect(110,0,0),vect(0,0,0),False,0);
    RecordRemoteMotion(vect(120,0,0),vect(0,1,0),True,900);
    if (!Check(bRemoteJumpPending && RemotePendingJumpZ==600,"pending_preserved")) Failures++;
    PrepareRemoteMotion(0.016);
    if (!Check(Pawn.JumpCalls==1 && Pawn.Velocity.Z==600 && !bRemoteJumpPending,"once_launch")) Failures++;
    BeforeZ=Pawn.Velocity.Z;
    PrepareRemoteMotion(0.016);
    if (!Check(Pawn.JumpCalls==1 && Pawn.Velocity.Z==BeforeZ,"no_repeat_or_z_rewrite")) Failures++;
    // 重复终点必须继续到达；到达后的摩擦滑行不重新拉回旧点。
    Init(); ResetRemoteMotion();
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),False,0);
    PrepareRemoteMotion(0.016); Pawn.Location.X=20; Level.TimeSeconds+=0.3;
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),False,0); PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Velocity.X>0,"duplicate_goal_still_advances")) Failures++;
    Pawn.Location.X=100; PrepareRemoteMotion(0.016);
    Pawn.Location.X=125; Pawn.Velocity.X=30; PrepareRemoteMotion(0.016);
    if (!Check(bRemoteGroundIdle && Pawn.Velocity.X==30 && Pawn.Acceleration.X==0,"ground_arrival_no_pullback")) Failures++;
    Level.TimeSeconds+=0.3;
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),False,0);
    if (!Check(bRemoteGroundIdle,"duplicate_does_not_reopen_arrival")) Failures++;
    // 零速起步跳保留输入加速度，再承接下一物理步产生的真实水平动量。
    Init(); ResetRemoteMotion();
    RecordRemoteMotion(vect(0,0,0),vect(1,0,0),True,600); PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Acceleration.X>0 && Pawn.Velocity.Z==600,"start_jump_keeps_acceleration")) Failures++;
    Pawn.Velocity.X=40; Level.TimeSeconds+=0.016; PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Velocity.X==40 && Pawn.Velocity.Z==600,"native_air_control_carry")) Failures++;
    // 父跳跃失败只尝试一次，不在后续落地补播。
    Init(); ResetRemoteMotion(); Pawn.AllowJump=False;
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),True,600);
    PrepareRemoteMotion(0.016); PrepareRemoteMotion(0.016);
    if (!Check(Pawn.JumpCalls==1 && !bRemoteJumpPending,"failed_no_retry")) Failures++;
    // 走路脉冲仍用消息 JumpZ，临时 walking 标记必须恢复；上限只缩放一次。
    Init(); ResetRemoteMotion(); Pawn.bIsWalking=True; Pawn.Velocity.X=100;
    RecordRemoteMotion(vect(50,0,0),vect(1,0,0),True,600);
    PrepareRemoteMotion(0.016);
    if (!Check(Pawn.bIsWalking && Pawn.Velocity.Z==600 && RemoteMotionLimit()==290,"walk_impulse_and_limit")) Failures++;
    // 空中相邻收包允许真实反向，减速后不保持旧超速，Z 不随目标高度变化。
    Init(); ResetRemoteMotion(); Pawn.Physics=2; Pawn.Velocity.X=200; Pawn.Velocity.Z=-150;
    RecordRemoteMotion(vect(100,0,50),vect(0,0,0),False,0);
    Level.TimeSeconds+=0.3;
    RecordRemoteMotion(vect(40,0,1000),vect(0,0,0),False,0);
    PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Velocity.X<0 && Pawn.Velocity.Z==-150 && Pawn.LocationCalls==0,"air_reverse_xy_only")) Failures++;
    Pawn.GroundSpeed=400; PrepareRemoteMotion(0.016);
    if (!Check(VSize(Pawn.Velocity*vect(1,1,0))<=400.01,"attribute_buff_before_packet")) Failures++;
    Level.TimeSeconds+=0.3;
    RecordRemoteMotion(vect(-400,0,1000),vect(0,0,0),False,0);
    PrepareRemoteMotion(0.016);
    if (!Check(VSize(Pawn.Velocity*vect(1,1,0))<=400.01,"buff_cap")) Failures++;
    Level.TimeSeconds+=0.1;
    RecordRemoteMotion(vect(-400,0,1000),vect(0,0,0),False,0);
    Level.TimeSeconds+=0.2; PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Velocity.X==0 && Pawn.Velocity.Z==-150,"explicit_air_stop")) Failures++;
    // 已越过旧点的落地不反向拉回，保持原物理摩擦减速。
    Init(); ResetRemoteMotion(); bRemoteMotionSample=True; RemoteMotionPawnName=Pawn.Name;
    bRemoteLandingGuard=True; RemoteMotionDirection=vect(1,0,0);
    RemoteMotionTarget=vect(0,0,0); Pawn.Location.X=10; Pawn.Velocity.X=100;
    PrepareRemoteMotion(0.016);
    if (!Check(Pawn.Velocity.X==100 && Pawn.Acceleration.X==0,"landing_no_pullback")) Failures++;
    // 恢复只在地面尝试，保留原高度；移动超过受阻阈值不能误判为卡住。
    Init(); ResetRemoteMotion(); Pawn.Location.Z=37; RemoteMotionTarget=vect(4000,0,999);
    RecoverRemoteGroundMotion(0.016);
    if (!Check(Pawn.LocationCalls==1 && Pawn.Location.Z==37,"ground_recovery_preserves_z")) Failures++;
    Pawn.Physics=2; RemoteMotionTarget.X=9000; RecoverRemoteGroundMotion(1);
    if (!Check(Pawn.LocationCalls==1,"no_air_recovery")) Failures++;
    Init(); ResetRemoteMotion(); RecordRemoteMotion(vect(100,0,0),vect(0,0,0),True,600);
    PSI.bDeleteMe=True; PrepareRemoteMotion(0.016);
    if (!Check(!bRemoteJumpPending && Pawn.JumpCalls==0,"deleted_psi_clears_jump")) Failures++;
    Init(); ResetRemoteMotion(); Pawn.AllowLocation=False; RemoteMotionTarget=vect(4000,0,0);
    RecoverRemoteGroundMotion(0.016); RecoverRemoteGroundMotion(0.016);
    if (!Check(Pawn.LocationCalls==1,"collision_failure_retry_bounded")) Failures++;
    Level.TimeSeconds+=0.31; RecoverRemoteGroundMotion(0.016);
    if (!Check(Pawn.LocationCalls==2,"collision_failure_retry_after_interval")) Failures++;
    // 低速角色在不同帧率下确实持续推进，不得触发受阻瞬移。
    for (FpsIndex=0;FpsIndex<3;FpsIndex++)
    {
        Fps=30;
        if (FpsIndex==1) Fps=60;
        if (FpsIndex==2) Fps=144;
        Init(); ResetRemoteMotion(); Pawn.Velocity.X=100;
        LastSyncLocation=Pawn.Location; RemoteMotionTarget=vect(1000,0,0);
        for (FrameIndex=0;FrameIndex<Fps;FrameIndex++)
        {
            Pawn.Location.X+=100.0/Fps; Level.TimeSeconds+=1.0/Fps;
            RecoverRemoteGroundMotion(1.0/Fps);
        }
        if (!Check(Pawn.LocationCalls==0,"slow_walk_no_false_recovery_fps=" $ Fps)) Failures++;
    }
    // 失权、角色重绑与本地图时钟回退必须清掉旧待跳。
    Init(); ResetRemoteMotion(); RecordRemoteMotion(vect(100,0,0),vect(0,0,0),True,600);
    Controlled=True; PrepareRemoteMotion(0.016); Controlled=False;
    if (!Check(!bRemoteJumpPending && Pawn.JumpCalls==0,"control_clears_jump")) Failures++;
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),True,600);
    Pawn=new(None,"ReplacementPawn") class'PawnStub'; CheckRemoteMotionContext();
    if (!Check(!bRemoteJumpPending && !bRemoteMotionSample,"rebind_clears_state")) Failures++;
    RecordRemoteMotion(vect(100,0,0),vect(0,0,0),True,600);
    Level.TimeSeconds=0; CheckRemoteMotionContext();
    if (!Check(!bRemoteJumpPending && !bRemoteMotionSample,"clock_reset")) Failures++;
    Init(); ResetRemoteMotion(); LocalPlayer=True;
    if (!Check(!CanPrepareRemoteMotion(),"local_ownership")) Failures++;
    LocalPlayer=False; TestState='Knockbacking';
    if (!Check(!CanPrepareRemoteMotion(),"knockback_ownership")) Failures++;
    TestState='BoothSelling';
    if (!Check(!CanPrepareRemoteMotion(),"booth_ownership")) Failures++;
    Log("REMOTE_SCRIPT_RESULT failures=" $ Failures);
    return Failures;
}
'''
    character_source = (source_path.parent/'Character.uc').read_text('utf-8')
    animation_methods = '\n\n'.join(extract(character_source, name)
                                    for name in ['CHAR_PlayInAir', 'DoJump'])
    animation_methods = animation_methods.replace('ClientController', 'DriverProbe')
    animation_methods = animation_methods.replace('Hero(Self)', 'Self')
    animation_probe = '''class AnimationProbe extends PawnStub;
var name AnimSequence,CurrentSequence,BasicAnim[5];
var float AnimSpeed,AnimRate;
var bool Animating;
var int PlayCalls,TweenCalls;
function bool HasAnim(name Sequence) { return Sequence=='Jump'; }
function bool IsBasicAnim(name Sequence) { return Sequence=='Idle' || Sequence=='Jump'; }
function GetAnimParams(int Channel,out name Sequence,out float Frame,out float Rate)
{ Sequence=CurrentSequence; Frame=0; Rate=AnimRate; }
function bool IsAnimating(int Channel) { return Animating; }
function CHAR_PlayAnim(name Sequence,optional float Rate,optional float TweenTime,optional int Channel)
{ PlayCalls++; AnimSequence=Sequence; CurrentSequence=Sequence; AnimRate=Rate; }
function CHAR_TweenAnim(name Sequence,float Time,optional int Channel)
{ TweenCalls++; AnimSequence=Sequence; CurrentSequence=Sequence; AnimRate=0; }
''' + animation_methods + '''
function int Verify()
{
    local DriverProbe Driver;
    local int Failures;
    Driver=new(None,"AnimationDriver") class'DriverProbe';
    Controller=Driver;
    BasicAnim[3]='Jump'; AnimSpeed=1;
    AnimSequence='Cast'; CurrentSequence='Cast'; AnimRate=1;
    DoJump(True);
    if (AnimSequence!='Cast' || PlayCalls!=0)
    { Log("REMOTE_ANIM_FAIL skill_marker"); Failures++; }
    AnimSequence='Jump'; CurrentSequence='Jump'; AnimRate=0; Animating=True;
    DoJump(True);
    if (PlayCalls!=1 || AnimRate!=1)
    { Log("REMOTE_ANIM_FAIL old_jump_tween"); Failures++; }
    PlayCalls=0; AnimSequence='Jump'; CurrentSequence='Jump'; AnimRate=1;
    DoJump(True);
    if (PlayCalls!=0 || AnimSequence!='Jump')
    { Log("REMOTE_ANIM_FAIL adopt_active_jump"); Failures++; }
    AllowJump=False; CurrentSequence='Idle'; AnimSequence='Idle'; DoJump(True);
    if (PlayCalls!=0 || AnimSequence!='Idle')
    { Log("REMOTE_ANIM_FAIL rejected_jump"); Failures++; }
    AllowJump=True; Driver.LocalPlayer=True; DoJump(True);
    if (TweenCalls!=1)
    { Log("REMOTE_ANIM_FAIL local_original_tween"); Failures++; }
    Log("REMOTE_ANIM_RESULT failures=" $ Failures);
    return Failures;
}
'''
    sources = {
        'DriverProbe.uc': driver,
        'AnimationProbe.uc': animation_probe,
        'ClockStub.uc': 'class ClockStub extends Object;\nvar float TimeSeconds;\nvar vector Gravity;\n',
        'InfoStub.uc': 'class InfoStub extends Object;\nvar bool bIsAlive,bDeleteMe;\ndefaultproperties\n{\n    bIsAlive=True\n}\n',
        'PawnStub.uc': '''class PawnStub extends Object;
var bool bDeleteMe,bIsDead,bIsWalking,AllowJump,bJustDamaged,AllowLocation;
var byte Physics;
var vector Location,Velocity,Acceleration;
var float GroundSpeed,CurrentGroundSpeed,WalkingPct,JumpZ,AccelRate,DesiredSpeed;
var float CollisionRadius,CollisionHeight;
var ClockStub PhysicsVolume;
var Object Controller;
var int JumpCalls,LocationCalls;
function bool DoJump(bool Updating)
{
    JumpCalls++;
    if (!AllowJump) return False;
    Physics=2;
    Velocity.Z=JumpZ;
    return True;
}
function bool SetLocation(vector Goal) { LocationCalls++; if (!AllowLocation) return False; Location=Goal; return True; }
defaultproperties
{
    GroundSpeed=580
    CurrentGroundSpeed=580
    WalkingPct=0.5
    AccelRate=1000
    Physics=1
    AllowJump=True
    AllowLocation=True
    CollisionRadius=10
    CollisionHeight=40
}
''',
        'MotionProbe.uc': '''class MotionProbe extends Commandlet;
event int Main(string Params)
{
    local DriverProbe Driver;
    local AnimationProbe Animation;
    local int Failures;
    local Object NativeController,NativePlayer;
    NativeController=DynamicLoadObject("Sephiroth.ClientController",class'Class');
    NativePlayer=DynamicLoadObject("SephirothUI.SephirothPlayer",class'Class');
    if (NativeController==None || NativePlayer==None) return 1;
    Log("REMOTE_NATIVE_CLASSES_LOADED " $ NativeController $ " " $ NativePlayer);
    Driver=new(None) class'DriverProbe';
    Failures=Driver.Verify();
    Animation=new(None) class'AnimationProbe';
    return Failures+Animation.Verify();
}
defaultproperties
{
    IsClient=False
    IsEditor=True
    IsServer=False
    LogToStdout=True
    ShowErrorCount=True
}
''',
    }
    for name, content in sources.items():
        (classes/name).write_text(content, encoding='utf-8')
    ini = (stage/'Bin/Build.ini').read_text()
    ini = ini.replace('EditPackages=SephirothUI', 'EditPackages=SephirothUI\nEditPackages=RemoteMotionTests')
    (stage/'Bin/MotionTest.ini').write_text(ini)
    (stage/'Bin/RemoteMotionTests.u').unlink(missing_ok=True)
    result = subprocess.run([str(stage/'Bin/UCC.exe'), 'make', 'ini=MotionTest.ini', '-unattended'],
                            cwd=stage/'Bin', stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
    (output/'script-probe-build.log').write_bytes(result.stdout)
    if result.returncode:
        raise RuntimeError(result.stdout.decode('gbk', 'replace')[-2500:])
    package = stage/'Bin/RemoteMotionTests.u'
    data = package.read_bytes()
    assert data[:4] == bytes.fromhex('c1832a9e')
    package.write_bytes(bytes(((v ^ SDK_KEY[i % 100])+i % 79) & 255 for i, v in enumerate(data)))
    result = subprocess.run([str(stage/'Bin/UCC.exe'), 'RemoteMotionTests.MotionProbe',
                             'ini=MotionTest.ini', '-unattended'], cwd=stage/'Bin',
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
    (output/'script-probe-run.log').write_bytes(result.stdout)
    text = result.stdout.decode('gbk', 'replace')
    if (result.returncode or 'REMOTE_SCRIPT_RESULT failures=0' not in text
            or 'REMOTE_ANIM_RESULT failures=0' not in text):
        raise RuntimeError(text[-3500:])
    report = {'vm': 'project UCC', 'production_methods_extracted': names,
              'assertions': driver.count('if (!Check(')+2,
              'animation_assertions': 5,
              'boundaries_replaced': ['Pawn/PSI/clock objects', 'character cast', 'state query',
                                      'DoJump and SetLocation (controlled implementations)',
                                      'animation resources/channel/playback (controlled implementations)'],
              'failures': 0, 'real_physics_or_online_tested': False}
    (output/'script-probe.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), 'utf-8')
    return report


def main():
    """只接受显式隔离构建目录，输出 VM 测试报告。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--source', default='Sephiroth/Classes/ClientController.uc')
    args = parser.parse_args()
    print(json.dumps(run(args.stage, args.output, args.source), ensure_ascii=False))


if __name__ == '__main__':
    main()
