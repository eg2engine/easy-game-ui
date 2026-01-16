class CPetMain extends CInterface
	config(CompPos);

var float PageX, PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

var float OffsetXL;
var float OffsetYL;

var float OldTime;
var float TimeAccumulation;

var Texture Face;
var Texture FaceBorder;

var int FaceStatus;
var int nAlpha;
var bool bAlphaDir;

//var float ClickTime; //!@ 2004.2.6 jhjung, DoubleClick time storage

function OnInit()
{
	local PetServerInfo PetSI;

	PageX = float(ConsoleCommand("get ini:SephirothUI.SephirothUI.CPetMain PageX"));
	PageY = float(ConsoleCommand("get ini:SephirothUI.SephirothUI.CPetMain PageY"));


	if(PageX<-1000)
		ResetDefaultPosition();		//2009.10.27.Sinhyub
	bMovingUI = true;	//Layout()에서 창밖을 벗어난 UI를 체크해줄수있도록합니다. 2009.10.29.Sinhyub

	FaceBorder = Texture(DynamicLoadObject("PetUI.Default.PetFaceOutline",class'Texture'));

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

	nAlpha = 155;
	bAlphaDir = false;
}

function SavePos()
{
	ConsoleCommand("set ini:SephirothUI.SephirothUI.CPetMain PageX" @ PageX);
	ConsoleCommand("set ini:SephirothUI.SephirothUI.CPetMain PageY" @ PageY);
}

function OnFlush()
{
	if(SephirothInterface(Parent).bPetTwinkle)  
	{
		SephirothInterface(Parent).bPetChangeable = true;
		SephirothInterface(Parent).bPetTwinkle = false;
	}

	SavePos();
	SaveConfig();
}

function LoadPetfaceTexture()
{
	local PetServerInfo PetSI;
	local string PetName;
	local string PetStatus;
	local string PetFaceTextureName;
	local int Space;
	
	PetSI = ClientController(PlayerOwner).PetSI;
	Space = InStr(PetSI.MeshName,"-");
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


	if(Face != None)
		UnloadTexture(Viewport(PlayerOwner.Player), Face);


//	Face = Texture(DynamicLoadObject(PetFaceTextureName, class'Texture'));
	Face = Texture(DynamicLoadObject("PetUI.icon_Pet", class'Texture'));

	SephirothInterface(Parent).bPetChangeable = false;
	SephirothInterface(Parent).bPetTwinkle = false;

	FaceStatus = PetSI.FaceStatus;	//@by wj(10/08)
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
		else {	
			if (PageX < 0)
			{	
				if(PageX <= -1000)
					PageX = C.ClipX/4 - WinWidth/2 - 20;
				else
					PageX = 0;
			}
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
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);

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

	Super.Layout(C);	
}


