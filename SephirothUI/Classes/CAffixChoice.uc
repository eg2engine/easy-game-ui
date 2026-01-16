class CAffixChoice extends CMultiInterface;	// 쓰이지 않고 있다

var string Caption;
var float CaptionHeight;
var float StatusHeight;
var float ActionHeight;
var float SelectAreaMarginWidth;
var CTextList Candidates;

const BN_Apply = 1;
const BN_Cancel = 2;

var string SelectedAffix;
var int SelectedAffixIndex;
var array<Color> EdgeColors;

delegate OnSelectChoice(int ChoiceIndex, string Choice);

function OnInit()
{
	Components[1].NotifyId = BN_Apply;
	Components[2].NotifyId = BN_Cancel;
	SetComponentTextureId(Components[1],1,0,0,2);
	SetComponentTextureId(Components[2],1,0,0,2);
	
	Candidates = CTextList(AddInterface("Interface.CTextList"));
	if (Candidates != None) {
		Candidates.ShowInterface();
		Candidates.bReadOnly = False;
		Candidates.bWrapText = False;
		Candidates.TextAlign = 0;
		Candidates.ItemHeight = 16;
		Candidates.SetSize(WinWidth - 2 * SelectAreaMarginWidth, WinHeight - CaptionHeight - ActionHeight - StatusHeight);
		Candidates.OnDrawText = InternalDrawItemAffix;
		Candidates.OnDrawSelectedBK = InternalDrawItemAffixHighlight;
		Candidates.OnSelectText = InternalSelectAffix;
	}
}

function OnFlush()
{
	if (Candidates != None) {
		Candidates.HideInterface();
		RemoveInterface(Candidates);
		Candidates = None;
	}
}

function Layout(Canvas C)
{
	WinX = (C.ClipX - WinWidth) / 2;
	WinY = (C.ClipY - WinHeight) / 2;
	MoveComponentId(0,true,(C.ClipX-Components[0].XL)/2,(C.ClipY-Components[0].YL)/2);
	MoveComponentId(1,true,WinX+WinWidth/2-Components[1].XL-20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[1].YL)/2);
	MoveComponentId(2,true,WinX+WinWidth/2+20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[2].YL)/2);
	if (Candidates != None) {
		Candidates.SetPos(WinX + SelectAreaMarginWidth, WinY + CaptionHeight);
		Candidates.SetSize(WinWidth - 2 * SelectAreaMarginWidth, WinHeight - CaptionHeight - ActionHeight - StatusHeight);
	}
	Super.Layout(C);
}

function InternalDrawItemAffix(Canvas C, int i, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;

	if (bSelected) {
		if (Controller.bLButtonDown) {
			X += 1.0f;
			Y += 1.0f;
		}
		ColorCode = MakeColorCodeEx(30,30,220);
	}
	else
		ColorCode = MakeColorCodeEx(255,255,255);
	C.DrawTextJustified(ColorCode $ Text, 0, X, Y, X+W, Y+H);
}

function InternalDrawItemAffixHighlight(Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.SetPos(X, Y);
	C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', W, H);
}

function InternalSelectAffix(int Index, string Text)
{
	SelectedAffixIndex = Index;
	SelectedAffix = Text;
}

function SetCaption(string InCaption)
{
	Caption = InCaption;
}

function SetData(array<string> Choices)
{
	local int i;
	Candidates.Clear();
	for (i=0;i<Choices.Length;i++)
		Candidates.MakeList(Choices[i]);
}

static function CAffixChoice PopupAffixChoice(CMultiInterface Parent, coerce string Title, array<string> Choices)
{
	local CAffixChoice Choice;
	Choice = CAffixChoice(Parent.Controller.HudInterface.AddInterface("SephirothUI.CAffixChoice", true));
	if (Choice != None) {
		Choice.ShowInterface();
		Choice.SetCaption(Title);
		Choice.SetData(Choices);
	}
	return Choice;
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local string Selected;

	if (NotifyId == BN_Apply) {
		Selected = SelectedAffix;
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
		if (Selected != "")
			OnSelectChoice(SelectedAffixIndex, Selected);
	}
	else if (NotifyId == BN_Cancel) {
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
	}
}

function OnPreRender(Canvas C)
{
	local float X, Y, Width, Height;

	Components[1].bDisabled = SelectedAffix == "";
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
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ Caption, 1, WinX, WinY, WinX + WinWidth, WinY + CaptionHeight);
	if (SelectedAffix != "")
		C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ Localize("Information","SelectedItem","Sephiroth") $ ": " $ MakeColorCodeEx(255,255,0) $ SelectedAffix, 1, WinX, WinY+WinHeight-ActionHeight-StatusHeight, WinX+WinWidth, WinY+WinHeight-ActionHeight);
	else
		C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ Localize("Information","SelectedItem","Sephiroth") $ ": ", 1, WinX, WinY+WinHeight-ActionHeight-StatusHeight, WinX+WinWidth, WinY+WinHeight-ActionHeight);
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
     Components(1)=(Id=1,Caption="Apply",Type=RES_PushButton,XL=67.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=163.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Caption="Cancel",Type=RES_PushButton,XL=67.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=95.000000,OffsetYL=163.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI",Path="Common.MsgBoxButtonNormal",Style=STY_Alpha)
     TextureResources(1)=(Package="UI",Path="Common.MsgBoxButtonOver",Style=STY_Alpha)
     WinWidth=300.000000
     WinHeight=200.000000
}
