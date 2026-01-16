class Smithy extends CMultiInterface;

var CBag Bag;
var Forge Forge;
//var CInfoBox InfoBox;

function OnInit()
{
	Bag = CBag(AddInterface("SephirothUI.CBag"));

	if (Bag != None)
		Bag.ShowInterface();

	Forge = Forge(AddInterface("SephirothUI.Forge"));

	if (Forge != None)
		Forge.ShowInterface();

	Bag.OffsetXL = 496;

//	InfoBox = CInfoBox(AddInterface("SephirothUI.CItemInfoBox"));
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

	if ( Bag != None )	{

		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}

	if ( Forge != None )	{

		Forge.HideInterface();
		RemoveInterface(Forge);
		Forge = None;
	}

	Controller.SelectingSource = None;
	Controller.DragSource = None;
	Controller.ResetSelecting();
	Controller.ResetDragging();
	Controller.ResetObjectList();
}


function Render(Canvas C)
{
/*	Super.Render(C);

	if (Bag != None)
		Bag.ShowItemInfo(C, InfoBox);*/

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

	if ( theInterface == Bag )		
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
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
	}
	else
		MainHud.ItemTooltipBox.SetInfo(None);*/
}


function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	if ((Interface == Bag || Interface == Forge) && NotifyType == INT_Close) {
		if (Command == "ByEscape" && SephirothInterface(Parent).ItemTooltipBox.Source != None)
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		else
			Parent.NotifyInterface(Self,INT_Close);
	}
	else if (NotifyType == INT_Command && Command == "ClearInfo") {
		if ( SephirothInterface(Parent).ItemTooltipBox.Source != None)
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
	}
}


function bool IsCursorInsideInterface()	{

	if ( IsCursorInsideComponent(Components[0]) || Bag.IsCursorInsideInterface() || Forge.IsCursorInsideInterface() )
		return true;

	return false;
}

defaultproperties
{
}
