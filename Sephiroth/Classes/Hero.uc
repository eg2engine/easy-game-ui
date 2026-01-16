class Hero extends Character
	native;

/* Attachment */
const AT_Head=0;
const AT_LeftHand=1;
const AT_RightHand=2;
const AT_BothHand=3;
const AT_LeftWrist=4;
const AT_RightWrist=5;
const AT_LeftCalf=6;
const AT_RightCalf=7;
const AT_LeftFist=8;
const AT_RightFist=9;
const AT_LeftFoot=10;
const AT_RightFoot=11;
const AT_FingerArrow=12;
const AT_BODY=13;
const AT_FACE=14;
const AT_BACK=15;
const AT_TOTAL=16;

var(Attachment) Attachment Attachments[16];

/* Status */
var bool bArmed;

var Controller TargetController;

var vector LeftHandVector, RightHandVector;

var color HairColor;

var string ControllerClassString;

var bool bServerAdmitJump;
//Ag blue
var string tmp, Atext;
var name NullName;


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

native final function EquipAttachmentName(string Name, int EquipPlace);
native final function UnequipAttachment(int EquipPlace);
native final function AttachHair(string HairName);

function Attachment GetRightHand() 
{ 
	return Attachments[AT_RightHand]; 
}

function Attachment GetLeftHand() 
{ 
	return Attachments[AT_LeftHand]; 
}
//2023/7/17
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

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetAnimBase('Bip01 R Toe0');
	SetupBasicAnims();

	HairColor.R = Rand(256);
	HairColor.G = Rand(256);
	HairColor.B = Rand(256);

	AppClassTag = 'Hero';
}

event NetRecv_BeginPlay()
{
	// should be called when occupant moved in and the occupant is a player type
	// for the locally controlled player, shouldn't be called
	local class<Controller> PlayerClass;
	PlayerClass = class<Controller>(DynamicLoadObject(ControllerClassString, class'Class'));
	Super.NetRecv_BeginPlay();
	Controller = Spawn(PlayerClass);
	Controller.bIsPlayer = False;
	Controller.Possess(Self);
	CHAR_TweenToWaiting(0.1);
}

event Destroyed()
{
	local int i;

	Super.Destroyed();
	for ( i = 0;i < ArrayCount(Attachments);i++ )
		if ( Attachments[i] != None && !Attachments[i].bDeleteMe )
			Attachments[i].Destroy();
	/* -jhjung
	foreach DynamicActors (class'Projectile', P) {
		if (P.Instigator == Self) {
			//Log(Self$".Destroyed --> Setting Instigator as None for "$P);
			P.Instigator = None;
		}
		if (MagicShot(P) != None && MagicShot(P).Shooter == Self) {
			//Log(Self$".Destroyed --> Setting Shooter as None for "$P);
			MagicShot(P).Shooter = None;
		}
	}
	*/

	/*
	for (i=0;i<GameManager(Level.Game).Heroes.Length;i++) {
		if (GameManager(Level.Game).Heroes[i] == Self) {
			GameManager(Level.Game).Heroes.Remove(1, i);
			break;
		}
	}
	*/
}

simulated function PlayWaiting()
{
	if ( Physics == PHYS_Falling )
		PlayFalling();
	else
		AnimateStanding();
}

simulated function PlayMoving()
{
	AnimateWalking();
}

simulated event PlayJump()
{
	AnimateJumping();
}

function PlayDying(class<DamageType> DamageType, vector HitLoc) 
{ 
	SetPhysics(PHYS_Walking); 
}

function GibbedBy(actor Other) 
{
}

function TakeFallingDamage() 
{
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
}

simulated function AnimateStanding()
{
	LoopIfNeeded(BasicAnim[0],AnimSpeed,0.1);
}

simulated function AnimateWalking()
{
	if ( bIsWalking ) 
	{
		TurnLeftAnim = 'Walk';
		TurnRightAnim = 'Walk';
		MovementAnims[0] = BasicAnim[1];
		MovementAnims[1] = BasicAnim[1];
		MovementAnims[2] = BasicAnim[1];
		MovementAnims[3] = BasicAnim[1];
	}
	else 
	{
		TurnLeftAnim = 'Run';
		TurnRightAnim = 'Run';
		MovementAnims[0] = BasicAnim[2];
		MovementAnims[1] = BasicAnim[2];
		MovementAnims[2] = BasicAnim[2];
		MovementAnims[3] = BasicAnim[2];
	}
}

