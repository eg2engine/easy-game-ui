class CBooth_Seller extends CSelectable;

var CBag Bag;
var BoothItems Showcase;
//var CInfoBox InfoBox;
var CSubInventorySelectBox SubSelectBox;

var array<SephirothItem> reservedItemsList;
var string reservedSellPrice;
var Point reservedDestPos;
var bool bPricePerEach;

var string OpenString;
var string PrepareString;
var string DefaultAdString;

var string TempBoothTitle;
var string TempBoothAd;
var bool TempUseTout;

var float lastChangeBoothTime;

var int SrcInvenIndex;	// Source Inventory Index.
						// SubInventory�� �߰��ϸ鼭, ����� �������� �κ��丮 index�� �����ؾ��Ѵ�.
						// Drop�� �̺�Ʈ�� ���� ��,
						// SourceInterface���� CBag(���� �κ��丮)�� ��� index 0,
						// CBagResizable(Ȯ�� �κ��丮)�� ��� index 1~4�� ������ ������ �ΰ�, ���� �̺�Ʈ �� �̸� ����Ѵ�.								

const BN_ChangeTitle = 1;
const BN_ChangeAd = 2;
const BN_ChangeState = 3;
const CB_Touting = 4;
const BN_Close = 5;

const IDS_ChangeTitle			= 1;
const IDS_ChangeAd				= 2;
const IDM_ChangeStateToOpen		= 3;
const IDM_ChangeStateToPrepare	= 4;
const IDM_Close					= 5;
const IDS_FixPrice				= 6;
const IDS_FixPriceMany			= 7;
const IDM_AddWithSamePrice		= 8;
const IDM_FixPricePerItem		= 11;

const BS_None = 0;
const BS_Open = 1;
const BS_Prepare = 2;
const BS_Visit = 3;

var string m_sTitle;
var string sTotalSell;

function OnInit()
{
	SetComponentTextureId(Components[4],5,-1,7,6);
	SetComponentTextureId(Components[5],5,-1,7,6);
	SetComponentTextureId(Components[6],8,-1,10,9);
	SetComponentTextureId(Components[13],2,-1,4,3);

	SetComponentNotify(Components[4], BN_ChangeTitle, Self);
	SetComponentNotify(Components[5], BN_ChangeAd, Self);
	SetComponentNotify(Components[6], BN_ChangeState, Self);
	SetComponentNotify(Components[7], CB_Touting, Self); 
	SetComponentNotify(Components[13], BN_Close, Self);

	OpenString = Localize("CBooth","S_Open","SephirothUI");
	PrepareString = Localize("CBooth", "S_Prepare", "SephirothUI");
	DefaultAdString = Localize("CBooth", "S_PlzAd", "SephirothUI");

	lastChangeBoothTime = -1;
	SephirothPlayer(PlayerOwner).PSI.BoothState = BS_Prepare;

	TempBoothTitle = SephirothPlayer(PlayerOwner).PSI.BoothTitle;
	if( SephirothPlayer(PlayerOwner).PSI.bUseAd )
		TempBoothAd = DefaultAdString;
	else
		TempBoothAd = "";

	TempUseTout = true;//SephirothPlayer(PlayerOwner).PSI.bUseTout;

	if( !SephirothPlayer(PlayerOwner).PSI.bUseAd )
		Components[5].bDisabled = true;

	bPricePerEach = false;
	reservedDestPos.X = -1;
	reservedDestPos.Y = -1;
	reservedSellPrice = "-1";

	SrcInvenIndex = 0;

	m_sTitle = Localize("CBooth", "Title", "SephirothUI");
	sTotalSell = Localize("CBooth", "S_TotalSell", "SephirothUI");

	Showcase = SephirothPlayer(PlayerOwner).Showcase;
	if (Showcase != None)
		Showcase.OnDrawItem = InternalDrawItem;

	Bag = CBag(AddInterface("SephirothUI.CBag"));

	if (Bag != None)
		Bag.ShowInterface();

//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));

	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(800,Bag.Components[0].Y+Bag.Components[0].YL);
	}

	GotoState('Nothing');
}


function OnFlush()
{
	Showcase.OnDrawItem = None;
	if(Controller.bMouseDrag)
		Controller.bMouseDrag = false;
	
	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();

	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if (Bag != None) {
		Bag.SepInventory.SelectAll(false);
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
	if (Showcase != None)
		Showcase.Clear();
	if (SubSelectBox != none){
    	SubSelectBox.HideInterface();
    	RemoveInterface(SubSelectBox);
    	SubSelectBox = none;
	}
}

function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[0],true,C.ClipX-Components[0].XL-Components[1].XL,0);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
	Super.Layout(C);
}

function OnPreRender(Canvas C)
{

}

