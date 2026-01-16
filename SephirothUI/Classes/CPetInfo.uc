class CPetInfo extends CInterface
	config(SephirothUI);

var globalconfig float PageX, PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var float OffsetXL;
var float OffsetYL;

var float OldTime;
var float TimeAccumulation;

var string Comment;

const BN_Exit = 10;
const BN_Change = 11;
const CB_PetFace = 100;
const BN_Dialog = 12;

//var Texture PetFaceBorder;
var Texture BlueGauge;
var Texture YellowGauge;
var Texture RedGauge;
var Texture PetUIFace;

var int FaceStatus;

var string m_sTitle;

function OnInit()
{
	local PetServerInfo PetSI;

	if(PageX == -1)
		ResetDefaultPosition();
	bMovingUI = true;	//Layout()���� â���� ��� UI�� üũ���ټ��ֵ����մϴ�. 2009.10.29.Sinhyub

	SetComponentNotify(Components[2], BN_Exit, Self);
	SetComponentTextureId(Components[2],13,0,15,14);
	SetComponentTextureId(Components[3],1,-1,3,2);

	SetComponentNotify(Components[3], BN_Change, Self);
	SetComponentNotify(Components[4], CB_PetFace, Self); 


//	PetFaceBorder = Texture(DynamicLoadObject("PetUI.Default.PetFaceOutline", class'Texture'));

	BlueGauge   = Texture(DynamicLoadObject("UI_2011_btn.gauge_blu", class'Texture'));
	RedGauge    = Texture(DynamicLoadObject("UI_2011_btn.gauge_red", class'Texture'));
	YellowGauge = Texture(DynamicLoadObject("UI_2011_btn.gauge_yell", class'Texture'));

	LoadPetFaceTexture();
	
	PetSI = ClientController(PlayerOwner).PetSI;

	if(PetSI.bChange)
	{
		SephirothInterface(Parent).bPetTwinkle = false;
		SephirothInterface(Parent).bPetChangeable = true;
	}
	else
	{
		SephirothInterface(Parent).bPetTwinkle = false;
		SephirothInterface(Parent).bPetChangeable = false;
	}

	m_sTitle = Localize("PetUI", "Title", "SephirothUI");
}

function LoadPetfaceTexture()
{
	local PetServerInfo PetSI;
//	local string PetName;
//	local string PetStatus;
//	local string PetFaceTextureName;
//	local int Space;
	
	PetSI = ClientController(PlayerOwner).PetSI;
/*	Space = InStr(PetSI.MeshName,"-");
	if(Space != -1)
		PetName = Left(PetSI.MeshName,Space);
	else
		PetName = PetSI.MeshName;

	if(PetSI.FoodGuage < 10)
		PetStatus = "Bad";
	else if(PetSI.FaceStatus < 50)
		PetStatus = "Normal";
	else if(PetSI.FaceStatus < 75)
		PetStatus = "Good";
	else if(PetSI.FaceStatus < 100)
		PetStatus = "VeryGood";

	if(PetName == "Egg")
		PetFaceTextureName = "PetUI.PetFace."$PetName;
	else
		PetFaceTextureName = "PetUI.PetFace."$PetName$"_"$PetStatus;

	if(PetUIFace != None)
		UnloadTexture(Viewport(PlayerOwner.Player), PetUIFace);

	PetUIFace = Texture(DynamicLoadObject(PetFaceTextureName, class'Texture'));
*/	// �ӽ÷� ����- �� ��
	PetUIFace = Texture(DynamicLoadObject("PetUI.icon_Pet", class'Texture'));

	SephirothInterface(Parent).bPetChangeable = false;
	SephirothInterface(Parent).bPetTwinkle = false;

	FaceStatus = PetSI.FaceStatus;	//@by wj(10/08)
}


function OnFlush()
{
	if(SephirothInterface(Parent).bPetTwinkle)
	{
		SephirothInterface(Parent).bPetChangeable = true;
		SephirothInterface(Parent).bPetTwinkle = false;
	}
	SaveConfig();
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
			if (PageX < 32)
				PageX = 0;
			if (PageY < 32)
				PageY = 0;
			if (PageX + WinWidth > C.ClipX - 32)
				PageX = C.ClipX - WinWidth;
			if (PageY + WinHeight > C.ClipY - 32)
				PageY = C.ClipY - WinHeight;
		}
		else
		{
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

	MoveComponent(Components[0],true,PageX,PageY);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);

	Super.Layout(C);
}	