simulated function AnimateJumping()
{
	if ( Acceleration.X == 0 && Acceleration.Y == 0 )
		PlayAnim(BasicAnim[3],AnimSpeed,0.3);
	else
		PlayAnim(BasicAnim[3],AnimSpeed);
}

function EquipAttachment(Attachment Attachment, int EquipPlace)
{
	Attachments[EquipPlace] = Attachment;
	if ( bArmed )
		Attachments[EquipPlace].Armed(Self);
	else
		Attachments[EquipPlace].DisArmed(Self);
}

exec function SetHair(string HairName)
{
	local string ItemName;
//	ItemName = HairName$"."$HairName;
	ItemName = HairName;
	EquipAttachmentName(ItemName, AT_Head);
}

exec function SetFace(string sRaceName, bool IsMale)
{
	local string sPkgName;

	if ( sRaceName == "Human" )
		sPkgName = "FaceH";
	else if ( sRaceName == "Nephilim" )
		sPkgName = "FaceN";
	else
	{
		// ��� �� ��Ȳ���� ������ ���µ� ��·�� �ƹ��ų� �ִ°Ÿ� �ִ´�.
		sPkgName = "FaceHM1";
		EquipAttachmentName(sPkgName, AT_FACE);
		return;
	}

	if ( IsMale )
		sPkgName$= "M";
	else
		sPkgName$= "F";

	// �ϴ� �ϳ��ۿ� ���µ� ���߿� �߰��� �� �ְڴ�.
	sPkgName$= "01";

	EquipAttachmentName(sPkgName, AT_FACE);

	///////////////////////////////////////
//	EquipAttachmentName("FaceHM", AT_FACE);
	Attachments[AT_FACE].bUnlit = True;
}


exec function SetSword(string SwordName)
{
	local string ItemName;
//	local class<Actor> EffectClass;
//	local Actor EffectActor;

	ItemName = SwordName$"."$SwordName;
	if ( Attachments[AT_BothHand] != None )
		Attachments[AT_BothHand].Destroy();
	EquipAttachmentName(ItemName, AT_RightHand);

//	EffectClass = class<Actor>(DynamicLoadObject("AcainSwordEF.AcainSwordEF",class'Class'));
//	EffectActor = spawn(EffectClass);
//	EffectActor.SetBase(Attachments[AT_RightHand],vect(0,0,1));
}

exec function SetShield(string ShieldName)
{
	local string ItemName;
	ItemName = ShieldName$"."$ShieldName;
	if ( Attachments[AT_BothHand] != None )
		Attachments[AT_BothHand].Destroy();
	EquipAttachmentName(ItemName, AT_LeftHand);
}

exec function SetGaiter(string GaiterName)
{
	local string ItemName;
	ItemName = GaiterName$"L."$GaiterName$"L";
	EquipAttachmentName(ItemName, AT_LeftCalf);
	ItemName = GaiterName$"R."$GaiterName$"R";
	EquipAttachmentName(ItemName, AT_RightCalf);
}

exec function SetBrassard(string BrassardName)
{
	local string ItemName;
	ItemName = BrassardName$"L."$BrassardName$"L";
	EquipAttachmentName(ItemName, AT_LeftWrist);
	ItemName = BrassardName$"R."$BrassardName$"R";
	EquipAttachmentName(ItemName, AT_RightWrist);
}

exec function SetStaff(string StaffName)
{
	local string ItemName;
	ItemName = StaffName$"."$StaffName;
	if ( Attachments[AT_LeftHand] != None )
		Attachments[AT_LeftHand].Destroy();
	if ( Attachments[AT_RightHand] != None )
		Attachments[AT_RightHand].Destroy();
	EquipAttachmentName(ItemName, AT_BothHand);
}

exec function SetCloth(name BodyName)
{
	local string Body;
	Body = "HumanMalePkg."$BodyName;
//	ChangeMesh(name(Body));  // Modify by Blue 2023/7/17
	ChangeMesh(StrToName(Body));
}

