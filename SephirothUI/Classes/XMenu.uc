class XMenu extends CMultiInterface;

#exec TEXTURE IMPORT NAME=TextBlackBg FILE=Textures/Black90Alpha.tga

const BN_TrackPlayer	= 1;		// 따라가기
const BN_ShowExterior	= 2;		// 아이템 보기
const BN_PartyMenu		= 3;		// 파티 메뉴
const BN_ClanMenu		= 4;		// 클랜 메뉴
const BN_ExchangeMenu	= 5;		// 교환 메뉴
const BN_DialogMenu		= 6;		// 대화 메뉴
const BN_MentorMenu		= 7;		// 사제 메뉴

const BN_PartySubRequest	= 31;		// 파티 서브메뉴 - 파티 신청
const BN_PartySubInvite		= 32;		// 파티 서브메뉴 - 파티 초대
const BN_PartySubBanish		= 33;		// 파티 서브메뉴 - 파티 추방

const BN_ExchangeSubRequest	= 51;		// 교환 서브메뉴 - 교환 신청
const BN_ExchangeSubReject	= 52;		// 교환 서브메뉴 - 교환 차단 혹은 허용 

const BN_DialogSubReject	= 61;		// 대화 서브메뉴 - 대화 차단 혹은 허용
const BN_DialogSubWhisper	= 62;		// 대화 서브메뉴 - 귓속말

const BN_MentorSubInfo		= 71;		// 사제 서브메뉴 - 정보보기
const BN_MentorSubRequest	= 72;		// 사제 서브메뉴 - 요청하기 (스승 혹은 사제)

const BN_SubMenu = 100;

const LIMIT_LEVEL	= 200;

struct PRE_INFO
{
	var string		strName;
	var int			nLevel;
	var int			nSize;
	var int			nEmpties;
	var int			nRP;
};

var Hero PlayerPawn;
var PlayerServerInfo PlayerInfo;
var bool bShowItems;
var int TopMenu;

var bool bShowInfo;
var PRE_INFO	sPreInfo;

var bool bMentorValid;		// 멘토 버튼 활성화

var array<color> EdgeColors;
var color DisableColor;

function OnInit()
{
	// 메인 팝업창에 사용되는 버튼
	Components[1].NotifyId = BN_TrackPlayer;
	Components[2].NotifyId = BN_ShowExterior;
	Components[3].NotifyId = BN_PartyMenu;
//	Components[4].NotifyId = BN_ClanMenu;
	Components[5].NotifyId = BN_ExchangeMenu;
	// 교환 봉인
	//EnableComponent(Components[5], false);
	Components[6].NotifyId = BN_DialogMenu;
	Components[11].NotifyId = BN_MentorMenu;

	// 서브 팝업창에 사용되는 버튼	- Xelloss : 여기서 할 필요가 없고 메인 메뉴가 선택된 다음에 하는 게 낫지 않을까
/*	Components[7].NotifyId = BN_SubMenu;
	Components[8].NotifyId = BN_SubMenu+1;
	Components[9].NotifyId = BN_SubMenu+2;*/

	// 서브 팝업창에 텍스쳐 세팅
    SetComponentTextureId(Components[7], 0);
    SetComponentTextureId(Components[8], 0);
    SetComponentTextureId(Components[9], 0);

/* 플레이어정보 (PlayerServerInfo 시리얼라이즈에 레벨은 없음 그래서 아래는 작동하지 않음
	// 같은 상황의 플레이어끼리는 의미가 없음
	if ( (SephirothPlayer(PlayerOwner).PSI.PlayLevel >= LIMIT_LEVEL && PlayerInfo.PlayLevel < LIMIT_LEVEL) ||
		(SephirothPlayer(PlayerOwner).PSI.PlayLevel < LIMIT_LEVEL && PlayerInfo.PlayLevel >= LIMIT_LEVEL) )
	{
		bMentorValid = true;
	}
	else
	{
		bMentorValid = false;
		SetComponentTextProperty(Components[11], TA_MiddleCenter, DisableColor);
	}*/
}


