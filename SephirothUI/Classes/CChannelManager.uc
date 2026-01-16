class CChannelManager extends CMultiInterface
	config(SephirothUI);

/*******************
    ä��â ���߱� ����� �߰�.
    MakeInvisible() / MakeVisible()
    bInvisible ������ �ΰ�, �ش� ��带 ǥ��.
    CInterface Ŭ�����κ��� ��ӹ޴� HideInterface()/ShowInterface()�� ��� �ش� �������̽� ��ü�� �Ҹ��Ű�� ������ �����ϰԵǾ�
    ������ ä�ó����� ��� ����������ϴ�. �̴� ��ġ�ʴ� �����̹Ƿ�,
    ä��â �������̽��� "�׸���" �� "Ű�̺�Ʈó��"���� �����ϰ�, ��ü�� ������ �����Ҽ��ִ� ���߱����� �߰��մϴ�.
    *����. �� ��, ���߱����� �����ϱ� ���� Components[] ����� bVisible�Ӽ��� False�� ó���� ��, �����ٶ� true�� �����մϴ�.
    ������ Components[]�� bVisible �Ӽ��� ���� ó���Ϸ��� ��� �ش系���� ����������Ե��� �������ּ���.
    2010.3.24.Sinhyub

    ��ũ�ѹ��� ���. PushComponentPlane���� ��ġ������ �Ͼ��.
	��ũ�ѹ� ������Ʈ�� Components[3]. CInterface RenderComponent���� Res_ScrollBar�� ��� ������ ����

********************/

// ä��â (�޽��� Ǯ. ���÷��̾�)
// 当前选中的文本池（用于显示聊天消息）
var CTextPoolAdv SelectedTextPool;

// 文本池对象（存储和管理聊天消息）
var CTextPoolAdv TextPool;


// 监听所有频道
var config bool bListen_All;
// 监听公会频道
var config bool bListen_Clan;
// 监听私聊频道
var config bool bListen_Whisper;
// 监听队伍频道
var config bool bListen_Party ;
// 监听频道1
var config bool bListen_Channel1;
// 监听频道2
var config bool bListen_Channel2;
// 监听团队频道
var config bool bListen_Team;
// 监听系统消息
var config bool bListen_System;
// 监听摊位频道
var config bool bListen_Booth;

// 频道模式选择界面
var ChatMode ChatMode;

// 监听模式界面
var ListenMode ListenMode;
// 监听列表界面
var ListenList ListenList;

// 私聊对象名称输入框
var CImeEdit WhisperEdit;
// 消息输入框
var CImeEdit MessageEdit;

// 最小显示行数
var int MinLines;
// 最大显示行数
var int MaxLines;
// 当前显示行数（可配置）
var globalconfig int Lines;
// 文本大小（每行高度）
var int TextSize;
// 文本输出区域宽度偏移量（用于计算换行宽度）
// 负数表示允许超出，正数表示提前换行
// 例如：-100 表示允许超出100像素，20 表示提前20像素换行
const TextOutRgnWidthOffset = -150;
//var int ClickY;  // 调整大小时的初始鼠标Y坐标

// 聊天窗口位置X坐标（可配置）
var globalconfig float PageX;
// 聊天窗口位置Y坐标（可配置）
var globalconfig float PageY;
// 系统消息窗口位置X坐标（可配置）
var globalconfig float Sys_PageX;
// 系统消息窗口位置Y坐标（可配置）
var globalconfig float Sys_PageY;
// 是否正在拖拽聊天窗口
var bool bIsDragging;
// 是否正在拖拽系统消息窗口
var bool bIsDragging_Sys;
// 拖拽时的X偏移量
var int DragOffsetX;
// 拖拽时的Y偏移量
var int DragOffsetY;

// 文本输出区域
var InterfaceRegion TextOutRgn;

// 当前频道模式（可配置）
var globalconfig int ChannelMode;
// 监听模式（可配置）
var globalconfig int var_ListenMode;

// 频道前缀数组（9种频道类型）
var string ChannelPrefix[9];

// 循环计数器
var int m_nLoopCnt;

/**
 * 频道模式枚举
 * 定义不同的聊天频道类型
 */
enum EChannelMode 
{
	Chan_Tell,      // 普通聊天
	Chan_Shout,     // 喊话
	Chan_Whisper,   // 私聊
	Chan_Party,     // 队伍
	Chan_Shell1,    // 频道1
	Chan_Shell2,    // 频道2
	Chan_Team,      // 团队
	Chan_Clan       // 公会
};

// 是否正在调整窗口大小
var bool bSizing;
// 是否保持聊天消息（不自动滚动）
var bool bHold;
//var bool bLayoutComplete;     //�ǹ��ľǺҰ� Ŀ��Ʈ�ƿ��޽��ϴ�. Sinhyub

// 是否显示系统消息
var bool bShowSystemMessage;

// 频道模式是否已改变
var bool bModeChanged;

// 普通聊天按钮文本
var string TellButton;
// 喊话按钮文本
var string ShoutButton;
// 私聊按钮文本
var string WhisperButton;
// 队伍按钮文本
var string PartyButton;
// 团队按钮文本
var string TeamButton;
// 公会按钮文本
var string ClanButton;

// 摊位频道名称
var string BoothChannel;

// 按钮通知ID：切换输入法
const BN_ToggleIme = 1;
// 按钮通知ID：切换频道模式
const BN_Mode = 2;
// 按钮通知ID：保持消息
const BN_Hold = 3;
// 按钮通知ID：监听列表
const BN_ListenList = 4;
// 按钮通知ID：显示系统消息
const BN_ShowSystemMessage = 5;
// 按钮通知ID：向上滚动
const BN_ScrollUp = 6;
// 按钮通知ID：向下滚动
const BN_ScrollDown = 7;

// 社交动画令牌数组：问候、是、迷人问候、抱歉、微笑、哭泣、呼唤
var array<string> HiToken,YesSirToken,CharmingHiToken,SorryToken,SmileToken,CryToken,YooHooToken;
// 社交动画令牌数组：无聊、愤怒、亲吻、爱你、冲刺、Sephiroth
var array<string> DullTimeToken,AngerToken,KissToken,LoveYouToken,RushToken,SephirothToken;

/**
 * 请求信息结构体
 * 用于显示确认对话框（如交易请求、组队请求等）
 */
struct RequestInfo
{
	var string ReqMessage;      // 请求消息文本
	var float X, XL;             // 消息文本位置和宽度
	var float YesX, YesXL;       // "是"按钮位置和宽度
	var float NoX, NoXL;         // "否"按钮位置和宽度
	var float Y, YL;             // 消息文本Y位置和高度
	var float YesY, YesYL;       // "是"按钮Y位置和高度
	var float NoY, NoYL;         // "否"按钮Y位置和高度
	var bool bShow;              // 是否显示请求对话框
	var bool IsXcngRequest;      // 是否为交易请求
};

// 当前请求信息
var RequestInfo ReqInfo;

// 交易请求消息
var string xcngReqMessage;
// 组队请求消息
var string partyReqMessage;

// 斜杠字符宽度（用于绘制请求对话框）
var float SlashWidth;

// 频道模式是否已初始化（在InitSephirothPlayer完成后初始化频道模式）
var bool bModeInitialized;	//ä��â ��� �ʱ�ȭ �Ǿ��°�.(InitSephirothPlayer�Ϸ����� ä��â ��� �ʱ�ȭ) sinhyub
var bool bInvisible;        //ä��â ���߱� �����ΰ�.   Sinhyub
var string strWhisperName;	//�ӼӸ�����ϰ��, ���߱����� ����� �̸��� ����.
//var array<bool> bVisibleComp; //�ش� Components��  bVisible�� ����. Sinhyub.

var array<string> Illegals;
var array<string> Flowers;
var array<string> CIllegals;
var string tmp, Atext;
var name NullName;

enum EPaperingType 
{
	PT_None,
	PT_TooFast,
	PT_AverageOver,
	PT_History
};


var plane PlaneD;
var int LastVisibleLines;

delegate function OnQueryAccept();
delegate function OnQueryDeny();


// ä��â�� ������ ���߱⸸ �ϴ� ����� ����.
// HideInterface()�� �̿��� ���, �ش� �������̽� ��ü�� �������ѹ����Ƿ�,
// ������ ä�� ������ ����� �����ϴ�.
// �̿� �ٸ���, �ܼ��� ä��â�� ������ �ʵ��� �ϴ� ����� �����մϴ�.
// ���� ������� CInterface�� ����� �߰��ϴ� �͵� ���ڽ��ϴ�.
// Sinhyub.
// Components[]�� bVisible��, boolŸ�� ��̿� �����صΰ�,��
// MakeVisible()�ÿ� �ش� ���� ������Ű���� ����ϰ� ����� ������,
// boolŸ�� ��̿� Components[].bVisible�� ���� ����� ���Ե��� �ʰ� False������ �������ִ� ������������
// �ϵ��ڵ����� �� Components�� �����Ͽ��ݴϴ�.

/**
 * 将字符串转换为Name类型
 * @param AString 要转换的字符串
 * @return 转换后的Name类型值
 */
final function name StrToName(string AString)
{
	local Name TempName;
	tmp = AString;
	SetPropertyText("NullName",GetPropertyText("tmp"));
	TempName = NullName;
	NullName = '';
	tmp = "";
	return TempName;
}



/**
 * 隐藏聊天窗口
 * 保存当前状态并隐藏所有组件
 */
function MakeInvisible()
{
	local int i;
    
	bInvisible = True;

    // 如果是私聊模式，保存私聊对象名称
	if( ChannelMode == EChannelMode.Chan_Whisper )
	{
		strWhisperName = WhisperEdit.GetText();
		WhisperEdit.SetText("");
		WhisperEdit.SetFocusEditBox(False);
	}

    // 隐藏所有组件
	for( i = 0; i < Components.Length; i++ )
	{
		Components[i].bVisible = False;
	}
}

/**
 * 显示聊天窗口
 * 恢复之前的状态并显示组件（系统通知组件除外）
 */
function MakeVisible()
{
	local int i;
	bInvisible = False;

    // 如果是私聊模式，恢复私聊对象名称
	if( ChannelMode == EChannelMode.Chan_Whisper )
		WhisperEdit.SetText(strWhisperName);

    // 显示组件（跳过系统通知组件和滚动条组件）
	for( i = 0; i < Components.Length;i++ )
	{
        // 跳过系统通知组件（索引7和8）
		if( i == 7 || i == 8 )
			continue;

        // 跳过滚动条组件（索引3）
		if( i == 3 )
			continue;

		Components[i].bVisible = True;
	}
}
/**
 * 检查聊天窗口是否隐藏
 * @return 如果窗口隐藏返回true，否则返回false
 */
function bool IsInvisible()
{
	return bInvisible;
}

