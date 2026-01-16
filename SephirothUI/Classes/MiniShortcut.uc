class MiniShortcut extends CInterface;

const BN_HotKeyUp = 100;
const BN_HotKeyDown = 200;

var int iOffsetX;
var int iOffsetY;

function OnInit()
{
	// ����Ű ���� ��ư
	SetComponentTextureId(Components[1],0,-1,1,2);
	SetComponentTextureId(Components[2],3,-1,4,5);
	SetComponentNotify(Components[1],BN_HotKeyUp,Self);
	SetComponentNotify(Components[2],BN_HotKeyDown,Self);
}

function MoveShortcut(int offsetX, int offsetY)
{
	iOffsetX = offsetX;
	iOffsetY = offsetY;
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,C.ClipX - (iOffsetX + WinWidth), C.ClipY - (iOffsetY + WinHeight));
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.Layout(C);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId)
	{
	case BN_HotKeyUp:
		Parent.NotifyInterface(Self,INT_Command,"HotKeyUp");
		break;
	case BN_HotKeyDown:
		Parent.NotifyInterface(Self,INT_Command,"HotKeyDown");
		break;
	}
}

function OnPreRender(Canvas C)
{
	local int i;
	MoveComponentId(0,true,C.ClipX - (iOffsetX + WinWidth), C.ClipY - (iOffsetY + WinHeight));
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);

	Components[3].Caption = string(SephirothInterface(Parent).QuickSlotIndex);
}

function OnPostRender(HUD H, Canvas C)
{
	DrawPotions(C);
}

