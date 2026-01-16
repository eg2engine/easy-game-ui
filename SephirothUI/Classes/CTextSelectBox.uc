class CTextSelectBox extends CMultiInterface;

var string Caption;
var float CaptionHeight;
var float StatusHeight;
var float ActionHeight;
var float SelectAreaMarginWidth;
var CTextList Candidates;

const BN_Apply = 1;
const BN_Cancel = 2;

var string SelectedText;
var int SelectedTextIndex;
//var array<Color> EdgeColors;

delegate OnSelectChoice(int ChoiceIndex, string Choice);

function OnInit()
{
	Components[1].NotifyId = BN_Apply;
	Components[2].NotifyId = BN_Cancel;
	SetComponentTextureId(Components[1],0,-1,1,2);
	SetComponentTextureId(Components[2],0,-1,1,2);
	
	Candidates = CTextList(AddInterface("Interface.CTextList"));
	if (Candidates != None) {
		Candidates.ShowInterface();
		Candidates.bReadOnly = False;
		Candidates.bWrapText = False;
		Candidates.TextAlign = 0;
		Candidates.ItemHeight = 16;
		Candidates.SetSize(WinWidth - 2 * SelectAreaMarginWidth, WinHeight - CaptionHeight - ActionHeight - StatusHeight);
		Candidates.OnDrawText = InternalDrawItemText;
		Candidates.OnDrawSelectedBK = InternalDrawItemTextHighlight;
		Candidates.OnSelectText = InternalSelectText;
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
	MoveComponentId(1);//,true,WinX+WinWidth/2-Components[1].XL-20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[1].YL)/2);
	MoveComponentId(2);//,true,WinX+WinWidth/2+20,WinY+WinHeight-ActionHeight+(ActionHeight - Components[2].YL)/2);
	if (Candidates != None) {
		Candidates.SetPos(WinX + SelectAreaMarginWidth, WinY + CaptionHeight);
		Candidates.SetSize(WinWidth - 2 * SelectAreaMarginWidth, WinHeight - CaptionHeight - ActionHeight - StatusHeight);
	}
	Super.Layout(C);
}

function InternalDrawItemText(Canvas C, int i, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;

	if (bSelected) {
		if (Controller.bLButtonDown) {
			X += 1.0f;
			Y += 1.0f;
		}
		ColorCode = MakeColorCodeEx(255,242,0);
	}
	else
		ColorCode = MakeColorCodeEx(255,255,255);
	C.DrawTextJustified(ColorCode $ Text, 0, X, Y, X+W, Y+H);
}

function InternalDrawItemTextHighlight(Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.SetPos(X, Y);
	C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', W, H);
}

function InternalSelectText(int Index, string Text)
{
	SelectedTextIndex = Index;
	SelectedText = Text;
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

static function CTextSelectBox PopupTextSelectBox(CMultiInterface Parent, coerce string Title, array<string> Choices, bool bNoCancel)
{
	local CTextSelectBox Choice;
	Choice = CTextSelectBox(Parent.Controller.HudInterface.AddInterface("SephirothUI.CTextSelectBox", true));
	if (Choice != None) {
		Choice.ShowInterface();
		Choice.SetCaption(Title);
		Choice.SetData(Choices);
		if (bNoCancel)
			Choice.Components[2].bDisabled = true;
	}
	return Choice;
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local string Selected;

	if (NotifyId == BN_Apply) {
		Selected = SelectedText;
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
		if (Selected != "")
			OnSelectChoice(SelectedTextIndex, Selected);
	}
	else if (NotifyId == BN_Cancel) {
		HideInterface();
		CMultiInterface(Parent).RemoveInterface(Self);
	}
}

function OnPreRender(Canvas C)
{
	Components[1].bDisabled = SelectedText == "";
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;

	X = Components[0].X;
	Y = Components[0].Y;

	C.DrawTextJustified(MakeColorCodeEx(229,231,174) $ Caption, 1, X + 18, Y + 16,  X + 18 + 210, Y + 16 + 14);
	if (SelectedText != "")
		C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ Localize("Information","SelectedItem","Sephiroth") $ ": " $ MakeColorCodeEx(255,242,0) $ SelectedText, 1, WinX, WinY+WinHeight-ActionHeight-StatusHeight - 14, WinX+WinWidth, WinY+WinHeight-ActionHeight - 14);
	else
		C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ Localize("Information","SelectedItem","Sephiroth") $ ": ", 1, WinX, WinY+WinHeight-ActionHeight-StatusHeight - 14, WinX+WinWidth, WinY+WinHeight-ActionHeight - 14);
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

function Close()
{
	HideInterface();
	CMultiInterface(Parent).RemoveInterface(Self);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Components[2].bDisabled && Key == IK_Escape)
		return true;
	return false;
}

defaultproperties
{
     CaptionHeight=45.000000
     StatusHeight=20.000000
     ActionHeight=30.000000
     SelectAreaMarginWidth=18.000000
     Components(0)=(ResId=3,Type=RES_Image,XL=246.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="Apply",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Caption="Cancel",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=128.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Escape)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_pop_s",Style=STY_Alpha)
     WinWidth=246.000000
     WinHeight=200.000000
}
