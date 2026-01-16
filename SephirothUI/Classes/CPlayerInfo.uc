class CPlayerInfo extends CMultiInterface
	config(CompData);

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var int Str,Dex,Vigor,White,Red,Blue,Yellow,Black,UsedPoints;

const IDM_UpdateStat = 1;

const BN_Str = 1;
const BN_Dex = 2;
const BN_Vigor = 3;
const BN_White = 4;
const BN_Red = 5;
const BN_Blue = 6;
const BN_Yellow = 7;
const BN_Black = 8;
const BN_Update = 9;
const BN_Cancel = 10;
const BN_AutoStat = 11;

const BN_StrUp = 12;
const BN_strDown = 13;
const BN_DexUp = 14;
const BN_DexDown = 15;
const BN_VigUp = 16;
const BN_VigDown = 17;

const BN_WhiteUp = 18;
const BN_WhiteDown = 19;
const BN_RedUp = 20;
const BN_RedDown = 21;
const BN_BlueUp = 22;
const BN_BlueDown = 23;
const BN_YellowUp = 24;
const BN_YellowDown = 25;
const BN_BlackUp = 26;
const BN_BlackDown = 27;

const BN_DetailInfo = 28;

const BN_TitleList = 29;

const BN_Exit = 99;

const ManaNormal = 0;
const ManaSaver = 1;
const ManaRebirth = 2;

// hp ui id
const ID_HP = 6;

// effect id
const GAUGEEFFECT_NORMAL = 0;
const GAUGEEFFECT_POISON = 1;
//---------------------------

struct StatBase {
	var float Str;
	var float Dex;
	var float Vigor;
	var float Mp;
};
var StatBase Basis[3];
var StatBase Weight[3];

var int nChangeInfo;

struct AutoStatsUpData
{
	var int CurIndex;
	var float StartTime;
	var float UpTime;
};

var AutoStatsUpData AutoStatsUp;

var array<string> m_sTextList;

var CComboBox TitleComboBox;

var string m_sTitle;

