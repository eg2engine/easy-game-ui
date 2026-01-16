class CMentorQuest	extends CMultiInterface;

const BN_QUEST1	= 1;
const BN_QUEST2	= 2;
const BN_QUEST3	= 3;
const BN_QUEST4	= 4;
const BN_QUEST5	= 5;
const BN_QUEST6	= 6;

const BN_FIRST	= 7;
const BN_LAST	= 8;
const BN_PREVIOUS	= 9;
const BN_NEXT	= 10;

const IDM_ToPrevPage	= 101;
const IDM_ToNextPage	= 102;
const IDM_ToFirstPage	= 103;
const IDM_ToLastPage	= 104;

var float PageX,PageY;
var int	nSelectIndex;
var PlayerServerInfo PSI;
var int nCurrPage, nMaxPage;

var int nTotalQuest;

function OnInit()
{
	local int n;

	nCurrPage = 0;
	nMaxPage = 3;
	nTotalQuest = 15;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	bNeedLayoutUpdate = true;

	for ( n = 0 ; n < 6 ; n++ )
	{
		SetComponentNotify(Components[2 + n], BN_QUEST1 + n, Self);
		SetComponentTextureId(Components[2 + n], 1, -1, 2, 3);
	}

	nSelectIndex = -1;

	SetComponentTextureId(Components[1], 4);

	SetComponentNotify(Components[8], BN_FIRST, Self);	// 처음으로 버튼 ( << )
	SetComponentTextureId(Components[8], 11, -1, 12, 13);

	SetComponentNotify(Components[9], BN_LAST, Self);	// 끝으로 버튼 ( >> )
	SetComponentTextureId(Components[9], 14, -1, 15, 16);

	SetComponentNotify(Components[10], BN_PREVIOUS, Self);	// 이전으로 버튼 ( < )
	SetComponentTextureId(Components[10], 5, -1, 6, 7);

	SetComponentNotify(Components[11], BN_NEXT, Self);	// 다음으로 버튼 ( > )
	SetComponentTextureId(Components[11], 8, -1, 9, 10);

	UpdatePage(nCurrPage);
}


function OnFlush()
{
	Saveconfig();
}


event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	CheckMouseOver();
}

function MoveWindow(int OffsetX, int OffsetY)
{
	PageX = OffsetX;
	PageY = OffsetY;
}


function Layout(Canvas C)
{
	//local int DX,DY;
	local int i;

	MoveComponent(Components[0], true, PageX, PageY, WinWidth, WinHeight);

	for ( i = 1 ; i < Components.Length; i++ )
		MoveComponent(Components[i]);
}


function OnPostRender(HUD H, Canvas C)
{
//	if ( nSelectIndex >= 0 && nSelectIndex < 5 )
//	{
//		class'CNativeInterface'.static.DrawRect(Components[1 + nSelectIndex].X, Components[1 + nSelectIndex].Y, Components[1 + nSelectIndex].X + Components[1 + nSelectIndex].XL, Components[1 + nSelectIndex].Y + Components[1 + nSelectIndex].YL,
//												class'Canvas'.static.MakeColor(255, 128, 255));
//	}
}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch ( NotifyId )
	{
	case BN_QUEST1 :
	case BN_QUEST2 :
	case BN_QUEST3 :
	case BN_QUEST4 :
	case BN_QUEST5 :
	case BN_QUEST6 :

		SephirothPlayer(PlayerOwner).Net.NotiAcceptRPQuest(nCurrPage * 6 + (NotifyId - BN_QUEST1));
		break;

	case BN_FIRST :

		nCurrPage = 0;
		UpdatePage(nCurrPage);
		break;
		
	case BN_LAST :

		nCurrPage = max(0, nMaxPage - 1);
		UpdatePage(nCurrPage);
		break;

	case BN_PREVIOUS :

		nCurrPage = max(nCurrPage - 1, 0);
		UpdatePage(nCurrPage);
		break;

	case BN_NEXT :

		nCurrPage = min(max(0, nMaxPage - 1), nCurrPage + 1);;
		UpdatePage(nCurrPage);
		break;
	}
}


function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}


