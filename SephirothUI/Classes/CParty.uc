class CParty extends CMultiInterface
	config(SephirothUI);

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

const MAX_PARTY_NUM = 15;

const BN_Dismiss = 1;
const BN_Leave = 2;
const BN_LeaveEnd = 15;

const Cmp_Gauge = 16;
const Cmp_GaugeEnd = 30;

const IDM_PartyDismiss = 1;
const IDM_PartyBan = 2;
const IDM_PartyLeave = 3;

const PartyGab = 40;

var PartyManager PM;
var array<PartyManager.PartyPlayer > Sorted;
var string ExpelPlayer;

function OnInit()
{
	local int i;
	if( PageX == -1 )		//Sinhyub
		ResetDefaultPosition();
	bMovingUI = True;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	for( i = BN_Dismiss; i < BN_Leave + (MAX_PARTY_NUM - 1);i++ )
	{
		SetComponentNotify(Components[i],i,Self);
		SetComponentTextureId(Components[i],3, -1,5,4);
	}

	PM = SephirothPlayer(PlayerOwner).PartyMgr;
}

//add neive : 파티창에 클레스 표시
function int GetJobIconIndex(int n)
{
	switch(n)
	{
		case 2: return 8;
		case 4: return 10;
		case 32: return 7;
		case 64: return 6;
		case 512: return 9;
	}

	return 10;
}

function int GetJobIconIndexS(string sName)
{
	switch(sName)
	{
		case "Red": return 8;
		case "Blue": return 10;
		case "Bare": return 7;
		case "OneHand": return 6;
		case "Bow": return 9;
	}

	return 10;
}

// 字符串替换函数
function string ReplaceTextEx(string S, string A, string B)
{
	local int i;
	local string Result;
 
    // 查找字符串A在S中的位置
	i = InStr(S, A);
	if ( i != -1 )
	{
        // 将字符串S从开始到A的位置添加到结果中
		Result = Left(S, i);
        // 将字符串B添加到结果中
		Result$= B;
        // 将字符串S从A的位置到结束添加到结果中，并进行递归替换
		Result$= ReplaceTextEx(Mid(S, i + Len(A)), A, B);
	}
	else
	{
        // 如果A不在S中，直接返回S
		Result = S;
	}
 
	return Result;
}
 

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local string PartyBanString;
	local string PartyContent;
	if ( PM.bLeader ) 
	{
		if ( NotifyId == BN_Dismiss )
		{
			class'CMessageBox'.Static.MessageBox(Self,"PartyDismiss",Localize("Modals","PartyDismiss","Sephiroth"),MB_YesNo,IDM_PartyDismiss);
		}
		else if (NotifyId >= BN_Leave && NotifyId < BN_Leave + Sorted.Length) 
		{
			ExpelPlayer = Sorted[NotifyId - 1].PlayName;
			PartyBanString = Localize("Modals","PartyBan","Sephiroth");
			PartyContent = ReplaceTextEx(PartyBanString, "$Name$", ExpelPlayer);
			class'CMessageBox'.Static.MessageBox(Self,"PartyBan",PartyContent,MB_YesNo,IDM_PartyBan);
		}
	}
	else if (NotifyId >= BN_Leave && NotifyId < BN_LeaveEnd)
		class'CMessageBox'.Static.MessageBox(Self,"PartyLeave",Localize("Modals","PartyLeave","Sephiroth"),MB_YesNo,IDM_PartyLeave);
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int NotifyValue;
	if ( NotifyType == INT_MessageBox ) 
	{
		NotifyValue = int(Command);
		if ( NotifyValue == IDM_PartyDismiss )
			SephirothPlayer(PlayerOwner).Net.NotiPartyDismiss();
		else if (NotifyValue == IDM_PartyLeave)
			SephirothPlayer(PlayerOwner).Net.NotiPartyLeave();
		else if (NotifyValue == IDM_PartyBan)
			SephirothPlayer(PlayerOwner).Net.NotiPartyBan(ExpelPlayer);
		else if (NotifyValue == -1 * IDM_PartyBan)
			ExpelPlayer = "";
	}
}


