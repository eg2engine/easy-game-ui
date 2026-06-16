class Forge extends CMultiInterface;

const BN_Exit    = 0;
const BN_Make    = 99;

const BN_OneHand = 1;
const BN_Bare    = 2;
const BN_Red     = 3;
const BN_Bow     = 4;
const BN_Blue    = 5;

const BN_Weapon  = 6;
const BN_Helmet  = 7;
const BN_Armor   = 8;
const BN_Vambrace= 9;
const BN_Boots   =10;
const BN_Shield  =11;

const BN_Recipe  =12;
const BN_Obj1    =13;
const BN_Obj2    =14;
const BN_Obj3    =15;
const BN_Obj4    =16;
const BN_Obj5    =17;
const BN_Obj6    =18;
const BN_Obj7    =19;
const BN_Obj8    =20;
const BN_Obj9    =21;
const BN_Obj10   =22;
const BN_Obj11   =23;
const BN_Obj12   =24;
const BN_Obj13   =25;
const BN_Obj14   =26;
const BN_Obj15   =27;
const BN_Obj16   =28;
const BN_Obj17   =29;
const BN_Obj18   =30;
const BN_Obj19   =31;
const BN_Obj20   =32;
const BN_Obj21   =33;
const BN_Obj22   =34;
const BN_Obj23   =35;

const CMP_Recipe =16;
const DetailLineHeight =13;

var string m_sTitle;
var CImeEdit Edit;
var SephirothInventory SepInventory;
var GameCustomCmdManager CustomCmd;

var int nAlpha;
var bool bAlphaDir;

var bool OnJob;
var int SelectJob;
var bool OnPart;
var int SelectPart;
var bool OnRecipe;
var int SelectRecipe;
var bool OnMake;
var int MakeItemIndex;
var int MakeItemNum;

var array<int> HavePics;
var array<int> NeedPics;
var array<string> MakeListName;
var array<int> MakeListNeedPics;
var array<int> MakeListHavePics;
var array<Texture> IconList;
var Texture RecipeBtn;
var bool bComplate;
var string teststring;

var int RequestSeq;
var int LastJobVersion;
var int LastProductVersion;
var int LastDetailVersion;
var int LastPreviewVersion;
var int LastCraftResultVersion;
var int LastUIStateVersion;
var int SelectJobIndex;
var int SelectProductIndex;
var int SelectDetailLineIndex;
var string SelectedProductTitle;
var string SelectedMakeTarget;
var int MaxDetailLines;
var int MaxPreviewLines;

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;

	if (TextureName == "")
		return None;

	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if (T != None) {
		for (i=0;i<IconList.Length;i++)
			if (T == IconList[i])
				break;
		if (i == IconList.Length) {
			T.AddReference();
			IconList[i] = T;
		}
	}
	return T;
}

final function FlushDynamicTextures()
{
	local int i,count;

	count = IconList.Length;
	for (i=0;i<IconList.Length;i++) {
		if (IconList[i] != None) {
			UnloadTexture(Viewport(PlayerOwner.Player),IconList[i]);
		}
	}
	IconList.Remove(0,count);
}

