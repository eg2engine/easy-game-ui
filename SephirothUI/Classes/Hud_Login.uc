class Hud_Login extends CDesktop;

const BN_Login = 1;
const BN_Account = 2;
const BN_Exit = 3;
const EN_Username = 4;
const EN_Password = 5;
const BN_WebShop = 6; //add neive : 웹상점

var ConnectProgress Progress;
var Texture T_Crusade[8];
//var Texture T_AgeLimit; //del neive : 등급표시 이미지 변경으로 삭제
var float fLogoScale;
var float fLogoDuration;
var float r,g,b;
var const float CinematicsRatioMin;
var const float CinematicsRatioMax;
var float CinematicsRatio;

//var SepEditBox AccountEdit, PasswordEdit;
var CImeEdit AccountEdit, PasswordEdit;

function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[0],true,(C.ClipX-Components[i].XL)/2,(C.ClipY-Components[i].YL)*23.0/24.0);
	for (i=1;i<Components.Length;i++) {
		MoveComponent(Components[i]);
	}
	Super.Layout(C);
}

function OnInit()
{
	local int i;
	local string TName;
	local string LangExt;
	local string LogoPackage;

	LangExt = PlayerOwner.ConsoleCommand("LangExt");
	if (LangExt == "Chn")
		LogoPackage = "LogoChn";
	else
		LogoPackage = "Logo"; //@cs changed
		//LogoPackage = "LogoChn";

	SetComponentNotify(Components[4],BN_Login,Self);
	SetComponentNotify(Components[5],BN_Account,Self);
	SetComponentNotify(Components[6],BN_Exit,Self);

	SetComponentTextureId(Components[4],1,2,3,4);
	SetComponentTextureId(Components[5],1,2,3,4);
	SetComponentTextureId(Components[6],1,2,3,4);


	for (i=0;i<8;i++) {
		TName = LogoPackage $ ".Logo_S";
		TName = TName $ i/4;
		TName = TName $ int(i%4);
		CreateTexture(Viewport(PlayerOwner.Player),TName,T_Crusade[i]);
	}

	//del neive : 등급표시 이미지 변경으로 삭제
	/*
	if( GetServiceFlags() == SF_KoreaAdult )
		CreateTexture(Viewport(PlayerOwner.Player),"Logo.Logo15",T_AgeLimit);
	else
		CreateTexture(Viewport(PlayerOwner.Player),"Logo.Logo15",T_AgeLimit);
	*/
	Controller.bActive = true;

}

function OnFlush()
{
	local int i;
	for (i=0;i<8;i++)
		DeleteTexture(Viewport(PlayerOwner.Player),T_Crusade[i]);
//	DeleteTexture(Viewport(PlayerOwner.Player),T_AgeLimit); //del neive : 등급표시 이미지 변경으로 삭제
}

state ShowLogo
{
	function BeginState()
	{
		//SepPlayerController(PlayerOwner).bNoDrawWorld = true;
		PlayerOwner.bNoDrawWorld = true;

		CinematicsRatio = CinematicsRatioMin;
		PlayerOwner.ConsoleCommand("CINEMATICSRATIO"@CinematicsRatio);
		if (PlayerOwner.Pawn != None)
			PlayerOwner.Pawn.bHidden = true;
	}
	function Render(Canvas C)
	{
		local int i;
		local int TextureWidth,TextureHeight;
		local int ScreenX,ScreenY;

		if (Level.TimeSeconds < fLogoDuration) {
			r = FClamp((Level.TimeSeconds/fLogoDuration)**2,0.0,1.0);
			g = r;
			b = g;
			C.DrawColor.R = 255 - 255*r;
			C.DrawColor.G = 255 - 255*g;
			C.DrawColor.B = 255 - 255*b;
			C.DrawColor.A = 255;
		}
		else {
			GotoState('Opening');
			return;
		}
		TextureWidth = min(C.ClipX/4.0,256.0) * fLogoScale;
		TextureHeight = TextureWidth;
		ScreenX = C.ClipX/2.0+TextureWidth*(-2.0);
		ScreenY = (C.ClipY * 11.0/12.0)/2.0 - TextureHeight;
		for (i=0;i<8;i++) {
			C.SetPos(ScreenX+TextureWidth*(i%4), ScreenY+TextureHeight * (i/4));
			C.DrawTile(T_Crusade[i],TextureWidth,TextureHeight,0,0,256,256);
		}
	}
}

