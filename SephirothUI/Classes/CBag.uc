class CBag extends CSelectable;

#exec TEXTURE IMPORT NAME=Selected FILE=Textures/Normal_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=MagicSelected FILE=Textures/Magic_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=DivineSelected FILE=Textures/Divine_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=PlatinumSelected FILE=Textures/Platinum_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=CanDrop FILE=Textures/CanDrop.tga MIPS=Off
#exec TEXTURE IMPORT NAME=CannotDrop FILE=Textures/CannotDrop.tga MIPS=Off
#exec TEXTURE IMPORT NAME=Dirty FILE=Textures/DirtyItem.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ItemArea FILE=Textures/item_area_n.tga MIPS=Off
#exec TEXTURE IMPORT NAME=Sealed FILE=Textures/Seal.tga MIPS=Off FLAGS=2
#exec TEXTURE IMPORT NAME=Used FILE=Textures/Used.tga MIPS=Off FLAGS=2

const BN_Exit = 1;
const BN_Sort = 2;
const BN_Leni = 3;

const IDM_EnchantItem = 1;
const IDS_SplitItem = 2;
const IDS_MoneyToGround = 3;
const IDS_MoneyToStash = 4;
const IDM_SellItem = 5;
const IDM_RepairItem = 6;
const IDM_LevelUpItem = 7;//@by wj(08/27)
const IDS_PetName = 8; // @by wj(10/04)

const IDS_BoothBuyItemAmount = 9;
const IDM_BoothBuyItem = 10;

const IDM_WEARSEALEDITEM	= 12;		// Xelloss : ���ε� ������ ������ Ȯ��
const IDM_TRADEUSEDITEM		= 13;		// Xelloss : ���������� ������ �ŷ��� Ȯ��
const IDM_DROPUSEDITEM		= 14;		// Xelloss : ���������� ������ ������ Ȯ��
const IDM_SWAP_ITEM			= 15;		// Xelloss : ���ε� ������ ���ҽ� Ȯ��
const LockSec = 1;
const CellSize = 25;

const IDM_UNPACK_ITEM		= 16;		// ok ������ ���


var string m_sTitle;

var SephirothInventory SepInventory;

var SephirothItem EnchantGem;
var Point EnchantDest;
var SephirothItem SplitRaw;
var Point SplitDest;
var int SplitAmount;     

var array<SephirothItem> SelectedItemsList;
var bool bIsSellerBooth;
var bool bIsGuestBooth;
var bool bIsExchange;
var bool bIsRemodeling;
var bool bIsDissolve;

var float OffsetXL;
var float OffsetYL;

var SephirothItem ContextItem;
var SephirothItem LevelUpItem;//@by wj(08/27)

var int BoothBuyAmount;
var string strTotalMoney;

var SephirothItem SealedItem;		// Xelloss

var CTextSelectBox AffixChoice;

var string m_sUnpackCommand;

function OnInit()
{
	SetComponentTextureId(Components[2],1,0,3,2);
	SetComponentTextureId(Components[3],4,0,0,5);
	SetComponentNotify(Components[2],BN_Exit,Self);
	SetComponentNotify(Components[3],BN_Sort,Self);
	SetComponentNotify(Components[6],BN_Leni,Self);
	bIsExchange = Parent.IsA('CTrade');
	bIsSellerBooth = Parent.IsA('CBooth_Seller');
	bIsGuestBooth = Parent.IsA('CBooth_Guest');
	bIsRemodeling = Parent.IsA('ItemRemodeling');
	bIsDissolve = Parent.IsA('DissolveDiag');
	SepInventory = SephirothPlayer(PlayerOwner).PSI.SepInventory;
	SepInventory.OnDrawItem = InternalDrawItem;
	SepInventory.SelectAll(false);
	
	BoothBuyAmount = 0;
	strTotalMoney = "-1";

	m_sTitle = Localize("CBag","Title", "SephirothUI");

	GotoState('Nothing');
}

function OnFlush()
{
	SepInventory.OnDrawItem = None;

	if(Controller.bMouseDrag)
		Controller.bMouseDrag = false;

	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();

	Controller.ContextMenu = None;
}

function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[0],true,C.ClipX-Components[0].XL*Components[0].ScaleX-OffsetXL,OffsetYL);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
	Super.Layout(C);
}

function bool IsRegisteredItem(SephirothItem Item)
{
	local int i;

	for(i = 0 ; i < SelectedItemsList.Length ; i++)
	{
		if(Item == SelectedItemsList[i])
			return true;
	}
	return false;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Exit:
		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self,INT_Close);
		break;
	case BN_Sort:
		if( bIsSellerBooth || bIsGuestBooth || bIsDissolve )
			return;
		Parent.NotifyInterface(Self,INT_Command,"ClearInfo");
		SephirothPlayer(PlayerOwner).Net.NotiCommand("Bag Arrange");
		break;
	case BN_Leni:
		MoneyButtonProc();
		break;
	}
}


function MoneyButtonProc()
{
	if (Parent.IsA('CStashLobby'))
	{
		//// �� â�� ���� �Ұ� ������ ���� Mod ssemp
		//class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
		class'CEditBox'.static.MoneyEditBox(Self, "MoneyToStash", Localize("Modals","TitleMoneyToStash","Sephiroth") ,IDS_MoneyToStash, 20);
		//class'CMessageBox'.static.MessageBox(self, "HelpMsg", "���ϸ� �����Կ� ���� �� �ִ� ����� ��� ���� �����˴ϴ�.(�����Կ��� ���ϸ� ã�� ���� �����մϴ�.)", MB_Ok);
	}
	else if (Parent.IsA('InventoryBag'))
	{
		class'CEditBox'.static.MoneyEditBox(Self, "MoneyToGround", Localize("Modals","TitleMoneyToGround","Sephiroth"), IDS_MoneyToGround, 20);
	//	class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
	//	class'CMessageBox'.static.MessageBox(self, "HelpMsg", "���ϸ� ����� �� �ִ� ����� ��� ���� �����˴ϴ�.", MB_Ok);
	}
}


function Render_Items(Canvas C,int X,int Y)
{
	SepInventory.DrawItems(C,X,Y);
}

function OnPreRender(Canvas C)
{
	Components[6].Caption = Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney);
}

function ShowItemInfo(Canvas C, CInfoBox InfoBox)
{
	local Point Point;
	local SephirothItem ISI;
	local InterfaceRegion Rgn, RgnEnd;
	local color OldColor;

//	if (!IsCursorInsideComponent(Components[0]))
//		return;

	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) 
	{
		InfoBox.SetInfo(None);
		return;		
	}

	Point = ScreenToRowColumn(Components[4],Controller.MouseX,Controller.MouseY);

	if ( Point.X != -1 && Point.Y != -1 )	{

		ISI = SepInventory.GetItem_RC(Point.X, Point.Y);

		if ( ISI != None )	{

			Rgn = RowColumnToScreen(Components[4],ISI.Y,ISI.X);
			OldColor = C.DrawColor;
			C.SetDrawColor(114, 121, 196);
			C.SetPos(Rgn.X - 1, Rgn.Y - 1);
			DrawBox(C,Rgn.W*ISI.Width+ISI.Width,Rgn.H*ISI.Height+ISI.Height,1);
			RgnEnd = RowColumnToScreen(Components[4], ISI.Y + ISI.Height - 1, ISI.X + ISI.Width - 1);

			if ( bIsSellerBooth || bIsGuestBooth )
				CItemInfoBox(InfoBox).SetDisplayMethod(4);

			if ( Controller.bMouseMoved )	{

				InfoBox.SetInfo(ISI, RgnEnd.X + RgnEnd.W + 1, RgnEnd.Y + RgnEnd.H + 1, true, C.ClipX, C.ClipY);
			}

			C.DrawColor = OldColor;
		}
	}
}

function InternalSelectAffix(int AffixIndex, string Affix)
{
	if (EnchantGem != None && AffixIndex >= 0 && Affix != "")
        SephirothPlayer(PlayerOwner).Net.NotiApplySelect(EnchantGem.X, EnchantGem.Y, EnchantDest.X, EnchantDest.Y, string(AffixIndex), 0);
}

