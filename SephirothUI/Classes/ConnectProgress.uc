class ConnectProgress extends CInterface;

const BN_Settlement = 1;
const BN_Retry = 2;
const BN_Close = 3;

var string UserName,Password;
var string Launching;

var float CurrentTime,LimitTime;

var string ConnectResult, LoginResult;

var ConstantColor BackgroundColor;
var FinalBlend BackgroundBlend;

//add neive : �ܺ� ��Ī �ε��� ------------------------------------------------
var int LaunchingIndex;
const PCheckNo = 10000;
const MaxLaunchingNo = 100;

var bool bDelayConnect;		// Add ssemp : 2011/07/12 �α��� ���� ����

enum eLaunching
{
	Imazic,
	GameLamp, //add neive : ���ӷ���
	Club5678, //add neive : Ŭ��5678
	SantaGame, //add neive : ��Ÿ����
};
//-----------------------------------------------------------------------------

function OnInit()
{
//	SetComponentTextureId(Components[0],0,2,1);
//	SetComponentNotify(Components[0],BN_Settlement,Self);
	SetComponentTextureId(Components[1],0,2,1);
	SetComponentNotify(Components[1],BN_Retry,Self);
//	SetComponentTextureId(Components[2],0,2,1); //del neive : ������õ� ȭ�鿡�� �ݱ� ����
//	SetComponentNotify(Components[2],BN_Close,Self);
}

function Layout(Canvas C)
{
	local int i;

	MoveComponent(Components[0],true,(C.ClipX-Components[0].XL)/2,C.ClipY/2+80);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_Escape && Action == IST_Press) {
		if (CurrentTime > 0 && CurrentTime <= LimitTime)
			ConsoleCommand("CANCELCONNECT");
		Parent.NotifyInterface(Self,INT_Close);
		return true;
	}
	else if (Key == IK_Enter && Action == IST_Press) {
		if (LoginResult != "")
			RetryConnect();
	}
}

function NotifyComponent(int ComponentId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Retry:
		Parent.NotifyInterface(Self,INT_Close);
		break;

//	case BN_Close:
//		Parent.NotifyInterface(Self,INT_Command,"Quit");
//		break;
	}
}

function RetryConnect()
{
	Parent.NotifyInterface(Self, INT_Command, "GotoLobby");
//	if (CurrentTime > 0 && CurrentTime <= LimitTime)
//		ConsoleCommand("CANCELCONNECT");
//	Connect();
}

function ShowInterface()
{
	Super.ShowInterface();
	Connect();
}

function string ConvertSpaceToUnderbar(string UserID)
{
	local int i;
	local string sTemp;

	if(InStr(UserID, " ") == -1)
		return UserID;

	sTemp = "";

	for(i=0; i<Len(UserID); i++)
	{
		//Log("neive : check ID : " $ Mid(UserID, i, 1));
		if(" " != Mid(UserID, i, 1))
			sTemp = sTemp $ Mid(UserID, i, 1);
		else
			sTemp = sTemp $ "_";
	}
	
	return sTemp;
}