/**
 * 检查鼠标是否点击在"上滚"按钮区域
 * 上滚按钮位于滚动条顶部16像素区域
 * @return 如果鼠标在上滚按钮区域返回true
 */
function bool IsInScrollUpBtn()
{
	return (Controller.MouseX >= Components[3].X) 
		&& (Controller.MouseX <= Components[3].X + Components[3].XL)
		&& (Controller.MouseY >= Components[3].Y)
		&& (Controller.MouseY <= Components[3].Y + 16);      // 顶部 16px
}

/**
 * 检查鼠标是否点击在"下滚"按钮区域
 * 下滚按钮位于滚动条底部16像素区域
 * @return 如果鼠标在下滚按钮区域返回true
 */
function bool IsInScrollDownBtn()
{
	local float bottomY;
	bottomY = Components[3].Y + Components[3].YL;
	return (Controller.MouseX >= Components[3].X) 
		&& (Controller.MouseX <= Components[3].X + Components[3].XL)
		&& (Controller.MouseY >= bottomY - 16)               // 底部 16px
		&& (Controller.MouseY <= bottomY);
}


/**
 * 初始化函数
 * 创建文本池、输入框等组件，并设置初始状态
 */
function OnInit()
{
	local float height;

	TextPool = Spawn(class'Interface.CTextPoolAdv');

    
    //WhisperEdit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	WhisperEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if ( WhisperEdit != None ) 
	{
		WhisperEdit.bNative = True;
		WhisperEdit.bAdjustSize = True;
		WhisperEdit.SetMaxWidth(20);
		WhisperEdit.SetSize(10,16);
		if( ChannelMode == EchannelMode.Chan_Whisper )    // 2009.11.10.Sinhyub
			WhisperEdit.ShowInterface();
		else
			WhisperEdit.HideInterface();
		WhisperEdit.OnKillFocus = OnFinishWhisperEdit;
	}

	//MessageEdit = SepEditBox(AddInterface("SepInterface.SepEditBox"));
	MessageEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if ( MessageEdit != None ) 
	{
		MessageEdit.bNative = True;
		MessageEdit.SetMaxWidth(110);       //��ȹ ��û ��, �����ؾ� �մϴ�.
		MessageEdit.SetSize(512,16);
		MessageEdit.ShowInterface();
		MessageEdit.OnKillFocus = OnFinishMessageEdit;
	}

	LastVisibleLines = -1;

	Components[0].NotifyId = BN_ToggleIme;
	Components[1].NotifyId = BN_Mode;
	Components[2].NotifyId = BN_Hold;
	Components[8].NotifyId = BN_ShowSystemMessage;
	Components[9].NotifyId = BN_ScrollUp;
	Components[10].NotifyId = BN_ScrollDown;

	Components[3].bVisible = False;
	Components[7].bVisible = False;
	Components[8].bVisible = False;

	SetComponentTextureId(Components[0], 1);
	SetComponentTextureId(Components[2], 4,0,5);
	SetComponentTextureId(Components[8], 4,0,5);


	SelectTextPool();
	SetTextPoolProperty(TextPool);

	if( PageX == -1 && PageY == -1 )
		ResetDefaultPosition();
	bMovingUI = True; 

	if ( Lines == 0 )
		Lines = MinLines;
	TextOutRgn.H = float(TextSize * Lines);

	BoothChannel = Localize("Terms","BoothChannel","Sephiroth");

	ParseIntoArray(Localize("SocialAnimation","TokenHi","Sephiroth"), "|", HiToken);
	ParseIntoArray(Localize("SocialAnimation","TokenYesSir","Sephiroth"), "|", YesSirToken);
	ParseIntoArray(Localize("SocialAnimation","TokenCharmingHi","Sephiroth"), "|", CharmingHiToken);
	ParseIntoArray(Localize("SocialAnimation","TokenSorry","Sephiroth"), "|", SorryToken);
	ParseIntoArray(Localize("SocialAnimation","TokenSmile","Sephiroth"), "|", SmileToken);
	ParseIntoArray(Localize("SocialAnimation","TokenCry","Sephiroth"), "|", CryToken);
	ParseIntoArray(Localize("SocialAnimation","TokenYooHoo","Sephiroth"), "|", YooHooToken);
	ParseIntoArray(Localize("SocialAnimation","TokenDull","Sephiroth"), "|", DullTimeToken);
	ParseIntoArray(Localize("SocialAnimation","TokenAnger","Sephiroth"), "|", AngerToken);
	ParseIntoArray(Localize("SocialAnimation","TokenKiss","Sephiroth"), "|", KissToken);
	ParseIntoArray(Localize("SocialAnimation","TokenLoveYou","Sephiroth"), "|", LoveYouToken);
	ParseIntoArray(Localize("SocialAnimation","TokenRush","Sephiroth"), "|", RushToken);
	ParseIntoArray(Localize("SocialAnimation","TokenSephiroth","Sephiroth"), "|", SephirothToken);

	ParseIntoArray(Localize("ChannelManager","Flowers","SephirothUI"), "|", Flowers);

	TellButton = Localize("Terms", "Tell", "Sephiroth");
	ShoutButton = Localize("Terms", "Shout", "Sephiroth");
	WhisperButton = Localize("Terms", "Whisper", "Sephiroth");
	PartyButton = Localize("Terms", "Party", "Sephiroth");
	TeamButton = Localize("Terms", "Match", "Sephiroth");    //������ ä���� "��ġ "�� �ٲپ� ���� -2010.1.22.Sinhyub.
	ClanButton = Localize("Terms", "Clan", "Sephiroth");

	class'CNativeInterface'.Static.TextSize("/", SlashWidth, height);

	LoadIllegalText();
	LoadClanIllegalText();

	SetDefaultChannel();

	bModeChanged = True;
	bNeedLayoutUpdate = True;
    //ShowListenMode();
}

/**
 * 设置默认频道
 * 根据玩家的团队和公会信息自动选择最合适的频道
 */
function SetDefaultChannel()
{
    //Log("SetDefaultChannel::::"$SephirothPlayer(PlayerOwner).PSI.PlayName$"::"$SephirothPlayer(PlayerOwner).PSI.TeamName$":"$SephirothPlayer(PlayerOwner).PSI.ClanName);
	if( SephirothPlayer(PlayerOwner) != None && SephirothPlayer(PlayerOwner).PSI != None )
	{
		if( (SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName == "NONE") )    //����Ʋ���� NONE���
			SetChannelMode(EChannelMode.Chan_Team);
		else if(SephirothPlayer(PlayerOwner).PSI.ClanName != "")
			SetChannelMode(EChannelMode.Chan_Clan);
		else if(((SephirothPlayer(PlayerOwner).PSI.TeamName == "") || (SephirothPlayer(PlayerOwner).PSI.TeamName == "NONE")) && ChannelMode == EChannelMode.Chan_Team)
			SetChannelMode(EChannelMode.Chan_Tell);
	}
	else
		SetChannelMode(EChannelMode.Chan_Tell);
	bModeChanged = True;
}

/**
 * 设置文本池属性
 * 配置文本池的控制器和点击事件回调
 * @param TextPool 要配置的文本池对象
 */
function SetTextPoolProperty(CTextPoolAdv TextPool)
{
	TextPool.InterfaceController = Controller;
	TextPool.OnLeftButtonClick = OnSelectWhisperName;
	TextPool.OnRightButtonClick = OnSelectBlockUserName;
}

////////////////////////////////////////////////////////////////////////////////////////
// UnrealWiki : http://wiki.beyondunreal.com/wiki/Useful_String_Functions�� Lower�Լ��� �����Ͽ� ����.
// This function is the equivalent to Caps that converts all lowercase characters in a string to uppercase
// (while leaving non-alphabetical characters untouched).
////////////////////////////////////////////////////////////////////////////////////////

/**
 * 将字符串转换为大写
 * 将字符串中的所有小写字母转换为大写字母，非字母字符保持不变
 * @param Text 要转换的字符串
 * @return 转换后的大写字符串
 */
static final function string Upper(coerce string Text)
{
	local int IndexChar;

	for ( IndexChar = 0; IndexChar < Len(Text); IndexChar++ )
	{
		if ( Mid(Text, IndexChar, 1) >= "a" && Mid(Text, IndexChar, 1) <= "z" )
		{
			Text = Left(Text, IndexChar)$Chr(Asc(Mid(Text, IndexChar, 1)) - 32)$Mid(Text, IndexChar + 1);
		}
	}
	return Text;
}

function LoadIllegalText()
{
	local CTextFile aFile;
	local string IllegalText;
	local int i;

	aFile = spawn(class'CTextFile');
	aFile.LoadTextDec("Illegals.dat");
	IllegalText = aFile.FileText;
	aFile.Destroy();

	class'CNativeInterface'.Static.WrapStringToArray(IllegalText, Illegals, 10000, ",");
}

function LoadClanIllegalText()
{
	local CTextFile aFile;
	local string IllegalText;
	local int i;

	aFile = spawn(class'CTextFile');
	aFile.LoadTextDec("CIllegals.dat");
	IllegalText = aFile.FileText;
	aFile.Destroy();

	class'CNativeInterface'.Static.WrapStringToArray(IllegalText, CIllegals, 10000, ",");
}

function int ParseIntoArray(string Source, string pchDelim, out array<string> InArray)
{
	local int i;
	local string S;

	S = Source;
	i = InStr(S,pchDelim);
	while ( i > 0 ) 
	{
		InArray[InArray.Length] = Caps(Left(S,i));
		S = Mid(S,i + 1,Len(S));
		i = InStr(S,pchDelim);
	}
	InArray[InArray.Length] = Caps(S);
	return InArray.Length;
}

function OnFlush()
{
	if ( TextPool != None ) 
	{
		TextPool.Destroy();
		TextPool = None;
	}


	if ( WhisperEdit != None ) 
	{
		WhisperEdit.HideInterface();
		RemoveInterface(WhisperEdit);
		WhisperEdit = None;
	}

	if ( MessageEdit != None ) 
	{
		MessageEdit.HideInterface();
		RemoveInterface(MessageEdit);
		MessageEdit = None;
	}
	if( ReqInfo.bShow )
		OnQueryDeny();

	HideChannel();
    //HideListenMode();
    //HideListenList();
	SaveConfig();
}

function ShowChannel()
{
	ChatMode = ChatMode(AddInterface("SephirothUI.ChatMode"));
	if ( ChatMode != None ) 
	{
		ChatMode.ShowInterface();
		ChatMode.SetPosition(Components[1].X + Components[1].XL + 2, Components[1].Y);
	}
}

function HideChannel()
{
	if ( ChatMode != None ) 
	{
		ChatMode.HideInterface();
		RemoveInterface(ChatMode);
		ChatMode = None;
	}
}