function bool KeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Parent.IsA('CStore') && KeyEvent_Store(Key,Action,Delta))
		return true;

	if(IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return true;

	return Super.KeyEvent(Key,Action,Delta);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local Point Point;
	local SephirothItem Item;
	local int EquipPlace;
	local WornItems WornItems;

	local string ContextString;
	local CTextMenu TextMenu;

	if(IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return true;

	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0])){
		return true;
	}

	if ((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		return false;

	if ((Parent.IsA('InventoryBag') || (Parent.IsA('CStashLobby') && !IsA('CStashBox')) || Parent.IsA('CCompound') ) && Key == IK_RightMouse && Action == IST_Release && IsCursorInsideComponent(Components[0])) {

		Point = ScreenToRowColumn(Components[4], Controller.MouseX, Controller.MouseY);
		if (Point.X != -1 && Point.Y != -1) {
			Item = SepInventory.GetItem_RC(Point.X, Point.Y);
			if (IsRegisteredItem(Item) || Item.bSelected)
				return true;

			if (Item != None) 
			{
				if (Item.IsPotion())
					ContextString = Localize("ContextMenu", "EatPotion", "Sephiroth");
//				else if (Item.IsReturnScroll() || Item.IsDetectScroll() || Item.IsSkillScroll())
				else if (Item.IsReturnScroll() || Item.IsSkillScroll())
					ContextString = Localize("ContextMenu", "UseScroll", "Sephiroth");
				else if (Item.IsStatGem())
					ContextString = Localize("ContextMenu", "ResetPoints", "Sephiroth");
				else if (Item.IsSkillBook())
					ContextString = Localize("ContextMenu", "UseSkillBook", "Sephiroth");
				//@by wj(10/07)------
				else if (Item.IsPetFood())
					ContextString = Localize("ContextMenu", "UseFood", "Sephiroth");
				else if (Item.IsPetCage())
					ContextString = Localize("ContextMenu", "PetRecall", "Sephiroth");
				//-------------------
				
				if (Item.HasAmount())
				{
					if(ContextString == "")	
						ContextString = Localize("ContextMenu", "SplitItem", "Sephiroth");
					else
						ContextString = ContextString $ "|" $ Localize("ContextMenu", "SplitItem", "Sephiroth");
				}

				WornItems = SephirothPlayer(PlayerOwner).PSI.WornItems;
				EquipPlace = WornItems.FindEquipPlace(Item);
				if (EquipPlace != WornItems.IP_NoPlace)
				{
					if(ContextString == "")
						ContextString = Localize("ContextMenu", "Equip", "Sephiroth");
					else
						ContextString = ContextString $ "|" $ Localize("ContextMenu", "Equip", "Sephiroth");
				}

				if(ContextString == "")
					ContextString = Localize("ContextMenu", "DropItem", "Sephiroth");
				else
					ContextString = ContextString $ "|" $ Localize("ContextMenu", "DropItem", "Sephiroth");

				TextMenu = PopupContextMenu(ContextString, Controller.MouseX, Controller.MouseY);
				TextMenu.OnTextMenu = InternalTextMenuOnItem;
				ContextItem = Item;
			}
		}
		return true;
	}
}

function InternalTextMenuOnItem(int Index, string Text)
{
	local bool bResetItem;

	if (Text == Localize("ContextMenu", "EatPotion", "Sephiroth") && ContextItem.IsPotion()) {
		UseItem(ContextItem);
		bResetItem = true;
	}
//	else if (Text == Localize("ContextMenu", "UseScroll", "Sephiroth") && (ContextItem.IsReturnScroll() || ContextItem.IsDetectScroll() || ContextItem.IsSkillScroll())) {
	else if (Text == Localize("ContextMenu", "UseScroll", "Sephiroth") && (ContextItem.IsReturnScroll() || ContextItem.IsSkillScroll())) {
		UseItem(ContextItem);
		bResetItem = true;
	}
	else if (Text == Localize("ContextMenu", "ResetPoints", "Sephiroth") && ContextItem.IsStatGem()) {
		UseItem(ContextItem);
		bResetItem = true;
	}
	else if(Text == Localize("ContextMenu", "Equip", "Sephiroth"))
	{
		UseItem(ContextItem);
		bResetItem = true;
	}
	else if (Text == Localize("ContextMenu", "DropItem", "Sephiroth"))
	{
		// ���� ������ ���������� Ȯ���Ѵ�.
		if ( ContextItem.xSealFlag == ContextItem.eSEALFLAG.SF_USED )
		{
			SealedItem = ContextItem;
			class'CMessageBox'.static.MessageBox(Self, "EquipSealedItem", Localize("Modals", "DeleteUsedItem", "Sephiroth"), MB_YesNo, IDM_DROPUSEDITEM);
		}
		else
			SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(0, ContextItem.X, ContextItem.Y, PlayerOwner.Pawn.Location.Z);

		bResetItem = true;
	}
	//+jhjung,2003.7.23
	else if (Text == Localize("ContextMenu", "SplitItem", "Sephiroth") && ContextItem.HasAmount()) {
		class'CEditBox'.static.EditBox(Self, "SplitRaw", Localize("Modals", "TitleItemSplit", "Sephiroth"), IDS_SplitItem, 10);
		bResetItem = false;
	}
	else if (Text == Localize("ContextMenu", "UseSkillBook", "Sephiroth") && ContextItem.IsSkillBook()){
		UseItem(ContextItem);
		bResetItem = true;
	}
	//@by wj(10/07)------
	else if (Text == Localize("ContextMenu", "UseFood", "Sephiroth") && ContextItem.IsPetFood()){
		UseItem(ContextItem);
		bResetItem = true;
	}
	else if (Text == Localize("ContextMenu", "PetRecall", "Sephiroth") && ContextItem.IsPetCage()){
		UseItem(ContextItem);
		bResetItem = true;
	}
	//-------------------
	
	if (bResetItem)
		ContextItem = None;
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	local int AmountSplit;
	local int BuyAmount;
	local SephirothItem Item;

	if (NotifyID == IDS_SplitItem) {
		AmountSplit = int(EditText);
		if (ContextItem != None && AmountSplit > 0) {
			AmountSplit = Clamp(AmountSplit, 0, ContextItem.Amount);
            SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemSplit"@ContextItem.X@ContextItem.Y@-1@-1@AmountSplit@"0");
		}
		ContextItem = None;
	}
	else if (NotifyId == IDS_MoneyToGround && int(EditText) > 0)		//else if (NotifyId == IDS_MoneyToGround && int(EditText) > 10)
	{
//		SephirothPlayer(PlayerOwner).Net.NotiDropMoney(int(EditText),PlayerOwner.Pawn.Location);
//		messagebox
		class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
//		class'CMessageBox'.static.MessageBox(self, "HelpMsg", "���ϸ� ����� �� �ִ� �����\n ��� ���� �����˴ϴ�.", MB_Ok);
	}
	else if (NotifyId == IDS_MoneyToStash && SephirothPlayer(PlayerOwner).CmpInt64(EditText, "0") > 0)	// �� ���� �Ұ�ó��
	{
//		SephirothPlayer(PlayerOwner).Net.NotiStashAddMoney(CStashLobby(Parent).SelectedStashId,EditText);		//checked
		class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
	//	class'CMessageBox'.static.MessageBox(self, "HelpMsg", "���ϸ� �����Կ� ���� �� �ִ� �����\n ��� ���� �����˴ϴ�.\n(�����Կ��� ���ϸ� ã�� ���� �����մϴ�.)", MB_Ok);
	//@by wj(10/04)------
	}
	else if (NotifyId == IDS_PetName && EditText != "")
        SephirothPlayer(PlayerOwner).Net.NotiApplyInput(EnchantGem.X, EnchantGem.Y, EnchantDest.X, EnchantDest.Y,EditText, 0);
	//-------------------
	else if( NotifyId == IDS_BoothBuyItemAmount ){
		BuyAmount = int(EditText);
		if( BuyAmount > 0 && CBooth_Guest(Parent) != None ){
			Item = CBooth_Guest(Parent).reservedItemsList[0];
			if( Item.Amount >= BuyAmount ){
				strTotalMoney = SephirothPlayer(PlayerOwner).MulInt64(Item.strBoothPrice, string(BuyAmount));
				BoothBuyAmount = BuyAmount;
				ShowConfirmMessagebox(strTotalMoney, IDM_BoothBuyItem);		// keios
				return;
			}
		}
		strTotalMoney = "-1";
		BoothBuyAmount = -1;
		if( CBooth_Guest(Parent) != None )
			CBooth_Guest(Parent).ResetReserved();
	}
	else if( NotifyId == -1*IDS_BoothBuyItemAmount ){
		strTotalMoney = "-1";
		BoothBuyAmount = -1;
		if( CBooth_Guest(Parent) != None )
			CBooth_Guest(Parent).ResetReserved();
	}
}

function bool KeyEvent_Store(Console.EInputKey Key, Console.EInputAction Action, FLOAT Delta)
{
	local CStore Store;

	Store = CStore(Parent);

	if (Store == None)
		return false;

	if (Store.Store.ActionState == Store.Store.BN_Sell || Store.Store.ActionState == Store.Store.BN_Repair) 
	{
		if (Key == IK_LeftMouse) 
		{
			if (Action == IST_Press && IsCursorInsideComponent(Components[4])) 
			{
				Controller.SelectingSource = Self;
				Controller.PressX = Controller.MouseX;
				Controller.PressY = Controller.MouseY;

				Controller.bMousedrag = true;
				return true;
			}
			else if (Action == IST_Release && IsPosInsideComponent(Components[4], Controller.PressX, Controller.PressY))
			{
				if (Controller.DragSource != None && Controller.DragSource.IsA('CEquipment') && Drop()) {
					Controller.ResetDragAndDropAll();
					return true;
				}
				if (LMRelease_Store(Key, Action))
					return true;
			}
			/*
			if(LMRelease_Store(Key, Action))
				return true;
			*/
		}
	}
	return false;
}


function bool LMRelease_Store(Console.EInputKey Key, Console.EInputAction Action)
{
	local CStore Store;
	local SephirothItem Item;
	local int i;
	local string strMoney, lstrTotalMoney, strPrice;

	Store = CStore(Parent);

	if (Store == None)
		return false;
	if (Store.Store.ActionState == Store.Store.BN_Sell || Store.Store.ActionState == Store.Store.BN_Repair) 
	{
		if (Action == IST_Release)
		{	
			ObjectSelecting();
			Controller.MergeSelectingList(Controller.ObjectList); 
			Controller.ResetObjectList();
			Controller.UpdateSelection();

			if(Controller.bMousedrag)
				Controller.bMousedrag = false;

			//-------------------
			// +jhjung,2003.5.27
			if (Store.Store.ActionState == Store.Store.BN_Repair && Controller.SelectedList.Length == 1) {
				Item = SephirothItem(Controller.SelectedList[0]);
				if (Item.IsRecyclable() && Item.Durability < Item.MaxDurability && Item.RepairPrice > 0) {
					strPrice = ClientController(PlayerOwner).GetItemRepairPriceString(Item.strRepairPrice);
					strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, strPrice);
					class'CMessageBox'.static.MessageBox(Self, "RepairItem", Localize("Modals", "TitleItemRepair", "Sephiroth") 
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
					return true;
				}
				//@cs added ����������
				else if(Item.IsDisposable() && Item.IsSeaShell()){
					strPrice = ClientController(PlayerOwner).GetItemRepairPriceString("10000000");
					strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, strPrice);
					class'CMessageBox'.static.MessageBox(Self, "RepairItem", Localize("Modals", "TitleItemRepair", "Sephiroth") 
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
					return true;
				}
				else {
					PlayerOwner.myHud.AddMessage(2,Localize("Information","UselessRepair","Sephiroth"),class'Canvas'.static.MakeColor(255,255,0));
					GotoState('Nothing');
					Controller.ResetSelecting();
					Controller.ResetDragging();
					Controller.ResetObjectList();
					Controller.SelectingSource = None;
					Controller.DragSource = None;
					return true;
				}
			}
			// end of REPAIR fix

			if (Controller.SelectedList.Length > 0) {
				lstrTotalMoney = "0";
				for (i=0;i<Controller.SelectedList.Length;i++){
					if (Store.Store.ActionState == Store.Store.BN_Sell)
						strPrice = SephirothItem(Controller.SelectedList[i]).strSellPrice;
					else
						strPrice = SephirothItem(Controller.SelectedList[i]).strRepairPrice;
					strPrice = (ClientController(PlayerOwner)).GetItemSellPriceString(strPrice);
					lstrTotalMoney = SephirothPlayer(PlayerOwner).AddInt64(lstrTotalMoney, strPrice);
				}

				if (Store.Store.ActionState == Store.Store.BN_Sell) {
					strMoney = SephirothPlayer(PlayerOwner).AddInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, lstrTotalMoney);
					class'CMessageBox'.static.MessageBox(Self,"SellItem",Localize("Modals","TitleItemSell","Sephiroth") $ "\\n" $ Localize("Modals","BeforeSell","Sephiroth") $ ": " $ Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) $ "\\n" $ Localize("Modals","AfterSell","Sephiroth") $ ": " $ Controller.MoneyStringEx(strMoney), MB_YesNo, IDM_SellItem);
				}
				else {
					strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, lstrTotalMoney);
					class'CMessageBox'.static.MessageBox(Self,"RepairItem",Localize("Modals","TitleItemRepair","Sephiroth") $ "\\n" $ Localize("Modals","BeforeRepair","Sephiroth") $ ": " $ Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) $ "\\n" $ Localize("Modals","AfterRepair","Sephiroth") $ ": " $ Controller.MoneyStringEx(strMoney), MB_YesNo, IDM_RepairItem);
				}

				GotoState('Dragging');
				
				return true;
			}
		}
	}

	return false;
}


