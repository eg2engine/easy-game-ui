class CDepartment extends CMultiInterface;

const BN_Exit = 1;
const BN_Buy = 2;
const BN_Sell = 3;
const BN_Repair = 4;
const BN_Tab = 100;

const IDM_BuyItem = 1;
const IDS_BatchAmount = 2;

var NpcServerInfo ShopNpc;
var Npc NpcPawn;
var SephirothPlayer.Shop Shop;
var ShopItems ShopItems;

var float OffsetXL;
var float OffsetYL;

var int TabState, ActionState;
var UIComponent TabButtons[8];

var int SelectedItemIndex,HotItemIndex;
var SephirothItem SelectedItem;
var int DisplayedItemCount;
var int DisplayStartIndex;

var string m_sTitle;

const IDM_SellItem = 5;
const IDM_RepairItem = 6;

function SetHost(NpcServerInfo Npc)
{
	ShopNpc = Npc;
	NpcPawn = Npc(Controller(ShopNpc.Owner).Pawn);
}

function SetShop(SephirothPlayer.Shop InShop)
{
	Shop = InShop;
	TabState = 0;
	ActionState = BN_Buy;
	LoadCategoryButton();
	SephirothPlayer(PlayerOwner).Net.NotiSellPrices(ShopNpc.PanID, Shop.Categories[0]);
}

function SetItems(ShopItems Items)
{
	ShopItems = Items;
}

function LoadCategoryButton()
{
	local int i;
	for (i=0;i<Shop.Categories.Length;i++) {
		TabButtons[i].Id = 1000+i;
		TabButtons[i].Type = RES_PushButton;
		TabButtons[i].TextAlign=TA_MiddleCenter;
		TabButtons[i].LocType = LCT_Terms;
		TabButtons[i].Caption = Shop.Categories[i];
		TabButtons[i].XL = 102;
		TabButtons[i].YL = 24;
		TabButtons[i].RenderStyle = ERenderStyle.STY_Alpha;		
		TabButtons[i].Tooltip = Localize("Terms", Shop.Categories[i],"Sephiroth");
		TabButtons[i].bNoLocalizeTooltip = true;
		InitComponent(TabButtons[i]);
		SetComponentNotify(TabButtons[i],BN_Tab+i,Self);
	}

	SetTabButtonsTexture(0);
}

function SetTabButtonsTexture(int SelectedComponentId)		//modified by yj
{
	local int i;

	for(i=0;i<Shop.Categories.Length;i++)
		SetComponentTextureId(TabButtons[i],15,-1,17,16);	// ��ü �� �̹��� ����

	SetComponentTextureId(TabButtons[SelectedComponentId],17,-1,17,17);	// ���� ���� �� �̹��� ����
}

function OnInit()
{
	SetComponentTextureId(Components[5],9,-1,11,10);
	SetComponentTextureId(Components[6],12,-1,14,13);
	SetComponentTextureId(Components[7],12,-1,14,13);
	SetComponentTextureId(Components[8],12,-1,14,13);
	SetComponentNotify(Components[5],BN_Exit,Self);
	SetComponentNotify(Components[6],BN_Buy,Self);
	SetComponentNotify(Components[7],BN_Sell,Self);
	SetComponentNotify(Components[8],BN_Repair,Self);

	m_sTitle = Localize("CDepartment", "Title", "SephirothUI");
}

function OnFlush()
{
	ShopItems = None;
	SephirothPlayer(PlayerOwner).CloseShopMenu();
}

function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[0],true,C.ClipX-Components[0].XL*Components[0].ScaleX-OffsetXL,OffsetYL);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);

	MoveComponent(TabButtons[0],true,Components[0].X+17,Components[0].Y+36);

	for (i=1;i<Shop.Categories.Length;i++)
		MoveComponent(TabButtons[i],true,TabButtons[i-1].X+TabButtons[i-1].XL,TabButtons[0].Y);

	Super.Layout(C);
}

function OnPreRender(Canvas C)
{
	local vector MyPos,NpcPos;

	if (ShopItems == None)
		return;

	MyPos = PlayerOwner.Pawn.Location;
	NpcPos = NpcPawn.Location;
	if (sqrt((MyPos.X-NpcPos.X)^2+(MyPos.Y-NpcPos.Y)^2) > 1500) {
		Parent.NotifyInterface(Self,INT_Close);
		return;
	}

	Components[4].bDisabled = ((Controller.SelectingSource != None && !Controller.SelectingSource.IsInState('Nothing')) || ActionState != BN_Buy || ShopItems.Items.Length < Components[3].YL/Components[9].YL);

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}

