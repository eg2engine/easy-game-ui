class CSubInventorySelectBox extends CInterface;

//-----------------------------------------------------------
//
//-----------------------------------------------------------
const BN_SUBINVEN0 = 1;
const BN_SUBINVEN1 = 2;
const BN_SUBINVEN2 = 3;

var int PosX;
var int PosY;

var texture testtexture[3];
var string m_sTitle;

function OnInit()
{
    //SubInventory 버튼 0,1,2
    SetComponentTextureId(Components[2],1,0,9,2);
    SetComponentTextureId(Components[3],1,0,9,2);
    SetComponentTextureId(Components[4],1,0,9,2);

    SetComponentNotify(Components[2],BN_SUBINVEN0,self);
    SetComponentNotify(Components[3],BN_SUBINVEN1,self);
    SetComponentNotify(Components[4],BN_SUBINVEN2,self);
/*
    SetComponentText(Components[2],Localize("InventoryUI", "Open", "SephirothUI"));
    SetComponentText(Components[3],Localize("InventoryUI", "Open", "SephirothUI"));
    SetComponentText(Components[4],Localize("InventoryUI", "Open", "SephirothUI"));
*/
 	SetComponentTextureId(Components[5],0,0,9,0);
 	SetcomponentTextureId(Components[6],0,0,9,0);
 	SetcomponentTextureId(Components[7],0,0,9,0);

 	SetComponentNotify(Components[5],BN_SUBINVEN0,self);
 	SetComponentNotify(Components[6],BN_SUBINVEN1,self);
 	SetComponentNotify(Components[7],BN_SUBINVEN2,self);

	SetComponentText(Components[2],Localize("InventoryUI","SubInvenName1","SephirothUI"));
	SetComponentText(Components[3],Localize("InventoryUI","SubInvenName2","SephirothUI"));
	SetComponentText(Components[4],Localize("InventoryUI","SubInvenName3","SephirothUI"));

    PosX =0;
    PosY =0;
    bNeedLayoutUpdate = true;

	m_sTitle = Localize("CSubBag","Title","SephirothUI");

	SephirothInterface(PlayerOwner.myHud).SubSelectBox = Self;
	UpdateOpenButtons();

	InitSubInventories();
}

function InitSubInventories()
{
	// 기존에 열려있던 확장인벤은 같이 열어준다.
	local SephirothInterface SepInterface;
	SepInterface = SephirothInterface(PlayerOwner.myHud);
	if(SepInterface.bSubInven0_On)
//	{
		SephirothPlayer(PlayerOwner).Net.NotiSubInvenOpen(0);
//		SetComponentText(Components[2],Localize("InventoryUI", "Close", "SephirothUI"));
//	}
//	else
//		SetComponentText(Components[2],Localize("InventoryUI", "Open", "SephirothUI"));
	if(SepInterface.bSubInven1_On)
//	{
		SephirothPlayer(PlayerOwner).Net.NotiSubInvenOpen(1);
//		SetComponentText(Components[3],Localize("InventoryUI", "Close", "SephirothUI"));
//	}
//	else
//		SetComponentText(Components[3],Localize("InventoryUI", "Open", "SephirothUI"));
	if(SepInterface.bSubInven2_On)
//	{
		SephirothPlayer(PlayerOwner).Net.NotiSubInvenOpen(2);
//		SetComponentText(Components[4],Localize("InventoryUI", "Close", "SephirothUI"));
//	}
//	else
//		SetComponentText(Components[4],Localize("InventoryUI", "Open", "SephirothUI"));
}

function MoveWindow(int X, int Y)
{
    PosX = X;
    PosY = Y;
    bNeedLayoutUpdate = true;
}

function Layout(Canvas C)
{
    local int i;
    if(bNeedLayoutUpdate)
    {
		PosX = C.ClipX-Components[0].XL;
        MoveComponent(Components[0],true,PosX,PosY);
        for( i=1; i<Components.Length;i++)
            MoveComponent(Components[i],false);
        bNeedLayoutUpdate = false;
    }
}

function UpdateOpenButtons()
{
	local int i;
	local bool bButtonValidity;
	local PlayerServerInfo PSI;
	PSI = SephirothPlayer(PlayerOwner).PSI;

//	local PlayerServerInfo mPSI;
//	mPSI = (SephirotyPlayer(PlayerOwner).PSI);
	for(i=0; i<3; i++)
	{
		bButtonValidity = PSI.SubInventories[i].IsValid();
// 		ButtonIndex = i+2;
//	EnableComponent(Components[ButtonIndex], bButtonValidity);
// 		EnableComponent(Components[ButtonIndex], true);

		SetBagTexture(i, bButtonValidity);
	}
}

