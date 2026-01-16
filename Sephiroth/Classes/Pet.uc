class Pet extends Actor
	native;

#exec obj load file=../Animations/PetPkg.ukx Package=PetPkg

var name PlayAnimName;

var name MeshName;
var name AnimationName;

var INT PetPosition;

var vector LocationOffset;

var bool bBalloon;
var string BalloonString;
var float BalloonTick;
var float BalloonDuration;

var bool bChangePosition;

var Emitter GlowEffect;
var INT PetHeight;
var INT PetRadius;
var bool bJump;

// 2023/7/17
var string tmp, Atext;
var name NullName;


//enum PositionType{
//	LeftStand,
//	RightStand
//};

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native final function bool LoadModel(string NewMeshName, string NewAnimName);

// 2023/7/17
final function name StrToName(string AString)
{
	local Name TempName;
	tmp = AString;
	SetPropertyText("NullName",GetPropertyText("tmp"));
	TempName = NullName;
	NullName = '';
	tmp = "";
	return TempName;
}



function InitPetSize()
{
	if( MeshName == 'Puppy_Black' || MeshName == 'Puppy_White' || MeshName == 'Puppy_Brown' )
	{
		PetHeight = 21;
		PetRadius = 55;
	}
	else if(MeshName == 'Crid')
	{
		PetHeight = 53;
		PetRadius = 65;
	}
	else if(MeshName == 'GreenSkink')
	{
		PetHeight = 28;
		PetRadius = 70;
	}
	else if(MeshName == 'Martis')
	{
		PetHeight = 26;
		PetRadius = 55;
	}
	else if(MeshName == 'Coro')
	{
		PetHeight = 18;
		PetRadius = 65;
	}
}

