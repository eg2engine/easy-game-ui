class DesignedWeaponFxBase extends SepEffect;

// Keep the original weapon mesh and native attachment conventions.
// Particle positions are local to this effect; calibrate in the client.
var Emitter DetailFx;
var class<Emitter> DetailClass;
var Actor DetailAnchor;
var bool bDetailStructureInvalid;

simulated function TraceDetailStage(name Stage, int Value)
{
    local BlackGoldWeaponFxLink Link;
    Link = BlackGoldWeaponFxLink(Owner);
    if (Link != None && !Link.bDeleteMe)
        Link.TraceStage(Stage, Value);
}

// Record the failure immediately, without destroying actors inside the callback.
simulated function MarkDetailStructureInvalid()
{
    local BlackGoldWeaponFxLink Link;
    bDetailStructureInvalid = True;
    Link = BlackGoldWeaponFxLink(Owner);
    if (Link != None && !Link.bDeleteMe)
        Link.RememberInvalidDetail(DetailClass);
}

simulated function ClearDetailFx()
{
    local Emitter OldDetailFx;
    OldDetailFx = DetailFx;
    DetailFx = None;
    if (OldDetailFx != None && !OldDetailFx.bDeleteMe)
        OldDetailFx.Destroy();
}

simulated function bool CheckDetailFx()
{
    local Designed_GlaciesStickB_Particles BlueDetail;
    if (DetailFx == None)
        return False;
    if (DetailFx.bDeleteMe)
    {
        DetailFx = None;
        return False;
    }
    BlueDetail = Designed_GlaciesStickB_Particles(DetailFx);
    if (BlueDetail != None && !BlueDetail.ValidateStructure())
        MarkDetailStructureInvalid();
    if (bDetailStructureInvalid)
    {
        ClearDetailFx();
        return False;
    }
    return True;
}

// The attachment's displayed transform can differ from this actor's Location.
// Anchor particle simulation to the actual weapon actor.
simulated function SyncDetailTransform()
{
    local Actor Anchor;
    if (bDeleteMe || !CheckDetailFx())
        return;
    Anchor = DetailAnchor;
    if (Anchor == None)
        Anchor = Base;
    if (Anchor == None || Anchor.bDeleteMe)
    {
        DetailFx.bHidden = True;
        return;
    }
    DetailFx.SetLocation(Anchor.Location);
    // In-game markers confirmed +Z runs from the grip toward the blade tip.
    DetailFx.SetRotation(Anchor.Rotation);
    DetailFx.bHidden = bHidden || Anchor.bHidden;
}

// A caller controls retry frequency; Tick never creates replacement particles.
simulated function bool EnsureDetailFx()
{
    if (bDeleteMe || bDetailStructureInvalid || Level.NetMode == NM_DedicatedServer
        || DetailClass == None)
        return False;
    if (CheckDetailFx())
        return True;
    if (bDetailStructureInvalid)
        return False;
    TraceDetailStage('DetailSpawnBefore', 0);
    DetailFx = Spawn(DetailClass, Self,, Location, Rotation);
    if (DetailFx == None || DetailFx.bDeleteMe)
    {
        DetailFx = None;
        TraceDetailStage('DetailSpawnAfter', 0);
        return False;
    }
    TraceDetailStage('DetailSpawnAfter', 1);
    if (!CheckDetailFx())
        return False;
    // The weapon anchor supplies the explicit world transform.
    DetailFx.SetBase(None);
    SyncDetailTransform();
    return True;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    EnsureDetailFx();
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    SyncDetailTransform();
}

simulated event Destroyed()
{
    ClearDetailFx();
    Super.Destroyed();
}

defaultproperties
{
    bDivineItem=True
}
