class CTrade extends CSelectable;

var CBag Bag;
var ExchangeItems InboxItems, OutboxItems;
var bool bOkPressed, bPartnerOkPressed;
//var CSubInventorySelectBox SubSelectBox;

const BN_Exchange = 1;
const BN_Cancel = 2;
const BN_Money = 3;

const IDM_ExchangeCancel = 1;
const IDS_ExchangeMoney = 2;

//var CInfoBox InfoBox;

var SephirothItem SealedItem;


function bool IsCursorInsideInterface()
{
	if ( IsCursorInsideComponent(Components[0]) || IsCursorInsideComponent(Components[1]) || Bag.IsCursorInsideInterface() )
		return true;

	return false;

//	return IsCursorInsideComponent(Components[0]);
}


function OnInit()
{
	InboxItems = SephirothPlayer(PlayerOwner).InboxItems;
	OutboxItems = SephirothPlayer(PlayerOwner).OutboxItems;
	if (InboxItems != None)
		InboxItems.OnDrawItem = InternalDrawItem;
	if (OutboxItems != None)
		OutboxItems.OnDrawItem = InternalDrawItem;
	Bag = CBag(AddInterface("SephirothUI.CBag"));
	if (Bag != None)
		Bag.ShowInterface();
	Bag.OffsetXL = Components[0].XL * 2;
	SetComponentNotify(Components[6],BN_Exchange,Self);
	SetComponentNotify(Components[7],BN_Cancel,Self);
	SetComponentNotify(Components[8],BN_Money,Self);
	SetComponentTextureId(Components[6],2,0,4,3);
	SetComponentTextureId(Components[7],2,0,4,3);
/*
	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(800,Bag.Components[0].Y+Bag.Components[0].YL);
	}
*/

	GotoState('Nothing');
}


function OnFlush()
{
	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if (Bag != None) {
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
	if (InboxItems != None)
		InboxItems.Clear();
	if (OutboxItems != None)
		OutboxItems.Clear();
/*
	if (SubSelectBox != none){
    	SubSelectBox.HideInterface();
    	RemoveInterface(SubSelectBox);
    	SubSelectBox = none;
	}*/
}


function Layout(Canvas C)
{
	local int i;
	// 내 창 위치 잡기 ( 남 창은 자동으로 오른쪽에 붙으니- )
	MoveComponent(Components[0],true,C.ClipX-(Components[0].XL)-(Components[1].XL),0);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
	Super.Layout(C);
}


function OnPreRender(Canvas C)
{
	Components[6].bDisabled = OutboxItems != None && OutboxItems.Items.Length == 0 && InboxItems != None && InboxItems.Items.Length == 0 && OutboxItems.Money == 0 && InboxItems.Money == 0;
}

function Render(Canvas C)
{
/*	Super.Render(C);
	if (Bag != None)
		Bag.ShowItemInfo(C, InfoBox);
	ShowItemInfo(C, InfoBox);*/

	local CInterface theInterface;
	local SephirothInterface MainHud;

	Super.Render(C);
	
	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == None )
	{
		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}
	else if(theInterface == Self)
	{
		if(IsCursorInsideMainFrame())		// 내가 올린거
			ShowItemInfo(C, MainHud.ItemTooltipBox);
		else if(IsCursorInsideComponent(Components[1]))	// 남이 올린거
			ShowItemInfo(C, MainHud.ItemTooltipBox);
		else if(Bag.IsCursorInsideMainFrame())
			Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	}
	else
		MainHud.ItemTooltipBox.SetInfo(None);

/*
	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface.Parent == Self )
		ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);
*/
	RenderDropArea(C);
}

