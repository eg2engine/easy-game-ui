//-----------------------------------------------------------
// 战斗界面管理类
// 用于管理团队战斗（Team Battle）相关的所有界面元素
// 继承自 SephirothInterface 并与 SephirothInterface 配合使用
// 所有团队战斗相关的界面元素都在这里进行管理
//
// ** 工作流程说明 **
// 根据 AppProtocol 中定义的消息协议，当客户端收到 Team Battle 相关的消息时，
// 会调用 EnterMatch 相关的消息处理函数。当玩家移动到战斗房间时，服务器会发送
// 战斗邀请，客户端收到后，EnterMatch 相关的消息处理函数会将 BattleInterface 
// 添加到 SephirothInterface 中。
// EndMatch 时会移除 BattleInterface。
// 2010.1.20. Sinhyub
//-----------------------------------------------------------
class CBattleInterface extends CMultiInterface;

// 消息框ID常量
const IDM_TryTeamBattle = 1;   // 团队战斗邀请消息框ID

//-----------------------------------------------
// 战斗界面相关的界面元素变量
//-----------------------------------------------
var TeamBattleMessage TeamBattleMessageBox; // 团队战斗邀请时显示的确认消息框
var CEndingEffect BattleEndingEffecter;     // 战斗结束时的特效显示器 (Gameover/Win/Draw... 等结果)
var CTimeDisplayer BattleWaitTimer;         // 战斗等待时间的倒计时显示
var CQuitMessage BattleQuitMessage;         // 战斗退出时的退出确认按钮
var CScoreDisplayer BattleScore;            // 战斗比分显示
var CMessageDisplayer BattleMessage;        // 团队战斗进行状态显示的消息框(击杀信息等消息)

//-----------------------------------------------

// 缓存的比赛名称
// 用于在 EnterMatch 消息到达之前保存比赛名称，通过 SetMatchName 函数进行设置
var string cachedMatchName;

//------------------------------------------------
// 战斗界面相关的界面元素管理函数
// 根据 AppProtocol.h 中定义的消息协议，当收到相应的消息时，会调用对应的处理函数，
// 这些处理函数会调用下面的函数来管理界面元素。
// 每个消息对应的函数都有详细说明。

//---------
// 1. TeamBattleMessageBox (团队战斗邀请时，显示确认对话框的消息框)
//    - 消息框显示、消息框更新(剩余时间倒计时显示)、消息框隐藏

/**
 * 显示团队战斗邀请消息框
 * @param MatchName 比赛名称
 * @param remain_sec 剩余时间（秒）
 */
function ShowTeamBattleMessage(string MatchName,int remain_sec)
{
	// 如果已存在消息框，先清理
	if( TeamBattleMessageBox != None )
	{
		TeamBattleMessageBox = None;
	}
	
	// 创建团队战斗邀请消息框
	// 注意：为了确保消息框能够正确接收键盘事件，需要将父界面的 KeyEvent Block 选项设置为启用
	TeamBattleMessageBox = TeamBattleMessage(class'TeamBattleMessage'.Static.MessageBox(Self,"TryTeamBattle","["$Localize("Match",MatchName,"Sephiroth")$"]"$Localize("Match","TryTeamBattle","Sephiroth"),MB_YesNo,IDM_TryTeamBattle,True,MBPos_TopRight,True));
	
	// 禁用自动删除，因为需要手动管理UI元素的生命周期，显示后需要手动调用Hide来隐藏
	TeamBattleMessageBox.bAutoDelete = False;

	// 设置比赛名称和剩余时间
	TeamBattleMessageBox.MatchName = MatchName;
	TeamBattleMessageBox.UpdateRemain_sec(remain_sec);
}

/**
 * 更新团队战斗邀请消息框
 * @param MatchName 比赛名称
 * @param remain_sec 剩余时间（秒）
 */
function UpdateTeamBattleMessage(String MatchName, int remain_sec)
{
	// 更新缓存的比赛名称，以便后续使用。如果消息框不存在则重新创建，否则只更新剩余时间
	SetMatchName(MatchName);
	
	if( TeamBattleMessageBox == None )
		ShowTeamBattleMessage(MatchName, remain_sec);
	else
		TeamBattleMessageBox.UpdateRemain_sec(remain_sec);
}

/**
 * 隐藏团队战斗邀请消息框
 * 当时间到期或用户取消时调用
 */
function HideTeamBattleMessage()
{
	if( TeamBattleMessageBox != None ) 
	{
		// 恢复父界面的键盘事件接收
		TeamBattleMessageBox.NotifyTarget.bIgnoreKeyEvents = False;
		// 隐藏并移除消息框
		TeamBattleMessageBox.HideInterface();
		RemoveInterface(TeamBattleMessageBox);
		TeamBattleMessageBox = None;
	}
}

