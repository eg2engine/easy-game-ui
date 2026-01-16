class CTooltip extends CMultiInterface;

var CAutoSizeTextArea TextArea;

function OnInit()
{
	TextArea = CAutoSizeTextArea(AddInterface("SephirothUI.CAutoSizeTextArea"));
	if (TextArea != None) {
		TextArea.ShowInterface();
	}
}

function OnFlush()
{
	if (TextArea != None) {
		TextArea.HideInterface();
		RemoveInterface(TextArea);
		TextArea = None;
	}
}

function ShowTooltip(string Text)
{
	TextArea.PushText(Text);
}

function HideTooltip()
{
	TextArea.ClearTexts();
}

defaultproperties
{
     bHideAllComponets=True
     bIgnoreKeyEvents=True
}
