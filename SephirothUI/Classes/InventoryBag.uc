//################
// CInventoryBag ���� �ٲ���� �κ����� ��Ŭ���� �ȸ����� �Ѥ�;; ��¿ �� ���� �ٲ� ���� ����;;;
//################

class InventoryBag extends CMultiInterface;

var CBag Bag; 
var CEquipment Equipment;
var CSubInventorySelectBox SubSelectBox;
var SephirothItem SealedItem;
var CInGameShopAD InGameShopAD;

//var CInfoBox InfoBox;		// SephirothInterface���� �ϰ������ϱ� ���� �ּ�ó���ǰ� ���õ� ���� ������ Xelloss

function OnInit()
{
	Bag = CBag(AddInterface("SephirothUI.CBag")); 
	if (Bag != None)
		Bag.ShowInterface();

	Equipment = CEquipment(AddInterface("SephirothUI.CEquipment"));
	if (Equipment != None)
		Equipment.ShowInterface();

	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(Components[0].X,Bag.Components[0].Y+Bag.Components[0].YL);
	}
/*
	// �ΰ��Ӽ�
	InGameShopAD = CInGameShopAD(AddInterface("SephirothUI.CInGameShopAD"));
	if(InGameShopAD != None)
		InGameShopAD.ShowInterface();
*/
	Bag.OffsetXL = 0;
	Equipment.OffsetXL = 282;
//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
	Controller.bNoneDrop = false;

//	GotoState('Nothing');
}

function OnFlush()
{
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
	if (Equipment != None) {
		Equipment.HideInterface();
		RemoveInterface(Equipment);
		Equipment = None;
	}
    if (SubSelectBox != none){
    	SubSelectBox.HideInterface();
    	RemoveInterface(SubSelectBox);
    	SubSelectBox = none;
    }

	if(InGameShopAD != None)
	{
		InGameShopAD.HideInterface();
		RemoveInterface(InGameShopAD);
		InGameShopAD = None;
	}

	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	if ( NotifyType == INT_Close )
	{
		if ( Interface == Bag || Interface == Equipment )	{

			// Xelloss
			if ( Command == "ByEscape" && SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
			else
				Parent.NotifyInterface(Self, INT_Close);
		}
	}
	else if ( NotifyType == INT_Command )
	{
		if ( Command == "ClearInfo" )
		{
			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		}
	}
}


function Render(Canvas C)	{

	local CInterface theInterface;
	local SephirothInterface MainHud;

	Super.Render(C);

/*	if(bFocused)
	{
	if (Bag != None)
		Bag.ShowItemInfo(C, InfoBox);
	if (Equipment != None)
		Equipment.ShowItemInfo(C, InfoBox);
	}	
	else
		InfoBox.SetInfo(None);*/

	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface == Equipment )
		Equipment.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);

	// Xelloss - 2011. 02. 14
/*	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

//		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Self )	{
		
		theInterface = GetTopInterfaceBelowCursor();

		if ( CBag(theInterface) != None )
			CBag(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
		else if ( CEquipment(theInterface) != None )
			CEquipment(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	}
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
//	else
//		MainHud.ItemTooltipBox.SetInfo(None);
*/
}


function bool IsCursorInsideInterface()
{
//	if( IsCursorInsideComponent(Components[0]) )	{
	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() || Equipment.IsCursorInsideInterface() || SubSelectBox.IsCursorInsideInterface() )	{

		return true;
	}
//	else	{

//		InfoBox.SetInfo(None);
		return false;
//	}
}

//Item Drop ���콺 ����Ʈ üũ. �κ��丮�� �ܿ� �ٸ��������� ����Ѵ�.
function bool IsCursorInsideItemDropArea()
{
	if( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() ||
		Equipment.IsCursorInsideInterface() || SubSelectBox.IsCursorInsideInterface() || IsCursorInsideSubInvens() )
	{
		return false;
	}
	return true;
}


