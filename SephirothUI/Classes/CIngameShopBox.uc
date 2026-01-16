class CIngameShopBox extends CIngameShopInterface;

const BN_Exit = 1;
const BN_Left = 2;
const BN_Right = 3;
const BN_DLeft = 4;
const BN_DRight = 5;

const XLINE = 5;
const YLINE = 4;

var string m_sTitle;

struct _Btn
{
	var string sImage;
	var int nCount;
	var int nFlag;
	var int nListIndex;
	var int nKeyTime;
	var bool bOver;
	var int X;
	var int Y;
	var int XL;
	var int YL;
};

var array<_Btn> m_BtnList;
var int m_nSelectBtnIndex;
var int m_nCurSubscriptionLength;

var int m_nCurPage;
var int m_nPageEnd;

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

function ResetButton()
{
	local int x,y,n;

	n = 0;
	for( y = 0; y < YLINE; y++ )
	{
		for( x = 0; x < XLINE; x++ )
		{
			m_BtnList[n].sImage = "";
			m_BtnList[n].nCount = 0;
			m_BtnList[n].X = 23;
			m_BtnList[n].Y = 44;
			m_BtnList[n].XL = 40;
			m_BtnList[n].YL = 40;
			m_BtnList[n].nListIndex = -1;
			m_BtnList[n].nKeyTime = -1;
			n++;
		}
	}
}

function UpdateButton()
{
	local int i,x,y,n;
	local int nPageStart;
	local GameShopManager.GameShopCatalogueData temp;
	local GameManager._SubscriptionData SubData;
	
	ResetButton();
	
	n = 0;
	for( y = 0; y < YLINE; y++ )
	{
		for( x = 0; x < XLINE; x++ )
		{
			m_BtnList[n].sImage = "";
			m_BtnList[n].X += x * 54;
			m_BtnList[n].Y += y * 54;
			m_BtnList[n].nListIndex = -1;
			m_BtnList[n].nKeyTime = -1;
			n++;
		}
	}
	
/*	
	// �ӽ÷� �Ǹ� ����Ʈ�� ��������
	for(i=0; i<m_BtnList.Length; i++)
	{
		temp = GameManager(Level.Game).m_InGameShopCatalogueList[i];

		m_BtnList[i].sImage = temp.sImage;
		m_BtnList[i].nCount = temp.nCount;
		m_BtnList[i].nIndex = i;	// ���� �ε������� �޸� �𸮾� ��ũ��Ʈ �迭������ �ε�����
		m_BtnList[i].nFlag = temp.nFlag;
	}
*/

//	//Log("neive : check Length " $ GameManager(Level.Game).m_SubscriptionList.Length);
	if( GameManager(Level.Game).m_SubscriptionList.Length != 0 )
	{		
		n = 0;
	//	//Log("Length " $ GameManager(Level.Game).m_SubscriptionList.Length);
		nPageStart = m_nCurPage * XLINE * YLINE;
		for( i = nPageStart; i < GameManager(Level.Game).m_SubscriptionList.Length; i++ )
		{
			if( n < XLINE * YLINE )	
			{
				SubData = GameManager(Level.Game).m_SubscriptionList[i];
				temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[SubData.nListIndex];
					
				m_BtnList[n].sImage = temp.sImage;
				m_BtnList[n].nCount = temp.nCount;
				m_BtnList[n].nListIndex = SubData.nListIndex;	// ���� �ε������� �޸� �𸮾� ��ũ��Ʈ �迭������ �ε�����
				m_BtnList[n].nKeyTime = SubData.nKeyTime;
				m_BtnList[n].nFlag = temp.nFlag;
				n++;
			}
		}
	}
}

function OnInit()
{
	SetComponentTextureId(Components[1],1, -1,1,2);
	SetComponentNotify(Components[1],BN_Exit,Self);

	SetComponentTextureId(Components[2],3, -1,5,4);
	SetComponentNotify(Components[2],BN_Left,Self);
	SetComponentTextureId(Components[3],6, -1,8,7);
	SetComponentNotify(Components[3],BN_Right,Self);

	SetComponentTextureId(Components[4],9, -1,11,10);
	SetComponentNotify(Components[4],BN_DLeft,Self);
	SetComponentTextureId(Components[5],12, -1,14,13);
	SetComponentNotify(Components[5],BN_DRight,Self);

	m_sTitle = Localize("InGameShopBox","Title","SephirothUI");

	ResetButton();
}

