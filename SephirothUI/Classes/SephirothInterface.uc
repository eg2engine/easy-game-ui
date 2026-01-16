/*!@
	[2004.1.28, jhjung]
	- ��������Ʈ ǥ�� ���� �巡��� ĳ���Ͱ� ���콺 Ŀ���� ����ٴϴ� ������ ������
	  �巡���� ������� �ʰ�, �ػ󵵰� ����Ǿ ȭ���� ������ �ʰ� �ٹ��̵ǵ��� ��.
	- ��Ű�� ��ϵ� �������� ������ 0�̵ɶ� ��Ű���� ������ �ʴ� ���� ������. (������ Ȥ�� ������ ������ ��)
	[2004.2.8, jhjung]
	- ������忡�� ��� �����̸� ����� �� �ֵ��� ������.
*/
class SephirothInterface extends CDesktop
	config(SephirothUI);

var int UIType;
var bool bVanished;
var bool NoCheckPapering;
var bool bAlreadyDisconnected;

// �����׽�Ʈ�� Ŭ����
var private UnitTest_Interface utInterface;
var private UnitTest_Portal utPortal;
var private UnitTest_MeleeAttack utMeleeAttack;
var private UnitTest_RangeAttack utRangeAttack;
var private UnitTest_SummonSpirit utSummonSpirit;
var private UnitTest_FindItem utFindItem;
var private Macro_Potion atPotion;
var private Macro_MasterAll atMaster;
var private Macro_DropAll13 atDropAll13;
var private UnitTest_DropMonsterItem utDropItem;
var private Macro_AutoAttack atAttack;

var InterfaceUtil IU;

const Type1 = 0;
const Type2 = 1;

const IDM_QuitGame			= 1;
const IDM_PartyJoin			= 2;
const IDM_PartyInvite		= 3;
const IDM_ExchangeRequest	= 4;
const IDM_QuitAtField		= 5;
const IDM_ClanApplyCancel	= 6;
const IDS_ClanApply			= 1;
const IDM_BoothOpenWithAd	= 7;
const IDM_BoothVisit		= 8;
// keios - userreport help id
const IDD_USERREPORTHELP	= 10;
//add neive : NPC ã��
const IDD_FindNPC			= 11;
const IDM_SEALEDITEM		= 12;		// Xelloss
const IDM_MentorRequest		= 13;
const IDM_MenteeRequest		= 14;

var string ReportText;

//add neive : ������ ���� -----------------------------------------------------
const IDM_WebShop = 99;
//-----------------------------------------------------------------------------

var CMainInterface MainHud;
var SimpleInterface SimpleHud;
var CGaugeInterface GaugeHud;
//var Minimap Minimap;
var CMiniMap m_MiniMap;
var CMainMenu MainMenu;
var CChannelManager ChannelMgr;


//********
var MenuList MenuList;
var Inbox_Helper Inbox_Helper;
//********

var CPlayerInfo m_PlayerInfo;
var CDetailInfo DetailInfo;		//add neive : ������â
var CEtcInfo BattleInfo;		//modified by yj : ��������â

var CIngameShop m_IngameShop;	//add neive : �ΰ��Ӽ�
var CIngameShopBox m_IngameShopBox;
var CIngameShopDlg m_IngameShopDlg;
var bool bOnInGameShop;

var CBattleInterface BattleInterface;   //����Ʋ �������̽� ����(�ϳ��� MultiInterface�� ����). 2010.1.20.Sinhyub

var COption Option;
var InventoryBag m_InventoryBag;
var CSkillTree SkillTree;
var CParty Party;
var CTrade Exchange;
var CStore Store;
var CStashLobby StashLobby;
var CDialog DialogMenu;
var XMenu XMenu;
var CAnimationMenu AnimationMenu;
var CDeadMenu DeadMenu;
var CHelp Help;
var CCompound Compound;
var Smithy Smithy;
var CQuest Quest;
var	CMentorInterface		IMentorInterface;
var float timeQuest;	// Xelloss
var CPlugin Plugin;

var CPortal Portal;
var float timePortal;	// Xelloss

var CTooltip Tooltip;
var CMapInterface MapInterface;
var CSoundInterface SoundInterface;
var CDevInterface DevInterface;
var CBooth_Seller SellerBooth;
var CBooth_Guest GuestBooth;
var CWebBrowser WebBrowser;
var array<CBagResizable> SubInventories;    //Ȯ�� �κ��丮. Sinhyub.
var CSubInventorySelectBox SubSelectBox;	// ���� ������� SelectBox�� �˱� ���� Xelloss

var Game_Login Login; //add neive : �α���
var CWorldMap WorldMap; //add neive : �����
var BuffIcon Buff; //add neive : ���� ���� ǥ��
var CQuestBrowser m_QuestBrowser;

/*@by wj(02/21)-----------*/
var messenger messenger;
var float timeMessenger;		// Xelloss

var ScreenEffect BlendingEffect;	//@by wj(040327)

var PetDialog PetChat;	//@by wj(040618)
var PetBag	  PetBag;	//@by wj(040618)

var CTextPool MsgPool;

struct MSG_RECV
{
	var string	strName;
	var int		nOccuID;
};

var array<MSG_RECV> aReceivedPSI;		// ��û�� Queue�� �װ� ó���ϵ��� PSI�� �迭�� �����Ѵ�.
var CMessageBox					msgBoxReceived;		// ���� �����ִ� �޽����ڽ�
var float						fRecvMsgTime;		// �ڵ��������� ó���ϱ� ���� Ÿ�̸�

var PlayerServerInfo ExchangePSI;
var string PartyPlayer;
var string TracePlayerName;
var int PartyPlayerLevel; // ��Ƽ ����

var int TempSellerId;

var float TimeZoneUpdated;
var string ZoneString;
var bool bRenderTopStuff;

var string S_CastleEnding, S_ZoneEnding, S_ZoneUnknown, S_TooClose;
var bool bRequestExit;

var Font ArialFont;

var float StatX, StatY;
var bool bShowStat;
var float StatClickTime;

var bool bDraggingControl;		//���ǹ��� �����ΰ� ���� ����������, Ȥ�ó��� ���� ����������Ʈ���� Ŀ��Ʈ�ƿ�ó���մϴ�. 2009.10.27.Sinhyub

var string GMWord;
var Sound GMSound;

var bool bPlotLocation;

var CInfoBox SkillInfo, ItemInfo;
var CInfoBox InfoBox;//@by wj(09/08)

// keios - maininterface�� �������� �ʴ� InfoBox
var CInfoBox GItemInfo, GSkillInfo, GSecondSkillInfo;

var CInfoBox ItemTooltipBox;	// Xelloss
var CInfoBox ItemCompareBox;	// Xelloss

var string TestSkillName;

var CCastleManager CastleManager;

var ItemRemodeling RemodelingUI;//@by wj(040311)


//*** Pet system 03.9.29 by BK
var CPetInfo m_PetInfo;
var CPetMain m_PetMain;
var bool bPetSummon;
var bool bShowPetFace;
var bool bPetChangeable;
var bool bPetTwinkle;
//****************************

var globalconfig int SubInven0_X, SubInven0_Y, SubInven1_X, SubInven1_Y, SubInven2_X, SubInven2_Y;
// Ȯ���κ��丮�� �����ִ��� ������ ����. �κ��丮 ���� �Բ� �����ֱ� ���ؼ�. SubInventorySelectBox�� �Ҹ�ɶ� ����.
var globalconfig bool bSubInven0_On, bSubInven1_On, bSubInven2_On;


/*	���� �޴� ��ư�� ��������ϴ�. 2009.11.10.Sinhyub
//add neive : ���θ޴���ư�� --------------------------------------------------
var int nMainBtnX; // ��ư�� �׷��� x
var int nMainBtnY; // ��ư�� �׷��� y
var string sTest;
//-----------------------------------------------------------------------------
*/

//add neive : ���� ǥ�ÿ� -----------------------------------------------------
var int nAcountMode;
//-----------------------------------------------------------------------------

//var string MydebugString;

//add neive : ��ų ���ÿ� ���ٰ� �ؼ� ������ ���� ���� üũ�ؼ� ���ƺ�
var int nLastItemUseTime;

//add neive : �Ҹ� ��ũ�ѷ� ������ ���� ��� ����
var int nLastScrollUseTime;
var string sLastTypeName;

//!@ ��Ű������ ĳ���ϱ� ���� ����ü.
struct ItemNamePair
{
	var string TypeName;
	var string ModelName;
};
var globalconfig array<ItemNamePair> ItemNamePairs;
var color TeamTellColor;
var color ClanTellColor;


enum EPaperingType 
{
	PT_None,
	PT_TooFast,
	PT_AverageOver,
	PT_History
};

var float LastSyncTime;				// �޽����� ���� �����ð�
var float PaperingProbeSeconds;		// ���踦 �˻��� �ð�
var float PaperingBlockTicks;		// ���� ���� ������ ���� �ð�
var float PaperingBlockSeconds;		// ���� ���� �ð�
var float PaperingBlockSecondsMax;	// ���� ���� �ִ� �ð�
var float PaperingBlockFactor;		// ���� ���� �ð� ���� ����
var bool bBlockPapering;			// ���� ���� ���� ��Ÿ���� �÷���
var int PaperingBlockCount;			// ���� ���� ȸ��

var int SyncCountInProbeSeconds;	// �˻� �ð� ���� ��ũ�� ȸ��
var float SyncCountPerSecond;		// ���� �ð� ���� ����ϴ� ��ũ ȸ��

var float AverageSyncSeconds;

var array<string> MessageHistory;
var float HistoryProbeSeconds;

var CDialogSession DialogSession;

//@by wj(040201)
var CClanInterface ClanInterface;

// keios - enchantbox ui
var EnchantBoxUI EnchantBoxUI;

// tf clan
var bool bDisplayClanBattleInfo;
var CClanBattleInfo ClanBattleInfo;
// ------------------------------------------------
// �� ���� �� �ٿ� Ű�� �����ؼ� ���� ���� ���� �ε��� ��ȣ�� ������� �����ؼ� �Ѱ��ִ� �Լ�.
var int QuickSlotIndex;
// ------------------------------------------------
//var bool MainMenuVisible;		//modifid by yj
var MiniShortcut MiniShortcut;

/******
//  ���������� ������ ���콺 �̺�Ʈ�� ���� �ʵ��� �����ϴ� ���
//  �ΰ��Ӽ��� ���� ����. 2010.3.10.Sinhyub
*******/
var bool bInputValidRegionOn;       //������ΰ�
var int InputValidRegion_left;      //�� ������ ����.
var int InputValidRegion_top;
var int InputValidRegion_width;
var int InputValidRegion_height;

var CInterface ITopOnCursor;		// ���콺 ��ġ ���� �ֻ��� �������̽�
//									(��, SephirothInterface�� ����� ���� �� ���ϴ� �ʿ信 ���� CMultiInterface::GetTopInterfaceBelowCursor()�� ȣ���Ͽ� ���) - Xelloss

var RandomBoxDiag RndBoxDlg;		// �����ڽ�	Add ssemp
var SephirothItem OldRndBoxItem;		// �����ڽ� Add ssemp
var int nOldSubInvenIndex;			// �����ڽ� Add ssemp

var CReadyToLobby	ToLobby;		// �κ�� �̵��ϱ� ���� ��� ��� Xelloss

var CPlayerEquip	IPlayerEquip;

var DissolveDiag	DissolveDlg;		// ����â	Add ssemp
var SephirothItem	OldDissolveItem;	// ����â Add ssemp

/*For Test 2009.10.27.Sinhyub*/
/*
	DefaultUIPosition
	Set Position of transportable UI items.
*/
function SetDefaultUIPosition()
{
	if( SimpleHud != None )
		SimpleHud.ResetDefaultPosition();
	if( GaugeHud != None )
		GaugeHud.ResetDefaultPosition();
	if( m_MiniMap != None )
		m_MiniMap.ResetDefaultPosition();
	if( ChannelMgr != None )
		ChannelMgr.ResetDefaultPosition();
	if( MenuList != None )
		MenuList.ResetDefaultPosition();
	if( m_PlayerInfo != None )
		m_PlayerInfo.ResetDefaultPosition();
	if( Party != None )
		Party.ResetDefaultPosition();
	if( Quest != None )
		Quest.ResetDefaultPosition();
	if( WorldMap != None )
		WorldMap.ResetDefaultPosition();
	if( messenger != None )
		Messenger.ResetDefaultPosition();
	if( MainHud != None )
		MainHud.ResetDefaultPosition();
	if( BattleInterface != None )
		BattleInterface.ResetDefaultPosition();
	if( WebBrowser != None )
		WebBrowser.ResetDefaultPosition();
}

function OnInit()
{
	IU = new(None) class'InterfaceUtil';
	SkillInfo = CInfoBox(AddInterface("SephirothUI.CSkillInfoBox"));
	ItemInfo = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	InfoBox = CInfoBox(AddInterface("SephirothUI.SecondSkillInfoBox")); //@by wj(09/08)
	ItemInfo = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	ItemTooltipBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));	// Xelloss
	ItemCompareBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));	// Xelloss

	// keios
	GSkillInfo = CInfoBox(AddInterface("SephirothUI.CSkillInfoBox"));
	GItemInfo = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	GSecondSkillInfo = CInfoBox(AddInterface("SephirothUI.SecondSkillInfoBox"));

	UIType = int(ConsoleCommand("GETOPTIONI UIType"));		//modified by yj
	MsgPool = spawn(class'CTextPool');
	MsgPool.AllowedLines = 5;
	MsgPool.TextAge = 7.0;
	ShowMinimap();
	ShowChannelManager();
	ShowMainInterface();
	ShowGaugeInterface();
	MoveGaugeInterface(0, 4);
	S_CastleEnding = Localize("Information","CastlePostfix","Sephiroth");
	S_ZoneEnding = Localize("Information","ZonePostfix","Sephiroth");
	S_ZoneUnknown = Localize("Information","ZoneUnknown","Sephiroth");
	S_TooClose = Localize("Warnings","TooCloseMagicSkill","Sephiroth");

	Tooltip = Spawn(class'SephirothUI.CTooltip',PlayerOwner);
	Tooltip.Controller = Controller;
	Tooltip.ShowInterface();

	PlayerOwner.ConsoleCommand("CINEMATICS 0");

	GMWord = Localize("Information","GMWord","Sephiroth");
	if ( GMWord == "" )
		GMWord = "(Sound)";

	TempSellerId = -1;

	// keios - EnchantBoxUI�� ����, show
	EnchantBoxUI = EnchantBoxUI(AddInterface("SephirothUI.EnchantBoxUI"));
	EnchantBoxUI.ShowInterface();

	//add neive : ���� ���� ǥ�� ----------------------------------------------
	Buff = BuffIcon(AddInterface("SephirothUI.BuffIcon"));
	Buff.ShowInterface();
	//-------------------------------------------------------------------------

	//add neive : ����Ʈ ���� ǥ�� --------------------------------------------
	m_QuestBrowser = CQuestBrowser(AddInterface("SephirothUI.CQuestBrowser"));
	m_QuestBrowser.ShowInterface();
	//-------------------------------------------------------------------------

	// SubInventory ����
	SubInventories.Insert(0,3);
	SubInventories[0] = None;
	SubInventories[1] = None;
	SubInventories[2] = None;
	//-----------

	nAcountMode = 77; //add neive : ���� ǥ�� ��� (�⺻ : ����)

	nLastItemUseTime = 0; //add neive : ��ų ���ÿ� ���ٰ� �ؼ� ������ ���� ���� üũ�ؼ� ���ƺ�

	nLastScrollUseTime = 0;
	timeMessenger = PlayerOwner.Level.TimeSeconds;
	timePortal = PlayerOwner.Level.TimeSeconds;
	timeQuest = PlayerOwner.Level.TimeSeconds;

//	aReceivedPSI.Empty();
}

function OnFlush()
{
	if ( DialogSession != None ) 
	{
		DialogSession.HideInterface();
		RemoveInterface(DialogSession);
		DialogSession = None;
	}

	if ( Tooltip != None ) 
	{
		Tooltip.HideInterface();
		Tooltip.Destroy();
		Tooltip = None;
	}

	// Xelloss
	if ( ItemTooltipBox != None )	
	{

		ItemTooltipBox.HideInterface();
		ItemTooltipBox.Destroy();
		ItemTooltipBox = None;
	}
	
	if ( ItemCompareBox != None )	
	{

		ItemCompareBox.HideInterface();
		ItemCompareBox.Destroy();
		ItemCompareBox = None;
	}

	// keios
	if( EnchantBoxUI != None )
	{
		EnchantBoxUI.HideInterface();
		EnchantBoxUI.Destroy();
		EnchantBoxUI = None;
	}

	HideGaugeInterface();
	HideMainInterface();
//	Hide2ndSkillInterface();//@by wj(08/26)
	HideMinimap();
//	HideChat();
	HideChannelManager();		// �� ���� ��ü ����. HideInterface��� 	Sinhyub.
	if ( MsgPool != None ) 
	{
		MsgPool.Destroy();
		MsgPool = None;
	}
	HideCastleManagerInterface();	//@by wj(12/11)

	HideRemodelingUI();		//@by wj(040311)

	ItemInfo.HideInterface();
	RemoveInterface(ItemInfo);
	ItemInfo = None;
	SkillInfo.HideInterface();
	RemoveInterface(SkillInfo);
	SkillInfo = None;
	//@by wj(09/08)------
	InfoBox.HideInterface();
	RemoveInterface(InfoBox);
	InfoBox = None;
	//-------------------



	// keios
	GItemInfo.HideInterface();
	GSkillInfo.HideInterface();
	GSecondSkillInfo.HideInterface();
	RemoveInterface(GItemInfo);
	RemoveInterface(GSkillInfo);
	RemoveInterface(GSecondSkillInfo);
	GItemInfo = None;
	GSkillInfo = None;
	GSecondSkillInfo = None;

	SaveConfig();
}

function CloseInterface(out CInterface Interface)
{
	if ( Interface != None ) 
	{
		Interface.HideInterface();
		RemoveInterface(Interface);
		Interface = None;
	}
}

event FullscreenToggled()		//modified by yj		ToggleFullScreen���� �� �ҷ���, UI��ġ�� �ٽ� ��������.
{
	SetDefaultUIPosition();
}

function ShowMainInterface()
{
	local int SkillLevels;
	local int i;

	if ( MainHud == None ) 
	{
		if( UIType == Type1 )
			MainHud = CMainInterface(AddInterface("SephirothUI.CMainInterface"));
		else if(UIType == Type2)
			MainHud = CMainInterface_type2(AddInterface("SephirothUI.CMainInterface_type2"));

		if ( MainHud != None )
			MainHud.ShowInterface();
	}

	if( SephirothPlayer(PlayerOwner).PSI != None )
	{
		for( i = 0 ; i < SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills.Length ; i++ )
			SkillLevels = SkillLevels + SephirothPlayer(PlayerOwner).PSI.SecondSkillBook.Skills[i].SkillLevel;
		if( SkillLevels != 0 || SephirothPlayer(PlayerOwner).PSI.SkillCredit != 0 )
			OnUpdateSkillCredit();
	}
}

function HideMainInterface()
{
	if ( MainHud != None ) 
	{
		MainHud.HideInterface();
		RemoveInterface(MainHud);
		MainHud = None;
	}
}

function bool IgnoreHide()
{
	if ( Exchange != None )			// ��ȯ
		return True;
	if( SellerBooth != None )		// �����Ǹ���
		return True;
	if( GuestBooth != None )		// ����������
		return True;
	if ( StashLobby != None )			// â�� �������
	{
		if ( StashLobby.StashBox != None )
			return True;
		HideStashLobby();
	}

	return False;
}

function SmartHide()
{
	if( Smithy != None )
		HideSmithy();
	if ( Compound != None )
		HideCompound();
	if( PetBag != None )
		HidePetBag();
	if( ClanInterface != None )
		HideClanInterface();
	if( AnimationMenu != None )
		HideAnimationMenu();
	if( Store != None )
		HideStore();
}

//****************************************************************************		//modified by yj
function ShowMenuList()
{
	if( IgnoreHide() )
		return;

	SmartHide();
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( messenger != None ) Hidemessenger();
	if( RemodelingUI != None ) HideRemodelingUI();

	if( MenuList == None )
	{
		MenuList = MenuList(AddInterface("SephirothUI.MenuList"));
		if( MenuList != None )
			MenuList.ShowInterface();
	}
}

function HideMenuList()
{
	if ( MenuList != None )
	{
		MenuList.HideInterface();
		RemoveInterface(MenuList);
		MenuList = None;
	}
}

//****************************************************************************

function RequestIngameShopData()
{	
	//if(GameManager(Level.Game).m_InGameShopCatalogueList.Length == 0)
	//if(GameManager(Level.Game).m_SubscriptionList.Length == 0)

	GameManager(Level.Game).m_SubscriptionList.Length = 0;
	GameManager(Level.Game).m_InGameShopCatalogueList.Length = 0;
	GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length = 0;
	
	SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopList();
	SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopSubscriptionList();
	SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopCash();
}

function ShowIngameShop()
{
	if( bOnInGameShop == False )
		return;

	if( IgnoreHide() )
		return;

	SmartHide();

	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( messenger != None ) Hidemessenger();
	if ( RemodelingUI != None ) HideRemodelingUI();
//	if (m_InventoryBag != None) HideInventoryBag();

	if( m_IngameShop == None )
	{
		RequestIngameShopData();
		
		m_IngameShop = CIngameShop(AddInterface("SephirothUI.CIngameShop"));
		if( m_IngameShop != None )
			m_IngameShop.ShowInterface();
	}
}

function HideIngameShop()
{
	if( m_IngameShop != None )
	{
		m_IngameShop.HideInterface();
		RemoveInterface(m_IngameShop);
		m_IngameShop = None;
	}
}

function ShowIngameShopBox()
{
	if( bOnInGameShop == False )
		return;
		
	if( IgnoreHide() )
		return;

	if( m_IngameShopBox == None )
	{
		RequestIngameShopData();
		
		m_IngameShopBox = CIngameShopBox(AddInterface("SephirothUI.CIngameShopBox"));
		if( m_IngameShopBox != None )
			m_IngameShopBox.ShowInterface();
	}
}

