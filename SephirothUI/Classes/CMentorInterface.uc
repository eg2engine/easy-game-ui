// 멘토 인터페이스에는 3개의 탭과 타이틀만 작동한다.
// 각 탭에 인터페이스가 연결되어 생성/소멸된다.
class CMentorInterface	extends CMultiInterface
	config(SephirothUI);

enum eMENTOR_TAB
{
	MT_NONE,
	MT_LIST,
	MT_INFO,
	MT_QUEST,
};

const BN_Exit		= 1;
const BN_MATCH		= 2;		// 매칭 탭버튼
const BN_INFO		= 3;		// 사제 정보 탭버튼
const BN_QUEST		= 4;		// 퀘스트 탭버튼
/*
const	TAB_LIST	= 0;
const	TAB_INFO	= 1;
const	TAB_QUEST	= 2;
*/
var CMentorMatching		tabList;		// 매칭 정보
var CMentorInfo			tabInfo;		// 사제 정보
var CMentorQuest		tabQuest;		// 퀘스트 정보

var eMENTOR_TAB			eSelectedTab;

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var string Title;

var PlayerServerInfo PSI;

function OnInit()
{
	local int n;

	eSelectedTab = MT_NONE;
	SetSelectedTab(MT_INFO);

	PSI = SephirothPlayer(PlayerOwner).PSI;

	Title = Localize("MentorInfo", "Title", "SephirothUI");

	SetComponentTextureId(Components[1], 5, -1, 5, 6);

	for ( n = 0 ; n < 3 ; n++ )
		SetComponentTextureId(Components[2 + n], 1, -1, 2, 3);

	SetComponentNotify(Components[1], BN_Exit, Self);

	SetComponentNotify(Components[2], BN_INFO, Self);
	SetComponentNotify(Components[3], BN_QUEST, Self);
	SetComponentNotify(Components[4], BN_MATCH, Self);

	VisibleComponent(Components[4], false);

	bNeedLayoutUpdate = true;
}


function OnFlush()
{
	Saveconfig();
}


function Layout(Canvas C)
{
	local int DX,DY;
	local int i;

	if (bMovingUI)
	{
		if (bIsDragging)
		{
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else
		{
			if (PageX < 0)
				PageX = 0;
			else if (PageX + WinWidth > C.ClipX)
				PageX = C.ClipX - WinWidth;

			if (PageY < 0)
				PageY = 0;
			else if (PageY + WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight;

			bMovingUI = false;
		}

		bNeedLayoutUpdate = true;
	}

	if (bNeedLayoutUpdate)
	{
		MoveComponent(Components[0], true, PageX, PageY, WinWidth, WinHeight);
		MoveComponent(Components[2], true, Components[0].X + 17, Components[0].Y + 36);

		for ( i = 1 ; i < Components.Length; i++ )
			MoveComponent(Components[i]);

		for ( i = 0 ; i < Interfaces.Length ; i++ )
		{
			Interfaces[i].MoveWindow(Components[0].X + 11, Components[0].Y + 56);
			Interfaces[i].bNeedLayoutUpdate = true;
		}

		bNeedLayoutUpdate = false;
	}

	Super.Layout(C);
}


function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 7, 8, 9, 10, 11, 12, 13, 14, 15);
	DrawTitle(C, Title);
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_LeftMouse )
	{
		if ( (Action == IST_Press) && IsCursorInsideComponent(Components[0]))
		{
			bIsDragging = true;
			bMovingUI = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}

		if (Action == IST_Release && bIsDragging)
		{
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}


function bool IsCursorInsideInterface()
{
	if ( IsCursorInsideComponent(Components[0]) || tabInfo.IsCursorInsideInterface() || tabList.IsCursorInsideInterface() || tabQuest.IsCursorInsideInterface() )
		return true;

	return false;
}


function SetSelectedTab(eMENTOR_TAB eTab)
{
	if ( eSelectedTab != eTab )
	{
		// 이전 탭의 내용은 지우고
		switch ( eSelectedTab )
		{
		case MT_INFO :

			tabInfo.HideInterface();
			RemoveInterface(tabInfo);
			tabInfo = None;
			VisibleComponent(Components[2], true);	
			break;

		case MT_QUEST :

			tabQuest.HideInterface();
			RemoveInterface(tabQuest);
			tabQuest = None;
			VisibleComponent(Components[3], true);	
			break;

		case MT_LIST :

			tabList.HideInterface();
			RemoveInterface(tabList);
			tabList = None;
			VisibleComponent(Components[4], true);	
			break;
		}

		// 새로운 탭의 내용을 구성한다.
		switch ( eTab )
		{
		case MT_INFO :

			tabInfo = CMentorInfo(AddInterface("SephirothUI.CMentorInfo"));

			if ( tabInfo != None )
				tabInfo.ShowInterface();

			tabInfo.MoveWindow(Components[0].X + 11, Components[0].Y + 56);
			VisibleComponent(Components[2], false);
			break;

		case MT_QUEST :

			tabQuest = CMentorQuest(AddInterface("SephirothUI.CMentorQuest"));

			if ( tabQuest != None )
				tabQuest.ShowInterface();

			tabQuest.MoveWindow(Components[0].X + 11, Components[0].Y + 56);
			VisibleComponent(Components[3], false);
			break;

		case MT_LIST :

			tabList = CMentorMatching(AddInterface("SephirothUI.CMentorMatching"));

			if ( tabList != None )
				tabList.ShowInterface();

			tabList.MoveWindow(Components[0].X + 11, Components[0].Y + 56);
			VisibleComponent(Components[4], false);
			break;
		}
	}

	eSelectedTab = eTab;
}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch ( NotifyId )
	{
	case BN_Exit :

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_INFO :

		SetSelectedTab(MT_INFO);
		break;

	case BN_QUEST :

//		SetSelectedTab(MT_QUEST);
		break;

	case BN_MATCH :

//		SetSelectedTab(MT_LIST);
		break;
	}
}


function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	local int NotifyValue;
	//local int NotifyValue, Space;
	//local string Cmd, Param;

	if (NotifyId == INT_MessageBox)
	{
		NotifyValue = int(Command);

		switch (NotifyValue)
		{
		default :
			break;
		}
	}
}

defaultproperties
{
     Components(0)=(XL=348.000000,YL=583.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=316.000000,OffsetYL=14.000000,HotKey=IK_Escape)
     Components(2)=(Id=2,Caption="MentorInfo",Type=RES_TextButton,XL=102.000000,YL=24.000000,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(3)=(Id=3,Caption="MentorQuest",Type=RES_TextButton,XL=102.000000,YL=24.000000,PivotId=2,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Caption="MentorMatch",Type=RES_TextButton,XL=102.000000,YL=24.000000,PivotId=3,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="chr_tab_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="chr_tab_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     WinWidth=348.000000
     WinHeight=583.000000
}