exec function SetBow(string BowName)
{
	local string ItemName;
	ItemName = BowName$"."$BowName;
	if ( Attachments[AT_LeftHand] != None )
		Attachments[AT_LeftHand].Destroy();
	if ( Attachments[AT_RightHand] != None )
		Attachments[AT_RightHand].Destroy();
	EquipAttachmentName(ItemName, AT_RightHand);
	SetupBasicAnims();
}

exec function SetArrow(string ArrowName)
{
	local string ItemName;
	ItemName = ArrowName$"."$ArrowName;
	if ( Attachments[AT_FingerArrow] != None )
		Attachments[AT_FingerArrow].Destroy();
	EquipAttachmentName(ItemName, AT_FingerArrow);
}

exec function ArmArrow(optional string ArrowName)
{
	local string ItemName;
	if ( !Level.Game.IsA('GameManager') )
		return;
	if ( ArrowName == "" )
		ItemName = "Arrow";
	else
		ItemName = ArrowName;
	EquipAttachmentName(ItemName, AT_FingerArrow);
}

exec function DisarmArrow()
{
	if ( Attachments[AT_FingerArrow] != None )
		UnequipAttachment(AT_FingerArrow);
}

event SetupBasicAnims()
{
//	//Log(Self@"SetupBasicAnims"@bWasSit@bIsSit);

	if ( bIsDead )
		return;

	if ( !bArmed ) 
	{
		BasicAnim[0] = 'Idle';
		BasicAnim[1] = 'Walk';
		BasicAnim[2] = 'Run';
		BasicAnim[3] = 'Jump';
		BasicAnim[4] = 'RunBack';
	}
	else 
	{
		if ( IsA('Human') ) 
		{
			if ( Attachments[AT_BothHand] != None ) 
			{
				BasicAnim[0] = 'IdleT';
				BasicAnim[1] = 'WalkT';
				BasicAnim[2] = 'RunT';
				BasicAnim[3] = 'JumpT';
				BasicAnim[4] = 'RunBack';
			}
			else if (Attachments[AT_RightHand] != None && Attachments[AT_LeftHand] == None) 
			{
				BasicAnim[0] = 'IdleS';
				BasicAnim[1] = 'WalkS';
				BasicAnim[2] = 'RunSwordOnly';
				BasicAnim[3] = 'Jump';
				BasicAnim[4] = 'RunBackSwordOnly';
			}
			else if (Attachments[AT_RightHand] == None && Attachments[AT_LeftHand] != None) 
			{
				BasicAnim[0] = 'IdleS';
				BasicAnim[1] = 'WalkS';
				BasicAnim[2] = 'RunShieldOnly';
				BasicAnim[3] = 'Jump';
				BasicAnim[4] = 'RunBackShieldOnly';
			}
			else if (Attachments[AT_RightHand] != None && Attachments[AT_LeftHand] != None) 
			{
				BasicAnim[0] = 'IdleS';
				BasicAnim[1] = 'WalkS';
				//BasicAnim[2] = 'RunSwordShield';
				BasicAnim[2] = 'RunS';
				BasicAnim[3] = 'Jump';
				BasicAnim[4] = 'RunBackSwordShield';
			}
			else 
			{
				BasicAnim[0] = 'Idle';
				BasicAnim[1] = 'Walk';
				BasicAnim[2] = 'Run';
				BasicAnim[3] = 'Jump';
				BasicAnim[4] = 'RunBack';
			}
		}
		else if (IsA('Nephilim')) 
		{
			if ( Attachments[AT_BothHand] != None ) 
			{ 
		// Staff
				BasicAnim[0] = 'IdleT';
				BasicAnim[1] = 'WalkT';
				BasicAnim[2] = 'RunT';
				BasicAnim[3] = 'JumpT';
			}
			else if (Attachments[AT_RightHand] != None) 
			{ 
		// Bow
				if ( Attachments[AT_RightHand].IsA('Bow') ) 
				{
					BasicAnim[0] = 'IdleB';
					BasicAnim[1] = 'WalkB';
					BasicAnim[2] = 'RunB';
					BasicAnim[3] = 'JumpB';
					CheckArrow();
				}
				else if (Attachments[AT_RightHand].IsA('CrossBow')) 
				{
					BasicAnim[0] = 'IdleC';
					BasicAnim[1] = 'WalkC';
					BasicAnim[2] = 'RunC';
					BasicAnim[3] = 'JumpC';
					if ( Attachments[AT_FingerArrow] != None )
						DisarmArrow();
				}
			}
			else 
			{
				BasicAnim[0] = 'Idle';
				BasicAnim[1] = 'Walk';
				BasicAnim[2] = 'Run';
				BasicAnim[3] = 'Jump';
				if ( Attachments[AT_FingerArrow] != None )
					DisarmArrow();
			}
		}
	}
	if ( bWasSit && bIsSit )
		BasicAnim[0] = 'IdleSit';
	else if (!bWasSit && bIsSit) 
	{
		BasicAnim[0] = 'IdleSit';
		bWasSit = True;
	}
	else if (bWasSit && !bIsSit) 
	{
		bWasSit = False;
	}
	ChangeAnimation();
}


