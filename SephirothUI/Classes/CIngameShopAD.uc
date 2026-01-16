class CIngameShopAD extends CIngameShopInterface;

const BN_More = 1;
const BN_Open = 2;

var string m_sTitle;

struct _ADBtn
{
	var string sImage;
	var int nFlag;
	var int nListIndex;
	var int nCount;
	var bool bOver;
	var int X;
	var int Y;
	var int XL;
	var int YL;
};

var array<_ADBtn> ADBtnList;
var int m_nSelectedBtn;

var int m_nListLength;

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
	SetComponentTextureId(Components[1],1, -1,3,2);
	SetComponentNotify(Components[1],BN_More,Self);

	SetComponentTextureId(Components[2],1, -1,3,2);
	SetComponentNotify(Components[2],BN_Open,Self);

	m_sTitle = Localize("InGameShopAD","Title","SephirothUI");
	
	bTopMost = True;
}

function UpdateButton()
{
	local int i,j, nIndex;
	local GameShopManager.GameShopCatalogueData temp;

	for( i = 0; i < GameManager(Level.Game).m_InGameShopADDList.Length; i++ )
	{
		nIndex = GameManager(Level.Game).m_InGameShopADDList[i];

		for( j = 0; j < GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList.Length; j++ )
		{
			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[j];

			if( temp.nIndex == nIndex )
			{
				ADBtnList[i].sImage = temp.sImage;
				ADBtnList[i].nListIndex = j;	// ���� �ε������� �޸� �𸮾� ��ũ��Ʈ �迭������ �ε�����
				ADBtnList[i].nFlag = temp.nFlag;
				ADBtnList[i].nCount = temp.nCount;
			}
		}
	}
}

function OnFlush()
{
	FlushDynamicTextures();
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i, x, y;
	local _ADBtn btn;

	if( !IsCursorInsideInterface() )
		return False;

	if( Key == IK_LeftMouse )
	{
		x = Components[0].X;
		y = Components[0].Y;
		
		for( i = 0; i < ADBtnList.Length; i++ )
		{
			btn = ADBtnList[i];
			if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
			{
				if( Action == IST_Press )
				{
					m_nSelectedBtn = i;
					class'CInGameShopBuy'.Static.OnDlg(Self, btn.nListIndex);
				}

				Parent.NotifyInterface(Self, INT_Command, "ClearInfo");
			}
		}
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int n;
	local GameShopManager.GameShopCatalogueData temp;
	
	switch (NotifyId) 
	{
		case BN_More:
			if( SephirothInterface(Parent.Parent).m_IngameShop == None )
				SephirothInterface(Parent.Parent).ShowInGameShop();
			break;

		case BN_Open:
			if( SephirothInterface(Parent.Parent).m_IngameShopBox == None )
			{
			//SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopSubscriptionList();
				SephirothInterface(Parent.Parent).ShowInGameShopBox();
			}
			else
				SephirothInterface(Parent.Parent).HideInGameShopBox();

			break;

		case class'CInGameShopBuy'.Default.RT_BUY:
			n = ADBtnList[m_nSelectedBtn].nListIndex;
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
			break;
	}
}

function OnPreRender(Canvas C)
{
	local int i;
	local float x, y;
	local _ADBtn btn;
	local bool bShowInfo;

	if( ADBtnList[0].sImage == "" )
		UpdateButton();
	
	x = Components[0].X;
	y = Components[0].Y;

	bShowInfo = False;
	for( i = 0; i < ADBtnList.Length; i++ )
	{
		btn = ADBtnList[i];
		if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
		{
			ADBtnList[i].bOver = True;
			ShowCatalogueInfo(x + btn.X, y + btn.Y + btn.YL, btn.nListIndex);
			bShowInfo = True;
		}
		else
			ADBtnList[i].bOver = False;
	}

	if( !bShowInfo )
		CloseCatalogueInfo();

}

function OnPostRender(HUD H, Canvas C)
{
	local int i, btnX, btnY;
	local float SX, SY;
	local _ADBtn btn;
	local Texture Image;

	SX = Components[0].X;
	SY = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetRenderStyleAlpha();
	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(m_sTitle, SX + 25, SY + 17, 73, 16);
	C.SetDrawColor(255,255,255);

	C.SetKoreanTextAlign(ETextAlign.TA_BottomRight);
	for( i = 0; i < ADBtnList.Length; i++ )
	{
		btn = ADBtnList[i];
		btnX = SX + btn.X;
		btnY = SY + btn.Y;

		// �̹���
		if( btn.sImage != "" )
		{
			Image = LoadDynamicTexture("InGame_item."$btn.sImage);
			if( Image != None )
			{
				if( btn.bOver )
				{
					C.SetPos(btnX - 27, btnY - 7);
					C.DrawTile(TextureResources[7].Resource,91,54,0,0,91,54);
				}

				C.SetPos(btnX, btnY);
				C.DrawTile(Image,40,40,0,0,40,40);
				
				if( btn.nCount > 1 )
					C.DrawKoreanText("x"$btn.nCount, btnX - 1, btnY, 40, 40);
			}
		}

		// hot new
		C.SetDrawColor(255,255,255);
		C.SetPos(btnX - 27, btnY - 7);
		if( btn.nFlag == 1 )	// hot
			C.DrawTile(TextureResources[4].Resource,37,37,0,0,37,37);
		else if(btn.nFlag == 2)	// new
			C.DrawTile(TextureResources[5].Resource,37,37,0,0,37,37);
		else if(btn.nFlag == 3)	// limit
			C.DrawTile(TextureResources[6].Resource,37,37,0,0,37,37);
	}
		
	C.SetDrawColor(255,255,255);

	Super.OnPostRender(H, C);
}

function Layout(Canvas C)
{
	local int i;

	MoveComponent(Components[0], True, C.ClipX - 404 - 280 - 123, 0);
	for( i = 1; i < Components.Length; i++ )
		MoveComponent(Components[i]);
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
	ADBtnList(0)=(X=43,Y=46,XL=40,YL=40)
	ADBtnList(1)=(X=43,Y=109,XL=40,YL=40)
	ADBtnList(2)=(X=43,Y=172,XL=40,YL=40)
	ADBtnList(3)=(X=43,Y=235,XL=40,YL=40)
	ADBtnList(4)=(X=43,Y=298,XL=40,YL=40)
	m_nSelectedBtn=-1
	m_nListLength=-1
	Components(0)=(Type=RES_Image,XL=123.000000,YL=423.000000)
	Components(1)=(Id=1,Caption="More",Type=RES_PushButton,XL=88.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=361.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	Components(2)=(Id=2,Caption="Open",Type=RES_PushButton,XL=88.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=385.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="SephShop")
	TextureResources(0)=(Package="UI_2011",Path="ingame_pr",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011_btn",Path="btn_yell_m_n",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011_btn",Path="btn_yell_m_o",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011_btn",Path="btn_yell_m_c",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011_btn",Path="Icon_ingame_hot",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011_btn",Path="Icon_ingame_new",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011_btn",Path="Icon_ingame_limit",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011_btn",Path="ingame_pr_btn_o",Style=STY_Alpha)
}
