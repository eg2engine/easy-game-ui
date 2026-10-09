// 驱动金龙增强动画与轨道，仅向仍由本 Link 控制的有效宿主恢复原状态。
class GoldenDragonGuardianLink extends Actor config(GoldenDragonOrbit);



var config bool bEnableOrbit, bDebugTrace;

var config float OrbitRadius, OrbitHeight, OrbitPeriod, StandDelay, BlendTime;

var config int FacingYawOffset;

var config vector FollowPosition;

var SkeletalMesh SavedMesh, GuardMesh;

var float SavedDrawScale;

var bool bGuardAssetReady, bHeadingCalibrated;

var config float DragonScale, BodyEnvelope, SafetyGap;

var config bool bPreserveSummonScale;

var config float TurnSpeed;

var config bool bUsePetSpacing;

var bool bSwimAssetReady, bRunAssetReady;



var vector SavedDrawScale3D;

var float SafeRadius, HeadingAge, LastPlaybackRate;

var float FollowDistance, ReturnAngle, ReturnRemaining;

var bool bWasOrbiting, bReturning;

// D46: live full-body pose mixing and continuous path speed (non-native helper only).
var bool bPoseLayersReady;
var float PoseAlpha, PoseAlphaVelocity, OrbitAngularSpeed, ActionHoldTime;


var int CalibratedYaw;

var rotator TravelRotation;

var Guardian Dragon;
var GoldenDragonBodyFxLink BodyFx;

var Hero Wearer;

var float StillTime, Phase, Weight, ReportTime;

var vector PreviousOwnerLocation, CurrentOffset, SavedFollowOffset;

var rotator CurrentRotation;

var bool bInitialized, bOrbiting;

var name LastAnimation;

var EPhysics SavedPhysics;

var int UpdateCount, AnimStartCount;

var float LastUpdateTime;
var bool bStopping;



// 使用引擎短模型名称识别金龙，避免完整模型对象字符串转换。
static function bool IsDragon(Guardian P)

{

    local string Key;

    if (P == None || P.bDeleteMe)

        return False;

    Key = Caps(P.GetMeshName());

    return Key == "GOLDENDRAGON" || Key == "GOLDENDRAGONGUARD";

}



// 先收集宿主的辅助对象再停止和销毁，避免遍历期间修改子对象集合；恢复由 bRestoreHost 控制。
static function StopForHost(Guardian Host, bool bRestoreHost)
{
    local GoldenDragonGuardianLink Link;
    local GoldenDragonBodyFxLink Fx;
    local array<GoldenDragonGuardianLink> Links;
    local array<GoldenDragonBodyFxLink> Effects;
    local int I;

    if (Host == None)
        return;
    foreach Host.ChildActors(class'GoldenDragonGuardianLink', Link)
    {
        Links.Length = Links.Length + 1;
        Links[Links.Length - 1] = Link;
    }
    foreach Host.ChildActors(class'GoldenDragonBodyFxLink', Fx)
    {
        Effects.Length = Effects.Length + 1;
        Effects[Effects.Length - 1] = Fx;
    }
    for (I = 0; I < Links.Length; I++)
    {
        Link = Links[I];
        if (Link != None)
        {
            Link.StopWork(bRestoreHost);
            if (!Link.bDeleteMe)
                Link.Destroy();
        }
    }
    for (I = 0; I < Effects.Length; I++)
    {
        Fx = Effects[I];
        if (Fx != None)
        {
            Fx.StopWork();
            if (!Fx.bDeleteMe)
                Fx.Destroy();
        }
    }
}

