class PetBag extends CSelectable;

#exec TEXTURE IMPORT NAME=Selected FILE=Textures/Normal_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=MagicSelected FILE=Textures/Magic_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=DivineSelected FILE=Textures/Divine_BG.tga MIPS=Off
#exec TEXTURE IMPORT NAME=CanDrop FILE=Textures/CanDrop.tga MIPS=Off
#exec TEXTURE IMPORT NAME=CannotDrop FILE=Textures/CannotDrop.tga MIPS=Off
#exec TEXTURE IMPORT NAME=Dirty FILE=Textures/DirtyItem.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ItemArea FILE=Textures/item_area_n.tga MIPS=Off

const BN_Exit = 1;
const BN_Sort = 2;

const BS_Normal	 = 0;
const BS_Disable = 1;
const BS_Over	 = 2;
const BS_Click	 = 3;

var PetInventory SepPetInventory;
var CBag	Bag;
//var CInfoBox InfoBox;
var float PageX, PageY;


struct SpriteImage
{
	var Texture Texture;
	var float U;
	var float V;
	var float UL;
	var float VL;
};

var array<SpriteImage> UnitSprites;
var Texture UITexture;
var Texture UseSlotTexture;
var int PressedButtonNum;

var string m_sTitle;

function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}

function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture SprTexture;
	C.SetPos(X,Y);
	C.SetRenderStyleAlpha();
	SprTexture = Sprite.Texture;
	C.DrawTile(SprTexture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}

function Render_Items(Canvas C,int X,int Y)
{
	SepPetInventory.DrawItems(C,X,Y);
}

function ShowItemInfo(Canvas C, CInfoBox InfoBox)
{
	local Point Point;
	local SephirothItem ISI;
	local InterfaceRegion Rgn,RgnEnd;
	local color OldColor;

	if (!IsCursorInsideComponent(Components[0]))
		return;

	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) 
	{
		InfoBox.SetInfo(None);
		return;		
	}

	Point = ScreenToRowColumn(Components[1],Controller.MouseX,Controller.MouseY);
	if (Point.X != -1 && Point.Y != -1) {
		ISI = SepPetInventory.GetItem_RC(Point.X, Point.Y);
		if (ISI != None) {
			Rgn = RowColumnToScreen(Components[1],ISI.Y,ISI.X);
			OldColor = C.DrawColor;
			C.SetDrawColor(114,121,196);
			C.SetPos(Rgn.X-1, Rgn.Y-1);
			DrawBox(C,Rgn.W*ISI.Width+ISI.Width,Rgn.H*ISI.Height+ISI.Height,1);
			RgnEnd = RowColumnToScreen(Components[1],ISI.Y+ISI.Height-1,ISI.X+ISI.Width-1);
			if (Controller.bMouseMoved)
				InfoBox.SetInfo(ISI, RgnEnd.X+RgnEnd.W+1, RgnEnd.Y+RgnEnd.H+1, true, C.ClipX, C.ClipY);
			C.DrawColor = OldColor;
		}
	}
}

function bool OnDropItem(POINT Dest)
{
	local SephirothItem Item;
	local array<SephirothItem> ItemList;
	local int i;
	
	// �κ� ���ΰ��� �̵�
	if(Controller.DragSource == Self)
	{
		//Log("Drop From Self");
		if(Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);				
			SephirothPlayer(PlayerOwner).Net.NotiPetInvenItemMove(Item.X, Item.Y, Dest.X, Dest.Y);
		}
	}

	// �ܺο��� �κ����� �̵�
	if(Controller.DragSource.IsA('CBag'))
	{
		//Log("Drop From Bag");
		if(Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);
			if(Item.IsUnseal())
				class'CMessageBox'.static.MessageBox(Self,"ItemMoveFailed",Localize("CBag","MoveError","SephirothUI"),MB_Ok);
			else
				SephirothPlayer(PlayerOwner).Net.NotiPetInvenItemIn(Item.X,Item.Y,Dest.x,Dest.y);
		}
		else if(Controller.SelectedList.Length > 1)
		{
			for(i = 0 ; i < Controller.SelectedList.Length ; i++)
			{
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);
				if(ItemList[i].IsUnseal())
				{
					class'CMessageBox'.static.MessageBox(Self,"ItemMoveFailed",Localize("CBag","MoveError","SephirothUI"),MB_Ok);
					return true;
				}
			}
			SephirothPlayer(PlayerOwner).Net.NotiPetinvenItemInMany(ItemList);
		}
	}
	return true;
}

