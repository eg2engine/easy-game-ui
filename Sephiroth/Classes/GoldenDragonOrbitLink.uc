class GoldenDragonOrbitLink extends Actor config(GoldenDragonOrbit);

var config bool bEnableOrbit, bDebugTrace;
var config float OrbitRadius, OrbitHeight, OrbitPeriod, StandDelay, BlendTime;
var config int FacingYawOffset;
var Pet Dragon;
var Hero Wearer;
var float StillTime, Phase, Weight, ReportTime;
var vector PreviousOwnerLocation, CurrentOffset, SavedFollowOffset;
var rotator CurrentRotation;
var bool bInitialized, bOrbiting;
var name LastAnimation;
var int UpdateCount;
var float LastUpdateTime;

static function bool IsDragon(Pet P)
{
    local string Key;
    local int Dot;
    if (P == None || P.bDeleteMe || P.Mesh == None)
        return False;
    Key = Caps(string(P.Mesh));
    Dot = InStr(Key, ".");
    while (Dot >= 0)
    {
        Key = Mid(Key, Dot + 1);
        Dot = InStr(Key, ".");
    }
    return Key == "GOLDENDRAGON";
}

simulated function UpdateDragon(float DT)
{
    local vector FollowOffset, OrbitOffset, Desired, Delta, Tangent;
    local rotator WantedRotation, Difference;
    local name PlayerAnim, DragonAnim, WantedAnim;
    local float Frame, Rate, Alpha, Speed;
    local bool Standing, Teleported;

    UpdateCount++;
    LastUpdateTime = Level.TimeSeconds;
    Dragon = Pet(Owner);
    if (!IsDragon(Dragon))
    {
        Destroy();
        return;
    }
    Wearer = Hero(Dragon.Owner);
    if (Wearer == None || Wearer.bDeleteMe)
        return;
    DT = FMax(DT, 0.001);
    if (!bInitialized)
    {
        CurrentOffset = Dragon.Location - Wearer.Location;
        CurrentRotation = Dragon.Rotation;
        PreviousOwnerLocation = Wearer.Location;
        SavedFollowOffset = CurrentOffset << Wearer.Rotation;
        Phase = Atan(CurrentOffset.Y, CurrentOffset.X);
        bInitialized = True;
    }
    FollowOffset = SavedFollowOffset;
    Delta = Wearer.Location - PreviousOwnerLocation;
    Teleported = VSize(Delta) > 600;
    Speed = VSize(Delta) / DT;
    PreviousOwnerLocation = Wearer.Location;
    Wearer.GetAnimParams(0, PlayerAnim, Frame, Rate);
    Standing = !Wearer.bIsDead && !Wearer.bIsSit && !Wearer.bHidden
        && !Dragon.bHidden && Wearer.Physics != PHYS_Falling
        && VSize(Wearer.Velocity) < 8 && VSize(Wearer.Acceleration) < 1
        && Speed < 8 && PlayerAnim == Wearer.BasicAnim[0];
    if (Standing && bEnableOrbit && !Teleported)
        StillTime += DT;
    else
        StillTime = 0;
    bOrbiting = StillTime >= StandDelay && bEnableOrbit;
    Alpha = FClamp(DT / FMax(BlendTime, 0.05), 0, 1);
    if (bOrbiting)
    {
        Weight = FMin(1, Weight + DT / FMax(BlendTime, 0.05));
        Phase += DT * 6.2831853 / FMax(OrbitPeriod, 1);
        if (Phase > 6.2831853) Phase -= 6.2831853;
    }
    else
        Weight = FMax(0, Weight - DT / FMax(BlendTime, 0.05));
    OrbitOffset.X = Cos(Phase) * OrbitRadius;
    OrbitOffset.Y = Sin(Phase) * OrbitRadius;
    OrbitOffset.Z = OrbitHeight;
    Desired = (FollowOffset >> Wearer.Rotation) * (1-Weight) + OrbitOffset * Weight;
    if (Teleported)
    {
        Weight = 0;
        StillTime = 0;
        CurrentOffset = FollowOffset >> Wearer.Rotation;
        CurrentRotation = Wearer.Rotation;
    }
    else
        CurrentOffset += (Desired - CurrentOffset) * Alpha;
    WantedRotation = Wearer.Rotation;
    if (Weight > 0.01)
    {
        Tangent.X = -Sin(Phase);
        Tangent.Y = Cos(Phase);
        WantedRotation = Rotator(Tangent);
        WantedRotation.Yaw += FacingYawOffset;
    }
    Difference = Normalize(WantedRotation - CurrentRotation);
    CurrentRotation.Yaw += int(Difference.Yaw * Alpha);
    CurrentRotation.Pitch += int(Difference.Pitch * Alpha);
    CurrentRotation.Roll += int(Difference.Roll * Alpha);
    // Called from Pet.Tick; actual native update ordering needs in-client validation.
    Dragon.SetLocation(Wearer.Location + CurrentOffset);
    Dragon.SetRotation(CurrentRotation);

    WantedAnim = 'Idle';
    if (VSize(Wearer.Velocity) >= 8 || Speed >= 8 || VSize(Wearer.Acceleration) >= 1)
        WantedAnim = 'Run';
    Dragon.GetAnimParams(0, DragonAnim, Frame, Rate);
    if (!Wearer.bIsDead && Dragon.PlayAnimName == '' && Dragon.HasAnim(WantedAnim) && (WantedAnim != LastAnimation || DragonAnim != WantedAnim))
    {
        Dragon.PlayAnimName = '';
        Dragon.LoopAnim(WantedAnim, 1, FMax(BlendTime, 0.05));
        LastAnimation = WantedAnim;
    }

}

simulated event Tick(float DT)
{
    // Lifetime only: Pet.Tick owns motion updates, avoiding double stepping.
    if (!IsDragon(Pet(Owner)) || Owner.Owner == None || Owner.Owner.bDeleteMe) Destroy();
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bEnableOrbit=True
    bDebugTrace=False
    OrbitRadius=140
    OrbitHeight=35
    OrbitPeriod=5.5
    StandDelay=0.3
    BlendTime=0.4
    FacingYawOffset=0
}