function Layout(Canvas C)
{
	local int i;

	Components[7].bVisible = TopMenu != -1;
	Components[8].bVisible = TopMenu != -1;
	Components[9].bVisible = (TopMenu == BN_PartyMenu) || (TopMenu == BN_ClanMenu);		// 파티 관련 서브메뉴와 클랜 관련 서브메뉴는 여기까지

	// 각 메뉴의 옆으로 위치시킨다.
	switch(TopMenu)
	{
	case BN_PartyMenu :

		MoveComponent(Components[7], true, Components[0].X + Components[0].XL, Components[3].Y);
		break;

	case BN_ClanMenu :

		MoveComponent(Components[7], true, Components[0].X + Components[0].XL, Components[4].Y);
		break;

	case BN_ExchangeMenu :

		MoveComponent(Components[7], true, Components[0].X + Components[0].XL, Components[5].Y);
		break;

	case BN_DialogMenu :

		MoveComponent(Components[7], true, Components[0].X + Components[0].XL, Components[6].Y);
		break;

	case BN_MentorMenu :

		MoveComponent(Components[7], true, Components[0].X + Components[0].XL, Components[11].Y);
		break;
	}

	for ( i = 0 ; i < Components.Length ; i++ )
		MoveComponentId(i);

	// 아이템 보기에는 별도의 서브메뉴 (10)
	if ( bShowItems )
	{
		Components[7].bVisible = false;
		Components[8].bVisible = false;
		Components[9].bVisible = false;
//		Components[11].bVisible = false;

		MoveComponent(Components[10], true, Components[0].X + Components[0].XL, Components[2].Y);
	}

	if ( bShowInfo )
	{
		if ( sPreInfo.nLevel < LIMIT_LEVEL )		// 제자정보를 본다.
		{
			Components[13].bVisible = false;
			MoveComponent(Components[12], true, Components[7].X + Components[7].XL, Components[7].Y);
		}
		else
		{
			Components[12].bVisible = false;
			MoveComponent(Components[13], true, Components[7].X + Components[7].XL, Components[7].Y);
		}
	}
}


