class CUserReport extends CMultiInterface;

var string Caption;
var float CaptionHeight;
var float StatusHeight;
var float ActionHeight;
var float SelectAreaMarginWidth;
var string TextCache;

var CImeRichEdit Edit;

const BN_Apply = 1;
const BN_Cancel = 2;

const IDD_USERREPORTHELP = 10;

var array<Color> EdgeColors;

delegate OnSelectChoice(int ChoiceIndex, string Choice);

function OnInit()
{
	Components[1].NotifyId = BN_Apply;
	Components[2].NotifyId = BN_Cancel;
	SetComponentTextureId(Components[1],0,-1,1,2);
	SetComponentTextureId(Components[2],0,-1,1,2);
	Edit = CImeRichEdit(AddInterface("Interface.CImeRichEdit"));
	if (Edit != None) {
		if (TextCache != "")
			Edit.SetText(TextCache);
		Edit.ShowInterface();
		Edit.SetSize(WinWidth - 2 * SelectAreaMarginWidth, WinHeight - CaptionHeight - ActionHeight - StatusHeight);
		Edit.MaxLines = 5;
		Edit.LineSpace = 24;
		Edit.SetFocusEditBox(true);
		Edit.SetTextColorEx(255,195,109);
	}
}

function OnFlush()
{
	if (Edit != None) {
		Edit.HideInterface();
		RemoveInterface(Edit);
		Edit = None;
	}
}

function Layout(Canvas C)
{
	WinX = (C.ClipX - WinWidth) / 2;
	WinY = (C.ClipY - WinHeight) / 2;
	MoveComponentId(0,true,(C.ClipX-Components[0].XL)/2,(C.ClipY-Components[0].YL)/2);
	MoveComponentId(1,true,WinX+WinWidth/2-Components[1].XL-20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[1].YL)/2);
	MoveComponentId(2,true,WinX+WinWidth/2+20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[2].YL)/2);
	if (Edit != None)
		Edit.SetPos(WinX + SelectAreaMarginWidth, WinY + CaptionHeight);
	Super.Layout(C);
}

function SetCaption(string InCaption)
{
	Caption = InCaption;
}

function RemoveSpaces(out string Message)
{
	if (Message == "")
		return;
	while (Left(Message, 1) == " ")
		Message = Mid(Message, 1);
}

function SetData(coerce string Message)
{
//	RemoveSpaces(Message);
	if (Edit != None)
		Edit.SetText(Message);
	else
		TextCache = Message;
}

static function CUserReport PopupUserReport(CMultiInterface Parent, coerce string Title, coerce string Message)
{
	local CUserReport report;
	report = CUserReport(Parent.Controller.HudInterface.AddInterface("SephirothUI.CUserReport", true));
	if (report != None) {
		report.SetCaption(Title);
		report.SetData(Message);
		report.ShowInterface();
	}
	return report;
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local string text;
	if (NotifyId == BN_Apply) {
		text = Edit.GetText();
		RemoveSpaces(text);
		if (text != "") {
			ReplaceText(text, "|", " ");
			SephirothPlayer(PlayerOwner).Net.NotiUserReport(text);
		}
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
	}
	else if (NotifyId == BN_Cancel) {
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
	}
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	// keios - handle userreporthelp result 
	if(NotifyId == INT_Close)
	{
		if(int(Command) == IDD_USERREPORTHELP)
		{
			ShowInterface();						
		}
		else if(int(Command) == -1 * IDD_USERREPORTHELP)
		{
			CMultiInterface(Parent).RemoveInterface(Self);
		}
	}
}


function OnPreRender(Canvas C)
{
	local float X, Y, Width, Height;

	Components[1].bDisabled = Edit.GetText() == "";
	C.SetRenderStyleAlpha();
	C.SetPos(WinX, WinY);
	C.DrawTile(Texture'TextBlackBg',WinWidth, WinHeight,0,0,4,4);

	DrawRaisedRectangle(WinX, WinY, WinWidth, WinHeight, EdgeColors.Length, EdgeColors);

	X = WinX+SelectAreaMarginWidth;
	Y = WinY+CaptionHeight;
	Width = WinWidth-2*SelectAreaMarginWidth;
	Height = WinHeight-CaptionHeight-ActionHeight-StatusHeight;

	class'CNativeInterface'.static.DrawLine(X,Y,X+Width,Y,EdgeColors[0]);
	class'CNativeInterface'.static.DrawLine(X+Width,Y,X+Width,Y+Height,EdgeColors[0]);
	class'CNativeInterface'.static.DrawLine(X,Y+Height,X+Width,Y+Height,EdgeColors[0]);
	class'CNativeInterface'.static.DrawLine(X,Y,X,Y+Height,EdgeColors[0]);
}

function OnPostRender(HUD H, Canvas C)
{
	C.DrawTextJustified(MakeColorCodeEx(229,201,174) $ Caption, 1, WinX, WinY, WinX + WinWidth, WinY + CaptionHeight);
}

function DrawRaisedRectangle(float X, float Y, float W, float H, int LineWidth, array<color> Colors)
{
	local int i;
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i+W, Y+i, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i+H, X+i+W, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i+W, Y+i, X+i+W, Y+i+H, Colors[i]);
}

defaultproperties
{
     CaptionHeight=30.000000
     StatusHeight=20.000000
     ActionHeight=30.000000
     SelectAreaMarginWidth=10.000000
     EdgeColors(0)=(B=113,G=113,R=114,A=255)
     EdgeColors(1)=(B=48,G=50,R=55,A=255)
     EdgeColors(2)=(B=16,G=19,R=20,A=255)
     Components(0)=(XL=300.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="Send",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=157.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Caption="Cancel",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=95.000000,OffsetYL=157.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Escape)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     WinWidth=300.000000
     WinHeight=200.000000
}