//---------
// 2. TeamBattleWaitTimer (等待时间、准备时间等倒计时显示的计时器)

/**
 * 显示战斗等待计时器
 * @param MatchName 比赛名称
 * @param timer_sec 计时器初始时间（秒）
 */
function ShowBattleWaitTimer(string MatchName, int timer_sec)
{
	local string t_MatchName;
	
	// 如果已存在计时器，先隐藏
	if( BattleWaitTimer != None )
	{
		BattleWaitTimer.HideInterface();
	}
	
	// 创建并添加计时器界面
	BattleWaitTimer = CTimeDisplayer(AddInterface("SephirothUI.CTimeDisplayer"));
	
	// 根据比赛名称获取本地化的计时器显示文本
	t_MatchName = Localize("Match",(MatchName$"_Timer"),"Sephiroth");
	BattleWaitTimer.SetBattleName(t_MatchName);
	
	// 启动计时器并显示
	BattleWaitTimer.TimerStart(timer_sec);
	BattleWaitTimer.ShowInterface();
}

/**
 * 隐藏战斗等待计时器
 */
function HideBattleWaitTimer()
{
	if( BattleWaitTimer != None )
	{
		BattleWaitTimer.HideInterface();
		RemoveInterface(BattleWaitTimer);
		BattleWaitTimer = None;
	}
}

//--------
// 3. BattleEndingEffecter - 战斗结束特效 (GameOver/Win/Lose... 等结果的显示)

/**
 * 显示战斗结束特效
 * @param MatchName 比赛名称（未使用）
 * @param result 战斗结果 (win/draw/out/lose 等对应的特效)
 * 注意：特效会根据设置的持续时间自动结束
 */
function ShowBattleEndingEffecter(string MatchName, int result)
{
	// 如果已存在特效，先隐藏
	if( BattleEndingEffecter != None )
	{
		BattleEndingEffecter.HideInterface();
	}
	
	// 创建并添加结束特效界面
	BattleEndingEffecter = CEndingEffect(AddInterface("SephirothUI.CEndingEffect"));
	
	// 设置特效类型（result: win/draw/out/lose 等对应的特效）
	BattleEndingEffecter.EffectSet(result);
	
	// 启动特效，持续15秒
	BattleEndingEffecter.EffectStart(15000);
	BattleEndingEffecter.ShowInterface();
}

//--------
// 4. BattleQuitMessage - 战斗退出时的退出确认按钮

/**
 * 显示战斗退出确认消息
 * @param MatchName 比赛名称
 * @param MatchWaitQuitTime 退出等待时间
 */
function ShowBattleQuitMessage(string MatchName, int MatchWaitQuitTime)
{
	// 如果退出消息框不存在，则创建
	if( BattleQuitMessage == None )
		BattleQuitMessage = CQuitMessage(AddInterface("SephirothUI.CQuitMessage"));
	
	// 设置退出按钮文本（根据比赛名称获取本地化文本）
	BattleQuitMessage.SetQuitButtonText( Localize("Match",MatchName$"_QuitMessage","Sephiroth") );
	
	// 显示退出消息框
	BattleQuitMessage.ShowInterface();
	
	// 设置退出计时器
	BattleQuitMessage.SetQuitTimer(MatchWaitQuitTime);
}

/**
 * 隐藏战斗退出确认消息
 */
function HideBattleQuitMessage()
{
	if( BattleQuitMessage != None )
	{
		BattleQuitMessage.HideInterface();
		RemoveInterface(BattleQuitMessage);
		BattleQuitMessage = None;
	}
}

//--------
// 5. BattleScore - 团队战斗比分显示

/**
 * 显示战斗比分
 */
function ShowBattleScore()
{
	// 如果比分显示器不存在，则创建
	if( BattleScore == None )
		BattleScore = CScoreDisplayer(AddInterface("SephirothUI.CScoreDisplayer"));
	
	// 显示比分界面
	BattleScore.ShowInterface();
}

/**
 * 更新战斗比分
 * @param ScoreA 队伍A的分数
 * @param ScoreB 队伍B的分数
 */
function UpdateBattleScore(int ScoreA, int ScoreB)
{
	if( BattleScore != None )
		BattleScore.SetScore(ScoreA, ScoreB);
}

/**
 * 隐藏战斗比分
 */
function HideBattleScore()
{
	if( BattleScore != None )
	{
		BattleScore.HideInterface();
		RemoveInterface(BattleScore);
		BattleScore = None;
	}
}

