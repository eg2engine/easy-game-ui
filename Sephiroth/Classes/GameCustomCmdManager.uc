
class GameCustomCmdManager extends Object;

struct AdvSynthesisMenuItem
{
	var int Id;
	var string Title;
	var int ClassType;
	var string Desc;
	var int CanCraft;
	var string ItemClassName;
	var string ItemIcon;
};

struct AdvSynthesisDetailLine
{
	var string Title;
	var int NeedCount;
	var int Indent;
	var string Desc;
	var int CanCraft;
	var string ItemClassName;
	var string ItemIcon;
	var string NeedSource;
};

struct AdvSynthesisPreviewLine
{
	var string Title;
	var int NeedCount;
	var string Desc;
	var string ItemClassName;
	var string ItemIcon;
	var string NeedSource;
};


//自定义消息协议
var const int CMD_S2C_GameShop_Open;
var const int CMD_S2C_GameShop_UpdateGamePoint;
var const int CMD_S2C_GameShop_UpdatePaymentLink;

//其他信息
var const int CMD_S2C_EtcInfo_Update;
var const int CMD_C2S_EtcInfo_Update;

//战场信息
var const int CMD_S2C_Battle_NotiPlayerKillMessage;

//自定义UI信息
var const int CMD_S2C_CustomBrowser_Status;
var const int CMD_S2C_CustomBrowser_Content;


//物品
var const int CMD_C2S_ItemAddAttrSelect_Query;
var const int CMD_S2C_ItemAddAttrSelect_Open;
var const int CMD_S2C_Item_UpdateNumber;

//高级合成
var const int CMD_C2S_AdvancedSynthesis_RequestJobList;
var const int CMD_C2S_AdvancedSynthesis_RequestProductList;
var const int CMD_C2S_AdvancedSynthesis_RequestRecipeDetail;
var const int CMD_C2S_AdvancedSynthesis_RequestMakePreview;
var const int CMD_C2S_AdvancedSynthesis_Craft;
var const int CMD_S2C_AdvancedSynthesis_JobListBegin;
var const int CMD_S2C_AdvancedSynthesis_JobListItem;
var const int CMD_S2C_AdvancedSynthesis_JobListEnd;
var const int CMD_S2C_AdvancedSynthesis_ProductListBegin;
var const int CMD_S2C_AdvancedSynthesis_ProductListItem;
var const int CMD_S2C_AdvancedSynthesis_ProductListEnd;
var const int CMD_S2C_AdvancedSynthesis_DetailBegin;
var const int CMD_S2C_AdvancedSynthesis_DetailLine;
var const int CMD_S2C_AdvancedSynthesis_DetailEnd;
var const int CMD_S2C_AdvancedSynthesis_MakePreviewBegin;
var const int CMD_S2C_AdvancedSynthesis_MakePreviewLine;
var const int CMD_S2C_AdvancedSynthesis_MakePreviewEnd;
var const int CMD_S2C_AdvancedSynthesis_CraftResult;
var const int CMD_S2C_AdvancedSynthesis_UIState;
var const int CMD_S2C_AdvancedSynthesis_Open;

var array<AdvSynthesisMenuItem> AdvancedSynthesisJobs;
var array<AdvSynthesisMenuItem> AdvancedSynthesisProducts;
var array<AdvSynthesisDetailLine> AdvancedSynthesisDetailLines;
var array<AdvSynthesisPreviewLine> AdvancedSynthesisPreviewLines;
var int AdvancedSynthesisJobVersion;
var int AdvancedSynthesisProductVersion;
var int AdvancedSynthesisDetailVersion;
var int AdvancedSynthesisPreviewVersion;
var int AdvancedSynthesisCraftResultVersion;
var int AdvancedSynthesisUIStateVersion;
var string AdvancedSynthesisJobTitle;
var string AdvancedSynthesisProductTitle;
var string AdvancedSynthesisDetailHeaderTitle;
var string AdvancedSynthesisDetailProductTitle;
var string AdvancedSynthesisDetailDesc;
var string AdvancedSynthesisPreviewHeaderTitle;
var string AdvancedSynthesisPreviewTargetTitle;
var string AdvancedSynthesisPreviewDesc;
var string AdvancedSynthesisPreviewItemClassName;
var string AdvancedSynthesisPreviewItemIcon;
var int AdvancedSynthesisCraftResultCode;
var int AdvancedSynthesisCraftResultCount;
var string AdvancedSynthesisCraftResultTarget;
var string AdvancedSynthesisCraftResultMessage;
var bool AdvancedSynthesisUIVisible;
var int AdvancedSynthesisUIReasonCode;
var string AdvancedSynthesisUIMessageTitle;
var string AdvancedSynthesisUIMessage;