function Render(Canvas C)
{
	local float X,Y;
	local CInterface theInterface;
	local SephirothInterface MainHud;

	Super.Render(C);

	X = Components[0].X;
	Y = Components[0].Y;
	C.SetDrawColor(255,255,255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.DrawKoreanText(ClipText(C,TempBoothTitle,Components[8].XL-5), Components[8].X+4, Components[8].Y, Components[8].XL, Components[8].YL); 
	C.DrawKoreanText(ClipText(C,TempBoothAd,Components[9].XL-5), Components[9].X+4, Components[9].Y, Components[9].XL, Components[9].YL);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
	C.SetDrawColor(215,213,174);
	C.DrawKoreanText(Controller.MoneyStringEx(Showcase.strMoney), Components[2].X-25, Components[2].Y-1, Components[2].XL, Components[2].YL);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(210,156,82);
	C.DrawKoreanText(sTotalSell, X+41, Y+430, 48, 14);
	C.SetDrawColor(255,255,255);

	DrawTitle(C, m_sTitle);

	// �Ǹ��߽�
	C.SetPos(X+11,Y+28);
	if(SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Open)
		C.DrawTile(TextureResources[12].Resource,51,64,0,0,51,64);
	else
		C.DrawTile(TextureResources[11].Resource,51,64,0,0,51,64);

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
		if(IsCursorInsideMainFrame())
			ShowItemInfo(C, MainHud.ItemTooltipBox);
		else if(Bag.IsCursorInsideMainFrame())
			Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	}
	else
		MainHud.ItemTooltipBox.SetInfo(None);

//del neive : selectable �� multi �������̽��� �ٲ������ �ٶ��� �̷����� �ν��� �Ұ��� �Ǿ��� �Ѥ�;;;
/*
	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
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

	if (!IsCursorInsideComponent(Components[0]))
		return;

	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) 
	{
		InfoBox.SetInfo(None);
		return;		
	}

	Point = ScreenToRowColumn(Components[3],Controller.MouseX,Controller.MouseY);

	if (Point.X != -1 && Point.Y != -1 && Showcase != None)
	{
		ISI = Showcase.GetItem_RC(Point.X, Point.Y);

		if (ISI != None)
		{
			CItemInfoBox(InfoBox).SetDisplayMethod(4);
			RgnEnd = RowColumnToScreen(Components[3],ISI.Y+ISI.Height-1,ISI.X+ISI.Width-1);
			InfoBox.SetInfo(ISI, RgnEnd.X+RgnEnd.W, RgnEnd.Y+RgnEnd.H, true, C.ClipX, C.ClipY);
			InfoBox.SetPos(Components[0].X-InfoBox.WinWidth-3, Components[0].Y+3);
			//InfoBox.SetInfo(ISI, Components[0].X-, Components[0].Y, true, C.ClipX, C.ClipY);
		}
	}
}


function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local int CellSize;
	local material Sprite;
	local int X, Y, XL, YL;

	CellSize = 25;
//	DraggingItem = SephirothItem(Controller.DragObject);
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
/*	if (DraggingItem == Item) {
		C.SetPos(X, Y);
		C.DrawTile(Controller.BackgroundBlend, XL, YL, 0, 0, 0, 0);
	}*/

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

	if (Item.IsPotion() || Item.IsScroll() || Item.IsQuiver() || Item.IsPetFood() || Item.IsStackUI())	// Mod ssemp : ���� �����̿� ������ ī��Ʈ �߰�
	{
		C.SetPos(X,Y);
		C.SetDrawColor(255,255,255);
		C.DrawText(Item.Amount);
	}
}


function DrawObject(Canvas C)
{
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	if(Controller.SelectingSource != None && Controller.SelectingSource == Self && Controller.SelectingSource.IsInState('Selecting'))
	{
		if(Controller.ObjectList.Length > 0)
			RenderSelectionState(C, CBooth_Seller(Controller.SelectingSource).Components[3].X, CBooth_Seller(Controller.SelectingSource).Components[3].Y, Controller.ObjectList);//Controller.SelectingList);
		if(Controller.SelectingList.Length > 0)
			RenderSelectionState(C, CBooth_Seller(Controller.SelectingSource).Components[3].X, CBooth_Seller(Controller.SelectingSource).Components[3].Y, Controller.SelectingList);
	}

	if(Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
		RenderSelectionState(C, CBooth_Seller(Controller.DragSource).Components[3].X, CBooth_Seller(Controller.DragSource).Components[3].Y, Controller.SelectedList);

	Render_Items(C, Showcase, Components[3].X, Components[3].Y);

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

	if ( Controller.SelectedList.Length > 0 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if ( ISI != None && Controller.DragSource != None )
		{
			Point = ScreenToRowColumn(Components[3], Controller.MouseX, Controller.MouseY);

			if ( Point.X != -1 && Point.Y != -1 )
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[3].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[3].ColumnCount - ISI.Width);

				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[3].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[3].RowCount - ISI.Height);

				if ( OnDropItem(ItemPos) )
					return true;
			}
		}
	}
	return false;
}


function ReserveItem(SephirothItem item)
{
	reservedItemsList[reservedItemsList.Length] = item;
}