function OnInit()
{
	local int i;

	SepInventory = SephirothPlayer(PlayerOwner).PSI.SepInventory;
	SepInventory.OnUpdateItem = InternalUpdateItem;
	CustomCmd = GameManager(Level.Game).GameCustomCmdManager;

	SetComponentNotify(Components[3], BN_Exit ,Self);
	SetComponentTextureId(Components[3],1,-1,1,2);
	SetComponentNotify(Components[4], BN_Make ,Self);
	SetComponentTextureId(Components[4],3,-1,5,4);

	SetComponentNotify(Components[5],BN_OneHand,Self);
	SetComponentNotify(Components[6],BN_Bare   ,Self);
	SetComponentNotify(Components[7],BN_Red    ,Self);
	SetComponentNotify(Components[8],BN_Bow    ,Self);
	SetComponentNotify(Components[9],BN_Blue   ,Self);

	SetComponentNotify(Components[10],BN_Weapon  ,Self);
	SetComponentNotify(Components[11],BN_Helmet  ,Self);
	SetComponentNotify(Components[12],BN_Armor   ,Self);
	SetComponentNotify(Components[13],BN_Vambrace,Self);
	SetComponentNotify(Components[14],BN_Boots   ,Self);
	SetComponentNotify(Components[15],BN_Shield  ,Self);

	for(i=10; i<16; i++)
		Components[i].bVisible = false;

	SetComponentNotify(Components[16],BN_Recipe,Self);
	SetComponentNotify(Components[17],BN_Obj1  ,Self);
	SetComponentNotify(Components[18],BN_Obj2  ,Self);
	SetComponentNotify(Components[19],BN_Obj3  ,Self);
	SetComponentNotify(Components[20],BN_Obj4  ,Self);
	SetComponentNotify(Components[21],BN_Obj5  ,Self);
	SetComponentNotify(Components[22],BN_Obj6  ,Self);
	SetComponentNotify(Components[23],BN_Obj7  ,Self);
	SetComponentNotify(Components[24],BN_Obj8  ,Self);
	SetComponentNotify(Components[25],BN_Obj9  ,Self);
	SetComponentNotify(Components[26],BN_Obj10 ,Self);
	SetComponentNotify(Components[27],BN_Obj11 ,Self);
	SetComponentNotify(Components[28],BN_Obj12 ,Self);
	SetComponentNotify(Components[29],BN_Obj13 ,Self);
	SetComponentNotify(Components[30],BN_Obj14 ,Self);
	SetComponentNotify(Components[31],BN_Obj15 ,Self);
	SetComponentNotify(Components[32],BN_Obj16 ,Self);
	SetComponentNotify(Components[33],BN_Obj17 ,Self);
	SetComponentNotify(Components[34],BN_Obj18 ,Self);
	SetComponentNotify(Components[35],BN_Obj19 ,Self);
	SetComponentNotify(Components[36],BN_Obj20 ,Self);
	SetComponentNotify(Components[37],BN_Obj21 ,Self);
	SetComponentNotify(Components[38],BN_Obj22 ,Self);
	SetComponentNotify(Components[39],BN_Obj23 ,Self);

	for(i=16; i<40; i++)
		Components[i].bVisible = false;

	Components[16].bDisabled = true;
	Components[4].bDisabled = true;

	Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (Edit != None)
	{
		Edit.bNative = True;
		Edit.bMaskText = False;
		Edit.SetMaxWidth(2);
		Edit.SetSize(153,18);
		Edit.SetText("");
		Edit.ShowInterface();
		Edit.SetFocusEditBox(true);
	}

	nAlpha = 155;
	bAlphaDir = false;
	OnJob = true;
	SelectJobIndex = -1;
	SelectProductIndex = -1;
	SelectDetailLineIndex = -1;
	SelectedProductTitle = "";
	SelectedMakeTarget = "";
	MaxDetailLines = 24;
	MaxPreviewLines = 8;
	HavePics.Length = MaxDetailLines;
	NeedPics.Length = MaxDetailLines;

	RecipeBtn = Texture(DynamicLoadObject("UI.Compound.Lv12Mix_Button00", class'Texture'));
	m_sTitle = Localize("Smithy","Smith","Sephiroth");
	RequestJobList();
}

function OnFlush()
{
	FlushDynamicTextures();

	if (Edit != None) {
		Edit.SetFocusEditBox(false);
		Edit.HideInterface();
		RemoveInterface(Edit);
		Edit = None;
	}
}

