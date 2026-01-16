class CMapInterface extends CMultiInterface
	config(MapHack);

const IDS_AddPortal = 1;

var int GridSpaceX, GridSpaceY;
var int StartMapX, StartMapY, MapHSize, MapVSize, MapSize;
var int ScreenX, ScreenY;
//var int ClickX, ClickY;
var vector ClickPos;
var config int ZoomLevel;
var int SelectedPortal;

struct Portal
{
	var() string Zone;
	var() int X;
	var() int Y;
	var() bool bVisible;
};
var config array<Portal> Portals;

// keios 
const ConstMapStartX = 32;
const ConstMapStartY = 38;
const ConstMapSizeX = 10;  //add neive : 동부 지역 9->10 로 수정. 맵 폭이 넓어졌기 때문
const ConstMapSizeY = 20; //add neive : 18->20 으로 수정. 맵 높이가 높아졌기 때문

var array<string> AvailMapPos;

function OnFlush()
{
	SaveConfig();
}

function OnInit()
{
	local int MapX, MapY;

	ZoomLevel = Clamp(ZoomLevel, 0, 3);
	MapX = PlayerOwner.Pawn.Location.X / MapSize + 40;
	MapY = PlayerOwner.Pawn.Location.Y / MapSize + 40;
	SetupZoom(ZoomLevel, MapX, MapY);
}

function Layout(Canvas Canvas)
{
	ScreenX = Canvas.ClipX - MapHSize * GridSpaceX - 2;
	ScreenY = 20;

	Components[0].X = ScreenX;
	Components[0].Y = ScreenY;
	Components[0].YL = GridSpaceY * MapVSize;
	Components[0].XL = GridSpaceX * MapHSize;

	Super.Layout(Canvas);
}

