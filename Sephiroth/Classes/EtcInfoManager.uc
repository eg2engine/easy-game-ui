class EtcInfoManager extends Object;


var string Param1;
var string Param2;
var string Param3;
var string Param4;
var string Param5;
var string Param6;
var string Param7;
var string Param8;
var string Param9;
var string Param10;
var string Param11;
var string Param12;
var string Param13;
var string Param14;



var GameCustomCmdManager CustomCmd;

function NetNotiOpenEtcInfo()
{
	if( CustomCmd == None )
		CustomCmd = GameManager(Outer).GameCustomCmdManager;

	CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_EtcInfo_Update, 0, 0, "");
}


function NetCustomRecv_OnUpdate(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;

	//GameManager(Outer).PlayerOwner.myHud.AddMessage(1,"Debug NetCustomRecv_OnUpdate Sucess : "@body,class'Canvas'.static.MakeColor(128,255,255));
	Split(body, "$", ItemDatas);

	if	( ItemDatas.Length < 14 )
		return;

	Param1 = ItemDatas[0];
	Param2 = ItemDatas[1];
	Param3 = ItemDatas[2];
	Param4 = ItemDatas[3];
	Param5 = ItemDatas[4];
	Param6 = ItemDatas[5];
	Param7 = ItemDatas[6];
	Param8 = ItemDatas[7];
	Param9 = ItemDatas[8];
	Param10 = ItemDatas[9];
	Param11 = ItemDatas[10];
	Param12 = ItemDatas[11];
	Param13 = ItemDatas[12];
	Param14 = ItemDatas[13];
}