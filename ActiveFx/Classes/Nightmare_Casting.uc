class Nightmare_Casting extends SepEmitter;

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 5, false, 128, 1, false);
}

defaultproperties
{
     AutoDestroy=True
     bNoDelete=False
     LifeSpan=1.000000
     SpawnSoundString="ActiveSound.Nightmare_Explosion"
}
