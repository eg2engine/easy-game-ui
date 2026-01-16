class CStashBox extends CBag;

const IDS_MoneyToBag = 20;

var Bank Bank;

function OnInit()
{
	Super.OnInit();
	Components[3].bDisabled = true;		//���߿� ���ľ� �ؾ��� ��.
	Bank = CStashLobby(Parent).Bank;
	SepInventory = Bank.StashItems;
	SepInventory.OnDrawItem = Super.InternalDrawItem;
}

function OnFlush()
{
	SepInventory.Clear();

	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetobjectList();
}

function OnPreRender(Canvas C)
{
	Components[6].Caption = Controller.MoneyStringEx(SepInventory.strMoney);
}

function MoneyButtonProc()
{
	class'CEditBox'.static.MoneyEditBox(Self,"StashMoneyToBag",Localize("Modals","TitleMoneyToBag","Sephiroth"),IDS_MoneyToBag,20);
}
//������ �ǹ̰� ���� �Լ�   //������ ��ӹ޾Ҵ� ��	//������ ���� ������ �����ϱ� ���� override
function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case BN_Exit:
		Controller.ResetDragAndDropAll();
		Parent.NotifyInterface(Self,INT_Close);
		break;
	//case BN_Sort:
	//	if( bIsSellerBooth || bIsGuestBooth )
	//		return;
	//	Parent.NotifyInterface(Self,INT_Command,"ClearInfo");
	//	SephirothPlayer(PlayerOwner).Net.NotiStashArrangeItem(CStashLobby(Parent).SelectedStashID,0,0,0,0);
	//	SephirothPlayer(PlayerOwner).Net.NotiCommand("Bag Arrange");
	//	break;
	case BN_Leni:
		MoneyButtonProc();
		break;
	}
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	if (NotifyId == IDS_MoneyToBag && SephirothPlayer(PlayerOwner).CmpInt64(EditText, "0") > 0)
		SephirothPlayer(PlayerOwner).Net.NotiStashRemoveMoney(CStashLobby(Parent).SelectedStashID, EditText);
}

function DrawObject(Canvas C)
{	
//	local float X,Y;
	local int nGab;

	nGab = SephirothPlayer(PlayerOwner).PSI.nCurTime - SephirothPlayer(PlayerOwner).PSI.nLastBoothAddTime;

	if(nGab < LockSec) //add neive : ���� ���� ����
		C.SetDrawColor(100,100,100,100);	
/*
	if(Controller.SelectingSource != None && Controller.SelectingSource == Self && Controller.SelectingSource.IsInState('Selecting'))
	{
		if(Controller.ObjectList.Length > 0)
			RenderSelectionState(C, CBag(Controller.SelectingSource).Components[4].X, CBag(Controller.SelectingSource).Components[4].Y, Controller.ObjectList);//Controller.SelectingList);
		if(Controller.SelectingList.Length > 0)
			RenderSelectionState(C, CBag(Controller.SelectingSource).Components[4].X, CBag(Controller.SelectingSource).Components[4].Y, Controller.SelectingList);
	}

	if(Controller.DragSource != None && Controller.DragSource == Self && Controller.DragSource.IsInState('Dragging'))
		RenderSelectionState(C, CBag(Controller.DragSource).Components[4].X, CBag(Controller.DragSource).Components[4].Y, Controller.SelectedList);
*/
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

	DrawTitle(C, Localize("StashBoxUI","StashBox","SephirothUI"));
/*
	X = Components[0].X;		
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);		//modified by yj  ���� ü��������.
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("StashBoxUI","StashBox","SephirothUI"),Components[0].X,Components[0].Y+13,Components[0].XL,20);
	C.SetDrawColor(255,255,0);	
*/
}


