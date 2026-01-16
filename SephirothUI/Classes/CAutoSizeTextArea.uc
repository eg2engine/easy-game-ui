class CAutoSizeTextArea extends CTextArea;

//#exec TEXTURE IMPORT NAME=TextBackground FILE=Textures/TooltipBackground.tga
#exec TEXTURE IMPORT NAME=TextBackground FILE=Textures/Black90Alpha.tga

var float ScreenX, ScreenY;
var float ScreenWidth, ScreenHeight;
var float MaxXL;
var color TextColor;
var Int nMarginX, nMarginY;

function SetPosition(float Sx,float Sy)
{
	ScreenX = Sx;
	ScreenY = Sy;
}

function CopyTexts(array<string> InTexts)
{
	local int i;
	local float XL,YL;

	Super.CopyTexts(InTexts);
	for (i=0;i<Texts.Length;i++) {
		class'CNativeInterface'.static.TextSize(Texts[i],XL,YL);
		MaxXL = max(MaxXL, XL);
	}
	ScreenWidth = MaxXL;
	ScreenHeight = 14 * Texts.Length;
}

function ClearTexts()
{
	MaxXL = 0;
	PushText("");
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;

	if (MaxXL > 0) {
		ScreenX = FClamp(Controller.MouseX-MaxXL/2,0,C.ClipX-ScreenWidth);
		ScreenY = FClamp(Controller.MouseY-ScreenHeight,0,C.ClipY-ScreenHeight);

		C.SetRenderStyleAlpha();
//		C.SetPos(ScreenX,ScreenY);
		C.SetPos(ScreenX - nMarginX, ScreenY - nMarginY);
//		C.DrawTile(Texture'TextBackground', ScreenWidth, ScreenHeight, 0,0,16,16);
		C.DrawTile(Texture'TextBackground', ScreenWidth + nMarginX * 2, ScreenHeight + nMarginY * 2, 0, 0, 4, 4);

//		C.SetDrawColor(114,121,196);
		C.SetDrawColor(114, 113, 113);
		C.SetPos(ScreenX - (nMarginX + 1),ScreenY - (nMarginY + 1));
		DrawBox(C, ScreenWidth + (nMarginX + 1) * 2,ScreenHeight + (nMarginY + 1) * 2, 1);

		C.Style = ERenderStyle.STY_Normal;
		C.KTextFormat = ETextAlign.TA_TopLeft;
		C.SetDrawColor(213,235,251);

		for (i=0;i<Texts.Length;i++)
			C.DrawKoreanText(Texts[i],ScreenX,ScreenY+i*14,ScreenWidth,14);
	}
}

defaultproperties
{
     nMarginX=2
     nMarginY=2
     PageWidth=200.000000
}
