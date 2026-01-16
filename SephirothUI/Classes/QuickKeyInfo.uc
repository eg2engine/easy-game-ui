class QuickKeyInfo extends Object;

//	keios - PSI�κ��� quickkey�� ������ ���, 
//	Skill�̳� Item�� ������ �����ϴ� Ŭ����
//	UI class�� QuickKeyButton


//-----------------------------------------
// data

// internal
var PlayerController PlayerOwner;
var Actor QuickKeyButton;

// infos
var byte SlotId;
var byte Type;
var string KeyName;

var int Amount;
var float Cooltime;
var bool Enabled;
var bool Learned;

var Skill Skill_ref;
var SephirothItem ISI_ref;



//-----------------------------------------
// functions


// create
static function QuickKeyInfo Create(PlayerController owner_controller, 
	Actor quickkeybutton)
{
	local QuickKeyInfo qk;

	qk = new(owner_controller) class'QuickKeyInfo';
	if( qk != None )
	{
		qk.PlayerOwner = owner_controller;
		qk.QuickKeyButton	= quickkeybutton;
		qk.SlotId = -1;
	}
	return qk;
} 



// destroy
function Destroy()
{
	PlayerOwner = None;
	QuickKeyButton = None;
}

// clear - slotid�� clear���� �ʴ´�.
function Clear()
{
	Type = class'GConst'.Default.BTNone;
	KeyName = "";

	Amount = 0;
	Cooltime = 0.0;
	Learned = False;
	Enabled = False;
	Skill_ref = None;
	ISI_ref = None;
}

///////////////////////////////////////
// Update function

function UpdateByType_()
{
	switch(Type)
	{
		case class'GConst'.Default.BTNone:
			UpdateNone();
			break;
		case class'GConst'.Default.BTPotion:
		case class'GConst'.Default.BTScroll:
			UpdateItem();
			break;
		case class'GConst'.Default.BTSkill:
			UpdateSkill();
			break;
	}
}


function UpdateTick()
{
	UpdateByType_();
}


function Update(byte _type, string _keyname)
{
	Clear();

	Type = _type;
	KeyName = _keyname;

	UpdateByType_();
}

function UpdateFromPSI(int _slotid)
{
	local PlayerServerInfo PSI;

	// Ŭ����
	Clear();
	SlotId = _slotid;

	if( _slotid == -1 )
	{
		// slot��-1�̸� return
		return;
	}

	PSI = ClientController(PlayerOwner).PSI;
	if( PSI == None )
		return;

	Update(PSI.QuickKeys[SlotId].Type, PSI.QuickKeys[SlotId].KeyName);
}


// update sub functions
function UpdateNone()
{
	Clear();
}

function UpdateItem()
{
	local PlayerServerInfo PSI;

	// amount update
	PSI = ClientController(PlayerOwner).PSI;
	Amount = PSI.SepInventory.GetItemAmountSum(KeyName);

	ISI_ref = PSI.SepInventory.FirstMatched(0, KeyName);

	if( ISI_ref.IsEvent() ) //add neive : �Ⱓ�� ǥ��
		Amount = -99;
}


function UpdateSkill()
{
	Skill_ref = ClientController(PlayerOwner).QuerySkillByName(KeyName);

	if( Skill_ref != None )
	{
		// update data
		Enabled = Skill_ref.bEnabled;
		Learned = Skill_ref.bLearned;
	}
	else
	{
		//Log("QuickKeyInfo::UpdateSkill() - ERROR : SKILL IS NONE");
	}
}


// return charge rate
function float GetChargeRate()
{
	if( Skill_ref != None && Skill_ref.IsA('SecondSkill') )
	{
		return SecondSkill(Skill_ref).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PlayerOwner.Level.TimeSeconds);
	}
	return 1.0;
}


/////////////////////////////////////////

// ��ų ���
function int Action()
{
	local Skill				Skill;
	local SecondSkill		Skill2nd;
	local SephirothItem		Item;
	local actor				TargetActor;
	local vector			HitLocation, TargetLoc, ShooterLoc;


	local SephirothPlayer PC;
	local SephirothInterface Interface;
	local SephirothController Controller;



	PC = SephirothPlayer(PlayerOwner);
	Interface = SephirothInterface(PC.myHud);
	Controller = SephirothController(Interface.Controller);


	if( Type == class'GConst'.Default.BTNone || KeyName == "" )
		return -1;

	switch(Type)
	{

	// scroll/potion
		case class'GConst'.Default.BTPotion:
		case class'GConst'.Default.BTScroll:

			if( !PC.CanUseItemNow() )			// ������ ��� ���� üũ
				return -1;

			if( PC.PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� ����Ű ��� ����			
			{
				Interface.AddMessage(2, Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(55,55,200));	
				return -1;
			}

			Item = PC.PSI.SepInventory.FirstMatched(0, KeyName);
			if ( Item != None && Item.Amount > 0 )
				PC.Net.NotiItemUseShotcut(Item.TypeName);
			return 0;


	// skill
		case class'GConst'.Default.BTSkill:

			if( !PC.CanUseAllSkill() )		// ��ų ��� ���� üũ
			{
				Interface.AddMessage(2, 
					Localize("Warnings", "CannotUseSkill", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
				return -1;
			}

			Skill = PC.QuerySkillByName(KeyName);

			if ( Skill == None )
				return -1;

			if ( PC.ZSI.bNoUseSkill )
				return -1;

			if ( !Skill.bLearned || !Skill.bEnabled )
				return -1;

		// hitlocation, targetactor�� ��´�.
			TargetActor = PC.GetSkillTargetActor(HitLocation);

		// ��ų ��� - from sephirothinterface
			if ( Skill.IsA('SecondSkill') ) 
			{
				Skill2nd = SecondSkill(Skill);

				if ( Skill2nd.SkillLevel < 1 ) //add neive : ��ų ������ 1���� ������ ��� ����
					if( Skill2nd.SkillName != "Transformation" )
						return -1;

				if( !PC.CanUse2ndSkill() )
				{
					Interface.AddMessage(2, Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(55,55,200));	
					return -1;
				}

				Skill2nd.GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);	// update bCharged
				if( Skill2nd.bCharged || (Skill2nd.SkillType == 6 && Skill.bEnabled) ) 
				{
					if ( Interface.IsSecondSkillFire(Skill2nd, TargetActor) ) 
					{
					//Log("=====>OnHotKeyApply SecondSkill"@Skill.SkillName@Skill2nd.ShootingRange);

						if ( Skill2nd.ShootingRange != 0 ) 
						{
							ShooterLoc = PC.Pawn.Location;
							TargetLoc = TargetActor.Location;

							if ( VSize(TargetLoc - ShooterLoc) > Skill2nd.ShootingRange ) 
							{
								Interface.AddMessage(2, Localize("Warnings", "ShootingRangeOver", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
								return -1;
							}
						}
						Controller.OnSecondSkillStart(Skill, TargetActor, HitLocation);
					}
				}
				else
					Interface.AddMessage(1, Skill.FullName@Localize("Warnings", "SkillInCooltime", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
			}
			else if (Skill.IsCombo() && PC.PSI.ComboSkill != Skill.SkillName)
				PC.SetHotSkill(0, Skill.SkillName);
			else if (Skill.IsFinish() && PC.PSI.FinishSkill != Skill.SkillName)
				PC.SetHotSkill(1, Skill.SkillName);
			else if (Skill.IsMagic() && PC.PSI.MagicSkill != Skill.SkillName)
				PC.SetHotSkill(2, Skill.SkillName);

			return 0;
	}
}

////////////////////////////////////////////

defaultproperties
{
}