function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Value,i;
	local SephirothItem Item;
	
	if (NotifyType == INT_MessageBox)
	{
		Value = int(Command);

		switch (Value)
		{
		case IDM_SellItem :
        case IDM_RepairItem :	// �⺻ �κ��丮 InvenIndex : 0 

			if (Value == IDM_SellItem)
			{
				for (i=0;i<Controller.SelectedList.Length;i++)
                    SephirothPlayer(PlayerOwner).Net.NotiSell(CStore(Parent).Store.ShopNpc.PanId, 0, SephirothItem(Controller.SelectedList[i]).X, SephirothItem(Controller.SelectedList[i]).Y);
			}	
			else if (Value == IDM_RepairItem)
			{
				for (i=0;i<Controller.SelectedList.Length;i++)
                    SephirothPlayer(PlayerOwner).Net.NotiRepair(CStore(Parent).Store.ShopNpc.PanId, 0, SephirothItem(Controller.SelectedList[i]).X, SephirothItem(Controller.SelectedList[i]).Y);
			}

		//@by wj(07/24)------
		case -1*IDM_SellItem :
		case -1*IDM_RepairItem :

			Parent.bIgnoreKeyEvents = false;
			break;

		case IDM_EnchantItem :

			if (EnchantGem != None)
				SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemApply"@EnchantGem.X@EnchantGem.Y@EnchantDest.X@EnchantDest.Y);

			break;

		//@by wj(08/27)------
		case IDM_LevelUpItem :

			if (LevelUpItem != None)
			{
				SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemUse"@LevelUpItem.X@LevelUpItem.Y);
				LevelUpItem = None;
			}
			break;
		//-------------------
		case IDM_BoothBuyItem :

			if ( CBooth_Guest(Parent) != None )
			{
				if ( CBooth_Guest(Parent).reservedItemsList.Length == 1 )
				{
					Item = CBooth_Guest(Parent).reservedItemsList[0];
                    SephirothPlayer(PlayerOwner).Net.NotiBoothBuyItem(0,CBooth_Guest(Parent).SellerInfo.PanID, Item.X, Item.Y, Item.bPricePerEach, Item.Amount, BoothBuyAmount, strTotalMoney);
				}
				else if ( CBooth_Guest(Parent).reservedItemsList.Length > 1 )
				{
                    SephirothPlayer(PlayerOwner).Net.NotiBoothBuyItemMany(0,CBooth_Guest(Parent).SellerInfo.PanID, CBooth_Guest(Parent).reservedItemsList, strTotalMoney);
				}

				strTotalMoney = "-1";
				BoothBuyAmount = -1;
				CBooth_Guest(Parent).ResetReserved();
			}

			break;

		case -1*IDM_BoothBuyItem :

			strTotalMoney = "-1";
			BoothBuyAmount = -1;

			if ( CBooth_Guest(Parent) != None )
				CBooth_Guest(Parent).ResetReserved();

			break;

		case IDM_WEARSEALEDITEM :

			SephirothPlayer(PlayerOwner).Net.NotiWearItem(0, SealedItem.X, SealedItem.Y, SephirothPlayer(PlayerOwner).PSI.WornItems.FindEquipPlace(SealedItem));
			break;

		case IDM_DROPUSEDITEM :

			SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(0, SealedItem.X, SealedItem.Y, PlayerOwner.Pawn.Location.Z);
			break;

		case IDM_SWAP_ITEM :
			if(AffixChoice != None)
				AffixChoice.Close();
			SephirothPlayer(PlayerOwner).Net.NotiSwapEquipment(SephirothPlayer(PlayerOwner).PSI.WornItems.FindEquipAblePlace(SealedItem), 0, SealedItem.X, SealedItem.Y);
			break;
			
		case IDM_UNPACK_ITEM:
			SephirothPlayer(PlayerOwner).Net.NotiCommand(m_sUnpackCommand);
			break;
		}

		Controller.ResetSelecting();
		Controller.ResetDragging();
		Controller.ResetObjectList();
		Controller.SelectingSource = None;
		Controller.DragSource = None;
		GotoState('Nothing');
	}
}

