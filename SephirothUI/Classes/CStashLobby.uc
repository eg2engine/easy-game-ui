class CStashLobby extends CMultiInterface;

const OpenStash_StartId = 17;	 // 17번 Component부터 개인창고의 Open 버튼입니다(DefaultProperty 참조)

const BN_Exit = 1;
const BN_Make = 2;
const BN_Open = 3;
const BN_Share = 4;
const BN_Return = 5;
const BN_Unshare = 6;
const BN_Open_Shared = 7;

const IDM_OpenStash = 1;
const IDM_MakeStash = 2;
const IDM_ReturnStash = 3;
const IDM_CloseStash = 4;
const IDM_CloseLobby = 5;
const IDM_RefuseShare = 6;
const IDM_OpenStash_Shared = 7;

const IDS_MakeStash = 20;
const IDS_ReturnStash = 21;		// modified by yj

var NpcServerInfo BankNpc;
var Npc NpcPawn;
var Bank Bank;
var int DisplayedStashCount;
var int DisplayStartIndex;
var int SelectedStashIndex;

var int SelectedStashId;

var InterfaceRegion StashArea;

var CBag Bag;
var CStashBox StashBox;
var StashShare StashShare;
var CSubInventorySelectBox SubSelectBox;

var CTextList MyStashes;
var CTextScroll OtherStashes;

var int MyStashCount, OtherStashCount;

var string CandidateStashName;
var string SelectedStashName;
var Bank.Deposit SelectedStash, ConstStash;
var int SelectedIndex;

var int OpenSharedStash_StartId;

var color SelectedTextColor;

var string m_sTitle;

// ======== 扩展仓库显示（12个） ========
const MaxStashDisplayCount = 12;			// 仓库列表最大显示数量
const MakeStash_StartId = 12;				// MakeStash按钮起始ID（前5个：12-16）
const MakeStash_SecondStartId = 22;			// MakeStash按钮第二段起始ID（中5个：22-26）
const MakeStash_ThirdStartId = 32;			// MakeStash按钮第三段起始ID（后2个：32-33）

const OpenStash_SecondStartId = 27;			// OpenStash按钮第二段起始ID（中5个：27-31）
const OpenStash_ThirdStartId = 34;			// OpenStash按钮第三段起始ID（后2个：34-35）

function SetHost(NpcServerInfo Npc)
{
	BankNpc = Npc;
	NpcPawn = Npc(Controller(Npc.Owner).Pawn);
}

function SetBank(Bank InBank)
{
	local int i;

	Bank = InBank;

	if ( MyStashes == None )
		MyStashes = CTextList(AddInterface("Interface.CTextList"));

	if ( MyStashes != None )
	{
		if ( !MyStashes.bVisible )
			MyStashes.ShowInterface();

		MyStashes.Clear();
		MyStashes.bReadOnly = False;
		MyStashes.bWrapText = False;
		MyStashes.ItemHeight = 19;
		MyStashes.OffsetPerText = 5;

		// 支持 MaxStashDisplayCount 个
		MyStashes.SetSize(177, MaxStashDisplayCount * 27);

		MyStashes.OnDrawText = InternalDrawMyStashText;
		MyStashes.OnSelectText = InternalSelectMyStash;
		MyStashes.SelectedTextColor = SelectedTextColor;
		MyStashes.OnDrawSelectedBK = InternalDrawMyStashSelectedBK;

		MyStashes.bAcceptDoubleClick = True;
		MyStashes.DoubleClick_ = Stash_DoubleClick;
	}

	// 取消共享仓库功能：不再初始化 OtherStashes
	/*
	...
	*/

	if ( Bank.bClanBank )
	{
		for ( i = 0; i < Bank.Stashes.Length; i++ )
			MyStashes.MakeList(Bank.Stashes[i].Name);
	}
	else
	{
		for ( i = 0; i < Bank.Stashes.Length; i++ )
		{
			// 取消共享仓库：Shared == 1 的不加入列表
			if ( Bank.Stashes[i].Shared == 1 )
			{
			}
			else
			{
				MyStashes.MakeList(Bank.Stashes[i].Name);
			}
		}
	}

	MyStashCount = CountMyStash();
	//OtherStashCount = CountSharedStash();

	ConstStash.Id = -1;
	SelectedIndex = -1;

	MakeSharedOpenButton();
	MakeStashMakeButton();
}

