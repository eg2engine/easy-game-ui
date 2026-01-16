class Character extends Pawn
	native
	placeable;

var(Display) name BasicMeshName;
var(Display) Material BaseMaterial;
var(Animation) name	BasicAnim[5];
var(Animation) name AnimSequence;
var(Animation) float AnimSpeed, CurrentAnimSpeed;
var(Animation) name WaitTweenState;
var(Action) class<AnimAction> ActionClass;
var(Action) AnimAction CAnimAction;
var(Action) name BasePivot;
var(Action) struct native ActionSummary 
		{
		var() bool	bIsValid;
		var() name	Sequence;
		var() EActionStage ActionStage;
		var() byte	ActionClass;
		var() name	PreparePivot;
		var() name	CleanupPivot;
	} 
	PendingAction;
var(Action) float ActionSpeedRate;
var float BaseGroundSpeed, CurrentGroundSpeed;
var bool bIsDead, bJustDamaged;
var bool bWasSit,bIsSit;
var float DeadTime;
var globalconfig bool bNoShadow;

var(Balloon) bool bBalloon;
var(Balloon) float BalloonDuration;
var(Balloon) float BalloonTick;
var(Balloon) byte BalloonStringColorType;
var(Balloon) string BalloonString;

var(Effect) array<Actor> BoneEffects;
var(Effect) array<EnchantType> EnchantTypes;
// keios - pk�ı�����Ʈ
var(Effect) DynamicEffect HaloEffect;


//@by wj(04/01)------
var name BoneHead;
var name BoneSpine;
//-------------------	

native final function SetupAnimNotifies();
native final function PlayAnimAction(name Sequence, optional int Step, optional float Rate, optional float TweenTime, optional int Channel);
native final function GetPlayAnimAction(name Sequence, out int OutTemp, out array<float> OutArray, out float OutEndTime, optional int Step, optional float Rate, optional float TweenTime, optional int Channel);	// ryu dualcore
native final function ChangeMesh(name MeshName, optional name AnimName);
native final function bool CheckHitFromBone(name Bone, Pawn Target, out vector HitLocation, out vector HitNormal);
native final function bool CheckHitFromAttachment(Attachment Attachment, Pawn Target, out vector HitLocation, out vector HitNormal);
native final function ShowAfterImage();
native final function HideAfterImage();
native final function bool AnimationInfo(name SequenceName, out float TotalFrames, out float DefualtAnimRate); // 2003.9.1	By BK

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

event MeshChange()
{
	ChangeAnimation();
}

event SetupBasicAnims();

// CHKIM
function PreBeginPlay()
{
	Super.PreBeginPlay();
	bActorShadows = !bNoShadow;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
//	//Log(Self $ " PostBeginPlay " $ ActionClass);
	if ( ActionClass != None ) 
	{
		CAnimAction = new(Self) ActionClass;
		SetupAnimNotifies();
		if ( BasePivot != '' )
			SetAnimBase(BasePivot);
	}
	BaseGroundSpeed = GroundSpeed;
	CurrentAnimSpeed = AnimSpeed;
	CurrentGroundSpeed = GroundSpeed;
	bActorShadows = !bNoShadow;
//	CHAR_LoopAnim(BasicAnim[0]);
}

event LostChild(Actor Child)
{
	local EffectProjectile P;
	if ( Child.IsA('EffectProjectile') ) 
	{
		P = EffectProjectile(Child);
		P.ProcessDanglings(Self);
		/*
		if (P.Instigator == Self) {
			//Log(Self$".LostChild --> Setting Instigator as None for "$P);
			P.Instigator = None;
		}
		if (P.Shooter == Self) {
			//Log(Self$".LostChild --> Setting Shooter as None for "$P);
			P.Shooter = None;
		}
		if (P.TargetActor == Self) {
			//Log(Self$".LostChild --> Setting TargetActor as None for "$P);
			P.TargetActor = None;
	}
		*/
	}
	Super.LostChild(Child);
}