function RegisterItem(SephirothItem Item)
{
	SelectedItemsList[SelectedItemsList.Length] = Item;
}

//@by wj(040310)------
function UnRegisterItem(SephirothItem Item)
{
	local int i;

	for(i = 0 ; i < SelectedItemsList.Length ; i++)
	{
		if(Item.X == SelectedItemsList[i].X && Item.Y == SelectedItemsList[i].Y) {
			SelectedItemsList.Remove(i,1);
		}
	}
}
//--------------------


function UseItem(SephirothItem ISI)
{
	local int EquipPlace;
	local WornItems WornItems;

	// keios - ������ ���Ұ� ���� üũ
	if (!SephirothPlayer(PlayerOwner).CanUseItemNow())
		return;

	if(SephirothPlayer(PlayerOwner).PSI.CheckBuffDontAct()) //add neive : 12�� ������ ���̽� ������ ȿ�� ����Ű ��� ����			
	{
		AddMessage(2, Localize("Warnings", "CannotAction", "Sephiroth"), class'Canvas'.static.MakeColor(55, 55, 200));	
		return;
	}

	if (ISI == None)	
		return;

	if (Parent.IsA('CTrade'))
	{
		SephirothPlayer(PlayerOwner).myHud.AddMessage(1,Localize("Warnings","CannotUseItemOnXcng","Sephiroth"),class'Canvas'.static.MakeColor(255,255,0));
		return;
	}


	if (ISI.IsUse() || ISI.IsPotion())
	{
		if (ISI.IsSkillBook())
		{				
			LevelUpItem = ISI;
			class'CMessageBox'.static.MessageBox(
				Self,
				"SkillLevelUp",
				ISI.LocalizedDescription$"\\n"$Localize("Modals","SkillLevelUp","Sephiroth"),
				MB_YESNO,
				IDM_LevelUpItem
			);
		}
		else
		{
			//if(ISI.IsInGameShopPackItem())	// ���Ŀ� idt �� �����ؼ� �ٸ��� ����
			// ���� �ٴ� ��� ����� �ؾ��ϴ� �������ΰ�?
			if(GameManager(Level.Game).CheckPackItem(ISI.TypeName))
			{
				m_sUnpackCommand = "ItemUse" @ ISI.X @ ISI.Y;
				class'CMessageBox'.static.MessageBox(Self, "EquipSealedItem", Localize("InGameShopBox", "Unpack", "SephirothUI"), MB_YesNo, IDM_UNPACK_ITEM);
			}
			else if( ISI.DetailType == ISI.IDT_StackUI )		// IDT_StackUI ������ �̰� �����...
				SephirothPlayer(PlayerOwner).OpenRandomBox(ISI,-1);
			else
				SephirothPlayer(PlayerOwner).Net.NotiCommand("ItemUse"@ISI.X@ISI.Y);

			// 2003.10.8 by BK
			ContextItem = None;
			Controller.ContextMenu = None;
			Controller.ResetDragAndDropAll();
		}
	}
	else
	{
		if(bIsDissolve)
			return;
		WornItems = SephirothPlayer(PlayerOwner).PSI.WornItems;
		EquipPlace = WornItems.FindEquipPlace(ISI);

		if ( EquipPlace != WornItems.IP_NoPlace && EquipPlace != WornItems.IP_Used)	// ���� ���� ������ ���� ��
		{
			if(!CheckEquip(ISI))
				return ;

			if ( ISI.xSealFlag == ISI.eSEALFLAG.SF_SEALED )
			{
				SealedItem = ISI;
				class'CMessageBox'.static.MessageBox(Self, "EquipSealedItem", Localize("Modals", "EquipSealedItem", "Sephiroth"), MB_YesNo, IDM_WEARSEALEDITEM);
			}
			else
				SephirothPlayer(PlayerOwner).Net.NotiWearItem(0, ISI.X, ISI.Y, EquipPlace); // index = 0; �⺻ �κ��丮.
		}
		else if(EquipPlace == WornItems.IP_Used)		// ���ų� �̹� ���� ���� ��
		{
			EquipPlace = WornItems.FindEquipAblePlace(ISI);
			if (EquipPlace != WornItems.IP_NoPlace)
			{
				if(WornItems.IsSwapAbleTime(Level.TimeSeconds) == false)
					return;

				if(!CheckEquip(ISI))
					return ;

				if ( ISI.xSealFlag == ISI.eSEALFLAG.SF_SEALED )
				{
					SealedItem = ISI;
					class'CMessageBox'.static.MessageBox(Self, "EquipSealedItem", Localize("Modals", "EquipSealedItem", "Sephiroth"), MB_YesNo, IDM_SWAP_ITEM);
				}
				else
				{
					if(AffixChoice != None)
						AffixChoice.Close();
					SephirothPlayer(PlayerOwner).Net.NotiSwapEquipment(EquipPlace,0,ISI.X,ISI.Y);
				}
			}
		}
	}
}

function bool CheckEquip(SephirothItem ISI)
{
	local PlayerServerInfo PSI;
	local WornItems WI;
	local string sRes;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	WI = SephirothPlayer(PlayerOwner).PSI.WornItems;
	
	sRes = WI.CheckEquip(ISI, PSI.JobName, PSI.PlayLevel, PSI.Str, PSI.Dex, PSI.Vigor, PSI.GetMagicValue(),
		PSI.Red, PSI.Blue);
	if(sRes == "")
		return true;

	class'CMessageBox'.static.MessageBox(self, "EquipFailed", Localize("Equip",sRes,"SephirothUI"), MB_Ok);
	return false;
}