function int CountMyStash()
{
	local int i, Count;
	if ( Bank != None )
	{
		for ( i = 0; i < Bank.Stashes.Length; i++ )
			if ( Bank.bClanBank || Bank.Stashes[i].Shared == 0 )
				Count++;
	}
	return Count;
}

function int CountSharedStash()
{
	local int i, Count;
	if ( Bank == None || Bank.bClanBank )
		return Count;

	for ( i = 0; i < Bank.Stashes.Length; i++ )
		if ( Bank.Stashes[i].Shared == 1 )
			Count++;

	return Count;
}

function OnInit()
{
	SetComponentTextureId(Components[3],2,0,2,3);
	SetComponentNotify(Components[3],BN_Exit,Self);

	SetComponentTextureId(Components[4],2,0,2,3);
	SetComponentNotify(Components[4],BN_Exit,Self);

	// 取消共享：隐藏取消共享按钮
	Components[6].bVisible = False;
	Components[6].bDisabled = True;

	SetComponentTextureId(Components[7],4,0,6,5);
	SetComponentNotify(Components[7],BN_Return,Self);

	// 设置 MakeStash 按钮（12-16 + 22-26 + 32-33）
	SetComponentNotify(Components[12],BN_Make,Self);
	SetComponentNotify(Components[13],BN_Make,Self);
	SetComponentNotify(Components[14],BN_Make,Self);
	SetComponentNotify(Components[15],BN_Make,Self);
	SetComponentNotify(Components[16],BN_Make,Self);

	SetComponentNotify(Components[22],BN_Make,Self);
	SetComponentNotify(Components[23],BN_Make,Self);
	SetComponentNotify(Components[24],BN_Make,Self);
	SetComponentNotify(Components[25],BN_Make,Self);
	SetComponentNotify(Components[26],BN_Make,Self);

	SetComponentNotify(Components[32],BN_Make,Self);
	SetComponentNotify(Components[33],BN_Make,Self);

	SetComponentTextureId(Components[12],7,8,9,10);
	SetComponentTextureId(Components[13],7,8,9,10);
	SetComponentTextureId(Components[14],7,8,9,10);
	SetComponentTextureId(Components[15],7,8,9,10);
	SetComponentTextureId(Components[16],7,8,9,10);

	SetComponentTextureId(Components[22],7,8,9,10);
	SetComponentTextureId(Components[23],7,8,9,10);
	SetComponentTextureId(Components[24],7,8,9,10);
	SetComponentTextureId(Components[25],7,8,9,10);
	SetComponentTextureId(Components[26],7,8,9,10);

	SetComponentTextureId(Components[32],7,8,9,10);
	SetComponentTextureId(Components[33],7,8,9,10);

	// 设置 OpenStash 按钮（17-21 + 27-31 + 34-35）
	SetComponentNotify(Components[17],BN_Open,Self);
	SetComponentNotify(Components[18],BN_Open,Self);
	SetComponentNotify(Components[19],BN_Open,Self);
	SetComponentNotify(Components[20],BN_Open,Self);
	SetComponentNotify(Components[21],BN_Open,Self);

	SetComponentNotify(Components[27],BN_Open,Self);
	SetComponentNotify(Components[28],BN_Open,Self);
	SetComponentNotify(Components[29],BN_Open,Self);
	SetComponentNotify(Components[30],BN_Open,Self);
	SetComponentNotify(Components[31],BN_Open,Self);

	SetComponentNotify(Components[34],BN_Open,Self);
	SetComponentNotify(Components[35],BN_Open,Self);

	SetComponentTextureId(Components[17],15,16,17,18);
	SetComponentTextureId(Components[18],15,16,17,18);
	SetComponentTextureId(Components[19],15,16,17,18);
	SetComponentTextureId(Components[20],15,16,17,18);
	SetComponentTextureId(Components[21],15,16,17,18);

	SetComponentTextureId(Components[27],15,16,17,18);
	SetComponentTextureId(Components[28],15,16,17,18);
	SetComponentTextureId(Components[29],15,16,17,18);
	SetComponentTextureId(Components[30],15,16,17,18);
	SetComponentTextureId(Components[31],15,16,17,18);

	SetComponentTextureId(Components[34],15,16,17,18);
	SetComponentTextureId(Components[35],15,16,17,18);

	OpenSharedStash_StartId = Components.Length;

	SubSelectBox = CSubInventorySelectBox(AddInterface("SephirothUI.CSubInventorySelectBox"));
	if ( SubSelectBox != None )
	{
		SubSelectBox.ShowInterface();
		SubSelectBox.MoveWindow(0, Components[0].Y + Components[0].YL);
	}

	m_sTitle = Localize("StashBoxUI", "Title", "SephirothUI");
}

