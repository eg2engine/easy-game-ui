class GameShopManager extends Object;


var string m_PaymentLink;

struct  GameShopCatalogueData
{
	var int nIndex;
	var string sTitle;
	var string sDesc;
	var string sImage;
	var int nCategory;
	var int nFlag;
	var string nSephiPrice;
	var string nPointPrice;
	var string nSalePrice;
	var int nCount;
};

var array<GameShopCatalogueData> m_GameShopCatalogueList;

var string m_nCashSephi;
var string m_nCashPoint;


function NetCustomRecv_UpdateGamePoint(int parm1, int parm2, string body)
{
	local array<string> ItemDatas;
	Split(body, "$", ItemDatas);
	if( ItemDatas.Length < 2 )
		return;
	m_nCashSephi = ItemDatas[0];
	m_nCashPoint = ItemDatas[1];
}

function NetCustomRecv_UpdatePaymentLink(int parm1, int parm2, string body)
{
	m_PaymentLink = body;
}

function NetCustomRecv_OnOpenShop(int parm1, int parm2, string body)
{	
	local int i;
	local array<string> ItemDatas;

	Split(body, "$", ItemDatas);
	if ( ItemDatas.Length < 10 )
		return;

	m_GameShopCatalogueList.Insert(m_GameShopCatalogueList.Length, 1);

	i = m_GameShopCatalogueList.Length - 1;

	m_GameShopCatalogueList[i].nIndex = int(ItemDatas[0]);
	m_GameShopCatalogueList[i].sTitle = ItemDatas[1];
	m_GameShopCatalogueList[i].sImage = ItemDatas[2];
	m_GameShopCatalogueList[i].sDesc = ItemDatas[3];
	m_GameShopCatalogueList[i].nCategory = int(ItemDatas[4]);
	m_GameShopCatalogueList[i].nFlag = int(ItemDatas[5]);
	m_GameShopCatalogueList[i].nSephiPrice = ItemDatas[6];
	m_GameShopCatalogueList[i].nPointPrice = ItemDatas[7];
	m_GameShopCatalogueList[i].nSalePrice = ItemDatas[8];
	m_GameShopCatalogueList[i].nCount = int(ItemDatas[9]);
}

// 辅助函数：检查字符串价格是否大于0（使用native函数进行比较）
function bool IsPriceGreaterThanZero(string sPrice, ClientController Controller)
{
	if( sPrice == "" || sPrice == "0" )
		return False;
	
	// 使用native函数 CmpInt64 进行比较：返回值 > 0 表示 a > b
	return Controller.CmpInt64(sPrice, "0") > 0;
}

// 辅助函数：获取商品的有效价格（优先返回赛菲价格，其次折扣价格，最后点数价格）
function string GetEffectivePrice(GameShopCatalogueData ItemData, ClientController Controller)
{
	if( IsPriceGreaterThanZero(ItemData.nSephiPrice, Controller) )
		return ItemData.nSephiPrice;
	else if( IsPriceGreaterThanZero(ItemData.nSalePrice, Controller) )
		return ItemData.nSalePrice;
	else
		return ItemData.nPointPrice;
}

// 辅助函数：获取商品的有效价格类型（0=赛菲，1=折扣，2=点数）
function int GetEffectivePriceType(GameShopCatalogueData ItemData, ClientController Controller)
{
	if( IsPriceGreaterThanZero(ItemData.nSephiPrice, Controller) )
		return 0; // 赛菲价格
	else if( IsPriceGreaterThanZero(ItemData.nSalePrice, Controller) )
		return 1; // 折扣价格
	else
		return 2; // 点数价格
}