function ShowListenMode()
{
	ListenMode = ListenMode(AddInterface("SephirothUI.ListenMode"));
	if ( ListenMode != None ) 
	{
		ListenMode.ShowInterface();
		ListenMode.SetPosition(Components[6].X + Components[6].XL, Components[6].Y);
		ListenMode.SetVisibleComponents(bListen_All, bListen_Clan, bListen_Whisper, bListen_Party,
			bListen_Channel1, bListen_Channel2, bListen_Team,
			bListen_System, bListen_Booth);
		ListenMode.SetListenType(var_ListenMode);
		ListenMode.SetShellChannelName();

	}
}

function HideListenMode()
{
	if ( ListenMode != None ) 
	{
		ListenMode.HideInterface();
		RemoveInterface(ListenMode);
		ListenMode = None;
	}
}

function ShowListenList()
{
	ListenList = ListenList(AddInterface("SephirothUI.ListenList"));
	if ( ListenList != None ) 
	{
		ListenList.ShowInterface();
		ListenList.SetPosition(Components[6].X, Components[6].Y - ListenList.Components[0].YL - 20);
		ListenList.SetShellChannelDisabled(SephirothPlayer(PlayerOwner).PSI.GetRightChannel() == "",SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() == "");
		ListenList.SetBools(bListen_All, bListen_Clan, bListen_Whisper, bListen_Party,
			bListen_Channel1, bListen_Channel2, bListen_Team,
			bListen_System, bListen_Booth);
		ListenList.SetShellChannelName();

	}
}

function HideListenList()
{
	if ( ListenList != None ) 
	{
		ListenList.HideInterface();
		RemoveInterface(ListenList);
		ListenList = None;
	}
}

function NotifyComponent(int CmpId, int NotifyId, optional string Command)
{
	switch (NotifyId) 
	{
		case BN_Mode:
        //@by wj(06/02)
        //if(!ReqInfo.bShow){
			if ( ChatMode != None && !ChatMode.bDeleteMe )
				HideChannel();
			else
				ShowChannel();
        //}
			break;
		case BN_ToggleIme:
			if ( !SephirothInterface(Parent).bBlockPapering )     //��  �� toggleIme�� MessageEditing���� ���°���
				GotoState('MessageEditing');
			break;
		case BN_Hold:
			bHold = !bHold;
			break;
		case BN_ShowSystemMessage:
			bShowSystemMessage = !bShowSystemMessage;
			if( bShowSystemMessage )
				Components[8].Tooltip = "HideSystemMessage";
			else
				Components[8].Tooltip = "ShowSystemMessage";
			break;
		case BN_ScrollUp:
			NotifyScrollUp(-1, 1);  // 向上滚动1行
			break;
		case BN_ScrollDown:
			NotifyScrollDown(-1, 1);  // 向下滚动1行
			break;

		case BN_ListenList:
        //if (ListenList != None )
        //    HideListenList();
        //else
        //    ShowListenList();
			break;
	}
}

function SetChannelMode(int Mode)
{
	if ( Mode != ChannelMode ) 
	{
		if ( ChannelMode == EChannelMode.Chan_Whisper )
			WhisperEdit.HideInterface();
		else if (Mode == EChannelMode.Chan_Whisper)
			WhisperEdit.ShowInterface();
		ChannelMode = Mode;
		bModeChanged = True;
	}

	SaveConfig();
}

function SelectTextPool()
{
	if ( TextPool != None )
		SelectedTextPool = TextPool;
	LastVisibleLines = -1;
}

function SetListenMode(int Mode)
{
	if ( Mode != var_ListenMode ) 
	{
		var_ListenMode = Mode;
		SelectTextPool();
		SaveConfig();
	}
}

function SetChannelPosReflesh()
{
	bModeChanged = True;
	SaveConfig();
}

function UpdateChannel(bool bForceOn,optional bool bLeftEar)        //modified by yj
{
	bModeChanged = True;

	//InitSephirothPlayer�� ���� ����(PSI�ʱ�ȭ??�Ȼ���), ä��â Mode �ʱ�ȭ���ش�. Sinhyub
	if( !bModeInitialized )
	{
		SetDefaultChannel();
		bModeInitialized = True;
	}

	if( bForceOn ) 
	{      
	//�Ҷ� �����(�����ϴ� ����) bListen_Channel1(Ȥ�� 2)�� true�� ������ �����Ѵ�.
		if( !bLeftEar )
			bListen_Channel1 = SephirothPlayer(PlayerOwner).PSI.GetRightChannel() != "" ;
		else
			bListen_Channel2 = SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() != "" ;
	}
	else 
	{              
	//�� ���� ��Ȳ�̶�� ����(force)�� true�� �������� �ʴ´�.
		if( SephirothPlayer(PlayerOwner).PSI.GetRightChannel() == "" )
			bListen_Channel1 = False;
		if( SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() == "" )
			bListen_Channel2 = False;
	}

	if( ListenList != None ) 
	{
		ListenList.SetShellChannelDisabled(SephirothPlayer(PlayerOwner).PSI.GetRightChannel() == "",SephirothPlayer(PlayerOwner).PSI.GetLeftChannel() == "");
		ListenList.SetBools_ShellChannel(bListen_Channel1, bListen_Channel2);
		ListenList.SetShellChannelName();
	}
	if( ListenMode != None ) 
	{
		ListenMode.SetVisibleComponents_ShellChannel(bListen_Channel1, bListen_Channel2);
		ListenMode.SetShellChannelName();
	}

	SaveConfig();
}

