class messenger extends CMultiInterface
	config(SephirothUI);

const BN_Inbox = 1;
const BN_NewNote = 2;
const BN_Exit = 3;
const BN_SendNote = 4;
const BN_AddFriend=5;

const IDS_GroupAdd = 10;
const IDS_GroupRename = 11;
const IDS_BuddyAdd = 12;

const IDM_RequestAddBuddy = 1;
const IDM_GroupDelete = 2;

const LineSize = 15;

const GS_CLOSE = 0;
const GS_OPEN = 1;

var array<int> GroupState;

var string m_sTitle;

var int SelectedLineNum;

var float VLine;

var int SelectedBuddyNum;
var int SelectedGroupNum;
var bool bDrawPopMenu;
var bool bDrawGroupPopMenu;
var float RClickMouseX, RClickMouseY;

var float GroupPopX,GroupPopY;
var int GroupPopWidth, GroupPopHeight;
var int SelectedMoveGroupNum;

var Inbox		Inbox;
var ReceiveNote ReceiveNote;
var SendNote	SendNote;
var SendNote_Direct	SendNote_Direct;

var int NewNoteCounts;

struct BuddyList
{
	var int GroupID;
	var int BuddyID;	
};

var array<BuddyList> ListOnMessenger;
var array<string> GroupPopTexts;
var array<string> BuddyPopTexts;

// jjh --- for moving window
var globalconfig float PageX, PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;
// --- jjh

/*for test------------------------------*/
/*
struct Buddy
{
	var bool bOnline;
	var string BuddyName;
};
struct BuddyGroup
{
	var string GroupName;
	var array<Buddy> Buddys;
};
var int OnlineCount;
struct TestBuddyManager
{
	var array<BuddyGroup> BuddyGroups;
};

var TestBuddyManager BuddyMgr;

function InitBuddyMgr()
{
	local BuddyGroup BG;
	local Buddy B;

	BG.GroupName = "";	
	BuddyMgr.BuddyGroups[0] = BG;
	BG.GroupName = "family";
	BuddyMgr.BuddyGroups[1] = BG;
	B.BuddyName = "father";
	B.bOnline = true;
	BuddyMgr.BuddyGroups[1].Buddys[0] = B;
	B.BuddyName = "mother";
	B.bOnline = false;
	BuddyMgr.BuddyGroups[1].Buddys[1] = B;
	B.BuddyName = "sister";
	B.bOnline = true;
	BuddyMgr.BuddyGroups[1].Buddys[2] = B;
	B.BuddyName = "brother";
	B.bOnline = false;
	BuddyMgr.BuddyGroups[1].Buddys[3] = B;
	BG.GroupName = "friends";
	BuddyMgr.BuddyGroups[2] = BG;	
}

function TestBuddyGroupAdd(string GroupName)
{
	local BuddyGroup BG;

	BG.GroupName = GroupName;
	BuddyMgr.BuddyGroups[BuddyMgr.BuddyGroups.Length] = BG;
}

function TestBuddyGroupRename(string OldName, string NewName)
{
	local BuddyGroup BG;

	BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName = NewName;	
}

function TestBuddyAdd(string GroupName, string BuddyName)
{
	local BuddyGroup BG;
	local Buddy B;

	B.BuddyName = BuddyName;
	if(OnlineCount == 5)
	{
		B.bOnline = false;
		OnlineCount = 0;
	}
	else
	{
		B.bOnline = true;
	}
		

	BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys[BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys.Length] = B;		
}

function TestBuddyRemove(int GroupID, int BuddyID)
{
	BuddyMgr.BuddyGroups[GroupID].Buddys.Remove(BuddyID, 1);
}

function TestBuddyGroupRemove(int GroupID)
{
	BuddyMgr.BuddyGroups.Remove(GroupID, 1);
	GroupState.Remove(GroupID, 1);
}

function TestBuddyArrange()
{
	local Buddy B;
	
	B = BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys[SelectedBuddyNum];
	BuddyMgr.BuddyGroups[SelectedMoveGroupNum].Buddys[BuddyMgr.BuddyGroups[SelectedMoveGroupNum].Buddys.Length] = B;
	BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys.Remove(SelectedBuddyNum,1);
}
*/
/*--------------------------------------*/