function SetWingsAnimation(name Sequence)
{
	switch ( Sequence )
	{
		case 'Run' :
		case 'RunB' :
		case 'RunC' :
		case 'RunS' :
		case 'RunT' :
		case 'Rush' :
		case 'Walk' :
		case 'WalkB' :
		case 'WalkC' :
		case 'WalkS' :
		case 'WalkT' :
		case 'RunShieldOnly' :
		case 'RunSwordOnly' :

			if ( Attachments[AT_BACK] != None )
				Attachments[AT_BACK].LoopAnim('Run', 1.0f, 0.2f, 0);

			break;

		case 'Jump' :
		case 'JumpT' :
		case 'JumpB' :
		case 'JumpC' :

			if ( Attachments[AT_BACK] != None )
				Attachments[AT_BACK].LoopAnim('Jump', 1.0f, 0.2f, 0);

			break;

		default :

			if ( Attachments[AT_BACK] != None )
				Attachments[AT_BACK].LoopAnim('Idle', 1.0f, 0.2f, 0);
	}
}


function CHAR_LoopAnim(name Sequence, float Rate, float Time, optional int Channel)
{
//	//Log("Xelloss : Hero's CHAR_LoopAnim-"$Sequence);
	Super.CHAR_LoopAnim(Sequence, Rate, Time, Channel);

	SetWingsAnimation(Sequence);
}


function CHAR_TweenAnim(name Sequence, float Time, optional int Channel)
{
//	//Log("Xelloss : Hero's CHAR_TweenAnim-"$Sequence);
	Super.CHAR_TweenAnim(Sequence, Time, Channel);

	SetWingsAnimation(Sequence);
}


//////////////////////////

function ChangeAnimation()
{
	// 2003.6.24 by BK
	local float AnimFrame, AnimRate;
	local name AnimSeq;
	GetAnimParams(0,AnimSeq, AnimFrame, AnimRate);

	if ( Controller == None || (!ClientController(Controller).IsInState('Attacking') && !IsSocialAnim(AnimSeq)) )
		Super.ChangeAnimation();
}

function Arm()
{
	local int i,j;
	local PlayerServerInfo PSI;
	local SephirothItem ItemInfo;
	local string HelmetStr;

	for ( i = 0;i < ArrayCount(Attachments);i++ )
		if ( Attachments[i] != None )
			Attachments[i].Armed(Self);

	if( Controller == None || ClientController(Controller).PSI == None )
		return;

	PSI = ClientController(Controller).PSI;

	// chkim
	if( PSI == None )
		return;

	if( PSI.bTransformed == False || PSI.TransToMonsterName == "" ) //add neive : ���� �ý���. ����� ��� ��Ÿ�� ���̴� �� ����
	{
		if ( bool(ConsoleCommand("GETOPTIONI ArmHelmet")) )
		{
			if ( ClientController(Controller) != None )
			{
				if ( Controller.bIsPlayer )
				{
					ItemInfo = PSI.WornItems.FindItem(class'GConst'.Default.IPHead);
					if ( ItemInfo != None )
						HelmetStr = ItemInfo.ModelName;
				}
				else
				{
					for ( j = 0;j < PSI.WornItems.Items.Length;j++ )
						if ( PSI.WornItems.Items[j].EquipPlace == class'GConst'.Default.IPHead )
							break;

					if ( j < PSI.WornItems.Items.Length )
						HelmetStr = PSI.WornItems.Items[j].ModelName;
				}

				if ( HelmetStr != "" )
				{
					UnequipAttachment(AT_Head);
					HelmetStr = HelmetStr$Left(string(PSI.RaceName),1);
					if ( PSI.bIsMale )
						HelmetStr = HelmetStr$"M";
					else
						HelmetStr = HelmetStr$"F";

					EquipAttachmentName(HelmetStr,AT_Head);
				}
			}
		}
	}

	//add neive : ���� ���� ���� �Ӹ���Ÿ�� ������ �� ����
	if ( PSI.bTransformed || PSI.TransToMonsterName != "" ) // �Ǽ��縮 (����� �������) << �� ���Ҹ���;;
	{
		UnequipAttachment(AT_Head);
		UnequipAttachment(AT_FACE);		// �󱼵� ������ �ȵ�
	}

	bArmed = True;
	SetupBasicAnims();
	if ( ClientController(Controller) != None && ClientController(Controller).Player != None )
		ClientController(Controller).PlayerArmed();
}