function bool OnDropItem(Point Dest)
{
	local SephirothItem Item;
	local array<SephirothItem> ItemList;
	local int i;
	local int SrcIndex;

	//// �����õ� ��
	//class'CMessageBox'.static.MessageBox(self, "HelpMsg", Localize("StashBoxUI","Error","SephirothUI"), MB_Ok);
	//	return false;

	if(Controller.DragSource == Self)
	{
		if(Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);
			SephirothPlayer(PlayerOwner).Net.NotiStashArrangeItem(CStashLobby(Parent).SelectedStashId,Item.X,Item.Y,Dest.X,Dest.Y);
	//		//Log("Item.X,Item.Y"@Item.X@Item.Y);
	//		//Log("Dest.X,Dest.Y"@Dest.X@Dest.Y);
			return true;
		}
	}

	if(Controller.DragSource != Self)
	{
		if(Controller.DragSource.IsA('CBag'))
			SrcIndex = 0;
		else if(Controller.DragSource.IsA('CBagResizable'))
			SrcIndex = CBagResizable(Controller.DragSource).SubInvenIndex+1;
		else
			return false;

		if(Controller.SelectedList.Length == 1)
		{
			Item = SephirothItem(Controller.SelectedList[0]);

/*			if(Item.IsUnseal())	// ������ ������ �������̶��
			{
				Controller.ResetDragAndDropAll();
				class'CMessageBox'.static.MessageBox(Self,"ItemMoveFailed",Localize("CBag","MoveError","SephirothUI"),MB_Ok);
				return false;
			}
			else
			{*/
				SephirothPlayer(PlayerOwner).Net.NotiStashAddItem(CStashLobby(Parent).SelectedStashId,SrcIndex,Item.X,Item.Y,Dest.X,Dest.Y);
				return true;
//			}
		}
		else if(Controller.SelectedList.Length > 1)
		{
			for(i=0; i<Controller.SelectedList.Length; i++)
			{
				ItemList[i] = SephirothItem(Controller.SelectedList[i]);

/*				if(ItemList[i].IsUnseal())	// ������ ������ �������̶��
				{
					Controller.ResetDragAndDropAll();
					class'CMessageBox'.static.MessageBox(Self,"ItemMoveFailed",Localize("CBag","MoveError","SephirothUI"),MB_Ok);
					return false;
				}*/
			}

			SephirothPlayer(PlayerOwner).Net.NotiStashAddItemMany(CStashLobby(Parent).SelectedStashId,SrcIndex, ItemList);
			return true;
		}
	}

	return false;
}

function ShowItemInfo(Canvas C, CInfoBox InfoBox)
{
	local Point Point;
	local SephirothItem ISI;
	local InterfaceRegion Rgn, RgnEnd;
	local color OldColor;

	if (!IsCursorInsideComponent(Components[0]))
		return;

	if (Controller.Modal() || Controller.ContextMenu != None || Controller.bLButtonPressed || (Controller.DragSource != None && Controller.DragSource.IsInState('Dragging'))) 
	{
		InfoBox.SetInfo(None);
		return;
	}

	Point = ScreenToRowColumn(Components[4],Controller.MouseX,Controller.MouseY);

	if ( Point.X != -1 && Point.Y != -1 )
	{
		ISI = SepInventory.GetItem_RC(Point.X, Point.Y);

		if ( ISI != None )
		{
			Rgn = RowColumnToScreen(Components[4],ISI.Y,ISI.X);
			OldColor = C.DrawColor;
			C.SetDrawColor(114, 121, 196);
			C.SetPos(Rgn.X - 1, Rgn.Y - 1);
			DrawBox(C,Rgn.W*ISI.Width+ISI.Width,Rgn.H*ISI.Height+ISI.Height,1);
			RgnEnd = RowColumnToScreen(Components[4], ISI.Y + ISI.Height - 1, ISI.X + ISI.Width - 1);

			if ( bIsSellerBooth || bIsGuestBooth )
				CItemInfoBox(InfoBox).SetDisplayMethod(4);
			if ( Controller.bMouseMoved )
				InfoBox.SetInfo(ISI, RgnEnd.X + RgnEnd.W + 1, RgnEnd.Y + RgnEnd.H + 1, true, C.ClipX, C.ClipY);

			C.DrawColor = OldColor;
		}
	}
}

function bool DoubleClick()
{
	return false;
}

defaultproperties
{
}
