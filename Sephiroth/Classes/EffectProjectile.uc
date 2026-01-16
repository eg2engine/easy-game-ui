////////////////////////////////////////////////////////////////////////////////////////////
//   
// EffectProjectile
// Description: MagicShot, BowShot, SephirothProjectile, GuidanceProjectile (type) Rewrite
// Date: 2003. 8. 4 ~ 
// Rewrited by jeong eui hoon   
//
////////////////////////////////////////////////////////////////////////////////////////////

class EffectProjectile extends Projectile;

var class<Actor> TrailerClass;
var class<Actor> ExplosionClass;

var character	Shooter;
var int			ActionID;
var string		SkillName; // projskillname
var Actor		TargetActor;
var vector		TargetLocation;
var Actor		TrailerActor;
var Rotator		MeshRotation;

var float		TrailerRate;
var float		ValidDistance;
var float		FloatingOffsetZ;
var float		SpeedupFactor;
var bool		bNoCheckHit;
var bool		bTouchOnlySeek;
var bool		bRotateMesh;
var bool		bGuided;

enum EffectDamageType {
	ED_Arrow,
	ED_SplitArrow,
	ED_Cloud,
	ED_Breath,
	ED_Apocalypse,
	ED_Shower
};

var byte DamageType;

enum ESpeedupType {
	ST_None,
	ST_Additive,
	ST_Multiplicative,
};
var ESpeedupType SpeedupType;

enum EFlyingType {
	FT_Straight,
	FT_Guided,
};
var EFlyingType FlyingType;

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
	local Vector initPos;

	Super.PostBeginPlay();
	Velocity = vector(Rotation) * Speed;
	if( TrailerClass != None ) {
		initPos = Location;
		initPos.Z = Location.Z + FloatingOffsetZ;
		TrailerActor = Spawn(TrailerClass,Self,,initPos,Rotation);
		if(TrailerActor.Physics == PHYS_Trailer)
			TrailerActor.SetBase(Self);
	}

	if (bActorShadows) {
		Shadow = Spawn(class'ShadowProjector',Self,,Location);
		//JH---
		if (Shadow != None && !Shadow.bDeleteMe) {
			ShadowProjector(Shadow).ShadowActor = Self;
			ShadowProjector(Shadow).LightDirection = Normal(vect(1,1,3));
			ShadowProjector(Shadow).LightDistance = 680;
			ShadowProjector(Shadow).MaxTraceDistance = 650;
			ShadowProjector(Shadow).UpdateShadow();
		}
		else
			Shadow = None;
		//---JH
	}
	//------------------------------------------------

//	//Log("PostBeginPlay ININ"@SpawnSoundString);

	if (SpawnSound == None && SpawnSoundString != "")
		SpawnSound = Sound(DynamicLoadObject(SpawnSoundString,class'Sound'));

//	//Log("PostBeginPlay ININ @@@@"@SpawnSoundString@SpawnSound);

	if (SpawnSound != None)
		PlaySpawnSound(SpawnSound);
}

function PlaySpawnSound(Sound Snd)
{
//	//Log(Self @ "PlaySpawnSound" @ Snd);
	PlaySound(Snd, SLOT_None, 4, false, 512, 1, false);
}

event LostChild(Actor Lost)
{
	if (Lost == TrailerActor)
		TrailerActor = None;
}

