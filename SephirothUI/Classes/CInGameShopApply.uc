class CInGameShopApply extends CInterface;

const BN_YES = 0;
const BN_NO = 1;
const BN_UNAPPLY = 2;
const BN_UN_YES = 3;
const BN_UN_NO = 4;

var string m_sDesc;
var string m_sWorning;
var string m_sCaution;
var string m_sRequest;

var CInterface NotifyLink;
var int RT_APPLY;
var int RT_UNAPPLY;
var int RT_CLOSE;

enum eDlgMode
{
	eNormal,
	eUnApply,
};

var eDlgMode m_DlgMode;

static function CInGameShopApply OnDlg(CMultiInterface Parent)
{
	local CInGameShopApply dlg;

	dlg = CInGameShopApply(Parent.Controller.HudInterface.AddInterface("SephirothUI.CInGameShopApply", true));
	if(dlg != None)
	{
		dlg.ShowInterface();
		dlg.NotifyLink = Parent;
		Parent.bIgnoreKeyEvents = true;
	}

	return dlg;
}

function CloseDlg()
{
	NotifyLink.bIgnoreKeyEvents = false;
	NotifyLink.NotifyComponent(0, RT_CLOSE);
	HideInterface();
	CMultiInterface(Parent).RemoveInterface(Self);
}

function OnInit()
{
	bTopMost = true;

	SetComponentTextureId(Components[1],1,-1,3,2);
	SetComponentNotify(Components[1],BN_YES,Self);

	SetComponentTextureId(Components[2],1,-1,3,2);
	SetComponentNotify(Components[2],BN_NO,Self);

	SetComponentTextureId(Components[3],1,-1,3,2);
	SetComponentNotify(Components[3],BN_UNAPPLY,Self);
	EnableComponent(Components[3], false);

	SetComponentTextureId(Components[4],1,-1,3,2);
	SetComponentNotify(Components[4],BN_UN_YES,Self);

	SetComponentTextureId(Components[5],1,-1,3,2);
	SetComponentNotify(Components[5],BN_UN_NO,Self);

	m_sDesc = Localize("InGameShopBox","Move","SephirothUI");
	m_sWorning = Localize("InGameShopBox","Warning","SephirothUI");
	m_sCaution = Localize("InGameShopBox","Caution","SephirothUI");
	m_sRequest = Localize("InGameShopBox","Request","SephirothUI");

	// normal 로
	m_DlgMode = eNormal;
	VisibleComponent(Components[4], false);	// 
	VisibleComponent(Components[5], false);	// 
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
	case BN_YES:
		NotifyLink.NotifyComponent(0, RT_APPLY);
		CloseDlg();
		break;

	case BN_NO:
		NotifyLink.NotifyComponent(0, RT_CLOSE);
		CloseDlg();
		break;

	case BN_UNAPPLY:
		ChangeMode(false);	// unapply mode 로
		break;

	// unapply mode 에서만 선택 가능한 버튼
	case BN_UN_YES:
		NotifyLink.NotifyComponent(0, RT_UNAPPLY);
		CloseDlg();
		break;

	case BN_UN_NO:
		ChangeMode(true);
		break;
	}
}

function OnPreRender(Canvas C)
{

}

function OnPostRender(HUD H, Canvas C)
{
	local int X, Y;

	X = Components[0].X;
	Y = Components[0].Y;

	if(m_DlgMode == eNormal)
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.SetDrawColor(255,255,255,255);
		C.DrawKoreanText(m_sDesc, X+39, Y+45, 360, 16);

		C.DrawKoreanText(m_sWorning, X+39, Y+77, 360, 16);

		C.SetDrawColor(254,100,100);
		C.DrawKoreanText(m_sCaution, X+39, Y+109, 360, 16);
	}
	else if(m_DlgMode == eUnApply)
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		C.SetDrawColor(255,255,255,255);
		C.DrawKoreanText(m_sRequest, X+39, Y+77, 360, 16);
	}

	C.SetDrawColor(255,255,255);
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

function ChangeMode(bool bNormal)
{
	if(bNormal)
	{
		m_DlgMode = eNormal;
		VisibleComponent(Components[1], true);
		VisibleComponent(Components[2], true);
		VisibleComponent(Components[3], true);
		VisibleComponent(Components[4], false);	// 
		VisibleComponent(Components[5], false);	// 
	}
	else
	{
		m_DlgMode = eUnApply;
		VisibleComponent(Components[1], false);
		VisibleComponent(Components[2], false);
		VisibleComponent(Components[3], false);
		VisibleComponent(Components[4], true);	// 
		VisibleComponent(Components[5], true);	// 
	}
}

defaultproperties
{
     RT_APPLY=1000
     RT_UNAPPLY=2000
     RT_CLOSE=100
     Components(0)=(Type=RES_Image,XL=406.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="Yes",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=59.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
     Components(2)=(Id=2,Caption="No",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=159.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
     Components(3)=(Id=3,Caption="UnApply",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=259.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
     Components(4)=(Id=4,Caption="Yes",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=59.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
     Components(5)=(Id=5,Caption="No",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=259.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
     TextureResources(0)=(Package="UI_2011",Path="win_pop_l",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
}
