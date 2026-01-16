class CIngameShop extends CIngameShopInterface;

const BN_Exit = 1;
const BN_CashBuy = 2;
const BN_Left = 3;
const BN_Right = 4;
const BN_DLeft = 5;
const BN_DRight = 6;

const CatalogueNumX = 2;
const CatalogueNumY = 7;
const CatalogueNum = 14;	// CatalogueNumX * CatalogueNumY
const CatalogueWidth = 236;
const CatalogueHeight = 62;


var string m_sTitle;
var string m_sSubTitleHot;
var string m_sSubTitleNormal;
var string m_sSephi;
var string m_sPoints;
var string m_sPrSephi;
var string m_sPrPoint;
var string m_sPics;

struct _CategoryBtn
{
	var string sCaption;
	var bool bOver;
	var int X;
	var int Y;
	var int XL;
	var int YL;
};

var array<_CategoryBtn> CategoryBtnList;
var int m_nSelectedCategory;
var int m_nCurPage;
var int m_nPageEnd;
var int m_nCategoryOver;
var int m_nCategoryClick;

struct _CatalogueBtn
{
	var int nListIndex;
	var int X;
	var int Y;
	var int XL;
	var int YL;
};

var array<_CatalogueBtn> CatalogueBtnList;
var int m_nCatalogueOver;
var int m_nCatalogueClick;
var int m_nMaxCatalogueNum;

var int m_nMainAlpha;

var bool m_bOnBuyDlg;


