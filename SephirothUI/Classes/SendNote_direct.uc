class SendNote_direct extends SendNote;

var CImeEdit NameEdit;

function OnInit()
{
	Super.OnInit();	
	//NameEdit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	NameEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (NameEdit != None) {	
		NameEdit.bNative = True;
		NameEdit.SetMaxWidth(20);
		NameEdit.SetSize(140, 18);
		NameEdit.ShowInterface();
		NameEdit.SetFocusEditBox(true);
	}
	
	m_sTitle = Localize("SendMsg","WriteMsg","SephirothUI");
}

function OnFlush()
{
	Super.OnFlush();
	if (NameEdit != None) {
		NameEdit.SetFocusEditBox(false);
		NameEdit.HideInterface();
		RemoveInterface(NameEdit);
		NameEdit = None;
	}
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch(NotifyId)
	{
		case BN_Exit:		
			Parent.NotifyInterface(self,INT_Close);
			break;

		case BN_Send:
			Body = RichEdit.GetText();
			Receiver = NameEdit.GetText();
			if(Body == "")		
			{
				class'CMessageBox'.static.MessageBox(Self,"SendNote",Localize("Inbox","NullMessage","Sephiroth"),MB_OK);
				return;
			}
			if(bGroup)
				SephirothPlayer(PlayerOwner).Net.NotiNoteSendToGroup(Receiver,Body);
			else
				SephirothPlayer(PlayerOwner).Net.NotiNoteSend(Receiver,Body);
			Parent.NotifyInterface(self,INT_Close);
			break;
	}
}

function OnPreRender(Canvas C)
{
	local float X, Y;

	X = Components[0].X;
	Y = Components[0].Y;

	if(Body == " ")
		Components[4].bDisabled = true;
	if (NameEdit != None)
		NameEdit.SetPos(X+86, Y+73);

	RichEdit.SetPos(X+35, Y+109);

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}

function OnPostRender(HUD H, Canvas C)
{

}




function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_Tab && Action == IST_Press) {			
		if (!NameEdit.HasFocus() && !RichEdit.HasFocus())
			NameEdit.SetFocusEditBox(true);
		else if (NameEdit.HasFocus() && !RichEdit.HasFocus()) {
			NameEdit.SetFocusEditBox(false);
			RichEdit.SetFocusEditBox(true);
		}
		else if (!NameEdit.HasFocus() && RichEdit.HasFocus()) {
			RichEdit.SetFocusEditBox(false);
			NameEdit.SetFocusEditBox(true);
		}
		return true;
	}
	if (Key == IK_Enter && Action == IST_Press) {
		if (!NameEdit.HasFocus() && NameEdit.GetText() == "") {
			if (RichEdit.HasFocus())
				RichEdit.SetFocusEditBox(false);
			NameEdit.SetFocusEditBox(true);
		}
		else if (!RichEdit.HasFocus() && RichEdit.GetText() == "") {
			if (NameEdit.HasFocus())
				NameEdit.SetFocusEditBox(false);
			RichEdit.SetFocusEditBox(true);
		}
	/*	else if (RichEdit.GetText() != "" && NameEdit.GetText() != "") {	//Enter의 기능은 나중에 생각.
			if (RichEdit.HasFocus())
				RichEdit.SetFocusEditBox(false);
			if (NameEdit.HasFocus())
				NameEdit.SetFocusEditBox(false);
		}
	*/
		return true;
	}
	if (Key == IK_LeftMouse && Action == IST_Press) {		//modified by yj  
		if (NameEdit.IsInBounds() && !NameEdit.HasFocus()) {
			NameEdit.SetFocusEditBox(true);
			return true;
		}
		else if (!RichEdit.IsInBounds() && RichEdit.HasFocus()) {
			RichEdit.SetFocusEditBox(false);
			return true;
		}
		else if (RichEdit.IsInBounds() && !RichEdit.HasFocus()) {
			RichEdit.SetFocusEditBox(true);
			return true;
		}
		else if (!RichEdit.IsInBounds() && RichEdit.HasFocus()) {
			RichEdit.SetFocusEditBox(false);
			return true;
		}
	}
	if (!NameEdit.HasFocus() && !RichEdit.HasFocus() && ((Key >= IK_0 && Key <= IK_9) || (Key >= IK_A && Key <= IK_Z)) && Action == IST_Press) {
		NameEdit.SetFocusEditBox(true);
		return true;
	}

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;

	return false;
}

defaultproperties
{
     Components(3)=(Caption="Cancel",ToolTip="CancelMessage")
     TextureResources(0)=(Path="win_1_LU")
     TextureResources(1)=(Path="win_1_CU")
     TextureResources(2)=(Path="win_1_RU")
}