function DisArm()
{
	local int i,j;
	local int ColorPos;
	local string HairName;
	local PlayerServerInfo PSI;
	local SephirothItem ISI;

	for ( i = 0;i < ArrayCount(Attachments);i++ )
		if ( Attachments[i] != None )
			Attachments[i].DisArmed(Self);

	if( Controller == None || ClientController(Controller).PSI == None )
		return;

	PSI = ClientController(Controller).PSI;

	// chkim 2009
	if( PSI == None )
		return;

	if( PSI.bTransformed == False || PSI.TransToMonsterName == "" ) //add neive : ���� �ý���. ���������� ��� ��Ÿ�� ���̴� �� ����
	{
		if ( bool(ConsoleCommand("GETOPTIONI ArmHelmet")) )
		{
			if ( ClientController(Controller) != None )
			{
				if ( Controller.bIsPlayer )
				{
					ISI = PSI.WornItems.FindItem(class'GConst'.Default.IPHead);
					if ( ISI != None )
					{
						UnequipAttachment(AT_Head);
						HairName = string(PSI.HairName);
						ColorPos = InStr(HairName,"#");
						if ( ColorPos != -1 )
							HairName = Left(HairName, ColorPos);
						SetHair(HairName);
					}
				}
				else
				{
					for ( j = 0;j < PSI.WornItems.Items.Length;j++ )
						if ( PSI.WornItems.Items[j].EquipPlace == class'GConst'.Default.IPHead )
							break;
					if ( j < PSI.WornItems.Items.Length )
					{
						UnequipAttachment(AT_Head);
						HairName = string(PSI.HairName);
						ColorPos = InStr(HairName,"#"); //�߿� ��Ÿ��+�� �ε��� ����
						if ( ColorPos != -1 )
							HairName = Left(HairName, ColorPos);
						SetHair(HairName);
					}
				}
			}
		}
	}

	if( PSI.bTransformed || PSI.TransToMonsterName != "" ) //add neive : ���� �ý��� ���� ���� ����ϸ� �Ӹ� ��
	{
		UnequipAttachment(AT_Head);
		UnequipAttachment(AT_FACE);
	}

	bArmed = False;
	SetupBasicAnims();
	if ( IsA('Nephilim') && Attachments[AT_FingerArrow] != None )
		DisarmArrow();
}

// ����Ǯ���� ��쿡 ����� �Ⱥ��̴� �ɼǿ� ���ؼ� (�Ӹ�ī���� �������ϹǷ�) ȣ��ȴ�. Xelloss
//@by wj(040726)------ Transformation�� Ǯ���� ��� Hair�� �ٽ� Attach ���Ѿ� �Ѵ�
function DisArmByTransformation()
{
	local int j;
	local int ColorPos;
	local string HairName, FaceName;
	local PlayerServerInfo PSI;
	local SephirothItem ISI;

	if ( ClientController(Controller) != None ) 
	{
		PSI = ClientController(Controller).PSI;
		if ( Controller.bIsPlayer ) 
		{
			ISI = PSI.WornItems.FindItem(class'GConst'.Default.IPHead);
			if ( ISI != None ) 
			{
				UnequipAttachment(AT_Head);
				HairName = string(PSI.HairName);
				ColorPos = InStr(HairName,"#");
				if ( ColorPos != -1 )
					HairName = Left(HairName, ColorPos);
				SetHair(HairName);
			}
		}
		else 
		{
			for ( j = 0;j < PSI.WornItems.Items.Length;j++ )
				if ( PSI.WornItems.Items[j].EquipPlace == class'GConst'.Default.IPHead )
					break;
			if ( j < PSI.WornItems.Items.Length ) 
			{
				UnequipAttachment(AT_Head);
				HairName = string(PSI.HairName);
				ColorPos = InStr(HairName,"#");
				if ( ColorPos != -1 )
					HairName = Left(HairName, ColorPos);
				SetHair(HairName);
			}
		}
	}
}
//--------------------