var array<Texture> DynamicTextures;

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if ( T != None ) 
	{
		for ( i = 0;i < DynamicTextures.Length;i++ )
			if ( T == DynamicTextures[i] )
				break;
		if ( i == DynamicTextures.Length ) 
		{
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
	for ( i = 0;i < DynamicTextures.Length;i++ ) 
	{
		if ( DynamicTextures[i] != None ) 
		{
			UnloadTexture(Viewport(PlayerOwner.Player),DynamicTextures[i]);
		}
	}
	DynamicTextures.Remove(0,count);
}



function OnInit()
{
	local int i;

	SetComponentTextureId(Components[3],9, -1,9,10);
	SetComponentNotify(Components[3],BN_Exit,Self);

	SetComponentTextureId(Components[4],14, -1,16,15);
	SetComponentNotify(Components[4],BN_CashBuy,Self);

	SetComponentTextureId(Components[5],17, -1,19,18);
	SetComponentNotify(Components[5],BN_Left,Self);
	SetComponentTextureId(Components[6],20, -1,22,21);
	SetComponentNotify(Components[6],BN_Right,Self);

	SetComponentTextureId(Components[7],23, -1,25,24);
	SetComponentNotify(Components[7],BN_DLeft,Self);
	SetComponentTextureId(Components[8],26, -1,28,27);
	SetComponentNotify(Components[8],BN_DRight,Self);


	m_sTitle = Localize("InGameShop","Title","SephirothUI");
	m_sSubTitleHot = Localize("InGameShop","TitleHot","SephirothUI");
	m_sSubTitleNormal = Localize("InGameShop","TitleNor","SephirothUI");
	m_sSephi = Localize("InGameShop","Sephi","SephirothUI");
	m_sPoints = Localize("InGameShop","Points","SephirothUI");
	m_sPrSephi = Localize("InGameShop", "PriceSe", "SephirothUI");
	m_sPrPoint = Localize("InGameShop", "PricePo", "SephirothUI");
	m_sPics = Localize("InGameShop", "Pics", "SephirothUI");

	for( i = 0; i < CategoryBtnList.Length; i++ )
		CategoryBtnList[i].sCaption = Localize("InGameShop","Menu"$i,"SephirothUI");

	SetCataloguePage(m_nSelectedCategory, m_nCurPage);
}

function OnFlush()
{
	FlushDynamicTextures();
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int n;
	local GameShopManager.GameShopCatalogueData temp;
	
	switch(NotifyId)
	{
		case BN_Exit:
			Parent.NotifyInterface(Self,INT_Close);		
			break;
			
		case BN_Left:
			if( m_nCurPage > 1 )
			{
				m_nCurPage--;
				SetCataloguePage(m_nSelectedCategory, m_nCurPage);
			}
			break;

		case BN_Right:
			if( m_nCurPage < m_nPageEnd )
			{
				m_nCurPage++;
				SetCataloguePage(m_nSelectedCategory, m_nCurPage);
			}
			break;

		case BN_DLeft:
			if( m_nCurPage != 1 )
			{
				m_nCurPage = 1;
				SetCataloguePage(m_nSelectedCategory, m_nCurPage);	
			}
			break;

		case BN_DRight:
			if( m_nCurPage != m_nPageEnd )
			{
				m_nCurPage = m_nPageEnd;
				SetCataloguePage(m_nSelectedCategory, m_nCurPage);
			}
			break;
	}
	
	if( NotifyId == BN_CashBuy )
		PlayerOwner.ClientTravel(GameManager(Level.Game).GameShopManager.m_PaymentLink,TRAVEL_Absolute,False);
	else if(NotifyId == class'CInGameShopBuy'.Default.RT_CLOSE)
	{
		m_bOnBuyDlg = False;
	}
	else if(NotifyId == class'CInGameShopBuy'.Default.RT_BUY)
	{
		n = CatalogueBtnList[m_nCatalogueClick].nListIndex;
		temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[n];

		// 价格优先级：赛菲价格 > 折扣价格 > 点数价格
		// 购买判断：根据实际使用的价格类型进行判断
		if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSephiPrice, "0") > 0 )
		{
			// 有赛菲价格，检查赛菲余额
			if( SephirothPlayer(PlayerOwner).PSI.IsInGameShopBuyAbleString(temp.nSephiPrice, "0") )
			{
				SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopBuy(temp.nIndex);
				SephirothInterface(Parent.Parent).ShowIngameShopBox();
			}
		}
		else if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSalePrice, "0") > 0 )
		{
			// 有折扣价格（用点数支付），检查点数余额
			if( SephirothPlayer(PlayerOwner).PSI.IsInGameShopBuyAbleString("0", temp.nSalePrice) )
			{
				SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopBuy(temp.nIndex);
				SephirothInterface(Parent.Parent).ShowIngameShopBox();
			}
		}
		else
		{
			// 只有点数价格，检查点数余额
			if( SephirothPlayer(PlayerOwner).PSI.IsInGameShopBuyAbleString("0", temp.nPointPrice) )
			{
				SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopBuy(temp.nIndex);
				SephirothInterface(Parent.Parent).ShowIngameShopBox();
			}
		}
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i, x, y, mx, my;
	local _CategoryBtn btn;

	if( !IsCursorInsideInterface() )
		return False;

	if( Key == IK_LeftMouse )
	{
		if( IsCursorInsideComponent(Components[2]) )
		{
			mx = Controller.MouseX;
			my = Controller.MouseY;

			x = (mx - Components[2].X) / CatalogueWidth;
			y = (my - Components[2].Y) / (CatalogueHeight + 7);

			if( x < CatalogueNumX && y < CatalogueNumY )	// ī�װ��� ĭ ���� x, y �� ����� ��ȿ
			{
				if( Action == IST_Press )
				{
					m_nCatalogueClick = y * CatalogueNumX + x;
					if( CatalogueBtnList[m_nCatalogueClick].nListIndex != -1 )
					{
						class'CInGameShopBuy'.Static.OnDlg(Self, CatalogueBtnList[m_nCatalogueClick].nListIndex);
						m_bOnBuyDlg = True;
					}
				}
				else
					m_nCatalogueClick = -1;
			}
		}
		else if(IsCursorInsideComponent(Components[1]))
		{
			if( Action == IST_Press )
			{
				x = Components[1].X;
				y = Components[1].Y;
				
				for( i = 0; i < CategoryBtnList.Length; i++ )
				{
					btn = CategoryBtnList[i];
					if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
					{
						m_nSelectedCategory = i;
						FlushDynamicTextures();
						m_nCurPage = 1;
						SetCataloguePage(m_nSelectedCategory, m_nCurPage);
					}
				}
			}
		}
	}

	return False;
}

function Layout(Canvas C)
{
	local int i;

	for( i = 0; i < Components.Length; i++ )
	{
		MoveComponent(Components[i]);
	}
}