state Opening
{
	function BeginState()
	{
		PlayerOwner.ClientSetMusic("Opening.ogg", MTRAN_SlowFade);
	}
	function bool KeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
	{
		if (Action == IST_Press) {
			return true;
		}
		if (Action == IST_Release) {
			GotoState('ShutdownOpening');
			return true;
		}
		return false;
	}
	function Render(Canvas C)
	{
		PlayerOwner.ConsoleCommand("CINEMATICS 1");
		//if (SepPlayerController(PlayerOwner).bNoDrawWorld)
		//	SepPlayerController(PlayerOwner).bNoDrawWorld = false;
		if (Playerowner.bNoDrawWorld)
			PlayerOwner.bNoDrawWorld = false;
	}
}

state ShutdownOpening
{
	function BeginState()
	{
		CinematicsRatio = CinematicsRatioMin;
	}
	function Render(Canvas C)
	{
		PlayerOwner.ConsoleCommand("CINEMATICS 1");
		CinematicsRatio = Clamp(CinematicsRatio+CinematicsRatio*2.f/3.f,CinematicsRatioMin,CinematicsRatioMax);
		PlayerOwner.ConsoleCommand("CINEMATICSRATIO"@CinematicsRatio);
		if (CinematicsRatio >= CinematicsRatioMax)
			GotoState('LoginMenu');
	}
}

