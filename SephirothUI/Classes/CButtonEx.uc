class CButtonEx extends Interface.CButton;

var string Text;

function SetTexture(Texture Normal, Texture Watched, Texture Focused, Texture Disabled) 
{
	if (Normal!=none)
		Images[0] = Normal;
	if (Watched!=none)
		Images[1] = Watched;
	if (Focused!=none)
		Images[2] =Focused;
	if (Disabled!=none)
		Images[3] = Disabled;
}

function OnPostRender(HUD H, Canvas C)
{
	super.OnPostRender(H,C);
	if(Text != ""){
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.SetDrawColor(255,241,113);
		C.DrawKoreanText(Text,WinX-9,WinY,WinWidth,WinHeight);
	}
}

defaultproperties
{
}