function OnPostRender(HUD H, Canvas Canvas)
{
	local int x, y, i;
	local string CoordStr;
	local Font OldFont;
	local vector Pos;
	local Material MapMat;

	OldFont = Canvas.Font;
	Canvas.Font = Font'Engine.DefaultFont';

	Canvas.SetDrawColor(128,128,128);
	Canvas.SetPos(ScreenX, ScreenY - 14);
	Canvas.DrawText(string(PlayerOwner.Pawn.Location.X)$":"$PlayerOwner.Pawn.Location.Y$":"$PlayerOwner.Pawn.Location.Z$" ZoomLevel="$ZoomLevel);

	Canvas.SetDrawColor(0,128,0);
	for (x = 0;x <= MapHSize;x++) {
		Canvas.SetPos(ScreenX + GridSpaceX * x, ScreenY);
		Canvas.DrawLine(1, GridSpaceY * MapVSize);
	}
	for (y = 0;y <= MapVSize;y++) {
		Canvas.SetPos(ScreenX, ScreenY + GridSpaceY * y);
		Canvas.DrawLine(3, GridSpaceX * MapHSize);
	}

	for (x = 0;x < MapHSize;x++) 
	{
		for (y = 0;y < MapVSize;y++) 
		{
			if (CheckMap(x+StartMapX, y+StartMapY)) {
				if (MapLoaded(x+StartMapX, y+StartMapY))
					Canvas.SetDrawColor(200,200,100);
				else
					Canvas.SetDrawColor(128,128,128);
				Canvas.SetPos(ScreenX+GridSpaceX*x+1, ScreenY+GridSpaceY*y+1);
				MapMat = Material(DynamicLoadObject("Minimap.minimap"$x+StartMapX$"-"$y+StartMapY, class'Material'));
				if (MapMat != None)
					Canvas.DrawTile(MapMat,GridSpaceX-1,GridSpaceY-1,0,0,512,512);
				else
					Canvas.DrawTileStretched(Controller.BackgroundBlend,GridSpaceX-2,GridSpaceY-2);
				Canvas.SetDrawColor(150,150,150);
			}
			else
				Canvas.SetDrawColor(128,128,128);
			CoordStr = string(StartMapX + x)$"-"$(StartMapY + y);
			Canvas.SetPos(ScreenX+GridSpaceX*x, ScreenY+GridSpaceY*y);
			Canvas.DrawText(CoordStr);
		}
	}

	if (ClickPos.X != -1) {
		Pos.X = ScreenX + (ClickPos.X - MapSize * (StartMapX - 40)) * GridSpaceX / float(MapSize);
		Pos.Y = ScreenY + (ClickPos.Y - MapSize * (StartMapY - 40)) * GridSpaceY / float(MapSize);
		if (IsPosInsideAt(Pos.X, Pos.Y, ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
			class'CNativeInterface'.static.DrawPoint(Pos.X, Pos.Y, 2, class'Canvas'.static.MakeColor(0,255,0));
		}
	}

	Canvas.Font = OldFont;
	for (i=0;i<Portals.Length;i++) {
		if (!Portals[i].bVisible)
			continue;
		Pos.X = ScreenX + (Portals[i].X - MapSize * (StartMapX - 40)) * GridSpaceX / float(MapSize);
		Pos.Y = ScreenY + (Portals[i].Y - MapSize * (StartMapY - 40)) * GridSpaceY / float(MapSize);
		if (IsPosInsideAt(Pos.X, Pos.Y, ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
			class'CNativeInterface'.static.DrawPoint(Pos.X, Pos.Y, 2, class'Canvas'.static.MakeColor(0,200,0));
			Canvas.SetDrawColor(0,150,0);
			//Canvas.DrawScreenText(Portals[i].Zone, Pos.X, Pos.Y, 5, true);
			Canvas.DrawScreenText(Portals[i].Zone, Pos.X, Pos.Y, DP_LowerMiddle);
		}
	}

	Pos = PlayerOwner.Pawn.Location;
	Pos.X -= MapSize * (StartMapX - 40);
	Pos.Y -= MapSize * (StartMapY - 40);
	Pos.X = ScreenX + Pos.X * GridSpaceX / float(MapSize);
	Pos.Y = ScreenY + Pos.Y * GridSpaceY / float(MapSize);

	if (IsPosInsideAt(Pos.X, Pos.Y, ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
		class'CNativeInterface'.static.DrawPoint(Pos.X, Pos.Y, 2, class'Canvas'.static.MakeColor(255,255,0));
		class'CNativeInterface'.static.DrawCircle(Pos.X, Pos.Y, (30000*GridSpaceX)/65024.f, (30000*GridSpaceY)/65024.f, class'Canvas'.static.MakeColor(200,200,0), 32);
		class'CNativeInterface'.static.DrawArrow(Pos.X, Pos.Y, PlayerOwner.Rotation.Yaw+32768,20,5,8192,class'Canvas'.static.MakeColor(255,255,255));
		class'CNativeInterface'.static.DrawArrow(Pos.X, Pos.Y, PlayerOwner.Pawn.Rotation.Yaw+32768, 20, 5, 8192, class'Canvas'.static.MakeColor(255,255,0));
	}
}

function bool CheckMap(int x, int y)
{
	// keios - array를 이용하여 체크
	local int mx, my;
	local string c;

	mx = x - ConstMapStartX;
	my = y - ConstMapStartY;
	
	if(mx < 0 || mx >= ConstMapSizeX)
		return false;
	if(my < 0 || my >= ConstMapSizeY)
		return false;

	c = Mid( AvailMapPos[my], mx, 1 );	//Mid 뭥미?

	//add neive : 퀘스트 던전
	if(my == 57)
		return true;
	//---------------------

	if( c == "1" )
		return true;

	return false;
}

function bool MapLoaded(int x, int y)
{
	return bool(ConsoleCommand("CHECKMAPLOADED " $ x $ " " $ y));
}

function SetupZoom(int Level,optional int x,optional int y)
{
	switch (Level) {
	case 1:
		StartMapX = X-2;
		StartMapY = Y-2;
		MapHSize = 5;
		MapVSize = 5;
		GridSpaceX = 70;
		GridSpaceY = 70;
		break;
	case 2:
		StartMapX = X-1;
		StartMapY = Y-1;
		MapHSize = 3;
		MapVSize = 3;
		GridSpaceX = 120;
		GridSpaceY = 120;
		break;
	case 3:
		StartMapX = X;
		StartMapY = Y;
		MapHSize = 1;
		MapVSize = 1;
		GridSpaceX = 350;
		GridSpaceY = 350;
		break;
	case 4:
		StartMapX = X;
		StartMapY = Y;
		MapHSize = 1;
		MapVSize = 1;
		GridSpaceX = 512;
		GridSpaceY = 512;
		break;
	default:
		StartMapX = Default.StartMapX;
		StartMapY = Default.StartMapY;
		MapHSize = Default.MapHSize;
		MapVSize = Default.MapVSize;
		GridSpaceX = Default.GridSpaceX;
		GridSpaceY = Default.GridSpaceY;
		break;
	}
}

function ZoomIn(int X, int Y)
{
	if (!CheckMap(X, Y))
		return;
	ZoomLevel = Clamp(ZoomLevel+1,0,4);
	SetupZoom(ZoomLevel,X,Y);
	SaveConfig();
}

function ZoomOut(int X, int Y)
{
	ZoomLevel = Clamp(ZoomLevel-1,0,4);
	SetupZoom(ZoomLevel,X,Y);
	SaveConfig();
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float RealX, RealY;
	local int MapX, MapY, i;
	local CTextMenu TextMenu;
	local string MenuString;

	if (Key == IK_LeftMouse && Action == IST_Press) {
		if (IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize))
			return true;
	}
	else if (Key == IK_LeftMouse && Action == IST_Release) {
		if (IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
			MapX = StartMapX + (Controller.MouseX - ScreenX) / GridSpaceX;
			MapY = StartMapY + (Controller.MouseY - ScreenY) / GridSpaceY;
			if (CheckMap(MapX, MapY)) {
				RealX = (Controller.MouseX-ScreenX)*MapSize/float(GridSpaceX) + MapSize*(StartMapX-40);
				RealY = (Controller.MouseY-ScreenY)*MapSize/float(GridSpaceY) + MapSize*(StartMapY-40);

				ClickPos.X = RealX;
				ClickPos.Y = RealY;

				TextMenu = PopupContextMenu(
					"Close MapTool|Add Mark|MoveAbs to Click Point|Zoom In|Zoom Out|Scroll Up|Scroll Down|Scroll Left|Scroll Right", 
					Controller.MouseX+2,Controller.MouseY+2);
				TextMenu.OnTextMenu = LeftClickOnTextMenu;
			}
			else
				ClickPos.X = -1;
		}
		else
			ClickPos.X = -1;
		return true;
	}
	if (Key == IK_MiddleMouse && Action == IST_Press) {
		if (IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize))
			return true;
	}
	else if (Key == IK_MiddleMouse && Action == IST_Release) {
		if (IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
			MapX = StartMapX + (Controller.MouseX - ScreenX) / GridSpaceX;
			MapY = StartMapY + (Controller.MouseY - ScreenY) / GridSpaceY;
			if (CheckMap(MapX, MapY)) {
				RealX = (Controller.MouseX-ScreenX)*MapSize/float(GridSpaceX) + MapSize*(StartMapX-40);
				RealY = (Controller.MouseY-ScreenY)*MapSize/float(GridSpaceY) + MapSize*(StartMapY-40);

				ClickPos.X = RealX;
				ClickPos.Y = RealY;

				TextMenu = PopupContextMenu(
					Localize("Zones","LadianesTown","SephirothUI")$"|"$
					Localize("Zones","LadianesFight","SephirothUI")$"|"$
					Localize("Zones","MelvilGate","SephirothUI")$"|"$
					Localize("Zones","SwampArea","SephirothUI")$"|"$
					Localize("Zones","WasteLand","SephirothUI")$"|"$
					Localize("Zones","EastWindmill","SephirothUI")$"|"$
					Localize("Zones","SealedLand","SephirothUI")$"|"$
					Localize("Zones","BlueCliffFight","SephirothUI")$"|"$
					Localize("Zones","TradePort","SephirothUI")$"|"$
					Localize("Zones","WaterTown","SephirothUI")$"|"$
					Localize("Zones","VerosTown","SephirothUI")$"|"$
					Localize("Zones","FloatingTown","SephirothUI")$"|"$
					Localize("Zones","Laziel","SephirothUI")$"|"$
					Localize("Zones","WarEntry","SephirothUI")$"|"$
					Localize("Zones","WarCastle","SephirothUI")$"|"$
					Localize("Zones","WarCentre","SephirothUI")$"|"$
					Localize("Zones","WarHwayeom","SephirothUI")$"|"$
					Localize("Zones","WarHaeiyl","SephirothUI")$"|"$
					Localize("Zones","WarPyungbum","SephirothUI")$"|"$
					Localize("Zones","WarJinmoo","SephirothUI")$"|"$
					Localize("Zones","FrozenLand","SephirothUI")$"|"$
					Localize("Zones","Rampao12","SephirothUI")$"|"$
					Localize("Zones","Rampao3","SephirothUI")$"|"$
					Localize("Zones","Delphiroth1","SephirothUI")$"|"$
					Localize("Zones","Delphiroth2","SephirothUI")$"|"$
					Localize("Zones","Delphiroth3","SephirothUI")$"|"$
					Localize("Zones","PetLand","SephirothUI")$"|"$
					Localize("Zones","GhostTown","SephirothUI")$"|"$
					Localize("Zones","QuestMap1","SephirothUI")$"|"$
					Localize("Zones","Cave1","SephirothUI")$"|"$
					Localize("Zones","DelphistMap","SephirothUI")$"|"$
					Localize("Zones","LostCave","SephirothUI"),
					Controller.MouseX+2,Controller.MouseY+2);
				TextMenu.OnTextMenu = MiddleClickOnTextMenu;
			}
			else
				ClickPos.X = -1;
		}
		else
			ClickPos.X = -1;
		return true;
	}
	else if (Key == IK_RightMouse && Action == IST_Press) {
		if (IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize))
			return true;
	}
	else if (Key == IK_RightMouse && Action == IST_Release) {
		if (Portals.Length > 0 && IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize)) {
			MenuString = Portals[0].Zone;
			for (i=1;i<Portals.Length;i++)
				MenuString = MenuString $ "|" $ Portals[i].Zone;
			TextMenu = PopupContextMenu(MenuString, Controller.MouseX+2,Controller.MouseY+2, true);
			TextMenu.OnTextMenu = RightClickOnTextMenu;
		}
		return true;
	}
	return false;
}