function OnPreRender(Canvas C)
{
	//local int i;
	//local SephirothItem ISI;
	//local bool bDrawItem;

	local float X,Y,XL,YL;
	local color OldColor;

	OldColor = C.DrawColor;
	C.SetRenderStyleAlpha();

	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;

	if (bShowItems)
	{
		SephirothInterface(Parent).ShowPlayerEquip(PlayerInfo);

		Parent.NotifyInterface(Self, INT_Close);

/*		SetComponentText(Components[2], "HideExterior");
		C.SetDrawColor(255,255,255);
		C.SetPos(Components[10].X ,Components[2].Y);
		C.DrawTile(TextureResources[2].Resource,Components[10].XL,Components[10].YL,0,0,Components[10].XL,Components[10].YL);

		X = Components[10].X + 14;
		Y = Components[10].Y + 12;
		C.SetDrawColor(241,215,113);
		for (i=0;i<PlayerInfo.WornItems.Items.Length;i++) {
			ISI = PlayerInfo.WornItems.Items[i];
			if (ISI != None) {
				bDrawItem = true;

				switch (ISI.EquipPlace) {
				case class'GConst'.default.IPHead:
//					Title = Localize("Terms","Helmet","Sephiroth");
					break;
				case class'GConst'.default.IPBody:
//					Title = Localize("Terms","Cloth","Sephiroth");
					break;
				case class'GConst'.default.IPCalves:
//					Title = Localize("Terms","Boots","Sephiroth");
					break;
				case class'GConst'.default.IPRArm:
//					Title = Localize("Terms","VambraceR","Sephiroth");
					break;
				case class'GConst'.default.IPLArm:
//					Title = Localize("Terms","VambraceL","Sephiroth");
					break;
				case class'GConst'.default.IPRHand:
//					Title = Localize("Terms","Weapon","Sephiroth");
					break;
				case class'GConst'.default.IPLHand:
//					Title = Localize("Terms","Shield","Sephiroth");
					break;
				default:
					bDrawItem = false;
					break;
				}
				if (bDrawItem) {
					C.DrawKoreanText(ISI.LocalizedDescription,X,Y,X+Components[10].XL, 15);
					Y+=24;
				}
			}
		}
*/

		C.DrawColor = OldColor;
	}
	else
		SetComponentText(Components[2],"ShowInfo");

	X = Components[2].X;
	Y = Components[2].Y;
	XL = Components[2].XL;
	C.SetPos(X + XL - 6, Y);
	C.DrawTile(TextureResources[3].Resource, 6, 10, 0, 0, 6, 10);
	

	X = Components[3].X;
	Y = Components[3].Y;
	XL = Components[3].XL;
	C.SetPos(X + XL - 6, Y);
	C.DrawTile(TextureResources[3].Resource, 6, 10, 0, 0, 6, 10);


	X = Components[5].X;
	Y = Components[5].Y;
	XL = Components[5].XL;
	C.SetPos(X + XL - 6, Y);
	C.DrawTile(TextureResources[3].Resource, 6, 10, 0, 0, 6, 10);

	X = Components[6].X;
	Y = Components[6].Y;
	XL = Components[6].XL;
	C.SetPos(X + XL - 6, Y);
	C.DrawTile(TextureResources[3].Resource, 6, 10, 0, 0, 6, 10);

	// 사제메뉴
	X = Components[11].X;
	Y = Components[11].Y;
	XL = Components[11].XL;
	C.SetPos(X + XL - 6, Y);
	C.DrawTile(TextureResources[3].Resource, 6, 10, 0, 0, 6, 10);

	if ( bShowInfo )
	{
		if ( sPreInfo.nLevel < LIMIT_LEVEL )
		{
			C.SetDrawColor(255, 255, 255);
			C.SetPos(Components[12].X ,Components[12].Y);
			C.DrawTile(Texture'TextBlackBg',Components[12].XL, Components[12].YL, 0, 0, 4, 4);
//			C.DrawTile(TextureResources[2].Resource, Components[12].XL, Components[12].YL, 0, 0, Components[12].XL, Components[12].YL);
			DrawRaisedRectangle(Components[12].X, Components[12].Y, Components[12].XL, Components[12].YL, EdgeColors.Length, EdgeColors);

			C.SetDrawColor(241, 215, 113);
			X = Components[12].X + 5;

			Y = Components[12].Y + 5;
			C.DrawKoreanText("Lv."$sPreInfo.nLevel, X, Y, X+Components[12].XL, 15);

			Y += 5;
			Y += 15;
			C.DrawKoreanText(Localize("Commands", "TotalRP", "Sephiroth")@sPreInfo.nRP, X, Y, X+Components[12].XL, 15);
		}
		else
		{
			C.SetDrawColor(255,255,255);
			C.SetPos(Components[13].X ,Components[13].Y);
//			C.DrawTile(TextureResources[2].Resource, Components[13].XL, Components[13].YL, 0, 0, Components[13].XL, Components[13].YL);
			C.DrawTile(Texture'TextBlackBg',Components[13].XL, Components[13].YL, 0, 0, 4, 4);
//			C.DrawTile(TextureResources[2].Resource, Components[13].XL, Components[13].YL, 0, 0, Components[13].XL, Components[13].YL);
			DrawRaisedRectangle(Components[13].X, Components[13].Y, Components[13].XL, Components[13].YL, EdgeColors.Length, EdgeColors);

			C.SetDrawColor(241, 215, 113);
			X = Components[13].X + 5;

			Y = Components[13].Y + 5;
			C.DrawKoreanText("Lv."$sPreInfo.nLevel, X, Y, X+Components[13].XL, 15);

			Y += 5;
			Y += 15;
			C.DrawKoreanText(Localize("Commands", "NumMentees", "Sephiroth")@sPreInfo.nSize, X, Y, X+Components[13].XL, 15);

			Y += 15;
			C.DrawKoreanText(Localize("Commands", "EmptySlots", "Sephiroth")@sPreInfo.nEmpties, X, Y, X+Components[13].XL, 15);

			Y += 15;
			C.DrawKoreanText(Localize("Commands", "TotalRP", "Sephiroth")@sPreInfo.nRP, X, Y, X+Components[13].XL, 15);
		}
	}
}


function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,XL,YL;
	//local float X2,Y2;
//	local string Title;
//	local color OldColor;

	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;

	C.SetRenderStyleAlpha();

//	OldColor = C.DrawColor;
	C.SetDrawColor(211,158,112);
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	if( PlayerInfo.MatchName == "" )
		C.DrawKoreanText(PlayerInfo.PlayName,X,Y+12,XL,14);
