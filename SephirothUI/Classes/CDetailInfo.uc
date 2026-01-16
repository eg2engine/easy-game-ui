class CDetailInfo extends CMultiInterface
	config(SephirothUI);

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var int nChangeInfo;

var array<string> m_sTextList;
var int m_nTypeAtkMax[6];
var int m_nTypeAtkMin[6];

const BN_Basic = 0;
const BN_Battle = 1;

const BN_Exit = 2;

var int m_nLoopCnt;

var string m_sTitle;

function OnInit()
{	
	SetComponentTextureId(Components[3],1,0,3,2);
	SetComponentTextureId(Components[2],4,0,6,5);
	SetComponentNotify(Components[3],BN_Exit,Self);
	SetComponentNotify(Components[2],BN_Basic,Self);
	Components[2].Caption = Localize("Info","S_Basic","SephirothUI");
	nChangeInfo = 2;	//modified by yj	//������ ��, �ٽ� Infoâ�� ������ ���� ����

	// ���� ��¥�� �ε� ���߿� �ٲܶ� ã�� �� �ָ��ϰ�����...
	m_sTextList[0] = Localize("Info","S_Detail","SephirothUI");
	m_sTextList[1] = Localize("Info","S_Critical","SephirothUI");   //ũ��Ƽ��/�ش�ȭ
    m_sTextList[2] = Localize("Info","S_Block","SephirothUI");
	m_sTextList[3] = Localize("Info","S_AntiMagic","SephirothUI");		// ���� ���׷�
	m_sTextList[4] = Localize("Info","S_AntiRedMagic","SephirothUI");	// ���� ���� ���׷�
	//m_sTextList[3] = Localize("Info","S_AntiCritical","SephirothUI");	//ũ��Ƽ��/�ش�ȭ ����
    m_sTextList[5] = Localize("Info","S_Disblock","SephirothUI");
    m_sTextList[6] = Localize("Info","S_Hit","SephirothUI");
    m_sTextList[7] = Localize("Info","S_Recharge","SephirothUI");   //������/������
    m_sTextList[8] = Localize("Info","S_MagicItemChance","SephirothUI");		//���� ������ ȹ�� Ȯ��
    //m_sTextList[9] = Localize("Info","S_MagicItemChance","SephirothUI"); //����/������
	m_sTextList[9] = Localize("Info","S_AttackSpeed","SephirothUI");
	m_sTextList[10] = Localize("Info","S_MoveSpeed","SephirothUI");
	m_sTextList[11] = Localize("Info","S_Type","SephirothUI");
	m_sTextList[12] = Localize("Info","S_Type1","SephirothUI");
	m_sTextList[13] = Localize("Info","S_Type2","SephirothUI");
	m_sTextList[14] = Localize("Info","S_Type3","SephirothUI");
	m_sTextList[15] = Localize("Info","S_Type4","SephirothUI");
	m_sTextList[16] = Localize("Info","S_Type5","SephirothUI");
	m_sTextList[17] = Localize("Info","S_Type6","SephirothUI");
	m_sTextList[18] = Localize("Info","S_MagicCritical","SephirothUI");   //ũ��Ƽ��/�ش�ȭ
	m_sTextList[19] = Localize("Info","S_AntiBlueMagic","SephirothUI");	// ���� ���� ���� ���׷�
	m_sTextList[20] = Localize("Info","S_RechargeM","SephirothUI");	// ��ȸ
	m_sTextList[21] = Localize("Info","S_ItemChanceAll","SephirothUI");	// ��ȹ
	m_sTextList[22] = Localize("Info","S_Battle","SephirothUI");	// ������
	m_sTextList[23] = Localize("Info","S_Surport","SephirothUI");	// ������
	m_sTextList[24] = Localize("Info","S_TypeDef","SephirothUI");	// �Ӽ� ���ݷ�

	m_sTitle = Localize("Info","S_Title","SephirothUI");
}

function OnFlush()
{

}

