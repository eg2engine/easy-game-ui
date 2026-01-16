class CClanMemberInfoPage extends CClanPage;

const NumberX = 0;
const NumberY = 23;
const NumberXL = 30;
const NameX = 34;
const NameY = 0;
const NameXL = 117;
const LevelX = 161;
const LevelXL = 40;
const ClassX = 208;
const ClassXL = 57;
const TitleX = 272;
const TitleXL = 71;

const IDS_ChangeTitle = 1;

struct test
{
	var string Title;
	var string Name;
	var bool bConnected;
};

var array<test> testdata;

//------------------------------------------
// keios - ���� update�� ������ ���þ������� �����ϱ� ����
var string selected_member;



function OnInit()
{	
	local ClientController CC;

	//Log("CClanMemberIngoPage.uc 1--->"); 

	Super.OnInit();
//	for(i = 0 ; i < 100 ; i++)
//	{
//		temp.Title = "test"$i;
//		temp.Name = "wawoo"$i;
//		temp.bConnected = true;
//		testdata[i] = temp;
//	}
	
	CC = ClientController(PlayerOwner);
	UITexture = Texture(DynamicLoadObject("UI_Clan.default.MemberInfo",class'Texture'));
	
//	SetSpriteTexture(UnitSprites[0],UITexture);
	SetSpriteTexture(UnitSprites[1],UITexture);
	SetSpriteTexture(UnitSprites[2],UITexture);
	SetSpriteTexture(UnitSprites[3],UITexture);
	InitScroll(0,10,CC.ClanManager.Members.Length);
//	InitScroll(0,10,testdata.Length);
}

function OnFlush()
{
//Log("CClanMemberIngoPage.uc 2--->"); 
	Controller.ContextMenu = None;
}

function UpdatePageItems()
{
	local int i, list_len;

	//Log("CClanMemberIngoPage.uc 3--->"); 

	UpdateScrollList(0,ClientController(PlayerOwner).ClanManager.Members.Length);

	// keios - ���� �����ϰ� �ִ� �������� �ٽ� ����
	if(selected_member != "" && Scrolls[0].SelectedItemNum != -1)
	{
		list_len = ClientController(PlayerOwner).ClanManager.Members.Length;

		for(i=0; i < list_len; ++i)
		{
			if(ClientController(PlayerOwner).ClanManager.Members[i].Name == selected_member)
			{
				Scrolls[0].SelectedItemNum = i;
				return;
			}
		}
	}
	Scrolls[0].SelectedItemNum = -1;
}

function DrawPage(Canvas C)
{
	local int ListLength;
	local ClientController CC;
	local int i;
	local Color OldColor;
	local string TempText;
	local int Index;
	// tf clan
	local bool bMaster, bFindSubMaster;
	local int j;

//	//Log("CClanMemberIngoPage.uc 4--->"); 
	
	CC = ClientController(PlayerOwner);
	C.SetRenderStyleAlpha();
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	//���
//	DrawUnitSprite(C,UnitSprites[0],PageX, PageY,447,261);

	//��ũ��
	DrawScroll(C);

	OldColor = C.DrawColor;
	C.SetDrawColor(229,201,174);	

	//������
//	C.DrawKoreanText(Localize("ClanUI","Icon","SephirothUI"),PageX+IconX,PageY+12,42,17);	

	//����
	C.DrawKoreanText(Localize("ClanUI","Number","SephirothUI"),PageX,PageY,30,15);

	//ĳ���͸�
	C.DrawKoreanText(Localize("ClanUI","ChrName","SephirothUI"),PageX+34,PageY,117,15);

	//����
	C.DrawKoreanText(Localize("ClanUI","Level","SephirothUI"),PageX+161,PageY,40,15);

	//����
	C.DrawKoreanText(Localize("ClanUI","Class","SephirothUI"),PageX+208,PageY,57,15);

	//ȣĪ
	C.DrawKoreanText(Localize("ClanUI","Title","SephirothUI"),PageX+272,PageY,71,15);

	//���ӿ���	
//	C.DrawKoreanText(Localize("ClanUI","Connect","SephirothUI"),PageX+OnlineX,PageY+12,58,17);

	if(Scrolls[0].ItemCountPerPage > Scrolls[0].MaxItemCount)
		ListLength = Scrolls[0].MaxItemCount;
	else 
		ListLength = Scrolls[0].ItemCountPerPage;
	C.DrawColor = OldColor;

	OldColor = C.DrawColor;

	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(255,255,255);	

	for(i = 0 ; i < ListLength ; i++)
	{
		// ���õ� �ɹ� ��׶���
		Index = Scrolls[0].CurrentPos+i;
		if(Index == Scrolls[0].SelectedItemNum)
		{
			C.SetDrawColor(255,242,0);
			DrawSelectedBox(C,PageX+NumberX,PageY+NumberY+i*23-1,460,17);
		}

		//���ӿ���
		if(CC.ClanManager.Members[Index].bConnected)
			C.SetDrawColor(255,255,255);
		else
			C.SetDrawColor(128,128,128);
		C.KTextFormat = ETextAlign.TA_MiddleCenter;

		//Icon
		bMaster = false;
		if(CC.ClanManager.Members[Index].Name == CC.ClanManager.MasterName)
		{
			bMaster = true;
			//DrawUnitSprite(C,UnitSprites[1],PageX+IconX+12,PageY+IconY+i*23,15,17);
			C.SetDrawColor(229,201,174);
		}
		// tf clan
		bFindSubMaster = false;				
		for (j=0;j<CC.ClanManager.SubMasterNames.Length;j++) {
			if(CC.ClanManager.Members[Index].Name == CC.ClanManager.SubMasterNames[j])
			{
				bFindSubMaster = true;
				C.SetDrawColor(184,200,255);
			}
		}
/*
		//if(CC.ClanManager.Members[Index].Name == CC.ClanManager.SubMasterName)
		if( bFindSubMaster )
			DrawUnitSprite(C,UnitSprites[2],PageX+IconX+17,PageY+IconY+i*23,16,18);
		if(CC.ClanManager.Members[Index].bRing)
			DrawUnitSprite(C,UnitSprites[3],PageX+IconX+37,PageY+IconY+i*23,16,18);
*/


		//����
		C.DrawKoreanText(CC.ClanManager.Members[Index].BackNumber,PageX+NumberX,PageY+NumberY+i*23,NumberXL,15);

		//ĳ���� ��
		TempText = CC.ClanManager.Members[Index].Name;
		C.DrawKoreanText(TempText,PageX+NameX,PageY+NumberY+i*23,NameXL,15);

		//ȣĪ
		TempText = CC.ClanManager.Members[Index].Title;

		if(TempText != "")
			C.DrawKoreanText(TempText,PageX+TitleX,PageY+NumberY+i*23,TitleXL,15);		//+7�� offset
	}

	C.DrawColor = OldColor;
}