function ClearGroupState()
{
	local int i;
	for(i = 0 ; i < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
		GroupState[i] = GS_CLOSE;
}

function OnInit()
{
	if(PageX == -1)
		ResetDefaultPosition();
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	SetButton();

	SelectedLineNum = -1;

	GroupPopTexts[0] = Localize("Messenger", "GroupAdd", "Sephiroth");/*"Group Add";*/
	GroupPopTexts[1] = Localize("Messenger", "GroupDelete", "Sephiroth");/*"Group Delete";*/
	GroupPopTexts[2] = Localize("Messenger", "GroupRename", "Sephiroth");/*"Group Rename";*/
	GroupPopTexts[3] = Localize("Messenger", "BuddyAdd", "Sephiroth");/*"Buddy Add";*/
	GroupPopTexts[4] = Localize("Messenger", "SendToGroup", "Sephiroth");/*"Send Note To Group";*/
	
	BuddyPopTexts[0] = Localize("Messenger", "SendNote", "Sephiroth");/*"Send Note";*/
	BuddyPopTexts[1] = Localize("Messenger", "BuddyDelete", "Sephiroth");/*"Buddy Delete";*/
	BuddyPopTexts[2] = Localize("Messenger", "GroupArrange", "Sephiroth");/*"Group Arrange";*/

	m_sTitle = Localize("Messenger","BuddyList","Sephiroth");

	ClearGroupState();
	SelectedGroupNum = -1;
	SelectedBuddyNum = -1;	
	//test
	/*
	InitBuddyMgr();
	OnlineCount = 1;*/
}

function OnFlush()
{
	SaveConfig();

	if(Inbox != None)
	{
		Inbox.HideInterface();
		RemoveInterface(Inbox);
		Inbox = None;
	}
	if(ReceiveNote != None)
	{
		ReceiveNote.HideInterface();
		RemoveInterface(ReceiveNote);
		ReceiveNote = None;
	}
	if(SendNote != None)
	{
		SendNote.HideInterface();
		RemoveInterface(SendNote);
		SendNote = None;
	}
}

function HideInbox()
{
	Inbox.HideInterface();
	RemoveInterface(Inbox);
	Inbox = None;
}

function ShowInbox()
{
	Inbox = Inbox(AddInterface("SephirothUI.Inbox"));
	if(Inbox != None)
		Inbox.ShowInterface();
}


function NotifyComponent(int CmpId, int NotifyId,optional string Command)
{
	local int i;

	switch(NotifyId)
	{
	case BN_Inbox:		
		if(Inbox != None) {
			HideInbox();
			Components[4].Caption = Localize("Messenger","OpenInbox","Sephiroth");
		}
		else {
			ShowInbox();
			Components[4].Caption = Localize("Messenger","CloseInbox","Sephiroth");
		}
		break;

	case BN_NewNote:
		// jjh --- to prevent abnormal note open
		/*
		Num = SephirothPlayer(PlayerOwner).InBoxNotes.Length-1;
		if(!SephirothPlayer(PlayerOwner).InBoxNotes[Num].bRead)
			OpenReceiveNoteInterface(Num);
		*/
		for (i=0;i<SephirothPlayer(PlayerOwner).InBoxNotes.Length;i++)
			if (!SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead)
				break;
		if (i < SephirothPlayer(PlayerOwner).InBoxNotes.Length)
			OpenReceiveNoteInterface(i);
		else
			PlayerOwner.myHud.AddMessage(1, Localize("Modals", "EmptyNewNote", "Sephiroth"), class'Canvas'.static.MakeColor(255,255,0));
		// --- jjh
		break;

	case BN_SendNote:	
		if(SendNote_Direct != None)
			CloseSendNote_DirectInterface();
		else
			OpenSendNote_DirectInterface();		
		break;
	case BN_AddFriend:
		if(SelectedGroupNum != -1)
			class'CEditbox'.static.EditBox(self,"BuddyAdd",Localize("Messenger","BuddyAddMessage","Sephiroth"),IDS_BuddyAdd,20,"");
		break;

	case BN_Exit:
		Parent.NotifyInterface(self,INT_Close);
		break;
	}
}

function int GetLatestNonReadNoteNum() 
{	
	local int i;
	for(i=SephirothPlayer(PlayerOwner).InBoxNotes.Length-1;i>=0;i--) {
		if(!SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead) 				
			if(InStr(SephirothPlayer(PlayerOwner).InBoxNotes[i].From, "SYS@") == -1) 
				return i;
	}
	return -1;
}

function OpenLatestReceiveNote()
{
	local int NoteNum;

	NoteNum = GetLatestNonReadNoteNum();
	if( NoteNum != -1)
		OpenReceiveNoteInterface(NoteNum);
}


function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Space,Value;
	local string Cmd, Param;

	if(NotifyType == INT_Close)
	{
		if(Interface == Inbox) {
			HideInbox();
			Components[4].Caption = Localize("Messenger","OpenInbox","Sephiroth");
		}
		else if(Interface == SendNote)
			CloseSendNoteInterface();
		else if(Interface == ReceiveNote)
			CloseReceiveNoteInterface();
		else if(Interface == SendNote_Direct)
			CloseSendNote_DirectInterface();
	}
	else if(NotifyType == INT_MessageBox)
	{
		Value = int(Command);
		if(Value == IDM_RequestAddBuddy)
		{
			SephirothPlayer(PlayerOwner).Net.NotiBuddyAdd("", SephirothPlayer(PlayerOwner).BuddyMgr.Fanlist[0]);
		}
		// jjh ---
		else if (Value == -1 * IDM_RequestAddBuddy)
		{
			SephirothPlayer(PlayerOwner).Net.NotiBuddyRemove(SephirothPlayer(PlayerOwner).BuddyMgr.Fanlist[0]);
			SephirothPlayer(PlayerOwner).BuddyMgr.Fanlist.Remove(0, 1);
			UpdateBuddyInfo();			
		}
		// --- jjh
		else if(Value == IDM_GroupDelete)
		{
			SephirothPlayer(PlayerOwner).Net.NotiBuddyGroupRemove(GetGroupName(SelectedGroupNum));			
			SelectedGroupNum = -1;
			SelectedBuddyNum = -1;
		}
	}
	else if(NotifyType == INT_Command)
	{
		if(Interface == ReceiveNote) {
			if(Command == "NextNote") {
				OpenLatestReceiveNote();
			}
		}
		else if(Interface == Inbox) {
			Space = InStr(Command," ");
			if(Space != -1)
			{
				Cmd = left(Command,Space);
				Param = Mid(Command,Space+1);			
				if(Cmd == "OpenSendNote")
				{			
					OpenSendNoteInterface(Param, false);
				}				
				// jjh ---
				else if (Cmd == "OpenSendNoteEx")
				{
					OpenSendNoteInterfaceEx(Param, false);
				}
				// --- jjh
				else if(Cmd == "OpenReceiveNote")
				{
					Value = int(Param);
					OpenReceiveNoteInterface(Value);
				}
			}

		}
	}
}

