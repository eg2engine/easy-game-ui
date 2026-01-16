class CPortal extends CMultiInterface
	config(SephirothUI);

const BN_Exit = 1;
const BN_Move = 2;
const BN_PartyMove = 3;
const BN_Add = 4;
const BN_Remove = 5;
const BN_Rename = 6;

const IDS_AddPortal = 100;
const IDS_RenamePortal = 101;
const IDM_RemovePortal = 102;

const _ListLine = 12;
const _TEXT_H = 16;

var string m_sTitle;

var CImeEdit m_pImeEdit;
var string m_sPotalName;

var int SelectedPortal;
var float VLine;
var globalconfig int Sorting;

function OnInit()
{
	SetButton();

	Sorting = Clamp(Sorting, 0, 3);
	if ( Sorting != SephirothPlayer(PlayerOwner).PortalCompare )
		SephirothPlayer(PlayerOwner).SortPortals(Sorting);

	m_pImeEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if ( m_pImeEdit != None )
	{
		m_pImeEdit.bNative = True;
		m_pImeEdit.SetMaxWidth(24);
		m_pImeEdit.SetSize(Components[2].XL, Components[2].YL);
		m_pImeEdit.SetFocusEditBox(False);
		m_pImeEdit.ShowInterface();
	}
	
	m_sTitle = Localize("PotalUI","Title","SephirothUI");
}

function OnFlush()
{
	if ( m_pImeEdit != None )
	{
		m_pImeEdit.SetFocusEditBox(False);
		m_pImeEdit.HideInterface();
		RemoveInterface(m_pImeEdit);
		m_pImeEdit = None;
	}
}

function ResetEditCtrl()
{
	m_sPotalName = "";
	m_pImeEdit.SetFocusEditBox(False);
	m_pImeEdit.SetText(m_sPotalName);
	m_pImeEdit.bNative = True;
	m_pImeEdit.SetMaxWidth(24);
	m_pImeEdit.ShowInterface();
}

function int GetMaxPortalNum(int Lv)
{
	if( Lv < 20 )
		return 5;
	else if(Lv < 40)
		return 20;
	else if(Lv < 60)
		return 40;
	else if(Lv < 80)
		return 60;
	else if(Lv < 100)
		return 80;
	else if(Lv >= 100 )
		return 100;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int PlayLevel, PortalNum;

	switch (NotifyId) 
	{
		case BN_Exit:
			Parent.NotifyInterface(Self,INT_Close);
			break;
		case BN_Move:
			MoveToPortal(True);
			break;
		case BN_PartyMove:
			PartyMove();
			break;
		case BN_Add:
			PlayLevel = SephirothPlayer(PlayerOwner).PSI.PlayLevel;
			PortalNum = SephirothPlayer(PlayerOwner).Portals.Length;
			if ( (PlayLevel < 20 && PortalNum < 5)
				|| (PlayLevel >= 20 && PlayLevel < 40 && PortalNum < 20)
				|| (PlayLevel >= 40 && PlayLevel < 60 && PortalNum < 40)
				|| (PlayLevel >= 60 && PlayLevel < 80 && PortalNum < 60)
				|| (PlayLevel >= 80 && PlayLevel < 100 && PortalNum < 80)
				|| (PlayLevel >= 100 && PortalNum < 100) )
			{
				AddPortal(m_sPotalName);
				ResetEditCtrl();
			}
			//class'CEditBox'.static.EditBox(Self,"AddPortal",Localize("Modals","TitleAddPortal","Sephiroth"),IDS_AddPortal,24);
			else
				class'CMessageBox'.Static.MessageBox(Self,"AddPortal",Localize("Modals","PortalAddLimit","Sephiroth"),MB_Ok);
			break;
		case BN_Rename:
			class'CEditBox'.Static.EditBox(Self,"RenamePortal",Localize("Modals","TitleRenamePortal","Sephiroth"),IDS_RenamePortal,24);
			break;
		case BN_Remove:
			class'CMessageBox'.Static.MessageBox(Self,"RemovePortal",Localize("Modals","TitleRemovePortal","Sephiroth"),MB_YesNo,IDM_RemovePortal);
			break;
	}
}