function SephirothItem GetSelectedItemServerInfo(int StartX,int StartY,int Width,int Height,int StepHeight,int StartIndex,out int ItemIndex)
{
	local int HotX,HotY;
	local int LocalIndex;
	HotX = PlayerOwner.Player.WindowsMouseX - StartX;
	HotY = PlayerOwner.Player.WindowsMouseY - StartY;

	// filter non-itemarea clicking
	if (HotX < 0 || HotX > Width || HotY < 0 || HotY > Height)
		return None;
	LocalIndex = HotY / StepHeight;

	// filter no-item clicking
	if (StartIndex + LocalIndex > ShopItems.Items.Length)
		return None;
	ItemIndex = StartIndex+LocalIndex;

	if (ItemIndex >= 0 && ItemIndex < ShopItems.Items.Length)
		return ShopItems.Items[ItemIndex];
	else
		return None;
}


function OnPostRender(HUD H, Canvas C)
{
	local int i,yy;
	local float X,Y,fW,fH;
	local SephirothItem ISI;
	local int ItemIndex;
	local InterfaceRegion ItemRegion;
	local color OldColor;
	local Material Sprite;

	for (i=0;i<Shop.Categories.Length;i++)
	{
		if (TabButtons[i].bVisible)
			RenderComponent(C,TabButtons[i]);		
	}
/*
	// ���� �̸� --------------------
	X = Components[0].X;
	Y = Components[0].Y;
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.DrawKoreanText(Shop.NpcName,X,Y+10,Components[0].XL,14);
	//-------------------------------
*/
//	C.SetPos(Components[2].X, Components[2].Y);
//	C.DrawRect1Fix(Components[2].XL, Components[2].YL);

	X = Components[3].X;
	Y = Components[3].Y;
	DisplayedItemCount = Components[3].YL / Components[9].YL;
	yy = Y;

	if (ShopItems == None)
		return;

	for ( i = 0 ; i < DisplayedItemCount ; i++ )
	{
		OldColor = C.DrawColor;

		if (i+DisplayStartIndex < ShopItems.Items.Length)
			ISI= ShopItems.Items[i+DisplayStartIndex];
		else
			ISI = None;

		if ( ISI != None )
		{
			ItemRegion.X = X;
			ItemRegion.Y = yy;
			ItemRegion.W = Components[3].XL;
			ItemRegion.H = Components[9].YL;
			if (Controller.SelectingSource != None && !Controller.SelectingSource.IsInState('Nothing'))
				C.SetDrawColor(150,150,150);
			else
			{
				if (ActionState == BN_Buy && IsCursorInsideRegion(ItemRegion))
				{
					ISI = GetSelectedItemServerInfo(X,Y,Components[3].XL,Components[3].YL,Components[9].YL,DisplayStartIndex,ItemIndex);
					if (ISI != None)
						HotItemIndex = ItemIndex;
					C.SetPos(ItemRegion.X,ItemRegion.Y);
					C.SetDrawColor(255,255,255);
					//C.DrawRect(Texture'Engine.WhiteSquareTexture',ItemRegion.W,ItemRegion.H);
					C.DrawTile(TextureResources[19].Resource,Components[9].XL,Components[9].YL,0,0,Components[9].XL+1,Components[9].YL);
					C.SetDrawColor(43,55,43);

					CItemInfoBox(SephirothInterface(Parent.Parent).ItemTooltipBox).SetDisplayMethod(3);

//					if ( Controller.bMouseMoved )
					// ���콺 ������ �������̽��� ������ ������ (��, Ȯ�尡���� ������ �ʾ��� ��) ����ȴ�. Xelloss
					if ( SephirothInterface(Parent.Parent).ITopOnCursor == Self )
						SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(ISI, X, Y + Components[3].YL, true, C.ClipX, C.ClipY);
					else
						SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
				}
				else if (ActionState == BN_Buy)
				{
					C.SetPos(ItemRegion.X,ItemRegion.Y);
					C.SetDrawColor(255,255,255);
					C.DrawTile(TextureResources[18].Resource,Components[9].XL,Components[9].YL,0,0,Components[9].XL+1,Components[9].YL);

					C.SetDrawColor(243,255,243);
				}
				else {
					C.SetDrawColor(150,150,150);
				}
			}
			C.SetDrawColor(255,255,255);
			C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
			C.DrawKoreanText(ClipText(C, ISI.LocalizedDescription, 180) ,ItemRegion.X+5,ItemRegion.Y+5,ItemRegion.W,ItemRegion.H);
			C.SetDrawColor(215,213,174);
			C.SetKoreanTextAlign(ETextAlign.TA_BottomRight);
			C.DrawKoreanText(Controller.MoneyStringEx(ISI.strBuyPrice),ItemRegion.X,ItemRegion.Y-5,ItemRegion.W - 25,ItemRegion.H);
			yy += Components[9].YL;
		}
		C.DrawColor = OldColor;
	}

	// ��ǰ �̸� ����
	X = Components[2].X;
	Y = Components[2].Y;
	if (HotItemIndex >= 0 && HotItemIndex < ShopItems.Items.Length)
	{
		ISI = ShopItems.Items[HotItemIndex];
		Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
		if (Sprite != None)
		{
			C.SetRenderStyleAlpha();

			fW = ISI.Width*25;
			fH = ISI.Height*25;
			C.SetPos(X + (Components[2].XL/2) - (fW/2), Y + (Components[2].YL/2) - (fH/2));
			if (ActionState == BN_Buy)
				C.SetDrawColor(243,255,243);
			else
				C.SetDrawColor(150,150,150);
			C.DrawTile(Sprite,fW,fH,0,0,fW,fH);

/*
			C.SetPos(X+(90-ISI.Width*25)/2,Y+(120-ISI.Height*25)/2);
			if (ActionState == BN_Buy)
				C.SetDrawColor(243,255,243);
			else
				C.SetDrawColor(150,150,150);
			C.DrawTile(Sprite,ISI.Width*25,ISI.Height*25,0,0,ISI.Width*25,ISI.Height*25);*/
		}
	}
}