function OnPreRender(Canvas C)
{
	local int Num, i;
	local string sFrom, Caption;
	Num = SephirothPlayer(PlayerOwner).InBoxNotes.Length-1;
	// jjh ---
	// if(Num != 0)
	// if (Num >= 0)
	//	Components[4].bDisabled = SephirothPlayer(PlayerOwner).InBoxNotes[Num].bRead;
	// --- jjh
	Components[9].bDisabled = SelectedGroupNum == -1;

	NewNoteCounts=0;
	for(i = 0 ; i < SephirothPlayer(PlayerOwner).InBoxNotes.Length ; i++)
	{
		sFrom = SephirothPlayer(PlayerOwner).InBoxNotes[i].From;
		if(InStr(sFrom, "SYS@") == -1 && !SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead)
			NewNoteCounts++;
	}
	Caption = Localize("Messenger","UnReadNote","Sephiroth");
	/*if(Level.TimeSeconds - int(Level.TimeSeconds) > 0.9)
		SetComponentText(Components[8],"");
	else */
	SetComponentText(Components[8],Caption);

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);
}

function string GetGroupName(int GroupID)
{
	if(GroupID == 0)
		return Localize("Messenger", "BaseGroup", "Sephiroth");
	else 
		return SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupID].GroupName;
		//return BuddyMgr.BuddyGroups[GroupID].GroupName;
}

function string GetBuddyName(int GroupID, int BuddyID)
{	
	return SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].BuddyName;
	//return BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].BuddyName;
}