function OnPreRender(Canvas C)
{
	if ( m_pImeEdit != None )
		m_pImeEdit.SetPos(Components[2].X, Components[2].Y);

	m_sPotalName = m_pImeEdit.GetText();
	if( m_sPotalName == "" )
		EnableComponent(Components[3], False);
	else
		EnableComponent(Components[3], True);

	Components[6].bDisabled = SelectedPortal == -1;
	Components[7].bDisabled = !SephirothPlayer(PlayerOwner).PSI.bParty || !SephirothPlayer(PlayerOwner).PartyMgr.bLeader;
	Components[8].bDisabled = SephirothPlayer(PlayerOwner).Portals.Length >= 100;
	Components[9].bDisabled = SelectedPortal == -1;
	Components[10].bDisabled = SelectedPortal == -1;

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,Y2,XL,YL;
	local int i,k;
	local color OldColor;
	local int PlayLevel, PortalNum;

	X = Components[0].X;
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	// ��ǥ
	C.DrawKoreanText(Localize("PotalUI","Pos","SephirothUI"),X + 33,Y + 310,54,14);

	// ���
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleRight);
	C.DrawKoreanText(Localize("PotalUI","List","SephirothUI"),X + 28,Y + 80,136,14);

	// ��Ż ����
	PlayLevel = SephirothPlayer(PlayerOwner).PSI.PlayLevel;
	PortalNum = SephirothPlayer(PlayerOwner).Portals.Length;
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(238,187,1);
	C.DrawKoreanText(PortalNum$"/"$GetMaxPortalNum(PlayLevel), X + 176,Y + 80,54,14);

	C.SetDrawColor(255,255,255);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	X = Components[3].X;
	Y = Components[3].Y;
	Y2 = Components[0].Y + Components[3].OffsetYL;

	k = 0;
	OldColor = C.DrawColor;

	for ( i = SephirothPlayer(PlayerOwner).Portals.Length - 1;i >= 0;i-- )
	{
		//if (Y+k*_TEXT_H >= Y2 && Y+k*_TEXT_H < Y2+_ListLine*_TEXT_H)
		if( Y2 <= Y + k * _TEXT_H && Y + k * _TEXT_H < Y2 + _ListLine * _TEXT_H )
		{
			C.DrawColor = OldColor;
			if ( i == SelectedPortal ) 
			{
				C.SetPos(X,Y + k * _TEXT_H);
				C.SetDrawColor(188, 63, 63, 150);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',208,_TEXT_H,0,0,0,0);
				C.SetDrawColor(255, 242, 0);
			}
			C.DrawKoreanText(SephirothPlayer(PlayerOwner).Portals[i].DescTag,X + 2,Y + k * _TEXT_H,208,15);	//��ġ ���
		}
		k++;
	}

	// ��ǥ ��ġ
	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length )
	{
		C.DrawColor = OldColor;
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		X = Components[4].X;
		Y = Components[4].Y;
		XL = Components[4].XL;
		YL = Components[4].YL;
		C.DrawKoreanText(SephirothPlayer(PlayerOwner).Portals[SelectedPortal].PosTag,X,Y,XL,YL); 
	}
/*
	C.SetPos(Components[2].X,Components[2].Y);
	C.DrawRect1Fix(Components[2].XL,Components[2].YL);
*/
	if( !m_pImeEdit.HasFocus() )
	{
		if( m_sPotalName == "" )
		{
			C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
			C.SetDrawColor(126,126,126);
			C.DrawKoreanText(Localize("PotalUI","Plz","SephirothUI"),Components[2].X,Components[2].Y - 2,Components[2].XL,Components[2].YL);
		}
	}
}

