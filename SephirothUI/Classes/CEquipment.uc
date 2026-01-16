class CEquipment extends CSelectable;

const IDS_Channel1 = 1;
const IDS_Channel2 = 2;
const IDM_SellItem = 3;
const IDM_RepairItem = 4;
const IDM_SelectChannel = 5;
const IDM_WEARSEALEDITEM = 6;
const IDM_SWAP_ITEM = 7;

var WornItems WornItems;
var InterfaceRegion ItemRegion[32]; //ref neive : ������ �߰� 26->27		// 2011/04/14 ssemp ��� ���� �������� ���� ��չ��� ��ġ �־���..

var SephirothItem SelectedItem;
var SephirothItem SelectedShell;

var float OffsetXL;
var float OffsetYL;

var ChannelMenu ChannelMenu;

const CB_ArmHelmet = 100;
const BN_Exit = 101;

// Xelloss
var SephirothItem	PickupItem;			// �̵��Ϸ��� ����� ������
var int				nDropPlace;			// ���� �ڸ�
var CInterface		PickupSource;		// ����� �������� �ҽ��������̽�

var string m_sTitle;

function OnInit()
{
	WornItems = SephirothPlayer(PlayerOwner).PSI.WornItems;
	WornItems.OnDrawItem = InternalDrawItem;

	Components[3].NotifyId = BN_Exit;
	SetComponentTextureId(Components[3],1,0,2,3);

	Components[2].NotifyId = CB_ArmHelmet;
	
	//add neive : ���� �ý��� ���� �߿��� ���(ĸ) ���߱� ���̱� ��� ����� --
	if(SephirothPlayer(PlayerOwner).PSI.bTransformed || SephirothPlayer(PlayerOwner).PSI.TransToMonsterName != "")
		Components[2].bVisible = false;
	else
		Components[2].bVisible = true;
	//-------------------------------------------------------------------------

	m_sTitle = Localize("InventoryUI", "Equipment", "SephirothUI");

	GotoState('Nothing');
}


function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[0],true,C.ClipX-Components[0].XL*Components[0].ScaleX-OffsetXL,OffsetYL);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
	Super.Layout(C);
}

function Render(Canvas C)
{
	Super.Render(C);

	DrawTitle(C, m_sTitle);

	RenderDropArea(C);
}

function bool KeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Parent.IsA('CStore') && KeyEvent_Store(Key,Action,Delta))
		return true;

	return Super.KeyEvent(Key,Action,Delta);
}


function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)	{

	local SephirothItem Item;
	local int EquipPlace;

	if ( Key == IK_Escape && Action == IST_Press )	{

		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}

	if ( Key == IK_RightMouse && Action == IST_Release )	{

		Item = GetItemUnderCursor(EquipPlace);
		
		if ( Item != None && Item.IsShell() )	{

			SelectedShell = Item;
			class'CMessageBoxChannel'.static.MessageBoxChannel(Self, "WhatToDoForChannel", Localize("Modals", "WhatToDoForChannel", "Sephiroth"), IDM_SelectChannel);
			return true;
		}
	}
}

function DrawItemBack(Canvas C, int OffsetX, int OffsetY, int i)
{
	local int nResId;
	nResId = ItemRegion[i].UsedResId;

	C.SetRenderStyleAlpha();
	C.SetPos(OffsetX + ItemRegion[i].X, OffsetY + ItemRegion[i].Y);
	C.DrawTile(TextureResources[nResId].Resource, ItemRegion[i].W, ItemRegion[i].H, 0, 0, ItemRegion[i].W, ItemRegion[i].H);
}

function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local material Sprite;
	local int X, Y, XL, YL, nPlaceIndex;