function OnInit()
{
	if(PageX == -1)
		 ResetDefaultPosition();
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	SetComponentNotify(Components[2], BN_DetailInfo, Self);
//	SetComponentNotify(Components[9],BN_Str,Self);
//	SetComponentNotify(Components[10],BN_Dex,Self);
//	SetComponentNotify(Components[11],BN_Vigor,Self);
	SetComponentNotify(Components[12],BN_White,Self);
	SetComponentNotify(Components[13],BN_Red,Self);
	SetComponentNotify(Components[14],BN_Blue,Self);
	SetComponentNotify(Components[15],BN_Yellow,Self);
	SetComponentNotify(Components[16],BN_Black,Self);
	SetComponentNotify(Components[17],BN_Update,Self);
	SetComponentNotify(Components[18],BN_Cancel,Self);
	SetComponentNotify(Components[19],BN_Exit,Self);
	SetComponentNotify(Components[20],BN_AutoStat,Self);


	SetComponentNotify(Components[21],BN_StrUp ,Self);
	SetComponentNotify(Components[22],BN_strDown,Self);
	SetComponentNotify(Components[23],BN_DexUp ,Self);
	SetComponentNotify(Components[24],BN_DexDown,Self);
	SetComponentNotify(Components[25],BN_VigUp, Self);
	SetComponentNotify(Components[26],BN_VigDown, Self);

	SetComponentNotify(Components[27],BN_WhiteUp ,Self);
	SetComponentNotify(Components[28],BN_WhiteDown,Self);
	SetComponentNotify(Components[29],BN_RedUp ,Self);
	SetComponentNotify(Components[30],BN_RedDown,Self);
	SetComponentNotify(Components[31],BN_BlueUp ,Self);
	SetComponentNotify(Components[32],BN_BlueDown,Self);
	SetComponentNotify(Components[33],BN_YellowUp ,Self);
	SetComponentNotify(Components[34],BN_YellowDown ,Self);
	SetComponentNotify(Components[35],BN_BlackUp, Self);
	SetComponentNotify(Components[36],BN_BlackDown, Self);

	SetComponentNotify(Components[37],BN_TitleList ,Self);		//modified by yj

	SetComponentTextureId(Components[2],16,0,18,17);
	SetComponentTextureId(Components[17],33,32,32,34);
	SetComponentTextureId(Components[18],33,32,32,34);
	SetComponentTextureId(Components[19],5,0,19,6);
	SetComponentTextureId(Components[20],29,0,31,30);
	SetComponentTextureId(Components[21],10,0,11,12);
	SetComponentTextureId(Components[22],13,0,14,15);
	SetComponentTextureId(Components[23],10,0,11,12);
	SetComponentTextureId(Components[24],13,0,14,15);
	SetComponentTextureId(Components[25],10,0,11,12);
	SetComponentTextureId(Components[26],13,0,14,15);

	SetComponentTextureId(Components[27],10,0,11,12);
	SetComponentTextureId(Components[28],13,0,14,15);
	SetComponentTextureId(Components[29],10,0,11,12);
	SetComponentTextureId(Components[30],13,0,14,15);
	SetComponentTextureId(Components[31],10,0,11,12);
	SetComponentTextureId(Components[32],13,0,14,15);
	SetComponentTextureId(Components[33],10,0,11,12);
	SetComponentTextureId(Components[34],13,0,14,15);
	SetComponentTextureId(Components[35],10,0,11,12);
	SetComponentTextureId(Components[36],13,0,14,15);

	Components[2].Caption = Localize("Info","S_Detail","SephirothUI");

	if(SephirothPlayer(PlayerOwner).PSI.Current_Show_Title != "")
		Components[37].Caption = SephirothPlayer(PlayerOwner).PSI.Current_Show_Title;
	else
		Components[37].Caption = Localize("BattleInfo","NotShowTitle","SephirothUI");

	UpdateHPGauge();

	nChangeInfo = 0; // 일단은 초기화~

	m_sTextList[0] = "";
	m_sTextList[1] = Localize("Terms","Experience","Sephiroth");
	m_sTextList[2] = Localize("Terms","Health","Sephiroth");
	m_sTextList[3] = Localize("Terms","Mana","Sephiroth");
	m_sTextList[4] = Localize("Terms","Stamina","Sephiroth");
	m_sTextList[5] = Localize("Terms","Atk","Sephiroth");
	m_sTextList[6] = Localize("Terms","MagicAtk","Sephiroth");
    m_sTextList[7] = Localize("Info","S_DEF","SephirothUI");	//방어력(-/%)
    m_sTextList[8] = Localize("Info","S_MDEF","SephirothUI");	//마법 방어력(-/%)
    m_sTextList[9] = Localize("Info","S_CDEF","SephirothUI");   	//탄력도(-/%)
    m_sTextList[10] = Localize("Info","S_CMDEF","SephirothUI");     //마법 탄력도(-/%)
	m_sTextList[11] = Localize("Terms","BasicStats","Sephiroth");
	m_sTextList[12] = Localize("Terms","MagicStats","Sephiroth");
	m_sTextList[13] = Localize("Terms","LevelPoint","Sephiroth");
	m_sTextList[14] = Localize("Info","S_Basic","SephirothUI");

	m_sTextList[15] = Localize("Info","S_White","SephirothUI");
	m_sTextList[16] = Localize("Info","S_Red","SephirothUI");
	m_sTextList[17] = Localize("Info","S_Blue","SephirothUI");
	m_sTextList[18] = Localize("Info","S_Yellow","SephirothUI");
	m_sTextList[19] = Localize("Info","S_Black","SephirothUI");
	m_sTextList[20] = Localize("Info","S_Concent","SephirothUI");

	m_sTextList[21] = Localize("CItemInfoBox","S_Str","SephirothUI");
	m_sTextList[22] = Localize("CItemInfoBox","S_Dex","SephirothUI");
	m_sTextList[23] = Localize("CItemInfoBox","S_Vigor","SephirothUI");


	Basis[0].Str	= 64;
	Basis[0].Dex	= 42;
	Basis[0].Vigor	= 52;
	Basis[0].Mp		= 42;

	Basis[1].Str	= 44;
	Basis[1].Dex	= 41;
	Basis[1].Vigor	= 53;
	Basis[1].Mp		= 62;

	Basis[2].Str	= 45;
	Basis[2].Dex	= 60;
	Basis[2].Vigor	= 50;
	Basis[2].Mp		= 45;

	Weight[0].Str	= 0.44;
	Weight[0].Dex	= 0.23;
	Weight[0].Vigor	= 0.3;
	Weight[0].Mp	= 0.03;

	Weight[1].Str	= 0.08;
	Weight[1].Dex	= 0.22;
	Weight[1].Vigor	= 0.26;
	Weight[1].Mp	= 0.44;

	Weight[2].Str	= 0.3;
	Weight[2].Dex	= 0.4;
	Weight[2].Vigor	= 0.2;
	Weight[2].Mp	= 0.1;

	m_sTitle = Localize("Info","S_Title","SephirothUI");
}


function OnFlush()
{
	SaveConfig();
}