function OnFlush()
{
	if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
		SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

	if ( SubSelectBox != None )
	{
		SubSelectBox.HideInterface();
		RemoveInterface(SubSelectBox);
		SubSelectBox = None;
	}
}

function Layout(Canvas C)
{
	local int i;
	local float X, Y;
	local vector MyPos, NpcPos;

	MyPos = PlayerOwner.Pawn.Location;
	NpcPos = NpcPawn.Location;

	if ( sqrt((MyPos.X - NpcPos.X)^2 + (MyPos.Y - NpcPos.Y)^2) > 1500 )
	{
		Parent.NotifyInterface(Self, INT_Close);
		return;
	}

	if ( Bank.bClanBank )
	{
		MoveComponentId(8,True,Components[2].X + 130,Components[2].Y + 254);
		MoveComponentId(0,True,C.ClipX - Components[2].XL,0);

		X = Components[0].X;
		Y = Components[0].Y;

		VisibleComponent(Components[6], False);
		VisibleComponent(Components[8], False);
	}
	else
	{
		MoveComponentId(0,True,C.ClipX - Components[1].XL,0);
	}

	for ( i = 1; i < Components.Length; i++ )
		MoveComponentId(i);

	if ( Bank.bClanBank && SubSelectBox != None )
		SubSelectBox.MoveWindow(0, Components[2].Y + Components[2].YL);

	if ( MyStashes != None )
		MyStashes.SetPos(Components[0].X + 69, Components[0].Y + 58);

	Super.Layout(C);
}

function bool IsSharedStash(int StashId)
{
	local int i;
	for ( i = 0; i < Bank.Stashes.Length; i++ )
		if ( StashId == Bank.Stashes[i].Id && Bank.Stashes[i].Shared == 1 )
			return True;

	return False;
}

function MakeSharedOpenButton()
{
	// 取消共享仓库：不再动态创建共享按钮
}

function int GetMakeStashButtonIdByIndex(int listIndex)
{
	if ( listIndex < 5 )
		return MakeStash_StartId + listIndex;				// 12-16

	if ( listIndex < 10 )
		return MakeStash_SecondStartId + (listIndex - 5);	// 22-26

	return MakeStash_ThirdStartId + (listIndex - 10);		// 32-33
}

function int GetOpenStashButtonIdByIndex(int listIndex)
{
	if ( listIndex < 5 )
		return OpenStash_StartId + listIndex;				// 17-21

	if ( listIndex < 10 )
		return OpenStash_SecondStartId + (listIndex - 5);	// 27-31

	return OpenStash_ThirdStartId + (listIndex - 10);		// 34-35
}

// 将按钮 CmpId 映射回 MyStashes 的列表索引（0..11）
function bool TryGetMyStashIndexByOpenButtonCmpId(int cmpId, out int stashIndex)
{
	// 17-21 => 0-4
	if ( cmpId >= OpenStash_StartId && cmpId <= (OpenStash_StartId + 4) )
	{
		stashIndex = cmpId - OpenStash_StartId;
		return True;
	}

	// 27-31 => 5-9
	if ( cmpId >= OpenStash_SecondStartId && cmpId <= (OpenStash_SecondStartId + 4) )
	{
		stashIndex = (cmpId - OpenStash_SecondStartId) + 5;
		return True;
	}

	// 34-35 => 10-11
	if ( cmpId >= OpenStash_ThirdStartId && cmpId <= (OpenStash_ThirdStartId + 1) )
	{
		stashIndex = (cmpId - OpenStash_ThirdStartId) + 10;
		return True;
	}

	stashIndex = -1;
	return False;
}

