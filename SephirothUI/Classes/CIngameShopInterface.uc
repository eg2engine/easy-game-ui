class CIngameShopInterface extends CMultiInterface;

// InGameShop �� AD �κп��� ���� ����â�� ����â�� ���ؼ� ������� �߰� �������̽�-

#exec TEXTURE IMPORT NAME=TextBlackBg FILE=Textures/Black90Alpha.tga

const SHOW_TIME = 0.0f;


// for info
var Texture TxImage;
var int m_nSX;
var int m_nSY;
var int m_nWidth;
var int m_nHeight;
var int m_nIndex;
var float m_fSec;

// �� ������
var bool m_bOnShopInfo;


function ShowCatalogueInfo(int X, int Y, int nIndex)
{
	if( m_bOnShopInfo == True && m_nIndex == nIndex )
		return;

	m_bOnShopInfo = True;
	m_nSX = X;
	m_nSY = Y;
	m_nIndex = nIndex;
	m_fSec = Level.Second;
	
	Controller.ResetDragAndDropAll();
	
	// ��� ������ ���� �ڽ��� �����
	if( SephirothInterface(Parent) != None )
	{
		SephirothInterface(Parent).GItemInfo.HideInterface();
		SephirothInterface(Parent).ItemTooltipBox.HideInterface();
		SephirothInterface(Parent).ItemCompareBox.HideInterface();
	}
	else if(SephirothInterface(Parent.Parent) != None)	// CIngameShopAD �� ��� �ܰ谡 �ٸ���
	{
		SephirothInterface(Parent.Parent).GItemInfo.HideInterface();
		SephirothInterface(Parent.Parent).ItemTooltipBox.HideInterface();
		SephirothInterface(Parent.Parent).ItemCompareBox.HideInterface();
	}
}

function CloseCatalogueInfo()
{
	m_bOnShopInfo = False;
}



function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{

	return False;
}

function OnPreRender(Canvas C)
{
	if( m_nSX + m_nWidth > C.ClipX )
		m_nSX = C.ClipX - m_nWidth;
		
	if( m_nSY + m_nHeight > C.ClipY )
		m_nSY = C.ClipY - m_nHeight;
}

function OnPostRender(HUD H, Canvas C)
{
	local int i,r,g,b;
	local int height;
	local GameShopManager.GameShopCatalogueData temp;
	local array<string> sTempList;
	local string sTemp;
	local string sColor;

	if( m_bOnShopInfo )
	{
		//Log("sec : " @ Level.Second - m_fSec);
		if( Level.Second - m_fSec > SHOW_TIME )
		{
			temp = GameManager(Level.Game).GameShopManager.m_GameShopCatalogueList[m_nIndex];
			sTemp = temp.sDesc;
			if( sTemp == "" )
				return ;
				
			m_nWidth = 400;				
			C.WrapStringToArray(sTemp, sTempList, m_nWidth,"|");
			height = sTempList.Length * 16 + 3 + 6;
			m_nHeight = height;
			
			C.SetRenderStyleAlpha();
			C.SetPos(m_nSX, m_nSY);
			C.DrawTile(Texture'TextBlackBg', m_nWidth, m_nHeight,0,0,4,4);

			C.SetDrawColor(126,126,126);
			C.SetPos(m_nSX, m_nSY);
			C.DrawRect1Fix(m_nWidth, m_nHeight);

			C.SetDrawColor(255,255,255);
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

			//http://udn.epicgames.com/Two/StringsInUnrealScript.html
			//sTemp = "@255255000Test|@255255100tstestsets|@155255000tsetsetst";
			for( i = 0; i < sTempList.Length; i++ )
			{
				C.SetDrawColor(255,255,255);
				if( Left(sTempList[i], 1) == "@" )
				{
					EatStr(sColor,sTempList[i],10);
					r = int(Mid(sColor, 1, 3));
					g = int(Mid(sColor, 4, 3));
					b = int(Mid(sColor, 7, 3));
					C.SetDrawColor(r,g,b);
					sColor = ""; // �����ָ� �ڷ� ��� += �ȴ� ������;
				}
				C.DrawKoreanText(sTempList[i], m_nSX + 4, m_nSY + 4 + (i * 16), 100, 16);
			}

			C.SetDrawColor(255,255,255);
		}
	}
}

defaultproperties
{
}
