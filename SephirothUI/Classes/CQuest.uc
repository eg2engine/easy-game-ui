class CQuest extends CMultiInterface
	config(SephirothUI);

var config float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

const BN_Exit = 1;
var bool bIsWaitingData;

const MAX_TEXTLIST_LINE = 27;
var float LiveLines, DoneLines;
var int SelectedLiveQuest,SelectedDoneQuest;
var int m_nStartLiveQuest;
var int m_nStartDoneQuest;

var CTextScroll CurrentStepArea;
var CTextScroll NextStepArea;

var int m_nShowQuestType;	// Live or Done

const QT_None = 0;
const QT_Limite = 1;
const QT_Epic = 2;
const QT_Done = 3;

const BTN_None = 11;
const BTN_Limite = 12;
const BTN_Epic = 13;
const BTN_Done = 14;

var string m_sTitle;

function OnInit()
{
	Components[2].NotifyId = BN_Exit;
	SetComponentTextureId(Components[2],9,-1,9,10);

	Components[11].NotifyId = BTN_None;
	SetComponentTextureId(Components[11],12,-1,14,13);
	Components[12].NotifyId = BTN_Limite;
	SetComponentTextureId(Components[12],12,-1,14,13);
	EnableComponent(Components[12], false);
	Components[13].NotifyId = BTN_Epic;
	SetComponentTextureId(Components[13],12,-1,14,13);
	EnableComponent(Components[13], false);
	Components[14].NotifyId = BTN_Done;
	SetComponentTextureId(Components[14],12,-1,14,13);

	m_sTitle = Localize("Information","QuestWindow","Sephiroth");
	
	if(PageX == -1)
		ResetDefaultPosition();		//2009.10.27.Sinhyub
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	CurrentStepArea = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (CurrentStepArea != None) {
		CurrentStepArea.ShowInterface();
		CurrentStepArea.TextList.bReadOnly = True;
		CurrentStepArea.TextList.bWrapText = True;
		CurrentStepArea.TextList.TextAlign = 0;
		CurrentStepArea.TextList.ItemHeight = 14;
		CurrentStepArea.SetSize(Components[5].XL, Components[5].YL);
	}
	NextStepArea = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (NextStepArea != None) {
		NextStepArea.ShowInterface();
		NextStepArea.TextList.bReadOnly = True;
		NextStepArea.TextList.bWrapText = True;
		NextStepArea.TextList.TextAlign = 0;
		NextStepArea.TextList.ItemHeight = 14;
		NextStepArea.SetSize(Components[6].XL, Components[6].YL);
	}

	m_nShowQuestType = QT_None;
	SetComponentTextureId(Components[11],14,-1,14,14);
	SetComponentTextureId(Components[14],12,-1,14,13);
}

function OnFlush()
{
	if (CurrentStepArea != None) {
		CurrentStepArea.HideInterface();
		RemoveInterface(CurrentStepArea);
		CurrentStepArea = None;
	}
	if (NextStepArea != None) {
		NextStepArea.HideInterface();
		RemoveInterface(NextStepArea);
		NextStepArea = None;
	}
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

	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	
	if(m_nShowQuestType == QT_None)
		Components[3].YL = SephirothPlayer(PlayerOwner).LiveQuests.Length * 14;
	else if(m_nShowQuestType == QT_Done)
		Components[3].YL = SephirothPlayer(PlayerOwner).DoneQuests.Length * 14;

	if (CurrentStepArea != None)
		CurrentStepArea.SetPos(Components[5].X, Components[5].Y);
	if (NextStepArea != None)
		NextStepArea.SetPos(Components[6].X, Components[6].Y);

	Super.Layout(C);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Exit)
		Parent.NotifyInterface(Self,INT_Close);
	else if (NotifyId == BTN_None)
	{
		m_nShowQuestType = QT_None;
		SetComponentTextureId(Components[11],14,-1,14,14);
		SetComponentTextureId(Components[14],12,-1,14,13);
	}
	else if (NotifyId == BTN_Limite)
		m_nShowQuestType = QT_Limite;
	else if (NotifyId == BTN_Epic)
		m_nShowQuestType = QT_Epic;
	else
	{
		m_nShowQuestType = QT_Done;
		SetComponentTextureId(Components[11],12,-1,14,13);
		SetComponentTextureId(Components[14],14,-1,14,14);
	}
}