// 将 MyStashes 的第 N 项映射回 Bank.Stashes 的真实下标（避免 Shared 夹杂导致错位）
function bool TryGetBankStashIndexByMyListIndex(int myListIndex, out int bankIndex)
{
	local int i;
	local int count;

	bankIndex = -1;

	if ( Bank == None )
		return False;

	if ( Bank.bClanBank )
	{
		if ( myListIndex < 0 || myListIndex >= Bank.Stashes.Length )
			return False;

		bankIndex = myListIndex;
		return True;
	}

	count = 0;
	for ( i = 0; i < Bank.Stashes.Length; i++ )
	{
		if ( Bank.Stashes[i].Shared == 0 )
		{
			if ( count == myListIndex )
			{
				bankIndex = i;
				return True;
			}
			count++;
		}
	}

	return False;
}

function MakeStashMakeButton()
{
	local int i;
	local int makeId, openId;
	local int stashCount;
	local bool bLocked;

	if ( MyStashes == None )
		stashCount = 0;
	else
		stashCount = MyStashes.Elements.Length;

	bLocked = (StashBox != None);

	// 规则：
	// 1) i < stashCount：显示 Open 按钮
	// 2) i == stashCount：显示 Make 按钮，且可点击（仅这一格可点）
	// 3) i > stashCount：显示 Make 按钮，但置灰（不可点）
	for ( i = 0; i < MaxStashDisplayCount; i++ )
	{
		makeId = GetMakeStashButtonIdByIndex(i);
		openId = GetOpenStashButtonIdByIndex(i);

		if ( makeId < Components.Length )
		{
			Components[makeId].bVisible = (stashCount < (i + 1)); // 没有该仓库才显示 Make
			if ( Components[makeId].bVisible )
			{
				if ( bLocked )
					Components[makeId].bDisabled = True;
				else
					Components[makeId].bDisabled = (i != stashCount); // 仅下一格可点
			}
		}

		if ( openId < Components.Length )
		{
			Components[openId].bVisible = (stashCount >= (i + 1)); // 已有该仓库才显示 Open
			if ( Components[openId].bVisible )
				Components[openId].bDisabled = bLocked;
		}
	}
}

function RefuseShare()	// modified by yj
{
	// 取消共享仓库：不再处理取消共享
}