//	local float XX,YY;

	nPlaceIndex = Item.EquipPlace;

	Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
	X = OffsetX + ItemRegion[nPlaceIndex].X + ItemRegion[nPlaceIndex].W / 2;
	Y = OffsetY + ItemRegion[nPlaceIndex].Y + ItemRegion[nPlaceIndex].H / 2;
	XL = Item.Width * 25;
	YL = Item.Height * 25;
	X = X - XL / 2;
	Y = Y - YL / 2;
	DrawItemBack(C, OffsetX, OffsetY, nPlaceIndex);
	C.SetPos(X, Y);
	C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
	if (Item.IsQuiver()) {
		C.SetPos(X,Y);
		C.SetDrawColor(255,255,255);
		C.DrawText(Item.Amount);
	}
/*
	XX = Components[0].X;
	YY = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("InventoryUI","Equipment","SephirothUI"),XX+2,YY+6,390,20);*/
}

function SephirothItem GetItemUnderCursor(out int EquipPlace)
{
	local int i;
	local InterfaceRegion Rgn;

	if (!IsCursorInsideComponent(Components[0]) || Controller.Modal()) {
		EquipPlace = -1;
		return None;
	}

	for (i=0;i<ArrayCount(ItemRegion);i++) {
		Rgn = ItemRegion[i];
		Rgn.X += Components[0].X;
		Rgn.Y += Components[0].Y;
		if (IsCursorInsideRegion(Rgn)) {
			EquipPlace = i;
			return WornItems.FindItem(i);
		}
	}
	EquipPlace = -1;
	return None;
}

function ShowItemInfo(Canvas C,CInfoBox InfoBox)
{
	local SephirothItem Item;
	local int EquipPlace;

	if (!IsCursorInsideComponent(Components[0]))
		return;
	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) 
	{
		InfoBox.SetInfo(None);
		return;
	}

	//add neive : 12�� ������ ��Ʈ ȿ�� ---------------------------------------
	SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel();
	//-------------------------------------------------------------------------

	Item = GetItemUnderCursor(EquipPlace);
	if (Item != None && Controller.bMouseMoved)
		InfoBox.SetInfo(Item, Controller.MouseX, Controller.MouseY, true, C.ClipX, C.ClipY);
}

function DrawItemEquipPlaces(Canvas C, int OffsetX, int OffsetY, int i)
{
	local int nResId;
	nResId = ItemRegion[i].OverResId;

	C.SetRenderStyleAlpha();
	C.SetPos(OffsetX + ItemRegion[i].X, OffsetY + ItemRegion[i].Y);
	C.DrawTile(TextureResources[nResId].Resource, ItemRegion[i].W, ItemRegion[i].H, 0, 0, ItemRegion[i].W, ItemRegion[i].H);
}

function Render_EquipPlaces(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local int i, EquipPlace;
	local array<int> EquipPlaces;
	if(Item.CanEquip()) //add neive : ���� ���ȭ
	{
//		//Log("neive : check Render_Equip 1");
		EquipPlaces = WornItems.FindEquipPlaces(Item);

		for (i=0;i<EquipPlaces.Length;i++) {
			EquipPlace = EquipPlaces[i];
			DrawItemEquipPlaces(C, OffsetX, OffsetY, EquipPlace);
			
			//C.SetPos(OffsetX + ItemRegion[EquipPlace].X, OffsetY + ItemRegion[EquipPlace].Y);
			//C.DrawTile(Texture'CanDrop', ItemRegion[EquipPlace].W, ItemRegion[EquipPlace].H, 0, 0, 1, 1);
		}
	}
}


