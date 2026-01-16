class CSoundInterface extends CInterface;

var float	MaxVolume,
			MonsterVolume,
			ItemVolume,
			CharacterVolume;
var int		MaxRadius,
			MonsterRadius,
			ItemRadius,
			CharacterRadius;

var float	ScreenX, ScreenY,
			GraphWidth, GraphHeight, GraphSpace;

var bool	UseMonster,
			UseItem,
			UseCharacter;

function Layout(Canvas C)
{
	ScreenX = C.ClipX - GraphWidth - 20;
	ScreenY = 200;
}

function OnPreRender(Canvas C)
{
	MonsterVolume = float(PlayerOwner.ConsoleCommand("GETMONSTERSOUNDV"));
	MonsterRadius = int(PlayerOwner.ConsoleCommand("GETMONSTERSOUNDR"));
	ItemVolume = float(PlayerOwner.ConsoleCommand("GETITEMSOUNDV"));
	ItemRadius = int(PlayerOwner.ConsoleCommand("GETITEMSOUNDR"));
	CharacterVolume = float(PlayerOwner.ConsoleCommand("GETCHARACTERSOUNDV"));
	CharacterRadius = int(PlayerOwner.ConsoleCommand("GETCHARACTERSOUNDR"));
	UseMonster = bool(PlayerOwner.ConsoleCommand("GETUSEMONSTERSOUND"));
	UseItem = bool(PlayerOwner.ConsoleCommand("GETUSEITEMSOUND"));
	UseCharacter = bool(PlayerOwner.ConsoleCommand("GETUSECHARACTERSOUND"));
}

function OnPostRender(HUD H, Canvas C)
{
	local color OldColor;
	local int i;
	local string FontName;
	
	OldColor = Controller.BackgroundColor.Color;
	
	for (i=0;i<6;i++) {
		class'CNativeInterface'.static.DrawRect(ScreenX, ScreenY+i*(GraphHeight+GraphSpace), ScreenX+GraphWidth, ScreenY+i*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	}
	FontName = "Font" $ GetLanguage() $ "." $ GetLanguageFontFace();
	C.Font = class'CInterface'.static.GetLocalizedFont(PlayerOwner);
	C.DrawColor = Controller.InterfaceSkin;
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Monster Volume " $ MonsterVolume,				0, ScreenX+1, ScreenY+0*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+0*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Monster Volume " $ MonsterVolume,		0, ScreenX, ScreenY+0*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+0*(GraphHeight+GraphSpace));
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Monster Radius " $ MonsterRadius,				0, ScreenX+1, ScreenY+1*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+1*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Monster Radius " $ MonsterRadius,		0, ScreenX, ScreenY+1*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+1*(GraphHeight+GraphSpace));
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Item Volume " $ ItemVolume,					0, ScreenX+1, ScreenY+2*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+2*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Item Volume " $ ItemVolume,				0, ScreenX, ScreenY+2*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+2*(GraphHeight+GraphSpace));
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Item Radius " $ ItemRadius,					0, ScreenX+1, ScreenY+3*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+3*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Item Radius " $ ItemRadius,				0, ScreenX, ScreenY+3*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+3*(GraphHeight+GraphSpace));
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Character Volume " $ CharacterVolume,			0, ScreenX+1, ScreenY+4*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+4*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Character Volume " $ CharacterVolume,	0, ScreenX, ScreenY+4*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+4*(GraphHeight+GraphSpace));
	C.DrawTextJustified(MakeColorCodeEx(0,0,0) $ "Character Radius " $ CharacterRadius,			0, ScreenX+1, ScreenY+5*(GraphHeight+GraphSpace)-GraphHeight+1, ScreenX+GraphWidth+1, ScreenY+5*(GraphHeight+GraphSpace)+1);
	C.DrawTextJustified(MakeColorCodeEx(255,255,255) $ "Character Radius " $ CharacterRadius,	0, ScreenX, ScreenY+5*(GraphHeight+GraphSpace)-GraphHeight, ScreenX+GraphWidth, ScreenY+5*(GraphHeight+GraphSpace));

	Controller.BackgroundColor.Color = class'Canvas'.static.MakeColor(255,0,0);
	C.SetPos(ScreenX, ScreenY+0*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * MonsterVolume - 1, GraphHeight - 1,0,0,0,0);
	C.SetPos(ScreenX, ScreenY+1*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * MonsterRadius / MaxRadius - 1, GraphHeight - 1,0,0,0,0);

	Controller.BackgroundColor.Color = class'Canvas'.static.MakeColor(0,255,0);
	C.SetPos(ScreenX, ScreenY+2*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * ItemVolume - 1, GraphHeight - 1,0,0,0,0);
	C.SetPos(ScreenX, ScreenY+3*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * ItemRadius / MaxRadius - 1, GraphHeight - 1,0,0,0,0);

	Controller.BackgroundColor.Color = class'Canvas'.static.MakeColor(0,0,255);
	C.SetPos(ScreenX, ScreenY+4*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * CharacterVolume - 1, GraphHeight - 1,0,0,0,0);
	C.SetPos(ScreenX, ScreenY+5*(GraphHeight+GraphSpace));
	C.DrawTile(Controller.BackgroundBlend, GraphWidth * CharacterRadius / MaxRadius - 1, GraphHeight - 1,0,0,0,0);

	Controller.BackgroundColor.Color = OldColor;

	class'CNativeInterface'.static.DrawRect(ScreenX-GraphSpace-GraphHeight,ScreenY+0*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+0*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	class'CNativeInterface'.static.DrawRect(ScreenX-GraphSpace-GraphHeight,ScreenY+2*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+2*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	class'CNativeInterface'.static.DrawRect(ScreenX-GraphSpace-GraphHeight,ScreenY+4*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+4*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	C.SetPos(ScreenX-GraphSpace-GraphHeight, ScreenY+0*(GraphHeight+GraphSpace));
	C.DrawTile(Texture'Engine.WhiteSquareTexture',GraphHeight-1,GraphHeight-1,0,0,0,0);
	C.SetPos(ScreenX-GraphSpace-GraphHeight, ScreenY+2*(GraphHeight+GraphSpace));
	C.DrawTile(Texture'Engine.WhiteSquareTexture',GraphHeight-1,GraphHeight-1,0,0,0,0);
	C.SetPos(ScreenX-GraphSpace-GraphHeight, ScreenY+4*(GraphHeight+GraphSpace));
	C.DrawTile(Texture'Engine.WhiteSquareTexture',GraphHeight-1,GraphHeight-1,0,0,0,0);

	if (UseMonster) {
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace-GraphHeight,ScreenY+0*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+0*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace,ScreenY+0*(GraphHeight+GraphSpace),ScreenX-GraphSpace-GraphHeight,ScreenY+0*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	}
	if (UseItem) {
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace-GraphHeight,ScreenY+2*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+2*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace,ScreenY+2*(GraphHeight+GraphSpace),ScreenX-GraphSpace-GraphHeight,ScreenY+2*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	}
	if (UseCharacter) {
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace-GraphHeight,ScreenY+4*(GraphHeight+GraphSpace),ScreenX-GraphSpace,ScreenY+4*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
		class'CNativeInterface'.static.DrawLine(ScreenX-GraphSpace,ScreenY+4*(GraphHeight+GraphSpace),ScreenX-GraphSpace-GraphHeight,ScreenY+4*(GraphHeight+GraphSpace)+GraphHeight,class'Canvas'.static.MakeColor(128,128,128));
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local int i;
	local float ClickOffset;

	if (Key == IK_LeftMouse && Action == IST_Press) {
		for (i=0;i<6;i++) {
			if (IsCursorInsideAt(ScreenX, ScreenY+i*(GraphHeight+GraphSpace), GraphWidth, GraphHeight)) {
				ClickOffset = Controller.MouseX - ScreenX;
				AdjustValue(i, ClickOffset/GraphWidth);
				return true;
			}
		}
		if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+0*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
			PlayerOwner.ConsoleCommand("USEMONSTERSOUND");
			return true;
		}
		if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+2*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
			PlayerOwner.ConsoleCommand("USEITEMSOUND");
			return true;
		}
		if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+4*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
			PlayerOwner.ConsoleCommand("USECHARACTERSOUND");
			return true;
		}
	}
	return false;
}

