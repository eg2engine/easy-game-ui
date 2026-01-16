class PageGame extends COptionPage;
/*	Setting Interface options	*/

var bool bShowTooltip;		//1.툴팁
var bool bTraceCamera;		//2.카메라추적
var bool bShowNameAlways;	//4_1 이름표시 모두선택 (true) 4_2선택된 타겟(false)
var bool bShowNpcName;		//4_3 NPC
var bool bShowMonsterName;	//4_4 몬스터
var bool bShowItemName;		//4_5 아이템
var bool bListenPartyInvite;	//*.파티초대
var bool bListenPartyJoin;		//*.파티가입
var bool bListenClanInvite;		//5_1클랜초대
var bool bListenClanJoin;		//5_2클랜가입 
var bool bListenExchangeRequest;	//6.아이템교환 신청 자동거절
var bool bPinMinimap;				//7.미니맵 고정

var bool bListenMessage;	//8.채팅표시
var bool bListenShout;		//9.외치기표시
var bool bListenWhisper;	//10.귓속말 표시
var bool bListenTip;		//12.알리미
var bool bEraseMessage;		//13.자동삭제

var bool WalkState;
var bool DisArmState;

const CB_ShowName = 1;
const CB_ToggleTooltip = 2;	//
//const CB_ToggleCameraState = 3;
const CB_TogglePartyInvite = 3;
const CB_TogglePartyJoin = 4;
const CB_ToggleClanInvite = 5;
const CB_ToggleClanJoin = 6;
const CB_ToggleExchangeRequest = 7;
const CB_ShowNpcName = 8;
const CB_ShowMonsterName = 9;
const CB_ShowItemName = 10;

const CB_ListenMessage = 12;
const CB_ListenShout = 13;
const CB_ListenWhisper = 14;
const CB_ListenTip = 15;
const CB_EraseMessage = 16;

const PB_DefaultUI = 17;

/*End, From PageChatting.uc*/

function LoadOption()
{
	bShowTooltip = bool(ConsoleCommand("GETOPTIONI ShowTooltip"));
	bTraceCamera = bool(ConsoleCommand("GETOPTIONI TraceCamera"));
	bShowNameAlways = bool(ConsoleCommand("GETOPTIONI ShowNameAlways"));
	bListenPartyInvite = bool(ConsoleCommand("GETOPTIONI ListenPartyInvite"));
	bListenPartyJoin = bool(ConsoleCommand("GETOPTIONI ListenPartyJoin"));
	bListenClanInvite = bool(ConsoleCommand("GETOPTIONI ListenClanInvite"));
	bListenClanJoin = bool(ConsoleCommand("GETOPTIONI ListenClanJoin"));
	bListenExchangeRequest = bool(ConsoleCommand("GETOPTIONI ListenExchangeRequest"));
	bPinMinimap = bool(ConsoleCommand("GETOPTIONI PinMinimap"));
	bShowNpcName = bool(ConsoleCommand("GETOPTIONI ShowNpcName"));
	bShowMonsterName = bool(ConsoleCommand("GETOPTIONI ShowMonsterName"));
	bShowItemName = bool(ConsoleCommand("GETOPTIONI ShowItemName"));

	bListenMessage = bool(ConsoleCommand("GETOPTIONI ListenMessage"));
	bListenShout = bool(ConsoleCommand("GETOPTIONI ListenShout"));
	bListenWhisper = bool(ConsoleCommand("GETOPTIONI ListenWhisper"));
	bListenTip = bool(ConsoleCommand("GETOPTIONI ListenTip"));
	bEraseMessage = bool(ConsoleCommand("GETOPTIONI EraseMessage"));
	Super.LoadOption();
}