function DrawObject(Canvas C)
{
	local int i;
	//add neive : ���� �ý��� ���� �߿��� ���(ĸ) ���߱� ���̱� ��� ����� --
	if(SephirothPlayer(PlayerOwner).PSI.TransToMonsterName != "" || SephirothPlayer(PlayerOwner).PSI.bTransformed)
		Components[2].bVisible = false;
	else
		Components[2].bVisible = true;
	//-------------------------------------------------------------------------

	if(false)	// ����ĭ �ܰ� ���� ���̱�
		for(i=0; i<29; i++)
		{
			C.SetPos(Components[0].X+ItemRegion[i].X,Components[0].Y+ItemRegion[i].Y);
			C.DrawRect1Fix(ItemRegion[i].W,ItemRegion[i].H);
		}

	C.SetDrawColor(255,255,255);
	C.SetRenderStyleAlpha();
	WornItems.DrawItems(C, Components[0].X, Components[0].Y);
/*
	ISI = SephirothItem(Controller.SelectedList[0]);
	Render_EquipPlaces(C, ISI, Components[0].X, Components[0].Y);
*/
	RenderDragging(C);
}


function bool ObjectSelecting()
{
	local int EquipPlace;
	local CStore Store;

	local SephirothItem Item;
	
	//add neive : ���� ������ �޺� ��ų�� �ٲ��ش� ----------------------------
/*	if(WornItems.IsEquipWeapon() == false) // ���⸦ �����ϰ� �ִ��� ����
	{
		//NormalSkill = "ComboSplash";//"Unarmed";
		//SephirothPlayer(PlayerOwner).SetHotSkill(0, NormalSkill); // 0 �� �޺���ų�̶�� ��
		SephirothPlayer(PlayerOwner).Net.NotiSkillAssign(0, "UnArmed1");
	}*/
	//-------------------------------------------------------------------------


	Store = CStore(Parent);
	
	if(Parent.IsA('CStore') && Store.Store.ActionState == Store.Store.BN_Repair)
		return false;

	Item = GetItemUnderCursor(EquipPlace);

	if(Item != None)
	{
		Controller.MergeSelectCandidate(Item);
		return true;
	}

	return false;
}

function bool CanDrag()
{
	return Controller.IsSomethingSelected();
}


/*
function RenderDragging(Canvas C)
{
	local SephirothItem ISI;
	local Material Sprite;

	if (Controller.Modal())
		return;

	if(Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			if (Controller.DragSource.IsA('CBag'))
				Render_EquipPlaces(C, ISI, Components[0].X, Components[0].Y);
			
			Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

			if (Sprite != None)
			{
				C.SetRenderStyleAlpha();
				C.SetPos(Controller.MouseX - ISI.Width*12, Controller.MouseY - ISI.Height*12);
				C.DrawTile(Sprite, ISI.Width*24, ISI.Height*24, 0, 0, ISI.Width*24, ISI.Height*24);
			}
		}
	}
}
*/


function RenderDropArea(Canvas C)
{
	local SephirothItem ISI;
	local Material Sprite;

//	local CStore Store;

//	Store = CStore(Parent);
//	if (Store != None && (/*Store.Store.ActionState == Store.Store.BN_Sell || */Store.Store.ActionState == Store.Store.BN_Repair))
//		return;

	if (Controller.Modal())
		return;

	if (Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			if ( Controller.DragSource.IsA('CBag') || Controller.DragSource.IsA('CBagResizable') )
				Render_EquipPlaces(C, ISI, Components[0].X, Components[0].Y);
		}
	}
}


function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	local SephirothItem Shell;
	switch (NotifyID) {
	case IDS_Channel1:
		Shell = WornItems.FindItem(WornItems.IP_REar);
		if (Shell != None && EditText != Shell.Channel)
			SephirothPlayer(PlayerOwner).Net.NotiSetChannelWorn(Shell.EquipPlace, EditText);
		break;
	case IDS_Channel2:
		Shell = WornItems.FindItem(WornItems.IP_LEar);
		if (Shell != None && EditText != Shell.Channel)
			SephirothPlayer(PlayerOwner).Net.NotiSetChannelWorn(Shell.EquipPlace, EditText);
		break;
	}
}