function HideHelmet()
{

	local int j;
	local int ColorPos;
	local string HairName;
	local PlayerServerInfo PSI;
	local SephirothItem ISI;

	if ( ClientController(Controller) != None ) 
	{
		PSI = ClientController(Controller).PSI;

		if ( Controller.bIsPlayer ) 
		{
			ISI = PSI.WornItems.FindItem(class'GConst'.Default.IPHead);
			if ( ISI != None ) 
			{

				UnequipAttachment(AT_Head);
				HairName = string(PSI.HairName);
				ColorPos = InStr(HairName,"#");
				if ( ColorPos != -1 )
					HairName = Left(HairName, ColorPos);
				SetHair(HairName);
			}
		}
		else 
		{
			for ( j = 0;j < PSI.WornItems.Items.Length;j++ )
				if ( PSI.WornItems.Items[j].EquipPlace == class'GConst'.Default.IPHead )
					break;
			if ( j < PSI.WornItems.Items.Length ) 
			{
				UnequipAttachment(AT_Head);
				HairName = string(PSI.HairName);
				ColorPos = InStr(HairName,"#");
				if ( ColorPos != -1 )
					HairName = Left(HairName, ColorPos);
				SetHair(HairName);
			}
		}

		//变身与变身卡状态下不显示
		if( PSI.bTransformed || PSI.TransToMonsterName != "" )
		{
			UnequipAttachment(AT_Head);
			UnequipAttachment(AT_FACE);
		}
	}
}

function DisplayEquipment(Canvas Canvas, out float YL, out float YPos)
{
	local int i;
	local string AttachName;
	Canvas.SetDrawColor(0,255,0);
	Canvas.SetPos(0,YPos);
	Canvas.DrawText(Self@"Equipment");
	Canvas.SetDrawColor(255,255,255);
	YPos += YL;
	for ( i = 0;i < 12;i++ ) 
	{
		switch (i) 
		{
			case 0: AttachName = "Head        "; break;
			case 1: AttachName = "Left Hand   "; break;
			case 2: AttachName = "Right Hand  "; break;
			case 3: AttachName = "Both Hand   "; break;
			case 4: AttachName = "Left Wrist  "; break;
			case 5: AttachName = "Right Wrist "; break;
			case 6: AttachName = "Left Leg    "; break;
			case 7: AttachName = "Right Leg   "; break;
			case 8: AttachName = "Left Fist   "; break;
			case 9: AttachName = "Right Fist  "; break;
			case 10: AttachName = "Left Foot   "; break;
			case 11: AttachName = "Right Foot  "; break;
		}
		Canvas.SetPos(4,YPos);
		if ( Attachments[i] != None )
			Canvas.DrawText(AttachName@Attachments[i].GetDebugString());
		else
			Canvas.DrawText(AttachName);
		YPos += YL;
	}
}