function DrawPotions(Canvas C)
{
	local SephirothPlayer PC;
	local int i,PotionKind,ScrollKind,XX,YY;
	local float XL,YL;
	local string HotkeyName, strNum;
	local byte HotkeyType;
	local Material Sprite;
	local int Amount;
	local array<SephirothItem> Items;
	local SephirothItem Item;
	local color OldColor;
	local SephirothInventory SepInventory;
	local int ItemCount;

	local int HotKeyPos;
	local int QuickSlotColumns;
	local int QuickSlotRows;
	local int QuickSlotIndex;

	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;
	QuickSlotColumns =	class 'QuickKeyConst'.default.QuickSlotColumns;
	QuickSlotRows =		class 'QuickKeyConst'.default.QuickSlotRows;

	OldColor = C.DrawColor;

	PC = SephirothPlayer(PlayerOwner);
	SepInventory = PC.PSI.SepInventory;
	for (i=0;i<QuickSlotRows;i++)
	{
		HotKeyPos = QuickSlotIndex*QuickSlotRows + i;

		HotkeyName = PC.PSI.QuickKeys[HotKeyPos].KeyName;
		HotkeyType = PC.PSI.QuickKeys[HotKeyPos].Type;
		if (HotkeyName != "") {
			Item = SepInventory.FirstMatched(0, HotkeyName);
			if (Item != None) {
				switch (HotkeyType) {
				case class'GConst'.default.BTPotion:
					PotionKind++;
					break;
				case class'GConst'.default.BTScroll:
					ScrollKind++;
					break;
				}
			}
			/*!@ �������� �������� �ʴ� ���(������ �� ����ȴٵ���..) 2004.1.28,jhjung*/
			else {
				HotkeyName = SephirothInterface(Parent).GetHotkeyModelName(HotkeyName);
				if (HotkeyName != "") {
					switch (HotkeyType) {
					case class'GConst'.default.BTPotion:
						PotionKind++;
						break;
					case class'GConst'.default.BTScroll:
						ScrollKind++;
						break;
					}
				}
			}
			/**/
		}
	}
	if (PotionKind == 0 && ScrollKind == 0)
		return;

	XX = C.ClipX - (iOffsetX + WinWidth) - (PotionKind + ScrollKind) * 32;
	YY = C.ClipY - (iOffsetY + WinHeight);
	C.SetRenderStyleAlpha();
	for (i=0;i<QuickSlotRows;i++)
	{
		HotKeyPos = QuickSlotIndex*QuickSlotRows + i;

		Sprite = None;
		Amount = 0;
		HotkeyName = PC.PSI.QuickKeys[HotKeyPos].KeyName;
		HotkeyType = PC.PSI.QuickKeys[HotKeyPos].Type;
		if (HotkeyType == class'GConst'.default.BTPotion || HotkeyType == class'GConst'.default.BTScroll)
		{
			ItemCount = SepInventory.FindItemToArray(0, HotkeyName, Items);
			if (ItemCount > 0)
			{
				Sprite = Items[0].GetMaterial(SephirothPlayer(PlayerOwner).PSI);
				Amount = PC.PSI.QuickKeys[HotKeyPos].Amount; //!@ ĳ���� ���� �̿��ϱ�� ��. 2004.1.28,jhjung, woojin
			}
			else
			{
				/*!@ �������� �κ��� ������, ĳ���� ������ ���� �ؽ��ĸ� �ε��Ѵ�. 2004.1.28,jhjung*/
				HotkeyName = SephirothInterface(Parent).GetHotkeyModelName(HotkeyName);
				//Log(HotkeyName);
				if (HotkeyName != "")
					Sprite = Material(DynamicLoadObject("ItemSprites." $ HotkeyName, class'Material'));
				Amount = 0;
			}

			if (Sprite != None)
			{
				C.SetPos(XX,YY);
				if (Amount == 0)
					C.SetDrawColor(128,128,128);
				else
					C.DrawColor = OldColor;
				C.DrawTile(Sprite,32,32,0,0,32,32);
				C.SetPos(XX,YY);
				//C.DrawTile(Texture'Keymap',10,10,i*10,0,10,10);
				//add neive : �̴ϼ��� ����Ű ���� ǥ�� -----------------------
				C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
				//C.SetDrawColor(75,75,75,100);
				//C.DrawTile(Controller.BackgroundBlend, 14,14,0,0,0,0);
				C.SetDrawColor(222, 210, 63);
				if(i == 9)
					strNum = "0";
				else if(i == 10)
					strNum = "-";
				else if(i == 11)
					strNum = "=";
				else
					strNum = ""$(i+1);
				C.DrawKoreanText(strNum,XX,YY,0,0);
				//-------------------------------------------------------------
				C.TextSize(string(Amount),XL,YL);
				C.SetPos(XX+32-XL,YY+32-YL);
				C.DrawTile(Controller.BackgroundBlend,XL,YL,0,0,0,0);
				C.KTextFormat = ETextAlign.TA_MiddleCenter;
				C.SetDrawColor(0,0,0);
				if(Amount == -99)
					C.DrawKoreanText("��",XX+32-XL,YY+32-YL,XL,YL);
				else
				C.DrawKoreanText(Amount,XX+32-XL+1,YY+32-YL+1,XL,YL);
				C.DrawColor = OldColor;
				if(Amount == -99)
					C.DrawKoreanText("��",XX+32-XL,YY+32-YL,XL,YL);
				else
				C.DrawKoreanText(Amount,XX+32-XL,YY+32-YL,XL,YL);
				XX += 32;
			}
		}
	}
}

function bool PointCheck()
{
	local int i;
	for (i=1;i<Components.Length;i++)
	{
		if (IsCursorInsideComponent(Components[i]) && (Components[i].bVisible == true))
		{
			return true;
		}
	}

	return false;
}

defaultproperties
{
     Components(0)=(XL=11.000000,YL=32.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=11.000000,YL=11.000000,PivotDir=PVT_Copy,ToolTip="HotKeyUp")
     Components(2)=(Id=2,Type=RES_PushButton,XL=11.000000,YL=11.000000,PivotDir=PVT_Copy,OffsetYL=21.000000,ToolTip="HotKeyDown")
     Components(3)=(Id=3,Caption="0",Type=RES_Text,XL=11.000000,YL=10.000000,PivotDir=PVT_Copy,OffsetYL=11.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     TextureResources(0)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton00",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton00A",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton00B",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton02",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton02A",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_Remodel",Path="Main.SlotMF_MiniBotton02B",Style=STY_Alpha)
     WinWidth=11.000000
     WinHeight=32.000000
}
