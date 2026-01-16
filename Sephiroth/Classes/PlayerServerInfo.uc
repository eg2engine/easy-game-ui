class PlayerServerInfo extends ServerInfo
	native;

var name PlayName;
var bool bIsMale;
var enum ERaceTypes 
	{
		Human, Elf, Berserker
	} 
	RaceType;
var enum EProfType 
	{
		Warrior, Sorcerer, Archer
	} 
	ProfType;

var name RaceName;
var name JobName;
var name CastleName;
var string ClanName, ClanTitle;

var name HairName, BodyName, FaceName;

var int PlayLevel, LevelPoint;
var float ExpDisplay;
var int Money;
var string strMoney;
var int Alignment, AlignmentColor;
var int Str, Dex, Vigor, White, Red, Blue, Yellow, Black;
var int Health, MaxHealth, Mana, MaxMana;
var float Stamina, MaxStamina;
var bool ArmState, RunState, PkState;
var EStateType StateType;
var bool CanPk;

/*!@2004.2.12 jhjung to protect move speed hacking*/
var float BaseSpeed;
var float WalkingPct;
var float MoveRatio;
/**/

var WornItems WornItems; // visuals only
var SephirothInventory SepInventory;
var array<SubInventory> SubInventories;

var string ComboSkill, FinishSkill, MagicSkill;
var int ComboPower, ComboRate;
var int FinishPower, FinishRate;
var int MagicPower, MagicRate;
var string DefenseEffect;
var int DefenseRate;

// ���� �л��
var int damageConcentration;
var int damageDistribution;

// ���� ���� ����
var int nCurrReputationPoint;
var int nUsedReputationPoint;

struct QuickKey {
	var byte Index;
	var byte Type;
	var string KeyName;
	var int Amount;
};
var array<QuickKey> QuickKeys;
var array<SkillBook> SkillBooks;

//@by wj(08/13)
var SecondSkillBook SecondSkillBook;
var int SkillCredit;

var array<string> EnchantMagics;

var(Party) bool bParty;
var(Skill) Skill Combo,Finish,Magic;
var bool bIsAlive;

var int PlayMode;

var int WarState;	//@by wj(12/19)

//@by wj(040624)------
var PetInventory PetInventory;
//@by wj(040722)------
var int Grade;
var bool bTransformed;
var bool CanTransform;
//@by wj(040803)------
var int RC;
var bool bBlind;
//--------------------

//ksshim + 2004.8.23
var int ManaState;

var int InvenEffectSpaceWidth;
var int InvenEffectSpaceHeight;

var string MatchName;
var string TeamName;
var string TeamDesc;

var array<string> AllyClans;
var array<string> EnemyClans;

var string WarLordClan;		// ksshim + 2005.4.6 meaningful only when player in the war map. (no reset, just update)

var enum EBoothState{ BS_None, BS_Open, BS_Prepare, BS_Visit } BoothState;
var string BoothTitle;
var bool bUseAd;
var string BoothAd;
var bool bUseTout;
var int BoothToutCount;

//////////////////////////////////
// keios - �̱� PVP ���� ����
var int PkPts;
var int PkPtsMax;	//�ִ�ġ sinhyub.
var int Kills;
var int Deads;
var int Match;
var int Win;
var int Lose;
var int Draw;
var bool CanPVP;


//modified by yj
var string Current_Show_Title;
struct BasePlayerTitleInfo {
	var string Title;
	var string Type_Name;
	var int acq_time;
	var int iValue;
};
var array<BasePlayerTitleInfo> Acquired_Title_List;
//////////////////////////////////

var bool StateNoUseSkill;			// keios - ��ų��� �Ұ� ����
var array<int>	PVPAttackers;		// keios - ������� ������ oid
var bool PVPIAmCriminal;			// keios - criminal flag

// tf ���� 
var bool IsClanMaster;

var bool IsClanSubMaster;

