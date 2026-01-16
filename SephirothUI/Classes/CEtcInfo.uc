class CEtcInfo extends CInterface
	config(SephirothUI);

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

const BN_Exit = 1;

var PlayerServerInfo PSI;

var string Title;
var string BattleInfo;
var string Rank;
var string AccumulatedPoint;
var string WinCounts;
var string LoseCounts;
var string DrawCounts;
var string KillsCounts;
var string DeadsCounts;
var string NotShowTitle;


//add neive : �Ȱ� ���� ���� ����
var string DungeonInfo;
var string MistVillage_Day;
var string MistVillage_Night;

var int Rank_Left_X, Rank_Left_Y, WinCounts_Left_X, WinCounts_Left_Y;
var int Rank_Right_X, Rank_Right_Y, WinCounts_Right_X, WinCounts_Right_Y;

var int Schedule_X, Schedule_Y;

const TextBoxWidth = 122;	//�� ĭ ����

var string WeeklyDungeonProgression;
var string ParamText1;
var string ParamText2;
var string ParamText3;
var string ParamText4;

function OnInit()
{
	PSI = SephirothPlayer(PlayerOwner).PSI;

	SetComponentTextureId(Components[1],9, -1,9,10);
	SetComponentNotify(Components[1],BN_Exit,Self);

	Title = Localize("EtcInfo","Title","SephirothUI");

	BattleInfo = Localize("EtcInfo","BattleInfo","SephirothUI");
	Rank = Localize("EtcInfo","Rank","SephirothUI");
	AccumulatedPoint = Localize("EtcInfo","AccumulatedPoint","SephirothUI");
	WinCounts = Localize("EtcInfo","WinCounts","SephirothUI");
	LoseCounts = Localize("EtcInfo","LoseCounts","SephirothUI");
	DrawCounts = Localize("EtcInfo","DrawCounts","SephirothUI");
	KillsCounts = Localize("EtcInfo","KillsCounts","SephirothUI");
	DeadsCounts = Localize("EtcInfo","DeadsCounts","SephirothUI");
	NotShowTitle = Localize("EtcInfo","NotShowTitle","SephirothUI");


	DungeonInfo = Localize("EtcInfo","DunInfo","SephirothUI");
	MistVillage_Day = Localize("Schedule","MistVillage_Day","SephirothUI");
	MistVillage_Night = Localize("Schedule","MistVillage_Night","SephirothUI");

	WeeklyDungeonProgression = Localize("Schedule","Weekly_Dungeon_Progression","SephirothUI");
	ParamText1 = Localize("Schedule","ParamText1","SephirothUI");
	ParamText2 = Localize("Schedule","ParamText2","SephirothUI");
	ParamText3 = Localize("Schedule","ParamText3","SephirothUI");
	ParamText4 = Localize("Schedule","ParamText4","SephirothUI");

	bNeedLayoutUpdate = True;
}

function OnFlush()
{
	Saveconfig();
}

function Layout(Canvas C)
{
	local int DX,DY;
	local int i;

	if( bMovingUI ) 
	{
		if ( bIsDragging )
		{
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			PageX = DX;
			PageY = DY;
		}
		else 
		{
			if ( PageX < 0 )
				PageX = 0;
			else if (PageX + WinWidth > C.ClipX)
				PageX = C.ClipX - WinWidth;

			if ( PageY < 0 )
				PageY = 0;
			else if (PageY + WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight;
			bMovingUI = False;
		}

		Rank_Left_X = PageX + 14;
		Rank_Left_Y = PageY + 91;
		WinCounts_Left_X = PageX + 14;
		WinCounts_Left_Y = PageY + 132;
		Rank_Right_X = PageX + 134;	
		Rank_Right_Y = PageY + 91;
		WinCounts_Right_X = PageX + 134;
		WinCounts_Right_Y = PageY + 132;

		Schedule_X = PageX + 14;
		Schedule_Y = PageY + 255;


		bNeedLayoutUpdate = True;
	}
	
	if( bNeedLayoutUpdate ) 
	{
		MoveComponent(Components[0],True,PageX,PageY,WinWidth,WinHeight);
		for ( i = 1;i < Components.Length;i++ )
			MoveComponent(Components[i]);
		bNeedLayoutUpdate = False;
	}

}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, Title);
}

