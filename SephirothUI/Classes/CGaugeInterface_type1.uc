class CGaugeInterface_type1 extends CGaugeInterface
	config(SephirothUI);
/************************
	CGaugeInterface_Type1

	1. Position of this interface unit can be translated.
	2. can be rotated (actually two different type of gauge bar. Vertical shape and Horizontal shape)

	PushComponentVector() of parent class(CGaugeInterface) handles updating HP/MP/Stamina status bar, dynamically.
	
	- 2009.11.10.Sinhyub
************************/

const BN_ROTATION = 1;

// Type 1 Textures (Horizontal Gauge)
const TEX_TEMPLATE1 = 0;
const TEX_HP1NORMAL = 1;
const TEX_HP1POISON = 6;
const TEX_MP1NORMAL = 2;
const TEX_ST1NORMAL = 3;
const TEX_MP1SAVER = 4;
const TEX_MP1REBIRTH = 5;

// Type 2 Textures (VerticalGauge)
const TEX_TEMPLATE2 = 15;
const TEX_HP2NORMAL = 16;
const TEX_HP2POISON = 21;
const TEX_MP2NORMAL = 17;
const TEX_ST2NORMAL = 18;
const TEX_MP2SAVER = 19;
const TEX_MP2REBIRTH = 20;

const nGaugeType = 2;			//가로형 세로형 두가지경우가있음.	-2009.11.3.Sinhyub
var config int GaugeType;		//가로형(0) 세로형(1) 구분을 위한 변수. (3개 이상일 경우를 대비하여 int사용)

function OnInit()
{
	if(PageX == -1)
		ResetDefaultPosition();
	UpdateGaugeType();

	SetComponentTextureId(Components[4],7,-1,9,10);
	SetComponentNotify(Components[4],BN_ROTATION,Self);
	
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub
	UpdateHPGauge();
	bNeedLayoutUpdate = true;
	bOnSimpleMode = false;	
	bNeedLayoutUpdate = true;
//	ScaleComponents(1.5);
}

function OnFlush(){	SaveConfig(); }

function ScaleComponents(float ScaleX, optional float ScaleY)
{
	local int i;
	for(i=0;i<Components.Length;i++)
		ScaleComponent(Components[i], ScaleX, ScaleY);
}

function bool pointCheck()
{
	if( IsCursorInsideComponent(Components[4])||IsCursorInsideComponent(Components[5]))
		return true;
	return false;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_LeftMouse){
		//이동은 이동 버튼을 이용할 경우에만 가능합니다. -2009.11.1.Sinhyub
		if ((Action == IST_Press)  && IsCursorInsideComponent(Components[5]) )
		{
			BindTextureResource(components[5],TextureResources[13]);
			bIsDragging = true;
			bMovingUI = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			bNeedLayoutUpdate = true;
			return true;
		}
		if (Action == IST_Release && bIsdragging){ //!SephirothInterface(Parent).bDraggingControl) {	//Commentout . 2009.10.27.Sinhyub
			BindTextureResource(components[5],TextureResources[11]);
			SaveConfig();		//modified by yj
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			bNeedLayoutUpdate = true;
			return true;
		}
	}
}