function MoveToPortal(optional bool bClose)
{
	local int MaxIndex;

	if ( SephirothPlayer(PlayerOwner).PSI.PlayLevel <= 20 )
		MaxIndex = 5;
	else
		MaxIndex = 100;

	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiPortalMove(SephirothPlayer(PlayerOwner).Portals[SelectedPortal].Index);
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function PartyMove()
{
	local int MaxIndex;

	if ( SephirothPlayer(PlayerOwner).PSI.PlayLevel < 20 )
		MaxIndex = 5;
	else
		MaxIndex = 100;

	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiPartyMove(SephirothPlayer(PlayerOwner).Portals[SelectedPortal].Index);	
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function AddPortal(string PortalDesc)
{
	local int Index,MaxIndex,Slot;
	local byte Mask[100];
	local int PlayLevel;
	local bool bDuplicate;

	if( PortalDesc == "" )
		return ;

	PlayLevel = SephirothPlayer(PlayerOwner).PSI.PlayLevel;
	if ( PlayLevel < 20 ) MaxIndex = 5;
	else if (PlayLevel < 40) MaxIndex = 20;
	else if (PlayLevel < 60) MaxIndex = 40;
	else if (PlayLevel < 80) MaxIndex = 60;
	else if (PlayLevel < 100) MaxIndex = 80;
	else MaxIndex = 100;

	if ( SephirothPlayer(PlayerOwner).Portals.Length < MaxIndex ) 
	{
		for ( Slot = 0;Slot < SephirothPlayer(PlayerOwner).Portals.Length;Slot++ ) 
		{
			if ( PortalDesc == SephirothPlayer(PlayerOwner).Portals[Slot].DescTag ) 
			{
				bDuplicate = True;
				break;
			}
			Mask[SephirothPlayer(PlayerOwner).Portals[Slot].Index] = 1;
		}

		if ( !bDuplicate ) 
		{
			for ( Index = 0;Index < ArrayCount(Mask);Index++ )
				if ( Mask[Index] == 0 )
					break;
			if ( Index < ArrayCount(Mask) ) 
			{
				SephirothPlayer(PlayerOwner).Net.NotiPortalSave(Index,PortalDesc);
			}
		}
		else
			PlayerOwner.myHud.AddMessage(1,Localize("Warnings","CannotAddDuplicatedName","Sephiroth"),class'Canvas'.Static.MakeColor(200,100,200));
	}
	else
		PlayerOwner.myHud.AddMessage(1,Localize("Warnings","CannotAddPortalByLevel","Sephiroth"),class'Canvas'.Static.MakeColor(200,100,200));
	VLine = 0;
}

function RemovePortal()
{
	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length )
		SephirothPlayer(PlayerOwner).Net.NotiPortalRemove(SephirothPlayer(PlayerOwner).Portals[SelectedPortal].Index);
	SelectedPortal = -1;
}

function RenamePortal(string Desc)
{
	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length )
		SephirothPlayer(PlayerOwner).Net.NotiPortalMemo(SephirothPlayer(PlayerOwner).Portals[SelectedPortal].Index,Desc);
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{
	local int Value;
	if ( NotifyType == INT_MessageBox ) 
	{
		Value = int(Command);
		if ( Value == IDM_RemovePortal )
			RemovePortal();
	}
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	if ( NotifyId == IDS_AddPortal && EditText != "" )
		AddPortal(EditText);
	else if (NotifyId == IDS_RenamePortal && EditText != "")
		RenamePortal(EditText);
}

function NotifyScrollUp(int CmpId,int Amount)
{
	local float MaxVLine;
	local float VisibleHeight;
	
	VisibleHeight = _ListLine * _TEXT_H;
	VLine -= Amount * _TEXT_H;
	
	// 计算最大滚动值
	if ( SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H > VisibleHeight )
		MaxVLine = SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H - VisibleHeight;
	else
		MaxVLine = 0;
	
	// 限制在有效范围内
	if ( VLine < 0 )
		VLine = 0;
	else if ( VLine > MaxVLine )
		VLine = MaxVLine;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	local float MaxVLine;
	local float VisibleHeight;
	
	VisibleHeight = _ListLine * _TEXT_H;
	
	if ( SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H <= VisibleHeight )
		return;
	
	VLine += Amount * _TEXT_H;
	
	// 计算最大滚动值
	MaxVLine = SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H - VisibleHeight;
	
	// 限制在有效范围内
	if ( VLine > MaxVLine )
		VLine = MaxVLine;
	if ( VLine < 0 )
		VLine = 0;
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	P.X = SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H;
	P.Y = 208;
	P.Z = _TEXT_H;
	P.W = VLine;
	return P;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local int k,i;
	local float X,Y,Y2;
	local CTextMenu TextMenu;
	local string ContextString;

	if ( Key == IK_MouseWheelUp && IsCursorInsideComponent(Components[0]) && Action == IST_Press )
	{
		NotifyScrollUp(-1,1);
		return True;
	}
	else if (Key == IK_MouseWheelDown && IsCursorInsideComponent(Components[0]) && Action == IST_Press)
	{
		NotifyScrollDown(-1,1);
		return True;
	}	

	if ( Key == IK_LeftMouse && Action == IST_Press )
	{
		X = Components[3].X;
		Y = Components[3].Y;
		Y2 = Components[0].Y + Components[3].OffsetYL;
		k = 0;
		for ( i = SephirothPlayer(PlayerOwner).Portals.Length - 1;i >= 0;i-- )
		{
			if ( Y + k * _TEXT_H >= Y2 && Y + k * _TEXT_H < Y2 + _ListLine * _TEXT_H )
			{
				if ( IsCursorInsideAt(Components[3].X,Components[3].Y + k * _TEXT_H,208,15) )
				{
					SelectedPortal = i;
					ResetEditCtrl();
					return True;
				}
			}
			k++;
		}
		if ( k == SephirothPlayer(PlayerOwner).Portals.Length )
			SelectedPortal = -1;

		if ( IsCursorInsideComponent(Components[2]) && !m_pImeEdit.HasFocus() )
		{
			m_pImeEdit.SetFocusEditBox(True);
			return True;
		}
		else if (!IsCursorInsideComponent(Components[2]) && m_pImeEdit.HasFocus())
		{
			m_pImeEdit.SetFocusEditBox(False);
			return True;
		}
	}

	if ( Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]) )
		return True;

	if ( Key == IK_RightMouse && Action == IST_Release ) 
	{
		if ( IsCursorInsideAt(Components[3].X, Components[0].Y + Components[3].OffsetYL, Components[3].XL, _ListLine * _TEXT_H) ) 
		{
			ContextString = Localize("ContextMenu", "MostRecentIndex", "Sephiroth");
			ContextString = ContextString$"|"$Localize("ContextMenu", "MostLatestIndex", "Sephiroth");
			ContextString = ContextString$"|"$Localize("ContextMenu", "AlphaAscending", "Sephiroth");
			ContextString = ContextString$"|"$Localize("ContextMenu", "AlphaDescending", "Sephiroth");
			TextMenu = PopupContextMenu(ContextString, Controller.MouseX, Controller.MouseY);
			if ( TextMenu != None )
				TextMenu.OnTextMenu = InternalPortalSort;
			return True;
		}
	}
	return False;
}