function Layout(Canvas C)
{
	local float X,Y;
	local int i, j, l, r;
	local int JobButtonX, JobButtonY, SelBtnX, SelBtnY, RecipeBtnX, RecipeBtnY;

	MoveComponentId(0,true,C.ClipX-Components[0].XL,0);
	for(i=1; i<=2; i++)
		MoveComponentId(i);

	X = Components[0].X;
	Y = Components[0].Y;

	MoveComponentId(3, false);
	MoveComponentId(4, false);

	JobButtonX = X + 315;
	JobButtonY = Y + 54;
	for(j=5; j<10; j++)
		MoveComponentId(j, true, JobButtonX, JobButtonY + ((j-5)*14));

	SelBtnX = X + 315;
	SelBtnY = Y + 138;
	for(l=10; l<16; l++)
		MoveComponentId(l, true, SelBtnX, SelBtnY + ((l-10)*14));

	RecipeBtnX = X + 21;
	RecipeBtnY = Y + 53;
	for(r=16; r<40; r++)
		MoveComponentId(r, true, RecipeBtnX, RecipeBtnY + ((r-16)*DetailLineHeight));

	if (Edit != None)
		Edit.SetPos(Components[0].X + 365, Components[0].Y + 344);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int Index;

	switch (NotifyId)
	{
	case BN_Exit:
		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_Make:
		MakeItemNum = int(Edit.GetText());
		if(OnMake && MakeItemNum > 0 && SelectedMakeTarget != "" && CustomCmd != None)
			CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_AdvancedSynthesis_Craft, MakeItemNum, 0, SelectedMakeTarget);
		break;

	case BN_OneHand:
	case BN_Bare:
	case BN_Red:
	case BN_Bow:
	case BN_Blue:
		Index = NotifyId - BN_OneHand;
		if(CustomCmd == None || Index < 0 || Index >= CustomCmd.AdvancedSynthesisJobs.Length)
			break;

		OnJob = false;
		OnPart = true;
		OnRecipe = false;
		OnMake = false;
		SelectJob = NotifyId;
		SelectJobIndex = Index;
		SelectProductIndex = -1;
		SelectDetailLineIndex = -1;
		SelectedProductTitle = "";
		SelectedMakeTarget = "";
		OffRecipeFrame();
		OffMakeFrame();
		FlushDynamicTextures();
		RequestProductList(CustomCmd.AdvancedSynthesisJobs[Index].Id);
		break;

	case BN_Weapon:
	case BN_Helmet:
	case BN_Armor:
	case BN_Vambrace:
	case BN_Boots:
	case BN_Shield:
		Index = NotifyId - BN_Weapon;
		if(CustomCmd == None || Index < 0 || Index >= CustomCmd.AdvancedSynthesisProducts.Length)
			break;

		OnPart = false;
		OnRecipe = true;
		OnMake = false;
		SelectPart = NotifyId;
		SelectProductIndex = Index;
		SelectDetailLineIndex = -1;
		SelectedProductTitle = CustomCmd.AdvancedSynthesisProducts[Index].Title;
		SelectedMakeTarget = "";
		OffMakeFrame();
		FlushDynamicTextures();
		RequestRecipeDetail(SelectedProductTitle);
		break;

	case BN_Recipe:
	case BN_Obj1:
	case BN_Obj2:
	case BN_Obj3:
	case BN_Obj4:
	case BN_Obj5:
	case BN_Obj6:
	case BN_Obj7:
	case BN_Obj8:
	case BN_Obj9:
	case BN_Obj10:
	case BN_Obj11:
	case BN_Obj12:
	case BN_Obj13:
	case BN_Obj14:
	case BN_Obj15:
	case BN_Obj16:
	case BN_Obj17:
	case BN_Obj18:
	case BN_Obj19:
	case BN_Obj20:
	case BN_Obj21:
	case BN_Obj22:
	case BN_Obj23:
		Index = CmpId - CMP_Recipe;
		if(CustomCmd == None || Index < 0 || Index >= CustomCmd.AdvancedSynthesisDetailLines.Length)
			break;
		if(Index == 0)
		{
			OnMake = true;
			SelectRecipe = 0;
			SelectDetailLineIndex = 0;
			SelectedMakeTarget = CustomCmd.AdvancedSynthesisDetailLines[0].Title;
			CustomCmd.AdvancedSynthesisPreviewLines.Remove(0, CustomCmd.AdvancedSynthesisPreviewLines.Length);
			break;
		}
		if(CustomCmd.AdvancedSynthesisDetailLines[Index].CanCraft != 1)
			break;

		OnMake = true;
		SelectRecipe = Index;
		SelectDetailLineIndex = Index;
		SelectedMakeTarget = CustomCmd.AdvancedSynthesisDetailLines[Index].Title;
		RequestMakePreview(SelectedMakeTarget);
		break;
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if(!IsCursorInsideInterface())
		return false;
}