function OnPreRender(Canvas C)
{
	local int i, x, y, mx, my;
	local _CategoryBtn btn;

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);

	//if(CategoryBtnList.Length == 0 && m_nSelectedCategory == 0)
	if( m_nMaxCatalogueNum != GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length )
	{
		m_nMaxCatalogueNum = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length;
		SetCataloguePage(m_nSelectedCategory, m_nCurPage);
	}

	// ���̾�α� Ȱ��ȭ�� ���� ���콺 �ν� ���Ҳ���
	if( m_bOnBuyDlg )
		return ;

	//#########
	// key 
	m_nCatalogueOver = -1;

	if( !IsCursorInsideInterface() )
		return ;

	if( IsCursorInsideComponent(Components[2]) )
	{
		mx = Controller.MouseX;
		my = Controller.MouseY;

		x = (mx - Components[2].X) / CatalogueWidth;
		y = (my - Components[2].Y) / (CatalogueHeight + 7);

		if( x < CatalogueNumX )	// īŻ�α� ĭ ���� x �� ����� ��ȿ
			if( y < CatalogueNumY )	// īŻ�α� ĭ ���� y �� ����� ��ȿ
			{
				m_nCatalogueOver = y * CatalogueNumX + x;

				//ShowCatalogueInfo(mx, my, m_nCatalogueOver);
			}
	}
	else if(IsCursorInsideComponent(Components[1]))
	{
		x = Components[1].X;
		y = Components[1].Y;
		for( i = 0; i < CategoryBtnList.Length; i++ )
		{
			btn = CategoryBtnList[i];
			if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
				CategoryBtnList[i].bOver = True;
			else
				CategoryBtnList[i].bOver = False;
		}
	}
}

// 绘制分类区域
// 包括：分类按钮、货币显示、页码显示等
function DrawCategory(Canvas C)
{
	local int i;					// 循环计数器
	local float SX, SY;				// 分类区域的起始坐标（X, Y）
	local _CategoryBtn btn;			// 分类按钮结构体

	// 获取分类区域的起始坐标
	SX = Components[1].X;
	SY = Components[1].Y;

	// 调试用：绘制分类区域边框（当前禁用）
	if( False )
	{
		C.SetPos(Components[1].X, Components[1].Y);
		C.DrawRect1Fix(Components[1].XL, Components[1].YL);
	}

	// 设置文本对齐方式为居中
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	// 设置文本颜色为金色（245,197,71），透明度为m_nMainAlpha
	C.SetDrawColor(245,197,71,m_nMainAlpha);

	// 绘制"热门"和"普通"副标题
	C.DrawKoreanText(m_sSubTitleHot, SX + 10, SY + 9, 135, 16);
	C.DrawKoreanText(m_sSubTitleNormal, SX + 10, SY + 117, 135, 16);

	// 遍历所有分类按钮并绘制
	for( i = 0; i < CategoryBtnList.Length; i++ )
	{
		btn = CategoryBtnList[i];
		
		// 如果当前分类被选中
		if( m_nSelectedCategory == i )
		{
			// 绘制选中状态的背景（白色，使用闪烁透明度）
			C.SetDrawColor(255,255,255,m_nShuttleAlpha);
			C.SetPos(SX + btn.X - 3, SY + btn.Y);
			C.DrawTile(TextureResources[32].Resource,142,16,0,0,142,16);

			// 设置文本颜色为白色
			C.SetDrawColor(255,255,255,m_nMainAlpha);
		}
		else if(btn.bOver)	// 鼠标悬停状态
		{
			// 绘制悬停状态的背景
			C.SetDrawColor(255,255,255,m_nMainAlpha);
			C.SetPos(SX + btn.X - 3, SY + btn.Y);
			C.DrawTile(TextureResources[32].Resource,142,16,0,0,142,16);

			// 设置文本颜色为黄色（255,242,0）
			C.SetDrawColor(255,242,0,m_nMainAlpha);
		}
		else			// 普通状态
		{
			// 设置文本颜色为白色
			C.SetDrawColor(255,255,255,m_nMainAlpha);
		}

		// 绘制分类按钮文本
		C.DrawKoreanText(btn.sCaption, SX + btn.X, SY + btn.Y, btn.XL, btn.YL);
	}
	
	// 设置文本对齐方式为左对齐
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	// 设置文本颜色为米色（229,201,174）
	C.SetDrawColor(229,201,174,m_nMainAlpha);

	// 绘制货币标签（"赛菲"和"点数"）
	C.DrawKoreanText(m_sSephi, SX + 11, SY + 374, 65, 16);
	C.DrawKoreanText(m_sPoints, SX + 11, SY + 428, 65, 16);

	// 如果有页面，绘制页码信息（当前页 / 总页数）
	if( m_nPageEnd > 0 )
		C.DrawKoreanText(m_nCurPage$" / "$m_nPageEnd, SX + 382, SY + 493, 50, 16);

	// 设置文本对齐方式为右对齐
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
	// 设置文本颜色为浅黄色（202,200,164）
	C.SetDrawColor(202,200,164,m_nMainAlpha);

	// 绘制玩家实际的赛菲和点数数值（使用MoneyStringEx处理string类型）
	C.DrawKoreanText(Controller.MoneyStringEx(GameManager(Level.Game).GameShopManager.m_nCashSephi), SX + 11, SY + 394, 129, 16);
	C.DrawKoreanText(Controller.MoneyStringEx(GameManager(Level.Game).GameShopManager.m_nCashPoint), SX + 11, SY + 448, 129, 16);

	// 恢复默认颜色为白色
	C.SetDrawColor(255,255,255);
}

