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

const CMP_Recipe =16;

var string m_sTitle;

//var SepEditBox Edit; // 에디트 컨트롤
var CImeEdit Edit; // 에디트 컨트롤

var SephirothInventory SepInventory;

var Recipe Recipe; // 레시피

var int nAlpha;
var bool bAlphaDir;

var bool OnJob;     // 캐릭터를 선택했나?
var int SelectJob;  // 선택한 캐릭터 직업
var bool OnPart;    // 제작할 부위를 선택했나?
var int SelectPart; // 선택한 제작할 부위
var bool OnRecipe;
var int SelectRecipe;
var bool OnMake;
var int MakeItemIndex; // 만들려고 클릭한 아이템 인덱스
var int MakeItemNum;   // 만들 아이템 개수

var array<int> HavePics; // 가지고 있는 개수
var array<int> NeedPics; // 필요한 개수

//make frame 디스플레이용
var array<string> MakeListName;
var array<int> MakeListNeedPics;
var array<int> MakeListHavePics;

var array<Texture> IconList;

var Texture RecipeBtn;

var bool bComplate;

var string teststring;

final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
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

	Recipe = spawn(class'Recipe');

	Recipe.LoadRecipe();

	// 닫기 버튼
	SetComponentNotify(Components[3], BN_Exit ,Self);
	SetComponentTextureId(Components[3],1,-1,1,2);

	// 만들기 버튼
	SetComponentNotify(Components[4], BN_Make ,Self);
	SetComponentTextureId(Components[4],3,-1,5,4);

	// 각 캐릭별 버튼
	SetComponentNotify(Components[5],BN_OneHand,Self); 
	SetComponentNotify(Components[6],BN_Bare   ,Self); 
	SetComponentNotify(Components[7],BN_Red    ,Self); 
	SetComponentNotify(Components[8],BN_Bow    ,Self); 
	SetComponentNotify(Components[9],BN_Blue   ,Self); 

	// 각 파츠별 버튼
	SetComponentNotify(Components[10],BN_Weapon  ,Self); 
	SetComponentNotify(Components[11],BN_Helmet  ,Self); 
	SetComponentNotify(Components[12],BN_Armor   ,Self); 
	SetComponentNotify(Components[13],BN_Vambrace,Self); 
	SetComponentNotify(Components[14],BN_Boots   ,Self); 
	SetComponentNotify(Components[15],BN_Shield  ,Self); 

	for(i=10; i<16; i++) // 모든 파츠 버튼을 감춘다              
		Components[i].bVisible = false;

	// 레시피 버튼
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

	for(i=16; i<33; i++)
		Components[i].bVisible = true;
	//-------------------------------------------------

	Components[16].bDisabled = true; // 최종 제작 버튼 비활성화
	Components[4].bDisabled = true;  // 만들기 버튼 초기 비활성화

	//Edit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	Edit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (Edit != None)
	{
		Edit.bNative = True;
		Edit.bMaskText = False;
		//Edit.bTestOutline = True;
		Edit.SetMaxWidth(2); // 받을 최대 글짜 수
		Edit.SetSize(153,18);
		Edit.SetText("");
		Edit.ShowInterface();
		Edit.SetFocusEditBox(true);
	}


	nAlpha = 155;
	bAlphaDir = false;

	OnJob = true;

	RecipeBtn = Texture(DynamicLoadObject("UI.Compound.Lv12Mix_Button00", class'Texture'));
	
	m_sTitle = Localize("Smithy","Smith","Sephiroth");
}