function LeftClickOnTextMenu(int Index, string Text)
{
	local int MapX, MapY;
	if (Index == 0) {
		SephirothInterface(Parent).MapTool();
	}
	else if (Index == 1) {
		class'CEditBox'.static.EditBox(Self,"AddPortal",Localize("Modals","TitleAddPortal","Sephiroth"),IDS_AddPortal,24);
	}
	else if (Index == 2) {
		SephirothPlayer(PlayerOwner).Net.NotiTell(1,"\\\\MoveAbs"@ClickPos.X@ClickPos.Y);
	}
	else if (Index == 3) {
		MapX = ClickPos.X / MapSize + 40;
		MapY = ClickPos.Y / MapSize + 40;
		ZoomIn(MapX, MapY);
	}
	else if (Index == 4) {
		MapX = ClickPos.X / MapSize + 40;
		MapY = ClickPos.Y / MapSize + 40;
		ZoomOut(MapX, MapY);
	}
	else if (Index == 5) { // scroll up
		StartMapY--;
	}
	else if (Index == 6) { // scroll down
		StartMapY++;
	}
	else if (Index == 7) { // scroll left
		StartMapX--;
	}
	else if (Index == 8) { // scroll right
		StartMapX++;
	}
}

function MiddleClickOnTextMenu(int Index, string Text)
{
	local int MapX, MapY;

	if (Text == Localize("Zones","LadianesTown","SephirothUI")) { MapX = 35; MapY = 52; }
	else if (Text == Localize("Zones","LadianesFight","SephirothUI")) { MapX = 35; MapY = 53; }
	else if (Text == Localize("Zones","MelvilGate","SephirothUI")) { MapX = 34; MapY = 52; }
	else if (Text == Localize("Zones","SwampArea","SephirothUI")) { MapX = 36; MapY = 52; }
	else if (Text == Localize("Zones","WasteLand","SephirothUI")) { MapX = 35; MapY = 54; }
	else if (Text == Localize("Zones","EastWindmill","SephirothUI")) { MapX = 34; MapY = 54; }
	else if (Text == Localize("Zones","SealedLand","SephirothUI")) { MapX = 34; MapY = 55; }
	else if (Text == Localize("Zones","BlueCliffFight","SephirothUI")) { MapX = 35; MapY = 55; }
	else if (Text == Localize("Zones","TradePort","SephirothUI")) { MapX = 36; MapY = 55; }
	else if (Text == Localize("Zones","WaterTown","SephirothUI")) { MapX = 37; MapY = 54; }
	else if (Text == Localize("Zones","VerosTown","SephirothUI")) { MapX = 33; MapY = 40; }
	else if (Text == Localize("Zones","FloatingTown","SephirothUI")) { MapX = 34; MapY = 39; }
	else if (Text == Localize("Zones","Laziel","SephirothUI")) { MapX = 32; MapY = 39; }
	else if (Text == Localize("Zones","WarEntry","SephirothUI")) { MapX = 32; MapY = 47; }
	else if (Text == Localize("Zones","WarCastle","SephirothUI")) { MapX = 33; MapY = 47; }
	else if (Text == Localize("Zones","WarCentre","SephirothUI")) { MapX = 32; MapY = 48; }
	else if (Text == Localize("Zones","WarHwayeom","SephirothUI")) { MapX = 33; MapY = 48; }
	else if (Text == Localize("Zones","WarHaeiyl","SephirothUI")) { MapX = 34; MapY = 48; }
	else if (Text == Localize("Zones","WarPyungbum","SephirothUI")) { MapX = 35; MapY = 48; }
	else if (Text == Localize("Zones","WarJinmoo","SephirothUI")) { MapX = 36; MapY = 48; }
	else if (Text == Localize("Zones","FrozenLand","SephirothUI")) { MapX = 32; MapY = 45; }
	else if (Text == Localize("Zones","Rampao12","SephirothUI")) { MapX = 32; MapY = 43; }
	else if (Text == Localize("Zones","Rampao3","SephirothUI")) { MapX = 33; MapY = 43; }
	else if (Text == Localize("Zones","Delphiroth1","SephirothUI")) { MapX = 35; MapY = 43; }
	else if (Text == Localize("Zones","Delphiroth2","SephirothUI")) { MapX = 36; MapY = 43; }
	else if (Text == Localize("Zones","Delphiroth3","SephirothUI")) { MapX = 35; MapY = 44; }
	else if (Text == Localize("Zones","PetLand","SephirothUI")) { MapX = 37; MapY = 44; }
	else if (Text == Localize("Zones","GhostTown","SephirothUI")) { MapX = 34; MapY = 46; }
	//add neive : 퀘스트 던전
	else if (Text == Localize("Zones","QuestMap1","SephirothUI")) { MapX = 32; MapY = 57; }
	else if (Text == Localize("Zones","QuestMap2","SephirothUI")) { MapX = 33; MapY = 57; }
	else if (Text == Localize("Zones","QuestMap3","SephirothUI")) { MapX = 34; MapY = 57; }
	else if (Text == Localize("Zones","QuestMap4","SephirothUI")) { MapX = 35; MapY = 57; }
	//add Ryu : 전장맵 추가..
	else if (Text == Localize("Zones","BattleZone1","SephirothUI")) { MapX = 39; MapY = 50; }
	else if (Text == Localize("Zones","BattleZone2","SephirothUI")) { MapX = 40; MapY = 50; }
	else if (Text == Localize("Zones","Cave1","SephirothUI")) { MapX = 36; MapY = 46; } //add neive : 메가로파 굴
	else if (Text == Localize("Zones","DelphistMap","SephirothUI")) { MapX = 39; MapY = 54; } //add neive : 라디아네스 동부
	else if (Text == Localize("Zones","LostCave","SephirothUI")) { MapX = 36; MapY = 57; } //add neive : 버려진 폐광
	else if (Text == Localize("Zones","MistVilage","SephirothUI")) { MapX = 39; MapY = 38; } //add neive : 버려진 폐광


	if (MapX != 0 && MapY != 0) {
		StartMapX = MapX - (MapHSize-1)/2;
		StartMapY = MapY - (MapVSize-1)/2;
	}
}