function UpdateQuestList()
{
/*	local int i, n;

	if(m_bOnUpdateQuestList)
		return;

	n = 0;
	for(i=0; i<SephirothPlayer(PlayerOwner).LiveQuests.Length; i++)
	{
		if(SephirothPlayer(PlayerOwner).LiveQuests[i].Name == "")
			continue;
		
		if(m_nShowQuestType == QT_Limite)
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].nSymbol == 3)
				StrainList[n] = SephirothPlayer(PlayerOwner).LiveQuests[i];
		}
		else if(m_nShowQuestType == QT_Epic)
		{
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].nSymbol == 4)
				StrainList[n] = SephirothPlayer(PlayerOwner).LiveQuests[i];
		}
		else
		{
			StrainList[n] = SephirothPlayer(PlayerOwner).LiveQuests[i];			
		}

		n++;
	}

	m_bOnUpdateQuestList = false;*/
}

function ShowQuestHUD(int n)
{
	local int i, nMaxShowCnt, nShowCnt;
	local string sTemp;

	if(SephirothPlayer(PlayerOwner).LiveQuests[n].bShowMain == true)	// 이미 true 면 걍 false 종료
	{
		SephirothPlayer(PlayerOwner).LiveQuests[n].bShowMain = false;
		return;
	}

	nMaxShowCnt = 5;

	for(i=0; i<SephirothPlayer(PlayerOwner).LiveQuests.Length; i++)
	{
		if(SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain)
			nShowCnt++;
	}

	if(nShowCnt < nMaxShowCnt)
		SephirothPlayer(PlayerOwner).LiveQuests[n].bShowMain = true;
	else
	{
		sTemp = nMaxShowCnt $ " " $ Localize("Modals","QuestShowOver","Sephiroth");
		class'CMessageBox'.static.MessageBox(Self, "HelpMsg", sTemp, MB_Ok);
	}
}