function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i,ItemIndex;
	local SephirothItem ISI;

	if(!IsCursorInsideInterface())
		return false;

	if(Key == IK_LeftMouse && (Action == IST_Press || Action == IST_Release))
	{
		if((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) ||
			(Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		{
			return false;
			// Controller.ResetDragAndDropAll();
		}
	}	

	for (i=0;i<Shop.Categories.Length;i++) {
		if (IsCursorInsideComponent(TabButtons[i])) {
			if (Key == IK_LeftMouse) {
				if (Action == IST_Press) {
					TabButtons[i].bMousePress = true;
					return true;
				}
				else if (Action == IST_Release) {
					if (TabButtons[i].bMousePress) {
						TabButtons[i].bMousePress = false;
						if (TabButtons[i].NotifyTarget != None)
							TabButtons[i].NotifyTarget.NotifyComponent(TabButtons[i].Id,TabButtons[i].NotifyId);
					}
					return true;
				}
			}
		}
	}
	if (ActionState == BN_Buy) {
		if (Key == IK_LeftMouse && Action == IST_Press && IsCursorInsideComponent(Components[3])) {
			ISI = GetSelectedItemServerInfo(Components[3].X,Components[3].Y,Components[3].XL,Components[3].YL,Components[9].YL,DisplayStartIndex,ItemIndex);
			if (ISI != None) {
				SelectedItemIndex = ItemIndex;
				SelectedItem = ISI;
				HotItemIndex = ItemIndex;
				if (ISI.HasAmount() && ISI.DetailType != ISI.IDT_Arrow) //������ ��Ʈ�� �Ǵ�.
					class'CEditBox'.static.EditBox(Self,"BuyItem",Localize("Modals","TitleAmountBuy","Sephiroth"),IDS_BatchAmount,3); // ����, ��ũ�� ����
				else
					class'CMessageBox'.static.MessageBox(Self,"BuyItem",ISI.LocalizedDescription $ "\\n" $ Localize("Modals","TitleItemBuy","Sephiroth"), MB_YesNo,IDM_BuyItem);
			}
			return true;
		}
		if (Action == IST_Press && !Components[4].bDisabled) {
			if (Key == IK_MouseWheelUp) {
				ScrollUp_ItemArea();
				return true;
			}
			if (Key == IK_MouseWheelDown) {
				ScrollDown_ItemArea();
				return true;
			}
		}
	}
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
	return false;
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)	{

	local int i, nInven;
	local int NotifyValue;
	local CStore store;

	if ( NotifyType == INT_MessageBox )	{

		NotifyValue = int(Command);

		switch ( NotifyValue )	{

		case IDM_BuyItem :

			if ( SelectedItemIndex >= 0 && SelectedItemIndex < ShopItems.Items.Length )	{
				OnBuyItemByIndex(SelectedItemIndex,1);
			}

			break;

        case IDM_SellItem :
        case IDM_RepairItem :

			store = SephirothInterface(PlayerOwner.myHud).Store;

			if ( store == None )
				return;

			if ( CBag(Controller.SelectingSource) != None )
				nInven = 0;
			else if ( CBagResizable(Controller.SelectingSource) != None )
				nInven = CBagResizable(Controller.SelectingSource).SubInvenIndex + 1;
			else
				return;

            if ( NotifyValue == IDM_SellItem )	{

                for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )
                    SephirothPlayer(PlayerOwner).Net.NotiSell(store.Store.ShopNpc.PanId, nInven, SephirothItem(Controller.SelectedList[i]).X, SephirothItem(Controller.SelectedList[i]).Y);
            }
            else if ( NotifyValue == IDM_RepairItem )	{

                for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )
                    SephirothPlayer(PlayerOwner).Net.NotiRepair(store.Store.ShopNpc.PanId, nInven, SephirothItem(Controller.SelectedList[i]).X, SephirothItem(Controller.SelectedList[i]).Y);
            }

        case -1 * IDM_SellItem :
        case -1 * IDM_RepairItem :

            Parent.bIgnoreKeyEvents = false;

			Controller.ResetSelecting();
			Controller.ResetDragging();
			Controller.ResetObjectList();
			Controller.SelectingSource = None;
			Controller.DragSource = None;
           break;
		}
	}
}

