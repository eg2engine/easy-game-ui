class CClanApplicantInfoPage extends CClanPage;

const ApplicantX = 34;
const ApplicantY = 23;

const BN_ApplicantDel	= 1;
const BN_ApplicantAcp	= 2;

const StartX = 350;
const StartY = 23; 

var array<string> Applicants;
var array<string> Blocks;

function OnInit()
{
	local ClientController CC;
	local int i;

	CC = ClientController(PlayerOwner);
	Super.OnInit();

	for(i = 0 ; i < 20 ; i++)
	{
		Applicants[i] = "wawoo200"$i;
		Blocks[i] = "woojin"$i;
	}

	SetSpriteTexture(UnitSprites[0],Texture(DynamicLoadObject("UI_2011_btn.btn_yell_s_n",class'Texture')));
	SetSpriteTexture(UnitSprites[1],Texture(DynamicLoadObject("UI_2011_btn.btn_yell_s_o",class'Texture')));
	SetSpriteTexture(UnitSprites[2],Texture(DynamicLoadObject("UI_2011_btn.btn_yell_s_c",class'Texture')));

	InitScroll(0,12,CC.ClanManager.Applicants.Length);
	MakeButtons();
}

function MakeButtons()		//modified by yj
{
	local int ListLength;
	local int i;

	if(Scrolls[0].ItemCountPerPage < Scrolls[0].MaxItemCount)
		ListLength = Scrolls[0].ItemCountPerPage;
	else
		ListLength = Scrolls[0].MaxItemCount;

	Buttons.Remove(0,Buttons.length);	//시작 시 초기화
	Buttons.Length = 2*ListLength;

	for(i = 0 ; i < ListLength ; i++) {
		SetButton(Buttons[2*i], BN_ApplicantAcp, startX, startY+i*25, 54, 21);
		SetButtonResource(Buttons[2*i],0,-1,2,1);		//가입 허가
		SetButtonText(2*i,Localize("ClanUI","ApplicantAccept","SephirothUI"));

		SetButton(Buttons[2*i+1], BN_ApplicantDel, startX+55, startY+i*25, 54, 21);
		SetButtonResource(Buttons[2*i+1],0,-1,2,1);		//가입불허
		SetButtonText(2*i+1,Localize("ClanUI","Delete","SephirothUI"));
	}

}
function OnFlush()
{
	if(Buttons.Length >0)
		Buttons.Remove(0,Buttons.length);
}

function UpdatePageItems()
{
	local ClientController CC;
	CC = ClientController(PlayerOwner);
	UpdateScrollList(0,CC.ClanManager.Applicants.Length);
	MakeButtons();		//modified by yj  //더좋은 위치가 있을수도
}

function DrawPage(Canvas C)
{
	local int i;
	local int ListLength;
	local ClientController CC;
	local Color OldColor;
	local string TempText;
	local float Sx,Sy;
	CC = ClientController(PlayerOwner);
	DrawButtons(C);
	DrawScroll(C);	

	OldColor = C.DrawColor;

	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	//캐릭터명
	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(Localize("ClanUI","ChrName","SephirothUI"),PageX+34,PageY,117,15);

	C.SetDrawColor(255,255,255);

	if(Scrolls[0].ItemCountPerPage < Scrolls[0].MaxItemCount)
		ListLength = Scrolls[0].ItemCountPerPage;
	else
		ListLength = Scrolls[0].MaxItemCount;
	for(i = 0 ; i < ListLength ; i++)
	{
		Sx = PageX+ApplicantX;
		Sy = PageY+ApplicantY+25*i;
		TempText = CC.ClanManager.Applicants[Scrolls[0].CurrentPos+i];
		C.DrawKoreanText(TempText,Sx,Sy,117,25);
	}
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.DrawColor = OldColor;
}


function bool OnPageKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	local int Index;
	local float Sx,Sy,Ex,Ey,MouseX,MouseY;
	local ClientController CC;
	local string ApplicantName;

	CC = ClientController(PlayerOwner);
	if (Key == IK_LeftMouse && Action == IST_Press){
		PressedButtonNum = CursorInButtons();
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;

		if(PressedButtonNum == -1){
			Sx = PageX + ApplicantX;
			Sy = PageY + ApplicantY;
			Ex = Sx + 146;
			Ey = Sy + 175;
			if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey){
				Scrolls[1].SelectedItemNum = -1;
				Index = Scrolls[0].CurrentPos + (MouseY - Sy) / 25;
				if(Index < Scrolls[0].MaxItemCount)
					Scrolls[0].SelectedItemNum = Index;
				else
					Scrolls[0].SelectedItemNum = -1;
			}
		}
		ProcessScrolls();
	}

	if (Key == IK_LeftMouse && Action == IST_Release) {
		Index = PressedButtonNum;
		if(Index != -1) {
			if(Buttons[Index].Id == BN_ApplicantDel) {		// && ApplicantName != ""){		//modified by yj
				ApplicantName = CC.ClanManager.Applicants[Scrolls[0].CurrentPos+Index/2];
				SephirothPlayer(PlayerOwner).Net.NotiClanReject(ApplicantName);
			}
			else if(Buttons[Index].Id == BN_ApplicantAcp) {		//	&& ApplicantName != ""){	//modified by yj
				ApplicantName = CC.ClanManager.Applicants[Scrolls[0].CurrentPos+Index/2];
				SephirothPlayer(PlayerOwner).Net.NotiClanAdmit(ApplicantName);
			}
			PressedButtonNum = -1;
		}
		OnReleaseMouseLButton();
	}

	if(Key == IK_MouseWheelUp) {
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX;		// + ApplicantX;
		Sy = PageY;		// + ApplicantY;
		Ex = Sx + 476;		//146;
		Ey = Sy + 322;		//175;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0, -1);
			return true;
		}
	}

	if(Key == IK_MouseWheelDown) {
		MouseX = Controller.MouseX;
		MouseY = Controller.MouseY;
		Sx = PageX;		// + ApplicantX;
		Sy = PageY;		// + ApplicantY;
		Ex = Sx + 476;		//146;
		Ey = Sy + 322;		//175;
		if(MouseX > Sx && MouseX < Ex && MouseY > Sy && MouseY < Ey && !Scrolls[0].bGriped) {
			UpdateScrollPosition(0, 1);
			return true;
		}
	}

	if(Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;

	return false;
}

defaultproperties
{
     UnitSprites(0)=(UL=54.000000,VL=21.000000)
     UnitSprites(1)=(UL=54.000000,VL=21.000000)
     UnitSprites(2)=(UL=54.000000,VL=21.000000)
     Scrolls(0)=(fX=462.000000,fY=-4.000000,ScrollHeight=212.000000)
     Components(0)=(XL=447.000000,YL=261.000000)
}