function DebugLog(string message)
{
	GameManager(Outer).PlayerOwner.myHud.AddMessage(2,"DebugLog GameCustomCmdManager: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}


function CustomMessage_CMD_S2C_GameShop_Open(int parm1, int parm2, string body)
{
	GameManager(Outer).GameShopManager.NetCustomRecv_OnOpenShop(parm1, parm2, body);
}

function CustomMessage_CMD_S2C_GameShop_UpdateGamePoint(int parm1, int parm2, string body)
{
	GameManager(Outer).GameShopManager.NetCustomRecv_UpdateGamePoint(parm1, parm2, body);
}

function CustomMessage_CMD_S2C_GameShop_UpdatePaymentLink(int parm1, int parm2, string body)
{
	GameManager(Outer).GameShopManager.NetCustomRecv_UpdatePaymentLink(parm1, parm2, body);
}

function CustomMessage_CMD_S2C_EtcInfo_Update(int parm1, int parm2, string body)
{
	GameManager(Outer).EtcInfoManager.NetCustomRecv_OnUpdate(parm1, parm2, body);
}

function CustomMessage_CMD_S2C_Battle_NotiPlayerKillMessage(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	//DebugLog(body);

	Split(body, "$", ItemDatas);

	if	( ItemDatas.Length < 4 )
		return;

	GameManager(Outer).PlayerOwner.BattleNotiPlayerKillMessage(ItemDatas[0], ItemDatas[1], ItemDatas[2], ItemDatas[3]);
}


function CustomMessage_CMD_S2C_CustomBrowser_Status(int parm1, int parm2, string body)
{
	local bool bVisible;
	if( parm1 == 1 )
		bVisible = True;
	else
		bVisible = False;

	GameManager(Outer).PlayerOwner.SetCustomBrowserVisible(bVisible);
}

function CustomMessage_CMD_S2C_CustomBrowser_Content(int parm1, int parm2, string body)
{
	GameManager(Outer).PlayerOwner.SetCustomBrowserContent(body);
}

function CustomMessage_CMD_S2C_ItemAddAttrSelect_Open(int parm1, int parm2, string body)
{
	GameManager(Outer).PlayerOwner.OnItemAddAttrSelectOpen(body);
}

function CustomMessage_CMD_S2C_Item_UpdateNumber(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	Split(body, "$", ItemDatas);

	if (ItemDatas.Length < 4)
		return;

	// ItemDatas[0]=背包编号  ItemDatas[1]=X  ItemDatas[2]=Y  ItemDatas[3]=新数量
	GameManager(Outer).PlayerOwner.PSI.UpdateItemAmountByPos(int(ItemDatas[0]), int(ItemDatas[1]), int(ItemDatas[2]), int(ItemDatas[3]));
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_JobListBegin(int parm1, int parm2, string body)
{
	AdvancedSynthesisJobs.Remove(0, AdvancedSynthesisJobs.Length);
	AdvancedSynthesisJobTitle = body;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_JobListItem(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;
	local int Index;

	Split(body, "$", ItemDatas);
	if (ItemDatas.Length < 4)
		return;

	Index = AdvancedSynthesisJobs.Length;
	AdvancedSynthesisJobs.Length = Index + 1;
	AdvancedSynthesisJobs[Index].Id = int(ItemDatas[0]);
	AdvancedSynthesisJobs[Index].Title = ItemDatas[1];
	AdvancedSynthesisJobs[Index].ClassType = int(ItemDatas[2]);
	AdvancedSynthesisJobs[Index].Desc = ItemDatas[3];
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_JobListEnd(int parm1, int parm2, string body)
{
	++AdvancedSynthesisJobVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListBegin(int parm1, int parm2, string body)
{
	AdvancedSynthesisProducts.Remove(0, AdvancedSynthesisProducts.Length);
	AdvancedSynthesisProductTitle = body;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListItem(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;
	local int Index;

	Split(body, "$", ItemDatas);
	if (ItemDatas.Length < 6)
		return;

	Index = AdvancedSynthesisProducts.Length;
	AdvancedSynthesisProducts.Length = Index + 1;
	AdvancedSynthesisProducts[Index].Id = int(ItemDatas[0]);
	AdvancedSynthesisProducts[Index].Title = ItemDatas[1];
	AdvancedSynthesisProducts[Index].Desc = ItemDatas[2];
	AdvancedSynthesisProducts[Index].CanCraft = int(ItemDatas[3]);
	AdvancedSynthesisProducts[Index].ItemClassName = ItemDatas[4];
	AdvancedSynthesisProducts[Index].ItemIcon = ItemDatas[5];
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListEnd(int parm1, int parm2, string body)
{
	++AdvancedSynthesisProductVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_DetailBegin(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	AdvancedSynthesisDetailLines.Remove(0, AdvancedSynthesisDetailLines.Length);
	Split(body, "$", ItemDatas);
	if (ItemDatas.Length >= 3)
	{
		AdvancedSynthesisDetailHeaderTitle = ItemDatas[0];
		AdvancedSynthesisDetailProductTitle = ItemDatas[1];
		AdvancedSynthesisDetailDesc = ItemDatas[2];
	}
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_DetailLine(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;
	local int Index;

	Split(body, "$", ItemDatas);
	if (ItemDatas.Length < 7)
		return;

	Index = AdvancedSynthesisDetailLines.Length;
	AdvancedSynthesisDetailLines.Length = Index + 1;
	AdvancedSynthesisDetailLines[Index].Title = ItemDatas[0];
	AdvancedSynthesisDetailLines[Index].NeedCount = int(ItemDatas[1]);
	AdvancedSynthesisDetailLines[Index].Indent = int(ItemDatas[2]);
	AdvancedSynthesisDetailLines[Index].Desc = ItemDatas[3];
	AdvancedSynthesisDetailLines[Index].CanCraft = int(ItemDatas[4]);
	AdvancedSynthesisDetailLines[Index].ItemClassName = ItemDatas[5];
	AdvancedSynthesisDetailLines[Index].ItemIcon = ItemDatas[6];
	if (ItemDatas.Length >= 8)
		AdvancedSynthesisDetailLines[Index].NeedSource = ItemDatas[7];
	else
		AdvancedSynthesisDetailLines[Index].NeedSource = "bag";
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_DetailEnd(int parm1, int parm2, string body)
{
	++AdvancedSynthesisDetailVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewBegin(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	AdvancedSynthesisPreviewLines.Remove(0, AdvancedSynthesisPreviewLines.Length);
	Split(body, "$", ItemDatas);
	if (ItemDatas.Length >= 6)
	{
		AdvancedSynthesisPreviewHeaderTitle = ItemDatas[0];
		AdvancedSynthesisPreviewTargetTitle = ItemDatas[1];
		AdvancedSynthesisPreviewDesc = ItemDatas[2];
		AdvancedSynthesisPreviewItemClassName = ItemDatas[4];
		AdvancedSynthesisPreviewItemIcon = ItemDatas[5];
	}
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewLine(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;
	local int Index;

	Split(body, "$", ItemDatas);
	if (ItemDatas.Length < 5)
		return;

	Index = AdvancedSynthesisPreviewLines.Length;
	AdvancedSynthesisPreviewLines.Length = Index + 1;
	AdvancedSynthesisPreviewLines[Index].Title = ItemDatas[0];
	AdvancedSynthesisPreviewLines[Index].NeedCount = int(ItemDatas[1]);
	AdvancedSynthesisPreviewLines[Index].Desc = ItemDatas[2];
	AdvancedSynthesisPreviewLines[Index].ItemClassName = ItemDatas[3];
	AdvancedSynthesisPreviewLines[Index].ItemIcon = ItemDatas[4];
	if (ItemDatas.Length >= 6)
		AdvancedSynthesisPreviewLines[Index].NeedSource = ItemDatas[5];
	else
		AdvancedSynthesisPreviewLines[Index].NeedSource = "bag";
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewEnd(int parm1, int parm2, string body)
{
	++AdvancedSynthesisPreviewVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_CraftResult(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	Split(body, "$", ItemDatas);
	AdvancedSynthesisCraftResultCode = parm1;
	AdvancedSynthesisCraftResultCount = parm2;
	if (ItemDatas.Length >= 2)
	{
		AdvancedSynthesisCraftResultTarget = ItemDatas[0];
		AdvancedSynthesisCraftResultMessage = ItemDatas[1];
	}
	++AdvancedSynthesisCraftResultVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_UIState(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	Split(body, "$", ItemDatas);
	if (parm1 == 1)
		AdvancedSynthesisUIVisible = True;
	else
		AdvancedSynthesisUIVisible = False;
	AdvancedSynthesisUIReasonCode = parm2;
	if (ItemDatas.Length >= 2)
	{
		AdvancedSynthesisUIMessageTitle = ItemDatas[0];
		AdvancedSynthesisUIMessage = ItemDatas[1];
	}
	++AdvancedSynthesisUIStateVersion;
}

function CustomMessage_CMD_S2C_AdvancedSynthesis_Open(int parm1, int parm2, string body)
{
	CustomMessage_CMD_S2C_AdvancedSynthesis_UIState(1, parm2, body);

	if (GameManager(Outer) != None && GameManager(Outer).PlayerOwner != None)
		GameManager(Outer).PlayerOwner.OnSmithDlg();
}

function bool HandleReceivedCustomMessage(int puslCmd, int cmd, int parm1, int parm2, string body)
{

    //GameManager(Outer).PlayerOwner.myHud.AddMessage(2,"Debug HandleReceivedCustomMessage Sucess : "@puslCmd @cmd @parm1 @parm2 @body,class'Canvas'.static.MakeColor(128,255,255));

	switch(cmd)
	{
		case CMD_S2C_GameShop_Open:
			CustomMessage_CMD_S2C_GameShop_Open(parm1, parm2, body);
			return True;
		case CMD_S2C_GameShop_UpdateGamePoint:
			CustomMessage_CMD_S2C_GameShop_UpdateGamePoint(parm1, parm2, body);
			return True;
		case CMD_S2C_GameShop_UpdatePaymentLink:
			CustomMessage_CMD_S2C_GameShop_UpdatePaymentLink(parm1, parm2, body);
			return True;
		case CMD_S2C_EtcInfo_Update:
			CustomMessage_CMD_S2C_EtcInfo_Update(parm1, parm2, body);
			return True;
		case CMD_S2C_Battle_NotiPlayerKillMessage:
			CustomMessage_CMD_S2C_Battle_NotiPlayerKillMessage(parm1, parm2, body);
			return True;
		case CMD_S2C_CustomBrowser_Status:
			CustomMessage_CMD_S2C_CustomBrowser_Status(parm1, parm2, body);
			return True;
		case CMD_S2C_CustomBrowser_Content:
			CustomMessage_CMD_S2C_CustomBrowser_Content(parm1, parm2, body);
			return True;
		case CMD_S2C_ItemAddAttrSelect_Open:
			CustomMessage_CMD_S2C_ItemAddAttrSelect_Open(parm1, parm2, body);
			return True;
		case CMD_S2C_Item_UpdateNumber:
			CustomMessage_CMD_S2C_Item_UpdateNumber(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_JobListBegin:
			CustomMessage_CMD_S2C_AdvancedSynthesis_JobListBegin(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_JobListItem:
			CustomMessage_CMD_S2C_AdvancedSynthesis_JobListItem(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_JobListEnd:
			CustomMessage_CMD_S2C_AdvancedSynthesis_JobListEnd(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_ProductListBegin:
			CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListBegin(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_ProductListItem:
			CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListItem(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_ProductListEnd:
			CustomMessage_CMD_S2C_AdvancedSynthesis_ProductListEnd(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_DetailBegin:
			CustomMessage_CMD_S2C_AdvancedSynthesis_DetailBegin(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_DetailLine:
			CustomMessage_CMD_S2C_AdvancedSynthesis_DetailLine(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_DetailEnd:
			CustomMessage_CMD_S2C_AdvancedSynthesis_DetailEnd(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_MakePreviewBegin:
			CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewBegin(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_MakePreviewLine:
			CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewLine(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_MakePreviewEnd:
			CustomMessage_CMD_S2C_AdvancedSynthesis_MakePreviewEnd(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_CraftResult:
			CustomMessage_CMD_S2C_AdvancedSynthesis_CraftResult(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_UIState:
			CustomMessage_CMD_S2C_AdvancedSynthesis_UIState(parm1, parm2, body);
			return True;
		case CMD_S2C_AdvancedSynthesis_Open:
			CustomMessage_CMD_S2C_AdvancedSynthesis_Open(parm1, parm2, body);
			return True;
		default:
			break;
	}

	return False;
}


function bool Handle(string data)
{

	local string Prefix;
	local array<string> Datas;

	Prefix = "/GAME_S2C_CUSTOM_CMD";

	//GameManager(Outer).PlayerOwner.myHud.AddMessage(2,"Debug GameCustomCmdManager Handle Len: "@Len(data)@Left(data, 16),class'Canvas'.Static.MakeColor(128,255,255));

	if ( Len(data) < Len(Prefix) || Left(Caps(data), Len(Prefix)) != Caps(Prefix) )
		return False; 

	//GameManager(Outer).PlayerOwner.myHud.AddMessage(1,"Debug GameCustomCmdManager Sucess : "@data,class'Canvas'.Static.MakeColor(128,255,255));

	Split(data, "#", Datas);
	if( Datas.Length < 6 )
		return False;

	return HandleReceivedCustomMessage(int(Datas[1]), int(Datas[2]), int(Datas[3]), int(Datas[4]), Datas[5]);
}

function NetNotiCustom(int cmd, int param1, int param2, string body)
{
	GameManager(Outer).PlayerOwner.Net.NotiCommand("/GAME_C2S_CUSTOM_CMD "@cmd@" "@param1@" "@param2@" "@body);
}


defaultproperties
{
	CMD_S2C_GameShop_Open=100001
	CMD_S2C_GameShop_UpdateGamePoint=100002
	CMD_S2C_GameShop_UpdatePaymentLink=100003
	
	CMD_S2C_EtcInfo_Update=10020
	CMD_C2S_EtcInfo_Update=20020


	CMD_S2C_Battle_NotiPlayerKillMessage=10040

	CMD_S2C_CustomBrowser_Status=10060
	CMD_S2C_CustomBrowser_Content=10061


	CMD_C2S_ItemAddAttrSelect_Query=200130
	CMD_S2C_ItemAddAttrSelect_Open=100135
	CMD_S2C_Item_UpdateNumber=100080

	CMD_C2S_AdvancedSynthesis_RequestJobList=200120
	CMD_C2S_AdvancedSynthesis_RequestProductList=200121
	CMD_C2S_AdvancedSynthesis_RequestRecipeDetail=200122
	CMD_C2S_AdvancedSynthesis_RequestMakePreview=200123
	CMD_C2S_AdvancedSynthesis_Craft=200124
	CMD_S2C_AdvancedSynthesis_JobListBegin=100120
	CMD_S2C_AdvancedSynthesis_JobListItem=100121
	CMD_S2C_AdvancedSynthesis_JobListEnd=100122
	CMD_S2C_AdvancedSynthesis_ProductListBegin=100123
	CMD_S2C_AdvancedSynthesis_ProductListItem=100124
	CMD_S2C_AdvancedSynthesis_ProductListEnd=100125
	CMD_S2C_AdvancedSynthesis_DetailBegin=100126
	CMD_S2C_AdvancedSynthesis_DetailLine=100127
	CMD_S2C_AdvancedSynthesis_DetailEnd=100128
	CMD_S2C_AdvancedSynthesis_MakePreviewBegin=100129
	CMD_S2C_AdvancedSynthesis_MakePreviewLine=100130
	CMD_S2C_AdvancedSynthesis_MakePreviewEnd=100131
	CMD_S2C_AdvancedSynthesis_CraftResult=100132
	CMD_S2C_AdvancedSynthesis_UIState=100133
	CMD_S2C_AdvancedSynthesis_Open=100134
}