event Destroyed()
{
	local EffectProjectile P;

	Super.Destroyed();

	if ( IsA('Hero') || IsA('Monster') || IsA('GuardStone') || IsA('MatchStone') ) 
	{
		foreach DynamicActors (class'EffectProjectile', P) 
		{
			P.ProcessDanglings(Self);
			/*
			if (P.Instigator == Self) {
				//Log(Self$".Destroyed --> Setting Instigator as None for "$P);
				P.Instigator = None;
			}
			if (P.Shooter == Self) {
				//Log(Self$".Destroyed --> Setting Shooter as None for "$P);
				P.Shooter = None;
			}
			if (P.TargetActor == Self) {
				//Log(Self$".Destroyed --> Setting TargetActor as None for "$P);
				P.TargetActor = None;
			}
			*/
		}
	}

	// keios -haloeffect ����
	if( HaloEffect != None )
		HaloEffect.Destroy();
	HaloEffect = None;
}

function BrightenCharacter()
{
	CreateStyle();
	BrightenStyleSoftly();
}

function UnbrightenCharacter()
{
	RemoveStyle();
}

event NetRecv_BeginPlay();

/* LoopIfNeeded()
play looping idle animation only if not already animating
*/
simulated function LoopIfNeeded(name NewAnim, float NewRate, float BlendIn)
{
	/*
	local name OldAnim;
	local float frame,rate;

	GetAnimParams(0,OldAnim,frame,rate);

	// FIXME - get tween time from anim
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, BlendIn);
	else
		LoopAnim(NewAnim, NewRate);
	*/
}

function bool IsAvatar()
{
	if ( PlayerController(Controller) == None )
		return False;
	if ( Viewport(PlayerController(Controller).Player) == None )
		return False;
	return True;
}

function HitDetect_LeftHand()
{
	if ( IsAvatar() )
		ClientController(Controller).HitDetect('Bip01 L Hand');
}

function HitDetect_RightHand()
{
	if ( IsAvatar() )
		ClientController(Controller).HitDetect('Bip01 R Hand');
}

function HitDetect_LeftFoot()
{
	if ( IsAvatar() )
		ClientController(Controller).HitDetect('Bip01 L Toe0');
}

function HitDetect_Pet()
{
	PetController(Controller).HitDetect();
}

function HitDetect_RightFoot()
{
	if ( IsAvatar() )
		ClientController(Controller).HitDetect('Bip01 R Toe0');
}

function RangeHit_Detected(actor HitActor, vector HitLocation,string SkillName,int ActionID)
{
	if ( IsAvatar() )
		ClientController(Controller).RangeHit_Detected(HitActor, HitLocation, SkillName, ActionID);
}

function StartIdle(bool bTweenToIdle, optional float TweenTime)
{
//	SetActionStage(STAGE_End);
//	StopAnimating();
	if ( bTweenToIdle )
		CHAR_TweenToWaiting(TweenTime);
}

event MeleeTouch(actor Other, vector HitLocation, vector HitNormal);

exec function SpeedAssignment(float Speed,optional float factor)
{
	if ( factor == 0 )
		factor = 1;
	GroundSpeed = Speed;

//	AnimSpeed = factor * FMax(GroundSpeed, Default.GroundSpeed) / Default.GroundSpeed;  // by BK (FMax)
	AnimSpeed = factor * FMax(GroundSpeed, Default.GroundSpeed) / GroundSpeed;  // 2003.7.1 by BK 
}

function AdjustRotation(vector Dest)
{
	local Rotator Rot;
	Rot = Rotation;
	Rot.Yaw = Rotator(Dest - Location).Yaw;
	SetRotation(Rot);
}