function Layout(Canvas C)
{
	local int DX,DY;
	local int i;
	local PlayerServerInfo PSI;

	if(m_nLoopCnt % 3 != 0) // ������ �ѹ� ������ ����ǵ� ����ϴ�
        return ;

	if(bMovingUI) {
		if (bIsDragging)
		{
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else
		{
			if (PageX < 0)
				PageX = 0;
			else if (PageX + WinWidth > C.ClipX)
				PageX = C.ClipX - WinWidth;

			if (PageY < 0)
				PageY = 0;
			else if (PageY + WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight;
			bMovingUI = false;
		}
	}

	MoveComponent(Components[0],true,PageX,PageY,WinWidth,WinHeight);
	for (i=0;i<Components.Length;i++)
		MoveComponent(Components[i]);


	PSI = SephirothPlayer(PlayerOwner).PSI;
	m_sTextList[25] = Localize("Terms",string(PSI.JobName), "Sephiroth");

	Super.Layout(C);
}

function OnPreRender(Canvas C)
{
	local PlayerServerInfo PSI;

	if(m_nLoopCnt++ > 100)
		m_nLoopCnt = 0;

	DrawBackGround3x3(C, 64, 64, 7, 8, 9, 10, 11, 12, 13, 14, 15);
	DrawTitle(C, m_sTitle);

	if(m_nLoopCnt % 10 != 0) // ������ �ѹ� ������ ����ǵ� ����ϴ�
		return ;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	m_nTypeAtkMin[0] = PSI.DI.nType1/10000;
	m_nTypeAtkMax[0] = PSI.DI.nType1%10000;

	m_nTypeAtkMin[1] = PSI.DI.nType2/10000;
	m_nTypeAtkMax[1] = PSI.DI.nType2%10000;

	m_nTypeAtkMin[2] = PSI.DI.nType3/10000;
	m_nTypeAtkMax[2] = PSI.DI.nType3%10000;

	m_nTypeAtkMin[3] = PSI.DI.nType4/10000;
	m_nTypeAtkMax[3] = PSI.DI.nType4%10000;

	m_nTypeAtkMin[4] = PSI.DI.nType5/10000;
	m_nTypeAtkMax[4] = PSI.DI.nType5%10000;

	m_nTypeAtkMin[5] = PSI.DI.nType6/10000;
	m_nTypeAtkMax[5] = PSI.DI.nType6%10000;


}

function OnPostRender(HUD H, Canvas C)
{
	local int X, Y, XL, YL, YY;
	local PlayerServerInfo PSI;

	X = Components[0].X;
	Y = Components[0].Y;
	PSI = SephirothPlayer(PlayerOwner).PSI;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);


	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(string(PSI.PlayName),X+32,Y+72,178,15);
	C.DrawKoreanText("Lv " $ PSI.PlayLevel $ " " $ m_sTextList[25],X+32,Y+92,178,15);

	// ������ ����â
	C.SetPos(X+123, Y+37);
	C.DrawTile(TextureResources[6].Resource, 102, 24, 0, 0, 102, 24);		
	C.DrawKoreanText(Localize("Info","S_Detail","SephirothUI"),X+124, Y+37, 102, 24);

	// ��ġ ǥ��
	XL = 87;
	YL = 14;
	YY = Y + 150;
	C.DrawKoreanText(PSI.DI.fAtk $ "%",					X+135,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.fCri $ "%",					X+135,YY,XL,YL); YY+=21; //ũ��Ƽ��
	C.DrawKoreanText(PSI.DI.MagicCriticalRate $ "%",	X+135,YY,XL,YL); YY+=21; // �ش�ȭ
	C.DrawKoreanText("+" $ PSI.DI.nHit $ "%",			X+135,YY,XL,YL); YY+=21; //���ݼ���Ȯ��
	C.DrawKoreanText(PSI.DI.nDisblock $ "%",			X+135,YY,XL,YL); YY+=21; //������Ȯ�� ����
    C.DrawKoreanText(PSI.DI.fBlock $ "%",				X+135,YY,XL,YL); // ����
	
	YY = Y + 322;
	C.DrawKoreanText(PSI.DI.fMove $ "%",				X+135,YY,XL,YL); YY+=21;
    C.DrawKoreanText(PSI.DI.nRHP,						X+135,YY,XL,YL); YY+=21; //������
    C.DrawKoreanText(PSI.DI.nRMP,						X+135,YY,XL,YL); YY+=21;	//������ ȸ��
    C.DrawKoreanText(PSI.DI.fMagicDodge $ "%",			X+135,YY,XL,YL); YY+=21;
    C.DrawKoreanText(PSI.DI.fRedMagicDodge $ "%",		X+135,YY,XL,YL); YY+=21;
    C.DrawKoreanText(PSI.DI.fBlueMagicDodge $ "%",		X+135,YY,XL,YL); YY+=21;
    C.DrawKoreanText(PSI.DI.nMChance,					X+135,YY,XL,YL); YY+=21;	//������ ȹ�� Ȯ��
    C.DrawKoreanText(PSI.DI.nIChance,					X+135,YY,XL,YL);	//������ ȹ�� Ȯ��

	XL = 69;
	YY = Y + 537;
	C.DrawKoreanText(m_nTypeAtkMin[0] $ " ~ " $ m_nTypeAtkMax[0],      X+69,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_nTypeAtkMin[1] $ " ~ " $ m_nTypeAtkMax[1],      X+69,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_nTypeAtkMin[2] $ " ~ " $ m_nTypeAtkMax[2],      X+69,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_nTypeAtkMin[3] $ " ~ " $ m_nTypeAtkMax[3],      X+69,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_nTypeAtkMin[4] $ " ~ " $ m_nTypeAtkMax[4],      X+69,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_nTypeAtkMin[5] $ " ~ " $ m_nTypeAtkMax[5],      X+69,YY,XL,YL);

	XL = 35;
	YY = Y + 537;
	C.DrawKoreanText(PSI.DI.nRatio1 $ "%",				X+141,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.nRatio2 $ "%",				X+141,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.nRatio3 $ "%",      		X+141,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.nRatio4 $ "%",      		X+141,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.nRatio5 $ "%",      		X+141,YY,XL,YL); YY+=21;
	C.DrawKoreanText(PSI.DI.nRatio6 $ "%",      		X+141,YY,XL,YL);

	//add neive : �Ӽ� ���
	YY = Y + 537;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef1,      		X+183,YY,XL,YL); YY+=21;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef2,      		X+183,YY,XL,YL); YY+=21;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef3,      		X+183,YY,XL,YL); YY+=21;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef4,      		X+183,YY,XL,YL); YY+=21;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef5,      		X+183,YY,XL,YL); YY+=21;
	C.DrawKoreanText("-" $ PSI.DI.nTypeDef6,      		X+183,YY,XL,YL);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	XL = 70;

	C.SetDrawColor(229,201,174);

	YY = Y + 150;
	C.DrawKoreanText(m_sTextList[9],					X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[1],					X+23,YY,XL,YL); YY+=21; //ũ��Ƽ��
	C.DrawKoreanText(m_sTextList[18],					X+23,YY,XL,YL); YY+=21; // �ش�ȭ
    C.DrawKoreanText(m_sTextList[6],					X+23,YY,XL,YL); YY+=21;	//���ݼ���Ȯ��
    C.DrawKoreanText(m_sTextList[5],					X+23,YY,XL,YL); YY+=21;	//������Ȯ�� ����
    C.DrawKoreanText(m_sTextList[2],					X+23,YY,XL,YL);	// ����

	YY = Y + 322;
	C.DrawKoreanText(m_sTextList[10],					X+23,YY,XL,YL); YY+=21;
    C.DrawKoreanText(m_sTextList[7],					X+23,YY,XL,YL); YY+=21;	//������
    C.DrawKoreanText(m_sTextList[20],					X+23,YY,XL,YL); YY+=21;	//������ ȸ��
    C.DrawKoreanText(m_sTextList[3],					X+23,YY,XL,YL); YY+=21;
    C.DrawKoreanText(m_sTextList[4],					X+23,YY,XL,YL); YY+=21;
    C.DrawKoreanText(m_sTextList[19],					X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[8],					X+23,YY,XL,YL); YY+=21;	//������ ȹ�� Ȯ��
	C.DrawKoreanText(m_sTextList[21],					X+23,YY,XL,YL);	//������ ȹ�� Ȯ��

	YY = Y + 537;
	C.DrawKoreanText(m_sTextList[12],      X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[13],      X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[14],      X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[15],      X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[16],      X+23,YY,XL,YL); YY+=21;
	C.DrawKoreanText(m_sTextList[17],      X+23,YY,XL,YL);

	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(m_sTextList[22],      X+23,Y+129,XL,YL);	// ������
	C.DrawKoreanText(m_sTextList[23],      X+23,Y+302,XL,YL);	// ������
	C.DrawKoreanText(m_sTextList[24],      X+23,Y+518,XL,YL);	// �Ӽ� ���ݷ�/����


}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_LeftMouse )
	{
		if( (Action == IST_Press)  && IsCursorInsideComponent(Components[0]))
		{
			bIsDragging = true;
			bMovingUI = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}

		if (Action == IST_Release && bIsDragging)
		{
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	//Log(Notifyid);
	if (NotifyId == BN_Exit)
	{
		nChangeInfo = 0;
		Parent.NotifyInterface(Self,INT_Close);
	}
	if(NotifyId == BN_Basic)
	{
		nChangeInfo = 1;
		Parent.NotifyInterface(Self,INT_Close);
	}
}

//-----------------------------------------------------------------------------
// ���� ���Ͻ���
//-----------------------------------------------------------------------------

function SetPosition(int x, int y)
{
	PageX = x;
	PageY = y;
}

//-----------------------------------------------------------------------------
// ����Ʈ �ʱ�ȭ
//-----------------------------------------------------------------------------

defaultproperties
{
     Components(0)=(XL=242.000000,YL=691.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=220.000000,YL=630.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=57.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=37.000000,TextAlign=TA_MiddleCenter)
     Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=211.000000,OffsetYL=16.000000,HotKey=IK_Escape)
     TextureResources(0)=(Package="UI_2011",Path="chr_info_2",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="chr_tab_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="chr_tab_o",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     WinWidth=242.000000
     WinHeight=691.000000
     IsBottom=True
}