function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyType, optional coerce string Command)
{
	if ( Interface == ChatMode ) 
	{
		switch (NotifyType) 
		{
			case INT_Command:
				if( (SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE" ) ) //add neive : �������̸� ä�η� �ٲٷ��ص� ���������� �ȴ�
				{
					SetChannelMode(EChannelMode.Chan_Team);
				}
				else
					SetChannelMode(int(Command));
				break;
			case INT_Close:
				HideChannel();
				break;
		}
	}
}

function NotifyScrollUp(int CmpId,int Amount)
{
	if ( SelectedTextPool != None )
		SelectedTextPool.ScrollUp(Amount);
}

function NotifyScrollDown(int CmpId,int Amount)
{
	if ( SelectedTextPool != None )
		SelectedTextPool.ScrollDown(Amount);
}

function OnAddMessage(string Message, color InColor, optional bool bCheckHit, optional int HitSizeX, optional int HitSizeY, optional string HitText, optional bool IsBgColor, optional color BgColor, optional int Style,optional string TellType)
{
	if ( TextPool != None && !bHold ) 
	{
		TextPool.AddMessage(Message, InColor, 12, 4, 2, bCheckHit, HitSizeX, min(14, HitSizeY), HitText, IsBgColor, BgColor, Style);
	}
}

function string ConvertIllegal(string InString)
{
    // filter something
	local int i;
	local int k;
	local string OutString, Hdr, Msg;

	i = InStr(InString, ":");
	if ( i != -1 )
	{
		Hdr = Left(InString, i);
		Msg = Mid(InString, i);
	}
	else
	{
		Hdr = "";
		Msg = InString;
	}

	//@cs delete ���յķ��������ݲ��ټ��Illegals
	OutString = Msg;
	//Log("cs debug Illegals err5");
	//Log(OutString);
	//Log(string(Asc(Mid(OutString,0,1))));
	//Log(string(Asc(Mid(OutString,1,1))));
	//Log(string(Asc(Mid(OutString,2,1))));
	for ( i = 0;i < Illegals.Length;i++ )
	{
		if ( InStr(InString, Illegals[i]) != -1 )
		{
			//Log("cs debug Illegals err3");
			//Log(InString);
			//Log(Illegals[i]);
			k = Rand(Flowers.Length);
			if ( Flowers.Length > 0 )
				ReplaceText(OutString, Illegals[i], Flowers[k]);
			else
				ReplaceText(OutString, Illegals[i], " ");
		}
	}

	return Hdr$OutString;
}

function bool IsClanIllegal(string InString)
{
	local int i;
	local string UpperStr;
	UpperStr = Upper(InString);

    //Log(UpperStr);

	for ( i = 0;i < CIllegals.Length;i++ )
	{
		if ( InStr(UpperStr, CIllegals[i]) != -1 )
		{
			return False;
		}
	}
	return True;
}

function ShowClanIllegalMsg(string InString)
{
    // �޼����� ��ĵ�Ͽ� Ŭ������ ���������� �ܾ ������ ����� ������.
	local int i;
	local string UpperStr;
	UpperStr = Upper(InString);

	for ( i = 0;i < CIllegals.Length;i++ )
	{
		if ( InStr(UpperStr, CIllegals[i]) != -1 )
		{
			TextPool.AddMessage(Localize("Information","IllegalClanTextUsed","Sephiroth"),
				class'Canvas'.Static.MakeColor(0,255,255),
				12, 4, 2, False, 0, 0, "",
				True,
				class'Canvas'.Static.MakeColor(0,0,0),
				2);
			break;
		}
	}
}

// 布局函数：负责计算和更新聊天窗口及其所有子组件的位置和大小
// 参数 C: 画布对象，用于获取屏幕尺寸等信息
function Layout(Canvas C)
{
	local float YL;              // 临时变量：用于计算文本输出区域的高度
	local int DX,DY;             // 临时变量：鼠标拖拽时的坐标偏移量
	local int i;                 // 循环计数器
	local int NewVisible;        // 新计算出的可见行数

	if( bInvisible )
		return;

	// ========== 第一部分：处理UI移动逻辑 ==========
	// 当用户正在拖拽移动聊天窗口时，需要实时更新窗口位置
	if( bMovingUI ) 
	{
		// 处理聊天窗口的拖拽移动
		if ( bIsDragging ) 
		{
			// 计算当前鼠标位置相对于拖拽起始点的偏移量
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			// 更新聊天窗口的页面坐标
			PageX = DX;
			PageY = DY;
        
			UpdateTextPoolPosition(TextOutRgn.X, TextOutRgn.Y, min(TextOutRgn.W - TextOutRgnWidthOffset, C.ClipX - Controller.MouseX - 40), TextOutRgn.H);
		}
		else 
		{

			if ( PageX < 0 )
				PageX = 0;
			else if (PageX + WinWidth > C.ClipX)
				PageX = C.ClipX - WinWidth - 30;
			if ( PageY - TextOutRgn.H - 40 < 0 )
				PageY = TextOutRgn.H + 40;
			else if (PageY + WinHeight > C.ClipY)
				PageY = C.ClipY - WinHeight;
			UpdateTextPoolPosition(TextOutRgn.X, TextOutRgn.Y, TextOutRgn.W - TextOutRgnWidthOffset, TextOutRgn.H);
		}

		// 处理系统窗口（系统菜单）的拖拽移动
		if( bIsDragging_Sys ) 
		{
			// 计算系统窗口的拖拽偏移量
			DX = Controller.MouseX - DragOffsetX;
			DY = Controller.MouseY - DragOffsetY;
			// 更新系统窗口的页面坐标
			Sys_PageX = DX;
			Sys_PageY = DY;
		}
		else 
		{
			// 系统窗口位置边界限制
			// 限制左边界
			if ( Sys_PageX < 0 )
				Sys_PageX = 0;
			// 限制右边界
			else if (Sys_PageX + WinWidth > C.ClipX)
				Sys_PageX = C.ClipX - WinWidth;
			// 限制上边界（系统窗口需要留出20像素的上边距）
			if ( Sys_PageY - 20 < 0 )
				Sys_PageY = TextOutRgn.H + 20 ;
			// 限制下边界（系统窗口高度为10行*14像素+15像素，再留出100像素边距）
			else if (Sys_PageY + 10 * 14 + 15 > C.ClipY)
				Sys_PageY = C.ClipY - (10 * 14 + 15 + 100);
		}

		// 如果既没有拖拽聊天窗口，也没有拖拽系统窗口，则结束移动状态
		if( !bIsDragging && !bIsDragging_Sys )
			bMovingUI = False;

		// 标记需要更新布局
		bNeedLayoutUpdate = True;
	}

	// ========== 第二部分：处理布局更新和大小调整 ==========
	// 当需要更新布局或正在调整窗口大小时，重新计算所有组件的位置和大小
	if( bNeedLayoutUpdate || bSizing ) 
	{        
		// 移动主聊天窗口组件（Components[0]）到新的页面坐标位置
		MoveComponent(Components[0],True,PageX,PageY);
		// 移动系统窗口组件（Components[7]）到新的系统页面坐标位置
		MoveComponent(Components[7],True,Sys_PageX,Sys_PageY);

		if ( bSizing && Controller.MouseY != ClickY ) 
		{
			YL = TextOutRgn.Y + TextOutRgn.H - Controller.MouseY; 
			if ( YL > MaxLines * TextSize )
				YL = MaxLines * TextSize;
			else if (YL < MinLines * TextSize)
				YL = MinLines * TextSize;
			Lines = YL / TextSize;
			YL = Lines * TextSize;
			if ( YL != TextOutRgn.H )
				TextOutRgn.H = YL;
		}

		// 计算滚动条（Components[3]）的高度
		// 滚动条高度 = 文本输出区域高度 - 锁定按钮（Components[2]）的高度
		// 注意：Components[4]（调整大小按钮）在TextOutRgn顶部，不占用滚动条高度
		//      Components[9]（向上滚动按钮）在TextOutRgn上方，不占用滚动条高度
		//      Components[10]（向下滚动按钮）在TextOutRgn底部，不占用滚动条高度
		//      Components[5]（移动按钮）在Components[10]下方，不占用滚动条高度
		Components[3].YL = TextOutRgn.H - Components[2].YL;

		// 遍历所有组件（从索引1开始，因为Components[0]已经手动移动），使用PivotId系统自动计算位置
		for( i = 1; i < Components.Length; i++ ) 
		{
			MoveComponentId(i);
		}
		
		// 设置消息输入框的大小：总宽度525减去频道按钮和发送按钮的宽度，高度固定为16像素
		MessageEdit.SetSize(525 - Components[0].XL - Components[1].XL,16);

		// 如果聊天模式选择器存在，设置其位置：在频道按钮（Components[1]）右侧，留出2像素间距
		if ( ChatMode != None )
			ChatMode.SetPosition(Components[1].X + Components[1].XL + 2, Components[1].Y);

		
		// 计算文本输出区域（聊天消息显示区域）的位置
		// X坐标：滚动条右侧
		TextOutRgn.X = Components[3].X + Components[3].XL;
		// Y坐标：主窗口顶部向上偏移文本区域的高度
		TextOutRgn.Y = Components[0].Y - TextOutRgn.H;

		// ========== 手动设置右侧按钮的精确位置 ==========
		// 这些按钮的位置需要精确控制，不能完全依赖PivotId系统
		
		Components[9].X = Components[3].X;
		Components[10].X = Components[3].X;

		// 如果不在移动UI状态，更新文本池的位置和大小
		// 文本池负责实际渲染聊天消息文本，需要与文本输出区域的位置和大小同步
		if( !bMovingUI )
			UpdateTextPoolPosition(TextOutRgn.X, TextOutRgn.Y, TextOutRgn.W - TextOutRgnWidthOffset, TextOutRgn.H);

		// 设置整个聊天窗口的页面位置
		SetPos(PageX,PageY);

		// 布局更新完成，清除更新标志
		if( bNeedLayoutUpdate )
			bNeedLayoutUpdate = False;
	}

	// ========== 第三部分：处理特殊输入框的位置 ==========
	// 如果当前是私聊模式且私聊输入框存在，设置其位置：在频道按钮右侧，留出2像素间距
	if ( ChannelMode == EChannelMode.Chan_Whisper && WhisperEdit != None )
		WhisperEdit.SetPos(Components[1].X + Components[1].XL + 2, Components[0].Y);

	// ========== 第四部分：处理消息输入框的位置和大小 ==========
	if ( MessageEdit != None ) 
	{
		// 如果是私聊模式且私聊输入框存在，消息输入框需要调整大小和位置以适应私聊输入框
		if ( ChannelMode == EChannelMode.Chan_Whisper && WhisperEdit != None ) 
		{
			// 消息输入框宽度 = 总宽度523 - 频道按钮宽度 - 发送按钮宽度 - 私聊输入框宽度
			MessageEdit.SetSize(523 - Components[0].XL - Components[1].XL - WhisperEdit.WinWidth,16);
			// 消息输入框位置：在私聊输入框右侧，留出1像素间距
			MessageEdit.SetPos(WhisperEdit.WinX + WhisperEdit.WinWidth + 1,WhisperEdit.WinY);
		}
		else
			// 非私聊模式：消息输入框位置在频道按钮右侧，留出1像素间距
			MessageEdit.SetPos(Components[1].X + Components[1].XL + 1, Components[0].Y);
	}

	// 调用父类的Layout函数，执行父类的布局逻辑
	Super.Layout(C);

	// ========== 第五部分：处理请求信息对话框的位置 ==========
	// 如果请求信息对话框需要显示，计算其位置和内部按钮的位置
	if( ReqInfo.bShow )
	{
		// 如果是私聊模式，请求信息对话框位置在私聊输入框右侧
		if ( ChannelMode == EChannelMode.Chan_Whisper && WhisperEdit != None )
		{
			ReqInfo.X = WhisperEdit.WinX + WhisperEdit.WinWidth + 1;
			ReqInfo.Y = WhisperEdit.WinY;
		}
		else
		{
			// 非私聊模式：请求信息对话框位置在频道按钮右侧，留出2像素间距
			ReqInfo.X = Components[1].X + Components[1].XL + 2;
			ReqInfo.Y = Components[0].Y;
		}
		// 垂直居中：根据频道按钮高度和请求信息对话框高度的差值进行居中调整
		ReqInfo.Y += (Components[0].YL - ReqInfo.YL) / 2;
		// 计算"是"按钮的位置：在请求信息对话框右侧，留出10像素间距
		ReqInfo.YesX = ReqInfo.X + ReqInfo.XL + 10;
		ReqInfo.YesY = ReqInfo.Y;
		// 计算"否"按钮的位置：在"是"按钮右侧，留出4像素间距和斜杠宽度
		ReqInfo.NoX = ReqInfo.YesX + ReqInfo.YesXL + 4 + SlashWidth;
		ReqInfo.NoY = ReqInfo.Y;
	}

	// ========== 第六部分：更新文本池的可见行数 ==========
	// 如果文本池存在，根据文本输出区域的高度计算可见行数并更新
	if ( SelectedTextPool != None )
	{
		// 计算新的可见行数：文本区域高度除以每行文本高度
		NewVisible = int(TextOutRgn.H / float(TextSize));
		// 如果可见行数发生变化，更新文本池的可见行数设置
		// 这会影响文本池的渲染优化，只渲染可见范围内的文本
		if ( NewVisible != LastVisibleLines )
		{
			SelectedTextPool.SetVisibleLines(NewVisible);
			LastVisibleLines = NewVisible;
		}
	}
}

function UpdateLayout()
{
	bNeedLayoutUpdate = True;
}

function OnPreRender(Canvas C)
{
    
	local string OldText, ChannelStr, TeamName;
	local ImeInterface IME;


	if( bInvisible ) 
		return;

	C.SetRenderStyleAlpha();


	// ä�ù�ư
	C.SetRenderStyleAlpha();
	C.SetPos(Components[1].X - 3, Components[1].Y);
	C.DrawTile(TextureResources[0].Resource,Components[1].XL + 6,Components[1].YL,0,0,16,16);

	if( IsCursorInsideComponent(Components[5]) )
	{
		if( bIsDragging )
			BindTextureResource(Components[5],TextureResources[8]);
		else
			BindTextureResource(Components[5],TextureResources[7]);
	}
	else
		BindTextureResource(Components[5],TextureResources[6]);

	if( IsCursorInsideComponent(Components[7]) )
	{
		if( bIsDragging_Sys )
			BindTextureResource(Components[7],TextureResources[8]);
		else
			BindTextureResource(Components[7],TextureResources[7]);
	}
	else if (Components[7].bVisible)
		BindTextureResource(Components[7],TextureResources[6]);

	if( bModeChanged )
	{
		OldText = Components[1].Caption;

		switch (ChannelMode) 
		{
			case EChannelMode.Chan_Tell:
				Components[1].Caption = TellButton;
				bModeChanged = False;
				break;
			case EChannelMode.Chan_Shout:
				Components[1].Caption = ShoutButton;
				bModeChanged = False;
				break;
			case EChannelMode.Chan_Whisper:
				Components[1].Caption = WhisperButton;
				bModeChanged = False;
				break;
			case EChannelMode.Chan_Party:
				Components[1].Caption = PartyButton;
				bModeChanged = False;
				break;
			case EChannelMode.Chan_Shell1:
				ChannelStr = SephirothPlayer(PlayerOwner).PSI.GetRightChannel();
				TeamName = SephirothPlayer(PlayerOwner).PSI.TeamName;
				if ( ChannelStr != "" )
				{
					Components[1].Caption = ChannelStr;
					bModeChanged = False;
				}
				else if ((TeamName != "") && (TeamName != "NONE"))
					SetChannelMode(EChannelMode.Chan_Team);
				else
					SetChannelMode(EChannelMode.Chan_Tell);
				break;
			case EChannelMode.Chan_Shell2:
				ChannelStr = SephirothPlayer(PlayerOwner).PSI.GetLeftChannel();
				TeamName = SephirothPlayer(PlayerOwner).PSI.TeamName;
				if ( ChannelStr != "" )
				{
					Components[1].Caption = ChannelStr;
					bModeChanged = False;
				}
				else if ((TeamName != "") && (TeamName != "NONE"))
					SetChannelMode(EChannelMode.Chan_Team);
				else
					SetChannelMode(EChannelMode.Chan_Tell);
				break;
			case EChannelMode.Chan_Team:
				Components[1].Caption = TeamButton;
				bModeChanged = False;
				break;
			case EChannelMode.Chan_Clan:
				Components[1].Caption = ClanButton;
				bModeChanged = False;
				break;
		}
       
		Components[1].bSizeCalced = OldText == Components[1].Caption;
		Components[1].bLayout = OldText == Components[1].Caption;
		bNeedLayoutUpdate = True;
	}


	IME = class'CNativeInterface'.Static.GetImeInterface();
	if ( IME != None ) 
	{
		if ( IME.IsNativeMode() )
			SetComponentText(Components[0], "ImeOn");
		else
			SetComponentText(Components[0], "ImeOff");
	}
    
    //bIsDragging = bSizing;    //????? 2009.10.27.Sinhyub
}

function OnPostRender(HUD H, Canvas C)
{
	local Texture SepTexture;
	local float X,Y;

	if( bInvisible ) 
		return;
    /* 
    C.SetPos(X, Y-1);
    C.DrawTile(TextureResources[2].Resource, 527, TextOutRgn.H+1, 0, 0, 256, 16);
    */
    
	C.Style = ERenderStyle.STY_Alpha;
    
	// 实现从左到右的渐变效果
	// 使用纹理渐变方案：TextureResources[2]用于左边（完全不透明），TextureResources[3]用于右边（纹理本身带渐变）
	// 这种方式性能更好（只需2次DrawTile调用），效果也更平滑自然
	X = TextOutRgn.X;
	Y = TextOutRgn.Y;
	
	// 绘制左边256像素：完全不透明
	C.SetPos(X - 16, Y);
	C.DrawTile(TextureResources[2].Resource, 256.0, TextOutRgn.H, 0, 0, 256, 16);
	
	// 绘制右边256像素：纹理本身带有从左到右的Alpha渐变
	C.SetPos(X - 16 + 256.0, Y);
	C.DrawTile(TextureResources[3].Resource, 256.0, TextOutRgn.H, 0, 0, 256, 16);

	C.SetPos(Components[4].X, Components[4].Y);
	C.SetRenderStyleAlpha();
	if ( bSizing )
		SepTexture = Controller.SizePress;
	else if (IsCursorInsideComponent(Components[4]))
		SepTexture = Controller.SizeOver;
	else
		SepTexture = Controller.SizeNormal;
	if ( SepTexture != None )
		C.DrawTile(SepTexture,16,16,0,0,16,16);

	// 绘制向上滚动按钮（Components[9]）
	if ( Components[9].bVisible )
	{
		C.SetPos(Components[9].X, Components[9].Y);
		C.SetRenderStyleAlpha();
		if ( IsCursorInsideComponent(Components[9]) )
			SepTexture = Controller.SizeOver;
		else
			SepTexture = Controller.SizeNormal;
		if ( SepTexture != None )
			C.DrawTile(SepTexture,16,16,0,0,16,16);
	}

	// 绘制向下滚动按钮（Components[10]）
	// 通过翻转纹理坐标实现向下箭头效果
	if ( Components[10].bVisible )
	{
		C.SetPos(Components[10].X, Components[10].Y);
		C.SetRenderStyleAlpha();
		if ( IsCursorInsideComponent(Components[10]) )
			SepTexture = Controller.SizeOver;
		else
			SepTexture = Controller.SizeNormal;
		if ( SepTexture != None )
			// 垂直翻转纹理：从底部(16)开始，向上绘制(-16)，实现向下箭头
			C.DrawTile(SepTexture, 16, 16, 0, 16, 16, -16);
	}

	X = TextOutRgn.X;
	Y = TextOutRgn.Y;

    //@by wj(05/30)
	if( ReqInfo.bShow )
		DrawRequestMessage(C);

	C.Style = ERenderStyle.STY_Normal;
	SelectedTextPool.DrawMessage(C, X, Y + TextOutRgn.H, C.ClipX);

	if ( ChannelMode == EChannelMode.Chan_Whisper ) 
	{
		C.SetPos(WhisperEdit.WinX, WhisperEdit.WinY);
		C.SetRenderStyleAlpha();
		C.DrawTileStretched(TextureResources[0].Resource, WhisperEdit.WinWidth, WhisperEdit.WinHeight);
	}

	if ( SephirothInterface(Parent).bBlockPapering ) 
	{
		C.Style = ERenderStyle.STY_Normal;
		C.SetPos(MessageEdit.WinX, MessageEdit.WinY);
		C.SetDrawColor(255,128,0);
		C.DrawTileStretched(Texture'Engine.WhiteSquareTexture',MessageEdit.WinWidth * (SephirothInterface(Parent).PaperingBlockTicks / SephirothInterface(Parent).PaperingBlockSeconds), MessageEdit.WinHeight);
		C.DrawTextJustified(MakeColorCodeEx(200,200,200)$Localize("Information","MessageSyncBlocked","Sephiroth"), 0, MessageEdit.WinX, MessageEdit.WinY, MessageEdit.WinX + MessageEdit.WinWidth, MessageEdit.WinY + MessageEdit.WinHeight);
		C.DrawTextJustified(MakeColorCodeEx(0,0,0)$Localize("Information","MessageSyncBlocked","Sephiroth"), 0, MessageEdit.WinX + 1, MessageEdit.WinY + 1, MessageEdit.WinX + MessageEdit.WinWidth + 1, MessageEdit.WinY + MessageEdit.WinHeight + 1);
	}
    
}

function OnSendWhisper(string Name)
{
	SetChannelMode(EChannelMode.Chan_Whisper);
	if ( Name != "" ) 
	{
		WhisperEdit.SetText(Name);
		GotoState('WhisperEditing');
	}
}

function OnSelectWhisperName(string SelectedText)
{
	SetChannelMode(EChannelMode.Chan_Whisper);
	if ( SelectedText != "" ) 
	{
		WhisperEdit.SetText(SelectedText);
		GotoState('WhisperEditing');
	}
}

//@by wj(05/27)------
function OnSelectBlockUserName(string SelectedText)
{
	if( SelectedText != "" && !SephirothInterface(Parent).bBlockPapering )
	{
		MessageEdit.SetText("/"$Localize("Commands","LockUserMessage","Sephiroth")@SelectedText);
		GotoState('MessageEditing');
	}
}

function SetRequestInfo(string Message, bool IsXcng)
{
	ReqInfo.ReqMessage = Message;
	ReqInfo.IsXcngRequest = IsXcng;
	if ( ChannelMode == EChannelMode.Chan_Whisper && WhisperEdit != None )
	{
		ReqInfo.X = WhisperEdit.WinX + WhisperEdit.WinWidth + 1;
		ReqInfo.Y = WhisperEdit.WinY;
	}
	else
	{
		ReqInfo.X = Components[0].XL + Components[1].XL + 2;
		ReqInfo.Y = Components[0].Y;
	}
	class'CNativeInterface'.Static.TextSize(Message, ReqInfo.XL, ReqInfo.YL);
	ReqInfo.Y += (Components[0].YL - ReqInfo.YL) / 2;
	ReqInfo.YesX = ReqInfo.X + ReqInfo.XL + 10;
	ReqInfo.YesY = ReqInfo.Y;
	class'CNativeInterface'.Static.TextSize(Localize("Commands","Yes","Sephiroth"),ReqInfo.YesXL, ReqInfo.YesYL);
	ReqInfo.NoX = ReqInfo.YesX + ReqInfo.YesXL + 4 + SlashWidth;
	ReqInfo.NoY = ReqInfo.Y;
	class'CNativeInterface'.Static.TextSize(Localize("Commands","No","Sephiroth"),ReqInfo.NoXL, ReqInfo.NoYL);
	ReqInfo.bShow = True;
    //Log("ReqInfo.bShow: TRUE");
}

function DrawRequestMessage(Canvas C)
{
	local color OldColor;
	local string TextYes, TextNo;

	TextYes = Localize("Commands","Yes","Sephiroth");
	TextNo = Localize("Commands","No","Sephiroth");

	OldColor = C.DrawColor;
	C.SetDrawColor(0, 0, 0);
	C.DrawKoreanText(ReqInfo.ReqMessage, ReqInfo.X + 1, ReqInfo.Y + 1, ReqInfo.XL, ReqInfo.YL);
	C.DrawKoreanText(TextYes, ReqInfo.YesX + 1, ReqInfo.YesY + 1, ReqInfo.YesXL, ReqInfo.YesYL);
	C.DrawKoreanText("/",ReqInfo.YesX + ReqInfo.YesXL + 4,ReqInfo.Y + 1, SlashWidth, ReqInfo.YL);
	C.DrawKoreanText(TextNo, ReqInfo.NoX + 1, ReqInfo.NoY + 1, ReqInfo.NoXL, ReqInfo.NoYL);
	C.SetDrawColor(255, 255, 255);
	C.DrawKoreanText(ReqInfo.ReqMessage, ReqInfo.X, ReqInfo.Y, ReqInfo.XL, ReqInfo.YL);
	C.DrawKoreanText("/",ReqInfo.YesX + ReqInfo.YesXL + 3,ReqInfo.Y, SlashWidth, ReqInfo.YL);
	if( CursorInYes() )
	{
		C.SetDrawColor(255, 255, 0);
		C.DrawKoreanText(TextYes, ReqInfo.YesX, ReqInfo.YesY, ReqInfo.YesXL, ReqInfo.YesYL);
		C.SetDrawColor(255, 255, 255);
		C.DrawKoreanText(TextNo, ReqInfo.NoX, ReqInfo.NoY, ReqInfo.NoXL, ReqInfo.NoYL);
	}
	else if(CursorInNo())
	{
		C.DrawKoreanText(TextYes, ReqInfo.YesX, ReqInfo.YesY, ReqInfo.YesXL, ReqInfo.YesYL);
		C.SetDrawColor(255, 255, 0);
		C.DrawKoreanText(TextNo, ReqInfo.NoX, ReqInfo.NoY, ReqInfo.NoXL, ReqInfo.NoYL);
	}
	else
	{
		C.DrawKoreanText(TextYes, ReqInfo.YesX, ReqInfo.YesY, ReqInfo.YesXL, ReqInfo.YesYL);
		C.DrawKoreanText(TextNo, ReqInfo.NoX, ReqInfo.NoY, ReqInfo.NoXL, ReqInfo.NoYL);
	}
	C.DrawColor = OldColor;
}

function bool CursorInYes()
{
	if( Controller.MouseX >= ReqInfo.YesX && Controller.MouseX <= ReqInfo.YesX + ReqInfo.YesXL &&
			Controller.MouseY >= ReqInfo.YesY && Controller.MouseY <= ReqInfo.YesY + ReqInfo.YesYL )
		return True;
	return False;
}

function bool CursorInNo()
{
	if( Controller.MouseX >= ReqInfo.NoX && Controller.MouseX <= ReqInfo.NoX + ReqInfo.NoXL &&
			Controller.MouseY >= ReqInfo.NoY && Controller.MouseY <= ReqInfo.NoY + ReqInfo.NoYL )
		return True;
	return False;
}
//-------------------

function OnRequestPartyMessage(string Message)
{
	if( ChatMode != None )
		HideChannel();
	MessageEdit.SetText("");
	GotoState('');

	partyReqMessage = Message;
}

function OnRequestXcngMessage(string Message)
{
	if( ChatMode != None )
		HideChannel();
	MessageEdit.SetText("");
	GotoState('');

	xcngReqMessage = Message;
}

function Bool OnQueryKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
{
	if( Key == IK_LeftMouse && ReqInfo.bShow )
	{
		if ( Action == IST_Press ) 
		{
			if( CursorInYes() )
				return True;
			if( CursorInNo() )
				return True;
		}
		else if (Action == IST_Release) 
		{
			if( CursorInYes() )
			{
				ReqInfo.bShow = False;
				OnQueryAccept();
				return True;
			}
			else if(CursorInNo())
			{
				ReqInfo.bShow = False;
				OnQueryDeny();
				return True;
			}
		}
	}
	return False;
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
{
    //ä��â ���߱� ���� ��� Ű�̺�Ʈ�� ����.  Sinhyub
	if( bInvisible )
		return False;

	if ( OnQueryKeyEvent(Key, Action, Delta) )
		return True;

    //�ؽ�Ʈ ��� ����(ä��â)�� �̺�Ʈ ó��
	if ( IsCursorInsideRegion(TextOutRgn) ) 
	{
        //1. �� ���
        
		if ( Action == IST_Press ) 
		{
			if ( Key == IK_MouseWheelUp ) 
			{
				NotifyScrollUp(-1,1);
				return True;
			}
			else if (Key == IK_MouseWheelDown) 
			{
				NotifyScrollDown(-1,1);
				return True;
			}
		}
        //2. ������ �̺�Ʈ�� �ش��ϴ� �ؽ�ƮǮ ���ο��� ó��.   -2009.11.9.Sinhyub
        // ��Ŭ�� : �ӼӸ� ����, ��Ŭ�� : ���� ����  (CTextPool���ο��� ó���մϴ�)
		if( (Action == IST_Press) || (ACtion == IST_Release) )
		{
			if( SelectedTextPool.KeyEvent(Key, Action, Delta) )
				return True;
		}
	}


    // ���� ���콺 �̺�Ʈ�� �߻��ߴ�.
	if ( Key == IK_LeftMouse ) 
	{
        //1.�̵� ��ư�� �̿��Ͽ� â�� ��ġ�� �̵��� �� �ֽ��ϴ�.
		if ( (Action == IST_Press) && IsCursorInsideComponent(Components[5]) )
		{
			bMovingUI = True;
			bIsDragging = True;
			DragOffsetX = Controller.MouseX - PageX;
			DragOffsetY = Controller.MouseY - PageY;
			return True;
		}
		if ( (Action == IST_Release) && bIsDragging ) 
		{
			bIsDragging = False;
			DragOffsetX = 0;
			DragOffsetY = 0;
			SaveConfig();
			return True;
		}
		if ( (Action == IST_Press) && IsCursorInsideComponent(Components[7]) )
		{
			bMovingUI = True;
			bIsDragging_Sys = True;
			DragOffsetX = Controller.MouseX - Sys_PageX;
			DragOffsetY = Controller.MouseY - Sys_PageY;
			return True;
		}
		if ( Action == IST_Release && bIsDragging_Sys ) 
		{
			bIsDragging_Sys = False;
			DragOffsetX = 0;
			DragOffsetY = 0;
			SaveConfig();
			return True;
		}

        //2.��Ÿ
		if ( Action == IST_Press ) 
		{
			// 检查滚动按钮点击（优先处理）
			if ( IsCursorInsideComponent(Components[9]) ) 
			{
				NotifyComponent(Components[9].Id, Components[9].NotifyId);
				return True;
			}
			if ( IsCursorInsideComponent(Components[10]) ) 
			{
				NotifyComponent(Components[10].Id, Components[10].NotifyId);
				return True;
			}

            // --- 点击上/下滚：优先处理 ---
			if ( IsInScrollUpBtn() )
			{
                // 每次点动几行：这里给 1 行；想要“半页/一页”，把 1 换成你计算的行数
				NotifyScrollUp(-1, 1);
				return True;
			}
			if ( IsInScrollDownBtn() )
			{
				NotifyScrollDown(-1, 1);
				return True;
			}

			if ( WhisperEdit.IsInBounds() ) 
			{ 
	// �����̸� �̸��Է»��ڿ���
				GotoState('WhisperEditing');        //�̰� ���� ��ܿ� ���ִ�. �������������������� Sinhyub
				return True;
			}
			if ( MessageEdit.IsInBounds() && !SephirothInterface(Parent).bBlockPapering ) 
			{ 
	// �����̸� �޽����Է»��ڿ���
                // ĳ���Ͱ� �ٰ� �־����� �׳� ��ŵ����.
//              if (PlayerOwner.Pawn.Acceleration.X == 0 && PlayerOwner.Pawn.Acceleration.Y == 0) {
				GotoState('MessageEditing');
				return True;
//              }
			}
			if ( IsCursorInsideComponent(Components[4]) ) 
			{
				bSizing = True;
                //ListenMode.bIsParentSizing=true;        //modified by yj        //ListenMode.uc�� �����ϼ���
				ClickY = Controller.MouseY;
				return True;
			}
		}
		else if (Action == IST_Release) 
		{
			if ( bSizing ) 
			{
				bSizing = False;
                //ListenMode.bIsParentSizing=false;
				return True;
			}
		}
	}

    // ����Ű�� ��������.
	if ( Key == IK_Enter && Action == IST_Press ) 
	{
        //@by wj(05/30)------
        //if(ReqInfo.bShow)
        //  return true;
        //-------------------
        // �ͼӸ� ����� ��쿡, �̸��Է»��ڰ� ��Ŀ���� ���� ������ ������ ��Ŀ���� ����.
		if ( ChannelMode == EChannelMode.Chan_Whisper && !WhisperEdit.HasFocus() && WhisperEdit.GetText() == "" )
			GotoState('WhisperEditing');
        // �ƴϸ�, �޽����� �Է��ϵ��� ����.
		else if (!SephirothInterface(Parent).bBlockPapering)
			GotoState('MessageEditing');
		return True;
	}

	if ( Key == IK_Escape && Action == IST_Press ) 
	{      
	//modified by yj  //Ȥ�� �� ��Ȳ�� ����Ͽ�
		if( bSizing ) 
		{
			bSizing = False;
			return True;
		}
		if( bIsDragging ) 
		{
			bIsDragging = False;
			return True;
		}
		if( bIsDragging_Sys ) 
		{
			bIsDragging_Sys = False;
			return True;
		}

		return False;
	}

	if ( !Controller.bProcessingKeyType ) 
	{
        // ���� ���ȴ� ������.
		if ( Key == IK_Period && Action == IST_Release ) 
		{
			OnSendWhisper(ConsoleCommand("GETLASTWHISPER"));
			return True;
		}

        // ä�� ����Ű ó���� �̷��� �Ѵ�.
		if ( !PlayerOwner.Player.Console.bTyping && !SephirothInterface(Parent).bBlockPapering ) 
		{
			if ( Controller.bCtrlPressed && (Key >= IK_0 && Key <= IK_7 || Key == IK_Tilde) ) 
			{
				switch (Key) 
				{
					case IK_Tilde:
						if ( (SephirothPlayer(PlayerOwner).PSI.TeamName == "") || (SephirothPlayer(PlayerOwner).PSI.TeamName == "NONE") ) //"NONE"�� ����Ʋ ������� ���
							SetChannelMode(EChannelMode.Chan_Tell);
						return True;
					case IK_1:
						if ( (SephirothPlayer(PlayerOwner).PSI.TeamName == "") || (SephirothPlayer(PlayerOwner).PSI.TeamName == "NONE") )
							SetChannelMode(EChannelMode.Chan_Shout);
						return True;
					case IK_2:
						SetChannelMode(EChannelMode.Chan_Whisper);
						return True;
					case IK_3:
						SetChannelMode(EChannelMode.Chan_Party);
						return True;
					case IK_4:
						if( (SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE") ) //add neive : �������̸� ä�η� �ٲٷ��ص� ���������� �ȴ�
							SetChannelMode(EChannelMode.Chan_Team);
						else
							SetChannelMode(EChannelMode.Chan_Shell1);
						return True;
					case IK_5:
						if( (SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE") ) //add neive : �������̸� ä�η� �ٲٷ��ص� ���������� �ȴ�
							SetChannelMode(EChannelMode.Chan_Team);
						else
							SetChannelMode(EChannelMode.Chan_Shell2);
						return True;
					case IK_6:
						if ( (SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE") )
							SetChannelMode(EChannelMode.Chan_Team);
						return True;
					case IK_7:
						if ( SephirothPlayer(PlayerOwner).PSI.ClanName != "" )
							SetChannelMode(EChannelMode.Chan_Clan);
						return True;
				}
			}
			if ( Key == IK_Slash && Action == IST_Press ) 
			{
				GotoState('MessageEditing');
				return True;
			}
		}
	}

    // 鼠标（含滚轮）事件透传给文本池
	if ( TextPool != None && TextPool.KeyEvent(Key, Action, Delta) )
		return True;

    // 右键同样透传
	if ( TextPool != None && int(Key) == 2 )  // IK_RightMouse
		if ( TextPool.KeyEvent(Key, Action, Delta) )
			return True;

	return False;
}

// �� ����Ʈ ��Ʈ���� ��Ŀ���� ���� �� ȣ��ȴ�.
// ������ �б� ������ ȣ��ȴ�.
function OnFinishWhisperEdit();
function OnFinishMessageEdit();

// WhisperEdit�� ��Ŀ���� ���� �� �� ���� �������� ����
// ���� �̺�Ʈ���� �ͼӸ������ ��쿡, EnterŰ�� �������ų�, ���콺�� �������� ����� ���´�.
state WhisperEditing
{
	function BeginState()
	{
        // �̸��Է��� �Ҽ� �ְ� ��Ŀ���� ��������
		WhisperEdit.SetFocusEditBox(True);
	}
	function EndState()
	{
        // �� ���°� ������, ��Ŀ���� ������ ������ ���� �ʵ��� ��~_~��.
		WhisperEdit.SetFocusEditBox(False);
	}
	function OnFinishWhisperEdit()
	{
		WhisperEdit.SetText("");
		GotoState('');
	}
	function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
	{
        // ���Ⱑ �ƴ� �ٸ� ���� ���� ��ư�� ��������, ������
		if (!WhisperEdit.IsInBounds() && Key == IK_LeftMouse && Action == IST_Press) 
		{
			GotoState('');
            // �޽��� �Է�â�� ������������ �𸣴ϱ� �۷ι� �̺�Ʈ�� �ѱ���.
			return Global.OnKeyEvent(Key, Action, Delta);
		}
        // ����Ű�� ������, �Է��� �������Ƿ�, �޽��� �Է��ϵ��� ��������
		if (Key == IK_Enter && Action == IST_Press && !SephirothInterface(Parent).bBlockPapering) 
		{
			GotoState('MessageEditing');
			return True;
		}
        // ESC�� ������ �Է��� �������.
		if (Key == IK_Escape && Action == IST_Press) 
		{
			WhisperEdit.SetText("");
			GotoState('');
			return True;
		}
		return Global.OnKeyEvent(Key, Action, Delta);
	}
}


state MessageEditing
{
	ignores OnQueryKeyEvent;

	function BeginState()
	{

		MessageEdit.SetFocusEditBox(True);
	}
	function EndState()
	{

		MessageEdit.SetFocusEditBox(False);
		MessageEdit.SetText("");
	}
	function OnFinishMessageEdit()
	{
		GotoState('');
	}
	function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
	{

		if (!MessageEdit.IsInBounds() && Key == IK_LeftMouse && Action == IST_Press) 
		{
			GotoState('');

			return Global.OnKeyEvent(Key, Action, Delta);
		}

		if (Key == IK_Enter && Action == IST_Press) 
		{
			SyncChannel();
			GotoState('');
			return True;
		}

		if (Key == IK_Escape && Action == IST_Press) 
		{
			MessageEdit.SetText("");
			GotoState('');
			return True;
		}
		return Global.OnKeyEvent(Key, Action, Delta);
	}
	function OnPostRender(HUD H, Canvas C)
	{
		Global.OnPostRender(H,C);
		C.Style = ERenderStyle.STY_Alpha;
		C.SetPos(MessageEdit.WinX, MessageEdit.WinY);
		C.DrawTileStretched(TextureResources[3].Resource, MessageEdit.WinWidth, MessageEdit.WinHeight);
	}
	function bool PointCheck()
	{
		if (MessageEdit.IsInBounds())
			return True;
		return Global.PointCheck();
	}
}

function bool PushComponentBool(int CmpId)
{
	if ( CmpId == 2 )
		return bHold;

	else if(CmpId == 8)
		return bShowSystemMessage;
	else
		return False;
}

function UseTeamChannel()
{
	switch(SephirothPlayer(PlayerOwner).PSI.MatchName) 
	{
		case "GTF" :
			if( SephirothPlayer(PlayerOwner).PSI.TeamName != "" )
				SetChannelMode(EChannelMode.Chan_Team);
			break;
		case "STB" :
            //Log(SephirothPlayer(PlayerOwner).PSI.TeamName);
			if( (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "") )
				SetChannelMode(EChannelMode.Chan_Team);
			break;
	}

}

function bool PointCheck()
{
	if ( bSizing )
		return True;
	if ( ChatMode != None && ChatMode.PointCheck() )
		return True;
    //if (ListenMode != None && ListenMode.PointCheck())
    //    return true;
    //if (ListenList != None && ListenList.PointCheck())
    //    return true;
	if ( SelectedTextPool != None && SelectedTextPool.PointCheck() )
		return True;
	if ( ReqInfo.bShow &&
			Controller.MouseX >= ReqInfo.X && Controller.MouseX <= ReqInfo.NoX + ReqInfo.NoXL &&
			Controller.MouseY >= ReqInfo.Y && Controller.MouseY <= ReqInfo.Y + ReqInfo.YL )
		return True;
	return IsCursorInsideComponent(Components[0])
		|| IsCursorInsideComponent(Components[1])
		|| IsCursorInsideComponent(Components[2])
		|| IsCursorInsideComponent(Components[3])
		|| IsCursorInsideComponent(Components[4])
		|| IsCursorInsideComponent(Components[5])
		|| IsCursorInsideComponent(Components[9])
		|| IsCursorInsideComponent(Components[10])
        //|| IsCursorInsideComponent(Components[6])
        //|| IsCursorInsideComponent(Components[7])
		|| (ChannelMode == EChannelMode.Chan_Whisper && WhisperEdit.IsInBounds());
}

function RemoveSpaces(out string Message)
{
	if ( Message == "" )
		return;
	while ( Left(Message, 1) == " " )
		Message = Mid(Message, 1);
}

event Tick(float DeltaTime)
{
	local bool bEraseMessage;
	bEraseMessage = bool(ConsoleCommand("GETOPTIONI EraseMessage"));
	if ( bEraseMessage && !bHold )
		SelectedTextPool.CheckAge(DeltaTime);
}

function SyncChannel()      //��� �Է��Ѱ� ó���ϴ� ����.
{
	local string MessageText, Head;
	local string Command, Message, Extra;
	local name AnimName;
	local string ChannelStr;
	local int i;

    // Mr.Do - ����â ����

    // ��! ������ ������.
	MessageText = MessageEdit.GetText();
	if ( MessageText != "" ) 
	{

		//Log("MessageText" @ MessageText);
        // ������ �����ϰ�...
		RemoveSpaces(MessageText);      //������ �����̽��� �ô´�.

        // ���۸��ɸӸ����ڸ� ������ �ƿ� ������ ����. ����� ��-_�Ѱ�...
		if ( MessageText == "\\\\" )
			return;

        // ù��° ���ڰ� ä�θӸ��������� �Ǵ�����, ������ ������.
		Head = Left(MessageText, 1);
		for ( i = 0;i < ArrayCount(ChannelPrefix);i++ )
			if ( Head == ChannelPrefix[i] )
				break;
		if ( i < ArrayCount(ChannelPrefix) ) 
		{ 
	// ������ �޽����� �̹� ���ԵǾ� �ִ�.
			Command = Head;
            // ���ɰ� �޽����� �и�����.
			MessageText = Mid(MessageText, 1);
            // ������ �����ϰ�...
			RemoveSpaces(MessageText);
			if ( Command == "/" ) 
			{ 
	// ������ ������ Ư���� ���� ó������.
				ProcessSlashCommand(MessageText);
				return;
			}
		}
		else // ������ �޽����� ���ԵǾ� ���� �����ϱ�, ä�θ�带 ���� ������ ������.
			Command = ChannelPrefix[ChannelMode];

        // ���� �޽����� �ٷ� �װŴ�.
		Message = MessageText;

        // Ư���� �������� ������ (�ͼӸ� ����̳�.. ä�� �̸��̳�..)
		switch (ChannelMode) 
		{
			case EChannelMode.Chan_Whisper:
            // �ͼӸ��� ���� ����̸��� ��������.
				Extra = WhisperEdit.GetText();
				break;
			case EChannelMode.Chan_Shell1:
			case EChannelMode.Chan_Shell2:
            // ä�� �̸��� ��������.
				if ( ChannelMode == EChannelMode.Chan_Shell1 )
					ChannelStr = SephirothPlayer(PlayerOwner).PSI.GetRightChannel();
				else
					ChannelStr = SephirothPlayer(PlayerOwner).PSI.GetLeftChannel();
				if ( ChannelStr != "" )
					Extra = ChannelStr;
				else
					return;
				break;
			case EChannelMode.Chan_Clan:
				Extra = SephirothPlayer(PlayerOwner).PSI.ClanName;
				if ( Extra == "" )
					return;
			default:
            // �ٸ� ä�θ�忡���� Ư���� ������ �ʿ����.
				Extra = "";
				break;
		}

        // �޽����� ��ĵ�Ͽ� �弳�� ������ ����� ������.
		for ( i = 0;i < Illegals.Length;i++ ) 
		{
			//Log("cs debug Illegals err2" @ Illegals[i]);
			if ( InStr(Message, Illegals[i]) != -1 ) 
			{
				//Log("cs debug Illegals err4");
				//Log(Message);
				//Log(string(i));
				TextPool.AddMessage(Localize("Information","IllegalTextUsed","Sephiroth"),
					class'Canvas'.Static.MakeColor(255,255,0),
					12, 4, 2, False, 0, 0, "",
					True,
					class'Canvas'.Static.MakeColor(0,0,0),
					2);
				break;
			}
		}

        //add neive : ������ ���� ������
		if ( Left(Message, 2) != "\\\\" && Command != "@" && Command != "#" && Command != "&" && SephirothInterface(Parent).ProcessBunchText(Message) )
        //if (Left(Message, 2) != "\\\\" && Command != "@" && Command != "#" && SephirothInterface(Parent).ProcessBunchText(Message))
			return;

        // ���� �������� ��ũ����.

        // �������� �����̸� �ٷ� ������.
		if ( Left(Message, 2) == "\\\\" )
		{
            // Mr.Do - ����â ���� ȣ�� === Start ===
			MessageText = Mid(Message, 2);
            // ��� ���� ������
			if ( Left(MessageText, 8) == "SendNote" )
			{
				MessageText = Mid(MessageText, 9);
				SephirothInterface(Parent).SuperSendNote(MessageText);
				return;
			}
            // Mr.Do - ����â ���� ȣ�� === End ===

			SephirothPlayer(PlayerOwner).Net.NotiTell(1, Message);
			bHold = False;
			return;
		}

        // ���⼭���� ������ ��忡���� ������ �ʴ´�.
        // 2003�� 11�� 20�� ������ ��忡�� �ͼӸ��� �����ϵ��� �ٲ۴�. (jhjung)
        /*
        if (SephirothPlayer(PlayerOwner).IsTransparent()) {
            if (Command != "~" && Command == "@")
                SephirothPlayer(PlayerOwner).Net.NotiWhisper(Extra, Message);
            return;
        }
        */

//      if (Command != "@" && Command != "#")
//          Message = Message $ "TIME_JJH_STAMP" $ Level.TimeSeconds;

        // �ͼӸ�, ä�θ�, ��ġ��, ��Ƽ���� �׳� �״�� ����������.
		if ( Command != "~" ) 
		{
			if ( Command == "!" && ((SephirothPlayer(PlayerOwner).PSI.TeamName == "") || (SephirothPlayer(PlayerOwner).PSI.TeamName == "NONE" )) )    //None -> ��Ʋ�ý��ۿ��� ��� .Sinhyub
				SephirothPlayer(PlayerOwner).Net.NotiTell(2, Message);
			else if (Command == "@") 
			{
                // SephirothInterface(Parent).StartDialogSession(Extra, Message);
				SephirothPlayer(PlayerOwner).Net.NotiWhisper(Extra, Message);
			}
			else if (Command == "#")
				SephirothPlayer(PlayerOwner).Net.NotiPartyTell(Message);
			else if (Command == "$" || Command == "%")
				SephirothPlayer(PlayerOwner).Net.NotiTellChannel(Extra, Message);
			else if (Command == "&")
				SephirothPlayer(PlayerOwner).Net.NotiTellTeam(Message);
			else if (Command == "*")
				SephirothPlayer(PlayerOwner).Net.NotiClanTell(Extra, string(SephirothPlayer(PlayerOwner).PSI.PlayName), Message);
			bHold = False;
			return;
		}
		else if (Command == "~" && ((SephirothPlayer(PlayerOwner).PSI.TeamName != "") && (SephirothPlayer(PlayerOwner).PSI.TeamName != "NONE")))
		{
			bHold = False;
			return;
		}

        // ���� ���ϱ� �޽����� ���Ҵ�.
        // ���⼱, �޽����� ���� ��Ȱ���ۿ� �ܾ ��� �ִ��� �켱 �˻������ �ȴ�.
		AnimName = GetAnimToken(Message);
		if ( AnimName != '' )
			SephirothPlayer(PlayerOwner).PlaySocialAnim(AnimName, 1, 0.3);
		SephirothPlayer(PlayerOwner).Net.NotiTell(1, Message);
		bHold = False;
	}
}

function bool StringHasToken(string Str, array<string> Token)
{
	local int i;
	for ( i = 0;i < Token.Length;i++ )
		if ( InStr(Str, Token[i]) != -1 )
			return True;
	return False;
}

function name GetAnimToken(string InStr)
{
    // ���� �׾� �ִ� ���¶�� ��Ȱ������ �ǹ̰� ����.
	if ( !SephirothPlayer(PlayerOwner).PSI.bIsAlive )
		return '';

	if ( StringHasToken(InStr, HiToken) ) return 'Hi';
	if ( StringHasToken(InStr, YesSirToken) ) return 'YesSir';
	if ( StringHasToken(InStr, CharmingHiToken) ) return 'CharmingHi';
	if ( StringHasToken(InStr, SorryToken) ) return 'Sorry';
	if ( StringHasToken(InStr, SmileToken) ) return 'Smile';
	if ( StringHasToken(InStr, CryToken) ) return 'Cry';
	if ( StringHasToken(InStr, YooHooToken) ) return 'YooHoo';
	if ( StringHasToken(InStr, DullTimeToken) ) return 'DullTime';
	if ( StringHasToken(InStr, AngerToken) ) return 'Anger';
	if ( StringHasToken(InStr, KissToken) ) return 'Kiss';
	if ( StringHasToken(InStr, LoveYouToken) ) return 'LoveYou';
	if ( StringHasToken(InStr, RushToken) ) return 'Rush';
	if ( StringHasToken(InStr, SephirothToken) ) return 'Sephiroth';

	return '';
}

function ProcessSlashCommand(string MessageText)
{
	local string Command;
	local array<string> Argv;
	local string Argument;
	local int i, nHour;

	class'CNativeInterface'.Static.WrapStringToArray(MessageText, Argv, 10000, " ");
	if ( Argv.Length == 0 )
		return;

	Command = Argv[0];


    // Mr.Do �Ű� ��� �߰� --- Start ----
    //del neive : /�Ű� ��� ���� ---------------------------------------------
    // Report
	if ( Command == Localize("Commands", "ReportComplain", "Sephiroth") || Command == "report" || Command == "REPORT" || Command == "Report" ) 
	{
		nHour = SephirothPlayer(PlayerOwner).PSI.nCurHour;


		if ( nHour < 15 || nHour > 20 )
		{
			PlayerOwner.myHud.AddMessage(2,Localize("Warnings","UserReport","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
			return;
		}

		if ( Argv.Length >= 1 ) 
		{
			Argument = Argv[1];
			for ( i = 2;i < Argv.Length;i++ )
				Argument = Argument@Argv[i];
		}
		SephirothInterface(Parent).OpenUserReport(Argument);
		return;
	}
    // Mr.Do �Ű� ��� �߰� --- End ----
    //-------------------------------------------------------------------------

    // ��ƼŻ��
	if ( Command == Localize("Commands", "PartyLeave", "Sephiroth") ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiPartyLeave();
		return;
	}

    // ��Ƽ�ʴ�
	if ( Command == Localize("Commands", "PartyInvite", "Sephiroth") && Argv.Length >= 2 ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiPartyInvite(0);
		return;
	}

    // ��Ƽ��û
	if ( Command == Localize("Commands", "PartyJoin", "Sephiroth") && Argv.Length >= 2 ) 
	{
		SephirothPlayer(PlayerOwner).Net.NotiPartyJoin(0);
		return;
	}

    // ��Ƽ�߹�
	if ( Command == Localize("Commands", "PartyBan", "Sephiroth") && Argv.Length >= 2 ) 
	{
		if ( SephirothPlayer(PlayerOwner).PartyMgr.bLeader )
			SephirothPlayer(PlayerOwner).Net.NotiPartyBan(Argv[1]);
		return;
	}

    // ��ȭ����
	if ( Command == Localize("Commands", "LockUserMessage", "Sephiroth") && Argv.Length >= 2 ) 
	{
        //SephirothPlayer(PlayerOwner).BlockMessage(SephirothPlayer(PlayerOwner).ConvertToName(Argv[1]));
		SephirothPlayer(PlayerOwner).BlockMessage(StrToName(Argv[1]));
		return;
	}

    // ��������
	if ( Command == Localize("Commands", "UnlockUserMessage", "Sephiroth") && Argv.Length >= 2 ) 
	{
        //SephirothPlayer(PlayerOwner).UnblockMessage(SephirothPlayer(PlayerOwner).ConvertToName(Argv[1]));
		SephirothPlayer(PlayerOwner).UnblockMessage(StrToName(Argv[1]));
		return;
	}

	//PlayerOwner.myHud.AddMessage(2,"CSDEDUG",class'Canvas'.static.MakeColor(255,255,0));
	//PlayerOwner.myHud.AddMessage(2,Command,class'Canvas'.static.MakeColor(255,255,0));
	//PlayerOwner.myHud.AddMessage(2,right(MessageText,len(MessageText)-8),class'Canvas'.static.MakeColor(255,255,0));
	//@cs debug added for debug cmd , Must close when release
	if ( Command == "CSDEBUG" && Argv.Length >= 2 ) 
	{
        
		PlayerOwner.myHud.AddMessage(2,right(MessageText,len(MessageText) - 8),class'Canvas'.Static.MakeColor(255,255,0));
		PlayerOwner.ConsoleCommand( right(MessageText,len(MessageText) - 8));

		return;
	}

    // ����Ŀ�ǵ�
	SephirothPlayer(PlayerOwner).Net.NotiCommand(MessageText);
}

function ResetDefaultPosition()     //modified by yj
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
	pos = InStr(Resolution, "x");

	ClipX = int(Left(Resolution, pos));
	ClipY = int(Mid(Resolution,pos + 1));

	PageX = 30;
	PageY = ClipY - WinHeight;

	Sys_PageX = 30;
	if( ClipX == 800 )
		Sys_PageY = 100;
	else
		Sys_PageY = 300;

	bNeedLayoutUpdate = True;

	SaveConfig();
}

function UpdateTextPoolPosition(float inX, float inY, optional float inXL, optional float inYL)
{
//  UpdateTextPoolRegion(PageX,PageY)
    //default value
	if( inXL == 0 )
		inXL = TextOutRgn.W - TextOutRgnWidthOffset;
	if( inYL == 0 )
		inYL = 400;
	if ( TextPool != None ) 
	{
       //TextPool.SetPos(inX, inY);
		TextPool.SetSize(inXL, inYL);
	}
}

defaultproperties
{
	bListen_All=True
	bListen_Party=True
	bListen_Channel1=True
	bListen_Channel2=True
	bListen_System=True
	MinLines=6
	MaxLines=40
	TextSize=14
	PageX=-1.000000
	PageY=-1.000000
	TextOutRgn=(W=520.000000,H=100.000000)
	var_ListenMode=1
	ChannelPrefix(0)="~"
	ChannelPrefix(1)="!"
	ChannelPrefix(2)="@"
	ChannelPrefix(3)="#"
	ChannelPrefix(4)="$"
	ChannelPrefix(5)="%"
	ChannelPrefix(6)="&"
	ChannelPrefix(7)="*"
	ChannelPrefix(8)="/"
	bShowSystemMessage=True
	Components(0)=(Caption="ImeOff",Type=RES_TextButton,XL=16.000000,YL=16.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Information,ToolTip="ToggleIme")
	Components(1)=(Id=1,Caption="Tell",Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=16.000000,PivotDir=PVT_Right,OffsetXL=1.000000,TextAlign=TA_MiddleCenter,ToolTip="ChatMode")
	Components(2)=(Id=2,Type=RES_ToggleButton,XL=15.000000,YL=15.000000,PivotDir=PVT_Up,OffsetYL=1.000000,ToolTip="ChatHold")
	Components(3)=(Id=3,Type=RES_Image,XL=15.000000,YL=100.000000,PivotId=2,PivotDir=PVT_Up,ToolTip="ScrollGutter")
	Components(4)=(Id=4,XL=16.000000,YL=16.000000,PivotId=3,PivotDir=PVT_Copy,OffsetYL=16.000000,ToolTip="ChatSize")
	Components(9)=(Id=9,Type=RES_PushButton,XL=16.000000,YL=16.000000,PivotId=6,PivotDir=PVT_Copy,OffsetYL=32.000000,ToolTip="ScrollUp")
	Components(10)=(Id=10,Type=RES_PushButton,XL=16.000000,YL=16.000000,PivotDir=PVT_Up,OffsetYL=15.000000,ToolTip="ScrollDown")
	Components(5)=(Id=5,Type=RES_Image,bPassKeytoOnKeyEvent=True,XL=16.000000,YL=16.000000,PivotId=4,PivotDir=PVT_Copy,OffsetYL=-16.000000,ToolTip="MoveChattingWindow")
	Components(6)=(Id=6,Type=RES_PushButton,bVisible=False,XL=16.000000,YL=16.000000,PivotId=5,PivotDir=PVT_Right,ToolTip="")
	Components(7)=(Id=7,Type=RES_Image,bPassKeytoOnKeyEvent=True,bVisible=False,XL=16.000000,YL=16.000000,ToolTip="MoveSystemChattingWindow")
	Components(8)=(Id=8,Type=RES_ToggleButton,XL=15.000000,YL=15.000000,bVisible=False,ToolTip="HideSystemMessage")
	TextureResources(0)=(Package="UI_2011_btn",Path="btn_chat_bg_n",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2011_btn",Path="btn_chat_bg_n",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2011",Path="ChatBg_S00",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2011",Path="ChatBg_S01",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2011_btn",Path="BTN06_08_O",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2011_btn",Path="BTN06_08_P",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2011_btn",Path="btn_chat_mv_n",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2011_btn",Path="btn_chat_mv_o",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2011_btn",Path="btn_chat_mv_c",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2011_btn",Path="btn_chat_op_n",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2011_btn",Path="btn_chat_op_o",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2011_btn",Path="btn_chat_op_c",Style=STY_Alpha)
	WinWidth=512.000000
	WinHeight=120.000000
}
