class SimpleInterface extends CMultiInterface
	config(SephirothUI);

#exec texture import name=Keymap file=Textures/Keymap.tga mips=off flags=2

var SephirothInventory SepInventory;

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;
var array<Color> EdgeColors;

var globalconfig bool bCanMove;

const ManaNormal = 0;
const ManaSaver = 1;
const ManaRebirth = 2;

//---------------------------
// keios - gauge effect

// hp texture
const TEX_HPNORMAL = 1;
const TEX_HPPOISON = 7;

// hp ui id
const ID_HP = 1;

// effect id
const GAUGEEFFECT_NORMAL = 0;
const GAUGEEFFECT_POISON = 1;
//---------------------------


function OnInit()
{
	SepInventory = SephirothPlayer(PlayerOwner).PSI.SepInventory;

	if(PageX == -1)
		ResetDefaultPosition();
	// hp gauge
	UpdateHPGauge();
}

function OnFlush()
{
	SaveConfig();
}

function Layout(Canvas C)
{
	local int DX, DY;
	if (bIsDragging) {
		DX = Controller.MouseX - DragOffsetX;
		DY = Controller.MouseY - DragOffsetY;
		PageX = DX;
		PageY = DY;
		if (PageX < 32)
			PageX = 0;
		if (PageY < 64)
			PageY = 32;
		if (PageX + WinWidth > C.ClipX - 32)
			PageX = C.ClipX - WinWidth;
		if (PageY + WinHeight > C.ClipY - 32)
			PageY = C.ClipY - WinHeight;
		//â���� �Ѿ� ��������� Dragging(�巡�� �̵�)�� ���������
		if ( (PageX < 0) || (PageX + WinWidth > C.ClipX) || (PageY < 0) || (PageY + WinHeight > C.ClipY) )
		{
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			PageX = C.ClipX - WinWidth;
			PageY = C.ClipY - WinHeight;	
		}
	}
	MoveComponent(Components[0],true,PageX,PageY,WinWidth,WinHeight);
	MoveComponentId(1);
	MoveComponentId(2);
	MoveComponentId(3);
	MoveComponentId(4);
}