function bool Drop()
{
	local SephirothItem ISI;
	local Point Point, ItemPos;


	//Log("=====>PetBag Drop "$Controller.SelectedList.Length);
	if(Controller.SelectedList.Length == 1)
	{
		Point = ScreenToRowColumn(Components[1], Controller.MouseX, Controller.MouseY);

		if(Point.X != -1 && Point.Y != -1)
		{
			ISI = SephirothItem(Controller.SelectedList[0]);

			if (ISI.Width % 2 == 1) 
				ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[1].ColumnCount - ISI.Width);
			else 
				ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[1].ColumnCount - ISI.Width);
			if (ISI.Height % 2 == 1) 
				ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[1].RowCount - ISI.Height);
			else
				ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[1].RowCount - ISI.Height);
			
			if(OnDropItem(ItemPos))
				return true;
		}
	}
	else
	{
		if(OnDropItem(ItemPos))
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
	
	Point = ScreenToRowColumn(Components[1], Controller.MouseX, Controller.MouseY);

	//Log("=====>PetBag ObejctSelecting");
	if(Point.X != -1 && Point.Y != -1)
	{
		Item = OnDragItem(SepPetInventory, Point);

		if(Item != None)
		{
			Controller.MergeSelectCandidate(Item);
			return true;
		}
	}

	return false;
}



function bool CanDrag()
{
	return Controller.IsSomethingSelected();
}

function OnQuerySelection(float StartX, float StartY, float MouseX, float MouseY, out Array<Object> ObjList)
{
	local SephirothInventory.Rectangle DR, IR;
	local SephirothItem ISI;
	local Point StartPoint, EndPoint;
	local float sx, sy, ex, ey, tmp;
	local int i, k;


	StartPoint = ScreenToRowColumn(PetBag(Controller.SelectingSource).Components[1], StartX, StartY);
	if(StartPoint.X != -1 && StartPoint.Y != -1)
	{
		EndPoint = ScreenToRowColumnEx(PetBag(Controller.SelectingSource).Components[1], MouseX, MouseY);

		sx = StartPoint.X;
		sy = StartPoint.Y;
		ex = EndPoint.X;
		ey = EndPoint.Y;

		if(ex < 0) ex = 0;
		if(ex > PetBag(Controller.SelectingSource).Components[1].ColumnCount-1) ex = PetBag(Controller.SelectingSource).Components[1].ColumnCount-1;
		if(ey < 0) ey = 0;
		if(ey > PetBag(Controller.SelectingSource).Components[1].RowCount-1)    ey = PetBag(Controller.SelectingSource).Components[1].RowCount-1;
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
		for(i=0; i<PetBag(Controller.SelectingSource).SepPetInventory.Items.Length; i++)
		{
			ISI = PetBag(Controller.SelectingSource).SepPetInventory.Items[i];
			if(ISI != None)
			{
				IR = PetBag(Controller.SelectingSource).SepPetInventory.Rectangle_Get(ISI);
				if(PetBag(Controller.SelectingSource).SepPetInventory.Rectangle_Intersect(IR,DR))
				{
					ObjList[k] = ISI;
					k++;
				}
			}
		}
	}
}

