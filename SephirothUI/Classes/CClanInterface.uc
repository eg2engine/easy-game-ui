class CClanInterface	extends CMultiInterface;

#exec TEXTURE IMPORT NAME=ScrollUpN FILE=../Interface/Textures/ScrollUpN.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ScrollUpO FILE=../Interface/Textures/ScrollUpO.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ScrollUpP FILE=../Interface/Textures/ScrollUpP.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ScrollDownN FILE=../Interface/Textures/ScrollDownN.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ScrollDownO FILE=../Interface/Textures/ScrollDownO.tga MIPS=Off
#exec TEXTURE IMPORT NAME=ScrollDownP FILE=../Interface/Textures/ScrollDownP.tga MIPS=Off

#exec OBJ LOAD FILE=../Textures/UI_Clan.utx PACKAGE=UI_Clan

// keios - 서열변경버튼 ID
const ID_ORDERUPBTN		= 1;
const ID_ORDERDOWNBTN	= 2;
const CB_ShowScore		= 3;
const BN_Exit			= 4;
const BN_ClanLeave		= 5;

const BN_MemberInfo		= 6;
const BN_ApplicantInfo	= 7;

const IDM_ClanLeave = 1;

const CMP_EXIT = 4;
const CMP_LEAVE = 5;
const CMP_MEMBER = 6;
const CMP_ACEPT = 7;



var array<string> PageNames;
var CClanPage CurrentPage;
var int CurPageIndex;

// tf clan
var CClanBattleInfo ClanBattleInfo;

//Buttons----------------------------------------
var float PageX,PageY;

function RecvClanMemberInfo()
{
	if(CurPageIndex != 0)
	{
		CurrentPage.OnFlush();
		RemoveInterface(CurrentPage);
		CurrentPage = None;
		CurrentPage = CClanPage(AddInterface(PageNames[0]));		
		if(CurrentPage != None)
		{
			CurrentPage.BaseInterface = Self;
			CurrentPage.OnInit();
			CurPageIndex = 0;
		SetComponentTextureId(Components[CMP_MEMBER],3,1,3,3);
		SetComponentTextureId(Components[CMP_ACEPT],1,-1,3,2);
		//VisibleComponent(Components[CMP_LEAVE], true);
			Components[ID_ORDERUPBTN].bVisible = true;
			Components[ID_ORDERDOWNBTN].bVisible = true;
			Components[3].bVisible = true;
		}
	}
	else
		CurrentPage.UpdatePageItems();
}

function RecvClanApplicantInfo()
{
	if(CurPageIndex != 1)
	{
		CurrentPage.OnFlush();
		RemoveInterface(CurrentPage);
		CurrentPage = None;
		CurrentPage = CClanPage(AddInterface(PageNames[1]));
		if(CurrentPage != None)
		{
			CurrentPage.BaseInterface = Self;
			CurrentPage.OnInit();
			CurPageIndex = 1;
		SetComponentTextureId(Components[CMP_MEMBER],1,-1,3,2);
		SetComponentTextureId(Components[CMP_ACEPT],3,1,3,3);
		//VisibleComponent(Components[CMP_LEAVE], true);
			Components[ID_ORDERUPBTN].bVisible = false;		//modified by yj   ... 이거 원구현이 왜 이렇게 꼬여있지..
			Components[ID_ORDERDOWNBTN].bVisible = false;
			Components[3].bVisible = false;
		}
	}
	else
		CurrentPage.UpdatePageItems();
}

function OnInit()
{
	SetComponentNotify(Components[3], CB_ShowScore, Self);

	SetComponentNotify(Components[4], BN_Exit, Self);
	SetComponentNotify(Components[5], BN_ClanLeave, Self);
	SetComponentNotify(Components[6], BN_MemberInfo, Self);
	SetComponentNotify(Components[7], BN_ApplicantInfo, Self);

	CurrentPage = CClanPage(AddInterface(PageNames[0]));	
	if(CurrentPage != None){
		CurrentPage.BaseInterface = Self;
		CurrentPage.OnInit();
		CurPageIndex = 0;
	}

	SetComponentTextureId(Components[1],14,0,16,15);
	SetComponentTextureId(Components[2],17,0,19,18);

	SetComponentTextureId(Components[CMP_EXIT],5,-1,5,6);
	SetComponentTextureId(Components[CMP_LEAVE],11,-1,13,12);

	SetComponentTextureId(Components[CMP_MEMBER],3,0,3,3);
	SetComponentTextureId(Components[CMP_ACEPT],1,0,3,2);
}

function OnFlush()
{
	if(CurrentPage != None){
		CurrentPage.OnFlush();
		RemoveInterface(CurrentPage);
		CurrentPage = None;
	}
}