function DrawGroupArrangePopMenu(Canvas C)
{
	local int i, Width, Height;	
	local float XL,YL,X,Y;
	local color OldColor;
	
	for(i = 0 ; i < SephirothPlayer(playerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		C.TextSize(GetGroupName(i), XL, YL);
		//C.TextSize(BuddyMgr.BuddyGroups[i].GroupName, XL, YL);
		if(XL > Width)
		{
			Width = XL;
		}
		Height += LineSize;
	}
	GroupPopWidth = Width;
	GroupPopHeight = Height;

	X = GroupPopX-Width-1;
	Y = GroupPopY;	
	
	C.SetPos(X-1,Y-1);
	C.DrawTile(Texture'Engine.WhiteSquareTexture',Width+2,Height+2,0,0,0,0);
	OldColor = C.DrawColor;

	for(i = 0 ; i < SephirothPlayer(playerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		C.SetDrawColor(30,30,50);
		if(IsCursorInsideAt(X,Y+LineSize*i,Width,LineSize-1))
		{
			C.SetPos(X,Y+LineSize*i+1);
			C.SetDrawColor(30,30,100);
			C.DrawTile(Texture'Engine.WhiteSquareTexture',Width,LineSize-2,0,0,0,0);
			C.DrawColor = OldColor;
		}				
		C.DrawKoreanText(GetGroupName(i),X,Y+LineSize*i,Width,LineSize);			
		C.DrawColor = OldColor;
	}	
}

function DrawPopUpMenu(Canvas C)
{
	local float X,Y;
	local float MouseX,MouseY;
	local int i;
	local color OldColor;

	MouseX = Controller.MouseX;
	MouseY = Controller.MouseY;

	if(RClickMouseX+100>=C.ClipX)
		RClickMouseX = C.ClipX-110;

	if(SelectedBuddyNum >= 0)
	{
		if(RClickMouseY+LineSize*5 >= C.ClipY)
			RClickMouseY = C.ClipY-(LineSize*5 + 10);
		X = RClickMouseX;
		Y = RClickMouseY;
				
		C.SetPos(X,Y);		
		C.DrawTile(Texture'Engine.WhiteSquareTexture',100,LineSize*BuddyPopTexts.Length,0,0,0,0);
		OldColor = C.DrawColor;		

		for(i=0;i<BuddyPopTexts.Length;i++)
		{
			C.SetDrawColor(30,30,50);
			if(IsCursorInsideAt(X,Y+LineSize*i,100,LineSize-1))
			{
				C.SetPos(X+3,Y+LineSize*i+1);
				C.SetDrawColor(30,30,100);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',94,LineSize-2,0,0,0,0);
				C.DrawColor = OldColor;
				if(i == 2)
				{
					GroupPopX = X;
					GroupPopY = Y+LineSize*2;
					bDrawGroupPopMenu = true;
				}					
				else
					bDrawGroupPopMenu = false;
			}			
			C.DrawKoreanText(BuddyPopTexts[i],X+5,Y+LineSize*i,90,LineSize);
			C.DrawColor = OldColor;
		}
		if(bDrawGroupPopMenu)
		{
			C.SetDrawColor(30,30,50);			
			C.SetPos(X+3,Y+LineSize*2+1);
			C.SetDrawColor(30,30,100);
			C.DrawTile(Texture'Engine.WhiteSquareTexture',94,LineSize-2,0,0,0,0);
			C.DrawColor = OldColor;			
			C.DrawKoreanText(BuddyPopTexts[2],X+5,Y+LineSize*2,90,LineSize);
			C.DrawColor = OldColor;			
			DrawGroupArrangePopMenu(C);
		}		
	}
	else
	{
		if(RClickMouseY+LineSize*3 >= C.ClipY)
			RClickMouseY = C.ClipY-(LineSize*3 + 10);
		X=RClickMouseX;
		Y=RClickMouseY;

		C.SetPos(X,Y);
		C.DrawTile(Texture'Engine.WhiteSquareTexture',130,LineSize*GroupPopTexts.Length,0,0,0,0);
		OldColor = C.DrawColor;

		for(i=0;i<GroupPopTexts.Length;i++)
		{
			C.SetDrawColor(30,30,50);
			if(IsCursorInsideAt(X,Y+LineSize*i,130,LineSize-1))
			{
				C.SetPos(X+3,Y+LineSize*i+1);
				C.SetDrawColor(30,30,100);
				C.DrawTile(Texture'Engine.WhiteSquareTexture',124,LineSize-2,0,0,0,0);
				C.DrawColor = Oldcolor;
			}
			C.DrawKoreanText(GroupPopTexts[i],X+5,Y+LineSize*i,120,LineSize);
		}
	}
	C.DrawColor = OldColor;
}

function DrawGroupName(Canvas C, float X, float Y, int GroupID)
{
	local float XL,YL;
	local color OldColor;
	local string GroupName;
	local bool bOpen;

	OldColor = C.DrawColor;
	if(SelectedGroupNum == GroupID && SelectedBuddyNum == -1)
	{		
		C.SetDrawColor(255,255,0);
	}
	
	if(GroupState.Length > 0 && GroupState[GroupID] == GS_OPEN)
		bOpen = false; //GroupName = "-" $ Chr(0x15) $ GetGroupName(GroupID);
	else 
		bOpen = true; //GroupName = "+" $ Chr(0x15) $ GetGroupName(GroupID);
	
	GroupName = GetGroupName(GroupID);

	C.TextSize(GroupName,XL,YL);
/*	if(XL>Components[3].XL)
	{
		if(IsCursorInsideAt(X+5,Y,Components[3].XL,LineSize-1) && !bDrawPopMenu)
		{
			C.SetPos(X,Y);
			C.SetDrawColor(241,215,113);
			C.DrawTileStretched(Controller.WhitePen,XL,YL);
			C.SetDrawColor(0,0,0);
			C.DrawTextJustified(GetGroupName(GroupID),0,X,Y,X+XL+5,Y+LineSize);
		}		
		else
		{
			C.SetDrawColor(241,215,113);
			GroupName = ClipText(C,GroupName,Components[3].XL);
			ReplaceText(GroupName, Chr(0x15), " ");
			C.DrawKoreanText(GroupName,X+5,Y,Components[3].XL,LineSize);
		}
	}
	else*/
	if(true)
	{
		C.SetDrawColor(241,215,113);
		ReplaceText(GroupName, Chr(0x15), " "); // 15, 16
		C.DrawKoreanText(GroupName,X+20,Y,Components[3].XL,LineSize);

		C.SetPos(X, Y);
		if(bOpen)
			C.DrawTile(TextureResources[15].Resource,14,14,0,0,20,20);
		else
			C.DrawTile(TextureResources[16].Resource,14,14,0,0,20,20);
	}

	C.DrawColor = OldColor;
}

function DrawBuddyName(Canvas C, float X, float Y, int GroupID, int BuddyID)
{
	local float XL,YL;
	local color OldColor;
	local string BuddyName;
	local bool bOnMouse;

	OldColor = C.DrawColor;

	if(SelectedGroupNum == GroupID && SelectedBuddyNum == BuddyID)
	{				
		C.SetDrawColor(255,255,0);
	}
	else if(!SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].bOnline)
//	else if(BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].bOnline)
	{
		C.SetDrawColor(128,128,128);
	}	
	BuddyName = SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].BuddyName;
//	BuddyName = BuddyMgr.BuddyGroups[GroupID].Buddys[BuddyID].BuddyName;

	C.TextSize(BuddyName,XL,YL);
	if(XL>110)
	{
		if(IsCursorInsideAt(X+20,Y,110,LineSize-1) && !bDrawPopMenu)
		{
			C.SetPos(X+5,Y);
			C.SetDrawColor(190,190,190);
			C.DrawTileStretched(Controller.WhitePen,XL,YL);
			C.SetDrawColor(0,0,0);
			C.DrawTextJustified(BuddyName,0,X+5,Y,X+5+XL,Y+LineSize-2);
			bOnMouse = true;
		}
		else
		{
			BuddyName = ClipText(C,BuddyName,105);
		}			
	}	
	//C.DrawKoreanText(BuddyName,X+20,Y,110,LineSize);
	if(!bOnMouse)
		C.DrawKoreanText(BuddyName,X+20,Y,105,LineSize);
	C.DrawColor = OldColor;
}