//
// * kcman - playname�� name type�̹Ƿ� master, submaster ��� nameŸ������ ���ؾ��Ѵ�. *
//
function bool OnPageKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float Sx,Sy,Ex,Ey,MouseX,MouseY;
	local ClientController CC;
	local int Index;
	local string ContextString, strChange, strBanish, strSubMaster;

	//local name PlayName, MasterName;
	// Change to string --Ag blue
	local String PlayName, MasterName;

	local CTextMenu TextMenu;
	// tf clan
	local bool bFindSubMaster;
	local int i, j, k;

	//Log("CClanMemberIngoPage.uc 5--->"); 

	CC = ClientController(PlayerOwner);

	if(Key == IK_LeftMouse && Action == IST_Press)
	{		
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX;
		Sy = PageY + NumberY;
		Ex = Sx + 425;
		Ey = Sy + 230;
		//Scrolls[0].SelectedItemNum = -1;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey)
		{
			Index = Scrolls[0].CurrentPos + (MouseY - Sy) / 23;
			if(Index < Scrolls[0].MaxItemCount)
			{
				Scrolls[0].SelectedItemNum = Index;
				selected_member = ClientController(PlayerOwner).ClanManager.Members[Index].Name;	// keios
			}
			else
			{
				Scrolls[0].SelectedItemNum = -1;
				selected_member = "";		// keios
			}
		}
		ProcessScrolls();
	}
	if(Key == IK_LeftMouse && Action == IST_Release)
	{
		OnReleaseMouseLButton();
	}
	if(Key == IK_RightMouse && Action == IST_Release)
	{
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX;
		Sy = PageY + NumberY;
		Ex = Sx + 425;
		Ey = Sy + 230;
		Scrolls[0].SelectedItemNum = -1;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey)
		{
			Index = Scrolls[0].CurrentPos + (MouseY - Sy) / 23;
			if(Index < Scrolls[0].MaxItemCount){
				Scrolls[0].SelectedItemNum = Index;

				//PlayName = CC.PSI.PlayName;
				// -- Ag Blue
                PlayName = String(CC.PSI.PlayName);
				//MasterName = StrToName(CC.ClanManager.MasterName);
				MasterName = CC.ClanManager.MasterName;
				//MasterName = CC.ConvertToName(CC.ClanManager.MasterName);

				//Log("CClanMemberIngoPage.uc OnPageKeyEvent 1--->"); 

				// tf clan
				//SubMasterName = name(CC.ClanManager.SubMasterName);
				bFindSubMaster = false;
				for (i=0;i<CC.ClanManager.SubMasterNames.Length;i++) {
					//if(PlayName == CC.ConvertToName(CC.ClanManager.SubMasterNames[i])) 
					//if(PlayName == StrToName(CC.ClanManager.SubMasterNames[i]))
					if(PlayName == CC.ClanManager.SubMasterNames[i])
						bFindSubMaster = true;
				}

				//Log("CClanMemberIngoPage.uc OnPageKeyEvent 2--->"); 

				// tf clan
				//if(PlayName == MasterName || PlayName == SubMasterName){
				if(PlayName == MasterName || bFindSubMaster){
					//ContextString = Localize("ContextMenu","ChangeTitle","Sephiroth")$"|"$
					//				Localize("ContextMenu","ChangeClanMaster","Sephiroth")$"|"$
					//				Localize("ContextMenu","BanFromClan","Sephiroth")$"|"$
					//				Localize("ContextMenu","PositionUp","Sephiroth")$"|"$
					//				Localize("ContextMenu","PositionDown","Sephiroth");
					if(PlayName == MasterName){
						strChange = Localize("ContextMenu","ChangeTitle","Sephiroth")$"|"$
									Localize("ContextMenu","ChangeClanMaster","Sephiroth");
						if(CC.ClanManager.bLordClan)
							strChange = strChange$"|"$Localize("ContextMenu","EndowItem","Sephiroth");
						//if(CC.ConvertToName(CC.ClanManager.Members[Index].Name) != MasterName)
						//if(StrToName(CC.ClanManager.Members[Index].Name) != MasterName)
						// Ag Blue
						if(CC.ClanManager.Members[Index].Name != MasterName)
							strBanish = "|"$Localize("ContextMenu","BanFromClan","Sephiroth");

						//Log("CClanMemberIngoPage.uc OnPageKeyEvent 3--->"); 

						// tf clan
						bFindSubMaster = false;				
						for (j=0;j<CC.ClanManager.SubMasterNames.Length;j++) {
							//if(CC.ConvertToName(CC.ClanManager.Members[Index].Name) == CC.ConvertToName(CC.ClanManager.SubMasterNames[j])) 
							//if(StrToName(CC.ClanManager.Members[Index].Name) == StrToName(CC.ClanManager.SubMasterNames[j]))
							// --AgBlue
							if(CC.ClanManager.Members[Index].Name == CC.ClanManager.SubMasterNames[j])
								bFindSubMaster = true;
						}
						//if(name(CC.ClanManager.Members[Index].Name) == SubMasterName)
						if( bFindSubMaster )
							strSubMaster = "|"$Localize("ContextMenu","ResetSubClanMaster","Sephiroth");

						//Log("CClanMemberIngoPage.uc OnPageKeyEvent 4--->"); 
						
						// tf clan
						bFindSubMaster = false;				
						for (k=0;k<CC.ClanManager.SubMasterNames.Length;k++) {
							//if(CC.ConvertToName(CC.ClanManager.Members[Index].Name) == CC.ConvertToName(CC.ClanManager.SubMasterNames[k])) 
							//if(StrToName(CC.ClanManager.Members[Index].Name) == StrToName(CC.ClanManager.SubMasterNames[k]))
							// -- Ag Blue
							if(CC.ClanManager.Members[Index].Name == CC.ClanManager.SubMasterNames[k])
								bFindSubMaster = true;								
						}

						//Log("CClanMemberIngoPage.uc OnPageKeyEvent 5--->"); 

						//if(name(CC.ClanManager.Members[Index].Name) != MasterName && SubMasterName == name(""))
						//if(name(CC.ClanManager.Members[Index].Name) != MasterName && !bFindSubMaster)
						//if(CC.ConvertToName(CC.ClanManager.Members[Index].Name) != MasterName && !bFindSubMaster)
						//if(StrToName(CC.ClanManager.Members[Index].Name) != MasterName && !bFindSubMaster)
						
						//-- AgBlue
						if(CC.ClanManager.Members[Index].Name != MasterName && !bFindSubMaster)
							strSubMaster = strSubMaster$"|"$Localize("ContextMenu","SetSubClanMaster","Sephiroth");

						//Log("CClanMemberIngoPage.uc OnPageKeyEvent 6--->"); 
					}
					else{
						strChange = Localize("ContextMenu","ChangeTitle","Sephiroth");
						//if(name(CC.ClanManager.Members[Index].Name) != MasterName && name(CC.ClanManager.Members[Index].Name) != PlayName)
						//if(CC.ConvertToName(CC.ClanManager.Members[Index].Name) != MasterName && CC.ConvertToName(CC.ClanManager.Members[Index].Name) != PlayName)
						//if(StrToName(CC.ClanManager.Members[Index].Name) != MasterName && StrToName(CC.ClanManager.Members[Index].Name) != PlayName)
						//--Ag Blue
						if(CC.ClanManager.Members[Index].Name != MasterName && CC.ClanManager.Members[Index].Name != PlayName)
							strBanish = "|"$Localize("ContextMenu","BanFromClan","Sephiroth");
					}

					//Log("CClanMemberIngoPage.uc OnPageKeyEvent 7--->"); 

					ContextString = strChange$
									strBanish$"|"$
									Localize("ContextMenu","PositionUp","Sephiroth")$"|"$
									Localize("ContextMenu","PositionDown","Sephiroth")$
									strSubMaster;
				}
				TextMenu = BaseInterface.PopupContextMenu(ContextString, MouseX, MouseY);
				TextMenu.OnTextMenu = InternalTextMenuOnClan;
			}
		}
	}
	if(Key ==IK_MouseWheelUp){
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX + TitleX;
		Sy = PageY + NumberY;
		Ex = Sx + 425;
		Ey = Sy + 230;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0,-1);
			return true;
		}
	}
	if(Key ==IK_MouseWheelDown){
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX + TitleX;
		Sy = PageY;
		Ex = Sx + 425;
		Ey = Sy + 230;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0,1);
			return true;
		}
	}
	
	if(Key == IK_LeftMouse && IsCursorInsideComponent(Components[0])){
		return true;
	}
	
	return false;
}

