"""提取实际生产方法进入项目 UCC VM；对象、物理及动画资源使用受控替身。"""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from build_ca_remote_motion import SDK_KEY, encode, run_ucc


def extract(source, name):
    """提取指定生产函数的完整方法体，保留原公式及判断顺序。"""
    match = re.search(r'(?m)^(?:private )?function (?:bool )?'+name+r'\(', source)
    if match is None:
        raise ValueError('未找到生产方法：'+name)
    start = source.index('{', match.start())
    # 本次方法中的注释不含单独花括号；字符串先遮蔽，避免把状态名当作代码。
    masked = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/',
                    lambda m: ' '*len(m.group()), source, flags=re.S)
    end, depth = start+1, 1
    while depth:
        depth += (masked[end] == '{') - (masked[end] == '}')
        end += 1
    return source[match.start():end]


def main():
    """仅在显式隔离目录编译并运行断言，拒绝操作正式 Bin。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', required=True)
    parser.add_argument('--name', default='CARemoteTests', help='独立测试包名，重试时使用新名称保留原记录')
    parser.add_argument('--ca-controller', type=Path, help='已从 CA 包提取的控制器源码，用于同输入公式对照')
    args = parser.parse_args()
    build = Path(args.build).resolve()
    if not build.is_relative_to((ROOT.parent/'.tmp').resolve()):
        raise ValueError('测试必须使用工作区 .tmp 下的隔离构建')
    stage, binary = build/'stage', build/'stage/Bin'
    if not re.fullmatch(r'CARemoteTests[A-Za-z0-9_]*', args.name):
        raise ValueError('测试包名必须以 CARemoteTests 开头')
    output = build/('vm-probe-'+args.name)
    output.mkdir(exist_ok=False)
    classes = stage/args.name/'Classes'
    classes.mkdir(parents=True, exist_ok=False)
    source = (ROOT/'Sephiroth/Classes/ClientController.uc').read_text('utf-8')
    names = ['IsRemoteCAPlayer', 'CanApplyRemoteCAMotion', 'ClearRemoteCAAttackAcceleration', 'ResetRemoteCAMotion',
             'UpdateRemoteCAMoving', 'CorrectRemoteCALargeError', 'RecordRemoteCAMotion', 'PrepareRemoteCAMotion',
             'IsRemotePlayerPawn', 'IsRemoteHardControlActive', 'IsRemoteSkillDashLockActive']
    methods = '\n\n'.join(extract(source, name) for name in names)
    # 只替换原生类型边界及状态查询，运算、待跳覆盖、步进和清理代码原样执行。
    methods = methods.replace('Hero(Pawn) == None', '!Pawn.bHero')
    methods = methods.replace('Character(Pawn)', 'Pawn')
    methods = methods.replace('IsInState(', 'TestIsInState(')
    driver = '''/** 以受控对象运行实际控制器方法，不模拟地图。 */
class DriverProbe extends Object;
var PawnStub Pawn;
var InfoStub PSI;
var ClockStub Level;
var Object Player;
var bool bDeleteMe, bIsPlayer, bSyncingPosition, bRemoteSkillDashLocked;
var float RemoteCADeltaTime, RemoteSkillDashLockEndTime, SyncCloseDistance, RemoteCASnapRetryTime;
var int RemoteCAMotionType;
var vector Destination;
var vector CurrentVelocity, CurrentAcceleration;
var name TestState;
var int Failures, Checks;

/** 替代 Actor 状态查询；逐个覆盖所列状态。 */
function bool TestIsInState(name Value)
{
    return TestState == Value;
}
''' + methods + '''
/** 初始化一位有效远端角色；生产地速和慢走比例不改成 CA 默认数值。 */
function Init()
{
    Pawn = new(None) class'CharacterJumpProbe';
    Pawn.Controller = Self;
    PSI = new(None) class'InfoStub';
    Level = new(None) class'ClockStub';
    Level.TimeSeconds = 10;
    Player = None;
    bDeleteMe = False;
    bIsPlayer = False;
    bRemoteSkillDashLocked = False;
    TestState = 'Navigating';
    ResetRemoteCAMotion();
}
/** 汇总断言失败，不把模型边界当成真实物理。 */
function Check(bool Value, string Label)
{
    Checks++;
    if (!Value)
    {
        Failures++;
        Log("CA_REMOTE_FAIL " $ Label);
    }
}
/** 执行攻击加速度控制权、运动公式、输入顺序及跳跃动画契约回归；对象与物理使用替身。 */
function int Verify()
{
    local int Index;
    local name BlockedStates[8];
    local float SavedSpeed;

    Init();
    Pawn.Acceleration = vect(120,20,0);
    Pawn.Velocity = vect(200,30,321);
    Pawn.bIsWalking = True;
    Pawn.Physics = 2;
    Destination = vect(400,50,60);
    RemoteCAMotionType = 2;
    RemoteCADeltaTime = 0.05;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(0,0,0), "attack_clears_remote_acceleration");
    Check(Pawn.Velocity == vect(200,30,321) && Pawn.JumpZ == 600, "attack_keeps_velocity_and_jumpz");
    Check(Pawn.bIsWalking && Pawn.Physics == 2, "attack_keeps_walking_and_physics");
    Check(Destination == vect(400,50,60) && RemoteCAMotionType == 2 && RemoteCADeltaTime == 0.05,
          "attack_keeps_destination_and_pending_jump");

    Init();
    Pawn.Acceleration = vect(120,20,0);
    PSI.bHardControl = True;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_respects_hard_control");
    PSI.bHardControl = False;
    bRemoteSkillDashLocked = True;
    RemoteSkillDashLockEndTime = Level.TimeSeconds + 1;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_respects_active_dash");
    bRemoteSkillDashLocked = False;
    TestState = 'Knockbacking';
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_respects_knockback");
    TestState = 'Navigating';
    Pawn.bIsDead = True;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_respects_death");
    Pawn.bIsDead = False;
    Pawn.bAvatar = True;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_helper_excludes_local_avatar");
    Pawn.bAvatar = False;
    Pawn.bHero = False;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn.Acceleration == vect(120,20,0), "attack_helper_excludes_nonhero");
    Pawn = None;
    ClearRemoteCAAttackAcceleration();
    Check(Pawn == None, "attack_missing_pawn_safe");

    Init();
    Check(IsRemoteCAPlayer(), "remote_identity");
    bIsPlayer = True;
    Check(!IsRemoteCAPlayer(), "local_controller_excluded");
    bIsPlayer = False;
    Player = new(None) class'Object';
    Check(!IsRemoteCAPlayer(), "player_connection_excluded");
    Player = None;
    Pawn.bAvatar = True;
    Check(!IsRemoteCAPlayer(), "avatar_excluded");
    Pawn.bAvatar = False;
    Pawn.bHero = False;
    Check(!IsRemoteCAPlayer(), "nonhero_excluded");
    Pawn.bHero = True;
    Pawn.Controller = None;
    Check(!IsRemoteCAPlayer(), "detached_pawn_excluded");
    Pawn.Controller = Self;
    Pawn.bDeleteMe = True;
    Check(!IsRemoteCAPlayer(), "deleted_pawn_excluded");
    Pawn.bDeleteMe = False;
    PSI.bDeleteMe = True;
    Check(!IsRemoteCAPlayer(), "deleted_psi_excluded");

    Init();
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), False, 0);
    PrepareRemoteCAMotion();
    Check(Abs(Pawn.Velocity.X-580) < 0.01, "new_speed_limited_to_current_ground");
    Check(RemoteCADeltaTime == 0 && RemoteCAMotionType == 0, "sample_consumed");
    Check(Pawn.GroundSpeed == 580, "no_groundspeed_multiplier");
    Pawn.Velocity.X = 123;
    PrepareRemoteCAMotion();
    Check(Pawn.Velocity.X == 123, "no_rewrite_without_sample");

    Init();
    Pawn.Velocity.X = 700;
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), False, 0);
    PrepareRemoteCAMotion();
    Check(Abs(Pawn.Velocity.X-700) < 0.01, "ca_existing_speed_lower_bound");
    Check(Pawn.CurrentAnimSpeed > 1, "animation_speed_updated");

    Init();
    Pawn.Physics = 2;
    Pawn.Velocity.Z = -300;
    RemoteCADeltaTime = 0.5;
    RecordRemoteCAMotion(vect(100,0,100), vect(0,0,0), False, 0);
    PrepareRemoteCAMotion();
    Check(Abs(Pawn.Velocity.X-141.421) < 0.02, "ca_horizontal_distance_with_xyz_direction");
    Check(Abs(Pawn.Velocity.Z-141.421) < 0.02, "ca_ordinary_sample_rewrites_z");

    Init();
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(100,0,0), vect(1,0,0), True, 600);
    Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 2, "jump_deferred_from_receive");
    RecordRemoteCAMotion(vect(110,0,0), vect(0,0,0), False, 0);
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0, "ca_ordinary_overwrites_pending_jump");
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(110,0,0), vect(0,0,0), False, 0);
    RecordRemoteCAMotion(vect(120,0,0), vect(1,0,0), True, 600);
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 1 && Pawn.Velocity.Z == 600, "ordinary_then_jump_launches_once");
    Check(Pawn.HorizontalAtJump > 0, "velocity_established_before_jump");
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 1, "no_jump_replay");

    Init();
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), True, 600);
    bRemoteSkillDashLocked = True;
    RemoteSkillDashLockEndTime = 11;
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 0 && RemoteCADeltaTime == 0, "dash_takes_control");
    bRemoteSkillDashLocked = False;
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0, "no_stale_jump_after_dash");
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), True, 600);
    PSI.bHardControl = True;
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 0, "hard_control_cancels_pending");

    BlockedStates[0] = 'Knockbacking';
    BlockedStates[1] = 'JustDead';
    BlockedStates[2] = 'BoothSelling';
    BlockedStates[3] = 'WasBoothSelling';
    BlockedStates[4] = 'BoothVisiting';
    BlockedStates[5] = 'Modal';
    BlockedStates[6] = 'SummonSpirit';
    BlockedStates[7] = 'Navigating';
    for (Index=0; Index<7; Index++)
    {
        Init();
        RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), True, 600);
        RemoteCADeltaTime = 0.1;
        TestState = BlockedStates[Index];
        PrepareRemoteCAMotion();
        Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 0, "state_takeover_" $ string(TestState));
        TestState = 'Navigating';
        PrepareRemoteCAMotion();
        Check(Pawn.JumpCalls == 0, "state_no_late_jump_" $ string(BlockedStates[Index]));
    }

    Init();
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), False, 0);
    Check(bSyncingPosition, "bow_moving_flag");
    Pawn.Location.X = 100;
    UpdateRemoteCAMoving();
    Check(!bSyncingPosition, "bow_arrival_flag");
    SavedSpeed = Pawn.GroundSpeed;
    ResetRemoteCAMotion();
    Check(Pawn.GroundSpeed == SavedSpeed, "reset_does_not_restore_stale_speed");

    Init();
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), True, 600);
    RemoteCADeltaTime = 0.1;
    PSI.bIsAlive = False;
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 0, "dead_psi_cancels_pending");
    Init();
    RecordRemoteCAMotion(vect(100,0,0), vect(0,0,0), True, 600);
    RemoteCADeltaTime = 0.1;
    Pawn.bIsDead = True;
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 0 && RemoteCAMotionType == 0, "dead_actor_cancels_pending");

    Init();
    Pawn.bIsWalking = True;
    Pawn.JumpZ = 900;
    Check(Pawn.DoJump(True), "remote_walk_jump_success");
    Check(Abs(Pawn.Velocity.Z-600*0.431035) < 0.01, "remote_walk_uses_default_jump_then_runtime_ratio");
    Check(Pawn.TweenCalls == 1 && Pawn.TweenTime == 0.5, "remote_air_tween_contract");
    Check(!Pawn.DoJump(True), "falling_rejects_repeat_jump");
    Check(Pawn.TweenCalls == 1, "failed_remote_jump_no_animation");

    Init();
    bIsPlayer = True;
    Pawn.bIsWalking = True;
    Check(Pawn.DoJump(True) && Pawn.Velocity.Z == 600, "local_walk_unchanged");
    Pawn.AnimSequence = '';
    Check(!Pawn.DoJump(True) && Pawn.TweenCalls == 2, "local_failed_jump_animation_unchanged");
    VerifyLargeError();
    Log("CA_REMOTE_VM_RESULT checks=" $ Checks $ " failures=" $ Failures);
    return Failures;
}
'''
    driver += """
