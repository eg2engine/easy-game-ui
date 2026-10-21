class Active_BlastBlade extends MagicSplash;

var int DropCount;
var array<Actor> Drops;
var array<Actor> Explos;



event SetRadius(int Radius)
{
	local int i;
	local vector SpawnLoc;
	local Actor LocalDrop;
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local vector Start, End;
	local float EmitOffset;
    ;


	Start = Location;
	End = Start;
	End.Z -= 1000;
	HitActor = Trace(HitLocation, HitNormal, End, Start, true);

	if (DropClass != None && ExplosionClass != None) {
		SpawnLoc = Location;
		for (i = 0;i < DropCount;i++) {
			if (HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor'))) {
				EmitOffset = Location.Z - HitLocation.Z;
				SpawnLoc.Z += -1 * (EmitOffset - CollisionHeight/2);
			}
			LocalDrop = Spawn(DropClass,Self,,SpawnLoc);
            ;
			if (LocalDrop != None && !LocalDrop.bDeleteMe) {
				Drops[Drops.Length] = LocalDrop;
			}
		}
	}
}


event Destroyed()
{
	local int i;
	for (i=0;i<Drops.Length;i++) {
		if (Drops[i] != None) {
			Drops[i].Destroy();
			Drops[i] = None;
		}
	}

	Drops.Remove(0,Drops.Length);
	Super.Destroyed();
}

event LostChild(Actor Child)
{
	local int i;
	for (i=0;i<Drops.Length;i++) {
		if (Drops[i] != None && Child == Drops[i]) {
			Drops[i] = None;
			return;
		}
	}
}

defaultproperties
{
     DropCount=1
     DropClass=Class'ActiveFx.Active_BlastBlade_Loop'
     ExplosionClass=Class'ActiveFx.Active_BlastBlade_Explosion'
}
