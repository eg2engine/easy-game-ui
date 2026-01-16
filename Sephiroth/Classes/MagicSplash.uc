class MagicSplash extends Actor
	native;

var class<Actor> DropClass;
var Actor Drop;
var class<Actor> ExplosionClass;
var Actor Explosion;

event SetRadius(int Radius)
{
	if (DropClass != None)
		Drop = Spawn(DropClass,Self);
	if (ExplosionClass != None)
		Explosion = Spawn(ExplosionClass,Self);
	if (Drop != None && Drop.IsA('Emitter')) {
		Emitter(Drop).Emitters[0].StartLocationRange.X.Min = -Radius;
		Emitter(Drop).Emitters[0].StartLocationRange.X.Max = Radius;
		Emitter(Drop).Emitters[0].StartLocationRange.Y.Min = -Radius;
		Emitter(Drop).Emitters[0].StartLocationRange.Y.Max = Radius;
		if (Emitter(Drop).Emitters.Length > 1) {
			Emitter(Drop).Emitters[1].StartLocationRange.X.Min = -Radius;
			Emitter(Drop).Emitters[1].StartLocationRange.X.Max = Radius;
			Emitter(Drop).Emitters[1].StartLocationRange.Y.Min = -Radius;
			Emitter(Drop).Emitters[1].StartLocationRange.Y.Max = Radius;
		}
	}
	if (Explosion != None && Explosion.IsA('Emitter')) {
		Emitter(Explosion).Emitters[0].StartLocationRange.X.Min = -Radius;
		Emitter(Explosion).Emitters[0].StartLocationRange.X.Max = Radius;
		Emitter(Explosion).Emitters[0].StartLocationRange.Y.Min = -Radius;
		Emitter(Explosion).Emitters[0].StartLocationRange.Y.Max = Radius;
		if (Emitter(Explosion).Emitters.Length > 1) {
			Emitter(Explosion).Emitters[1].StartLocationRange.X.Min = -Radius;
			Emitter(Explosion).Emitters[1].StartLocationRange.X.Max = Radius;
			Emitter(Explosion).Emitters[1].StartLocationRange.Y.Min = -Radius;
			Emitter(Explosion).Emitters[1].StartLocationRange.Y.Max = Radius;
		}
	}
}

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 1.0f, false, 128.f, 1.0f, false);
}

event Destroyed()
{
	if (Drop != None)
		Drop.Destroy();

	if (Explosion != None)
		Explosion.Destroy();

	Super.Destroyed();
}

//hanullo---
event LostChild(Actor Child)
{
	if (Drop != None && Child == Drop) {
		Drop = None;
	}
	else if (Explosion != None && Child == Explosion) {
		Explosion = None;
	}
}
//---hanullo

defaultproperties
{
     bHidden=True
}