function HideIngameShopBox()
{
	if( m_IngameShopBox != None )
	{
		m_IngameShopBox.HideInterface();
		RemoveInterface(m_IngameShopBox);
		m_IngameShopBox = None;
	}
}

function ShowIngameShopDlg(int nType, int nResult)
{
	if( IgnoreHide() )
		return;

	class'CInGameShopDlg'.Static.OnDlg(Self, nType, nResult);
}

function HideIngameShopDlg()
{
	if( m_IngameShopDlg != None )
	{
		m_IngameShopDlg.HideInterface();
		RemoveInterface(m_IngameShopDlg);
		m_IngameShopDlg = None;
	}
}

function ShowMiniShortcut()
{
	if ( MiniShortcut == None )
	{
		MiniShortcut = MiniShortcut(AddInterface("SephirothUI.MiniShortcut"));
		if ( MiniShortcut != None )
			MiniShortcut.ShowInterface();
	}
}

function MiniShortcutOffset(int offsetX, int offsetY)
{
	if ( MiniShortcut != None )
	{
		MiniShortcut.MoveShortcut(offsetX, offsetY);
	}
}

function HideMiniShortcut()
{
	if ( MiniShortcut != None )
	{
		MiniShortcut.HideInterface();
		RemoveInterface(MiniShortcut);
		MiniShortcut = None;
	}
}

//@by wj(08/18)------
/*function Show2ndSkillInterface()
{
	if(Skill2ndInterface == None)
	{
		Skill2ndInterface = SecondSkillInterface(AddInterface("SephirothUI.SecondSkillInterface"));
		if(Skill2ndInterface != None)
			Skill2ndInterface.ShowInterface();
	}
}*/
/*
function Hide2ndSkillInterface()
{

	if(Skill2ndInterface != None)
	{
		Skill2ndInterface.HideInterface();
		RemoveInterface(Skill2ndInterface);
		Skill2ndInterface = None;
	}
}*/
//-------------------
//@by wj(08/28)------
/*
function SlideSkill2ndInterface()
{
	if(Skill2ndInterface.RenderState == Show){
		Skill2ndInterface.RenderState = SlideRight;
		Skill2ndInterface.SlideStartTime = PlayerOwner.Level.TimeSeconds;
	}
	else if(Skill2ndInterface.RenderState == Hide){
		Skill2ndInterface.RenderState = SlideLeft;
		Skill2ndInterface.SlideStartTime = PlayerOwner.Level.TimeSeconds;
	}
}*/
//-------------------

//@by wj(12/11)------
function ShowCastleManagerInterface()
{
	if( CastleManager == None )
	{
		CastleManager = CCastleManager(AddInterface("SephirothUI.CCastleManager"));
		if( CastleManager != None )
			CastleManager.ShowInterface();
	}
}

function HideCastleManagerInterface()
{
	if( CastleManager != None )
	{
		CastleManager.HideInterface();
		RemoveInterface(CastleManager);
		CastleManager = None;
	}
}
//-------------------

//@by wj(040201)------
function ShowClanInterface()
{
	if( IgnoreHide() )
		return;

	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if ( Smithy != None ) HideSmithy(); //add neive : ����
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Portal != None ) HidePortal();
	if ( Quest != None ) HideQuest();
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( messenger != None )
		Messenger.CloseNotes();

	if( ClanInterface == None )
	{
		ClanInterface = CClanInterface(AddInterface("SephirothUI.CClanInterface"));
		if( ClanInterface != None )
			ClanInterface.ShowInterface();
	}
}

function HideClanInterface()
{
	if( ClanInterface != None )
	{
		ClanInterface.HideInterface();
		RemoveInterface(ClanInterface);
		ClanInterface = None;
	}
}
//--------------------

//@by wj(040311)------
function ShowRemodelingUI()
{
	if( IgnoreHide() )
		return;

	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Portal != None ) HidePortal();
	if ( Quest != None ) HideQuest();
	if ( messenger != None )
		Messenger.CloseNotes();
	if ( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI == None )
	{
		RemodelingUI = ItemRemodeling(AddInterface("SephirothUI.ItemRemodeling"));
		if( RemodelingUI != None )
			RemodelingUI.ShowInterface();
	}
}

function HideRemodelingUI()
{
	if( RemodelingUI != None ) 
	{
		RemodelingUI.HideInterface();
		RemoveInterface(RemodelingUI);
		RemodelingUI = None;
	}
}
//--------------------

//@by wj(040618)------
function ShowPetChat()
{
	if ( PetChat == None ) 
	{
		PetChat = PetDialog(AddInterface("SephirothUI.PetDialog"));
		if( PetChat != None )
			PetChat.ShowInterface();
	}
	//@by wj(040706)------
	else if (PetChat != None)
		PetChat.UpdatePetDialog();
	//--------------------
}

function HidePetChat()
{
	if ( PetChat != None ) 
	{
		PetChat.HideInterface();
		RemoveInterface(PetChat);
		PetChat = None;
	}
}

function ShowPetBag()
{

	//return; //@cs changed for disable pet bag

	if( IgnoreHide() )
		return;

	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if ( Smithy != None ) HideSmithy(); //add neive : 12�� ������ ����
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Portal != None ) HidePortal();
	if ( Quest != None ) HideQuest();
	if ( messenger != None )
		Messenger.CloseNotes();
	if ( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();
	if ( Inbox_Helper != None ) HideInbox_Helper();

	if( PetBag == None ) 
	{
		PetBag = PetBag(AddInterface("SephirothUI.PetBag"));
		if( PetBag != None )
			PetBag.ShowInterface();
	}
}

function HidePetBag()
{
	if ( PetBag != None ) 
	{
		PetBag.HideInterface();
		RemoveInterface(PetBag);
		PetBag = None;
	}
}
//--------------------

function SetHotKeySprite(SephirothPlayer PC, int SlotIndex, int BoxIndex, bool bSet)
{
	if( MainHud != None )
		MainHud.SetHotKeySprite(PC, SlotIndex, BoxIndex, bSet);
}

function ShowSimpleInterface()
{
	if ( SimpleHud == None ) 
	{
		SimpleHud = SimpleInterface(AddInterface("SephirothUI.SimpleInterface"));
		if ( SimpleHud != None )
			SimpleHud.ShowInterface();
	}
}

function HideSimpleInterface()
{
	if ( SimpleHud != None ) 
	{
		SimpleHud.HideInterface();
		RemoveInterface(SimpleHud);
		SimpleHud = None;
	}
}

function ShowGaugeInterface()
{
	if ( GaugeHud == None ) 
	{
		if( UIType == Type1 )
			GaugeHud = CGaugeInterface(AddInterface("SephirothUI.CGaugeInterface_type1"));	//��Ӱ��踦 ���Ӱ� �����Ͽ����ϴ�. 2009.11.10.Sinhyub
		else if(UIType == Type2)
			GaugeHud = CGaugeInterface(AddInterface("SephirothUI.CGaugeInterface_type2"));
		if ( GaugeHud != None )
			GaugeHud.ShowInterface();
	}
}

function HideGaugeInterface()
{
	if ( GaugeHud != None ) 
	{
		GaugeHud.HideInterface();
		RemoveInterface(GaugeHud);
		GaugeHud = None;
	}
}

function MoveGaugeInterface(int offsetX, int offsetY)
{
	if ( GaugeHud != None )
	{
		GaugeHud.MoveGaugeInterface(offsetX, offsetY);
	}
}

function ShowMinimap()
{
	if ( m_MiniMap == None )
	{
		m_MiniMap = CMiniMap(AddInterface("SephirothUI.CMiniMap"));

		if ( m_MiniMap != None )
			m_MiniMap.ShowInterface();
	}
}

function HideMinimap()
{
	if ( m_MiniMap != None ) 
	{
		m_MiniMap.HideInterface();
		RemoveInterface(m_MiniMap);
		m_MiniMap = None;
	}
}

function ShowInbox_Helper()
{
	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if ( Smithy != None ) HideSmithy();
	if ( messenger != None ) HideMessenger();
	if( Inbox_Helper == None ) 
	{
		Inbox_Helper = Inbox_Helper(AddInterface("SephirothUI.Inbox_Helper"));
		if ( Inbox_Helper != None )
			Inbox_Helper.ShowInterface();
	}
}

function ShowLatestHelper()
{
	ShowInbox_Helper();
	Inbox_Helper.OpenLatestHelper();
}


function HideInbox_Helper()
{
	if ( Inbox_Helper != None ) 
	{
		Inbox_Helper.HideInterface();
		RemoveInterface(Inbox_Helper);
		Inbox_Helper = None;
	}
}

function ShowInfo()
{
	if ( messenger != None )
		messenger.CloseNotes();

	if ( DetailInfo != None )
	{
		DetailInfo.HideInterface();
		RemoveInterface(DetailInfo);
		DetailInfo = None;
	}

	if( m_PlayerInfo == None )
	{
		m_PlayerInfo = CPlayerInfo(AddInterface("SephirothUI.CPlayerInfo"));
		if( m_PlayerInfo != None )
			m_PlayerInfo.ShowInterface();
	}
}

function HideInfo()
{
	local int nChangeInfo;

	if ( m_PlayerInfo != None )
	{
		nChangeInfo = m_PlayerInfo.nChangeInfo;
		if( nChangeInfo == 2 )
		{
			ShowDetailInfo();
		}
		m_PlayerInfo.HideInterface();
		RemoveInterface(m_PlayerInfo);
		m_PlayerInfo = None;
	}
}

function ShowDetailInfo()
{
	if ( messenger != None )
		messenger.CloseNotes();

	if ( DetailInfo == None ) 
	{
		DetailInfo = CDetailInfo(AddInterface("SephirothUI.CDetailInfo"));
		if ( DetailInfo != None )
		{
			DetailInfo.SetPosition(m_PlayerInfo.PageX, m_PlayerInfo.PageY);
			DetailInfo.ShowInterface();
		}
	}
}

function HideDetailInfo()
{
	local int nChangeInfo;

	if ( DetailInfo != None )
	{
		nChangeInfo = DetailInfo.nChangeInfo;
		DetailInfo.HideInterface();
		RemoveInterface(DetailInfo);
		DetailInfo = None;

		if( nChangeInfo == 1 )
			ShowInfo();
	}
}

function ShowBattleInfo()
{
	if ( messenger != None )
		messenger.CloseNotes();

	if ( BattleInfo == None ) 
	{
		BattleInfo = CEtcInfo(AddInterface("SephirothUI.CEtcInfo"));
		if ( BattleInfo != None )
		{
			BattleInfo.ShowInterface();
			GameManager(Level.Game).EtcInfoManager.NetNotiOpenEtcInfo();
		}
	}
}

function HideBattleInfo()
{
	if ( BattleInfo != None )	
	{
		BattleInfo.HideInterface();
		RemoveInterface(BattleInfo);
		BattleInfo = None;
	}
}

function ShowInventoryBag()
{
	if ( Exchange != None )
		return;
	if ( StashLobby != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if( DissolveDlg != None )
		return;
	if ( SkillTree != None ) HideSkillTree();
	//if (Party != None) HideParty();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if ( Smithy != None ) return ;
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	/*@by wj(02/21)*/
	if ( messenger != None )
		Messenger.CloseNotes();
	//@by wj(040205)
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None ) HideInbox_Helper();	//modified by yj
//	if(m_InGameShop != None) HideIngameShop();
	if ( m_InventoryBag == None ) 
	{
		//RequestIngameShopData();
		
		m_InventoryBag = InventoryBag(AddInterface("SephirothUI.InventoryBag"));
		if ( m_InventoryBag != None )
			m_InventoryBag.ShowInterface();
	}
}

function HideInventoryBag()
{
	local int i;
	if ( m_InventoryBag != None ) 
	{
		m_InventoryBag.HideInterface();
		RemoveInterface(m_InventoryBag);
		m_InventoryBag = None;
	}
	for( i = 0; i < 3; i++ )
		HideSubInventory(i);
}

// �κ��丮�� ������ ��� True,
// �κ��丮�� �ݾ��� ��� false,
function bool SubInventoryTrigger(int nIndex)
{
	if( SubInventories[nIndex] == None )
	{
		//ShowSubInventory(nIndex);
		SephirothPlayer(PlayerOwner).Net.NotiSubInvenOpen(nIndex);
		return True;
	}
	else
	{
		HideSubInventory(nIndex);
		return False;
	}
}

// �� �Լ��� NotiSubInvenInfoUpdate������ ȣ��ǵ��� �Ѵ�.
// �κ��丮 ���� ��û�� NotiSubInvenOpen(nIndex)�� ���ؼ��� �����ϵ��� �ϰ�,
// �ش� ��û�� ������ ������, �����κ��� ����� �������� �κ��丮�� �����ش�. sinhyub
function ShowSubInventory(int nIndex)
{
	if ( SkillTree != None ) HideSkillTree();
	if ( Compound != None ) HideCompound();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( messenger != None )
		Messenger.CloseNotes();

	if( SubInventories[nIndex] == None )
	{
		SubInventories[nIndex] = CbagResizable(AddInterface("SephirothUI.CBagResizable"));
		if( SubInventories[nIndex] != None )
		{
			SubInventories[nIndex].InitInventory(nIndex);
			SubInventories[nIndex].SetBagSize(13,9);
			SubInventories[nIndex].ShowInterface();
			//SubInventories[nIndex].MoveInventory(200*nIndex,10+30*nIndex);
		}
	}
}

function HideSubInventory(int nIndex)
{
	local CSubInventorySelectBox SelectBox;

	if( m_InventoryBag != None )
		SelectBox = m_InventoryBag.SubSelectBox;
	else if(SellerBooth != None)
		SelectBox = SellerBooth.SubSelectBox;
//	else if(GuestBooth != None)
//		SelectBox = GuestBooth.SubSelectBox;
	else if(StashLobby != None)
		SelectBox = StashLobby.SubSelectBox;
	else if(Exchange != None)
//		SelectBox = Exchange.SubSelectBox;
		return;
		
	if( SubInventories[nIndex] != None )
	{
		SubInventories[nIndex].HideInterface();
		RemoveInterface( SubInventories[nIndex] );
		SubInventories[nIndex] = None;
//		if(SelectBox != None)
//			SelectBox.SetComponentText(SelectBox.Components[nIndex+2],Localize("InventoryUI", "Open", "SephirothUI"));
	}
}


function ShowChannelManager()
{
	if ( ChannelMgr == None ) 
	{
		ChannelMgr = CChannelManager(AddInterface("SephirothUI.CChannelManager"));
		if ( ChannelMgr != None )
			ChannelMgr.ShowInterface();
	}
}

function HideChannelManager()
{
	if ( ChannelMgr != None ) 
	{
		ChannelMgr.HideInterface();
		RemoveInterface(ChannelMgr);
		ChannelMgr = None;
	}
}

// ä��â�� ������ ���߱⸸ �ϴ� ����� ����.
// HideInterface()�� �̿��� ���, �ش� �������̽� ��ü�� �������ѹ����Ƿ�,
// ������ ä�� ������ ����� �����ϴ�.
// �̿� �ٸ���, �ܼ��� ä��â�� ������ �ʵ��� �ϴ� ����� �����մϴ�.
// ���� ������� CInterface�� ����� �߰��ϴ� �͵� ���ڽ��ϴ�.
// Sinhyub.
function MakeInvisibleChannelManager()
{
	if( ChannelMgr != None )
		ChannelMgr.MakeInvisible();
}

function MakeVisibleChannelManager()
{
	if( ChannelMgr != None )
		ChannelMgr.MakeVisible();
}

function ShowMainMenu()
{
	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( MainMenu == None ) 
	{
		MainMenu = CMainMenu(AddInterface("SephirothUI.CMainMenu"));
		if ( MainMenu != None )
			MainMenu.ShowInterface();
	}
}

function HideMainMenu()
{
	if ( MainMenu != None ) 
	{
		MainMenu.HideInterface();
		RemoveInterface(MainMenu);
		MainMenu = None;
	}
}

function ShowOption()
{
//	Option = Hud_Option(AddInterface("SephirothUI.Hud_Option"));
	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( Option == None ) 
	{
		Option = COption(AddInterface("SephirothUI.COption"));
		if ( Option != None )
			Option.ShowInterface();
	}
}

//���ڷ� ���õ� ���� �����Ͽ��ݴϴ�.
function ShowOptionTab(int TabNum)
{
//	Option = Hud_Option(AddInterface("SephirothUI.Hud_Option"));
	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( Option == None ) 
	{
		Option = COption(AddInterface("SephirothUI.COption"));
		if( Option != None )
			Option.ShowInterface();
		Option.OpenPage(TabNum);
	}
}


function HideOption()
{
	if ( Option != None ) 
	{
		Option.HideInterface();
		RemoveInterface(Option);
		Option = None;
	}
}

//cs added plugin window
function ShowPlugin()
{
//	Option = Hud_Option(AddInterface("SephirothUI.Hud_Option"));
	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( Plugin == None ) 
	{
		Plugin = CPlugin(AddInterface("SephirothUI.CPlugin"));
		if( Plugin != None )
			Plugin.ShowInterface();
		Plugin.OpenPage(0);
	}
}


function HidePlugin()
{
	if ( Plugin != None ) 
	{
		Plugin.HideInterface();
		RemoveInterface(Plugin);
		Plugin = None;
	}
}

function ShowSkillTree()
{
	if( IgnoreHide() )
		return;

	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( messenger != None ) Messenger.CloseNotes();
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( SkillTree == None ) 
	{
		SkillTree = CSkillTree(AddInterface("SephirothUI.CSkillTree"));
		if ( SkillTree != None )
			SkillTree.ShowInterface();
	}

	// ���� ��ų �����ڽ� ����
	if( GSecondSkillInfo == None )
		GSecondSkillInfo = CInfoBox(AddInterface("SephirothUI.SecondSkillInfoBox"));
}

//add neive : ���� ��ų -------------------------------------------------------
function ShowHighSkillTree()
{
	if( IgnoreHide() )
		return;

	if ( m_InventoryBag != None ) HideInventoryBag();
	//if (Party != None) HideParty();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	/*@by wj(02/21)*/
	if ( messenger != None )
		Messenger.CloseNotes();
	//@by wj(040205)
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( SkillTree == None )
	{
		SkillTree = CSkillTree(AddInterface("SephirothUI.CSkillTree"));
		if ( SkillTree != None )
		{
			SkillTree.bOnHighLv = True;
			SkillTree.ShowInterface();
		}
	}

	// ���� ��ų �����ڽ� ����
	if( GSecondSkillInfo == None )
		GSecondSkillInfo = CInfoBox(AddInterface("SephirothUI.SecondSkillInfoBox"));
}
//-----------------------------------------------------------------------------

function HideSkillTree()
{
	if ( SkillTree != None ) 
	{
		SkillTree.HideInterface();
		RemoveInterface(SkillTree);
		SkillTree = None;
	}

	//add neive : ���� ��ų���� �����ڽ��� ������� �ʴ� ���� ������� �� -----
	GSecondSkillInfo.HideInterface();
	RemoveInterface(GSecondSkillInfo);
	GSecondSkillInfo = None;
	//-------------------------------------------------------------------------
}

function ShowParty()
{
	if( IgnoreHide() )
		return;

	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if ( Quest != None ) HideQuest();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Portal != None ) HidePortal();
	/*@by wj(02/21)*/
	if ( messenger != None )
		Messenger.CloseNotes();
	//@by wj(040205)
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( SephirothPlayer(PlayerOwner).PSI.bParty )
	{ 
	//���� ���� Sinhyub.
		if( Party == None )
			Party = CParty(AddInterface("SephirothUI.CParty"));
        //if (Party != None)	//�̰͵� �ƴ���... Sinhyub
		Party.ShowInterface();
	}
	else
		PlayerOwner.myHud.AddMessage(2,Localize("Warnings","NeedParty","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
}

function HideParty()
{
	if ( Party != None ) 
	{
		Party.HideInterface();
		RemoveInterface(Party);
		Party = None;
	}
}

function ShowStore()
{
	if ( SkillTree != None ) HIdeSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
    //if (Party != None) HideParty();	//��Ƽâ�� �׳� ��� �����ش�. sinhyub
	if ( Store != None ) HideExchange();
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			return;
		HideStashLobby();
	}
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( messenger != None )
		Messenger.CloseNotes();
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if( DissolveDlg != None ) HideDissolveBox();
	if ( Store == None ) 
	{
		Store = CStore(AddInterface("SephirothUI.CStore"));
		if ( Store != None )
			Store.ShowInterface();
	}
}

function HideStore()
{
	local int i;
	for( i = 0; i < 3; i++ )
		HideSubInventory(i);

	if ( Store != None ) 
	{
		Store.HideInterface();
		RemoveInterface(Store);
		Store = None;
	}
}

function ShowExchange()
{
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	//if (Party != None) HideParty();
	if ( Store != None ) HIdeStore();
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			return;
		HideStashLobby();
	}
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();

	if ( messenger != None )
		Messenger.CloseNotes();

	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( MainMenu != None ) HideMainMenu();
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if( DissolveDlg != None ) HideDissolveBox();
	if ( Exchange == None ) 
	{
		Exchange = CTrade(AddInterface("SephirothUI.CTrade"));
		if ( Exchange != None )
			Exchange.ShowInterface();
	}
}

function HideExchange()
{
	local int i;

	if ( Exchange != None ) 
	{
		Exchange.HideInterface();
		RemoveInterface(Exchange);
		Exchange = None;
	}
	for( i = 0; i < 3; i++ )
		HideSubInventory(i);
}

function OnBoothFee(string FeeString)
{
	if( GuestBooth == None && SellerBooth == None )
		class'CMessageBoxBoothOpen'.Static.MessageBoxBoothOpen(Self,IDM_BoothOpenWithAd, FeeString);
}