function bool IsCursorInsideSubInvens()
{
    local int nSubInvens;
    local int i;
    local array<CBagResizable> SubInvens;
    SubInvens = SephirothInterface(Parent).SubInventories;
    nSubInvens = SubInvens.Length;
    for( i =0; i<nSubInvens; i++)
    {
		//Log("IsCursorInsideSubInvens Index:"$i);
    	if(SubInvens[i].IsCursorInsideInterface())
    		return true;
	}
	return false;
}


// Xelloss : Drop�����Ͽ� ������ ������
function bool OnPress(Interaction.EInputKey Key)	{

	if ( !IsCursorInsideInterface() )	{

		if ( Key == IK_LeftMouse )
			Controller.bNoneDrop = false;

		return false;
	}
}


function bool OnRelease(Interaction.EInputKey Key)	{
	
	if ( !IsCursorInsideInterface() && (Key == IK_LeftMouse) )	{

		if ( Controller.DragSource != none && Controller.DragSource.IsInState('Dragging') &&
			!Controller.bNoneDrop && SephirothInterface(Parent).ITopOnCursor == None )	{

			if ( Drop() )	{

				Controller.ResetDragging();
				Controller.ResetObjectList();
				
				if ( Controller.DragSource != None )
					Controller.DragSource.GotoState('Nothing');
				
				Controller.DragSource = None;
				return true;
			}
		}
	}

	return false;
}
// Xelloss


function bool Drop()
{
	local SephirothItem ISI;
	local int i;
	local CMainInterface MainHud;

	MainHud = SephirothInterface(Parent).MainHud;

	if (Controller.DragSource != None && Controller.SelectedList.Length > 0)	{

        if ( (Controller.DragSource.IsA('CBag') || Controller.DragSource.IsA('CBagResizable')) && IsCursorInsideItemDropArea() )
			//&& !Bag.IsCursorInsideInterface() && !Equipment.IsCursorInsideInterface() && !IsCursorInsideSubInvens() && !SubSelectBox.IsCursorInsideInterface() )  //TEST �ڵ�. TestBag�� ���� üũ
		{
			if ( MainHud != None && !MainHud.IsCursorInsideInterface() ) 
			{
				if ( Controller.CanDropObjectAtMousePos() )
				{
					for ( i = 0 ; i < Controller.SelectedList.Length ; i++ ) 
					{
						ISI = SephirothItem(Controller.SelectedList[i]);

						if (ISI != None)
						{
 							// ���� ������ ���������� Ȯ���Ѵ�.
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
									class'CMessageBox'.static.MessageBox(CBagResizable(Controller.DragSource), "DropSealedItem", Localize("Modals", "DeleteUsedItem", "Sephiroth"),
																		MB_YesNo, CBagResizable(Controller.DragSource).IDM_DROPUSEDITEM);
								}
							
								break;
							}
							else
							{
								if ( Controller.DragSource == Bag )
									SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(0, ISI.X, ISI.Y, PlayerOwner.Pawn.Location.Z);
								else	//CBagResizable
									SephirothPlayer(PlayerOwner).Net.NotiDropInvenItem(CBagResizable(Controller.DragSource).SubInvenIndex + 1, ISI.X, ISI.Y, PlayerOwner.Pawn.Location.Z);
							}
						}
					}
				}
				else
				{
					Controller.ResetDragAndDropAll();
				}
				return true;
			}
		}
        else if (Controller.DragSource == Equipment && IsCursorInsideItemDropArea() )
			//&& !Equipment.IsCursorInsideInterface() && !Bag.IsCursorInsideInterface() && !IsCursorInsideSubInvens() )   //TEst�ڵ�. TEstBag�� ���� üũ
		{
			if (MainHud != None && !MainHud.IsCursorInsideInterface()) 
			{
				ISI = SephirothItem(Controller.SelectedList[0]);
				if (Controller.CanDropObjectAtMousePos())
					SephirothPlayer(PlayerOwner).Net.NotiDropWornItem(ISI.EquipPlace, PlayerOwner.Location.Z);
				else
					Controller.ResetDragAndDropAll();
				return true;
			}
		}
	}

	return false;
}

defaultproperties
{
     bVisible=True
     bDragAndDrop=True
}