function OnPreRender(Canvas C)
{
	local float X, Y;

	X = Components[0].X;
	Y = Components[0].Y;

	if(CustomCmd == None)
		CustomCmd = GameManager(Level.Game).GameCustomCmdManager;
	SyncAdvancedSynthesisData();

	if(bAlphaDir == true)
	{
		if(nAlpha > 155)
			nAlpha -= 10;
		else
			bAlphaDir = false;
	}
	else
	{
		if(nAlpha < 255)
			nAlpha += 10;
		else
			bAlphaDir = true;
	}

	SepInventory.UpdateItems();

	Components[4].bDisabled = true;
	if(OnMake && Edit != None)
	{
		MakeItemNum = int(Edit.GetText());
		Components[4].bDisabled = !(SelectedMakeTarget != "" && MakeItemNum > 0);
	}

	if(Edit != None && IsCursorInsideAt(Components[0].X + 365, Components[0].Y + 344, 153, 18))
		if(!Edit.bHasFocus)
			Edit.SetFocusEditBox(true);

	if(Edit != None && IsCursorInsideComponent(Components[4]))
		Edit.SetFocusEditBox(false);

	DrawBackGround3x3(C, 64, 64, 6, 7, 8, 9, 10, 11, 12, 13, 14);
	DrawTitle(C, m_sTitle);

	if(OnJob)
	{
		C.SetDrawColor(0, nAlpha, 0);
		C.SetPos(X + 311, Y + 39);
		C.DrawRect1Fix(191, 85);
	}
	else if(OnPart)
	{
		C.SetDrawColor(0, nAlpha, 0);
		C.SetPos(X + 311, Y + 123);
		C.DrawRect1Fix(191, 100);
		if(SelectJobIndex >= 0)
		{
			C.SetDrawColor(nAlpha, 188, 63, 63);
			C.SetPos(X + 315, Y + 52 + (SelectJobIndex*14));
			C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);
		}
	}
	else if(OnRecipe)
	{
		C.SetDrawColor(0, nAlpha, 0);
		C.SetPos(X + 17, Y + 37);
		C.DrawRect1Fix(288, 332);
		if(SelectProductIndex >= 0)
		{
			C.SetDrawColor(nAlpha, 188, 63, 63);
			C.SetPos(X + 315, Y + 136 + (SelectProductIndex*14));
			C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);
		}
		if(SelectJobIndex >= 0)
		{
			C.SetPos(X + 315, Y + 52 + (SelectJobIndex*14));
			C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);
		}
	}

	C.SetDrawColor(255,255,255);
}