function bool OnDropItem(Point Dest)
{
	local int i, amountsum;
	local SephirothItem Item, ShowcaseItem;
	local array<SephirothItem>ItemList;
	local string lastItemName;
	local bool isDirty;

	isDirty = false;

	if ( (Controller.DragSource.IsA('CBag')||Controller.DragSource.IsA('CBagResizable')) && Showcase != None ) 
	{
		if (Controller.SelectedList.Length == 1)
		{
			if (Controller.DragSource.IsA('CBag'))
				SrcInvenIndex = 0;
			else if (Controller.DragSource.IsA('CBagResizable'))
				SrcInvenIndex = CBagResizable(Controller.DragSource).SubInvenIndex + 1;

			Item = SephirothItem(Controller.SelectedList[0]);
			ShowcaseItem = Showcase.FirstMatched(0, Item.TypeName);

			// ���� ������ ���������� Ȯ���Ѵ�.
			if ( Item.xSealFlag == Item.eSEALFLAG.SF_USED )
			{
				class'CMessageBox'.static.MessageBox(Self, "CannotTrade", Localize("Modals", "CannotTradeUsedItem", "Sephiroth"), MB_OK);
				return false;
			}

			if ( ShowcaseItem != None && !ShowcaseItem.CanEquip() && !ShowcaseItem.IsQuiver() && !ShowcaseItem.IsPetCage() )
			{
				if ( (Item.IsMaterial() || Item.IsRefined()) )
				{
					if ( Item.Amount != 10000 )
					{
						class'CMessageBox'.static.MessageBox(Self,"FailAddItem",Localize("Modals","AddOnly10000","Sephiroth"),MB_OK);
						return true;
					}
					else
					{
						bPricePerEach = false;
						reservedSellPrice = ShowcaseItem.strBoothPrice;
						class'CMessageBox'.static.MessageBox(Self,"AddedItem",ShowcaseItem.strBoothPrice@Localize("Modals","AddAdditional","Sephiroth"),MB_YesNo,IDM_AddWithSamePrice);
					}
				}
				else
				{
					if ( Item.HasAmount() )
						bPricePerEach = true;
					else
						bPricePerEach = false;

					reservedSellPrice = ShowcaseItem.strBoothPrice;
					class'CMessageBox'.static.MessageBox(Self,"AddedItem",ShowcaseItem.strBoothPrice@Localize("Modals","AddAdditional","Sephiroth"),MB_YesNo,IDM_AddWithSamePrice);
				}
			}
			else if ( Item.IsMaterial() || Item.IsRefined() )
			{
				bPricePerEach = false;

				if ( Item.Amount == 10000 )
				{
					class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@Item.amount@Localize("Modals","FixPricePer10000","Sephiroth"),IDS_FixPrice, IDM_FixPricePerItem);
				}
				else
				{
					class'CMessageBox'.static.MessageBox(Self,"FailAddItem",Localize("Modals","AddOnly10000","Sephiroth"), MB_OK);
					return true;
				}
			}
			else if( Item.IsQuiver() )
			{
				bPricePerEach = false;
				class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@Item.amount@Localize("Modals","FixPrice","Sephiroth"), IDS_FixPrice, IDM_FixPricePerItem);
			}
			else if( Item.HasAmount() )
			{
				bPricePerEach = true;
				class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@Item.amount@Localize("Modals","FixPricePer1","Sephiroth"), IDS_FixPrice, IDM_FixPricePerItem);
			}
			else
			{
				bPricePerEach = false;
				class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@"1"@Localize("Modals","FixPrice","Sephiroth"), IDS_FixPrice, IDM_FixPricePerItem);
			}

			ReserveItem(Item);
			reservedDestPos = Dest;
		}
		else if (Controller.SelectedList.Length > 1)
		{
			if (Controller.DragSource.IsA('CBag'))
				SrcInvenIndex = 0;
			else if (Controller.DragSource.IsA('CBagResizable'))
				SrcInvenIndex = CBagResizable(Controller.DragSource).SubInvenIndex + 1;

			// ���� ������ ���������� Ȯ���Ѵ�.
			// ������ �� ������ �����۸� ó���� �ǹǷ� �ϳ������� �Ǵ��� ������
			if ( SephirothItem(Controller.SelectedList[0]).xSealFlag == SephirothItem(Controller.SelectedList[0]).eSEALFLAG.SF_USED )
			{
				class'CMessageBox'.static.MessageBox(Self, "CannotTrade", Localize("Modals", "CannotTradeUsedItem", "Sephiroth"), MB_OK);
				return false;
			}

			for ( i=0 ; i < Controller.SelectedList.Length; i++ )
			{
				Item = SephirothItem(Controller.SelectedList[i]);

				if ( i != 0 && lastItemName != Item.TypeName )
				{
					isDirty = true;
					break;
				}
				else if ( (Item.IsMaterial() || Item.IsRefined()) && Item.Amount != 10000 )
				{
					isDirty = true;
					break;
				}
				else if ( Item.CanEquip() || Item.IsPetCage() || Item.IsQuiver() )
				{
					isDirty = true;
					break;
				}

				lastItemName = Item.TypeName;
				ItemList[i] = Item;

				if( Item.HasAmount() )
					amountsum += Item.Amount;
				else
					amountsum++;
			}

			// ���� ������ �����۸� ó���� ������
			if ( isDirty )
			{
				class'CMessageBox'.static.MessageBox(Self, "FailAddItem", Localize("Modals", "DirtyItemList", "Sephiroth"), MB_OK);
				return false;
			}

			ShowcaseItem = Showcase.FirstMatched(0, Item.TypeName);

			if( ShowcaseItem == None )
			{
				if( Item.IsMaterial() || Item.IsRefined() )
				{
					bPricePerEach = false;
					class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@amountsum@Localize("Modals","FixPricePer10000","Sephiroth"), IDS_FixPriceMany, IDM_FixPricePerItem);
				}
				else if ( !Item.IsQuiver() && Item.HasAmount() ){
					bPricePerEach = true;
					class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@amountsum@Localize("Modals","FixPricePer1","Sephiroth"), IDS_FixPriceMany, IDM_FixPricePerItem);
				}
				else{
					bPricePerEach = false;
					class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@amountsum@Localize("Modals","FixPrice","Sephiroth"), IDS_FixPriceMany, IDM_FixPricePerItem);
				}
			}
			else
			{
				if( Item.IsMaterial() || Item.IsRefined() ){
					bPricePerEach = false;
					reservedSellPrice = ShowcaseItem.strBoothPrice;
					class'CMessageBox'.static.MessageBox(Self,"AddedItem",ShowcaseItem.strBoothPrice@Localize("Modals","AddAdditional","Sephiroth"), MB_YesNo, IDM_AddWithSamePrice);
				}
				else if( !ShowcaseItem.CanEquip() && !ShowcaseItem.IsQuiver() && !ShowcaseItem.IsPetCage() ){
					if( Item.HasAmount() )
						bPricePerEach = true;
					else
						bPricePerEach = false;
					reservedSellPrice = ShowcaseItem.strBoothPrice;
					class'CMessageBox'.static.MessageBox(Self,"AddedItem",ShowcaseItem.strBoothPrice@Localize("Modals","AddAdditional","Sephiroth"), MB_YesNo, IDM_AddWithSamePrice);
				}
				else{
					bPricePerEach = false;
					class'CEditBox'.static.MoneyEditBox(Self,"FixPrice",Item.LocalizedDescription@amountsum@Localize("Modals","FixPrice","Sephiroth"), IDS_FixPriceMany, IDM_FixPricePerItem);	
				}
			}

			for(i=0 ; i<Controller.SelectedList.Length; i++){
				ReserveItem(ItemList[i]);
			}
		}
		Controller.ResetDragAndDropAll();
		return true;
	}
	else if( Controller.DragSource == Self ){
		ResetReserved();
		Controller.ResetDragAndDropAll();
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
}