function bool KeyEvent_Store(Console.EInputKey Key, Console.EInputAction Action, FLOAT Delta)
{
	local CStore Store;
	local int EquipPlace;
	local string strMoney;

	if (!IsCursorInsideComponent(Components[0]))
		return false;

	Store = CStore(Parent);
	if (Store == None)
		return false;

	if (Action == IST_Press && Key == IK_LeftMouse) 
	{
		if (Store.Store.ActionState == Store.Store.BN_Repair) {
			SelectedItem = GetItemUnderCursor(EquipPlace);
			if (SelectedItem != None) {
				if (SelectedItem.IsRecyclable() && SelectedItem.Durability < SelectedItem.MaxDurability && SelectedItem.RepairPrice > 0) {
					strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, SelectedItem.strRepairPrice);
					class'CMessageBox'.static.MessageBox(Self,"RepairItem",Localize("Modals","TitleItemRepair","Sephiroth") 
						$ "\\n" 
						$ Localize("Modals","BeforeRepair","Sephiroth") 
						$ ": " 
						$ Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) 
						$ "\\n" 
						$ Localize("Modals","AfterRepair","Sephiroth") 
						$ ": " 
						$ Controller.MoneyStringEx(strMoney), 
						MB_YesNo, IDM_RepairItem);
					GotoState('Dragging');
				}else if(SelectedItem.IsDisposable() && SelectedItem.IsSeaShell()){  //@cs added ����������
					strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, "10000000");
					class'CMessageBox'.static.MessageBox(Self,"RepairItem",Localize("Modals","TitleItemRepair","Sephiroth") 
						$ "\\n" 
						$ Localize("Modals","BeforeRepair","Sephiroth") 
						$ ": " 
						$ Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) 
						$ "\\n" 
						$ Localize("Modals","AfterRepair","Sephiroth") 
						$ ": " 
						$ Controller.MoneyStringEx(strMoney), 
						MB_YesNo, IDM_RepairItem);
					GotoState('Dragging');
				}
				else
					PlayerOwner.myHud.AddMessage(2,Localize("Information","UselessRepair","Sephiroth"),class'Canvas'.static.MakeColor(255,255,0));
				
				
				return true;
			}
		}
	}
	
	if(Key == IK_LeftMouse && Action == IST_Release)
	{
		LMRelease_Store(Key, Action);
	}

	return false;
}


function bool LMRelease_Store(Console.EInputKey Key, Console.EInputAction Action)
{
	if(Controller.SelectingSource != None && Controller.SelectingSource.IsA('CBag'))
	{
		CBag(Controller.SelectingSource).LMRelease_Store(Key, Action);
	}

	return true;
}

function bool CheckEquip()
{
	local PlayerServerInfo PSI;
	local WornItems WI;
	local string sRes;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	WI = SephirothPlayer(PlayerOwner).PSI.WornItems;
	
	sRes = WI.CheckEquip(PickupItem, PSI.JobName, PSI.PlayLevel, PSI.Str, PSI.Dex, PSI.Vigor, PSI.GetMagicValue(),
		PSI.Red, PSI.Blue);
	if(sRes == "")
		return true;

	class'CMessageBox'.static.MessageBox(self, "EquipFailed", Localize("Equip",sRes,"SephirothUI"), MB_Ok);
	return false;
}