function SetDetailLineDrawColor(Canvas C, int Index)
{
	local int Have, Need;

	if(CustomCmd == None || Index < 0 || Index >= CustomCmd.AdvancedSynthesisDetailLines.Length)
	{
		C.SetDrawColor(255, 255, 255);
		return;
	}

	if(Index == 0)
	{
		C.SetDrawColor(241, 215, 113);
		return;
	}

	Need = CustomCmd.AdvancedSynthesisDetailLines[Index].NeedCount;
	Have = GetSmithHaveCount(
		CustomCmd.AdvancedSynthesisDetailLines[Index].ItemClassName,
		CustomCmd.AdvancedSynthesisDetailLines[Index].NeedSource
	);

	if(Have >= Need)
	{
		C.SetDrawColor(71, 129, 186);
	}
	else if(CustomCmd.AdvancedSynthesisDetailLines[Index].CanCraft == 1)
	{
		C.SetDrawColor(255, 180, 64);
	}
	else
	{
		C.SetDrawColor(237, 51, 41);
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local float X, Y;
	local int i, Count, Have, Need, Qty;
	local string DescText;
	local array<string> DescLines;

	X = Components[0].X;
	Y = Components[0].Y;

	if(CustomCmd != None && OnRecipe)
	{
		Count = Min(CustomCmd.AdvancedSynthesisDetailLines.Length, MaxDetailLines);
		C.KTextFormat = ETextAlign.TA_MiddleLeft;
		for(i=0; i<Count; i++)
		{
			SetDetailLineDrawColor(C, i);
			C.DrawKoreanText(
				GetDetailTreeTitle(i),
				Components[i + CMP_Recipe].X,
				Components[i + CMP_Recipe].Y,
				Components[i + CMP_Recipe].XL,
				Components[i + CMP_Recipe].YL
			);
		}

		C.KTextFormat = ETextAlign.TA_MiddleRight;
		for(i=1; i<Count; i++)
		{
			Need = CustomCmd.AdvancedSynthesisDetailLines[i].NeedCount;
			if(Need > 0)
			{
				Have = GetSmithHaveCount(
					CustomCmd.AdvancedSynthesisDetailLines[i].ItemClassName,
					CustomCmd.AdvancedSynthesisDetailLines[i].NeedSource
				);
				SetDetailLineDrawColor(C, i);
				C.DrawKoreanText("" $ Have $ "/" $ Need, X + 21, Y + 53 + (i*DetailLineHeight), 274, 14);
			}
		}

	}

	if(CustomCmd != None && OnMake)
	{
		Qty = MakeItemNum;
		if(Qty <= 0)
			Qty = 1;
		if(SelectDetailLineIndex == 0 && CustomCmd.AdvancedSynthesisDetailLines.Length > 0)
		{
			DescText = CustomCmd.AdvancedSynthesisDetailLines[0].Desc;
			if(DescText != "")
			{
				C.SetDrawColor(255, 255, 255);
				C.KTextFormat = ETextAlign.TA_MiddleLeft;
				C.WrapStringToArray(DescText, DescLines, 10000, "|");
				Count = Min(DescLines.Length, MaxPreviewLines);
				for(i=0; i<Count; i++)
					C.DrawKoreanText(DescLines[i], X + 315, Y + 236 + (i*14), 180, 15);
			}
		}
		else
		{
			Count = Min(CustomCmd.AdvancedSynthesisPreviewLines.Length, MaxPreviewLines);
			for(i=0; i<Count; i++)
			{
				C.SetDrawColor(255, 255, 255);
				C.KTextFormat = ETextAlign.TA_MiddleLeft;
				C.DrawKoreanText(CustomCmd.AdvancedSynthesisPreviewLines[i].Title, X + 315, Y + 236 + (i*14), 90, 15);

				Need = CustomCmd.AdvancedSynthesisPreviewLines[i].NeedCount * Qty;
				Have = GetSmithHaveCount(
					CustomCmd.AdvancedSynthesisPreviewLines[i].ItemClassName,
					CustomCmd.AdvancedSynthesisPreviewLines[i].NeedSource
				);
				if(Have >= Need)
					C.SetDrawColor(71, 129, 186);
				else
					C.SetDrawColor(237, 51, 41);

				C.KTextFormat = ETextAlign.TA_MiddleRight;
				C.DrawKoreanText(Have $ "/" $ Need, X + 315, Y + 236 + (i*14), 180, 14);
			}
		}

		if(SelectDetailLineIndex >= 0)
		{
			C.SetDrawColor(237, 23, 124);
			C.SetPos(X + 21, Y + 53 + (SelectDetailLineIndex*DetailLineHeight));
			C.DrawRect1Fix(280, DetailLineHeight);
		}
	}

	C.SetDrawColor(231, 202, 174);
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.DrawKoreanText(Localize("Smithy","Recipe","Sephiroth"), X + 21, Y + 38, 187, 14);
	C.DrawKoreanText(Localize("Smithy","HaveNeed","Sephiroth"), X + 208, Y + 38, 101, 14);
	C.DrawKoreanText(Localize("Smithy","Job","Sephiroth"), X + 315, Y + 38, 190, 14);
	C.DrawKoreanText(Localize("Smithy","Part","Sephiroth"), X + 315, Y + 123, 190, 14);
	C.DrawKoreanText(Localize("Smithy","Stuff","Sephiroth"), X + 315, Y + 221, 80, 14);
	C.DrawKoreanText(Localize("Smithy","HaveNeed","Sephiroth"), X + 398, Y + 221, 100, 14);
	C.DrawKoreanText(Localize("Smithy","Num","Sephiroth"), X + 314, Y + 344, 46, 14);
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
}

function InternalUpdateItem(SephirothItem Item)
{
}

function RequestJobList()
{
	if(CustomCmd == None)
		return;
	++RequestSeq;
	CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_AdvancedSynthesis_RequestJobList, RequestSeq, 0, " ");
}

function RequestProductList(int JobId)
{
	if(CustomCmd == None)
		return;
	++RequestSeq;
	CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_AdvancedSynthesis_RequestProductList, RequestSeq, JobId, " ");
}

function RequestRecipeDetail(string ProductTitle)
{
	if(CustomCmd == None || ProductTitle == "")
		return;
	++RequestSeq;
	CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_AdvancedSynthesis_RequestRecipeDetail, RequestSeq, 0, ProductTitle);
}

function RequestMakePreview(string TargetTitle)
{
	if(CustomCmd == None || TargetTitle == "")
		return;
	++RequestSeq;
	CustomCmd.NetNotiCustom(CustomCmd.CMD_C2S_AdvancedSynthesis_RequestMakePreview, RequestSeq, 0, TargetTitle);
}

