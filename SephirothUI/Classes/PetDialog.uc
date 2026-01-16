class PetDialog	extends CMultiInterface;

var float PageX, PageY;

const BS_Normal	 = 0;
const BS_Disable = 1;
const BS_Over	 = 2;
const BS_Click	 = 3;

const OwnerWordX = 22;
const OwnerWordY = 74;
const OwnerWordXL = 75;
const OwnerWordYL = 15;

const PetCommentX = 97;
const PetCommentY = 74;
const PetCommentXL = 146;
const PetCommentYL = 15;

const BN_Exit	= 1;
const BN_Resist = 2;
const BN_Delete = 3;

//Buttons----------------------------------------
struct SpriteImage
{
	var Texture Texture;
	var float U;
	var float V;
	var float UL;
	var float VL;
};

struct InterfaceButton
{
	var int Id;
	var int BtnState;
	var float X,Y,XL,YL;
	var int Normal, Disable, Pressed, Over;
	var string Tooltip;
	var string Text;
};

struct InterfaceScroll
{
	var int Id;
	var float X,Y;				// 스크롤 위치
	var float ScrollHeight;		// 스크롤 바가 움직일 공간의 높이
	var float ThumbPosY;		// 현재 스크롤 바의 위치
	var float ThumbHeight;		// 스크롤 바의 크기중 높이값
	var float ThumbUnitY;		// 스크롤 바가 움직이는 단위
	var bool bGriped;
	var float GripOffsetY;
	var int   ClickedBtnNum;// 스크롤의 버튼이 눌러졌는지 확인 하기 위해 0 : 없음 1 : Up 2 : Down

	var int MaxItemCount;		// 스크롤로 표현되야 하는 대상의 전체 수
	var int ItemCountPerPage;	// 한 페이지에 표시될 대상의 수
	var int CurrentPos;			// 현재 표시될 대상의 시작 위치
	var int SelectedItemNum;	// 현재 선택된 Item이 있으면 그 아이템의 위치, 없으면 -1
};

var array<InterfaceButton> Buttons;
var array<SpriteImage> UnitSprites;
var Texture UITexture;
var int PressedButtonNum;
var float PageWidth;
var float PageHeight;

var PetDialogInput DlgInputUI;

var array<InterfaceScroll> Scrolls;

function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}

function SetButtonResource(out InterfaceButton Button, optional int Normal, optional int Disable, optional int Pressed, optional int Over, OPTIONAL string Text)
{
	Button.Normal = Normal;
	Button.Disable = Disable;
	Button.Pressed = Pressed;
	Button.Over = Over;
	Button.Text = Text;
}

function SetButtonToolTip(OUT InterfaceButton Button, string ToolTip)
{
	Button.Tooltip = ToolTip;
}

function int CursorInButtons()
{
	local int i;
	local float Sx,Sy,Ex,Ey;
	
	for(i = 0 ; i < Buttons.Length ; i++)
	{	
		Sx = PageX+Buttons[i].X;
		Sy = PageY+Buttons[i].Y;
		Ex = Sx+Buttons[i].XL;
		Ey = Sy+Buttons[i].YL;
		if(Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey)
			return i;
	}
	return -1;
}

function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture SprTexture;
	C.SetRenderStyleAlpha();	//modified by yj
	C.SetPos(X,Y);
	SprTexture = Sprite.Texture;
	C.DrawTile(SprTexture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}