function InternalPortalSort(int Index, string Text)
{
	SephirothPlayer(PlayerOwner).SortPortals(Index);
	Sorting = Index;
	SaveConfig();
}

function bool DoubleClick()
{
	if ( SelectedPortal >= 0 && SelectedPortal < SephirothPlayer(PlayerOwner).Portals.Length ) 
	{
		MoveToPortal(False);
		return True;
	}

	return False;
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,True,C.ClipX - Components[0].XL,0);
	for ( i = 1;i < Components.Length;i++ )
		MoveComponentId(i);
	MoveComponentId(3,True,Components[0].X + Components[3].OffsetXL,Components[0].Y + Components[3].OffsetYL - VLine);	//������ 77  
	Components[3].YL = SephirothPlayer(PlayerOwner).Portals.Length * _TEXT_H;
}

function SetButton()
{
	Components[5].NotifyId = BN_Exit;
	SetComponentTextureId(Components[5],10,0,10,11);
	Components[6].NotifyId = BN_Move;
	Components[7].NotifyId = BN_PartyMove;
	Components[8].NotifyId = BN_Add;
	Components[9].NotifyId = BN_Rename;
	Components[10].NotifyId = BN_Remove;
	SetComponentTextureId(Components[6],12, -1,14,13);
	SetComponentTextureId(Components[7],12, -1,14,13);
	SetComponentTextureId(Components[8],15, -1,17,_TEXT_H);
	SetComponentTextureId(Components[9],15, -1,17,_TEXT_H);
	SetComponentTextureId(Components[10],15, -1,17,_TEXT_H);
}

defaultproperties
{
	SelectedPortal=-1
	Components(0)=(XL=286.000000,YL=423.000000)
	Components(1)=(Id=1,ResId=9,Type=RES_Image,XL=252.000000,YL=331.000000,PivotDir=PVT_Copy,OffsetXL=14.000000,OffsetYL=39.000000)
	Components(2)=(Id=2,XL=147.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=27.000000,OffsetYL=42.000000)
	Components(3)=(Id=3,XL=208.000000,YL=191.000000,PivotDir=PVT_Copy,OffsetXL=25.000000,OffsetYL=106.000000)
	Components(4)=(Id=4,XL=125.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=108.000000,OffsetYL=309.000000)
	Components(5)=(Id=5,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=250.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
	Components(6)=(Id=6,Caption="MoveToPortal",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=24.000000,OffsetYL=375.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="PortalMove")
	Components(7)=(Id=7,Caption="MoveParty",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=142.000000,OffsetYL=375.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="PartyMove")
	Components(8)=(Id=8,Caption="AddPortal",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=171.000000,OffsetYL=37.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="PortalAdd")
	Components(9)=(Id=9,Caption="RenamePortal",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=51.000000,OffsetYL=337.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="PortalRename")
	Components(10)=(Id=10,Caption="RemovePortal",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=147.000000,OffsetYL=337.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="PortalRemove")
	Components(11)=(Id=11,Type=RES_ScrollBar,XL=23.000000,YL=203.000000,PivotDir=PVT_Copy,OffsetXL=241.000000,OffsetYL=100.000000)
	Components(12)=(Id=12,XL=208.000000,YL=1500.000000)
	TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011",Path="move_info",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
	TextureResources(16)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
	TextureResources(17)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
	bDragAndDrop=True
	bAcceptDoubleClick=True
	IsBottom=True
}
