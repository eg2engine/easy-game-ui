class CLobby extends CDesktop
	config(CompData);

// 大厅界面逻辑入口，负责角色选择与登录交互
const MAX_CREATE_PLAYER_NUM = 5;	// add neive: 可创建角色的最大数量

const BN_Back=1;
const BN_Start=2;
const BN_Delete=3;
const BN_New=4;
const BN_Option=5;
const BN_Quit=6;

const BN_CharA=7;
const BN_CharB=8;
const BN_CharC=9;
const BN_CharD=10;
const BN_CharE=11;


const IDM_DeleteCharacter=1;
const IDM_QuitGame=2;
const IDM_JobChange=3;
const IDM_ConfirmBare=4;
const IDM_ConfirmOneHand=5;
const IDS_DeleteCharacter = 6;

var config BackgroundData BkgData[10];

var Actor PointingAt;
var Hero SelectedHero;
var vector PlayerLocation;

// 缓存其他界面实例
var COption Option;
var CLobbyNewCharacter NewCharacter;

var bool bAlreadyDisconnected;

// 记录点击与心跳的时间戳
var float ClickEventTime;
var float PingTime;

// 当前选中角色的索引与名称
var int nSelectedCharacter;
var string sSelectedCharacterName;

var float m_LastDeleteTime;	// 控制删除角色的冷却时间

// 初始化大厅界面组件、背景以及按钮事件
function OnInit()
{
	// 停止过场与角色动画通知，并播放选角音乐
	PlayerOwner.ConsoleCommand("CINEMATICS 0");
	ConsoleCommand("NOTIFYANIMSTEP 0");
	PlayerOwner.ClientSetMusic("Select.ogg", MTRAN_FastFade);

	// 绑定主要按钮的回调
	SetComponentNotify(Components[1],BN_Start,Self);
	SetComponentNotify(Components[2],BN_New,Self);
	SetComponentNotify(Components[3],BN_Delete,Self);
//	SetComponentNotify(Components[4],BN_Back,Self);
//	SetComponentNotify(Components[5],BN_Option,Self);
	SetComponentNotify(Components[6],BN_Quit,Self);

	// 绑定角色卡槽按钮的回调
	SetComponentNotify(Components[7],BN_CharA,Self);
	SetComponentNotify(Components[8],BN_CharB,Self);
	SetComponentNotify(Components[9],BN_CharC,Self);
	SetComponentNotify(Components[10],BN_CharD,Self);
	SetComponentNotify(Components[11],BN_CharE,Self);

	Controller.bActive = true;

	// 切换场景后重置鼠标外观，避免光标异常
	if(PlayerOwner.Player.gamestate != PlayerOwner.Player.GM_Normal)		//modified by yj
		ClientController(PlayerOwner).CursorToNormal();

	ClickEventTime = Level.TimeSeconds;
	PingTime = Level.TimeSeconds;

	// 初始化背景资源并匹配界面组件
	InitBackground(BkgData);
	MoveBackground(-1, -1);
	MatchComponentFromBackground();

	// 设置按钮的贴图状态
	SetComponentTextureID(Components[1], 0, 1, 3, 2);
	SetComponentTextureID(Components[2], 0, 1, 3, 2);
	SetComponentTextureID(Components[3], 0, 1, 3, 2);
	SetComponentTextureID(Components[6], 4, 5, 7, 6);

	SetComponentTextureID(Components[7], 8, -1, 10, 10);
	SetComponentTextureID(Components[8], 8, -1, 10, 10);
	SetComponentTextureID(Components[9], 8, -1, 10, 10);
	SetComponentTextureID(Components[10], 8, -1, 10, 10);
	SetComponentTextureID(Components[11], 8, -1, 10, 10);

	PlayerOwner.SetFOV(79);
}

// 清理界面资源并刷新配置
function OnFlush()
{
	SaveConfig();

	ConsoleCommand("NOTIFYANIMSTEP 1");
}