function OnQuerySelection(float StartX, float StartY, float MouseX, float MouseY, out Array<Object> ObjList)
{
	local SephirothInventory.Rectangle DR, IR;
	local SephirothItem ISI;
	local Point StartPoint, EndPoint;
	local float sx, sy, ex, ey, tmp;
	local int i, k;

	StartPoint = ScreenToRowColumn(CBooth_Seller(Controller.SelectingSource).Components[3], StartX, StartY);
	if(StartPoint.X != -1 && StartPoint.Y != -1)
	{
		EndPoint = ScreenToRowColumnEx(CBooth_Seller(Controller.SelectingSource).Components[3], MouseX, MouseY);

		sx = StartPoint.X;
		sy = StartPoint.Y;
		ex = EndPoint.X;
		ey = EndPoint.Y;

		if(ex < 0) 
			ex = 0;
		if(ex > CBooth_Seller(Controller.SelectingSource).Components[3].ColumnCount-1) 
			ex = CBooth_Seller(Controller.SelectingSource).Components[3].ColumnCount-1;
		if(ey < 0) 
			ey = 0;
		if(ey > CBooth_Seller(Controller.SelectingSource).Components[3].RowCount-1)    
			ey = CBooth_Seller(Controller.SelectingSource).Components[3].RowCount-1;
		if(sx > ex){
			tmp = sx;
			sx = ex;
			ex = tmp;
		}

		if(sy > ey){
			tmp = sy;
			sy = ey;
			ey = tmp;
		}

		DR.Left = sx;
		DR.Top = sy;
		DR.Right = ex;
		DR.Bottom = ey;

		k=0;
		for(i=0; i<CBooth_Seller(Controller.SelectingSource).Showcase.Items.Length; i++)
		{
			ISI = CBooth_Seller(Controller.SelectingSource).Showcase.Items[i];
			if(ISI != None)
			{
				IR = CBooth_Seller(Controller.SelectingSource).Showcase.Rectangle_Get(ISI);
				if(CBooth_Seller(Controller.SelectingSource).Showcase.Rectangle_Intersect(IR,DR))
				{
					ObjList[k] = ISI;
					k++;
				}
			}
		}
	}
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

	Point = ScreenToRowColumn(Components[3], Controller.MouseX, Controller.MouseY);

	if(Point.X != -1 && Point.Y != -1)
	{
		Item = OnDragItem(Showcase, Point);

		if(Item != None)
		{
			Controller.MergeSelectCandidate(Item);
			//log("### CBooth_Seller.ObjectSelecting TRUE");
			return true;
		}
	}

	//log("### CBooth_Seller.ObjectSelecting FALSE");
	return false;
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
		StartPoint = ScreenToRowColumn(Controller.SelectingSource.Components[3], Controller.PressX, Controller.PressY);
		if(StartPoint.X != -1 && StartPoint.Y != -1)
		{
			EndPoint = ScreenToRowColumnEx(Controller.SelectingSource.Components[3], Controller.MouseX, Controller.MouseY);

			sx = StartPoint.X;
			sy = StartPoint.Y;
			ex = EndPoint.X;
			ey = EndPoint.Y;


			if(ex < 0) ex = 0;
			if(ex > Controller.SelectingSource.Components[3].ColumnCount-1) ex = Controller.SelectingSource.Components[3].ColumnCount-1;
			if(ey < 0) ey = 0;
			if(ey > Controller.SelectingSource.Components[3].RowCount-1)    ey = Controller.SelectingSource.Components[3].RowCount-1;
			if(sx > ex){
				tmp = sx;
				sx = ex;
				ex = tmp;
			}

			if(sy > ey){
				tmp = sy;
				sy = ey;
				ey = tmp;
			}

			RgnStart = RowColumnToScreen(Controller.SelectingSource.Components[3],sy,sx);
			RgnEnd = RowColumnToScreen(Controller.SelectingSource.Components[3],ey,ex);
			
			C.SetPos(RgnStart.X-1,RgnStart.Y-1);
			DrawBox(C,RgnEnd.X-RgnStart.X+RgnEnd.W-1,RgnEnd.Y-RgnStart.Y+RgnEnd.H-1);


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
			
			if( !Controller.DragSource.IsA('CBag') )
				ShowSelectionItemList(C, TempList);
		}
	}	

