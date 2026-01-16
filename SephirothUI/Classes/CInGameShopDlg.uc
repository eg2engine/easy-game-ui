class CInGameShopDlg extends CInterface;

const BN_OK = 0;

const TYPE_BUY = 0;
const TYPE_APPLY = 1;
const TYPE_CANCEL = 2;

var CInterface NotifyLink;

var string m_sTitle;
var string m_sDesc;

static function CInGameShopDlg OnDlg(CMultiInterface Parent, int nType, int nResult)
{
	local CInGameShopDlg dlg;

	dlg = CInGameShopDlg(Parent.Controller.HudInterface.AddInterface("SephirothUI.CInGameShopDlg", true));
	if(dlg != None)
	{
		dlg.ShowInterface();
		dlg.NotifyLink = Parent;
		dlg.SetData(nType, nResult);
		Parent.bIgnoreKeyEvents = true;
	}

	return dlg;
}

function CloseDlg()
{
	NotifyLink.bIgnoreKeyEvents = false;
	HideInterface();
	CMultiInterface(Parent).RemoveInterface(Self);
}

function SetData(int nType, int nResult)
{
	m_sTitle = Localize("InGameShopBox","Notice","SephirothUI");

	if(nType == TYPE_BUY)
	{
		m_sDesc = Localize("InGameShopBox","ResBuy" $ nResult,"SephirothUI");	
	}
	else if(nType == TYPE_APPLY)
	{
		m_sDesc = Localize("InGameShopBox","ResApp" $ nResult,"SephirothUI");	
	}
	else if(nType == TYPE_CANCEL)
	{
		m_sDesc = Localize("InGameShopBox","ResCan" $ nResult,"SephirothUI");	
	}
	
	if(m_sDesc == "")
		m_sDesc = Localize("InGameShopBox","ResCan1" $ nResult,"SephirothUI");
}

function OnInit()
{
	bTopMost = true;

	SetComponentTextureId(Components[1],1,-1,3,2);
	SetComponentNotify(Components[1],BN_OK,Self);
	
	m_sTitle = Localize("InGameShopBox","Notice","SephirothUI");
}

function OnFlush()
{
	Parent.bIgnoreKeyEvents = false;
}

function Layout(Canvas C)
{
	local int i;

	MoveComponent(Components[0], true, (C.ClipX - Components[0].XL) / 2, (C.ClipY - Components[0].YL) / 2);
	for(i=1; i<Components.Length; i++)
		MoveComponent(Components[i]);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) 
	{
	case BN_OK:
		CloseDlg();
		break;
	}
}

function OnPreRender(Canvas C)
{

}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local int X, Y;
	local int nDown;
	local string sTemp;
	local array<string> sTempList;
	
	X = Components[0].X;
	Y = Components[0].Y;

	// ≈∏¿Ã∆≤
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(238,219,160,255);
	C.DrawKoreanText(m_sTitle, X, Y+16, Components[0].XL, 16);

	C.SetDrawColor(255,255,255);
	sTemp = m_sDesc;
	C.WrapStringToArray(sTemp, sTempList, Components[0].XL, "|");
	
	nDown = (3 / sTempList.Length) * 16;
	for(i=0; i<sTempList.Length; i++)
	{
		C.DrawKoreanText(sTempList[i], X, Y+55+(i*16)+nDown, Components[0].XL, 16);
	}

	C.SetDrawColor(255,255,255);
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=246.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="Ok",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=78.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Commands")
     TextureResources(0)=(Package="UI_2011",Path="win_pop_s",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
}