// ���� �ý���
var string TransToMonsterName; //add neive : ����
var string TransToMonsterPkgName; //add neive : ����

var string DisplayEmblemName;

// ������ ���� ��Ÿ��
var int userAccountType; //add neive : ����

//add neive : ���� ���� ���� �ð� ǥ�� ----------------------------------------
var array<int> EnchantMagicTimes;

struct native init _BuffIconData
{
	var string sName;
	var int nFlag;
	var string sPath;
	var string sDesc;
	var int nTime;
};

var array<_BuffIconData> BuffList;

var int nCurTime; // �ð� �޾Ƴ��� ����
var int nCurHour; // �Ű����� �ð�
var int nGapTime; // ������ Ŭ���̾�Ʈ���� �ð� ����
//-----------------------------------------------------------------------------

var int SetAvilityLevel; //add neive : 12�� �� ��Ʈ ȿ�� ���� (1~5)
var int SetWeaponLevel;  //add neive : 12�� ���� ���� ��Ʈ ȿ��

var int nLastBoothAddTime; //add neive : ���� ���� ����

//add neive : �ΰ��Ӽ� --------------------------------------------------------
var int m_nCashSephi;
var int m_nCashPoint;
var int nLastReflashTime;	//add neive : �ΰ��Ӽ� ���� ���� ���� ����
var int nLastBuyTime;		//add neive : ���Ÿ� ���������� ���ϰ� ����
//-----------------------------------------------------------------------------

//add neive : �� ����
struct DetailInfoData
{
	var float fBlock;
	var float fCri;
	var int   nDisblock;
	var int   nHit;
	var int   nRHP;
	var int   nRMP;
	var int   nIChance;
	var int   nMChance;
	var float fMove;
	var float fAtk;
	var int   nType1;
	var int   nType2;
	var int   nType3;
	var int   nType4;
	var int   nType5;
	var int   nType6;
	var int   nRatio1;
	var int   nRatio2;
	var int   nRatio3;
	var int   nRatio4;
	var int   nRatio5;
	var int   nRatio6;
	var int		nTypeDef1; //add neive : �Ӽ� ���
	var int		nTypeDef2;
	var int		nTypeDef3;
	var int		nTypeDef4;
	var int		nTypeDef5;
	var int		nTypeDef6;
	var int		nTypeDef7;
	var float MagicCriticalRate;	//���� ũ��Ƽ�� Ȯ��
	var float AntiCritical;			//��Ƽ ũ��Ƽ��
	var float AntiMagicCritical;	//��Ƽ ���� ũ��Ƽ��
	var int AbsCriticalDefense;	//ũ��Ƽ�� �¾��� �� - ����������
	var int AbsCriticalResist;	//���� ũ��Ƽ�� �¾��� �� -����������
	var float CriticalDefense;		//ũ��Ƽ�ø¾��� �� %������ ����
	var float MagicCriticalResist;	//���� ũ��Ƽ�� �¾��� �� %������ ����
	var float	fMagicDodge;		// ���� ȸ��
	var float	fRedMagicDodge;		// ���� ���� ȸ��
	var float	fBlueMagicDodge;	// ���� ���� ȸ��
};

var DetailInfoData DI; //add neive : ������â

struct ScheduleData
{
	var int nMistVillage;
	var int nMistVillageNight;
};

var ScheduleData Schedules;	//add neive : �Ȱ� ����

var int nNameLength;

var int nWaitingAttackResultCnt;		//add neive : ���� ���� ���� ��Ŷ ���� ����

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//@by wj(12/02)------
event ItemAmountUpdate(SephirothItem Item)
{
	local int i;
	local int QuickSlotTotalNum;
	QuickSlotTotalNum = class 'QuickKeyConst'.default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.default.QuickSlotRows;
	
	for(i = 0 ; i < QuickSlotTotalNum ; i++)
	{
		if(QuickKeys[i].KeyName == Item.TypeName)
			if(Item.IsEvent()) //add neive : �Ⱓ������ üũ
				QuickKeys[i].Amount = -99; // �Ⱓ���� ����
			else
				QuickKeys[i].Amount = SepInventory.GetItemAmountSum(Item.TypeName);
	}
}
//-------------------

