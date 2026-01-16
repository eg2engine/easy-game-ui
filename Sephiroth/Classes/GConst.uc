class GConst extends Object
	config(User);

var const int EPR_NUM;
var const int EPR_Human;
var const int EPR_Nephilim;
var const int EPR_Titaan;
var const int EPR_All;

var const int EJT_NUM;
var const int EJT_White;
var const int EJT_Red;
var const int EJT_Blue;
var const int EJT_Yellow;
var const int EJT_Black;
var const int EJT_Bare;
var const int EJT_OneHand;
var const int EJT_TwoHand;
var const int EJT_Spear;
var const int EJT_Bow;
var const int EJT_All;

/* Item Place */
var const int IPNeck		;		// 0 Necklace
//var const int IPShoulder	;		// 1 Shoulder Protector(Pad)
var const int IPHead		;		// 1 Shoulder Protector(Pad)
var const int IPBody		;		// 2 Armor
var const int IPCalves		;		// 3 Calves Protector(Gaiter)
var const int IPRArm		;		// 4 Arm Protector(Brassard)
var const int IPLArm		;
var const int IPRWrist		;		// 5 Bracelet
var const int IPLWrist		;		// 6
var const int IPRHand		;		// 7 // Attack Weapon
var const int IPLHand		;		// 8 // Attack Weapon or Shield
var const int IPFingerR1	;		// 9 // Ring
var const int IPFingerR2	;
var const int IPFingerL1	;
var const int IPFingerL2	;
var const int IPREar		;		// Shell
var const int IPLEar		;
var const int IPBHand		;       // ���� ������
var const int MaxBodyPlace	;
var const int IPInventory	;
var const int IPGround		;
var const int IPNoPlace		;

var const int IPREaring     ;       //add neive : �Ͱ��� �߰�
var const int IPLEaring     ;

var const int IPCharm1      ;       //add neive : ���������� �������� ��ȯ
var const int IPCharm2      ;
var const int IPCharm3      ;
var const int IPCharm4      ;
var const int IPCharm5      ;
var const int IPCharm6      ;

var const int IPDeadPet     ;       //add neive : �� ��� ���� 

var const int IPBelt		;		//add neive : ��Ʈ �߰� 2
var const int IPEmblem		;		//add neive : ������ �߰�
var const int IPWings		;		// �����߰�

var const int Glove;
var const int Sword;
var const int Staff;
var const int Shield;
var const int Gaiter;
var const int Brassard;
var const int Helmet;
var const int Cloth;
var const int Shell;
var const int Bracelet;
var const int Necklace;
var const int Ring;

/* Item Rareness Level Type */
var const int IRNormal		;
var const int IRMagic		;
var const int IRRare		;
var const int IRUnique		;
var const int IRPlatinum	;

/* Item Usage Type */
var const int IUNone		;
var const int IUConsume		;
var const int IUFillAdd		;
var const int IUFillRate	;
var const int IUAttack		;
var const int IUDefenseEffect;
var const int IUDefenseRate	;
var const int IUShell		;
var const int IUMap		;
var const int IUAmulet		;
var const int IUArrow		;
var const int IUResetPoints	;
var const int IUEnchantItem	;
var const int IUReturn		;
var const int IUSubMap		;
var const int IUSkillScroll	;
//var const int IURadar;
//var const int IUDetectScroll;
var const int IUFillDirect;
var const int IUFillDirectRate;
var const int IUUseScript;
var const int IUApplyScript;
var const int IUApplySelectScript;
var const int IUApplyInputScript;		// skkim + 2003/10/2
var const int IUPetCage;				// skkim +  2003/10/2
var const int IUPetFood;				// skkim +  2003/10/4
var const int IUUseInstantScript;		// skkim + 2003/12/2
var const int IUDefenseRace;			//add neive : ���� �Ӽ� ���
var const int IUSkillItem;		//������ä��.
var const int IUSetArmor;		//add neive : ��Ʈ ���
var const int IUSetArmorRace;
var const int IUSetWeapon;
var const int IUSetShield;

// Server AppProtocol.h �� �������� 


/* Belt Slot Type */
var const int BTNone		;
var const int BTPotion		;
var const int BTSkill		;
var const int BTScroll		;
var const int BTMenu		;		//modified by yj

/* SkillBook Type */
var const int SBNone;
var const int SBBareHand;
var const int SBBareFoot;
var const int SBOneHand;
var const int SBTwoHand;
var const int SBSpear;
var const int SBBow;
var const int SBSpirit;
var const int SBStaff;
var const int SBWhite;
var const int SBWhiteSupport;
var const int SBRed;
var const int SBRedSupport;
var const int SBBlue;
var const int SBBlueSupport;
var const int SBYellow;
var const int SBYellowSupport;
var const int SBBlack;
var const int SBBlackSupport;
var const string BookNames[19];
var const string MagicPrefix[5];

