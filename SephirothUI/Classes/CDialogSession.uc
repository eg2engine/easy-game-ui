class CDialogSession extends CMultiInterface;

var CTextScroll Dialog;
//var SepEditBox Edit;
var CImeEdit Edit;

var bool bIcon;
var string OtherPlayName;

var array<string> Contents;

function InitDialog(string Name, string Msg)
{
	OtherPlayName = Name;
	Contents[0] = Msg;
}

function ReceiveDialog(string Name, string Msg);

function OnInit()
{
	GotoState('Window');
}

state Window
{
	function BeginState()
	{
		local int i;

		WinX=200;
		WinY=100;
		WinWidth=400;
		WinHeight=216;
		Dialog = CTextScroll(AddInterface("Interface.CTextScroll"));
		if (Dialog != None) {
			Dialog.ShowInterface();
			Dialog.TextList.bReadOnly = True;
			Dialog.TextList.bWrapText = True;
			Dialog.TextList.TextAlign = 0;
			Dialog.TextList.ItemHeight = 14;
			Dialog.SetSize(WinWidth, WinHeight-16);
			Dialog.TextList.TextColor = class'Canvas'.static.MakeColor(255,255,255);
	//		Dialog.TextList.OnDrawText = InternalDrawTextItem;

			for (i=0;i<Contents.Length;i++) {
				Dialog.TextList.MakeList(Contents[i]);
			}
		}

		//Edit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
		Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
		if (Edit != None) {
			Edit.bNative = true;
			Edit.SetMaxWidth(80);
			Edit.SetSize(WinWidth,16);
			Edit.ShowInterface();
			Edit.SetFocusEditBox(true);
		}
	}

	function EndState()
	{
		if (Dialog != None) {

			Contents = Dialog.TextList.Elements;

			Dialog.HideInterface();
			RemoveInterface(Dialog);
			Dialog = None;
		}

		if (Edit != None) {
			Edit.SetFocusEditBox(false);
			Edit.HideInterface();
			RemoveInterface(Edit);
			Edit = None;
		}
	}

	function Layout(Canvas C)
	{
		if (Dialog != None)
			Dialog.SetPos(WinX+0,WinY+0);
		if (Edit != None)
			Edit.SetPos(WinX+0,WinY+WinHeight-16);
	}

	function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
	{
		if (Key == IK_Enter && Action == IST_Press) {
			SyncDialog();
			return true;
		}
		if (Key == IK_Escape && Action == IST_Press) {
			// SephirothInterface(Parent).FinishDialogSession();
			GotoState('Icon');
			return true;
		}
		if (Key == IK_LeftMouse && Action == IST_Press && IsCursorInsideAt(WinX, WinY, WinWidth, WinHeight)) {
			if (!Edit.HasFocus())
				Edit.SetFocusEditBox(true);
			return true;
		}
		return false;
	}

	function OnPreRender(Canvas C)
	{
		C.SetPos(WinX-5,WinY-5);
		C.SetDrawColor(0,255,0);
		C.DrawTile(Controller.BackgroundBlend,WinWidth+10,WinHeight+10,0,0,0,0);
		class'CNativeInterface'.static.DrawRect(WinX,WinY+WinHeight-16,WinX+WinWidth,WinY+WinHeight,class'Canvas'.static.MakeColor(255,255,255));
	}

	function SyncDialog()
	{
		local string Text;
		local string Player;

		Text = Edit.GetText();
		if (Text == "")
			return;

		Player = string(SephirothPlayer(PlayerOwner).PSI.PlayName);
		AddDialog(true, Player, Text);
		SephirothPlayer(PlayerOwner).Net.NotiWhisper(OtherPlayName, Text);
		Edit.SetText("");
		Edit.SetFocusEditBox(false);
	}

	function AddDialog(bool bSelf, string Teller, string Message)
	{
		local color NameColor;
		if (bSelf)
			NameColor = class'Canvas'.static.MakeColor(128,128,255);
		else
			NameColor = class'Canvas'.static.MakeColor(128,255,128);
		Dialog.TextList.MakeList(MakeColorCode(NameColor) $ Teller $ MakeColorCodeEx(255,255,255) $ ": " $ Message);
		Dialog.TextList.End();
	}

	function ReceiveDialog(string Teller, string Message)
	{
		AddDialog(false, Teller, Message);
	}
}

state Icon
{
	function BeginState()
	{
		WinX=10;
		WinY=140;
		WinWidth=128;
		WinHeight=32;
	}
	function OnPostRender(HUD H, Canvas C)
	{
		C.SetPos(WinX,WinY);
		C.SetDrawColor(0,255,0);
		C.DrawTile(Controller.BackgroundBlend,WinWidth,WinHeight-16,0,0,0,0);
		C.SetDrawColor(255,255,0);
		C.DrawTextJustified(ClipText(C, OtherPlayName, WinWidth), 0, WinX, WinY+16, WinX+WinWidth, WinY+WinHeight);
	}
	function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
	{
		if (Key == IK_LeftMouse && IsCursorInsideAt(WinX,WinY,WinWidth,WinHeight)) {
			GotoState('Window');
			return true;
		}
		return false;
	}
}

defaultproperties
{
     OtherPlayName="ABCDEFG"
     WinX=200.000000
     WinY=100.000000
     WinWidth=400.000000
     WinHeight=216.000000
}