// 永久停止更新并清理子效果；仅当请求恢复且宿主归属、网格仍匹配时恢复原动画、缩放和物理状态。
simulated function StopWork(bool bRestoreHost)
{
    local Guardian OldDragon;
    local GoldenDragonBodyFxLink OldBodyFx;
    local bool bCanRestore;

    if (bStopping)
        return;
    bStopping = True;
    Disable('Tick');
    OldDragon = Dragon;
    OldBodyFx = BodyFx;
    BodyFx = None;
    // 只有仍归属原主人且当前网格仍受本 Link 控制的存活宿主才能恢复，避免覆盖新模型或销毁中的状态。
    bCanRestore = bRestoreHost && bInitialized && bGuardAssetReady
        && OldDragon != None && !OldDragon.bDeleteMe && Owner == OldDragon
        && Wearer != None && !Wearer.bDeleteMe && OldDragon.OwnPlayer == Wearer
        && GuardMesh != None && SavedMesh != None && OldDragon.Mesh == GuardMesh;
    Dragon = None;
    Wearer = None;
    if (OldBodyFx != None)
    {
        OldBodyFx.StopWork();
        if (!OldBodyFx.bDeleteMe)
            OldBodyFx.Destroy();
    }
    if (bCanRestore)
    {
        if (bPoseLayersReady)
        {
            OldDragon.AnimBlendParams(1, 0);
            OldDragon.AnimStopLooping(1);
        }
        OldDragon.LinkMesh(SavedMesh);
        OldDragon.SetDrawScale(SavedDrawScale);
        OldDragon.SetDrawScale3D(SavedDrawScale3D);
        OldDragon.SetPhysics(SavedPhysics);
    }
    SavedMesh = None;
    GuardMesh = None;
    bPoseLayersReady = False;
}

// Normal pet spacing with tangent-facing orbit; full body clearance needs visual testing.

// Idle/Run stay straight; OrbitGuard from D6 is deliberately not played.

// Keep both loops advancing; changing their weight does not restart either clip.
simulated function bool UpdatePoseBlend(float DT)
{
    local name BaseAnim, OrbitAnim;
    local float BaseFrame, OrbitFrame, BaseRate, OrbitRate;
    local float TargetAlpha, BlendSeconds, W, E, Error, Temp;

    if (!bRunAssetReady || !bSwimAssetReady || !bHeadingCalibrated ||
        !bEnableOrbit || Wearer.bIsDead || Wearer.bIsSit || Wearer.bHidden ||
        Dragon.bHidden || Dragon.PlayAnimName != '')
    {
        if (bPoseLayersReady) Dragon.AnimBlendParams(1, 0);
        bPoseLayersReady = False;
        PoseAlpha = 0;
        PoseAlphaVelocity = 0;
        return False;
    }

    Dragon.GetAnimParams(0, BaseAnim, BaseFrame, BaseRate);
    Dragon.GetAnimParams(1, OrbitAnim, OrbitFrame, OrbitRate);
    if (!bPoseLayersReady || BaseAnim != 'RunFlowV5')
    {
        Dragon.LoopAnim('RunFlowV5', 1.27, 0.15, 0);
        AnimStartCount++;
    }
    if (!bPoseLayersReady || OrbitAnim != 'OrbitCrawlV17')
    {
        Dragon.AnimBlendParams(1, 0, 0, 0, '', False);
        Dragon.LoopAnim('OrbitCrawlV17', 2.0 / FMax(OrbitPeriod, 1), 0, 1);
        Dragon.EnableChannelNotify(1, 0);
        AnimStartCount++;
    }
    bPoseLayersReady = True;
    BlendSeconds = FClamp(BlendTime, 0.45, 1.2);
    TargetAlpha = 0;
    if (bOrbiting) TargetAlpha = 1;
    else if (bReturning)
    {
        // Uncurl during the final CCW approach, rather than after reaching the slot.
        TargetAlpha = FClamp(ReturnRemaining / BlendSeconds, 0, 1);
        TargetAlpha = TargetAlpha * TargetAlpha * (3 - 2 * TargetAlpha);
    }

    // Analytic critically damped spring: reversals keep weight AND weight velocity.
    W = 6.0 / BlendSeconds;
    E = Exp(-W * DT);
    Error = PoseAlpha - TargetAlpha;
    Temp = (PoseAlphaVelocity + W * Error) * DT;
    PoseAlpha = FClamp(TargetAlpha + (Error + Temp) * E, 0, 1);
    PoseAlphaVelocity = (PoseAlphaVelocity - W * Temp) * E;
    Dragon.AnimBlendParams(1, PoseAlpha, 0, 0, '', False);
    LastAnimation = 'RunFlowV5';
    LastPlaybackRate = 1.27;
    return True;
}

// 由宠物控制器驱动动画和轨道；先校验主人状态，失效时停止并按宿主有效性清理。
simulated function UpdateDragon(float DT)