// 根据当前鼠标位置挑选场景中的可选角色
function SelectCharacter()
{
	local vector CameraLocation,Direction,MousePos;
	local vector HitLocation,HitNormal;

	CameraLocation = PlayerOwner.Location;
	MousePos.X = PlayerOwner.Player.WindowsMouseX;
	MousePos.Y = PlayerOwner.Player.WindowsMouseY;

	Direction = ScreenToWorld(MousePos);

	// 从屏幕坐标向场景发射射线，确认指向的对象
	PointingAt = TraceEx(HitLocation,HitNormal,TCST_Reserved0,CameraLocation+1000.f*Direction,CameraLocation);

	SelectedHero = Hero(PointingAt);
	if (SelectedHero != None) {
		// 为展示角色加载各个演示技能动画
		SelectedHero.SetDemoSkillBook(0,CLobbyInfo(Level.Game).BareHandSkillAnimation);
		SelectedHero.SetDemoSkillBook(1,CLobbyInfo(Level.Game).BareFootSkillAnimation);
		SelectedHero.SetDemoSkillBook(2,CLobbyInfo(Level.Game).OneHandSkillAnimation);
		SelectedHero.SetDemoSkillBook(3,CLobbyInfo(Level.Game).StaffSkillAnimation);
		SelectedHero.SetDemoSkillBook(4,CLobbyInfo(Level.Game).BowSkillAnimation);
		//SelectedHero.PlayRandomSkillAnim();
	}
	else
		SelectedHero = None;
}

// 处理键鼠输入，双击或按键触发相应操作
function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	ClickEventTime = Level.TimeSeconds;

	if (Key == IK_LeftMouse)
	{
		switch (Action)
		{
		case IST_Press:
			// 鼠标双击同一位置则直接开始游戏
			if (Level.TimeSeconds - ClickTime <= 0.35 && ClickX == PlayerOwner.Player.WindowsMouseX && ClickY == PlayerOwner.Player.WindowsMouseY)
			{
				NotifyComponent(0,BN_Start);
				return true;
			}

			ClickTime = Level.TimeSeconds;
			ClickX = PlayerOwner.Player.WindowsMouseX;
			ClickY = PlayerOwner.Player.WindowsMouseY;
			SelectCharacter();
			return true;
		}
	}

	if (Action == IST_Press)
	{
		switch (Key)
		{
		case IK_Q:case IK_W:case IK_E:case IK_S:case IK_A:case IK_D:
			// 阻止在聊天或输入状态下误触 WASD
			if (!PlayerOwner.Player.Console.bTyping && !Controller.bProcessingKeyType)
				return true;
		case IK_F2:case IK_F3:case IK_F4:
			return true;
		}
	}
	return false;
}

// 根据背景布局刷新组件位置与可见性
function Layout(Canvas C)
{
	local int i, cx, cy;
	local int y;

	cx = Components[0].X;
	cy = Components[0].Y;

	// 摆放主按钮
	MoveComponent(Components[1],true,cx + 19, cy + Components[0].YL - Components[1].YL - 19);
	MoveComponent(Components[2],true,cx + Components[0].XL - Components[2].XL - 19,
										cy + Components[0].YL - Components[2].YL - 19);
	MoveComponent(Components[3],true,cx + 19, cy + Components[0].YL + 10);
	MoveComponent(Components[6],true,cx + Components[0].XL - Components[3].XL - 19,
										cy + Components[0].YL + 10);
	for(i=BN_CharA; i<=BN_CharE; i++)
	{
		y = ((i-BN_CharA) * Components[i].YL) + ((i-BN_CharA) * 8);
		MoveComponent(Components[i],true,cx + Components[0].XL/2 - Components[i].XL/2,cy + 20 + y);
	}

	// 当前无选中角色时尝试自动选中第一个角色
	if(Level.Second - m_LastDeleteTime > 1)
		if(nSelectedCharacter == -1 && bHideAllComponets == false)
			if(bool(ConsoleCommand("CharacterSelect 0")))
				nSelectedCharacter = 0;

	// 创建角色界面打开时隐藏主界面组件
	if(NewCharacter != None)
		bHideAllComponets = true;
	else
		bHideAllComponets = false;

	Super.Layout(C);
}