function CHAR_CreatureWalkingAnim()
{
	if ( !bIsDead ) 
	{
		if ( Physics == PHYS_Falling ) 
		{
			CHAR_PlayInAir();
		}
		else 
		{
			if ( Acceleration == vect(0,0,0) && (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000
				|| VSize(Controller.Destination - Location) <= 150 ) 
			{
				Controller.Destination = Location;
				CHAR_PlayWaiting();
			}
			else 
			{
				if ( bIsWalking )
					CHAR_PlayWalking();
				else
					CHAR_PlayRunning();
			}
		}
	}
}

function CHAR_CheckCreatureWalkAnim()
{
	if ( !bIsDead && Physics != PHYS_Falling ) 
	{
		if ( CHAR_ShouldTweenToMoving() ) 
		{
			CHAR_TweenToRunning(0.1);
		}
	}
}

event CHAR_PlayerWalkingAnim()
{
	if ( !bIsDead && !bJustDamaged )
	{
		if ( Physics == PHYS_Falling )
		{
			CHAR_PlayInAir();
		}
		else
		{
			if ( Acceleration == vect(0,0,0) && (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000 )
			{
				if ( CHAR_AlreadyPlayingWaiting() )
				{
					CHAR_PlayWaiting();
				}
				else
				{
					CHAR_TweenToWaiting(0.1);
				}
			}
			else if (bIsWalking)
			{
				if ( CHAR_ShouldTweenToMoving() )
				{
					CHAR_TweenToWalking(0.1);
				}
				else
				{
					CHAR_PlayWalking();
				}
			}
			else
			{
				//@by wj(040319)------
				if( IsA('Hero') && 
					((AnimSequence == BasicAnim[2] && ClientController(Controller).bBackward) || 
					(AnimSequence == BasicAnim[4] && !(ClientController(Controller).bBackward))) )
				{
					CHAR_TweenToWaiting(0.1);
				}
				//--------------------
				else if (CHAR_ShouldTweenToMoving())
					CHAR_TweenToRunning(0.1);
				else
					CHAR_PlayRunning();
			}
		}
	}
}

event CHAR_CheckWalkAnim(vector OldAccel,bool bIsTurning,bool bTurningLeft)
{
	if ( !bIsDead && !bJustDamaged && Physics != PHYS_Falling ) 
	{
		if ( Acceleration == vect(0,0,0) && Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000 ) 
		{
			if ( CHAR_AlreadyPlayingWaiting() ) 
			{
				if ( bIsTurning && SimAnim.AnimFrame >= 0 )
					CHAR_PlayTurning(True);
			}
			else if (!bIsTurning)
				CHAR_TweenToWaiting(0.1);
		}
		else 
		{
			if ( CHAR_ShouldTweenToMoving() )
				CHAR_TweenToRunning(0.1);
		}
	}
}

function bool CHAR_AlreadyPlayingWaiting()
{
	return (AnimSequence == BasicAnim[0]);
}

function bool CHAR_ShouldTweenToMoving()
{
	if ( bIsWalking ) 
	{
		if ( AnimSequence == BasicAnim[1] )
			return False;
	}
	else 
	{
		if ( AnimSequence == BasicAnim[2] ) 
		{
			if( IsA('Hero') )
			{
				if( !ClientController(Controller).bBackward )
					return False;
			}
			else
				return False;
		}
		//@by wj(040319)------
		if ( IsA('Hero') && AnimSequence == BasicAnim[4] && ClientController(Controller).bBackward )
			return False;
		//--------------------
	}
	return True;
}

function CHAR_TweenToWaiting(float TweenTime)
{
	CHAR_TweenAnim(BasicAnim[0],TweenTime);
	if ( Controller != None )
		WaitTweenState = Controller.GetStateName();
}

function CHAR_TweenToRunning(float TweenTime)
{
	if ( bIsWalking ) 
	{
		CHAR_TweenToWalking(TweenTime * 2);
	}
	else 
	{ 
		//@by wj(040319)------
		if( IsA('Hero') && ClientController(Controller).bBackward )
			CHAR_TweenAnim(BasicAnim[4],TweenTime);
		else
			CHAR_TweenAnim(BasicAnim[2],TweenTime);
		//--------------------
	}
}

function CHAR_TweenToWalking(float TweenTime)
{
	CHAR_TweenAnim(BasicAnim[1],TweenTime);
}

function CHAR_PlayTurning(bool bTurningLeft)
{
}

function CHAR_PlayInAir()
{
	if ( AnimSequence != BasicAnim[3] && BasicAnim[3] != '' )
	{
		CHAR_TweenAnim(BasicAnim[3], 0.5);
	}
	else
	{
	}
}

function CHAR_PlayWalking()
{
	CHAR_LoopAnim(BasicAnim[1],AnimSpeed);
}

function CHAR_PlayRunning()
{	
	//@by wj(040319)------
	if( IsA('Hero') && ClientController(Controller).bBackward )
		CHAR_LoopAnim(BasicAnim[4],AnimSpeed);
	else
		CHAR_LoopAnim(BasicAnim[2],AnimSpeed);
	//--------------------
}

function CHAR_PlayWaiting()
{
	if ( bWasSit && !bIsSit || !bWasSit && bIsSit )
	{
		//log("##### CHAR_PlayWaiting::SetupBasicAnims()"$bWasSit$bIsSit);
		SetupBasicAnims();
	}

//	//Log("Xelloss : CHAR_PlayWaiting");
	CHAR_LoopAnim(BasicAnim[0], 1, 0.1); // 2003.7.1  append 0.1  by BK

//	if ( IsA('Hero') && Hero(Pawn).Attachments[UCONST_AT_WING] != None )
//		Hero(Pawn).Attachments[EquipPlace].PlayAnim(0, _T("run"), 0.5f, 0.2f, true);
}

function CHAR_PlayAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel)
{
	if ( HasAnim(Sequence) )
	{
		AnimSequence = Sequence;
		PlayAnim(Sequence,Rate,TweenTime,Channel);
	}
}

function CHAR_LoopAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel)
{
	if ( HasAnim(Sequence) )
	{
		AnimSequence = Sequence;
		LoopAnim(Sequence,Rate,TweenTime,Channel);
	}
}

