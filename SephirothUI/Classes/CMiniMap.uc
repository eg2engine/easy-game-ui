class CMiniMap extends CInterface
	config(SephirothUI);

#exec OBJ LOAD FILE=../Textures/LHC_Package.utx PACKAGE=LHC_Package

const TexSize = 512;
const MapSize = 65024;
const Radius_type1 = 68;	// NonRotatable Rectagular Version	2009.10.27.Sinhyub
const Radius_type2 = 64;	// Rotatatible Circular Version		

const BN_ScaleDown = 1;
const BN_ScaleUP = 2;

//modified by yj  //�̵�
var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var bool bMinimapType;	//Minimap Type. True = Ractagle. False = Circle 2009.10.26.Sinhyub
var vector r_Loc,r_V1,r_V2;	//Minimap Rotation Variables
var float r_Yaw;


var int Radius;

var float VisibleRadius;
var float WorldMax;
var float WorldHalf;
var float MaxScale, MinScale;
var globalconfig float Scale;
var int MapStartX,MapStartY,MapEndX,MapEndY;
var int TexStartX,TexStartY,TexEndX,TexEndY;
var int PlayerOffsetX,PlayerOffsetY;
var float X,Y,XL,YL,U,V,UL,VL,U2,V2,UL2,VL2;
var InterfaceRegion rcWindow;

var TexScaler AlphaScale;
var Combiner MinimapCombiner;
var FinalBlend MinimapBlend;

var array<Texture> DynamicTextures;

var color C_LowMonster;     // ���� ���͸� ǥ���� ����
var color C_MiddleMonster;  // ���� ���͸� ǥ���� ����
var color C_HighMonster;    // ���� ���͸� ǥ���� ����
var color C_Npc;            // NPC �� ǥ���� ����
var color C_Hero;           // ���ΰ�
var color C_Party;          // ��Ƽ
var color C_MatchStone;     // ������ ���� �μ� ��;;

//add neive : ���� ���� ���� �� ǥ��
var color ColorDiffA;
var color ColorDiffB;
var color ColorDiffC;
var color ColorDiffD;
var color ColorDiffE;
var color ColorDiffF;

var array<string> AvailMapPos;


//-------------------modified by yj
var float ScaleSpeed;
var int ScaleTick;
var int ScaleTick_;

//#############################################################################
// ���� ǥ�� : �� üũ ���� �������̽� �ϳ��� �ʿ��ѵ� �ϳ� �� �����ڴ� ������ ���Ұ� �־ �׳� ���⼭ ���� �Ѵ�
//struct _AreaDisplay
//{
	var Font DisplayFont;
	var string CurDisplayAreaName;	// ���� ǥ�� ���� �̸�
	var string LastDisplayAreaName;	// ������ ���� �̸�
	var float LastDisplayTime;		// ���������� ���� �̸��� ǥ���� �ð�
	var float DisplayStartTime;
//};

function AreaTick()
{
	if(CurDisplayAreaName == "" && SephirothPlayer(PlayerOwner).ZSI.ZoneDesc != LastDisplayAreaName)
	{
		CurDisplayAreaName = SephirothPlayer(PlayerOwner).ZSI.ZoneDesc;
		DisplayStartTime = Level.TimeSeconds;
//		//Log("neive: check Start Display Area Name " $ CurDisplayAreaName $ ":(");
	}

	if(CurDisplayAreaName != "" && Level.TimeSeconds - DisplayStartTime > 3.0f)	// 3�ʰ� �����ְ� �� ���� ���� ����
	{
		LastDisplayAreaName = CurDisplayAreaName;
		CurDisplayAreaName = "";
//		//Log("neive: check End Display Area Name " $ LastDisplayAreaName $ ":(");
	}
}

function RenderAreaName(Canvas C)
{
	local float fX,fY,fW,fH;
	local float Ratio;
	local Font OldFont;

	//Ratio = 1.f; //cs changged
	Ratio = 2.f;

	if(CurDisplayAreaName != "")
	{
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
//		C.SetDrawColor(195,195,195);
//		C.DrawKoreanText(CurDisplayAreaName, (C.ClipX - 200) / 2, 100, 200, 15);

		OldFont = C.Font;
		C.Font = DisplayFont;

		C.TextSize(CurDisplayAreaName, fW, fH);

//		fX = (C.ClipX - (fW * Ratio)) / 2;
//		fY = 50;

//		C.SetPos(fX-10, fY-10);	// ��-_-Ÿ
//		C.DrawTile(TextureResources[9].Resource,(fW * Ratio)+20,(fH * Ratio)+20,0,0,115,15);

		fX = (C.ClipX - 956) / 2;
		fY = 50;
		C.SetPos(fX-10, fY-10);	// ��-_-Ÿ
		C.DrawTile(TextureResources[11].Resource,956,61,0,0,956,61);

		C.SetDrawColor(255,212,115);
		//fX = (C.ClipX - (fW * Ratio)) / 2;
		fX = ((C.ClipX - (fW * Ratio)) + fW)/ 2;//cs changed
		fY = 56;
		C.SetPos(fX, fY);
		//PlayerOwner.myHud.AddMessage(1,CurDisplayAreaName,class'Canvas'.static.MakeColor(200,100,200));
		C.DrawTextScaled(CurDisplayAreaName, true, Ratio, Ratio);   //cs changed UCanvas::execDrawTextScaled code 
		
		C.Font = OldFont;
	}
}
//#############################################################################