function Connect()
{
	local string ConnectCommand;
	local string ServerHost;
	local int ServerPort;

	CurrentTime = 0;
	LimitTime = Default.LimitTime;
	ConnectResult = "";
	LoginResult = "";

	//ConsoleCommand("IsLoginSepGame");

	Game_Login(Level.Game).GameServerInfo(ServerHost,ServerPort);
	
	//add neive : �̱� ������ ���� _ ó�� ---------------------------------
	//UserName = ConvertSpaceToUnderbar(UserName);
	//Log("neive : check Final User ID : " $ UserName);
	//-------------------------------------------------------------------------

	//add neive : �ܺ� ��Ī ---------------------------------------------------
	if(ServerPort > PCheckNo)
	{
		LaunchingIndex = ServerPort % MaxLaunchingNo;
		//PlayerOwner.LaunchingIndex = LaunchingIndex;
		//SepPlayerController(PlayerOwner).LaunchingIndex = LaunchingIndex;
		PlayerOwner.LaunchingIndex = LaunchingIndex;
		ServerPort = ServerPort / MaxLaunchingNo;
	}

	if(LaunchingIndex == 1) // ���ӷ���
	{
		UserName = "c21_" $ UserName;	
		ConnectCommand = "CONNECT HOST="$ServerHost$" PORT="$ServerPort$" USER="$UserName $" PASSWORD="$Password; // ���ӷ���
	}
	else if(LaunchingIndex == 2) // Ŭ��5678
	{
		UserName = "c22_" $ UserName;
		ConnectCommand = "CONNECT HOST="$ServerHost$" PORT="$ServerPort$" USER="$UserName $" PASSWORD="$Password; // Ŭ��5678
	}
	else if(LaunchingIndex == 3) // ��Ÿ����
	{
		UserName = "c23_" $ UserName;
		ConnectCommand = "CONNECT HOST="$ServerHost$" PORT="$ServerPort$" USER="$UserName $" PASSWORD="$Password; // Ŭ��5678
	}
	else if(LaunchingIndex == 4) // Gamepass
	{
		UserName = "c24_" $ UserName;
		ConnectCommand = "CONNECT HOST="$ServerHost$" PORT="$ServerPort$" USER="$UserName $" PASSWORD="$Password; // Ŭ��5678
	}
	else                    // Imazic
		ConnectCommand = "CONNECT HOST="$ServerHost$" PORT="$ServerPort$" USER="$UserName$" PASSWORD="$Password;
	//-------------------------------------------------------------------------

	//ConnectResult = "";
	//Log("TEST Consolcomm"@ConnectCommand);
	ConnectCommand @= "DELAYCONNECT="$bDelayConnect;
	ConnectResult = PlayerOwner.ConsoleCommand(ConnectCommand);
	if (ConnectResult == "Success")
		Parent.NotifyInterface(Self,INT_Close);
}

function ConnectTick(float Current,float Limit)
{
	CurrentTime = Current;
	LimitTime = Limit;
}

function OnPreRender(Canvas C)
{
	C.SetDrawColor(255,255,255);
	C.SetPos(C.ClipX/2-150,C.ClipY/2+10);
	DrawBox(C,300,16,1);
	if (CurrentTime > 0 && CurrentTime <= LimitTime) {
		C.SetPos(C.ClipX/2-150+2,C.ClipY/2+10+2);
		C.SetDrawColor(211,158,112);
		C.DrawTile(Controller.BackgroundColor,(CurrentTime/LimitTime)*298.0,14,0,0,0,0);
		C.SetDrawColor(255,255,255);
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.DrawKoreanText(string(int(CurrentTime))$"sec / "$int(LimitTime)$"sec",C.ClipX/2-150+2,C.ClipY/2+10+2,298,14);
	}

	C.SetDrawColor(255,255,255);
//	EnableComponent(Components[0],LoginFailReason == 67 || LoginFailReason == 68);
		// 67: RSExpiredUser
	EnableComponent(Components[1],LoginResult != "");
	if( Components.Length >= 2 )
	{
		if ( LoginResult != "" ) 
			SetComponentText(Components[2],"Close");
		else
			SetComponentText(Components[2],"Cancel");
	}

	if (ConnectResult != "") {
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.DrawKoreanText(ConnectResult,C.ClipX/2-150+2,C.ClipY/2-10,298,14);
	}
	if (LoginResult != "") {
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.DrawKoreanText(LoginResult,0,C.ClipY/2+40,C.ClipX,20);
	}
}

defaultproperties
{
     LimitTime=60.000000
     Components(0)=(Type=RES_PushButton,XL=126.000000,YL=22.000000,TextAlign=TA_MiddleCenter)
     Components(1)=(Id=1,Caption="Reconnect",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotDir=PVT_Down,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2009",Path="BTN02_04_N",Style=STY_Normal)
     TextureResources(1)=(Package="UI_2009",Path="BTN02_04_P",Style=STY_Normal)
     TextureResources(2)=(Package="UI_2009",Path="BTN02_04_D",Style=STY_Normal)
}