// 绘制商品目录列表
// 显示当前页面的所有商品信息，包括图标、名称、价格、数量等
function DrawCatalogue(Canvas C)
{
	local int i, n, XL, YL;						// i: 循环计数器, n: 商品列表索引, XL/YL: 商品按钮的宽高
	local int SX, SY, btnX, btnY;				// SX/SY: 目录区域起始坐标, btnX/btnY: 商品按钮坐标
	local GameShopManager.GameShopCatalogueData temp;	// 商品数据临时变量
	local Texture Image;							// 商品图标纹理
	local string sText;							// 商品标题文本（可能被截断）
	local bool bShowInfo;						// 是否显示商品详细信息
	local int nLen;								// 商品标题长度

	// 调试用：绘制目录区域边框（当前禁用）
	if( False )
	{
		C.SetPos(Components[2].X, Components[2].Y);
		C.DrawRect1Fix(Components[2].XL, Components[2].YL);
	}

	// 获取目录区域的起始坐标和商品按钮尺寸
	SX = Components[2].X;
	SY = Components[2].Y;
	XL = CatalogueWidth;		// 商品按钮宽度：236
	YL = CatalogueHeight;		// 商品按钮高度：62
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

	// 初始化：不显示详细信息
	bShowInfo = False;
	
	// 遍历所有商品槽位（最多14个）
	for( i = 0; i < CatalogueNum/*CatalogueBtnList.Length*/; i++ )
	{
		// 如果该槽位没有商品，跳过
		if( CatalogueBtnList[i].nListIndex == -1 )
			continue;

		// 获取商品按钮的坐标
		btnX = CatalogueBtnList[i].X;
		btnY = CatalogueBtnList[i].Y;

		// 获取商品在列表中的索引，并获取商品数据
		n = CatalogueBtnList[i].nListIndex;
		temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[n];

		// 绘制商品按钮背景
		C.SetDrawColor(255,255,255,m_nMainAlpha);
		C.SetPos(btnX, btnY);
		
		// 根据鼠标交互状态绘制不同的背景
		if( m_nCatalogueClick == i && m_nCatalogueOver == i )
		{
			// 点击且悬停状态：绘制按下状态的背景
			C.DrawTile(TextureResources[13].Resource,XL,YL,0,0,XL,YL);
			ShowCatalogueInfo(btnX, btnY + YL, n);
			bShowInfo = True;
		}
		else if(m_nCatalogueOver == i)
		{
			// 仅悬停状态：绘制悬停状态的背景
			C.DrawTile(TextureResources[12].Resource,XL,YL,0,0,XL,YL);
			ShowCatalogueInfo(btnX, btnY + YL, n);
			bShowInfo = True;
		}
		else
		{
			// 普通状态：绘制普通背景
			C.DrawTile(TextureResources[11].Resource,XL,YL,0,0,XL,YL);
		}

		// 加载并绘制商品图标
		Image = LoadDynamicTexture("InGame_item."$temp.sImage);
		if( Image != None )
		{
			C.SetPos(btnX + 11, btnY + 11);
			C.DrawTile(Image,40,40,0,0,40,40);
		}

		// 绘制商品标题（如果超过18个字符则截断并添加省略号）
		C.SetDrawColor(229,201,174,m_nMainAlpha);
		nLen = StrLen(temp.sTitle);
		if( nLen > 18 )
			sText = Left(temp.sTitle, 16)$"...";
		else
			sText = temp.sTitle;
		C.DrawKoreanText(sText, btnX + 60, btnY + 7, 65, 16);

		// 绘制商品价格
		// 价格显示优先级：赛菲价格 > 折扣价格 > 点数价格
		// 非商场点数优先，折扣道具只限商场点数
		C.SetDrawColor(255,255,255,m_nMainAlpha);
		// 使用native函数 CmpInt64 进行比较：返回值 > 0 表示 a > b
		if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSephiPrice, "0") > 0 )
			// 如果有赛菲价格，显示赛菲价格（带颜色格式化）
			C.DrawKoreanText(Controller.MoneyColoredString(temp.nSephiPrice)$m_sPrSephi, btnX + 60, btnY + 23, 65, 16);
		else if( SephirothPlayer(PlayerOwner).CmpInt64(temp.nSalePrice, "0") > 0 )
			// 如果有折扣价格，显示折扣价格（带颜色格式化）
			C.DrawKoreanText(Controller.MoneyColoredString(temp.nSalePrice)$m_sPrPoint, btnX + 60, btnY + 23, 65, 16);
		else
			// 否则显示点数价格（带颜色格式化）
			C.DrawKoreanText(Controller.MoneyColoredString(temp.nPointPrice)$m_sPrPoint, btnX + 60, btnY + 23, 65, 16);

		// 绘制商品数量
		C.SetDrawColor(255,255,255,m_nMainAlpha);
		C.DrawKoreanText(temp.nCount$m_sPics, btnX + 60, btnY + 39, 65, 16);

		// 绘制商品标签图标（热门、新品、限时等）
		C.SetPos(btnX, btnY);
		if( temp.nFlag == 1 )	// 热门标签
			C.DrawTile(TextureResources[30].Resource,37,37,0,0,37,37);
		else if(temp.nFlag == 2)	// 新品标签
			C.DrawTile(TextureResources[31].Resource,37,37,0,0,37,37);
		else if(temp.nFlag == 3)	// 限时标签
			C.DrawTile(TextureResources[33].Resource,37,37,0,0,37,37);
	}

	// 如果没有显示任何商品信息，关闭详细信息窗口
	if( !bShowInfo )
		CloseCatalogueInfo();

	// 恢复默认颜色为白色
	C.SetDrawColor(255,255,255);
}

