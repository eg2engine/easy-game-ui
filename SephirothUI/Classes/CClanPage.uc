class CClanPage extends CMultiInterface;

//**************
//스크롤 Thumb 관련 기능 없앰.		//관련 변수, 함수 정리해야 함.
//
const ButtonW	= 23;
const ButtonH	= 23;
const ThumbW	= 23;

const BS_Normal	 = 0;
const BS_Disable = 1;
const BS_Over	 = 2;
const BS_Click	 = 3;

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
	var float fX,fY;				// 스크롤 위치
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

var CClanInterface BaseInterface;

var array<InterfaceButton> Buttons;
var array<SpriteImage> UnitSprites;
var Texture UITexture;

var int PressedButtonNum;
var float PageX,PageY;
var float PageWidth;
var float PageHeight;


var array<InterfaceScroll> Scrolls;

function SetRegion(float X,float Y,float W,float H)
{
	PageX = X;
	PageY = Y;
	PageWidth = W;
	PageHeight = H;
}

function SetPosition(float X,float Y)
{
	PageX = X;
	PageY = Y;
}

function bool IsInPageBounds()
{
	return Controller.MouseX >= PageX && Controller.MouseY <= PageX+PageWidth &&
		Controller.MouseY >= PageY && Controller.MouseY <= PageY+PageHeight;
}

function Layout(Canvas C)
{
	local int i;
	if (Components.Length < 1)
		return;
	MoveComponent(Components[0],true,PageX,PageY,PageWidth,PageHeight);
	for (i=0;i<Components.Length;i++)
		MoveComponent(Components[i]);
}

function OnInit()
{
	
}
function UpdatePageItems();
//Buttons----------------------------------------
function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}

function SetButton(out InterfaceButton Button, int Id, float X, float Y, float XL, float YL)
{
	Button.Id = Id;
	Button.X = X;
	Button.Y = Y;
	Button.XL = XL;
	Button.YL = YL;
}

function SetButtonText(int Index, string Text)
{
	Buttons[Index].Text = Text;
}

function SetButtonResource(out InterfaceButton Button, optional int Normal, optional int Disable, optional int Pressed, optional int Over)
{
	Button.Normal = Normal;
	Button.Disable = Disable;
	Button.Pressed = Pressed;
	Button.Over = Over;
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

function DrawButtons(Canvas C)
{
	local int i;
	local int Index;
	local float MouseX, MouseY;
	local float Sx,Sy,Ex,Ey;
	local Color OldColor;

	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;


	for(i = 0 ; i < Buttons.Length ; i++)
	{
		Index = -1;
		Sx = PageX + Buttons[i].X;
		Sy = PageY + Buttons[i].Y;
		Ex = Sx + Buttons[i].XL;
		Ey = Sy + Buttons[i].YL;
		Buttons[i].BtnState = BS_Normal;

		if(i == PressedButtonNum){
			Index = Buttons[i].Pressed;
			Buttons[i].BtnState = BS_Click;
		}
		else if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey)
		{			
			Index = Buttons[i].Over;			
			Buttons[i].BtnState = BS_Over;
		}
		else {		//modified by yj
			Index = Buttons[i].Normal;
			Buttons[i].BtnState = BS_Normal;
		}	

		if(Index != -1)
			DrawUnitSprite(C, UnitSprites[Index],Sx,Sy,Buttons[i].XL,Buttons[i].YL);
		if(Buttons[i].Text != "")
		{
			OldColor = C.DrawColor;
			if(Buttons[i].BtnState != BS_Normal && Buttons[i].BtnState != BS_Disable){
				C.SetDrawColor(167,230,191);
				if(Buttons[i].BtnState == BS_Click){
					Sx += 1;
					Sy += 1;
				}
			}
			C.DrawKoreanText(Buttons[i].Text,Sx+1,Sy+1,Buttons[i].XL,Buttons[i].YL);
			
			C.DrawColor = OldColor;
		}
	}	
}

function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	C.SetPos(X,Y);
	C.DrawTile(Sprite.Texture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
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
		Sx = PageX+Scrolls[i].fX;
		Sy = PageY+Scrolls[i].fY;
		//UpArrow
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+1 && MouseY < Sy+1+14){
			UpdateScrollPosition(i,-1);
			Scrolls[i].ClickedBtnNum = 1;
			return true;
		}
		//DownArrow
		if(MouseX > Sx+1 && MouseX < Sx+1+13 && MouseY > Sy+Scrolls[i].ScrollHeight+10 && MouseY < Sy+Scrolls[i].ScrollHeight+10+14){
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

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Scroll = Scrolls[i];
		Sx = PageX+Scroll.fX;
		Sy = PageY+Scroll.fY;
		
		//가운데
//		C.SetPos(Sx+6, Sy+10-2);
//		C.DrawTile(Texture'ScrollBar',1,Scroll.ScrollHeight+4,0,0,1,1);

		C.SetPos(Sx+1,Sy+1);
		if(MouseX > Sx+1 && MouseX < Sx+1+ButtonW && MouseY > Sy+1 && MouseY < Sy+1+ButtonH){			
			if(Scroll.ClickedBtnNum == 1)
				C.DrawTile(Texture'Interface.ScrollUpP', ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);		//modified by yj
			else
				C.DrawTile(Texture'Interface.ScrollUpO', ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);
		}
		else 
			C.DrawTile(Texture'Interface.ScrollUpN',ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);

		C.SetPos(Sx+1,Sy+10+Scroll.ScrollHeight);
		if(MouseX > Sx+1 && MouseX < Sx+1+ButtonW && MouseY > Sy+ButtonH+Scroll.ScrollHeight && MouseY < Sy+Scroll.ScrollHeight+10+ButtonH) {			
			if(Scroll.ClickedBtnNum == 2)
				C.DrawTile(Texture'Interface.ScrollDownP', ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);
			else
				C.DrawTile(Texture'Interface.ScrollDownO', ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);
		}
		else 
			C.DrawTile(Texture'Interface.ScrollDownN', ButtonW, ButtonH, 0, 0, ButtonW, ButtonH);

	/*	//ScrollThumb의 rendering을 막는다.
		if(Scroll.MaxItemCount > Scroll.ItemCountPerPage){
			C.SetPos(Sx+1,Sy+16+Scroll.ThumbPosY);
			C.DrawTile(ScrollTexture_Thumb, 12, Scroll.ThumbHeight, 0, 0, 8, 8);	//음 이건 어떻게 해야 될까나.
		}
	*/
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
	Sy = PageY+Scroll.fY+16;
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
	C.SetDrawColor(50,50,300);
	C.SetPos(X,Y);
	C.DrawTile(Texture'Engine.WhiteSquareTexture',Width,Height,0,0,0,0);
	C.DrawColor = OldColor;
}

function DrawPage(Canvas C);
function bool OnPageKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta);

event Tick(float DeltaTime)
{
	local int i;

	for(i = 0 ; i < Scrolls.Length ; i++)
	{
		if(Scrolls[i].bGriped)
			ThumbMouseMove(i);
	}
}

//-----------------------------------------------

defaultproperties
{
     PressedButtonNum=-1
}
