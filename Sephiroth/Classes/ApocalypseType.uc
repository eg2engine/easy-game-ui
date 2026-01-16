class ApocalypseType extends Emitter;

var class<Actor> SpecialEffectClass;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (SpecialEffectClass != None) {
		Spawn(SpecialEffectClass,,,Location,Rotation);
	}
}

function PlaySpawnSound(Sound Snd)
{
//	PlaySound(Snd, SLOT_None, 1.0f, false, 128.f, 1.0f, false);
	PlaySound(Snd, SLOT_None, 10.0f, false, 512.f, 1.0f, false);
}

defaultproperties
{
     bNoDelete=False
     LifeSpan=1.000000
}