function OnBuyItem(SephirothItem Item, optional int Count)
{
	if (Item != None)
		SephirothPlayer(PlayerOwner).Net.NotiBuy(ShopNpc.PanID, Item.PanID, Count);
}

function OnBuyItemByIndex(int Index, optional int Count)
{
	if (Index >= 0 && Index < ShopItems.Items.Length)
		OnBuyItem(ShopItems.Items[Index], Count);
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	local string strMoney;
	if (NotifyId == IDS_BatchAmount && SelectedItemIndex >= 0 && SelectedItemIndex < ShopItems.Items.Length) {
		OnBuyItemByIndex(SelectedItemIndex, int(EditText));
	}
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)	{

	if (NotifyId == BN_Exit)
		Parent.NotifyInterface(Self,INT_Close);
	else if ( NotifyId == BN_Buy )	{

		ActionState = BN_Buy;
		SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
	}
	else if ( NotifyId == BN_Sell )	{

		ActionState = BN_Sell;
		SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
		SephirothPlayer(PlayerOwner).Net.NotiBuyPrices(ShopNpc.PanID);

/*		if ( Controller.SelectingSource != None )	{

			lstrTotalMoney = "0";
			
			for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )	{

				strPrice = SephirothItem(Controller.SelectedList[i]).strSellPrice;
				strPrice = (ClientController(PlayerOwner)).GetItemSellPriceString(strPrice);
				lstrTotalMoney = SephirothPlayer(PlayerOwner).AddInt64(lstrTotalMoney, strPrice);
			}

			strMoney = SephirothPlayer(PlayerOwner).AddInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, lstrTotalMoney);
			class'CMessageBox'.static.MessageBox(Self, "SellItem", Localize("Modals", "TitleItemSell", "Sephiroth") $ "\\n" $ Localize("Modals", "BeforeSell", "Sephiroth") $ ": " $
												Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) $ "\\n" $ Localize("Modals", "AfterSell", "Sephiroth") $ ": " $
												Controller.MoneyStringEx(strMoney), MB_YesNo, IDM_SellItem);
		
			Controller.SelectingSource.GotoState('Dragging');
		}*/
	}
	else if ( NotifyId == BN_Repair )	{

		ActionState = BN_Repair;
		SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
		SephirothPlayer(PlayerOwner).Net.NotiRepairPrices(ShopNpc.PanID);

/*		if ( Controller.SelectingSource != None )	{

			lstrTotalMoney = "0";

			for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )	{

				strPrice = SephirothItem(Controller.SelectedList[i]).strRepairPrice;
				strPrice = (ClientController(PlayerOwner)).GetItemSellPriceString(strPrice);
				lstrTotalMoney = SephirothPlayer(PlayerOwner).AddInt64(lstrTotalMoney, strPrice);
			}

			strMoney = SephirothPlayer(PlayerOwner).SubInt64(SephirothPlayer(PlayerOwner).PSI.strMoney, lstrTotalMoney);
			class'CMessageBox'.static.MessageBox(Self, "RepairItem", Localize("Modals", "TitleItemRepair", "Sephiroth") $ "\\n" $ Localize("Modals", "BeforeRepair", "Sephiroth") $ ": " $
												Controller.MoneyStringEx(SephirothPlayer(PlayerOwner).PSI.strMoney) $ "\\n" $ Localize("Modals", "AfterRepair", "Sephiroth") $ ": " $
												Controller.MoneyStringEx(strMoney), MB_YesNo, IDM_RepairItem);
                
			Controller.DragSource.GotoState('Nothing');
		}*/
	}
	else if ( NotifyId >= BN_Tab && NotifyId < BN_Tab + Shop.Categories.Length )	{

		TabState = NotifyId - BN_Tab;
		SetTabButtonsTexture(TabState);		//modified by yj   //�� ��ư�� �ؽ��� ����
		SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
		DisplayStartIndex = 0;
		SephirothPlayer(PlayerOwner).Net.NotiSellPrices(ShopNpc.PanID, Shop.Categories[TabState]);
	}
}