// 布局完成后同步按钮状态与角色位置
function OnPreRender(Canvas C)
{
	local int HeroCount;
	local bool bLoaded;

	bLoaded = bool(ConsoleCommand("IsCharacterLoaded"));
	HeroCount = int(ConsoleCommand("GETLOBBYPLAYERNUM"));
	if (bLoaded) {
		if (SelectedHero != None) {
			PlayerLocation = Controller.WorldToScreen(SelectedHero.Location,PlayerOwner.Location,PlayerOwner.Rotation);
			PlayerLocation.X -= 209/2;
			PlayerLocation.Y -= C.ClipY/6+211;	//121+40 +50 2009.10.20.Sinhyub
		}
	}

	// 根据状态启用或禁用按钮
	EnableComponent(Components[1],nSelectedCharacter != -1 && bLoaded);
	EnableComponent(Components[2],HeroCount < MAX_CREATE_PLAYER_NUM && bLoaded);
	EnableComponent(Components[3],nSelectedCharacter != -1 && bLoaded);
	//EnableComponent(Components[4],bool(ConsoleCommand("ISAUTHCONNECT")) == false);
}

// 绘制角色列表、服务器信息与提示文本
function OnPostRender(HUD H, Canvas C)
{
	local int HeroCount;
	local bool bLoaded;
	local string ServerGroup;
	local int ServerIndex;
	local int i, x, y, alpha;
	local string sTemp, sCharName;

	if(bHideAllComponets)
		return;

	bLoaded = bool(ConsoleCommand("IsCharacterLoaded"));
	HeroCount = int(ConsoleCommand("GETLOBBYPLAYERNUM"));

	C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);

	if (bLoaded)
	{
//		if (SelectedHero == None)
//			if (Level.TimeSeconds - int(Level.TimeSeconds) < 0.5)
//				C.SetDrawColor(255,255,0);
	}
	else
	{
		// 未加载完毕时提示角色数据正在同步
		C.SetDrawColor(255,255,255);
		C.DrawKoreanText(Localize("LobbyMenu","DownloadingCharacter","Sephiroth"),0,C.ClipY/2-200,C.ClipX,20);
	}

	if(false) // for debug
	{
		C.DrawKoreanText("�������� ĳ����: " $ nSelectedCharacter $ " " $ sSelectedCharacterName, 0, 0, Components[i].XL, Components[i].YL - y);
	}

	// 绘制角色按钮上的角色信息 --------------------------------------------
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	y = 4;
	x = 10;
	for(i=BN_CharA; i<=BN_CharE; i++)
	{
		C.SetDrawColor(255,255,255);
		if(i-BN_CharA < HeroCount)				// 有效角色槽位
			Components[i].bVisible = true; //Components[i].bDisabled = false;
		else									// 空槽位
		{
			Components[i].bVisible = false; //Components[i].bDisabled = true;

//			C.SetDrawColor(255,0,0);
//			C.KTextFormat = ETextAlign.TA_MiddleCenter;
//			C.DrawKoreanText(Localize("Lobby", "CreateAble", "SephirothUI"), Components[i].X, Components[i].Y, Components[i].XL, Components[i].YL - y);
			continue;
		}

		sCharName = ConsoleCommand("GetCharName " $ (i-BN_CharA));

		alpha = 100;
		if(i-BN_CharA == nSelectedCharacter)	// 当前槽位已被选中
		{
			alpha = 255;
			sSelectedCharacterName = sCharName;
			C.SetPos(Components[i].X, Components[i].Y);
			if(IsCursorInsideComponent(Components[i]))
			{
				C.SetDrawColor(255,255,0); //C.SetDrawColor(255,255,255);
				C.DrawTile(TextureResources[11].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
			}
			else
			{
				C.SetDrawColor(255,255,255);
//				C.DrawTile(TextureResources[10].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
				C.DrawTile(TextureResources[11].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
			}
		}

		// 绘制角色的名称、等级和最近登录时间
		C.SetDrawColor(249,208,32,alpha);
		C.KTextFormat = ETextAlign.TA_TopLeft;
		C.DrawKoreanText(sCharName, Components[i].X + x, Components[i].Y + y + 3, Components[i].XL, Components[i].YL - y);

		sTemp = ConsoleCommand("GetCharLV_Job " $ (i-BN_CharA));
		C.SetDrawColor(255,255,255,alpha);
		C.KTextFormat = ETextAlign.TA_MiddleLeft;
		C.DrawKoreanText(sTemp, Components[i].X + x, Components[i].Y + y - 2, Components[i].XL, Components[i].YL - y);

		sTemp = ConsoleCommand("LOBBYCOMMAND Name=" $ sCharName $ " LastGameTime");
		C.SetDrawColor(229,201,174,alpha);
		C.KTextFormat = ETextAlign.TA_BottomLeft;
		C.DrawKoreanText(sTemp, Components[i].X + x, Components[i].Y - 4, Components[i].XL, Components[i].YL - y);
	}
	//-------------------------------------------------------------------------

	// 标记当前服务器分组信息
	CLobbyInfo(Level.Game).GetServerId(ServerGroup, ServerIndex);
	if (ServerGroup != "" && ServerIndex != -1) {
		C.SetDrawColor(255,255,0);
		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		C.DrawKoreanText(ServerGroup $ Localize("Terms","ServerGroup","Sephiroth") $ " - " $ Localize("Terms","Server","Sephiroth") $ ServerIndex, 0, 0, C.ClipX, 18);
	}

	// 保持与服务器的心跳，以防长时间无操作断线
	if( Level.TimeSeconds - ClickEventTime < 180.0f && Level.TimeSeconds - PingTime > 2.0f  )
	{
		ConsoleCommand("PINGLOBBY");
		PingTime = Level.TimeSeconds;
	}
}

// 响应按钮事件，触发开始游戏、创建或删除等逻辑
function NotifyComponent(int ComponentId, int NotifyId, optional string Command)
{
	switch (NotifyId) {
	case BN_Start:
		StartGameB();
		break;
	case BN_New:
		CreateCharacter();
		break;
	case BN_Delete:
		OnDeleteDialog();
		break;
	case BN_Back:
		ReturnToLogin();
		break;
	case BN_Option:
		OpenOption();
		break;
	case BN_Quit:
		QuitGame();
		break;
	case BN_CharA:
	case BN_CharB:
	case BN_CharC:
	case BN_CharD:
	case BN_CharE:
		if(nSelectedCharacter == (NotifyId-BN_CharA))	// 再次点击已选角色则直接开始游戏
		{
			StartGameB();
		}
		else											// 点击未选中的角色时刷新选择
		{
			nSelectedCharacter = (NotifyId-BN_CharA);
			ConsoleCommand("CharacterSelect " $ nSelectedCharacter);
		}
		break;
	}
	ClickEventTime = Level.TimeSeconds;
}

// 旧版开始游戏逻辑（保留注释记录）
function StartGame()		//modified by yj http://blog.naver.com/dntjdrhksdld/110101098051
{
	//local string ErrorString;
	//log(SelectedHero.GetPlayName());

	//	if (SelectedHero != None) {
	//		if(bool(PlayerOwner.ConsoleCommand("CHECKNAMEVALIDWHENLOGIN" @ SelectedHero.GetPlayName())) ) {	//当角色名不合法时禁止在登录阶段继续
	//			if (!SelectedHero.NeedJobChange())
	//			{
	//			//	ConsoleCommand("STARTPLAY "$SelectedHero.GetPlayName());
	//			}
	//			else
	//				class'CMessageBoxJobSelect'.static.MessageBoxJobSelect(Self,"JobSelection",Localize("Modals","JobChange","Sephiroth"),MB_YesNo,IDM_JobChange,true);
	//		}
	//		else {
	//			ErrorString = Localize("Modals","PlayerWrongName_Whenlogin","Sephiroth");				
	//			class'CMessageBox'.static.MessageBox(Self,"InvalidCharacterName_whenlogin",ErrorString,MB_Ok);			
	//		}
	//	}
}

// 开始游戏逻辑：通知服务器并发送网络消息
function StartGameB()
{
	//local ClientController ClientCtrl;

	//local Controller C;
	//ClientCtrl = ClientController(PlayerOwner.GetEntryLevel().GetLocalPlayerController());

	//for ( C=PlayerOwner.GetEntryLevel().ControllerList; C!=None; C=C.NextController )
	//{
	//	if ( C.IsA('ClientController') )
	//	{
	//		ClientCtrl = ClientController(C);
	//	}

	//	//Log("StartGameB IN "@C);

	//}

	//Log("StartPlay " $ sSelectedCharacterName);
	ConsoleCommand("StartPlay " $ sSelectedCharacterName);
	if(0 <= nSelectedCharacter && nSelectedCharacter < MAX_CREATE_PLAYER_NUM)
		if(sSelectedCharacterName != "")
		{
			//Log("StartPlay " $ sSelectedCharacterName@ClientController(PlayerOwner)@ClientController(PlayerOwner).Net@Level@PlayerOwner.GetEntryLevel());
			ClientController(PlayerOwner).Net.NotiGameStartPlay(sSelectedCharacterName);
			//ConsoleCommand("StartPlay " $ sSelectedCharacterName);
		}
}

// 清空选中角色状态
function ResetSelectCharacter()
{
	nSelectedCharacter = -1;
}

// 打开创建角色界面并隐藏其他组件
function CreateCharacter()
{
	NewCharacter = CLobbyNewCharacter(AddInterface("SephirothUI.CLobbyNewCharacter"));
	if (NewCharacter != None)
	{
		bHideAllComponets = true;
		ResetSelectCharacter();
		ConsoleCommand("HideAllCharacter");

		NewCharacter.ShowInterface();
	}
}

// 弹出删除角色确认输入框
function OnDeleteDialog()
{
	local string sTemp;

	sTemp = Localize("Modals","DeleteCharacter","Sephiroth") $ Localize("Lobby","DelKey","SephirothUI") $
				Localize("Modals","DeleteCharacterEnd","Sephiroth");
	class'CEditBox'.static.EditBox(Self,"DeleteCharacter","["$sSelectedCharacterName$"]"@sTemp, IDS_DeleteCharacter, 20, "",true);
}

// 真正执行删除角色并刷新状态
function DeleteCharacter()
{
	PlayerOwner.ConsoleCommand("DELETECHARACTER "$sSelectedCharacterName);
	sSelectedCharacterName = "";
	SelectedHero = None;
	ResetSelectCharacter();
	m_LastDeleteTime = Level.Second;	// 删除后记录时间，防止连续删除触发异常
}

// 返回登录界面并断开当前连接
function ReturnToLogin()
{
	local string LoginURL;
	PlayerOwner.SetPause(true);
	ConsoleCommand("RETURNTOLOGIN");
	ConsoleCommand("DISCONNECT");
	CLobbyInfo(Level.Game).LoginURLInfo(LoginURL);
	if (LoginURL != "") {
		PlayerOwner.ClientTravel(LoginURL,TRAVEL_Absolute,false);
	}
}

// 打开设置界面并屏蔽大厅按键
function OpenOption()
{
	Option = COption(AddInterface("SephirothUI.COption"));
	if (Option != None) {
		bIgnoreKeyEvents = true;
		Option.ShowInterface();
	}
}

// 弹出退出游戏提示框
function QuitGame()
{
	class'CMessageBox'.static.MessageBox(Self,"QuitGame",Localize("Modals","QuitGame","Sephiroth"),MB_YesNo,IDM_QuitGame);
}

// 处理输入框回调，例如删除角色的确认口令
function NotifyEditBox(CInterface Interface,int NotifyId,string EditText)
{
	if(NotifyId == IDS_DeleteCharacter && EditText != "")
	{
		if( EditText == Localize("Lobby", "DelKey", "SephirothUI") )
			DeleteCharacter();
		else
			class'CMessageBox'.static.MessageBox(Self,"WrongInput",Localize("Modals","WrongInput","Sephiroth"),MB_YesNo,IDM_DeleteCharacter);		// IDM_DeleteCharacter 在此仅用于提示
	}

}

// 接收其他界面的消息，处理退出或子界面关闭
function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyId,optional coerce string Command)
{
	local int NotifyValue;
	if (NotifyId == INT_MessageBox)
	{
		NotifyValue = int(Command);
		switch (NotifyValue)
		{
		case IDM_QuitGame:
			PlayerOwner.ConsoleCommand("Quit");
			break;
		}
	}
	else if (NotifyId == INT_Close)
	{
		if (Interface == Option)
		{
			bIgnoreKeyEvents = false;
			Option.HideInterface();
			RemoveInterface(Option);
			Option = None;
		}
		else if (Interface == NewCharacter)
		{
			bHideAllComponets = false;
			NewCharacter.HideInterface();
			RemoveInterface(NewCharacter);
			NewCharacter = None;
		}
	}
}