function RightClickOnTextMenu(int Index, string Text)
{
	local CTextMenu TextMenu;
	local string MenuString;

	if (Index >= 0 && Index < Portals.Length) {
		MenuString = "MoveAbs|Remove|Update XY|";
		if (Portals[Index].bVisible)
			MenuString = MenuString $ "Hide";
		else
			MenuString = MenuString $ "Show";
		TextMenu = PopupContextMenu(MenuString, Controller.MouseX, Controller.MouseY);
		TextMenu.OnTextMenu = OnPortalTextMenu;
		SelectedPortal = Index;
	}
}

function OnPortalTextMenu(int Index, string Text)
{
	local int i;
	if (SelectedPortal >= 0 && SelectedPortal < Portals.Length) {
		if (Index == 0) {
			SephirothPlayer(PlayerOwner).Net.NotiTell(1,"\\\\MoveAbs"@Portals[SelectedPortal].X@Portals[SelectedPortal].Y);
			PlayerOwner.myHud.AddMessage(1, "Try to teleport "$Portals[SelectedPortal].Zone, class'Canvas'.static.MakeColor(255,255,0));
		}
		else if (Index == 1) {
			for (i=SelectedPortal;i<Portals.Length-1;i++) {
				Portals[i].Zone = Portals[i+1].Zone;
				Portals[i].X = Portals[i+1].X;
				Portals[i].Y = Portals[i+1].Y;
			}
			Portals.Remove(Portals.Length-1,1);
			SaveConfig();
		}
		else if (Index == 2) {
			Portals[SelectedPortal].X = PlayerOwner.Pawn.Location.X;
			Portals[SelectedPortal].Y = PlayerOwner.Pawn.Location.Y;
			SaveConfig();
		}
		else if (Index == 3) {
			Portals[SelectedPortal].bVisible = !Portals[SelectedPortal].bVisible;
			SaveConfig();
		}
	}
}