function OnPreRender(Canvas C)
{
	local float X,Y;

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);

	C.SetDrawColor(255,255,255);

	X = Components[0].X;
	Y = Components[0].Y;

	C.SetPos(X + 11, Y + 56); // 텝 윗줄
	C.DrawTile(TextureResources[15].Resource,653,4,0,0,4,4);

	C.SetPos(X + 11, Y + 62 + 399); // 텝 아랫줄
	C.DrawTile(TextureResources[15].Resource,653,4,0,0,4,4);

	UpdateQuestList();
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,Y2;
	local color OldColor;
	local int i;
	local int CL;

	OldColor = C.DrawColor;

	C.SetDrawColor(255,255,255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	X = Components[3].X;
	Y = Components[3].Y;
	Y2 = Components[0].Y+67;

	if(m_nShowQuestType == QT_None)
	{
		for (i=m_nStartLiveQuest;i<SephirothPlayer(PlayerOwner).LiveQuests.Length;i++)
		{
			if(IsCursorInsideAt(X, Y+(CL*14), Components[3].XL, 13) )	// 마우스 오버 백판 그리기용
			{
				if(SephirothPlayer(PlayerOwner).LiveQuests[i].Name != "")
				{
					C.SetPos(X+15,Y+CL*14);
					C.SetDrawColor(188,63,63);
					C.DrawTile(Texture'Engine.WhiteSquareTexture',Components[3].XL,14,0,0,0,0);
				}
			}

			if (Y+CL*14 >= Y2 && Y+i*14 < Y2+26*14)
			{
				if (CL == SelectedLiveQuest)
					C.SetDrawColor(255,242,0);

				C.DrawKoreanText(SephirothPlayer(PlayerOwner).LiveQuests[i].Name,X+15,Y+CL*14,Components[3].XL,13);

				// 메인화면에 보여질 것인가 체크 표시
				C.SetDrawColor(255,255,255);
				C.SetPos(X,Y+CL*14);
				if(SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain)
					C.DrawTile(TextureResources[17].Resource,14,14,0,0,28,28);
				else
					C.DrawTile(TextureResources[16].Resource,14,14,0,0,28,28);
					
				CL++;
			}
		}
	}
	else if(m_nShowQuestType == QT_Done)
	{
		for (i=m_nStartDoneQuest;i<SephirothPlayer(PlayerOwner).DoneQuests.Length;i++)
		{
			if(IsCursorInsideAt(X, Y+(CL*14), Components[3].XL, 13) )	// 마우스 오버 백판 그리기용
			{
				if(SephirothPlayer(PlayerOwner).DoneQuests[i].Name != "")
				{
					C.SetPos(X,Y+CL*14);
					C.SetDrawColor(188,63,63);
					C.DrawTile(Texture'Engine.WhiteSquareTexture',Components[3].XL,14,0,0,0,0);
				}
			}

			if (Y+CL*14 >= Y2 && Y+CL*14 < Y2+26*14)
			{
				C.SetDrawColor(255,255,255);
				if (CL == SelectedDoneQuest)
					C.SetDrawColor(255,242,0);
				C.DrawKoreanText(SephirothPlayer(PlayerOwner).DoneQuests[i].Name,X,Y+CL*14,Components[3].XL,13);
				
				CL++;
			}
		}
	}

	C.DrawColor = OldColor;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int i;
	local int CL;

	if (Key == IK_MouseWheelUp && IsCursorInsideComponent(Components[3]) && Action == IST_Press)
	{
		NotifyScrollUp(3,1);
		SelectedLiveQuest = -1;
		SelectedDoneQuest = -1;
		return true;
	}
	else if (Key == IK_MouseWheelDown && IsCursorInsideComponent(Components[3]) && Action == IST_Press)
	{
		NotifyScrollDown(3,1);
		SelectedLiveQuest = -1;
		SelectedDoneQuest = -1;
		return true;
	}	

	if ( Key == IK_LeftMouse && Action == IST_Press )	{

		SelectedLiveQuest = -1;
		SelectedDoneQuest = -1;

		//  현재 진행중인 퀘스트 목록을 클릭하면..
		if ( IsCursorInsideAt(Components[3].X, Components[3].Y, Components[3].XL, Components[3].YL) )
		{
			if(m_nShowQuestType == QT_None)
			{
				for ( i = m_nStartLiveQuest ; i < SephirothPlayer(PlayerOwner).LiveQuests.Length ; i++ )
				{
					if ( IsCursorInsideAt(Components[3].X, Components[3].Y + CL * 14, Components[3].XL, 13) )
					{
						if(IsCursorInsideAt(Components[3].X, Components[3].Y + CL * 14, 13, 13))	// 체크 버튼 클릭
						{
							ShowQuestHUD(CL + m_nStartLiveQuest);
							return false;
						}

						SelectedLiveQuest = CL;

						CurrentStepArea.TextList.Clear();
						CurrentStepArea.TextList.MakeList(SephirothPlayer(PlayerOwner).LiveQuests[i].CurrentStep);

						NextStepArea.TextList.Clear();
						NextStepArea.TextList.MakeList(SephirothPlayer(PlayerOwner).LiveQuests[i].NextStep);
						return true;
					}
					
					CL++;
				}
			}
			else if(m_nShowQuestType == QT_Done)
			{
				for ( i = m_nStartDoneQuest ; i < SephirothPlayer(PlayerOwner).DoneQuests.Length ; i++ )
				{
					if ( IsCursorInsideAt(Components[3].X, Components[3].Y + CL * 14, Components[3].XL, 13) )
					{
						SelectedDoneQuest = CL;
						
						NextStepArea.TextList.Clear();
						CurrentStepArea.TextList.Clear();
						CurrentStepArea.TextList.MakeList(SephirothPlayer(PlayerOwner).DoneQuests[i].Description);
						return true;
					}
					
					CL++;
				}
			}
		}
	}

	if (Key == IK_LeftMouse ) {//2009.10.27.Sinhyub
		if ((Action == IST_Press) && IsInsideTitleBar())
		{
			bMovingUI = true;
			bIsDragging = true;			
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
		//	return true;
		}
		if (Action == IST_Release && bIsDragging) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
		//	return true;
		}
	}

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function NotifyScrollUp(int CmpId,int Amount)
{
	if(CmpId == 3)
	{
		// 표시 시작 줄 감소
		if(m_nShowQuestType == QT_None)
		{
			m_nStartLiveQuest--;
	
			if(m_nStartLiveQuest < 0)
				m_nStartLiveQuest = 0;		
		}
		else if(m_nShowQuestType == QT_Done)
		{
			m_nStartDoneQuest--;
			
			if(m_nStartDoneQuest < 0)
				m_nStartDoneQuest = 0;		
		}	
	}
}