function DrawBlinkMessage(Canvas C)
{
	local float X,Y;

	X = Components[0].X;
	Y = Components[0].Y;

	if(!SephirothPlayer(PlayerOwner).InBoxNotes[SephirothPlayer(PlayerOwner).InBoxNotes.Length-1].bRead)
	{
		if (Level.TimeSeconds - int(Level.TimeSeconds) < 0.5)
			C.DrawKoreanText(Localize("Messenger","NewMessage","Sephiroth"),X+26,Y+74,130,15);
	}	
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,StartY, CurrentYPos;
	local color OldColor;
	local int i, j;
	local int LineNum, OnListNum;
	local BuddyList TempBuddy;

	X = Components[0].X;
	Y = Components[0].Y;
	/*
	C.SetPos(Components[6].X,Components[6].Y);
	C.DrawRect1Fix(Components[6].XL, Components[6].YL);
*/

	C.KTextFormat = ETextAlign.TA_MiddleRight;
	C.SetDrawColor(238,187,1);
	C.DrawKoreanText(NewNoteCounts $ " " $ Localize("Messenger","Count","Sephiroth"), X+149,Y+39, 52, 14);

	//DrawBlinkMessage(C);
	C.SetDrawColor(255,255,255);
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	X = Components[6].X;
	Y = Components[6].Y;
	StartY = Components[2].Y;
	
	LineNum = 0;

	OldColor = C.DrawColor;
	
	/*ListOnMessenger.Empty();*/
	for(i=0;i<ListOnMessenger.Length;i++)
	{
		ListOnMessenger[i].GroupID = -1;
		ListOnMessenger[i].BuddyID = -1;
	}

	for(i = 0 ; i < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		CurrentYPos = Y+LineNum*LineSize;
		if(CurrentYPos >= StartY && CurrentYPos < StartY+18*LineSize)
		{
			DrawGroupName(C, X, CurrentYPos, i);
			TempBuddy.GroupID = i;
			TempBuddy.BuddyID = -1;
			ListOnMessenger[OnListNum]=TempBuddy;
			OnListNum++;
		}
		LineNum++;
		if(GroupState.Length > 0 && GroupState[i] == GS_OPEN)
		{
			for(j = 0 ; j < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[i].Buddys.Length ; j++)
			//for(j = 0 ; j < BuddyMgr.BuddyGroups[i].Buddys.Length ; j++)
			{
				CurrentYPos = Y+LineNum*LineSize;
				if(CurrentYPos >= StartY && CurrentYPos < StartY+18*LineSize)
				{
					DrawBuddyName(C,X,CurrentYPos,i,j);
					TempBuddy.GroupID = i;
					TempBuddy.BuddyID = j;
					ListOnMessenger[OnListNum]=TempBuddy;
					OnListNum++;
				}
				LineNum++;
			}
		}
	}	
	if(bDrawPopMenu)		// 친구목록에서 오른쪽 클릭 했을경우 (쪽지보내기, 친구삭제...)
		DrawPopUpMenu(C);
}

function NotifyScrollUp(int CmdId, int Amount)
{
	VLine -= Amount * LineSize;
	if(VLine <= 0)
		VLine = 0;
}

function NotifyScrollDown(int CmdId, int Amount)
{
	if(Components[6].YL <= 274)
	{
		VLine = 0;
		return;
	}
	if(Components[6].YL > 274)
	{
		VLine += Amount * LineSize;		
	}
	if(VLine >= Components[6].YL - 274)
		VLine = Components[6].YL - 274;
}

function int GetListLength()
{
	local int length;
	local int i;

	length = 0;
	for(i = 0 ; i < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		length += LineSize;
		if(GroupState.Length > 0 && GroupState[i] == GS_OPEN)
		{
			length += LineSize*SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[i].Buddys.Length;
			//length += LineSize*BuddyMgr.BuddyGroups[i].Buddys.Length;
		}		
	}
	return length;
}

function Plane PushComponentPlane(int CmdId)
{
	local Plane P;
	if(GetListLength() <= 274)
		VLine = 0;
	P.X = GetListLength();
	P.Y = 274;
	P.Z = LineSize;
	P.W = VLine;
	return P;	
}

