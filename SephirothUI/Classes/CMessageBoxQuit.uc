class CMessageBoxQuit extends CMessageBox;

function OnInit()
{
	Super.OnInit();
	SetComponentText(Components[3],"QuitAtField");
	SetComponentText(Components[4],"QuitAtSafeZone");
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape) {
		if (Action == IST_Press)
			return true;
		if (Action == IST_Release) {
			HideInterface();
			CMultiInterface(Parent).RemoveInterface(Self);
			NotifyTarget.bIgnoreKeyEvents = false;
			return true;
		}
	}
}

static function CMessageBoxQuit MessageBoxQuit(CMultiInterface Parent,int NotifyId)
{
	local CMessageBoxQuit MsgBox;
	MsgBox = CMessageBoxQuit(Parent.Controller.HudInterface.AddInterface("SephirothUI.CMessageBoxQuit",true));
	if (MsgBox != None) {
		MsgBox.NotifyValue = NotifyId;
		MsgBox.bNoHotkey = true;
		MsgBox.BoxType = MB_YesNo;
		MsgBox.Title="SelectQuitLocation";
		MsgBox.ShowInterface();
		MsgBox.SetMessage(Localize("Modals","SelectQuitLocation","Sephiroth"));
		MsgBox.NotifyTarget = Parent;
		Parent.bIgnoreKeyEvents = true;
	}
	return MsgBox;
}

defaultproperties
{
}