//add neive : ���� ������ ������
event AddBuffData(string sName, int nFlag, string sPath, string sDesc, int nTime)
{
	local int i;

	for(i=0; i<BuffList.Length; i++)
	{
		if(BuffList[i].sName == sName)
		{
			BuffList.Remove(i, 1);
			break;
		}
	}	

	BuffList.Insert(BuffList.Length, 1);

	i = BuffList.Length - 1;

	BuffList[i].sName = sName;
	BuffList[i].nFlag = nFlag;
	BuffList[i].sPath = sPath;
	BuffList[i].sDesc = sDesc;
	BuffList[i].nTime = nTime;
}

event DelBuffData(int n)
{
	BuffList.Remove(n, 1);
}

event DelBuffDataFromName(string sName)
{
	local int i;
	
	for(i=0; i<BuffList.Length; i++)
	{
		if(BuffList[i].sName == sName)
		{
			BuffList.Remove(i, 1);
			return;
		}
	}	
}

function bool HasBuffByName(string name)
{
	local int i;

	for(i=0; i<BuffList.Length; i++)
	{
		if(BuffList[i].sName == name)
		{
			return true;
		}
	}
	return false;
}

event UpdateCash(int nSephi, int nPoint)
{
	m_nCashSephi = nSephi;
	m_nCashPoint = nPoint;
}

event ClearSubscription()
{
	//SubscriptionList.Remove(0, SubscriptionList.Length);
}

//add neive : �ΰ��Ӽ��� ��-;;
function int GetRealSehpi()
{
	local int n;
	
	n = m_nCashSephi;
	if(n < 0)
		return 0;
	
	return n;
}

function int GetRealPoint()
{
	local int n;
	
	n = m_nCashPoint;
	if(n < 0)
		return 0;
		
	return n;
}

function bool IsInGameShopBuyAble(int nPriceSephi, int nPricePoint)
{
	local string LangExt;
	
	if(nPriceSephi < 0 || nPricePoint < 0)	// 0 ������ �� �� ����
		return false;
	
	// ���� ���Ƿ��� �ڽ�Ʈ ���� ����
	if(GetRealSehpi() < nPriceSephi)
		return false;
		
	// ���� ����Ʈ���� �ڽ�Ʈ ���� ����
	if(GetRealPoint() < nPricePoint)
		return false;
		
	// �� �ѱ��� �ƴϴ� (���ö����� ����. �߱��� ������)
	//LangExt = ConsoleCommand("LANGEXT");
	//if (LangExt != "KOR")
	//	return false;
		
	return true;
}

// ��ü �����Ӽ��� ���̴�
function int GetMagicValue()
{
	return White + Red + Blue + Yellow + Black;
}

function InitAsDefault(bool bMale)
{
	CastleName='Ladianes';
	RaceName='Human';
	BodyName='HunterSuit';
	bIsAlive=true;
	bIsMale = bMale;
	if (bIsMale) {
		HairName='HairHM1';
		FaceName='FaceHM1';
	}
	else {
		HairName='HairHF1';
		FaceName='FaceHF1';
	}
}

function bool IsLocallyControlled()
{
	if (Owner == None) return false;
	if (ClientController(Owner) == None) return false;
	return true;
}

function string MoneyString()
{
	local string localStr;
	local int LR, i;
	local array<string> StrArr;

	localStr = string(Money);
	LR = Len(localStr) % 3;

	if (LR != 0) {
		StrArr[StrArr.Length] = Left(localStr, LR);
		localStr = Mid(localStr, LR);
	}
	while (localStr != "") {
		StrArr[StrArr.Length] = Left(localStr, 3);
		localStr = Mid(localStr, 3);
	}
	
	if (StrArr.Length > 0) {
		localStr = StrArr[0];
		for (i=1;i<StrArr.Length;i++)
			localStr = localStr $ "," $ StrArr[i];
	}
	return localStr;
}