function DrawButtons(Canvas C)
{
	local int i;
	local int Index;
	local float Sx,Sy,Ex,Ey;
	local Color OldColor, TextColor;
	local CInterface TopInterface;

	TopInterface = SephirothInterface(PlayerOwner.myHud).ITopOnCursor;
	
	//버튼들 그리기, 버튼에 마우스가 올려져 있으면 툴팁도 그려준다.	
	C.SetRenderStyleAlpha();
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	for ( i = 0 ; i < Buttons.Length ; i++)
	{
		Index = Buttons[i].Normal;
		Sx = PageX+Buttons[i].X;
		Sy = PageY+Buttons[i].Y;
		Ex = Sx+Buttons[i].XL;
		Ey = Sy+Buttons[i].YL;
		Buttons[i].BtnState = BS_Normal;

		if(i == PressedButtonNum){
			Index = Buttons[i].Pressed;
			Buttons[i].BtnState = BS_Click;
		}

		if ( TopInterface == Self && Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey)	{	//modified by yj   PressedButtonNum은 한번 위에 클릭했을 때 1이된다. 그래서 else를 풀어줌. 문제가 발생할수도 있음.

			Index = Buttons[i].Over;
			Buttons[i].BtnState = BS_Over;

			if (Buttons[i].Tooltip != "")
				Controller.SetToolTip(Buttons[i].Tooltip,false);
		}
		
		if(Index != -1)
			DrawUnitSprite(C,UnitSprites[Index],Sx,Sy,Buttons[i].XL,Buttons[i].YL);
		if(Buttons[i].Text != "") {
			OldColor = C.DrawColor;
			if(Buttons[i].BtnState == BS_Disable)
				TextColor = C.MakeColor(160,160,160);
				//C.SetDrawColor(160,160,160);
			else if(Buttons[i].BtnState != BS_Normal) {
				TextColor = C.MakeColor(255, 255, 0);
				//C.SetDrawColor(255,255,0);
				if(Buttons[i].BtnState == BS_Click) {
					Sx+=1;
					Sy+=1;
				}
			}
			else
				TextColor = C.MakeColor(255, 255, 255);
			C.SetDrawColor(0,0,0);
			C.DrawKoreanText(Buttons[i].Text, Sx+1, Sy+2, Buttons[i].XL-2, Buttons[i].YL+1);
			C.DrawColor = TextColor;
			C.DrawKoreanText(Buttons[i].Text, Sx, Sy+1, Buttons[i].XL-2, Buttons[i].YL+1);
			C.DrawColor = OldColor;
		}
	}
}
//-----------------------------------------------

//Scroll-----------------------------------------
function InitScroll(int Index, int ItemPerPage, int MaxItemCount)
{
	Scrolls[Index].SelectedItemNum = -1;
	Scrolls[Index].ItemCountPerPage = ItemPerPage;
	UpdateScrollList(Index,MaxItemCount);
}
// 스크롤 될 대상을 Update 한다.
function UpdateScrollList(int Index, int MaxItemCount)
{
	local InterfaceScroll Scroll;
	Scroll = Scrolls[Index];
	Scroll.MaxItemCount = MaxItemCount;	
	if(Scroll.MaxItemCount > Scroll.ItemCountPerPage){
		Scroll.ThumbUnitY = Scroll.ScrollHeight / Scroll.MaxItemCount;
		Scroll.ThumbHeight = Scroll.ThumbUnitY * Scroll.ItemCountPerPage;
		//@by wj(040507)------
		if (Scroll.CurrentPos + Scroll.ItemCountPerPage >= Scroll.MaxItemCount)
			Scroll.CurrentPos = Scroll.MaxItemCount - Scroll.ItemCountPerPage;
		//--------------------
		Scroll.ThumbPosY = Scroll.CurrentPos * Scroll.ThumbUnitY;
	}
	else{
		Scroll.ThumbUnitY = 0;
		//@by wj(040507)------
		Scroll.ThumbHeight = 0;
		Scroll.CurrentPos = 0;
		//--------------------
	}
	Scrolls[Index] = Scroll;
}
//스크롤 바의 동작을 제어한다.
function UpdateScrollPosition(int Index, int Delta)
{
	local int Temp;	

	if(Scrolls[Index].MaxItemCount > Scrolls[Index].ItemCountPerPage) {
		Temp = Scrolls[Index].CurrentPos;
		Temp += Delta;
		if(Temp < 0){
			Temp = 0;
		}
		if(Temp > (Scrolls[Index].MaxItemCount - Scrolls[Index].ItemCountPerPage)){
			Temp = Scrolls[Index].MaxItemCount - Scrolls[Index].ItemCountPerPage;
		}
		Scrolls[Index].CurrentPos = Temp;
		Scrolls[Index].ThumbPosY = Temp * Scrolls[Index].ThumbUnitY;
	}
}

function bool ProcessScrolls()
{
	local int i;
	local float Sx, Sy;
	local float MouseX, MouseY;

	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		Sx = PageX+Scrolls[i].X;
		Sy = PageY+Scrolls[i].Y;
		//UpArrow
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+1 && MouseY < Sy+1+14){
			UpdateScrollPosition(i,-1);
			Scrolls[i].ClickedBtnNum = 1;
			return true;
		}
		//DownArrow
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+Scrolls[i].ScrollHeight+17 && MouseY < Sy+Scrolls[i].ScrollHeight+17+14){
			Scrolls[i].ClickedBtnNum = 2;
			UpdateScrollPosition(i,1);
			return true;
		}
		//ScrollBar
		if(MouseX > Sx+1 && MouseX < Sx+1+12 && MouseY > Sy+16+Scrolls[i].ThumbPosY && MouseY < Sy+16+Scrolls[i].ThumbPosY+Scrolls[i].ThumbHeight){
			Scrolls[i].bGriped = true;
			Scrolls[i].GripOffsetY = MouseY - (Sy+16+Scrolls[i].ThumbPosY);
			return true;
		}
	}
	return false;
}