function Layout(Canvas C)
{
	local int DX,DY;
	local int i;	

	if(bMovingUI) {
		if (bIsDragging) {
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else {
			if (PageX < 0)
				PageX = 0;
			else if (PageX + WinWidth > C.ClipX)
				PageX = C.ClipX - WinWidth;
			if (PageY < 0)
				PageY = 0;
			else if (PageY + WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight;
			bMovingUI = false;
		}
		bNeedLayoutUpdate = true;
	}
	if(bNeedLayoutUpdate) {
		MoveComponent(Components[0],true,PageX,PageY,WinWidth,WinHeight);
		for (i=1;i<Components.Length;i++)
			MoveComponent(Components[i]);
		bNeedLayoutUpdate = false;
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch(NotifyId)
	{
	case BN_ROTATION:
		GaugeType = (GaugeType+1)%2;
		UpdateGaugeType();
		SaveConfig();
		break;
	}
}

function OnPreRender(Canvas C)
{
	local float X,Y;
	local PlayerServerInfo PSI;
	local int manaState;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	X = Components[0].X;
	Y = Components[0].Y;
	if(IsCursorInsideComponent(Components[1]))
		Controller.SetTooltip(Localize("Tooltip","ShowHealth","Sephiroth") $ " " $ PSI.Health$"/"$PSI.MaxHealth);
	
	else if(IsCursorInsideComponent(Components[2]))
		Controller.SetTooltip(Localize("Tooltip","ShowMana","Sephiroth") $ " " $ PSI.Mana$"/"$PSI.MaxMana);
	
	else if(IsCursorInsideComponent(Components[3]))
		Controller.SetTooltip(Localize("Tooltip","ShowStamina","Sephiroth") $ " " $ int(PSI.Stamina)$"/"$int(PSI.MaxStamina));

	//Trnaslation Button - Mouse over
	if(IsCursorInsideComponent(Components[5]))
	{
		if(bIsDragging)
			BindTextureResource(Components[5],TextureResources[13]);
		else
			BindTextureResource(Components[5],TextureResources[14]);
	}
	else
		BindTextureResource(Components[5],TextureResources[11]);

	manaState = SephirothPlayer(PlayerOwner).PSI.ManaState;
	if( manaState != ManaNormal ){
		if(GaugeType==0)
		{
			switch( manaState ){
				case ManaSaver:
					BindTextureResource(Components[2],TextureResources[TEX_MP1SAVER]);
					break;
				case ManaRebirth:
					BindTextureResource(Components[2],TextureResources[TEX_MP1Rebirth]);
					break;
			}
		}
		else if(GaugeType==1)
		{
			switch( manaState ){
				case ManaSaver:
					BindTextureResource(Components[2],TextureResources[TEX_MP2SAVER]);
					break;
				case ManaRebirth:
					BindTextureResource(Components[2],TextureResources[TEX_MP2Rebirth]);
					break;
			}
		}
	}	

//	if(SephirothController(Controller).ArmKey == IK_Tilde)
//		Components[6].Hotkey=IK_Tilde;
//	else
//		Components[6].Hotkey=IK_Shift;
}

function OnPostRender(HUD H, Canvas C)
{
	local int tempX,tempY;
	local int TextLength;

	//Draw text of Level, HP, MP and Stamina.		-2009.11.3.Sinhyub
	if(GaugeType==0)
	{
		TextLength = Components[1].X-PageX;
		tempX = PageX+7*Components[0].ScaleX;
		tempY = PageY + 5;
		C.SetDrawColor(255,0,0);
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		C.DrawKoreanText("LV"@SephirothPlayer(PlayerOwner).PSI.PlayLevel,tempX,tempY,Components[0].XL,12);

		C.SetDrawColor(255,255,255);
		C.KTextFormat = ETextAlign.TA_MiddleLeft;
		tempX = PageX+TextLength/2-7 ;
		C.DrawKoreanText("HP",tempX,Components[1].Y+4,TextLength,12);
		C.DrawKoreanText("MP",tempX,Components[2].Y+4,TextLength,12);
		C.DrawKoreanText("ST",tempX,Components[3].Y,TextLength,10);
			
		tempX += TextLength;
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		//C.DrawKoreanText(SephirothPlayer(PlayerOwner).PSI.PlayName,tempX,tempY,Components[1].XL*Components[1].ScaleX,12);
		C.DrawKoreanText(SephirothPlayer(PlayerOwner).PSI.Health$"/"$SephirothPlayer(PlayerOwner).PSI.MaxHealth,Components[1].X,Components[1].Y+1,Components[1].XL*Components[1].ScaleX,Components[1].YL*Components[1].ScaleY);
		C.DrawKoreanText(SephirothPlayer(PlayerOwner).PSI.Mana$"/"$SephirothPlayer(PlayerOwner).PSI.MaxMana,Components[2].X,Components[2].Y+1,Components[2].XL*Components[2].ScaleX,Components[2].YL*Components[2].ScaleY);
		C.DrawKoreanText(int(SephirothPlayer(PlayerOwner).PSI.Stamina)$"/"$int(SephirothPlayer(PlayerOwner).PSI.MaxStamina),Components[3].X,Components[3].Y,Components[3].XL*Components[3].ScaleX,10);//Components[3].YL*Components[3].ScaleY);
	}
	else if(GaugeType==1)
	{
		TextLength = Components[1].X-PageX;
		C.SetDrawColor(255,0,0);
		C.KTextFormat = ETextAlign.TA_MiddleLeft;
		C.DrawKoreanText("LV"@SephirothPlayer(PlayerOwner).PSI.PlayLevel,PageX+10,PageY+113,Components[0].XL,12);
	}
}

/*********************
	UpdateGaugeType()

	Setting position and texture of gauge components.
		1. GaugeType == 0 means Horizontal,
		2. GaugeType == 1 means Vertical.

	게이지 타입에 따라 각기 컴포넌트의 위치와 텍스쳐 이미지, 기타 사항을 재설정해줍니다.
	-2009.11.3.Sinhyub
*********************/
function UpdateGaugeType()
{
	if(GaugeType == 0)
	{
		WinWidth = 190;
		WinHeight = 80;
		//Template
		BindTextureResource(Components[0],TextureResources[TEX_TEMPLATE1]);
		Components[0].XL=WinWidth;
		Components[0].YL=WinHeight;
		//HP Gauge
		BindTextureResource(Components[1],TextureResources[TEX_HP1NORMAL]);
		Components[1].GaugeDir=GDT_Right;
		Components[1].XL=154;
		Components[1].YL=16;
		Components[1].PivotId=0;
		Components[1].PivotDir=PVT_Copy;
		Components[1].OffsetXL=30;
		Components[1].OffsetYL=22;
		//MP Gauge
		BindTextureResource(Components[2],TextureResources[TEX_MP1NORMAL]);
		Components[2].GaugeDir=GDT_Right;
		Components[2].XL=154;
		Components[2].YL=16;
		Components[2].PivotId=1;
		Components[2].PivotDir=PVT_Down;
		Components[2].OffsetYL=5;
		//Stamina Gauge
		BindTextureResource(Components[3],TextureResources[TEX_ST1NORMAL]);
		Components[3].GaugeDir=GDT_Right;
		Components[3].XL=154;
		Components[3].YL=7;
		Components[3].PivotId=2;
		Components[3].PivotDir=PVT_Down;
		Components[3].OffsetYL=5;
		//Buttons
		Components[4].OffsetXL=157;
		Components[4].OffsetYL=1;
		Components[5].PivotDir=PVT_Right;
	}
	else if(GaugeType == 1)
	{
		WinWidth = 88;
		WinHeight = 128;
		//Template
		BindTextureResource(Components[0],TextureResources[TEX_TEMPLATE2]);
		Components[0].XL=WinWidth;
		Components[0].YL=WinHeight;
		//HP Gauge
		BindTextureResource(Components[1],TextureResources[TEX_HP2NORMAL]);
		Components[1].GaugeDir=GDT_Up;
		Components[1].XL=27;
		Components[1].YL=101;
		Components[1].PivotId=0;
		Components[1].PivotDir=PVT_Copy;
		Components[1].OffsetXL=21;
		Components[1].OffsetYL=6;
		//MP Gauge
		BindTextureResource(Components[2],TextureResources[TEX_MP2NORMAL]);
		Components[2].GaugeDir=GDT_Up;
		Components[2].XL=27;
		Components[2].YL=101;
		Components[2].PivotId=1;
		Components[2].PivotDir=PVT_Right;
		Components[2].OffsetXL=5;
		//Stamina Gauge
		BindTextureResource(Components[3],TextureResources[TEX_ST2NORMAL]);
		Components[3].GaugeDir=GDT_Up;
		Components[3].XL=10;
		Components[3].YL=101;
		Components[3].PivotId=0;
		Components[3].PivotDir=PVT_COPY;
		Components[3].OffsetXL=6;
		Components[3].OffsetYL=6;
		//Buttons
		Components[4].OffsetXL=55;
		Components[4].OffsetYL=111;
		Components[5].PivotDir=PVT_Right;
	}

	//Check wheather component is outside of MainFrame(game screen), and modify it. reference Layout()
	bMovingUI = true;

	bNeedLayoutUpdate =true;
}

function UpdateManaGauge()
{
	if(GaugeType==0)
	{
		switch(SephirothPlayer(PlayerOwner).PSI.ManaState){
		case ManaNormal:
			BindTextureResource(Components[2],TextureResources[TEX_MP1NORMAL]);
			break;
		case ManaSaver:
			BindTextureResource(Components[2],TextureResources[TEX_MP1SAVER]);
			break;
		case ManaRebirth:
			BindTextureResource(Components[2],TextureResources[TEX_MP1Rebirth]);
			break;		
		}
	}
	else if(GaugeType==1)
	{
		switch(SephirothPlayer(PlayerOwner).PSI.ManaState){
		case ManaNormal:
			BindTextureResource(Components[2],TextureResources[TEX_MP2NORMAL]);
			break;
		case ManaSaver:
			BindTextureResource(Components[2],TextureResources[TEX_MP2SAVER]);
			break;
		case ManaRebirth:
			BindTextureResource(Components[2],TextureResources[TEX_MP2Rebirth]);
			break;		
		}
	}
}

// keios - hp 색의 변경
function UpdateHPGauge()
{
	if(GaugeType==0)
	{
		switch(SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect)
		{
		case GAUGEEFFECT_NORMAL:
			BindTextureResource(Components[ID_HP], TextureResources[TEX_HP1NORMAL]);
			break;
		case GAUGEEFFECT_POISON:
			BindTextureResource(Components[ID_HP], TextureResources[TEX_HP1POISON]);
			break;
		}
	}
	else if(GaugeType==1)
	{
		switch(SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect)
		{
		case GAUGEEFFECT_NORMAL:
			BindTextureResource(Components[ID_HP], TextureResources[TEX_HP2NORMAL]);
			break;
		case GAUGEEFFECT_POISON:
			BindTextureResource(Components[ID_HP], TextureResources[TEX_HP2POISON]);
			break;
		}
	}
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     Components(0)=(Type=RES_Image,XL=190.000000,YL=80.000000)
     Components(1)=(Id=1,ResId=1,Type=RES_Gauge,XL=154.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=30.000000,OffsetYL=22.000000,GaugeDir=GDT_Right)
     Components(2)=(Id=2,ResId=2,Type=RES_Gauge,XL=154.000000,YL=16.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=5.000000,GaugeDir=GDT_Right)
     Components(3)=(Id=3,ResId=3,Type=RES_Gauge,XL=154.000000,YL=7.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=5.000000,GaugeDir=GDT_Right)
     Components(4)=(Id=4,Type=RES_PushButton,XL=14.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=157.000000,OffsetYL=1.000000)
     Components(5)=(Id=5,ResId=11,Type=RES_Image,XL=16.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Right)
     TextureResources(0)=(Package="UI_2009",Path="Gauge1_1",UL=190.000000,VL=80.000000,Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="Gauge1_1_HP",UL=154.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="Gauge1_1_MP",UL=154.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="Gauge1_1_ST",UL=154.000000,VL=7.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2009",Path="Gauge1_1_MP1",UL=154.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2009",Path="Gauge1_1_MP2",UL=154.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2009",Path="Gauge1_1_HP1",UL=154.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2009",Path="BTN06_13_N",UL=14.000000,VL=14.000000,Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2009",Path="BTN06_13_P",UL=14.000000,VL=14.000000,Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2009",Path="BTN06_13_O",UL=14.000000,VL=14.000000,Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2009",Path="BTN06_04_N",UL=16.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2009",Path="BTN06_04_P",UL=16.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2009",Path="BTN06_04_O",UL=16.000000,VL=16.000000,Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2009",Path="Gauge1_2",UL=88.000000,VL=128.000000,Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2009",Path="Gauge1_2_HP",UL=27.000000,VL=101.000000,Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2009",Path="Gauge1_2_MP",UL=27.000000,VL=101.000000,Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2009",Path="Gauge1_2_ST",UL=10.000000,VL=101.000000,Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2009",Path="Gauge1_2_MP1",UL=27.000000,VL=101.000000,Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2009",Path="Gauge1_2_MP2",UL=27.000000,VL=101.000000,Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2009",Path="Gauge1_2_HP1",UL=27.000000,VL=101.000000,Style=STY_Alpha)
     WinWidth=190.000000
     WinHeight=80.000000
}