function NotifyInterface(CInterface Interface ,EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Value,Space;
	local string Cmd, Param;
	local CTextSelectBox ChannelChoice;
	local array<string> ChannelStrings;

	if (NotifyType == INT_MessageBox)
	{
		Value = int(Command);

		switch ( Value )
		{
		case IDM_RepairItem :

			SephirothPlayer(PlayerOwner).Net.NotiRepairWorn(CStore(Parent).Store.ShopNpc.PanId, SelectedItem.EquipPlace);
			Parent.bIgnoreKeyEvents = false;
			break;

		case IDM_SellItem :

			SephirothPlayer(PlayerOwner).Net.NotiSellWorn(CStore(Parent).Store.ShopNpc.PanId, SelectedItem.EquipPlace);
			Parent.bIgnoreKeyEvents = false;
			break;

		case IDM_SelectChannel :

			class'CNativeInterface'.static.WrapStringToArray(Localize("Information","ChannelList","Sephiroth"), ChannelStrings, 10000, "|");
			ChannelChoice = class'CTextSelectBox'.static.PopupTextSelectBox(Self, Localize("Information","SelectChannel","Sephiroth"), ChannelStrings, false);

			if (ChannelChoice != None)
				ChannelChoice.OnSelectChoice = InternalSelectChannel;

			break;

		case -1 * IDM_SelectChannel :
			if (SelectedShell == None)
				return;

			if (SelectedShell.EquipPlace == 14)
				class'CEditBox'.static.EditBox(Self,"SetChannel",Localize("Modals","TitleItemSetChannel","Sephiroth"),IDS_Channel1,10,SelectedShell.Channel);
			else
				class'CEditBox'.static.EditBox(Self,"SetChannel",Localize("Modals","TitleItemSetChannel","Sephiroth"),IDS_Channel2,10,SelectedShell.Channel);

			SelectedShell = None;
			break;

		case IDM_WEARSEALEDITEM :
			if(!CheckEquip())
				return ;
			// �κ��丮 : 0, �����κ��丮 1, 2, 3
			if ( PickupSource.IsA('CBag') )
				SephirothPlayer(PlayerOwner).Net.NotiWearItem(0, PickupItem.X, PickupItem.Y, nDropPlace);
			else if ( PickupSource.IsA('CBagResizable') )
				SephirothPlayer(PlayerOwner).Net.NotiWearItem(CBagResizable(PickupSource).SubInvenIndex + 1, PickupItem.X, PickupItem.Y, nDropPlace);

			Controller.ResetDragAndDropAll();
			break;

		case IDM_SWAP_ITEM:
			if(!CheckEquip())
				return ;
			if ( PickupSource.IsA('CBag') )
				SephirothPlayer(PlayerOwner).Net.NotiSwapEquipment(nDropPlace, 0, PickupItem.X, PickupItem.Y);
			else if ( PickupSource.IsA('CBagResizable') )
				SephirothPlayer(PlayerOwner).Net.NotiSwapEquipment(nDropPlace, CBagResizable(PickupSource).SubInvenIndex + 1, PickupItem.X, PickupItem.Y);
			Controller.ResetDragAndDropAll();
			break;
		}
	}
	else if ( NotifyType == INT_Close )
	{
		if (Interface == ChannelMenu)
		{
			ChannelMenu.HideInterface();
			RemoveInterface(ChannelMenu);
			ChannelMenu = None;
		}

//		Parent.NotifyInterface(Self, INT_Close);
	}
	else if (NotifyType == INT_Command)
	{
		Space = InStr(Command," ");

		if (Space != -1)
		{
			Cmd = Left(Command,Space);
			Param = Mid(Command,Space+1);

			if (Cmd == "SetChannel")
			{
				if (SelectedShell != None)
				{
					if (SelectedShell.EquipPlace == 14)
						NotifyEditBox(Self,IDS_Channel1,Param);
					else if (SelectedShell.EquipPlace == 15)
						NotifyEditBox(Self,IDS_Channel2,Param);
				}
			}
		}
	}

	GotoState('Nothing');
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetobjectList();
	Controller.SelectingSource = None;
	Controller.DragSource = None;
}


function InternalSelectChannel(int Index, string Channel)
{
	if (Index >= 0 && Channel != "" && SelectedShell != None)
		SephirothPlayer(PlayerOwner).Net.NotiSetChannelWorn(SelectedShell.EquipPlace, Channel);
	SelectedShell = None;
}


