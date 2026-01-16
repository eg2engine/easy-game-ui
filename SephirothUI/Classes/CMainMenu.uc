class CMainMenu extends CInterface;

const BN_Help = 1;
const BN_OpScreen = 2;
const BN_OpSound = 3;
const BN_OpGame = 4;
const BN_OpControl = 5;
const BN_Lobby = 6;
const BN_Quit = 7;

//Component ID(index) 2009.10.30.Sinhyub
const IDC_HELP = 2;
const IDC_SCREEN = 3;
const IDC_SOUND = 4;
const IDC_GAME = 5;
const IDC_CONTROL = 6;
const IDC_LOBBY = 7;
const IDC_QUIT = 8;

//const BN_WebShop = 4;

function OnInit()
{
	SetComponentTextureId(Components[IDC_HELP],1,-1,3,2);
	SetComponentTextureId(Components[IDC_SCREEN],1,-1,3,2);
	SetComponentTextureId(Components[IDC_SOUND],1,-1,3,2);
	SetComponentTextureId(Components[IDC_GAME],1,-1,3,2);
	SetComponentTextureId(Components[IDC_CONTROL],1,-1,3,2);
	SetComponentTextureId(Components[IDC_LOBBY],1,-1,3,2);
	SetComponentTextureId(Components[IDC_QUIT],1,-1,3,2);

//	SetComponentTextureId(Components[4],2,-1,-1,3); //add neive : 웹상점 버튼
//	SetComponentTextureId(Components[4],0,-1,-1,1); //add neive : 테스터 게시판 버튼
	SetComponentNotify(Components[IDC_HELP],BN_Help,Self);
	SetComponentNotify(Components[IDC_SCREEN],BN_OpScreen,Self);
	SetComponentNotify(Components[IDC_SOUND],BN_OpSound,Self);
	SetComponentNotify(Components[IDC_GAME],BN_OpGame,Self);
	SetComponentNotify(Components[IDC_CONTROL],BN_OpControl,Self);
	SetComponentNotify(Components[IDC_LOBBY],BN_Lobby,Self);
	SetComponentNotify(Components[IDC_QUIT],BN_Quit,Self);
//	SetComponentnotify(Components[4],BN_WebShop,Self); //add neive : 웹상점 버튼


}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,(C.ClipX-WinWidth)/2,(C.ClipY-WinHeight)/2);
	for(i=1; i<Components.Length;i++)
		MoveComponentId(i);
	//MoveComponentId(4); //add neive : 웹상점 버튼
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Parent.NotifyInterface(Self, INT_Close);
	switch(NotifyId) {
	case BN_Help:
		Parent.NotifyInterface(Self, INT_Command, "Help");
		break;
	case BN_OpScreen:
		Parent.NotifyInterface(Self, INT_Command, "OptionScreen");
		break;
	case BN_OpSound:
		Parent.NotifyInterface(Self, INT_Command, "OptionSound");
		break;
	case BN_OpGame:
		Parent.NotifyInterface(Self, INT_Command, "OptionGame");
		break;
	case BN_OpControl:
		Parent.NotifyInterface(Self, INT_Command, "OptionControl");
		break;
	case BN_Lobby:
		Parent.NotifyInterface(Self, INT_Close);
		Parent.NotifyInterface(Self, INT_Command, "GotoLobby");
		break;
	case BN_Quit:
		Parent.NotifyInterface(Self, INT_Command, "Quit");
		break;

	//add neive : 웹상점 버튼 -------------------------------------------------
//	case BN_WebShop:
//		Parent.NotifyInterface(Self, INT_Command, "GoWebShop"); //SephirothInterface.uc 의 notify 에 GoWebShop 으로..
		//Parent.NotifyInterface(Self, INT_Command, "GoWebShop"); //SephirothInterface.uc 의 notify 에 GoWebShop 으로..
//		break;
	//-------------------------------------------------------------------------
	}
}

	

defaultproperties
{
     Components(0)=(XL=160.000000,YL=200.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=160.000000,YL=200.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Caption="Help",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=24.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(3)=(Id=3,Caption="OptionScreen",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(4)=(Id=4,Caption="OptionSound",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(5)=(Id=5,Caption="OptionGame",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(6)=(Id=6,Caption="OptionControl",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(7)=(Id=7,Caption="GotoLobby",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     Components(8)=(Id=8,Caption="QuitGame",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="GameMenu")
     TextureResources(0)=(Package="UI_2009",Path="WIN12",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN02_04_N",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN02_04_O",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="BTN02_04_P",Style=STY_Alpha)
     WinWidth=160.000000
     WinHeight=200.000000
}