/** 核对阈值、水平拉回、碰撞拒绝重试及特殊状态边界；真实地形另行验证。 */
function VerifyLargeError()
{
    Init();
    Pawn.Location = vect(10,20,80);
    RecordRemoteCAMotion(vect(1010,20,9000), vect(0,0,0), False, 0);
    Check(Pawn.SetLocationCalls == 0, "snap_exact_1000_excluded");
    RecordRemoteCAMotion(vect(10,20,10000), vect(0,0,0), False, 0);
    Check(Pawn.SetLocationCalls == 0, "snap_height_only_excluded");
    Pawn.Velocity = vect(400,50,-200);
    Pawn.Acceleration = vect(100,20,7);
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(1011,20,9000), vect(0,0,0), False, 0);
    Check(Pawn.Location == vect(1011,20,80), "snap_xy_preserves_height");
    Check(Pawn.Velocity == vect(0,0,-200) && Pawn.Acceleration == vect(0,0,7), "snap_clears_horizontal_momentum_only");
    Check(Pawn.Physics == 1 && Pawn.JumpCalls == 0, "snap_keeps_physics_no_jump");
    Check(Destination == vect(1011,20,9000) && RemoteCAMotionType == 1 && RemoteCADeltaTime == 0.1, "snap_records_latest_sample");
    PrepareRemoteCAMotion();
    Check(Pawn.Velocity.X == 0 && Pawn.Velocity.Y == 0, "snap_no_old_horizontal_rebound");

    Init();
    Pawn.Location.Z = 80;
    Pawn.Physics = 2;
    Pawn.Velocity.Z = -200;
    RecordRemoteCAMotion(vect(0,1001,1000), vect(0,0,0), False, 0);
    Check(Pawn.Location == vect(0,1001,80) && Pawn.Velocity.Z == -200 && Pawn.Physics == 2, "snap_falling_preserves_height_and_physics");

    Init();
    RemoteCADeltaTime = 0.1;
    RecordRemoteCAMotion(vect(1001,0,0), vect(120,0,0), True, 700);
    Check(RemoteCAMotionType == 2 && Pawn.JumpZ == 700 && Pawn.Acceleration.X == 120, "snap_keeps_current_jump_request");
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 1 && Pawn.Velocity.Z == 700, "snap_current_jump_consumed_once");
    PrepareRemoteCAMotion();
    Check(Pawn.JumpCalls == 1, "snap_no_jump_replay");

    Init();
    Pawn.bRejectLocation = True;
    Pawn.Velocity = vect(400,50,-200);
    Pawn.Acceleration = vect(100,20,7);
    RecordRemoteCAMotion(vect(4000,0,0), vect(0,0,0), False, 0);
    Check(Pawn.Location == vect(0,0,0) && Pawn.Velocity == vect(400,50,-200) && Pawn.Acceleration == vect(100,20,7), "snap_failure_keeps_motion");
    Check(Destination == vect(4000,0,0) && RemoteCAMotionType == 1, "snap_failure_keeps_latest_target");
    Level.TimeSeconds = 10.1;
    RecordRemoteCAMotion(vect(4100,0,0), vect(0,0,0), False, 0);
    Check(Pawn.SetLocationCalls == 1 && Destination.X == 4100, "snap_failure_throttled_latest_target_updated");
    Level.TimeSeconds = 10.31;
    Pawn.bRejectLocation = False;
    RecordRemoteCAMotion(vect(4200,0,0), vect(0,0,0), False, 0);
    Check(Pawn.SetLocationCalls == 2 && Pawn.Location.X == 4200, "snap_retry_uses_latest_target");
    ResetRemoteCAMotion();
    Check(RemoteCASnapRetryTime == 0, "snap_reset_clears_retry_deadline");

    Init();
    PSI.bHardControl = True;
    CorrectRemoteCALargeError(vect(4000,0,0));
    PSI.bHardControl = False;
    bRemoteSkillDashLocked = True;
    RemoteSkillDashLockEndTime = 11;
    CorrectRemoteCALargeError(vect(4000,0,0));
    bRemoteSkillDashLocked = False;
    TestState = 'Knockbacking';
    CorrectRemoteCALargeError(vect(4000,0,0));
    TestState = 'JustDead';
    CorrectRemoteCALargeError(vect(4000,0,0));
    TestState = 'Navigating';
    PSI.bIsAlive = False;
    CorrectRemoteCALargeError(vect(4000,0,0));
    PSI.bIsAlive = True;
    bIsPlayer = True;
    CorrectRemoteCALargeError(vect(4000,0,0));
    bIsPlayer = False;
    Pawn.bHero = False;
    CorrectRemoteCALargeError(vect(4000,0,0));
    Check(Pawn.SetLocationCalls == 0, "snap_respects_business_and_identity_boundaries");
    Pawn = None;
    CorrectRemoteCALargeError(vect(4000,0,0));
    Check(Pawn == None, "snap_missing_pawn_safe");
}
"""
    ca_hash = None
    if args.ca_controller:
        import hashlib
        ca_source = args.ca_controller.read_text('utf-8')
        ca_hash = hashlib.sha256(args.ca_controller.read_bytes()).hexdigest()
        ca_method = extract(ca_source, 'AdjustDestinationMotion')
        ca_method = ca_method.replace('AdjustDestinationMotion', 'ReferenceCAMotion')
        ca_method = ca_method.replace('NetRecv_DeltaTime', 'RemoteCADeltaTime')
        ca_method = ca_method.replace('DestinationMotionType', 'RemoteCAMotionType')
        ca_method = ca_method.replace('Character(Pawn)', 'Pawn')
        driver += '\n'+ca_method+'''
/** 对同一组输入分别执行 CA 提取方法与当前生产方法，核对向量、动画速度及起跳次数。 */
function CompareReference()
{
    local int Index, ExpectedJumps;
    local vector ExpectedVelocity;
    local float ExpectedAnim;
    for (Index=0; Index<12; Index++)
    {
        Init();
        Destination = vect(120,0,0);
        Destination.Z = (Index-6)*20;
        Pawn.Velocity.X = Index*70;
        Pawn.Velocity.Z = -200;
        RemoteCADeltaTime = 0.05+Index*0.025;
        RemoteCAMotionType = 1;
        if (Index >= 8) RemoteCAMotionType = 2;
        ReferenceCAMotion();
        ExpectedVelocity = Pawn.Velocity;
        ExpectedAnim = Pawn.AnimSpeed;
        ExpectedJumps = Pawn.JumpCalls;
        Init();
        Destination = vect(120,0,0);
        Destination.Z = (Index-6)*20;
        Pawn.Velocity.X = Index*70;
        Pawn.Velocity.Z = -200;
        RemoteCADeltaTime = 0.05+Index*0.025;
        RemoteCAMotionType = 1;
        if (Index >= 8) RemoteCAMotionType = 2;
        PrepareRemoteCAMotion();
        Check(VSize(Pawn.Velocity-ExpectedVelocity) < 0.01, "ca_reference_velocity_" $ Index);
        Check(Abs(Pawn.AnimSpeed-ExpectedAnim) < 0.01, "ca_reference_animation_" $ Index);
        Check(Pawn.JumpCalls == ExpectedJumps, "ca_reference_jump_" $ Index);
    }
}
'''
        driver = driver.replace('    Log("CA_REMOTE_VM_RESULT checks="', '    CompareReference();\n    Log("CA_REMOTE_VM_RESULT checks="')
    (classes/'DriverProbe.uc').write_text(driver, encoding='utf-8')
    (classes/'InfoStub.uc').write_text('''/** 受控角色资料。 */
class InfoStub extends Object;
var bool bDeleteMe, bIsAlive, bHardControl;
/** 返回测试设置的硬控状态。 */
function bool CheckBuffDontAct() { return bHardControl; }
defaultproperties
{
    bIsAlive=True
}
''', encoding='utf-8')
    (classes/'ClockStub.uc').write_text('''/** 受控业务时钟。 */
class ClockStub extends Object;
var float TimeSeconds;
''', encoding='utf-8')
    (classes/'PawnStub.uc').write_text('''/** 替代地图和原生对象；只提供可观察的物理及动画边界。 */
class PawnStub extends Object;
var Object Controller;
var bool bDeleteMe, bHero, bAvatar, bIsDead, bIsWalking, bJustDamaged;
var vector Location, Velocity, Acceleration;
var float GroundSpeed, JumpZ, WalkingPct, AnimSpeed, CurrentAnimSpeed, HorizontalAtJump, TweenTime;
var int JumpCalls, Physics, TweenCalls, SetLocationCalls;
var bool bRejectLocation;
var name AnimSequence, BasicAnim[5];
/** 记录定位尝试，按测试设置模拟碰撞拒绝；不模拟真实地图。 */
function bool SetLocation(vector Value)
{
    SetLocationCalls++;
    if (bRejectLocation)
        return False;
    Location = Value;
    return True;
}
/** 返回受控的本地身份。 */
function bool IsAvatar() { return bAvatar; }
/** 替代父类物理跳跃；真实地图和原生碰撞不在测试范围。 */
function bool DoJump(bool bUpdating)
{
    JumpCalls++;
    HorizontalAtJump = Velocity.X;
    if (Physics != 1) return False;
    if (bIsWalking) Velocity.Z = Default.JumpZ;
    else Velocity.Z = JumpZ;
    Physics = 2;
    return True;
}
/** 只允许测试用的跳跃资源。 */
function bool HasAnim(name Sequence) { return Sequence == 'Jump'; }
/** 记录调用，不模拟骨骼混合。 */
function bool TweenAnim(name Sequence, float Time, optional int Channel)
{
    TweenCalls++;
    TweenTime = Time;
    return True;
}
defaultproperties
{
    bHero=True
    GroundSpeed=580
    JumpZ=600
    WalkingPct=0.431035
    Physics=1
    BasicAnim(3)="Jump"
}
''', encoding='utf-8')
    character = (ROOT/'Sephiroth/Classes/Character.uc').read_text('utf-8')
    jump = extract(character, 'DoJump').replace('ClientController', 'DriverProbe')
    animation = extract(character, 'CHAR_PlayInAir')+'\n'+extract(character, 'CHAR_TweenAnim')
    (classes/'CharacterJumpProbe.uc').write_text('/** 执行实际角色起跳及空中动画方法。 */\nclass CharacterJumpProbe extends PawnStub;\n'+jump+'\n'+animation, encoding='utf-8')
    (classes/'Check.uc').write_text('''/** 运行受控运动回归。 */
class Check extends Commandlet;
/** 返回测试失败数。 */
event int Main(string Params)
{
    local DriverProbe Driver;
    Driver = new(None) class'DriverProbe';
    return Driver.Verify();
}
defaultproperties
{
    IsClient=False
    IsEditor=True
    IsServer=False
    LogToStdout=True
    ShowErrorCount=True
}
''', encoding='utf-8')
    ini = (binary/'Build.ini').read_text()+'\n[Editor.EditorEngine]\nEditPackages='+args.name+'\n'
    ini_name = args.name+'.ini'
    (binary/ini_name).write_text(ini)
    text = run_ucc(binary, ['make', 'ini='+ini_name, '-unattended'], output/'build.log')
    if not re.search(r'Success\s*-\s*0 error\(s\)', text):
        raise RuntimeError('VM 测试编译失败')
    package = binary/(args.name+'.u')
    data = package.read_bytes()
    if data[:4] != bytes.fromhex('c1832a9e'):
        raise ValueError('测试包格式不符')
    package.write_bytes(encode(data))
    result = run_ucc(binary, [args.name+'.Check', 'ini='+ini_name, '-unattended'], output/'run.log', timeout=40)
    match = re.search(r'CA_REMOTE_VM_RESULT checks=(\d+) failures=0', result)
    if match is None:
        raise RuntimeError('VM 行为断言失败：'+result[-3000:])
    report = dict(vm='project UCC', checks=int(match[1]), failures=0, extracted_methods=names,
                  character_methods=['DoJump', 'CHAR_PlayInAir', 'CHAR_TweenAnim'],
                  replaced_boundaries=['原生对象与身份类型转换', '状态查询', '父类物理跳跃', '动画资源和混合'],
                  ca_controller_source_sha256=ca_hash,
                  ca_reference_cases=12 if ca_hash else 0, actual_game_or_physics_tested=False)
    (output/'result.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    main()