function OnFlush()
{
	FlushDynamicTextures();
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i, x, y;
	local _Btn btn;

	if( !IsCursorInsideInterface() )
		return False;

	if( Key == IK_LeftMouse )
	{
		x = Components[0].X;
		y = Components[0].Y;
		
		for( i = 0; i < m_BtnList.Length; i++ )
		{
			btn = m_BtnList[i];
			if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
			{
				if( Action == IST_Press )
				{
					if( btn.nListIndex != -1 )
					{
						m_nSelectBtnIndex = i;
						class'CInGameShopApply'.Static.OnDlg(Self);
					}
				}

				Parent.NotifyInterface(Self, INT_Command, "ClearInfo");
				return True;
			}
		}
	}

	return False;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int n, nKeyTime;
	local GameShopManager.GameShopCatalogueData temp;
	
	switch (NotifyId) 
	{
		case BN_Exit:
			SephirothInterface(PlayerOwner.myHud).HideIngameShopBox();
			break;

		case BN_Left:
			if( m_nCurPage > 0 )
				m_nCurPage--;
			UpdateButton();
			break;

		case BN_Right:
			if( m_nCurPage < m_nPageEnd )
				m_nCurPage++;
			UpdateButton();
			break;

		case BN_DLeft:
			m_nCurPage = 0;
			UpdateButton();
			break;

		case BN_DRight:
			m_nCurPage = m_nPageEnd;
			UpdateButton();
			break;

		case class'CInGameShopApply'.Default.RT_CLOSE:
			m_nSelectBtnIndex = -1;
			break;

		case class'CInGameShopApply'.Default.RT_APPLY:
			n = m_BtnList[m_nSelectBtnIndex].nListIndex;
			nKeyTime = m_BtnList[m_nSelectBtnIndex].nKeyTime;

			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[n];
	
			SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopSubscriptionAccept(temp.nIndex, nKeyTime);
			m_nSelectBtnIndex = -1;
			break;

		case class'CInGameShopApply'.Default.RT_UNAPPLY:
			n = m_BtnList[m_nSelectBtnIndex].nListIndex;
			nKeyTime = m_BtnList[m_nSelectBtnIndex].nKeyTime;

			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[n];
	
		//Log("req cancel " $ temp.nIndex $ ", " $ nKeyTime);
			SephirothPlayer(PlayerOwner).Net.NotiRequestInGameShopSubscriptionCancel(temp.nIndex, nKeyTime);

			m_nSelectBtnIndex = -1;
		//SephirothInterface(PlayerOwner.myHud).HideIngameShopBox();
			break;
	}
}

function OnPreRender(Canvas C)
{
	local int i;
	local float x, y;
	local _Btn btn;
	local bool bShowInfo;

	if( m_nCurSubscriptionLength != GameManager(Level.Game).m_SubscriptionList.Length )
	{
		m_nCurSubscriptionLength = GameManager(Level.Game).m_SubscriptionList.Length;
		UpdateButton();
	}

	x = Components[0].X;
	y = Components[0].Y;

	bShowInfo = False;
	for( i = 0; i < m_BtnList.Length; i++ )
	{
		btn = m_BtnList[i];
		if( IsCursorInsideAt(x + btn.X, y + btn.Y, btn.XL, btn.YL) )
		{
			m_BtnList[i].bOver = True;
			ShowCatalogueInfo(x + btn.X, y + btn.Y + btn.YL, btn.nListIndex);
			bShowInfo = True;
		}
		else
			m_BtnList[i].bOver = False;
	}
	
	if( !bShowInfo )
		CloseCatalogueInfo();
		
	Super.OnPreRender(C);
}

