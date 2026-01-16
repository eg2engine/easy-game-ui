class StashShare extends CMultiInterface;

const BN_Exit = 1;
const BN_Add = 2;
const BN_Remove = 3;

var Bank Bank;
var int StashId;
var array<string> Friends;
var string SelectedFriendName;

//+jhjung, 2003-04-25
//var SepEditBox Edit;
var CImeEdit Edit;

function GetFriends()
{
	local int i;
	for (i=0;i<Bank.Stashes.Length;i++) {
		if (Bank.Stashes[i].Id == StashId) {
			class'CNativeInterface'.static.WrapStringToArray(Bank.Stashes[i].Friends, Friends, 10000, "|");
			return;
		}
	}
}

function OnInit()
{
	SetComponentNotify(Components[2],BN_Exit,Self);
	SetComponentTextureId(Components[2],1,0,1,2);

	SetComponentNotify(Components[3],BN_Add,Self);
	SetComponentNotify(Components[4],BN_Remove,Self);

	SetComponentTextureId(Components[3],3,-1,5,4);
	SetComponentTextureId(Components[4],3,-1,5,4);

	Bank = CStashLobby(Parent).Bank;
	StashId = CStashLobby(Parent).SelectedStashId;		//Yes! 여는 게 아니라, 클릭한 후, 공유 보관 하는 것이니 SelectedStashId가 맞아.
	SephirothPlayer(PlayerOwner).Net.NotiStashInfo(StashId);

	//Edit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (Edit != None) {
		Edit.bNative = true;
		Edit.SetMaxWidth(20);
		Edit.SetSize(104,16);
		Edit.ShowInterface();
		Edit.SetFocusEditBox(true);
	}
}

function OnFlush()
{
	if (Edit != None) {
		Edit.SetFocusEditBox(false);
		Edit.HideInterface();
		RemoveInterface(Edit);
		Edit = None;
	}
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,(C.ClipX-235)/2,(C.ClipY-316)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);
	if (Edit != None)
		Edit.SetPos(Components[0].X+28, Components[0].Y+73);
	Super.Layout(C);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Exit)
		Parent.NotifyInterface(Self,INT_Close);
	else if (NotifyId == BN_Add && Edit.GetText() != "") {
		SephirothPlayer(PlayerOwner).Net.NotiStashShare(StashId, Edit.GetText());
		Edit.SetText("");
	}
	else if (NotifyId == BN_Remove && SelectedFriendName != "")
		SephirothPlayer(PlayerOwner).Net.NotiStashUnshare(StashId, SelectedFriendName);
}

function OnPreRender(Canvas C)
{
	local bool bFound;
	local string Name;
	local int i;

	Name = Edit.GetText();
	if (Name != "") {
		for (i=0;i<Friends.Length;i++)
			if (Friends[i] == Name) {
				bFound = true;
				SelectedFriendName = Name;
				break;
			}
	}
	else
		SelectedFriendName = "";

	Components[3].bDisabled = Friends.Length >= 10 || Name == SelectedFriendName || Name == "" || bFound;
	Components[4].bDisabled = Friends.Length == 0 || SelectedFriendName == "" || (Name != "" && !bFound);
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;
	local int i;
	local color OldColor;

	C.DrawColor = OldColor;
	C.SetDrawColor(255, 255, 255);
	X = Components[0].X;
	Y = Components[0].Y;

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.SetDrawColor(229, 201, 174);
	C.DrawKoreanText(Localize("StashBoxUI","StashName","SephirothUI"),X+25,Y+40,50,14);

	C.SetDrawColor(128, 128, 128);
	if(CStashLobby(Parent).SelectedStashName == "" || !Edit.HasFocus())
		C.DrawKoreanText(Localize("Information","InputStashSharedUser","Sephiroth"),X+28,Y+73,209,14);
	
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255, 255, 255);
	C.DrawKoreanText(CStashLobby(Parent).SelectedStashName,X+114,Y+41,125,14);

	for (i=0;i<Friends.Length;i++)
	{
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		C.SetDrawColor(169, 208, 202);
		C.DrawKoreanText(string(i+1) $ " /", X+18, Y+135+i*24, 31, 17);
		if (Friends[i] == SelectedFriendName)
			C.SetDrawColor(255,219,93);
		else if (IsCursorInsideAt(X+62, Y+135+i*24, 154, 17))
			C.SetDrawColor(93,219,255);
		C.DrawKoreanText(Friends[i], X+62,Y+135+i*24,154,17);
	}
	
	C.DrawColor = OldColor;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local int i;
	local float X, Y;

	if (Key == IK_LeftMouse && Action == IST_Press)
	{
		X = Components[0].X;
		Y = Components[0].Y;

		for (i=0;i<Friends.Length;i++) {
			if (IsCursorInsideAt(X+62, Y+135+i*24, 154, 17)) {
				SelectedFriendName = Friends[i];
				if (SelectedFriendName != "") {	
					Edit.SetText(SelectedFriendName);
					return true;
				}
			}
		}
	}
	if (Key == IK_Enter && Action == IST_Press) {
		if (Edit.HasFocus() && Edit.GetText() != "") {
			SephirothPlayer(PlayerOwner).Net.NotiStashShare(StashId, Edit.GetText());
			Edit.SetText("");
		}
		return true;
	}
}

/*
function OnActivate(int CmpId,bool bActive)
{
	if (CmpId == 4 && bActive) {
		PlayerOwner.ConsoleCommand("OpenIME 1");
		SelectedFriendName = "";
	}
}
*/

function UpdateContents(int Id)
{
	if (Id == StashId) {
		Friends.Remove(0, Friends.Length);
		GetFriends();
//		if (Friends.Length < 10)
//			Edit.SetFocusEditBox(true);
	}
}

defaultproperties
{
     Components(0)=(XL=266.000000,YL=322.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=266.000000,YL=322.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=237.000000,OffsetYL=14.000000,HotKey=IK_Escape)
     Components(3)=(Id=3,Caption="Add",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=19.000000,OffsetYL=94.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Caption="Remove",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=135.000000,OffsetYL=94.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2011",Path="win_keep_2",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2009",Path="BTN02_00_P",Style=STY_Alpha)
}
