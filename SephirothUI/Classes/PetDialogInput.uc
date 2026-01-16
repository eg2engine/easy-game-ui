class PetDialogInput extends CMultiInterface;

const BN_Apply	= 1;
const BN_Exit	= 2;

const BS_Normal	 = 0;
const BS_Disable = 1;
const BS_Over	 = 2;
const BS_Click	 = 3;

//var array<SepEditBox> OwnerWord;
var array<CImeEdit> OwnerWord;
var CImeRichEdit	PetComment;
var float PageX, PageY;

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

var array<InterfaceButton> Buttons;
var array<SpriteImage> UnitSprites;
var Texture UITexture;
var int PressedButtonNum;

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
	
	//��ư�� �׸���, ��ư�� ���콺�� �÷��� ������ ������ �׷��ش�.	
	C.SetRenderStyleAlpha();
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	for(i = 0 ; i < Buttons.Length ; i++)
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
		if(Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey){
			Index = Buttons[i].Over;
			Buttons[i].BtnState = BS_Over;
			if(Buttons[i].Tooltip != "")
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

function OnInit()
{
	local int i;
	local Color TextColor;

	//OwnerWord[0] = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	//OwnerWord[1] = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	//OwnerWord[2] = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	//OwnerWord[3] = SepEditBox(AddInterface("SepInterface.SepEditBox"));

	OwnerWord[0] = CImeEdit(AddInterface("Interface.CImeEdit"));
	OwnerWord[1] = CImeEdit(AddInterface("Interface.CImeEdit"));
	OwnerWord[2] = CImeEdit(AddInterface("Interface.CImeEdit"));
	OwnerWord[3] = CImeEdit(AddInterface("Interface.CImeEdit"));


	for(i = 0 ; i < 4 ; i++)
	{
		if(OwnerWord[i] != None){			
			OwnerWord[i].bNative = true;
			OwnerWord[i].bMaskText = false;
			OwnerWord[i].bTestOutline = false;
			OwnerWord[i].SetMaxWidth(24);
			OwnerWord[i].SetSize(148, 20);
			OwnerWord[i].SetText("");
			OwnerWord[i].ShowInterface();
			OwnerWord[i].SetFocusEditBox(false);
		}
	}
	PetComment = CImeRichEdit(AddInterface("Interface.CImeRichEdit"));
	if(PetComment != None)
	{
		PetComment.ShowInterface();
		PetComment.SetSize(140, 144);
		PetComment.MaxLines = 6;
		PetComment.LineSpace = 21;
		PetComment.SetFocusEditBox(false);	
		TextColor = class'Canvas'.static.MakeColor(255,255,255);
		PetComment.SetTextColor(TextColor);
	}
	OwnerWord[0].SetFocusEditBox(true);

//	UITexture = Texture(DynamicLoadObject("PetUI.default.InputBack",class'Texture'));
	UITexture = TextureResources[0].Resource;
	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],TextureResources[1].Resource);
	SetSpriteTexture(UnitSprites[2],TextureResources[2].Resource);
	SetButtonResource(Buttons[0],-1,-1,-1,-1,Localize("PetUI","Apply","SephirothUI"));
	SetButtonResource(Buttons[1],-1,-1,-1,-1,Localize("PetUI","Close","SephirothUI"));

	SetButtonResource(Buttons[2],1,-1,-1,2);	//modified by yj

}

function OnFlush()
{
	local int i;

	for(i = 0 ; i < 4 ; i++)
	{
		if(OwnerWord[i] != None){
			OwnerWord[i].SetFocusEditBox(false);
			OwnerWord[i].HideInterface();
			RemoveInterface(OwnerWord[i]);
			OwnerWord[i] = None;
		}
	}
//	OwnerWord.Empty();
	if(PetComment != None)
	{
		PetComment.HideInterface();
		RemoveInterface(PetComment);
		PetComment = None;
	}
}

function LayOut(Canvas C)
{
	PageX = (C.ClipX-Components[0].XL)/2;
	PageY = (C.ClipY-Components[0].YL)/2;
	MoveComponentId(0,true,PageX,PageY);
	OwnerWord[0].SetPos(PageX+33,PageY+69);
	OwnerWord[1].SetPos(PageX+33,PageY+107);
	OwnerWord[2].SetPos(PageX+33,PageY+146);
	OwnerWord[3].SetPos(PageX+33,PageY+184);
	PetComment.SetPos(PageX+209,PageY+65);
	Super.LayOut(C);
}

function OnPostRender(HUD H, Canvas C)
{
	C.SetRenderStyleAlpha();
	//���
	DrawUnitSprite(C,UnitSprites[0],PageX,PageY,WinWidth,WinHeight);

	//Buttons
	DrawButtons(C);

	// "���θ�"
	C.DrawKoreanText(Localize("PetUI","OwnerWord","SephirothUI"),PageX+63,PageY+28,87,21);
	// "���ȭ"
	C.DrawKoreanText(Localize("PetUI","PetComment","SephirothUI"),PageX+239,PageY+28,87,21);
	C.Style = ERenderStyle.STY_Normal;
}