function CHAR_TweenAnim(name Sequence, float Time, optional int Channel)
{
	if ( HasAnim(Sequence) )
	{
		AnimSequence = Sequence;
		TweenAnim(Sequence,Time,Channel);
	}
}

function bool DoJump(bool bUpdating)
{
	local bool result;
	result = Super.DoJump(bUpdating);
	CHAR_PlayInAir();
	return result;
}

function ChangeAnimation()
{
	CHAR_CheckWalkAnim(Acceleration,False,False);
	if( !IsA('Monster') )  //2003.7.1 by BK
	{
		CHAR_PlayerWalkingAnim();
	}
}

exec function Walk() 
{ 
	SetWalking(True); 
}

exec function Run() 
{ 
	SetWalking(False); 
}

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);

	if ( bIsDead )
		return;

	if ( ClientController(Controller) != None )
		ClientController(Controller).Landfloor(HitNormal);

	if ( Controller == None || (!Controller.IsInState('Attacking') && !Controller.IsInState('SummonSpirit')) )
	{
		CHAR_PlayWaiting();
	}
}

exec function PlayPain()
{
	bJustDamaged = True;
}

function SpiritCastEnd(string SpiritName);

function projHitActor(Actor HitActor, Vector HitLocation, string ProjName, int ProjSequence);


state NetState_JustDead
{
	ignores AdjustRotation, SpeedAssignment, SetupBasicAnims,
	CHAR_CheckCreatureWalkAnim,
	CHAR_CreatureWalkingAnim,
	CHAR_CheckWalkAnim,
	CHAR_PlayerWalkingAnim,
	AnimEnd,
	CHAR_TweenToWaiting,
	CHAR_PlayWaiting;

	function BeginState()
	{
//		//Log(Self @ GetStateName() @ "BeginState");
		if (IsA('Creature') && Controller != None && !Controller.bDeleteMe) 
		{
			Controller.SetLocation(Location);
			UnPossessed();
		}
		bJustDamaged = False;
		bIsDead = True;

		//if (IsA('Monster'))
		//	SetTimer(6, false);
		//else
		//	SetTimer(4, false);
		SetTimer(4, False);

		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		CHAR_PlayAnim('Die',1);
		SetCollision(False, False, False);
		SetAnimFrame(0);
	}
	function EndState()
	{
//		//Log(Self @ GetStateName() @ "EndState");
//		CHAR_TweenToWaiting(0);
//		CHAR_PlayWaiting();
		CHAR_PlayAnim(BasicAnim[0],1);
		bIsDead = False;
//		SetCollision(true, true, true);
	}
	function Timer()
	{
		if (IsA('Monster'))
			Destroy();
	}
}