function OnPostRender(HUD H, Canvas C)
{
	local int addX;
	local PetServerInfo PetSI;


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
/*	
	// border
	if(SephirothInterface(Parent).bPetTwinkle)
	{
		CurTime = PlayerOwner.Level.TimeSeconds;
		TimeOffset = CurTime - OldTime;
		if( TimeAccumulation < 0.5f)
			TimeAccumulation += TimeOffset;
		else if(TimeAccumulation > 1.f)
			TimeAccumulation = 0;
		else
		{
			C.SetPos(PageX, PageY);
			C.DrawTile(FaceBorder, 66, 66, 0, 0, 66,66);	
			TimeAccumulation += TimeOffset;
		}

		OldTime = CurTime;
	}
	else if(SephirothInterface(Parent).bPetChangeable)
	{
		C.SetPos(PageX, PageY);
		C.DrawTile(FaceBorder, 66, 66, 0, 0, 66,66);
	}
*/

	// 배고픔 게이지별 색 변화
	if(PetSI.FoodGuage < 50)
		BindTextureResource(Components[2],TextureResources[2]);
	else if(PetSI.FoodGuage < 10)
		BindTextureResource(Components[2],TextureResources[3]);
	else
		BindTextureResource(Components[2],TextureResources[1]);


	// 진화 가능 여부
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	if(PetSI.bChange)
	{
		C.SetDrawColor(222,222,222,nAlpha);
		C.DrawKoreanText(Localize("PetUI", "EvolutionAble", "SephirothUI"), Components[0].X + 76, Components[0].Y + 8, 100, 14);

		C.SetDrawColor(255,255,255, nAlpha);
		C.SetPos(Components[0].X + 2, Components[0].Y + 2);
		C.DrawTile(TextureResources[4].Resource,59,59,0,0,59,59);
		C.SetDrawColor(255,255,255,255);
	}
	else
	{
		C.SetDrawColor(126,126,126);
		C.DrawKoreanText(Localize("PetUI", "EvolutionAble", "SephirothUI"), Components[0].X + 76, Components[0].Y + 8, 100, 14);
	}

	// 이름
	addX = 66;	// 실시간 문자열 길이 얻어오면 너무 코스트가 크다 -_- 
	C.SetDrawColor(222,222,222);
	C.DrawKoreanText("Lv " $ PetSI.PetLevel, Components[0].X + addX, Components[0].Y + 24, 100, 14);

	if(PetSI.PetLevel < 10)
		addX += 32;
	else if(PetSI.PetLevel == 100)
		addX += 44;
	else
		addX += 36;

	C.SetDrawColor(255,204,102);
	C.DrawKoreanText(PetSI.GetTitle(), Components[0].X + addX, Components[0].Y + 24, 100, 14);

	// 펫 호칭에 의한 계산된 간격 이격을 실시한다. 로컬라이징시 대략 --- 노가다
	addX += 39;

	C.SetDrawColor(222,222,222);
	C.DrawKoreanText(PetSI.PetName, Components[0].X + addX, Components[0].Y + 24, 100, 14);

	C.SetRenderStyleAlpha();

	// PetFace
	C.SetPos(PageX+8, PageY+8);
	C.DrawTile(Face, 50, 50, 0, 0, 50,50);	
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	/*!@ 2004.2.6 jhjung
		to prevent open PetInterface during loading game
		move DoubleClick to here
		*/
	if (Key == IK_LeftMouse && IsCursorInsideAt(PageX, PageY, WinWidth, WinHeight)) {
		if (Action == IST_Press) {
			bMovingUI = true;
			bIsDragging = true;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return true;
		}
		if (Action == IST_Release) {
			if (ClickTime > 0 && Level.TimeSeconds - ClickTime < 0.25)
				SephirothInterface(Parent).ShowPetInterface();
			else
				ClickTime = Level.TimeSeconds;

			SavePos();
			SaveConfig();
			bIsDragging = false;
			DragOffsetX = 0;
			DragOffsetY = 0;
			return true;
		}
	}
	return false;
}

function bool DoubleClick()
{
	if(IsCursorInsideInterface())
	{
		SephirothInterface(Parent).ShowPetInterface();
		return true;
	}
	return false;
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

	PageX = 400;//(ClipX-WinWidth)/2;
	PageY = 300;//(ClipY-WinHeight)/2;

	SavePos();
	SaveConfig();
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	local PetServerInfo PetSI;
	
	PetSI = ClientController(PlayerOwner).PetSI;

	V.X = 0;
	V.Y = PetSI.FoodGuage;
	V.Z = 100;

	return V;
}

defaultproperties
{
     PageX=400.000000
     PageY=300.000000
     Components(0)=(XL=66.000000,YL=64.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=250.000000,YL=64.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,ResId=1,Type=RES_Gauge,XL=155.000000,YL=8.000000,PivotDir=PVT_Copy,OffsetXL=67.000000,OffsetYL=47.000000,bTextureSegment=True,GaugeDir=GDT_Right)
     TextureResources(0)=(Package="UI_2011",Path="pat_hud_out",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="gauge_blu",UL=155.000000,VL=8.000000,Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="gauge_yell",UL=155.000000,VL=8.000000,Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="gauge_red",UL=155.000000,VL=8.000000,Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="pet_hungry_circle",Style=STY_Alpha)
     WinWidth=66.000000
     WinHeight=66.000000
     bAcceptDoubleClick=True
}