function ShowItemInfo(Canvas C, CInfoBox InfoBox)	{

	local Point Point;
	local SephirothItem ISI;
	local InterfaceRegion RgnEnd;

	if (!IsCursorInsideComponent(Components[0]) && !IsCursorInsideComponent(Components[1]) || Controller.Modal())
		return;

	Point = ScreenToRowColumn(Components[4],Controller.MouseX,Controller.MouseY);

	if (Point.X != -1 && Point.Y != -1 && OutboxItems != None) {
		ISI = OutboxItems.GetItem_RC(Point.X, Point.Y);
		if (ISI != None) {
			RgnEnd = RowColumnToScreen(Components[4],ISI.Y+ISI.Height-1,ISI.X+ISI.Width-1);
			InfoBox.SetInfo(ISI, RgnEnd.X+RgnEnd.W, RgnEnd.Y+RgnEnd.H, true, C.ClipX, C.ClipY);
		}
	}

	Point = ScreenToRowColumn(Components[5],Controller.MouseX,Controller.MouseY);
	if (Point.X != -1 && Point.Y != -1 && InboxItems != None) {
		ISI = InboxItems.GetItem_RC(Point.X, Point.Y);
		if (ISI != None) {
			RgnEnd = RowColumnToScreen(Components[5],ISI.Y+ISI.Height-1,ISI.X+ISI.Width-1);
			InfoBox.SetInfo(ISI, RgnEnd.X+RgnEnd.W, RgnEnd.Y+RgnEnd.H, true, C.ClipX, C.ClipY);
		}
	}
}


function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local int CellSize;
	local material Sprite;
	local int X, Y, XL, YL;

	CellSize = 25;

	C.SetRenderStyleAlpha();
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

	C.SetPos(X,Y);
	C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);

	Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
	if (Sprite != None) {
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
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
	
	if (Item.IsPotion() || Item.IsScroll() || Item.IsQuiver() || Item.IsPetFood() || Item.IsStackUI())	// Mod ssemp : 스텍 유아이용 아이템 카운트 추가
	{
		C.SetPos(X,Y);
		C.SetDrawColor(255,255,255);
		C.DrawText(Item.Amount);
	}
}


function DrawObject(Canvas C)
{
	local float X, Y, W, H;
	local Color OldColor;

	OldColor=C.drawColor;

	C.SetDrawColor(255, 255, 255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	X = Components[0].X;
	Y = Components[0].Y;
	W = Components[6].XL;
	H = Components[6].YL;
	C.Style = ERenderStyle.STY_Normal;
	if (OutboxItems != None)
	{
		C.SetDrawColor(229, 201, 174);
		C.DrawKoreanText(OutboxItems.OwnerName,X,Y+15,Components[0].XL,15);
	}
	Components[8].bDisabled = InboxItems != None && InboxItems.OwnerId == 0;
	if (OutboxItems != None) {
		Components[8].Caption = Controller.MoneyStringEx(OutboxItems.strMoney);
		if(Components[8].Caption == "") {
			X = Components[8].X;
			Y = Components[8].Y;
			C.SetDrawColor(126, 126, 126);
			C.DrawKoreanText(Localize("CTradeUI","TypeLeni","SephirothUI"),X,Y,134,20);
		}
	}

	// 수락 처리
	C.SetRenderStyleAlpha();
	C.KTextFormat = ETextAlign.TA_MiddleCenter;

	if (bOkPressed) {
		if (Level.TimeSeconds - int(Level.TimeSeconds) < 0.5) {
			X = Components[6].X;
			Y = Components[6].Y;
			C.SetPos(X,Y);
			C.DrawTile(TextureResources[4].Resource,W,H,0,0,W,H);
			C.DrawKoreanText(Localize("Terms","Exchange","Sephiroth"),X,Y,W,H);
		}
	}

	X = Components[1].X;
	Y = Components[1].Y;
	if (InboxItems != None && InboxItems.OwnerName != '')
	{
		C.SetDrawColor(229, 201, 174);
		C.DrawKoreanText(InboxItems.OwnerName,X,Y+15,Components[1].XL,15);
	}

	C.SetDrawColor(255, 255, 255);
	if (InboxItems != None)
		Components[9].Caption = Controller.MoneyStringEx(InboxItems.strMoney);	
				
	if (bPartnerOkPressed) {
		if (Level.TimeSeconds - int(Level.TimeSeconds) < 0.5) {
			X = X + 20;
			Y = Y + Components[1].YL - H - 14;
			C.SetPos(X,Y);
			C.DrawTile(TextureResources[4].Resource,W,H,0,0,W,H);
			C.DrawKoreanText(Localize("Terms","Exchange","Sephiroth"),X,Y,W,H);
		}
	}

	Render_Items(C, OutboxItems, Components[4].X, Components[4].Y);
	Render_Items(C, InboxItems, Components[5].X, Components[5].Y);

	C.drawColor=OldColor;	

//	if(Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
//		RenderSelectionState(C, CBag(Controller.DragSource).Components[7].X, CBag(Controller.DragSource).Components[7].Y, Controller.SelectedList);
}

function Render_Items(Canvas C,SephirothInventory Inv,int X,int Y)
{
	if (Inv != None)
		Inv.DrawItems(C, X, Y);
}


function bool Drop()
{
	local SephirothItem ISI;
	local Point Point, ItemPos;
	local CMainInterface MainHud;
	local int i;

	if (Controller.SelectedList.Length > 0)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None && Controller.DragSource != None)
		{
			Point = ScreenToRowColumn(Components[4],Controller.MouseX,Controller.MouseY);

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

				if (OnDropItem(ItemPos))
					return true;
			}
			else
			{
				MainHud = SephirothInterface(Parent).MainHud;

				if ( (Controller.DragSource.IsA('CBag')||Controller.DragSource.IsA('CBagResizable')) && !Bag.IsCursorInsideInterface() && !IsCursorInsideComponent(Components[0]) && !IsCursorInsideComponent(Components[1])) 
				{
					if (MainHud == None || !MainHud.IsCursorInsideInterface()) 
					{
						if (Controller.CanDropObjectAtMousePos())
						{
							for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )
							{
								ISI = SephirothItem(Controller.SelectedList[i]);

								if (ISI != None)
								{
									// 봉인 해제된 아이템인지 확인한다.
									if ( ISI.xSealFlag == ISI.eSEALFLAG.SF_USED )
									{
										if ( Controller.DragSource == Bag )
										{
											Bag.SealedItem = ISI;
											class'CMessageBox'.static.MessageBox(Bag, "DropSealedItem", Localize("Modals", "DeleteUsedItem", "Sephiroth"), MB_YesNo, Bag.IDM_DROPUSEDITEM);
										}
										else
										{
											CBagResizable(Controller.DragSource).SealedItem = ISI;
											class'CMessageBox'.static.MessageBox(CBagResizable(Controller.DragSource), "DropSealedItem",
																				Localize("Modals", "DeleteUsedItem", "Sephiroth"), MB_YesNo,
																				CBagResizable(Controller.DragSource).IDM_DROPUSEDITEM);
										}

										break;
									}
									else
									{
										if (Controller.DragSource.IsA('CBag'))
											SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(0, ISI.X, ISI.Y, PlayerOwner.Pawn.Location.Z);
										else
											SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(CBagResizable(Controller.DragSource).SubInvenIndex + 1, ISI.X, ISI.Y, PlayerOwner.Pawn.Location.Z);
									}
								}
							}
						}
						else
							Controller.ResetDragAndDropAll();

						return true;
					}
				}
			}
		}
	}

	return false;
}