function DrawObject(Canvas C)	{

	local CInterface theInterface;
	local SephirothInterface MainHud;
	local float GridXL,GridYL;

	//��� & �׸���
//	DrawUnitSprite(C,UnitSprites[0],PageX,PageY,Components[0].XL,Components[0].YL);
	GridXL = Components[1].ColumnCount * 25 + 1;
	GridYL = Components[1].rowCount * 25 + 1;
	//C.SetPos(PageX+28,PageY+47);
	C.SetPos(Components[1].X, Components[1].Y);
	C.DrawTile(UnitSprites[1].Texture,GridXL,GridYL,0,0,GridXL,GridYL);

	DrawTitle(C, m_sTitle);
	
	if (Controller.SelectingSource != None && Controller.SelectingSource == Self && Controller.SelectingSource.IsInState('Selecting'))
	{
		if(Controller.ObjectList.Length > 0)
			RenderSelectionState(C, PetBag(Controller.SelectingSource).Components[1].X, PetBag(Controller.SelectingSource).Components[1].Y, Controller.ObjectList);//Controller.SelectingList);
		if(Controller.SelectingList.Length > 0)
			RenderSelectionState(C, PetBag(Controller.SelectingSource).Components[1].X, PetBag(Controller.SelectingSource).Components[1].Y, Controller.SelectingList);
	}

	if (Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
		RenderSelectionState(C, PetBag(Controller.DragSource).Components[1].X, PetBag(Controller.DragSource).Components[1].Y, Controller.SelectedList);

	C.SetDrawColor(255,255,255);
	C.SetRenderStyleAlpha();
	Render_Items(C,Components[1].X,Components[1].Y);

/*	if(Bag != None)
		Bag.ShowItemInfo(C, InfoBox);
	ShowItemInfo(C,InfoBox);*/

	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface.Parent == Self )
		ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);

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
	else
		MainHud.ItemTooltipBox.SetInfo(None);*/


}


function InternalDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY)
{
	local material Sprite;
	local int X, Y, XL, YL;
	local int CellSize;

	CellSize = 25;
	X = OffsetX + Item.X * CellSize;
	Y = OffsetY + Item.Y * CellSize;
	XL = Item.Width * CellSize - 1;
	YL = Item.Height * CellSize - 1;

	Sprite = Item.GetMaterial(SephirothPlayer(PlayerOwner).PSI);
	if (Sprite != None) {
		C.SetPos(X, Y);
		C.DrawTile(Texture'ItemArea', XL, YL, 0, 0, XL, YL);	// ������ ���� ǥ��
		C.SetPos(X, Y);
		C.DrawTile(Sprite, XL, YL, 0, 0, XL, YL);				// ������ �� �̹���
	}
	if (Item.IsPotion() || Item.IsScroll() || Item.IsQuiver() || Item.IsPetFood() || Item.IsStackUI())	// Mod ssemp : ���� �����̿� ������ ī��Ʈ �߰�
	{
		C.SetPos(X,Y);
		C.SetDrawColor(255,255,255);
		C.DrawText(Item.Amount);
	}
}