function OnPreRender(Canvas C)
{
	if ( NpcPawn.Controller == None )
	{
		if ( StashBox != None )
			CloseStashBox();

		Parent.NotifyInterface(Self, INT_Close);
		return;
	}

	Components[8].bDisabled = (StashBox != None) || (SelectedStashId == -1) || (Bank.Stashes.Length == 0);
	Components[7].bDisabled = (StashBox != None) || (SelectedStashId == -1) || (Bank.Stashes.Length == 0);

	if ( MyStashes != None )
		MyStashes.bReadOnly = (StashBox != None);

	C.SetRenderStyleAlpha();
	C.SetPos(Components[1].X, Components[1].Y);

	if ( Bank.bClanBank )
	{
		VisibleComponent(Components[3], False);
		VisibleComponent(Components[4], True);
		C.DrawTile(TextureResources[1].Resource, Components[2].XL, Components[2].YL, 0, 0, Components[2].XL, Components[2].YL);
	}
	else
	{
		VisibleComponent(Components[3], True);
		VisibleComponent(Components[4], False);
		C.DrawTile(TextureResources[0].Resource, Components[1].XL, Components[1].YL, 0, 0, Components[1].XL, Components[1].YL);
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X, Y;
	local color OldColor;

	C.DrawColor = OldColor;

	X = Components[0].X;
	Y = Components[0].Y;

	DrawTitle(C, m_sTitle);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

	if ( Bank.bClanBank )
	{
		C.DrawKoreanText(Localize("Terms", "ClanStash", "Sephiroth"), X + 25, Y + 38, 144, 14);
	}
	else
	{
		C.DrawKoreanText(Localize("Terms", "MyStash", "Sephiroth"), X + 25, Y + 37, 144, 14);
	}

	C.DrawColor = OldColor;
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
}

function int GetSelectedStash(int StartX, int StartY, int Width, int Height, int StepHeight, int StartIndex, out int StashIndex)
{
	local int HotX, HotY;
	local int LocalIndex;

	HotX = PlayerOwner.Player.WindowsMouseX - StartX;
	HotY = PlayerOwner.Player.WindowsMouseY - StartY;

	if ( HotX < 0 || HotX > Width || HotY < 0 || HotY > Height )
		return -1;

	LocalIndex = HotY / StepHeight;

	if ( StartIndex + LocalIndex > Bank.Stashes.Length )
		return -1;

	StashIndex = StartIndex + LocalIndex;

	if ( StashIndex >= 0 && StashIndex < Bank.Stashes.Length )
		return Bank.Stashes[StashIndex].Id;

	return -1;
}

function Bank.Deposit GetStash(int Id)
{
	local int i;

	for ( i = 0; i < Bank.Stashes.Length; i++ )
		if ( Bank.Stashes[i].Id == Id )
			return Bank.Stashes[i];

	return ConstStash;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if ( Key == IK_Escape && Action == IST_Press )
	{
		if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		else
		{
			if ( StashBox != None )
				class'CMessageBox'.Static.MessageBox(Self, "CloseStash", Localize("Modals", "StashClose", "Sephiroth"), MB_YesNo, IDM_CloseLobby);
			else
				Parent.NotifyInterface(Self, INT_Close);
		}

		return True;
	}

	if ( Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]) )
		return True;

	return False;
}

function bool Stash_DoubleClick()
{
	if ( StashBox == None && SelectedStashId != -1 )
	{
		OpenStash();
		return True;
	}
	return False;
}

function NotifyScrollUp(int CmpId, int Amount)
{
	ScrollUpStashList();
}

function NotifyScrollDown(int CmpId, int Amount)
{
	ScrollDownStashList();
}

function ScrollUpStashList()
{
	DisplayStartIndex = max(DisplayStartIndex - 1, 0);
}

function ScrollDownStashList()
{
	DisplayStartIndex = min(DisplayStartIndex + 1, Bank.Stashes.Length - DisplayedStashCount);
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	local int Index;

	switch (NotifyId)
	{
		case BN_Exit:
			Controller.ResetDragAndDropAll();

			if ( StashBox != None )
				class'CMessageBox'.Static.MessageBox(Self, "CloseStash", Localize("Modals", "StashClose", "Sephiroth"), MB_YesNo, IDM_CloseLobby);
			else
				Parent.NotifyInterface(Self, INT_Close);

			break;

		case BN_Make:
			MakeStash();
			break;

		case BN_Open:
			if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
				SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);

			if ( StashBox != None )
			{
				class'CMessageBox'.Static.MessageBox(Self, "CloseStash", Localize("Modals", "StashClose", "Sephiroth"), MB_YesNo, IDM_CloseStash);
			}
			else
			{
				if ( !TryGetMyStashIndexByOpenButtonCmpId(CmpId, Index) )
					return;

				if ( Index < 0 || MyStashes == None || Index >= MyStashes.Elements.Length )
					return;

				InternalSelectMyStash(Index, "");
				OpenStash();
			}
			break;

		case BN_Open_Shared:
			break;

		case BN_Share:
			break;

		case BN_Unshare:
			break;

		case BN_Return:
			ReturnStash();
			break;
	}
}

function MakeStash()
{
	class'CEditBox'.Static.EditBox(Self, "MakeStash", Localize("Modals", "StashMake", "Sephiroth"), IDS_MakeStash, 20);
}

function OpenStash()
{
	class'CMessageBox'.Static.MessageBox(Self, "OpenStash", Localize("Modals", "StashOpen", "Sephiroth"), MB_YesNo, IDM_OpenStash);
}