function ScrollUp_ItemArea()
{
	DisplayStartIndex = max(DisplayStartIndex-1, 0);
}

function ScrollDown_ItemArea()
{
	DisplayStartIndex = min(DisplayStartIndex+1,ShopItems.Items.Length-DisplayedItemCount);
}

function NotifyScrollUp(int CmpId,int Amount)
{
	ScrollUp_ItemArea();
}

function NotifyScrollDown(int CmpId,int Amount)
{
	ScrollDown_ItemArea();
}

function bool PushComponentBool(int CmpId)
{
	if (CmpId == 6) return ActionState == BN_Buy;
	if (CmpId == 7) return ActionState == BN_Sell;
	if (CmpId == 8) return ActionState == BN_Repair;
	if (CmpId >= TabButtons[0].Id && CmpId < TabButtons[0].Id + Shop.Categories.Length) {
		return TabState == CmpId - TabButtons[0].Id;
	}
}

function plane PushComponentPlane(int CmpId)
{
	local Plane P;
	if (CmpId == 4) {
		if (ShopItems != None)
			P.X = ShopItems.Items.Length;
		P.Y = DisplayedItemCount;
		P.Z = 1;
		P.W = DisplayStartIndex;
	}
	return P;
}

defaultproperties
{
     HotItemIndex=-1
     Components(0)=(XL=347.000000,YL=423.000000)
     Components(1)=(Id=1,ResId=21,Type=RES_Image,XL=325.000000,YL=356.000000,PivotDir=PVT_Copy,OffsetXL=12.000000,OffsetYL=56.000000)
     Components(2)=(Id=2,XL=120.000000,YL=235.000000,PivotDir=PVT_Copy,OffsetXL=16.000000,OffsetYL=67.000000)
     Components(3)=(Id=3,XL=171.000000,YL=340.000000,PivotDir=PVT_Copy,OffsetXL=139.000000,OffsetYL=67.000000)
     Components(4)=(Id=4,Type=RES_ScrollBar,XL=15.000000,YL=325.000000,PivotDir=PVT_Copy,OffsetXL=315.000000,OffsetYL=66.000000)
     Components(5)=(Id=5,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=318.000000,OffsetYL=14.000000)
     Components(6)=(Id=6,Caption="Buy",Type=RES_ToggleButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=307.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(7)=(Id=7,Caption="Sell",Type=RES_ToggleButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=338.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(8)=(Id=8,Caption="Repair",Type=RES_ToggleButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=369.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(9)=(Id=9,XL=171.000000,YL=36.000000)
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
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="chr_tab_n",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="chr_tab_o",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_npc_shop_n",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_npc_shop_o",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011_btn",Path="btn_npc_shop_c",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011",Path="npc_shop_win_info",Style=STY_Alpha)
     IsBottom=True
}