function OnInit()
{
	if(PageX == -1)
		ResetDefaultPosition();
	bMovingUI = true;	//Layout()���� â���� ��� UI�� üũ���ټ��ֵ����մϴ�. 2009.10.29.Sinhyub

	ChangeMiniMapDisplayMode();
	SetComponentTextureId(Components[3],6,-1,8,7);
	SetComponentTextureId(Components[4],3,-1,5,4);

	SetComponentNotify(Components[3],BN_ScaleUp,Self);
	SetComponentNotify(Components[4],BN_ScaleDown,Self);	

	AlphaScale = new(None) class'TexScaler';
	MinimapCombiner = new(None) class'Combiner';
	MinimapBlend = new(None) class'FinalBlend';

	Scale = FClamp(Scale, MinScale, MaxScale);
	bNeedLayoutUpdate = true;
}

function OnFlush()
{
	FlushDynamicTextures();
	SaveConfig();
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if (!IsCursorInsideComponent(Components[3]) && !IsCursorInsideComponent(Components[4]))		//Check this condition	//���콺�� ���� ���� ��찡 �ξ� �����ٵ�
		return;

	if (Components[3].bMousePress && IsCursorInsideComponent(Components[3])) {
		ScaleTick_++;
		if(ScaleTick_ >= 20) {
			ScaleTick++;
			if (ScaleTick >= 1.0f / ScaleSpeed) {
				Scale = FClamp(Scale-0.2,MinScale,MaxScale);
				ScaleTick = 0;
			}
		}
	}
	else if (Components[4].bMousePress && IsCursorInsideComponent(Components[4])) {
		ScaleTick_++;
		if(ScaleTick_ >= 20) {
			ScaleTick++;
			if (ScaleTick >= 1.0f / ScaleSpeed) {
				Scale = FClamp(Scale+0.2,MinScale,MaxScale);
				ScaleTick = 0;
			}
		}
	}
	else 
		ScaleTick_ = 0;		//��..
}