function bool PushComponentBool(int CmpId)
{
	if (CmpId == 2) {
		return bool(ConsoleCommand("GETOPTIONI ArmHelmet"));
	}
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local Hero myHero;
	local bool bAlreadyArmed;

	Parent.NotifyInterface(Self, INT_Command, "ClearInfo");

	switch (NotifyId)	{

	case BN_EXIT :

		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self, INT_Close);
		break;
		
	case CB_ArmHelmet :

		myHero = Hero(PlayerOwner.Pawn);
		bAlreadyArmed = myHero.bArmed;
		if (bAlreadyArmed)
			myHero.Disarm();
		if (Command == "Checked")
			ConsoleCommand("SETOPTIONB ArmHelmet"@true);
		else if (Command == "UnChecked")
			ConsoleCommand("SETOPTIONB ArmHelmet"@false);		
		if (bAlreadyArmed)
			myHero.Arm();
		break;
	}
}


function bool Drop()
{
	local SephirothItem TargetItem;			// ����߸� ��ġ�� �������� �𸣴� ������
	local int nTempPlace;

	// ������ ������ ������ �ʴ´�.
	if (Controller.SelectedList.Length > 1)
		return false;

	PickupItem = SephirothItem(Controller.SelectedList[0]);
	PickupSource = Controller.DragSource;						// �׼��� ������ ������ �� �����Ƿ� �Űܳ��´�. (�޽��� ó���ÿ� ���� �ʿ�)

	if ( PickupItem != None && PickupSource != None )
	{
		TargetItem = GetItemUnderCursor(nDropPlace);		// ���� ��ġ�� �������� �ִ��� Ȯ��
 		nTempPlace = nDropPlace;

		// ����â ���ο����� �̵��� ������� �ʴ´�.
		if ( PickupSource == Self )
		{
			// Ŀ���� ���â �ȿ� �ִ��� üũ
			if (IsCursorInsideComponent(Components[0]))
			{
				PickupSource = None;
				return true;
			}
		}
		else if ( PickupSource.IsA('CBag') || PickupSource.IsA('CBagResizable') )		// �����̳� Ȯ�尡�濡 ���ؼ�
		{
			// ĭ�� ��� ���� ������, ���� ������ ��� �ִ� ĭ�� ã�� ������ �õ��Ѵ�.
			if (TargetItem != None || nDropPlace == -1)
			{
				nDropPlace = WornItems.FindEquipPlace(TargetItem);
/*
				if (nDropPlace == WornItems.IP_NoPlace)
				{
					PickupSource = None;
					return true;
				}*/
			}

			if (nDropPlace != WornItems.IP_Used)	// ���� ���� ������ ���� ��
			{
				if ( PickUpItem.xSealFlag == PickUpItem.eSEALFLAG.SF_SEALED )
					class'CMessageBox'.static.MessageBox(self, "EquipSealedItem", Localize("Modals", "EquipSealedItem", "Sephiroth"), MB_YesNo, IDM_WEARSEALEDITEM);
				else
					NotifyInterface(Self, INT_MessageBox, IDM_WEARSEALEDITEM);
			}
			else if (nDropPlace == WornItems.IP_Used)		// ���ų� �̹� ���� ���� ��
			{
				if (WornItems.IsSwapAbleTime(Level.TimeSeconds) == false)
					return false;

				if(!CheckEquip())
					return false;
//				nDropPlace = WornItems.FindEquipAblePlace(PickUpItem);

				if ( PickUpItem.IsSeal() )
					class'CMessageBox'.static.MessageBox(Self, "EquipSealedItem", Localize("Modals", "EquipSealedItem", "Sephiroth"), MB_YesNo, IDM_SWAP_ITEM);
				else
					SephirothPlayer(PlayerOwner).Net.NotiSwapEquipment(nTempPlace,0,PickUpItem.X,PickUpItem.Y);
			}

			return true;
		}
	}

	return false;
}

