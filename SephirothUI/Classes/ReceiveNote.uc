class ReceiveNote extends CMultiInterface
	config(SephirothUI);

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

const BN_Exit = 101;
const BN_Reply = 102;

const Edit_Width = 215;
const Edit_Height = 108;

var string Sender;
var string Body;

var int NoteNum;
var int NextNoteNum;

var CImeRichEdit RichEdit;

function OnInit()
{
	if(PageX==-1)
		ResetDefaultPosition();
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	SetButton();

	NoteNum = -1;
	NextNoteNum = -1;
	RichEdit = CImeRichEdit(AddInterface("Interface.CImeRichEdit"));
	if(RichEdit != None)
	{
		RichEdit.bReadOnly = true; // jjh
		RichEdit.ShowInterface();
		RichEdit.SetSize(Edit_Width, Edit_Height);	
		RichEdit.MaxLines = 5;
		RichEdit.LineSpace = 22;
		RichEdit.bIgnoreKeyEvents = true; // jjh
	}	

}

function OnFlush()
{
	if(RichEdit != None)
	{
		RichEdit.HideInterface();
		RemoveInterface(RichEdit);
		RichEdit = None;
	}
	saveconfig();
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


	for(i=1;i<Components.Length;i++)
		MoveComponentId(i);
	Super.LayOut(C);
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch(NotifyId)
	{
	case BN_Exit:
		Parent.NotifyInterface(self,INT_Close);
		break;
	case BN_Reply:
		Parent.NotifyInterface(self,INT_Command,"OpenSendNoteEx"@SephirothPlayer(PlayerOwner).InBoxNotes[NoteNum].From$"|"$PageX$"|"$PageY);
		Parent.NotifyInterface(self,INT_Close);
		break;
	}
}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y,XL,YL;
	local string From;

	RichEdit.SetPos(Components[0].X+35, Components[0].Y+109);

	X = Components[0].X+86;
	Y = Components[0].Y+75;
	XL = 100;
	YL = 15;

	From = SephirothPlayer(PlayerOwner).InBoxNotes[NoteNum].From;
	From = ClipText(C, From, XL);
	From = MakeColorCodeEx(255,255,255) $ From;

	C.DrawTextJustified(From, 0, X, Y, X+XL, Y+YL);
	// --- jjh
}

function bool OnKeyEvent(interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float X, Y, XL, YL;
	
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
	{
		if (Action == IST_Press) 
		{
			bMovingUI = true;
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}

		// jjh ---
		X = Components[0].X + 86;
		Y = Components[0].Y + 48;
		XL = 100;
		YL = 15;
		if (Action == IST_Release && bIsDragging)
		{
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
		// --- jjh
		return true;
	}

	return false;
}


function int GetNextNonReadNoteNum()
{	
	local int i;
	for(i=SephirothPlayer(PlayerOwner).InBoxNotes.Length-1;i>=0;i--) {
		if(!SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead) 				
			if(InStr(SephirothPlayer(PlayerOwner).InBoxNotes[i].From, "SYS@") == -1) 
				return i;
	}
	return -1;
}

function SetNoteNum(int Num)
{
	NoteNum = Num;

	if ( NoteNum != -1 )	{

		SephirothPlayer(PlayerOwner).Net.NotiNoteInboxRead(SephirothPlayer(PlayerOwner).InBoxNotes[NoteNum].NoteID);

		// 읽은 알리미는 개수를 차감해준다.	- Xelloss
		if ( !SephirothPlayer(PlayerOwner).InBoxNotes[NoteNum].bRead && SephirothPlayer(PlayerOwner).nNoteUnread > 0 )
			SephirothPlayer(PlayerOwner).nNoteUnread--;
	}

	NextNoteNum = GetNextNonReadNoteNum();
	RichEdit.bReadOnly = true; // jjh
	RichEdit.SetText(SephirothPlayer(PlayerOwner).InBoxNotes[Num].Body);
	// RichEdit.bReadOnly = true;
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
	Components[3].NotifyId = BN_Exit;
	SetComponentTextureId(Components[3],9,-1,11,10);
//	Components[4].NotifyId = BN_Reply;
//	SetComponentTextureId(Components[4],9,-1,11,10);
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     Components(0)=(XL=289.000000,YL=371.000000)
     Components(1)=(Id=1,ResId=12,Type=RES_Image,XL=273.000000,YL=297.000000,PivotDir=PVT_Copy,OffsetXL=7.000000,OffsetYL=36.000000)
     Components(2)=(Id=2,ResId=13,Type=RES_Image,XL=46.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=74.000000)
     Components(3)=(Id=3,Caption="Close",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=150.000000,OffsetYL=329.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Escape,ToolTip="CloseContext")
     TextureResources(0)=(Package="UI_2011",Path="win_1_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_1_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_1_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="mail_bg",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="mail_from",Style=STY_Alpha)
     WinWidth=289.000000
     WinHeight=371.000000
}