function SetOffsetZ()
{
	local float OffsetZ;
	local vector Start, End;
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local vector TempLocation;

	if( MeshName == 'Egg' )
		return;
	
	if( bJump )
		return;

	if( Owner != None )
	{
		Start = Location;
		End = Start;
		Start.Z += 200;
		End.Z -= 1000;

		HitActor = Trace(HitLocation, HitNormal, End, Start, False);
		if( HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor')) )
		{
			OffsetZ = Owner.Location.Z - HitLocation.Z;
			if( abs(OffsetZ) > Pawn(Owner).CollisionHeight * 2 )
				OffsetZ = (OffsetZ / abs(OffsetZ)) * (Pawn(Owner).CollisionHeight);
		}
		//TempLocation = RelativeLocation;
		TempLocation = LocationOffset;
		TempLocation.Z = -OffsetZ + (PetHeight);
		SetRelativeLocation(TempLocation);
	}
}

function SetPosition(INT Position)
{	
	local vector Offset;
	if( MeshName == 'Egg' )
		return;
	
	switch(Position)
	{
		case 0://PositionType.LeftStand:
			if( PetPosition == 0 )//PositionType.LeftStand)
				return;
			Offset.Y = -1 * PetRadius;
			LocationOffset = Offset;
			break;

		case 1://PositionType.RightStand:
			if( PetPosition == 1 )//PositionType.RightStand)
				return;
			Offset.Y = PetRadius;
			LocationOffset = Offset;
			break;
	}
	PetPosition = Position;
	SetOffsetZ();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();	
	
	SetTimer(1,True);
}

function Timer()
{
//	SetOffsetZ();
}

function bool ChangePetMesh(string NewMeshName, string NewAnimName)
{
	if( LoadModel(NewMeshName, NewAnimName) )
	{
		// manage Shadow
		if( NewMeshName != "Egg" )
		{
			if ( Shadow != None && !Shadow.bDeleteMe ) 
			{
				ShadowProjector(Shadow).ShadowActor = Self;
				ShadowProjector(Shadow).UpdateShadow();
			}
		}
		else if (Shadow != None) 
		{
			Shadow.DetachProjector(True);
		}

//		MeshName = name(NewMeshName);
		MeshName = StrToName(NewMeshName);
//		AnimationName = name(NewAnimName);
		AnimationName = StrToName(NewAnimName);
		InitPetSize();
		if( PetPosition == -1 )
			SetPosition(0);
		else 
			SetPosition(PetPosition);
		return True;
	}
	return False;
}

event NetRecv_PetAction(string ActionName)
{
//	PET_PlayAction(name(ActionName));
	PET_PlayAction(StrToName(ActionName));
}


event AnimEnd(int Channel)
{
	local float AnimRate, AnimFrame;
	local name AnimName;

	if ( MeshName == 'Egg' )
		return;

	GetAnimParams(0, AnimName, AnimFrame, AnimRate);

	if ( AnimName != '' && AnimName == PlayAnimName )
		PlayAnimName = '';

	if ( Hero(Owner).Base != None ) 
	{
		if ( Hero(Owner).Acceleration == vect(0,0,0) ) 
		{
			if ( PET_AlreadyPlayingWaiting(AnimName) )
				PET_PlayWaiting();
			else
				PET_TweenToWaiting(0.01);
		}
		else if (Hero(Owner).bIsWalking) 
		{
			if ( PET_ShouldTweenToMoving(AnimName) )
				PET_TweenToWalking(0.01);
			else
				PET_PlayWalking();
		}
		else 
		{
			if ( PET_ShouldTweenToMoving(AnimName) )
				PET_TweenToRunning(0.01);
			else
				PET_PlayRunning();
		}
	}
//	else if (Hero(Owner).Physics == PHYS_Falling)
//		PET_PlayInAir();
}

event Tick(float DeltaSeconds)
{
	local float AnimRate, AnimFrame, OwnerAnimRate, OwnerAnimFrame;
	local name AnimName, OwnerAnimName;

	if ( MeshName == 'Egg' )
		return;

	GetAnimParams(0, AnimName, AnimFrame, AnimRate);
	Hero(Owner).GetAnimParams(0, OwnerAnimName, OwnerAnimFrame, OwnerAnimRate);
	if( OwnerAnimName == Hero(Owner).BasicAnim[3] )
		PET_PlayInAir();

	// �־׼��� �ϴ� �߿��� �ٸ� ������ ���� �ʴ´�.
	if ( AnimName != '' && AnimName == PlayAnimName && Owner.Acceleration == vect(0,0,0) )
		return;

	if ( Owner.Base != None ) 
	{
		// ������ ���ڸ��� ������, �ֵ� ���ڸ��� ���ĵ��� �����Ѵ�.
		// ������ ���ڸ��� ���� �ʰ� �����̸�, �ֵ� ���� �̵��� �����Ѵ�.
		if ( Owner.Acceleration == vect(0,0,0) ) 
		{
			if ( !PET_AlreadyPlayingWaiting(AnimName) ) 
			{
				PET_TweenToWaiting(0.1);
				PlayAnimName = '';
			}
		}
		else if (PET_ShouldTweenToMoving(AnimName)) 
		{
			PET_TweenToRunning(0.01);
			PlayAnimName = '';
		}
	}
}

function bool PET_AlreadyPlayingWaiting(name AnimName)
{
	return (AnimName == 'LeftStand' || AnimName == 'RightStand');
}

function bool PET_ShouldTweenToMoving(name AnimName)
{
	if ( Hero(Owner).bIsWalking )
		return (AnimName != 'Walk');
	else
	{
		if( MeshName == 'Coro' )
			return (AnimName != 'Walk');
		else
			return (AnimName != 'Run');
	}
}

function PET_TweenToWaiting(float TweenTime)
{
	if ( PetPosition == 1 )//PositionType.RightStand)
		TweenAnim('RightStand',TweenTime);
	else if (PetPosition == 0)//PositionType.LeftStand)
		TweenAnim('LeftStand',TweenTime);
}

function PET_TweenToRunning(float TweenTime)
{
	if ( Hero(Owner).bIsWalking )
		TweenAnim('Walk',TweenTime * 2);
	else
	{
		if( MeshName == 'Coro' )
			TweenAnim('Walk',TweenTime);
		else
			TweenAnim('Run',TweenTime);
	}
}

function PET_TweenToWalking(float TweenTime)
{
	TweenAnim('Walk',TweenTime);
}

function PET_PlayWalking()
{
	local float Rate;
	Rate = Hero(Owner).AnimSpeed * 2;
	LoopAnim('Walk',Rate,0.05);
}

function PET_PlayRunning()
{
	local float Rate;
	if ( MeshName == 'Coro' )
	{
		Rate = Hero(Owner).AnimSpeed * 2.2;
		LoopAnim('Walk',Rate,0.05);
	}
	else
	{
		Rate = Hero(Owner).AnimSpeed * 1.8;
		LoopAnim('Run',Rate,0.05);
	}
}

function PET_PlayWaiting()
{
	if( bJump )
		bJump = False;


	if ( bChangePosition ) 
	{
		if ( PetPosition == 0 )//PositionType.LeftStand)
			SetPosition(1);//PositionType.RightStand);
		else if (PetPosition == 1)//PositionType.RightStand)
			SetPosition(0);//PositionType.LeftStand);
		bChangePosition = False;
	}

	if ( PetPosition == 1 )//PositionType.RightStand)
		LoopAnim('RightStand',1.0,0);
	else if (PetPosition == 0)//PositionType.LeftStand)
		LoopAnim('LeftStand',1.0,0);
}

function PET_PlayAction(name Anim)
{
	if ( Anim == 'RightLeft' || Anim == 'LeftRight' ) 
	{
		if ( PetPosition == 0/*PositionType.LeftStand*/ && Anim == 'RightLeft' )
			return;
		if ( PetPosition == 1/*PositionType.RightStand*/ && Anim == 'LeftRight' )
			return;
		bChangePosition = True;
	}
	PlayAnimName = Anim;
	PlayAnim(PlayAnimName, 1.0, 0.1);
}

function PlayPain()
{
	if ( PlayAnimName != 'Hit' )
		PET_PlayAction('Hit');
}

function PET_PlayInAir()
{
	if( PlayAnimName != 'Jump' )
	{
		bJump = True;
		PET_PlayAction('Jump');
	}	
}

defaultproperties
{
	PetPosition=-1
	PetHeight=5
	PetRadius=5
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'PetPkg.egg'
}