// 后渲染处理函数
// 在每帧渲染的最后阶段调用，用于绘制UI元素
function OnPostRender(HUD H, Canvas C)
{
	// 如果正在显示购买对话框
	if( m_bOnBuyDlg )
	{
		// 逐渐降低透明度（淡出效果），最低降到100
		if( m_nMainAlpha > 100 )
			m_nMainAlpha -= 5;
	}
	else
	{
		// 不在购买对话框时，恢复完全不透明
		m_nMainAlpha = 255;
	}

	// 绘制分类区域（左侧）
	DrawCategory(C);
	// 绘制商品目录列表（右侧）
	DrawCatalogue(C);

	// 调用父类的后渲染处理
	Super.OnPostRender(H, C);
}

// 设置商品目录页面
// 根据分类和页码，从商品列表中筛选并填充当前页面显示的商品
// @param nCategory: 分类索引（0-2为特殊分类，3+为普通分类）
// @param nPage: 页码（从1开始）
function SetCataloguePage(int nCategory, int nPage)
{
	local int i, n;								// i: 循环计数器, n: 当前填充的商品槽位索引
	local int sn;								// skip number: 需要跳过的商品数量（用于分页）
	local int nCount;							// 该分类下的商品总数
	local GameShopManager.GameShopCatalogueData temp;	// 商品数据临时变量

	// 初始化所有商品槽位为无效（-1表示无商品）
	for( i = 0; i < CatalogueBtnList.Length; i++ )
		CatalogueBtnList[i].nListIndex = -1;

	n = 0;			// 当前填充的商品槽位索引
	nCount = 0;		// 商品计数器
	
	// 判断是特殊分类（热门、新品、限时）还是普通分类
	if( nCategory < 3 )
	{
		// 特殊分类：热门(1)、新品(2)、限时(3)
		// 将分类索引转换为nFlag值（需要+1，因为0表示普通商品）
		nCategory = nCategory + 1;
		
		// 统计该分类下的商品总数
		for( i = 0; i < GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length; i++ )
			if( GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[i].nFlag == nCategory )
				nCount++;
		
		// 计算总页数（向上取整）
		m_nPageEnd = nCount / CatalogueNum;
		if( nCount % CatalogueNum != 0 )
			m_nPageEnd = m_nPageEnd + 1;
	
		// 计算需要跳过的商品数量（前面页面的商品）
		sn = (nPage - 1) * CatalogueNum;
		
		// 遍历商品列表，筛选出符合分类的商品并填充到当前页面
		for( i = 0; i < GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length; i++ )
		{
			// 如果已填满一页，停止填充
			if( n > CatalogueNum )
				continue;
				
			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[i];

			// 如果商品标志匹配当前分类
			if( temp.nFlag == nCategory )
			{
				// 如果还需要跳过商品（不在当前页），跳过
				if( sn > 0 )
				{
					sn--;
					continue;
				}
				
				// 将商品索引填充到商品槽位
				CatalogueBtnList[n].nListIndex = i;
				n++;
			}
		}
	}
	else
	{
		// 普通分类：LVUP(0)、EASY(1)、BUTY(2)、ENCH(3)、PACK(4)、SPCL(5)、EVEN(6)、POIN(7)
		// 将分类索引转换为nCategory值（需要-3，因为前3个是特殊分类）
		nCategory = nCategory - 3;
		
		// 统计该分类下的商品总数
		for( i = 0; i < GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length; i++ )
			if( GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[i].nCategory == nCategory )
				nCount++;
		
		// 计算总页数（向上取整）
		m_nPageEnd = nCount / CatalogueNum;
		if( nCount % CatalogueNum != 0 )
			m_nPageEnd = m_nPageEnd + 1;

		// 计算需要跳过的商品数量（前面页面的商品）
		sn = (nPage - 1) * 14;
		
		// 遍历商品列表，筛选出符合分类的商品并填充到当前页面
		for( i = 0; i < GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length; i++ )
		{		
			// 如果已填满一页，停止填充
			if( n > CatalogueNum )
				continue;
				
			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[i];

			// 如果商品分类匹配当前分类
			if( temp.nCategory == nCategory )
			{
				// 如果还需要跳过商品（不在当前页），跳过
				if( sn > 0 )
				{
					sn--;
					continue;
				}
				
				// 将商品索引填充到商品槽位
				CatalogueBtnList[n].nListIndex = i;
				n++;
			}
		}
	}

}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
	CategoryBtnList(0)=(X=9,Y=35,XL=135,YL=16)
	CategoryBtnList(1)=(X=9,Y=63,XL=135,YL=16)
	CategoryBtnList(2)=(X=9,Y=91,XL=135,YL=16)
	CategoryBtnList(3)=(X=9,Y=147,XL=135,YL=16)
	CategoryBtnList(4)=(X=9,Y=175,XL=135,YL=16)
	CategoryBtnList(5)=(X=9,Y=203,XL=135,YL=16)
	CategoryBtnList(6)=(X=9,Y=231,XL=135,YL=16)
	CategoryBtnList(7)=(X=9,Y=259,XL=135,YL=16)
	CategoryBtnList(8)=(X=9,Y=287,XL=135,YL=16)
	CategoryBtnList(9)=(X=9,Y=315,XL=135,YL=16)
	CategoryBtnList(10)=(X=9,Y=343,XL=135,YL=16)
	m_nCurPage=1
	CatalogueBtnList(0)=(X=170,Y=42,XL=236,YL=62)
	CatalogueBtnList(1)=(X=411,Y=42,XL=236,YL=62)
	CatalogueBtnList(2)=(X=170,Y=111,XL=236,YL=62)
	CatalogueBtnList(3)=(X=411,Y=111,XL=236,YL=62)
	CatalogueBtnList(4)=(X=170,Y=180,XL=236,YL=62)
	CatalogueBtnList(5)=(X=411,Y=180,XL=236,YL=62)
	CatalogueBtnList(6)=(X=170,Y=249,XL=236,YL=62)
	CatalogueBtnList(7)=(X=411,Y=249,XL=236,YL=62)
	CatalogueBtnList(8)=(X=170,Y=318,XL=236,YL=62)
	CatalogueBtnList(9)=(X=411,Y=318,XL=236,YL=62)
	CatalogueBtnList(10)=(X=170,Y=387,XL=236,YL=62)
	CatalogueBtnList(11)=(X=411,Y=387,XL=236,YL=62)
	CatalogueBtnList(12)=(X=170,Y=456,XL=236,YL=62)
	CatalogueBtnList(13)=(X=411,Y=456,XL=236,YL=62)
	m_nMainAlpha=255
	Components(0)=(XL=664.000000,YL=578.000000)
	Components(1)=(Id=1,ResId=29,Type=RES_Image,XL=153.000000,YL=481.000000,PivotDir=PVT_Copy,OffsetXL=13.000000,OffsetYL=39.000000)
	Components(2)=(Id=2,XL=477.000000,YL=476.000000,PivotDir=PVT_Copy,OffsetXL=170.000000,OffsetYL=42.000000)
	Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=633.000000,OffsetYL=14.000000,HotKey=IK_Escape)
	Components(4)=(Id=4,Caption="CashBuy",Type=RES_PushButton,XL=157.000000,YL=44.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=520.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	Components(5)=(Id=5,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=363.000000,OffsetYL=531.000000)
	Components(6)=(Id=6,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=437.000000,OffsetYL=531.000000)
	Components(7)=(Id=7,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=335.000000,OffsetYL=531.000000)
	Components(8)=(Id=8,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=465.000000,OffsetYL=531.000000)
	TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="btn_ingame_shop_n",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011_btn",Path="btn_ingame_shop_o",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2011_btn",Path="btn_ingame_shop_c",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2011_btn",Path="btn_red_n",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2011_btn",Path="btn_red_o",Style=STY_Alpha)
	TextureResources(16)=(Package="UI_2011_btn",Path="btn_red_c",Style=STY_Alpha)
	TextureResources(17)=(Package="UI_2011_btn",Path="btn_s_arr_l_n",Style=STY_Alpha)
	TextureResources(18)=(Package="UI_2011_btn",Path="btn_s_arr_l_o",Style=STY_Alpha)
	TextureResources(19)=(Package="UI_2011_btn",Path="btn_s_arr_l_c",Style=STY_Alpha)
	TextureResources(20)=(Package="UI_2011_btn",Path="btn_s_arr_r_n",Style=STY_Alpha)
	TextureResources(21)=(Package="UI_2011_btn",Path="btn_s_arr_r_o",Style=STY_Alpha)
	TextureResources(22)=(Package="UI_2011_btn",Path="btn_s_arr_r_c",Style=STY_Alpha)
	TextureResources(23)=(Package="UI_2011_btn",Path="btn_s_arr_l_n_2",Style=STY_Alpha)
	TextureResources(24)=(Package="UI_2011_btn",Path="btn_s_arr_l_o_2",Style=STY_Alpha)
	TextureResources(25)=(Package="UI_2011_btn",Path="btn_s_arr_l_c_2",Style=STY_Alpha)
	TextureResources(26)=(Package="UI_2011_btn",Path="btn_s_arr_r_n_2",Style=STY_Alpha)
	TextureResources(27)=(Package="UI_2011_btn",Path="btn_s_arr_r_o_2",Style=STY_Alpha)
	TextureResources(28)=(Package="UI_2011_btn",Path="btn_s_arr_r_c_2",Style=STY_Alpha)
	TextureResources(29)=(Package="UI_2011",Path="ingame_cate",Style=STY_Alpha)
	TextureResources(30)=(Package="UI_2011_btn",Path="Icon_ingame_hot",Style=STY_Alpha)
	TextureResources(31)=(Package="UI_2011_btn",Path="Icon_ingame_new",Style=STY_Alpha)
	TextureResources(32)=(Package="UI_2011_btn",Path="btn_ingame_cate_bar",Style=STY_Alpha)
	TextureResources(33)=(Package="UI_2011_btn",Path="Icon_ingame_limit",Style=STY_Alpha)
}