function NotifyScrollDown(int CmpId,int Amount)
{
	if(CmpId == 3)
	{
		// 표시 시작 줄 증가
		if(m_nShowQuestType == QT_None)
		{
			m_nStartLiveQuest++;
			
			if(m_nStartLiveQuest + MAX_TEXTLIST_LINE > SephirothPlayer(PlayerOwner).LiveQuests.Length)
				m_nStartLiveQuest = SephirothPlayer(PlayerOwner).LiveQuests.Length - MAX_TEXTLIST_LINE;
			
			if(m_nStartLiveQuest < 0)
				m_nStartLiveQuest = 0;	
		}
		else if(m_nShowQuestType == QT_Done)
		{
			m_nStartDoneQuest++;
			
			if(m_nStartDoneQuest + MAX_TEXTLIST_LINE > SephirothPlayer(PlayerOwner).DoneQuests.Length)
				m_nStartDoneQuest = SephirothPlayer(PlayerOwner).DoneQuests.Length - MAX_TEXTLIST_LINE;
				
			if(m_nStartDoneQuest < 0)
				m_nStartDoneQuest = 0;	
		}	
	}
}


function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	if (CmpId == 3) {
		if(m_nShowQuestType == QT_None)
		{
			P.X = SephirothPlayer(PlayerOwner).LiveQuests.Length * 14;
			P.Y = 140;
			P.Z = 14;
			P.W = LiveLines;
		}
		else if(m_nShowQuestType == QT_Done)
		{
			P.X = SephirothPlayer(PlayerOwner).DoneQuests.Length * 14;
			P.Y = 140;
			P.Z = 14;
			P.W = DoneLines;
		}
	}
	return P;
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

	PageX = (ClipX-WinWidth)/2;
	PageY = (ClipY-WinHeight)/2;

	SaveConfig();
}



/*
\\SetQuest NQ_Quest61 0
\\SetQuest HQ_Quest62 0
\\SetQuest HQ_Quest63 0
\\SetQuest HQ_Quest64 0
\\SetQuest NQ_Quest66 0
\\SetQuest HQ_Quest67 0
\\SetQuest HQ_Quest68 0
\\SetQuest HQ_Quest69 0
\\SetQuest NQ_Quest71 0
\\SetQuest HQ_Quest72 0
\\SetQuest HQ_Quest73 0
\\SetQuest NQ_Quest74 0
\\SetQuest HQ_Quest76 0
\\SetQuest HQ_Quest77 0
\\SetQuest HQ_Quest78 0
\\SetQuest HQ_Quest79 0
\\SetQuest NQ_Quest82 0
\\SetQuest HQ_Quest83 0
\\SetQuest HQ_Quest84 0
\\SetQuest NQ_Quest86 0
\\SetQuest HQ_Quest87 0
\\SetQuest HQ_Quest88 0
\\SetQuest HQ_Quest89 0
\\SetQuest NQ_Quest92 0
\\SetQuest HQ_Quest93 0
\\SetQuest HQ_Quest94 0
\\SetQuest NQ_Quest96 0
\\SetQuest HQ_Quest97 0
\\SetQuest HQ_Quest98 0
\\SetQuest HQ_Quest99 0
*/

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     bIsWaitingData=True
     SelectedLiveQuest=-1
     SelectedDoneQuest=-1
     Components(0)=(XL=675.000000,YL=509.000000)
     Components(1)=(Id=1,ResId=11,Type=RES_Image,XL=358.000000,YL=399.000000,PivotDir=PVT_Copy,OffsetXL=302.000000,OffsetYL=62.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=645.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(3)=(Id=3,XL=256.000000,YL=364.000000,PivotDir=PVT_Copy,OffsetXL=23.000000,OffsetYL=70.000000)
     Components(4)=(Id=4)
     Components(5)=(Id=5,XL=319.000000,YL=125.000000,PivotDir=PVT_Copy,OffsetXL=318.000000,OffsetYL=197.000000)
     Components(6)=(Id=6,XL=319.000000,YL=80.000000,PivotDir=PVT_Copy,OffsetXL=318.000000,OffsetYL=97.000000)
     Components(11)=(Id=11,Caption="Doing",Type=RES_PushButton,XL=69.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=36.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(14)=(Id=14,Caption="Comp",Type=RES_PushButton,XL=69.000000,YL=24.000000,PivotId=11,PivotDir=PVT_Right,OffsetXL=3.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
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
     TextureResources(11)=(Package="UI_2011",Path="quest_info_bg",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="quest_tab_n",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="quest_tab_o",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="quest_tab_c",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011",Path="tab_line",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="check_box_n",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="check_box_c",Style=STY_Alpha)
     WinWidth=675.000000
     WinHeight=509.000000
     IsBottom=True
}
