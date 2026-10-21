//    : CA-style arrival, native friction braking; no pre-arrival queue slowdown.
// Public class/function names remain compatible with the cumulative main SPG.
// Original CA script source is evidence for the policy, not a binary ABI donor.
class MoveQueue extends Object;
struct Sample
{
    var vector Position, Acceleration;
    var rotator Facing;
    var float Speed, WalkScale, JumpSpeed, At;
    var bool Walking, Jumping;
};
var PlayerController Driver;
var Pawn BoundPawn;
var LevelInfo PawnLevel;
var MoveQueue Next;
var array<Sample> Items;
var Sample Anchor, Active;
var int Head,Count,Dropped,Expired,PeakCount,Packets;
var float LastWireSpeed,AppliedGroundSpeed,AppliedDesired;
var float FirstAt,LastAt,BufferDelay,PlayAt,LagSeconds,PlanRate;
var vector PlanStart,PlanEnd,LastPosition;
var bool HasAnchor,Playing,Moving,Driven,JumpPending;
var float PendingJumpZ;
var bool Idle,StopReceived;
var float LastMovingAt,LastReceiveAt;
var int IgnoredStationary;
// These belong to the whole movement epoch, never to an individual packet.
var bool EaseStarting, EaseStopping;
// An unchanged-position jump is an event, not a movement queue node.
var bool DirectJumpPending;
var float DirectJumpSpeed;


var float LatestRate;

var bool Recovering, HadWorld, HadActors, HadBlock, HadPlayers, HeadJumpStarted;
var Actor.EPhysics SavedPhysics;
var float SavedAirSpeed, BlockedFor, HeightBlockedFor, LastHeight;
var vector RecoveryEnd,RecoveryOrigin;
var int RecoveryStarts, RecoveryEnds;
var bool QueuedLaunchPending;
var float QueuedLaunchSpeed, QueuedLaunchAt;
// Airborne dead reckoning is bounded by receipt time, never by catch-up speed.
var vector AirDirection;
var float AirRate,AirWindow,AirStopAt;
var bool AirOwned,AirStopping,AirLandingGuard;
var vector AirWirePosition;
var float AirWireAt;
var bool AirHasWire;
var int AirTraceCount;
// Receipt-derived motion survives transient animation writes to Pawn.Velocity.
var vector AirWireDirection;
var float AirWireRate,AirWireWindow;
var float RecoveryNativeZ,AirLaunchUntil;
var float AirAppliedRate;
var vector AirAppliedDirection;
var bool AirNativeCarry;


// Remote presentation has independent movement and animation ownership.
// 1=ordinary, 2=advanced, 3=bow support. These fields never steer the pawn.
var name DisplaySequence;
var byte DisplayKind;
var int DisplaySerial;
var bool DisplayActive,DisplayEndSent;
var float DisplayNotBefore,DisplayDeadline;

