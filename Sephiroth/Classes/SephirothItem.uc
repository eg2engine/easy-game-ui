class SephirothItem extends Object
	native;

const ITEM_HAS_NO_AMOUNT = -1;
const ITEM_HAS_NO_PRICE = -1;
const ITEM_ISNOT_ATTACHABLE = -1;

const IDT_Raw = 0;
const IDT_Refined = 1;
const IDT_HPotion = 2;
const IDT_MPotion = 3;
const IDT_HMPotion = 4;
const IDT_Ring = 5;
const IDT_Necklace = 6;
const IDT_Bracelet = 7;
const IDT_OneHand = 8;
const IDT_TwoHand = 9;
const IDT_Glove = 10;
const IDT_Staff = 11;
const IDT_Spear = 12;
const IDT_Bow = 13;
const IDT_Arrow = 14;
const IDT_Armor = 15;
const IDT_Shield = 16;
const IDT_Gaiter = 17;
const IDT_Brassard = 18;
const IDT_Robe = 19;
const IDT_Helmet = 20;
const IDT_Cap = 21;
const IDT_Sendal = 22;
const IDT_Sleevelet = 23;
const IDT_Garb = 24;
const IDT_Gown = 25;
const IDT_Gem = 26;
const IDT_SubMapScroll = 27;
const IDT_ReturnScroll = 28;
const IDT_SkillScroll = 29;
const IDT_Shell = 30;
const IDT_Amulet = 31;
const IDT_Map = 32;
const IDT_Quest = 33;
const IDT_Money = 34;
const IDT_Event = 35;
const IDT_Protector = 36;
const IDT_Stack = 37;
const IDT_Stick = 38;
const IDT_PetFood = 39;
const IDT_PetCage = 40;
const IDT_SkillBook = 41;

const IDT_UnlimitArrow = 42;
const IDT_Earring = 43; //add neive : 귀걸이 추가
const IDT_Charm = 44; //add neive : 부적 장비화
const IDT_DeadPet = 45;
const IDT_Belt = 46;	//add neive : 벨트 추가 2
const IDT_Emblem = 47;	//add neive : 엠블렘 추가
const IDT_StackUI = 48;	//add ssemp : UI오픈 아이템 추가
const IDT_SeaShell = 49;
const IDT_Wings = 50;
const IDT_None = 51;

// 젠장 GConst.uc 에도 맞춰줘야한다 둘중 하나 날려버리던가

// Base information
var int PanID;
var vector Location;
var string TypeName;
var int Level;
var string ModelName;
var string KindName;
var string Description;
var string LocalizedDescription;
var string Tooltip;
var byte UsageType;
var byte Rareness;
var int Color;
var int X;
var int Y;
var int Width;
var int Height;
var int DetailType;
var int ReuseType;
var float MaxDurability;
var float Durability;
var int Amount;
/*!@2004.3.22,jhjung*/
var int SellPrice;
var string strSellPrice;
var int RepairPrice;
var int UntilTime;               // tf 아이템 
var string strRepairPrice;
var int BuyPrice;
var string strBuyPrice;

// Xelloss : 봉인상태
enum eSEALFLAG	{

	SF_NORMAL,			// 일반 (상관없음)
	SF_SEALED,			// 봉인됨 (미사용)
	SF_USED,			// 봉인 해제됨 (사용됨)
};

var byte xSealFlag;

var int iDamageConcentration;
var	int iDamageDistribution;		// Xelloss

/**/
var int EquipPlace;

var bool bPricePerEach;
var int BoothPrice;
var string strBoothPrice;

// Priviledge information
var array<name> PriviledgePeople;


// Attach information
var int AttachPlace;
var int AttachRaceMask;
var int AttachJobMask;

struct ItemDemand
{
	var byte Type;
	var string Name;
	var int Value;
};
var array<ItemDemand> ItemDemands;

struct ItemAffix
{
	var string AffixName;
	var int AffixValue;
	var string Display;
};
var array<ItemAffix> Affixes;

//@by wj(040304)
var array<string> SpecialAffixes;

// IUAttack
var float Quality;
var int AttackRange;
var float AttackSpeed;
var range AttackDamage;
var range MagicDamage;
var array<range> RaceAttackPower;
var int m_nSetIndex; //add neive : 세트 효과

