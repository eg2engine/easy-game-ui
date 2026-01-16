class GameManager extends SephirothGameInfo
	native
	config;

var ClientController PlayerOwner;
var array<Creature> Creatures;
var array<Attachment> GroundItems;
var array<Hero> Heroes;

enum ESephirothMapType
{
	SEPHIROTH_Human,
	SEPHIROTH_Nephilim,
	SEPHIROTH_Titaan,
	SEPHIROTH_IceLand,
	SEPHIROTH_GhostTown,
};

/* Environment Parameters */
var(Environment) globalconfig bool bNoEnvironmentBlending;
var(Environment) globalconfig bool bNoUpdateTime;
var(Environment) Environment Environment;
var(Environment) string ZoneEnvironmentString;
var(Environment) array<Environment> Environments;

/* Music Parameters */
var(Music) MusicPlayer MusicPlayer;

/* Static Skill Books */
var array<SkillBook> StaticSkillBooks;

//@by wj(08/11)
var array<SecondSkillBook> Static2ndSkillBooks;

///////////////////////////////////////////////////////////////////////////////////////

// keios - Enchant ����
var EnchantTable		EnchantTable;			// keios - enchant table
var EnchantIconTable	EnchantIconTable;		// keios - enchant icon table

struct native _InGameShopCatalogueData
	{
	var int nIndex;
	var string sTitle;
	var string sDesc;
	var string sImage;
	var int nCategory;
	var int nFlag;
	var int nSephiPrice;	// ���� ����
	var int nPointPrice;	// ����Ʈ ����
	var int nSalePrice;		// ���� ����
	var int nCount;			// ���� ����
};

var array<_InGameShopCatalogueData> m_InGameShopCatalogueList;
var array<int> m_InGameShopADDList;

struct native _SubscriptionData
	{
	var int nIndex;
	var int nListIndex;
	var int nKeyTime;
};

var array<_SubscriptionData> m_SubscriptionList;

var array<string> m_InGamePackItemList;

var GameShopManager GameShopManager;
var GameCustomCmdManager GameCustomCmdManager;
var EtcInfoManager EtcInfoManager;

// enchant add/remove �Լ�
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

native function bool AddEnchantToController(Controller controller,
	name enchant_name, 
	optional float duration,
	optional bool newenchant);

native function RemoveEnchantFromController(Controller controller,
	name enchant_name);

native function bool GetNPCData(string sName, int outIndex, int outX, int outY);
///////////////////////////////////////////////////////////////////////////////////////

event PlayerController Login(string Portal, string Options, out string Error)
{
	local PlayerController PC;
	PC = Super.Login(Portal, Options, Error);
	PlayerOwner = ClientController(PC);
	return PC;
}

