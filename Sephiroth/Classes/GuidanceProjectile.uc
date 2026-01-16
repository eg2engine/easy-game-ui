class GuidanceProjectile extends SephirothProjectile;

var Actor Seek;
var bool bTouchOnlySeek;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = vector(Rotation)*Speed;
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (!bTouchOnlySeek || Other == Seek)
		Super.ProcessTouch(Other, HitLocation);
}

function HitWall(Vector HitNormal, Actor Wall)
{
	if (!bTouchOnlySeek)
		Super.HitWall(HitNormal, Wall);
}

//@BY WJ(04/04)
event LostChild(Actor Child)
{
	if(Child == Seek)
		Seek = None;
	else
		Super.LostChild(Child);
}

event Timer()
{
	local vector HitLocation, HitNormal;
	local vector CurrLocation, Start, End;
	local actor HitActor;
	
	Super.Timer();

	//@by wj(04/04)------
	if(Character(Seek) != None && Character(Seek).bIsDead)
	{
		Destroy();
		return;
	}

	if(SpawnEffect != None && SpawnEffect.Physics == PHYS_Trailer)
	{
		Start = Location;
		End = Start;
		End.Z -= 1000;

		HitActor = Trace(HitLocation, HitNormal, End, Start, true);
		if(HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor')))
		{
			CurrLocation.X = Location.X;
			CurrLocation.Y = Location.Y;
			CurrLocation.Z = HitLocation.z + FloatingOffsetZ;
			SetLocation(CurrLocation);
		}			
	}
	//-------------------
	
	if (bTouchOnlySeek) {
		if (Owner == None || Seek != None && Seek.IsA('Monster'))
			bCollideWorld = False;
	}

	if (Seek != None && !Seek.bDeleteMe) {
		SetRotation(rotator(Seek.Location - Location));
		Velocity = vector(Rotation)*Speed;
	}
}

defaultproperties
{
}