function float HeightTolerance()
{
    if (Recovering) return 1;
    if (BoundPawn==None) return 4;
    // Ground-following capsule height need not equal a network sample to 4 units.
    return FMax(8,BoundPawn.CollisionHeight*0.5);
}
function bool HeightReached(vector Point,vector Origin)
{
    // Passing a rising/falling height counts, an unrelated airborne pose does not.
    // Flat ground waypoints do not constrain the height of a real jump above them.
    if (BoundPawn!=None && BoundPawn.Physics==PHYS_Falling && !Recovering)
    {
        if (Abs(Point.Z-Anchor.Position.Z)<=4) return True;
        if (Point.Z>Anchor.Position.Z) return Origin.Z>=Point.Z-HeightTolerance();
        return Origin.Z<=Point.Z+HeightTolerance();
    }
    return Abs(Point.Z-Origin.Z)<=HeightTolerance();
}
function bool BlockingAhead(vector Goal)
{
    local Actor Hit;
    local vector Pos,Normal,Extent;
    if (BoundPawn==None || Driver==None) return False;
    Extent.X=BoundPawn.CollisionRadius; Extent.Y=Extent.X;
    Extent.Z=FMax(1,BoundPawn.CollisionHeight-1);
    // The controller's trace remains independent of recovery collision flags.
    Hit=Driver.Trace(Pos,Normal,Goal,BoundPawn.Location,True,Extent);
    if (Hit==None || Normal.Z>=0.7) return False;
    return Hit.bBlockActors || Hit.bWorldGeometry || Hit==BoundPawn.Level || Hit.IsA('TerrainInfo');
}
// Probe just the local capsule and this frame's sweep, never the scene list.
function bool RecoveryClear(vector Goal)
{
    local Actor Hit;
    local vector Pos,Normal,Extent,Origin;
    if (BoundPawn==None || Driver==None) return False;
    Origin=BoundPawn.Location;
    Extent.X=BoundPawn.CollisionRadius; Extent.Y=Extent.X;
    Extent.Z=FMax(1,BoundPawn.CollisionHeight-1);
    if (VSize(Goal-Origin)<0.01) Goal.X+=0.25;
    // Both directions must be empty. A floor-first hit is not proof of clearance.
    Hit=Driver.Trace(Pos,Normal,Goal,Origin,True,Extent);
    if (Hit!=None) return False;
    Hit=Driver.Trace(Pos,Normal,Origin,Goal,True,Extent);
    return Hit==None;
}
function EndRecovery()
{
    if (!Recovering) return;
    Recovering=False; BlockedFor=0; HeightBlockedFor=0; RecoveryEnds++;
    if (BoundPawn==None || BoundPawn.bDeleteMe) return;
    BoundPawn.bCollideWorld=HadWorld;
    BoundPawn.SetCollision(HadActors,HadBlock,HadPlayers);
    BoundPawn.AirSpeed=SavedAirSpeed;
    // Never overwrite a control/death transition which already changed physics.
    if (BoundPawn.Physics==PHYS_Flying)
    {
        // Flying recovery owns a synthetic Z velocity. It is not a second
        // jump impulse and must never be carried into restored gravity.

        BoundPawn.Velocity.Z=0;
        BoundPawn.Acceleration.Z=0;
        BoundPawn.SetPhysics(SavedPhysics);
    }
}
function bool BeginRecovery()
{
    if (Recovering) return True;
    if (BoundPawn==None || BoundPawn.bDeleteMe || Driver==None || Driver.Player!=None
        || (BoundPawn.Physics!=PHYS_Walking && BoundPawn.Physics!=PHYS_Falling)) return False;
    HadWorld=BoundPawn.bCollideWorld; HadActors=BoundPawn.bCollideActors;
    HadBlock=BoundPawn.bBlockActors; HadPlayers=BoundPawn.bBlockPlayers;
    SavedPhysics=BoundPawn.Physics; SavedAirSpeed=BoundPawn.AirSpeed;
    RecoveryNativeZ=BoundPawn.Velocity.Z;
    RecoveryEnd=Active.Position; RecoveryOrigin=BoundPawn.Location;
    Recovering=True; RecoveryStarts++;
    // One ownership transition for a recovery segment, not a toggle each frame.
    BoundPawn.SetPhysics(PHYS_Flying);
    BoundPawn.SetCollision(False,False,False); BoundPawn.bCollideWorld=False;
    return True;
}
function RecoveryVelocity(float Dt,vector HorizontalVelocity)
{
    local vector Segment,Offset,Goal,V;
    local float LengthSquared,Along,ZRate,Distance,Scale;
    if (!Recovering || BoundPawn==None || BoundPawn.bDeleteMe || Dt<=0) return;
    if (BoundPawn.Physics!=PHYS_Flying) { EndRecovery(); return; }
    // A receipt/native transition can restore collision while the path is recovering.
    // Reassert only changed flags, retaining the original flags for cleanup.
    if (BoundPawn.bCollideWorld) BoundPawn.bCollideWorld=False;
    if (BoundPawn.bCollideActors || BoundPawn.bBlockActors || BoundPawn.bBlockPlayers)
        BoundPawn.SetCollision(False,False,False);
    Goal=BoundPawn.Location+HorizontalVelocity*Dt;
    Segment=Active.Position-Anchor.Position; Segment.Z=0;
    LengthSquared=Segment Dot Segment;
    if (LengthSquared>0.0001)
    {
        Offset=Goal-Anchor.Position; Offset.Z=0;
        Along=FClamp((Offset Dot Segment)/LengthSquared,0,1);
        Goal.Z=Anchor.Position.Z+(Active.Position.Z-Anchor.Position.Z)*Along;
    }
    else Goal.Z=Active.Position.Z;
    ZRate=Abs(Active.Position.Z-Anchor.Position.Z)/FMax(Active.At-Anchor.At,0.01);
    // Running/BUFF speed is horizontal and cannot authorize a vertical launch.
    // Preserve an existing natural fast fall instead of replacing it with run speed.
    if (ZRate<1) ZRate=FMax(Abs(BoundPawn.JumpZ),1);
    ZRate=FMin(ZRate,FMax(Abs(BoundPawn.JumpZ),FMax(Abs(RecoveryNativeZ),1)));
    V=HorizontalVelocity;
    V.Z=FClamp((Goal.Z-BoundPawn.Location.Z)/Dt,-ZRate,ZRate);
    // The engine advances ONE bounded velocity, in all axes. No SetLocation.
    Scale=1;
    if (BoundPawn.bIsWalking) Scale=FMax(BoundPawn.WalkingPct,0.01);
    BoundPawn.AirSpeed=FMax(VSize(V)/Scale,0.01); BoundPawn.DesiredSpeed=1;
    BoundPawn.Velocity=V; BoundPawn.Acceleration=Normal(V)*BoundPawn.AccelRate;
    Offset=RecoveryEnd-BoundPawn.Location; Offset.Z=0;
    Distance=VSize(Offset);
    // Collision ownership ends in free space, not only on a one-frame node match.
    // Keep the current vertical leg until its height is satisfied.
    if (VSize(BoundPawn.Location-RecoveryOrigin)>0.01
        && HeightReached(Active.Position,BoundPawn.Location)
        && RecoveryClear(BoundPawn.Location+HorizontalVelocity*Dt)) EndRecovery();
}

