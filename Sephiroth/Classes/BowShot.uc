class BowShot extends Projectile;

var Character Shooter;
var int ActionID;
var string SkillName;
var actor TargetActor;
var vector TargetLocation;
var actor HitActor;

var class<Emitter> TrailerClass;
var Emitter TrailerEffect;
var class<Emitter> HitClass;

var bool bGuided;
var bool bParabola;

var vector Dir, InitialDir;
var int Pitch;

var float InitTime;

var bool bTouchOnlySeek;

//jeh
var vector monsterPos;
//jeh

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = vector(Rotation) * Speed;
	if (TrailerClass != None) {
		TrailerEffect = Spawn(TrailerClass,Self,,,Rotation);
		TrailerEffect.SetPhysics(PHYS_Trailer);
		TrailerEffect.SetBase(Self);
	}
	Pitch = Rotation.Pitch;
	Dir = vector(Rotation);
	InitTime = Level.TimeSeconds;
}

event Destroyed()
{
	Super.Destroyed();
	if (TrailerEffect != None)
		TrailerEffect.Destroy();
}

event LostChild(Actor Child)
{
	Super.LostChild(Child);
	if (Child == TrailerEffect)
		TrailerEffect = None;
}

event ForcedTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	if (Other != None)
		ProcessTouch(Other, HitLocation);
	else
		Explode(HitLocation, HitNormal);
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other != Instigator) {
		if (Shooter != None && Other.IsA('Character'))
			Shooter.RangeHit_Detected(Other, HitLocation, SkillName, ActionID);
		Super.ProcessTouch(Other, HitLocation);
	}
}

/*
function HitWall(vector HitNormal, Actor Wall)
{
	if (Shooter != None)
		Shooter.RangeHit_Detected(None, Location + ExploWallOut * HitNormal, SkillName, ActionID);
	Super.HitWall(HitNormal, Wall);
}
*/

function Explode(vector HitLocation,vector HitNormal)
{
	if (HitClass != None)
		Spawn(HitClass,,,HitLocation);
	Destroy();
}

event Tick(float Delta)
{
	Super.Tick(Delta);

	if (TargetActor != None)
		monsterPos = TargetActor.Location;
	
	if (Level.TimeSeconds - InitTime > 0.1) {
		if (bGuided && TargetActor != None && !Character(TargetActor).bIsDead && !TargetActor.bDeleteMe)
			SetRotation(Rotator(monsterPos - Location));
	}
	/*
	if (Pitch < 4096 && bGuided && TargetActor != None && !TargetActor.bDeleteMe)
		SetRotation(Rotator(TargetActor.Location - Location));
	else {
		if (bGuided && TargetActor != None && !TargetActor.bDeleteMe)
			Destination = TargetActor.Location;
		else
			Destination = TargetLocation;

		Dummy = Destination - Shooter.Location;
		Dummy.Z = 0;
		DistanceOwnerToTarget = VSize(Dummy);
		Dummy = Location - Shooter.Location;
		Dummy.Z = 0;
		DistanceOwnerToSelf = VSize(Dummy);
		Rot = Rotation;
		if (DistanceOwnerToSelf < DistanceOwnerToTarget / 2.0f) {
			Rot.Pitch = Pitch - 1.5 * (DistanceOwnerToSelf / DistanceOwnerToTarget) * Pitch;
			if (Rot.Pitch < 0)
				Rot.Pitch = 0;
		}
		else {
			Rot.Pitch = (-1 * (DistanceOwnerToSelf / DistanceOwnerToTarget) * Pitch + 65536) % 65536;
		}
		SetRotation(Rot);
	}
	*/

	if (bTouchOnlySeek && TargetActor != None && TargetActor.IsA('Monster'))
		bCollideWorld = false;
	Velocity = Vector(Rotation) * Speed;
}

defaultproperties
{
     LifeSpan=5.000000
}
