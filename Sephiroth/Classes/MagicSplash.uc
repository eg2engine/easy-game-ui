class MagicSplash extends Actor
	native;

var class<Actor> DropClass;
var Actor Drop;
var class<Actor> ExplosionClass;
var Actor Explosion;

event SetRadius(int Radius)
{
    ;

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
    ;
}

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 1.0f, false, 128.f, 1.0f, false);
}

event Destroyed()
{
    local Actor Fx;
    ;

    Fx = Drop;
    Drop = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    Fx = Explosion;
    Explosion = None;
    if (Fx != None && !Fx.bDeleteMe) Fx.Destroy();
    // Include children stored by subclasses in their own arrays.
    foreach ChildActors(class'Actor', Fx)
        if (Fx != None && !Fx.bDeleteMe && Fx.Owner == Self) Fx.Destroy();
    Super(Actor).Destroyed();
}

//hanullo---
event LostChild(Actor Child)
{
    local Actor Remaining;
    ;

    if (Child == Drop) Drop = None;
    if (Child == Explosion) Explosion = None;
    // Explicit-duration subclasses retain their original lifetime.
    if (bDeleteMe || LifeSpan > 0) return;
    foreach ChildActors(class'Actor', Remaining)
        if (Remaining != None && Remaining != Child && !Remaining.bDeleteMe && Remaining.Owner == Self) return;
    Destroy();
}
//---hanullo

defaultproperties
{
     bHidden=True
}
