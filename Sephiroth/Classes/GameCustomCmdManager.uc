
class GameCustomCmdManager extends Object;


//自定义消息协议
var const int CMD_S2C_GameShop_Open;
var const int CMD_S2C_GameShop_UpdateGamePoint;
var const int CMD_S2C_GameShop_UpdatePaymentLink;

//其他信息
var const int CMD_S2C_EtcInfo_Update;
var const int CMD_C2S_EtcInfo_Update;

//战场信息
var const int CMD_S2C_Battle_NotiPlayerKillMessage;



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
}