function OnBoothOpen()
{
	if( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
	{
		if( SephirothPlayer(PlayerOwner).PSI.IsBoothSeller() )
		{
			SephirothPlayer(PlayerOwner).Net.NotiBoothClose();
			AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
		}
	}
	else
	{
		ShowSellerBooth();
		SephirothPlayer(PlayerOwner).BiasCameraAbs(200);
		SephirothPlayer(PlayerOwner).GotoState('BoothSelling');
	}
}

function OnBoothStateChange()
{
	if( SellerBooth != None )
		SellerBooth.ChangeBoothState();
	else if( GuestBooth != None )
		GuestBooth.ChangeBoothState();
}

function AskBoothVisit(Hero Hero)
{
	if( GuestBooth == None && SellerBooth == None )
	{
		TempSellerId = ClientController(Hero.Controller).PSI.PanID;
		class'CMessageBox'.Static.MessageBox(Self, "BoothVisit", ClientController(Hero.Controller).PSI.PlayName$localize("Modals", "AskBoothVisit", "Sephiroth"), MB_YesNo, IDM_BoothVisit);
	}
}

function OnBoothVisit(PlayerServerInfo Seller)
{
	ShowGuestBooth(Seller);
	SephirothPlayer(PlayerOwner).BiasCameraAbs(200);
	SephirothPlayer(PlayerOwner).GotoState('BoothVisiting');
}

function OnSellerBoothClose()
{
	HideSellerBooth();
	SephirothPlayer(PlayerOwner).BiasCameraAbs(0);
	SephirothPlayer(PlayerOwner).GotoState('Navigating');
}

function OnGuestBoothClose()
{
	HideGuestBooth();
	SephirothPlayer(PlayerOwner).BiasCameraAbs(0);
	SephirothPlayer(PlayerOwner).GotoState('Navigating');
}

function ShowSellerBooth()
{
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
    //if (Party != None) HideParty();//��Ƽâ�� �׳� ��� �����ش�. sinhyub
	if ( Store != None ) HIdeStore();
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			return;
		HideStashLobby();
	}
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( DialogMenu != None ) HideDialog();
	if ( messenger != None )
		Messenger.CloseNotes();
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();
	if( PetBag != None ) HidePetBag();
	if ( MainMenu != None ) HideMainMenu();
	if( DissolveDlg != None ) HideDissolveBox();

	if( SellerBooth == None )
	{
		SellerBooth = CBooth_Seller(AddInterface("SephirothUI.CBooth_Seller"));
		if( SellerBooth != None )
			SellerBooth.ShowInterface();
	}
}

function HideSellerBooth()
{
	local int i;
	if ( ModalInterface != None ) 
	{
		ModalInterface.HideInterface();
		RemoveInterface(ModalInterface);
		ModalInterface = None;
	}

	for( i = 0; i < 3; i++ )
		HideSubInventory(i);

	if( SellerBooth != None )
	{
		SellerBooth.HideInterface();
		RemoveInterface(SellerBooth);
		SellerBooth = None;
	}
}

function ShowGuestBooth(PlayerServerInfo Seller)
{
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
    //if (Party != None) HideParty();		//��Ƽâ�� �׳� ��� �����ش�. sinhyub
	if ( Store != None ) HIdeStore();
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			return;
		HideStashLobby();
	}
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	if ( DialogMenu != None ) HideDialog();
	if ( messenger != None )
		Messenger.CloseNotes();
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();
	if( PetBag != None ) HidePetBag();
	if ( MainMenu != None ) HideMainMenu();
	if( DissolveDlg != None ) HideDissolveBox();

	if( GuestBooth == None )
	{
		GuestBooth = CBooth_Guest(AddInterface("SephirothUI.CBooth_Guest"));
		GuestBooth.SellerInfo = Seller;
		if( GuestBooth != None )
			GuestBooth.ShowInterface();
	}
}

function HideGuestBooth()
{
	local int i;
	if ( ModalInterface != None ) 
	{
		ModalInterface.HideInterface();
		RemoveInterface(ModalInterface);
		ModalInterface = None;
	}
	
	for( i = 0; i < 3; i++ )
		HideSubInventory(i);

	if( GuestBooth != None )
	{
		GuestBooth.HideInterface();
		RemoveInterface(GuestBooth);
		GuestBooth = None;
	}
}

function ShowStashLobby()
{
	//// ������ ��� ��û��
	//class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
	//	return;

	if ( Exchange != None )
		return;
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();
	//if (Party != None) HideParty();		//��Ƽâ�� �׳� ��� �����ش�. sinhyub
	if ( Store != None ) HideStore();
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();
	/*@by wj(02/21)*/
	if ( messenger != None )
		Messenger.CloseNotes();
	//@by wj(040205)
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if( DissolveDlg != None ) HideDissolveBox();
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( StashLobby == None ) 
	{
		StashLobby = CStashLobby(AddInterface("SephirothUI.CStashLobby"));
		if ( StashLobby != None )
			StashLobby.ShowInterface();
	}
}

function HideStashLobby()
{
	local int i;

	for( i = 0; i < 3; i++ )
		HideSubInventory(i);

	if ( StashLobby != None ) 
	{
		StashLobby.HideInterface();
		RemoveInterface(StashLobby);
		StashLobby = None;
	}
}

//********  Pet system UI 03.9.29 by BK
function ShowPetInterface()
{
	if( m_PetInfo == None )
	{
		if( bPetSummon )
		{
			m_PetInfo = CPetInfo(AddInterface("SephirothUI.CPetInfo"));
			if( m_PetInfo != None )
				m_PetInfo.ShowInterface();
		}
	}
}

function HidePetInterface()
{
	if( m_PetInfo != None )
	{
		if( PetChat != None )
			HidePetChat();
		m_PetInfo.HideInterface();
		RemoveInterface(m_PetInfo);
		m_PetInfo = None;
	}
}

function ShowPetFace()
{
	if( m_PetMain == None /*&& bShowPetFace*/ )
		m_PetMain = CPetMain(AddInterface("SephirothUI.CPetMain"));
	if( m_PetMain != None )
		m_PetMain.ShowInterface();
}

function HidePetFace()
{
	if( m_PetMain != None )
	{
		if( PetBag != None )
			HidePetBag();
//		m_PetMain.HideInterface();
		RemoveInterface(m_PetMain);
		m_PetMain = None;
	}
}

function LoadPetfaceTexture()
{
	if( m_PetMain != None )
		m_PetMain.LoadPetfaceTexture();
	if( m_PetInfo != None )
		m_PetInfo.LoadPetfaceTexture();
}

//************************************


function ShowDialog()
{
	/*!@jhjung,2004.2.6 check StashLobby before opening NPC dialog #bug536*/
	if ( StashLobby != None )
		return;
	/**/

	if (Exchange != None)
		return;

	if( DissolveDlg != None ) HideDissolveBox();

	if (DialogMenu == None) {
		DialogMenu = CDialog(AddInterface("SephirothUI.CDialog"));
		if (DialogMenu != None)
			DialogMenu.ShowInterface();
	}
}

function HideDialog()
{
	if (DialogMenu != None) {
		DialogMenu.HideInterface();
		RemoveInterface(DialogMenu);
		DialogMenu = None;
	}
}

function HideXMenu()
{
	if (XMenu != None) {
		XMenu.HideInterface();
		RemoveInterface(XMenu);
		XMenu = None;
	}
}

function ShowAnimationMenu()
{
	if(MenuList !=None) HideMenuList();
	if (AnimationMenu == None) {
		AnimationMenu = CAnimationMenu(AddInterface("SephirothUI.CAnimationMenu"));
		if (AnimationMenu != None)
			AnimationMenu.ShowInterface();
	}
}

function HideAnimationMenu()
{
	if (AnimationMenu != None) {
		AnimationMenu.HideInterface();
		RemoveInterface(AnimationMenu);
		AnimationMenu = None;
	}
}

function ShowDeadMenu()
{
	if (DeadMenu == None) {
		DeadMenu = CDeadMenu(AddInterface("SephirothUI.CDeadMenu",true));
		if (DeadMenu != None) {
			//Log("Vanished? " $ bVanished);
			DeadMenu.bVanished = bVanished;
			DeadMenu.ShowInterface();
			bVanished = false;
		}
	}
}

function HideDeadMenu()
{
	if (DeadMenu != None) {
		DeadMenu.HideInterface();
		RemoveInterface(DeadMenu);
		DeadMenu = None;
	}
}

function ShowHelp()
{
	if (Help == None) {
		Help = CHelp(AddInterface("SephirothUI.CHelp"));
		if (Help != None)
			Help.ShowInterface();
	}
}

function HideHelp()
{
	if (Help != None) {
		Help.HideInterface();
		RemoveInterface(Help);
		Help = None;
	}
}

function ShowCompound()
{
	if(IgnoreHide())
		return;

	if (SkillTree != None) HideSkillTree();
	if (m_InventoryBag != None) HideInventoryBag();
	if (Store != None) HideStore();
	if (Quest != None) HideQuest();
	if (Portal != None) HidePortal();
	if (messenger != None)
		Messenger.CloseNotes();
	if(ClanInterface != None) HideClanInterface();
	if(RemodelingUI != None) HideRemodelingUI();	//@by wj(040311)
	if(PetBag != None) HidePetBag();	//@by wj(040621)
	if(Smithy != None) HideSmithy();
	if (WorldMap != None) HideWorldMap(); //add neive : �����
	if (Inbox_Helper != None) HideInbox_Helper();
	if (Compound == None) {
		Compound = CCompound(AddInterface("SephirothUI.CCompound"));
		if (Compound != None)
			Compound.ShowInterface();
	}
}

function HideCompound()
{
	if (Compound != None) {
		Compound.HideInterface();
		RemoveInterface(Compound);
		Compound = None;
	}
}

function ShowSmithy()
{
	if(IgnoreHide())
		return;

	if (SkillTree != None) HideSkillTree();
	if (m_InventoryBag != None) HideInventoryBag();
	if (Store != None) HideStore();
	if (Quest != None) HideQuest();
	if (Portal != None) HidePortal();
	/*@by wj(02/21)*/
	if ( messenger != None )
		Messenger.CloseNotes();
	//@by wj(040205)
	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if( Smithy == None )
	{
		Smithy = Smithy(AddInterface("SephirothUI.Smithy"));
		if( Smithy != None )
			Smithy.ShowInterface();
	}
}

function HideSmithy() //add neive : ����
{
	if( Smithy != None )
	{
		Smithy.HideInterface();
		RemoveInterface(Smithy);
		Smithy = None;
	}
}

//*******************************************
// �������� �������̽� ���� 2010.2.18.Sinhyub
// �������� �������̽� ���̱�.
// ���������� ���ŵǾ��ִٸ� �����ؼ� ������.
function ShowWebBrowser(int Otp, int ServerID)
{
    //â��, �ŷ�â, ������ �����ʽ��ϴ�.
	HideAllInterfaces();
	if( MainHud != None )
		HideMainInterface();
	if( GaugeHud != None )
		HideGaugeInterface();

	if( WebBrowser == None )
	{
		WebBrowser = CWebBrowser(AddInterface("SephirothUI.CWebBrowser"));
		if( WebBrowser != None )
		{
			WebBrowser.SetOTP(Otp, ServerID);
			WebBrowser.ShowInterface();
		}
	}
	SetInputValidRegion(WebBrowser.Components[0].X,WebBrowser.Components[0].Y,WebBrowser.Components[0].XL,WebBrowser.Components[0].YL);
}
// �������� �������̽� ���߱�. (��ü�� ������ ��������)
function HideWebBrowser()
{
    // UIâ�� �ݰ� �Ҹ��Ű����, ��������(InternetExplorer) �ǰ�ü�� �Ҹ���� �ʰ� �����ֽ��ϴ�.
	if( WebBrowser != None )
	{
		WebBrowser.HideInterface();
		RemoveInterface(WebBrowser);
		WebBrowser = None;
	}

    //�⺻���� �������̽��� �ٽ� �׷���
	if( MainHud == None )
		ShowMainInterface();
	if( GaugeHud == None )
	{
		ShowGaugeInterface();
		MoveGaugeInterface(0, 4);
	}
	if( ChannelMgr == None )
	{
		ShowChannelManager();
	}

	ClearInputValidRegion();
}

function bool IsWebBrowserOn()
{
	return (WebBrowser != None);
}

function NotifyNewGrantItem(int nNewGrantItem)
{
	if( WebBrowser != None )
		WebBrowser.NotifyNewGrantItem(nNewGrantItem);
}

// �ش� ������ ���������� Ű����/���콺 �Է� ����. (�ΰ��� �� UI������ ����)
// UI��ҵ��� ��� Components(0)�� �⺻ ���������� ����ϹǷ� �� ũ�⸦ �̿��Ѵ�.
function bool SetInputValidRegion(int left, int top, int width, int height)
{
//  if(bInputValidRegionOn)
//      return false;   //�̹� �ٸ��༮�� Masking�ϰ������� �������.
	InputValidRegion_left = left;
	InputValidRegion_top = top;
	InputValidRegion_width = width;
	InputValidRegion_height = height;
	bInputValidRegionOn = True;
	return True;    //�۾� ����. Masking����.
}
// ����.
function bool ClearInputValidRegion()
{
	bInputValidRegionOn = False;
	return True;
}

// �������� �������̽� ����.
// ��, ���������� �׻� �ϳ��� ���簡��.
// �⺻������ Ŭ���̾�Ʈ ������ ������ �Բ� �����Ǿ�����. (��ü ����)
//function AddWebBrowser(){}
// �������� �������̽� ����. (��ü �Ҹ�)
//function RemoveWebBrowser(){}
// �������� �������̽� ����.  End.
//**********************************************


function ShowWorldMap()
{
	if( IgnoreHide() )
		return;

	if ( SkillTree != None )
		HideSkillTree();
	if ( m_InventoryBag != None )
		HideInventoryBag();
	if ( Party != None )
		HideParty();
	if ( Store != None )
		HideStore();
	if ( Quest != None )
		HideQuest();
	if ( Portal != None )
		HidePortal();
	if ( messenger != None )
		Messenger.CloseNotes();
	if( ClanInterface != None )
		HideClanInterface();
	if( RemodelingUI != None )
		HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None )
		HidePetBag();	//@by wj(040621)
	if( Smithy != None )
		HideSmithy();
	if ( Inbox_Helper != None ) HideInbox_Helper();

	if( WorldMap == None )
	{
		WorldMap = CWorldMap(AddInterface("SephirothUI.CWorldMap"));
		if( WorldMap != None )
		{
			if( WorldMap.IsCheckWorldMapUseArea() )
			{
				WorldMap.InitWorldData();
				WorldMap.ShowInterface();
			}
			else
				AddMessage(1, Localize("Information","CannotUseRadarUnderSiege","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
		}
	}
}

function HideWorldMap()
{
	if( WorldMap != None )
	{
		WorldMap.HideInterface();
		RemoveInterface(WorldMap);
		WorldMap = None;
	}
}


function ShowQuest()	
{

	// ����Ʈ UI�� ���µ� ��Ÿ���� �д�.
	if ( PlayerOwner.Level.TimeSeconds - timeQuest < 0.5 )
		return;

	if( IgnoreHide() )
		return;

	if ( SkillTree != None )		HideSkillTree();
	if ( m_InventoryBag != None )	HideInventoryBag();
	if ( Store != None )			HideStore();

	if ( Compound != None )	HideCompound();
	if ( Smithy != None )		HideSmithy();
	if ( WorldMap != None )	HideWorldMap(); //add neive : �����
	if ( Portal != None )		HidePortal();

	if ( messenger != None )		Messenger.CloseNotes();	/*@by wj(02/21)*/

	if ( ClanInterface != None )	HideClanInterface();	//@by wj(040205)
	if ( RemodelingUI != None )	HideRemodelingUI();		//@by wj(040311)
	if ( PetBag != None )			HidePetBag();			//@by wj(040621)

	if ( Quest == None )	
	{

		Quest = CQuest(AddInterface("SephirothUI.CQuest"));

		if ( Quest != None )	
		{

			SephirothPlayer(PlayerOwner).Net.NotiQuestInfo();   //��ȡ����״̬
			timeQuest = PlayerOwner.Level.TimeSeconds;
			Quest.ShowInterface();
		}
	}
}


function HideQuest()
{
	if ( Quest != None ) 
	{
		Quest.HideInterface();
		RemoveInterface(Quest);
		Quest = None;
	}
}


function ShowMentorInterface()
{
	if ( IMentorInterface == None )	
	{

		IMentorInterface = CMentorInterface(AddInterface("SephirothUI.CMentorInterface"));

		if ( IMentorInterface != None )
			IMentorInterface.ShowInterface();
	}
}


function HideMentorInterface()
{
	if ( IMentorInterface != None )
	{
		IMentorInterface.HideInterface();
		RemoveInterface(IMentorInterface);
		IMentorInterface = None;
	}
}


function ShowPortal()	
{

	// �̵���ġ UI���µ� ��Ÿ���� �ش�.
	if ( PlayerOwner.Level.TimeSeconds - timePortal < 0.5 )
		return;

	if( IgnoreHide() )
		return;

	if ( SkillTree != None )			HideSkillTree();
	if ( m_InventoryBag != None )		HideInventoryBag();
	if ( Store != None )				HideStore();
	if ( Compound != None )			HideCompound();
	if( Smithy != None )				HideSmithy();
	if ( WorldMap != None )			HideWorldMap(); //add neive : �����
	if ( Quest != None )				HideQuest();
	
	if ( messenger != None )			//@by wj(02/21)
		Messenger.CloseNotes();

	
	if ( ClanInterface != None )		HideClanInterface();	//@by wj(040205)
	if ( RemodelingUI != None )		HideRemodelingUI();	//@by wj(040311)
	if ( PetBag != None )				HidePetBag();	//@by wj(040621)
	if ( Inbox_Helper != None )		HideInbox_Helper();

	if ( Portal == None )	
	{

		Portal = CPortal(AddInterface("SephirothUI.CPortal"));

		if ( Portal != None )	
		{

			SephirothPlayer(PlayerOwner).Net.NotiPortalInfo(0);
			timePortal = PlayerOwner.Level.TimeSeconds;
			Portal.ShowInterface();
		}
	}
}

function HidePortal()
{
	if ( Portal != None ) 
	{
		Portal.HideInterface();
		RemoveInterface(Portal);
		Portal = None;
	}
}

/*@by wj(02/21)*/
function bool ShowMessenger()	
{

	// UI�� �����ϴµ� ��Ÿ���� �ش�.
	if ( PlayerOwner.Level.TimeSeconds - timeMessenger < 0.5 )
		return False;

	if( IgnoreHide() )
		return False;

	if ( Inbox_Helper != None )	HideInbox_Helper();
	if ( SkillTree != None )		HideSkillTree();
	if ( m_InventoryBag != None )	HideInventoryBag();
	if ( Store != None )			HideStore();
	if ( Compound != None )		HideCompound();
	if ( Smithy != None )			HideSmithy();

	if ( messenger == None )	
	{

		messenger = messenger(AddInterface("SephirothUI.messenger"));

		if ( messenger != None )	
		{

			SephirothPlayer(PlayerOwner).Net.NotiBuddyInfo();
			messenger.ShowInterface();
			timeMessenger = PlayerOwner.Level.TimeSeconds;
			return True;
		}
	}

	return False;
}


exec function SuperSendNote(string name)
{
	messenger.OpenSendNoteInterface(name, False);
}

function HideMessenger()
{
	if( messenger != None )
	{
		messenger.HideInterface();
		RemoveInterface(messenger);
		messenger = None;
	}
}

function ChangeUIType(int Type)		//modified by yj
{
	if( UIType == Type )
		return;

	UIType = Type;

	HideMainInterface();
	HideGaugeInterface();

	ShowMainInterface();
	ShowGaugeInterface();
}

function ChangeMinimapType(bool bPin)
{
	m_MiniMap.ChangeMiniMapDisplayMode();		//2009.10.26.Sinhyub
	HideMinimap();
	ShowMinimap();
}

//*******************************************
// �����ڽ� �������̽� ���� 2011.4.19.ssemp
// �����ڽ� �������̽� ���̱�.
// �����ڽ��� ���ŵǾ��ִٸ� �����ؼ� ������.
function ShowRandomBox( SephirothItem ISI, optional int nSubIndex )
{
    //â��, �ŷ�â, ������ �����ʽ��ϴ�.
    //HideAllInterfaces();
    //if(MainHud!=none)
    //    HideMainInterface();
    //if(GaugeHud!=none)
    //    HideGaugeInterface();

	if( RndBoxDlg == None )
	{
		RndBoxDlg = RandomBoxDiag(AddInterface("SephirothUI.RandomBoxDiag"));
		if( RndBoxDlg != None )
		{
			RndBoxDlg.SetRndItem( ISI, nSubIndex);
			RndBoxDlg.ShowInterface();
		}
	}
}
// �������� �������̽� ���߱�. (��ü�� ������ ��������)
function HideRandomBox()
{
    // UIâ�� �ݰ� �Ҹ��Ű����, ��������(InternetExplorer) �ǰ�ü�� �Ҹ���� �ʰ� �����ֽ��ϴ�.
	if( RndBoxDlg != None )
	{
		RndBoxDlg.HideInterface();
		RemoveInterface(RndBoxDlg);
		RndBoxDlg = None;
		OldRndBoxItem = RndBoxDlg.RndUseItem;
		nOldSubInvenIndex = RndBoxDlg.nSubInvenIndex;
	}

    ////�⺻���� �������̽��� �ٽ� �׷���
    //if(MainHud == none)
    //    ShowMainInterface();
    //if(GaugeHud == none)
    //{
    //    ShowGaugeInterface();
    //    MoveGaugeInterface(0, 4);
    //}
    //if(ChannelMgr == none)
    //{
    //    ShowChannelManager();
    //}
}

function bool IsRandomBoxOn()
{
	return (RndBoxDlg != None);
}

function ResultRandombox( string strTypeName, string strModelName, string LocalizedDescription )
{
	if( IsRandomBoxOn() )
		RndBoxDlg.ResultRandombox( strTypeName, strModelName, LocalizedDescription );
	else
	{
		//class'CMessageBox'.static.MessageBox(Self,"ApplyResist",Localize("Modals","InputPetChat","Sephiroth")$strTypeName,MB_Ok);
		//log("ResultRandombox ININ"@RndBoxDlg@OldRndBoxItem);
		if( RndBoxDlg == None )
		{
			RndBoxDlg = RandomBoxDiag(AddInterface("SephirothUI.RandomBoxDiag"));
			//Log(" ResultRandombox ININ 2"@RndBoxDlg@OldRndBoxItem);
			if( RndBoxDlg != None )
			{
				//RndBoxDlg.SetRndItem(OldRndBoxItem);
				RndBoxDlg.SetRndItem( OldRndBoxItem, nOldSubInvenIndex );
				RndBoxDlg.ShowInterface();
				RndBoxDlg.ResultRandombox( strTypeName, strModelName, LocalizedDescription );
			}
		}
	}
}

//*******************************************
// ���� �������̽� ���� 2012.4.02.ssemp
// ���� �������̽� ���̱�.
// ���� �ڽ��� ���ŵǾ��ִٸ� �����ؼ� ������.
function ShowDissolveBox( string category )
{
	if( SellerBooth != None )
		return;
	if( GuestBooth != None )
		return;
	if ( SkillTree != None ) HideSkillTree();
	if ( m_InventoryBag != None ) HideInventoryBag();

	if ( Store != None ) HIdeStore();
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			return;
		HideStashLobby();
	}
	if ( Compound != None ) HideCompound();
	if( Smithy != None ) HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	if ( Quest != None ) HideQuest();
	if ( Portal != None ) HidePortal();

	if ( messenger != None )
		Messenger.CloseNotes();

	if( ClanInterface != None ) HideClanInterface();
	if( RemodelingUI != None ) HideRemodelingUI();	//@by wj(040311)
	if( PetBag != None ) HidePetBag();	//@by wj(040621)
	if ( MainMenu != None ) HideMainMenu();
	if ( Inbox_Helper != None ) HideInbox_Helper();
	if ( Exchange != None ) HideExchange();

    //â��, �ŷ�â, ������ �����ʽ��ϴ�.
	if( DissolveDlg == None )
	{
		DissolveDlg = DissolveDiag(AddInterface("SephirothUI.DissolveDiag"));
		if( DissolveDlg != None )
		{
			DissolveDlg.SetCategory( category );
			DissolveDlg.ShowInterface();
		}
	}
}

