class CInGameShopBuy extends CInterface;

const BN_CLOSE = 0;
const BN_BUY = 1;
const BN_CHARGE = 2;
const BN_REFLASH = 3;

const COOLTIME = 30;

var Texture TxImage;
var string m_sItemName;
var string m_nSephiPrice;
var string m_nPointPrice;
var int m_nCount;


var string m_sSephi;
var string m_sPoint;
var string m_sPics;
var string m_sSec;
var string m_sSephiLow;
var string m_sPointLow;

var CInterface NotifyLink;

var int RT_CLOSE;
var int RT_CHARGE;
var int RT_BUY;

enum eDlgMode
{
	eNormal,
	eReflash,
};

var eDlgMode m_DlgMode;

static function CInGameShopBuy OnDlg(CMultiInterface Parent, int nBuyIndex)
{
	local CInGameShopBuy dlg;

	dlg = CInGameShopBuy(Parent.Controller.HudInterface.AddInterface("SephirothUI.CInGameShopBuy", True));
	if( dlg != None )
	{
		dlg.ShowInterface();
		dlg.NotifyLink = Parent;
		dlg.SetBuyData(nBuyIndex);
		Parent.bIgnoreKeyEvents = True;
	}

	return dlg;
}

function CloseDlg()
{
	NotifyLink.bIgnoreKeyEvents = False;
	NotifyLink.NotifyComponent(0, RT_CLOSE);
	HideInterface();
	CMultiInterface(Parent).RemoveInterface(Self);
}

function SetBuyData(int nIndex)
{
	local GameShopManager.GameShopCatalogueData temp;

	if( nIndex > GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length )
		return ;

	temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[nIndex];
	TxImage = Texture( DynamicLoadObject("InGame_item."$temp.sImage,class'Texture') );
	m_sItemName = temp.sTitle;

	// 使用native函数进行比较，直接使用string类型存储价格（支持大数字）
	// 价格优先级：赛菲价格 > 折扣价格 > 点数价格
	// 折扣价格用点数支付，所以需要正确设置
	if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSephiPrice, "0") > 0 )
	{
		// 有赛菲价格，使用赛菲价格
		m_nSephiPrice = temp.nSephiPrice;
		m_nPointPrice = "0";
	}
	else if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSalePrice, "0") > 0 )
	{
		// 有折扣价格（用点数支付），折扣价格应该放在点数价格字段
		m_nSephiPrice = "0";
		m_nPointPrice = temp.nSalePrice;
	}
	else
	{
		// 只有点数价格
		m_nSephiPrice = "0";
		m_nPointPrice = temp.nPointPrice;
	}

	m_nCount = temp.nCount;
}

function OnInit()
{
	bTopMost = True;

	SetComponentTextureId(Components[1],1, -1,3,2);
	SetComponentNotify(Components[1],BN_BUY,Self);

	SetComponentTextureId(Components[2],1, -1,3,2);
	SetComponentNotify(Components[2],BN_CLOSE,Self);

	SetComponentTextureId(Components[3],1, -1,3,2);
	SetComponentNotify(Components[3],BN_CHARGE,Self);

	SetComponentTextureId(Components[4],1, -1,3,2);
	SetComponentNotify(Components[4],BN_REFLASH,Self);
	VisibleComponent(Components[4], False);	// �ϴ� ���������� ����д�

	m_sSephi = Localize("InGameShop", "PriceSe", "SephirothUI");
	m_sPoint = Localize("InGameShop", "PricePo", "SephirothUI");
	m_sPics = Localize("InGameShop", "Pics", "SephirothUI");
	m_sSec = Localize("InGameShop", "Sec", "SephirothUI");
	
	m_sSephiLow = Localize("InGameShop", "CashLow", "SephirothUI");
	m_sPointLow = Localize("InGameShop", "PointLow", "SephirothUI");

	m_DlgMode = eNormal;
}

function OnFlush()
{
	Parent.bIgnoreKeyEvents = False;
}

