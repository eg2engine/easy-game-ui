class CDialog extends CMultiInterface
	config(SephirothUI);

var NpcServerInfo DialogNpc;
var Npc NpcPawn; //, NpcModel;
var SephirothPlayer.Dialog Dialog;
var vector NpcOffset;
var array<string> Dialogs;
var CTextScroll TextArea, LinkArea;

const BN_Close = 1;
const IDS_ClanCreate = 100;
const IDM_ClanDelete = 101;

var globalconfig float NpcRatio, NpcX, NpcY;

function OnInit()
{
	SetButton();

	TextArea = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (TextArea != None) {
		TextArea.ShowInterface();
		TextArea.TextList.bReadOnly = True;
		TextArea.TextList.bWrapText = True;
		TextArea.TextList.TextAlign = 0;
		TextArea.TextList.ItemHeight = 18;
		TextArea.SetSize(360, 265);
	}
	LinkArea = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (LinkArea != None) {
		LinkArea.ShowInterface();
		LinkArea.TextList.bReadOnly = False;
		LinkArea.TextList.bWrapText = False;
		LinkArea.TextList.TextAlign = 0;
		LinkArea.TextList.ItemHeight = 18;
		LinkArea.SetSize(360, 109);
		LinkArea.TextList.OnDrawText = InternalDrawLinkText;
		LinkArea.TextList.OnDrawSelectedBK = InternalDrawLinkHighlight;
	}
}

function OnFlush()
{
/*
	if (NpcModel != None) {
		NpcModel.Destroy();
		NpcModel = None;
	}*/
	if (TextArea != None) {
		TextArea.HideInterface();
		RemoveInterface(TextArea);
		TextArea = None;
	}
	if (LinkArea != None) {
		LinkArea.HideInterface();
		RemoveInterface(LinkArea);
		LinkArea = None;
	}
}

function SetDialogProperty(Npc Npc,string DialogString)
{
	/*
	DialogNPC = Npc;
	if (DialogNpc != None) {
		DialogNpc.Talk();
		DialogNpcName = NpcServerInfo(ServerController(DialogNpc.Controller).MSI).FullnameLocalized;
	}
	LoadModel();
	if (TextArea != None)
		TextArea.MakeList(DialogString);
	*/
}

function SetHost(NpcServerInfo Npc)
{
	DialogNpc = Npc;
	if (DialogNpc != None)
		NpcPawn = Npc(Controller(DialogNpc.Owner).Pawn);
	if (NpcPawn != None)
		NpcPawn.Talk();
	LoadModel();
}

function SetDialog(SephirothPlayer.Dialog InDialog)
{
	local int i;
	Dialog = InDialog;
	if (TextArea != None) {
		TextArea.TextList.Clear();
		TextArea.TextList.MakeList(Dialog.Text);
	}
	if (LinkArea != None) {
		LinkArea.TextList.Clear();
		for (i=0;i<Dialog.Links.Length;i++)
			LinkArea.TextList.MakeList(Dialog.Links[i].Value);
	}
}

function LoadModel()
{
//	local string NpcClass;
//	local int CacheIndex;
	local string Res;

	Res = PlayerOwner.ConsoleCommand("GETRES");
/*	if (Res == "800x600")
		fScale = 1.0; //0.84375;
	else if (Res == "1024x768")
		fScale = 0.8;
	else if (Res == "1280x1024")
		fScale = 0.7;
	else if (Res == "1600x1024") //add neive : 와이드 모드
		fScale = 0.7;
	else if (Res == "1400x840")
		fScale = 0.8f;
	else
		fScale = 0.8;
*/		// Comment by Xelloss

/*
	if (DialogNpc != None)
	{
		CacheIndex = -1;
		NpcClass = class'ModelCache'.static.GetClassName(string(DialogNpc.ModelName), CacheIndex);
		if (NpcClass != "" && CacheIndex > -1) {
			NpcModel = Spawn(class<Npc>(DynamicLoadObject(NpcClass, class'Class')));
			if (NpcModel != None) {
				class'ModelCache'.static.BindCacheProperty(NpcModel, CacheIndex);
				NpcModel.bHidden = true;
//				NpcModel.SetDrawScale(NpcModel.Class.Default.DrawScale * fScale);		// Comment by Xelloss
				NpcModel.SetCollision(false,false,false);
				NpcModel.SetCollisionSize(0,0);
				NpcModel.bUnlit = true;
				if (NpcModel.HasAnim('Talk'))
					NpcModel.LoopAnim('Talk');
				else if (NpcModel.HasAnim('Idle'))
					NpcModel.LoopAnim('Idle');
			}
		}
	}*/
}

function DrawModel(Canvas C)
{
//	local vector CamPos,X,Y,Z;
//	local rotator CamRot;
/*	local int addX;

	if (C.ClipX == 1024)
		SetNpcOffset(300,-100,-10);
	else if (C.ClipX == 800)
		SetNpcOffset(350,-100,-10);
	else if (C.ClipX == 1280)
		SetNpcOffset(200,-100,-10);
	else
		SetNpcOffset(300,-100,-10);
*/

// Xelloss : 모델 위치 잡는 방법 변경됨
//	addX = (C.ClipX - 800) / 2;
/*	SetNpcOffset(C.ClipX / NpcRatio, NpcX, NpcY);

	if (NpcModel != None) {
		CamPos = PlayerOwner.Location;
		CamRot = PlayerOwner.Rotation;
		GetAxes(CamRot,X,Y,Z);
		NpcModel.SetRotation(OrthoRotation(-X,-Y,Z));
		NpcModel.SetLocation(CamPos + NpcOffset.X * X + NpcOffset.Y * Y + NpcOffset.Z * Z);		// Xelloss
		C.DrawActor(NpcModel, false, true, 90.0);
	}*/
}