{

    local vector Delta, FollowWorld, Direction, Head, Neck;

    local rotator WantedRotation, Difference, LocalFacing;

    local name PlayerAnim, DragonAnim, WantedAnim;

    local float Frame, Rate, Speed, AnimationRate, Step, TurnLimit, HeadingError, RightPhase;
    local float OrbitSpeed, OrbitAcceleration, TargetSpeed, FollowError;

    local bool Standing, Teleported, Stationary;



    if (bStopping)
        return;
    UpdateCount++;

    LastUpdateTime = Level.TimeSeconds;

    Dragon = Guardian(Owner);

    if (Dragon == None || Dragon.bDeleteMe)
    {
        StopWork(False);
        Destroy();
        return;
    }

    Wearer = Hero(Dragon.OwnPlayer);

    if (class'FxLifecyclePolicy'.static.GetHeroState(Wearer) != 'Ready')
    {
        StopWork(True);
        Destroy();
        return;
    }
    if (!IsDragon(Dragon))
    {
        StopWork(False);
        Destroy();
        return;
    }

    DT = FClamp(DT, 0.001, 0.1);

    if (!bInitialized)

    {

        SavedMesh = SkeletalMesh(Dragon.Mesh);

        SavedDrawScale = Dragon.DrawScale;

        SavedDrawScale3D = Dragon.DrawScale3D;

        GuardMesh = SkeletalMesh(DynamicLoadObject("PetPkg.GoldenDragonGuard", class'SkeletalMesh', True));

        if (GuardMesh != None)

        {

            Dragon.LinkMesh(GuardMesh);

            bGuardAssetReady = Dragon.HasAnim('Run') && Dragon.HasAnim('Idle');

            bSwimAssetReady = Dragon.HasAnim('OrbitCrawlV17');

            bRunAssetReady = Dragon.HasAnim('RunFlowV5');

            if (!bGuardAssetReady) Dragon.LinkMesh(SavedMesh);

        }

        if (!bGuardAssetReady) return;

        if (bPreserveSummonScale)

        {

            Dragon.SetDrawScale(SavedDrawScale);

            Dragon.SetDrawScale3D(SavedDrawScale3D);

        }

        else

        {

            Dragon.SetDrawScale(FClamp(DragonScale, 0.1, 4));

            Dragon.SetDrawScale3D(vect(1,1,1));

        }

        SavedPhysics = Dragon.Physics;

        Dragon.SetPhysics(PHYS_None);

        PreviousOwnerLocation = Wearer.Location;

        CurrentRotation = Dragon.Rotation;

        FollowDistance = Abs(Dragon.LocationOffset.Y);

        if (FollowDistance < 10) FollowDistance = Dragon.PetRadius;

        if (FollowDistance < 10) FollowDistance = 100;

        FollowWorld = vect(0,1,0) >> Wearer.Rotation;

        Phase = Atan(FollowWorld.Y, FollowWorld.X);

        CalibratedYaw = -16384;

        Dragon.PlayAnimName = '';

        Dragon.LoopAnim('Run', 1, 0);

        LastAnimation = 'Run';

        LastPlaybackRate = 1;

        bInitialized = True;

    }

    // Match normal pet spacing. Length lies along the tangent, not along the radius.

    // OrbitRadius=0 uses this Guardian's original PetRadius/right-side offset.

    SafeRadius = FollowDistance;

    Dragon.Velocity = vect(0,0,0);

    Dragon.Acceleration = vect(0,0,0);

    Delta = Wearer.Location - PreviousOwnerLocation;

    Speed = VSize(Delta) / DT;

    Teleported = VSize(Delta) > 600;

    PreviousOwnerLocation = Wearer.Location;

    Wearer.GetAnimParams(0, PlayerAnim, Frame, Rate);

    // A stationary owner can flinch without interrupting the dragon orbit.
    // Movement, falling, knockback animation and other actions still exit normally.
    Stationary = !Wearer.bIsDead && !Wearer.bIsSit && !Wearer.bHidden

        && !Dragon.bHidden && Wearer.Physics != PHYS_Falling

        && VSize(Wearer.Velocity) < 8 && VSize(Wearer.Acceleration) < 1

        && Speed < 8;

    Standing = Stationary && (PlayerAnim == Wearer.BasicAnim[0] || PlayerAnim == 'Pain');
    if (!Stationary || Standing) ActionHoldTime = 0;
    else ActionHoldTime += DT;
    // Only suppress brief stationary animation changes; actual movement exits immediately.
    if (Stationary && bWasOrbiting && ActionHoldTime < 0.2) Standing = True;

    if (Standing && bEnableOrbit && !Teleported) StillTime += DT;

    else StillTime = 0;

    bOrbiting = StillTime >= StandDelay && bEnableOrbit;

    if (bOrbiting && !bUsePetSpacing && OrbitRadius > 0) SafeRadius = OrbitRadius;

    FollowWorld = vect(0,1,0) >> Wearer.Rotation;

    RightPhase = Atan(FollowWorld.Y, FollowWorld.X);
    OrbitSpeed = 6.2831853 / FMax(OrbitPeriod, 1);
    OrbitAcceleration = OrbitSpeed / FClamp(BlendTime, 0.35, 1.2);

    if (bOrbiting) bReturning = False;

    else if (bWasOrbiting) bReturning = True;

    if (Teleported || Wearer.bIsDead || Wearer.bIsSit || Wearer.bHidden || !bEnableOrbit)

    {

        Weight = 0;
        OrbitAngularSpeed = 0;
        ActionHoldTime = 0;

        StillTime = 0;

        bOrbiting = False;

        bReturning = False;

    }

    if (!bOrbiting)

    {

        if (bReturning)

        {

            // Decreasing phase is CCW; never choose the reverse short arc.

            ReturnAngle = Phase - RightPhase;

            while (ReturnAngle < 0) ReturnAngle += 6.2831853;

            while (ReturnAngle >= 6.2831853) ReturnAngle -= 6.2831853;

            TargetSpeed = FMin(OrbitSpeed, Sqrt(2 * OrbitAcceleration * ReturnAngle));
            OrbitAngularSpeed += FClamp(TargetSpeed - OrbitAngularSpeed,
                -OrbitAcceleration * DT, OrbitAcceleration * DT);
            Step = DT * OrbitAngularSpeed;

            if (ReturnAngle <= Step || ReturnAngle < 0.002)

            {

                Phase -= ReturnAngle;

                bReturning = False;

                ReturnRemaining = 0;
                OrbitAngularSpeed = 0;

            }

            else

            {

                Phase -= Step;

                ReturnRemaining = (ReturnAngle-Step) * FMax(OrbitPeriod, 1) / 6.2831853;

            }

        }

        else

        {

            // Follow the right-side slot along the circle even when the owner turns sharply.
            FollowError = RightPhase - Phase;
            while (FollowError > 3.14159265) FollowError -= 6.2831853;
            while (FollowError < -3.14159265) FollowError += 6.2831853;
            Step = FMax(TurnSpeed, 30) * 3.14159265 / 180.0 * DT;
            if (Teleported) Phase = RightPhase;
            else Phase += FClamp(FollowError, -Step, Step);
            OrbitAngularSpeed = 0;
            ReturnRemaining = 0;

        }

    }

    else ReturnRemaining = 0;

    if (Phase < -6.2831853) Phase += 6.2831853;

    bWasOrbiting = bOrbiting;

    // Read actual animated head/neck in world space to resolve importer axis conventions.

    HeadingAge += DT;

    if (!bHeadingCalibrated && HeadingAge >= 0.15)

    {

        Head = Dragon.GetBoneCoords('Bone017_060').Origin;

        Neck = Dragon.GetBoneCoords('Bone015_058').Origin;

        Direction = (Head - Neck) << Dragon.Rotation;

        Direction.Z = 0;

        if (VSize(Direction) > 2)

        {

            LocalFacing = Rotator(Direction);

            CalibratedYaw = -LocalFacing.Yaw;

            bHeadingCalibrated = True;

        }

    }

    // Use the same path angle for the slot and heading, including sharp owner turns.
    Direction.X = Sin(Phase);
    Direction.Y = -Cos(Phase);
    Direction.Z = 0;

    if (VSize(Direction) > 0.01) TravelRotation = Rotator(Direction);

    WantedRotation = TravelRotation;

    WantedRotation.Pitch = 0;

    WantedRotation.Roll = 0;

    WantedRotation.Yaw += CalibratedYaw + FacingYawOffset;

    Difference = Normalize(WantedRotation - CurrentRotation);

    TurnLimit = FMax(TurnSpeed, 30) * 65536.0 / 360.0 * DT;

    CurrentRotation.Yaw += int(FClamp(float(Difference.Yaw), -TurnLimit, TurnLimit));

    CurrentRotation.Pitch = 0;

    CurrentRotation.Roll = 0;

    Difference = Normalize(WantedRotation - CurrentRotation);

    HeadingError = Abs(Difference.Yaw) * 360.0 / 65536.0;

    if (bOrbiting)
    {
        TargetSpeed = 0;
        if (bHeadingCalibrated && HeadingError < 15) TargetSpeed = OrbitSpeed;
        OrbitAngularSpeed += FClamp(TargetSpeed - OrbitAngularSpeed,
            -OrbitAcceleration * DT, OrbitAcceleration * DT);
        Weight = OrbitAngularSpeed / OrbitSpeed;
        Step = DT * OrbitAngularSpeed;
        Phase -= Step;
        CurrentRotation.Yaw -= int(Step * 65536.0 / 6.2831853);
        if (Phase < -6.2831853) Phase += 6.2831853;
    }
    else Weight = OrbitAngularSpeed / OrbitSpeed;

    CurrentOffset.X = Cos(Phase) * SafeRadius;

    CurrentOffset.Y = Sin(Phase) * SafeRadius;

    CurrentOffset.Z = OrbitHeight;

    Dragon.SetLocation(Wearer.Location + CurrentOffset);

    Dragon.SetRotation(CurrentRotation);
    if (BodyFx==None) BodyFx=Spawn(class'GoldenDragonBodyFxLink',Dragon);
    if (BodyFx!=None) BodyFx.UpdateEffects(DT);

    if (UpdatePoseBlend(DT)) return;

    WantedAnim = 'Idle';

    AnimationRate = 1;

    if (bOrbiting || Speed >= 8 || VSize(Wearer.Velocity) >= 8 || VSize(Wearer.Acceleration) >= 1)

        WantedAnim = 'Run';

    if (bOrbiting || bReturning)

    {

        AnimationRate = 0.65;

        if (bSwimAssetReady)

        {

            WantedAnim = 'OrbitCrawlV17';

            AnimationRate = 2.0 / FMax(OrbitPeriod, 1);

        }

    }

    // Keep original Run for the initial forward-axis calibration and asset fallback.
    if (WantedAnim == 'Run' && bRunAssetReady && bHeadingCalibrated)
    {
        WantedAnim = 'RunFlowV5';
        // Speed up the entire gait, keeping body and paws on the same phase.
        if (!bOrbiting && !bReturning) AnimationRate = 1.27;
    }

    Dragon.GetAnimParams(0, DragonAnim, Frame, Rate);

    if (!Wearer.bIsDead && Dragon.PlayAnimName == '' &&

        (WantedAnim != LastAnimation || DragonAnim != WantedAnim || AnimationRate != LastPlaybackRate))

    {

        Dragon.LoopAnim(WantedAnim, AnimationRate, FMax(BlendTime, 0.05));

        AnimStartCount++;

        LastAnimation = WantedAnim;

        LastPlaybackRate = AnimationRate;

    }

}