state auto LoginMenu
{
	function BeginState()
	{
		//SepPlayerController(PlayerOwner).bNoDrawWorld = true;
		PlayerOwner.bNoDrawWorld = true;
		PlayerOwner.ClientSetMusic("Select.ogg", MTRAN_FastFade);

		//AccountEdit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
		AccountEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
		if (AccountEdit != None) {
			AccountEdit.bNative = false;
			AccountEdit.SetMaxWidth(20);
			AccountEdit.SetSize(104, 26);
			//AccountEdit.SetSize(148, 26);
			AccountEdit.ShowInterface();

		}

		//PasswordEdit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
		PasswordEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
		if (PasswordEdit != None) {
			PasswordEdit.bNative = false;
			PasswordEdit.bMaskText = true;
			PasswordEdit.SetMaxWidth(20);
			PasswordEdit.SetSize(148, 26);
			PasswordEdit.ShowInterface();
		}
	}
	function EndState()
	{
		if (AccountEdit != None) {
			AccountEdit.HideInterface();
			RemoveInterface(AccountEdit);
			AccountEdit = None;
		}

		if (PasswordEdit != None) {
			PasswordEdit.HideInterface();
			RemoveInterface(PasswordEdit);
			PasswordEdit = None;
		}
	}
	function OnPreRender(Canvas C)
	{
		local int i;
		local int TextureWidth,TextureHeight;
		local int ScreenX,ScreenY;
		local Color Color;
		Color = C.DrawColor;
		fLogoScale = 0.9;
		C.SetDrawColor(255,255,255);
		TextureWidth = min(C.ClipX/4.0,256) * fLogoScale;
		TextureHeight = TextureWidth;
		ScreenX = C.ClipX/2+TextureWidth*(-2);
		//ksshim ... 2004.6.30
		//ScreenY = (C.ClipY * 11.0/12.0)/2.0 - TextureHeight;
		ScreenY = (C.ClipY * 9.0/12.0)/2.0 - TextureHeight;
		for (i=0;i<8;i++) {
			C.SetPos(ScreenX+TextureWidth*(i%4), ScreenY+TextureHeight * (i/4));
			C.DrawTile(T_Crusade[i],TextureWidth,TextureHeight,0,0,256,256);
		}
		C.DrawColor = Color;


		//class'CMessageBox'.static.MessageBox(Self,"Disconnected","꿎桿櫓匡test!!!",MB_Ok);
		if(Level.TimeSeconds > 300) //add neive : 로그인 화면에서 5분간 로그인하지 않으면 강제 종료
			class'CMessageBox'.static.MessageBox(Self,"Disconnected",Localize("Modals","BanGhost","Sephiroth"),MB_Ok, BN_Exit);
			
//		C.DrawKoreanText("Sec :"$Level.TimeSeconds, 0, 0, 100, 18);
	}

	function Layout(Canvas C)
	{
		local float xOffset, yOffset;

		Global.Layout(C);
		if (AccountEdit != None) {
			xOffset = Components[0].X + 98;
			yOffset = Components[0].Y + 35;
			AccountEdit.SetPos(int(xOffset), int(yOffset));
			AccountEdit.SetSize(148,26);
		}
		if (PasswordEdit != None) {
 			xOffset = Components[0].X + 98;
 			yOffset = Components[0].Y + 69;
			PasswordEdit.SetPos(int(xOffset), int(yOffset));
			PasswordEdit.SetSize(148, 26);
		}
	}

	function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
	{
		if (Progress != None && !Progress.bDeleteMe)
			return false;

		if (Key == IK_Tab && Action == IST_Press) {
			if (!AccountEdit.HasFocus() && !PasswordEdit.HasFocus())
				AccountEdit.SetFocusEditBox(true);
			else if (AccountEdit.HasFocus() && !PasswordEdit.HasFocus()) {
				AccountEdit.SetFocusEditBox(false);
				PasswordEdit.SetFocusEditBox(true);
			}
			else if (!AccountEdit.HasFocus() && PasswordEdit.HasFocus()) {
				PasswordEdit.SetFocusEditBox(false);
				AccountEdit.SetFocusEditBox(true);
			}
			return true;
		}
		if (Key == IK_Enter && Action == IST_Press) {
			if (!AccountEdit.HasFocus() && AccountEdit.GetText() == "") {
				if (PasswordEdit.HasFocus())
					PasswordEdit.SetFocusEditBox(false);
				AccountEdit.SetFocusEditBox(true);
			}
			else if (!PasswordEdit.HasFocus() && PasswordEdit.GetText() == "") {
				if (AccountEdit.HasFocus())
					AccountEdit.SetFocusEditBox(false);
				PasswordEdit.SetFocusEditBox(true);
			}
			else if (PasswordEdit.GetText() != "" && AccountEdit.GetText() != "") {
				if (PasswordEdit.HasFocus())
					PasswordEdit.SetFocusEditBox(false);
				if (AccountEdit.HasFocus())
					AccountEdit.SetFocusEditBox(false);
				LoginGame();
			}
			return true;
		}
		if (Key == IK_LeftMouse && Action == IST_Press) {
			if (!AccountEdit.HasFocus() && AccountEdit.IsInBounds()) {
				if (PasswordEdit.HasFocus())
					PasswordEdit.SetFocusEditBox(false);
				AccountEdit.SetFocusEditBox(true);
				return true;
			}
			else if (!PasswordEdit.HasFocus() && PasswordEdit.IsInBounds()) {
				if (AccountEdit.HasFocus())
					AccountEdit.SetFocusEditBox(false);
				PasswordEdit.SetFocusEditBox(true);
				return true;
			}
			else {
				if (AccountEdit.HasFocus() && !AccountEdit.IsInBounds())
					AccountEdit.SetFocusEditBox(false);
				if (PasswordEdit.HasFocus() && !PasswordEdit.IsInBounds())
					PasswordEdit.SetFocusEditBox(false);
				return false;
			}
		}
		if (!AccountEdit.HasFocus() && !PasswordEdit.HasFocus() && ((Key >= IK_0 && Key <= IK_9) || (Key >= IK_A && Key <= IK_Z)) && Action == IST_Press) {
			AccountEdit.SetFocusEditBox(true);
			return true;
		}
		return false;
	}

	function NotifyComponent(int ComponentId,int NotifyId,optional string Command)
	{
		local string URL;

		//add neive : 외부 런칭 -----------------------------------------------
		local string ServerHost;
		local int ServerPort;
		local int lidx;

		Game_Login(Level.Game).GameServerInfo(ServerHost,ServerPort);

		if(ServerPort > 10000)
		{
			lidx = ServerPort % 100;
		}
		//---------------------------------------------------------------------

		switch (NotifyId) {

		case BN_Login:
			LoginGame();
			break;

		case BN_Account: //중요 neive : 웹페이지 띄우는 비밀이...
			Game_Login(Level.Game).GetHomeURL(URL, lidx);
			PlayerOwner.ClientTravel(URL,TRAVEL_Absolute,false);
			break;

		//add neive : 웹상점 --------------------------------------------------
		case BN_WebShop:
			Game_Login(Level.Game).GetHomeURL(URL, lidx);
			PlayerOwner.ClientTravel(URL,TRAVEL_Absolute,false);
			break;

		//---------------------------------------------------------------------

		case BN_Exit:
			QuitGame();
			break;
		}
	}

	function LoginGame()
	{
		local bool bDelayLoginGame;

		bDelayLoginGame = bool(ConsoleCommand("IsLoginSepGame"));

		//if(!bDelayLoginGame)
		//{
		//	class'CMessageBox'.static.MessageBox(Self,"로그인 지연","로그인 정보를 정리 중입니다.",MB_Ok);
		//	return;
		//}

		//Log("TEST LOGIN GAME"@bDelayLoginGame);
		//class'CMessageBox'.static.MessageBox(Self,"cs log in","result",MB_Ok);

		Progress = ConnectProgress(AddInterface("SephirothUI.ConnectProgress"));
		if (Progress != None) {
			Progress.bDelayConnect = bDelayLoginGame;
			bHideAllComponets = true;
			//SepPlayerController(PlayerOwner).bNoDrawWorld = true;
			PlayerOwner.bNoDrawWorld = true;
			Progress.UserName = AccountEdit.GetText();
			Progress.Password = PasswordEdit.GetText();
			Progress.ShowInterface();
			AccountEdit.HideInterface();
			PasswordEdit.HideInterface();
		}
	}

	function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
	{
		if (Interface == Progress && NotifyId == INT_Close) {
			Progress.HideInterface();
			RemoveInterface(Progress);
			Progress = None;
			bHideAllComponets = false;
			AccountEdit.ShowInterface();
			PasswordEdit.ShowInterface();
		}

		//add neive : 로그인 화면에서 3분간 로그인하지 않으면 강제 종료 -------
		if(NotifyId == INT_MessageBox)
			if(int(Command) == BN_Exit)
				QuitGame();
		//---------------------------------------------------------------------
	}

	function OnPostRender(HUD H, Canvas C)
	{
		C.SetPos(C.ClipX-85,0);
		C.SetRenderStyleAlpha();
		//C.DrawTile(T_AgeLimit, 85, 85, 0, 0, 85, 85); //del neive : 등급표시 이미지 변경으로 삭제
	}
}