function OnPreRender(Canvas C)
{
	local int i, j, count, cx, cy;
	local vector Loc,Center;
	local int Yaw;
	local PartyManager.PartyPlayer PartyPlayer;
	local Creature Creature;
	local Hero Hero;
	local int MnstLV, DiffLV;
	local InterfaceRegion Rgn;
	local color OldColor;
	local Material MinimapTexture;
	local color TypeColor;
	local string MapName;

	if(true)
		Yaw = 0; //PlayerOwner.Rotation.Yaw + 16384;
	else
		Yaw = -PlayerOwner.Rotation.Yaw - 16384;

//	Components[5].Rotation = PlayerOwner.Pawn.Rotation.Yaw + 16384; //Yaw;
	Components[5].Rotation = PlayerOwner.Rotation.Yaw + 16384; // �ü� ȸ��


	/*This is not a good place to call ChangeMiniMapDisplayMode(), Sorry for do this but I have not enough time to replace it. -2009.10.26.Sinhyub*/
	//ChangeMiniMapDisplayMode();

	/* MapPosition = (Translated Player Position +/- Scaled Visible Radius) / MapSize; */
	MapStartX = (PlayerOwner.Pawn.Location.X + 40*MapSize - VisibleRadius * Scale) / MapSize;
	MapStartY = (PlayerOwner.Pawn.Location.Y + 40*MapSize - VisibleRadius * Scale) / MapSize;
	MapEndX = (PlayerOwner.Pawn.Location.X + 40*MapSize + VisibleRadius * Scale) / MapSize;
	MapEndY = (PlayerOwner.Pawn.Location.Y + 40*MapSize + VisibleRadius * Scale) / MapSize;

	count = 0;
	for (i=MapStartX;i<=MapEndX;i++) {
		for (j=MapStartY;j<=MapEndY;j++) {

			// keios
			if(CheckMap(i, j))
				MapName = "Minimap.minimap" $ i $ "-" $ j;
			else
				MapName = "Minimap.blankmap";

			MinimapTexture = LoadDynamicTexture(MapName);
			if (MinimapTexture == None)
				continue;

			PlayerOffsetX = (PlayerOwner.Pawn.Location.X - (i-40)*MapSize) * TexSize / MapSize;
			PlayerOffsetY = (PlayerOwner.Pawn.Location.Y - (j-40)*MapSize) * TexSize / MapSize;
			TexStartX = rcWindow.X + Radius - PlayerOffsetX / Scale;
			TexStartY = rcWindow.Y + Radius - PlayerOffsetY / Scale;
			TexEndX = TexStartX + TexSize / Scale;
			TexEndY = TexStartY + TexSize / Scale;

			if (TexStartX < rcWindow.X) {
				X = rcWindow.X ;
				U = (rcWindow.X - TexStartX) * Scale;
				XL = min(TexEndX - X,Radius * 2) ;
				UL = min((TexEndX - X) * Scale, Radius * 2 * Scale);
				U2 = 0;
				UL2 = min(TexEndX - rcWindow.X,Radius * 2);
			}
			else {
				X = TexStartX ;
				U = 0;
				XL = rcWindow.X + Radius*2 - X ;
				UL = (rcWindow.X + Radius*2 - X) * Scale;
				U2 = max(0, TexStartX - rcWindow.X);
				UL2 = min(rcWindow.X + Radius*2 - TexStartX , Radius * 2);
			}

			if (TexStartY < rcWindow.Y) {
				Y = rcWindow.Y ;
				V = (rcWindow.Y - TexStartY) * Scale;
				YL = min(TexEndY - Y + 0.5,Radius * 2  );
				VL = min((TexEndY - Y) * Scale, Radius * 2 * Scale);
				V2 = 0;
				VL2 = min(TexEndY - rcWindow.Y,Radius * 2);
			}
			else {
				Y = TexStartY ;
				V = 0;
				YL = rcWindow.Y + Radius*2 - Y ;
				VL = (rcWindow.Y + Radius*2 - Y) * Scale;
				V2 = max(0, TexStartY - rcWindow.Y );
				VL2 = min(rcWindow.Y + Radius*2 - TexStartY , Radius * 2 );
			}

			AlphaScale.UScale = UL/UL2 / TexSize * Radius * 2.0;
			AlphaScale.VScale = VL/VL2 / TexSize * Radius * 2.0;
			AlphaScale.UOffset = - ( U/TexSize - ( U2/Radius/2.0) ) * Radius *2.0;
			if( AlphaScale.UOffset < 0.0 ) 
				AlphaScale.UOffset = AlphaScale.UOffset / AlphaScale.UScale;
			AlphaScale.VOffset = - ( V/TexSize - ( V2/Radius/2.0) ) * Radius * 2.0;
			if( AlphaScale.VOffset < 0.0 ) 
				AlphaScale.VOffset = AlphaScale.VOffset / AlphaScale.VScale;
			if(bMinimapType)		// 2009.10.26.Sinhyub
				AlphaScale.Material = None;
			else
				AlphaScale.Material = TextureResources[0].Resource;


			MinimapCombiner.CombineOperation = CO_Use_Color_From_Material1;
			MinimapCombiner.AlphaOperation = AO_Use_Alpha_From_Material2;
			MinimapCombiner.Material1 = MinimapTexture;
			if( bMinimapType )		// 2009.10.26.Sinhyub
				MinimapCombiner.Material2 = None;
			else
				MinimapCombiner.Material2 = AlphaScale;		//modified by yj   //�ϴ��� Rot ����� �������� �����Ƿ� AlphaBlend�� ���Ƶд�.

			MinimapBlend.FrameBufferBlending = FB_AlphaBlend;
			MinimapBlend.Material = MinimapCombiner;
			MinimapBlend.ZWrite = false;
			MinimapBlend.ZTest = false;

			if(YL < 0)	// ��ü�Ҹ��� ��� �ѷ��ִ� ���� ���� �ӽ�-_-����
				continue;

			X = X-0.5; XL = XL + 0.5;
			Y = Y-0.5; YL = YL + 0.5;
			cx = Components[1].X + Components[1].XL / 2;
			cy = Components[1].Y + Components[1].YL / 2;
			C.SetPos(X,Y);
			C.DrawTileRotated(MinimapBlend, XL, YL, U, V, UL, VL, cx, cy, Yaw);
		}
	}

	OldColor = C.DrawColor;
	C.SetRenderStyleAlpha();
	Rgn.X = rcWindow.X+25;
	Rgn.Y = rcWindow.Y+25;
	Rgn.W = rcWindow.W-50;
	Rgn.H = rcWindow.H-50;

	Center.X = Rgn.X+Rgn.W/2;
	Center.Y = Rgn.Y+Rgn.H/2;

	if (Scale < 3.0)
	{
		// Render creature/monster spot
		for (i=0;i<GameManager(Level.Game).Creatures.Length;i++)
		{
			Creature = GameManager(Level.Game).Creatures[i];
			if (Creature != None && !Creature.bDeleteMe)
			{
				if (Creature.IsA('Monster'))
				{
					MnstLV = Monster(Creature).GetPlayLevel();
					DiffLV = MnstLV - SephirothPlayer(PlayerOwner).PSI.PlayLevel;

					//add neive : ���� ���� ǥ�� ------------------------------------------
					// ��ȫ FColor(196, 136, 255);
					// ���� FColor(128, 128, 128);

					if(SephirothPlayer(PlayerOwner).PSI.bParty)
					{
						if(DiffLV < -130)
							TypeColor = ColorDiffF;
						else if(DiffLV <= -31)
							TypeColor = ColorDiffE;
						else if(DiffLV <= -21)
							TypeColor = ColorDiffD;
						else if(DiffLV <= 20)
							TypeColor = ColorDiffC;
						else if(DiffLV < 22)
							TypeColor = ColorDiffB;
						else
							TypeColor = ColorDiffA;
					}
					else
					{
						if(DiffLV < -130)
							TypeColor = ColorDiffF;
						else if(DiffLV <= -21)
							TypeColor = ColorDiffE;
						else if(DiffLV <= -11)
							TypeColor = ColorDiffD;
						else if(DiffLV <= 3)
							TypeColor = ColorDiffC;
						else if(DiffLV <= 5)
							TypeColor = ColorDiffB;
						else
							TypeColor = ColorDiffA;
					}

					Loc = (Creature.Location - PlayerOwner.Pawn.Location) * TexSize / MapSize / Scale;
					class'CNativeInterface'.static.DrawPointRotated(Center.X, Center.Y, Loc.X, Loc.Y, Yaw, 2, TypeColor, Rgn.X, Rgn.Y, Rgn.W, Rgn.H, true);
					//---------------------------------------------------------------------
				}
				else if (Creature.IsA('Npc'))
				{
					TypeColor = C_Npc;
					Loc = (Creature.Location - PlayerOwner.Pawn.Location) * TexSize / MapSize / Scale;

					if(Creature.nSymbol == 0)
					{
						class'CNativeInterface'.static.DrawPointRotated(Center.X, Center.Y, Loc.X, Loc.Y, Yaw, 2, TypeColor, Rgn.X, Rgn.Y, Rgn.W, Rgn.H, true);
					}
					else
					{
						C.SetPos(Center.X + Loc.X - 10, Center.Y + Loc.Y - 12);

						switch(Creature.nSymbol)	// NPC symbol npc �ɹ� ǥ��
						{
						case 1: C.DrawTile(TextureResources[12].Resource,19,24,0,0,19,24); break;
						case 2: C.DrawTile(TextureResources[13].Resource,19,24,0,0,19,24); break;
						case 3: C.DrawTile(TextureResources[14].Resource,19,24,0,0,19,24); break;
						case 4: C.DrawTile(TextureResources[15].Resource,19,24,0,0,19,24); break;
						case 5: C.DrawTile(TextureResources[16].Resource,19,24,0,0,19,24); break;
						case 6: C.DrawTile(TextureResources[17].Resource,19,24,0,0,19,24); break;
						}
					}
				}
				else if (Creature.IsA('MatchStone'))
				{
					TypeColor = C_MatchStone;
					Loc = (Creature.Location - PlayerOwner.Pawn.Location) * TexSize / MapSize / Scale;
					class'CNativeInterface'.static.DrawPointRotated(Center.X, Center.Y, Loc.X, Loc.Y, Yaw, 2, TypeColor, Rgn.X, Rgn.Y, Rgn.W, Rgn.H, true);
				}
			}
		}

		for (i=0;i<GameManager(Level.Game).Heroes.Length;i++) {
			Hero = GameManager(Level.Game).Heroes[i];
			if (Hero != None && !Hero.bDeleteMe && Hero.Controller != None && !ClientController(Hero.Controller).IsTransparent() && !SephirothPlayer(PlayerOwner).PartyMgr.IsInParty(string(ClientController(Hero.Controller).PSI.PlayName))) {
				Loc = (Hero.Location - PlayerOwner.Pawn.Location) * TexSize / MapSize / Scale;
				class'CNativeInterface'.static.DrawPointRotated(Center.X, Center.Y, Loc.X, Loc.Y, Yaw, 2, C_Hero, Rgn.X, Rgn.Y, Rgn.W, Rgn.H, true);
			}
		}
	}

	// Render party member spot
	if (SephirothPlayer(PlayerOwner).PSI.bParty) {
		for (i=1;i<SephirothPlayer(PlayerOwner).PartyMgr.Members.Length;i++) {
			PartyPlayer = SephirothPlayer(PlayerOwner).PartyMgr.Members[i];
			Loc = (PartyPlayer.Location - PlayerOwner.Pawn.Location) * TexSize / MapSize / Scale;
			class'CNativeInterface'.static.DrawPointRotated(Center.X, Center.Y, Loc.X, Loc.Y, Yaw, 2, C_Party, Rgn.X, Rgn.Y, Rgn.W, Rgn.H, true);
		}
	}

	//if (bShowActiveItems) {
	//	if (PlayerOwner.Level.TimeSeconds - ActiveItemLastShownTime > 10.0) {
	//		bShowActiveItems = false;
	//		ActiveItemLastShownTime = 0;
	//	}
	//	else {
	//		for (i=0;i<SephirothPlayer(PlayerOwner).ActiveItems.Length;i++) {
	//			ActiveItem = SephirothPlayer(PlayerOwner).ActiveItems[i];
	//			Loc2.X = ActiveItem.PosX;
	//			Loc2.Y = ActiveItem.PosY;
	//			Loc = Loc2 - PlayerOwner.Pawn.Location;
	//			Loc.Z = 0;
	//			Distance = VSize(Loc);
	//			Yaw2 = Rotator(Loc).Yaw;
	//			Loc = Loc * TexSize / MapSize / Scale;
	//			Loc2.X = Loc.X * Cos(2 * PI * Yaw / 65536.) - Loc.Y * Sin(2 * PI * Yaw / 65536.);
	//			Loc2.Y = Loc.X * Sin(2 * PI * Yaw / 65536.) + Loc.Y * Cos(2 * PI * Yaw / 65536.);
	//			Loc = Loc2;
	//			if (IsPosInsideCircleRegion(Rgn,rcWindow.X+rcWindow.W/2+Loc.X,rcWindow.Y+rcWindow.H/2+Loc.Y)) {
	//				C.SetRenderStyleAlpha();
	//				C.SetPos(Center.X+Loc.X-16,Center.Y+Loc.Y-16);
	//				C.DrawTile(ActiveItemMat,32,32,0,0,32,32);
	//				if (ActiveItem.OwnerName != "") {
	//					C.SetPos(Center.X+Loc.X,Center.Y+Loc.Y);
	//					C.KTextFormat = ETextAlign.TA_BottomCenter;
	//					C.DrawKoreanText(ActiveItem.OwnerName,Center.X+Loc.X-100,Center.Y+Loc.Y-20,200,20);
	//				}
	//			}
	//			else {
	//				if (Distance < 3000)
	//					DistanceColor = 255;
	//				else if (Distance > 100000)
	//					DistanceColor = 128;
	//				else
	//					DistanceColor = 255.0 - 128.0 * (Distance - 3000.0) / (100000.0 - 3000.0);

	//				C.SetPos(Center.X-4, Center.Y-44);
	//				C.SetRenderStyleAlpha();
	//				C.DrawTileRotated(ActiveItemMatArrow, 8, 44, 0, 0, 8, 44, Center.X, Center.Y, Yaw+Yaw2+16384);
	//			}
	//		}
	//	}
	//}

	C.DrawColor = OldColor;

	AreaTick();
}

