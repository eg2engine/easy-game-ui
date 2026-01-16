class SpiritType extends EffectAnimation;

var class<Actor> SpiritEffectClass;
var Actor SpiritEffect;
var string SpiritName;
var float SpiritRemainingTime;
var bool bSpiritCastEnd;
var vector HeadVector;

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 1, false, 128, 1, false);
}
 
function SummonSpirit(Actor Host, string Name)
{
	SpiritName = Name;
	StartAnimation(Host);
	Timers[Timers.Length] = SpiritRemainingTime;
}

event Destroyed()
{
	Super.Destroyed();
	if (SpiritEffect != None) {
		SpiritEffect.Destroy();
		SpiritEffect = None;
	}
}

event LostChild(Actor Lost)
{
	if (Lost == SpiritEffect) {
//		//Log(Self @ "LostChild" @ Lost @ SpiritEffect);
		SpiritEffect = None;
	}
	else
		Super.LostChild(Lost);
}

function EffectTimerExpired(int Index)
{
	if (Index == 0 && SpiritEffectClass != None) {
		SpiritEffect = Spawn(SpiritEffectClass, Self, , Location, Rotation);
//		//Log(Self @ "EffectTimerExpired" @ Index @ "Spawning" @ SpiritEffect);
	}
}

function EffectAnimationEnd()
{
	SetTimer(Timers[Timers.Length-1], False);
	if (AnimHost != None)
		Character(AnimHost).SpiritCastEnd(SpiritName);
	bSpiritCastEnd = true;
}

event Timer()
{
	if (!bSpiritCastEnd)
		Super.Timer();
	else if (SpiritEffect != None) {
//		//Log(Self @ "Timer" @ "Destroying" @ SpiritEffect);
		SpiritEffect.Destroy();
		SpiritEffect = None;
	}
}

defaultproperties
{
     SpiritRemainingTime=0.500000
}