function bool CheckSameName(string Name, int ID)
{
	local int i,j;	

	for(i=0 ; i < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	{
		if(ID == 2)
		{
			for(j=0; j < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[i].Buddys.Length ; j++)
			{
				if(Name == SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[i].Buddys[j].BuddyName)
					return true;
			}
		}
		else
		{			
			if(Name == GetGroupName(0))
				return true;
			if(Name == SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[i].GroupName)
				return true;
		}
	}	
	return false;
}

function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	switch(NotifyId)
	{
	case IDS_GroupAdd:	
		if(CheckSameName(EditText, 1))
		{
			class'CEditBox'.static.EditBox(Self,"GroupAdd",Localize("Messenger","ExistName","Sephiroth"),IDS_GroupAdd,22,"");
			return;
		}			
		SephirothPlayer(PlayerOwner).Net.NotiBuddyGroupAdd(EditText);
		//TestBuddyGroupAdd(EditText);
		break;

	case IDS_GroupRename:
		if(CheckSameName(EditText, 1))
		{
			class'CEditBox'.static.EditBox(Self,"GroupRename",Localize("Messenger","ExistName","Sephiroth"),IDS_GroupRename,22,"");
			return;
		}
		SephirothPlayer(PlayerOwner).Net.NotiBuddyGroupRename(SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName,EditText);
		//TestBuddyGroupRename(BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName, EditText);
		break;

	case IDS_BuddyAdd:
		if(EditText == string(SephirothPlayer(PlayerOwner).PSI.PlayName))
		{
			class'CMessageBox'.static.MessageBox(Self,"BuddyAdd",Localize("Messenger","AddMyName","Sephiroth"),MB_OK);
			return;
		}			
		SephirothPlayer(PlayerOwner).Net.NotiBuddyAdd(SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName,EditText);
		//TestBuddyAdd(BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName, EditText);
		break;
	}
	SelectedGroupNum = -1;
	SelectedBuddyNum = -1;
}