function Layout(Canvas C)
{
	local int DX,DY;
	local int i;

	if(bMovingUI) {
		if (bIsDragging) {
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else {
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

	if(TitleComboBox != None)	//(움직일경우를 위해)호칭 콤보박스도 갱신시켜주어야합니다. sinhyub
		MoveTitleComboBox(Components[37].X, Components[37].Y+Components[37].YL);
	Super.Layout(C);
}

function OnPreRender(Canvas C)
{
	local PlayerServerInfo PSI;
	local int manaState;
	local int i;
	local float fCurTime;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	Components[12].Caption = string(PSI.White + White);
	Components[13].Caption = string(PSI.Red + Red);
	Components[14].Caption = string(PSI.Blue + Blue);
	Components[15].Caption = string(PSI.Yellow + Yellow);
	Components[16].Caption = string(PSI.Black + Black);

	Components[17].bDisabled = PSI.LevelPoint <= 0 || UsedPoints <= 0;
	Components[18].bDisabled = PSI.LevelPoint <= 0 || UsedPoints <= 0;
	Components[20].bDisabled = PSI.LevelPoint - UsedPoints < 10;

	manaState = SephirothPlayer(PlayerOwner).PSI.ManaState;
	if( manaState != ManaNormal ){
		switch( manaState ){
			case ManaSaver:
                BindTextureResource(Components[7],TextureResources[8]);
				break;
			case ManaRebirth:
                BindTextureResource(Components[7],TextureResources[7]);
				break;
		}
	}

	if(AutoStatsUp.CurIndex > 0)
		if(Components[AutoStatsUp.CurIndex].nState != ePush)
			AutoStatsUp.CurIndex = -1;

	fCurTime = Level.TimeSeconds;

	DrawBackGround3x3(C, 64, 64, 20, 21, 22, 23, 24, 25, 26, 27, 28);
	DrawTitle(C, m_sTitle);

//	C.SetPos(Components[0].X + 11,Components[0].Y + 57);
//	C.DrawTile(TextureResources[36].Resource,Components[0].XL-20,4,0,0,4,4);

	C.SetPos(Components[0].X+42, Components[0].Y+536);	// 마법속성 백판
	C.DrawTile(TextureResources[35].Resource,50,99,0,0,50,99);

	for(i=21; i<37; i++)
	{
		if(IsCursorInsideComponent(Components[i]))
		{
			if(Components[i].nState == ePush)
			{
				if(AutoStatsUp.CurIndex != i)
				{
					AutoStatsUp.CurIndex = i;
					AutoStatsUp.StartTime = fCurTime;
				}
				else
				{
					if(fCurTime - AutoStatsUp.StartTime > 1.0f) // 1초 이상 누르고 있었다면
					{
						if(fCurTime - AutoStatsUp.Uptime < 0.05f) // 너무 빨리 올라가는 것을 방지
							return ;

						AutoStatsUp.Uptime = fCurTime;

						switch(i-9)
						{
							case BN_StrUp: SubtractValue(Str, 0); return ;
							case BN_strDown: AddValue(Str); return ;
							case BN_DexUp: SubtractValue(Dex, 0); return ;
							case BN_DexDown: AddValue(Dex); return ;
							case BN_VigUp: SubtractValue(Vigor, 0); return ;
							case BN_VigDown: AddValue(Vigor); return ;
							case BN_WhiteUp: SubtractValue(White, 0); return ;
							case BN_WhiteDown:  AddValue(White); return ;
							case BN_RedUp: SubtractValue(Red, 0); return ;
							case BN_RedDown: AddValue(Red); return ;
							case BN_BlackUp: SubtractValue(Black, 0); return ;
							case BN_BlackDown: AddValue(Black); return ;
							case BN_BlueUp: SubtractValue(Blue, 0); return ;
							case BN_BlueDown: AddValue(Blue); return ;
							case BN_YellowUp: SubtractValue(Yellow, 0); return ;
							case BN_YellowDown: AddValue(Yellow); return ;
						}
					}
				}
			}
		}
	}

	m_sTextList[0] = Localize("Terms",string(PSI.JobName), "Sephiroth");
}

function OnPostRender(HUD H, Canvas C)
{
	local PlayerServerInfo PSI;
	local float X,Y,offX, offY, XL, YL;
//	local string LvStr;
	local string sTemp, sA, sD, sPDEF, sDEF, sPMDEF, sMDEF;

	X = Components[0].X;
	Y = Components[0].Y;
	PSI = SephirothPlayer(PlayerOwner).PSI;

	// 기본 정보창
	C.SetPos(X+18, Y+37);
	C.DrawTile(TextureResources[16].Resource, 102, 24, 0, 0, 102, 24);		
	C.DrawKoreanText(Localize("Info","S_Basic","SephirothUI"),X+18, Y+37, 102, 24);


	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);


	if(SephirothPlayer(PlayerOwner).PSI.Current_Show_Title == "")
		C.DrawKoreanText(Localize("Info","S_NotUseTitle","SephirothUI"), X+30, Y+117, 182, 16);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(string(PSI.PlayName),X+32,Y+72,178,15);
	C.DrawKoreanText("Lv " $ PSI.PlayLevel $ " " $ m_sTextList[0],X+32,Y+92,178,15);

	C.DrawKoreanText(PSI.ExpDisplay $ "%",                        X+107,Y+150,116,10);

	C.DrawKoreanText(PSI.Health $ "/" $ PSI.MaxHealth,            X+107,Y+179,116,10);
	C.DrawKoreanText(PSI.Mana $ "/" $ PSI.MaxMana,                X+107,Y+198,116,10);
	C.DrawKoreanText(int(PSI.Stamina) $ "/" $ int(PSI.MaxStamina),X+107,Y+217,116,10);

	// 실수치 부분
	offX = X + 102;
	offY = Y + 242;
	XL = 116;
	YL = 14;

	// 공격/마공
	C.DrawKoreanText(PSI.ComboPower $ " - " $ PSI.FinishPower,offX,offY,XL,YL); offY += 21;
	C.DrawKoreanText(string(PSI.MagicPower),                   offX,offY,XL,YL);

	//방어력
	sTemp = PSI.DefenseEffect; // PDEF+DEF ( PMDEF+MDEF ) 구조로 넘어온다
	sA = Left(sTemp, Instr(sTemp, "(") - 1);
	sTemp = Mid(sTemp, Instr(sTemp, "(") +1, Len(sTemp));
	sD = Left(sTemp, Instr(sTemp, ")") - 1);

	sPDEF = Left(sA, Instr(sA, "+"));
	sDEF  = Mid(sA, Instr(sA, "+")+1, Len(sA));

	sPMDEF = Mid(sD, 1, Instr(sD, "+")-1);
	sMDEF = Mid(sD, Instr(sD, "+")+1, Len(sD));

	offX = X + 110;
	offY = Y + 290;
    //방어력  (-/%)
    C.DrawKoreanText("-" $ sPDEF@"/"@sDEF $ "%",										offX,offY,XL,YL); offY += 21;
    //마법 방어력(-/%)
    C.DrawKoreanText("-" $ sPMDEF@"/"@sMDEF $ "%",										offX,OffY,XL,YL); offY += 21;
    //탄력도(-/%)
    C.DrawKoreanText("-" $ PSI.DI.AbsCriticalDefense@"/"@PSI.DI.CriticalDefense $ "%",	offX,OffY,XL,YL); offY += 21;
    //마법탄력도(-/%)
    C.DrawKoreanText("-" $ PSI.DI.AbsCriticalResist@"/"@PSI.DI.MagicCriticalResist $ "%",offX,OffY,XL,YL); offY += 21;
	// 집중력 분산력
    C.DrawKoreanText(PSI.damageConcentration / 10 $ "%" @"/"@PSI.damageDistribution / 10 $ "%",offX,OffY,XL,YL); offY += 21;


	// 힘민체
	C.DrawKoreanText(PSI.Str+Str,    X+99,Y+445,84,14);
	C.DrawKoreanText(PSI.Dex+Dex,    X+99,Y+466,84,14);
	C.DrawKoreanText(PSI.Vigor+Vigor,X+99,Y+487,84,14);


	C.SetDrawColor(229,201,174);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

	// 경험치 체력 마나 스테
	C.DrawKoreanText(m_sTextList[1],		X+18,Y+148,101,14);
	C.DrawKoreanText(m_sTextList[2],		X+18,Y+176,101,14);
	C.DrawKoreanText(m_sTextList[3],		X+18,Y+196,101,14);
	C.DrawKoreanText(m_sTextList[4],		X+18,Y+215,101,14);

	//공격력
	C.DrawKoreanText(m_sTextList[5],		X+18,Y+243,101,14);
	C.DrawKoreanText(m_sTextList[6],		X+18,Y+262,101,14);

	//방어력
	C.DrawKoreanText(m_sTextList[7],		X+18,Y+291,101,14);
	C.DrawKoreanText(m_sTextList[8],		X+18,Y+312,101,14);
	C.DrawKoreanText(m_sTextList[9],		X+18,Y+333,101,14);
	C.DrawKoreanText(m_sTextList[10],		X+18,Y+354,101,14);
	C.DrawKoreanText(m_sTextList[20],		X+18,Y+375,101,14);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	if(false)
	{
	C.SetPos(X+25, Y+446);
	C.DrawRect1fix(60, 14);
	}

	// 힘민원
	C.DrawKoreanText(m_sTextList[21],		X+25,Y+446,60,14);
	C.DrawKoreanText(m_sTextList[22],		X+25,Y+467,60,14);
	C.DrawKoreanText(m_sTextList[23],		X+25,Y+488,60,14);

	//마속
	C.DrawKoreanText(m_sTextList[15],		X+25,Y+537,60,14);
	C.DrawKoreanText(m_sTextList[16],		X+25,Y+558,60,14);
	C.DrawKoreanText(m_sTextList[17],		X+25,Y+579,60,14);
	C.DrawKoreanText(m_sTextList[18],		X+25,Y+600,60,14);
	C.DrawKoreanText(m_sTextList[19],		X+25,Y+621,60,14);

	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(m_sTextList[11],X+25,Y+424,60,14);	// 기본속성
	C.DrawKoreanText(m_sTextList[12],X+25,Y+517,60,14);	// 마법속성
	C.DrawKoreanText(PSI.White+PSI.Red+PSI.Blue+PSI.Yellow+PSI.Black+White+Red+Blue+Yellow+Black,X+99,Y+517,84,15);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

	// 전체 스텟 포인트
	C.SetDrawColor(169,204,82);
	C.DrawKoreanText(m_sTextList[13],X+23,Y+402,70,14);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.DrawKoreanText(PSI.LevelPoint-UsedPoints,X+93,Y+400,128,16);


	// 기본 정보창 탭 이미지
	C.SetDrawColor(255,255,255);
	C.SetPos(X+18, Y+37);
	C.DrawTile(TextureResources[18].Resource, 104, 24, 0, 0, 104, 24);		
	C.DrawKoreanText(Localize("Info","S_Basic","SephirothUI"),X+18, Y+37, 104, 24);


	// keios - pvp 정보 임시
/**
	// 테섭 이벤트를 제거하면서 함께 제거한다
	C.SetDrawColor(0, 0, 0);
	C.SetPos(X+41+1,Y+380+1);
	C.DrawText(Localize("Terms","CurrentPKPts","Sephiroth")@PSI.PkPts);
	C.SetDrawColor(255, 255, 255);
	C.SetPos(X+41,Y+380);
	C.DrawText(Localize("Terms","CurrentPKPts","Sephiroth")@PSI.PkPts);
**/
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_LeftMouse) {
		if ((Action == IST_Press) && IsCursorInsideComponent(Components[0]))
		{
			bMovingUI = true;
			bIsDragging = true;
			bMovingUI = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		if (Action == IST_Release && bIsDragging) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}

function CloseInfo()
{
	if (UsedPoints > 0)
		class'CMessageBox'.static.MessageBox(Self,"StatUpdate",Localize("Modals","StatUpdate","Sephiroth"),MB_YesNo,IDM_UpdateStat);
	else
		Parent.NotifyInterface(Self,INT_Close);
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int NotifyValue;
	local string TitleName;

	if (Interface == TitleComboBox && NotifyType == INT_Command) {
		Components[37].Caption = Command;
		if(Command == Localize("BattleInfo","NotShowTitle","SephirothUI") )		//'보이지 않기' 라면 TitleName="";
			TitleName = "";
		else
			TitleName = Command;
		SephirothPlayer(PlayerOwner).Net.NotiChangePlayerTitle(TitleName);		
		HideTitleComboBox();
	}

	if (NotifyType == INT_MessageBox) {
		NotifyValue = int(Command);
		if (NotifyValue == IDM_UpdateStat)
			UpdateStat();
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function DefaultStat()
{
	Str = 0;
	Dex = 0;
	Vigor = 0;
	White = 0;
	Red = 0;
	Blue = 0;
	Yellow = 0;
	Black = 0;
	UsedPoints = 0;
}

function UpdateStat()
{
	local PlayerServerInfo PSI;
	local SepNetInterface Net;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	Net = SephirothPlayer(PlayerOwner).Net;
	if (Str>0) Net.NotiUsePoint(0,Str);
	if (Dex>0) Net.NotiUsePoint(1,Dex);
	if (Vigor>0) Net.NotiUsePoint(2,Vigor);
	if (White>0) Net.NotiUsePoint(3,White);
	if (Red>0) Net.NotiUsePoint(4,Red);
	if (Blue>0) Net.NotiUsePoint(5,Blue);
	if (Yellow>0) Net.NotiUsePoint(6,Yellow);
	if (Black>0) Net.NotiUsePoint(7,Black);
	Str = 0;
	Dex = 0;
	Vigor = 0;
	White = 0;
	Red = 0;
	Blue = 0;
	Yellow = 0;
	Black = 0;
	UsedPoints = 0;
}

function AutoStat()
{
/*

	Basis(0)=(Str=64,Dex=42,Vigor=52,Mp=42)		//무투, 한손검
	Basis(1)=(Str=44,Dex=41,Vigor=53,Mp=62)		//레법, 블법
	Basis(2)=(Str=45,Dex=60,Vigor=50,Mp=45)		//궁수

	Weight(0)=(Str=0.47,Dex=0.24,Vigor=0.24,Mp=0.05)
	Weight(1)=(Str=0.08,Dex=0.22,Vigor=0.26,Mp=0.44)
	Weight(2)=(Str=0.3,Dex=0.4,Vigor=0.2,Mp=0.1)


전사 (칼전사+무투가)
힘
40+(50*0.47)+( (lv-1)*10*0.47)
덱스
30+(50*0.24)+( (lv-1)*10*0.24)
비거
40+(50*0.24)+( (lv-1)*10*0.24)
마법력 (Default는 Black)
40+(50*0.05)+( (lv-1)*10*0.05)


마법사
힘
40+(50*0.08)+( (lv-1)*10*0.08)
덱스
30+(50*0.22)+( (lv-1)*10*0.22)
비거
40+(50*0.26)+( (lv-1)*10*0.26)
마법력
40+(50*0.44)+( (lv-1)*10*0.44)


자동 분배 방식

1) 현재 레벨에서 각 속성치별 기준 값을 위의 공식으로 구한다.
2) 기준값에서 현재 자신의 속성값들을 뺀다(0보다 작으면 0으로 한다.)
3) 남은 스탯을 2)번에서 구한 비율로 나누어 올린다(반올림한다.)

예) 현재 Lv 30의 전사이며, Str 250, Dex 50, MP 50, Vigor 50 남은 포인트가 90일때

기준 스텟은 Str 200, Dex 112, MP 57, Vigor 122이다.
현재 스탯을 빼면 ( -50, 62, 7, 72) 인데, 음수를 0으로 바꾸면 (0,62,7,72)이다.
이 비율로 남음 90포인트를 분배하면,

Dex = 90 * 62 / ( 62+7+72) = 39.57 = 40
MP = 90 * 7 / ( 62+7+72) = 4.46 = 4
Vigor = 90 * 72 / (62+7+72) = 45.95 = 46

4) 중간에 잘못 올렸더라도 자동분배를 계속 하면 기준 스탯으로 간다.

  ========================== [ MOST RECENTLY DATA ] =========================
전사/무투가
Str 64 (0.47)     Dex 42 (0.24)     Vig 52 (0.24)    Mp 42 (0.05)

마법사
Str 44 (0.08)    Dex 41 (0.22)    Vig 53 (0.26)    Mp 62 (0.44)

궁수
Str 45 (0.3)    Dex 60 (0.4)    Vig 50 (0.2)    Mp 45 (0.1)
*/
	local name Job;
	local int LocalLevel;
	local StatBase StatBase;
	local PlayerServerInfo PSI;
	local int MP;
	local float Sum;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	MP = PSI.White + PSI.Red + PSI.Blue + PSI.Yellow + PSI.Black;
	LocalLevel = PSI.PlayLevel;
	Job = PSI.JobName;
/*
전사 (칼전사+무투가)
힘
40+(50*0.47)+( (lv-1)*10*0.47)
덱스
30+(50*0.24)+( (lv-1)*10*0.24)
비거
40+(50*0.24)+( (lv-1)*10*0.24)
마법력 (Default는 Black)
40+(50*0.05)+( (lv-1)*10*0.05)
*/

	if (Job == 'OneHand' || Job == 'Bare')	{

		StatBase.Str = Basis[0].Str + ((LocalLevel-1)*10.0*Weight[0].Str);
		StatBase.Dex = Basis[0].Dex + ((LocalLevel-1)*10.0*Weight[0].Dex);
		StatBase.Vigor = Basis[0].Vigor + ((LocalLevel-1)*10.0*Weight[0].Vigor);
		StatBase.Mp = Basis[0].Mp + ((LocalLevel-1)*10.0*Weight[0].Mp);
	}
	else if (Job == 'Red' || Job == 'Blue' || Job == 'Yellow')	{

		StatBase.Str = Basis[1].Str + ((LocalLevel-1)*10.0*Weight[1].Str);
		StatBase.Dex = Basis[1].Dex + ((LocalLevel-1)*10.0*Weight[1].Dex);
		StatBase.Vigor = Basis[1].Vigor + ((LocalLevel-1)*10.0*Weight[1].Vigor);
		StatBase.Mp = Basis[1].Mp + ((LocalLevel-1)*10.0*Weight[1].Mp);
	}
	else if (Job == 'Bow')	{

		StatBase.Str = Basis[2].Str + ((LocalLevel-1)*10.0*Weight[2].Str);
		StatBase.Dex = Basis[2].Dex + ((LocalLevel-1)*10.0*Weight[2].Dex);
		StatBase.Vigor = Basis[2].Vigor + ((LocalLevel-1)*10.0*Weight[2].Vigor);
		StatBase.Mp = Basis[2].Mp + ((LocalLevel-1)*10.0*Weight[2].Mp);
	}

	StatBase.Str = max(0, StatBase.Str - PSI.Str);
	StatBase.Dex = max(0, StatBase.Dex - PSI.Dex);
	StatBase.Vigor = max(0, StatBase.Vigor - PSI.Vigor);
	StatBase.Mp = max(0, StatBase.Mp - MP);
	Sum = StatBase.Str + StatBase.Dex + StatBase.Vigor + StatBase.Mp;

	StatBase.Str = int(PSI.LevelPoint * StatBase.Str / Sum);
	StatBase.Dex = int(PSI.LevelPoint * StatBase.Dex / Sum);
	StatBase.Vigor = int(PSI.LevelPoint * StatBase.Vigor / Sum);
	StatBase.Mp = int(PSI.LevelPoint * StatBase.Mp / Sum);
	Sum = StatBase.Str + StatBase.Dex + StatBase.Vigor + StatBase.Mp;

	Str = StatBase.Str;		//이번에 올릴 stat point 수!  쌓여온거 말구
	Dex = StatBase.Dex;
	Vigor = StatBase.Vigor;
	if (Job == 'OneHand' || Job == 'Bare' || Job == 'Bow')
		Black = StatBase.Mp;
	else if (Job == 'Blue')
		Blue = StatBase.Mp;
	else if (Job == 'Red')
		Red = StatBase.Mp;
	UsedPoints = Sum;
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	switch (CmpId) {
    case 6: // Health
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Health;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxHealth;
		break;
    case 7: // Mana
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Mana;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxMana;
		break;
	case 8: // Stamina
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Stamina;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxStamina;
		break;
    case 5: // Exp
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
		V.Z = 100.0;
		break;
	}
	return V;
}

function AddValue(out int Value)
{
	local PlayerServerInfo PSI;
	PSI = SephirothPlayer(PlayerOwner).PSI;
	if (PSI.LevelPoint - UsedPoints > 0) {
		Value++;
		UsedPoints++;
	}
}

function SubtractValue(out int Value,int Min)
{
	if (Value-1 >= Min) {
		Value--;
		UsedPoints--;
	}
}

function ShowTitleComboBox()		//modified by yj
{
	local int i;
	local PlayerServerInfo PSI;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	TitleComboBox = CComboBox(AddInterface("Interface.CComboBox"));
	if (TitleComboBox != None) {
		TitleComboBox.ShowInterface();
		TiTleComboBox.SetSize(186,96);
		TitleComboBox.SetPos(Components[37].X,Components[37].Y+Components[37].YL);
		for(i=0; i<PSI.Acquired_Title_List.length; i++)
			TitlecomboBox.AddList(PSI.Acquired_Title_List[i].Title);

		TitlecomboBox.AddList(Localize("BattleInfo","NotShowTitle","SephirothUI"));		//modified by yj		//보이지 않기 기능 추가.
	}
}

function MoveTitleComboBox(int X, int Y)
{
	TitleComboBox.SetPos(X,Y);
}

function HideTitleComboBox()
{
	if (TitleComboBox != None) {
		TitleComboBox.HideInterface();
		RemoveInterface(TitleComboBox);
		TitleComboBox = None;
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Exit)
		CloseInfo();
	else if(NotifyId == BN_DetailInfo)
	{
		nChangeInfo = 2;
		CloseInfo();
	}
	else if(NotifyId == BN_TitleList) {
		if(TitleComboBox != None)
			HideTitlecomboBox();
		else
			ShowTitleComboBox();
	}
	else {
		if (SephirothPlayer(PlayerOwner).PSI.LevelPoint <= 0)
			return;
		switch (NotifyId) {
		case BN_Str: AddValue(Str); break;
		case BN_Dex: AddValue(Dex); break;
		case BN_Vigor: AddValue(Vigor); break;
		case BN_White: AddValue(White); break;
		case BN_Red: AddValue(Red); break;
		case BN_Blue: AddValue(Blue); break;
		case BN_Yellow: AddValue(Yellow); break;
		case BN_Black: AddValue(Black); break;
		case -1*BN_Str: SubtractValue(Str, 0); break;
		case -1*BN_Dex: SubtractValue(Dex, 0); break;
		case -1*BN_Vigor: SubtractValue(Vigor, 0); break;
		case -1*BN_White: SubtractValue(White, 0); break;
		case -1*BN_Red: SubtractValue(Red, 0); break;
		case -1*BN_Blue: SubtractValue(Blue, 0); break;
		case -1*BN_Yellow: SubtractValue(Yellow, 0); break;
		case -1*BN_Black: SubtractValue(Black, 0); break;
		case BN_Update: UpdateStat(); break;
		case BN_Cancel: DefaultStat(); break;
		case BN_AutoStat: AutoStat(); break;

		// 새로 추가 버튼
		case BN_StrUp: SubtractValue(Str, 0); break;
		case BN_strDown: AddValue(Str); break;
		case BN_DexUp: SubtractValue(Dex, 0); break;
		case BN_DexDown: AddValue(Dex); break;
		case BN_VigUp: SubtractValue(Vigor, 0); break;
		case BN_VigDown: AddValue(Vigor); break;

		case BN_WhiteUp: SubtractValue(White, 0); break;
		case BN_WhiteDown:  AddValue(White); break;
		case BN_RedUp: SubtractValue(Red, 0); break;
		case BN_RedDown: AddValue(Red); break;
		case BN_BlackUp: SubtractValue(Black, 0); break;
		case BN_BlackDown: AddValue(Black); break;
		case BN_BlueUp: SubtractValue(Blue, 0); break;
		case BN_BlueDown: AddValue(Blue); break;
		case BN_YellowUp: SubtractValue(Yellow, 0); break;
		case BN_YellowDown: AddValue(Yellow); break;
		}
	}
}

function ChangeManaBar()
{
	switch(SephirothPlayer(PlayerOwner).PSI.ManaState){
	case ManaNormal:
		BindTextureResource(Components[7],TextureResources[2]);
		break;
	case ManaSaver:
		BindTextureResource(Components[7],TextureResources[8]);
		break;
	case ManaRebirth:
		BindTextureResource(Components[7],TextureResources[7]);
		break;
	}
}


// keios - hp 색의 변경
function UpdateHPGauge()
{
	switch(SephirothPlayer(PlayerOwner).HPGaugeStatus.gauge_effect)
	{
	case GAUGEEFFECT_NORMAL:
		BindTextureResource(Components[ID_HP], TextureResources[1]);
		break;
	case GAUGEEFFECT_POISON:
		BindTextureResource(Components[ID_HP], TextureResources[9]);
		break;
	}
}

function ResetDefaultPosition()		//2009.10.27.Sinhyub
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
	pos = InStr(Resolution, "x");

	ClipX=int(Left(Resolution, pos));
	ClipY=int(Mid(Resolution,pos+1));

	PageX = WinWidth/2;
	PageY = WinHeight/3;

	SaveConfig();
}

defaultproperties
{
     PageX=-1.000000
     Basis(0)=(str=64.000000,Dex=42.000000,Vigor=52.000000,Mp=42.000000)
     Basis(1)=(str=44.000000,Dex=41.000000,Vigor=53.000000,Mp=62.000000)
     Basis(2)=(str=45.000000,Dex=60.000000,Vigor=50.000000,Mp=45.000000)
     Weight(0)=(str=0.440000,Dex=0.230000,Vigor=0.300000,Mp=0.030000)
     Weight(1)=(str=0.080000,Dex=0.220000,Vigor=0.260000,Mp=0.440000)
     Weight(2)=(str=0.300000,Dex=0.400000,Vigor=0.200000,Mp=0.100000)
     Components(0)=(XL=242.000000,YL=691.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=220.000000,YL=609.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=57.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=123.000000,OffsetYL=37.000000,TextAlign=TA_MiddleCenter)
     Components(5)=(Id=5,ResId=3,Type=RES_Gauge,XL=114.000000,YL=10.000000,PivotDir=PVT_Copy,OffsetXL=103.000000,OffsetYL=150.000000,GaugeDir=GDT_Right)
     Components(6)=(Id=6,ResId=1,Type=RES_Gauge,XL=114.000000,YL=10.000000,PivotDir=PVT_Copy,OffsetXL=103.000000,OffsetYL=179.000000,GaugeDir=GDT_Right)
     Components(7)=(Id=7,ResId=2,Type=RES_Gauge,XL=114.000000,YL=10.000000,PivotDir=PVT_Copy,OffsetXL=103.000000,OffsetYL=198.000000,GaugeDir=GDT_Right)
     Components(8)=(Id=8,ResId=4,Type=RES_Gauge,XL=114.000000,YL=10.000000,PivotDir=PVT_Copy,OffsetXL=103.000000,OffsetYL=217.000000,GaugeDir=GDT_Right)
     Components(12)=(Id=12,Type=RES_TextButton,XL=84.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=99.000000,OffsetYL=537.000000,TextAlign=TA_MiddleCenter)
     Components(13)=(Id=13,Type=RES_TextButton,XL=84.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=99.000000,OffsetYL=558.000000,TextAlign=TA_MiddleCenter)
     Components(14)=(Id=14,Type=RES_TextButton,XL=84.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=99.000000,OffsetYL=579.000000,TextAlign=TA_MiddleCenter)
     Components(15)=(Id=15,Type=RES_TextButton,XL=84.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=99.000000,OffsetYL=600.000000,TextAlign=TA_MiddleCenter)
     Components(16)=(Id=16,Type=RES_TextButton,XL=84.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=99.000000,OffsetYL=621.000000,TextAlign=TA_MiddleCenter)
     Components(17)=(Id=17,Caption="Ok",Type=RES_PushButton,XL=54.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=112.000000,OffsetYL=642.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(18)=(Id=18,Caption="Cancel",Type=RES_PushButton,XL=54.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=168.000000,OffsetYL=642.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(19)=(Id=19,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=211.000000,OffsetYL=16.000000,HotKey=IK_Escape)
     Components(20)=(Id=20,Caption="AutoStat",Type=RES_PushButton,XL=88.000000,YL=21.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=642.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(21)=(Id=21,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=442.000000)
     Components(22)=(Id=22,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=21,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(23)=(Id=23,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=463.000000)
     Components(24)=(Id=24,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=23,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(25)=(Id=25,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=484.000000)
     Components(26)=(Id=26,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=25,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(27)=(Id=27,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=534.000000)
     Components(28)=(Id=28,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=27,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(29)=(Id=29,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=555.000000)
     Components(30)=(Id=30,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=29,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(31)=(Id=31,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=576.000000)
     Components(32)=(Id=32,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=31,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(33)=(Id=33,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=597.000000)
     Components(34)=(Id=34,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=33,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(35)=(Id=35,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=181.000000,OffsetYL=618.000000)
     Components(36)=(Id=36,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotId=35,PivotDir=PVT_Right,OffsetXL=-1.000000)
     Components(37)=(Id=37,Type=RES_PushButton,XL=186.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=30.000000,OffsetYL=117.000000,TextAlign=TA_MiddleCenter)
     TextureResources(0)=(Package="UI_2011",Path="chr_info_1",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="Gauge_red_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="Gauge_blu_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="gauge_org_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="Gauge_yell_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="gauge_cyan_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="gauge_vio_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="gauge_grn_l",UL=114.000000,VL=10.000000,Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_s_-_n",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_s_-_o",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_s_-_c",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_s_+_n",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_s_+_o",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_s_+_c",UL=20.000000,VL=20.000000,Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="chr_tab_n",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="chr_tab_o",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(28)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(29)=(Package="UI_2011_btn",Path="btn_yell_m_n",Style=STY_Alpha)
     TextureResources(30)=(Package="UI_2011_btn",Path="btn_yell_m_o",Style=STY_Alpha)
     TextureResources(31)=(Package="UI_2011_btn",Path="btn_yell_m_c",Style=STY_Alpha)
     TextureResources(32)=(Package="UI_2011_btn",Path="btn_yell_s_n",Style=STY_Alpha)
     TextureResources(33)=(Package="UI_2011_btn",Path="btn_yell_s_o",Style=STY_Alpha)
     TextureResources(34)=(Package="UI_2011_btn",Path="btn_yell_s_c",Style=STY_Alpha)
     TextureResources(35)=(Package="UI_2011",Path="chr_color_bg",Style=STY_Alpha)
     TextureResources(36)=(Package="UI_2011",Path="tab_line",Style=STY_Alpha)
     WinWidth=242.000000
     WinHeight=691.000000
     IsBottom=True
}