function string MoneyStringEx(string m)
{
	local string localStr;
	local int LR, i;
	local array<string> StrArr;

	localStr = m;
	LR = Len(localStr) % 3;

	if (LR != 0) {
		StrArr[StrArr.Length] = Left(localStr, LR);
		localStr = Mid(localStr, LR);
	}
	while (localStr != "") {
		StrArr[StrArr.Length] = Left(localStr, 3);
		localStr = Mid(localStr, 3);
	}
	
	if (StrArr.Length > 0) {
		localStr = StrArr[0];
		for (i=1;i<StrArr.Length;i++)
			localStr = localStr $ "," $ StrArr[i];
	}
	return localStr;
}

function bool CanEquip(SephirothItem ISI,optional bool bCheckSkill)
{
	local int i,Value;
	for (i=0;i<ISI.ItemDemands.Length;i++) {
		switch (ISI.ItemDemands[i].Type) {
		case 0: Value=PlayLevel; break; //Level //add neive : �Ͱ��� �߰�
		case 1: Value=Str; break; //Str	
		case 2: Value=Dex; break; //Dex
		case 3: Value=Vigor; break; //Vigor
		case 4: Value=White+Red+Blue+Yellow+Black; break; //MagicPower
		case 5: Value=White; break; //White
		case 6: Value=Red; break; //Red
		case 7: Value=Blue; break; //Blue
		case 8: Value=Yellow; break; //Yellow
		case 9: Value=Black; break; //Black
		}
		if (ISI.ItemDemands[i].Value > Value)
			break;
	}
	if (i!=ISI.ItemDemands.Length)
		return false;
	if (bCheckSkill) {
		return false;
	}

	if (RaceName == 'Human' && (ISI.AttachRaceMask & class'GConst'.default.EPR_Human) != class'GConst'.default.EPR_Human) return false;
	if (RaceName == 'Nephilim' && (ISI.AttachRaceMask & class'GConst'.default.EPR_Nephilim) != class'GConst'.default.EPR_Nephilim) return false;
	if (RaceName == 'Titaan' && (ISI.AttachRaceMask & class'GConst'.default.EPR_Titaan) != class'GConst'.default.EPR_Titaan) return false;
	if (JobName == 'White' && (ISI.AttachJobMask & class'GConst'.default.EJT_White) != class'GConst'.default.EJT_White) return false;
	if (JobName == 'Red' && (ISI.AttachJobMask & class'GConst'.default.EJT_Red) != class'GConst'.default.EJT_Red) return false;
	if (JobName == 'Blue' && (ISI.AttachJobMask & class'GConst'.default.EJT_Blue) != class'GConst'.default.EJT_Blue) return false;
	if (JobName == 'Yellow' && (ISI.AttachJobMask & class'GConst'.default.EJT_Yellow) != class'GConst'.default.EJT_Yellow) return false;
	if (JobName == 'Black' && (ISI.AttachJobMask & class'GConst'.default.EJT_Black) != class'GConst'.default.EJT_Black) return false;
	if (JobName == 'Bare' && (ISI.AttachJobMask & class'GConst'.default.EJT_Bare) != class'GConst'.default.EJT_Bare) return false;
	if (JobName == 'OneHand' && (ISI.AttachJobMask & class'GConst'.default.EJT_OneHand) != class'GConst'.default.EJT_OneHand) return false;
	if (JobName == 'TwoHand' && (ISI.AttachJobMask & class'GConst'.default.EJT_TwoHand) != class'GConst'.default.EJT_TwoHand) return false;
	if (JobName == 'Spear' && (ISI.AttachJobMask & class'GConst'.default.EJT_Spear) != class'GConst'.default.EJT_Spear) return false;
	if (JobName == 'Bow' && (ISI.AttachJobMask & class'GConst'.default.EJT_Bow) != class'GConst'.default.EJT_Bow) return false;

	return true;
}

