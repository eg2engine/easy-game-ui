class Helper extends CMultiInterface
	config(SephirothUI);

var globalconfig float PageX, PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

// 항목용
var string ShowIndex;
var string Title;
var Texture BackGround;
var string LangExt;
var CTextFile FileLoader;
var CScrollTextureTextArea TextureTextArea;
//		NoteList.Scroll.HideInterface();
const BN_Exit = 1;
const BN_Previous = 2;
const BN_Next = 3;

function OnInit()
{	
	SetButton();

	LangExt = PlayerOwner.ConsoleCommand("LangExt");

	if(FileLoader == None )
		FileLoader = spawn(class'CTextFile');

	if(TextureTextArea == None)
		TextureTextArea = CScrollTextureTextArea(AddInterface("SephirothUI.CScrollTextureTextArea"));

	if(TextureTextArea != None) {
		TextureTextArea.ShowInterface();
		TextureTextArea.SetTextArea(377, 319);
		LoadHelperNote();
	}
}

function OnFlush()
{		
	SaveConfig();
	CloseHelperNote();
}

function Layout(Canvas C)
{
	local int i;
	local int nDragX, nDragY;

	if(bMovingUI) {
		if (bIsDragging)
		{
			nDragX = Controller.MouseX - DragOffsetX;
			nDragY = Controller.MouseY - DragOffsetY;
			PageX = nDragX;
			PageY = nDragY;
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

	if (TextureTextArea != None) 
		TextureTextArea.SetPosition(Components[0].X+14,Components[0].Y+55);
	
	Super.Layout(C);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_LeftMouse )	//2009.10.27.Sinhyub
	{
		if (Action == IST_Press&& IsCursorInsideComponent(Components[0]))
		{
			bMovingUI = true;
			bIsDragging = true;
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

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;

}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch(NotifyId) {
		case BN_Exit:
			Parent.NotifyInterface(self,INT_Close);
			break;		
		case BN_Previous:		
			Parent.NotifyInterface(self,INT_Command,"Previous");
			break;
		case BN_Next:					
			Parent.NotifyInterface(self,INT_Command,"Next");
			break;
	}
}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, Title);
}

function OnPostRender(HUD H, Canvas C)
{

}


function LoadHelperNote()
{
	if (TextureTextArea != None) {	
		if(Len(ShowIndex) < 4){
/*			FileLoader.LoadParagraphs("Etc\\EX0" $ ShowIndex $ "." $LangExt);
			TextureTextArea.CopyTexts(FileLoader.Paragraphs);
			TextureTextArea.LoadTexture("Help.Tutorial_0"$ShowIndex$"_"$"kr");*/
		}
		else {	// 퀘스트 알림		
			FileLoader.LoadParagraphs("Etc\\EX" $ ShowIndex $ "." $LangExt);
			TextureTextArea.CopyTexts(FileLoader.Paragraphs);
			TextureTextArea.LoadTexture("Help.Qeust_Form_kr");
		}
	}
}

function CloseHelperNote()
{
	if (FileLoader != None)	{
		FileLoader.Destroy();
		FileLoader = None;
	}
	if (TextureTextArea != None) {
		TextureTextArea.HideInterface();
		RemoveInterface(TextureTextArea);
		TextureTextArea = None;
	}
}

function SetButton()
{
	SetComponentNotify(Components[2], BN_Exit ,Self);
	SetComponentTextureId(Components[2],9,-1,9,10);

	SetComponentNotify(Components[3], BN_Previous ,Self);
	SetComponentTextureId(Components[3],11,-1,13,12);
	SetComponentNotify(Components[4], BN_Next ,Self);
	SetComponentTextureId(Components[4],11,-1,13,12);
}

defaultproperties
{
     PageX=100.000000
     PageY=100.000000
     Components(0)=(XL=405.000000,YL=424.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=374.000000,OffsetYL=14.000000,HotKey=IK_Escape)
     Components(3)=(Id=3,Caption="Previous",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=76.000000,OffsetYL=379.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Commands")
     Components(4)=(Id=4,Caption="Next",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=214.000000,OffsetYL=379.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Commands")
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
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     WinWidth=405.000000
     WinHeight=424.000000
}