function DebugLog(string message)
{
	ClientController(Controller).myHud.AddMessage(1,"Debug GameCustomCmdManager Handle Len: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

exec function TestAct2(name action)
{
	PlayAnim(action);
}

exec function TestAct(name action, int step)
{
	SetActionStage(STAGE_Prepare);
	PlayAnimAction(action, step, AnimSpeed, 0.3);
}

function bool PointOfView()
{
	return True;
}

function AdjustPlayerSpeed(PlayerServerInfo PSI)
{
	local ClientController CC;

	CC = ClientController(Controller);
	if ( CC != None ) 
	{
		if ( CC.PSI != None && CC.PSI.ArmState ) 
		{
			GroundSpeed = CurrentGroundSpeed * 0.9;
			AnimSpeed = CurrentAnimSpeed * 0.9;
		}
		else 
		{
			GroundSpeed = CurrentGroundSpeed;
			AnimSpeed = CurrentAnimSpeed;
		}
		if ( CC.aForward < 0 || CC.aStrafe != 0 ) 
		{
			GroundSpeed = GroundSpeed * 0.9;
			AnimSpeed = AnimSpeed * 0.9;
		}
	}
}

function bool IsJumping()
{
	if ( Physics == PHYS_Falling ) return True;
	return False;
}

function bool IsRunning()
{
	if ( (Velocity.X != 0 || Velocity.Y != 0) && !bIsWalking ) return True;
	return False;
}

function bool IsWalking()
{
	if ( (Velocity.X != 0 || Velocity.Y != 0) && bIsWalking ) return True;
	return False;
}

function bool DoJump(bool bUpdating)
{
	if ( !bServerAdmitJump )
		return False;
	if ( IsLocallyControlled() )
		ClientController(Controller).PlayerJump();
	return Super.DoJump(bUpdating);
}

function RenderCharacterInfo(Canvas C,vector ScreenPosition);
function DisplayCharacterInfo(Canvas C,vector ScreenPosition);
function PlayRandomSocialAnim();
function PlayRandomSkillAnim();
function PlayRandomBareSkillAnim();
function PlayRandomOneHandSkillAnim();
//ksshim ... 2003.11.6
function PlayRandomBowSkillAnim();
function PlayRandomStaffSkillAnim();

function bool NeedJobChange();
function string GetPlayName();

event Landed(vector HitNormal)
{
	local ClientController CC;

	CC = ClientController(Controller);

	Super.Landed(HitNormal);

	if ( CC != None && !CC.IsTransparent() )
		bHidden = False;

//	if (CC != None && CC.Net != None)
//		CC.Net.NotiMove();
}

function SetDemoSkillBook(int id,SkillBook Book);

function TweenToFinish()
{
	if ( ClientController(Controller) != None )
		ClientController(Controller).TweenToFinish();
}

exec function PlayPain()
{
	Super.PlayPain();
	PlayAnim('Pain',1,0.3);
	if ( ClientController(Controller).Pet != None )
		ClientController(Controller).Pet.PlayPain();
//	PlayAnimAction('Pain',-1,1.0,0.3);
//	SetAnimFrame(0);
}

function SpiritCastEnd(string SpiritName)
{
	if ( ClientController(Controller) != None && IsAvatar() )
		ClientController(Controller).SpiritCastEnd(SpiritName);
}

function projHitActor(Actor HitActor, Vector HitLocation, string ProjName, int ProjSequence)
{
	local ClientController Player;

	Player = ClientController(Controller);
	if ( Player.Net != None )
		Player.RangeHit_Detected(HitActor, HitLocation, ProjName, ProjSequence);
}

function CheckArrow()
{
	if ( Attachments[AT_FingerArrow] == None )
		ArmArrow();
}

function bool IsBasicAnim(name Seq)
{
	return (Seq == BasicAnim[0] || Seq == BasicAnim[1] || Seq == BasicAnim[2] || Seq == BasicAnim[3] || Seq == BasicAnim[4]
		|| Seq == 'Idle' || Seq == 'Walk' || Seq == 'Run' || Seq == 'Jump'
		|| Seq == 'Pain' || Seq == 'Knockback');
}

function Bool IsSocialAnim(name Seq)  // 2003.6.24 by BK
{
	return (Seq == 'Hi' || Seq == 'CharmingHi' || Seq == 'YesSir' || Seq == 'Smile' || Seq == 'Cry'
		|| Seq == 'YooHoo' || Seq == 'Sorry' || Seq == 'DullTime' || Seq == 'Anger' || Seq == 'Kiss'
		|| Seq == 'LoveYou' || Seq == 'Rush' || Seq == 'Sephiroth' );
}

defaultproperties
{
	ControllerClassString="Sephiroth.ClientController"
	bServerAdmitJump=True
	BasicAnim(0)="Idle"
	BasicAnim(1)="Walk"
	BasicAnim(2)="Run"
	BasicAnim(3)="Jump"
	BasicAnim(4)="RunBack"
	BasePivot="Bip01 L Toe0"
	GroundSpeed=580.000000
	JumpZ=600.000000
	WalkingPct=0.431035
	ControllerClass=None
	MovementAnims(0)="Run"
	MovementAnims(1)="Run"
	MovementAnims(2)="Run"
	MovementAnims(3)="Run"
	TurnLeftAnim="Run"
	TurnRightAnim="Run"
	bRootFixPawn=False
}