// 每帧先检查所属对象的停止或生命周期状态，失效时不继续访问效果资源。
simulated event Tick(float DT)

{

    local Guardian Host;

    if (bStopping)
        return;
    Host = Guardian(Owner);

    if (Host == None || Host.bDeleteMe)
    {
        StopWork(False);
        Destroy();
        return;
    }

    if (class'FxLifecyclePolicy'.static.GetHeroState(Hero(Host.OwnPlayer)) != 'Ready')
    {
        StopWork(True);
        Destroy();
        return;
    }
    if (!IsDragon(Host))
    {
        StopWork(False);
        Destroy();
    }

}



// 销毁时先停止所属增强或效果，再执行父类清理。
simulated event Destroyed()
{
    StopWork(False);
    Super.Destroyed();
}

defaultproperties

{

    bHidden=True

    RemoteRole=ROLE_None

    bCollideActors=False

    bBlockActors=False

    bBlockPlayers=False

    bEnableOrbit=True

    bUsePetSpacing=True

    bDebugTrace=False

    OrbitRadius=0

    OrbitHeight=30

    OrbitPeriod=2.625

    StandDelay=0.3

    BlendTime=0.7

    FacingYawOffset=0

    FollowPosition=(X=-1,Y=1,Z=0)

    DragonScale=1.0

    bPreserveSummonScale=True

    TurnSpeed=180

    BodyEnvelope=400

    SafetyGap=45

}



