/**
 * 短时记录一个远端控制器的跳跃观测，不参与运动、动画或位置计算。
 * 日志所有者是远端控制器；每次采样都重新核对当前 Pawn，避免继续读取已失效角色。
 */
class RemoteJumpTrace extends FileLog config(RemoteJumpTrace);

var config bool bEnabled;
var config int TargetPanID;
var name TracedPawnName;
var float SampleElapsed, TraceElapsed;
var int LineCount, AnimationCallCount;
var bool bStarted, bLimitReported, bAnimationCallLimitReported;

/** 写入一条长度有限的诊断记录；文件打开失败时引擎 Logf 会直接返回。 */
function WriteTrace(string Message)
{
    if (!bStarted)
        return;
    if (LineCount >= 160)
    {
        if (!bLimitReported)
        {
            Logf("LIMIT max=160");
            bLimitReported = True;
        }
        return;
    }
    LineCount++;
    // 引擎使用固定大小的单字节缓冲，限制文本避免异常长字段溢出。
    Logf(Left(Message, 480));
}

/** 获取当前控制器；角色销毁或控制权变化后停止读取原角色。 */
function ClientController GetTraceController()
{
    local ClientController C;

    C = ClientController(Owner);
    if (C == None)
        return None;
    if (C.bDeleteMe)
        return None;
    if (C.Pawn == None)
        return None;
    if (C.Pawn.bDeleteMe)
        return None;
    if (C.Pawn.Name != TracedPawnName)
        return None;
    return C;
}

/**
 * 打开短时诊断文件并记录接收位置；该入口发生在原生跳跃位置校正之后。
 * OpenLog 没有成功返回值，文件名只用于降低多客户端同时运行时的碰撞概率。
 */
function BeginTrace(vector MessageLocation, vector MessageAcceleration, float MessageJumpZ)
{
    local ClientController C, LocalC;
    local int ObserverID, RemoteID;
    local string BaseName;

    C = ClientController(Owner);
    if (C == None)
        return;
    if (C.bDeleteMe)
        return;
    if (C.Pawn == None)
        return;
    if (C.Pawn.bDeleteMe)
        return;
    TracedPawnName = C.Pawn.Name;
    if (bStarted)
    {
        WriteTrace("RECV t=" $ Level.TimeSeconds $ " loc=" $ string(MessageLocation)
            $ " acc=" $ string(MessageAcceleration) $ " jumpz=" $ MessageJumpZ);
        CaptureFrame("recv_after_native");
        return;
    }

    LocalC = ClientController(Level.GetLocalPlayerController());
    if (LocalC != None && LocalC.PSI != None)
        ObserverID = LocalC.PSI.PanID;
    if (C.PSI != None)
        RemoteID = C.PSI.PanID;
    BaseName = "RemoteJump_" $ Level.Year $ "_" $ Level.Month $ "_" $ Level.Day
        $ "_" $ Level.Hour $ "_" $ Level.Minute $ "_" $ Level.Second $ "_" $ Level.Millisecond
        $ "_" $ int(Level.TimeSeconds * 1000) $ "_" $ ObserverID $ "_" $ RemoteID
        $ "_" $ string(Name);
    OpenLog(BaseName, "log", False);
    bStarted = True;
    WriteTrace("BEGIN version=jump_anim_detail_v2 file=" $ BaseName
        $ " observer=" $ ObserverID $ " remote=" $ RemoteID
        $ " pawn=" $ string(TracedPawnName) $ " t=" $ Level.TimeSeconds);
    WriteTrace("PATH log=" $ LogFileName $ " temp=" $ TempFileName);
    WriteTrace("RECV t=" $ Level.TimeSeconds $ " loc=" $ string(MessageLocation)
        $ " acc=" $ string(MessageAcceleration) $ " jumpz=" $ MessageJumpZ);
    RecordJumpAsset();
    CaptureFrame("recv_after_native");
}

/** 查询当前远端角色实际使用的跳跃序列资源；查询失败时保留返回标志。 */
function RecordJumpAsset()
{
    local ClientController C;
    local Character P;
    local name JumpSequence;
    local float Frames, DefaultRate;
    local bool bHasSequence, bInfoAvailable;

    C = GetTraceController();
    if (C == None)
        return;
    P = Character(C.Pawn);
    if (P == None)
        return;
    JumpSequence = P.BasicAnim[3];
    if (JumpSequence != '')
        bHasSequence = P.HasAnim(JumpSequence);
    if (bHasSequence)
        bInfoAvailable = P.AnimationInfo(JumpSequence, Frames, DefaultRate);
    WriteTrace("ASSET t=" $ Level.TimeSeconds $ " mesh=" $ P.GetMeshName()
        $ " jump=" $ string(JumpSequence) $ " has=" $ bHasSequence
        $ " info=" $ bInfoAvailable $ " frames=" $ Frames $ " default_rate=" $ DefaultRate
        $ " anim_speed=" $ P.AnimSpeed);
}