function OnFlush()
{
	FlushDynamicTextures();

	if (Recipe != None) 
	{
		Recipe.Destroy();
		Recipe = None;
	}

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
	for(i=1; i<=2; i++) // 기본 위치 셋팅
		MoveComponentId(i);

	X = Components[0].X;
	Y = Components[0].Y;

	MoveComponentId(3, false); // 닫기 버튼 위치로!
	MoveComponentId(4, false); // 만들기 버튼 위치로!
	
	JobButtonX = X + 315;
	JobButtonY = Y + 51;
	for(j=5; j<10; j++) // 캐릭터 선택 버튼들 
		MoveComponentId(j, true, JobButtonX, JobButtonY + ((j-5)*14));

	SelBtnX = X + 315;
	SelBtnY = Y + 135;
	for(l=10; l<16; l++) // 만들 부위 선택 버튼들
		MoveComponentId(l, true, SelBtnX, SelBtnY + ((l-10)*14));

	RecipeBtnX = X + 21;
	RecipeBtnY = Y + 51;

	for(r=16; r<33; r++) // 레시피에서 선택 버튼들
	{
		MoveComponentId(r, true, RecipeBtnX, RecipeBtnY + ((r-16)*14));
		Components[r].bVisible = false;
	}

	// 에디트 박스
	if (Edit != None)
		Edit.SetPos(Components[0].X + 365, Components[0].Y + 344);
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	local int i;

	switch (NotifyId) 
	{
	case BN_Exit:
		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_Make:
		if(MakeItemNum > 0)
		{
			//for(i=0; i<Recipe.InableList.Length; i++)
			//{
				//if(Recipe.InableList[i] == MakeItemIndex)
				//{
					SephirothPlayer(PlayerOwner).Net.NotiMixRaw(MakeItemIndex + 100, MakeItemNum); // 일단 무조건 1개 만들라
					SepInventory.UpdateItems(); // 아이템 갱신
					SetRecipeFrame();
					SetMakeFrame();
					Edit.SetText("");
					MakeItemNum = 0;
					Edit.SetFocusEditBox(true);
					break;
				//}
			//}
		}
		break;

	case BN_OneHand:
	case BN_Bare:
	case BN_Red:
	case BN_Bow:
	case BN_Blue:
		OnJob = false;
		OnPart = true;
		if(OnRecipe)
		{
			OnRecipe = false;
			OffRecipeFrame();
		}
		if(OnMake)
		{
			OnMake = false;
			OffMakeFrame();
		}
		SelectJob = NotifyId;   // 선택한 직업 셋팅
		SetPartFrame(); // 파츠 표시창 셋팅
		FlushDynamicTextures();	// 목록이 바뀔수도 있으니 일단 아이콘 삭제
		break;

	case BN_Weapon:
	case BN_Helmet: 
	case BN_Armor:
	case BN_Vambrace:
	case BN_Boots:
	case BN_Shield:
		OnPart = false;
		OnRecipe = true;
		OnMake = false;
		SelectPart = NotifyId;
		FlushDynamicTextures();	// 목록이 바뀔수도 있으니 일단 아이콘 삭제
		SetRecipeFrame(true);
		break;

	case BN_Recipe:
		MakeItemIndex = Recipe.GetRecipeIndex(SelectJob, SelectPart);
		for(i=0; i<Recipe.InableList.Length; i++)
		{
			if(Recipe.InableList[i] == MakeItemIndex) // +100 은 기존 조합 인덱스와 겹쳐서
			{
				SephirothPlayer(PlayerOwner).Net.NotiMixRaw(MakeItemIndex + 100, 1); // 일단 무조건 1개 만들라
				SepInventory.UpdateItems(); // 아이템 갱신
				SetRecipeFrame();
				break;
			}
		}
		break;
	case BN_Obj1  :
	case BN_Obj2  :
	case BN_Obj3  :
	case BN_Obj4  :
	case BN_Obj5  :
	case BN_Obj6  :
	case BN_Obj7  :
	case BN_Obj8  :
	case BN_Obj9  :
	case BN_Obj10 :
	case BN_Obj11 :
	case BN_Obj12 :
	case BN_Obj13 :
	case BN_Obj14 :
	case BN_Obj15 :
		OnMake = true;
		SelectRecipe = NotifyId - BN_Recipe;
		//teststring = "OnMake";
		SetMakeFrame();
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

	// 알파 깜빡이게 ------------------------------------------------------
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
	//---------------------------------------------------------------------

	// 아이템, 필요, 보유량 갱신 (아주 자주 불러주므로 렉 생긴다면 여기 좀 줄여주...)
	SepInventory.UpdateItems();

	if(OnRecipe)
		SetRecipeFrame();

	Components[4].bDisabled = true;  // 만들기 버튼 비활성화

	if(OnMake)
	{
		Components[4].bDisabled = false;  // 만들기 버튼 활성화
		SetMakeFrame();
	}
	//-------------------------------------------------------------------------

	if(IsCursorInsideAt(Components[0].X + 365, Components[0].Y + 344, 153, 18))
		if(!Edit.bHasFocus)
			Edit.SetFocusEditBox(true);

	if(IsCursorInsideComponent(Components[4])) // 만들기 버튼 위에 있나 체크
	{
		teststring = Edit.GetText();
		MakeItemNum = int(Edit.GetText());
		Edit.SetFocusEditBox(false);
	}

	DrawBackGround3x3(C, 64, 64, 6, 7, 8, 9, 10, 11, 12, 13, 14);
	DrawTitle(C, m_sTitle);

//	SelectedBkColor=(A=255,R=188,G=63,B=63)
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

		C.SetDrawColor(nAlpha, 188, 63, 63);
		C.SetPos(X + 315, Y + 52 + ((SelectJob-1)*14));	// 선택한 직업
//		C.DrawRect1Fix(181, 16);
		C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);		
	}
	else if(OnRecipe)
	{
		C.SetDrawColor(0, nAlpha, 0);
		C.SetPos(X + 17, Y + 37);
		C.DrawRect1Fix(288, 332);

		C.SetDrawColor(nAlpha, 188, 63, 63);
		C.SetPos(X + 315, Y + 136 + ((SelectPart-6)*14));
//		C.DrawRect1Fix(181, 16);
		C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);

		C.SetPos(X + 315, Y + 52 + ((SelectJob-1)*14));	// 선택한 직업