function OnPostRender(HUD H, Canvas C)
{	
	local float textXL, textYL, XL;
	local EtcInfoManager EtcInfo;

	
	XL = Components[0].XL;
	EtcInfo = GameManager(Level.Game).EtcInfoManager;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(PSI.PlayName,PageX + 50,PageY + 38,177,14);

	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(BattleInfo,PageX + 50,PageY + 66,177,14);

	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(Rank,Rank_Left_X,Rank_Left_Y,TextBoxWidth,17);
	C.DrawKoreanText(AccumulatedPoint,Rank_Left_X,Rank_Left_Y + 17,TextBoxWidth,17);



	
	// ���
	C.SetDrawColor(255,242,0);
	C.DrawKoreanText(PSI.Current_Show_Title,Rank_Right_X,Rank_Right_Y,117,15);

	//��������Ʈ - ��������Ʈ�� �Ķ���, �ִ�����Ʈ�� �������� �־�޶� �Ͻʴϴ�.

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(EtcInfo.Param1,Rank_Right_X + TextBoxWidth / 2,Rank_Right_Y + 17,textXL,15);
	
	/*
	C.SetDrawColor(35,240,245);
	C.TextSize(PSI.PkPts, textXL, textYL);
	C.DrawKoreanText(PSI.PkPts,(Rank_Right_X + TextBoxWidth / 2 - textXL - 8),Rank_Right_Y + 17,textXL,15);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText("/",(Rank_Right_X + TextBoxWidth / 2 - 8),Rank_Right_Y + 17,16,15);
	C.SetDrawColor(240,55,40);
	C.TextSize(PSI.PkPtsMax,textXL,textYL);
	C.DrawKoreanText(PSI.PkPtsMax,(Rank_Right_X + TextBoxWidth / 2 + 8),Rank_Right_Y + 17,textXL,15);
	C.SetDrawColor(255,255,255);
	*/

	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(WinCounts,WinCounts_Left_X,WinCounts_Left_Y,TextBoxWidth,15);
	C.DrawKoreanText(LoseCounts,WinCounts_Left_X,WinCounts_Left_Y + 17,TextBoxWidth,15);
	C.DrawKoreanText(DrawCounts,WinCounts_Left_X,WinCounts_Left_Y + 17 * 2,TextBoxWidth,15);
	C.DrawKoreanText(KillsCounts,WinCounts_Left_X,WinCounts_Left_Y + 17 * 3,TextBoxWidth,15);
	C.DrawKoreanText(DeadsCounts,WinCounts_Left_X,WinCounts_Left_Y + 17 * 4,TextBoxWidth,15);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(EtcInfo.Param2,WinCounts_Right_X,WinCounts_Right_Y,TextBoxWidth,15);
	C.DrawKoreanText(EtcInfo.Param3,WinCounts_Right_X,WinCounts_Right_Y + 17,TextBoxWidth,15);
	C.DrawKoreanText(EtcInfo.Param4,WinCounts_Right_X,WinCounts_Right_Y + 17 * 2,TextBoxWidth,15);
	C.DrawKoreanText(EtcInfo.Param5,WinCounts_Right_X,WinCounts_Right_Y + 17 * 3,TextBoxWidth,15);
	C.DrawKoreanText(EtcInfo.Param6,WinCounts_Right_X,WinCounts_Right_Y + 17 * 4,TextBoxWidth,15);

	
	C.SetDrawColor(184,200,255);
	C.DrawKoreanText(DungeonInfo,PageX + 50,PageY + 230,177,15);

	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(MistVillage_Day,Schedule_X,Schedule_Y,TextBoxWidth,15);
	C.DrawKoreanText(MistVillage_Night,Schedule_X,Schedule_Y + 17,TextBoxWidth,15);
	C.DrawKoreanText(WeeklyDungeonProgression,Schedule_X,Schedule_Y + 42,TextBoxWidth,15);
	C.DrawKoreanText(ParamText1, Schedule_X,Schedule_Y + 42 + 17 * 1,TextBoxWidth,15);
	C.DrawKoreanText(ParamText2, Schedule_X,Schedule_Y + 42 + 17 * 2,TextBoxWidth,15);
	C.DrawKoreanText(ParamText3, Schedule_X,Schedule_Y + 42 + 17 * 3,TextBoxWidth,15);
	C.DrawKoreanText(ParamText4, Schedule_X,Schedule_Y + 42 + 17 * 4,TextBoxWidth,15);

	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(EtcInfo.Param7, PageX + 134,PageY + 255,117,15);
	C.DrawKoreanText(EtcInfo.Param8, PageX + 134,PageY + 272,117,15);
	C.DrawKoreanText(EtcInfo.Param9, PageX + 134,PageY + 297,117,15);
	C.DrawKoreanText(EtcInfo.Param10, PageX + 134,PageY + 297 + 17 * 1,117,15);
	C.DrawKoreanText(EtcInfo.Param11, PageX + 134,PageY + 297 + 17 * 2,117,15);
	C.DrawKoreanText(EtcInfo.Param12, PageX + 134,PageY + 297 + 17 * 3,117,15);
	C.DrawKoreanText(EtcInfo.Param13, PageX + 134,PageY + 297 + 17 * 4,117,15);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if ( Key == IK_LeftMouse ) 
	{
		if( (Action == IST_Press) && IsCursorInsideComponent(Components[0]) ) 
		{
			bIsDragging = True;
			bMovingUI = True;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return True;
		}

		if ( Action == IST_Release && bIsDragging ) 
		{
			bIsDragging = False;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return True;
		}
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if ( NotifyId == BN_Exit )
		Parent.NotifyInterface(Self,INT_Close);	
}

function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}

defaultproperties
{
	Components(0)=(XL=270.000000,YL=413.000000)
	Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=245.000000,OffsetYL=14.000000,HotKey=IK_Escape)
	Components(2)=(Id=2,ResId=11,Type=RES_Image,XL=216.000000,YL=31.000000,PivotDir=PVT_Copy,OffsetXL=31.000000,OffsetYL=31.000000)
	Components(3)=(Id=3,ResId=12,Type=RES_Image,XL=254.000000,YL=144.000000,PivotDir=PVT_Copy,OffsetXL=8.000000,OffsetYL=80.000000)
	Components(4)=(Id=4,ResId=12,Type=RES_Image,XL=254.000000,YL=144.000000,PivotDir=PVT_Copy,OffsetXL=8.000000,OffsetYL=244.000000)
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
	TextureResources(11)=(Package="UI_2011",Path="combat_info_1",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011",Path="combat_info_2",Style=STY_Alpha)
	WinWidth=270.000000
	WinHeight=413.000000
	IsBottom=True
}
