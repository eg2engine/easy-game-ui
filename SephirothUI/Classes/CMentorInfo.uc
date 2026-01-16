class CMentorInfo extends CMultiInterface;

const BN_Exit		= 1;
const BN_LEAVE		= 2;
const BN_ACTIVATE2	= 3;		// 슬롯 활성화
const BN_ACTIVATE3	= 4;
const BN_ACTIVATE4	= 5;
const BN_ACTIVATE5	= 6;
const BN_SELECTMENTOR	= 7;
const BN_SELECTMENTEE1	= 8;
const BN_SELECTMENTEE2	= 9;
const BN_SELECTMENTEE3	= 10;
const BN_SELECTMENTEE4	= 11;
const BN_SELECTMENTEE5	= 12;
const BN_GIVE			= 13;

const IDM_LeaveMentor	= 101;
const IDM_ActivateSlot	= 102;
const IDM_ExpelMentee	= 103;
const IDM_GivePoint		= 104;

const SELECT_MENTOR		= 5;
const LIMIT_LEVEL		= 200;

var float PageX,PageY;

var string Title;

var PlayerServerInfo PSI;
var int	nSlotActivate;			// 활성화를 원하는 슬롯번호
var int nSelectIndex;			// 파문을 원하는 제자
var int nHoverIndex;

function OnInit()
{
	local int n;
	//local int nEmblemOfMentor;

	PSI = SephirothPlayer(PlayerOwner).PSI;

	bNeedLayoutUpdate = true;

    SetComponentTextureId(Components[1], 1);
	SetComponentNotify(Components[1], BN_LEAVE, Self);

    SetComponentTextureId(Components[12], 1);
	SetComponentNotify(Components[12], BN_GIVE, Self);

	for ( n = 0 ; n < 4 ; n++ )
	{
		VisibleComponent(Components[2 + n], false);
		SetComponentNotify(Components[2 + n], BN_ACTIVATE2 + n, Self);
	}

	SetComponentNotify(Components[6], BN_SELECTMENTOR, Self);

	for ( n = 0 ; n < 5 ; n++ )
	{
		SetComponentNotify(Components[7 + n], BN_SELECTMENTEE1 + n, Self);
		SetComponentTextureId(Components[7 + n], 0, -1, 10, 10);
	}

	nSelectIndex = -1;
	SetComponentTextureId(Components[19], 12);
}


function OnFlush()
{
	Saveconfig();
}


function MoveWindow(int OffsetX, int OffsetY)
{
	PageX = OffsetX;
	PageY = OffsetY;
}


function Layout(Canvas C)
{
	//local int DX,DY;
	local int i, j;
	local int nEmblemOfMentor;
	local int nLocIndex;

	MoveComponent(Components[0], true, PageX, PageY, WinWidth, WinHeight);

	SetComponentText(Components[52], string(PSI.nUsedReputationPoint));
	SetComponentText(Components[53], string(PSI.nCurrReputationPoint) );

	// 2011. 08. 09 현재 스승/제자 구분없이 모두 스승 정보가 있으면 보여준다.
	if ( SephirothPlayer(PlayerOwner).strMentorName != "" )
	{
		for ( i = 0 ; i < 6 ; i++ )
			VisibleComponent(Components[13 + i], true);

		nEmblemOfMentor = GetEmblem(SephirothPlayer(PlayerOwner).MentorJob);
		SetComponentTextureId(Components[13], nEmblemOfMentor);
		SetComponentText(Components[14], "Lv."$SephirothPlayer(PlayerOwner).nMentorLevel);		// 레벨
		SetComponentText(Components[15], SephirothPlayer(PlayerOwner).strMentorName);			// 이름
		SetComponentText(Components[18], string(GetTotalPoint()));								// 평판
	}
	else
	{
		for ( i = 0 ; i < 6 ; i++ )
			VisibleComponent(Components[13 + i], false);
	}

	// 제자 정보
	for ( i = 0 ; i < 5 ; i++ )
	{
		for ( j = 0 ; j < 6 ; j++ )
			VisibleComponent(Components[20 + i * 6 + j], false);

		if ( i < SephirothPlayer(PlayerOwner).aMentees.Length && SephirothPlayer(PlayerOwner).aMentees[i].IsEnabled )
		{
			if ( SephirothPlayer(PlayerOwner).aMentees[i].strMenteeName != "" )
			{
				for ( j = 0 ; j < 6 ; j++ )
					VisibleComponent(Components[20 + i * 6 + j], true);

				nEmblemOfMentor = GetEmblem(SephirothPlayer(PlayerOwner).aMentees[i].JobName);
				SetComponentTextureId(Components[20 + i * 6], nEmblemOfMentor);
				SetComponentText(Components[20 + i * 6 + 1], "Lv."$SephirothPlayer(PlayerOwner).aMentees[i].nLevel);			// 레벨
				SetComponentText(Components[20 + i * 6 + 2], SephirothPlayer(PlayerOwner).aMentees[i].strMenteeName);			// 이름
				SetComponentText(Components[20 + i * 6 + 4], string(SephirothPlayer(PlayerOwner).aMentees[i].nReputePoint));	// 평판
			}
		}
		else
		{
			if ( i < SephirothPlayer(PlayerOwner).aMentees.Length )			// 이 경우에는 초기화가 되지 않은 경우
				nLocIndex = SephirothPlayer(PlayerOwner).aMentees[i].nSlotIndex;
			else
				nLocIndex = i;

			if ( nLocIndex == 0 )
				SetComponentTextureId(Components[20 + i * 6], -1);
			else
			{
				VisibleComponent(Components[20 + i * 6], true);

				if ( nLocIndex < 3 )
					SetComponentTextureId(Components[20 + i * 6], 8);
				else
					SetComponentTextureId(Components[20 + i * 6], 9);
			}
		}
	}

	for ( i = 1 ; i < Components.Length; i++ )
		MoveComponent(Components[i]);
}