function OnPreRender(Canvas C)
{
//	DrawBackGround(C);
	DrawBackGround3x3(C, 64, 64, 4, 5, 6, 7, 8, 9, 10, 11, 12);
	DrawTitle(C, m_sTitle);
}

function OnPostRender(HUD H, Canvas C)
{
	local int X, Y;
	local int PetFoodGauge; 
	local PlayerServerInfo PSI;
	local PetServerInfo PetSI;


	X = Components[0].X;
	Y = Components[0].Y;

	PSI = SephirothPlayer(PlayerOwner).PSI;
	PetSI = ClientController(PlayerOwner).PetSI;

	//@by wj(10/08)------
	if(PetSI.FaceStatus != FaceStatus)
		LoadPetfaceTexture();
	//-------------------

	if(PetSI.bChange)
	{
		if(SephirothInterface(Parent).bPetTwinkle == false && SephirothInterface(Parent).bPetChangeable == true)
		{
			SephirothInterface(Parent).bPetTwinkle = false;
			SephirothInterface(Parent).bPetChangeable = true;
		}
		else if(SephirothInterface(Parent).bPetTwinkle == false)
		{
			SephirothInterface(Parent).bPetTwinkle = true;
		}
	}

	// border
/*	if(SephirothInterface(Parent).bPetTwinkle)
	{
		CurTime = PlayerOwner.Level.TimeSeconds;
		TimeOffset = CurTime - OldTime;
		if( TimeAccumulation < 0.5f)
			TimeAccumulation += TimeOffset;
		else if(TimeAccumulation > 1.f)
			TimeAccumulation = 0;
		else
		{
			C.SetPos(PageX+16, PageY+47);
			C.DrawTile(PetFaceBorder, 66, 66, 0, 0, 66,66);	
			TimeAccumulation += TimeOffset;
		}

		OldTime = CurTime;
	}
	else if(SephirothInterface(Parent).bPetChangeable)
	{
		C.SetPos(PageX+16, PageY+47);
		C.DrawTile(PetFaceBorder, 66, 66, 0, 0, 66,66);			
	}
*/
	// PetFace
	C.SetPos(X+24, Y+44);
	C.DrawTile(PetUIFace, 50, 50, 0, 0, 50,50);	

	// Gauge
	C.SetPos(X+62, Y+140);
	PetFoodGauge = PetSI.FoodGuage;
	if( PetFoodGauge > 50)       
	{
		Comment = "Normal";		
		C.DrawTile(BlueGauge,PetFoodGauge*1.55,8,
					(100-PetFoodGauge)*100/155,0,
					PetFoodGauge*1.55,8);
	}
	else if(PetFoodGauge > 10)   
	{
		Comment = "Hungry";
		C.DrawTile(YellowGauge,PetFoodGauge*1.55,8,(100-PetFoodGauge)*100/155,0,PetFoodGauge*1.55,8);
	}
	else if(PetFoodGauge >= 0 && PetFoodGauge <= 10)
	{
		Comment = "Hungry";
		C.DrawTile(RedGauge,PetFoodGauge*1.55,8,(100-PetFoodGauge)*100/155,0,PetFoodGauge*1.55,8);
	}
	
	// text
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(PetSI.PetName, X+133, Y+41, 100, 14);		// �� �̸�
	C.DrawKoreanText(PetSI.PetLevel, X+133, Y+62, 100, 14);		// �� ����
	C.DrawKoreanText(PetSI.GetTitle(), X+133, Y+84, 100, 14);	// �� ģ�� ����
	C.DrawKoreanText(Localize("PetUI",PetSI.MeshName,"SephirothUI"), X+133, Y+106, 100, 14);	// Pet ����  

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	C.SetDrawColor(229,201,174);

	C.DrawKoreanText(Localize("PetUI","PetName","SephirothUI"), X+94, Y+41, 50, 14);
	C.DrawKoreanText(Localize("PetUI","PetLevel","SephirothUI"), X+94, Y+62, 50, 14);
	C.DrawKoreanText(Localize("PetUI","PetState","SephirothUI"), X+94, Y+84, 50, 14);
	C.DrawKoreanText(Localize("PetUI","PetType","SephirothUI"), X+94, Y+106, 50, 14);

	C.DrawKoreanText(Localize("PetUI","State","SephirothUI"), X+21, Y+136, 50, 14);			// Pet State ( �����, ���� )

	C.DrawKoreanText(Localize("PetUI","PointHP","SephirothUI"), X+21, Y+165, 50, 14);	// "���� Point"
	C.DrawKoreanText(Localize("PetUI","PointAttack","SephirothUI"), X+21, Y+186, 50,14);	// "�κ� Point"
	C.DrawKoreanText(Localize("PetUI","PointMP","SephirothUI"), X+136, Y+165, 50, 14);		// "HP Point"
	C.DrawKoreanText(Localize("PetUI","PointInven","SephirothUI"), X+136, Y+186, 50, 14);		// "MP Point"
	C.DrawKoreanText(Localize("PetUI","PetPoint","SephirothUI"), X+21, Y+217, 50, 14);		// "�� Point"

	C.DrawKoreanText(Localize("PetUI","Simple","SephirothUI"), X+170, Y+247, 50, 14);		// "�� Point"

	if(PetSI.bChange)
	{
		C.SetDrawColor(255,255,255);
		C.DrawKoreanText(Localize("PetUI","EvolutionAble","SephirothUI"), X+25, Y+103, 50, 14);
	}
	else
	{
		C.SetDrawColor(103,102,102);
		C.DrawKoreanText(Localize("PetUI","EvolutionAble","SephirothUI"), X+25, Y+103, 50, 14);
	}

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(PetSI.PointHP, X+95, Y+165, 33, 14);	
	C.DrawKoreanText(PetSI.PointAttack, X+95, Y+186, 33, 14);
	C.DrawKoreanText(PetSI.PointMP, X+199, Y+165, 33, 14);										// MP Point									
	C.DrawKoreanText(PetSI.PointInven, X+199, Y+186, 33, 14);									// �κ� Point

	C.DrawKoreanText(PetSI.PetPoint, X+95, Y+217, 33, 14);


}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if(Key == IK_LeftMouse && IsCursorInsideComponent(Components[0])) {
		if(Action == IST_Press)	{	
			bMovingUI = true;
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		
		else if(Action == IST_Release) {
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
}


function bool PushComponentBool(int CmpId)
{
	switch (CmpId) {
		case 4: return SephirothInterface(Parent).m_PetMain != None;
	}
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Exit)
		Parent.NotifyInterface(Self,INT_Close);
	else if(NotifyId == CB_PetFace)
	{
		if(Command == "Checked")
		{
			if(SephirothInterface(Parent).m_PetMain == None)
				SephirothInterface(Parent).ShowPetFace();
		}
		else if(Command == "UnChecked")
			SephirothInterface(Parent).HidePetFace();
	}
	else if(NotifyId == BN_Change)
	{
		SephirothPlayer(PlayerOwner).Net.NotiPetToCage();
		Parent.NotifyInterface(Self, INT_Close);
	}
	else if(NotifyId == BN_Dialog)
	{
		//Log("=====>NotiPetChatInfo");
		SephirothPlayer(PlayerOwner).Net.NotiPetChatInfo();
	}
}

function ResetDefaultPosition()		//2009.10.27.Sinhyub
{
	PageX=6;
	PageY=160;
}

defaultproperties
{
     PageX=-1.000000
     PageY=-1.000000
     Components(0)=(XL=254.000000,YL=278.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=228.000000,YL=208.000000,PivotDir=PVT_Copy,OffsetXL=14.000000,OffsetYL=33.000000)
     Components(2)=(Id=2,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=217.000000,OffsetYL=13.000000,HotKey=IK_Escape)
     Components(3)=(Id=3,Caption="Change",Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=238.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Terms)
     Components(4)=(Id=4,Type=RES_CheckButton,XL=130.000000,YL=26.000000,PivotDir=PVT_Copy,OffsetXL=145.000000,OffsetYL=243.000000,LocType=LCT_Setting)
     TextureResources(0)=(Package="UI_2011",Path="pat_win_info",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_x_c",Style=STY_Alpha)
     WinWidth=254.000000
     WinHeight=278.000000
}