function ChangeEditFocus(bool bTurned)
{
	local int Index;
	local int i;

	if(!bTurned) {
		Index = -1;
		for(i = 0 ; i < 4 ; i++) 
		{
			if(OwnerWord[i].IsInBounds())
				Index = i;
			else if(OwnerWord[i].HasFocus())
				OwnerWord[i].SetFocusEditBox(false);
		}
		if(Index == -1 && PetComment.IsInBounds() && !PetComment.HasFocus())
			PetComment.SetFocusEditBox(true);
		else if(Index != -1 && !OwnerWord[Index].HasFocus())
			OwnerWord[Index].SetFocusEditBox(true);
	}
	else if(OwnerWord[0].HasFocus()) {
		OwnerWord[0].SetFocusEditBox(false);
		OwnerWord[1].SetFocusEditBox(true);
	}
	else if(OwnerWord[1].HasFocus()) {
		OwnerWord[1].SetFocusEditBox(false);
		OwnerWord[2].SetFocusEditBox(true);
	}
	else if(OwnerWord[2].HasFocus()) {
		OwnerWord[2].SetFocusEditBox(false);
		OwnerWord[3].SetFocusEditBox(true);
	}
	else if(OwnerWord[3].HasFocus()) {
		OwnerWord[3].SetFocusEditBox(false);
		PetComment.SetFocusEditBox(true);
	}
	else if(PetComment.HasFocus()) {
		PetComment.SetFocusEditBox(false);
		OwnerWord[0].SetFocusEditBox(true);
	}
}

function bool CanApplicantPetComment()
{
	local int i;
	if(PetComment.GetText() == "")
		return false;
	for(i = 0 ; i < 4 ; i++)
	{
		if(OwnerWord[i].GetText() != "")
			return true;
	}
	return false;
}

function bool OnkeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local ClientController CC;
	local int Index;
	local int i, nums;
	local array<string> KeyWords;
	local string KeyWord;

	CC = ClientController(PlayerOwner);

	if(Key == IK_Tab && Action == IST_Press) {
		ChangeEditFocus(true);
		return true;
	}
	if(Key == IK_Enter && Action == IST_Press) {
		ChangeEditFocus(true);
		return true;
	}
	if(Key ==IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if(Key == IK_LeftMouse && Action == IST_Press) {
		ChangeEditFocus(false);
		PressedButtonNum = CursorInButtons();
	}
	if(Key == IK_LeftMouse && Action == IST_Release) {
		if(PressedButtonNum != -1) {
			Index = PressedButtonNum;
			PressedButtonNum = -1;
			if(Buttons[Index].Id == BN_Exit) {
				Parent.NotifyInterface(Self,INT_Close);
				return true;
			}
			if(Buttons[Index].Id == BN_Apply) {
				if(CanApplicantPetComment()) {
					for(i = 0 ; i < OwnerWord.Length ; i++)
					{
						KeyWord = OwnerWord[i].GetText();

						if(KeyWord != "")
						{
							//Log("=====>PetCommentResist "$KeyWord);
							KeyWords[nums] = KeyWord;
							nums++;
						}

						OwnerWord[i].SetText("");
					}

					SephirothPlayer(PlayerOwner).Net.NotiPetchatAdd(KeyWords,PetComment.GetText());
					PetComment.SetText("");
					return true;
				}
				else {
					// "�� ��ȭ�� ���θ��� �Է����� ������ ����� �� �����ϴ�." �޼��� �ڽ� ���
					class'CMessageBox'.static.MessageBox(Self,"ApplyResist",Localize("Modals","InputPetChat","Sephiroth"),MB_Ok);
					return true;
				}
			}
		}
	}
	if((Key == IK_LeftMouse || Key == IK_RightMouse) && IsCursorInsideComponent(Components[0]))
		return true;
}

defaultproperties
{
     Buttons(0)=(Id=1,X=53.000000,Y=228.000000,XL=109.000000,YL=17.000000)
     Buttons(1)=(Id=2,X=228.000000,Y=228.000000,XL=109.000000,YL=17.000000)
     Buttons(2)=(Id=2,X=366.000000,Y=3.000000,XL=23.000000,YL=21.000000)
     UnitSprites(0)=(UL=390.000000,VL=276.000000)
     UnitSprites(1)=(UL=23.000000,VL=21.000000)
     UnitSprites(2)=(UL=23.000000,VL=21.000000)
     PressedButtonNum=-1
     Components(0)=(XL=390.000000,YL=276.000000)
     TextureResources(0)=(Package="UI_2009",Path="Win10",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN01_01_N",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN01_01_O",Style=STY_Alpha)
     WinWidth=390.000000
     WinHeight=276.000000
}
