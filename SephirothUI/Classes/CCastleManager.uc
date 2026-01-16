class CCastleManager extends CMultiInterface;

#exec OBJ LOAD FILE=../Textures/UI_Castle.utx PACKAGE=UI_Castle

const BN_NormalAdd	= 1;
const BN_NormalSub	= 2;
const BN_BoothAdd	= 3;
const BN_BoothSub	= 4;
const BN_Receipts	= 5;
const BN_Payment	= 6;
const BN_Exit		= 7;

const IDS_Receipts	= 1;
const IDS_Payment	= 2;


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
	var float X,Y,XL,YL;
	var int Normal, Disable, Pressed, Over;
};

var array<InterfaceButton> Buttons;
var array<SpriteImage> UnitSprites;
var Texture UITexture;
var int PressedButtonNum;
var float PageX,PageY;


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

function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture SprTexture;
	C.SetPos(X,Y);
	SprTexture = Sprite.Texture;
	C.DrawTile(SprTexture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}

function OnInit()
{
	UITexture = Texture(DynamicLoadObject("UI_Castle.default.Main",class'Texture'));	

	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],UITexture);
	SetSpriteTexture(UnitSprites[2],UITexture);
	SetSpriteTexture(UnitSprites[3],UITexture);
	SetSpriteTexture(UnitSprites[4],UITexture);
	SetSpriteTexture(UnitSprites[5],UITexture);
	SetSpriteTexture(UnitSprites[6],UITexture);
	SetSpriteTexture(UnitSprites[7],UITexture);

	SetButtonResource(Buttons[0],-1,-1,3,2);	// 일반 세율 +
	SetButtonResource(Buttons[1],-1,-1,5,4);	// 일반 세율 -
	SetButtonResource(Buttons[2],-1,-1,3,2);	// 노점 세율 +
	SetButtonResource(Buttons[3],-1,-1,5,4);	// 노점 세율 -
	SetButtonResource(Buttons[4],-1,-1,7,6);	// 입금
	SetButtonResource(Buttons[5],-1,-1,7,6);	// 출금
	SetButtonResource(Buttons[6],-1,-1,-1,1);	// Exit
}

function LayOut(Canvas C)
{
	PageX = C.ClipX - Components[0].XL;
	PageY = 0;
	MoveComponentId(0,true,PageX,PageY);
	Super.LayOut(C);
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local int Index;
	local float Sx,Sy,Ex,Ey;
	local string ClanName, CastleMoney;
	local int NormalTax;
	local int BoothTax;
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	//유아이 배경
	DrawUnitSprite(C, UnitSprites[0],PageX,PageY,WinWidth,WinHeight);

	//버튼들..
	for(i = 0 ; i < Buttons.Length ; i++)
	{
		Index = -1;

		Sx = PageX+Buttons[i].X;
		Sy = PageY+Buttons[i].Y;
		Ex = Sx+Buttons[i].XL;
		Ey = Sy+Buttons[i].YL;

		if(i == PressedButtonNum)
			Index = Buttons[i].Pressed;
		else if(Controller.MouseX > Sx && Controller.MouseX < Ex && Controller.MouseY > Sy && Controller.MouseY < Ey)
			Index = Buttons[i].Over;

		if(Index == -1)
			continue;

		DrawUnitSprite(C,UnitSprites[Index],Sx,Sy,Buttons[i].XL,Buttons[i].YL);
	}

	//소유 클랜 이름	
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	ClanName = CC.OwnedCastle.ClanName;
	C.DrawKoreanText(ClanName,PageX+98,PageY+29,102,24);
//	C.DrawKoreanText("ClanName",PageX+98,PageY+29,102,24);
	//"현재 소지금"
	C.DrawKoreanText(Localize("CastleUI","Cash","SephirothUI"),PageX+29,PageY+75,75,19);
	//금액
	C.KTextFormat = ETextAlign.TA_MiddleRight;
	CastleMoney = Controller.MoneyStringEx(CC.OwnedCastle.CastleMoney);
	C.DrawKoreanText(CastleMoney,PageX+118,PageY+75,107, 17);
//	C.DrawKoreanText("100,000,000",PageX+118,PageY+75,107, 17);
	//일반 세율
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.DrawKoreanText(Localize("CastleUI","NormalTax","SephirothUI"),PageX+39,PageY+123,50,20);
	NormalTax = int(CC.OwnedCastle.NormalTaxRate * 100);
	C.DrawKoreanText(NormalTax$" %",PageX+94,PageY+123,43,20);
//	C.DrawKoreanText("100 %",PageX+94,PageY+123,43,20);
	//노점 세율
	C.DrawKoreanText(Localize("CastleUI","BoothTax","SephirothUI"),PageX+39,PageY+165,50,20);
	BoothTax = int(CC.OwnedCastle.BoothTaxRate * 100);
	C.DrawKoreanText(BoothTax$" %",PageX+94,PageY+166,43,20);
	
	//입금
	C.DrawKoreanText(Localize("CastleUI","Receipts","SephirothUI"),PageX+222,PageY+120,32,27);
	//출금
	C.DrawKoreanText(Localize("CastleUI","Payment","SephirothUI"),PageX+222,PageY+161,32,27);		
}