//	if(Controller.bLButtonPressed || Controller.bCtrlPressed)
//		ShowSelectionItemList(C, Controller.SelectingList);

}

function bool CanDrag()
{
	if( SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Prepare && Controller.IsSomethingSelected() )
		return true;
	return false;
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

	if(Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[3],Controller.MouseX,Controller.MouseY);

			if (Point.X != -1 && Point.Y != -1) 
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[3].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[3].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[3].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[3].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[3],ItemPos.Y,ItemPos.X);
				XL = ISI.Width*Components[3].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[3].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				for (i=0;i<ISI.Width;i++) {
					for (j=0;j<ISI.Height;j++) {
						if (Showcase != None)
							Foo = Showcase.GetItem_RC(ItemPos.X+i, ItemPos.Y+j);
						if (Foo != None)
							break;
					}
					if (Foo != None)
						break;
				}
				if (Foo != None && Foo != ISI)
					Sprite = Texture'CannotDrop';
				else
					Sprite = Texture'CanDrop';
				C.DrawTile(Sprite,XL,YL,0,0,1,1);
			}

			Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
			if (Sprite != None) {
				XL = ISI.Width*Components[3].CellWidth;
				YL = ISI.Height*Components[3].CellHeight;
				X = Controller.MouseX-XL/2;
				Y = Controller.MouseY-YL/2;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				C.DrawTile(Sprite,XL,YL,0,0,XL,YL);
			}
		}

	}
	else if(Controller.SelectedList.Length > 1 && !Controller.DragSource.IsA('CBag'))
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

	if (Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[3],Controller.MouseX,Controller.MouseY);

			if (Point.X != -1 && Point.Y != -1) 
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[3].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[3].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[3].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[3].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[3],ItemPos.Y,ItemPos.X);
				XL = ISI.Width*Components[3].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[3].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;

				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for (i=0;i<ISI.Width;i++)
				{
					for (j=0;j<ISI.Height;j++)
					{
						if (Showcase != None)
							Foo = Showcase.GetItem_RC(ItemPos.X+i, ItemPos.Y+j);

						if (Foo != None)
							break;
					}

					if (Foo != None)
						break;
				}

				if (Foo != None && Foo != ISI)
					Sprite = Texture'CannotDrop';
				else
					Sprite = Texture'CanDrop';

				C.DrawTile(Sprite,XL,YL,0,0,1,1);
			}
		}
	}
}