function OnPostRender(HUD H, Canvas C)
{
//	local int i;
//	local int Intv;

	if ( nSelectIndex >= 0 )
	{
		C.SetPos(Components[7 + nSelectIndex].X, Components[7 + nSelectIndex].Y);

		if ( nSelectIndex == nHoverIndex )
			C.SetDrawColor(0, 255, 255, 128);
		else
			C.SetDrawColor(255, 255, 0, 128);

		SetComponentTextureId(Components[7 + nSelectIndex], 11);
	}

	// 테스트용으로
/*	C.SetDrawColor(255,255,255);

	Intv = 120;

	for ( i = 0 ; i < SephirothPlayer(PlayerOwner).aMentees.Length ; i++ )
	{
		C.DrawKoreanText("Mentee("$i$") Index="$SephirothPlayer(PlayerOwner).aMentees[i].nSlotIndex, Components[0].X + Components[0].XL, Components[0].Y + Intv, 100, 10);
		C.DrawKoreanText("Name="$SephirothPlayer(PlayerOwner).aMentees[i].strMenteeName, Components[0].X + Components[0].XL + 10, Components[0].Y + Intv + 10, 100, 10);
		C.DrawKoreanText("Level="$SephirothPlayer(PlayerOwner).aMentees[i].nLevel, Components[0].X + Components[0].XL + 10, Components[0].Y + Intv + 20, 100, 10);
		C.DrawKoreanText("Job="$SephirothPlayer(PlayerOwner).aMentees[i].JobName, Components[0].X + Components[0].XL + 10, Components[0].Y + Intv + 30, 100, 10);
		C.DrawKoreanText("Enable="$SephirothPlayer(PlayerOwner).aMentees[i].IsEnabled, Components[0].X + Components[0].XL + 10, Components[0].Y + Intv + 40, 100, 10);
		Intv += 70;
	}*/
}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local int nTempSelect;
	local int i;

	for ( i = 0 ; i < 5 ; i++ )
		SetComponentTextureId(Components[7 + i], 0);

	switch ( NotifyId )
	{
	case BN_LEAVE :

		if ( PSI.PlayLevel < 200 )		// 제자 레벨인 경우
			class'CMessageBox'.static.MessageBox(self, "LeaveMentor", Localize("Modals", "LeaveMento", "Sephiroth"), MB_YesNo, IDM_LeaveMentor, ,MBPos_TopRight, true);
		else if ( nSelectIndex >= 0 )	// 제자중 한명을 선택하고 인연을 끊을 경우 ( 스승 레벨인 경우)
			class'CMessageBox'.static.MessageBox(self, "ExpelMentee", SephirothPlayer(PlayerOwner).aMentees[nSelectIndex].strMenteeName$Localize("Modals", "ExpelMentee", "Sephiroth"), MB_YesNo, IDM_ExpelMentee, , MBPos_TopRight, true);

		break;

	case BN_ACTIVATE2 :
	case BN_ACTIVATE3 :
	case BN_ACTIVATE4 :
	case BN_ACTIVATE5 :
		
		// 스승일 때에 한해서 슬롯사용을 요청할 수 있다.
		if ( PSI.PlayLevel >= LIMIT_LEVEL )
		{
			nSlotActivate = NotifyId - BN_ACTIVATE2 + 1;
			class'CMessageBox'.static.MessageBox(self, "ActivateSlot", Localize("Modals", "ActivateSlot", "Sephiroth"), MB_YesNo, IDM_ActivateSlot, ,MBPos_TopRight, true);
		}

		break;

	case BN_SELECTMENTOR :

		break;

	case BN_SELECTMENTEE1 :
	case BN_SELECTMENTEE2 :
	case BN_SELECTMENTEE3 :
	case BN_SELECTMENTEE4 :
	case BN_SELECTMENTEE5 :

		nSelectIndex = -1;
		nTempSelect = NotifyId - BN_SELECTMENTEE1;

		// 스승레벨일 경우에
		if ( PSI.PlayLevel >= LIMIT_LEVEL )
		{
			// 존재하는 제자일 경우에 선택이 가능하고
			if ( nTempSelect < SephirothPlayer(PlayerOwner).aMentees.Length && SephirothPlayer(PlayerOwner).aMentees[nTempSelect].strMenteeName != "" )
			{
				nSelectIndex = nTempSelect;
			}
			else if ( nTempSelect > 0 )
			{
				if ( nTempSelect >= SephirothPlayer(PlayerOwner).aMentees.Length )
				{
					nSlotActivate = nTempSelect;
					nSelectIndex = nTempSelect;

					if ( nSlotActivate < 3 )
						class'CMessageBox'.static.MessageBox(self, "ActivateSlot", Localize("Modals", "ActivateSlot", "Sephiroth"), MB_YesNo, IDM_ActivateSlot, ,MBPos_TopRight, true);
					else
						class'CMessageBox'.static.MessageBox(self, "ActivateSlot", Localize("Modals", "ActivateSlotCash", "Sephiroth"), MB_YesNo, IDM_ActivateSlot, ,MBPos_TopRight, true);
				}
				else if ( !SephirothPlayer(PlayerOwner).aMentees[nTempSelect].IsEnabled )
				{
					nSlotActivate = SephirothPlayer(PlayerOwner).aMentees[nTempSelect].nSLotIndex;
					nSelectIndex = nTempSelect;

					if ( nSlotActivate < 3 )
						class'CMessageBox'.static.MessageBox(self, "ActivateSlot", Localize("Modals", "ActivateSlot", "Sephiroth"), MB_YesNo, IDM_ActivateSlot, ,MBPos_TopRight, true);
					else
						class'CMessageBox'.static.MessageBox(self, "ActivateSlot", Localize("Modals", "ActivateSlotCash", "Sephiroth"), MB_YesNo, IDM_ActivateSlot, ,MBPos_TopRight, true);
				}
			}
		}

		break;

	case BN_GIVE :

		if ( PSI.PlayLevel < LIMIT_LEVEL )
			class'CEditBox'.static.EditBox(Self, "GiveReputationPoint", Localize("Modals", "GiveReputationPoint", "Sephiroth"), IDM_GivePoint, PSI.nCurrReputationPoint);

		break;
	}
}