//add neive : �䱸ġ ���� ǥ�� ------------------------------------------------
function bool CanUse(SephirothItem ISI)
{
	if(ISI.DetailType == 45) //add neive : �Ͱ��� �߰�
		return true; // �������� ���� �ϴ� �������� true

	if (JobName == 'White' && (ISI.AttachJobMask & class'GConst'.default.EJT_White) != class'GConst'.default.EJT_White) return false;
	if (JobName == 'Red' && (ISI.AttachJobMask & class'GConst'.default.EJT_Red) != class'GConst'.default.EJT_Red) return false;
	if (JobName == 'Blue' && (ISI.AttachJobMask & class'GConst'.default.EJT_Blue) != class'GConst'.default.EJT_Blue) return false;
	if (JobName == 'Yellow' && (ISI.AttachJobMask & class'GConst'.default.EJT_Yellow) != class'GConst'.default.EJT_Yellow) return false;
	if (JobName == 'Black' && (ISI.AttachJobMask & class'GConst'.default.EJT_Black) != class'GConst'.default.EJT_Black) return false;
	if (JobName == 'Bare' && (ISI.AttachJobMask & class'GConst'.default.EJT_Bare) != class'GConst'.default.EJT_Bare) return false;
	if (JobName == 'OneHand' && (ISI.AttachJobMask & class'GConst'.default.EJT_OneHand) != class'GConst'.default.EJT_OneHand) return false;
	if (JobName == 'TwoHand' && (ISI.AttachJobMask & class'GConst'.default.EJT_TwoHand) != class'GConst'.default.EJT_TwoHand) return false;
	if (JobName == 'Spear' && (ISI.AttachJobMask & class'GConst'.default.EJT_Spear) != class'GConst'.default.EJT_Spear) return false;
	if (JobName == 'Bow' && (ISI.AttachJobMask & class'GConst'.default.EJT_Bow) != class'GConst'.default.EJT_Bow) return false;
	
	return true;
}
//-----------------------------------------------------------------------------

function string GetLeftChannel()
{
	local SephirothItem Item;
	if (WornItems != None) {
		Item = WornItems.FindItem(WornItems.IP_LEar);
		if (Item != None && Item.IsShell())
			return Item.Channel;
	}
	return "";
}

function string GetRightChannel()
{
	local SephirothItem Item;
	if (WornItems != None) {
		Item = WornItems.FindItem(WornItems.IP_REar);
		if (Item != None && Item.IsShell())
			return Item.Channel;
	}
	return "";
}

function bool IsBoothSeller()
{
	if( BoothState == BS_Prepare || BoothState == BS_Open )
		return true;
	return false;
}

function bool IsBoothGuest()
{
	if( BoothState == BS_Visit )
		return true;
	return false;
}

function bool IsEnchantBuff(string s) //add neive : ��þƮ �ɷ��ֳ� üũ
{
	local int i;
	for(i=0; i<EnchantMagics.Length; i++)
		if(EnchantMagics[i] == s)
			return true;

	return false;
}

function bool CheckBuffDontUseSkill()
{
	local int i;
	for(i=0; i<EnchantMagics.Length; i++)
		if(EnchantMagics[i] == "SilentFx") //add neive : AC ��ų, ���Ϸ�Ʈ �� ��ų ��� ����
			return true;

	return false;
}

function bool CheckBuffDontAct() //add neive : ����2nd �ൿ�Ҵ� ������ �ɷ��ֳ� üũ (�Լ� ����)
{
	local int i;
	for(i=0; i<EnchantMagics.Length; i++)
		if(EnchantMagics[i] == "Freezing" || EnchantMagics[i] == "Sleep" || EnchantMagics[i] == "Fetter")
			return true;

	return false;
}