function bool OnDropItem(Point Dest)
{
	local SephirothItem Item, ExistItem;
	//local CTextSelectBox AffixChoice;
	local array<SephirothItem> ItemList;
	local array<string> AffixList;
    local int i, srcIndex, destIndex;

	if(IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return true;

	if ( Controller.DragSource == Self )
	{
		if ( Controller.SelectedList.Length == 1 )
		{
			Item = SephirothItem(Controller.SelectedList[0]);
			ExistItem = SepInventory.GetItem_RC(Dest.X, Dest.Y);		// ����� ���ϴ� ��ġ�� �����ϴ� ������

			// �̹� �������� �����ϴ� �����̶��
			if (Item.IsApplication() && ExistItem != None && ExistItem != Item) 
			{
				EnchantGem = Item;
				EnchantDest.X = ExistItem.X;
				EnchantDest.Y = ExistItem.Y;

				if (ExistItem.TypeName == "PetDeadCage")
				{
					class'CMessageBox'.static.MessageBox(
						Self,
						"PetRevive",
						Localize("Modals","TitlePetRevive","Sephiroth"),
						MB_YesNo,
						IDM_EnchantItem
					);
				}
				else if(Item.TypeName != "ReviveWater"){
					class'CMessageBox'.static.MessageBox(
						Self,
						"EnchantItem",
						ExistItem.LocalizedDescription $ "\\n" $ Localize("Modals","TitleItemEnchant","Sephiroth"), 
						MB_YesNo, 
						IDM_EnchantItem
					);
				}
			}
			else if ( Item.IsApplicationSelect() && ExistItem != None && ExistItem != Item ) 
			{
				ExistItem.GetAffixList(AffixList);
				AffixChoice = class'CTextSelectBox'.static.PopupTextSelectBox(Self,Localize("Information","ChooseUpgradeAffix","Sephiroth"), AffixList,false);

				if (AffixChoice != None) {
					AffixChoice.OnSelectChoice = InternalSelectAffix;
					EnchantGem = Item;
					EnchantDest.X = ExistItem.X;
					EnchantDest.Y = ExistItem.Y;
				}
			}
			else if (Item.IsApplicationRemoveSelect() && ExistItem != None && ExistItem != Item)	// Mr.Do - ��æƮ ���찳 ����
			{
				ExistItem.GetAffixList(AffixList);
				AffixChoice = class'CTextSelectBox'.static.PopupTextSelectBox(Self, Localize("Information", "ChooseDeleteAffix", "Sephiroth"), AffixList, false);

				if (AffixChoice != None)
				{
					AffixChoice.OnSelectChoice = InternalSelectAffix;
					EnchantGem = Item;
					EnchantDest.X = ExistItem.X;
					EnchantDest.Y = ExistItem.Y;
				}
			}
			//@by wj(10/04)------
			else if (Item.IsApplicationInput() && ExistItem != None && ExistItem != Item && (ExistItem.TypeName == "PetEgg"))
			{
				class'CEditBox'.static.EditBox(Self,"PetName",Localize("Pet","PetNaming","Sephiroth"),IDS_PetName,22,"");
				EnchantGem = Item;
				EnchantDest.X = ExistItem.X;
				EnchantDest.Y = ExistItem.Y;
			}
			// Mr.Do - 
			else if (Item.IsPetNameChange() && ExistItem != None && ExistItem != Item && (ExistItem.TypeName == "PetCage"))
			{
				class'CEditBox'.static.EditBox(Self,"PetNameChange",Localize("Pet","PetNaming","Sephiroth"),IDS_PetName,22,"");
				EnchantGem = Item;
				EnchantDest.X = ExistItem.X;
				EnchantDest.Y = ExistItem.Y;
			}
			//-------------------
            else if ( IsCursorInsideComponent(Components[4]) )
			{		
				SephirothPlayer(PlayerOwner).Net.NotiArrangeItem(Item.X, Item.Y, Dest.X, Dest.Y);
			}

			Controller.ResetDragAndDropAll();
			return true;
		}
	}
	else if (Controller.DragSource.IsA('CBagResizable') && IsCursorInsideComponent(Components[4]) )
	{
		// NotiInvenItemMove ����������
		// ������ �κ��丮�� Index = 0,
		// Ȯ�� �κ��丮�� Index = 1���� ����.
		// ������, �������� ����ִ� Ȯ���κ��丮�� Index�� 0���� �����ϹǷ� ����ȭ�ϴ� ���� �״�ξ���,
		// NotiInvenMove ������ ����� ��츸 SubInventory�� Index�� +1���ְ�,
		// ������ Inventory�� Index 0�� ����Ѵ�.
//		//Log("CBagResizable :: DragSource CBagResizable");
		srcIndex = CBagResizable(Controller.DragSource).SubInvenIndex+1;
		destIndex = 0;	//�ڽ�(�⺻ �κ��丮)
		if(Controller.SelectedList.Length == 1){
			Item = SephirothItem(Controller.SelectedList[0]);
			SephirothPlayer(PlayerOwner).Net.NotiInvenItemMove(srcIndex, Item.X, Item.Y, destIndex, Dest.X, Dest.Y);
		}
		else if(Controller.SelectedList.Length >1)
        {
            for(i=0;i<Controller.SelectedList.Length;i++)
                ItemList[i]=SephirothItem(Controller.SelectedList[i]);
			SephirothPlayer(PlayerOwner).Net.NotiInvenItemMoveMany(SrcIndex, ItemList, destIndex);
        }
	

	}
	else if (Controller.DragSource.IsA('CEquipment') && IsCursorInsideComponent(Components[4]) )
	{
		Item = SephirothItem(Controller.SelectedList[0]);

		// Index 0 : ���� �κ��丮
        SephirothPlayer(PlayerOwner).Net.NotiTakeOffItem(Item.EquipPlace,0,Dest.X,Dest.Y);
		return true;
	}
    else if(Controller.DragSource.IsA('CStashBox') && IsCursorInsideComponent(Components[4]) )
	{
		if(Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);
			//index : 0  �����κ��丮�� index0, Ȯ���κ��丮0������ index1
            SephirothPlayer(PlayerOwner).Net.NotiStashRemoveItem(CStashLobby(Parent).SelectedStashId, Item.X, Item.Y, Dest.X, Dest.Y, 0);      //checked
			return true;			
		}
		else if(Controller.SelectedList.Length > 1)
		{		
			for(i=0; i<Controller.SelectedList.Length; i++)
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);

            SephirothPlayer(PlayerOwner).Net.NotiStashRemoveItemMany(CStashLobby(Parent).SelectedStashId, ItemList, 0);        //checked
			return true;
		}		
	}

	//@by wj(040310)-----
    if(Controller.DragSource.IsA('ItemRemodeling') && IsCursorInsideComponent(Components[4]) )
	{
		if(Controller.SelectedList.Length == 1) {
			Item = SephirothItem(Controller.SelectedList[0]);
			ItemRemodeling(Controller.DragSource).RemoveItem(Item);
			//for(i = 0 ; i < InboxItemsList.Length ; i++)
			//{
			//	if(InboxItemsList[i] == Item)
			//		InboxItemsList.Remove(i,1);
			//}
			return true;
		}
	}
	//@by wj(040622)-----
    if(Controller.DragSource.IsA('PetBag') && IsCursorInsideComponent(Components[4]) )
	{
		if(Controller.SelectedList.Length == 1) {
			Item = SephirothItem(Controller.SelectedList[0]);
			SephirothPlayer(PlayerOwner).Net.NotiPetInvenItemOut(Item.X,Item.Y,Dest.X,Dest.Y);
			return true;
		}
		else if(Controller.SelectedList.Length > 1) {
			for(i = 0 ; i < Controller.SelectedList.Length ; i++)
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);

			SephirothPlayer(PlayerOwner).Net.NotiPetInvenItemOutMany(ItemList);
			return true;
		}
	}
	//-------------------
    if( Controller.DragSource.IsA('CBooth_Seller') && IsCursorInsideComponent(Components[4]) ){
		if( Controller.SelectedList.Length == 1 ){
			Item = SephirothItem(Controller.SelectedList[0]);
			SephirothPlayer(PlayerOwner).Net.NotiBoothRemoveItem(Item.X, Item.Y);
			return true;
		}
		else if( Controller.SelectedList.Length > 1 ){
			for( i=0; i<Controller.SelectedList.Length; i++ )
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);

			SephirothPlayer(PlayerOwner).Net.NotiBoothRemoveItemMany(ItemList);
			return true;
		}
	}

    if ( Controller.DragSource.IsA('CBooth_Guest') && bIsGuestBooth && IsCursorInsideComponent(Components[4]) )
	{
		if ( CBooth_Guest(Parent).reservedPaidMoney == "-1" )
			return true;

		// keios - ���űݾ� ���� ǥ�� & ����
		if( CBooth_Guest(Parent).reservedItemsList.Length == 1 )
		{
			Item = SephirothItem(Controller.SelectedList[0]);

			if ( Item.bPricePerEach )
				class'CEditBox'.static.EditBox(Self, "BuyBuyItemAmount", Localize("Modals","BoothBuyItemAmount","Sephiroth"), IDS_BoothBuyItemAmount, 4, string(Item.Amount));
			else
			{
				strTotalMoney = CBooth_Guest(Parent).reservedPaidMoney;
				ShowConfirmMessagebox(strTotalMoney, IDM_BoothBuyItem);		// keios
			}

			return true;
		}
		else if ( CBooth_Guest(Parent).reservedItemsList.Length > 1 )
		{
			strTotalMoney = CBooth_Guest(Parent).reservedPaidMoney;
			ShowConfirmMessagebox(strTotalMoney, IDM_BoothBuyItem);		// keios

			return true;
		}
	}

	return false;
}

function bool Drop()
{
	local SephirothItem ISI;
	local Point Point, ItemPos;

	if (IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return false;	

	if (Controller.SelectedList.Length == 1)
	{
		Point = ScreenToRowColumn(Components[4], Controller.MouseX, Controller.MouseY);

		if (Point.X != -1 && Point.Y != -1)
		{
			ISI = SephirothItem(Controller.SelectedList[0]);

			if (ISI.Width % 2 == 1) 
				ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[4].ColumnCount - ISI.Width);
			else 
				ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[4].ColumnCount - ISI.Width);
			if (ISI.Height % 2 == 1) 
				ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[4].RowCount - ISI.Height);
			else
				ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[4].RowCount - ISI.Height);
			
			if (OnDropItem(ItemPos))
				return true;
		}
	}
	else
	{
		if (OnDropItem(ItemPos))
			return true;	
	}


	return false;
}