function Reset()
{
    DisplayActive=False; DisplayEndSent=False; DisplayKind=0;
    DisplaySequence=''; DisplayNotBefore=0; DisplayDeadline=0;
    DisplaySerial++;

    AirAppliedRate=0; AirAppliedDirection=vect(0,0,0); AirNativeCarry=False;
    RecoveryNativeZ=0; AirLaunchUntil=0;
    AirWireDirection=vect(0,0,0); AirWireRate=0; AirWireWindow=0;
    AirWirePosition=vect(0,0,0); AirWireAt=0; AirHasWire=False;
    AirDirection=vect(0,0,0); AirRate=0; AirWindow=0; AirStopAt=0;
    AirOwned=False; AirStopping=False; AirLandingGuard=False;
    EndRecovery(); BlockedFor=0; HeightBlockedFor=0; HeadJumpStarted=False; QueuedLaunchPending=False;
    EaseStarting=False; EaseStopping=False; DirectJumpPending=False;
    Head=0; Count=0; HasAnchor=False; Playing=False; Moving=False;
    Driven=False; JumpPending=False; Items.Length=0;
    BufferDelay=0; LatestRate=0; LagSeconds=0; Packets=0;
    Idle=True; StopReceived=False; LastMovingAt=0; LastReceiveAt=0;
}
function Dispose()
{
    Reset(); Driver=None; BoundPawn=None; PawnLevel=None; Next=None;
}
function Bind(PlayerController C)
{
    if (BoundPawn!=C.Pawn || (BoundPawn!=None && PawnLevel!=BoundPawn.Level))
    {
        Reset(); LastWireSpeed=0; BoundPawn=C.Pawn;
        if (BoundPawn!=None) PawnLevel=BoundPawn.Level;
    }
}
// Compatibility entry points: there is at most ONE latest destination.
function Pop()
{
    if (Count>0) Anchor=Active;
    Head=0; Count=0; HeadJumpStarted=False;
}
function EnsureSpace()
{
    if (Items.Length!=1) Items.Length=1;
    Head=0;
}
// Native CA/EG MoveTo with no Actor goal accepts the walking capsule radius.
// Retain stricter previous vertical/air/recovery guards rather than ending a jump.
function bool LatestReached(vector Point,vector Origin)
{
    local vector D;
    local float Radius;
    D=Point-Origin; D.Z=0; Radius=0.01;
    if (BoundPawn!=None && BoundPawn.Physics==PHYS_Walking && !Recovering)
        Radius=FMax(Radius,BoundPawn.CollisionRadius);
    return VSize(D)<=Radius && HeightReached(Point,Origin);
}
function bool PushAt(vector P,rotator R,float Speed,bool Walk,float Ratio,
    bool Jump,float JumpZ,vector Acc,float Now,vector Origin)
{
    local float Gap,Limit,OldSpeed,SampleGap,MeasuredRate;
    local vector D,OldVelocity,WireDelta,WireAccel,NextDirection;
    local bool Starting,WasIdle,Same,FreshWire,KeepAirRate;
    local Sample S;
    KeepAirRate=AirNativeCarry && AirOwned && !Recovering && !AirStopping
        && BoundPawn!=None && BoundPawn.Physics==PHYS_Falling
        && Now<AirLaunchUntil;
    if (Jump && LastWireSpeed>0) Speed=LastWireSpeed;
    if (!(Speed>0)) Speed=580;
    if (!(Ratio>0 && Ratio<=1)) Ratio=0.431035;
    if (!Jump) LastWireSpeed=Speed;
    WireDelta=P-LastPosition; WireDelta.Z=0;
    WireAccel=Acc; WireAccel.Z=0;
    WasIdle=!HasAnchor || Idle;
    D=P-LastPosition; D.Z=0;
    Same=HasAnchor && VSize(D)<=0.01 && Abs(P.Z-LastPosition.Z)<=4;
    Starting=WasIdle;
    Gap=Now-LastReceiveAt;
    if (Starting || !(Gap>0.001)) Gap=0.3;
    LastReceiveAt=Now; LastAt=Now; LastMovingAt=Now;
    S.Position=P; S.Facing=R; S.Speed=Speed;
    S.Walking=Walk; S.WalkScale=Ratio; S.Jumping=False;
    S.JumpSpeed=JumpZ; S.Acceleration=Acc; S.At=Now;
    D=P-Origin; D.Z=0;
    Limit=Speed;
    if (Walk) Limit*=Ratio;
    OldSpeed=0;
    if (BoundPawn!=None)
    { OldVelocity=BoundPawn.Velocity; OldVelocity.Z=0; OldSpeed=VSize(OldVelocity); }
    // A fresh endpoint during native braking continues motion; it is not a new start.
    Starting=WasIdle && OldSpeed<=0.01;
    // CA: distance / receive interval, capped by wire speed, retain motion speed.
    // Unlike its unconditional max(old speed), a slow buff must lower the cap.
    LatestRate=FMin(Limit,FMax(OldSpeed,VSize(D)/Gap));
    if (Starting && VSize(D)>0.01) LatestRate=Limit;
    if (AirLandingGuard && VSize(WireDelta)>0.01
        && (Normal(WireDelta) Dot AirDirection)<0.25)
        AirLandingGuard=False; // An actual received turn is not a stale endpoint.
    // A jump event does not advance the normal-move sample clock. It may
    // nevertheless observe motion since the last normal coordinate.
    SampleGap=Now-AirWireAt;
    FreshWire=AirHasWire && SampleGap>=0 && SampleGap<=AirWireWindow;
    if (!Recovering && BoundPawn!=None && (Jump || BoundPawn.Physics==PHYS_Falling))
    {
        SampleGap=Gap;
        if (AirHasWire)
        {
            // Jump-launch samples are events, not a second normal move clock.
            SampleGap=Now-AirWireAt;
            WireDelta=P-AirWirePosition; WireDelta.Z=0;
        }
        NextDirection=AirDirection;
        if (AirHasWire && VSize(WireDelta)>0.01) NextDirection=Normal(WireDelta);
        else if (Jump && VSize(WireAccel)>0.01) NextDirection=Normal(WireAccel);
        else if (Jump && FreshWire && AirWireRate>0.01) NextDirection=AirWireDirection;
        else if (OldSpeed>0.01) NextDirection=Normal(OldVelocity);
        else if (!HasAnchor && VSize(D)>0.01) NextDirection=Normal(D);
        AirOwned=True;
        AirWindow=FClamp(SampleGap*1.5,0.15,0.45);
        if (Jump || VSize(WireDelta)>0.01 || (!AirHasWire && OldSpeed>0.01))
        {
            AirDirection=NextDirection;
            // GroundSpeed is a ceiling, not the pawn's actual horizontal velocity.
            MeasuredRate=OldSpeed;
            if (AirHasWire && SampleGap>=0.05 && VSize(WireDelta)>0.01)
                MeasuredRate=VSize(WireDelta)/SampleGap;
            else if (Jump && FreshWire && AirWireRate>0.01)
                MeasuredRate=AirWireRate;
            // Receipts may change direction and speed ceilings, but their
            // interval average is not the current native startup velocity.
            // In particular, an attack transition writing zero is not a stop.
            if (KeepAirRate)
            {
                MeasuredRate=AirRate;
                if (OldSpeed>0.01 && Abs(OldSpeed-AirAppliedRate)>0.0001
                    && (Normal(OldVelocity) Dot AirAppliedDirection)>0.5)
                    MeasuredRate=OldSpeed;
            }
            if (VSize(AirDirection)>0.01) AirRate=FMin(Limit,FMax(MeasuredRate,0));
            else AirRate=0;
            AirStopping=False;
        }
        else if (!AirStopping)
        { AirStopping=True; AirStopAt=Now; }
        // A slow BUFF and walk mode lower the cap immediately, including while stopping.
        AirRate=FMin(AirRate,Limit);
        // At most 80 event records per bound actor; never a frame/scene scan.

    }
    if (!Jump)
    {
        // Always use received-to-received displacement, never distance from
        // the delayed display pawn. Stationary heartbeats invalidate motion.
        WireDelta=P-AirWirePosition; WireDelta.Z=0;
        SampleGap=Now-AirWireAt;
        if (AirHasWire && SampleGap>=0.05)
        {
            AirWireRate=FMin(Limit,VSize(WireDelta)/SampleGap);
            AirWireDirection=Normal(WireDelta);
            AirWireWindow=FClamp(SampleGap*1.5,0.15,0.45);
        }
        else if (!AirHasWire || VSize(WireDelta)<=0.01)
        { AirWireRate=0; AirWireDirection=vect(0,0,0); AirWireWindow=0; }
        if (AirHasWire && SampleGap>=0.05 && VSize(WireDelta)>0.01
            && BoundPawn!=None && BoundPawn.Physics==PHYS_Walking && !Recovering)
        {
            // A completed observation is not proof that the sender stopped.
            // In particular, WasIdle must not replace a real 0.8s receive gap
            // with 0.3s, or retain an older, faster display speed indefinitely.
            LatestRate=FMin(Limit,VSize(WireDelta)/SampleGap);
        }
        AirWirePosition=P; AirWireAt=Now; AirHasWire=True;
    }

    if (Jump)
    { DirectJumpPending=True; DirectJumpSpeed=JumpZ; }
    // Repeated coordinates carry metadata/jumps, never become historical nodes.
    Anchor=S; Anchor.Position=Origin; Anchor.At=Now-Gap;
    Active=S; LastPosition=P; HasAnchor=True; Playing=True;
    BufferDelay=0; LagSeconds=0; PlayAt=Now; FirstAt=Now;
    StopReceived=False; Head=0; Packets++;
    // Startup belongs to grounded locomotion, never to an airborne receipt.
    if (Starting && !Jump && BoundPawn!=None && BoundPawn.Physics!=PHYS_Falling)
    { EaseStarting=True; EaseStopping=False; }
    else if (EaseStopping) { EaseStopping=False; EaseStarting=False; }
    if (WasIdle && Same && !Jump)
    {
        // Standing/stop heartbeats must never pull a braking pawn back to its old point.
        Anchor=S; Active=S; Items.Length=0; Count=0; Idle=True;
        Moving=OldSpeed>0.01; EaseStarting=False; EaseStopping=False;
        LatestRate=0; StopReceived=True; return True;
    }
    if (LatestReached(P,Origin))
    {
        IgnoredStationary++; Items.Length=0; Count=0;
        Anchor=S; Active=S; FinishMotion(Origin);
    }
    else
    {
        EnsureSpace(); Items[0]=S; Count=1; PeakCount=Max(PeakCount,1);
        Idle=False;
    }
    return True;
}
function bool Push(vector P,rotator R,float Speed,bool Walk,float Ratio,
    bool Jump,float JumpZ,vector Acc)
{
    if (BoundPawn==None || Driver==None || Driver.Level==None) return False;
    return PushAt(P,R,Speed,Walk,Ratio,Jump,JumpZ,Acc,
        Driver.Level.TimeSeconds,BoundPawn.Location);
}
function vector Plan(float Dt,vector Origin,float Now)
{
    local vector D;
    local float Distance,AirAge,AirScale,AirLimit;
    local vector AirVelocity,SideError;
    JumpPending=DirectJumpPending;
    if (DirectJumpPending) PendingJumpZ=DirectJumpSpeed;
    DirectJumpPending=False;
    PlanStart=Origin; PlanEnd=Origin; PlanRate=0; Moving=False;
    BufferDelay=0; LagSeconds=0; PlayAt=Now;
    if (!HasAnchor || Dt<=0) return Origin;
    D=LastPosition-Origin; D.Z=0; Distance=VSize(D);
    // Step has not called DoJump yet. Do not mistake pre-launch Walking for
    // landing, consume the endpoint, or clear airborne ownership here.
    if (JumpPending && BoundPawn!=None && BoundPawn.Physics!=PHYS_Falling)
        return Origin;
    if (AirOwned && BoundPawn!=None && BoundPawn.Physics==PHYS_Falling && !Recovering)
    {
        // Vertical motion remains owned by native jump/gravity. A network point
        // is an observation, not a mandatory mid-air stop at its exact XY.
        AirAge=FMax(0,Now-FMax(LastReceiveAt,AirLaunchUntil-AirWindow));
        if (AirStopping) AirScale=FClamp(1-(Now-AirStopAt)/0.15,0,1);
        else if (Now<AirLaunchUntil) AirScale=1;
        else AirScale=FClamp(1-FMax(0,AirAge-AirWindow)/0.15,0,1);
        AirLimit=Active.Speed;
        if (Active.Walking) AirLimit*=Active.WalkScale;
        PlanRate=FMin(AirRate,AirLimit)*AirScale;
        SideError=D-AirDirection*(D Dot AirDirection);
        AirVelocity=AirDirection*PlanRate+SideError*2;
        if (PlanRate>0.01 && VSize(AirVelocity)>0.01)
        {
            // Lateral correction spends part of the same velocity budget.
            // There is no longitudinal chasing or reversal toward an old point.
            AirVelocity=Normal(AirVelocity)*PlanRate;
            PlanEnd=Origin+AirVelocity*Dt;
            Moving=True; Idle=False; Playing=True; AirLandingGuard=True;
        }
        else
        { Count=0; Idle=True; Playing=False; StopReceived=True; }
        return PlanEnd;
    }
    if (AirOwned && BoundPawn!=None && BoundPawn.Physics!=PHYS_Falling)
    { AirOwned=False; AirStopping=False; AirLaunchUntil=0; }
    if (AirLandingGuard && BoundPawn!=None && BoundPawn.Physics==PHYS_Walking && !Recovering)
    {
        SideError=D-AirDirection*(D Dot AirDirection);
        if ((D Dot AirDirection)<=0 && VSize(SideError)<=FMax(4,BoundPawn.CollisionRadius)
            && HeightReached(LastPosition,Origin))
        {
            // Air inertia can legitimately pass the last wire point. Do not
            // undo it on landing. Native ground friction still owns stopping.
            Count=0; Idle=True; Playing=False; StopReceived=True; LatestRate=0;
            return Origin;
        }
        AirLandingGuard=False;
    }
    if (LatestReached(LastPosition,Origin))
    {
        Count=0; Anchor=Active;
        FinishMotion(Origin);
        return Origin;
    }
    if (Idle) return Origin;
    Playing=True;
    PlanRate=LatestRate;
    if (Distance>0.01 && PlanRate>0)
    {
        PlanEnd=Origin+Normal(D)*FMin(Distance,PlanRate*Dt);
        Moving=True;
    }
    return PlanEnd;
}
// The engine brakes in <=30ms slices with 2*GroundFriction. This is
// a look-ahead distance only; the real local engine integrator does the easing.
// Ignoring its <10-unit speed cutoff overestimates distance by less than a
// small tail, so no synthetic acceleration is needed to hit an exact pixel.
function float BrakeDistance(float Speed,float Dt,float Friction)
{
    local float Left,Slice,V,Average,Factor;
    if (Dt<=0 || Friction<=0 || Speed<=0) return 0;
    Left=FMin(Dt,0.1); V=1;
    while (Left>0.000001)
    {
        Slice=FMin(Left,0.03);
        V*=FMax(0,1-2*Friction*Slice);
        Average+=V*Slice;
        Left-=Slice;
    }
    Factor=FClamp(Average/FMin(Dt,0.1),0,0.9999);
    return Speed*Factor*FMin(Dt,0.1)/FMax(1-Factor,0.0001);
}
function bool UseNativeEase(float Dt,float Speed,float WantedSpeed,float Remaining,
    float Friction,bool Grounded)
{
    // CA MoveTo stops steering when reached; native physics then owns braking.
    // Do not apply the old queue's synthetic pre-arrival slowdown curve.
    EaseStopping=False;
    if (!Grounded || Idle) return False;
    if (EaseStarting && Moving && WantedSpeed>0.01 && Speed>=WantedSpeed-0.01)
        EaseStarting=False;
    return EaseStarting && Moving;
}
function FinishMotion(vector Origin)
{
    local vector D;
    D=LastPosition-Origin; D.Z=0;
    // No caller may clear pending route nodes simply by matching the newest end.
    if (!HasAnchor || Count>0 || !LatestReached(LastPosition,Origin)) return;
    Active=Anchor;
    Idle=True; Playing=False; Moving=False; StopReceived=True;
    Items.Length=0; Head=0; Count=0; Packets=0;
    EaseStarting=False; EaseStopping=False;
    LagSeconds=0; BufferDelay=0; LatestRate=0;
    if (Driver!=None && Driver.Level!=None) PlayAt=Driver.Level.TimeSeconds;
}
function Step(float Dt,bool KeepFacing)
{
    local vector V,Horizontal,ToStop;
    local rotator R;
    local float Scale,Speed,Friction,Remaining,StopSpeed,GravityZ;
    local bool NativeEase, WasWalking, WasFalling, WasGrounded;
    local Actor LaunchBase;
    local vector PreviousStep,ActualStep,ProbeGoal;
    local float Expected,Progress,AirCap;
    if (Dt<=0 || BoundPawn==None || Driver==None || Driver.Level==None) return;
    if (BoundPawn.bDeleteMe || Driver.bDeleteMe || Driver.Player!=None) return;
    BoundPawn.bCanStrafe=True;
    // Native physFalling has already integrated AirControl since our last
    // write. Carry that result instead of erasing it with the receipt snapshot.
    // A zero from an animation transition cannot discard received momentum.
    if (AirNativeCarry && AirOwned && BoundPawn.Physics==PHYS_Falling
        && !Recovering && !AirStopping && Driver.Level.TimeSeconds<AirLaunchUntil)
    {
        Horizontal=BoundPawn.Velocity; Horizontal.Z=0; Speed=VSize(Horizontal);
        AirCap=Active.Speed;
        if (Active.Walking) AirCap*=Active.WalkScale;
        if (Speed>0.01 && Abs(Speed-AirAppliedRate)>0.0001
            && (Normal(Horizontal) Dot AirAppliedDirection)>0.5)
            AirRate=FMin(AirCap,Speed);
    }
    PreviousStep=PlanEnd-PlanStart; PreviousStep.Z=0; Expected=VSize(PreviousStep);
    ActualStep=BoundPawn.Location-PlanStart; ActualStep.Z=0;
    Progress=ActualStep Dot Normal(PreviousStep);
    if (!DirectJumpPending && !Recovering && !Idle && Moving && Expected>0.001
        && (BoundPawn.Physics==PHYS_Walking || BoundPawn.Physics==PHYS_Falling))
    {
        // Falling must be stationary in Z too: never hijack a real jump or fall.
        if (Progress<FMin(Expected*0.1,0.5) && VSize(ActualStep)<FMin(Expected*0.1,0.5)
            && (BoundPawn.Physics==PHYS_Walking || Abs(BoundPawn.Location.Z-LastHeight)<0.5))
            BlockedFor+=FMin(Dt,0.1);
        else BlockedFor=0;
        // Floor-first hits and trace masks can hide a real native movement blocker.
        // A full second of actual immobility is independently sufficient evidence.
        if (BlockedFor>=1.0) BeginRecovery();
        else if (BlockedFor>=0.5 && BoundPawn.Physics==PHYS_Walking)
        {
            ProbeGoal=BoundPawn.Location+Normal(PreviousStep)*FMax(Expected*2,BoundPawn.CollisionRadius*2);
            if (BlockingAhead(ProbeGoal)) BeginRecovery();
        }
    }
    else BlockedFor=0;
    // Actual external relocation invalidates the old path, not received distance.
    if (Driven && VSize(BoundPawn.Location-PlanStart)>VSize(PlanEnd-PlanStart)+2000)
    { Reset(); return; }
    Plan(Dt,BoundPawn.Location,Driver.Level.TimeSeconds);
    if (!HasAnchor) return;
    if (Moving && BoundPawn.Physics==PHYS_None) BoundPawn.SetPhysics(PHYS_Walking);
    if (JumpPending)
    {
        // Preserve the received jump impulse even if the preceding sample walked.
        if (Recovering) EndRecovery();
        if (BoundPawn.Physics==PHYS_None) BoundPawn.SetPhysics(PHYS_Walking);
        WasFalling=BoundPawn.Physics==PHYS_Falling;
        WasWalking=BoundPawn.bIsWalking; BoundPawn.bIsWalking=False;
        WasGrounded=BoundPawn.Physics==PHYS_Walking;
        LaunchBase=BoundPawn.Base;
        BoundPawn.JumpZ=PendingJumpZ; BoundPawn.DoJump(True);
        BoundPawn.bIsWalking=WasWalking;
        if (BoundPawn.Physics==PHYS_Falling)
        {
            if (!WasFalling)
            {
                // A successful takeoff ends this remote ground-start epoch.
                // Do not carry startup/braking or grounded blocker history
                // through the air and into the next consecutive jump.
                AirOwned=True; AirStopping=False; AirNativeCarry=False;
                EaseStarting=False; EaseStopping=False;
                BlockedFor=0; HeightBlockedFor=0;
                LastHeight=BoundPawn.Location.Z;
                // Static bases cannot supply platform momentum. Pawn.DoJump
                // otherwise adds Base.Velocity.Z even for a static mesh roof.
                if (WasGrounded && LaunchBase!=None && LaunchBase.bStatic && !LaunchBase.bWorldGeometry)
                    BoundPawn.Velocity.Z=PendingJumpZ;
                // A real jump lasts longer than one normal upload interval.
                // Keep its horizontal momentum until the expected landing time;
                // explicit stop samples still brake immediately in Plan.
                AirLaunchUntil=0;
                if (BoundPawn.PhysicsVolume!=None)
                {
                    GravityZ=Abs(BoundPawn.PhysicsVolume.Gravity.Z);
                    if (GravityZ>=1 && BoundPawn.Velocity.Z>0)
                        AirLaunchUntil=Driver.Level.TimeSeconds
                            +2*BoundPawn.Velocity.Z/GravityZ;
                }
            }
            if (AirOwned) Plan(Dt,BoundPawn.Location,Driver.Level.TimeSeconds);
        }
        else Plan(Dt,BoundPawn.Location,Driver.Level.TimeSeconds);
    }
    BoundPawn.bIsWalking=Active.Walking; BoundPawn.WalkingPct=Active.WalkScale;
    Driver.Destination=LastPosition;
    if (!KeepFacing)
    { R=BoundPawn.Rotation; R.Yaw=Active.Facing.Yaw; BoundPawn.SetRotation(R); }
    if (AirOwned && BoundPawn.Physics==PHYS_Falling && !Recovering)
    {
        V=(PlanEnd-BoundPawn.Location)/Dt; V.Z=0;
        AppliedGroundSpeed=Active.Speed; AppliedDesired=1;
        BoundPawn.GroundSpeed=AppliedGroundSpeed; BoundPawn.DesiredSpeed=1;
        BoundPawn.Velocity.X=V.X; BoundPawn.Velocity.Y=V.Y;
        BoundPawn.Acceleration=Normal(V)*BoundPawn.AccelRate;
        // Local start-jumps can begin below the movement epsilon. Preserve
        // their input acceleration so native air physics can actually start.
        if (VSize(V)<=0.01 && !AirStopping
            && Driver.Level.TimeSeconds<AirLaunchUntil && VSize(AirDirection)>0.01)
            BoundPawn.Acceleration=AirDirection*BoundPawn.AccelRate;
        AirAppliedRate=VSize(V);
        AirAppliedDirection=Normal(V);
        if (AirAppliedRate<=0.01) AirAppliedDirection=AirDirection;
        AirNativeCarry=True;
        LastHeight=BoundPawn.Location.Z;
        HeightBlockedFor=0;
        Driven=True;
        return;
    }
    AirNativeCarry=False;
    if (Idle && !Recovering)
    {
        // Native MoveTo arrival clears Acceleration, not horizontal Velocity.
        // DesiredSpeed stays enabled so calcVelocity uses friction instead of
        // an immediate zero-speed cap. Gravity and live jump Z remain native.
        AppliedGroundSpeed=Active.Speed; AppliedDesired=1;
        BoundPawn.GroundSpeed=AppliedGroundSpeed; BoundPawn.DesiredSpeed=1;
        BoundPawn.Acceleration=vect(0,0,0);
        Horizontal=BoundPawn.Velocity; Horizontal.Z=0;
        Moving=VSize(Horizontal)>0.01;
        Driven=True;
        return;
    }
    V=(PlanEnd-BoundPawn.Location)/Dt; V.Z=0;
    Scale=1;
    if (Active.Walking) Scale=Active.WalkScale;
    AppliedGroundSpeed=Active.Speed;
    AppliedDesired=1;
    if (Moving) AppliedGroundSpeed=FMax(VSize(V)/Scale,0.01);
    else AppliedDesired=0;
    BoundPawn.bCanStrafe=True;
    BoundPawn.GroundSpeed=AppliedGroundSpeed; BoundPawn.DesiredSpeed=AppliedDesired;
    Horizontal=BoundPawn.Velocity; Horizontal.Z=0; Speed=VSize(Horizontal);
    ToStop=LastPosition-BoundPawn.Location; ToStop.Z=0; Remaining=VSize(ToStop);
    if (BoundPawn.PhysicsVolume!=None) Friction=BoundPawn.PhysicsVolume.GroundFriction;
    NativeEase=UseNativeEase(Dt,Speed,VSize(V),Remaining,Friction,
        BoundPawn.Physics==PHYS_Walking);
    if (EaseStopping && NativeEase)
    {
        // Shape the final speed by remaining distance using the same native
        // friction curve. Keep moving until arrival instead of braking to zero
        // short of the endpoint and having to start again to finish the path.
        StopSpeed=FMin(VSize(V),Remaining/FMax(Dt+BrakeDistance(1,Dt,Friction),Dt));
        if (Speed>0.01) StopSpeed=FMin(StopSpeed,Speed);
        V=Normal(V)*StopSpeed;
        AppliedGroundSpeed=FMax(StopSpeed/FMax(Scale,0.01),0.01);
        AppliedDesired=1;
        BoundPawn.GroundSpeed=AppliedGroundSpeed; BoundPawn.DesiredSpeed=1;
        BoundPawn.Velocity.X=V.X; BoundPawn.Velocity.Y=V.Y;
        BoundPawn.Acceleration=Normal(V)*BoundPawn.AccelRate;
        Moving=StopSpeed>0;
    }
    else
    {
        if (!NativeEase)
        { BoundPawn.Velocity.X=V.X; BoundPawn.Velocity.Y=V.Y; }
        else if (EaseStarting && Moving && Speed<0.001 && VSize(V)>0.01)
        {
            // Open the velocity-only native physics gate; native acceleration
            // still owns the real startup. This is not an instant running speed.
            Horizontal=Normal(V)*FMin(VSize(V),0.001);
            BoundPawn.Velocity.X=Horizontal.X; BoundPawn.Velocity.Y=Horizontal.Y;
        }
        BoundPawn.Acceleration=Normal(V)*BoundPawn.AccelRate;
    }
    if (!Recovering && Count>0 && BoundPawn.Physics==PHYS_Walking
        && !HeightReached(Active.Position,BoundPawn.Location)
        && Abs(BoundPawn.Location.Z-LastHeight)<0.5) HeightBlockedFor+=FMin(Dt,0.1);
    else HeightBlockedFor=0;
    LastHeight=BoundPawn.Location.Z;
    if (HeightBlockedFor>=0.5) BeginRecovery();
    if (Recovering) RecoveryVelocity(Dt,V);
    Driven=True;
}