function DrawDialog(Canvas C, float X, float Y)
{
	local int i;
	local color OldColor;

	OldColor = C.DrawColor;
	C.SetDrawColor(0,0,0);
	if (Dialogs.Length > 0) {
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		for (i=0;i<Dialogs.Length;i++) {
			C.SetPos(X+186,Y+70+i*14);
			C.DrawText(Dialogs[i]);
		}
	}
	C.DrawColor = OldColor;
}

function SetNpcOffset(float X, float Y, float Z)
{
	NpcOffset.X = X;
	NpcOffset.Y = Y;
	NpcOffset.Z = Z;
}

function SetNpcRotation(int P,int Y,int R)
{
}


function Render(Canvas C)	{

	if ( NpcPawn.Controller == None )	{

		Parent.NotifyInterface(Self, INT_Close);
		return;
	}

	Super.Render(C);
}

function OnPreRender(Canvas C)
{
	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, Dialog.NpcName);
}

function OnPostRender(HUD H, Canvas C)
{

//	Components(1)=(Id=1,Type=RES_Image,ResId=11,XL=382,YL=2,PivotId=0,PivotDir=PVT_Copy,OffsetXL=17,OffsetYL=352) // 구분선
	C.SetDrawColor(255,255,255,255);
	C.SetPos(Components[0].X+17, Components[0].Y+352);
	C.DrawTile(TextureResources[11].Resource,382,2,0,0,32,2);

//	DrawModel(C);
//	DrawDialog(C, Components[0].X, Components[0].Y);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Super.OnKeyEvent(Key,Action,Delta))
		return true;

	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Index;
	if (Interface == LinkArea.TextList && NotifyType == INT_Command) {
		Index = int(Command);
		if (ProcessLink(Dialog.Links[Index].Key))
			Parent.NotifyInterface(Self,INT_Close);
	}
	else if (NotifyType == INT_MessageBox) {
		if (int(Command) == IDM_ClanDelete)
			SephirothPlayer(PlayerOwner).Net.NotiNpcDialog(DialogNpc.PanID, "/ClanDelete");
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	if (NotifyId == IDS_ClanCreate && EditText != "") {
		if (bool(PlayerOwner.ConsoleCommand("CHECKNAMEVALID" @ EditText))) {
			PlayerOwner.myHud.AddMessage(2,Localize("Warnings","InvalidClanName","Sephiroth"),class'Canvas'.static.MakeColor(255,255,0));
			return;
		}

		// 클랜 필터 관련 추가
		if(SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).ChannelMgr.IsClanIllegal(EditText))
		{
			SephirothPlayer(PlayerOwner).Net.NotiNpcDialog(DialogNpc.PanID, "/ClanCreate"$EditText);
		}
		else
		{
			SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).ChannelMgr.ShowClanIllegalMsg(EditText);
		}
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Close) {
		Parent.NotifyInterface(Self,INT_Close);
	}
}

function bool ProcessLink(string URL)
{
	if (DialogNpc != None) {
		if (URL == "/ClanCreate")
			class'CEditBox'.static.EditBox(Self,"ClanName",Localize("Modals","ClanCreate","Sephiroth"),IDS_ClanCreate,20);//@by wj(040216) 클랜명 한글 10자로 수정
		else if (URL == "/ClanDelete") {
			if (SephirothPlayer(PlayerOwner).PSI.ClanName == "")
				PlayerOwner.myHud.AddMessage(2,Localize("Warnings","NeedClan","Sephiroth"),class'Canvas'.static.MakeColor(255,255,0));
			else
				class'CMessageBox'.static.MessageBox(Self,"ClanDismiss",Localize("Modals","ClanDelete","Sephiroth"),MB_YesNo,IDM_ClanDelete);
		}
		else {
			SephirothPlayer(PlayerOwner).Net.NotiNpcDialog(DialogNpc.PanID, URL);
			return true;
		}
	}
	return false;
}

function InternalDrawLinkText(Canvas C, int i, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;
	if (bSelected) {
		if (Controller.bLButtonDown) {
			X += 1.0f;
			Y += 1.0f;
		}
		ColorCode = MakeColorCodeEx(255,242,0);	// 선택 글짜 색
	}
	else
		ColorCode = MakeColorCodeEx(255,255,255);
	C.DrawTextJustified(ColorCode $ Text, 1, X, Y, X+W, Y+H);
}

function InternalDrawLinkHighlight(Canvas C, float X, float Y, float W, float H, bool bSelected)
{
	C.SetPos(X, Y);
	C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', W, H);
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0, true, (C.ClipX-Components[0].XL)/2, (C.ClipY-Components[0].YL)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	if (TextArea != None)
		TextArea.SetPos(Components[0].X+26, Components[0].Y+58);
	if (LinkArea != None)
		LinkArea.SetPos(Components[0].X+26, Components[0].Y+371);
	Super.Layout(C);
}

function SetButton()
{
	SetComponentTextureId(Components[2],9,0,9,10);
	Components[2].NotifyId = BN_Close;
}

defaultproperties
{
     NpcOffset=(X=210.000000,Y=-110.000000,Z=15.000000)
     Components(0)=(XL=416.000000,YL=518.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=386.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
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
     TextureResources(11)=(Package="UI_2011",Path="line",Style=STY_Alpha)
}