event PostLogin(PlayerController NewPlayer)
{
	local int i;

	Super.PostLogin(NewPlayer);
	MusicPlayer = Spawn(class'MusicPlayer');

	if( GameCustomCmdManager == None )
		GameCustomCmdManager = new(Self) class'GameCustomCmdManager';
		
	if( GameShopManager == None )
		GameShopManager = new(Self) class'GameShopManager';

	if( EtcInfoManager == None )
		EtcInfoManager = new(Self) class'EtcInfoManager';
	

	StaticSkillBooks[0] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BareHandBook",class'Class'));
	StaticSkillBooks[1] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BareFootBook",class'Class'));
	StaticSkillBooks[2] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.OneHandBook",class'Class'));
	StaticSkillBooks[3] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.StaffBook",class'Class'));
	StaticSkillBooks[4] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BowBook",class'Class'));
	StaticSkillBooks[5] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.SpiritBook",class'Class'));
	StaticSkillBooks[6] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.RedBook",class'Class'));
	StaticSkillBooks[7] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.RedSupportBook",class'Class'));
	StaticSkillBooks[8] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BlueBook",class'Class'));
	StaticSkillBooks[9] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BlueSupportBook",class'Class'));
	StaticSkillBooks[10] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.MonsterBook",class'Class'));
	StaticSkillBooks[11] = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.MonsterFxBook",class'Class'));

	for ( i = 0;i < StaticSkillBooks[0].Skills.Length;i++ )
		StaticSkillBooks[0].Skills[i].BookName = "BareHand";
	for ( i = 0;i < StaticSkillBooks[1].Skills.Length;i++ )
		StaticSkillBooks[1].Skills[i].BookName = "BareFoot";
	for ( i = 0;i < StaticSkillBooks[2].Skills.Length;i++ )
		StaticSkillBooks[2].Skills[i].BookName = "OneHand";
	for ( i = 0;i < StaticSkillBooks[3].Skills.Length;i++ )
		StaticSkillBooks[3].Skills[i].BookName = "Staff";
	for ( i = 0;i < StaticSkillBooks[4].Skills.Length;i++ )
		StaticSkillBooks[4].Skills[i].BookName = "Bow";
	for ( i = 0;i < StaticSkillBooks[5].Skills.Length;i++ )
		StaticSkillBooks[5].Skills[i].BookName = "Spirit";
	for ( i = 0;i < StaticSkillBooks[6].Skills.Length;i++ )
		StaticSkillBooks[6].Skills[i].BookName = "Red";
	for ( i = 0;i < StaticSkillBooks[7].Skills.Length;i++ )
		StaticSkillBooks[7].Skills[i].BookName = "RedSupport";
	for ( i = 0;i < StaticSkillBooks[8].Skills.Length;i++ )
		StaticSkillBooks[8].Skills[i].BookName = "Blue";
	for ( i = 0;i < StaticSkillBooks[9].Skills.Length;i++ )
		StaticSkillBooks[9].Skills[i].BookName = "BlueSupport";
	for ( i = 0;i < StaticSkillBooks[10].Skills.Length;i++ )
		StaticSkillBooks[10].Skills[i].BookName = "Monster";
	for ( i = 0;i < StaticSkillBooks[11].Skills.Length;i++ )
		StaticSkillBooks[11].Skills[i].BookName = "MonsterFx";

	//@by wj(08/11)------
	Static2ndSkillBooks[0] = new(None) class<SecondSkillBook>(DynamicLoadObject("SkillBooks.BareSecondSkillBook",class'Class'));
	Static2ndSkillBooks[1] = new(None) class<SecondSkillBook>(DynamicLoadObject("SkillBooks.OneHandSecondSkillBook",class'Class'));
	Static2ndSkillBooks[2] = new(None) class<SecondSkillBook>(DynamicLoadObject("SkillBooks.RedSecondSkillBook",class'Class'));
	Static2ndSkillBooks[3] = new(None) class<SecondSkillBook>(DynamicLoadObject("SkillBooks.BlueSecondSkillBook",class'Class'));
	Static2ndSkillBooks[4] = new(None) class<SecondSkillBook>(DynamicLoadObject("SkillBooks.BowSecondSkillBook",class'Class'));
	//-------------------

	//add neive : '0' �ӽ�	
	AddInGamePackItem("Market_Box_SephirothGem_G1_5");
	AddInGamePackItem("Market_Box_SephirothGem_G1_10");		
	AddInGamePackItem("Market_Box_AquamarineGem_G1_5");		
	AddInGamePackItem("Market_Box_AquamarineGem_G1_10");		
	AddInGamePackItem("Market_Box_BlueTears_G1_5");	
	AddInGamePackItem("Market_Box_BlueTears_G1_10");
	AddInGamePackItem("Market_Box_RedHonors_G1_5");
	AddInGamePackItem("Market_Box_RedHonors_G1_10");
	AddInGamePackItem("Market_Box_ChoiceEraser_5");
	AddInGamePackItem("Market_Box_ChoiceEraser_10");
	AddInGamePackItem("Market_Box_InitST_All_5");
	AddInGamePackItem("Market_Box_InitST_All_10");
	AddInGamePackItem("Market_Box_InventoryBagSet");
}