function OnPostRender(HUD H, Canvas C)
{
	local int i, btnX, btnY;
	local float SX, SY;
	local _Btn btn;
	local Texture Image;

	SX = Components[0].X;
	SY = Components[0].Y;

	C.SetRenderStyleAlpha();

	DrawTitle(C, m_sTitle);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(229,201,174);
	m_nPageEnd = GameManager(Level.Game).m_SubscriptionList.Length / (XLINE * YLINE);
	C.DrawKoreanText(m_nCurPage + 1$" / "$m_nPageEnd + 1, SX + 126, SY + 263, 50, 16);
	C.SetDrawColor(255,255,255);

	// �����ܵ�~
	C.SetKoreanTextAlign(ETextAlign.TA_BottomRight);
	for( i = 0; i < m_BtnList.Length; i++ )
	{
		btn = m_BtnList[i];
		btnX = SX + btn.X;
		btnY = SY + btn.Y;

		// �̹���
		if( btn.sImage != "" )
		{
			Image = LoadDynamicTexture("InGame_item."$btn.sImage);
			if( Image != None )
			{
				if( btn.bOver || m_nSelectBtnIndex == i )
				{
					C.SetPos(btnX - 2, btnY - 2);
					C.DrawTile(TextureResources[15].Resource,44,44,0,0,44,44);
				}

				C.SetPos(btnX, btnY);
				C.DrawTile(Image,40,40,0,0,40,40);
				
				if( btn.nCount > 1 )
					C.DrawKoreanText("x"$btn.nCount,btnX - 3, btnY - 4, 44, 44);
			}
		}
	}

	C.SetDrawColor(255,255,255);
	
	if( False )
	{
		for( i = 0; i < GameManager(Level.Game).m_SubscriptionList.Length; i++ )
		{
			if( m_nSelectBtnIndex + (m_nCurPage * XLINE * YLINE) == i )
				C.SetDrawColor(255,2,2);
			else
				C.SetDrawColor(255,255,255);
		
			C.DrawKoreanText(GameManager(Level.Game).m_SubscriptionList[i].nIndex$", "$GameManager(Level.Game).m_SubscriptionList[i].nKeyTime,0,0 + (i * 16),200,16);
		}
	}
	
	Super.OnPostRender(H, C);
}

function Layout(Canvas C)
{
	local int i;

	MoveComponent(Components[0], True, C.ClipX - Components[0].XL, C.ClipY - Components[0].YL);
	for( i = 1; i < Components.Length; i++ )
		MoveComponent(Components[i]);
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
	m_BtnList(0)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(1)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(2)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(3)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(4)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(5)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(6)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(7)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(8)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(9)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(10)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(11)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(12)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(13)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(14)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(15)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(16)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(17)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(18)=(X=23,Y=44,XL=40,YL=40)
	m_BtnList(19)=(X=23,Y=44,XL=40,YL=40)
	m_nSelectBtnIndex=-1
	m_nCurSubscriptionLength=-1
	Components(0)=(Type=RES_Image,XL=302.000000,YL=296.000000)
	Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=271.000000,OffsetYL=14.000000)
	Components(2)=(Id=2,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=104.000000,OffsetYL=261.000000)
	Components(3)=(Id=3,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=178.000000,OffsetYL=261.000000)
	Components(4)=(Id=4,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=76.000000,OffsetYL=261.000000)
	Components(5)=(Id=5,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=206.000000,OffsetYL=261.000000)
	TextureResources(0)=(Package="UI_2011",Path="ingame_bank",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011_btn",Path="btn_s_arr_l_n",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011_btn",Path="btn_s_arr_l_o",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011_btn",Path="btn_s_arr_l_c",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011_btn",Path="btn_s_arr_r_n",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011_btn",Path="btn_s_arr_r_o",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011_btn",Path="btn_s_arr_r_c",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011_btn",Path="btn_s_arr_l_n_2",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="btn_s_arr_l_o_2",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="btn_s_arr_l_c_2",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011_btn",Path="btn_s_arr_r_n_2",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2011_btn",Path="btn_s_arr_r_o_2",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2011_btn",Path="btn_s_arr_r_c_2",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2011_btn",Path="btn_ingame_bank_o",Style=STY_Alpha)
}
