class EffectAnimation extends Actor;

var Actor AnimHost;
var array< class<Actor> > EffectActorClasses;
var array<Actor> EffectActors;
var array<float> Timers;
var int CurrentAnim;
var bool bForcedDestroy;

function PostBeginPlay()
{
	local int i;
	Super.PostBeginPlay();
	if (EffectActorClasses.Length <= 0 || Timers.Length != EffectActorClasses.Length) {
		Destroy();
		return;
	}
	for (i=0;i<EffectActorClasses.Length;i++) {
		if (EffectActorClasses[i].Default.LifeSpan == 0) {
			Destroy();
			return;
		}
		LifeSpan += EffectActorClasses[i].Default.LifeSpan;
	}
}

event Destroyed()
{
	local int i;
	Super.Destroyed();
	bForcedDestroy = true;
	for (i=0;i<EffectActors.Length;i++) {
		if (EffectActors[i] != None) {
			EffectActors[i].Destroy();
			EffectActors[i] = None;
		}
	}
	EffectActors.Remove(0, EffectActors.Length);
}

event LostChild(Actor Lost)
{
	local int i;
	//Log(Self@"LostChild"@Lost);
	for (i=0;i<=CurrentAnim;i++) {
		if (Lost == EffectActors[i]) {
			EffectActors[i] = None;
			break;
		}
	}
}

function SpawnEffect(int Index)
{
	if (Index < EffectActorClasses.Length) {
		EffectActors[Index] = Spawn(EffectActorClasses[Index], Self, , Location, Rotation);
		SetTimer(Timers[Index], False);
	}
}

function StartAnimation(Actor Host)
{
	AnimHost = Host;
	if (EffectActorClasses[0] != None) {
		SpawnEffect(0);
		CurrentAnim = 0;
	}
}

event Timer()
{
	if (CurrentAnim+1 < EffectActorClasses.Length) {
		EffectTimerExpired(CurrentAnim);
		SpawnEffect(CurrentAnim+1);
		CurrentAnim++;
	}
	else
		EffectAnimationEnd();
}

function EffectTimerExpired(int Index);
function EffectAnimationEnd();

defaultproperties
{
     bHidden=True
     LifeSpan=20.000000
}