function OnPreRender(Canvas C)
{
	local int i;

	Components[0].YL = Sorted.Length * 15;

	if ( !SephirothPlayer(PlayerOwner).PSI.bParty ) 
	{
		Parent.NotifyInterface(Self,INT_Close);
		return;
	}
	Sorted.Remove(0,Sorted.Length);
	PM.SortMembers(Sorted);
	Components[1].bDisabled = Sorted.Length <= i || !PM.bLeader;

	for ( i = 1; i < MAX_PARTY_NUM; i++ )
	{
		if( i + BN_Dismiss >= 0 && i + BN_Dismiss < Components.Length )
		{
			if( PM.bLeader )
				Components[i + BN_Dismiss].bDisabled = Sorted.Length <= i;
			else if(i >= 0 && i < Sorted.Length && PM.Members[0] == Sorted[i])
				Components[i + BN_Dismiss].bDisabled = False;
			else 
				Components[i + BN_Dismiss].bDisabled = True;

			Components[i + BN_Dismiss].bVisible = Sorted.Length > i;
		}
	}

	if( PM.bLeader == True )
	{
		for( i = 0;i < MAX_PARTY_NUM;i++ )
		{
			if( i + BN_Dismiss >= 0 && i + BN_Dismiss < Components.Length )
			{
				if( i >= 0 && i < Sorted.Length && Sorted[i].PlayName != "" )
					Components[i + BN_Dismiss].bVisible = True;
				else
					Components[i + BN_Dismiss].bVisible = False;
			}
		}
	}
	else
	{
		for( i = 0; i < MAX_PARTY_NUM; i++ )
		{
			if( i + BN_Dismiss >= 0 && i + BN_Dismiss < Components.Length )
			{
				Components[i + BN_Dismiss].bVisible = False;
			}
		}
			
		Components[2].bVisible = True;
	}

	// 빽판
	for ( i = 0;i < Sorted.Length;i++ )
	{
		C.SetPos(Components[0].X, Components[0].Y + (i * PartyGab));
		C.DrawTile(TextureResources[0].Resource,226,36,0,0,226,36);
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X, Y;
	local int i, nRes;

	X = Components[0].X;
	Y = Components[0].Y;

	C.SetRenderStyleAlpha();

	for ( i = 0;i < Sorted.Length;i++ )
	{
		C.SetDrawColor(222,222,222);
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
		C.DrawKoreanText(Sorted[i].PlayName,X,Y + (i * PartyGab) + 6,210,13);

		C.SetDrawColor(255,204,102);
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
		C.DrawKoreanText("Lv "$Sorted[i].PlayLevel,X + 56,Y + (i * PartyGab) + 5,180,13); 

		//add neive : 파티창에 클레스 표시 ----------------------------------------
		nRes = GetJobIconIndex(Sorted[i].job);
		if( Sorted[i].PlayName == string(SephirothPlayer(PlayerOwner).PSI.PlayName) )
			nRes = GetJobIconIndexS(string(SephirothPlayer(PlayerOwner).PSI.JobName));
		C.SetPos(X + 11, Y + (i * PartyGab) + 5);		//클래스에 따른 그림
		C.DrawTile(TextureResources[nRes].Resource,42,26,0,0,42,26);
		//---------------------------------------------------------------------
	}


	// 파티장 표시
	if( PM.bLeader == False )
	{
		for ( i = 0;i < Sorted.Length;i++ )
		{
			if( i == 0 )
			{
				C.SetPos(X + 5,Y + (i * PartyGab) - 12);
				C.DrawTile(TextureResources[2].Resource,15,13,0,0,15,13);
			}
		}
	}
	else
	{
		C.SetPos(X + 5,Y - 12);		//왕관
		C.DrawTile(TextureResources[2].Resource,15,13,0,0,15,13);
	}

	C.SetDrawColor(byte(255), 204, 102);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.DrawKoreanText(Localize("PartyUI","Title","SephirothUI")@string(Sorted.Length)@"/"@string(15), X + 25, Y - 12, Components[0].XL - 30, 13);
}


function OnFlush()
{
	SaveConfig();
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
		bNeedLayoutUpdate = True;
	}

	if( bNeedLayoutUpdate ) 
	{
		MoveComponent(Components[0],True,PageX,PageY,WinWidth,WinHeight);
		for ( i = 1;i < Components.Length;i++ )
			MoveComponent(Components[i]);
		bNeedLayoutUpdate = False;
	}
	Super.Layout(C);
}