function NotifyEditBox(CInterface Interface, int NotifyId, string EditText)
{
	local string TempStr;
	local ClientController CC;

	CC = ClientController(PlayerOwner);
	TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
	if(NotifyId == IDS_ChangeTitle)	{
		SephirothPlayer(PlayerOwner).Net.NotiClanTitle(TempStr,EditText);		
	}
}

function InternalTextMenuOnClan(int Index, string Text)
{
	local string TempStr;
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	if(Text == Localize("ContextMenu","ChangeTitle","Sephiroth")) {
		class'CEditBox'.static.EditBox(Self,"ChangeClanTitle",Localize("Modals","ChangeClanTitle","Sephiroth"),IDS_ChangeTitle,10,"");
	}
	else if(Text == Localize("ContextMenu","ChangeClanMaster","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanMaster(TempStr);
	}
	else if(Text == Localize("ContextMenu","BanFromClan","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanExpel(TempStr);
	}
	else if(Text == Localize("ContextMenu","PositionUp","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanOrder(TempStr,-1);
	}
	else if(Text == Localize("ContextMenu","PositionDown","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanOrder(TempStr,1);
	}
	else if(Text == Localize("ContextMenu","SetSubClanMaster","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanDelegate(TempStr);
	}
	else if(Text == Localize("ContextMenu","ResetSubClanMaster","Sephiroth")) {
		// tf clan
		//TempStr = CC.ClanManager.SubMasterName;
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanCancelDelegate(TempStr);
	}
	else if(Text == Localize("ContextMenu","EndowItem","Sephiroth")) {
		TempStr = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
		SephirothPlayer(PlayerOwner).Net.NotiClanEndowedItem(TempStr);
	}
	Controller.ContextMenu = None;
}

//////////////////////////////////////
// keios - ���� ���� ó��
// ��û�� CClanInterface�������� �´�.

function OnOrderUp()
{
	local ClientController CC;
	local string membername;
	CC = ClientController(PlayerOwner);
	membername = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;
	if(membername != "")
		SephirothPlayer(PlayerOwner).Net.NotiClanOrder(membername,-1);
}
function OnOrderDown()
{
	local ClientController CC;
	local string membername;


	CC = ClientController(PlayerOwner);
	membername = CC.ClanManager.Members[Scrolls[0].SelectedItemNum].Name;

	if(membername != "")
		SephirothPlayer(PlayerOwner).Net.NotiClanOrder(membername,1);
}

defaultproperties
{
     UnitSprites(0)=(UL=447.000000,VL=261.000000)
     UnitSprites(1)=(V=300.000000,UL=16.000000,VL=18.000000)
     UnitSprites(2)=(U=20.000000,V=300.000000,UL=16.000000,VL=18.000000)
     UnitSprites(3)=(U=40.000000,V=300.000000,UL=16.000000,VL=18.000000)
     Scrolls(0)=(fX=462.000000,fY=-4.000000,ScrollHeight=212.000000)
     Components(0)=(XL=447.000000,YL=261.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=15.000000,PivotDir=PVT_Copy,OffsetXL=260.000000,OffsetYL=240.000000,UL=14.000000,VL=15.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=15.000000,PivotDir=PVT_Copy,OffsetXL=276.000000,OffsetYL=240.000000,UL=14.000000,VL=15.000000)
}