function SephirothItem OnDragItem(SephirothInventory Inv, Point Src)
{
	local SephirothItem Item;

	Item = Inv.GetItem_RC(Src.X, Src.Y);

	return Item;
}


function bool ObjectSelecting()
{
	local SephirothItem Item;
	local Point Point;

	if(IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return false;	
		
	/*
	local CStore Store;
	Store = CStore(Parent);

//	if(Parent.IsA('CStore') && (Store.Store.ActionState == Store.Store.BN_Repair || Store.Store.ActionState == Store.Store.BN_Sell) )
//		return false;
	*/
	
	Point = ScreenToRowColumn(Components[4], Controller.MouseX, Controller.MouseY);

	if(Point.X != -1 && Point.Y != -1)
	{
		Item = OnDragItem(SepInventory, Point);

		if((bIsExchange || bIsRemodeling || bIsSellerBooth || bIsGuestBooth) && (IsRegisteredItem(Item) || Item.bSelected ))
			return false;

		if(Item != None)
		{
			Controller.MergeSelectCandidate(Item);	//Ŭ�� �� �� ���´�!
			return true;
		}
	}

	return false;
}

function bool CanDrag()
{
	local int BS_Open;
	BS_Open = 1;

	if(IsLockedInventory()) //add neive : ������� �κ��丮 ��
		return false;

	if( Controller.IsSomethingSelected() ){
		if( bIsSellerBooth && SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Open )
			return false;
		return true;
	}
}

function bool IsCursorInsideInterface()
{
	return IsCursorInsideComponent(Components[0]);
}

function OnQuerySelection(float StartX, float StartY, float MouseX, float MouseY, out Array<Object> ObjList)
{
	local SephirothInventory.Rectangle DR, IR;
	local SephirothItem ISI;
	local Point StartPoint, EndPoint;
	local float sx, sy, ex, ey, tmp;
	local int i, k;

//	if(Controller.bCtrlPressed && Controller.SelectingSource != Self)
//		return;


	StartPoint = ScreenToRowColumn(CBag(Controller.SelectingSource).Components[4], StartX, StartY);
	if(StartPoint.X != -1 && StartPoint.Y != -1)
	{
		EndPoint = ScreenToRowColumnEx(CBag(Controller.SelectingSource).Components[4], MouseX, MouseY);

		sx = StartPoint.X;
		sy = StartPoint.Y;
		ex = EndPoint.X;
		ey = EndPoint.Y;

		if(ex < 0) ex = 0;
		if(ex > CBag(Controller.SelectingSource).Components[4].ColumnCount-1) ex = CBag(Controller.SelectingSource).Components[4].ColumnCount-1;
		if(ey < 0) ey = 0;
		if(ey > CBag(Controller.SelectingSource).Components[4].RowCount-1)    ey = CBag(Controller.SelectingSource).Components[4].RowCount-1;
		if(sx > ex)
		{
			tmp = sx;
			sx = ex;
			ex = tmp;
		}

		if(sy > ey)
		{
			tmp = sy;
			sy = ey;
			ey = tmp;
		}

		DR.Left = sx;
		DR.Top = sy;
		DR.Right = ex;
		DR.Bottom = ey;

		k=0;
		for(i=0; i<CBag(Controller.SelectingSource).SepInventory.Items.Length; i++)
		{
			ISI = CBag(Controller.SelectingSource).SepInventory.Items[i];
			if(ISI != None)
			{
				IR = CBag(Controller.SelectingSource).SepInventory.Rectangle_Get(ISI);
				if(CBag(Controller.SelectingSource).SepInventory.Rectangle_Intersect(IR,DR))
				{
					if((bIsExchange || bIsRemodeling || bIsSellerBooth || bIsGuestBooth) && (IsRegisteredItem(ISI) || ISI.bSelected))
						continue;

					ObjList[k] = ISI;
					k++;
				}
			}
		}
	}

//	if(Controller.SelectingSource != Self)
//		GotoState('Nothing');
}


function DrawObject(Canvas C)
{	
	local float X,Y;
	local int nGab;

	nGab = SephirothPlayer(PlayerOwner).PSI.nCurTime - SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime;

	if(nGab < LockSec) //add neive : ���� ���� ����
		C.SetDrawColor(100,100,100,100);	

	if(Controller.SelectingSource != None && Controller.SelectingSource == Self && Controller.SelectingSource.IsInState('Selecting'))
	{
		if(Controller.ObjectList.Length > 0)
			RenderSelectionState(C, CBag(Controller.SelectingSource).Components[4].X, CBag(Controller.SelectingSource).Components[4].Y, Controller.ObjectList);//Controller.SelectingList);
		if(Controller.SelectingList.Length > 0)
			RenderSelectionState(C, CBag(Controller.SelectingSource).Components[4].X, CBag(Controller.SelectingSource).Components[4].Y, Controller.SelectingList);
	}

	if(Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
		RenderSelectionState(C, CBag(Controller.DragSource).Components[4].X, CBag(Controller.DragSource).Components[4].Y, Controller.SelectedList);

	if(nGab < LockSec) //add neive : ���� ���� ����
		C.SetDrawColor(150,150,150,100);	
	else
		C.SetDrawColor(255,255,255,255);
	C.SetRenderStyleAlpha();
	Render_Items(C,Components[4].X,Components[4].Y);

	if(nGab < LockSec) //add neive : ���� ���� ����
	{
		C.SetPos(Components[0].X+21, Components[0].Y+60);
		C.SetDrawColor(255,255,0,255);
		C.DrawText("Locked Inventory...");
	}

	// ������
	X = Components[0].X;
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(Localize("InventoryUI","Leni","SephirothUI"),X+75,Y+387,10,14);

	DrawTitle(C, m_sTitle);
}

function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local material Sprite;
	local int X, Y, XL, YL;

	X = OffsetX + Item.X * CellSize;
	Y = OffsetY + Item.Y * CellSize;
	XL = Item.Width * CellSize - 1;
	YL = Item.Height * CellSize - 1;

	if ((bIsExchange || bIsRemodeling || bIsSellerBooth || bIsGuestBooth) && (IsRegisteredItem(Item) || Item.bSelected))
	{
		if (bIsRemodeling)
		{
			switch ( Item.Rareness )
			{
			case class'GConst'.default.IRMagic :

				Sprite = Texture'MagicSelected';
				break;

			case class'GConst'.default.IRRare :

				Sprite = Texture'DivineSelected';
				break;

			case class'GConst'.default.IRPlatinum :

				Sprite = Texture'PlatinumSelected';
				break;

			default :

				Sprite = Texture'Selected';
				break;
			}
		}
		else
			Sprite = Texture'Dirty';

		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
	}

	Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
	if (Sprite != None) {
		C.SetPos(X, Y);
		C.DrawTile(Texture'ItemArea', XL, YL, 0, 0, XL, YL);	// ������ ���� ǥ��
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);				// ������ �� �̹���
	}

	switch ( Item.xSealflag )
	{
	case Item.eSEALFLAG.SF_USED :
	
		Sprite = material(DynamicLoadObject("ItemSprites.Slot_unlock_"$Item.Width$"-"$Item.Height, class'Material'));
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
		break;
	
	case Item.eSEALFLAG.SF_SEALED :

		Sprite = material(DynamicLoadObject("ItemSprites.Slot_lock_"$Item.Width$"-"$Item.Height, class'Material'));
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
		break;
	
	default :
		break;
	}
	
	if (Item.IsPotion() || Item.IsScroll() || Item.IsQuiver() || Item.IsPetFood() || Item.IsStackUI())	// ���� �����̿� ������ ī��Ʈ �߰�
	{
		C.SetPos(X, Y);
		C.SetDrawColor(255, 255, 255);
		C.DrawText(Item.Amount);
	}

	if (IsLockedInventory()) //add neive : ������� �κ��丮 ��
		C.SetDrawColor(100, 100, 100, 100);
	else
		C.SetDrawColor(255, 255, 255, 255);	
	
}