function OnPostRender(HUD H, Canvas C)
{
	local int Qx, Qy;
	local string PosStr;
	local string sZoneDesc;

	C.SetRenderStyleAlpha();

	//���� ���� ��ġ ��ǥ�� ǥ���� �ִ� �ڵ�. �� ������ �̴ϸ� �߶� �׸��� �κп� ������ ������. Sinhyub
	Qx = PlayerOwner.Pawn.Location.X+40*MapSize;
	Qy = PlayerOwner.Pawn.Location.Y+40*MapSize;
	PosStr = Qx/100 $ ":" $ Qy/100;
	C.SetPos(Components[0].X+14, Components[0].Y+Components[0].XL);
	C.DrawTile(TextureResources[9].Resource,115,15,0,0,115,15);
	C.TextSize(PosStr,XL,YL);
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(255,255,90);
	C.DrawKoreanText(PosStr,Components[0].X+19, Components[0].Y+Components[0].XL, 115, 15);

	// ���� ǥ��
	//C.SetDrawColor(113,162,55);
	C.SetDrawColor(172,242,84);

//	C.SetPos(Components[6].X, Components[6].Y);
//	C.DrawRect1fix(Components[6].XL, Components[6].YL);

//	SephirothPlayer(PlayerOwner).ZSI.ZoneDesc = "�׽�Ʈ �ʵ尡 ��� �󸶳� ��ھ��";
	sZoneDesc = ClipText(C, SephirothPlayer(PlayerOwner).ZSI.ZoneDesc, Components[6].XL - 10);
	C.DrawKoreanText(sZoneDesc,Components[6].X, Components[6].Y, Components[6].XL, Components[6].YL);
//	C.DrawKoreanText(SephirothPlayer(PlayerOwner).ZSI.CastleDesc,Components[6].X, Components[6].Y, Components[6].XL, Components[6].YL);

	if(IsCursorInsideComponent(Components[6]))
	{
		Components[6].Tooltip = SephirothPlayer(PlayerOwner).ZSI.ZoneDesc;
		Components[6].bNoLocalizeTooltip = true;
	}

	/*
	C.SetDrawColor(0,0,255);
	C.SetPos(Components[0].X, Components[0].Y);
	C.DrawRect1Fix(Components[0].XL, Components[0].YL);

	C.SetDrawColor(255,0,0);
	C.SetPos(Components[1].X, Components[1].Y);
	C.DrawRect1Fix(Components[1].XL, Components[1].YL);*/

	RenderAreaName(C);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
		case BN_ScaleUp:
			Scale -= 0.2;
			if (Scale < MinScale) Scale = MinScale;
			SaveConfig();
			break;
		case BN_ScaleDown:
			Scale += 0.2;
			if (Scale > MaxScale) Scale = MaxScale;
			SaveConfig();
			break;
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Action == IST_Press) 
	{
		switch (Key) {	
			case IK_MouseWheelUp :
				if(IsCursorInsideComponent(Components[0])) {
					Scale += 0.2;
					if (Scale > MaxScale) Scale = MaxScale;
					SaveConfig();
					return true;	
				}
				break;
			case IK_MouseWheelDown :
				if(IsCursorInsideComponent(Components[0])) {
					Scale -= 0.2;
					if (Scale < MinScale) Scale = MinScale;
					SaveConfig();
					return true;	
				}
				break;
			
			case IK_LeftMouse:
				if( IsCursorInsideComponent(Components[6]) ) {
					bMovingUI = true;
					bIsDragging = true;
					DragOffsetX = Controller.MouseX - PageX;
					DragOffsetY = Controller.MouseY - PageY;
				}
				//Pin Minimap ��� �׽�Ʈ. N��ư�� ������ ������ ���� ������
				//V1 : �̴ϸ� Pin ��ư�� �߽�
				//V2 : �̴ϸ� �߽���(ȸ����)
				//Loc : �߽������� Pin��ư�� ��ġ�� ���ͷ� ǥ�� 
				//Loc2 : Loc�� ���ϱ����� ����ϴ� �ӽ� ���� ����
/*				if(bool(ConsoleCommand("GETOPTIONI PinMinimap")))
				{
					if(IsCursorInsideCircleAt(PAGEX+59,PAGEY-8,18,18))
					{//PinMinimap ��ư �ȿ� �ִ°�
						ConsoleCommand("TOGGLEOPTION PinMinimap");
						ConsoleCommand("SAVEOPTION");
						ChangeMiniMapDisplayMode();
						Saveconfig();
						return true;
					}
				}
				else
				{
					//r_Loc vector�� Layout���� ���Ǿ����ϴ�.
					if (IsCursorInsideCircleAt(PAGEX+64+r_Loc.X-9,PAGEY+64+r_Loc.Y-9,18,18)) {
						ConsoleCommand("TOGGLEOPTION PinMinimap");
						ConsoleCommand("SAVEOPTION");
						ChangeMiniMapDisplayMode();
						Saveconfig();
						return true;
					}
				}*/
				break;
			case IK_Home:
				Scale -= 0.2;
				if (Scale < MinScale) Scale = MinScale;
				//SaveConfig();
				//return true;
				return false; //cs changed for plugin triger
				break;
			case IK_End:
				Scale += 0.2;
				if (Scale > MaxScale) Scale = MaxScale;
				//SaveConfig();
				return true;
				break;
		}
	}
	else if (Action == IST_Release) 
	{
		if(bIsDragging) {	// 2009.10.27.Sinhyub
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			SaveConfig();			//modified by yj
			return true;
		}

		if ((Key == IK_LeftMouse || Key == IK_RightMouse) && IsCursorInsideComponent(Components[0]))
			return true;
	}

	return false;
}