function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	local int n;
	local int nPoint;

	if ( NotifyId == IDM_GivePoint )
	{
		nPoint = int(EditText);

		if ( nPoint > 0 )
		{
			for ( n = 0 ; n < SephirothPlayer(PlayerOwner).aMentees.Length ; n++ )
			{
				if ( SephirothPlayer(PlayerOwner).aMentees[n].strMenteeName == string(SephirothPlayer(PlayerOwner).PSI.PlayName) )
				{
					SephirothPlayer(PlayerOwner).Net.NotiGiveReputationPoint(SephirothPlayer(PlayerOwner).aMentees[n].nSlotIndex, nPoint);
					break;
				}
			}
		}
	}
}


function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	local int n;
	local int NotifyValue;

	if (NotifyId == INT_MessageBox)
	{
		NotifyValue = int(Command);

		switch (NotifyValue)
		{
		case IDM_LeaveMentor :

			for ( n = 0 ; n < 5 ; n++ )
			{
				if ( SephirothPlayer(PlayerOwner).aMentees[n].strMenteeName == string(SephirothPlayer(PlayerOwner).PSI.PlayName) )
				{
					SephirothPlayer(PlayerOwner).Net.NotiLeaveMentorSystem(SephirothPlayer(PlayerOwner).aMentees[n].nSlotIndex);
					break;
				}
			}

			break;

		case IDM_ActivateSlot :

			SephirothPlayer(PlayerOwner).Net.NotiEnableMenteeSlot(nSlotActivate);
			break;

		case IDM_ExpelMentee :

			SephirothPlayer(PlayerOwner).Net.NotiKickMentee(SephirothPlayer(PlayerOwner).aMentees[nSelectIndex].nSlotIndex, SephirothPlayer(PlayerOwner).aMentees[nSelectIndex].strMenteeName);
			break;
		}
	}
}