function bool IsArrangeGroupSelected()
{
	local int i;
	local float X,Y;

	X = GroupPopX;
	Y = GroupPopY;

	for(i = 0 ; i < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		if(IsCursorInsideAt(X-GroupPopWidth,Y+LineSize*i,GroupPopWidth,LineSize-1))
		{
			SelectedMoveGroupNum = i;
			return true;
		}
	}
	return false;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float X, Y, StartY, CurrentYPos;
	local int i, LineNum;
	local int GroupNum, BuddyNum;

	if(SelectedGroupNum != -1)
		Components[9].Tooltip="Friend";
	else
		Components[9].Tooltip="Friend_";

	if (Key == IK_LeftMouse || Key == IK_RightMouse) {
		if (SendNote != None || ReceiveNote != None)
			return true;
	}

	GroupNum = -1;
	BuddyNum = -1;
	
	if(Action == IST_Press)
	{
		X = Components[0].X;
		Y = Components[0].Y;
		if(IsCursorInsideAt(X+21,Y+71,143,296))
		{
			if(Key == IK_MouseWheelDown)
			{
				NotifyScrollDown(-1,1);
				return true;
			}
			if(Key == IK_MouseWheelUp)
			{
				NotifyScrollUp(-1,1);
				return true;
			}
		}		
	}

	if(Action == IST_Press)
	{
		X = Components[6].X;
		StartY = Components[2].Y;

		for(i = 0 ; i < ListOnMessenger.Length ; i++)
		{
			CurrentYPos = StartY+(i*LineSize);
			if(IsCursorInsideAt(X,CurrentYPos,130,LineSize-1))
			{
				GroupNum = ListOnMessenger[i].GroupID;
				BuddyNum = ListOnMessenger[i].BuddyID;
				LineNum = i;				
			}			
		}	
		
		if (Key == IK_LeftMouse)
		{
			if(bDrawPopMenu)
			{
				X = RClickMouseX;
				Y = RClickMouseY;				

				if(SelectedBuddyNum >= 0 && SelectedBuddyNum < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys.Length)
				//if(SelectedBuddyNum >= 0 && SelectedBuddyNum < BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys.Length)
				{					
					if(IsCursorInsideAt(X,Y,100,LineSize-1))
					{	/*Send Note*/
						OpenSendNoteInterface(GetBuddyName(SelectedGroupNum, SelectedBuddyNum), false);
					}
					else if(IsCursorInsideAt(X,Y+LineSize,100,LineSize-1))
					{	/*Delete Buddy*/
						SephirothPlayer(PlayerOwner).Net.NotiBuddyRemove(/*GetGroupName(SelectedGroupNum), */GetBuddyName(SelectedGroupNum, SelectedBuddyNum));
						//TestBuddyRemove(SelectedGroupNum, SelectedBuddyNum);
						SelectedGroupNum = -1;
						SelectedBuddyNum = -1;
					}
					else if(bDrawGroupPopMenu)
					{	/*Group Arrange*/	
						if(IsArrangeGroupSelected())
						{
							SephirothPlayer(playerOwner).Net.NotiBuddyArrange(SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName,
									SephirothPlayer(playerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].Buddys[SelectedBuddyNum].BuddyName,
									SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedMoveGroupNum].GroupName);
							//TestBuddyArrange();
							SelectedBuddyNum = -1;
							SelectedGroupNum = -1;
							SelectedMoveGroupNum = -1;							
						}						
					}
				}
				else if(SelectedGroupNum>=0 && SelectedGroupNum < SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length)
				//else if(SelectedGroupNum>=0 && SelectedGroupNum < BuddyMgr.BuddyGroups.Length)
				{
					if(IsCursorInsideAt(X,Y,100,LineSize-1))
					{	/*Add Group*/						
						class'CEditBox'.static.EditBox(self,"GroupAdd",Localize("Messenger","GroupAddMessage","Sephiroth"),IDS_GroupAdd,22,"");
					}
					else if(IsCursorInsideAt(X,Y+LineSize,100,LineSize-1))
					{	/*Delete Group*/
						if(SelectedGroupNum != 0)
						{
							class'CMessageBox'.static.MessageBox(Self,"GroupDelete",Localize("Messenger","GroupDeleteConfirm","Sephiroth"),MB_YesNo,IDM_GroupDelete);							
						}						
					}
					else if(IsCursorInsideAt(X,Y+LineSize*2,100,LineSize-1))
					{	/*Rename Group*/
						class'CEditBox'.static.EditBox(self,"GroupRename",Localize("Messenger","GroupRenameMessage","Sephiroth"),IDS_GroupRename,22,SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName);
						//class'CEditBox'.static.EditBox(self,"RenameGroup","GroupRename",IDS_GroupRename,22,BuddyMgr.BuddyGroups[SelectedGroupNum].GroupName);
					}
					else if(IsCursorInsideAt(X,Y+LineSize*3,130,LineSize-1))
					{	/*Add Buddy*/
						class'CEditbox'.static.EditBox(self,"BuddyAdd",Localize("Messenger","BuddyAddMessage","Sephiroth"),IDS_BuddyAdd,20,"");
					}
					else if(IsCursorInsideAt(X,Y+LineSize*4,130,LineSize-1))
					{	/*Send note to all groupmember*/
						if(SelectedGroupNum == 0)
							OpenSendNoteInterface("",true);
						else
							OpenSendNoteInterface(GetGroupName(SelectedGroupNum), true);
					}
				}
				else
				{
					SelectedGroupNum = -1;
					SelectedBuddyNum = -1;
				}
				bDrawPopMenu = false;
				bDrawGroupPopMenu = false;
				RClickMouseX = -1;
				RClickMouseY = -1;				
				return true;
			}
			else
			{
				if(BuddyNum>=0)
				{
					SelectedGroupNum = GroupNum;
					SelectedBuddyNum = BuddyNum;
					return true;
				}
				else if(GroupNum>=0)
				{
					SelectedGroupNum = GroupNum;
					SelectedBuddyNum = -1;
					if(GroupState[GroupNum] == GS_OPEN)
						GroupState[GroupNum] = GS_CLOSE;
					else
						GroupState[GroupNum] = GS_OPEN;
					return true;
				}
				else 
				{
					SelectedGroupNum = -1;
					SelectedBuddyNum = -1;
				}
			}
		}
		else if(Key == IK_RightMouse)
		{
		//	OnlineCount++;
			if(GroupNum >= 0 || BuddyNum >= 0)
			{
				SelectedGroupNum = GroupNum;
				SelectedBuddyNum = BuddyNum;				
				RClickMouseX = Controller.MouseX;				
				RClickMouseY = Controller.MouseY;
				bDrawPopMenu = true;
				return true;
			}			
		}		
	}

	// jjh ---
	if (Key == IK_LeftMouse) {
		if ((Action == IST_Press)&& IsCursorInsideComponent(Components[0])) {
			bMovingUI = true;
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
	/*
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
	*/
	// --- jjh
}

function OpenSendNote_DirectInterface()
{
	//@by wj(05/27)
	if(SendNote != None)
		CloseSendNoteInterface();
	//+jhjung,2003.6.24
	if (ReceiveNote != None)
		CloseReceiveNoteInterface();

	SendNote_Direct = SendNote_Direct(AddInterface("SephirothUI.SendNote_Direct"));
	if(SendNote_Direct != None)
	{
		SendNote_Direct.ShowInterface();
	}
}


function OpenSendNoteInterface(string Name, bool flag)
{
	//@by wj(05/27)
	if(SendNote != None)
		CloseSendNoteInterface();
	//+jhjung,2003.6.24
	if (ReceiveNote != None)
		CloseReceiveNoteInterface();

	SendNote = SendNote(AddInterface("SephirothUI.SendNote"));
	if(SendNote != None)
	{
		SendNote.ShowInterface();
		SendNote.SetReceiver(Name, flag);
	}
}

// jjh ---
function OpenSendNoteInterfaceEx(string Param, bool flag)
{
	local array<string> Params;
	class'CNativeInterface'.static.WrapStringToArray(Param, Params, 10000, "|");
	if (Params.Length != 3)
		return;
	if(SendNote != None)
		CloseSendNoteInterface();
	//+jhjung,2003.6.24
	if (ReceiveNote != None)
		CloseReceiveNoteInterface();

	SendNote = SendNote(AddInterface("SephirothUI.SendNote"));
	if(SendNote != None)
	{
		SendNote.ShowInterface();
		SendNote.SetReceiver(Params[0], flag);
		SendNote.WinX = int(Params[1]);
		SendNote.WinY = int(Params[2]);
	}
}
// --- jjh

function CloseSendNoteInterface()
{
	SendNote.HideInterface();
	RemoveInterface(SendNote);
	SendNote = None;
}

function CloseSendNote_DirectInterface()
{
	SendNote_Direct.HideInterface();
	RemoveInterface(SendNote_Direct);
	SendNote_Direct = None;
}

function OpenReceiveNoteInterface(int Num)
{
	//+jhjung,2003.6.24
	if (SendNote != None)
		CloseSendNoteInterface();

	if(ReceiveNote != None)
		CloseReceiveNoteInterface();

	SephirothPlayer(PlayerOwner).Net.NotiNoteInboxRead(SephirothPlayer(PlayerOwner).InBoxNotes[Num].NoteID);

	// 읽은 알리미는 개수를 차감해준다.	- Xelloss
	if ( !SephirothPlayer(PlayerOwner).InBoxNotes[Num].bRead && SephirothPlayer(PlayerOwner).nNoteUnread > 0 )
		SephirothPlayer(PlayerOwner).nNoteUnread--;

	ReceiveNote = ReceiveNote(AddInterface("SephirothUI.ReceiveNote"));

	if(ReceiveNote != None)
	{
		ReceiveNote.ShowInterface();
		ReceiveNote.SetNoteNum(Num);
	}
}

function CloseReceiveNoteInterface()
{
	ReceiveNote.HideInterface();
	RemoveInterface(ReceiveNote);
	ReceiveNote = None;
}

function UpdateBuddyInfo()
{
	local string FanName;

	if(SephirothPlayer(PlayerOwner).BuddyMgr.Fanlist.Length != 0)
	{
		FanName = SephirothPlayer(PlayerOwner).BuddyMgr.Fanlist[0];
		// jjh ---
		// class'CMessageBox'.static.MessageBox(Self,"RequestAddBuddy",FanName@"RequestBuddyAddMessage",MB_YESNO,IDM_RequestAddBuddy);
		class'CMessageBox'.static.MessageBox(Self,"RequestAddBuddy",FanName@Localize("Messenger","RequestBuddyAddMessage","Sephiroth"),MB_YESNO,IDM_RequestAddBuddy);
	}
}

// jjh ---
function CloseNotes()
{
	if (Inbox != None) {
		Inbox.HideInterface();
		RemoveInterface(Inbox);
		Inbox = None;
	}
	if (SendNote != None)
		CloseSendNoteInterface();
	if (ReceiveNote != None)
		CloseReceiveNoteInterface();
}

function bool DoubleClick()
{
	local int i, BuddyNum, GroupNum;
	local float X, StartY;
	local string BuddyName;
	local bool bOnline;

	if (SendNote != None || ReceiveNote != None)
		return true;

	if (!IsCursorInsideComponent(Components[0]))
		return false;

	X = Components[6].X;
	StartY = Components[2].Y;
	for (i=0;i<ListOnMessenger.Length;i++) {
		if (IsCursorInsideAt(X, StartY + (i * LineSize), 130, LineSize - 1)) {
			GroupNum = ListOnMessenger[i].GroupID;
			BuddyNum = ListOnMessenger[i].BuddyID;
			if (BuddyNum >= 0) {
				bOnline = SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupNum].Buddys[BuddyNum].bOnline;
				BuddyName = SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups[GroupNum].Buddys[BuddyNum].BuddyName;
				if (bOnline)
					Parent.NotifyInterface(Self,INT_Command,"SendWhisper " $ BuddyName);
				else
					OpenSendNoteInterface(GetBuddyName(GroupNum, BuddyNum), false);
			}
			return true;
		}
	}
	return false;
}
// --- jjh

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