// �ϳ��� �̹����� �����Ͽ� ����� ���缭 ����Ѵ�.
function DrawSplitImage(Canvas C,
						material Mat,						// �̹���
						int X, int Y,						// ��ġ
						int XL, int YL,						// ũ��
						int EdgeWidth, int EdgeHeight,		// ���� �� �׵θ��� ����, ����
						int ImgWidth, int ImgHeight)		// ����� �̹��� ������
{
	C.SetPos(X, Y);
	C.DrawTile(Mat, EdgeWidth, EdgeHeight, 0, 0, EdgeWidth, EdgeHeight);											// �»�

	C.SetPos(X + XL - EdgeWidth, Y);
	C.DrawTile(Mat, EdgeWidth, EdgeHeight, ImgWidth - EdgeWidth, 0, EdgeWidth, EdgeHeight);							// ���

	C.SetPos(X, Y + YL - EdgeHeight);
	C.DrawTile(Mat, EdgeWidth, EdgeHeight, 0, ImgHeight - EdgeHeight, EdgeWidth, EdgeHeight);						// ����

	C.SetPos(X + XL - EdgeWidth, Y + YL - EdgeHeight);
	C.DrawTile(Mat, EdgeWidth, EdgeHeight, ImgWidth - EdgeWidth, ImgHeight - EdgeHeight, EdgeWidth, EdgeHeight);	// ����

	C.SetPos(X + EdgeWidth, Y);
	C.DrawTile(Mat, XL - EdgeWidth * 2, EdgeHeight, EdgeWidth, 0, ImgWidth - EdgeWidth * 2, EdgeHeight);			// ����

	C.SetPos(X, Y + EdgeHeight);
	C.DrawTile(Mat, EdgeWidth, YL - EdgeHeight * 2, 0, EdgeHeight, EdgeWidth, ImgHeight - EdgeHeight * 2);			// ������

	C.SetPos(X + XL - EdgeWidth, Y + EdgeHeight);
	C.DrawTile(Mat, EdgeWidth, YL - EdgeHeight * 2, ImgWidth - EdgeWidth, EdgeHeight, EdgeWidth, ImgHeight - EdgeHeight * 2);	// ������

	C.SetPos(X + EdgeWidth, Y + YL - EdgeHeight);
	C.DrawTile(Mat, XL - EdgeWidth * 2, EdgeHeight, EdgeWidth, ImgHeight - EdgeHeight, ImgWidth - EdgeWidth * 2, EdgeHeight);	// �Ʒ���

//	C.SetPos(X + EdgeWidth, Y + EdgeHeight);
//	C.DrawTile(Texture'Sealed', XL - EdgeWidth * 2,  YL - EdgeHeight * 2, EdgeWidth, EdgeHeight, ImgWidth - EdgeWidth * 2, ImgHeight - EdgeHeight * 2);	// �߾�
}


// ���� �������� ����� �°� ���۵� �̹����� ���
function DrawSizedImage(Canvas C,
						string strMat,
						int X, int Y,				// ��ġ
						int XL, int YL,				// ũ��
						int ItemW, int ItemH)		// ����� �̹��� ������ (���� ���� ����)
{
	local material Mat;
	Mat = material(DynamicLoadObject(strMat $ ItemW $ "X" $ ItemH, class'Material'));

	if ( Mat != None )
	{
		C.SetPos(X, Y);
		C.DrawTile(Mat, XL, YL, 0, 0, XL, YL);
	}
}


function RenderSelectionState(Canvas C, int OffsetX, int OffsetY, Array<Object> ItemList)
{
	local SephirothItem Item;
	local material Sprite;
	local int X, Y, XL, YL;
	local int i;


	//************* Select Texture Draw ***********************************
	C.SetRenderStyleAlpha();

	for(i=0; i< ItemList.Length; i++)
	{
		Item = SephirothItem(ItemList[i]);
		X = OffsetX + Item.X * CellSize;
		Y = OffsetY + Item.Y * CellSize;
		XL = Item.Width * CellSize - 1;
		YL = Item.Height * CellSize - 1;

		switch ( Item.Rareness )
		{
		case class'GConst'.default.IRMagic :

			Sprite = Texture'MagicSelected';
			break;

		case class'GConst'.default.IRRare :

			Sprite = Texture'DivineSelected';
			break;

		case class'GConst'.default.IRPlatinum :

			Sprite = Texture'PlatinumSelected';
			break;

		default :

			Sprite = Texture'Selected';
			break;
		}
		
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
	}
	//**********************************************************************
}


function RenderSelecting(Canvas C)
{	
	local InterfaceRegion RgnStart,RgnEnd;
	local float sx, sy, ex, ey, tmp;
	local Point StartPoint, EndPoint;
	local Array<Object> TempList;
	local int i, j, k;
	local SephirothItem ISI;
	

	if(Controller.SelectingSource == None)
		return;

	if(Controller.bLButtonPressed)
	{
		//************* Selecting Box Draw ****************************************************
		StartPoint = ScreenToRowColumn(Controller.SelectingSource.Components[4], Controller.PressX, Controller.PressY);
		if(StartPoint.X != -1 && StartPoint.Y != -1)
		{
			EndPoint = ScreenToRowColumnEx(Controller.SelectingSource.Components[4], Controller.MouseX, Controller.MouseY);

			sx = StartPoint.X;
			sy = StartPoint.Y;
			ex = EndPoint.X;
			ey = EndPoint.Y;


			if(ex < 0) ex = 0;
			if(ex > Controller.SelectingSource.Components[4].ColumnCount-1) ex = Controller.SelectingSource.Components[4].ColumnCount-1;
			if(ey < 0) ey = 0;
			if(ey > Controller.SelectingSource.Components[4].RowCount-1)    ey = Controller.SelectingSource.Components[4].RowCount-1;
			if(sx > ex)
			{
				tmp = sx;
				sx = ex;
				ex = tmp;
			}

			if(sy > ey)
			{
				tmp = sy;
				sy = ey;
				ey = tmp;
			}

			RgnStart = RowColumnToScreen(Controller.SelectingSource.Components[4],sy,sx);
			RgnEnd = RowColumnToScreen(Controller.SelectingSource.Components[4],ey,ex);
			
			C.SetPos(RgnStart.X-1,RgnStart.Y-1);
			DrawBox(C,RgnEnd.X-RgnStart.X+RgnEnd.W-1,RgnEnd.Y-RgnStart.Y+RgnEnd.H-1);
			//*********************************************************************************



			TempList.Remove(0, TempList.Length);

			if(Controller.SelectingList.Length > 0)
			{
				for(i=0; i<Controller.SelectingList.Length; i++)
					TempList[i] = Controller.SelectingList[i];
			}

			if(Controller.ObjectList.Length > 0)
			{
				for(j=0; j<Controller.ObjectList.Length; j++)
				{
					ISI = SephirothItem(Controller.ObjectList[j]);

					if(ISI == None)
						continue;
					
					if(Controller.SelectingList.Length > 0)
					{
						for(k=0; k<Controller.SelectingList.Length; k++)
						{
							if(TempList[k] == ISI)
							{
								TempList.Remove(k,1);
								break;
							}
						}

					}
					TempList[TempList.Length] = ISI;						
				}
			}
			
			ShowSelectionItemList(C, TempList);//Controller.SelectingList);
		}
	}	

//	if(Controller.bLButtonPressed || Controller.bCtrlPressed)
//		ShowSelectionItemList(C, Controller.SelectingList);

	C.SetDrawColor(255,255,255);
}


/*
function RenderDragging(Canvas C)
{
	local SephirothItem ISI, Foo;
	local Point Point, ItemPos;
	local InterfaceRegion Rgn;
	local Material Sprite;

	local float X, Y, XL, YL;
	local int i, j;

	if ( Controller.Modal() )
		return;

	if ( Controller.SelectedList.Length == 1 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			Point = ScreenToRowColumn(Components[4], Controller.MouseX-XL/2, Controller.MouseY-YL/2); 

			if (Point.X != -1 && Point.Y != -1)
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[4].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[4].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[4].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[4].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[4],ItemPos.Y,ItemPos.X);

				XL = ISI.Width*Components[4].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[4].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for (i=0;i<ISI.Width;i++)
				{
					for (j=0;j<ISI.Height;j++) {
						Foo = SepInventory.GetItem_RC(ItemPos.X+i,ItemPos.Y+j);
						if (Foo != None && Foo != ISI)
							break;
					}

					if (Foo != None && Foo != ISI)
						break;
				}

				if (Foo != None && Foo != ISI)
				{
					Sprite = Texture'CannotDrop';
					if (ISI.HasAmount() && ISI.ModelName == Foo.ModelName)
						Sprite = Texture'CanDrop';
				}
				else
					Sprite = Texture'CanDrop';

				C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
			}

			Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

			if (Sprite != None)	{

				XL = ISI.Width*Components[4].CellWidth;
				YL = ISI.Height*Components[4].CellHeight;					

				X = Controller.MouseX-XL/2;
				Y = Controller.MouseY-YL/2;	 

				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				C.DrawTile(Sprite,XL,YL,0,0,XL,YL);
			}

			if (ISI.HasAmount())
			{           
				C.SetPos(Controller.MouseX+12, Controller.MouseY-14);
				C.SetDrawColor(255,255,255);
				C.DrawText(ISI.Amount);
			}
		}
	}
	else if(Controller.SelectedList.Length > 1)
	{
		ShowSelectionItemList(C, Controller.SelectedList);
	}

	C.SetDrawColor(255,255,255);
}
*/

