class Inbox_Helper extends Inbox	//modified by yj
	config(SephirothUI);

//***********************
//	쪽지함(InBoxNotes)을 차용하여서 알리미를 구현하였습니다.
//	일반 쪽지와 알리미 메시지와의 구분은 From에 Sys가 포함되느냐의 유무로 결정합니다.
//***********************

var array<int> HelperNoteTable;		//알리미 쪽지용 Index Table;
var Helper Helper;

function OnInit()
{
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
}


function MakeTables()		//InBoxNotes에 있는 쪽지 및 알리미 메시지를,  읽은 것과 읽지 않은 것으로 구분하여 정렬한다.
{
	local int i;
	local int First_bRead_index_for_HelperNote;
	local string From;

	HelperNoteTable.Remove(0,HelperNoteTable.length);
	SephirothPlayer(PlayerOwner).nHelperUnread = 0;			// 확인 차 읽지 않은 메일을 여기서 체크할 수 있다.

	for ( i = SephirothPlayer(PlayerOwner).InBoxNotes.Length-1 ; i >= 0 ; i-- )	{

		From = SephirothPlayer(PlayerOwner).InBoxNotes[i].From;

		if ( InStr(From, "SYS@") != -1 )	{		//알리미 쪽지라면
			
			if ( SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead )	{

				HelperNoteTable.Insert(HelperNoteTable.Length,1);
				HelperNoteTable[HelperNoteTable.Length-1]=i;
			}
			else	{

				HelperNoteTable.Insert(First_bRead_index_for_HelperNote,1);
				HelperNoteTable[First_bRead_index_for_HelperNote]=i;
				First_bRead_index_for_HelperNote++;

				SephirothPlayer(PlayerOwner).nHelperUnread++;
			}
		}
	}
}


function bool DoubleClick_()
{
	if(SelectedNoteNum != -1) {
		ShowHelper(SelectedNoteNum);
		return true;
	}
	return false;
}

function ShowHelper(int Num)
{
	local string From, Title;
	local string ShowPage;

	From = SephirothPlayer(PlayerOwner).InBoxNotes[Num].From;
	Title = SephirothPlayer(PlayerOwner).InBoxNotes[Num].Body;

	if(InStr(From, "SYS@") != -1) //add neive : 알리미
	{
		if(Len(From) < 7)
			ShowPage = Right(From, 2);
		else
			ShowPage = Right(From, 4); // 퀘스트 알림 (SYS@1000 의 타입으로 온다)
		
		if (Helper == None)	{			
			Helper = Helper(AddInterface("SephirothUI.Helper"));
			Helper.ShowIndex = ShowPage;
			Helper.Title = Left(Title, 16);
			Helper.ShowInterface();
		}		
		else {
			Helper.ShowIndex = ShowPage;
			Helper.Title = Left(Title, 16);
			Helper.LoadHelperNote();
		}

		if ( !SephirothPlayer(PlayerOwner).InBoxNotes[Num].bRead )
			SephirothPlayer(PlayerOwner).Net.NotiNoteInboxRead(SephirothPlayer(PlayerOwner).InBoxNotes[Num].NoteID);		// 읽은 것으로 처리
	}
}

function HideHelper()
{
	if (Helper != None) {
		Helper.HideInterface();
		RemoveInterface(Helper);
		Helper = None;
	}
}

function MakeList()
{
	local int i;
	local int value;
	local string From;
	local string Body;

	NoteList.TextList.Clear();

	for(i=0;i<HelperNoteTable.Length; i++) {
		value = HelperNoteTable[i];
		From = SephirothPlayer(PlayerOwner).InBoxNotes[value].From;
		Body = SephirothPlayer(PlayerOwner).InBoxNotes[value].Body;
		if ( InStr(From, "SYS@") != -1 )
			NoteList.TextList.MakeList(Body);
		else
			NoteList.TextList.MakeList(From@":"@Body);
	}
}

function OnSelectNoteList(int Index, string Text)
{
	SelectedNoteNum=HelperNoteTable[index];	
	CurrentLineNum=index;

	//만약 클릭만으로도 키고 싶다면 여기서 설정. 
//	Parent.NotifyInterface(self,INT_Command,SelectedNoteNum);	
}