function Layout(Canvas C)
{
	local int i;
	local int DX, DY;
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
	MoveComponentId(0, true, PageX, PageY, WinWidth, WinHeight);
	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
	MoveComponentId(6,true,Components[2].X,Components[2].Y-VLine);	// 목록 위치 설정
	Components[6].YL = GetListLength();
	Super.LayOut(C);
}

function SetButton()
{
	Components[3].NotifyId = BN_SendNote;
	Components[4].NotifyId = BN_Inbox;//BN_NewNote;
	Components[7].NotifyId = BN_Exit;
	Components[8].NotifyId = BN_Inbox;
	Components[9].NotifyId = BN_AddFriend;
	SetComponentTextureId(Components[3],11,-1,13,12);
	SetComponentTextureId(Components[4],11,-1,13,12);
	SetComponentTextureId(Components[9],11,-1,13,12);

	SetComponentTextureId(Components[7],9,-1,9,10);
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     Components(0)=(XL=289.000000,YL=438.000000)
     Components(1)=(Id=1,ResId=14,Type=RES_Image,XL=267.000000,YL=339.000000,PivotDir=PVT_Copy,OffsetXL=11.000000,OffsetYL=54.000000)
     Components(2)=(Id=2,XL=130.000000,YL=274.000000,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=69.000000)
     Components(3)=(Id=3,Caption="SendNote",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=12.000000,OffsetYL=396.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Messenger")
     Components(4)=(Id=4,Caption="OpenInbox",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=100.000000,OffsetYL=396.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="Messenger")
     Components(5)=(Id=5,Type=RES_ScrollBar,XL=22.000000,YL=314.000000,PivotDir=PVT_Copy,OffsetXL=252.000000,OffsetYL=64.000000)
     Components(6)=(Id=6,XL=130.000000,YL=274.000000)
     Components(7)=(Id=7,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=261.000000,OffsetYL=14.000000,HotKey=IK_Escape)
     Components(8)=(Id=8,Type=RES_TextButton,XL=135.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=12.000000,OffsetYL=39.000000,TextAlign=TA_MiddleRight)
     Components(9)=(Id=9,Caption="Friend",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=188.000000,OffsetYL=396.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,ToolTip="Friend")
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
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="fri_info",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_s_+_n",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_s_-_n",Style=STY_Alpha)
     WinWidth=289.000000
     WinHeight=438.000000
     bDragAndDrop=True
     bAcceptDoubleClick=True
     IsBottom=True
}