function bool PointCheck()
{
	local int i;

	// 检查主UI区域
	if( IsCursorInsideComponent(Components[0]) )
		return True;
	
	// 检查所有按钮和其他组件
	for( i = 1; i < Components.Length; i++ )
		if( Components[i].bVisible && IsCursorInsideComponent(Components[i]) )	// 버튼 클릭하면 이동 안되게
			return True;
	
	return False;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	// 使用 PointCheck() 检查鼠标是否在UI上
	if ( Key == IK_LeftMouse && PointCheck() )
	{	
		//Sinhyub.
		if ( Action == IST_Press && IsCursorInsideComponent(Components[0]) )
		{
			bMovingUI = True;
			bIsDragging = True;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
		}
		if ( Action == IST_Release && bIsDragging )
		{
			SaveConfig();
			bIsDragging = False;
			DragOffsetX = 0;
			DragOffsetY = 0;
		}
		return True;  // 鼠标在UI上，阻止事件传递给游戏逻辑
	}
	
	return False;
}


function vector PushComponentVector(int CmpId)
{
	local vector V;
	if ( CmpId >= Cmp_Gauge && CmpId <= Cmp_GaugeEnd && CmpId - Cmp_Gauge < Sorted.Length ) 
	{
		V.X = 0;
		if ( Sorted[CmpId - Cmp_Gauge].PlayName == string(SephirothPlayer(PlayerOwner).PSI.PlayName) ) 
		{
			V.Y = SephirothPlayer(PlayerOwner).PSI.Health;
			V.Z = SephirothPlayer(PlayerOwner).PSI.MaxHealth;
		}
		else
		{
			if( Sorted[CmpId - Cmp_Gauge].MaxHealth == -1 )
			{
				V.Y = 0;
				V.Z = 1;
			}
			else
			{
				V.Y = Sorted[CmpId - Cmp_Gauge].Health;
				V.Z = Sorted[CmpId - Cmp_Gauge].MaxHealth;
			}
		}
	}
	return V;
}

function ResetDefaultPosition()		//2009.Sinhyub
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
	pos = InStr(Resolution, "x");

	ClipX = int(Left(Resolution, pos));		
	ClipY = int(Mid(Resolution,pos + 1));

	PageX = ClipX - WinWidth;
	PageY = 180;	//미니맵 아래에 위치하도록

	bNeedLayoutUpdate = True;
	SaveConfig();
}

defaultproperties
{
	PageX=-1.000000
	PageY=-1.000000
	Components(0)=(XL=226.000000,YL=36.000000)
	Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=203.000000,OffsetYL=6.000000,ToolTip="PartyDismiss")
	Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(4)=(Id=4,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(5)=(Id=5,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(6)=(Id=6,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(7)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(8)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(9)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(10)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=9,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(11)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=10,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(12)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=11,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(13)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=12,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(14)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=13,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(15)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=14,PivotDir=PVT_Down,OffsetYL=27.000000,ToolTip="PartyMemberButton")
	Components(16)=(Id=16,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotDir=PVT_Copy,OffsetXL=56.000000,OffsetYL=20.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(17)=(Id=17,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=16,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(18)=(Id=18,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=17,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(19)=(Id=19,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=18,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(20)=(Id=20,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=19,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(21)=(Id=21,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=20,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(22)=(Id=22,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=21,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(23)=(Id=23,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=22,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(24)=(Id=24,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=23,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(25)=(Id=25,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=24,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(26)=(Id=26,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=25,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(27)=(Id=27,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=26,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(28)=(Id=28,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=27,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(29)=(Id=29,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=28,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	Components(30)=(Id=30,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotId=29,PivotDir=PVT_Down,OffsetYL=32.000000,bTextureSegment=True,GaugeDir=GDT_Right)
	TextureResources(0)=(Package="UI_2011",Path="party_bg",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011_btn",Path="gauge_red",UL=155.000000,VL=8.000000,Style=STY_Normal)
	TextureResources(2)=(Package="UI_2011_btn",Path="icon_king",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011",Path="icon_job_swd",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011",Path="icon_job_punch",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011",Path="icon_job_red",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011",Path="icon_job_bow",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011",Path="icon_job_blue",Style=STY_Alpha)
	WinWidth=150.000000
	WinHeight=50.000000
}