defaultproperties
{
     ItemRegion(0)=(X=96.000000,Y=112.000000,W=78.000000,H=30.000000,OverResId=16,UsedResId=7)
     ItemRegion(1)=(X=108.000000,Y=51.000000,W=54.000000,H=54.000000,OverResId=24,UsedResId=11)
     ItemRegion(2)=(X=96.000000,Y=148.000000,W=78.000000,H=126.000000,OverResId=14,UsedResId=5)
     ItemRegion(3)=(X=108.000000,Y=316.000000,W=54.000000,H=78.000000,OverResId=18,UsedResId=9)
     ItemRegion(4)=(X=25.000000,Y=244.000000,W=61.000000,H=61.000000,OverResId=15,UsedResId=6)
     ItemRegion(5)=(X=184.000000,Y=244.000000,W=61.000000,H=61.000000,OverResId=15,UsedResId=6)
     ItemRegion(6)=(X=41.000000,Y=313.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(7)=(X=199.000000,Y=313.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(8)=(X=25.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=21,UsedResId=12)
     ItemRegion(9)=(X=184.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=25,UsedResId=12)
     ItemRegion(10)=(X=25.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(11)=(X=56.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(12)=(X=184.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(13)=(X=215.000000,Y=351.000000,W=30.000000,H=30.000000,OverResId=17,UsedResId=8)
     ItemRegion(14)=(X=266.000000,Y=180.000000,W=54.000000,H=54.000000,OverResId=26,UsedResId=11)
     ItemRegion(15)=(X=325.000000,Y=180.000000,W=54.000000,H=54.000000,OverResId=26,UsedResId=11)
     ItemRegion(16)=(X=25.000000,Y=112.000000,W=61.000000,H=126.000000,OverResId=21,UsedResId=12)
     ItemRegion(17)=(X=76.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=13,UsedResId=4)
     ItemRegion(18)=(X=165.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=13,UsedResId=4)
     ItemRegion(19)=(X=277.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(20)=(X=313.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(21)=(X=349.000000,Y=51.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(22)=(X=277.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(23)=(X=313.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(24)=(X=349.000000,Y=112.000000,W=30.000000,H=54.000000,OverResId=22,UsedResId=4)
     ItemRegion(25)=(X=266.000000,Y=238.000000,W=54.000000,H=54.000000,OverResId=20,UsedResId=11)
     ItemRegion(26)=(X=96.000000,Y=280.000000,W=78.000000,H=30.000000,OverResId=23,UsedResId=7)
     ItemRegion(27)=(X=325.000000,Y=238.000000,W=54.000000,H=54.000000,OverResId=20,UsedResId=11)
     ItemRegion(28)=(X=266.000000,Y=312.000000,W=54.000000,H=54.000000,OverResId=27,UsedResId=11)
     Components(0)=(XL=404.000000,YL=423.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=404.000000,YL=423.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Caption="ArmHelmet",Type=RES_CheckButton,XL=130.000000,YL=19.000000,PivotDir=PVT_Copy,OffsetXL=304.000000,OffsetYL=382.000000,TextAlign=TA_MiddleLeft,TextColor=(B=98,G=151,R=218,A=255),LocType=LCT_Terms)
     Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=374.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(4)=(Id=4,Type=RES_Text,XL=280.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=50.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     TextureResources(0)=(Package="UI_2011",Path="win_inven_2",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_inven_ear_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_inven_armor_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_inven_glv_n",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_inven_neck_n",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_inven_ring_n",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_inven_shoe_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_inven_sml_n",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_inven_sora_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_inven_swd_n",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_inven_ear_o",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_inven_armor_o",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_inven_glv_o",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_inven_neck_o",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="btn_inven_ring_o",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_inven_shoe_o",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_inven_sml_o",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011_btn",Path="btn_inven_sora_o",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011_btn",Path="btn_inven_swd_o",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2011_btn",Path="btn_inven_charm_o",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2011_btn",Path="btn_inven_belt_o",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2011_btn",Path="btn_inven_helmet_o",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2011_btn",Path="btn_inven_shield_o",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2011_btn",Path="btn_inven_sora_2_o",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2011_btn",Path="btn_inven_sora_3_o",Style=STY_Alpha)
     IsBottom=True
}