function SaveOption()
{
	ConsoleCommand("SETOPTIONB ShowTooltip"@bShowTooltip);
	ConsoleCommand("SETOPTIONB TraceCamera"@bTraceCamera);
	ConsoleCommand("SETOPTIONB ShowNameAlways"@bShowNameAlways);
	ConsoleCommand("SETOPTIONB ListenPartyInvite"@bListenPartyInvite);
	ConsoleCommand("SETOPTIONB ListenPartyJoin"@bListenPartyJoin);
	ConsoleCommand("SETOPTIONB ListenClanInvite"@bListenClanInvite);
	ConsoleCommand("SETOPTIONB ListenClanJoin"@bListenClanJoin);
	ConsoleCommand("SETOPTIONB ListenExchangeRequest"@bListenExchangeRequest);
	ConsoleCommand("SETOPTIONB PinMinimap"@bPinMinimap);
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).ChangeMinimapType(bPinMinimap);		//modified by yj	//추후에 깔끔히

	ConsoleCommand("SETOPTIONB ShowNpcName"@bShowNpcName);
	ConsoleCommand("SETOPTIONB ShowMonsterName"@bShowMonsterName);
	ConsoleCommand("SETOPTIONB ShowItemName"@bShowItemName);

	ConsoleCommand("SETOPTIONB ListenMessage"@bListenMessage);
	ConsoleCommand("SETOPTIONB ListenShout"@bListenShout);
	ConsoleCommand("SETOPTIONB ListenWhisper"@bListenWhisper);
	ConsoleCommand("SETOPTIONB ListenTip"@bListenTip);
	ConsoleCommand("SETOPTIONB EraseMessage"@bEraseMessage);


	if( PlayerOwner != none )
	{
		WalkState = !SephirothPlayer(PlayerOwner).PSI.RunState;
		DisArmState = !SephirothPlayer(PlayerOwner).PSI.ArmState;
	}

	Super.SaveOption();
}

function OnInit()
{
	Components[1].NotifyId = CB_ShowName;
	Components[2].NotifyId = CB_ToggleTooltip;
	Components[3].NotifyId = CB_TogglePartyInvite;
	Components[4].NotifyId = CB_TogglePartyJoin;
	Components[5].NotifyId = CB_ToggleClanInvite;
	Components[6].NotifyId = CB_ToggleClanJoin;
	Components[7].NotifyId = CB_ToggleExchangeRequest;
	Components[8].NotifyId = CB_ShowNpcName;
	Components[9].NotifyId = CB_ShowMonsterName;
	Components[10].NotifyId = CB_ShowItemName;

	SetComponentNotify(Components[12], CB_ListenMessage, Self);
	SetComponentNotify(Components[13], CB_ListenShout, Self);
	SetComponentNotify(Components[14], CB_ListenWhisper, Self);
	SetComponentNotify(Components[15], CB_ListenTip, Self);
	SetComponentNotify(Components[16], CB_EraseMessage, Self);
//	SetComponentNotify(Components[9],BN_ToggleRun,Self);
//	SetComponentNotify(Components[13],BN_ToggleArm,Self);
}

function UpdateComponents()
{
/*
	SetComponentText(Components[1],"TooltipMenu");
	SetComponentText(Components[2],"ShowTooltip");
	SetComponentText(Components[3],"CameraSmoothMenu");
	SetComponentText(Components[4],"SmoothCamera");
	SetComponentText(Components[5],"CameraViewMenu");
	SetComponentText(Components[7],"NameDisplayMenu");
	SetComponentText(Components[9],"PartyMenu");
	SetComponentText(Components[10],"AcceptPartyInvite");
	SetComponentText(Components[11],"AcceptPartyJoin");
	SetComponentText(Components[12],"ClanMenu");
	SetComponentText(Components[13],"AcceptClanInvite");
	SetComponentText(Components[14],"AcceptClanJoin");
	SetComponentText(Components[15],"ExchangeMenu");
	SetComponentText(Components[16],"AcceptExchangeRequest");
	SetComponentText(Components[17],"MinimapMenu");
	SetComponentText(Components[18],"PinMinimap");
	SetComponentText(Components[20],"ShowNpcName");
	SetComponentText(Components[21],"ShowMonsterName");
	SetComponentText(Components[22],"ShowItemName");
*/

	Components[13].bDisabled = !bListenMessage;
	Components[14].bDisabled = !bListenMessage;
}

function OnFlush()
{

}