event AddCatalogue(int nIndex, string sTitle, string sImage, string sDesc, int nCategory, int nFlag, int nSephiPrice, int nPointPrice, int nSalePrice, int nCount)
{
	local int i;

	// '0' ��.. ���� �����ϳ�
	m_InGameShopCatalogueList.Insert(m_InGameShopCatalogueList.Length, 1);

	i = m_InGameShopCatalogueList.Length - 1;

	m_InGameShopCatalogueList[i].nIndex = nIndex;
	m_InGameShopCatalogueList[i].sTitle = sTitle;
	m_InGameShopCatalogueList[i].sImage = sImage;
	m_InGameShopCatalogueList[i].sDesc = sDesc;
	m_InGameShopCatalogueList[i].nCategory = nCategory;
	m_InGameShopCatalogueList[i].nFlag = nFlag;
	m_InGameShopCatalogueList[i].nSephiPrice = nSephiPrice;
	m_InGameShopCatalogueList[i].nPointPrice = nPointPrice;
	m_InGameShopCatalogueList[i].nSalePrice = nSalePrice;
	m_InGameShopCatalogueList[i].nCount = nCount;
}

event AddInGameShopADDList(int nIndex)
{
	local int i;

	m_InGameShopADDList.Insert(m_InGameShopADDList.Length, 1);

	i = m_InGameShopADDList.Length - 1;

	m_InGameShopADDList[i] = nIndex;
}

event ClearSubscription()
{
	m_SubscriptionList.Remove(0, m_SubscriptionList.Length);
}

event AddSubscription(int nIndex, int nKeyTime)
{
	local int i, n;
	
	for( i = 0; i < m_SubscriptionList.Length; i++ )
		if( m_SubscriptionList[i].nKeyTime == nKeyTime )
			return ;

	if( m_InGameShopCatalogueList.Length == 0 )
		return;

	for( i = 0; i < m_InGameShopCatalogueList.Length; i++ )
	{
		if( m_InGameShopCatalogueList[i].nIndex == nIndex )
		{
			//Log(eive : check AddSubscription OK");
			m_SubscriptionList.Insert(m_SubscriptionList.Length, 1);
			
			n = m_SubscriptionList.Length - 1;
			
			m_SubscriptionList[n].nIndex = nIndex;
			m_SubscriptionList[n].nListIndex = i;
			m_SubscriptionList[n].nKeyTime = nKeyTime;	
		}
	}
}

event DelSubscription(int nIndex, int nKeyTime)
{
	local int i;
	
	for( i = 0; i < m_SubscriptionList.Length; i++ )
	{
		if( m_SubscriptionList[i].nKeyTime == nKeyTime )
		{
			if( m_SubscriptionList[i].nIndex == nIndex )
			{
				//Log("res cancel " $ nIndex $ ", " $ nKeyTime);
				m_SubscriptionList.Remove(i, 1);
				return;			
			}
		}
	}
}

function Skill QueryStaticSkillByName(string SkillName)
{
	local int i;
	local Skill Skill;
	for ( i = 0;i < StaticSkillBooks.Length;i++ ) 
	{
		Skill = StaticSkillBooks[i].QuerySkillByName(SkillName);
		if ( Skill != None )
			return Skill;
	}
}

function AddInGamePackItem(string sName)
{
	local int i;

	// '0' ��.. ���� �����ϳ�
	m_InGamePackItemList.Insert(m_InGamePackItemList.Length, 1);

	i = m_InGamePackItemList.Length - 1;
	
	m_InGamePackItemList[i] = sName;
}

function bool CheckPackItem(string sName)
{
	local int i;
	
	for( i = 0; i < m_InGamePackItemList.Length; i++ )
		if( m_InGamePackItemList[i] == sName )
			return True;
			
	return False;
}

defaultproperties
{
	HUDType="Sephiroth.GameHUD"
}
