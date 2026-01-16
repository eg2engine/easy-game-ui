class CReadyToLobby extends CMultiInterface
	config(SephirothUI);

#exec TEXTURE IMPORT NAME=Background FILE=Textures/Black90Alpha.tga MIPS=Off

var float fTimer;
var config		float	fDelayTime;
var int		nAlpha;

function OnInit()
{
	fTimer = Level.timeSeconds;
}

simulated event Destroyed()
{
	//Log("Destroyed()"@class);
}

function OnPreRender(Canvas C)
{
	local float tAlpha;
	tAlpha = (Level.timeSeconds - fTimer) * 255.0f / fDelayTime;
	nAlpha = min(max(0, tAlpha), 255);
	C.SetDrawColor(255, 255, 255, nAlpha);
	C.DrawTileAlpha(Texture'Background', 0, 0, C.ClipX, C.ClipY);

	C.SetDrawColor(255, 255, 255, 255);
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("Modals", "ReadyToLobby", "Sephiroth"), Components[0].X, Components[0].Y, WinWidth, WinHeight);
}


function Layout(Canvas C)
{
	MoveComponent(Components[0], true, (C.ClipX - WinWidth) / 2, (C.ClipY - WinHeight) / 2, WinWidth, WinHeight);
	Super.Layout(C);
}

defaultproperties
{
     fDelayTime=7.000000
     Components(0)=(XL=512.000000,YL=128.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     WinWidth=512.000000
     WinHeight=128.000000
}