function bool AllowDisplay(byte Kind,float Now)
{
    local name Sequence;
    local float Frame,Rate;
    if (BoundPawn==None || BoundPawn.bDeleteMe) return False;
    if (!DisplayActive) return True;
    BoundPawn.GetAnimParams(0,Sequence,Frame,Rate);
    if (Sequence!=DisplaySequence || Now>DisplayDeadline)
    { DisplayActive=False; return True; }
    if (Frame>=0 && !BoundPawn.IsAnimating(0) && Now>=DisplayNotBefore)
    { DisplayActive=False; return True; }
    // Advanced casts replace ordinary/support immediately. Ordinary packets
    // are discarded during advanced/support, never queued to play afterwards.
    if (Kind==2) return True;
    if (Kind==3) return DisplayKind==1;
    return DisplayKind==1;
}
function NoteDisplay(byte Kind,name Expected,float Now)
{
    local name Sequence;
    local float Frame,Rate,Duration;
    if (BoundPawn==None || BoundPawn.bDeleteMe) return;
    BoundPawn.GetAnimParams(0,Sequence,Frame,Rate);
    // A failed/missing animation start cannot acquire the display lane.
    if (Sequence!=Expected || Expected=='') return;
    Duration=0;
    if (Rate>0 && Rate<1000) Duration=1.0/Rate;
    DisplaySequence=Sequence; DisplayKind=Kind;
    DisplaySerial++; DisplayActive=True; DisplayEndSent=False;
    DisplayNotBefore=Now+Duration;
    DisplayDeadline=Now+FMax(Duration+1.3,1.3);
}
function bool TakeDisplayEnd(float Now)
{
    local name Sequence;
    local float Frame,Rate;
    // Support's original AnimEnd arms its acknowledgement timer. Do not arm it
    // twice; its active clip still participates in admission/priority above.
    if (!DisplayActive || DisplayEndSent || DisplayKind==3 || BoundPawn==None || BoundPawn.bDeleteMe) return False;
    BoundPawn.GetAnimParams(0,Sequence,Frame,Rate);
    if (Sequence!=DisplaySequence) { DisplayActive=False; return False; }
    // No restarting active clips, guessing hit counts, or interrupting tweens.
    if (Frame<0 || BoundPawn.IsAnimating(0) || Now<DisplayNotBefore) return False;
    DisplayEndSent=True;
    return True;
}

defaultproperties
{
}