function SyncAdvancedSynthesisData()
{
	if(CustomCmd == None)
		return;

	if(LastJobVersion != CustomCmd.AdvancedSynthesisJobVersion)
	{
		LastJobVersion = CustomCmd.AdvancedSynthesisJobVersion;
		SetJobFrame();
	}
	if(LastProductVersion != CustomCmd.AdvancedSynthesisProductVersion)
	{
		LastProductVersion = CustomCmd.AdvancedSynthesisProductVersion;
		SetPartFrame();
	}
	if(LastDetailVersion != CustomCmd.AdvancedSynthesisDetailVersion)
	{
		LastDetailVersion = CustomCmd.AdvancedSynthesisDetailVersion;
		SetRecipeFrame(true);
	}
	if(LastPreviewVersion != CustomCmd.AdvancedSynthesisPreviewVersion)
	{
		LastPreviewVersion = CustomCmd.AdvancedSynthesisPreviewVersion;
		SetMakeFrame();
	}
	if(LastCraftResultVersion != CustomCmd.AdvancedSynthesisCraftResultVersion)
	{
		LastCraftResultVersion = CustomCmd.AdvancedSynthesisCraftResultVersion;
		GameManager(Level.Game).PlayerOwner.myHud.AddMessage(3, CustomCmd.AdvancedSynthesisCraftResultMessage, class'Canvas'.Static.MakeColor(255,255,255));
		SepInventory.UpdateItems();
		if(SelectedProductTitle != "")
			RequestRecipeDetail(SelectedProductTitle);
		if(SelectedMakeTarget != "" && SelectDetailLineIndex > 0)
			RequestMakePreview(SelectedMakeTarget);
	}
	if(LastUIStateVersion != CustomCmd.AdvancedSynthesisUIStateVersion)
	{
		LastUIStateVersion = CustomCmd.AdvancedSynthesisUIStateVersion;
		if(!CustomCmd.AdvancedSynthesisUIVisible)
			Parent.NotifyInterface(Self, INT_Close);
	}
}

function SetJobFrame()
{
	local int i;

	for(i=5; i<10; i++)
	{
		if(CustomCmd != None && i-5 < CustomCmd.AdvancedSynthesisJobs.Length)
		{
			Components[i].bVisible = true;
			Components[i].Caption = CustomCmd.AdvancedSynthesisJobs[i-5].Title;
			Components[i].bDisabled = false;
		}
		else
		{
			Components[i].bVisible = false;
			Components[i].Caption = "";
		}
	}
}

function SetPartFrame()
{
	local int i;

	for(i=10; i<16; i++)
	{
		if(CustomCmd != None && i-10 < CustomCmd.AdvancedSynthesisProducts.Length)
		{
			Components[i].bVisible = true;
			Components[i].Caption = CustomCmd.AdvancedSynthesisProducts[i-10].Title;
			Components[i].bDisabled = CustomCmd.AdvancedSynthesisProducts[i-10].CanCraft != 1;
		}
		else
		{
			Components[i].bVisible = false;
			Components[i].Caption = "";
		}
	}
}

function SetRecipeFrame(optional bool bLoad)
{
	local int i, Count;

	for(i=16; i<40; i++)
	{
		Components[i].bVisible = false;
		Components[i].Caption = "";
		Components[i].bDisabled = true;
	}

	if(CustomCmd == None)
		return;

	Count = Min(CustomCmd.AdvancedSynthesisDetailLines.Length, MaxDetailLines);
	for(i=0; i<Count; i++)
	{
		Components[i + CMP_Recipe].bVisible = true;
		Components[i + CMP_Recipe].Caption = "";
		Components[i + CMP_Recipe].bDisabled = CustomCmd.AdvancedSynthesisDetailLines[i].CanCraft != 1;
		NeedPics[i] = CustomCmd.AdvancedSynthesisDetailLines[i].NeedCount;
		HavePics[i] = GetSmithHaveCount(
			CustomCmd.AdvancedSynthesisDetailLines[i].ItemClassName,
			CustomCmd.AdvancedSynthesisDetailLines[i].NeedSource
		);
	}
}

function OffRecipeFrame()
{
	local int i;

	for(i=16; i<40; i++)
		Components[i].bVisible = false;
}