function AdjustValue(int Kind, float Ratio)
{
	local float vFloat;
	local int vInt;

	//Log(Self @ Kind @ Ratio);

	switch (Kind) {
	case 0: // monster volume
		if (!UseMonster)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		PlayerOwner.ConsoleCommand("MONSTERSOUNDV" @ vFloat);
		break;
	case 1: // monster radius
		if (!UseMonster)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		vInt = vFloat * MaxRadius;
		PlayerOwner.ConsoleCommand("MONSTERSOUNDR" @ vInt);
		break;
	case 2: // item volume
		if (!UseItem)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		PlayerOwner.ConsoleCommand("ITEMSOUNDV" @ vFloat);
		break;
	case 3: // item radius
		if (!UseItem)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		vInt = vFloat * MaxRadius;
		PlayerOwner.ConsoleCommand("ITEMSOUNDR" @ vInt);
		break;
	case 4: // character volume
		if (!UseCharacter)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		PlayerOwner.ConsoleCommand("CHARACTERSOUNDV" @ vFloat);
		break;
	case 5: // character radius
		if (!UseCharacter)
			return;
		vFloat = Ratio;
		if (Ratio < 0.05)
			vFloat = 0;
		else if (Ratio > 0.95)
			vFloat = 1.0;
		vInt = vFloat * MaxRadius;
		PlayerOwner.ConsoleCommand("CHARACTERSOUNDR" @ vInt);
		break;
	}
}

function bool PointCheck()
{
	local int i;
	for (i=0;i<6;i++) {
		if (IsCursorInsideAt(ScreenX, ScreenY+i*(GraphHeight+GraphSpace), GraphWidth, GraphHeight)) {
			return true;
		}
	}
	if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+0*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
		return true;
	}
	if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+2*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
		return true;
	}
	if (IsCursorInsideAt(ScreenX-GraphSpace-GraphHeight,ScreenY+4*(GraphHeight+GraphSpace),GraphHeight,GraphHeight)) {
		return true;
	}
	return false;
}

defaultproperties
{
     MaxVolume=1.000000
     MaxRadius=2048
     GraphWidth=200.000000
     GraphHeight=16.000000
     GraphSpace=20.000000
}