function DrawScroll(Canvas C)
{
	local InterfaceScroll Scroll;
	local int i;
	local float Sx, Sy;	
	local float MouseX, MouseY;

	if(Scroll.MaxItemCount <= Scroll.ItemCountPerPage)
		return;

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Scroll = Scrolls[i];
		Sx = PageX+Scroll.X;
		Sy = PageY+Scroll.Y;
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+1 && MouseY < Sy+1+13){
			C.SetPos(Sx+1,Sy+1);
			if(Scroll.ClickedBtnNum == 1)
				C.DrawTile(UITexture, 13, 14, 60, 380, 13, 14);
			else
				C.DrawTile(UITexture, 13, 14, 40, 380, 13, 14);
		}
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+17+Scroll.ScrollHeight && MouseY < Sy+Scroll.ScrollHeight+17+13) {
			C.SetPos(Sx+1,Sy+17+Scroll.ScrollHeight);
			if(Scroll.ClickedBtnNum == 2)
				C.DrawTile(UITexture, 13, 14, 100, 380, 13, 14);
			else
				C.DrawTile(UITexture, 13, 14, 80, 380, 13, 14);
		}
		C.SetPos(Sx+1,Sy+16+Scroll.ThumbPosY);
		C.DrawTile(UITexture, 12, Scroll.ThumbHeight, 120, 380, 12, 49);
	}
}

function ThumbMouseMove(int Index)
{
	local InterfaceScroll Scroll;
	local float Sy,Ey;
	local float MouseY;
	local float ThumbPosY;

	Scroll = Scrolls[Index];	
	MouseY = Controller.MouseY;	
	Sy = PageY+Scroll.Y+16;
	Ey = Sy+Scroll.ScrollHeight;

	if(MouseY < Sy || MouseY > Ey)
		return;

	ThumbPosY = MouseY - Scroll.GripOffsetY - Sy;
	if(ThumbPosY < 0)
		ThumbPosY = 0;
	if(ThumbPosY > Scrolls[Index].ScrollHeight - Scrolls[Index].ThumbHeight)
		ThumbPosY = Scrolls[Index].ScrollHeight - Scrolls[Index].ThumbHeight;
	Scrolls[Index].ThumbPosY = ThumbPosY;
	Scrolls[Index].CurrentPos = ThumbPosY / Scroll.ThumbUnitY;
}

function OnReleaseMouseLButton()
{
	local int i;

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		if(Scrolls[i].bGriped)
		{
			Scrolls[i].bGriped = false;
			Scrolls[i].GripOffsetY = -1;
			Scrolls[i].ThumbPosY = Scrolls[i].CurrentPos * Scrolls[i].ThumbUnitY;
		}
		Scrolls[i].ClickedBtnNum = 0;
	}
}

function DrawSelectedBox(Canvas C, float X, float Y, float Width, float Height)
{
	local Color OldColor;

	OldColor = C.DrawColor;
	C.SetDrawColor(188, 63, 63, 150);
	C.SetPos(X,Y);
	C.DrawTile(Texture'Engine.WhiteSquareTexture',Width,Height,0,0,0,0);
	C.DrawColor = OldColor;
}

function UpdatePetDialog()
{
	local PetServerInfo PetSI;

	PetSI = ClientController(PlayerOwner).PetSI;

	UpdateScrollList(0,PetSI.PetComment.Length);
}

event Tick(float DeltaTime)
{
	local int i;

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		if(Scrolls[i].bGriped)
			ThumbMouseMove(i);
	}
}

function OnInit()
{
	local PetServerInfo PetSI;

	PetSI = ClientController(PlayerOwner).PetSI;
	
//	UITexture=Texture(DynamicLoadObject("PetUI.default.DialogBack",class'Texture'));
	UITexture=Texture(DynamicLoadObject("UI_2009.Win09",class'Texture'));
	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],UITexture);
	SetSpriteTexture(UnitSprites[2],TextureResources[0].Resource);
	SetSpriteTexture(UnitSprites[3],TextureResources[1].Resource);

	SetButtonResource(Buttons[0],-1,-1,-1,1);
	SetButtonResource(Buttons[1],2,-1,-1,3,Localize("PetUI","Resist","SephirothUI"));
	SetButtonResource(Buttons[2],2,-1,-1,3,Localize("PetUI","Delete","SephirothUI"));
	InitScroll(0,15,PetSI.Petcomment.Length);
}