function ShowSelectionItemList(Canvas C, Array<Object> ObjList)
{
	local float XXL,YYL;
	local float MaxXL, PriceMaxXL, MaxYL;
	local array<string> ItemStringArr;
	local array<string> ItemPriceArr;
	local string LocalizedAmountStr, LocalizedEachStr, LocalizedBunchStr, LocalizedLenniStr, LocalizedTotalStr, TempStr, TempStr2;
	local int i, j;
	local SephirothItem ISI;
	local float X, Y, XL, YL;
	local array<string> ItemDescs;
	local array<SephirothItem> ItemList;
	local array<int> ItemAmounts;
	local string strTotalBuyPrice;
	local string strTempPrice;
	strTotalBuyPrice = "0";
	strTempPrice = "0";

	if(ObjList.Length > 1 || IsInState('Selecting'))
	{
		//log("### CBooth_Seller.ShowSelectionItemList");
		MaxXL = 0;
		MaxYL = 0;
		LocalizedAmountStr = Localize("Terms", "ItemSize", "Sephiroth");
		LocalizedEachStr = Localize("Terms", "PerEach", "Sephiroth");
		LocalizedBunchStr = Localize("Terms", "Bunch", "Sephiroth");
		LocalizedLenniStr = Localize("Terms", "Lenni", "Sephiroth");
		LocalizedTotalStr = Localize("Booth", "TotalMoney", "Sephiroth");

		for (i=0; i < ObjList.Length; i++) 
		{
			ISI = SephirothItem(ObjList[i]);

			if( (ISI.IsUse() && !ISI.IsPetCage()) || ISI.IsGem() || ISI.IsScroll() || ISI.IsPotion() || ISI.IsMaterial() || ISI.IsRefined() ){
				for( j=0; j<ItemDescs.Length; j++ ){
					if( ISI.LocalizedDescription == ItemDescs[j] ){
						if( ISI.HasAmount() )
							ItemAmounts[j] += ISI.Amount; 
						else
							ItemAmounts[j] += 1;
						break;
					}
				}
				
				if( j == ItemDescs.Length ){
					ItemDescs[j] = ISI.LocalizedDescription;
					ItemList[j] = ISI;
					if( ISI.HasAmount() )
						ItemAmounts[j] = ISI.Amount;
					else
						ItemAmounts[j] = 1;
				}
				if( ISI.IsMaterial() || ISI.IsRefined() )
					strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
				else if( ISI.HasAmount() ){
					strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,string(ISI.Amount));
					strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					strTempPrice = "0";
				}
				else
					strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
			}
			else{

				TempStr = ISI.LocalizedDescription;
				if (ISI.HasAmount()){
					TempStr = TempStr $ " " $ ISI.Amount $ LocalizedAmountStr;
					if( ISI.IsMaterial() || ISI.IsRefined() ){
						TempStr2 = LocalizedBunchStr @ Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
					}
					else if( ISI.IsQuiver() ){
						TempStr2 = Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
					}
					else{
						TempStr2 = LocalizedEachStr @ Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,string(ISI.Amount));
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
						strTempPrice = "0";
						
					}
				}
				else{
					TempStr = TempStr $ " 1" $ LocalizedAmountStr;
					TempStr2 = Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
					strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
				}

				C.TextSize(TempStr, XXL, YYL);
				MaxXL = max(MaxXL, XXL);
				MaxYL = MaxYL + YYL + 5;
				C.TextSize(TempStr2, XXL, YYL);
				PriceMaxXL = max(PriceMaxXL, XXL);

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

				TempStr2 = MakeColorCodeEx(255, 255, 255) $ TempStr2;

				ItemStringArr[ItemStringArr.Length] = TempStr;
				ItemPriceArr[ItemPriceArr.Length] = TempStr2;
			}
		}

		if( ItemDescs.Length > 0 ){
			for( i=0; i<ItemDescs.Length; i++ ){
				ISI = ItemList[i];
				if( ISI == None )
					continue;
				TempStr = ItemDescs[i] $ " " $ ItemAmounts[i] $ LocalizedAmountStr;
				if( ISI.bPricePerEach ){
					TempStr2 = LocalizedEachStr @ Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,ItemAmounts[i]);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
				}
				else if( ISI.IsMaterial() || ISI.IsRefined() ){
					//k = ItemAmounts[i] / 10000;
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,k);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
					TempStr2 = LocalizedBunchStr @ Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
				}
				else{
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,ItemAmounts[i]);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
					TempStr2 = Controller.MoneyStringEx(ISI.strBoothPrice) @ LocalizedLenniStr;
				}

				C.TextSize(TempStr, XXL, YYL);
				MaxXL = max(MaxXL, XXL);
				MaxYL = MaxYL + YYL + 5;
				C.TextSize(TempStr2, XXL, YYL);
				PriceMaxXL = max(PriceMaxXL, XXL);

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

				TempStr2 = MakeColorCodeEx(255, 255, 255) $ TempStr2;

				ItemStringArr[ItemStringArr.Length] = TempStr;
				ItemPriceArr[ItemPriceArr.Length] = TempStr2;
			}
		}

		if (ItemStringArr.Length > 0) {

			XL = MaxXL + PriceMaxXL + 15;
			YL = MaxYL + YYL*6;
			X = Components[0].X - XL;
			Y = components[0].Y;

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

			C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
			C.DrawKoreanText(localize("Booth", "SelectedList", "Sephiroth"), X, Y+YYL, XL, YYL);

			if( ItemStringArr.Length == ItemPriceArr.Length ){
				//log("# Length: "$ItemStringArr.Length);
				for (i=0;i<ItemStringArr.Length;i++){
					C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
					C.DrawKoreanText(ItemStringArr[i], X+5, Y+(i+2)*(YYL+4)+5, MaxXL, YYL+5);
					C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
					C.DrawKoreanText(ItemPriceArr[i], X+MaxXL+5, Y+(i+2)*(YYL+4)+5, PriceMaxXL+5, YYL+5);
				}
			}

			C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
			C.DrawKoreanText(LocalizedTotalStr, X+5, Y+YL-YYL-7, MaxXL, YYL+5);
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
			C.DrawKoreanText(Controller.MoneyStringEx(strTotalBuyPrice) @ LocalizedLenniStr, X+MaxXL+5, Y+YL-YYL-7, PriceMaxXL+5, YYL+5);
		}
	}
}