function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	if (NotifyId == IDS_AddPortal && EditText != "") {
		Portals.Length = Portals.Length+1;
		Portals[Portals.Length-1].Zone = EditText;
		Portals[Portals.Length-1].X = ClickPos.X;
		Portals[Portals.Length-1].Y = ClickPos.Y;
		Portals[Portals.Length-1].bVisible = True;
		SaveConfig();
	}
}

function bool PointCheck()
{
	return IsCursorInsideAt(ScreenX, ScreenY, GridSpaceX*MapHSize, GridSpaceY*MapVSize);
}

function TimerProc()
{
	local int RandValue;
	if (Portals.Length > 0) {
		RandValue = Rand(Portals.Length);
		PlayerOwner.myHud.AddMessage(1, "Move to zone " $ Portals[RandValue].Zone, class'Canvas'.static.MakeColor(255,255,255));
		SephirothPlayer(PlayerOwner).Net.NotiTell(1, "\\\\MoveAbs " $ Portals[RandValue].X $ " " $ Portals[RandValue].Y);
	}
}

defaultproperties
{
     GridSpaceX=50
     GridSpaceY=30
     StartMapX=32
     StartMapY=38
     MapHSize=11
     MapVSize=20
     MapSize=65024
     ClickPos=(X=-1.000000)
     AvailMapPos(0)="111101011000"
     AvailMapPos(1)="111101011000"
     AvailMapPos(2)="110001000000"
     AvailMapPos(3)="110001000000"
     AvailMapPos(4)="000000000000"
     AvailMapPos(5)="110110000000"
     AvailMapPos(6)="000101000000"
     AvailMapPos(7)="100000000000"
     AvailMapPos(8)="001010000000"
     AvailMapPos(9)="110000000000"
     AvailMapPos(10)="111110000000"
     AvailMapPos(11)="000000000000"
     AvailMapPos(12)="000000011000"
     AvailMapPos(13)="001110000000"
     AvailMapPos(14)="101111111111"
     AvailMapPos(15)="001111111111"
     AvailMapPos(16)="111111111111"
     AvailMapPos(17)="111111111111"
     AvailMapPos(18)="000000000000"
     AvailMapPos(19)="111111110000"
}