function bool OnDropItem(Point Dest)
{
	local int i;
	local int InvenIndex;
	local SephirothItem Item;
	local array<SephirothItem>ItemList;


	if ( ( Controller.DragSource.IsA('CBag') || Controller.DragSource.IsA('CBagResizable') ) && InboxItems != None) 
	{
		//CBAG(기본인벤토리) invenIndex = 0, 확장인벤토리 invenIndex = 1~3
		if (Controller.DragSource.IsA('CBag') )
			InvenIndex = 0;
		else if(Controller.DragSource.IsA('CBagResizable') )
			InvenIndex = CbagResizable(Controller.DragSource).SubInvenIndex+1;

		if (Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);

			// 봉인 해제된 아이템인지 확인한다.
			if ( Item.xSealFlag == Item.eSEALFLAG.SF_USED )
			{
				class'CMessageBox'.static.MessageBox(Self, "CannotTrade", Localize("Modals", "CannotTradeUsedItem", "Sephiroth"), MB_OK);
				return false;
			}

			SephirothPlayer(PlayerOwner).Net.NotiXcngAddItem(InboxItems.OwnerId, InvenIndex, Item.X, Item.Y, Dest.X, Dest.Y);
			CBag(Controller.DragSource).RegisterItem(Item);
		}
		else if (Controller.SelectedList.Length > 1)
		{
			for ( i=0 ; i < Controller.SelectedList.Length ; i++ )
			{
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);

				// 봉인 해제된 아이템인지 확인한다.
				if ( ItemList[i].xSealFlag == ItemList[i].eSEALFLAG.SF_USED )
				{
					class'CMessageBox'.static.MessageBox(Self, "CannotTrade", Localize("Modals", "CannotTradeUsedItem", "Sephiroth"), MB_OK);
					return false;
				}
			}

			SephirothPlayer(PlayerOwner).Net.NotiXcngAddItemMany(InboxItems.OwnerId, InvenIndex, ItemList);

			for ( i = 0 ; i < Controller.SelectedList.Length ; i++ )
			{
				CBag(Controller.DragSource).RegisterItem(ItemList[i]);
			}
		}
	
		return true;
	}
	return false;
}

