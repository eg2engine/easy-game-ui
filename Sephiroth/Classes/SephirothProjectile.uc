class SephirothProjectile extends Projectile;

var class<Actor> SpawnEffectClass;
var class<Actor> DestroyEffectClass;
var Actor SpawnEffect;

var Character ProjOwner;
var bool bNotifyOwner;
var string ProjName;
var int ProjSequence;

const SpeedUp_None=0;
const SpeedUp_Additive=1;
const SpeedUp_Multiplicative=2;
var int SpeedUpType;
var float SpeedUpFactor;

//@by wj(04/04)
var float FloatingOffsetZ;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (SpawnEffectClass != None) {
		SpawnEffect = Spawn(SpawnEffectClass,Self,,Location,Rotation);
		if (SpawnEffect != None)
			SpawnEffect.SetBase(Self);
	}
	SetTimer(0.1, True);
}

function SetProjectileInfo(Character InOwner, string InName, int InSeq, optional bool bNotify)
{
	ProjOwner = InOwner;
	ProjName = InName;
	ProjSequence = InSeq;
	bNotifyOwner = bNotify;
}

event LostChild(Actor Lost)
{
	if (Lost == SpawnEffect)
		SpawnEffect = None;
}

event Destroyed()
{
	Super.Destroyed();
	if (SpawnEffect != None) {
		SpawnEffect.Destroy();
		SpawnEffect = None;
	}
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (bNotifyOwner && ProjOwner != None)
		ProjOwner.projHitActor(Other, HitLocation, ProjName, ProjSequence);
	Super.ProcessTouch(Other, HitLocation);
}

function HitWall(Vector HitNormal, Actor Wall)
{
	if (bNotifyOwner && ProjOwner != None)
		ProjOwner.projHitActor(None, Location + ExploWallOut * HitNormal, ProjName, ProjSequence);
	Super.HitWall(HitNormal, Wall);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (DestroyEffectClass != None)
		Spawn(DestroyEffectClass,,,HitLocation);
	Super.Explode(HitLocation, HitNormal);
}

simulated function Timer()
{
	switch (SpeedUpType) {
	case SpeedUp_None:
		break;
	case SpeedUp_Additive:
		Speed = Speed + SpeedUpFactor;
		break;
	case SpeedUp_Multiplicative:
		Speed = Speed * SpeedUpFactor;
		break;
	}
	Speed = Clamp(Speed, 0, MaxSpeed);
	Velocity = Vector(Rotation) * Speed;
}

defaultproperties
{
     FloatingOffsetZ=50.000000
     LifeSpan=5.000000
}