function OnFlush()
{
	if (DlgInputUI != None) {
		DlgInputUI.HideInterface();
		RemoveInterface(DlgInputUI);
		DlgInputUI = None;
	}
}

function DrawDialog(Canvas C, string OwnerString, string PetString, int CurrentY)
{
	local array<string> OwnerText;
	local array<string> PetText;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	//주인말
	C.WrapStringToArray(OwnerString,OwnerText,OwnerWordXL,"|");
	C.DrawKoreanText(OwnerText[0],PageX+OwnerWordX,CurrentY,OwnerWordXL,OwnerWordYL);
	//펫 말
	C.WrapStringToArray(PetString,PetText,PetCommentXL,"|");
	C.DrawKoreanText(PetText[0],PageX+PetCommentX,CurrentY,PetCommentXL,PetCommentYL);	
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local int ListLength;
	local int Index;
	local int CurrentY;
	local PetServerInfo PetSI;
	local float MouseX, MouseY;

	PetSI = ClientController(PlayerOwner).PetSI;


	//배경
	DrawUnitSprite(C,UnitSprites[0],PageX,PageY,WinWidth,WinHeight);

	//Buttons
	DrawButtons(C);

	//Scroll
	DrawScroll(C);

	if(Scrolls[0].ItemCountPerPage > Scrolls[0].MaxItemCount)
		ListLength = Scrolls[0].MaxItemCount;
	else
		ListLength = Scrolls[0].ItemCountPerPage;

	C.SetPos(Components[0].X+20,Components[0].Y+25);
	C.SetRenderStyleAlpha();
	C.DrawTile(TextureResources[3].Resource, 60, 21, 0, 0, 60, 21);
	C.SetPos(Components[0].X+100,Components[0].Y+25);
	C.DrawTile(TextureResources[2].Resource, 118, 18, 0, 0, 118, 21);	
		
	C.SetDrawColor(255,255,255);

	//대화 갯수
//	C.DrawKoreanText(PetSI.LearnedTextNums$" / "$PetSI.LearnTextNumsmax,PageX+57,PageY+25,51,18);
	C.DrawKoreanText(PetSI.LearnedTextNums$" / "$PetSI.LearnTextNumsmax,PageX+20,PageY+25,60,22);

	//"펫 대화 정보"
//	C.DrawKoreanText(Localize("PetUI","PetDialogInfo","SephirothUI"),PageX+117,PageY+22,101,20);
	C.DrawKoreanText(Localize("PetUI","PetDialogInfo","SephirothUI"),PageX+100,PageY+25,118,22);

	//"저장된 대화"
	C.DrawKoreanText(Localize("PetUI","ResistedDialog","SephirothUI"),PageX+22,PageY+58,228,16);

	for(i = 0 ; i < ListLength ; i++)
	{
		Index = Scrolls[0].CurrentPos+i;
		CurrentY = PageY+OwnerWordY+(16*i);
		if(Index == Scrolls[0].SelectedItemNum)
			DrawSelectedBox(C,PageX+OwnerWordX,CurrentY,OwnerWordXL+PetCommentXL,OwnerWordYL);
		DrawDialog(C,PetSI.OwnerWord[Index],PetSI.PetComment[Index],CurrentY);
		/*
		//주인말
		C.WrapStringToArray(PetSI.OwnerWord[Index],OwnerText,OwnerWordXL,"|");
		C.DrawKoreanText(OwnerText[0],PageX+OwnerWordX,CurrentY,OwnerWordXL,OwnerWordYL);
		//펫 말
		C.WrapStringToArray(PetSI.PetComment[Index],PetText,PetCommentXL,"|");
		C.DrawKoreanText(PetText[0],PageX+PetCommentX,CurrentY,PetCommentXL,PetCommentYL);
		*/
	}
	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;
	if(MouseY > PageY+OwnerWordY && MouseY < PageY+OwnerWordY+16*15)
	{
		Index = Scrolls[0].CurrentPos + (MouseY - (PageY + OwnerWordY))/16;
		if(Index < ListLength) {
			if(MouseX > PageX+OwnerWordX && MouseX < PageX+OwnerWordX+OwnerWordXL){
				Controller.SetToolTip(PetSI.OwnerWord[Index],false);
			}
			else if(MouseX > PageX+PetCommentX && MouseX < PageX+PetCommentX+PetCommentXL){
				Controller.SetToolTip(PetSI.PetComment[Index],false);
			}	
		}
	}
}

