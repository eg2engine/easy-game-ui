class CPlugin extends CMultiInterface
	config(SephirothUI);

const BN_Close = 1;

//Component ID(Index) -2009.10.30.Sinhyub
const IDC_PLUGIN = 2;
const IDC_Attack = 3;

var array<COptionPage> Pages;
var array<string> PageNames;
var COptionPage CurrentPage;
var int CPI;

var string m_sTitle;

// cs added --- for moving window
var globalconfig float PageX, PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

function OnInit()
{
	local int i;
	
	for (i=0;i<PageNames.Length;i++) {
		Pages[i] = COptionPage(AddInterface(PageNames[i]));
		Pages[i].InitResources();
		Pages[i].InitComponents();
		//PlayerOwner.myHud.AddMessage(1,"Debug info:CPlugin OnInit count",class'Canvas'.static.MakeColor(200,100,200));
	}
	CPI = Clamp(CPI,0,Pages.Length-1);
	CurrentPage = Pages[CPI];
	if (CurrentPage != None)
		CurrentPage.bVisible = true;

	SetComponentTextureId(Components[1],9,-1,9,10);
	Components[1].NotifyId = BN_Close;

	SetTabTexture(IDC_PLUGIN);
	for (i=0;i<Pages.Length;i++)
		Components[IDC_PLUGIN+i].NotifyId = IDC_PLUGIN+i;

	m_sTitle = Localize("OptionUI", "PluginUI", "SephirothUI");

}

function OnFlush()
{
	local int i;
	for (i=0;i<Pages.Length;i++) {
		if (Pages[i] != None) {
			Pages[i].OnFlush();
			RemoveInterface(Pages[i]);
			Pages[i] = None;
		}
	}
	CurrentPage = None;
	SaveConfig();
}

function Layout(Canvas C)
{
	local int i;

	// cs added --- for moving window
	local int DX, DY;
	if(bMovingUI) {
		if (bIsDragging) {
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else {
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
	}

	MoveComponentId(0, true, PageX, PageY, WinWidth, WinHeight);
	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
	//MoveComponentId(6,true,Components[2].X,Components[2].Y-VLine);	//
	//Components[6].YL = GetListLength();

	/*
	MoveComponentId(0,true,(C.ClipX-Components[0].XL)/2,(C.ClipY-Components[0].YL)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	*/
	if (CurrentPage != None)
		CurrentPage.SetRegion(Components[0].X,Components[0].Y,Components[0].XL,Components[0].YL);
	Super.Layout(C);
}

function OnPostRender(HUD H, Canvas C)
{	
}

function OpenPage(int PageIndex)
{
	if (PageIndex >= 0 && PageIndex < Pages.Length) {
		if (CurrentPage != Pages[PageIndex]) {
			if (CurrentPage != None)
				CurrentPage.bVisible =false;
			CurrentPage = Pages[PageIndex];
			if (CurrentPage != None)
				CurrentPage.bVisible = true;
			CPI = Clamp(PageIndex,0,Pages.Length-1);
		}
	}

	SetTabTexture(PageIndex + IDC_PLUGIN);	//페이지를 열고 해당탭으로 변경	Sinhyub.
	//Pages[i].ShowInterface();
}

function ApplyOption()
{
	local int i;
	for (i=0;i<Pages.Length;i++)
		if (Pages[i] != None)
			Pages[i].SaveOption();
	ConsoleCommand("SAVEOPTION");
	ConsoleCommand("APPLYOPTION");
	Parent.NotifyInterface(Self,INT_Close);
}

function SetTabTexture(int SelectedComponentId)		//modified by yj		//선택된 탭과 그렇지 않은 탭의 텍스쳐를 구분한다.
{
	local int i;
	
	for(i=IDC_PLUGIN; i<IDC_PLUGIN+Pages.Length; i++)
	{
		if(i == SelectedComponentId)
			SetComponentTextureId(Components[i],13,-1,13,13);
		else
			SetComponentTextureId(Components[i],11,-1,13,12);
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Close:
		Parent.NotifyInterface(Self,INT_Close);
		break;
	default:
		if (NotifyId >= IDC_PLUGIN && NotifyId < IDC_PLUGIN + Pages.Length)
			OpenPage(NotifyId - IDC_PLUGIN); //BN_OpenPage == 3) 
		break;
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	//if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
	//	return true;
	// cs added --- for moving window
	if (Key == IK_LeftMouse) {
		if ((Action == IST_Press)&& IsCursorInsideComponent(Components[0])) {
			bMovingUI = true;
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		if (Action == IST_Release && bIsDragging) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);

	C.SetPos(Components[0].X + 11, Components[0].Y + 56);
	C.DrawTile(TextureResources[14].Resource, 369, 4, 0, 0, 4, 4);
}

defaultproperties
{
     PageNames(0)="SephirothUI.PagePlugin"
     PageNames(1)="SephirothUI.PageAttack"
     PageNames(2)="SephirothUI.PageChat"
     Components(0)=(XL=391.000000,YL=423.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=361.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(2)=(Id=2,Caption="PluginAuto",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=36.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Setting")
     Components(3)=(Id=3,Caption="PluginAttack",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=2,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Setting")
     Components(4)=(Id=4,Caption="PluginAutoChat",Type=RES_PushButton,XL=80.000000,YL=24.000000,PivotId=3,PivotDir=PVT_Right,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Setting")
     TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="skill_tab_s_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="skill_tab_s_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="skill_tab_s_c",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="tab_line",Style=STY_Alpha)
}