function OpenLatestHelper()
{
	ShowHelper(HelperNoteTable[0]);
}


function OnDrawNoteList(Canvas C, int Index, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;
	local int value;
	
	value=HelperNoteTable[index];

	if (Index == CurrentLineNum) {
		if (bSelected)
			ColorCode = MakeColorCodeEx(254,254,254);	// 안읽었고 마우스 오버
		else
			ColorCode = MakeColorCodeEx(255,219,93);	// 안읽었음
	}
	else
	{
		if(SephirothPlayer(PlayerOwner).InBoxNotes[value].bRead)	// 이미 읽음
		{
			ColorCode = MakeColorCodeEx(128,128,128);
		}		
	}

	C.DrawTextJustified(ColorCode $ Text, 0, X, Y, X+W, Y+H);
}


function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch(NotifyId) {
		case BN_OPEN:
			if(SelectedNoteNum != -1)
				ShowHelper(SelectedNoteNum);			
			break;
		case BN_Delete:
			class'CMessageBox'.static.MessageBox(Self,"RemoveHelper",Localize("Modals","DeleteHelper","Sephiroth"),MB_YesNo,IDM_Delete);
			break;
		case BN_Exit:
			Parent.NotifyInterface(self,INT_Close);
			break;		
	}
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Value;
	
	switch (NotifyType) {

	case INT_MessageBox :

		if ( int(Command) == IDM_Delete )	{

			if ( SelectedNoteNum >= 0 && SelectedNoteNum < SephirothPlayer(PlayerOwner).InBoxNotes.Length )	{
				
				if ( CurrentLineNum == NoteTable.Length )		//마지막 알리미를 지우면, 하나 위의 것을 선택한다.
					CurrentLineNum--;
				
				SephirothPlayer(PlayerOwner).Net.NotiNoteInboxRemove(SephirothPlayer(PlayerOwner).InBoxNotes[SelectedNoteNum].NoteID);
				
				bNoDrawNoteList = true;
				LastNoteSize = SephirothPlayer(PlayerOwner).InBoxNotes.Length;				
			}		
		}	
		break;

	case INT_Command :
		
		if(Command == "Previous") {
			value=CurrentLineNum;
			value--;
			if(value < 0)
				value =0;
			else {
				OnSelectNoteList(value,"");
				ShowHelper(SelectedNoteNum);
			} 				
		}
		
		else if(Command =="Next") {
			value=CurrentLineNum;
			value++;
			if(value > NoteList.TextList.ItemCount-1)
				value = NoteList.TextList.ItemCount-1;
			else {
				OnSelectNoteList(value,"");
				ShowHelper(SelectedNoteNum);
			} 
		}
		break;

	case INT_Close :

		if(Interface == Helper)
			HideHelper();
		break;
	}
}

function OnFlush()
{	
	if (NoteList != None) {
		NoteList.HideInterface();
		RemoveInterface(NoteList);
		NoteList = None;
	}
	HelperNoteTable.Remove(0, NoteTable.Length);	
	SaveConfig();
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;
	local color OldColor;

	X = Components[0].X;
	Y = Components[0].Y;
	OldColor = C.DrawColor;
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(229,231,174);
	C.DrawKoreanText(Localize("HelperUI","Helper","SephirothUI"),X,Y+10, Components[0].XL, 20);
	C.DrawColor = OldColor;
}

function SetButton()
{
	Components[3].bVisible = false;

	Components[2].NotifyId = BN_OPEN;
	Components[4].NotifyId = BN_Delete;
	Components[5].NotifyId = BN_Exit;
	
	SetComponentTextureId(Components[2],11,-1,13,12);
	SetComponentTextureId(Components[3],11,-1,13,12);
	SetComponentTextureId(Components[4],11,-1,13,12);
	SetComponentTextureId(Components[5],9,-1,9,10);
}

defaultproperties
{
     Components(2)=(Caption="Open_Helper",OffsetXL=76.000000,OffsetYL=379.000000,ToolTip="OpenHelper")
     Components(4)=(Id=2,Caption="Delete_Helper",PivotId=0,PivotDir=PVT_Copy,OffsetXL=214.000000,OffsetYL=379.000000,ToolTip="Delete_Helper")
}