function OnPreRender(Canvas C)
{
	local float X,Y,Width,Height;
	local int manaState;

	if (bCanMove && IsCursorInsideComponent(Components[0]) && Controller.bLButtonDown && Controller.ContextMenu == None) {
		X = Components[0].X - 3;
		Y = Components[0].Y - 35;
		Width = Components[0].XL + 6;
		Height = Components[0].YL + 6 + 32;

		C.SetRenderStyleAlpha();
		C.SetPos(X, Y);
		C.DrawTile(Texture'TextBlackBg',Width, Height,0,0,4,4);

		class'CNativeInterface'.static.DrawLine(X,Y,X+Width,Y,EdgeColors[0]);
		class'CNativeInterface'.static.DrawLine(X+Width,Y,X+Width,Y+Height,EdgeColors[0]);
		class'CNativeInterface'.static.DrawLine(X,Y+Height,X+Width,Y+Height,EdgeColors[0]);
		class'CNativeInterface'.static.DrawLine(X,Y,X,Y+Height,EdgeColors[0]);
	}

	SephirothInterface(Parent).MiniShortcutOffset(C.ClipX - (PageX + WinWidth), C.ClipY - Components[0].Y);

	X = Components[0].X;
	Y = Components[0].Y;

	C.Style = ERenderStyle.STY_Normal;
	C.SetPos(X,Y+8);
	C.DrawTile(TextureResources[0].Resource,128,12,0,0,128,12);
	C.SetPos(X,Y+28);
	C.DrawTile(TextureResources[0].Resource,128,12,0,0,128,12);
	C.SetPos(X,Y+48);
	C.DrawTile(TextureResources[0].Resource,128,12,0,0,128,12);
	C.SetPos(X,Y+68);
	C.DrawTile(TextureResources[0].Resource,128,12,0,0,128,12);

	manaState = SephirothPlayer(PlayerOwner).PSI.ManaState;
	if( manaState != ManaNormal ){
		switch(manaState){
			case ManaSaver:
				BindTextureResource(Components[2],TextureResources[5]);
				break;
			case ManaRebirth:
				BindTextureResource(Components[2],TextureResources[6]);
				break;
		}
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,XL,YL;
	local PlayerServerInfo PSI;
	local string Str;
	local color OldColor;

	OldColor = C.DrawColor;

	X = Components[0].X;
	Y = Components[0].Y;
	PSI = ClientController(PlayerOwner).PSI;

	Str = Localize("Tooltip","ShowHealth","Sephiroth") $ " " $ PSI.Health$"/"$PSI.MaxHealth;
	C.TextSize(Str,XL,YL);
//	C.SetPos(X+(128-XL)/2,Y);
//	C.DrawTile(Controller.BackgroundBlend,XL,14,0,0,0,0);
	C.SetDrawColor(0,0,0);
	C.DrawKoreanText(Str,X+(128-XL)/2+1,Y+1,XL,14);
	C.DrawColor = OldColor;
	C.DrawKoreanText(Str,X+(128-XL)/2,Y,XL,14);

	Str = Localize("Tooltip","ShowMana","Sephiroth") $ " " $ PSI.Mana$"/"$PSI.MaxMana;
	C.TextSize(Str,XL,YL);
//	C.SetPos(X+(128-XL)/2,Y+20);
//	C.DrawTile(Controller.BackgroundBlend,XL,14,0,0,0,0);
	C.SetDrawColor(0,0,0);
	C.DrawKoreanText(Str,X+(128-XL)/2+1,Y+20+1,XL,14);
	C.DrawColor = OldColor;
	C.DrawKoreanText(Str,X+(128-XL)/2,Y+20,XL,14);

	Str = Localize("Tooltip","ShowStamina","Sephiroth") $ " " $ int(PSI.Stamina)$"/"$int(PSI.MaxStamina);
	C.TextSize(Str,XL,YL);
//	C.SetPos(X+(128-XL)/2,Y+40);
//	C.DrawTile(Controller.BackgroundBlend,XL,14,0,0,0,0);
	C.SetDrawColor(0,0,0);
	C.DrawKoreanText(Str,X+(128-XL)/2+1,Y+40+1,XL,14);
	C.DrawColor = OldColor;
	C.DrawKoreanText(Str,X+(128-XL)/2,Y+40,XL,14);

	Str = "Lv " $ PSI.PlayLevel $ "  " $ Localize("Tooltip","ShowExp","Sephiroth") $ " " $ PSI.ExpDisplay $ "%";
	C.TextSize(Str,XL,YL);
//	C.SetPos(X+(128-XL)/2,Y+60);
//	C.DrawTile(Controller.BackgroundBlend,XL,14,0,0,0,0);
	C.SetDrawColor(0,0,0);
	C.DrawKoreanText(Str,X+(128-XL)/2+1,Y+60+1,XL,14);
	C.DrawColor = OldColor;
	C.DrawKoreanText(Str,X+(128-XL)/2,Y+60,XL,14);
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	switch (CmpId) {
	case 1: // Health
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Health;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxHealth;
		break;
	case 2: // Mana
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Mana;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxMana;
		break;
	case 3: // Stamina
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Stamina;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxStamina;
		break;
	case 4: // Exp
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
		V.Z = 100.0;
		break;
	}
	return V;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local CTextMenu TextMenu;
	local string ContextString;

	if (bCanMove && Key == IK_LeftMouse) {// && IsCursorInsideComponent(Components[0]) ���Ǻθ� ��. (2009.10.27.Sinhyub
		if ( (Action == IST_Press)&&IsCursorInsideComponent(Components[0])) {	//Sinhyub
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		if (Action == IST_Release && bIsDragging ){ // && !SephirothInterface(Parent).bDraggingControl) 2009.10.27.sinhyub
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
	if (!Controller.bLButtonDown && Key == IK_RightMouse&& IsCursorInsideComponent(Components[0]) ) {
		if (bCanMove)
			ContextString = Localize("ContextMenu","FixedMenu","Sephiroth");
		else
			ContextString = Localize("ContextMenu","FloatingMenu","Sephiroth");
		TextMenu = PopupContextMenu(ContextString, Controller.MouseX, Controller.MouseY);
		if (TextMenu != None)
			TextMenu.OnTextMenu = InternalTextMenu;
		return true;
	}

	return false;
}

function InternalTextMenu(int Index, string Text)
{
	if (Index == 0)
		bCanMove = !bCanMove;
}

function bool PointCheck()
{
	if (bCanMove || Controller.ContextMenu != None)
		return Super.PointCheck();
	return false;
}

//ksshim + 2004.8.23
function ChangeManaBar()
{
	switch(SephirothPlayer(PlayerOwner).PSI.ManaState){
	case ManaNormal:
		BindTextureResource(Components[2],TextureResources[2]);
		break;
	case ManaSaver:
		BindTextureResource(Components[2],TextureResources[5]);
		break;
	case ManaRebirth:
		BindTextureResource(Components[2],TextureResources[6]);
		break;		
	}
}
//ksshim END

// keios - hp ���� ����
function UpdateHPGauge()
{
	switch(SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect)
	{
	case GAUGEEFFECT_NORMAL:
		BindTextureResource(Components[ID_HP], TextureResources[TEX_HPNORMAL]);
		break;
	case GAUGEEFFECT_POISON:
		BindTextureResource(Components[ID_HP], TextureResources[TEX_HPPOISON]);
		break;
	}
}

function ResetDefaultPosition()		//2009.10.27.Sinhyub
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");	
	pos = InStr(Resolution, "x");

	ClipX=int(Left(Resolution, pos));		
	ClipY=int(Mid(Resolution,pos+1));

	PageX = (ClipX - WinWidth)/2;
	PageY = ClipY - WinHeight;

	SaveConfig();
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     EdgeColors(0)=(B=113,G=113,R=114,A=255)
     EdgeColors(1)=(B=48,G=50,R=55,A=255)
     EdgeColors(2)=(B=16,G=19,R=20,A=255)
     Components(0)=(XL=128.000000,YL=80.000000)
     Components(1)=(Id=1,ResId=1,Type=RES_Gauge,XL=125.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=1.000000,OffsetYL=8.000000,GaugeDir=GDT_Right)
     Components(2)=(Id=2,ResId=2,Type=RES_Gauge,XL=125.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=1.000000,OffsetYL=28.000000,GaugeDir=GDT_Right)
     Components(3)=(Id=3,ResId=3,Type=RES_Gauge,XL=125.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=1.000000,OffsetYL=48.000000,GaugeDir=GDT_Right)
     Components(4)=(Id=4,ResId=4,Type=RES_Gauge,XL=125.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=1.000000,OffsetYL=68.000000,GaugeDir=GDT_Right)
     TextureResources(0)=(Package="UI",Path="Info.GaugeBg",Style=STY_Normal)
     TextureResources(1)=(Package="UI",Path="Info.HealthSimple",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(2)=(Package="UI",Path="Info.ManaSimple",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(3)=(Package="UI",Path="Info.Stamina",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI",Path="Info.Exp",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(5)=(Package="UI",Path="Info.SavManaSimple",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(6)=(Package="UI",Path="Info.RebManaSimple",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     TextureResources(7)=(Package="UI",Path="Info.PoisonHealth",UL=125.000000,VL=12.000000,Style=STY_Alpha)
     WinWidth=128.000000
     WinHeight=80.000000
}