function bool PushComponentBool(int CmpId)
{
	switch (CmpId)
	{
		case CB_ShowName: return bShowNameAlways;
		case CB_ToggleTooltip: return bShowTooltip;
		case CB_TogglePartyInvite: return bListenPartyInvite;
		case CB_TogglePartyJoin: return bListenPartyJoin;
		case CB_ToggleClanInvite: return bListenClanInvite;
		case CB_ToggleClanJoin: return bListenClanJoin;
		case CB_ToggleExchangeRequest: return bListenExchangeRequest;
		case CB_ShowNpcName: return bShowNpcName;
		case CB_ShowMonsterName: return bShowMonsterName;
		case CB_ShowItemName: return bShowItemName;

		case CB_ListenMessage: return bListenMessage;
		case CB_ListenShout: return bListenShout;
		case CB_ListenWhisper: return bListenWhisper;
		case CB_ListenTip: return bListenTip;
		case CB_EraseMessage: return bEraseMessage;

//	if (CmpId == 11) return WalkState;
//	if (CmpId == 13) return DisArmState;
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch(NotifyId)
	{
	case CB_ShowName: bShowNameAlways = (Command == "Checked"); break;
	case CB_ToggleTooltip: bShowTooltip = (Command == "Checked"); break;
	case CB_TogglePartyInvite: bListenPartyInvite = (Command == "Checked"); break;
	case CB_TogglePartyJoin: bListenPartyJoin = (Command == "Checked"); break;
	case CB_ToggleClanInvite: bListenClanInvite = (Command == "Checked"); break;
	case CB_ToggleClanJoin: bListenClanJoin = (Command == "Checked"); break;
	case CB_ToggleExchangeRequest: bListenExchangeRequest = (Command == "Checked"); break;
	case CB_ShowNpcName: bShowNpcName = (Command == "Checked"); break;
	case CB_ShowMonsterName: bShowMonsterName = (Command == "Checked"); break;
	case CB_ShowItemName: bShowItemName = (Command == "Checked"); break;

	case CB_ListenMessage: bListenMessage = (Command == "Checked"); break;
	case CB_ListenShout: bListenShout = (Command == "Checked"); break;
	case CB_ListenWhisper: bListenWhisper = (Command == "Checked"); break;
	case CB_ListenTip: bListenTip = (Command == "Checked"); break;
	case CB_EraseMessage: bEraseMessage = (Command == "Checked"); break;

/*
		case BN_ToggleRun:				
			SephirothPlayer(PlayerOwner).ToggleRunState();			
			break;
		case BN_ToggleArm:
			SephirothPlayer(PlayerOwner).ToggleArmState();
			break;
*/
	}

	Components[4].bDisabled = !bListenMessage;
	Components[6].bDisabled = !bListenMessage;

/*	Default UI Position. 다음 업데이트 때 개봉하겟습니다 ^^* 2009.10.27.Sinhyub
	if (NotifyId == PB_DefaultUI){
		SephirothInterface(PlayerOwner.myHud).SetDefaultUIPosition();
		SaveConfig();
	}
*/		
	Apply();
}

function OnComboUpdate(int ComponentId)
{
	Apply();
}

defaultproperties
{
     Components(1)=(Id=1,Caption="ShowUserName",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=72.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(2)=(Id=2,Caption="ShowTooltip",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=99.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(3)=(Id=3,Caption="AcceptPartyInvite",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=126.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(4)=(Id=4,Caption="AcceptPartyJoin",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=153.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(5)=(Id=5,Caption="AcceptClanInvite",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=180.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(6)=(Id=6,Caption="AcceptClanJoin",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=207.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(7)=(Id=7,Caption="AcceptExchangeRequest",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=234.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(8)=(Id=8,Caption="ShowNpcName",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=261.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(9)=(Id=9,Caption="ShowMonsterName",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=288.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(10)=(Id=10,Caption="ShowItemName",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=315.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(12)=(Id=12,Caption="ListenMessage",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=72.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(13)=(Id=13,Caption="ListenShout",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=99.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(14)=(Id=14,Caption="ListenWhisper",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=126.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(15)=(Id=15,Caption="ListenTip",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=153.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(16)=(Id=16,Caption="EraseMessage",Type=RES_CheckButton,XL=146.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=180.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
}