/** 记录已挂钩的动画包装函数现场；调用量单独限额，避免挤掉采样。 */
function RecordAnimationCall(string Stage, name Sequence, float RequestedRate, float TweenTime, bool bAccepted)
{
    local ClientController C;
    local Character P;
    local name ActualSequence;
    local float Frame, ActualRate;

    if (AnimationCallCount >= 48)
    {
        if (!bAnimationCallLimitReported)
        {
            WriteTrace("ANIM_CALL_LIMIT max=48");
            bAnimationCallLimitReported = True;
        }
        return;
    }
    C = GetTraceController();
    if (C == None)
        return;
    P = Character(C.Pawn);
    if (P == None)
        return;
    AnimationCallCount++;
    P.GetAnimParams(0, ActualSequence, Frame, ActualRate);
    WriteTrace("ANIM_CALL " $ Stage $ " t=" $ Level.TimeSeconds
        $ " requested=" $ string(Sequence) $ " request_rate=" $ RequestedRate
        $ " tween_time=" $ TweenTime $ " accepted=" $ bAccepted
        $ " actual=" $ string(ActualSequence) $ " cached=" $ string(P.AnimSequence)
        $ " frame=" $ Frame $ " rate=" $ ActualRate $ " playing=" $ P.IsAnimating(0)
        $ " tween=" $ P.IsTweening(0) $ " state=" $ string(C.GetStateName()));
}

/** 记录真实位置、物理和动画通道状态；调用时不改变角色状态。 */
function CaptureFrame(string Stage)
{
    local ClientController C;
    local name Sequence;
    local float Frame, Rate;

    C = GetTraceController();
    if (C == None)
        return;
    C.Pawn.GetAnimParams(0, Sequence, Frame, Rate);
    WriteTrace("FRAME " $ Stage $ " t=" $ Level.TimeSeconds
        $ " loc=" $ string(C.Pawn.Location) $ " vel=" $ string(C.Pawn.Velocity)
        $ " phy=" $ string(C.Pawn.Physics) $ " state=" $ string(C.GetStateName()));
    WriteTrace("ANIM " $ Stage $ " seq=" $ string(Sequence) $ " frame=" $ Frame
        $ " rate=" $ Rate $ " playing=" $ C.Pawn.IsAnimating(0)
        $ " tween=" $ C.Pawn.IsTweening(0));
}

/** 记录起跳实际返回值；返回值仅用于诊断，不参与原流程判断。 */
function RecordJumpResult(bool bJumpResult)
{
    WriteTrace("JUMP result=" $ bJumpResult $ " t=" $ Level.TimeSeconds);
    CaptureFrame("after_jump");
}

/** 记录跳包对应的脚本追赶参数，不推断 Pawn 的实际即时速度。 */
function RecordSync(float Distance, float Multiplier, float GroundSpeed)
{
    WriteTrace("SYNC t=" $ Level.TimeSeconds $ " distance=" $ Distance
        $ " multiplier=" $ Multiplier $ " ground=" $ GroundSpeed);
}

/** 记录脚本即将尝试或已完成的位置校正；成功与否通过前后位置判断。 */
function RecordCorrection(string Stage, vector Target)
{
    WriteTrace("CORRECTION " $ Stage $ " t=" $ Level.TimeSeconds $ " target=" $ string(Target));
    CaptureFrame(Stage);
}

/** 起跳后约一秒加密采样，之后恢复低频；超过生命周期后由引擎销毁。 */
event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (!bStarted)
        return;
    if (GetTraceController() == None)
    {
        Destroy();
        return;
    }
    TraceElapsed += DeltaTime;
    SampleElapsed += DeltaTime;
    if (TraceElapsed < 1.0)
    {
        if (SampleElapsed < 0.05)
            return;
    }
    else
    {
        if (SampleElapsed < 0.2)
            return;
    }
    SampleElapsed = 0;
    CaptureFrame("sample");
}

/** 显式关闭文件；异常退出时可能只留下尚未完成的临时文件。 */
event Destroyed()
{
    if (bStarted)
    {
        Logf("END t=" $ Level.TimeSeconds);
        CloseLog();
        bStarted = False;
    }
    Super.Destroyed();
}

defaultproperties
{
    bEnabled=True
    LifeSpan=2.3
    RemoteRole=ROLE_None
}