event Destroyed()
{
	Super.Destroyed();
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

function NotifyHit(Character Sht, Actor Target, vector HitLocation)
{
	if (!Character(Target).bIsDead)
		Sht.RangeHit_Detected(Target, HitLocation, SkillName, ActionID); // projskillname
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other != None && Other.IsA('Attachment'))
		return;
	
	//@by wj(040705)-----
	if (Other != None && Other.IsA('Guardian'))
		return;
	//-------------------

	if (Other != Instigator) 
	{
		// �� ����� �� ĳ�����̰� ���� Ÿ���� �ݵ�� ����/ĳ���� �̾�� �Ѵ�.
		if (Shooter != None && Shooter.IsA('Hero') && (Other.IsA('Monster') || Other.IsA('Hero') || Other.IsA('GuardStone') || Other.IsA('MatchStone')) && !bNoCheckHit)
		{
			switch (DamageType)
			{
			case 0: //ED_Arrow:
				if (Other == TargetActor) {
					NotifyHit(Shooter, Other, HitLocation);
					Explode(HitLocation, Normal(HitLocation - Other.Location));
				}
				return;
			case 1: //ED_SplitArrow:
				NotifyHit(Shooter, Other, HitLocation);
				Explode(HitLocation, Normal(HitLocation - Other.Location));
				return;
			case 2: //ED_Cloud:
				if (Other == TargetActor) {
					NotifyHit(Shooter, Other, HitLocation);
					Explode(HitLocation, Normal(HitLocation - Other.Location));
				}
				return;
			case 3: //ED_Breath:
				//if (Owner.IsA('EffectProjectile') && VSize(Other.Location - Owner.Location) <= EffectProjectile(Owner).ValidDistance) {
				if (ValidDistance == 0 || VSize(Other.Location - Shooter.Location) <= ValidDistance) {
					NotifyHit(Shooter, Other, HitLocation);
//					Explode(HitLocation, Normal(HitLocation - Other.Location));
				}
				return;
			case 4: //ED_Apocalypse:
				// �̰��� ���� ���ͼ��� �ȵȴ�.
//				//Log(Self @ "Strange Entrance" @ "ED_Apocalypse");
				break;
			case 5: //ED_Shower:
				// �̰��� ���� ���ͼ��� �ȵȴ�.
//				//Log(Self @ "Strange Entrance" @ "ED_Shower");
				break;
			}
			return;
		}

		// �� ����� ������ų�
		// ���Ͱ� �� �Ŷ��
		// Ÿ�ٿ� ������ �����Ѵ�.
		if (!bTouchOnlySeek || Other == TargetActor)
			Explode(HitLocation, Normal(HitLocation - Other.Location));
	}
}

function HitWall(vector HitNormal, Actor Wall)
{
	if (Shooter != None && !bNoCheckHit)
		Shooter.RangeHit_Detected(None, Location + ExploWallOut * HitNormal, SkillName, ActionID); // projskillname
	if (!bTouchOnlySeek)
		Super.HitWall(HitNormal, Wall);
}

function Explode(vector HitLocation,vector HitNormal)
{
	if (ExplosionClass != None)
		Spawn(ExplosionClass,,,HitLocation);
	Destroy();
}

function AdjustLocation(vector Loc)
{
	SetLocation(Loc);
}

event Tick(float Delta)
{
	local Rotator Rot;
	local vector monsterPos;
	local vector HitLocation, HitNormal;
	local vector CurrLocation, Start, End;
	local actor HitActor;

	monsterPos = TargetLocation;
	if (TargetActor != None)
		monsterPos = TargetActor.Location;

	if(Character(TargetActor) != None && Character(TargetActor).bIsDead)
	{
		Destroy();
		return;
	}	

	if(FloatingOffsetZ != 0 && TrailerActor != None && TrailerActor.Physics == PHYS_Trailer)
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

	if (bGuided)
		FlyingType=FT_Guided;
	switch (FlyingType) {
	case FT_Guided:
		if (TargetActor != None && !TargetActor.bDeleteMe) {
			Rot = Rotator(monsterPos - Location);
			SetRotation(Rot);
		}
		/*else if (TargetLocation != vect(0,0,0)) {
			Rot = Rotator(TargetLocation - Location);
			SetRotation(Rot);
		}*/
		break;
	}

	if (Mesh != None && bRotateMesh) {
		Rot = Rotation;
		Rot.Pitch += MeshRotation.Pitch;
		Rot.Yaw += MeshRotation.Yaw;
		Rot.Roll += MeshRotation.Roll;
		SetRotation(Rot);
	}

	if (bTouchOnlySeek) {
		if (TargetActor != None/* && TargetActor.IsA('Monster')*/)
			bCollideWorld = false;
	}

	Velocity = Vector(Rotation) * Speed;
}

function ProcessDanglings(Character C)
{
	local bool bFound;

	bFound = false;
	if (Instigator == C) {
//		//Log(Self$" --> Setting Instigator as None for "$C);
		Instigator = None;
		bFound = true;
	}
	if (Shooter == C) {
//		//Log(Self$" --> Setting Shooter as None for "$C);
		Shooter = None;
		bFound = true;
	}
	if (TargetActor == C) {
//		//Log(Self$" --> Setting TargetActor as None for "$C);
		TargetActor = None;
		bFound = true;
	}

	if (bFound)
		ProcessChildDanglings();
}

function ProcessChildDanglings();

defaultproperties
{
     FloatingOffsetZ=50.000000
     LifeSpan=5.000000
}