function UpdatePage(int nPage)
{
	local int nFirst, nLast;
	local int i, j, nCurr;

	// 일단 클리어한 다음
	for ( i = 0 ; i < 6 ; i++ )
	{
		for ( j = 0 ; j < 7 ; j++ )
			VisibleComponent(Components[13 + i * 7 + j], false);
	}

	// 현재 페이지에 해당하는 내용들로 채운다
	nFirst = nPage * 6;
	nLast = min((nPage + 1) * 6, nTotalQuest);

	for ( i = nFirst ; i < nLast ; i++ )
	{
		nCurr = i - nFirst;

		for ( j = 0 ; j < 7 ; j++ )
			VisibleComponent(Components[13 + nCurr * 7 + j], true);
			
		SetComponentTextureId(Components[13 + nCurr * 7], 17);
	}
	
	SetComponentText(Components[12], (nCurrPage + 1) @ "/" @ nMaxPage );
}


function CheckMouseOver()
{
	local int n;

	nSelectIndex = -1;

	for ( n = 0 ; n < 5 ; n++ )
	{
		if ( IsCursorInsideComponent(Components[1+n]) )
		{
			nSelectIndex = n;
			return;
		}
	}
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=326.000000,YL=529.000000)
     Components(1)=(Id=1,Caption="MentorQuest",Type=RES_TextButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=111.000000,OffsetYL=-20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=14.000000)
     Components(3)=(Id=3,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=10.000000)
     Components(4)=(Id=4,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=10.000000)
     Components(5)=(Id=5,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=10.000000)
     Components(6)=(Id=6,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=10.000000)
     Components(7)=(Id=7,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=10.000000)
     Components(8)=(Id=8,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=91.000000,OffsetYL=458.000000)
     Components(9)=(Id=9,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=221.000000,OffsetYL=458.000000)
     Components(10)=(Id=10,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=120.000000,OffsetYL=458.000000)
     Components(11)=(Id=11,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=193.000000,OffsetYL=458.000000)
     Components(12)=(Id=12,Type=RES_Text,XL=50.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=141.000000,OffsetYL=460.000000,TextAlign=TA_MiddleRight,TextColor=(B=174,G=201,R=229,A=255))
     Components(13)=(Id=13,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(14)=(Id=14,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(15)=(Id=15,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(16)=(Id=16,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(17)=(Id=17,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(18)=(Id=18,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(19)=(Id=19,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(20)=(Id=20,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(21)=(Id=21,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(22)=(Id=22,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(23)=(Id=23,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(24)=(Id=24,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(25)=(Id=25,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(26)=(Id=26,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(27)=(Id=27,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(28)=(Id=28,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(29)=(Id=29,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(30)=(Id=30,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(31)=(Id=31,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(32)=(Id=32,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(33)=(Id=33,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(34)=(Id=34,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(35)=(Id=35,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(36)=(Id=36,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(37)=(Id=37,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(38)=(Id=38,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(39)=(Id=39,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(40)=(Id=40,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(41)=(Id=41,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(42)=(Id=42,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(43)=(Id=43,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(44)=(Id=44,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(45)=(Id=45,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(46)=(Id=46,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(47)=(Id=47,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(48)=(Id=48,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=10.000000)
     Components(49)=(Id=49,Caption="CapQuestName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=5.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(50)=(Id=50,Caption="CapProcCondition",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=24.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(51)=(Id=51,Caption="CapReward",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=43.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(52)=(Id=52,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(53)=(Id=53,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(54)=(Id=54,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     TextureResources(0)=(Package="UI_2011",Path="master_info_3",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_master_slot_3_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_master_slot_3_c",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_master_slot_3_o",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_s_arr_l_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_s_arr_l_c",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_s_arr_l_o",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_s_arr_r_n",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_s_arr_r_c",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_s_arr_r_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_s_arr_l_n_2",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_s_arr_l_c_2",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_s_arr_l_o_2",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_s_arr_r_n_2",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_s_arr_r_c_2",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_s_arr_r_o_2",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011",Path="emble_master_lock",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011",Path="emble_master_gold_lock",Style=STY_Alpha)
     WinWidth=326.000000
     WinHeight=529.000000
     IsBottom=True
}