//function ShowActiveItems()
//{
//	ActiveItemLastShownTime = PlayerOwner.Level.TimeSeconds;
//	bShowActiveItems = true;
//}

//add neive : �ּ������ϸ� ���콺 Ŭ�� ���� -----------------------------------
function bool PointCheck()
{
	return IsCursorInsideComponent(Components[2]) || IsCursorInsideComponent(Components[3]) || IsCursorInsideComponent(Components[4]) ||
		IsCursorInsideComponent(Components[6]);
}
//-----------------------------------------------------------------------------



function Layout(Canvas C)
{
	local int DX,DY;
	local int i;
//	local vector r_Loc2;

	if(bMovingUI) {
		if (bIsDragging) {		
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else {
			if (PageX -8 < 0)		//modified by yj  //������ �ѷ��ΰ� �ִ� Ʋ�� �ƴ�, ���̱� ������
				PageX = 8;
			else if (PageX-8+WinWidth > C.ClipX)
				PageX = C.ClipX - (WinWidth-8);
			if (PageY -8< 0)
				PageY = 8;
			else if (PageY -8+ WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight+8;
			bMovingUI = false;
		}
		bNeedLayoutUpdate = true;
	}

	if(bNeedLayoutUpdate)
	{
		MoveComponentId(0,true,PageX,PageY);
		MoveComponentId(1,true,Components[0].X + (Components[0].XL - Components[1].XL) / 2,
								Components[0].Y + (Components[0].YL - Components[1].YL) / 2);
		MoveComponentId(2);

		for(i=3; i<Components.Length; i++)
			MoveComponentId(i);

		rcWindow.X = Components[1].X;
		rcWindow.Y = Components[1].Y;
		rcWindow.W = Components[1].XL;
		rcWindow.H = Components[1].YL;
		bNeedLayoutUpdate = false;
	}
/*
	//Pin Minimap Button�� ���� ó���Դϴ�.
	//���⼭ ����� Loc�� Onkey Event������ ���̹Ƿ� �ڵ� ������ �����ؿ��ֽñ�ٶ��ϴ�.
	//2009.10.28.Sinhyub
	r_V1.X = 64;	r_V1.Y = 9;	r_V2.X = 64;	r_V2.Y = 64;
	r_Loc = r_V1 - r_V2;
	r_Yaw = -PlayerOwner.Rotation.Yaw - 16384;
	r_Loc2.X = r_Loc.X*Cos(2*PI*r_Yaw/65536.)-r_Loc.Y*Sin(2*PI*r_Yaw/65536.);
	r_Loc2.Y = r_Loc.X*Sin(2*PI*r_Yaw/65536.)+r_Loc.Y*Cos(2*PI*r_Yaw/65536.);
	r_Loc = r_Loc2;
	if(bMinimaptype)
	{
		Components[7].X = PAGEX+59;
		Components[7].Y = PAGEY-8;
	}
	else
	{
		Components[7].X = PAGEX+64+r_Loc.X-9;
		Components[7].Y = PAGEY+64+r_Loc.Y-9;
	}
	//PinMinimapButton Mouse Over Image
	if(IsCursorInsideComponent(Components[7]))
		Components[7].bVisible = true;
	else
		Components[7].bVisible = false;*/
}

//#############################################################################
// �� ��
//#############################################################################

function bool CheckMap(int x, int y)
{
	// keios - array�� �̿��Ͽ� üũ
	local int mx, my;
	local string c;

	local int MapSizeX, MapSizeY;

	MapStartX = 32;	// ���� �� ���� ����Ʈ x, y
	MapStartY = 38;
	MapSizeX = 10;	// ���� �������� 10ĭ�� ����
	MapSizeY = 18;	// �Ʒ������� �� ĭ�� ��������

	mx = x - MapStartX;
	my = y - MapStartY;

	if(mx < 0 || mx >= MapSizeX)
		return false;
	if(my < 0 || my >= MapSizeY)
		return false;
	
	c = Mid( AvailMapPos[my], mx, 1 );

	if( c == "1" )
		return true;

	return false;
}

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if (T != None) {
		for (i=0;i<DynamicTextures.Length;i++)
			if (T == DynamicTextures[i])
				break;
		if (i == DynamicTextures.Length) {
			T.AddReference();
			DynamicTextures[i] = T;
		}
	}
	return T;
}

final function FlushDynamicTextures()
{
	local int i,count;

	count = DynamicTextures.Length;
	for (i=0;i<DynamicTextures.Length;i++) {
		if (DynamicTextures[i] != None) {
			UnloadTexture(Viewport(PlayerOwner.Player),DynamicTextures[i]);
		}
	}
	DynamicTextures.Remove(0,count);
}

//#############################################################################
// �ܺ� ����
//#############################################################################

function ResetDefaultPosition()		//modified by yj
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
	pos = InStr(Resolution, "x");

	ClipX=int(Left(Resolution, pos));		
	ClipY=int(Mid(Resolution,pos+1));

	PageX = ClipX-WinWidth - 2;		//+8�� PageX�� 'Ʋ'�� �ƴ� '�̴ϸ�'��ü �̱� ������
	PageY = 33;

	bNeedLayoutUpdate = true;
	SaveConfig();
}