function bool IsSTMBreak() //add neive : AC ��ų
{
	local int i;
	for(i=0; i<EnchantMagics.Length; i++)
	{
		if(EnchantMagics[i] == "STMBreak") // �������� ���¹̳�
			return true;

		if(EnchantMagics[i] == "DemolitionFx")
		{
			if(IsDelmolitionEx())
				return false;

			return true;
		}
	}

	return false;
}

static function bool CanAttackPlayer(PlayerServerInfo Src, PlayerServerInfo Dest, bool bUnderSiege)
{
	local int i;

	if (Src == None || Dest == None || Src == Dest)
		return false;

	//add neive : �ݷμ��� Įǥ�� ---------------------------------------------
	if(Dest.MatchName == "Colosseum")
		if(Src.MatchName == Dest.MatchName)
			return true;
	//-------------------------------------------------------------------------


	// keios - ������� ������ Įǥ��
	for(i=0; i < Src.PVPAttackers.Length; ++i)
	{
		if(Src.PVPAttackers[i] == Dest.PanID)
			return true;
	}

	if (bUnderSiege) {
		// �������� ���� Ŭ�������� PK�� �� �� �ֵ��� �Ѵ�. 
		if (Src.PkState)
			return true;

		// ����������� ���ݺҰ����ϴ�.
		if (Src.WarState == class'GConst'.default.EWS_Defense && 
			Dest.WarState == class'GConst'.default.EWS_Defense)
			return false;

		// ���� Ŭ���� ������������ ���ݺҰ����ϴ�.
		if (Src.WarState == class'GConst'.default.EWS_Offense && 
			Dest.WarState == class'GConst'.default.EWS_Offense){
			if(Src.ClanName == Dest.ClanName)
				return false;
			else{
				for (i=0;i<Src.AllyClans.Length;i++){
					if( Dest.ClanName == Src.AllyClans[i] )
						return false;
				}
				return true;
			}
		}

		// ���� Ŭ���� �߸��������� ���ݺҰ����ϴ�.
		if (Src.WarState == class'GConst'.default.EWS_None && 
			Dest.WarState == class'GConst'.default.EWS_None && 
			Src.ClanName != "" && 
			Src.ClanName == Dest.ClanName)
			return false;
		
		return true;
	}

	if( Src.Owner != None && ClientController(Src.Owner).ZSI != None && ClientController(Src.Owner).ZSI.bNoPvp )
		return false;

	// if I'm in a match... << ����� �� ����� �ǹ̾��� �ּ��� ���η����� �ƿ�����
	// ������ (Ȥ�� ��Ÿ match) �� ���� �ٸ��� ������ �����ϰ� �ϴ� ��ƾ
	if (Src.MatchName != "") {
		
		if (Src.MatchName == Dest.MatchName) {
			if (Src.TeamName == Dest.TeamName)
				return false;
			else
				return true;
		}
		else
			return false;
	}
	// if I'm not in a match...
	else {
		
		if (Dest.MatchName == "") {
			if (Src.PkState)
				return true;
			else{
				// not pkState, but if clanbattle...
				for (i=0;i<Src.EnemyClans.Length;i++){
					if( Dest.ClanName == Src.EnemyClans[i] )
						return true;
				}
				return false;
			}
		}
		else
			return false;
	}
		
	return false;
}

static function bool CanAttackGuardStone(PlayerServerInfo Src, GuardStoneServerInfo Dest)
{
	if (Src == None || Dest == None)
		return false;

	if (Dest.Helth <= 0)
		return false;

	// �����ڰ� ������̰�, ��ȣ���� ������̸� ���ݺҰ����ϴ�.
	if (Src.WarState == class'GConst'.default.EWS_Defense &&
		Dest.WarState == class'GConst'.default.EWS_Defense)
		return false;

	// �����ڰ� �������̰�, ��ȣ���� �������̸� ��ȣ���� ����Ŭ���� �������� �Ҽ�Ŭ���϶� ���ݺҰ����ϴ�.
	if (Src.WarState == class'GConst'.default.EWS_Offense &&
		Dest.WarState == class'GConst'.default.EWS_Offense &&
		Src.ClanName == Dest.ClanName)
		return false;

	// �����ڰ� �߸��̰ų� ��Ŭ���̸� ���ݺҰ����ϴ�.
	if (Src.WarState == class'GConst'.default.EWS_None)
		return false;

	return true;
}