function ResetReserved()
{
	reservedSellPrice = "-1";
	reservedItemsList.Remove(0, reservedItemsList.Length);
	reservedDestPos.X = -1;
	reservedDestPos.Y = -1;
	bPricePerEach = false;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape && Action == IST_Press) {
		class'CMessageBox'.static.MessageBox(Self,"CloseBooth",Localize("Modals","BoothClose","Sephiroth"),MB_YesNo,IDM_Close);
		return true;
	}
	if ((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		return false;

	if ((Key == IK_LeftMouse || Key == IK_RightMouse) && IsCursorInsideComponent(Components[0]))
		return true;
}

function NotifyComponent(int CmpId,int NotifyId, optional string Command)
{
	
	switch(NotifyID)
	{
	case BN_Close:
		class'CMessageBox'.static.MessageBox(Self,"CloseBooth",Localize("Modals","BoothClose","Sephiroth"),MB_YesNo,IDM_Close);
		break;
	case BN_ChangeTitle:
		class'CEditBox'.static.EditBox(Self,"ChangeTitle",Localize("Modals","BoothChangeTitle","Sephiroth"),IDS_ChangeTitle,40);
		break;
	case BN_ChangeAd:
		class'CEditBox'.static.EditBox(Self,"ChangeAd",Localize("Modals","BoothChangeAd","Sephiroth"),IDS_ChangeAd,100);
		break;
	case CB_Touting:
		if(Command == "Checked")
			TempUseTout = true;
		else
			TempUseTout = false;
		break;
	case BN_ChangeState:
		if( SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Prepare )
			class'CMessageBox'.static.MessageBox(Self,"ChangeState",Localize("Modals","BoothChangeStateToOpen","Sephiroth"),MB_YesNo,IDM_ChangeStateToOpen);
		else if( SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Open )
			class'CMessageBox'.static.MessageBox(Self,"ChangeState",Localize("Modals","BoothChangeStateToPrepare","Sephiroth"),MB_YesNo,IDM_ChangeStateToPrepare);
		break;
	}
}

function bool PushComponentBool(int CmpId)
{
	switch (CmpId)
	{
		case 7: return TempUseTout;
	}
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	local int i;
	local SephirothItem item;

	switch ( NotifyId )
	{
	case IDS_ChangeTitle :

		TempBoothTitle = EditText;
		break;

	case IDS_ChangeAd :

		TempBoothAd = EditText;
		break;

	case IDS_FixPrice :

		if ( EditText != "" && reservedDestPos.X != -1 && reservedDestPos.Y != -1 )
		{
			item = reservedItemsList[0];

			if ( item != None )
			{
//				//Log("neive : check NotifyEditBox ������ �ϳ� �ø���");
				SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
				SephirothPlayer(PlayerOwner).Net.NotiBoothAddItem(SrcInvenIndex, item.X, item.Y, reservedDestPos.X, reservedDestPos.Y, bPricePerEach, EditText);
			}
		}

		ResetReserved();
		break;

	case IDS_FixPriceMany :

		if ( EditText != "" )
		{
			for ( i=0; i<reservedItemsList.Length; i++ )
			{
				if ( reservedItemsList[i] == None )
				{
					ResetReserved();
					return;
				}
			}
//			//Log("neive : check NotifyEditBox ������ ������ �ø���");
			SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
			SephirothPlayer(PlayerOwner).Net.NotiBoothAddItemMany(SrcInvenIndex, reservedItemsList, bPricePerEach, EditText);
		}

		ResetReserved();
		break;

	case -1*IDS_FixPrice :
	case -1*IDS_FixPriceMany :
		ResetReserved();
	}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Cmd;

	if( NotifyType == INT_MessageBox )	{

		Cmd = int(Command);

		switch(Cmd){
		case IDM_ChangeStateToOpen :

			if ( TempBoothAd == DefaultAdString )
				SephirothPlayer(PlayerOwner).Net.NotiBoothState(BS_Open, TempBoothTitle, "", TempUseTout);
			else
				SephirothPlayer(PlayerOwner).Net.NotiBoothState(BS_Open, TempBoothTitle, TempBoothAd, TempUseTout);
			break;

		case IDM_ChangeStateToPrepare :

			if( TempBoothAd == DefaultAdString )
				SephirothPlayer(PlayerOwner).Net.NotiBoothState(BS_Prepare, TempBoothTitle, "", TempUseTout);
			else
				SephirothPlayer(PlayerOwner).Net.NotiBoothState(BS_Prepare, TempBoothTitle, TempBoothAd, TempUseTout);
			break;

		case IDM_AddWithSamePrice :

			if ( reservedSellPrice != "-1" )	{

				if ( reservedItemsList.Length == 1 )
				{
//					//Log("neive : check NotifyInterface ������ �ϳ� �ø���");
					SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
					SephirothPlayer(PlayerOwner).Net.NotiBoothAddItem(SrcInvenIndex, reservedItemsList[0].X, reservedItemsList[0].Y, reservedDestPos.X, reservedDestPos.Y, bPricePerEach, reservedSellPrice);
				}
				else if( reservedItemsList.Length > 0 )
				{
//					//Log("neive : check NotifyInterface ������ ������ �ø���");
					SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
					SephirothPlayer(PlayerOwner).Net.NotiBoothAddItemMany( SrcInvenIndex, reservedItemsList, bPricePerEach, reservedSellPrice);
				}
			}

			ResetReserved();
			break;

		case -1*IDM_AddWithSamePrice :

			ResetReserved();
			break;

		case IDM_Close :

			Parent.NotifyInterface(Self,INT_Close);
			break;
		}
	}
	else if ( Interface == Bag && NotifyType == INT_Close )	{
		
		if ( Command == "ByEscape" )	{

			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
			else
				class'CMessageBox'.static.MessageBox(Self, "CloseBooth", Localize("Modals", "BoothClose", "Sephiroth"), MB_YesNo, IDM_Close);
		}				
	}
}

function ChangeBoothState()
{
	TempBoothTitle = SephirothPlayer(PlayerOwner).PSI.BoothTitle;
	if( SephirothPlayer(PlayerOwner).PSI.BoothAd != "" )
		TempBoothAd = SephirothPlayer(PlayerOwner).PSI.BoothAd;
	else if( SephirothPlayer(PlayerOwner).PSI.bUseAd )
		TempBoothAd = DefaultAdString;
	TempUseTout = SephirothPlayer(PlayerOwner).PSI.bUseTout;

	if( SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Open ){
		Components[6].Caption = PrepareString;
		Components[4].bDisabled = true;
		Components[5].bDisabled = true;
		Components[6].bDisabled = true;
		Components[7].bDisabled = true;
		lastChangeBoothTime = level.TimeSeconds;
	}
	else if( SephirothPlayer(PlayerOwner).PSI.BoothState == BS_Prepare ){
		Components[6].Caption = OpenString;
		Components[4].bDisabled = false;
		if( SephirothPlayer(PlayerOwner).PSI.bUseAd )
			Components[5].bDisabled = false;
		Components[4].bDisabled = false;
		Components[7].bDisabled = false;
	}
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if( lastChangeBoothTime > 0 ){
		if( level.TimeSeconds - lastChangeBoothTime > 30 ){
			Components[6].bDisabled = false;
			lastChangeBoothTime = -1;
		}
	}
}


function bool IsCursorInsideInterface()
{
	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() || SubSelectBox.IsCursorInsideInterface() )
		return true;

	return false;

//	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
     Components(0)=(XL=280.000000,YL=498.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=280.000000,YL=498.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,ResId=1,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=107.000000,OffsetYL=425.000000)
     Components(3)=(Id=3,Type=RES_RowColumn,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=97.000000,ColumnCount=9,RowCount=13,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(4)=(Id=4,Caption="Retry",Type=RES_PushButton,XL=54.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=38.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="ChangeBoothTitle")
     Components(5)=(Id=5,Caption="input",Type=RES_PushButton,XL=54.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=207.000000,OffsetYL=63.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="ChangeBoothAd")
     Components(6)=(Id=6,Caption="BoothOpen",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=15.000000,OffsetYL=455.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="ChangeBoothState")
     Components(7)=(Id=7,Caption="Touting",Type=RES_CheckButton,XL=130.000000,YL=26.000000,PivotDir=PVT_Copy,OffsetXL=182.000000,OffsetYL=461.000000,TextAlign=TA_MiddleLeft,TextColor=(B=98,G=151,R=218,A=255),LocType=LCT_Terms)
     Components(8)=(Id=8,ResId=13,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=60.000000,OffsetYL=36.000000)
     Components(9)=(Id=9,ResId=13,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=60.000000,OffsetYL=61.000000)
     Components(13)=(Id=13,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=249.000000,OffsetYL=14.000000,ToolTip="CloseContext")
     TextureResources(0)=(Package="UI_2011",Path="win_pri_shop",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="inven_coin_bg",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_yell_s_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_yell_s_o",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_yell_s_c",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="sym_shop_off",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="sym_shop_on",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="input_bg",Style=STY_Alpha)
     IsBottom=True
}