function LayOut(Canvas C)
{
	local int i;
	PageX = C.ClipX - Components[0].XL;
	PageY = 10;	
	MoveComponentId(0,true,PageX,PageY);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.LayOut(C);
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	if(NotifyId == INT_Close) {
		if (Interface == DlgInputUI) {
			if(DlgInputUI != None) {
				DlgInputUI.HideInterface();
				RemoveInterface(DlgInputUI);
				DlgInputUI = None;
			}
		}
	}
}

function bool OnkeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local PetServerInfo PetSI;
	local int Index;
	local float Sx,Sy,Ex,Ey,MouseX,MouseY;

	PetSI = ClientController(PlayerOwner).PetSI;

	if(Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if(Key == IK_LeftMouse && Action == IST_Press) {
		PressedButtonNum = CursorInButtons();
		ProcessScrolls();
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX + OwnerWordX;
		Sy = PageY + OwnerWordY;
		Ex = Sx + OwnerWordXL + PetCommentXL;
		Ey = Sy + 16 * 15;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey)
		{
			Index = Scrolls[0].CurrentPos + (MouseY - Sy) / 16;
			if(Index < Scrolls[0].MaxItemCount)
				Scrolls[0].SelectedItemNum = Index;
			else 
				Scrolls[0].SelectedItemNum = -1;
		}
	}
	if(Key == IK_LeftMouse && Action == IST_Release) {

		OnReleaseMouseLButton();
		
		if(PressedButtonNum != -1) {
			Index = PressedButtonNum;
			PressedButtonNum = -1;
			if(Buttons[Index].Id == BN_Exit) {
				Parent.NotifyInterface(Self, INT_Close);
				return true;
			}
			if(Buttons[Index].Id == BN_Resist) {
				if(DlgInputUI == None) {
					DlgInputUI = PetDialogInput(AddInterface("SephirothUI.PetDialogInput"));
					if(DlgInputUI != None)
						DlgInputUI.ShowInterface();
				}
				return true;
			}
			if(Buttons[Index].Id == BN_Delete) {
				if(Scrolls[0].SelectedItemNum != -1){
					SephirothPlayer(PlayerOwner).Net.NotiPetChatDeleteIndex(Scrolls[0].SelectedItemNum);
					Scrolls[0].SelectedItemNum = -1;
				}
				return true;
			}
		}
	}
	if(Key ==IK_MouseWheelUp){
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX + OwnerWordX;
		Sy = PageY + OwnerWordY;
		Ex = Sx + OwnerWordXL + PetCommentYL;
		Ey = Sy + 16* 15;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0,-1);
			return true;
		}
	}
	if(Key ==IK_MouseWheelDown){
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX + OwnerWordX;
		Sy = PageY + OwnerWordY;
		Ex = Sx + OwnerWordXL + PetCommentYL;
		Ey = Sy + 16* 15;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0,1);
			return true;
		}
	}
	if((Key == IK_LeftMouse || Key == IK_RightMouse) && IsCursorInsideComponent(Components[0]))
		return true;
}

defaultproperties
{
     Buttons(0)=(Id=1,X=241.000000,Y=3.000000,XL=23.000000,YL=20.000000)
     Buttons(1)=(Id=2,X=50.000000,Y=330.000000,XL=72.000000,YL=22.000000)
     Buttons(2)=(Id=3,X=151.000000,Y=330.000000,XL=72.000000,YL=22.000000)
     UnitSprites(0)=(UL=264.000000,VL=370.000000)
     UnitSprites(1)=(V=380.000000,UL=23.000000,VL=20.000000)
     UnitSprites(2)=(UL=72.000000,VL=22.000000)
     UnitSprites(3)=(UL=72.000000,VL=22.000000)
     Scrolls(0)=(X=235.000000,Y=73.000000,ScrollHeight=209.000000)
     Components(0)=(XL=264.000000,YL=370.000000)
     TextureResources(0)=(Package="UI_2009",Path="BTN02_02_N",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN02_02_O",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="DLG08",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="DLG09",Style=STY_Alpha)
     WinWidth=264.000000
     WinHeight=370.000000
     IsBottom=True
}