function RenderDropArea(Canvas C)
{
	local SephirothItem ISI, Foo;
	local Point Point, ItemPos;
	local InterfaceRegion Rgn;
	local Material Sprite;

	local float X, Y, XL, YL;
	local int i, j;

//     local CStore Store;
//     Store = CStore(Parent);


//	if(Controller.DragSource != None && Controller.DragSource == Self)
//		RenderSelectionState(C, CBag(Controller.DragSource).Components[7].X, CBag(Controller.DragSource).Components[7].Y, Controller.SelectedList);


//	if (Store != None && Store.Store != None && (/*Store.Store.ActionState == Store.Store.BN_Sell || */Store.Store.ActionState == Store.Store.BN_Repair))
//		return;

	if ( Controller.Modal() )
		return;

	if ( Controller.SelectedList.Length == 1 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			Point = ScreenToRowColumn(Components[4], Controller.MouseX-XL/2, Controller.MouseY-YL/2); 

			if (Point.X != -1 && Point.Y != -1)
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[4].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[4].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[4].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[4].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[4],ItemPos.Y,ItemPos.X);

				XL = ISI.Width*Components[4].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[4].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;

				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for (i=0;i<ISI.Width;i++)
				{
					for (j=0;j<ISI.Height;j++) {
						Foo = SepInventory.GetItem_RC(ItemPos.X+i,ItemPos.Y+j);
						if (Foo != None && Foo != ISI)
							break;
					}

					if (Foo != None && Foo != ISI)
						break;
				}

				if (Foo != None && Foo != ISI)
				{
					Sprite = Texture'CannotDrop';
					if (ISI.HasAmount() && ISI.ModelName == Foo.ModelName)
						Sprite = Texture'CanDrop';
				}
				else
					Sprite = Texture'CanDrop';

				C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
			}
		}
	}

	C.SetDrawColor(255,255,255);
}


function ShowSelectionItemList(Canvas C, Array<Object> ObjList)
{
	local float XXL,YYL;
	local float MaxXL, MaxYL;
	local array<string> ItemStringArr;
	local string LocalizedAmountStr, TempStr;
	local int i;
	local SephirothItem ISI;
	local float X, Y, XL, YL;

	if(ObjList.Length > 1 || IsInState('Selecting'))
	{
		MaxXL = 0;
		MaxYL = 0;
		LocalizedAmountStr = Localize("Terms", "ItemSize", "Sephiroth");

		for (i=0; i < ObjList.Length; i++) 
		{
			ISI = SephirothItem(ObjList[i]);

			TempStr = ISI.LocalizedDescription;
			if (ISI.HasAmount())
				TempStr = TempStr $ " " $ ISI.Amount $ " " $ LocalizedAmountStr;

			C.TextSize(TempStr, XXL, YYL);
			MaxXL = max(MaxXL, XXL);
			MaxYL = MaxYL + YYL;

			switch ( ISI.Rareness )
			{
			case class'GConst'.default.IRNormal :

				TempStr = MakeColorCodeEx(207, 207, 207) $ TempStr;
				break;

			case class'GConst'.default.IRMagic :

				TempStr = MakeColorCodeEx(23, 255, 12) $ TempStr;
				break;

			case class'GConst'.default.IRRare :

				TempStr = MakeColorCodeEx(255, 255, 0) $ TempStr;
				break;

			case class'GConst'.default.IRUnique :

				TempStr = MakeColorCodeEx(229, 212, 140) $ TempStr;
				break;

			case class'GConst'.default.IRPlatinum :

				TempStr = MakeColorCodeEx(174, 51, 249) $ TempStr;
				break;

			default :

				TempStr = MakeColorCodeEx(255, 255, 255) $ TempStr;
				break;
			}

			ItemStringArr[i] = TempStr;
		}

		if (ItemStringArr.Length > 0) {
			X = Controller.MouseX+32;
			Y = Controller.MouseY+24;
			XL = MaxXL + 10;
			YL = MaxYL + 10;

			if (X < 0)
				X = 0;
			if (X+XL > C.ClipX)
				X = C.ClipX - XL;
			if (Y < 0)
				Y = 0;
			if (Y+YL > C.ClipY)
				Y = C.ClipY - YL;

			C.SetPos(X, Y);
			C.SetRenderStyleAlpha();
			C.DrawTile(Texture'TextBlackBg',XL,YL,0,0,0,0);
			class'CNativeInterface'.static.DrawRect(X,Y,X+XL,Y+YL,class'Canvas'.static.MakeColor(128,128,128));

			for (i=0;i<ItemStringArr.Length;i++)
				C.DrawTextJustified(ItemStringArr[i],0,X+4,Y+5+i*YYL,X+XL,Y+5+i*YYL+YYL);
		}
	}
}

function bool DoubleClick()
{
	local Point Point;
	Point = ScreenToRowColumn(Components[4],Controller.MouseX,Controller.MouseY);

	if (Point.X != -1 && Point.Y != -1)
	{
		if( !bIsSellerBooth )
			UseItem(SepInventory.GetItem_RC(Point.X,Point.Y));

		return true;
	}

	return false;
}

// keios - ���űݾ� ǥ�� �޽����ڽ� ���
function ShowConfirmMessagebox(string price, int id)
{
	local string money_before, money_after;
	local string message_string;

	money_before = Controller.MoneyStringEx( SephirothPlayer(PlayerOwner).PSI.strMoney );
	money_after = Controller.MoneyStringEx( 
		SephirothPlayer(PlayerOwner).SubInt64( SephirothPlayer(PlayerOwner).PSI.strMoney, price ) );
	price = Controller.MoneyColoredString( price );

	message_string = Localize("Modals","BuyPriceInfo","Sephiroth") $ "\\n"
		$ price @ Localize("Terms", "Lenni", "Sephiroth") $ "\\n"
		$ Chr(4)$"    " $ Localize("Modals","BeforeBuy","Sephiroth") $ ":" @ money_before @ Localize("Terms", "Lenni", "Sephiroth") $ "\\n"
		$ Chr(4)$"    " $ Localize("Modals","AfterBuy","Sephiroth") $ ":" @ money_after @ Localize("Terms", "Lenni", "Sephiroth") $ "\\n"
		$ Localize("Modals","WillYouBuy","Sephiroth");

	class'CMessageBox'.static.MessageBox(Self,
		"BoothBuyItem",
		message_string,
		MB_YesNo, 
		id);
}

//add neive : ���� ���� ���� --------------------------------------------------
function bool IsLockedInventory()
{
	local int nGab;
	nGab = SephirothPlayer(PlayerOwner).PSI.nCurTime - SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime;

	if(nGab < LockSec) // 1�ʰ� ���� ���¿��� �ȵ�!
		return true;

	return false;
}


function Render(Canvas C)
{
	super.Render(C);

	RenderDropArea(C);
}

defaultproperties
{
     Components(0)=(XL=280.000000,YL=423.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=280.000000,YL=423.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=249.000000,OffsetYL=14.000000,ToolTip="CloseContext")
     Components(3)=(Id=3,ResId=6,Type=RES_PushButton,XL=30.000000,YL=30.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=381.000000)
     Components(4)=(Id=4,Type=RES_RowColumn,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=47.000000,ColumnCount=9,RowCount=13,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(5)=(Id=5,ResId=6,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=115.000000,OffsetYL=384.000000)
     Components(6)=(Id=6,Type=RES_TextButton,XL=136.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=101.000000,OffsetYL=387.000000,TextAlign=TA_MiddleRight)
     TextureResources(0)=(Package="UI_2011",Path="win_inven",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_clean_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_clean_o",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="inven_coin_bg",Style=STY_Alpha)
     bVisible=True
     bAcceptDoubleClick=True
     IsBottom=True
}