static function bool CanAttackMatchStone(PlayerServerInfo Src, MatchStoneServerInfo Dest)
{
	if( Src == None || Dest == None )
		return false;

	if( Dest.Health <= 0 )
		return false;
	
	if( Src.TeamName == "" )
		return false;

	if( Dest.MatchName == Src.MatchName)
		return True;

	return False;
}

// keios - pk����Ʈ�� ���� �ı� ����Ʈ
function string GetHaloEffectShaderName()
{
	if( PkPts <= 0 )
	{
		return "";
	}
	else if(PkPts > 0 && PkPts <= 10)
	{
		return "PassiveEffect.PKEffect_W";
	} 
	else if(PkPts > 10 && PkPts <= 30)
	{
		return "PassiveEffect.PKEffect_Y";
	}
	else if(PkPts > 30 && PkPts <= 70)
	{
		return "PassiveEffect.PKEffect_G";
	}
	else if(PkPts > 70 && PkPts <= 150)
	{
		return "PassiveEffect.PKEffect_R";	
	}
	else if(PkPts > 150 && PkPts <= 300)
	{
		return "PassiveEffect.PKEffect_B";
	}
	else if(PkPts > 300)
	{
		return "PassiveEffect.PKEffect_D";
	}
	return "";
}


function bool IsWeaponORShield(int i) //add neive : 12�� ������ - �����ΰ� ���ΰ� üũ (�� 12�ܿ� �ش��ϴ°� �ƴ�����)
{
//	//Log("neive : check DT " $ i);
	// ������ �ε��� �ٲٸ� ������ߵǴ� ������ �Ф�
	if( i == class'GConst'.Default.IDT_Glove || i == class'GConst'.Default.IDT_Protector || 
			i == class'GConst'.Default.IDT_Stick ||
			i == class'GConst'.Default.IDT_OneHand || i == class'GConst'.Default.IDT_Shield ||
			i == class'GConst'.Default.IDT_Staff ||
			i == class'GConst'.Default.IDT_Bow )
		return True;

	return False;
}

function SetSetItemLevel()
{
	local int i, SetWeaponNum, SetItemNum;

	//add neive : 12�� ������ ��Ʈ ȿ�� ---------------------------------------
	for ( i = 0; i < WornItems.Items.Length; i++ )
	{
		if ( WornItems.Items[i].Level == 14 )
		{
			if ( IsWeaponORShield(WornItems.Items[i].DetailType) )
			{
				SetWeaponNum++;
			}
			else
				SetItemNum++;
		}
	}

	SetAvilityLevel = SetItemNum;
	SetWeaponLevel = SetWeaponNum;
	//-------------------------------------------------------------------------
}

//add neive : ��Ʈ ��� �����Ƽ ���� üũ
function int GetSetWeaponLevel(int nSetIndex)
{
	local int i, nSetWeaponLevel;

	for ( i = 0; i < WornItems.Items.Length; i++ )
	{
		if( WornItems.Items[i].m_nSetIndex == nSetIndex )
			if( IsWeaponORShield(WornItems.Items[i].DetailType) )
				nSetWeaponLevel++;
	}

	return nSetWeaponLevel;
}

function int GetSetArmorLevel(int nSetIndex)
{
	local int i, nSetArmorLevel;

	for ( i = 0; i < WornItems.Items.Length; i++ )
	{
		if( WornItems.Items[i].m_nSetIndex == nSetIndex )
			nSetArmorLevel++;
	}

	return nSetArmorLevel;
}

