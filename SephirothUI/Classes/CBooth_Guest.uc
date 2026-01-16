class CBooth_Guest extends CSelectable;

var CBag Bag;
var BoothItems Showcase;
//var CSubInventorySelectBox SubSelectBox;

var PlayerServerInfo SellerInfo;

var array<SephirothItem> reservedItemsList;
var string reservedPaidMoney;

var string m_sTitle;
var string sTotalBuy;

const BN_Close = 1;
const CMP_InventoryArea = 2;

const IDM_Close = 1;

const BS_None = 0;
const BS_Open = 1;
const BS_Prepare = 2;
const BS_Visit = 3;

function OnInit()
{
	SetComponentTextureId(Components[10],1,0,3,2);

	SetComponentNotify(Components[10], BN_Close, Self);
	
	reservedPaidMoney = "-1";
	Showcase = SephirothPlayer(PlayerOwner).Showcase;
	if (Showcase != None)
		Showcase.OnDrawItem = InternalDrawItem;

	Bag = CBag(AddInterface("SephirothUI.CBag"));
	if (Bag != None)
		Bag.ShowInterface();
/*
	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(800,Bag.Components[0].Y+Bag.Components[0].YL);
	}
*/
	m_sTitle = Localize("CBooth", "Title", "SephirothUI");
	sTotalBuy = Localize("CBooth", "S_TotalBuy", "SephirothUI");

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
	
/*	if (InfoBox != None) {
		InfoBox.HideInterface();
		RemoveInterface(InfoBox);
		InfoBox = None;
	}*/

	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if (Bag != None) {
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
	if (Showcase != None)
		Showcase.Clear();
/*	
	if (SubSelectBox != none){
    	SubSelectBox.HideInterface();
    	RemoveInterface(SubSelectBox);
    	SubSelectBox = none;
	}
*/
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
	//DrawKoreanTextMultiLine(C, X+68, Y+39, 100, 14, 2, 32, SellerInfo.BoothTitle);
	C.DrawKoreanText(Mid(SellerInfo.BoothTitle, 0, 17),X+73, Y+39, 100, 14);
	C.DrawKoreanText(Mid(SellerInfo.BoothTitle, 17, 17),X+73, Y+55, 100, 14);

	C.SetDrawColor(215,213,174);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
	C.DrawKoreanText(Controller.MoneyColoredString(Showcase.strMoney), Components[3].X-25, Components[3].Y-1, Components[3].XL, Components[3].YL);
	
	C.SetDrawColor(210,156,82);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.DrawKoreanText(sTotalBuy, X+41, Y+430, 48, 14);
	C.SetDrawColor(255,255,255);

	// 판매중스
	C.SetPos(X+11,Y+28);
	if(SellerInfo.BoothState == BS_Open)
		C.DrawTile(TextureResources[5].Resource,51,64,0,0,51,64);
	else
		C.DrawTile(TextureResources[6].Resource,51,64,0,0,51,64);

	DrawTitle(C, m_sTitle);

	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

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
/*
	if(theInterface == Self && IsCursorInsideMainFrame())	//Self 가 너무 광범위 하다 -_- 부속 interface 까지 인식해버리니...
		ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface == Self && Bag.IsCursorInsideMainFrame() ) // theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);
*/
	// Xelloss - 2011. 02. 14
/*	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Self )	{
		
		theInterface = GetTopInterfaceBelowCursor();

		if ( CBag(theInterface) != None )
			CBag(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
		else
			ShowItemInfo(C, MainHud.ItemTooltipBox);
	}
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);
*/

/*
	//del neive : 블라인드 처리 안한다
	if ( SellerInfo.BoothState == BS_Prepare )	{

		C.SetPos(Components[CMP_InventoryArea].X, Components[CMP_InventoryArea].Y);
		C.SetRenderStyleAlpha();
		C.DrawTile(Texture'TextBlackBg', Components[CMP_InventoryArea].XL - 1, Components[CMP_InventoryArea].YL - 1, 0, 0, 0, 0);		//시작점에 -1추가. (네모가 다 안그려졋음) 2009.11.3.Sinhyub
	}
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

	Point = ScreenToRowColumn(Components[CMP_InventoryArea],Controller.MouseX,Controller.MouseY);
	if (Point.X != -1 && Point.Y != -1 && Showcase != None) {
		ISI = Showcase.GetItem_RC(Point.X, Point.Y);
		if (ISI != None) {
			CItemInfoBox(InfoBox).SetDisplayMethod(4);
			RgnEnd = RowColumnToScreen(Components[CMP_InventoryArea],ISI.Y+ISI.Height-1,ISI.X+ISI.Width-1);
			InfoBox.SetInfo(ISI, RgnEnd.X+RgnEnd.W, RgnEnd.Y+RgnEnd.H, true, C.ClipX, C.ClipY);
			InfoBox.SetPos(Components[0].X-InfoBox.WinWidth-3, Components[0].Y+3);
		}
	}
}

function ChangeBoothState(){

	if( SellerInfo != None ){
		if( SellerInfo.BoothState == BS_Open ){
			if(Controller.bMouseDrag)
				Controller.bMouseDrag = false;	
			Controller.SelectingSource = None;
			Controller.DragSource = None;
			Controller.ResetSelecting();
			Controller.ResetDragging();
			Controller.ResetObjectList();
		}
		else if( SellerInfo.BoothState == BS_Prepare ){			
			if(Controller.bMouseDrag)
				Controller.bMouseDrag = false;	
			Controller.SelectingSource = None;
			Controller.DragSource = None;
			Controller.ResetSelecting();
			Controller.ResetDragging();
			Controller.ResetObjectList();

			if( Showcase != None )
				Showcase.Clear();

			if( SephirothInterface(Parent).ItemTooltipBox != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
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

	if (Item.IsPotion() || Item.IsScroll() || Item.IsQuiver() || Item.IsPetFood() || Item.IsStackUI())	// Mod ssemp : 스텍 유아이용 아이템 카운트 추가
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
			RenderSelectionState(C, CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].X, CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].Y, Controller.ObjectList);//Controller.SelectingList);
		if(Controller.SelectingList.Length > 0)
			RenderSelectionState(C, CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].X, CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].Y, Controller.SelectingList);
	}

	if(Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
		RenderSelectionState(C, CBooth_Guest(Controller.DragSource).Components[CMP_InventoryArea].X, CBooth_Guest(Controller.DragSource).Components[CMP_InventoryArea].Y, Controller.SelectedList);

	Render_Items(C, Showcase, Components[CMP_InventoryArea].X, Components[CMP_InventoryArea].Y);
}

function Render_Items(Canvas C,SephirothInventory Inv,int X,int Y)
{
	if (Inv != None)
		Inv.DrawItems(C, X, Y);
}

function bool Drop()
{
	if( Controller.SelectedList.Length > 0 ){
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


	StartPoint = ScreenToRowColumn(CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea], StartX, StartY);
	if(StartPoint.X != -1 && StartPoint.Y != -1)
	{
		EndPoint = ScreenToRowColumnEx(CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea], MouseX, MouseY);

		sx = StartPoint.X;
		sy = StartPoint.Y;
		ex = EndPoint.X;
		ey = EndPoint.Y;

		if(ex < 0) 
			ex = 0;
		if(ex > CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].ColumnCount-1) 
			ex = CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].ColumnCount-1;
		if(ey < 0) 
			ey = 0;
		if(ey > CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].RowCount-1)    
			ey = CBooth_Guest(Controller.SelectingSource).Components[CMP_InventoryArea].RowCount-1;
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
		for(i=0; i<CBooth_Guest(Controller.SelectingSource).Showcase.Items.Length; i++)
		{
			ISI = CBooth_Guest(Controller.SelectingSource).Showcase.Items[i];
			if(ISI != None)
			{
				IR = CBooth_Guest(Controller.SelectingSource).Showcase.Rectangle_Get(ISI);
				if(CBooth_Guest(Controller.SelectingSource).Showcase.Rectangle_Intersect(IR,DR))
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
	
	Point = ScreenToRowColumn(Components[CMP_InventoryArea], Controller.MouseX, Controller.MouseY);

	if(Point.X != -1 && Point.Y != -1)
	{
		Item = OnDragItem(Showcase, Point);

		if(Item != None)
		{
			Controller.MergeSelectCandidate(Item);
			return true;
		}
	}
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
		StartPoint = ScreenToRowColumn(Controller.SelectingSource.Components[CMP_InventoryArea], Controller.PressX, Controller.PressY);
		if(StartPoint.X != -1 && StartPoint.Y != -1)
		{
			EndPoint = ScreenToRowColumnEx(Controller.SelectingSource.Components[CMP_InventoryArea], Controller.MouseX, Controller.MouseY);

			sx = StartPoint.X;
			sy = StartPoint.Y;
			ex = EndPoint.X;
			ey = EndPoint.Y;


			if(ex < 0) ex = 0;
			if(ex > Controller.SelectingSource.Components[CMP_InventoryArea].ColumnCount-1) ex = Controller.SelectingSource.Components[CMP_InventoryArea].ColumnCount-1;
			if(ey < 0) ey = 0;
			if(ey > Controller.SelectingSource.Components[CMP_InventoryArea].RowCount-1)    ey = Controller.SelectingSource.Components[CMP_InventoryArea].RowCount-1;
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

			RgnStart = RowColumnToScreen(Controller.SelectingSource.Components[CMP_InventoryArea],sy,sx);
			RgnEnd = RowColumnToScreen(Controller.SelectingSource.Components[CMP_InventoryArea],ey,ex);
			
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
			
			ShowSelectionItemList(C, TempList);
		}
	}	

//	if(Controller.bLButtonPressed || Controller.bCtrlPressed)
//		ShowSelectionItemList(C, Controller.SelectingList);

}

function bool CanDrag()
{
	if( SellerInfo.BoothState == BS_Open && Controller.IsSomethingSelected() )
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
	local string strTotalBuyPrice, strTempPrice;

	local float X, Y, XL, YL;
	local int i, j;

	//log("### CBooth_Guest.RenderDragging"@Controller.SelectedList.Length);
	if(Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[CMP_InventoryArea],Controller.MouseX,Controller.MouseY);

			if (Point.X != -1 && Point.Y != -1) 
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[CMP_InventoryArea].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[CMP_InventoryArea].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[CMP_InventoryArea].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[CMP_InventoryArea].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[CMP_InventoryArea],ItemPos.Y,ItemPos.X);
				XL = ISI.Width*Components[CMP_InventoryArea].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[CMP_InventoryArea].CellHeight+ISI.Height-1;
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
				XL = ISI.Width*Components[CMP_InventoryArea].CellWidth;
				YL = ISI.Height*Components[CMP_InventoryArea].CellHeight;
				X = Controller.MouseX-XL/2;
				Y = Controller.MouseY-YL/2;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				C.DrawTile(Sprite,XL,YL,0,0,XL,YL);
			}
		}
		if( ISI.bPricePerEach ){
			strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,string(ISI.Amount));
			strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
			strTempPrice = "0";
		}
		else
			strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
		reservedPaidMoney = strTotalBuyPrice; // 가격 계산은 왜 여기서;
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
	local string strTotalBuyPrice, strTempPrice;

	local float X, Y, XL, YL;
	local int i, j;

	if (Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None) 
		{
			Point = ScreenToRowColumn(Components[CMP_InventoryArea],Controller.MouseX,Controller.MouseY);

			if (Point.X != -1 && Point.Y != -1) 
			{
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[CMP_InventoryArea].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[CMP_InventoryArea].ColumnCount - ISI.Width);

				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[CMP_InventoryArea].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[CMP_InventoryArea].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[CMP_InventoryArea],ItemPos.Y,ItemPos.X);
				XL = ISI.Width*Components[CMP_InventoryArea].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[CMP_InventoryArea].CellHeight+ISI.Height-1;
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

		if ( ISI.bPricePerEach )
		{
			strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,string(ISI.Amount));
			strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
			strTempPrice = "0";
		}
		else
			strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);

		reservedPaidMoney = strTotalBuyPrice; // 가격 계산은 왜 여기서;
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
		//log("### CBooth_Guest.ShowSelectionItemList");
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
						TempStr2 = LocalizedBunchStr @ Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
					}
					else if( ISI.IsQuiver() ){
						TempStr2 = Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,ISI.strBoothPrice);
					}
					else{
						TempStr2 = LocalizedEachStr @ Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
						strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,string(ISI.Amount));
						strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
						strTempPrice = "0";
						
					}
				}
				else{
					TempStr = TempStr $ " 1" $ LocalizedAmountStr;
					TempStr2 = Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
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

		if ( ItemDescs.Length > 0 )
		{
			for ( i=0; i<ItemDescs.Length; i++ )
			{
				ISI = ItemList[i];

				if ( ISI == None )
					continue;

				TempStr = ItemDescs[i] $ " " $ ItemAmounts[i] $ LocalizedAmountStr;

				if ( ISI.bPricePerEach )
				{
					TempStr2 = LocalizedEachStr @ Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,ItemAmounts[i]);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
				}
				else if ( ISI.IsMaterial() || ISI.IsRefined() )
				{
					//k = ItemAmounts[i] / 10000;
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,k);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
					TempStr2 = LocalizedBunchStr @ Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
				}
				else
				{
					//strTempPrice = SephirothPlayer(PlayerOwner).MulInt64(ISI.strBoothPrice,ItemAmounts[i]);
					//strTotalBuyPrice = SephirothPlayer(PlayerOwner).AddInt64(strTotalBuyPrice,strTempPrice);
					//strTempPrice = "0";
					TempStr2 = Controller.MoneyColoredString(ISI.strBoothPrice) @ LocalizedLenniStr;
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
			C.DrawKoreanText(Controller.MoneyColoredString(strTotalBuyPrice) @ LocalizedLenniStr, X+MaxXL+5, Y+YL-YYL-7, PriceMaxXL+5, YYL+5);
		}
		reservedPaidMoney = strTotalBuyPrice;
		//log("SET reservedPaidMoney To "$reservedPaidMoney);
	}
}

function ReserveItem(SephirothItem item)
{
	reservedItemsList[reservedItemsList.Length] = item;
}

function ResetReserved()
{
	reservedItemsList.Remove(0, reservedItemsList.Length);
	reservedPaidMoney = "-1";
	//log("SET reservedPaidMoney To "$reservedPaidMoney);
}

function bool KeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i;
	local bool bRet;

	// 주의 - Parent인 CSelectable의 이벤트를 먼저 진행해야 아래의 SelectedList를 제대로 확인할 수 있다. Xelloss
	bRet = Super.KeyEvent(Key,Action,Delta);

	// Cselectable 에서 드래그한게 잡힌 상태로 정교한 타이밍에 여기로 들어온다 -_-;;
	// 그러면 잡혀있는 걸 체크해서 Reserve ~
	// Guest 의 List 에 부어넣고 Controller 에도 남겨둔다 (둘다 필요)
	// Cbag 에 클릭해서 drop 하면 거기서 CBooth_Guest.List & Controller.List 를 이용해서
	// 구매 cnoti 를 서버로 날린다

	if ( Action == IST_Release && IsPosInsideComponent(Components[CMP_InventoryArea], Controller.PressX, Controller.PressY) )
		for ( i=0; i<Controller.SelectedList.Length; i++ )
			ReserveItem(SephirothItem(Controller.SelectedList[i]));

	//Log("############ reservedItemsList.Length: "$reservedItemsList.Length);

	return bRet;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape && Action == IST_Press)
	{
		class'CMessageBox'.static.MessageBox(Self, "CloseBooth", Localize("Modals", "BoothClose", "Sephiroth"), MB_YesNo, IDM_Close);
		return true;
	}
	
	if (Key == IK_LeftMouse || Key == IK_RightMouse)
	{
		ResetReserved();
		return true;
	}
	
	if ((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		return false;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if( NotifyId == BN_Close )
		class'CMessageBox'.static.MessageBox(Self,"CloseBooth",Localize("Modals","BoothClose","Sephiroth"),MB_YesNo,IDM_Close);
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	/*
	if (NotifyID == IDS_ExchangeMoney && SephirothPlayer(PlayerOwner).CmpInt64(EditText, "0") > 0 && InboxItems != None)
		SephirothPlayer(PlayerOwner).Net.NotiXcngMoney(InboxItems.OwnerId,EditText);
	*/
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Cmd;
	if( NotifyType == INT_MessageBox ){
		Cmd = int(Command);
		switch(Cmd){
		case IDM_Close:
			SephirothPlayer(PlayerOwner).PSI.BoothState = BS_None;
			Parent.NotifyInterface(Self,INT_Close);
			break;
		}
	}
	else if ( Interface == Bag && NotifyType == INT_Close )	{

		if ( Command == "ByEscape" )	{

			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
			else
				class'CMessageBox'.static.MessageBox(Self, "CloseBooth", Localize("Modals","BoothClose","Sephiroth"), MB_YesNo, IDM_Close);
		}				
	}
}


function bool IsCursorInsideInterface()
{
//	return IsCursorInsideComponent(Components[0]);

	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() ) // || SubSelectBox.IsCursorInsideInterface() )
		return true;

	return false;
}

defaultproperties
{
     Components(0)=(XL=280.000000,YL=498.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=280.000000,YL=498.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_RowColumn,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=97.000000,ColumnCount=9,RowCount=13,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(3)=(Id=3,ResId=4,Type=RES_Image,XL=146.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=107.000000,OffsetYL=425.000000)
     Components(10)=(Id=10,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=249.000000,OffsetYL=14.000000,ToolTip="CloseContext")
     TextureResources(0)=(Package="UI_2011",Path="win_pri_shop",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="inven_coin_bg",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="sym_shop_on",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="sym_shop_off",Style=STY_Alpha)
     IsBottom=True
}