function RenderSelectionState(Canvas C, int OffsetX, int OffsetY, Array<Object> ObjList)
{
	local SephirothItem Item;
	local material Sprite;
	local int CellSize;
	local int X, Y, XL, YL;
	local int i;


	//************* Select Texture Draw *********************************
	CellSize = 25;
	C.SetRenderStyleAlpha();

	for(i=0; i< ObjList.Length; i++)
	{
		Item = SephirothItem(ObjList[i]);
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
	//********************************************************************
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

	if ( Controller.SelectedList.Length == 1 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[4], Controller.MouseX, Controller.MouseY);

			if ( Point.X != -1 && Point.Y != -1 ) 
			{
				if ( ISI.Width % 2 == 1 ) 
					ItemPos.X = Clamp(Point.X - ISI.Width / 2, 0, Components[4].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1) / 2, 0, Components[4].ColumnCount - ISI.Width);

				if ( ISI.Height % 2 == 1 ) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height / 2, 0, Components[4].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1) / 2, 0, Components[4].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[4], ItemPos.Y, ItemPos.X);
				XL = ISI.Width * Components[4].CellWidth + ISI.Width - 1;
				YL = ISI.Height * Components[4].CellHeight + ISI.Height - 1;
				X = Rgn.X;
				Y = Rgn.Y;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for ( i = 0 ; i < ISI.Width ; i++ )
				{
					for ( j = 0 ; j < ISI.Height ; j++ )
					{
						if ( OutboxItems != None )
							Foo = OutboxItems.GetItem_RC(ItemPos.X + i, ItemPos.Y + j);
						if ( Foo != None )
							break;
					}

					if (Foo != None)
						break;
				}

				if ( Foo != None && Foo != ISI )
					Sprite = Texture'CannotDrop';
				else
					Sprite = Texture'CanDrop';

				C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
			}

			Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

			if ( Sprite != None )
			{
				XL = ISI.Width * Components[4].CellWidth;
				YL = ISI.Height * Components[4].CellHeight;
				X = Controller.MouseX - XL / 2;
				Y = Controller.MouseY - YL / 2;

				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);
			}
		}

	}
	else if(Controller.SelectedList.Length > 1)
	{
		ShowSelectionItemList(C, Controller.SelectedList);
	}
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

	if ( Controller.SelectedList.Length == 1 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[4], Controller.MouseX, Controller.MouseY);

			if ( Point.X != -1 && Point.Y != -1 ) 
			{
				if ( ISI.Width % 2 == 1 ) 
					ItemPos.X = Clamp(Point.X - ISI.Width / 2, 0, Components[4].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1) / 2, 0, Components[4].ColumnCount - ISI.Width);

				if ( ISI.Height % 2 == 1 ) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height / 2, 0, Components[4].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1) / 2, 0, Components[4].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[4], ItemPos.Y, ItemPos.X);
				XL = ISI.Width * Components[4].CellWidth + ISI.Width - 1;
				YL = ISI.Height * Components[4].CellHeight + ISI.Height - 1;
				X = Rgn.X;
				Y = Rgn.Y;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for ( i = 0 ; i < ISI.Width ; i++ )
				{
					for ( j = 0 ; j < ISI.Height ; j++ )
					{
						if ( OutboxItems != None )
							Foo = OutboxItems.GetItem_RC(ItemPos.X + i, ItemPos.Y + j);
						if ( Foo != None )
							break;
					}

					if (Foo != None)
						break;
				}

				if ( Foo != None && Foo != ISI )
					Sprite = Texture'CannotDrop';
				else
					Sprite = Texture'CanDrop';

				C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);
			}
		}
	}
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

	if(ObjList.Length > 1)
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

		if (ItemStringArr.Length > 0)
		{
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

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if ((Key == IK_LeftMouse || Key == IK_RightMouse) && (IsCursorInsideComponent(Components[0]) || IsCursorInsideComponent(Components[1])))
		return true;
	if (Key == IK_Escape && Action == IST_Press) {
		class'CMessageBox'.static.MessageBox(Self,"CancelExchange",Localize("Modals","TitleItemExchangeCancel","Sephiroth"),MB_YesNo,IDM_ExchangeCancel);
		return true;	
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Cancel)
		class'CMessageBox'.static.MessageBox(Self,"CancelExchange",Localize("Modals","TitleItemExchangeCancel","Sephiroth"),MB_YesNo,IDM_ExchangeCancel);
	else if (NotifyId == BN_Exchange && InboxItems != None)
		SephirothPlayer(PlayerOwner).Net.NotiXcngOk(InboxItems.OwnerId);
	else if (NotifyId == BN_Money)
		class'CEditBox'.static.EditBox(Self,"ExchangeMoney",Localize("Modals","TitleItemExchangeMoney","Sephiroth"),IDS_ExchangeMoney,10);
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	if (NotifyID == IDS_ExchangeMoney && SephirothPlayer(PlayerOwner).CmpInt64(EditText, "0") > 0 && InboxItems != None)
		SephirothPlayer(PlayerOwner).Net.NotiXcngMoney(InboxItems.OwnerId,EditText);
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Value;
	if (NotifyType == INT_MessageBox)
	{
		Value = int(Command);

		switch (Value)
		{
		case IDM_ExchangeCancel :

			if (InboxItems != None)
				SephirothPlayer(PlayerOwner).Net.NotiXcngCancel(InboxItems.OwnerId);

			Parent.NotifyInterface(Self, INT_Close);
			break;

		default :
			break;
		}
	}
	else if ( Interface == Bag && NotifyType == INT_Close )
	{
		if ( Command == "ByEscape" && SephirothInterface(Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
	}
}


function OnOkPressed(bool bySelf)
{
	bOkPressed = bySelf;
	bPartnerOkPressed = !bySelf;
}

function OnOkReleased(bool bySelf)
{
	bOkPressed = false;
	bPartnerOkPressed = false;
}

defaultproperties
{
     Components(0)=(XL=285.000000,YL=423.000000)
     Components(1)=(Id=1,XL=285.000000,YL=423.000000,PivotDir=PVT_Right,OffsetXL=-5.000000)
     Components(2)=(Id=2,Type=RES_Image,XL=285.000000,YL=423.000000,PivotDir=PVT_Copy)
     Components(3)=(Id=3,Type=RES_Image,XL=285.000000,YL=423.000000,PivotId=1,PivotDir=PVT_Copy)
     Components(4)=(Id=4,Type=RES_RowColumn,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=47.000000,ColumnCount=9,RowCount=12,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(5)=(Id=5,Type=RES_RowColumn,PivotId=1,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=47.000000,ColumnCount=9,RowCount=12,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(6)=(Id=6,Caption="Exchange",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=83.000000,OffsetYL=381.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms,ToolTip="ExchangeStart")
     Components(7)=(Id=7,Caption="Cancel",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=174.000000,OffsetYL=381.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="ExchangeCancel")
     Components(8)=(Id=8,Type=RES_TextButton,XL=124.000000,YL=22.000000,PivotDir=PVT_Copy,OffsetXL=106.000000,OffsetYL=352.000000,TextAlign=TA_MiddleRight,ToolTip="ExchangeLeni")
     Components(9)=(Id=9,Type=RES_Text,XL=124.000000,YL=22.000000,PivotId=1,PivotDir=PVT_Copy,OffsetXL=106.000000,OffsetYL=352.000000,TextAlign=TA_MiddleRight,TextColor=(B=255,G=255,R=255,A=255))
     Components(10)=(Id=10,ResId=1,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=107.000000,OffsetYL=351.000000)
     Components(11)=(Id=11,ResId=1,Type=RES_Image,XL=146.000000,YL=24.000000,PivotId=1,PivotDir=PVT_Copy,OffsetXL=107.000000,OffsetYL=351.000000)
     Components(12)=(Id=12,ResId=5,Type=RES_Image,XL=86.000000,YL=338.000000,PivotDir=PVT_Copy,OffsetXL=237.000000,OffsetYL=40.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_exchg",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="inven_coin_bg",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="exch_deco",Style=STY_Alpha)
     IsBottom=True
}