function bool IsDelmolitionEx()
{
	if( GetSetArmorLevel(7) >= 4 )	//add neive : ��Ʈ ���. �ü� ���� ��Ʈ ȿ���� �� ���������� �г�Ƽ�� ���ش�..  - -;; �־��� �����̴�..
		return True;

	return False;
}

function bool IsAuraOfFuryEx()
{
	if( GetSetArmorLevel(3) >= 2 )	//add neive : ��Ʈ ���. ���� ���� ��Ʈ ȿ���� �� �г�Ƽ ����
		return True;

	return False;
}

// 接受string类型的价格参数（用于处理超过21亿的大数字）
// sPriceSephi: 赛菲价格（如果有折扣价格，这里应该是折扣价格）
// sPricePoint: 点数价格
function bool IsInGameShopBuyAbleString(string sPriceSephi, string sPricePoint)
{

	local ClientController CC;
	local GameShopManager ShopManager;
	local GameManager GM;
	local string strCashSephi, strCashPoint;
	local string sPriceSephiCheck, sPricePointCheck;

	// 获取ClientController来使用native函数
	CC = ClientController(Owner);
	if( CC == None )
		return False;
	
	// 如果无法从 GameShopManager 获取，尝试通过 ClientController 的 Level 访问
	if( ShopManager == None && CC.Level != None && CC.Level.Game != None && CC.Level.Game.IsA('GameManager') )
	{
		GM = GameManager(CC.Level.Game);
		if( GM != None && GM.GameShopManager != None )
		{
			ShopManager = GM.GameShopManager;
		}
	}
	
	// 如果仍然无法获取 GameShopManager，使用 PlayerServerInfo 自己的货币信息（转换为string）
	if( ShopManager == None )
	{
		return False;
	}

	// 使用GameShopManager中的string类型货币（支持大数字）
	strCashSephi = ShopManager.m_nCashSephi;
	strCashPoint = ShopManager.m_nCashPoint;
	
	// 处理空字符串的情况，转换为 "0"
	if( strCashSephi == "" )
		strCashSephi = "0";
	if( strCashPoint == "" )
		strCashPoint = "0";
	
	// 处理价格字符串为空的情况
	sPriceSephiCheck = sPriceSephi;
	sPricePointCheck = sPricePoint;
	if( sPriceSephiCheck == "" )
		sPriceSephiCheck = "0";
	if( sPricePointCheck == "" )
		sPricePointCheck = "0";

	// 使用native函数 CmpInt64 进行比较：返回值 < 0 表示 a < b
	// 如果两个价格都无效（小于等于0），返回false
	if( CC.CmpInt64(sPriceSephiCheck, "0") <= 0 && CC.CmpInt64(sPricePointCheck, "0") <= 0 )
		return False;

	// 如果赛菲价格有效（大于0），检查赛菲余额是否足够
	if( CC.CmpInt64(sPriceSephiCheck, "0") > 0 )
	{
		if( CC.CmpInt64(strCashSephi, sPriceSephiCheck) < 0 )
			return False;
	}
	
	// 如果点数价格有效（大于0），检查点数余额是否足够
	if( CC.CmpInt64(sPricePointCheck, "0") > 0 )
	{
		if( CC.CmpInt64(strCashPoint, sPricePointCheck) < 0 )
			return False;
	}

	return True;
	
}
/**
 * 调试日志输出
 * @param message 要输出的消息
 */
function DebugLog(string message)
{
	local ClientController CC;
	
	// 通过Owner获取ClientController
	CC = ClientController(Owner);
	if( CC != None && CC.myHud != None )
	{
		CC.myHud.AddMessage(1, "DebugLog PlayerServerInfo: "@message, class'Canvas'.Static.MakeColor(128,255,255));
	}
}
//-----------------------------------------------------------------------------

defaultproperties
{
	RaceName="'"
	CastleName="'"
	PlayLevel=10
	bIsAlive=True
	WarState=1
	userAccountType=78
}