// 创建角色界面的回调：成功则关闭窗口，否则提示错误
function NewCharacterResult(string Result)
{
	if (NewCharacter != None && !NewCharacter.bDeleteMe) {
		if (Result == "Success") {
			bHideAllComponets = false;
			NewCharacter.HideInterface();
			RemoveInterface(NewCharacter);
			NewCharacter = None;
		}
		else
			NewCharacter.NewCharacterError(Result);
	}
}

// 开始游戏结果：成功时销毁大厅 HUD
function StartPlayResult(string Result)
{
	if (Result == "Success") {
		if (PlayerOwner.myHud == Self)
			PlayerOwner.myHud = None;
		Destroy();
	}
}

// 断线提示处理
function OnDisconnected(optional string Result)
{
	if (Result == "" && !bAlreadyDisconnected)
		class'CMessageBox'.static.MessageBox(Self,"Disconnected",Localize("Modals","Disconnected","Sephiroth"),MB_Ok,IDM_QuitGame);
	else
		class'CMessageBox'.static.MessageBox(Self,"Disconnected",Result,MB_Ok,IDM_QuitGame);
	bAlreadyDisconnected = true;
}

// 桌面渲染的占位函数，目前没有额外绘制逻辑
function OnRenderDesktop(Canvas C)
{

}