function LaunchAccountBrowser()
{
	local string URL;
	Game_Login(Level.Game).GetHomeURL(URL, Progress.LaunchingIndex);
	PlayerOwner.ClientTravel(URL,TRAVEL_Absolute,false);
}

function QuitGame()
{
	PlayerOwner.ConsoleCommand("Quit");
}

function ConnectTick(float Current,float Limit)
{
	if (Progress != None && !Progress.bDeleteMe)
		Progress.ConnectTick(Current, Limit);
}

function SetLoginResult(string Result, int Reason)
{
	if (Progress != None && !Progress.bDeleteMe) {
		Progress.LoginResult = Result;
//		Progress.LoginFailReason = Reason;
	}
}

function Render(Canvas C)
{
	Super.Render(C);
}

function ClearTooltip()
{
	Super.ClearTooltip();
}

defaultproperties
{
     fLogoScale=1.000000
     fLogoDuration=6.000000
     R=1.000000
     G=1.000000
     B=1.000000
     CinematicsRatioMin=1.660000
     CinematicsRatioMax=128.000000
     Components(0)=(XL=265.000000,YL=207.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=265.000000,YL=207.000000,PivotDir=PVT_Copy)
     Components(2)=(Id=2,Caption="UserName",Type=RES_Text,XL=74.000000,YL=28.000000,PivotDir=PVT_Copy,OffsetXL=16.000000,OffsetYL=34.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255),LocType=LCT_Terms)
     Components(3)=(Id=3,Caption="UserKey",Type=RES_Text,XL=74.000000,YL=28.000000,PivotId=2,PivotDir=PVT_Down,OffsetYL=6.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255),LocType=LCT_Terms)
     Components(4)=(Id=4,Caption="Login",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotDir=PVT_Copy,OffsetXL=63.000000,OffsetYL=110.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(5)=(Id=5,Caption="NewAccount",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=4,PivotDir=PVT_Down,OffsetYL=4.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(6)=(Id=6,Caption="Exit",Type=RES_PushButton,XL=126.000000,YL=22.000000,PivotId=5,PivotDir=PVT_Down,OffsetYL=2.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2009",Path="Win05_01",UL=265.000000,VL=207.000000,Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN02_04_N",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN02_04_D",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="BTN02_04_P",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2009",Path="BTN02_04_O",Style=STY_Alpha)
}