function LayOut(Canvas C)
{
	local int i;

	PageX = (C.ClipX-Components[0].XL)/2;
	PageY = (C.ClipY-Components[0].YL)/2;
	MoveComponentId(0,true,PageX,PageY);

	if(CurrentPage != None)
		CurrentPage.SetRegion(PageX+17, PageY+167,473,317);
/*
	if(CurrentPage.IsA('CClanMemberInfoPage'))
	{
		SetComponentTextureId(Components[CMP_MEMBER],3,1,3,3);
		SetComponentTextureId(Components[CMP_ACEPT],1,-1,3,2);
		VisibleComponent(Components[CMP_LEAVE], true);
	}
	else if(CurrentPage.IsA('CClanApplicantInfoPage'))
	{
		SetComponentTextureId(Components[CMP_MEMBER],1,-1,3,2);
		SetComponentTextureId(Components[CMP_ACEPT],3,1,3,3);
		VisibleComponent(Components[CMP_LEAVE], false);
	}
*/
	for(i=0; i<Components.Length; i++)
		MoveComponentId(i);
}

function OnPostRender(HUD H, Canvas C)
{
	local ClientController CC;
	local string strMemberNums, strRing;

	CC = ClientController(PlayerOwner);
	
	//버튼들 그리기, 버튼에 마우스가 올려져 있으면 툴팁도 그려준다.	
	C.SetDrawColor(255,255,255);
	C.SetRenderStyleAlpha();
	C.KTextFormat = ETextAlign.TA_MiddleCenter;	

	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(Localize("ClanUI","ClanUI","SephirothUI"),PageX,PageY+14,Components[0].XL,15);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);

	// info
	C.SetDrawColor(241,215,113);
	C.DrawKoreanText(Localize("ClanUI","Name","SephirothUI"),PageX+116,PageY+50,66,15);
	C.DrawKoreanText(Localize("ClanUI","MasterName","SephirothUI"),PageX+116,PageY+74,66,15);
	C.DrawKoreanText(Localize("ClanUI","Member","SephirothUI"),PageX+340,PageY+50,66,15);
	C.DrawKoreanText(Localize("ClanUI","Ring","SephirothUI"),PageX+116,PageY+108,66,15);

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255,255,255);

	//클랜명
	C.DrawKoreanText(CC.ClanManager.ClanName,PageX+188,PageY+49,136,15);

	//클랜 마스터명
	C.DrawKoreanText(CC.ClanManager.MasterName,PageX+188,PageY+74,136,15);



	//클랜 멤버수
//	strMemberNums = CC.ClanManager.OnlineMemberNums$" / "$CC.ClanManager.Members.Length$" / "$CC.ClanManager.MaxMemberNums;
	strMemberNums = CC.ClanManager.Members.Length $ " / " $ CC.ClanManager.MaxMemberNums;
	C.DrawKoreanText(strMemberNums,PageX+372,PageY+49,118,15);


	//맹세의 반지 갯수
	if(CC.ClanManager.bLordClan)
		strRing = CC.ClanManager.RestRingNums$" / 10";
	else
		strRing = "0 / 0";
	C.DrawKoreanText(strRing,PageX+188,PageY+108,38,15);

	C.SetDrawColor(153,153,153);
	C.DrawKoreanText("(성주클랜만 해당)",PageX+230,PageY+108,99,15);

	C.SetDrawColor(255,255,255);

	// keios - 서열 변경 버튼 Draw
	if(CurrentPage.IsA('CClanMemberInfoPage')) {
		DrawOrderButtons_(C);
	}

	CurrentPage.DrawPage(C);

	C.SetDrawColor(255,255,255);
}

//@by wj(040331)------
function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	local int Value;
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	if(NotifyType == INT_MessageBox) {
		Value = int(Command);
		if(Value == IDM_ClanLeave){
			SephirothPlayer(PlayerOwner).Net.NotiClanQuit();
			Parent.NotifyInterface(Self, INT_Close);
		}
	}
}
//--------------------