// IUArrow
var float BasicDamageRate;
var array<float> RaceAttackRate;
// IUDefenseEffect
var string DefenseEffect;
// IUDefenseRate
var float DefenseRate;
// IUFillAdd/Rate
var float Health;
var float Mana;
var int Weight;
// IUShell
var string Channel;

//@by wj(10/04)------
//	IUPetCage
var string PetType;
var string PetName;
var int PetLevel;
var int PetHPPoint;  // kcman
var int PetManaPoint;  
var int PetAttackPoint;  
var int PetInventoryPoint;  
var int PetPoint;  
var string PetColor;  
//-------------------

// HouseKeeping
var bool bSelected;
var Attachment Model;

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

function bool CanPickup(name ProbeName)
{
	local int i;
	if (PriviledgePeople.Length == 0 || ProbeName == '')
		return true;
	for (i=0;i<PriviledgePeople.Length;i++)
		if (PriviledgePeople[i] == ProbeName)
			return true;
	return false;
}

function bool CanEquip()
{
	switch (DetailType) {
	case IDT_Ring:
	case IDT_Necklace:
	case IDT_Bracelet:
	case IDT_OneHand:
	case IDT_TwoHand:
	case IDT_Glove:
	case IDT_Staff:
	case IDT_Spear:
	case IDT_Bow:
	case IDT_Arrow:
	case IDT_Armor:
	case IDT_Shield:
	case IDT_Gaiter:
	case IDT_Brassard:
	case IDT_Robe:
	case IDT_Helmet:
	case IDT_Cap:
	case IDT_Sendal:
	case IDT_Sleevelet:
	case IDT_Garb:
	case IDT_Gown:
	case IDT_Shell:
	case IDT_Protector:
	case IDT_Stick:
	case IDT_Earring: //add neive : 귀걸이 추가
	case IDT_Charm: //add neive : 부적 장비화
	case IDT_Belt:	//add neive : 벨트 추가 2
	case IDT_Emblem:	//add neive : 엠블렘 추가
	case IDT_SeaShell:		//add ssemp : 신규 마법소라 아이템 추가
	case IDT_Wings :		// Xelloss : 등부위 추가
		return true;
	}
	return false;
}

function bool CanDisplayDurability()
{
	if(DetailType == IDT_Charm || DetailType == IDT_Ring || DetailType == IDT_Necklace
		|| DetailType == IDT_Bracelet || DetailType == IDT_Earring || DetailType == IDT_Arrow)
		return false;

	if(MaxDurability == -1 || Durability == -1)
		return false;

	return true;
}

function string GetAttachRace()
{
	if (AttachRaceMask == 1) return "H"; // Human
	if (AttachRaceMask == 2) return "N"; // Nephilim
	if (AttachRaceMask == 4) return "T"; // Titaan
	return "";
}

function CloneItem(SephirothItem Item);

function bool IsPotion() { return DetailType == IDT_HPotion || DetailType == IDT_MPotion || DetailType == IDT_HMPotion; }
function bool IsHPotion() { return DetailType == IDT_HPotion || DetailType == IDT_HMPotion; }      //cs added
function bool IsMPotion() { return  DetailType == IDT_MPotion || DetailType == IDT_HMPotion; }       //cs added
function bool IsMaterial() { return DetailType == IDT_Raw; }
function bool IsUse() { return KindName == "Use"; }
function bool IsGem() { return DetailType == IDT_Gem; }
function bool IsApplication() { return KindName == "Application"; }
function bool IsApplicationSelect() { return KindName == "ApplicationSelect"; }
function bool IsApplicationRemoveSelect() { return KindName == "ApplicationRemoveSelect"; }
//function bool IsShell() { return DetailType == IDT_Shell; }
function bool IsShell() { return (DetailType == IDT_Shell || DetailType == IDT_SeaShell ); }
function bool IsSeaShell() { return ( DetailType == IDT_SeaShell ); }   //@cs added
function bool IsCloth() { return DetailType == IDT_Armor || DetailType == IDT_Robe || DetailType == IDT_Garb || DetailType == IDT_Gown; }
function bool IsReturnScroll() { return DetailType == IDT_ReturnScroll; }
//function bool IsDetectScroll() { return DetailType == IDT_DetectScroll; }
function bool IsSkillScroll() { return DetailType == IDT_SkillScroll; }
function bool IsSubMapScroll() { return DetailType == IDT_SubMapScroll; }
function bool IsPortalScroll() { return DetailType == IDT_Stack; }
//function bool IsScroll() { return DetailType == IDT_ReturnScroll || DetailType == IDT_DetectScroll || DetailType == IDT_SkillScroll || DetailType == IDT_SubMapScroll || DetailType == IDT_Stack; }
function bool IsScroll() { return DetailType == IDT_ReturnScroll || DetailType == IDT_SkillScroll || DetailType == IDT_SubMapScroll || DetailType == IDT_Stack; }
function bool IsStatGem() { return UsageType == class'GConst'.default.IUResetPoints; }
function bool IsRefined() { return DetailType == IDT_Refined; }
function bool IsQuiver() { return DetailType == IDT_Arrow; }
function bool IsSkillBook() { return DetailType == IDT_SkillBook; }
function bool IsEvent() { return DetailType == IDT_Event; }

