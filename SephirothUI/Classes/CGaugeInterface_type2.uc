class CGaugeInterface_type2 extends CGaugeInterface
	config(SephirothUI);
/***********************
	CGaugeInterface_Type2

	PushComponentVector() of parent class(CGaugeInterface) handles updating HP/MP/Stamina status bar, dynamically.
	
	- 2009.11.10.Sinhyub
************************/

function OnInit()
{
	Components[0].bVisible = false;		//modified by yj  추후에 수정

	// hp gauge
	UpdateHPGauge();
	bOnSimpleMode = false;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta){	return false; }

function Layout(Canvas C)
{
	local int i;

	if(bNeedLayoutUpdate) {
		PageX = C.ClipX/2 - Components[0].XL/2 -7;
		PageY = C.ClipY - Components[0].YL -20;
		MoveComponent(Components[0],true,PageX,PageY,WinWidth,WinHeight);
		for (i=1;i<Components.Length;i++)
			MoveComponent(Components[i]);

		bNeedLayoutUpdate = false;
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
	
	
	manaState = SephirothPlayer(PlayerOwner).PSI.ManaState;
	if( manaState != ManaNormal ){
		switch( manaState ){
			case ManaSaver:
				BindTextureResource(Components[2],TextureResources[4]);
				break;
			case ManaRebirth:
				BindTextureResource(Components[2],TextureResources[5]);
				break;
		}
	}	
}

function UpdateManaGauge()
{
	switch(SephirothPlayer(PlayerOwner).PSI.ManaState){
	case ManaNormal:
		BindTextureResource(Components[2],TextureResources[2]);
		break;
	case ManaSaver:
		BindTextureResource(Components[2],TextureResources[4]);
		break;
	case ManaRebirth:
		BindTextureResource(Components[2],TextureResources[5]);
		break;		
	}
	bNeedLayoutUpdate = true;
}

// keios - hp 색의 변경
function UpdateHPGauge()
{
	switch(SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect)
	{
	case GAUGEEFFECT_NORMAL:
		BindTextureResource(Components[1], TextureResources[1]);
		break;
	case GAUGEEFFECT_POISON:
		BindTextureResource(Components[1], TextureResources[6]);
		break;
	}
	bNeedLayoutUpdate = true;
}

function bool pointCheck(){	return false; }

defaultproperties
{
     Components(0)=(XL=86.000000,YL=85.000000)
     Components(1)=(Id=1,ResId=1,Type=RES_Gauge,XL=43.000000,YL=85.000000,PivotDir=PVT_Copy,GaugeDir=GDT_Up)
     Components(2)=(Id=2,ResId=2,Type=RES_Gauge,XL=43.000000,YL=85.000000,PivotId=1,PivotDir=PVT_Right,OffsetXL=3.000000,GaugeDir=GDT_Up)
     Components(3)=(Id=3,ResId=3,Type=RES_Gauge,XL=4.000000,YL=85.000000,PivotId=1,PivotDir=PVT_Right,GaugeDir=GDT_Up)
     TextureResources(0)=(Package="UI_2009",Path="Gauge.Gauge1",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="Gauge2_HP",UL=43.000000,VL=85.000000,Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="Gauge2_MP",UL=43.000000,VL=85.000000,Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="Gauge2_ST",UL=4.000000,VL=85.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2009",Path="Gauge2_MP1",UL=43.000000,VL=85.000000,Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2009",Path="Gauge2_MP2",UL=43.000000,VL=85.000000,Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2009",Path="Gauge2_HP1",UL=43.000000,VL=85.000000,Style=STY_Alpha)
     WinWidth=86.000000
     WinHeight=85.000000
}
