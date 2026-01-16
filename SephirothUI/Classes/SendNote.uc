class SendNote extends CMultiInterface;

const BN_Exit = 1;
const BN_Send = 2;

const Edit_Width = 215;
//const Edit_Height = 108;
const Edit_Height = 154;

var bool bGroup;
var string Receiver;
var string Body;
var CImeRichEdit RichEdit;

var string m_sTitle;

function OnInit()
{
	SetButton();

	RichEdit = CImeRichEdit(AddInterface("Interface.CImeRichEdit"));
	if (RichEdit != None) {
//		RichEdit.OnRichEditInit = InternalRichEditInitialized;
		RichEdit.ShowInterface();
		RichEdit.SetSize(Edit_Width, Edit_Height);	
		RichEdit.MaxLines = 8;		
		RichEdit.LineSpace = 22;
		RichEdit.SetFocusEditBox(true);
	}
	// jjh
	// PlayerOwner.ConsoleCommand("OpenIME 1"); --> moved to CRichEdit activation code
	WinX = Controller.MouseX;
	WinY = Controller.MouseY;
	
	m_sTitle = Localize("SendMsg","WriteMsg","SephirothUI");
}

function InternalRichEditInitialized()
{
//	local Chat Chat;
//	Chat = SephirothInterface(Controller.HudInterface).Chat;
//	if (Chat != None && (Chat.IsInState('Typing') || Chat.IsInState('Whispering')))
//		Chat.GotoState('');
}

function OnFlush()
{
	// PlayerOwner.ConsoleCommand("OpenIME 0"); --> moved to CRichEdit deactivation code
	if(RichEdit != None)
	{
		RichEdit.HideInterface();
		RemoveInterface(RichEdit);
		RichEdit = None;
	}	
}

function LayOut(Canvas C)
{
	local int i;
	// jjh ---
	if (WinX+WinWidth > C.ClipX)
		WinX = C.ClipX - WinWidth;
	if (WinY+WinHeight > C.ClipY)
		WinY = C.ClipY - WinHeight;
	MoveComponentId(0, true, WinX, WinY, WinWidth, WinHeight);
	// MoveComponentId(0,true,(C.ClipX-Components[0].XL)/2,(C.ClipY-Components[0].YL)/2);
	// ---jjh
	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.LayOut(C);
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
	if(Body == " ")
		Components[4].bDisabled = true;

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,XL,YL;
	local string To;
	local color OldColor;

	RichEdit.SetPos(Components[0].X+35, Components[0].Y+109);

	X = Components[0].X+86;
	Y = Components[0].Y+73;
	XL = 100;
	YL = 15;

	OldColor = C.DrawColor;	
	C.SetDrawColor(255,255,255);
	if(Receiver == "")
		To = Localize("Messenger","BaseGroup","Sephiroth");
	else
		To = Receiver;
	To = ClipText(C, To, XL);
	C.DrawKoreanText(To, X, Y,XL, YL);

	C.DrawColor = OldColor;		
}

function bool OnKeyEvent(interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function SetReceiver(string Name, bool flag)
{
	Receiver = Name;
	bGroup = flag;
}

function SetButton()
{
	Components[3].NotifyId = BN_Exit;
	Components[4].NotifyId = BN_Send;
	SetComponentTextureId(Components[3],9,-1,11,10);
	SetComponentTextureId(Components[4],9,-1,11,10);
}

defaultproperties
{
     Components(0)=(XL=289.000000,YL=371.000000)
     Components(1)=(Id=1,ResId=12,Type=RES_Image,XL=273.000000,YL=297.000000,PivotDir=PVT_Copy,OffsetXL=7.000000,OffsetYL=36.000000)
     Components(2)=(Id=2,ResId=13,Type=RES_Image,XL=46.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=74.000000)
     Components(3)=(Id=3,Caption="Close",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=150.000000,OffsetYL=329.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(4)=(Id=4,Caption="Send",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=50.000000,OffsetYL=329.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="SendMessage")
     TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="mail_bg",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="mail_to",Style=STY_Alpha)
     WinWidth=289.000000
     WinHeight=371.000000
}