function bool PointCheck()
{
	return IsCursorInsideComponent(Components[0]);
}


event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	CheckMouseOver();
}


function CheckMouseOver()
{
	local int n;

	nHoverIndex = -1;

	for ( n = 0 ; n < 5 ; n++ )
	{
		if ( IsCursorInsideComponent(Components[7 + n]) )
		{
			nHoverIndex = n;
			return;
		}
	}
}


function int GetEmblem(name JobName)
{
	switch (JobName)
	{
	case 'OneHand' :	return 2;break;
	case 'Bare' :		return 3;break;
	case 'Red' :		return 4;break;
	case 'Bow' :		return 5;break;
	case 'Blue' :		return 6;break;
	}
}


function int GetTotalPoint()
{
	local int i;
	local int nSum;

	nSum = 0;

	for ( i = 0 ; i < SephirothPlayer(PlayerOwner).aMentees.Length ; i++ )
	{
		if ( SephirothPlayer(PlayerOwner).aMentees[i].IsEnabled )
		{
			nSum += SephirothPlayer(PlayerOwner).aMentees[i].nReputePoint;
		}
	}

	return nSum;
}


function ResetMentorSystem()
{
	local int n;

	SetComponentTextureId(Components[13], -1);
	SetComponentText(Components[14], "");
	SetComponentText(Components[15], "");
	SetComponentText(Components[18], "");
	SetComponentText(Components[19], "");

	for ( n = 0 ; n < 7 ; n++ )
		VisibleComponent(Components[13 + n], true);
}