//		C.DrawRect1Fix(181, 16);
		C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 181, 14);
	}

	C.SetDrawColor(255,255,255);
}

function OnPostRender(HUD H, Canvas C)
{
	local float X, Y;
	local int i, cx, index, nStep;
	local string sIconName;
	local Texture Icon;

	X = Components[0].X;
	Y = Components[0].Y;
	cx = C.ClipX;

	C.SetDrawColor(0, nAlpha, 0);
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
/*
//	SelectedBkColor=(A=255,R=188,G=63,B=63)
	if(OnJob)
	{
		C.SetPos(X + 315, Y + 36);
		C.DrawRect1Fix(182, 86);
	}
	else if(OnPart)
	{
		C.SetPos(X + 315, Y + 121);
		C.DrawRect1Fix(182, 100);

		C.SetPos(X + 315, Y + 51 + ((SelectJob-1)*14));	// 선택한 직업
//		C.DrawRect1Fix(181, 16);
		C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', 180, 15);		
	}
	else if(OnRecipe)
	{
		C.SetPos(X + 21, Y + 50);
		C.DrawRect1Fix(281, 324);

		C.SetPos(X + 315, Y + 135 + ((SelectPart-6)*14));
		C.DrawRect1Fix(181, 16);

		C.SetPos(X + 315, Y + 51 + ((SelectJob-1)*14));	// 선택한 직업
		C.DrawRect1Fix(181, 16);
	}
*/
	if(OnRecipe)
	{
		C.SetDrawColor(255, 255, 255);
		C.KTextFormat = ETextAlign.TA_MiddleRight;

		for(i=0; i<NeedPics.Length; i++)
		{
			if(NeedPics[i] > 0 && NeedPics[i] != 99 && NeedPics[i] != -1)
			{
				if(HavePics[i] >= NeedPics[i]) // 충분히 가지고 있다면
					C.SetDrawColor(71, 129, 186);
				else                          // 모자르다면
					C.SetDrawColor(237, 51, 41);

				C.DrawKoreanText("" $ HavePics[i] $ "/" $ NeedPics[i], X + 21, Y + 51 + (i*14), 274, 14);
			}		
		}	

		C.SetRenderStyleAlpha();
		C.SetDrawColor(255, 255, 255);

		for(i=17; i<33; i++)
		{
			index = Recipe.GetRecipeDataIndex(SelectJob, SelectPart, i-CMP_Recipe);
			sIconName = Recipe.IndexToIconName(index);							// 아이템 아이콘 가져오기
			nStep =	Recipe.IndexToStep(index);

			//Log("iconlist " $ i $ "= " $ index $ ", " $ nStep);
			if(nStep == 2)
				C.SetPos(Components[i].X+(15*nStep)-2,Components[i].Y+2);
			else if(nStep == 3)
				C.SetPos(Components[i].X+15-2,Components[i].Y+2);
			else
				C.SetPos(Components[i].X-2,Components[i].Y+2);

			Icon = LoadDynamicTexture("ItemSprites." $ sIconName);
			C.DrawTile(Icon,15,15,0,0,32,32);
		}

		// 버튼 백그라운드 테스트
		if(bComplate)
		{
		//	C.SetDrawColor(255, 255, 255, nAlpha-150);//(228, 200, 128, 120);//nAlpha-50);
		//	C.DrawTileAlphaArea(RecipeBtn, cx-482, 72, 277, 11, 0, 0, 277, 11);
			C.SetDrawColor(nAlpha, 200, nAlpha, 255);
			C.KTextFormat = ETextAlign.TA_MiddleLeft;
			C.DrawKoreanText("" $ Components[16].Caption, C.ClipX-482, 71, 277, 14);
		}
	}

	if(OnMake)
	{
		for(i=0; i<4; i++)
		{
			if(MakeListName[i] != "")
			{
				C.SetDrawColor(255, 255, 255);
				C.KTextFormat = ETextAlign.TA_MiddleLeft;
				C.DrawKoreanText(MakeListName[i], X + 315, Y + 234 + (i*14), 65, 15);

				if(MakeListHavePics[i] >= MakeListNeedPics[i]) // 충분히 가지고 있다면
					C.SetDrawColor(71, 129, 186);
				else                          // 모자르다면
					C.SetDrawColor(237, 51, 41);

				C.KTextFormat = ETextAlign.TA_MiddleRight;
				C.DrawKoreanText(MakeListHavePics[i] $ "/" $ MakeListNeedPics[i], X + 315, Y + 234 + (i*14), 180, 14);
			}
		}

		// 레시피 안에서 선택한 재료
		C.SetDrawColor(237, 23, 124);
		C.SetPos(X + 21, Y + 53 + (SelectRecipe*14));
		C.DrawRect1Fix(280, 14);
	}

//	teststring = MakeListName[0];

//	C.DrawKoreanText(teststring, cx-260, 0, 50, 15);

/*
	for(i=0; i<IconList.Length; i++)
	{
		//sTemp = Recipe.GetRecipeData(SelectJob, SelectPart, i+1);
		index = Recipe.GetRecipeDataIndex(SelectJob, SelectPart, i+1);
		nStep =	Recipe.IndexToStep(index);

		//Log("iconlist " $ i $ "= " $ index $ ", " $ nStep);
		if(nStep == 2)
			C.SetPos(Components[i+17].X+(15*nStep)-2,Components[i+17].Y+2);
		else if(nStep == 3)
			C.SetPos(Components[i+17].X+15-2,Components[i+17].Y+2);
		else
			C.SetPos(Components[i+17].X-2,Components[i+17].Y+2);

		C.DrawTile(IconList[i],15,15,0,0,32,32);
	}
*/

	C.SetDrawColor(231, 202, 174);
	C.KTextFormat = ETextAlign.TA_MiddleCenter;

	C.DrawKoreanText(Localize("Smithy","Recipe","Sephiroth"), X + 21, Y + 36, 187, 14); // 레시피
	C.DrawKoreanText(Localize("Smithy","HaveNeed","Sephiroth"), X + 208, Y + 36, 101, 14); // 레시피 보/필
	C.DrawKoreanText(Localize("Smithy","Job","Sephiroth"), X + 315, Y + 36, 190, 14); // 직업
	C.DrawKoreanText(Localize("Smithy","Part","Sephiroth"), X + 315, Y + 121, 190, 14); // 부위
	C.DrawKoreanText(Localize("Smithy","Stuff","Sephiroth"), X + 315, Y + 221, 80, 14); // 제작
	C.DrawKoreanText(Localize("Smithy","HaveNeed","Sephiroth"), X + 398, Y + 221, 100, 14); // 제작 보/필

	C.DrawKoreanText(Localize("Smithy","Num","Sephiroth"), X + 314, Y + 344, 46, 14); // 조합 개수

	C.KTextFormat = ETextAlign.TA_MiddleLeft;
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 응용 함수
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function InternalUpdateItem(SephirothItem Item)
{
	local string Desc;
	local int Amount;

	Desc = Item.Description;
	Amount = Item.Amount;
}


function SetPartFrame()
{
	local int i, n;
	
	switch(SelectJob)
	{
		case BN_OneHand: n = 0; break;
		case BN_Bare: n = 6; break;
		case BN_Red: n = 12; break;
		case BN_Bow: n = 17; break;
		case BN_Blue: n = 22; break;
	}

	for(i=10; i<15; i++)                    // 무기 ~ 방패 전까지는 일단 모두 보인다
	{
		Components[i].bVisible = true;
		Components[i].Caption = Recipe.RecipeName[n + (i-10)];
	}

	if(SelectJob == BN_OneHand || SelectJob == BN_Bare) // 방패 캐릭일 경우만 보이게 한다
	{
		Components[15].bVisible = true;
		if(SelectJob == BN_OneHand)
			Components[i].Caption = Recipe.RecipeName[5];
		else
			Components[i].Caption = Recipe.RecipeName[11];
	}
	else
		Components[15].bVisible = false;
}

function SetRecipeFrame(optional bool bLoad)
{
	local int i, index, part, RecipeLine, cnt;
	local string c, sIconName;

	bComplate = true;          // 모두 보유 모드로 초기화
	part = SelectPart;

	for(i=CMP_Recipe; i<33; i++)       // 일단 모든 목록을 다 숨긴다
		Components[i].bVisible = false;

	SepInventory.UpdateItems();

	for(i=CMP_Recipe; i<33; i++)
	{
		NeedPics[i-16] = -1;
		HavePics[i-16] = -1;
	}

	for(i=CMP_Recipe; i<33; i++)
	{
		Components[i].bVisible = true;

		RecipeLine = i - CMP_Recipe;
		c = Mid( Recipe.DisableList[SelectJob], RecipeLine, 1); // 제작 가능한 것인지 체크
		if( c == "1" )
			Components[i].bDisabled = true;
		else
			Components[i].bDisabled = false;

		Components[i].Caption = Recipe.GetRecipeData(SelectJob, part, RecipeLine);  // 아이템 이름 가져오기
		index = Recipe.GetRecipeDataIndex(SelectJob, part, RecipeLine);

		if(bLoad && i != CMP_Recipe)	// 16번은 버려 -_-
		{
			sIconName = Recipe.IndexToIconName(index);							// 아이템 아이콘 가져오기
			//Log("Load Texture " $ "ItemSprites." $ sIconName);
			LoadDynamicTexture("ItemSprites." $ sIconName);
		}

		if(Components[i].Caption != "")
		{
			NeedPics[RecipeLine] = Recipe.GetRecipeDataNeedPics(SelectJob, part, RecipeLine); // 아이템 필요량 가져오기
			HavePics[RecipeLine] = SepInventory.GetSmithItemSum(Recipe.ItemSDNameList[index]); // 아이템 보유량 가져오기
		}
		else
		{
			NeedPics[RecipeLine] = -1;
			HavePics[RecipeLine] = -1;
		}

		// 완성품을 제작할 조건이 되는지 체크 ---------------------------------
		if(index >= 300 && i != 16) // 0(16번)은 레시피 타이틀이므로 체크에서 제외
		{	
			++cnt;
			if(HavePics[i-16] < NeedPics[i-16])
				bComplate = false; // 하나라도 부족한게 나타나면 모두 보유 모드 false
		}

//		teststring = "" $ cnt ;

		if(index == 301) // 엘라임이면 루프 중지
			break;
		//---------------------------------------------------------------------
	}	

	
	if(bComplate)
		Components[16].bDisabled = false; 
}

function OffRecipeFrame()
{
	local int i;

	for(i=16; i<33; i++)
		Components[i].bVisible = false;		
}

function SetMakeFrame()
{
	local int i, index, line;

	line = SelectRecipe;

	MakeItemIndex = Recipe.GetRecipeDataIndex(SelectJob, SelectPart, line);

	for(i=0; i<4; i++)
	{
		MakeListName[i] = Recipe.GetNeedName(SelectJob, SelectPart, line, i);
		index = Recipe.GetNeedIndex(SelectJob, SelectPart, line, i);
		MakeListHavePics[i] = SepInventory.GetSmithItemSum(Recipe.ItemSDNameList[index]);
		MakeListNeedPics[i] = Recipe.GetNeedPics(SelectJob, SelectPart, line, i);
	}

	Components[4].bDisabled = false; // 만들기 버튼 활성화
}


function OffMakeFrame()
{
	local int i;

	for(i=0; i<4; i++)
	{
		MakeListName[i] = "";
		MakeListHavePics[i] = 0;
		MakeListNeedPics[i] = 0;
	}
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
     Components(16)=(Id=16,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(17)=(Id=17,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(18)=(Id=18,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(19)=(Id=19,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(20)=(Id=20,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(21)=(Id=21,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(22)=(Id=22,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(23)=(Id=23,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(24)=(Id=24,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(25)=(Id=25,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(26)=(Id=26,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(27)=(Id=27,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(28)=(Id=28,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(29)=(Id=29,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(30)=(Id=30,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(31)=(Id=31,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
     Components(32)=(Id=32,Type=RES_TextButton,XL=166.000000,YL=14.000000,TextAlign=TA_MiddleLeft)
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