state NetState_WasDead extends NetState_JustDead
{
	function BeginState()
	{
		Super.BeginState();
		SetAnimFrame(100);
	}
}

/*
state NetState_BoothSelling
{
	ignores AdjustRotation, SpeedAssignment, 
			CHAR_CheckCreatureWalkAnim,
			CHAR_CreatureWalkingAnim,
			CHAR_CheckWalkAnim,
			CHAR_PlayerWalkingAnim,
			CHAR_TweenToWaiting,
			CHAR_PlayWaiting;

	function BeginState()
	{
		//Log("##### BeginState");
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		CHAR_PlayAnim('SitDown',1,0.3);
		SetTimer(15, true);
		bIsSit = true;
		
		if( ClientController(Controller).PSI != None && ClientController(Controller).PSI.ArmState )
			ClientController(Controller).ToggleArmState();
	}
	function Timer()
	{
		//Log("##### Timer");
		
		CHAR_PlayAnim('SitUp',1,0.3);

		if( ClientController(Controller) != None )
			return;		

		if( ClientController(Controller).BoothToutCount < 4 ){
			if( ClientController(Controller).BoothToutCount == 0 )
				ClientController(Controller).ToutName = 'CharmingHi';
			else if( ClientController(Controller).BoothToutCount == 1 )
				ClientController(Controller).ToutName = 'YooHoo';
			else if( ClientController(Controller).BoothToutCount == 2 )
				ClientController(Controller).ToutName = 'DullTime';
			else if( ClientController(Controller).BoothToutCount == 3 )
				ClientController(Controller).ToutName = 'Hi';
			ClientController(Controller).BoothToutCount++;
		}
		else{
			ClientController(Controller).ToutName = 'LoveYou';
			ClientController(Controller).BoothToutCount = 0;
		}
	}
	event AnimEnd(int Channel) 
	{
		local name AnimName;
		local float AnimFrame, AnimRate;

		GetAnimParams(0, AnimName, AnimFrame, AnimRate);
		//Log("##### AnimEnd ToutName: "$ClientController(Controller).ToutName@"AnimName: "$AnimName);
		if( AnimName == 'SitUp' )
			PlayAnim(ClientController(Controller).ToutName, 1, 0.3);
		else if( AnimName != 'SitDown' && AnimName != 'IdleSit' )
			CHAR_PlayAnim('SitDown',1,0.3);
		else if( AnimName == 'SitDown' )
			CHAR_PlayWaiting();
	}
	event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune) {}
	function EndState()
	{
		CHAR_PlayAnim('SitUp',1,0.3);
		SetTimer(0, false);
		bIsSit = false;
	}
}

state NetState_WasBoothSelling extends NetState_BoothSelling
{
	function BeginState()
	{
		Super.BeginState();
		SetAnimFrame(100);
	}
}
*/


// keios - PK �ı� ����Ʈ ����
function DynamicEffect SpawnDynamicEffect(string effectName, string shaderName)
{
	local DynamicEffect dyneffect;

	dyneffect = Spawn(class'DynamicEffect', Self,, Location, Rotation);
	dyneffect.SetEffectName(effectName);
	dyneffect.SetShaderName(shaderName);

	return dyneffect;
}

function UpdateHaloEffectShader(string shadername)
{
	if( shadername == "" )
	{
		HaloEffect.Destroy();
		HaloEffect = None;
		return ;
	}

	if( HaloEffect == None )
	{
		HaloEffect = SpawnDynamicEffect("PassiveEffect.Pk_01", shadername);
		return ;
	}
	HaloEffect.SetShaderName(shadername);
}

defaultproperties
{
	AnimSpeed=1.000000
	ActionClass=Class'Sephiroth.AnimAction'
	ActionSpeedRate=1.000000
	BoneHead="Bip01 Head"
	BoneSpine="Bip01 Spine"
	bIsWalking=True
	bRootFixPawn=True
	Physics=PHYS_Walking
	bRotateToDesired=False
}