/* SkillSlot Type */
var const int SSCombo		;
var const int SSFinish		;
var const int SSMagic		;

var globalconfig const string DialogSchemeHeader;

/* UI Hit type */
var const int HIT_None;
var const int HIT_Minimap;
var const int HIT_Gauge;
var const int HIT_Repair;
var const int HIT_DialogLink;

var const int IDT_Raw;
var const int IDT_Refined;
var const int IDT_HPotion;
var const int IDT_MPotion;
var const int IDT_HMPotion;
var const int IDT_Ring;
var const int IDT_Necklace;
var const int IDT_Bracelet;
var const int IDT_OneHand;
var const int IDT_TwoHand;
var const int IDT_Glove;
var const int IDT_Staff;
var const int IDT_Spear;
var const int IDT_Bow;
var const int IDT_Arrow;
var const int IDT_Armor;
var const int IDT_Shield;
var const int IDT_Gaiter;
var const int IDT_Brassard;
var const int IDT_Robe;
var const int IDT_Helmet;
var const int IDT_Cap;
var const int IDT_Sendal;
var const int IDT_Sleevelet;
var const int IDT_Garb;
var const int IDT_Gown;
var const int IDT_Gem;
var const int IDT_SubMapScroll;
var const int IDT_ReturnScroll;
var const int IDT_SkillScroll;
var const int IDT_Shell;
var const int IDT_Amulet;
var const int IDT_Map;
var const int IDT_Quest;
var const int IDT_Money;
var const int IDT_Event;
var const int IDT_Protector;
var const int IDT_Stack;
var const int IDT_Stick;
var const int IDT_PetFood;
var const int IDT_PetCage;
var const int IDT_SkillBook;
var const int IDT_UnlimitArrow;
var const int IDT_Earring; //add neive : �Ͱ��� �߰�
var const int IDT_Charm; //add neive : ���� ���ȭ
var const int IDT_DeadPet;
var const int IDT_Belt;	//add neive : ��Ʈ �߰� 2
var const int IDT_Emblem;	//add neive : ������ �߰�
var const int IDT_StackUI;	//add ssemp : UI���� ������ �߰�

var const int RM_Plywood;
var const int RM_Wedge;
var const int RM_Sawdust;
var const int RM_Bronze;
var const int RM_Steel;
var const int RM_AlloyPowder;
var const int RM_RLeather;
var const int RM_Strap;
var const int RM_Patch;
var const int RM_WareGemstone;
var const int RM_GemPowder;
var const int RM_PowerGem;
var const int RM_HealthHerb;
var const int RM_ManaHerb;
var const int RM_HerbRoot;

var const int EWS_Debug;
var const int EWS_None;
var const int EWS_Defense;
var const int EWS_Offense;

/* enum EServerMsgType */
var const int SM_Error;
var const int SM_Help;
var const int SM_Operator;
var const int SM_Result;
var const int SM_Unknown;
var const int SM_WhisperResult;
var const int SM_MsgBox;
var const int SM_Notice;
var const int SM_EventAlarm;
var const int SM_ClientOnly;