function HideDissolveBox()
{
	if( DissolveDlg != None )
	{
		DissolveDlg.HideInterface();
		RemoveInterface(DissolveDlg);
		DissolveDlg = None;
//		OldDissolveItem = DissolveDlg.RndUseItem;
//		nOldSubInvenIndex = DissolveDlg.nSubInvenIndex;
	}
}

function bool IsDissolveBoxOn()
{
	return (DissolveDlg != None);
}

function ResultDissolve( int nErrCode, array<string> strItem, array<string> strModel, array<int> nItemCount )
{
	if ( m_InventoryBag != None )
		HideInventoryBag();

	if( IsDissolveBoxOn() )
		DissolveDlg.ResultDissolve( nErrCode, strItem, strModel, nItemCount );
	else
	{
		if( DissolveDlg == None )
		{
			DissolveDlg = DissolveDiag(AddInterface("SephirothUI.DissolveDiag"));
			if( DissolveDlg != None )
			{
				DissolveDlg.ShowInterface();
				DissolveDlg.ResultDissolve( nErrCode, strItem, strModel, nItemCount );
			}
		}
	}
}
//��� �������̽� â�� �ݾ��ݴϴ�.
//���� �����ؼ�, �� UI Show* �Լ��� �̿��� ��ȹ.
function HideAllInterfaces()
{
	HideMainInterface();
	HideChannelManager();
	HideSimpleInterface();
	HideGaugeInterface();
	HideMinimap();
	HideMainMenu();
	HideChannelManager();
	HideMenuList();
	HideIngameShop();
	HideInbox_Helper();
	HideInfo();
	HideDetailInfo();
	HideOption();
	HideInventoryBag();
	HideSkillTree();
//  HideParty();
//  HideTrade();    //�̰� ���߸�ȵɳ���
	HideStore();
//  HideStashLobby();   //�̰͵� �����Ѱǵ�
	HideDialog();
	HideXMenu();        //�̰� ��
	HideAnimationMenu();
//  HideDeadMenu();
	HideHelp();
	HideCompound();     //�̰� ��
	HideSmithy();       //��
	HideQuest();
	HidePortal();
//  HideBooth_Seller();
//  HideBooth_Guest();
//  HideWebBrowser();   ���������� �ܺ�Ŭ���̾�Ʈ �����̹Ƿ� �ֻ�����.  ����ȴ�.
//  HideGame_Login();   //�̰� ��
	HideWorldMap();
	HideMessenger();
//  HideScreenEffect(); �̰ǹ�?
	HidePetBag();
    //�Ʒ� �ΰ� �߰�
	RemoveBattleInterface();
	HideBattleInfo();
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)	
{

	local string Resolution;

	if ( bInputValidRegionOn )	
	{
		//WebBrowser!=none)

		// �ΰ��Ӽ��� ���ִٸ� Ű�����̺�Ʈ ESC�� ���.
		if ( !((  ((Key == IK_Escape) || (Key == IK_LeftMouse) || (key == IK_RightMouse))
			&& ((Action == IST_Press) || (Action == IST_Release) || (Action == IST_Hold)) )) )
		{
			//IK_�����������ͺ��� IK_�� ���� ū������ ���̿��ְ�, IK_ESCAPE�� ������ �������� �����ؾ��Ѵ�.
			return True;
		}
	}

	if ( bShowStat && IsCursorInsideCircleAt(StatX,StatY,32,32) )	
	{

		/*!@ 2004.1.28, jhjung ��������Ʈ ���� ����*/
		if ( Key == IK_LeftMouse && Action == IST_Release )	
		{
			if ( ClickTime > 0 && Level.TimeSeconds - ClickTime < 0.25 )
				ShowInfo();
			else
				ClickTime = Level.TimeSeconds;
			return True;
		}
	}


	/* ���θ޴���ư�� ��������ϴ�. 2009.11.10. Sinhyub
	//add neive : ���θ޴���ư Ŭ�� -------------------------------------------
	if (IsCursorInsideCircleAt(nMainBtnX, nMainBtnY,32,32))
	{
		if (Key == IK_LeftMouse && Action == IST_Release)
		{
			if (MainMenu != None && !MainMenu.bDeleteMe)
				HideMainMenu();
			else
				ShowMainMenu();

			return true;
		}
	}
	*/

	if ( !PlayerOwner.Player.Console.bTyping && !Controller.bProcessingKeyType )
	{
		if ( Controller.bCtrlPressed && (Key >= IK_0 && Key <= IK_5 || Key == IK_Tilde) /* && !SephirothPlayer(PlayerOwner).TargetLocked()) */ ||
			((Key == IK_Enter || Key == IK_Slash) && Action == IST_Press) )
		{
			/*
			if (Chat == None)
			{
				ShowChat();
				if (Chat != None)
					Chat.GotoState('Typing');
				return false;
			}
			*/
			if ( ChannelMgr == None )
			{
				ShowChannelManager();
				if ( ChannelMgr != None && !bBlockPapering )
					ChannelMgr.GotoState('MessageEditing');
				return False;
			}
		}
		else if (!Controller.bCtrlPressed && Action == IST_Release)		// && Key >= IK_0 && Key <= IK_9)/* && (!Controller.bCtrlPressed || (SephirothPlayer(PlayerOwner).TargetLocked() && SephirothPlayer(PlayerOwner).bIsTargetLocked))) { */
		{
			switch(Key)
			{
				case IK_1:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows);
					break;
				case IK_2:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 1);
					break;
				case IK_3:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 2);
					break;
				case IK_4:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 3);
					break;
				case IK_5:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 4);
					break;
				case IK_6:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 5);
					break;
				case IK_7:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 6);
					break;
				case IK_8:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 7);
					break;
				case IK_9:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 8);
					break;
				case IK_0:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 9);
					break;
				case IK_Minus:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 10);
					break;
				case IK_Equals:
					OnApplyHotkey(QuickSlotIndex * class 'QuickKeyConst'.Default.QuickSlotRows + 11);
					break;
				case IK_F1:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows );
					break;
				case IK_F2:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 1);
					break;
				case IK_F3:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 2);
					break;
				case IK_F4:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 3);
					break;
				case IK_F5:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 4);
					break;
				case IK_F6:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 5);
					break;
				case IK_F7:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 6);
					break;
				case IK_F8:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 7);
					break;
				case IK_F9:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 8);
					break;
				case IK_F10:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 9);
					break;
				case IK_F11:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 10);
					break;
				case IK_F12:
					OnApplyHotkey(2 * class 'QuickKeyConst'.Default.QuickSlotRows + 11);
					break;
			}
		}
	}

	if ( Key == IK_PrintScrn && Action == IST_Release ) 
	{		
		//modified by yj		//�ٺ����� �ذ����� �ƴ�. �� �� ����
		PlayerOwner.ConsoleCommand("shot");
		return True;
	}
	
	// �̺�Ʈ ���� ���� Xelloss
	if ( Action == IST_Press )	
	{
		switch ( Key )	
		{

		// ���� ����Ű H
			case IK_H :
		
				if ( Help != None )
					HideHelp();
				else
					ShowHelp();

				return True;
				break;

		// �������� ����Ű Y
			case IK_Y :

				if ( BattleInfo != None )
					HideBattleInfo();
				else
					ShowBattleInfo();

				return True;
				break;

		// ����Ű���� semicolon -> scrolllock
			case IK_ScrollLock :

				Resolution = ConsoleCommand("GETOPTIONS Resolution"); // add neive : ���̵� ����߿��� ���� �������̽� ����

				if ( Resolution != "800x600" && Resolution != "1024x768" && Resolution != "1280x1024" )
					return True;

				if ( MainHud != None && GaugeHud != None )	
				{

					HideMainInterface();
					ShowMiniShortcut();
					MoveGaugeInterface(0, 0);
					MiniShortcutOffset(90, 0);
				}
				else if (MainHud == None && GaugeHud != None)	
				{

					HideMiniShortcut();
					HideGaugeInterface();
					ShowSimpleInterface();
					ShowMiniShortcut();
				}
				else if (SimpleHud != None)	
				{

					HideMiniShortcut();
					HideSimpleInterface();
				}
				else	
				{

					HideMiniShortcut();
					ShowMainInterface();
					ShowGaugeInterface();
					MoveGaugeInterface(0, 4);
				}

				ChannelMgr.SetChannelPosReflesh();
				break;

		// ����� / �̴ϸ� ���� ����Ű M
			case IK_M :

				if ( Controller.bCtrlPressed )	
				{

					if ( m_MiniMap != None )
						HideMinimap();
					else	
					{

						if ( SephirothPlayer(PlayerOwner).ZSI.bUnderSiege || SephirothPlayer(PlayerOwner).ZSI.bNoMinimap )	
						{

							AddMessage(1, Localize("Information", "CannotUseRadarUnderSiege", "Sephiroth"), class'Canvas'.Static.MakeColor(255, 255, 0));
							return True;
						}

						ShowMinimap();
					}
				}
				else	
				{

					if ( WorldMap != None )
						HideWorldMap();
					else	
					{

						if ( SephirothPlayer(PlayerOwner).ZSI.bUnderSiege || SephirothPlayer(PlayerOwner).ZSI.bNoMinimap )
							AddMessage(1, Localize("Information","CannotUseRadarUnderSiege","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
						else
							ShowWorldMap();
					}
				}

				return True;
				break;

			case IK_Delete :

				GameManager(Level.Game).playerowner.ToggleView();
				break;

		// ���� ����â ����Ű O
		// ���� ���� ����ŰCtrl + O
			case IK_O :

				if ( Controller.bCtrlPressed )
				{
					if ( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
						AddMessage(1, Localize("Booth", "NoBoothOpenZone", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
					else
						SephirothPlayer(PlayerOwner).Net.NotiBoothFee();
				}
				else
				{
					if ( IMentorInterface != None )
						HideMentorInterface();
					else
						ShowMentorInterface();
				}

				return True;
				break;

		// �˸��� ����Ű U
			case IK_U :

				if ( Inbox_Helper != None )
					HideInbox_Helper();
				else
					ShowInbox_Helper();

				return True;
				break;

			case IK_J :

				if ( MenuList != None )
					HideMenuList();
				else
					ShowMenuList();

				return True;
				break;

		// ä��â ���̱�/���߱� ����Ű C
			case IK_C :
			//@cs added for disable auto pickup hot key
				if( Controller.bCtrlPressed )
				{
					return False;
				}
				if ( ChannelMgr.IsInvisible() )
					MakeVisibleChannelManager();	// ������ �༮�� ���̵����Ѵ�.
				else
					MakeInvisibleChannelManager();	// �ܼ��� ���ߵ��� �Ѵ�.

				return True;
				break;

		// �÷��̾� ����â ����Ű I
			case IK_I :

				if ( m_PlayerInfo != None )
					m_PlayerInfo.CloseInfo();
				else
					ShowInfo();

				return True;
				break;

		// ���â ����Ű TAB
			case IK_Tab :

				if ( m_InventoryBag != None )
					HideInventoryBag();
				else
					ShowInventoryBag();

				return True;
				break;

		// �⺻��ųâ ����Ű K
			case IK_K :

				if ( SkillTree != None )
					HideSkillTree();
				else
					ShowSkillTree();

				return True;
				break;

		// ��Ƽâ ����Ű P
			case IK_P :
				if ( Party != None )
					HideParty();
				else
					ShowParty();

				return True;
				break;

		// ����Ʈâ ����Ű T
			case IK_T :

				if ( Quest != None )
					HideQuest();
				else
					ShowQuest();

				return True;
				break;

		// ��ġ���â ����Ű R
			case IK_R :

				if ( Portal != None )
					HidePortal();
				else
					ShowPortal();

				return True;
				break;

		// ģ�����â ����Ű B
			case IK_B :

				if ( messenger != None )
					HideMessenger();
				else
					ShowMessenger();

				return True;
				break;

		// ���޽�ųâ ����Ű L
			case IK_L :

				if ( SkillTree != None ) //add neive : ���� ������ ����
					HideSkillTree();
				else
					ShowHighSkillTree();

				break;

			case IK_G :

				if ( SephirothPlayer(PlayerOwner).SPet == None || SephirothPlayer(PlayerOwner).PetSI.PetLevel < 16 )
					return True;
				if ( PetBag != None )
					HidePetBag();
				else
					ShowPetBag();

				return True;
				break;

			case IK_F :

				if ( m_PetInfo != None )
					HidePetInterface();
				else //if (bPetSummon)
					ShowPetInterface();

				return True;
				break;

			case IK_N :

				if ( ClanInterface == None )	
				{

					if ( SephirothPlayer(PlayerOwner).PSI.ClanName != "" )
						SephirothPlayer(PlayerOwner).Net.NotiClanMemberInfo();
					else
						SephirothPlayer(PlayerOwner).Net.NotiClanApplying();
				}
				else
					HideClanInterface();

				return True;
				break;

			case IK_Insert :

				SephirothPlayer(PlayerOwner).ToggleRunState();
				return True;
				break;

			case IK_Escape :

				if ( MainMenu != None && !MainMenu.bDeleteMe )
					HideMainMenu();
				else
					ShowMainMenu();

				return True;
				break;

			case IK_Q :

				if ( Controller.bCtrlPressed )	
				{

					QuickSlotIndex = 0;
					return True;
				}

				break;

			case IK_W :

				if ( Controller.bCtrlPressed )	
				{

					QuickSlotIndex = 1;
					return True;
				}

				break;

			case IK_PageUp :

				QuickSlotIndex++;

				if ( QuickSlotIndex == class 'QuickKeyConst'.Default.QuickSlotColumns - 1 )
					QuickSlotIndex = 0;

				return True;
				break;

			case IK_PageDown :

				QuickSlotIndex--;

				if ( QuickSlotIndex == -1 )
					QuickSlotIndex = class 'QuickKeyConst'.Default.QuickSlotColumns - 1 - 1;

				return True;
				break;


		//plugin triger
			case IK_Home :
			/* 
			if ( Plugin != None )
				HidePlugin();
			else
				ShowPlugin();
			*/
				return True;
				break;


	
			case SephirothController(Controller).ArmKey :

				SephirothPlayer(PlayerOwner).ToggleArmState();
				return True;
				break;
		}
	}

	return False;
}


exec function MapTool()
{
	if ( MapInterface != None ) 
	{
		MapInterface.HideInterface();
		RemoveInterface(MapInterface);
		MapInterface = None;
	}
	else 
	{
		MapInterface = CMapInterface(AddInterface("SephirothUI.CMapInterface"));
		MapInterface.ShowInterface();
	}
}

exec function DevLog()
{
	if ( DevInterface != None ) 
	{
		DevInterface.HideInterface();
		RemoveInterface(DevInterface);
		DevInterface = None;
	}
	else 
	{
		DevInterface = CDevInterface(AddInterface("SephirothUI.CDevInterface"));
		DevInterface.ShowInterface();
	}
}

exec function SoundTool()
{
	if ( SoundInterface != None ) 
	{
		SoundInterface.HideInterface();
		RemoveInterface(SoundInterface);
		SoundInterface = None;
	}
	else 
	{
		SoundInterface = CSoundInterface(AddInterface("SephirothUI.CSoundInterface"));
		SoundInterface.ShowInterface();
	}
}

//@by wj(12/11)------
exec function ShowCastleUI()
{
	if( CastleManager != None )
		HideCastleManagerInterface();
	else
		ShowCastleManagerInterface();
}
//-------------------

//@by wj(040327)-----
exec function ScreenBlending(byte R, byte G, byte B, byte A, int MaxCount, float Time, byte Range)
{
	if( BlendingEffect != None )
		return;

	ShowScreenEffect();
	BlendingEffect.SetScreenEffect(R, G, B, A, MaxCount, Time, Range);
}

function ShowScreenEffect()
{
	if( BlendingEffect == None )
	{
		BlendingEffect = ScreenEffect(AddInterface("SephirothUI.ScreenEffect"));
		BlendingEffect.ShowInterface();
		SetFirstDraw(BlendingEffect);
	}
}

function HideScreenEffect()
{
	if( BlendingEffect != None )
	{
		BlendingEffect.HideInterface();
		RemoveInterface(BlendingEffect);
		BlendingEffect = None;
	}
}

function SetFirstDraw(CInterface Interface)
{
	local int i;
	for( i = Interface.InterfaceIndex + 1 ; i < Interfaces.Length ; i++ )
	{
		Interfaces[i - 1] = Interfaces[i];
		Interfaces[i].InterfaceIndex = Interfaces[i].InterfaceIndex - 1;
	}
	Interfaces[Interfaces.Length - 1] = Interface;
	Interfaces[Interfaces.Length - 1].InterfaceIndex = Interfaces.Length - 1;
}
//-------------------
function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	if( NotifyId == IDS_ClanApply )
	{
		if( EditText != "" )
			SephirothPlayer(PlayerOwner).Net.NotiClanApply(EditText);
	}

	//add neive : NPC ã��
	if( NotifyId == IDD_FindNPC )
	{
		if( EditText != "" )
			if( WorldMap.FindNPC(EditText) == False )
				AddMessage(1, Localize("Information","NotFindNPC","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
	}
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	local int NotifyValue, Space;
	local string Cmd, Param;

	if ( NotifyId == INT_MessageBox ) 
	{
		NotifyValue = int(Command);
		switch (NotifyValue) 
		{
			case IDM_QuitAtField:
				PlayerOwner.ConsoleCommand("Quit");
				break;
			case -1 * IDM_QuitAtField:
				bRequestExit = True;
				SephirothPlayer(PlayerOwner).Net.NotiResurrectAt(1,2);
				break;
			case IDM_PartyJoin:
				SephirothPlayer(PlayerOwner).Net.NotiPartyJoinAccept(PartyPlayer, PartyPlayerLevel); // ��Ƽ ����
				break;
			case -1 * IDM_PartyJoin:
				SephirothPlayer(PlayerOwner).Net.NotiPartyJoinDeny(PartyPlayer);
				break;
			case IDM_PartyInvite:
				SephirothPlayer(PlayerOwner).Net.NotiPartyInviteAccept(PartyPlayer, PartyPlayerLevel); // ��Ƽ ����
				break;
			case -1 * IDM_PartyInvite:
				SephirothPlayer(PlayerOwner).Net.NotiPartyInviteDeny(PartyPlayer);
				break;
			case IDM_ExchangeRequest:
				SephirothPlayer(PlayerOwner).Net.NotiXcngRequestAccept(ExchangePSI.PanID);
				break;
			case -1 * IDM_ExchangeRequest:
				SephirothPlayer(PlayerOwner).Net.NotiXcngRequestDeny(ExchangePSI.PanID);
				break;

			case IDM_MentorRequest :

				SephirothPlayer(PlayerOwner).Net.NotiResponseMentorAccept(aReceivedPSI[0].strName, aReceivedPSI[0].nOccuID);
				break;

			case -1 * IDM_MentorRequest :

				SephirothPlayer(PlayerOwner).Net.NotiResponseMentorDeny(aReceivedPSI[0].strName);
				break;

			case IDM_MenteeRequest :

				SephirothPlayer(PlayerOwner).Net.NotiResponseMenteeAccept(aReceivedPSI[0].strName, aReceivedPSI[0].nOccuID);
				break;

			case -1 * IDM_MenteeRequest :

				SephirothPlayer(PlayerOwner).Net.NotiResponseMenteeDeny(aReceivedPSI[0].strName);
				break;

			case IDM_QuitGame:
				PlayerOwner.ConsoleCommand("Quit");
				break;
		//@by wj(040203)------
			case IDM_ClanApplyCancel:
				SephirothPlayer(PlayerOwner).Net.NotiClanCancelApply();
				break;
			case -1 * IDM_ClanApplyCancel:
				break;
		//--------------------
			case IDM_BoothOpenWithAd:
				if( SephirothPlayer(PlayerOwner).PSI.TeamName != "" )
					AddMessage(1, Localize("Booth","CannotOpenBoothDuringMatch","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else if( StashLobby != None )
					AddMessage(1, Localize("Booth","CannotOpenBoothDuringStash","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else if( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
					AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else
					SephirothPlayer(PlayerOwner).Net.NotiBoothOpen(True);
				break;
			case -1 * IDM_BoothOpenWithAd:
				if( SephirothPlayer(PlayerOwner).PSI.TeamName != "" )
					AddMessage(1, Localize("Booth","CannotOpenBoothDuringMatch","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else if( StashLobby != None )
					AddMessage(1, Localize("Booth","CannotOpenBoothDuringStash","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else if( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
					AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else
					SephirothPlayer(PlayerOwner).Net.NotiBoothOpen(False);
				break;
			case IDM_BoothVisit:
				if( StashLobby != None )
					AddMessage(1, Localize("Booth","CannotVisitBoothDuringStash","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
				else
					SephirothPlayer(PlayerOwner).Net.NotiBoothVisit(TempSellerId);
				TempSellerId = -1;
				break;
			case -1 * IDM_BoothVisit:
				TempSellerId = -1;
				break;

			case IDM_SEALEDITEM :
			
				if ( Attachment(SephirothPlayer(PlayerOwner).InteractTo) != None )
				{
					SephirothPlayer(PlayerOwner).Net.NotiPickupItem(Attachment(SephirothPlayer(PlayerOwner).InteractTo).Info.PanID);
					SephirothPlayer(PlayerOwner).InteractTo = None;
				}

				break;
		}
	}
	else if (NotifyId == INT_Close) 
	{
		if ( Interface == m_PlayerInfo )		//esc ó�� ���⼭ ����.
			HideInfo();
		else if (Interface == DetailInfo) //add neive : ������â
			HideDetailInfo();
		else if (Interface == BattleInfo)
			HideBattleInfo();
		else if (Interface == MenuList)
			HideMenuList();
		else if(Interface == m_IngameShop)
			HideIngameShop();
		else if (Interface == MainMenu)
			HideMainMenu();
		else if (Interface == Option)
			HideOption();
		else if (Interface == Plugin)   //cs added
			HidePlugin();
		else if (Interface == m_InventoryBag)
			HideInventoryBag();
		else if (Interface == SkillTree)
			HideSkillTree();
		else if (Interface == Party)
			HideParty();
		else if (Interface == Exchange)
			HideExchange();
		else if (Interface == Store)
			HideStore();
		else if (Interface == StashLobby)
			HideStashLobby();
		else if (Interface == DialogMenu)
			HideDialog();
		else if (Interface == XMenu)
			HideXMenu();
		else if (Interface == AnimationMenu)
			HideAnimationMenu();
		else if (Interface == DeadMenu)
			HideDeadMenu();
		else if (Interface == Help)
			HideHelp();
		else if (Interface == Compound)
			HideCompound();
		else if (Interface == Smithy)
			HideSmithy();
		else if (WorldMap != None)
			HideWorldMap(); //add neive : �����
		else if (Interface == Quest)
			HideQuest();
		else if (Interface == Portal)
			HidePortal();
		else if (Interface == messenger)
			HideMessenger();
		else if (Interface == m_PetInfo)
			HidePetInterface();
		else if (Interface == CastleManager)
			HideCastleManagerInterface();
		else if (Interface == Inbox_Helper)	//modified by yj
			HideInbox_Helper();
		else if (Interface == ClanInterface)
			HideClanInterface();
		else if (Interface == RemodelingUI)
			HideRemodelingUI();
		else if (Interface == BlendingEffect)
		{
			HideScreenEffect();
		}
		else if (Interface == PetChat)
		{
			HidePetChat();
		}
		else if (Interface == PetBag)
		{
			HidePetBag();
		}
		else if( Interface == SellerBooth )
			SephirothPlayer(PlayerOwner).Net.NotiBoothClose();
		else if( Interface == GuestBooth )
		{
			SephirothPlayer(PlayerOwner).Net.NotiBoothLeave(GuestBooth.SellerInfo.PanID);
			OnGuestBoothClose();
		}
		else if( Interface == Smithy )
		{
			HideSmithy();
		}
		else if( Interface == WebBrowser)
		{
			HideWebBrowser();
		}
		else if( Interface == SubInventories[0] )
		{
			HideSubInventory(0);
		}
		else if( Interface == SubInventories[1] )
		{
			HideSubInventory(1);
		}
		else if( Interface == SubInventories[2] )
		{
			HideSubInventory(2);
		}
		else if (Interface == RndBoxDlg)
		{
			HideRandomBox();
		}
		else if ( Interface == IMentorInterface )
		{
			HideMentorInterface();
		}
		else if ( Interface == IPlayerEquip )
			HidePlayerEquip();
		else if (Interface == DissolveDlg)
		{
			HideDissolveBox();
		}
		else if (WorldMap != None)
			HideWorldMap(); //add neive : �����
		// Mr.Do �Ű� ��� �߰� --- Start ---
		//del neive : /�Ű� ��� ���� -----------------------------------------

		// keios - userreporthelp
		else if(int(Command) == IDD_USERREPORTHELP)
		{
			class'CUserReport'.Static.PopupUserReport(Self, Localize("Information", "ReportTitle", "Sephiroth"),
				ReportText);
		}
		//---------------------------------------------------------------------
		// Mr.Do �Ű� ��� �߰� --- End ---
	}
	else if (NotifyId == INT_Command) 
	{
	/*
		if(Interface == MainHud) {			//INT_Command�� ����� ��, Command�� ��� �޶� Interface�� Ȯ�� �� �ʿ�� ����.
			switch(Command) {
				case "Helper" :

					break;
				case "Note":

					break;
			}

		}
	*/
		if( Command == "Helper" ) 
		{
			ShowLatestHelper();
		}
		else if ( Command == "Note" )	
		{

			if ( ShowMessenger() )	
			{

				messenger.ShowInbox();
				messenger.OpenLatestReceiveNote();
			}
		}
		else if (Command == "Info") 
		{
			if ( m_PlayerInfo != None && !m_PlayerInfo.bDeleteMe )
				m_PlayerInfo.CloseInfo();
			else
				ShowInfo();
		}
		else if (Command == "DetailInfo") 
		{
			if ( DetailInfo != None && !DetailInfo.bDeleteMe )
				HideDetailInfo();
			else
				ShowDetailInfo();
		}
		else if (Command == "BattleInfo") 
		{
			if ( BattleInfo != None && !BattleInfo.bDeleteMe )
				HideBattleInfo();
			else
				ShowBattleInfo();
		}
		else if (Command == "InventoryBag") 
		{
			if ( m_InventoryBag != None && !m_InventoryBag.bDeleteMe )
				HideInventoryBag();
			else
				ShowInventoryBag();
		}
		else if (Command == "SkillTree") 
		{
			if ( SkillTree != None && !SkillTree.bDeleteMe )
				HideSkillTree();
			else
				ShowSkillTree();
		}
		else if (Command == "Party") 
		{
			if ( Party != None )
				HideParty();
			else
				ShowParty();
		}
		else if (Command == "Quest")	
		{

			if ( Quest != None )
				HideQuest();
			else
				ShowQuest();
		}
		else if (Command == "Portal") 
		{
			if ( Portal != None )
				HidePortal();
			else
				ShowPortal();
		}
		else if (Command == "MainMenuButton") 
		{
			if( MenuList != None )
				HideMenuList();
			else
				ShowMenuList();
		}
		else if (Command == "ShopButton")
		{
			if( m_IngameShop != None )
				HideIngameShop();
			else
				ShowIngameShop();
/*			//����ư ����
            if(WebBrowser != None)
            {
                HideWebBrowser();
                //ClearInputValidRegion();
            }
            else
            {
				SephirothPlayer(PlayerOwner).Net.NotiRequestOtp(ConsoleCommand("GetAccountName"),string(SephirothPlayer(PlayerOwner).PSI.PlayName));
				//NotiRequestOtp(string UserAlias, string CharacterName)
                //ShowWebBrowser();
                //SetInputValidRegion(WebBrowser.Components[0].X,WebBrowser.Components[0].Y,WebBrowser.Components[0].XL,WebBrowser.Components[0].YL);
            }
			//-----����ư �ӽ�����
*/
		}
		/*
		else if (Command == "MainMenuButton")
		{
			MainMenuVisible = bool(1 - int(MainMenuVisible));
		}
		*/
		else if (Command == "MainMenu") 
		{
			if ( MainMenu != None && !MainMenu.bDeleteMe )
				HideMainMenu();
			else
				ShowMainMenu();
		}
		else if (Command == "AnimationMenu") 
		{
			if ( AnimationMenu != None )
				HideAnimationMenu();
			else
				ShowAnimationMenu();
		}
		else if (Command == "Option") 
		{
			if ( Option != None && !Option.bDeleteMe )
				HideOption();
			else
				ShowOption();
		}
		/*@by wj(02/21)*/
		else if (Command == "messenger") 
		{
			if ( messenger != None && !messenger.bDeleteMe )
				HideMessenger();
			else
				ShowMessenger();
		}
		else if (Command == "Message") 
		{
			if ( messenger != None )
				HideMessenger();
			else	
			{

				if ( ShowMessenger() )
					messenger.ShowInbox();
			}
		}
		else if (Command == "Quit")
			class'CMessageBoxQuit'.Static.MessageBoxQuit(Self,IDM_QuitAtField);
		else if (Command == "GotoLobby") 
		{
			GotoLobby(False);
		}
		else if (Command == "Help")
			ShowHelp();
		else if (Command == "OptionScreen")
			ShowOptionTab(0);
		else if (Command == "OptionSound")
			ShowOptionTab(1);
		else if (Command == "OptionGame")
			ShowOptionTab(3);
		//else if (Command == "OptionControl")
		//	ShowOptionTab(4);
		else if(Command == "OptionPlugin")
		{   
		//@cs added
			ShowOptionTab(4);
		}

		//add neive : ������ --------------------------------------------------
		else if (Command == "GoWebShop")
		{   
		//�۾�
			//PlayerOwner.ConsoleCommand("Quit");
			//PlayerOwner.ConsoleCommand("GoWebShop");

			//add neive : �׽��� �Խ��� ����
//			PlayerOwner.ClientTravel("https://www.kaixuan2.com/community/boardbeta/in.jsp",TRAVEL_Absolute,false);

			PlayerOwner.ClientTravel("http://www.kaixuan2.com/sephiroth/www/shop/shop_main.jsp",TRAVEL_Absolute,False);
			GotoLobbyDirect(True);
			//PlayerOwner.ConsoleCommand("Quit");
		}
		//---------------------------------------------------------------------
		else if (Command == "GotoLobbyForce") 
		{
			GotoLobby(True);
		}
		else if (Command == "HotKeyUp")
		{
			QuickSlotIndex++;
			if( QuickSlotIndex == class 'QuickKeyConst'.Default.QuickSlotColumns - 1 )
			{
				QuickSlotIndex = 0;
			}
		}
		else if (Command == "HotKeyDown")
		{
			QuickSlotIndex--;
			if( QuickSlotIndex == -1 )
			{
				QuickSlotIndex = class 'QuickKeyConst'.Default.QuickSlotColumns - 1 - 1;
			}
		}
		else 
		{
			Space = InStr(Command," ");
			if ( Space != -1 ) 
			{
				Cmd = Left(Command,Space);
				Param = Mid(Command,Space + 1);
				if ( Cmd == "ApplyHotKey" )
					OnApplyHotkey(int(Param));
				else if (Cmd == "SendWhisper")
					OnSendWhisper(Param);
				else if (Cmd == "Trace")
					TracePlayerName = Param;
			}
		}
	}
}

// 返回到游戏大厅（显示服务器选择框）
// 弹出服务器选择对话框，让玩家选择要连接的大厅服务器
// @param bForce: 是否强制显示选择框（true=强制，false=可选）
function GotoLobby(bool bForce)
{
	local CTextSelectBox ServerInfoBox;		// 服务器选择对话框
	local string ServerGroup;				// 服务器组名称
	local int ServerIndex;					// 当前服务器索引
	local array<string> ServerIp;			// 服务器IP地址列表
	local array<string> ServerSetNames;		// 服务器显示名称列表
	local int i;							// 循环计数器
	local string ServerName;				// 服务器显示名称（临时变量）

	// 从游戏管理器获取服务器信息（服务器组、当前索引、IP列表）
	SephirothGame(Level.Game).GetServerInfoEx(ServerGroup, ServerIndex, ServerIp);
	
	// 遍历所有服务器IP，生成显示名称列表
	for ( i = 0;i < ServerIp.Length;i++ ) 
	{
		// 生成服务器显示名称：服务器组-服务器序号（例如："服务器组-1"）
		ServerName = ServerGroup@Localize("Terms","Server","Sephiroth")$"-"$(i + 1);
		
		// 如果是当前连接的服务器，在名称后添加"(当前服务器)"标记
		if ( i == ServerIndex )
			ServerName = ServerName@"("$Localize("Terms","CurrentServerSet","Sephiroth")$")";
		
		// 将生成的名称添加到列表中
		ServerSetNames[i] = ServerName;
	}
	
	// 弹出服务器选择对话框
	ServerInfoBox = class'CTextSelectBox'.Static.PopupTextSelectBox(Self, Localize("Information","GotoLobby","Sephiroth"), ServerSetNames, bForce);
	
	// 如果对话框创建成功，设置回调函数和默认选中项
	if ( ServerInfoBox != None ) 
	{
		// 设置选择回调函数：当玩家选择服务器后，调用OnServerSelect函数
		ServerInfoBox.OnSelectChoice = OnServerSelect;
		// 设置默认选中的文本为当前服务器名称
		ServerInfoBox.SelectedText = ServerSetNames[ServerIndex];
		// 设置默认选中的索引为当前服务器索引
		ServerInfoBox.SelectedTextIndex = ServerIndex;
	}
}


// 直接返回到游戏大厅（显示服务器选择框并立即执行）
// 与GotoLobby的区别：此函数会立即执行返回操作，不等待用户选择
// @param bForce: 是否强制显示选择框（true=强制，false=可选）
function GotoLobbyDirect(bool bForce)
{
	local CTextSelectBox ServerInfoBox;		// 服务器选择对话框
	local string ServerGroup;				// 服务器组名称
	local int ServerIndex;					// 当前服务器索引
	local array<string> ServerIp;			// 服务器IP地址列表
	local array<string> ServerSetNames;		// 服务器显示名称列表
	local int i;							// 循环计数器
	local string ServerName;				// 服务器显示名称（临时变量）

	// 从游戏管理器获取服务器信息（服务器组、当前索引、IP列表）
	SephirothGame(Level.Game).GetServerInfoEx(ServerGroup, ServerIndex, ServerIp);
	
	// 遍历所有服务器IP，生成显示名称列表
	for ( i = 0;i < ServerIp.Length;i++ ) 
	{
		// 生成服务器显示名称：服务器组-服务器序号（例如："服务器组-1"）
		ServerName = ServerGroup@Localize("Terms","Server","Sephiroth")$"-"$(i + 1);
		
		// 如果是当前连接的服务器，在名称后添加"(当前服务器)"标记
		if ( i == ServerIndex )
			ServerName = ServerName@"("$Localize("Terms","CurrentServerSet","Sephiroth")$")";
		
		// 将生成的名称添加到列表中
		ServerSetNames[i] = ServerName;
	}
	
	// 弹出服务器选择对话框
	ServerInfoBox = class'CTextSelectBox'.Static.PopupTextSelectBox(Self, Localize("Information","GotoLobby","Sephiroth"), ServerSetNames, bForce);
	
	// 如果对话框创建成功，设置回调函数和默认选中项
	if ( ServerInfoBox != None ) 
	{
		// 设置选择回调函数：当玩家选择服务器后，调用OnServerSelect函数
		ServerInfoBox.OnSelectChoice = OnServerSelect;
		// 设置默认选中的文本为当前服务器名称
		ServerInfoBox.SelectedText = ServerSetNames[ServerIndex];
		// 设置默认选中的索引为当前服务器索引
		ServerInfoBox.SelectedTextIndex = ServerIndex;
	}

	// 直接执行返回大厅操作（不等待用户选择）
	// 执行控制台命令，通知引擎跳转到指定的大厅服务器
	PlayerOwner.ConsoleCommand("GotoLobbyEx"@ServerIp[ServerIndex]);
	
	// 如果玩家控制器是客户端控制器，发送网络通知
	if( ClientController(PlayerOwner) != None )
		// 通知服务器：客户端请求跳转到指定的大厅服务器地址
		ClientController(PlayerOwner).Net.NotiGotoLobbyEx(ServerIp[ServerIndex]);
}


// 服务器选择回调函数
// 当玩家在服务器选择对话框中选择了某个服务器后，此函数被调用
// @param Index: 玩家选择的服务器索引
// @param Choice: 玩家选择的服务器显示名称（未使用）
function OnServerSelect(int Index, string Choice)
{
	local string ServerGroup;				// 服务器组名称（未使用）
	local int ServerIndex;					// 当前服务器索引（未使用）
	local array<string> ServerIp;			// 服务器IP地址列表

	// 从游戏管理器获取服务器信息（用于验证索引有效性）
	SephirothGame(Level.Game).GetServerInfoEx(ServerGroup, ServerIndex, ServerIp);

	// 验证选择的服务器索引是否有效
	if ( Index >= 0 && Index < ServerIp.Length )
	{
		// 清理频道管理器相关的编辑框界面
		if( ChannelMgr != None )
		{
			// 完成消息编辑（保存当前编辑状态）
			ChannelMgr.OnFinishMessageEdit();

			// 如果消息编辑框存在，关闭并移除
			if ( ChannelMgr.MessageEdit != None )
			{
				ChannelMgr.MessageEdit.HideInterface();
				RemoveInterface(ChannelMgr.MessageEdit);
				ChannelMgr.MessageEdit = None;
			}

			// 如果私聊编辑框存在，关闭并移除
			if ( ChannelMgr.WhisperEdit != None )
			{
				ChannelMgr.WhisperEdit.HideInterface();
				RemoveInterface(ChannelMgr.WhisperEdit);
				ChannelMgr.WhisperEdit = None;
			}
		}

		// 执行控制台命令，通知引擎跳转到指定的大厅服务器
		// 参数：GotoLobbyEx + 服务器IP地址
		PlayerOwner.ConsoleCommand("GotoLobbyEx"@ServerIp[Index]);
		
		// 如果玩家控制器是客户端控制器，发送网络通知
		if( ClientController(PlayerOwner) != None )
			// 通知服务器：客户端请求跳转到指定的大厅服务器地址
			ClientController(PlayerOwner).Net.NotiGotoLobbyEx(ServerIp[Index]);

		// 显示"准备返回大厅"的等待界面
		// 创建并显示返回大厅的过渡界面，提示玩家正在返回大厅
		ToLobby = CReadyToLobby(AddInterface("SephirothUI.CReadyToLobby"));
		ToLobby.ShowInterface();
		
		// 隐藏所有其他界面，只显示返回大厅的等待界面
		HideAllInterfaces();
	}
}


function OnPlayerMessage(int TellerInfo,string Teller,string Type,string Message,float HitSizeX,float HitSizeY,string HitText)
{
	local string DisplayText;
	local color DisplayColor;
	local bool IsBgColor;
	local color BgColor;

	if ( ChannelMgr != None && !ChannelMgr.bDeleteMe ) 
	{
		// +jhjung,2003.6.4
		if ( TellerInfo == 1 )
			Teller = Teller$"[GM]";
		// end

		if ( Type == "TELL" ) 
		{
			DisplayText = Teller$": "$Message;
			DisplayColor = class'Canvas'.Static.MakeColor(138,224,255);
		}
		else if (Type == "SHOUT") 
		{
			DisplayText = Teller$"("$Localize("Terms","Shout","Sephiroth")$"): "$Message;
			DisplayColor = class'Canvas'.Static.MakeColor(122,242,100);
		}
		else if (Type == "WHISPER") 
		{
//			if (DialogSession != None)
//				DialogSession.ReceiveDialog(Teller,Message);
			DisplayText = Teller$"("$Localize("Terms","Whisper","Sephiroth")$"): "$Message;
			DisplayColor = class'Canvas'.Static.MakeColor(249,249,127);
		}
		else if (Type == "PARTY") 
		{
			DisplayText = Teller$"("$Localize("Terms","Party","Sephiroth")$"): "$Message;
			DisplayColor = class'Canvas'.Static.MakeColor(194,255,179);
		}
		else if (Type == "TELLTEAM") 
		{
			DisplayText = Teller$"["$SephirothPlayer(PlayerOwner).PSI.TeamDesc$"]: "$Message;
			DisplayColor = TeamTellColor;
		}
		else if (Type == "CLANTELL") 
		{
			DisplayText = Teller$"["$SephirothPlayer(PlayerOwner).PSI.ClanName$"]: "$Message;
			DisplayColor = ClanTellColor;
		}
		else 
		{
			if( Type == localize("Booth", "BoothChannel", "Sephiroth") )
			{
/**
				if( ChannelMgr.ChannelMode != 4 && ChannelMgr.ChannelMode != 5 )
					return;
				else if( ChannelMgr.ChannelMode == 4 && SephirothPlayer(PlayerOwner).PSI.GetRightChannel() != Type )
					return;
				else if( ChannelMgr.ChannelMode == 5 && SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() != Type )
					return;
				else{
**/
				DisplayText = Teller$"["$Type$"]: "$Message;
				if ( SephirothPlayer(PlayerOwner).PSI.GetRightChannel() == Type )
					DisplayColor = class'Canvas'.Static.MakeColor(251,186,91);
				else if (SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() == Type)
					DisplayColor = class'Canvas'.Static.MakeColor(248,177,218);
/**
				}
**/
			}
			else
			{
				DisplayText = Teller$"["$Type$"]: "$Message;
				if ( SephirothPlayer(PlayerOwner).PSI.GetRightChannel() == Type )
					DisplayColor = class'Canvas'.Static.MakeColor(251,186,91);
				else if (SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() == Type)
					DisplayColor = class'Canvas'.Static.MakeColor(248,177,218);
			}
		}

		///  03.5.28 by BK
		switch(TellerInfo)
		{
			case 0:  // Normal
				break;
			case 1:  // GM
				DisplayColor = class'Canvas'.Static.MakeColor(144, 144, 253);
				break;
		}


		// +jhjung,2003.6.3 for GM sound
		if ( TellerInfo == 1 && InStr(DisplayText, GMWord) != -1 ) 
		{
			ReplaceText(DisplayText, GMWord, "");
			PlayerOwner.Pawn.PlaySound(GMSound,SLOT_None,0.4f,False,64.f,1.0f,False);
		}
		ChannelMgr.OnAddMessage(DisplayText, DisplayColor, True, int(HitSizeX), int(HitSizeY), HitText, IsBgColor, BgColor, TellerInfo,Type); // IsBgColor  03.5.29 by BK

	}
}

function OnSkillUpdate(int Index,bool bSet)
{
	if ( MainHud != None )
		MainHud.SetSkillSprite(SephirothPlayer(PlayerOwner),Index,bSet);
}

//@by wj(08/18)------
function bool IsSecondSkillFire(SecondSkill Skill, out actor Actor)
{
	local PlayerServerInfo PSI;
	local SephirothPlayer CC, OtherCC;

	CC = SephirothPlayer(PlayerOwner);
	PSI = SephirothPlayer(PlayerOwner).PSI;

	SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel(); //add neive : 12�� ������ üũ

	//add by hansung
	//2006.08.08
	//2�� ��ų �� �ϴù������ �����ȵǴ� �������..
    //if(Actor == None || Actor.bDeleteMe)
	if( Actor.bDeleteMe )
		return False;
	//@by wj(040810)------
	if( PSI.Grade < 2 ) //add neive : AC ��ų, �����ڴ� ���� ���ϰ��� ���� ��ų ����Ѵ�
	{
		if( Skill.Grade == 2 && !PSI.bTransformed )
		{
			AddMessage(1,Localize("Warnings","NeedTransformation","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
			return False;
		}
	}
	//--------------------
	//@by wj(040804)------
	if( Skill.SkillType != 3 && Skill.SkillType != 4 && Skill.SkillType != 5 && Skill.SkillType != 6 && PSI.bBlind )
		return False;

	//--------------------

	if( Skill.SkillType == 3 || Skill.SkillType == 5 || Skill.SkillType == 6 )
	{
		Actor = None;
		return True;
	}
	if( Skill.SkillType == 1 || Skill.SkillType == 2 )
	{
		if( Actor != PlayerOwner.Pawn )
		{
			/*
			if(Actor.IsA('Monster'))
				return true;
			CC = SephirothPlayer(PlayerOwner);
			if (Actor.IsA('Hero')) {
				if (CC.PSI.PkState)
					return true;
				else if (CC.ZSI.bUnderSiege) {
					OtherCC = SephirothPlayer(Hero(Actor).Controller);
					if (CC.PSI.WarState != OtherCC.PSI.WarState)
						return true;
				}
			}

			//@by wj(12/20)------
			if(Actor.IsA('GuardStone') && PSI.WarState != 1) {
				if(class'GuardStone'.static.IsGuardStoneAttackable(GuardStone(Actor).GSI ,PSI))
					return true;
			}
			//-------------------
			*/
			// ���콺�� ������ �� Ÿ���� �켱�̸� �� ������ ���� �������� Ÿ���̴�.
			if ( Actor.IsA('Monster') && !Character(Actor).bIsDead )
				return True;
			else if (Actor.IsA('Hero') && !Character(Actor).bIsDead) 
			{
				OtherCC = SephirothPlayer(Hero(Actor).Controller);
				if ( class'PlayerServerInfo'.Static.CanAttackPlayer(PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
					return True;
			}
			else if (Actor.IsA('GuardStone') && class'PlayerServerInfo'.Static.CanAttackGuardStone(PSI, GuardStone(Actor).GSI))
				return True;
			else if (Actor.IsA('MatchStone') && class'PlayerServerInfo'.Static.CanAttackMatchStone(PSI, MatchStone(Actor).MSI))
				return True;
			else if (CC.LockedTarget != None) 
			{
				Actor = CC.LockedTarget;
				if ( Actor.IsA('Monster') && !Character(Actor).bIsDead )
					return True;
				else if (Actor.IsA('Hero') && !Character(Actor).bIsDead) 
				{
					OtherCC = SephirothPlayer(Hero(Actor).Controller);
					if ( class'PlayerServerInfo'.Static.CanAttackPlayer(PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
						return True;
				}
				else if (Actor.IsA('GuardStone') && class'PlayerServerInfo'.Static.CanAttackGuardStone(PSI, GuardStone(Actor).GSI))
					return True;
				else if (Actor.IsA('MatchStone') && class'PlayerServerInfo'.Static.CanAttackMatchStone(PSI, MatchStone(Actor).MSI))
					return True;
			}
		}
	}
	if( Skill.SkillType == 4 )
	{
		if( Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor') )
			return True;
		if ( Actor.IsA('Monster') && !Character(Actor).bIsDead )
			return True;
		if ( Actor.IsA('Hero') && !Character(Actor).bIsDead ) 
		{
			OtherCC = SephirothPlayer(Hero(Actor).Controller);
			if ( class'PlayerServerInfo'.Static.CanAttackPlayer(PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
				return True;
		}
		if ( Actor.IsA('GuardStone') && class'PlayerServerInfo'.Static.CanAttackGuardStone(PSI, GuardStone(Actor).GSI) )
			return True;
		else if (Actor.IsA('MatchStone') && class'PlayerServerInfo'.Static.CanAttackMatchStone(PSI, MatchStone(Actor).MSI))
			return True;
	}
	return False;
}
//-------------------

function OnApplyHotkey(int Index)
{

	local int HotkeyType;
	local string HotkeyName;
	local SephirothPlayer PC;
	local Skill Skill;
	local SephirothItem Item;


	local actor TraceActor;
	local vector ViewOrigin, Direction, MousePos;
	local vector HitLocation, HitNormal;
	local vector ShooterLoc, TargetLoc;


	PC = SephirothPlayer(PlayerOwner);
	HotkeyName = PC.PSI.QuickKeys[Index].KeyName;
	HotkeyType = PC.PSI.QuickKeys[Index].Type;

	if( SellerBooth != None || GuestBooth != None )
		return;

	if( Smithy != None ) //add neive : 12�� ������. ����â�� ���ִٸ� ����Ű ��� ����~
		return;

	if ( HotkeyName == "" )
		return;

	if ( HotkeyType == class'GConst'.Default.BTNone )
		return;

	if( SephirothPlayer(PlayerOwner).PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� ����Ű ��� ����
	{
		AddMessage(2, Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(55,55,200));
		return;
	}

	if ( HotkeyType == class'GConst'.Default.BTPotion || HotkeyType == class'GConst'.Default.BTScroll )
	{
		Item = PC.PSI.SepInventory.FirstMatched(0, HotkeyName);

		//add neive : ��ũ�ѷ��� ����Ű â���� ���� ��� ���� Ÿ���� �ش�
		if( HotkeyType == class'GConst'.Default.BTScroll )
		{
			//Log("neive : check model name " $ Item.TypeName);
			if( sLastTypeName == Item.TypeName )
			{
				if( PlayerOwner.Level.TimeSeconds - nLastScrollUseTime < 3 )
				{
					//Log("neive : check ok !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
					if( InStr(Item.Typename, "Firecracker") == -1 )	//�̺�Ʈ�� ������ ��� ���ӻ�밡���ϵ��� �������ݴϴ�. -2009.12.28.Sinhyub
						return;
				}
			}

			nLastScrollUseTime = PlayerOwner.Level.TimeSeconds;
			sLastTypeName = Item.TypeName;
		}
		//---------------------------------------------------------

		if( Item.IsMarket() )
		{
			if ( Item != None )
				PC.Net.NotiItemUseShotcut(Item.TypeName);
		}
		else
		{
			if ( Item != None && Item.Amount > 0 )
				PC.Net.NotiItemUseShotcut(Item.TypeName);
		}

		return;
	}




	if ( HotkeyType == class'GConst'.Default.BTMenu )			//modified by yj
	{
		switch(HotkeyName) 
		{
			case "Info" :
				if ( m_PlayerInfo != None )
					m_PlayerInfo.closeInfo();	//hide�� close��  �� �˾ƺ���
				else
					ShowInfo();
				break;
			case "WorldMap" :
				if ( WorldMap != None )
					HideWorldMap();
				else
					ShowWorldMap();
				break;
			case "SkillTree" :
				if( SkillTree != None )
					HideSkillTree();
				else
					ShowSkillTree();
				break;
			case "InventoryBag" :
				if( m_InventoryBag != None )
					HideInventoryBag();
				else
					ShowInventoryBag();
				break;
			case "PetUI":
				if ( m_PetInfo != None )
					HidePetInterface();
				else
					ShowPetInterface();
				break;
			case "Party":
				if ( Party != None )
					HideParty();
				else
					ShowParty();
				break;
			case "PetBag":
				if( SephirothPlayer(PlayerOwner).SPet == None || SephirothPlayer(PlayerOwner).PetSI.PetLevel < 16 )
					return;
				if( PetBag != None )
					HidePetBag();
				else
					ShowPetBag();
				break;
			case "Portal":
				if ( Portal != None )
					HidePortal();
				else
					ShowPortal();
				break;
			case "ClanInterface":
				if( ClanInterface == None )
				{
					if( SephirothPlayer(PlayerOwner).PSI.ClanName != "" )
						SephirothPlayer(PlayerOwner).Net.NotiClanMemberInfo();
					else
						SephirothPlayer(PlayerOwner).Net.NotiClanApplying();
				}
				else
					HideClanInterface();
				break;
			case "Booth":
				if( SephirothPlayer(PlayerOwner).ZSI.bNoBoothOpen )
				{
					//AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
					class'CMessageBox'.Static.MessageBox(Self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
				}
				else
					SephirothPlayer(PlayerOwner).Net.NotiBoothFee();
				break;
			case "Friend":
				if ( messenger != None )
					HideMessenger();
				else
					ShowMessenger();

				break;

			case "Animation":
				if( AnimationMenu != None )
					HideAnimationMenu();
				else
					ShowAnimationMenu();
				break;
			case "Quest":
				if ( Quest != None )
					HideQuest();
				else
					ShowQuest();

				break;
			case "message":
				if ( messenger != None )
					HideMessenger();
				else	
				{

					if ( ShowMessenger() )
						messenger.ShowInbox();
				}
				break;
			case "BattleInfo":
				if ( BattleInfo != None )
					HideBattleInfo();
				else
					ShowBattleInfo();
				break;
			case "Option":
				if ( Option != None )
					HideOption();
				else
					ShowOption();
				break;
			case "Help":
				if ( Help != None )
					HideHelp();
				else
					ShowHelp();
				break;

		}

		return;		//�̰Ŷ� �ϴ� else if �����̾���� �� �����ϴ°� �ƴϾ�? Ȯ���ϰ� �ٲ���
	}


	if ( HotkeyType == class'GConst'.Default.BTSkill )
	{
		Skill = PC.QuerySkillByName(HotkeyName);
		if ( Skill == None )
			return;

		// keios - ��ų ���Ұ� ���� üũ
		if( !SephirothPlayer(PlayerOwner).CanUseAllSkill() )
		{
			AddMessage(2,Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			return;
		}

		if ( Skill.IsA('SecondSkill') )
		{
			if ( PC.ZSI.bNoUseSkill )
				return;

			if ( Skill.SkillLevel < 1 ) //add neive : ��ų ������ 1���� ������ ��� ����
				if( Skill.SkillName != "Transformation" )
					return;

			if( !SephirothPlayer(PlayerOwner).CanUse2ndSkill() )
			{
				AddMessage(2,Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}

			if ( SephirothController(Controller).IsValidContext(SephirothController(Controller).HoverContext, 3.0) ) 
			{
				TraceActor = SephirothController(Controller).HoverContext.Actor;
				if ( TraceActor != None )
					HitLocation = TraceActor.Location;
			}
			else 
			{
				ViewOrigin = PC.Location;
				MousePos.X = Controller.MouseX;
				MousePos.Y = Controller.MouseY;
				Direction = ScreenToWorld(MousePos);
				TraceActor = Trace(HitLocation, HitNormal, ViewOrigin + 5000 * Direction, ViewOrigin, True);
			}
			SecondSkill(Skill).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);
			if ( SecondSkill(Skill).bCharged || (SecondSkill(Skill).SkillType == 6 && Skill.bEnabled) ) 
			{
				if ( IsSecondSkillFire(SecondSkill(Skill), TraceActor) ) 
				{
					//Log("=====>OnHotKeyApply SecondSkill"@Skill.SkillName@SecondSkill(Skill).ShootingRange);
					if ( SecondSkill(Skill).ShootingRange != 0 ) 
					{
						ShooterLoc = PC.Pawn.Location;
						TargetLoc = TraceActor.Location;
						if ( VSize(TargetLoc - ShooterLoc) > SecondSkill(Skill).ShootingRange ) 
						{
							AddMessage(2, Localize("Warnings", "ShootingRangeOver", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
							return;
						}
					}

					//add neive : ��ų ���ÿ� ���ٰ� �ؼ� ������ ���� ���� üũ�ؼ� ���ƺ�
					if( PlayerOwner.Level.TimeSeconds - nLastItemUseTime < 0.4 )
						return;

					nLastItemUseTime = PlayerOwner.Level.TimeSeconds;
					//---------------------------------------------------------

					//PC.Start2ndSkillAction(Skill, TraceActor, HitLocation);
					SephirothController(Controller).OnSecondSkillStart(Skill, TraceActor, HitLocation);
				}
			}
			else
				AddMessage(1, Skill.FullName@Localize("Warnings", "SkillInCooltime", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
		}
		else if (Skill.IsCombo() && PC.PSI.ComboSkill != Skill.SkillName)
			PC.SetHotSkill(0, Skill.SkillName);
		else if (Skill.IsFinish() && PC.PSI.FinishSkill != Skill.SkillName)
			PC.SetHotSkill(1, Skill.SkillName);
		else if (Skill.IsMagic() && PC.PSI.MagicSkill != Skill.SkillName)
			PC.SetHotSkill(2, Skill.SkillName); //����

		//add neive : ������ ��ϵ� �Ͱ� ���� ����Ű�� ��ġ�ϸ� �׳� �ߵ� -----
		if( Skill.IsMagic() && PC.PSI.MagicSkill == Skill.SkillName )
			SephirothController(Controller).OnSelfInteraction();
		//---------------------------------------------------------------------

		return;
	}
}

function OnSendWhisper(string PlayName)
{
	if ( ChannelMgr == None )
		ShowChannelManager();
	if ( ChannelMgr != None )
		ChannelMgr.OnSendWhisper(PlayName);
}

function OnLevelUp()
{
	if ( MainHud != None )
		MainHud.JustLevelUp();
}

function OnSkillLearn(Skill Skill)
{
	if ( MainHud != None )
		MainHud.JustSkillLearned(Skill);
}

function OnPartyJoinRequest(string Requester, int level) // ��Ƽ ����
{
	PartyPlayer = Requester;
	PartyPlayerLevel = level;
	// Mr.Do - ��Ƽ���Խ� �˾�â���� ����
	class'CMessageBox'.Static.MessageBox(Self,"PartyJoin",Requester$Localize("Modals","SelectPartyJoinOrNot","Sephiroth"),MB_YesNo,IDM_PartyJoin,,MBPos_TopRight,True);

	//@by wj(05/30)------
	//if(ChannelMgr == None)
	//	ShowChannelManager();

// 	ChannelMgr.OnRequestPartyMessage(Requester$Localize("Status","SelectPartyJoinOrNot","Sephiroth"));
// 	if( !ChannelMgr.ReqInfo.bShow || !ChannelMgr.ReqInfo.IsXcngRequest ){
// 		ChannelMgr.SetRequestInfo(ChannelMgr.partyReqMessage, false);
// 		ChannelMgr.OnQueryAccept = OnPartyJoinRequestAccept;
// 		ChannelMgr.OnQueryDeny = OnPartyJoinRequestDeny;
// 	}
	//-------------------
}

function OnPartyInviteRequest(string Requester, int level) // ��Ƽ ����
{
	PartyPlayer = Requester;
	PartyPlayerLevel = level;
	// Mr.Do - ��Ƽ�ʴ�� �˾�â���� ����
	class'CMessageBox'.Static.MessageBox(Self,"PartyInvite",Requester$Localize("Modals","SelectPartyInviteOrNot","Sephiroth"),MB_YesNo,IDM_PartyInvite,,MBPos_TopRight,True);
	//@by wj(05/30)------
	//if(ChannelMgr == None)
	//	ShowChannelManager();
// 	ChannelMgr.OnRequestPartyMessage(Requester$Localize("Status","SelectPartyInviteOrNot","Sephiroth"));
// 	if( !ChannelMgr.ReqInfo.bShow || !ChannelMgr.ReqInfo.IsXcngRequest ){
// 		ChannelMgr.SetRequestInfo(ChannelMgr.partyReqMessage, false);
// 		ChannelMgr.OnQueryAccept = OnPartyInviteRequestAccept;
// 		ChannelMgr.OnQueryDeny = OnPartyInviteRequestDeny;
// 	}
	//-------------------
}

//@by wj(05/30)------
function OnPartyInviteRequestAccept()
{
	SephirothPlayer(PlayerOwner).Net.NotiPartyInviteAccept(PartyPlayer, PartyPlayerLevel); // ��Ƽ ����
	ChannelMgr.partyReqMessage = "";
	if( ChannelMgr.xcngReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.OnRequestXcngMessage(ChannelMgr.xcngReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.xcngReqMessage, True);
		ChannelMgr.OnQueryAccept = OnExchangeRequestAccept;
		ChannelMgr.OnQueryDeny = OnExchangeRequestDeny;
	}
}

function OnPartyInviteRequestDeny()
{
	SephirothPlayer(PlayerOwner).Net.NotiPartyInviteDeny(PartyPlayer);
	ChannelMgr.partyReqMessage = "";
	if( ChannelMgr.xcngReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.OnRequestXcngMessage(ChannelMgr.xcngReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.xcngReqMessage, True);
		ChannelMgr.OnQueryAccept = OnExchangeRequestAccept;
		ChannelMgr.OnQueryDeny = OnExchangeRequestDeny;
	}
}

function OnPartyJoinRequestAccept()
{
	SephirothPlayer(PlayerOwner).Net.NotiPartyJoinAccept(PartyPlayer, PartyPlayerLevel); // ��Ƽ ����
	ChannelMgr.partyReqMessage = "";
	if( ChannelMgr.xcngReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.OnRequestXcngMessage(ChannelMgr.xcngReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.xcngReqMessage, True);
		ChannelMgr.OnQueryAccept = OnExchangeRequestAccept;
		ChannelMgr.OnQueryDeny = OnExchangeRequestDeny;
	}
}

function OnPartyJoinRequestDeny()
{
	SephirothPlayer(PlayerOwner).Net.NotiPartyJoinDeny(PartyPlayer);
	if( ChannelMgr.xcngReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.partyReqMessage = "";
		ChannelMgr.OnRequestXcngMessage(ChannelMgr.xcngReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.xcngReqMessage, True);
		ChannelMgr.OnQueryAccept = OnExchangeRequestAccept;
		ChannelMgr.OnQueryDeny = OnExchangeRequestDeny;
	}
}

function OnExchangeRequestAccept()
{
	SephirothPlayer(PlayerOwner).Net.NotiXcngRequestAccept(ExchangePSI.PanID);
	ChannelMgr.xcngReqMessage = "";
	if( ChannelMgr.partyReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.OnRequestPartyMessage(ChannelMgr.partyReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.partyReqMessage, False);
		ChannelMgr.OnQueryAccept = OnPartyInviteRequestAccept;
		ChannelMgr.OnQueryDeny = OnPartyInviteRequestDeny;
	}
}

function OnExchangeRequestDeny()
{
	SephirothPlayer(PlayerOwner).Net.NotiXcngRequestDeny(ExchangePSI.PanID);
	ChannelMgr.xcngReqMessage = "";
	if( ChannelMgr.partyReqMessage != "" )
	{
		if( ChannelMgr == None )
			ShowChannelManager();
		ChannelMgr.OnRequestPartyMessage(ChannelMgr.partyReqMessage);
		ChannelMgr.SetRequestInfo(ChannelMgr.partyReqMessage, False);
		ChannelMgr.OnQueryAccept = OnPartyInviteRequestAccept;
		ChannelMgr.OnQueryDeny = OnPartyInviteRequestDeny;
	}
}

exec function PartyInvite()
{
//	OnPartyInviteRequest("wawoo");
}

exec function PartyJoin()
{
//	OnPartyJoinRequest("wawoo");
}

exec function ExchangeRequest()
{
	OnExchangeRequest(SephirothPlayer(PlayerOwner).PSI);
}
//-------------------

function OnExchangeRequest(PlayerServerInfo Requester)
{
	local string RequesterName;
	RequesterName = string(Requester.PlayName);
	ExchangePSI = Requester;
	// Mr.Do - ��ȯ��û�� �˾�â���� ����
	class'CMessageBox'.Static.MessageBox(Self,"ExchangeRequest",ExchangePSI.PlayName$Localize("Modals","SelectExchangeOrNot","Sephiroth"),MB_YesNo,IDM_ExchangeRequest,,MBPos_TopRight,True);
	//@by wj(05/30)------
	//if(ChannelMgr == None)
	//	ShowChannelManager();
// 	ChannelMgr.OnRequestXcngMessage(RequesterName$Localize("Status","SelectExchangeOrNot","Sephiroth"));
// 	if( !ChannelMgr.ReqInfo.bShow || ChannelMgr.ReqInfo.IsXcngRequest ){
// 		ChannelMgr.SetRequestInfo(ChannelMgr.xcngReqMessage, true);
// 		ChannelMgr.OnQueryAccept = OnExchangeRequestAccept;
// 		ChannelMgr.OnQueryDeny = OnExchangeRequestDeny;
// 	}
	//-------------------
}

exec function OnExchangeStart()
{
	if ( Exchange == None )
		ShowExchange();
}

function OnExchangeEnd()
{
	if ( Exchange != None )
		HideExchange();
}

function OnExchangeOkPressed(bool bySelf)
{
	if ( Exchange != None )
		Exchange.OnOkPressed(bySelf);
}

function OnExchangeOkReleased(bool bySelf)
{
	if ( Exchange != None )
		Exchange.OnOkReleased(bySelf);
}

function OnOpenStashLobby()
{
	if ( StashLobby == None )
		ShowStashLobby();
}

function OnOpenStashBox()
{
	if ( StashLobby != None )
		StashLobby.OpenStashBox();
}

function OnDialog(Npc Npc,string DialogStr)
{
	if ( DialogMenu == None )
		ShowDialog();
	if ( DialogMenu != None )
		DialogMenu.SetDialogProperty(Npc,DialogStr);
}

function OnXMenu(Hero Hero)
{
	local ClientController CC;	//ArmState
	CC = ClientController(Hero.Controller);
	if ( CC != None && CC.PSI != None )
	{
		//if(SephirothPlayer(PlayerOwner).PSI.ArmState)	// �����߿� ������� �Ⱥ���
		//	return;

		XMenu = XMenu(AddInterface("SephirothUI.XMenu"));

		if ( XMenu != None )
		{
			XMenu.PlayerPawn = Hero;
			XMenu.PlayerInfo = CC.PSI;
			XMenu.ShowInterface();
			XMenu.SetPosition(Controller.MouseX, Controller.MouseY);
		}
	}
}

exec function XMenuTest()
{
	OnXMenu(Hero(PlayerOwner.Pawn));
}

function OnPlayerDead()
{
	ShowDeadMenu();
}

function OnTraceFinish()
{
	TracePlayerName = "";
	AddMessage(2,Localize("Information","TrackingPlayerDisappeared","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
}

function OnCompoundStart()
{
	ShowCompound();
}

function OnSmithStart()
{
	ShowSmithy();
}

function OnWorldMapStart() //add neive : �����
{
	ShowWorldMap();
}

function OnNPCSearch(string sName) //add neive : NPC ǥ��
{
	if( sName != "" )
		WorldMap.FindNPC(sName);
}

function OnOpenCompound(array<int> Dealings)
{
	ShowCompound();
	if ( Compound != None && Compound.Compound != None )
		Compound.Compound.SetDealings(Dealings);
}

event AddMessage(int MessageType, string Message, color Color)
{
	if ( MessageType == 1 ) 
	{
		if( GameManager(Level.Game).GameCustomCmdManager.Handle(Message) )
			return;
		if ( ChannelMgr != None )
			ChannelMgr.OnAddMessage(Message, Color);
	}
	else if (MessageType == 2)
		MsgPool.AddMessage(Message,Color,12,ETextAlign.TA_MiddleCenter,1);
	else if (MessageType == 3) 
	{
		if ( DevInterface != None ) 
		{
			DevInterface.TextList.MakeList(Message);
			DevInterface.TextList.End();
		}
	}
	else if (MessageType == 5) 		//modified by yj		//�ӼӸ��� �۾� ���
		ChannelMgr.OnAddMessage(Message, Color, False, , , , , ,1,"WHISPER");
	else if (MessageType == 6)	
		MsgPool.AddMessage(Message, Color, 12, ETextAlign.TA_MiddleCenter, 1, False, , , , , , 1);
	else if(MessageType == class'GConst'.Default.SM_EventAlarm) //add neive : �̺�Ʈ �˸�
		class'CEventAlarmDlg'.Static.OnDlg(Self, Message, Color);
	else if (MessageType == 254 && ChannelMgr != None)
		ChannelMgr.OnAddMessage(Message, Color, False, , , , , , 1);
	else if (MessageType == 255)
		MsgPool.AddMessage(Message, Color, 12, ETextAlign.TA_MiddleCenter, 1, False, , , , , , 1);
}

function OnUpdateZone() // ���� ǥ��
{
	local SephirothPlayer Player;
	local string CastleDesc, ZoneDesc;

	Player = SephirothPlayer(PlayerOwner);
	CastleDesc = Player.ZSI.CastleDesc;
	ZoneDesc = Player.ZSI.ZoneDesc;

	/*!@
		[2004.1.28, jhjung]
		�������� ���� ���������� ���� ���,
		ZoneString �� S_ZoneUnknown���� �����Ǿ�� �Ѵ�.
		�׷��� ������, ������ ���������� �����Ǿ� ��ȣ������.
		���� ���, ��ũ��Ÿ����� ���������� ���� ��� "���Ƴ׽� ����"�� ǥ�õȴ�.

	if (CastleDesc == "" && ZoneDesc == "")
		return;
	*/
	TimeZoneUpdated = Level.TimeSeconds;
	if ( ZoneDesc != "" && CastleDesc == "" )
		ZoneString = ZoneDesc;
	else if (ZoneDesc == "" && CastleDesc != "")
		ZoneString = CastleDesc$" / "$S_ZoneUnknown;
	else if (CastleDesc == "" && ZoneDesc == "") //!@
		ZoneString = S_ZoneUnknown;
	else
		ZoneString = CastleDesc$" / "$ZoneDesc;

	if ( Player.ZSI.bUnderSiege || Player.ZSI.bNoMinimap )
	{
		if ( m_MiniMap != None )
		{
			HideMinimap();
			AddMessage(1, Localize("Information","RadarOffUnderSiege","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
		}
	}

	if( Player.ZSI.bNoBoothOpen )
	{
		if( Player.PSI.IsBoothSeller() )
		{
			Player.Net.NotiBoothClose();
			AddMessage(1, Localize("Booth","NoBoothOpenZone","Sephiroth"), class'Canvas'.Static.MakeColor(255,255,0));
		}
	}

	//bRenderTopStuff = true;
}

function RenderTopStuff(Canvas C)
{
	local SephirothGame GM;
	local string S_Reign,S_Year,S_Month,S_Day,S_Hour;
	local string ServerGroup;
	local int ServerIndex;

	GM = SephirothGame(Level.Game);
	if ( GM != None && GM.Environment != None ) 
	{
		C.SetPos(0,0);
		C.DrawTile(Controller.BackgroundBlend,C.ClipX,18,0,0,0,0);
		S_Reign = Localize("Terms","Reign","Sephiroth");
		S_Year = Localize("Terms","Year","Sephiroth");
		S_Month = Localize("Terms","Month","Sephiroth");
		S_Day = Localize("Terms","Day","Sephiroth");
		S_Hour = Localize("Terms","Hour","Sephiroth");
		C.KTextFormat = ETextAlign.TA_MiddleLeft;
		C.DrawKoreanText(S_Reign$" "$GM.Environment.Year$S_Year@GM.Environment.Month$S_Month@GM.Environment.Day$S_Day@GM.Environment.Hour$S_Hour,0,0,C.ClipX,18);
		if ( ZoneString != "" ) 
		{
			C.KTextFormat = ETextAlign.TA_MiddleRight;
			C.DrawKoreanText(ZoneString,0,0,C.ClipX,18);
		}

		GM.GetServerId(ServerGroup,ServerIndex);
		if ( ServerGroup != "" && ServerIndex != -1 ) 
		{
			C.KTextFormat = ETextAlign.TA_MiddleCenter;
			C.DrawKoreanText(ServerGroup$Localize("Terms","ServerGroup","Sephiroth")$" - "$Localize("Terms","Server","Sephiroth")$ServerIndex, 0, 0, C.ClipX, 18);
		}
	}
}


function OnRenderDesktop(Canvas C)
{
	//local CInterface theInterface;

	if ( MsgPool != None )
		MsgPool.DrawMessage(C,0,100,C.ClipX);

	//add neive : NPC ã�� ������ �ڽ� ���� -----------------------------------
	if( WorldMap != None )
		if( WorldMap.bOnOpenEditBox == True )
		{
			class'CEditBox'.Static.EditBox(Self,"FindNPC",Localize("Modals","FindNPC","Sephiroth"),IDD_FindNPC ,20,"");
			WorldMap.bOnOpenEditBox = False;
		}
	//-------------------------------------------------------------------------


/*
	if (bShowStat && MainHud != None) {
		if(C.ClipX >= 1280)
			StatX = GaugeHud.PageX + 37 ;		//C.ClipX - 53- (C.ClipX/2 - 1280/2) ;
		else
			StatX = GaugeHud.PageX + 37 ;	//C.ClipX - 53;

		StatY =	GaugeHud.PageY - 28;		// C.ClipY - 196; //add neive : ���� ��ư ��ġ ����

		if (IsCursorInsideCircleAt(StatX,StatY,32,32)) {
			Texture = TextureResources[1].Resource;
			Controller.SetTooltip(Localize("Tooltip","OnTopStat","Sephiroth"));
		}
		else
			Texture = TextureResources[0].Resource;
		C.SetPos(StatX,StatY);
		C.DrawColor = Controller.InterfaceSkin;
		C.SetRenderStyleAlpha();
		C.DrawTile(Texture,32,32,0,0,32,32);
		C.SetDrawColor(255,255,255);
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		C.DrawKoreanText(SephirothPlayer(PlayerOwner).PSI.LevelPoint,StatX,StatY,32,32);
	}

	//add neive : ���θ޴� ��ư -----------------------------------------------
	if (MainHud != None || GaugeHud != None)
	{

		////////////////////////////////////////////////////////////modifieid by yj
		if(C.ClipX >= 1280)		//modified by yj
			nMainBtnX = GaugeHud.PageX + 37;  //C.ClipX - 53- (C.ClipX/2 - 1280/2);
		else
			nMainBtnX = GaugeHud.PageX + 37;	//C.ClipX - 53;

		if (MainHud != None)
			nMainBtnY =	GaugeHud.PageY + 13;	//C.ClipY - 155;
		else
			nMainBtnY = C.ClipY - 140;
		if (IsCursorInsideCircleAt(nMainBtnX, nMainBtnY, 32, 32))
			Texture = TextureResources[3].Resource;
		else
			Texture = TextureResources[2].Resource;
		C.SetPos(nMainBtnX, nMainBtnY);
		C.SetRenderStyleAlpha();
//		C.DrawTile(Texture,32,32,0,0,32,32);
	}
	//-------------------------------------------------------------------------

*/

	// ���콺 Ŀ���� ȭ�� ��ܿ� ��ġ���� �� ���ӻ��� �޷°� �ð��� ǥ��
	if ( Controller.MouseY < 9 ) // ������ �� ������Ʈ ���� ���������� �ʿ���� �� -��-; �����Ӹ� 10 �ش� �׳� ���콺 �ø��� ������
	{
		if  ( Controller.MouseY < 9 || Level.TimeSeconds - TimeZoneUpdated <= 3 ) // �� ������Ƽ�� �ð��� �̿��ϸ� �� �ٲ� �� �̷� ǥ�ø� ũ�� ���� �� �ְ���
			RenderTopStuff(C);
		else
			bRenderTopStuff = False;
	}

	// �ٸ� �÷��̾ ���󰡱� ���� ���� �� ǥ��
	if ( PlayerOwner.IsInState('TracingEx') && TracePlayerName != "" )
	{
		if ( Level.TimeSeconds - int(Level.TimeSeconds) < 0.5 )
		{
			C.KTextFormat = ETextAlign.TA_MiddleCenter;
			C.DrawKoreanText(TracePlayerName$" "$Localize("Status","TrackingPlayer","Sephiroth"),0,0,C.ClipX,18);
		}
	}

	if ( Tooltip != None )
	{
		Tooltip.Layout(C);
		Tooltip.Render(C);
	}
}

function RenderTest(Canvas C)
{
	local string TestString;
	local array<string> TestStringArray;
	local int i;

	TestString = "AbcdEfghIjkl|MnopQrstUvwx Yz";
	TestString = MakeColorCode(class'Canvas'.Static.MakeColor(255,0,255))$TestString$MakeColorCode(class'Canvas'.Static.MakeColor(0,255,0))$TestString;
	C.WrapStringToArray(TestString,TestStringArray,100, "|");
	for ( i = 0;i < TestStringArray.Length;i++ ) 
	{
		C.DrawKoreanText(TestStringArray[i], 100, 100 + i * 15, 200, 16);
	}

	C.DrawScreenText("My Name Is Jaehun Jung", 0.5, 0.5, DP_MiddleMiddle );
	C.SetPos(400, 400);
	C.DrawBox(C, 200, 14);
	C.DrawTextJustified("Hi What's up! What's your name? What do you do?", 0, 400, 400, 600, 414);
}


// ���� ��û�� �޾Ҵ�
function OnRecv_RequestMentor(string strMentorName, int nOccuID)
{
	local MSG_RECV	tempMSG;

	tempMSG.strName = strMentorName;
	tempMSG.nOccuID = nOccuID;

/*	aReceivedPSI[aReceivedPSI.Length] = tempMSG;*/
	aReceivedPSI[0] = tempMSG;
	class'CMessageBox'.Static.MessageBox(Self, "MentorRequest",
		aReceivedPSI[0].strName$Localize("Status", "SelectMentorRequest1", "Sephiroth")@aReceivedPSI[0].strName$Localize("Status", "SelectMentorRequest2", "Sephiroth"),
		MB_YesNo, IDM_MentorRequest, ,MBPos_TopRight, True);
}


// ���� ��û�� �޾Ҵ�.
function OnRecv_RequestFollower(string strMentorName, int nOccuID)
{
	local MSG_RECV	tempMSG;
	
	tempMSG.strName = strMentorName;
	tempMSG.nOccuID = nOccuID;

/*	aReceivedPSI[aReceivedPSI.Length] = tempMSG;*/
	aReceivedPSI[0] = tempMSG;
	class'CMessageBox'.Static.MessageBox(Self, "FollowerRequest",
		strMentorName$Localize("Status", "SelectFollowerRequest1", "Sephiroth")@strMentorName$Localize("Status", "SelectFollowerRequest2", "Sephiroth"),
		MB_YesNo, IDM_MenteeRequest, ,MBPos_TopRight, True);
}


event Tick(float DeltaTime)
{
	if ( MsgPool != None )
		MsgPool.CheckAge(DeltaTime);
	Super.Tick(DeltaTime);
	if ( bBlockPapering ) 
	{
		PaperingBlockTicks += DeltaTime;
		if ( PaperingBlockTicks > PaperingBlockSeconds ) 
		{
			bBlockPapering = False;
			PaperingBlockTicks = 0;
			PaperingBlockSeconds = PaperingBlockSeconds * PaperingBlockFactor;
			if ( PaperingBlockSeconds > PaperingBlockSecondsMax )
				PaperingBlockSeconds = PaperingBlockSecondsMax;
//			LastSyncTime = Level.TimeSeconds; // Hack for continuous input
		}
	}

	// ������ ��ũ�� �ð����κ��� 5�� �Ŀ� �����丮�� �����.
	if ( Level.TimeSeconds - LastSyncTime > 5 )
		MessageHistory.Remove(0, MessageHistory.Length);

	// ���� �޽����� ����Ʈ�� ���������� ó��
/*	if ( msgBoxReceived != None )
	{
		// �޽��� �ڽ��� �ִ� ���ȿ��� Ÿ�̸Ӹ� üũ�ؼ� �ڵ��������� ó���Ѵ�.
		if ( Level.TimeSeconds - fRecvMsgTime > 30 )
		{
			// TODO : ������ ������ ������.
			aReceivedPSI.remove(0, 1);
			RemoveInterface(msgBoxReceived);
			msgBoxReceived = None;
		}
	}
	else
	{
		// ��û���� �޽����� �����ִٸ� ó�����ش�.
		if ( aReceivedPSI.Length > 0 )
		{
			// ���� ������ 200 �̸��̶�� ���ڿ�û�� ������ ���̰�
			if ( SephirothPlayer(PlayerOwner).PSI.PlayLevel < 200 )
			{
				msgBoxReceived = class'CMessageBox'.static.MessageBox(Self, "FollowerRequest",
												aReceivedPSI[0].strName $ Localize("Modals", "SelectFollowerRequest1", "Sephiroth") @ aReceivedPSI[0].strName $ Localize("Modals", "SelectFollowerRequest2", "Sephiroth"),
												MB_YesNo, IDM_MentorRequest, ,MBPos_TopRight, true);
			}
			// ���� ������ 200 �̻��̶�� ���¿�û�� ������ ���̴�.
			else
			{
				msgBoxReceived = class'CMessageBox'.static.MessageBox(Self, "MentorRequest",
												aReceivedPSI[0].strName $ Localize("Modals", "SelectMentorRequest1", "Sephiroth") @ aReceivedPSI[0].strName $ Localize("Modals", "SelectMentorRequest2", "Sephiroth"),
												MB_YesNo, IDM_MenteeRequest, ,MBPos_TopRight, true);
			}

			if ( msgBoxReceived != None )
				fRecvMsgTime = Level.TimeSeconds;
		}
	}*/

	// �ֻ��� �������̽� üũ
	ITopOnCursor = GetTopInterfaceBelowCursor();
}

function ClearTooltip()
{
	if ( Tooltip != None )
		Tooltip.HideTooltip();
}

function ShowTooltip(string Text,bool bLocalize)
{
	if ( Text != "" && bool(ConsoleCommand("GETOPTIONI ShowTooltip")) ) 
	{
		if ( bLocalize )
			Tooltip.ShowTooltip(Localize("Tooltip",Text,"Sephiroth"));
		else
			Tooltip.ShowTooltip(Text);
	}
}

function OnRestart()
{
	/*!@ 2004.2.25 jhjung: to close Stash when teleport finished */
	if ( StashLobby != None ) 
	{
		if ( StashLobby.StashBox != None )
			StashLobby.CloseStashBox();
		HideStashLobby();
	}
	/**/
	if (m_InventoryBag != None)
		HideInventoryBag();
	if (SkillTree != None)
		HideSkillTree();
    if ( (Party != None) && !SephirothPlayer(PlayerOwner).PSI.bParty )	//��Ƽ�� �����Ѵٸ� ��� �����ش�. sinhyub
		HideParty();
	if (Store != None)
		HideStore();
	if (DialogMenu != None)
		HideDialog();
	if (XMenu != None)
		HideXMenu();
	if (DeadMenu != None)
		HideDeadMenu();
	if (Compound != None)
		HideCompound();
	/*@by wj(02/21)*/
	if ( messenger != None )
		HideMessenger();
	//@by wj(0202)
	if ( ClanInterface != None )
		HideClanInterface();
	//@by wj(040331)
	if ( RemodelingUI != None )
		HideRemodelingUI();
	if ( Smithy != None ) //add neive : ����
		HideSmithy();
	if ( WorldMap != None ) HideWorldMap(); //add neive : �����
	//+jhjung,2004.01.13
	if ( CastleManager != None )
		HideCastleManagerInterface();
	if ( ModalInterface != None ) 
	{
		ModalInterface.HideInterface();
		RemoveInterface(ModalInterface);
		ModalInterface = None;
	}
	//end+

	//@by wj(040621)------
	if ( PetChat != None )
		HidePetChat();
	if ( PetBag != None )
		HidePetBag();
	//--------------------
	if ( MenuList != None )
		HideMenuList();
	if( m_IngameShop != None )
		HideIngameShop();
	if ( Inbox_Helper != None )
		HideInbox_Helper();

	//if (InventoryBag != None)
	//	HideInventoryBag();

	if ( RndBoxDlg != None )
		HideRandomBox();

	if ( DissolveDlg != None )
		HideDissolveBox();
	if ( bRequestExit )
		PlayerOwner.ConsoleCommand("Quit");
}

function OnPlayerOut(PlayerServerInfo PSI,Pawn Pawn)
{
	if ( XMenu != None && XMenu.PlayerPawn == Pawn && XMenu.PlayerInfo == PSI )
		HideXMenu();
}

function OnDisconnected(optional string Result)
{
	if ( Result == "" && !bAlreadyDisconnected )
		class'CMessageBox'.Static.MessageBox(Self,"Disconnected",Localize("Modals","Disconnected","Sephiroth"),MB_Ok,IDM_QuitGame);
	else
		class'CMessageBox'.Static.MessageBox(Self,"Disconnected",Result,MB_Ok,IDM_QuitGame);
	bAlreadyDisconnected = True;
}

exec function PortalTest(optional bool bOff)
{
	if ( utPortal == None )
		utPortal = spawn(class'UnitTest_Portal');
	if ( utPortal != None ) 
	{
		if ( bOff ) 
		{
			utPortal.Finish();
			MapInterface.HideInterface();
			RemoveInterface(MapInterface);
			MapInterface = None;
		}
		else 
		{
			if ( MapInterface == None ) 
			{
				MapInterface = CMapInterface(AddInterface("SephirothUI.CMapInterface"));
				MapInterface.ShowInterface();
			}
			utPortal.Start(MapInterface);
		}
	}
}

exec function DropMonsterItem(name MobName, int nSimulation)
{
	if ( utDropItem == None )
		utDropItem = spawn(class'UnitTest_DropMonsterItem');
	if ( utDropitem != None ) 
	{
		utDropItem.MonsterName = MobName;
		utDropItem.SimulationCount = nSimulation;
		utDropItem.Start(Self);
	}
}

exec function MasterAll()
{
	if ( atMaster == None )
		atMaster = spawn(class'Macro_MasterAll');
	if ( atMaster != None )
		atMaster.Start(Self);
}

exec function DropAll13()
{
	if( atDropAll13 == None )
	{
		atDropAll13 = spawn(class'Macro_DropAll13');
		atDropAll13.Start(Self);
	}
}

exec function IngameDlg(int nType, int nResult)
{
	ShowIngameShopDlg(nType, nResult);
}

exec function OnInGameShop()
{
	bOnInGameShop = True;
}

exec function FindItemTest(optional bool bOff)
{
	if ( utFindItem == None )
		utFindItem = spawn(class'UnitTest_FindItem');
	if ( utFindItem != None ) 
	{
		if ( bOff )
			utFindItem.Finish();
		else
			utFindItem.Start(Self);
	}
}

function MakeTransparent()
{
	if ( Tooltip != None ) 
	{
		Tooltip.HideInterface();
		Tooltip.Destroy();
		Tooltip = None;
	}
	HideMainInterface();
	HideInfo();
	HideOption();
	HideInventoryBag();
	HideSkillTree();
	HideParty();
	HideExchange();
	HideSellerBooth();
	HideGuestBooth();
	HideStore();
	HideStashLobby();
	HideXMenu();
	HideAnimationMenu();
	HideDeadMenu();
	HideHelp();
	HideCompound();
	HideQuest();
	HidePortal();
	/*@by wj(02/21)*/
	HideMessenger();
	//@by wj(040205)
	HideClanInterface();
	//@by wj(08/26)
//	Hide2ndSkillInterface();
	HideSmithy(); //add neive : ����
	HideMenuList();
	HideInbox_Helper();

	HideRandomBox();

	HideDissolveBox();
	ChannelMgr.UpdateLayout();
}

event WorldSpaceOverlays()
{
	local int i;
	local GameManager GM;
	local Creature M;
	local Hero H;

	Super.WorldSpaceOverlays();
	if ( bPlotLocation ) 
	{
		GM = GameManager(Level.Game);
		for ( i = 0;i < GM.Creatures.Length;i++ ) 
		{
			M = GM.Creatures[i];
			if ( M != None && !M.bDeleteMe ) 
			{
				Draw3DLine(M.Controller.Destination, M.Location, class'Canvas'.Static.MakeColor(255,255,0));
				Draw3DLine(ServerController(M.Controller).MSI.PanPos, M.Location, class'Canvas'.Static.MakeColor(255,0,255));
			}
		}
		for ( i = 0;i < GM.Heroes.Length;i++ ) 
		{
			H = GM.Heroes[i];
			if ( H != None && !H.bDeleteMe ) 
			{
				Draw3DLine(H.Controller.Destination, H.Location, class'Canvas'.Static.MakeColor(0,255,255));
			}
		}
	}
}

exec function DumpAttachment()
{
	local Hero H;
	local Attachment A;
	local int i;

	H = Hero(PlayerOwner.Pawn);
	for ( i = 0;i < 13;i++ ) 
	{
		A = H.Attachments[i];
		if ( A != None ) 
		{
			//Log(A.Name @ A.RelativeLocation @ A.AttachmentBone @ A.Physics);
			if ( A.DivineEffect != None ) 
			{
				//Log("     " @ A.DivineEffect.Name @ A.DivineEffect.RelativeLocation @ A.DivineEffect.AttachmentBone @ A.DivineEffect.Physics);
			}
		}
	}
}

/*@by wj(02/21)*/
exec function OpenMessenger()
{
	if ( messenger == None )
		ShowMessenger();
}

exec function CloseMessenger()
{
	if( messenger != None )
		HideMessenger();
}

function OnOpenDialog(NpcServerInfo Npc, SephirothPlayer.Dialog Dialog)
{
	if ( DialogMenu == None )
		ShowDialog();
	if ( DialogMenu != None ) 
	{
		DialogMenu.SetHost(Npc);
		DialogMenu.SetDialog(Dialog);
	}
}

function OnOpenShop(NpcServerInfo Npc, SephirothPlayer.Shop Shop)
{
	if ( Store == None )
		ShowStore();

	if ( Store != None ) 
	{

		Store.SetHost(Npc);
		Store.SetShop(Shop);
	}
}

function OnUpdateShop(ShopItems Items)
{
	if ( Store != None )
		Store.SetItems(Items);
}

function OnOpenBank(NpcServerInfo Npc, Bank Bank)
{
	if ( StashLobby == None )
		ShowStashLobby();
	if ( StashLobby != None ) 
	{
		StashLobby.SetHost(Npc);
		StashLobby.SetBank(Bank);
	}
}

function OnOpenDepository(StashItems StashItems)
{
	if ( StashLobby != None )
		StashLobby.OpenStashBox();
}

function OnUpdateStashInfo(int StashId)
{
	if ( StashLobby != None )
		StashLobby.UpdateStashInfo(StashId);
}

function OnUpdateBuddyInfo() //@by wj(02/24)
{
	if ( messenger != None )
		messenger.UpdateBuddyInfo();
}

//@by wj(08/21)------

function OnUpdateSkillCredit()
{
//	Show2ndSkillInterface();
}
//-------------------

function ResetWaitingAttackResult() 	//add neive : ���� ���� ���� ��Ŷ ���� ���� ����
{
	//Log("neive : check Reset Attack !");
	SephirothPlayer(PlayerOwner).PSI.nWaitingAttackResultCnt = 0;
}

//@by wj(040203)------
function OnClanApplying(string ClanName)
{
	if( ClanName == "" )
		class'CEditBox'.Static.EditBox(Self,"ClanApply",Localize("Modals","ClanApply","Sephiroth"),IDS_ClanApply,20,"");
	else
		class'CMessageBox'.Static.MessageBox(Self,"ClanApplyCancel",ClanName$Localize("Modals","ClanApplyCancel","Sephiroth"),MB_YESNO,IDM_ClanApplyCancel);
}
//--------------------

exec function SetInterfaceSkin(byte A, byte R, byte G, byte B)
{
	Controller.InterfaceSkin.A = A;
	Controller.InterfaceSkin.R = R;
	Controller.InterfaceSkin.G = G;
	Controller.InterfaceSkin.B = B;
}

exec function SetNpcOffset(float X, float Y, float Z)
{
	if ( DialogMenu != None )
		DialogMenu.SetNpcOffset(X,Y,Z);
}
//@by wj(08/18) fortest
exec function SecondSkillLevelUp(string SkillName)
{
	local SephirothPlayer PC;
	local Skill Skill;

	PC = SephirothPlayer(PlayerOwner);
	Skill = PC.QuerySkillByName(SkillName);
	if( Skill != None && Skill.IsA('SecondSkill') )
	{
		if( Skill.SkillLevel < 5 )
			Skill.SkillLevel += 1;
	}
}

function OnRemoveBagItem(SephirothItem Item)
{
	local int i;
	// unreference purged object
	if( Controller.SelectingList.Length > 0 ) 
	{
		for ( i = 0;i < Controller.SelectingList.Length;i++ ) 
		{
			if ( Item == Controller.SelectingList[i] ) 
			{
				Controller.SelectingList[i] = None;
				break;
			}
		}
	}

	if( Controller.ObjectList.Length > 0 ) 
	{
		for ( i = 0;i < Controller.ObjectList.Length;i++ ) 
		{
			if ( Item == Controller.ObjectList[i] ) 
			{
				Controller.ObjectList[i] = None;
				break;
			}
		}
	}

	if ( Controller.DragSource != None ) 
	{
		for ( i = 0;i < Controller.SelectedList.Length;i++ ) 
		{
			if ( Item == Controller.SelectedList[i] ) 
			{
				Controller.SelectedList[i] = None;
				break;
			}
		}
	}

	if ( RemodelingUI != None ) 
	{
		if( Item == RemodelingUI.MainItem )
			RemodelingUI.RemoveItem(Item);
		else 
		{
			for ( i = 0 ; i < RemodelingUI.Resources.Length ; i++ ) 
			{
				if ( Item == RemodelingUI.Resources[i] ) 
				{
					RemodelingUI.RemoveItem(Item);
					break;
				}
			}
		}
	}
}

exec function PlotLocation()
{
	bPlotLocation = !bPlotLocation;
}

exec function SetTestSkillName(name Name)
{
	TestSkillName = string(Name);
}

function EPaperingType CheckPapering(string Message)
{
	if ( Level.TimeSeconds - LastSyncTime <= PaperingProbeSeconds ) 
	{
		if ( (SyncCountInProbeSeconds + 1) / PaperingProbeSeconds >= SyncCountPerSecond )
			return PT_TooFast;
		else 
		{
			if ( CheckHistory(Message, 1) )
				return PT_History;
			SyncCountInProbeSeconds++;
		}
	}
	else 
	{
		if ( CheckHistory(Message, 0) )
			return PT_History;
		SyncCountInProbeSeconds = 1;
		PaperingBlockTicks = 0;
		LastSyncTime = Level.TimeSeconds;
	}
	return PT_None;
}

function bool CheckHistory(string Message, optional int AllowedDiffSize)
{
	local int i;
	local string Last, Curr;
	local int LastSize, CurrSize;

	Curr = Message;
	CurrSize = Len(Curr);
	for ( i = 0;i < MessageHistory.Length;i++ ) 
	{
		Last = MessageHistory[i];
		LastSize = Len(Last);
		if ( abs(LastSize - CurrSize) > AllowedDiffSize )
			continue;
		if ( LastSize < CurrSize )
			Curr = Left(Curr, LastSize);
		else if (CurrSize < LastSize)
			Last = Left(Last, CurrSize);
		if ( Last == Curr )
			return True;
	}
	if ( MessageHistory.Length < 4 )
		MessageHistory[MessageHistory.Length] = Message;
	else 
	{
		for ( i = 0;i < MessageHistory.Length - 1;i++ )
			MessageHistory[i] = MessageHistory[i + 1];
		MessageHistory[MessageHistory.Length - 1] = Message;
	}
	return False;
}

exec function SetPaperCheck(bool bSet)
{
	NoCheckPapering = !bSet;
}

function bool ProcessBunchText(string Message)
{
	local float LST;
	local EPaperingType PaperingType;

	if ( NoCheckPapering )
		return False;

	LST = LastSyncTime;
	PaperingType = CheckPapering(Message);
	switch (PaperingType) 
	{
		case PT_None:
			bBlockPapering = False;
			break;
		case PT_TooFast:
			bBlockPapering = True;
			PaperingBlockCount++;
			if ( ChannelMgr != None )
				ChannelMgr.TextPool.AddMessage(Localize("Information","TextInputTooFast","Sephiroth"),
					class'Canvas'.Static.MakeColor(255,255,0),
					12,4,2,False,0,0,"",True,
					class'Canvas'.Static.MakeColor(0,0,0),
					2);
			AverageSyncSeconds = 1.2 / SyncCountPerSecond;
			break;
		case PT_History:
			bBlockPapering = True;
			PaperingBlockCount++;
			if ( ChannelMgr != None )
				ChannelMgr.TextPool.AddMessage(Localize("Information","TextInputAlreadyExist","Sephiroth"),
					class'Canvas'.Static.MakeColor(255,255,0),
					12,4,2,False,0,0,"",True,
					class'Canvas'.Static.MakeColor(0,0,0),
					2);
			AverageSyncSeconds = 1.2 / SyncCountPerSecond;
			break;
	}
	return bBlockPapering;
}

exec function PetLevelUp(int Count)
{
	local int i;
	for ( i = 0;i < Count;i++ ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiTell(0, "\\\\PetLevelUp");
	}
}

function StartDialogSession(string Other, string Message)
{
	DialogSession = CDialogSession(AddInterface("SephirothUI.CDialogSession"));
	if ( DialogSession != None ) 
	{
		DialogSession.InitDialog(Other, Message);
		DialogSession.ShowInterface();
	}
}

function FinishDialogSession()
{
	if ( DialogSession != None ) 
	{
		DialogSession.HideInterface();
		RemoveInterface(DialogSession);
		DialogSession = None;
	}
}

function OpenUserReport(string Message)
{
	local CUserReportHelp reporthelp;

	reporthelp = class'CUserReportHelp'.Static.Show(Self, IDD_USERREPORTHELP);
	ReportText = Message;
}

exec function ToggleDamage(bool bShow)
{
	if ( SephirothPlayer(PlayerOwner).DamageInteractor != None ) 
	{
		SephirothPlayer(PlayerOwner).DamageInteractor.bVisible = bShow;
		SephirothPlayer(PlayerOwner).DamageInteractor.bActive = bShow;
	}
}

function OnPlayerJustDead()
{
	SephirothController(Controller).OnActorOut(PlayerOwner.Pawn);
}

/*!@
	SephirothInterface::PointCheck
	2004.1.28, jhjung
	������ ���� ��, ĳ���Ͱ� �̵����� �ʵ��� ó���ϱ� ���Ͽ� ���������.
	�ݵ�� Desktop�� PointCheck�� ȣ�����־�� ��.
*/
function bool PointCheck()
{
	if( bInputValidRegionOn )
	{
	//�ش� ���� �� �ٸ� ���콺 �̺�Ʈ�� ��� �����ϵ��� �մϴ�.
		if( !IsCursorInsideAt(InputValidRegion_left,InputValidRegion_top,InputValidRegion_width,InputValidregion_height) )
		{
            //�ش翵������ ��� ����.
			return True;
		}

	}
	if ( bShowStat && IsCursorInsideAt(StatX, StatY, 32, 32) )
		return True;

	return Super.PointCheck();
}

/*!@
	SephirothInterface::CacheHotkey
	2004.1.28, jhjung
	��Ű������ ĳ���ϴ� �Լ�.
	ĳ����, configuration�� �����Ѵ�.
*/
function CacheHotkey(string InTypeName, string InModelName)
{
	local int i;
	local bool bFound;
	local ItemNamePair Pair;

	if ( InTypeName != "" && InModelName != "" ) 
	{
		for ( i = 0;i < ItemNamePairs.Length;i++ ) 
		{
			if ( ItemNamePairs[i].TypeName == InTypeName ) 
			{
				bFound = True;
				break;
			}
		}
		if ( !bFound ) 
		{
			Pair.TypeName = InTypeName;
			Pair.ModelName = InModelName;
			ItemNamePairs[ItemNamePairs.Length] = Pair;
		}
	}
}

/*!@
	SephirothInterface::GetHotkeyModelName
	2004.1.28, jhjung
	ĳ���� ������ ��Ű�� ���̸��� ����
	�κ��丮�� ���� �������� ��Ű�� ��ϵǾ� �ִ� ��쿡, ĳ���� ������ ���� ���̸� read
*/
function string GetHotkeyModelName(string InTypeName)
{
	local int i;
	for ( i = 0;i < ItemNamePairs.Length;i++ ) 
	{
		if ( ItemNamePairs[i].TypeName == InTypeName )
			return ItemNamePairs[i].ModelName;
	}
	return "";
}

//@by wj(040311)------
exec function Remodeling()
{
	//Log("=====>Remodeling");
	if( RemodelingUI == None )
		ShowRemodelingUI();
	else
		HideRemodelingUI();
}
//--------------------

//ksshim + 2004.8.23
function ChangeManaState()
{
	if( GaugeHud != None )
		GaugeHud.UpdateManaGauge();
	if( SimpleHud != None )
		SimpleHud.ChangeManaBar();
	if( m_PlayerInfo != None )
		m_PlayerInfo.ChangeManaBar();

}
//ksshim END

function OpenVanishedMenu()
{
	bVanished = True;
}

// keios - Ư�� client command
exec function ClientCommand(string command_str)
{
	local ClientCommandProcessor ccp;

	ccp = Spawn(class'ClientCommandProcessor');
	ccp.PlayerOwner = PlayerOwner;

	ccp.RunCommand(command_str);
}


// keios - HP������ update (����,�� ����)
function UpdateHPGauge()
{
	if( GaugeHud != None )
	{
		GaugeHud.UpdateHPGauge();
	}
	if( SimpleHud != None )
	{
		SimpleHud.UpdateHPGauge();
	}
	if( m_PlayerInfo != None )
	{
		m_PlayerInfo.UpdateHPGauge();
	}
}

// ������ ȿ�� �׽�Ʈ�� �Լ�
exec function UpdateHPGauge_Normal()
{
	SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect = 0;
	UpdateHPGauge();
}

exec function UpdateHPGauge_Poison()
{
	SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect = 1;
	UpdateHPGauge();
}

// test
exec function ObjectTest()
{

}

// test
exec function ClanBattleInfoAdd()
{
	ClanBattleInfo = CClanBattleInfo(AddInterface("SephirothUI.CClanBattleInfo"));
	if( ClanBattleInfo != None )
		ClanBattleInfo.ShowInterface();
}

// test
exec function ClanBattleInfoRemove()
{
	RemoveInterface(ClanBattleInfo);
}

// BattyeSystem Interface ����/����
function AddBattleInterface(string MatchName)
{
    //Log("AddBattleInterface");
	if( BattleInterface == None )
	{
		BattleInterface = CBattleInterface(AddInterface("SephirothUI.CBattleInterface"));
	}
	BattleInterface.SetMatchName(MatchName);	//MatchName�� ĳ���صд�. ĳ���������� �������� �ʴ´�.
	BattleInterface.ShowInterface();

    // Do Something Initialize
}

function RemoveBattleInterface()
{
    //Log("RemoveBattleInterface");
	if( BattleInterface != None )
	{
		Battleinterface.HideBattleInterfaces();
		BattleInterface.HideInterface();
		RemoveInterface(BattleInterface);
		BattleInterface = None;
	}
}

// TEST for ending effect of Battle System -Sinhyub 2009.12.30.
exec function BSEffect(int result)
{
	//Log("BattleSystem Ending Effect");
	//ShowTimeDisplayer();
//	ShowBattleWaitTimer("BST", 70);
	AddBattleInterface("STB");
	BattleInterface.ShowBattleEndingEffecter("BST", result);
}
// TEST for timer of Battle System -Sinhyub. 2009.1.6
exec function BSTimer(int time, string battle)
{
     //Log("BATTLENAME = "@battle);
	AddBattleInterface("STB");
	BattleInterface.ShowBattleWaitTimer(battle, time);
}
//TEST
exec function BSMESSAGE()
{
	//Log("BATTLE ENDING MESSAGE");
	AddBattleInterface("STB");
	BattleInterface.ShowBattleQuitMessage("STB", 30);
}
//TEST
exec function BSSCORE(int A, int B)
{
    //Log("BSSCORE A:"$A@" B:"$B);
	AddBattleInterface("STB");
	BattleInterface.ShowBattleScore();
	BattleInterface.UpdateBattleScore(A,B);
}

exec function BSSCORE2()
{
	AddBattleInterface("STB");
	BattleInterface.HideBattleScore();
}
//TEST
exec function BSLIST(int distributer)
{
/*	static int Distributer_b;
    if(distributer == 0)
    {
    	Distributer_B = (Distributer_B++)%4 +1;
		distributer = Distributer_B;
   	}
*/
	AddBattleInterface("STB");
	if( BattleInterface.BattleMessage == None )
		BattleInterface.ShowBattleMessage();
	switch(distributer)
	{
		case 1:
			BattleInterface.UpdateBattleMessage("������","BlackCat","ȭ��Ʈ�̱�","WhiteEagle");
			break;
		case 2:
			BattleInterface.UpdateBattleMessage("ȭ��Ʈ�̱�","WhiteEagle","������","BlackCat");
			break;
		case 3:
			BattleInterface.UpdateBattleMessage("�ȴٸ�","BlackCat","��¿","WhiteEagle");
			break;
		case 4:
			BattleInterface.UpdateBattleMessage("�׷���","BlackCat","�׾��","WhiteEagle");
			break;
		default :
			BattleInterface.UpdateBattleMessage("�׷���","BlackCat","�׾��","WhiteEagle");
			break;

	}
}
//TEST
exec function BSInterface()
{
	AddBattleInterface("STB");
	BSScore(12,5);
	BSList(1);
	BSTimer(65, "STB");
	BSMessage();
	BSEffect(1);
}
//TEST
exec function BSShake(int x_, int y_, int z_, int k_)
{
	local vector A;
	local vector B;

	A.X = 10;
	A.Y = 10;
	A.Z = 10;
	B.X = 100;
	B.Y = 100;
	B.Z = 100;
    //PlayerOwner.ShakeView(20,100,A,300,B,200);
	PlayerOwner.ShakeView(A,A,2.0f,B,B,1.5f);
/*
	A.X=10000;
	A.Y=10000;
	A.Z=10000;
	B.X=10000;
	B.Y=10000;
	B.Z=10000;
    PlayerOwner.ShakeView(x_,y_,A,z_,B,k_);
	*/
}

exec function TestSubInven(int index, int Time)
{
	if( index == 0 )
		SephirothPlayer(PlayerOwner).Net.NotiCommand("Bag ArrangeSub0");
	else if(index == 1)
		SephirothPlayer(PlayerOwner).Net.NotiCommand("Bag ArrangeSub1");
	else if(index == 2)
		SephirothPlayer(PlayerOwner).Net.NotiCommand("Bag ArrangeSub2");
}

exec function TestShopButton()
{
	if( WebBrowser != None )
	{
		HideWebBrowser();
	}
	else
	{
		SephirothPlayer(PlayerOwner).Net.NotiRequestOtp(ConsoleCommand("GetAccountName"),string(SephirothPlayer(PlayerOwner).PSI.PlayName));
	}
}


function ShowPlayerEquip(PlayerServerInfo targetSI)
{
	if ( IPlayerEquip == None )
	{
		IPlayerEquip = CPlayerEquip(AddInterface("SephirothUI.CPlayerEquip"));
		IPlayerEquip.SetTargetInfo(targetSI);

		if ( IPlayerEquip != None )
			IPlayerEquip.ShowInterface();
	}
}


function HidePlayerEquip()
{
	local int i;

	if ( IPlayerEquip != None )
	{
		// �������� �����ִٸ� �ݾ��ְ�
		ItemCompareBox.SetInfo(None);
		
		for ( i = 0 ; i < 6 ; i++ )
			IPlayerEquip.TooltipBoxes[i].SetInfo(None);

		// ����â�� �ݴ´�.
		IPlayerEquip.HideInterface();
		RemoveInterface(IPlayerEquip);
		IPlayerEquip = None;
	}
}

defaultproperties
{
	bOnInGameShop=True
	ArialFont=Font'Arial.ArialBlack'
	GMSound=Sound'InterfaceSound.GMchat'
	TeamTellColor=(B=255,G=207,R=73,A=255)
	ClanTellColor=(B=180,G=255,A=255)
	PaperingProbeSeconds=3.000000
	PaperingBlockSeconds=1.000000
	PaperingBlockSecondsMax=64.000000
	PaperingBlockFactor=2.000000
	SyncCountPerSecond=0.670000
	HistoryProbeSeconds=5.000000
	InterfaceControllerClassName="SephirothUI.SephirothController"
	TextureResources(0)=(Package="UI",Path="Info.OnTopStatN",Style=STY_Alpha)
	TextureResources(1)=(Package="UI",Path="Info.OnTopStatO",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_Remodel",Path="Main.StatMF_SystemButton",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_Remodel",Path="Main.StatMF_SystemButton_B",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_Remodel",Path="Main.StatMF_SystemButton_A",Style=STY_Alpha)
	bHideAllComponets=True
}