function ShareStash()
{
	StashShare = StashShare(AddInterface("SephirothUI.StashShare", True));
	if ( StashShare != None )
		StashShare.ShowInterface();
}

function RefuseStashShare()
{
	if ( SelectedStash.Shared == 1 )
	{
		SephirothPlayer(PlayerOwner).Net.NotiStashShareRefuse(SelectedStash.Id);
		SelectedIndex = -1;
		SelectedStashId = -1;
	}
}

function MakeButtonsDisabled()
{
	local int i;
	local int makeId, openId;

	for ( i = 0; i < MaxStashDisplayCount; i++ )
	{
		makeId = GetMakeStashButtonIdByIndex(i);
		openId = GetOpenStashButtonIdByIndex(i);

		if ( makeId < Components.Length )
			Components[makeId].bDisabled = True;

		if ( openId < Components.Length )
			Components[openId].bDisabled = True;
	}
}

function MakeButtonsEnabled()
{
	// 重新按“依次开设”规则刷新（并启用 Open 按钮）
	MakeStashMakeButton();
}

function ReturnStash()
{
	class'CEditBox'.Static.EditBox(Self, "ReturnStash", "["$SelectedStash.Name$"]"@Localize("Modals", "StashTrash", "Sephiroth"), IDS_ReturnStash, 24,, True);
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Value;

	if ( NotifyType == INT_MessageBox )
	{
		Value = int(Command);
		switch (Value)
		{
			case IDM_MakeStash:
				if ( CandidateStashName != "" )
					SephirothPlayer(PlayerOwner).Net.NotiStashNew(CandidateStashName);

				SelectedStashId = -1;
				CandidateStashName = "";
				MakeStashMakeButton();
				break;

			case IDM_OpenStash:
				SephirothPlayer(PlayerOwner).Net.NotiStashOpen(SelectedStashId);
				MakeButtonsDisabled();
				break;

			case IDM_CloseStash:
				CloseStashBox();
				MakeButtonsEnabled();
				break;

			case IDM_CloseLobby:
				CloseStashBox();
				Parent.NotifyInterface(Self, INT_Close);
				break;

			case IDM_RefuseShare:
				break;
		}
	}
	else if (NotifyType == INT_Close)
	{
		if ( Command == "ByEscape" && SephirothInterface(Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
		else if (Interface == Bag || Interface == StashBox)
			class'CMessageBox'.Static.MessageBox(Self, "CloseStash", Localize("Modals", "StashClose", "Sephiroth"), MB_YesNo, IDM_CloseStash);
		else if (Interface == StashShare)
		{
			StashShare.HideInterface();
			RemoveInterface(StashShare);
			StashShare = None;
		}
	}
	else if (NotifyType == INT_Command && Command == "ClearInfo")
	{
		if ( SephirothInterface(Parent).ItemTooltipBox.Source != None )
			SephirothInterface(Parent).ItemTooltipBox.SetInfo(None);
	}
}

function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	local int i;

	if ( NotifyId == IDS_MakeStash && EditText != "" )
	{
		for ( i = 0; i < Bank.Stashes.Length; i++ )
			if ( Bank.Stashes[i].Name == EditText && Bank.Stashes[i].Shared == 0 )
				break;

		if ( i < Bank.Stashes.Length )
		{
			class'CEditBox'.Static.EditBox(Self, "MakeStash", Localize("Modals", "CannotCreateSameStash", "Sephiroth"), IDS_MakeStash, 20);
			return;
		}

		CandidateStashName = EditText;
		class'CMessageBox'.Static.MessageBox(
			Self,
			"MakeStash",
			Localize("Modals", "StashMake1", "Sephiroth")@Controller.MoneyStringEx(string(Bank.InstallFee))$" "$Localize("Modals", "StashMake2", "Sephiroth"),
			MB_YesNo,
			IDM_MakeStash
		);
	}
	else if (NotifyId == IDS_ReturnStash && EditText != "")
	{
		if ( EditText == Localize("Modals", "StashTrashConfirm", "Sephiroth") )
		{
			SephirothPlayer(PlayerOwner).Net.NotiStashTrash(SelectedStashId);
			SelectedStashId = -1;
			MakeStashMakeButton();
		}
		else
		{
			class'CMessageBox'.Static.MessageBox(Self, "WrongInput", Localize("Modals", "WrongInput", "Sephiroth"), MB_YesNo, IDM_ReturnStash);
		}
	}
}

function CloseStashBox()
{
	if ( Bag != None )
	{
		Bag.HideInterface();
		RemoveInterface(Bag);
		Bag = None;
	}

	if ( StashBox != None )
	{
		StashBox.HideInterface();
		RemoveInterface(StashBox);
		StashBox = None;
	}

	SephirothPlayer(PlayerOwner).Net.NotiStashDismissBox(SelectedStashId);
}

function OpenStashBox()
{
	StashBox = CStashBox(AddInterface("SephirothUI.CStashBox"));
	if ( StashBox != None )
		StashBox.ShowInterface();

	Bag = CBag(AddInterface("SephirothUI.CBag"));
	if ( Bag != None )
		Bag.ShowInterface();

	StashBox.OffsetXL = 282;
	Bag.OffsetXL = 279 + 282;
}

function Render(Canvas C)
{
	local CInterface theInterface;
	local SephirothInterface MainHud;

	Super.Render(C);

	MainHud = SephirothInterface(Parent);
	theInterface = MainHud.ITopOnCursor;

	if ( theInterface == None )
	{
		MainHud.ItemTooltipBox.SetInfo(None);
		return;
	}

	if ( theInterface == Bag )
		Bag.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if (CStashBox(theInterface) != None)
		StashBox.ShowItemInfo(C, MainHud.ItemTooltipBox);
	else if (CBagResizable(theInterface) != None)
		CBagResizable(theInterface).ShowItemInfo(C, MainHud.ItemTooltipBox);
	else
		MainHud.ItemTooltipBox.SetInfo(None);
}

function UpdateStashInfo(int StashId)
{
	if ( StashId == SelectedStashId && StashShare != None )
		StashShare.UpdateContents(StashId);
}

function InternalDrawMyStashText(Canvas C, int Index, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string ColorCode;

	if ( Index == SelectedIndex )
	{
		if ( bSelected )
			ColorCode = MakeColorCodeEx(255,255,127);
		else
		{
			ColorCode = MakeColorCodeEx(255,219,93);
			C.SetRenderStyleAlpha();
			C.SetPos(X, Y);
			C.DrawTile(TextureResources[14].Resource, 177, 22, 0, 0, 177, 22);
		}
	}
	else
	{
		C.SetRenderStyleAlpha();
		C.SetPos(X, Y);
		C.DrawTile(TextureResources[11].Resource, 177, 22, 0, 0, 177, 22);
	}

	C.DrawTextJustified(ColorCode$Text, 1, X, Y + 5, X + W, Y + H);
}

function string InternalTooltipOtherStash(int Index, string Text)
{
	return Bank.Stashes[Index + MyStashCount].Owner;
}

function InternalDrawMyStashSelectedBK(Canvas C, float X, float Y, float Width, float Height, bool bSelected)
{
	C.SetRenderStyleAlpha();
	C.SetPos(X, Y);
	C.DrawTile(TextureResources[14].Resource, 177, 22, 0, 0, 177, 22);
}

function InternalDrawOtherStashSelectedBK(Canvas C, float X, float Y, float Width, float Height, bool bSelected)
{
	C.SetRenderStyleAlpha();
	C.SetPos(X, Y);
	C.DrawTile(TextureResources[14].Resource, 177, 22, 0, 0, 177, 22);
}

function InternalSelectMyStash(int Index, string Text)
{
	local int bankIndex;

	if ( !TryGetBankStashIndexByMyListIndex(Index, bankIndex) )
		return;

	SelectedStashIndex = Index;
	SelectedStashId = Bank.Stashes[bankIndex].Id;
	SelectedStashName = Bank.Stashes[bankIndex].Name;
	SelectedStash = Bank.Stashes[bankIndex];
	SelectedIndex = Index;
}

function InternalSelectOtherStash(int Index, string Text)
{
	// 取消共享仓库：不处理
}

function bool IsCursorInsideInterface()
{
	if ( IsCursorInsideComponent(Components[0]) ||
		(Bag != None && Bag.IsCursorInsideInterface()) ||
		(StashBox != None && StashBox.IsCursorInsideInterface()) ||
		(StashShare != None && StashShare.IsCursorInsideInterface()) ||
		(SubSelectBox != None && SubSelectBox.IsCursorInsideInterface()) )
	{
		return True;
	}

	return False;
}

defaultproperties
{
	SelectedStashId=-1
	SelectedIndex=-1
	SelectedTextColor=(B=127,G=255,R=255,A=255)
	Components(0)=(XL=286.000000,YL=399.000000)
	Components(1)=(Id=1,XL=286.000000,YL=399.000000,PivotDir=PVT_Copy)
	Components(2)=(Id=2,XL=266.000000,YL=229.000000,PivotDir=PVT_Copy)
	Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=256.000000,OffsetYL=14.000000)
	Components(4)=(Id=4,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotId=2,PivotDir=PVT_Copy,OffsetXL=237.000000,OffsetYL=14.000000)
	Components(5)=(Id=5,Type=RES_PushButton,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=252.000000)
	Components(6)=(Id=6,Caption="UnshareStash",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=145.000000,OffsetYL=352.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(7)=(Id=7,Caption="ReturnStash",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=145.000000,OffsetYL=352.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(9)=(Id=9)

	Components(12)=(Id=12,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotDir=PVT_Copy,OffsetXL=20.000000,OffsetYL=58.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(13)=(Id=13,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=12,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(14)=(Id=14,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=13,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(15)=(Id=15,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=14,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(16)=(Id=16,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=15,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	Components(17)=(Id=17,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=12,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(18)=(Id=18,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=13,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(19)=(Id=19,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=14,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(20)=(Id=20,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=15,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(21)=(Id=21,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=16,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	Components(22)=(Id=22,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=16,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(23)=(Id=23,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=22,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(24)=(Id=24,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=23,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(25)=(Id=25,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=24,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(26)=(Id=26,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=25,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	Components(27)=(Id=27,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=22,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(28)=(Id=28,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=23,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(29)=(Id=29,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=24,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(30)=(Id=30,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=25,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(31)=(Id=31,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=26,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	// ======== 新增：第 11、12 个仓库（Make 32-33 / Open 34-35）========
	Components(32)=(Id=32,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=26,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(33)=(Id=33,Caption="MakeStash",Type=RES_PushButton,XL=225.000000,YL=22.000000,PivotId=32,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	Components(34)=(Id=34,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=32,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
	Components(35)=(Id=35,Caption="OpenStash_",Type=RES_PushButton,XL=48.000000,YL=22.000000,PivotId=33,PivotDir=PVT_Copy,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)

	TextureResources(0)=(Package="UI_2011",Path="win_keep_1",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011",Path="win_keep_3",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011_btn",Path="btn_keep_n",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011_btn",Path="btn_keep_co",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011_btn",Path="btn_keep_c",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="btn_keep_o",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="btn_keep_s_n",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2011_btn",Path="btn_keep_s_co",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2011_btn",Path="btn_keep_s_c",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2011_btn",Path="btn_keep_s_o",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2011_btn",Path="btn_open_n",Style=STY_Alpha)
	TextureResources(16)=(Package="UI_2011_btn",Path="BTN08_03_D",Style=STY_Alpha)
	TextureResources(17)=(Package="UI_2011_btn",Path="btn_open_c",Style=STY_Alpha)
	TextureResources(18)=(Package="UI_2011_btn",Path="btn_open_o",Style=STY_Alpha)
	TextureResources(19)=(Package="UI_2009",Path="BTN08_04_N",Style=STY_Alpha)
	TextureResources(20)=(Package="UI_2009",Path="BTN08_04_D",Style=STY_Alpha)
	TextureResources(21)=(Package="UI_2009",Path="BTN08_04_P",Style=STY_Alpha)
	TextureResources(22)=(Package="UI_2009",Path="BTN08_04_O",Style=STY_Alpha)
	TextureResources(23)=(Package="UI_2009",Path="BTN01_01_P",Style=STY_Alpha)
}