//	C.DrawColor = OldColor;
}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	bShowInfo = false;

	switch (NotifyId)
	{
	case BN_TrackPlayer :			// 따라가기
		
		SephirothPlayer(PlayerOwner).FollowPlayer(PlayerPawn);
		Parent.NotifyInterface(Self, INT_Command, "Trace " $ PlayerInfo.PlayName);
		break;

	case BN_ShowExterior :			// 아이템 보기
		//@cs added 鞫刻뚤렘陋구섟斤口
		bShowItems = !bShowItems;
		break;

	case BN_PartyMenu :

		Components[7].NotifyId = BN_PartySubRequest;
		Components[8].NotifyId = BN_PartySubInvite;
		Components[9].NotifyId = BN_PartySubBanish;

		SetComponentText(Components[7], "PartyJoin");
		SetComponentText(Components[8], "PartyInvite");
		SetComponentText(Components[9], "PartyBan");

		TopMenu = BN_PartyMenu;
		break;

	case BN_ClanMenu :

		SetComponentText(Components[7],"ClanJoin");
		SetComponentText(Components[8],"ClanInvite");
		SetComponentText(Components[9],"ClanBan");

		TopMenu = BN_ClanMenu;
		break;

	case BN_ExchangeMenu :

		Components[7].NotifyId = BN_ExchangeSubRequest;
		Components[8].NotifyId = BN_ExchangeSubReject;

		SetComponentText(Components[7],"ExchangeRequest");

		if (SephirothPlayer(PlayerOwner).IsExchangeBlocked(PlayerInfo.PlayName))
			SetComponentText(Components[8],"ExchangeRejectRelease");
		else
			SetComponentText(Components[8],"ExchangeReject");

		TopMenu = BN_ExchangeMenu;
		break;

	case BN_DialogMenu :

		Components[7].NotifyId = BN_DialogSubReject;
		Components[8].NotifyId = BN_DialogSubWhisper;

		if (SephirothPlayer(PlayerOwner).IsMessageBlocked(PlayerInfo.PlayName))
			SetComponentText(Components[7],"DialogRejectRelease");
		else
			SetComponentText(Components[7],"DialogReject");

		SetComponentText(Components[8],"SendWhisper");

		TopMenu = BN_DialogMenu;
		break;

	case BN_MentorMenu :

		// 같은 상황의 플레이어끼리는 의미가 없음
//		if ( !bMentorValid )
//			break;

		Components[7].NotifyId = BN_MentorSubInfo;
		Components[8].NotifyId = BN_MentorSubRequest;

		SetComponentText(Components[7], "MentorInfo");

		if ( SephirothPlayer(PlayerOwner).PSI.PlayLevel >= LIMIT_LEVEL )
			SetComponentText(Components[8], "FollowerRequest");		// 제자요청
		else
			SetComponentText(Components[8], "MentorRequest");		// 스승요청

		TopMenu = BN_MentorMenu;
		break;

	case BN_PartySubRequest :		// 파티 서브메뉴 - 파티 신청

		if (PlayerInfo.PkState)
			PlayerOwner.myHud.AddMessage(1, Localize("Warnings", "PKBlockedMessage", "Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
		else
			SephirothPlayer(PlayerOwner).Net.NotiPartyJoin(PlayerInfo.PanID);

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_PartySubInvite :		// 파티 서브메뉴 - 파티 초대

		SephirothPlayer(PlayerOwner).Net.NotiPartyInvite(PlayerInfo.PanID);
		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_PartySubBanish :		// 파티 서브메뉴 - 파티 추방

		SephirothPlayer(PlayerOwner).Net.NotiPartyBan(string(PlayerInfo.PlayName));
		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_ExchangeSubRequest :	// 교환 서브메뉴 - 교환 신청

		if (PlayerInfo.PkState)
			PlayerOwner.myHud.AddMessage(1, Localize("Warnings", "PKBlockedMessage", "Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
		else
		{
			if (SephirothPlayer(PlayerOwner).IsExchangeBlocked(PlayerInfo.PlayName))
				PlayerOwner.myHud.AddMessage(2,PlayerInfo.PlayName$Localize("Warnings","DisallowedExchange","Sephiroth"),class'Canvas'.static.MakeColor(255,255,255));
			else
				SephirothPlayer(PlayerOwner).Net.NotiXcngRequest(PlayerInfo.PanID);
		}

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_ExchangeSubReject :		// 교환 서브메뉴 - 교환신청 거부/해제

		if (SephirothPlayer(PlayerOwner).IsExchangeBlocked(PlayerInfo.PlayName))
			SephirothPlayer(PlayerOwner).UnblockExchange(PlayerInfo.PlayName);
		else
			SephirothPlayer(PlayerOwner).BlockExchange(PlayerInfo.PlayName);

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_DialogSubReject :		// 대화 서브메뉴 - 대화 차단/해제

		if (SephirothPlayer(PlayerOwner).IsMessageBlocked(PlayerInfo.PlayName))
			SephirothPlayer(PlayerOwner).UnblockMessage(PlayerInfo.PlayName);
		else
			SephirothPlayer(PlayerOwner).BlockMessage(PlayerInfo.PlayName);

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_DialogSubWhisper :		// 대화 서브메뉴 - 귓속말

		if (SephirothPlayer(PlayerOwner).IsMessageBlocked(PlayerInfo.PlayName))
			PlayerOwner.myHud.AddMessage(2,PlayerInfo.PlayName$Localize("Warnings","DisallowedWhisper","Sephiroth"),class'Canvas'.static.MakeColor(255,255,255));
		else
			Parent.NotifyInterface(Self,INT_Command,"SendWhisper " $ string(PlayerInfo.PlayName));

		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_MentorSubInfo :			// 사제 서브메뉴 - 정보 보기

//		Parent.NotifyInterface(Self, INT_Close);
		SephirothPlayer(PlayerOwner).Net.NotiRequestMentorInfo(PlayerInfo.PanID);
		break;

	case BN_MentorSubRequest:		// 사제 서브메뉴 - 요청하기 (스승요청/제자요청)

		Parent.NotifyInterface(Self, INT_Close);

		if ( SephirothPlayer(PlayerOwner).PSI.PlayLevel < LIMIT_LEVEL )
			SephirothPlayer(PlayerOwner).Net.NotiRequestMentor(PlayerInfo.PanID);
		else
			SephirothPlayer(PlayerOwner).Net.NotiRequestMentee(PlayerInfo.PanID);

		break;
	}
}


function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape && Action == IST_Press)
	{
		Parent.NotifyInterface(Self, INT_Close);
		return true;
	}

	if ( Key == IK_LeftMouse && Action == IST_Press && !IsCursorInsideComponent(Components[0]) )
	{
		Parent.NotifyInterface(Self, INT_Close);
		return false;
	}
}


function SetPosition(float X, float Y)
{
	MoveComponentId(0, true, X, Y);
}


function SetPreInfo(string strName, int MaxLevel, int nCurrMenteeNum, int nEmptySlots, int nCurrReputationPoint)
{
	bShowInfo = true;

	sPreInfo.strName	= strName;
	sPreInfo.nLevel		= MaxLevel;
	sPreInfo.nSize		= nCurrMenteeNum;
	sPreInfo.nEmpties	= nEmptySlots;
	sPreInfo.nRP		= nCurrReputationPoint;
}


function bool PointCheck()
{
	local int i;

	if(IsCursorInsideComponent(Components[0]))
		return true;

	for( i = 7 ; i < Components.Length ; i++)
	{
		if (IsCursorInsideComponent(Components[i]))	// 버튼 클릭하면 이동 안되게
			return true;
	}
}


function DrawRaisedRectangle(float X, float Y, float W, float H, int LineWidth, array<color> Colors)
{
	local int i;
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i+W, Y+i, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i+H, X+i+W, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i+W, Y+i, X+i+W, Y+i+H, Colors[i]);
}

