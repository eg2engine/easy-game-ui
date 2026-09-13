class DesignedWeaponFxBase extends SepEffect;

// Keep the original weapon mesh and native attachment conventions.
// Particle positions are local to this effect; calibrate in the client.
var Emitter DetailFx;
var class<Emitter> DetailClass;
var Actor DetailAnchor;

// SepEffect native attachment can render at its base while its own Location
// remains stale. Anchor particle simulation to the actual weapon actor.
simulated function SyncDetailTransform()
{
    local Actor Anchor;
    Anchor = DetailAnchor;
    if (Anchor == None)
        Anchor = Base;
    if (Anchor == None || Anchor.bDeleteMe || DetailFx == None)
        return;
    DetailFx.SetLocation(Anchor.Location);
    // In-game markers confirmed +Z runs from the grip toward the blade tip.
    DetailFx.SetRotation(Anchor.Rotation);
    DetailFx.bHidden = bHidden || Anchor.bHidden;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Level.NetMode != NM_DedicatedServer && DetailClass != None)
    {
        DetailFx = Spawn(DetailClass, Self,, Location, Rotation);
        if (DetailFx != None)
        {
            // Explicit world transform avoids the stale SepEffect transform.
            DetailFx.SetBase(None);
            SyncDetailTransform();
        }
    }
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    SyncDetailTransform();
}

simulated event Destroyed()
{
    if (DetailFx != None)
    {
        DetailFx.Destroy();
        DetailFx = None;
    }
    Super.Destroyed();
}

defaultproperties
{
    bDivineItem=True
}