function Layout(Canvas C)
{
	local int i;

	MoveComponent(Components[0], True, (C.ClipX - Components[0].XL) / 2, (C.ClipY - Components[0].YL) / 2);
	for( i = 1; i < Components.Length; i++ )
		MoveComponent(Components[i]);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int nSec;

	switch (NotifyId) 
	{
		case BN_CLOSE:
			CloseDlg();
			break;

		case BN_BUY:
			nSec = SephirothPlayer(PlayerOwner).PSI.nCurTime - SephirothPlayer(PlayerOwner).PSI.nLastBuyTime;
			if( nSec > 1 )
			{
				SephirothPlayer(PlayerOwner).PSI.nLastBuyTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
				NotifyLink.NotifyComponent(0, RT_BUY);
				CloseDlg();
			}
			break;

		case BN_CHARGE:
			ChangeMode(False);
			PlayerOwner.ClientTravel(GameManager(Level.Game).GameShopManager.m_PaymentLink,TRAVEL_Absolute,False);
			break;
			break;

		case BN_REFLASH:
			SephirothPlayer(PlayerOwner).PSI.nLastReflashTime = SephirothPlayer(PlayerOwner).PSI.nCurTime;
			SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopCash();
			ChangeMode(True);
			break;
	}
}

function OnPreRender(Canvas C)
{
	if( SephirothPlayer(PlayerOwner).PSI.IsInGameShopBuyAbleString(m_nSephiPrice, m_nPointPrice) )
		EnableComponent(Components[1], True);
	else
		EnableComponent(Components[1], False);
}

function OnPostRender(HUD H, Canvas C)
{
	local int X, Y;
	local int nSec;


	X = Components[0].X;
	Y = Components[0].Y;


	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(238,219,160,255);
	C.DrawKoreanText(Localize("InGameShop","Buy","SephirothUI"), X + 125, Y + 16, 156, 16);


	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(Localize("InGameShop","HelpBuy","SephirothUI"), X + 85, Y + 119, 236, 16);



	C.SetPos(X + 96, Y + 51);
	C.DrawTile(TxImage,40,40,0,0,40,40);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(m_sItemName, X + 145, Y + 47, 157, 16);
	C.SetDrawColor(255,255,255);
	// 使用native函数 CmpInt64 进行比较：返回值 > 0 表示 a > b
	if( SephirothPlayer(PlayerOwner).CmpInt64(m_nSephiPrice, "0") > 0 )
		C.DrawKoreanText(Controller.MoneyColoredString(m_nSephiPrice)$m_sSephi, X + 145, Y + 63, 157, 16);
	else
		C.DrawKoreanText(Controller.MoneyColoredString(m_nPointPrice)$m_sPoint, X + 145, Y + 63, 157, 16);
	C.DrawKoreanText(m_nCount$m_sPics, X + 145, Y + 79, 157, 16);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	nSec = SephirothPlayer(PlayerOwner).PSI.nCurTime - SephirothPlayer(PlayerOwner).PSI.nLastReflashTime;
	if( nSec > COOLTIME )
		EnableComponent(Components[4], True);
	else
	{
		EnableComponent(Components[4], False);
		if( m_DlgMode == eReflash )
			C.DrawKoreanText(COOLTIME - nSec$m_sSec, Components[4].X, Components[4].Y, Components[4].XL, Components[4].YL);	
	}

	C.SetDrawColor(255,255,255);
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

function ChangeMode(bool bNormal)
{
	if( bNormal )
	{
		m_DlgMode = eNormal;
		VisibleComponent(Components[3], True);
		VisibleComponent(Components[4], False);
	}
	else
	{
		m_DlgMode = eReflash;
		VisibleComponent(Components[3], False);
		VisibleComponent(Components[4], True);
	}
}

defaultproperties
{
	RT_CLOSE=100
	RT_CHARGE=200
	RT_BUY=150
	Components(0)=(Type=RES_Image,XL=406.000000,YL=200.000000)
	Components(1)=(Id=1,Caption="Buy",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=64.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	Components(2)=(Id=2,Caption="Cancel",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=254.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	Components(3)=(Id=3,Caption="Charge",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=159.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	Components(4)=(Id=4,Caption="Reflash",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=159.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	TextureResources(0)=(Package="UI_2011",Path="ingame_buy",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
}
