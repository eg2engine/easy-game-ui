class MagicShot extends Projectile;

var character Shooter;
var int ActionID;
var string SkillName;
var actor TargetActor;
var vector TargetLocation;
//var actor HitActor;
var float Count, TrailerRate;
var float ValidDistance;
var bool bNoCheckHit;

var class<Actor> MeshTrailerClass;
var Actor MeshTrailerActor;
var class<Actor> TrailerClass;
var Actor TrailerActor;
var class<Actor> ExplosionClass;

//@by wj(04/04)
var float FloatingOffsetZ;

var bool bTouchOnlySeek;

enum ESpeedupType {
	ST_None,
	ST_Additive,
	ST_Multiplicative,
};
var ESpeedupType SpeedupType;
var float SpeedupFactor;

enum EFlyingType {
	FT_Straight,
	FT_Guided,
};
var EFlyingType FlyingType;

var bool bRotateMesh;
var Rotator MeshRotation;

function BeginPlay()
{
	Super.BeginPlay();
	// chkim 2009
	if (Level.DetailMode == DM_High && !Level.bDropDetail) 
		TrailerRate = 0.01;
	else 
		TrailerRate = 0.02;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = vector(Rotation) * Speed;
	if (MeshTrailerClass != None) {
		MeshTrailerActor = Spawn(MeshTrailerClass,Self,,Location,Rotation);
//		//Log(Self $ " " $ MeshTrailerActor);
		if (MeshTrailerActor != None) {
			//@by wj(03/21)
	//		MeshTrailerActor.SetPhysics(PHYS_Trailer);
			if(MeshTrailerActor.Physics == PHYS_Trailer)
				MeshTrailerActor.SetBase(Self);
		}
	}
	if( TrailerClass != None ) {
		//@by wj(03/21)
		TrailerActor = Spawn(TrailerClass,Self,,Location,Rotation);
		if(TrailerActor.Physics == PHYS_Trailer)
			TrailerActor.SetBase(Self);
	}
}

event LostChild(Actor Lost)
{
	if (Lost == TrailerActor)
		TrailerActor = None;
}

event Destroyed()
{
	Super.Destroyed();
	if (MeshTrailerActor != None)
		MeshTrailerActor.Destroy();
	if( TrailerActor != None )
		TrailerActor.Destroy();
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
//	//Log("ProcessTouch"@Other@HitLocation);
	if (Other != Instigator) {
		if (Shooter != None && Other.IsA('Character') && (ValidDistance == 0 || VSize(Other.Location-Shooter.Location) <= ValidDistance) && !bNoCheckHit)
			Shooter.RangeHit_Detected(Other, HitLocation, SkillName, ActionID);
		Super.ProcessTouch(Other, HitLocation);
	}
}

function HitWall(vector HitNormal, Actor Wall)
{
//	//Log("HitWall"@HitNormal@Wall);
	if (Shooter != None && !bNoCheckHit)
		Shooter.RangeHit_Detected(None, Location + ExploWallOut * HitNormal, SkillName, ActionID);
	Super.HitWall(HitNormal, Wall);
}

function Explode(vector HitLocation,vector HitNormal)
{
//	//Log(Self$ " Explode" $ " " $ HitLocation);
	if (ExplosionClass != None)
		Spawn(ExplosionClass,,,HitLocation);
	Destroy();
}

function AdjustLocation(vector Loc)
{
	SetLocation(Loc);
}

function SpawnTrailer()
{
/*	if (Speed == 0 && TrailerActor != None)
		return;
	TrailerActor = Spawn(TrailerClass);
	TrailerActor.SetPhysics(PHYS_Trailer);
*/
}

event Tick(float Delta)
{
	local Rotator Rot;
	local vector HitLocation, HitNormal;
	local vector CurrLocation, Start, End;
	local actor HitActor;

	Super.Tick(Delta);	

	//@by wj(04/04)------
	if(Character(TargetActor) != None && Character(TargetActor).bIsDead)
	{
		Destroy();
		return;
	}	

	if(TrailerActor != None && TrailerActor.Physics == PHYS_Trailer)
	{
		Start = Location;
		End = Start;
		End.Z -= 1000;		

		HitActor = Trace(HitLocation, HitNormal, End, Start, true);
		if(HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor')))
		{
			CurrLocation = Location;
			CurrLocation.Z = HitLocation.Z + FloatingOffsetZ;
			SetLocation(CurrLocation);
		}
	}
	//-------------------

	/*
	if (MeshTrailerActor != None) {
		MeshTrailerActor.SetLocation(Location);
	}
	*/
	/*
	if (TrailerClass != None) {
		Count += Delta;
		if (Count > FRand() * TrailerRate + TrailerRate) {
			SpawnTrailer();
			Count = 0;
		}
	}
	*/
	switch (SpeedupType) {
	case ST_Additive:
		Speed = Speed + (SpeedupFactor*Delta/0.05);
		if (Speed > MaxSpeed)
			Speed = MaxSpeed;
		if (Speed < 0)
			Speed = 0;
		break;
	case ST_Multiplicative:
		Speed = Speed * (SpeedupFactor*Delta/0.05);
		if (Speed > MaxSpeed)
			Speed = MaxSpeed;
		if (Speed < 0)
			Speed = 0;
		break;
	}

	switch (FlyingType) {
	case FT_Guided:
		if (TargetActor != None && !TargetActor.bDeleteMe) {
			Rot = Rotator(TargetActor.Location - Location);
			SetRotation(Rot);
		}
		break;
	}

	if (Mesh != None && bRotateMesh) {
		Rot = Rotation;
		Rot.Pitch += MeshRotation.Pitch;
		Rot.Yaw += MeshRotation.Yaw;
		Rot.Roll += MeshRotation.Roll;
		SetRotation(Rot);
	}

	if (bTouchOnlySeek && TargetActor != None && TargetActor.IsA('Monster'))
		bCollideWorld = false;

	Velocity = Vector(Rotation) * Speed;
}

defaultproperties
{
     FloatingOffsetZ=50.000000
     LifeSpan=5.000000
}