defaultproperties
{
	EPR_NUM=3
	EPR_Human=1
	EPR_Nephilim=2
	EPR_Titaan=4
	EPR_All=7
	EJT_NUM=10
	EJT_White=1
	EJT_Red=2
	EJT_Blue=4
	EJT_Yellow=8
	EJT_Black=16
	EJT_Bare=32
	EJT_OneHand=64
	EJT_TwoHand=128
	EJT_Spear=256
	EJT_Bow=512
	EJT_All=1023
	IPHead=1
	IPBody=2
	IPCalves=3
	IPRArm=4
	IPLArm=5
	IPRWrist=6
	IPLWrist=7
	IPRHand=8
	IPLHand=9
	IPFingerR1=10
	IPFingerR2=11
	IPFingerL1=12
	IPFingerL2=13
	IPREar=14
	IPLEar=15
	IPBHand=16
	MaxBodyPlace=32
	IPInventory=29
	IPGround=30
	IPNoPlace=31
	IPREaring=17
	IPLEaring=18
	IPCharm1=19
	IPCharm2=20
	IPCharm3=21
	IPCharm4=22
	IPCharm5=23
	IPCharm6=24
	IPDeadPet=25
	IPBelt=26
	IPEmblem=27
	IPWings=28
	Sword=1
	Staff=2
	Shield=3
	Gaiter=4
	Brassard=5
	Helmet=6
	Cloth=7
	Shell=8
	Bracelet=9
	Necklace=10
	Ring=11
	IRMagic=1
	IRRare=2
	IRUnique=3
	IRPlatinum=4
	IUConsume=1
	IUFillAdd=2
	IUFillRate=3
	IUAttack=4
	IUDefenseEffect=5
	IUDefenseRate=6
	IUShell=7
	IUMap=8
	IUAmulet=9
	IUArrow=10
	IUResetPoints=11
	IUEnchantItem=12
	IUReturn=13
	IUSubMap=14
	IUSkillScroll=15
	IUFillDirect=16
	IUFillDirectRate=17
	IUUseScript=18
	IUApplyScript=19
	IUApplySelectScript=20
	IUApplyInputScript=21
	IUPetCage=22
	IUPetFood=23
	IUUseInstantScript=24
	IUDefenseRace=25
	IUSkillItem=26
	IUSetArmor=27
	IUSetArmorRace=28
	IUSetWeapon=29
	IUSetShield=30
	BTPotion=1
	BTSkill=2
	BTScroll=3
	BTMenu=4
	SBBareHand=1
	SBBareFoot=2
	SBOneHand=3
	SBTwoHand=4
	SBSpear=5
	SBBow=6
	SBSpirit=7
	SBStaff=8
	SBWhite=9
	SBWhiteSupport=10
	SBRed=11
	SBRedSupport=12
	SBBlue=13
	SBBlueSupport=14
	SBYellow=15
	SBYellowSupport=16
	SBBlack=17
	SBBlackSupport=18
	BookNames(0)="NullBook"
	BookNames(1)="BareHandBook"
	BookNames(2)="BareFootBook"
	BookNames(3)="OneHandBook"
	BookNames(4)="TwoHandBook"
	BookNames(5)="SpearBook"
	BookNames(6)="BowBook"
	BookNames(7)="SpiritBook"
	BookNames(8)="StaffBook"
	BookNames(9)="WhiteBook"
	BookNames(10)="WhiteSupportBook"
	BookNames(11)="RedBook"
	BookNames(12)="RedSupportBook"
	BookNames(13)="BlueBook"
	BookNames(14)="BlueSupportBook"
	BookNames(15)="YellowBook"
	BookNames(16)="YellowSupportBook"
	BookNames(17)="BlackBook"
	BookNames(18)="BlackSupportBook"
	MagicPrefix(0)="WHITE"
	MagicPrefix(1)="RED"
	MagicPrefix(2)="BLUE"
	MagicPrefix(3)="YELLOW"
	MagicPrefix(4)="BLACK"
	SSFinish=1
	SSMagic=2
	DialogSchemeHeader="<scheme height=12 base=#00ff00 link=#ffff00 highlight=#ff00ff>"
	HIT_Minimap=1
	HIT_Gauge=2
	HIT_Repair=3
	HIT_DialogLink=4
	IDT_Refined=1
	IDT_HPotion=2
	IDT_MPotion=3
	IDT_HMPotion=4
	IDT_Ring=5
	IDT_Necklace=6
	IDT_Bracelet=7
	IDT_OneHand=8
	IDT_TwoHand=9
	IDT_Glove=10
	IDT_Staff=11
	IDT_Spear=12
	IDT_Bow=13
	IDT_Arrow=14
	IDT_Armor=15
	IDT_Shield=16
	IDT_Gaiter=17
	IDT_Brassard=18
	IDT_Robe=19
	IDT_Helmet=20
	IDT_Cap=21
	IDT_Sendal=22
	IDT_Sleevelet=23
	IDT_Garb=24
	IDT_Gown=25
	IDT_Gem=26
	IDT_SubMapScroll=27
	IDT_ReturnScroll=28
	IDT_SkillScroll=29
	IDT_Shell=30
	IDT_Amulet=31
	IDT_Map=32
	IDT_Quest=33
	IDT_Money=34
	IDT_Event=35
	IDT_Protector=36
	IDT_Stack=37
	IDT_Stick=38
	IDT_PetFood=39
	IDT_PetCage=40
	IDT_SkillBook=41
	IDT_UnlimitArrow=42
	IDT_Earring=43
	IDT_Charm=44
	IDT_DeadPet=45
	IDT_Belt=46
	IDT_Emblem=47
	IDT_StackUI=48
	RM_Wedge=1
	RM_Sawdust=2
	RM_Bronze=3
	RM_Steel=4
	RM_AlloyPowder=5
	RM_RLeather=6
	RM_Strap=7
	RM_Patch=8
	RM_WareGemstone=9
	RM_GemPowder=10
	RM_PowerGem=11
	RM_HealthHerb=12
	RM_ManaHerb=13
	RM_HerbRoot=14
	EWS_None=1
	EWS_Defense=2
	EWS_Offense=3
	SM_Help=1
	SM_Operator=2
	SM_Result=3
	SM_Unknown=4
	SM_WhisperResult=5
	SM_MsgBox=100
	SM_Notice=101
	SM_EventAlarm=150
	SM_ClientOnly=255
}
