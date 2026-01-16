class Inbox extends CMultiInterface
	config(SephirothUI);

const BN_Reply	= 1000;
const BN_Delete = 1001;
const BN_SetNote	= 1002;
const BN_NoteShop	= 1003;
const IDM_Delete = 1004;
const BN_OPEN = 1005;

const Note_Send = 21;
const Note_Read = 22;
const BN_Exit = 2000;

const NotesInPage = 10;

const LineHeight = 15;

var string m_sTitle;

var int SelectedNoteNum;
var int CurrentLineNum;		//modified by yj

var bool bNoDrawNoteList;		// jjh
var int LastNoteSize;

var globalconfig float PageX, PageY;		// jjh
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;
var CTextScroll NoteList;		//modified by yj   -- CTextScroll ������� ��� ���� ��.
var array<int> NoteTable;		//�Ϲ� ������ Index Table;		//modified by yj

function OnInit()
{	
	if(PageX == -1)
		ResetDefaultPosition();		//2009.10.27.Sinhyub
	bMovingUI = true;	//Layout()���� â���� ��� UI�� üũ���ټ��ֵ����մϴ�. 2009.10.29.Sinhyub

	SetButton();

	if (NoteList == None)
		NoteList = CTextScroll(AddInterface("Interface.CTextScroll"));
	
	if (NoteList != None) {
		if (!NoteList.bVisible)
			NoteList.ShowInterface();
		NoteList.TextList.Clear();
		NoteList.TextList.bReadOnly = false;
		NoteList.TextList.bWrapText = false;
		NoteList.TextList.ItemHeight = 13;
		NoteList.SetSize(350,300);
		NoteList.TextList.OnDrawText = OnDrawNoteList;
		NoteList.TextList.OnSelectText = OnSelectNoteList;
		NoteList.TextList.bAcceptDoubleClick = true;		//modified by yj
		NoteList.TextList.DoubleClick_=DoubleClick_;
	}

	MakeTables();
	MakeList();
	SelectedNoteNum = -1;
	CurrentLineNum = -1;
	
	m_sTitle = Localize("Inbox","NoteInbox","Sephiroth");
}


function MakeTables()		//InBoxNotes�� �ִ� ���� �� �˸��� �޽�����,  ���� �Ͱ� ���� ���� ������ �����Ͽ� �����Ѵ�.
{
	local int i;
	local int First_bRead_index_for_Note;
	local string sFrom;

	NoteTable.Remove(0,NoteTable.length);
	SephirothPlayer(PlayerOwner).nNoteUnread = 0;			// Ȯ�� �������� ���� ���� ������ ���⼭ �ѹ� üũ�� �� �ִ�. Xelloss

	for ( i = SephirothPlayer(PlayerOwner).InBoxNotes.Length - 1 ; i >= 0 ; i-- )	{		// �˸��� �޽����� �ƴ� �͸� �ɷ�����.

		sFrom = SephirothPlayer(PlayerOwner).InBoxNotes[i].From;

		if ( InStr(sFrom, "SYS@") == -1 )	{

			if ( SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead )	{

				NoteTable.Insert(NoteTable.Length,1);
				NoteTable[NoteTable.Length - 1] = i;
			}
			else	{

				NoteTable.Insert(First_bRead_index_for_Note, 1);
				NoteTable[First_bRead_index_for_Note] = i;
				First_bRead_index_for_Note++;

				SephirothPlayer(PlayerOwner).nNoteUnread++;
			}
		}
	}
}


function bool DoubleClick_()
{
	if(SelectedNoteNum != -1) {
		Parent.NotifyInterface(self,INT_Command,"OpenReceiveNote"@SelectedNoteNum);
		return true;
	}
	return false;
}

function MakeList()
{
	local int i;
	local int value;
	local string From;
	local string Body;

	NoteList.TextList.Clear();

	for(i=0;i<NoteTable.Length; i++) {
		value = NoteTable[i];
		From = SephirothPlayer(PlayerOwner).InBoxNotes[value].From;
		Body = SephirothPlayer(PlayerOwner).InBoxNotes[value].Body;
		NoteList.TextList.MakeList(From@":"@Body);		//�ӽ÷�
	}
}

function OnSelectNoteList(int Index, string Text)
{
	CurrentLineNum=index;
	SelectedNoteNum=NoteTable[CurrentLineNum];	

	//Log("CurrentLineNum is"@CurrentLineNum);
	//Log("SelectedNoteNum is"@SelectedNoteNum);
	
//	Parent.NotifyInterface(self,INT_Command,SelectedNoteNum);		//���� Ŭ�������ε� Ű�� �ʹٸ� ���⼭ ����.
}

function OnDrawNoteList(Canvas C, int Index, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;
	local int Value;
	
	ColorCode = MakeColorCodeEx(255,255,255);

	Value=NoteTable[index];
	
	if (Index == CurrentLineNum) {
		if (bSelected)
			ColorCode = MakeColorCodeEx(255,200,15);
		else
			ColorCode = MakeColorCodeEx(255,219,93);
	}
	else
	{
		if(SephirothPlayer(PlayerOwner).InBoxNotes[value].bRead)
		{
			ColorCode = MakeColorCodeEx(128,128,128);
		}		
	}

	C.DrawTextJustified(ColorCode $ Text, 0, X, Y, X+W, Y+H);
}


function OnFlush()
{	
	if (NoteList != None) {
		NoteList.HideInterface();
		RemoveInterface(NoteList);
		NoteList = None;
	}

	NoteTable.Remove(0, NoteTable.Length);
	SaveConfig();
}