function RenderSelectionState(Canvas C, int OffsetX, int OffsetY, Array<Object> ItemList)
{
	local SephirothItem Item;
	local material Sprite;
	local int CellSize;
	local int X, Y, XL, YL;
	local int i;


	//************* Select Texture Draw ***********************************
	CellSize = 25;
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
		StartPoint = ScreenToRowColumn(Controller.SelectingSource.Components[1], Controller.PressX, Controller.PressY);
		if(StartPoint.X != -1 && StartPoint.Y != -1)
		{
			EndPoint = ScreenToRowColumnEx(Controller.SelectingSource.Components[1], Controller.MouseX, Controller.MouseY);

			sx = StartPoint.X;
			sy = StartPoint.Y;
			ex = EndPoint.X;
			ey = EndPoint.Y;


			if(ex < 0) ex = 0;
			if(ex > Controller.SelectingSource.Components[1].ColumnCount-1) ex = Controller.SelectingSource.Components[1].ColumnCount-1;
			if(ey < 0) ey = 0;
			if(ey > Controller.SelectingSource.Components[1].RowCount-1)    ey = Controller.SelectingSource.Components[1].RowCount-1;
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

			RgnStart = RowColumnToScreen(Controller.SelectingSource.Components[1],sy,sx);
			RgnEnd = RowColumnToScreen(Controller.SelectingSource.Components[1],ey,ex);
			
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

//	if(Controller.DragSource != None && Controller.DragSource == Self)
//		RenderSelectionState(C, CBag(Controller.DragSource).Components[1].X, CBag(Controller.DragSource).Components[1].Y, Controller.SelectedList);


//	if (Store != None && Store.Store != None && (Store.Store.ActionState == Store.Store.BN_Sell || Store.Store.ActionState == Store.Store.BN_Repair))
//		return;

	if (Controller.Modal())
		return;

	if(Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			Point = ScreenToRowColumn(Components[1], Controller.MouseX-XL/2, Controller.MouseY-YL/2);

			if (Point.X != -1 && Point.Y != -1) {
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[1].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[1].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[1].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[1].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[1],ItemPos.Y,ItemPos.X);

				XL = ISI.Width*Components[1].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[1].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;
				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();
				for (i=0;i<ISI.Width;i++) {
					for (j=0;j<ISI.Height;j++) {
						Foo = SepPetInventory.GetItem_RC(ItemPos.X+i,ItemPos.Y+j);
						if (Foo != None && Foo != ISI)
							break;
					}
					if (Foo != None && Foo != ISI)
						break;
				}
				if (Foo != None && Foo != ISI) {
					Sprite = Texture'CannotDrop';
					if (ISI.HasAmount() && ISI.ModelName == Foo.ModelName)
						Sprite = Texture'CanDrop';
				}
				else
					Sprite = Texture'CanDrop';
				C.DrawTile(Sprite, XL, YL, 0, 0, 1, 1);

				Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);			
				if (Sprite != None) {
					XL = ISI.Width*Components[1].CellWidth;
					YL = ISI.Height*Components[1].CellHeight;

					X = Controller.MouseX-XL/2;
					Y = Controller.MouseY-YL/2;	 

					C.SetPos(X,Y);
					C.SetRenderStyleAlpha();
					C.DrawTile(Sprite,XL,YL,0,0,XL,YL);
				}

			}			

			if (ISI.HasAmount()) {           
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

	if (Controller.Modal())
		return;

	if (Controller.SelectedList.Length == 1)
	{
		ISI = SephirothItem(Controller.SelectedList[0]);

		if (ISI != None)
		{
			Point = ScreenToRowColumn(Components[1], Controller.MouseX-XL/2, Controller.MouseY-YL/2);

			if (Point.X != -1 && Point.Y != -1) {
				if (ISI.Width % 2 == 1) 
					ItemPos.X = Clamp(Point.X - ISI.Width/2, 0, Components[1].ColumnCount - ISI.Width);
				else 
					ItemPos.X = Clamp(Point.X - (ISI.Width+1)/2, 0, Components[1].ColumnCount - ISI.Width);
				if (ISI.Height % 2 == 1) 
					ItemPos.Y = Clamp(Point.Y - ISI.Height/2, 0, Components[1].RowCount - ISI.Height);
				else
					ItemPos.Y = Clamp(Point.Y - (ISI.Height+1)/2, 0, Components[1].RowCount - ISI.Height);

				Rgn = RowColumnToScreen(Components[1],ItemPos.Y,ItemPos.X);

				XL = ISI.Width*Components[1].CellWidth+ISI.Width-1;
				YL = ISI.Height*Components[1].CellHeight+ISI.Height-1;
				X = Rgn.X;
				Y = Rgn.Y;

				C.SetPos(X,Y);
				C.SetRenderStyleAlpha();

				for (i=0;i<ISI.Width;i++)
				{
					for (j=0;j<ISI.Height;j++)
					{
						Foo = SepPetInventory.GetItem_RC(ItemPos.X+i,ItemPos.Y+j);

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

function SetInvenSize(int Width, int Height)
{
	Components[1].ColumnCount = Width;
	Components[1].RowCount = Height;
	InitComponent(Components[1]);
}


function OnInit()
{
	local PlayerServerInfo PSI;

	PSI = ClientController(PlayerOwner).PSI;
//	UITexture = Texture(DynamicLoadObject("PetUI.default.InventoryBack",class'Texture'));
	UITexture = Texture(DynamicLoadObject("UI_2011.win_pet_inven_lock",class'Texture'));
	UseSlotTexture = Texture(DynamicLoadObject("UI_2011.win_pet_inven_unlock",class'Texture'));

	Bag = CBag(AddInterface("SephirothUI.CBag"));

	if(Bag != None)
		Bag.ShowInterface();

	Bag.OffsetXL = 0;

//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));

//	SetComponentTextureId(Components[5],4,0,0,5);
//	SetComponentNotify(Components[5],BN_Exit,Self);

	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],UseSlotTexture);
//	SetSpriteTexture(UnitSprites[2],UITexture);
//	SetSpriteTexture(UnitSprites[3],TextureResources[0].Resource);
//	SetSpriteTexture(UnitSprites[4],TextureResources[1].Resource);

	Components[2].NotifyId = BN_Exit;
	SetComponentTextureId(Components[2],1,-1,2,2);

//	SetButtonResource(Buttons[0],-1,-1,-1,2,);
//	SetButtonResource(Buttons[1],3,-1,4,4,Localize("PetUI","Sort","SephirothUI"));

	SepPetInventory = PSI.PetInventory;
	Components[1].ColumnCount = SepPetInventory.InvenWidth;
	Components[1].RowCount = SepPetInventory.InvenHeight;	
	SepPetInventory.OnDrawItem = InternalDrawItem;
	InitComponent(Components[1]);
	//Log("=====>PetInventory"@SepPetInventory);
	GotoState('Nothing');

	m_sTitle = Localize("PetUI","PetUI","SephirothUI");
}

function OnFlush()
{
	SepPetInventory.OnDrawItem = None;
	if(Controller.bMouseDrag)
		Controller.bMouseDrag = false;
	
	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();
	
/*	if(InfoBox != None) {
		InfoBox.HideInterface();
		RemoveInterface(InfoBox);
		InfoBox = None;
	}*/

	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if(Bag != None) {
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}
}

function LayOut(Canvas C)
{
	local int i;
	PageX = C.ClipX - 282 - Components[0].XL;
	PageY = 0;
	MoveComponent(Components[0],true,PageX,PageY);
	for(i = 1 ; i < Components.Length ; i++)
		MoveComponent(Components[i]);
	Super.LayOut(C);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Exit)
	{
		if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType,optional coerce string Command)	{

	if ( Interface == Bag && NotifyType == INT_Close )	{
		
		if ( Command == "ByEscape" )	{

			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
			else
				Parent.NotifyInterface(Self, NotifyType, Command);
		}
		else
			Parent.NotifyInterface(Self,NotifyType);
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
//	local int Index;
	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}

	if ((Controller.SelectingSource != None && Controller.SelectingSource.IsInState('Selecting')) || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging')) )
		return false;

	if((Key == IK_LeftMouse || Key == IK_RightMouse) && IsCursorInsideComponent(Components[0]))
		return true;
}


function bool IsCursorInsideInterface()	{

	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() )
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
     PageY=40.000000
     UnitSprites(0)=(UL=255.000000,VL=276.000000)
     UnitSprites(1)=(UL=199.000000,VL=199.000000)
     Components(0)=(Type=RES_Image,XL=255.000000,YL=276.000000)
     Components(1)=(Id=1,Type=RES_RowColumn,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=47.000000,ColumnCount=2,RowCount=2,CellWidth=24,CellHeight=24,ColumnSpace=1,RowSpace=1)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=225.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     TextureResources(0)=(Package="UI_2011",Path="win_pet_inven_lock",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
}