defaultproperties
{
     TopMenu=-1
     EdgeColors(0)=(B=113,G=113,R=114,A=255)
     EdgeColors(1)=(B=48,G=50,R=55,A=255)
     EdgeColors(2)=(B=16,G=19,R=20,A=255)
     DisableColor=(G=255,R=255,A=128)
     Components(0)=(ResId=1,Type=RES_Image,XL=118.000000,YL=206.000000)
     Components(1)=(Id=1,Caption="TrackPlayer",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotDir=PVT_Copy,OffsetXL=8.000000,OffsetYL=45.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Caption="ShowInfo",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=10.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(3)=(Id=3,Caption="Party",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=10.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(5)=(Id=5,Caption="Exchange",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=10.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(6)=(Id=6,Caption="Dialog",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=10.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(7)=(Id=7,Type=RES_TextButton,XL=100.000000,YL=15.000000,LocType=LCT_Commands)
     Components(8)=(Id=8,Type=RES_TextButton,XL=100.000000,YL=15.000000,PivotId=7,PivotDir=PVT_Down,OffsetXL=10.000000,LocType=LCT_Commands)
     Components(9)=(Id=9,Type=RES_TextButton,XL=100.000000,YL=15.000000,PivotId=8,PivotDir=PVT_Down,OffsetXL=10.000000,LocType=LCT_Commands)
     Components(10)=(Id=10,XL=184.000000,YL=206.000000)
     Components(11)=(Id=11,Caption="Mentor",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=10.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(12)=(Id=12,XL=184.000000,YL=40.000000)
     Components(13)=(Id=13,XL=184.000000,YL=80.000000)
     TextureResources(0)=(Package="UI_2011",Path="pulldown_bg",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_menu_sub",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_action",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="icon_arr_xs",Style=STY_Alpha)
}