/*
	ChangeMiniMapDisplayMode()
	We have two different type of Minimap.
	Each Minimap has some different properties.
	So, when constructing minimap or changing the type of minimap, we have to set up the different property.
	Call this function in Oninit() and whenever minimap type is changed.
	2009.10.26.Sinhyub.
*/
function ChangeMiniMapDisplayMode()
{
	//if(bool(ConsoleCommand("GETOPTIONI PinMinimap")))
	if(false)
	{
		bMinimapType = true;
		Radius = Radius_type1;
	}
	else
	{
		bMinimapType = false;
		Radius = 64;
	}
	bNeedLayoutUpdate = true;
}

defaultproperties
{
     PageX=-1.000000
     VisibleRadius=8128.000000
     WorldMax=5242880.000000
     WorldHalf=2621440.000000
     MaxScale=8.000000
     MinScale=0.600000
     Scale=4.000000
     C_LowMonster=(B=224,G=193,R=48,A=255)
     C_MiddleMonster=(G=132,R=255,A=255)
     C_HighMonster=(G=18,R=255,A=255)
     C_Npc=(B=255,G=255,R=255,A=255)
     C_Hero=(B=255,G=164,R=209,A=255)
     C_Party=(B=42,G=221,A=255)
     C_MatchStone=(G=180,R=128,A=255)
     ColorDiffA=(G=18,R=255,A=255)
     ColorDiffB=(G=132,R=255,A=255)
     ColorDiffC=(B=255,R=255,A=255)
     ColorDiffD=(G=255,R=255,A=255)
     ColorDiffE=(B=224,G=193,R=48,A=255)
     ColorDiffF=(B=128,G=128,R=128,A=255)
     AvailMapPos(0)="11110100000"
     AvailMapPos(1)="11110100000"
     AvailMapPos(2)="11000100000"
     AvailMapPos(3)="11000100000"
     AvailMapPos(4)="00000000000"
     AvailMapPos(5)="00000000000"
     AvailMapPos(6)="00000000000"
     AvailMapPos(7)="10000000000"
     AvailMapPos(8)="00100000000"
     AvailMapPos(9)="00000000000"
     AvailMapPos(10)="00000000000"
     AvailMapPos(11)="00000000000"
     AvailMapPos(12)="00000000000"
     AvailMapPos(13)="00111000000"
     AvailMapPos(14)="10111111111"
     AvailMapPos(15)="00111111111"
     AvailMapPos(16)="11111111111"
     AvailMapPos(17)="11111111111"
     ScaleSpeed=0.300000
     DisplayFont=Font'FontKor.NanumGothicEx'
     Components(0)=(XL=144.000000,YL=145.000000)
     Components(1)=(Id=1,XL=128.000000,YL=128.000000)
     Components(2)=(Id=2,ResId=1,Type=RES_Image,XL=144.000000,YL=144.000000,PivotDir=PVT_Copy)
     Components(3)=(Id=3,Type=RES_PushButton,XL=27.000000,YL=27.000000,PivotDir=PVT_Copy,OffsetXL=119.000000,OffsetYL=89.000000,ToolTip="ScaleUpMinimap")
     Components(4)=(Id=4,Type=RES_PushButton,XL=27.000000,YL=27.000000,PivotDir=PVT_Copy,OffsetXL=104.000000,OffsetYL=109.000000,ToolTip="ScaleDownMinimap")
     Components(5)=(Id=5,ResId=2,Type=RES_Image,XL=145.000000,YL=144.000000,PivotDir=PVT_Copy,bRotating=True)
     Components(6)=(Id=6,ResId=10,Type=RES_Image,XL=157.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=-6.000000,OffsetYL=-23.000000)
     TextureResources(0)=(Package="UI_2009",Path="Win07_2",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="mini_win_out",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="mini_win_in",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_-_n",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_-_o",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_-_c",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_+_n",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_+_o",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_+_c",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="mini_bg_d",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="mini_bg_u",Style=STY_Alpha)
     TextureResources(11)=(Package="HUD_2011",Path="zone_bg",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="icon_excl_g",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="icon_excl_y",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="icon_excl_b",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="icon_que_g",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011",Path="icon_que_y",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011",Path="icon_que_b",Style=STY_Alpha)
     WinWidth=152.000000
     WinHeight=170.000000
     IsBottom=True
}