function SetMakeFrame()
{
	Components[4].bDisabled = false;
}

function OffMakeFrame()
{
	SelectedMakeTarget = "";
	SelectDetailLineIndex = -1;
	if(CustomCmd != None)
		CustomCmd.AdvancedSynthesisPreviewLines.Remove(0, CustomCmd.AdvancedSynthesisPreviewLines.Length);
	Components[4].bDisabled = true;
}

function int GetSmithHaveCount(string ItemClassName, optional string NeedSource)
{
	if(NeedSource ~= "wear")
		return GetWearHaveCount(ItemClassName);

	if(ItemClassName == "" || SepInventory == None)
		return 0;
	return SepInventory.GetSmithItemSum(ItemClassName);
}

function int GetWearHaveCount(string ItemClassName)
{
	local int i;
	local WornItems WI;

	if(ItemClassName == "" || SephirothPlayer(PlayerOwner) == None || SephirothPlayer(PlayerOwner).PSI == None)
		return 0;

	WI = SephirothPlayer(PlayerOwner).PSI.WornItems;
	if(WI == None)
		return 0;

	for(i=0; i<WI.Items.Length; i++)
	{
		if(WI.Items[i] != None && WI.Items[i].TypeName == ItemClassName)
			return 1;
	}

	return 0;
}

function string GetIconTextureName(string IconName)
{
	if(IconName == "")
		return "";
	if(InStr(IconName, ".") != -1)
		return IconName;
	return "ItemSprites." $ IconName;
}

function string GetDetailTreeTitle(int Index)
{
	local int i, Indent;
	local string Prefix, Title;

	if(CustomCmd == None || Index < 0 || Index >= CustomCmd.AdvancedSynthesisDetailLines.Length)
		return "";

	Title = CustomCmd.AdvancedSynthesisDetailLines[Index].Title;
	if(Index == 0)
		return "   " $ Title;

	Indent = CustomCmd.AdvancedSynthesisDetailLines[Index].Indent;
	for(i=0; i<Indent; i++)
		Prefix = Prefix $ "   ";

	return Prefix $ "   " $ Title;
}
defaultproperties
{
     Components(0)=(XL=518.000000,YL=387.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=496.000000,YL=408.000000,PivotDir=PVT_Copy,OffsetXL=13.000000,OffsetYL=35.000000)
     Components(2)=(Id=2,XL=188.000000,YL=24.000000,PivotDir=PVT_Copy)
     Components(3)=(Id=3,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=489.000000,OffsetYL=14.000000,ToolTip="CloseContext")
     Components(4)=(Id=4,Caption="Make",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=409.000000,OffsetYL=337.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Smithy)
     Components(5)=(Id=5,Caption="OneHand",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Terms)
     Components(6)=(Id=6,Caption="Bare",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Terms)
     Components(7)=(Id=7,Caption="Red",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Terms)
     Components(8)=(Id=8,Caption="Bow",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Terms)
     Components(9)=(Id=9,Caption="Blue",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Terms)
     Components(10)=(Id=10,Caption="Weapon",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(11)=(Id=11,Caption="Helmet",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(12)=(Id=12,Caption="Armor",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(13)=(Id=13,Caption="Vambrace",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(14)=(Id=14,Caption="Boots",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(15)=(Id=15,Caption="Shield",Type=RES_TextButton,XL=100.000000,YL=14.000000,TextAlign=TA_MiddleLeft,LocType=LCT_Smithy)
     Components(16)=(Id=16,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(17)=(Id=17,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(18)=(Id=18,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(19)=(Id=19,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(20)=(Id=20,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(21)=(Id=21,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(22)=(Id=22,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(23)=(Id=23,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(24)=(Id=24,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(25)=(Id=25,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(26)=(Id=26,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(27)=(Id=27,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(28)=(Id=28,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(29)=(Id=29,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(30)=(Id=30,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(31)=(Id=31,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(32)=(Id=32,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(33)=(Id=33,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(34)=(Id=34,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(35)=(Id=35,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(36)=(Id=36,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(37)=(Id=37,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(38)=(Id=38,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     Components(39)=(Id=39,Type=RES_TextButton,XL=166.000000,YL=13.000000,TextAlign=TA_MiddleLeft)
     TextureResources(0)=(Package="UI_2011",Path="make_info",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     IsBottom=True
}