// 鼠标命中判定：主体命中或落在背景组件上即认为有效
function bool PointCheck()
{
	if (Super.PointCheck())
		return true;
	return IsCursorInsideComponent(Components[0]);
}

// 绘制主界面
function Render(Canvas C)
{
	Super.Render(C);
}

defaultproperties
{
     nSelectedCharacter=-1
     Components(0)=(XL=160.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="StartGame",Type=RES_PushButton,XL=157.000000,YL=44.000000,OffsetXL=20.000000,OffsetYL=38.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="LobbyMenu")
     Components(2)=(Id=2,Caption="NewCharacter",Type=RES_PushButton,XL=157.000000,YL=44.000000,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="LobbyMenu")
     Components(3)=(Id=3,Caption="DeleteCharacter",Type=RES_PushButton,XL=157.000000,YL=44.000000,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="LobbyMenu")
     Components(6)=(Id=6,Caption="QuitGame",Type=RES_PushButton,XL=157.000000,YL=44.000000,OffsetYL=1.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="LobbyMenu",HotKey=IK_Escape)
     Components(7)=(Id=7,Type=RES_PushButton,XL=322.000000,YL=62.000000,LocType=LCT_User)
     Components(8)=(Id=8,Type=RES_PushButton,XL=322.000000,YL=62.000000,LocType=LCT_User)
     Components(9)=(Id=9,Type=RES_PushButton,XL=322.000000,YL=62.000000,LocType=LCT_User)
     Components(10)=(Id=10,Type=RES_PushButton,XL=322.000000,YL=62.000000,LocType=LCT_User)
     Components(11)=(Id=11,Type=RES_PushButton,XL=322.000000,YL=62.000000,LocType=LCT_User)
     TextureResources(0)=(Package="UI_2011_btn",Path="btn_blue_n",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_blue_d",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_blue_o",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_blue_c",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011_btn",Path="btn_red_n",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011_btn",Path="btn_blue_d",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011_btn",Path="btn_red_o",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011_btn",Path="btn_red_c",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011_btn",Path="btn_chr_n",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011_btn",Path="btn_chr_d",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_chr_o",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_chr_c",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_chr_c_o",Style=STY_Alpha)
}