//@by wj(10/04)------
function bool IsPetCage() { return (DetailType == IDT_PetCage || ModelName == "PetDeadCage"); }
function bool IsPetFood() { return DetailType == IDT_PetFood; }
function bool IsApplicationInput() { return KindName == "ApplicationInput"; }
function bool IsPetNameChange() { return KindName == "PetNameInput"; }
//-------------------

function bool IsStackUI() { return DetailType == IDT_StackUI; }		// Add ssemp

function bool IsMarket()
{
	local string sTemp;
	sTemp = Mid(ModelName, 0, 7);

	if(sTemp == "Market_")
		return true;

	return false;
}

function bool IsUnseal()	// 봉인 해제된 상태
{
	return xSealFlag == eSEALFLAG.SF_USED;
}

function bool IsSeal()	// 봉인된 상태
{
	return xSealFlag == eSEALFLAG.SF_SEALED;
}

function bool IsPermanent() { return ReuseType == 0; }
function bool IsDisposable() { return ReuseType == 1; }
function bool IsRecyclable() { return ReuseType == 2; }

function bool HasAmount() { return Amount != ITEM_HAS_NO_AMOUNT; }

function material GetMaterial(PlayerServerInfo Owner)
{
	local string Race, Gender;
	if (Owner != None) 
	{
		if (Owner.bIsMale) 
			Gender = "M";
		else 
			Gender = "F";

		if (IsCloth() || InStr(ModelName, "SantaCap") != -1 || InStr(ModelName, "MysticCap") != -1) 
		{
			if (InStr(ModelName, "Tuxedo") != -1 || InStr(ModelName, "WeddingDress") != -1)
				Race = "H";
			else 
			{
				switch (AttachRaceMask) {
				case class'GConst'.default.EPR_Human:
					Race = "H";
					break;
				case class'GConst'.default.EPR_Nephilim:
					Race = "N";
					break;
				case class'GConst'.default.EPR_Titaan:
					Race = "T";
					break;
				}
			}
			
			//add neive : 블랙계열 옷들은 다른 곳에서 스프라이트 로드 ---------
			if(InStr(ModelName, "TriumphusArmor_Black") != -1 ||
				InStr(ModelName, "AcuraArmor_Black") != -1 ||
				InStr(ModelName, "UltimaGarment_Black") != -1 ||
				InStr(ModelName, "MysticGarb_Black") != -1 ||
				InStr(ModelName, "FabulaGown_Black") != -1)
			{
				return material(DynamicLoadObject("ItemSpritesA." $ ModelName $ Race $ Gender, class'Material'));
			}
			//-----------------------------------------------------------------
			else
			return material(DynamicLoadObject("ItemSprites." $ ModelName $ Race $ Gender, class'Material'));
		}
		else
		{
			//add neive : 마켓아이템용 스프라이트 로드 ------------------------
			if(IsMarket()) // 마켓아이템인지 체크
				return material(DynamicLoadObject("ItemSpritesM." $ ModelName, class'Material'));
			else                        // 마켓아이템이 아니라면 그냥 옛날부터 써오던 일반 아이템
			return material(DynamicLoadObject("ItemSprites." $ ModelName, class'Material'));
		}
	}
}

function GetAffixList(out array<string> AffixList)
{
	local int i;

	AffixList.Remove(0,AffixList.Length);
	for (i=0;i<Affixes.Length;i++)
		AffixList[i] = Affixes[i].Display;
}

defaultproperties
{
     Amount=-1
     SellPrice=-1
     RepairPrice=-1
     BuyPrice=-1
     AttachPlace=-1
}