function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	switch(NotifyId)
	{
	case IDS_Receipts:
		SephirothPlayer(PlayerOwner).Net.NotiCastleLordDepositMoney(CC.OwnedCastle.CastleName,EditText);
		break;

	case IDS_Payment:
		SephirothPlayer(PlayerOwner).Net.NotiCastleLordWithdrawMoney(CC.OwnedCastle.CastleName,EditText);
		break;
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int Index;
	local float NormalTax;
	local float BoothTax;
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if (Key == IK_LeftMouse && Action == IST_Press){
		PressedButtonNum = CursorInButtons();
		return true;
	}
	if(Key == IK_LeftMouse && Action == IST_Release) {
		Index = PressedButtonNum;
		if(Index != -1){
			PressedButtonNum = Index;
			if(Buttons[Index].Id == BN_Exit)
				Parent.NotifyInterface(Self,INT_Close);
			else if(Buttons[Index].Id == BN_NormalAdd) {
				NormalTax = CC.OwnedCastle.NormalTaxRate * 100;
				if(NormalTax < 100)
					NormalTax += 1.00f;
				SephirothPlayer(PlayerOwner).Net.NotiCastleLordTaxRate(CC.OwnedCastle.CastleName, NormalTax/100);
			}
			else if(Buttons[Index].Id == BN_NormalSub) {
				NormalTax = CC.OwnedCastle.NormalTaxRate * 100;
				if(NormalTax > 0)
					NormalTax -= 1.00f;
				SephirothPlayer(PlayerOwner).Net.NotiCastleLordTaxRate(CC.OwnedCastle.CastleName, NormalTax/100);
			}
			else if(Buttons[Index].Id == BN_BoothAdd) {
				BoothTax = CC.OwnedCastle.BoothTaxRate * 100;
				if(BoothTax < 91)
					BoothTax += 10.00f;
				SephirothPlayer(PlayerOwner).Net.NotiCastleLordBoothTaxRate(CC.OwnedCastle.CastleName, BoothTax/100);
			}
			else if(Buttons[Index].Id == BN_BoothSub) {
				BoothTax = CC.OwnedCastle.BoothTaxRate * 100;
				if(BoothTax > 9)
					BoothTax -= 10.00f;
				SephirothPlayer(PlayerOwner).Net.NotiCastleLordBoothTaxRate(CC.OwnedCastle.CastleName, BoothTax/100);
			}
			else if(Buttons[Index].Id == BN_Receipts) {
				class'CEditBox'.static.EditBox(Self, "Receipts", Localize("Modals","CastleMoneyReceipts","Sephiroth") ,IDS_Receipts, 10);
			}
			else if(Buttons[Index].Id == BN_Payment) {
				class'CEditBox'.static.EditBox(Self, "Payment", Localize("Modals","CastleMoneyPayment","Sephiroth") ,IDS_Payment, 10);
			}
			PressedButtonNum = -1;
		}
	}

	if(KEY == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
	{
		return true;
	}
	return false;
}

defaultproperties
{
     Buttons(0)=(Id=1,X=142.000000,Y=123.000000,XL=24.000000,YL=20.000000)
     Buttons(1)=(Id=2,X=171.000000,Y=123.000000,XL=24.000000,YL=20.000000)
     Buttons(2)=(Id=3,X=142.000000,Y=165.000000,XL=24.000000,YL=20.000000)
     Buttons(3)=(Id=4,X=171.000000,Y=165.000000,XL=24.000000,YL=20.000000)
     Buttons(4)=(Id=5,X=222.000000,Y=120.000000,XL=32.000000,YL=27.000000)
     Buttons(5)=(Id=6,X=222.000000,Y=161.000000,XL=32.000000,YL=27.000000)
     Buttons(6)=(Id=7,X=264.000000,XL=30.000000,YL=36.000000)
     UnitSprites(0)=(UL=294.000000,VL=226.000000)
     UnitSprites(1)=(U=360.000000,UL=30.000000,VL=36.000000)
     UnitSprites(2)=(U=320.000000,UL=24.000000,VL=20.000000)
     UnitSprites(3)=(U=320.000000,V=30.000000,UL=24.000000,VL=20.000000)
     UnitSprites(4)=(U=320.000000,V=60.000000,UL=24.000000,VL=20.000000)
     UnitSprites(5)=(U=320.000000,V=90.000000,UL=24.000000,VL=20.000000)
     UnitSprites(6)=(U=320.000000,V=120.000000,UL=32.000000,VL=27.000000)
     UnitSprites(7)=(U=320.000000,V=150.000000,UL=32.000000,VL=27.000000)
     PressedButtonNum=-1
     Components(0)=(XL=294.000000,YL=226.000000)
     WinWidth=294.000000
     WinHeight=226.000000
}
