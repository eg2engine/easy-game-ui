class CMessageBoxBoothOpen extends CMessageBox;

function OnInit()
{
	Super.OnInit();
	SetComponentText(Components[3],"WithAd");
	SetComponentText(Components[4],"NoAd");
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
	if (Key == IK_Enter) {
		if (Action == IST_Press)
			return true;
		if (Action == IST_Release) {
			CloseBox(NotifyValue);
			return true;
		}
	}
}

static function CMessageBoxBoothOpen MessageBoxBoothOpen(CMultiInterface Parent,int NotifyId,string FeeString)
{
	local CMessageBoxBoothOpen MsgBox;
	MsgBox = CMessageBoxBoothOpen(Parent.Controller.HudInterface.AddInterface("SephirothUI.CMessageBoxBoothOpen",true));
	if (MsgBox != None) {
		MsgBox.NotifyValue = NotifyId;
		MsgBox.bNoHotkey = true;
		MsgBox.BoxType = MB_YesNo;
		MsgBox.Title="BoothOpen";
		MsgBox.ShowInterface();
		MsgBox.SetMessage(FeeString);
		MsgBox.NotifyTarget = Parent;
		Parent.bIgnoreKeyEvents = true;
	}
	return MsgBox;
}

defaultproperties
{
}