//--------
// 6. BattleMessage - 战斗进行状态的消息框 (击杀信息等消息)

/**
 * 显示战斗消息框
 */
function ShowBattleMessage()
{
	// 如果消息显示器不存在，则创建
	if( BattleMessage == None )
		BattleMessage = CMessageDisplayer(AddInterface("SephirothUI.CMessageDisplayer"));
	
	// 显示消息界面
	BattleMessage.ShowInterface();
	
	// 设置队伍名称（示例）
	BattleMessage.SetTeamName("WhiteEagle","BlackCat");
}

/**
 * 更新战斗消息（添加新的击杀消息）
 * @param KillerName 击杀者名称
 * @param KillerTeam 击杀者队伍
 * @param DeaderName 被击杀者名称
 * @param DeaderTeam 被击杀者队伍
 */
function UpdateBattleMessage(string KillerName, string KillerTeam, string DeaderName, string DeaderTeam)
{
	if( BattleMessage != None )
		BattleMessage.PushMessageList(KillerName,KillerTeam,DeaderName,DeaderTeam);
}

/**
 * 隐藏战斗消息框
 */
function HideBattleMessage()
{
	if( BattleMessage != None )
	{
		BattleMessage.HideInterface();
		RemoveInterface(BattleMessage);
		BattleMessage = None;
	}
}

//--------
// 7. 界面元素统一隐藏函数

/**
 * 隐藏所有战斗界面元素
 * 注意：这里会停止BGM等音效
 */
function HideBattleInterfaces()
{
	HideBattleQuitMessage();
	HideBattleWaitTimer();
	HideBattleScore();
	HideBattleMessage();
	
	// 如果结束特效存在，结束特效（这里会停止BGM等音效）
	if( BattleEndingEffecter != None )
		BattleEndingEffecter.EffectEnd();
}

// End. 战斗界面相关的界面元素管理函数
//----------------------------------------------------------------------

/* 注释掉的 HideInterface 函数
function HideInterface()
{
    HideBattleInterfaces(); // 如果需要的话可以在这里调用...
    super.HideInterface();
}
*/

//------------------------------------------------
// 比赛名称缓存管理函数
// 由 cNotifyEnterMatch 等函数调用

/**
 * 设置比赛名称（缓存）
 * @param MatchName 比赛名称
 */
function SetMatchName(string MatchName)
{
	cachedMatchName = MatchName;
}

//------------------------------------------------
// 界面消息通知处理函数

/**
 * 处理界面消息通知
 * @param Interface 发送通知的界面
 * @param NotifyId 通知类型
 * @param Command 命令字符串（可选）
 */
function NotifyInterface(CInterface Interface, EInterfaceNotifyType NotifyId, optional coerce string Command)
{
	local int NotifyValue;

	// 处理消息框通知
	if ( NotifyId == INT_MessageBox ) 
	{
		NotifyValue = int(Command);
		switch (NotifyValue) 
		{
			// 团队战斗邀请 - 用户点击确认按钮时
			case IDM_TryTeamBattle:
				// 隐藏消息框
				if( TeamBattleMessageBox != None )
					HideTeamBattleMessage();
			
				// 发送进入比赛确认消息
				// 如果缓存的比赛名称为空，使用玩家当前的比赛名称（这是错误的情况，需要修复）
				if( cachedMatchName == "" )
					SephirothPlayer(PlayerOwner).Net.NotiAnswerEnterMatch(SephirothPlayer(PlayerOwner).PSI.MatchName,1);
				else	// 这是正确的情况
					SephirothPlayer(PlayerOwner).Net.NotiAnswerEnterMatch(cachedMatchName,1);
				break;
			
			// 团队战斗邀请 - 用户点击取消按钮时（由yj修改）
			case -1 * IDM_TryTeamBattle:
				if( TeamBattleMessageBox != None )				
				{
					HideTeamBattleMessage();
					// 发送拒绝进入比赛的消息
					SephirothPlayer(PlayerOwner).Net.NotiAnswerEnterMatch(cachedMatchName,0);
				}
				break;
		}
	}
}

//------------------------------------------------
// 界面位置重置函数

/**
 * 重置界面默认位置
 * 调用各个界面的 ResetDefaultPosition 函数
 * 团队战斗邀请消息框等界面元素需要根据屏幕分辨率重新调整位置
 * 注意：由于团队战斗界面元素在每帧(Tick)中会根据 Canvas ClipX,Y 的变化来调整位置，所以这个函数可能不需要
 */
function ResetDefaultPosition()
{
	if( TeamBattleMessageBox != None )
		TeamBattleMessageBox.ResetDefaultPosition();
}

defaultproperties
{
	IsBottom=True
}