defaultproperties
{
     Components(0)=(ResId=7,Type=RES_Image,XL=320.000000,YL=487.000000)
     Components(1)=(Id=1,Caption="LeaveMentor",Type=RES_TextButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=233.000000,OffsetYL=462.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(2)=(Id=2,Caption="ActivateSlot",Type=RES_TextButton,XL=102.000000,YL=15.000000,OffsetYL=20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(3)=(Id=3,Caption="ActivateSlot",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Caption="ActivateSlot",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(5)=(Id=5,Caption="ActivateSlot",Type=RES_TextButton,XL=102.000000,YL=15.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(6)=(Id=6,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=25.000000)
     Components(7)=(Id=7,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=114.000000)
     Components(8)=(Id=8,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=5.000000)
     Components(9)=(Id=9,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=5.000000)
     Components(10)=(Id=10,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=5.000000)
     Components(11)=(Id=11,Type=RES_PushButton,XL=316.000000,YL=64.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=5.000000)
     Components(12)=(Id=12,Caption="GivePoint",Type=RES_TextButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=233.000000,OffsetYL=489.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(13)=(Id=13,Type=RES_Image,XL=44.000000,YL=44.000000,PivotDir=PVT_Copy,OffsetXL=27.000000,OffsetYL=27.000000)
     Components(14)=(Id=14,Type=RES_Text,XL=44.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=27.000000,OffsetYL=71.000000,TextAlign=TA_TopCenter,TextColor=(B=102,G=204,R=255,A=255))
     Components(15)=(Id=15,Type=RES_Text,XL=149.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=149.000000,OffsetYL=31.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(16)=(Id=16,Caption="RecvTotalPoint",Type=RES_Text,XL=63.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=79.000000,OffsetYL=50.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(17)=(Id=17,Caption="CaptionCharName",Type=RES_Text,XL=63.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=79.000000,OffsetYL=31.000000,TextAlign=TA_MiddleRight,TextColor=(B=102,G=204,R=255,A=255),LocType=LCT_Commands)
     Components(18)=(Id=18,Type=RES_Text,XL=149.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=149.000000,OffsetYL=50.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(19)=(Id=19,Caption="MentorInfo",Type=RES_TextButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=6.000000,OffsetYL=-20.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(20)=(Id=20,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=2.000000)
     Components(21)=(Id=21,Type=RES_Text,XL=44.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255))
     Components(22)=(Id=22,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(23)=(Id=23,Caption="UsedRepPoint",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     Components(24)=(Id=24,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(25)=(Id=25,Caption="CaptionCharName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255),LocType=LCT_Commands)
     Components(26)=(Id=26,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=2.000000)
     Components(27)=(Id=27,Type=RES_Text,XL=44.000000,YL=16.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255))
     Components(28)=(Id=28,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(29)=(Id=29,Caption="UsedRepPoint",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     Components(30)=(Id=30,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(31)=(Id=31,Caption="CaptionCharName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=8,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255),LocType=LCT_Commands)
     Components(32)=(Id=32,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=2.000000)
     Components(33)=(Id=33,Type=RES_Text,XL=44.000000,YL=16.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255))
     Components(34)=(Id=34,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(35)=(Id=35,Caption="UsedRepPoint",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     Components(36)=(Id=36,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(37)=(Id=37,Caption="CaptionCharName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255),LocType=LCT_Commands)
     Components(38)=(Id=38,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=2.000000)
     Components(39)=(Id=39,Type=RES_Text,XL=44.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255))
     Components(40)=(Id=30,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(41)=(Id=41,Caption="UsedRepPoint",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     Components(42)=(Id=42,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(43)=(Id=43,Caption="CaptionCharName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=10,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255),LocType=LCT_Commands)
     Components(44)=(Id=44,Type=RES_Image,XL=44.000000,YL=44.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=2.000000)
     Components(45)=(Id=45,Type=RES_Text,XL=44.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=5.000000,OffsetYL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255))
     Components(46)=(Id=46,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(47)=(Id=47,Caption="UsedRepPoint",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Commands)
     Components(48)=(Id=48,Type=RES_Text,XL=149.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=138.000000,OffsetYL=25.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
     Components(49)=(Id=49,Caption="CaptionCharName",Type=RES_Text,XL=55.000000,YL=16.000000,PivotId=11,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=102,G=204,R=225,A=255),LocType=LCT_Commands)
     Components(50)=(Id=50,Caption="UsedRepPoint",Type=RES_Text,XL=51.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=16.000000,OffsetYL=462.000000,TextAlign=TA_MiddleRight,TextColor=(B=174,G=201,R=229,A=255),LocType=LCT_Commands)
     Components(51)=(Id=51,Caption="RemainRepPoint",Type=RES_Text,XL=51.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=16.000000,OffsetYL=489.000000,TextAlign=TA_MiddleRight,TextColor=(B=174,G=201,R=229,A=255),LocType=LCT_Commands)
     Components(52)=(Id=52,Type=RES_Text,XL=132.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=81.000000,OffsetYL=462.000000,TextAlign=TA_MiddleLeft,TextColor=(B=255,G=255,R=255,A=255))
     Components(53)=(Id=53,Type=RES_Text,XL=132.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=81.000000,OffsetYL=489.000000,TextAlign=TA_MiddleLeft,TextColor=(B=255,G=255,R=255,A=255))
     Components(54)=(Id=54,Caption="CaptionMentorInfo",Type=RES_Text,XL=51.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=14.000000,OffsetYL=7.000000,TextAlign=TA_MiddleLeft,TextColor=(B=174,G=201,R=229,A=255),LocType=LCT_Commands)
     Components(55)=(Id=55,Caption="CaptionFollowerInfo",Type=RES_Text,XL=51.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=14.000000,OffsetYL=97.000000,TextAlign=TA_MiddleLeft,TextColor=(B=174,G=201,R=229,A=255),LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_master_slot_2_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="emble_master_swd",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="emble_master_punch",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="emble_master_red",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="emble_master_bow",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="emble_master_blue",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="master_info_2",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="emble_master_lock",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="emble_master_gold_lock",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_master_slot_2_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_master_slot_2_c",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     WinWidth=320.000000
     WinHeight=487.000000
     IsBottom=True
}
