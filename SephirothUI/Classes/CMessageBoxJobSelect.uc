class CMessageBoxJobSelect extends CMessageBox;

function OnInit()
{
	Super.OnInit();
	SetComponentText(Components[3],"SelectBare");
	SetComponentText(Components[4],"SelectOneHand");
}

static function CMessageBoxJobSelect MessageBoxJobSelect(CMultiInterface Parent,coerce string Title,coerce string Message,EMessageBoxType Type,optional int NotifyId,optional bool bNoHotkey)
{
	local CMessageBoxJobSelect MsgBox;
	MsgBox = CMessageBoxJobSelect(Parent.Controller.HudInterface.AddInterface("SephirothUI.CMessageBoxJobSelect",true));
	if (MsgBox != None) {
		MsgBox.NotifyValue = NotifyId;
		MsgBox.bNoHotkey = bNoHotkey;
		MsgBox.BoxType = Type;
		MsgBox.Title=Title;
		MsgBox.ShowInterface();
		MsgBox.SetMessage(Message);
		MsgBox.NotifyTarget = Parent;
		Parent.bIgnoreKeyEvents = true;
	}
	return MsgBox;
}

defaultproperties
{
}
