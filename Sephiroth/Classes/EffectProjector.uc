class EffectProjector extends Projector;

var bool IsVoodoo;

simulated function PostBeginPlay()
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local vector Start, End, Loc;
	local float EmitOffset;
	local Rotator	Rot;

	Super.PostBeginPlay();

	if (Owner != None)
		IsVoodoo = bool(Owner.ConsoleCommand("IsVoodoo"));
	if (IsVoodoo)
		return;
		
	Start = Location;
	Loc = Location;
	End = Start;
	End.Z -= 1000;

	HitActor = Trace(HitLocation, HitNormal, End, Start, false);
	if (HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor'))) {
		EmitOffset = Location.Z - HitLocation.Z;
		Loc.Z += -1 * (EmitOffset-1000);
	}
	SetLocation(Loc);
	Rot.Pitch = -16384;
	SetRotation(Rot);
	DetachProjector(true);
	AttachProjector();
	ConsoleCommand("IncreaseEffectProjector");

	if (SpawnSound == None && SpawnSoundString != "")
		SpawnSound = Sound(DynamicLoadObject(SpawnSoundString,class'Sound'));

	if (SpawnSound != None)
		PlaySpawnSound(SpawnSound);
}

event Destroyed()
{
	ConsoleCommand("DecreaseEffectProjector");
	Super.Destroyed();
}

function PlaySpawnSound(Sound Snd)
{
//	PlaySound(Snd, SLOT_None, 3.0f, false, 128.f, 1.0f, false);
	PlaySound(Snd, SLOT_None, 3.0f, false, 512.f, 1.0f, false);
}

defaultproperties
{
     bProjectActor=False
     bStatic=False
     bUnlit=True
}