function Layout(Canvas C)
{
	local int i;
	local int DX, DY;

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
	}

	MoveComponentId(0, true, PageX, PageY, WinWidth, WinHeight);
	
	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.LayOut(C);

	if (NoteList != None)	// ����Ʈ ��ġ
		NoteList.SetPos(Components[0].X+30, Components[0].Y+55);
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local int Value;
	switch(NotifyId) {
		case BN_OPEN:
			if(SelectedNoteNum != -1) 
				Parent.NotifyInterface(self,INT_Command,"OpenReceiveNote"@SelectedNoteNum);
			break;
		case BN_Reply:
			Value = Note_Send;
			Parent.NotifyInterface(self,INT_Command,"OpenSendNote"@SephirothPlayer(PlayerOwner).InBoxNotes[SelectedNoteNum].From);
			break;
		case BN_Delete:
			class'CMessageBox'.static.MessageBox(Self,"RemoveNote",Localize("Modals","DeleteNote","Sephiroth"),MB_YesNo,IDM_Delete);
			break;
		case BN_Exit:
			Parent.NotifyInterface(self,INT_Close);
			break;
	}
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Value;

	if ( NotifyType == INT_MessageBox )	{

		Value = int(Command);

		switch (Value) {

		case IDM_Delete :

			if ( SelectedNoteNum >= 0 && SelectedNoteNum < SephirothPlayer(PlayerOwner).InBoxNotes.Length )	{

				if(CurrentLineNum == NoteTable.Length-1)		//������ ������ �����, �ϳ� ���� ���� �����Ѵ�.
					CurrentLineNum--;

				SephirothPlayer(PlayerOwner).Net.NotiNoteInboxRemove(SephirothPlayer(PlayerOwner).InBoxNotes[SelectedNoteNum].NoteID);
				bNoDrawNoteList = true;			
				
				LastNoteSize = SephirothPlayer(PlayerOwner).InBoxNotes.Length;
			}			
			break;
		}
	}

}

function OnPreRender(Canvas C)
{	
	Components[2].bDisabled = SelectedNoteNum == -1 || bNoDrawNoteList || SephirothPlayer(PlayerOwner).InBoxNotes.Length == 0;
	Components[3].bDisabled = SelectedNoteNum == -1 || bNoDrawNoteList || SephirothPlayer(PlayerOwner).InBoxNotes.Length == 0;
	Components[4].bDisabled = SelectedNoteNum == -1 || bNoDrawNoteList || SephirothPlayer(PlayerOwner).InBoxNotes.Length == 0;

	if (bNoDrawNoteList && SephirothPlayer(PlayerOwner).InBoxNotes.Length < LastNoteSize) {		//�������� ������.	//NotiNoteInboxRemove���� ����ȭ ������ �ذ� - �� �Լ� ȣ���� �����Ͽ� 'InboxRemove�� �Ϸ�'�� ���� if������ ���´�. ��Ÿ�� ��쿡�� if������ ������ �ʴ´�.

		MakeTables();
		MakeList();
		OnSelectNoteList(CurrentLineNum,"");		//NotiNoteInboxRemove�� �Ϸ� �� ��  return �Ǵ°� �ƴϹǷ�, ����Ǿ��� ��(������ InboxNotes.Length�� LastNoteSize���� ���� ��) OnSelectNoteList�� ȣ���Ͽ� CurrentLine�� SelectedNoteNum�� �ϰ����� �����Ѵ�.
		bNoDrawNoteList = false;
	}

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}


function OnPostRender(HUD H, Canvas C)
{
/*	local float StartXPos,StartYPos;
	local int LineNum;

	StartXPos = Components[0].X + 20;	//32;	
	StartYPos = Components[0].Y + 50;	//70;
	LineNum = 0;
*/
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float StartX,StartY;	
	
	StartX = Components[0].X+20;
	StartY = Components[0].Y+50;

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]) && !IsCursorInsideAt(StartX, StartY, 280, 160)) {
		if (Action == IST_Press) {
			bIsDragging = true;
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
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))		//Need to be cleared
		return true;

}

function string GetSelectedReceiverName()
{
	return SephirothPlayer(PlayerOwner).InBoxNotes[SelectedNoteNum].From;
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

function SetButton()
{
	Components[2].NotifyId = BN_OPEN;
	Components[3].NotifyId = BN_Reply;
	Components[4].NotifyId = BN_Delete;
	Components[5].NotifyId = BN_Exit;
	SetComponentTextureId(Components[2],11,-1,13,12);
	SetComponentTextureId(Components[3],11,-1,13,12);
	SetComponentTextureId(Components[4],11,-1,13,12);
	SetComponentTextureId(Components[5],9,0,9,10);
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     Components(0)=(XL=405.000000,YL=424.000000)
     Components(1)=(Id=1,ResId=14,Type=RES_Image,XL=383.000000,YL=329.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=49.000000)
     Components(2)=(Id=2,Caption="Open",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=32.000000,OffsetYL=375.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Inbox",ToolTip="OpenNote")
     Components(3)=(Id=3,Caption="Reply",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotId=2,PivotDir=PVT_Right,OffsetXL=7.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Inbox",ToolTip="Reply")
     Components(4)=(Id=4,Caption="Delete",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotId=3,PivotDir=PVT_Right,OffsetXL=7.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Inbox",HotKey=IK_Delete,ToolTip="Delete")
     Components(5)=(Id=5,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=374.000000,OffsetYL=14.000000,HotKey=IK_Escape)
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
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="notice_info",Style=STY_Alpha)
     WinWidth=405.000000
     WinHeight=424.000000
     bDragAndDrop=True
     IsBottom=True
}
