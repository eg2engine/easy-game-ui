class CStore extends CMultiInterface;

var CBag Bag;
var CEquipment Equipment;
var CDepartment Store;
//var CInfoBox InfoBox;			// SephirothInterface에서 일괄관리하기 위해 주석처리되고 관련된 내용 삭제됨 Xelloss
var CSubInventorySelectBox SubSelectBox;

function OnInit()
{
	Equipment = CEquipment(AddInterface("SephirothUI.CEquipment"));
	if (Equipment != None)
		Equipment.ShowInterface();

	Bag = CBag(AddInterface("SephirothUI.CBag"));
	if (Bag != None)
		Bag.ShowInterface();

	Store = CDepartment(AddInterface("SephirothUI.CDepartment"));
	if (Store != None)
		Store.ShowInterface();

	Store.OffsetXL = 0;
	Bag.OffsetXL = Store.Components[0].XL;
	Equipment.OffsetXL = Store.Components[0].XL + Bag.Components[0].XL;
//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));

	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectbox != None)
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(Bag.OffsetXL,Bag.OffsetYL+Bag.Components[0].YL);
	}
}


function SetHost(NpcServerInfo Npc)
{
	Store.SetHost(Npc);
}

function SetShop(SephirothPlayer.Shop Shop)
{
	Store.SetShop(Shop);
}

function SetItems(ShopItems Items)
{
	Store.SetItems(Items);
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
	if (Store != None) {
		Store.HideInterface();
		RemoveInterface(Store);
		Store = None;
	}

	if (SubSelectBox != none){
    	SubSelectBox.HideInterface();
    	RemoveInterface(SubSelectBox);
    	SubSelectBox = none;
	}


	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();
}

function Render(Canvas C)	{

	local CInterface theInterface;
	local SephirothInterface MainHud;

	if ( Store.NpcPawn.Controller == None )	{

		Parent.NotifyInterface(Self,INT_Close);
		return;
	}

	Super.Render(C);

	if ( Store.ActionState == Store.BN_Buy )
		CItemInfoBox(SephirothInterface(Parent).ItemTooltipBox).SetDisplayMethod(0);
//		Use = 0;
	else if ( Store.ActionState == Store.BN_Sell )
		CItemInfoBox(SephirothInterface(Parent).ItemTooltipBox).SetDisplayMethod(1);
//		Use = 1;
	else if ( Store.ActionState == Store.BN_Repair )
		CItemInfoBox(SephirothInterface(Parent).ItemTooltipBox).SetDisplayMethod(2);
//		Use = 2;

/*	if ( Bag != None )
		Bag.ShowItemInfo(C, InfoBox);

	if ( Equipment != None )
		Equipment.ShowItemInfo(C, InfoBox);*/

	// Xelloss - 2011. 02. 24
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( theInterface == Equipment )
		Equipment.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if ( CBagResizable(theInterface) != None )
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);

/*	// Xelloss - 2011. 02. 14
	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )	{

		MainHud.ItemTooltipBox.SetInfo(None);
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
	else
		MainHud.ItemTooltipBox.SetInfo(None);*/
}


function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)	{

	switch ( NotifyType )	{

	case INT_Close :

		if ( Interface == Bag || Interface == Equipment )	{

			if ( Command == "ByEscape" && SephirothInterface(Parent.Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
			else
				Parent.NotifyInterface(Self, INT_Close);
		}
		else if ( Interface == Store )	{

			Parent.NotifyInterface(Self, INT_Close);
		}

		break;

	case INT_Command :

		if ( Command == "ClearInfo")	{

			if ( SephirothInterface(Parent.Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
		}

		break;
	}
/*	if ( (Interface == Bag ) && NotifyType == INT_Close )	{

		if ( Command == "ByEscape" && SephirothInterface(Parent.Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
		else
			Parent.NotifyInterface(Self,INT_Close);
	}
	else if ( Interface == Store && NotifyType == INT_Close )
		Parent.NotifyInterface(Self,INT_Close);
	else if (NotifyType == INT_Command && Command == "ClearInfo")	{

		if ( SephirothInterface(Parent.Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent.Parent).ItemTooltipBox.SetInfo(None);
	}*/
}


function bool IsCursorInsideInterface()
{
	if ( Bag.IsCursorInsideInterface() || Equipment.IsCursorInsideInterface() ||
		Store.IsCursorInsideInterface() || SubSelectBox.IsCursorInsideInterface() )	{

		return true;
	}
//	else	{

//		InfoBox.SetInfo(None);
		return false;
//	}
}

defaultproperties
{
     bVisible=True
}
