class CDevInterface extends CTextScroll;

function OnInit()
{
	Super.OnInit();
	TextList.OnDrawBackground = InternalDrawBackground;
	TextList.TextColor=class'Canvas'.static.MakeColor(30,30,50);
	TextList.SelectedTextColor=class'Canvas'.static.MakeColor(255,255,255);
	TextList.SelectedBKColor=class'Canvas'.static.MakeColor(30,30,100);
	SetPos(0,0);
	SetSize(1024,200);
}

function Layout(Canvas C)
{
	SetSize(C.ClipX, 200);
	Super.Layout(C);
}

function InternalDrawBackground(Canvas C)
{
	local float Width;

	Width = WinWidth-15;
	C.SetDrawColor(220,220,220);
	C.SetPos(WinX, WinY);
	C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', Width, WinHeight);
}

defaultproperties
{
}