function SetBagTexture(int Index, bool bValid)
{
	local int ButtonTextureID, ButtonComponentID;
	ButtonComponentID = 5+Index;
	ButtonTextureID = 3+Index*2;
	if(bValid)
	{
		Components[ButtonComponentID].bVisible =true;
		SetComponentTextureId(Components[ButtonComponentID], ButtonTextureID,0,ButtonTextureID,ButtonTextureID+1);
	}
	else
	{
		Components[ButtonComponentID].bVisible =false;
	//	SetComponentTextureId(Components[ButtonComponentID], 0,0,0,0);
	}
}

function OnPostRender(HUD H, Canvas C)
{
	DrawTitle(C, m_sTitle);
}

function OnSubInvenButtonEvent(int index)
{
	if( SephirothInterface(PlayerOwner.myHud).SubInventoryTrigger(index) )
		return;
	else
		return;
}

function Notifycomponent(int CmpId, int NotifyId, optional string Command)
{
    switch(NotifyId)
    {
    case BN_SUBINVEN0:
		//열었을경우 True반환.
		OnSubInvenButtonEvent(0);
        break;
    case BN_SUBINVEN1:
		OnSubInvenButtonEvent(1);
        break;
    case BN_SUBINVEN2:
		OnSubInvenButtonEvent(2);
        break;
    }
}

function OnFlush()
{
	local SephirothInterface SepInterface;

	// 열려진 SelectBox가 없어질 테니까
	SephirothInterface(PlayerOwner.myHud).SubSelectBox = None;

	// 확장인벤토리가 열려있는지 유무를 저장. 인벤토리 열때 함께 열어주기 위해서.
	SepInterface = SephirothInterface(PlayerOwner.myHud);

	SepInterface.bSubInven0_On = (SepInterface.SubInventories[0]!=None);
	SepInterface.bSubInven1_On = (SepInterface.SubInventories[1]!=None);
	SepInterface.bSubInven2_On = (SepInterface.SubInventories[2]!=None);

	SaveConfig();
}

function bool IsCursorInsideInterface()
{
	if(IsCursorInsideComponent(Components[0]))
	{
		Parent.bFocused = false;
		return true;
	}
	//else
		
	return false;
}

defaultproperties
{
     testtexture(0)=Texture'UI_2011_btn.btn_brw_s_n'
     testtexture(1)=Texture'UI_2011_btn.btn_brw_s_o'
     testtexture(2)=Texture'UI_2011_btn.btn_brw_s_c'
     Components(0)=(XL=280.000000,YL=133.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=280.000000,YL=133.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_PushButton,XL=62.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=34.000000,OffsetYL=91.000000,TextAlign=TA_MiddleCenter,TextColor=(G=255,R=255,A=255))
     Components(3)=(Id=3,Type=RES_PushButton,XL=62.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=109.000000,OffsetYL=91.000000,TextAlign=TA_MiddleCenter,TextColor=(G=255,R=255,A=255))
     Components(4)=(Id=4,Type=RES_PushButton,XL=62.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=184.000000,OffsetYL=91.000000,TextAlign=TA_MiddleCenter,TextColor=(G=255,R=255,A=255))
     Components(5)=(Id=5,Type=RES_PushButton,XL=50.000000,YL=50.000000,PivotDir=PVT_Copy,OffsetXL=42.000000,OffsetYL=39.000000)
     Components(6)=(Id=6,Type=RES_PushButton,XL=50.000000,YL=50.000000,PivotId=5,PivotDir=PVT_Right,OffsetXL=25.000000)
     Components(7)=(Id=7,Type=RES_PushButton,XL=50.000000,YL=50.000000,PivotId=6,PivotDir=PVT_Right,OffsetXL=25.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_bag",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_s_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_s_o",Style=STY_Alpha)
     TextureResources(3)=(Package="ItemSpritesM",Path="Market_Bag_Ruby_N",Style=STY_Alpha)
     TextureResources(4)=(Package="ItemSpritesM",Path="Market_Bag_Ruby_O",Style=STY_Alpha)
     TextureResources(5)=(Package="ItemSpritesM",Path="Market_Bag_Sapphire_N",Style=STY_Alpha)
     TextureResources(6)=(Package="ItemSpritesM",Path="Market_Bag_Sapphire_O",Style=STY_Alpha)
     TextureResources(7)=(Package="ItemSpritesM",Path="Market_Bag_Topaz_N",Style=STY_Alpha)
     TextureResources(8)=(Package="ItemSpritesM",Path="Market_Bag_Topaz_O",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_brw_s_c",Style=STY_Alpha)
}