function NotifyComponent(int ResId, int NotifyId, optional string NotifyCommand)
{
	local int i;
	local bool bFindSubMaster;
	local ClientController CC;

	CC = ClientController(PlayerOwner);

	switch(ResId)
	{
	case ID_ORDERUPBTN:
		if(NotifyId == ID_ORDERUPBTN)
		{
			if(CurrentPage.IsA('CClanMemberInfoPage'))
			{
				CClanMemberInfoPage(CurrentPage).OnOrderUp();
			}
		}
		break;
	case ID_ORDERDOWNBTN:
		if(NotifyId == ID_ORDERDOWNBTN)
		{
			if(CurrentPage.IsA('CClanMemberInfoPage'))
			{
				CClanMemberInfoPage(CurrentPage).OnOrderDown();
			}
		}
		break;
	case CB_ShowScore:   // tf clan
		if(NotifyId == CB_ShowScore)
		{
			if( SephirothInterface(Parent).bDisplayClanBattleInfo == true ){
				SephirothInterface(Parent).bDisplayClanBattleInfo = false;
				SephirothInterface(Parent).ClanBattleInfoRemove();
			} else {
				SephirothInterface(Parent).bDisplayClanBattleInfo = true;
				SephirothInterface(Parent).ClanBattleInfoAdd();
			}
		}
		break;

	case BN_EXIT:
		Parent.NotifyInterface(Self, INT_Close);
		break;

	case BN_ClanLeave:
		if(string(CC.PSI.PlayName) == CC.ClanManager.MasterName)
			class'CMessageBox'.static.MessageBox(Self,"ClanLeave",Localize("Modals","ClanLeaveWarning","Sephiroth"),MB_OK);
		else
			class'CMessageBox'.static.MessageBox(Self,"ClanLeave",CC.ClanManager.ClanName@Localize("Modals","ClanLeave","Sephiroth"),MB_YESNO,IDM_ClanLeave);
		break;

	case BN_MemberInfo:
		bFindSubMaster = false;				
		for (i=0;i<CC.ClanManager.SubMasterNames.Length;i++)
		{
			if(string(CC.PSI.PlayName) == CC.ClanManager.SubMasterNames[i]) 
				bFindSubMaster = true;								
		}

		if(string(CC.PSI.PlayName) == CC.ClanManager.MasterName || bFindSubMaster )
			if(CurPageIndex != 0)
				SephirothPlayer(PlayerOwner).Net.NotiClanMemberInfo();
		break;

	case BN_ApplicantInfo:
		bFindSubMaster = false;				
		for (i=0;i<CC.ClanManager.SubMasterNames.Length;i++)
		{
			if(string(CC.PSI.PlayName) == CC.ClanManager.SubMasterNames[i]) 
				bFindSubMaster = true;								
		}

		if(string(CC.PSI.PlayName) == CC.ClanManager.MasterName || bFindSubMaster )
			if(CurPageIndex != 1)
					SephirothPlayer(PlayerOwner).Net.NotiClanApplicantInfo();
		break;
	}
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local float Sx,Sy,Ex,Ey;
	local float MouseX,MouseY;
	
	if(Key ==IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close, "ByEscape");
		return true;
	}
	if(IsCursorInsideComponent(Components[0])) {
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = CurrentPage.PageX;
		Sy = CurrentPage.PageY;
		Ex = Sx + CurrentPage.PageWidth;
		Ey = Sy + CurrentPage.PageHeight;
		
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey){			
			if(CurrentPage.OnPageKeyEvent(Key,Action,Delta))
				return true;
		}

		if(Key == IK_LeftMouse)
			return true;
	}

	return false;
}


///////////////////////////////////
// keios - 서열 변경 버튼 관련
// - ClanPage는 CInterface의 기능을 전혀 이용하고 있지 않다. (ShowInterface도 하지 않고, Layout도 되지 않고 있다.)
// - 따라서 개별적으로 위치조정 후 Render해줘야한다.

/////////////////////
//yj - 왜 이렇게 짰는지 잘 모르... 나중에 싹 정리하면 좋을 듯


function LayoutButtons_(Canvas C)
{
	MoveComponent(Components[ID_ORDERUPBTN]);
	MoveComponent(Components[ID_ORDERDOWNBTN]);
	MoveComponent(Components[3]);
}

function DrawOrderButtons_(Canvas C)
{
	LayoutButtons_(C);
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(241,215,113);
	C.DrawKoreanText(Localize("ClanUI","Reorder","SephirothUI"), Components[0].X + 234,
					Components[0].Y + 421, 40, 15);
	C.SetDrawColor(255,255,255);
	RenderComponent(C, Components[ID_ORDERUPBTN]);
	RenderComponent(C, Components[ID_ORDERDOWNBTN]);
	// tf clan
	RenderComponent(C, Components[3]);
}

// tf clan
function bool PushComponentBool(int CmpId)
{
	if (CmpId == 3) {
		if( SephirothInterface(Parent).bDisplayClanBattleInfo == true )			
			return true;		
		else 
			return false;	
	}
}

defaultproperties
{
     PageNames(0)="SephirothUI.CClanMemberInfoPage"
     PageNames(1)="SephirothUI.CClanApplicantInfoPage"
     Components(0)=(Type=RES_Image,XL=512.000000,YL=455.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=205.000000,OffsetYL=418.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=20.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=286.000000,OffsetYL=418.000000)
     Components(3)=(Id=3,Caption="BattleInfo",Type=RES_CheckButton,XL=22.000000,YL=22.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=415.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Setting)
     Components(4)=(Id=4,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=482.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(5)=(Id=5,Caption="Leave",Type=RES_PushButton,XL=112.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=381.000000,OffsetYL=412.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(6)=(Id=6,Caption="Member",Type=RES_PushButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=137.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(7)=(Id=7,Caption="AceptPage",Type=RES_PushButton,XL=102.000000,YL=24.000000,PivotDir=PVT_Copy,OffsetXL=119.000000,OffsetYL=137.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     TextureResources(0)=(Package="UI_2011",Path="win_clan",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="chr_tab_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="chr_tab_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="chr_tab_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="chr_tab_co",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2009",Path="Win03_01",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_brw_l_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_brw_l_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_brw_l_c",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_s_arr_u_n",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_s_arr_u_o",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_s_arr_u_c",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="btn_s_arr_d_n",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_s_arr_d_o",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_s_arr_d_c",Style=STY_Alpha)
     WinWidth=512.000000
     WinHeight=455.000000
}
