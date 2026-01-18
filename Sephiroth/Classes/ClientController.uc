/**
 * 客户端控制器类
 * 继承自PlayerController，负责处理客户端玩家的输入、移动、战斗、UI交互等核心功能
 */
class ClientController extends PlayerController native dependsOn(QuestStepInfo) config(User);

// 消息屏蔽标志常量
const BLOCK_Tell	= 1;		// 屏蔽密语
const BLOCK_Shout	= 2;		// 屏蔽喊话
const BLOCK_Yell	= 4;		// 屏蔽大叫
const BLOCK_Whisper	= 8;		// 屏蔽私语
const BLOCK_BGM		= 32;		// 屏蔽背景音乐
const BLOCK_Message	= 16;		// 屏蔽消息
const BLOCK_Sound	= 64;		// 屏蔽音效

// PVP相关统计常量
const PCPVPPkPts = 58;			// PVP PK点数
const PCMaxPvpInfo = 62;		// 最大PVP信息
const PCPVPKills = 59;			// PVP击杀数
const PCPVPDeads = 60;			// PVP死亡数
const PCPVPMatch = 66;			// PVP比赛数
const PCPVPWin = 67;			// PVP胜利数
const PCPVPLose = 68;			// PVP失败数
const PCPVPDraw = 69;			// PVP平局数

const IDM_SEALEDITEM = 12;		// 封印物品对话框ID		

// 服务器信息相关
var PlayerServerInfo PSI;		// 玩家服务器信息
var ZoneServerInfo ZSI;			// 区域服务器信息
var SepNetInterface Net;		// 网络接口
var Actor InteractTo;			// 当前交互目标

// 管理器相关
var BuddyManager BuddyMgr;		// 好友管理器
var PartyManager PartyMgr;		// 队伍管理器
var ClanManager ClanManager;	// 公会管理器
var SkillFrame SkillFrame;		// 技能帧管理器

var DamageInteractor DamageInteractor;	// 伤害交互器

// 移动相关
var bool bMouseMove, bKeyboardMove;	// 鼠标移动/键盘移动标志
var actor AimActor;					// 瞄准目标
var bool bForceToWalk;				// 强制行走标志
var bool bTracePlayer;				// 是否追踪玩家
var Hero TracePlayer;				// 追踪的玩家对象

// 战斗相关
var Pawn LastHitEnemy;			// 最后攻击的敌人
var float LastHitTime;			// 最后攻击时间

// 宠物相关
var PetServerInfo PetSI;		// 宠物服务器信息
var PetController PetController;// 宠物控制器
var Guardian SPet;				// 守护者宠物
var Pet Pet;					// 宠物对象
var LenzFlareEmitter	Flare;	// 镜头光晕发射器

// 摄像机相关配置
var(Camera) globalconfig int MaxCameraDist;	// 最大摄像机距离
var(Camera) globalconfig int MinCameraDist;	// 最小摄像机距离
var(Camera) int CameraHeight;					// 摄像机高度
var(Camera) int CameraBias;					// 摄像机偏移
var(Camera) enum EViewType 
	{ 
		FirstPerson,		// 第一人称视角
		BehindFree,			// 背后自由视角
		QuaterView			// 四分之三视角
	} 
	ViewType;				// 视角类型
var(Camera) bool bCameraSet;		// 摄像机是否已设置
var(Camera) bool bCameraReversed;	// 摄像机是否反转

var globalconfig bool bTraceCamera;	// 是否追踪摄像机

var(Setting) int BlockFlag;		// 屏蔽标志

// 战斗相关
var(Battle) Character LockedTarget;		// 锁定的目标
var(Battle) bool bIsActing, bIsActingFinish;	// 是否正在行动/行动是否完成
var(Battle) int ComboCount;				// 连击计数
var(Battle) Skill ThisSkill,NextSkill;	// 当前技能/下一个技能
var(Battle) struct native HitDetectInfo 
		{
		var() bool bCheckHit;			// 是否检查命中
		var() name CheckBone;			// 检查的骨骼名称
		var() Attachment CheckAttachment;// 检查的附件
		var() Skill CheckSkill;			// 检查的技能
	} 
	HDI;					// 命中检测信息
var(Battle) Actor LastFiredEffect;		// 最后发射的特效

var(Battle) float CoolTime;				// 冷却时间
var(Battle) bool bJustFired;			// 是否刚发射

var(UI) bool bShowItemName;				// 是否显示物品名称

// 追踪结果结构
var(Trace) struct native TraceResult 
		{
		var() actor Actor;			// 追踪到的Actor
		var() vector Location;		// 位置
		var() vector Normal;		// 法线
		var() rotator Direction;	// 方向
		var() bool bIsValid;		// 是否有效
	} 
	Hit, ActionTarget;				// 命中结果/动作目标

// 屏蔽列表
var array<name> ExchangeBlockedPlayer;	// 屏蔽交易的玩家列表
var array<name> MessageBlockedPlayer;	// 屏蔽消息的玩家列表

/**
 * 动作条目结构
 * 用于动作池中存储待执行的动作信息
 */
struct native ActionEntry 
	{
	var string SkillName;		// 技能名称
	var byte Type;				// 类型
	var Character Target;		// 目标角色
	var vector TargetLocation;	// 目标位置
	var float Speed;			// 速度
	var int ComboCount;			// 连击计数
};
var array<ActionEntry> ActionPool;	// 动作池


/**
 * 任务结构
 * 存储任务相关信息
 */
struct Quest
{
	var string Name;				// 任务名称
	var string Description;			// 任务描述
	var string CurrentStep;			// 当前步骤
	var string NextStep;			// 下一步骤

	var string	strStepName;		// 步骤名称
	var int		nStepValue;			// 步骤值
	var string	strNpcName;			// NPC名称
	var int		nSymbol;				// 符号标识
	var string	strLocaleName;		// 本地化名称

	var string	strHudTitle;		// HUD标题
	var string	strHudDesc;			// HUD描述

	var array<int> aProgressCount;	// 进度计数数组
	var int		nLastUpdateTime;	// 最后更新时间

	var bool bShowMain;				// 是否显示在主界面
};

var array<Quest> LiveQuests;		// 进行中的任务列表
var array<Quest> DoneQuests;		// 已完成的任务列表

/**
 * 传送门结构
 * 存储传送门相关信息
 */
struct Portal 
{
	var int Index;			// 索引
	var string PosTag;		// 位置标签
	var string DescTag;		// 描述标签
};
var array<Portal> Portals;		// 传送门列表
var byte PortalCompare;			// 传送门比较方式
	

/**
 * 消息便签结构
 * 存储消息相关信息
 */
struct MessageNote 
{
	var bool bRead;			// 是否已读
	var bool bKeep;			// 是否保留
	var int NoteID;			// 便签ID
	var string From;		// 发送者
	var string Body;		// 内容
	var int Time;			// 时间
};
var array<MessageNote> InBoxNotes;	// 收件箱便签列表
var array<MessageNote> NewNotes;		// 新便签列表

var ExchangeItems InboxItems, OutboxItems;	// 交易物品：收件箱/发件箱

// 摊位相关
var BoothItems Showcase;		// 展示物品
var name ToutName;				// 叫卖名称
var int BoothToutCount;			// 摊位叫卖计数

// 战斗相关
var bool bOnMacroKiller;			// 是否开启宏检测
var int nComboStartCount;			// 连击开始计数
var float fBlockedTime;				// 阻塞时间
var float fLastAttackTime;			// 最后攻击时间


/**
 * 字符串键值对结构
 */
struct StringPair 
{
	var string Key;		// 键
	var string Value;	// 值
};

/**
 * 对话框结构
 * 存储NPC对话信息
 */
struct Dialog 
{
	var string NpcName;					// NPC名称
	var string NpcModel;				// NPC模型
	var string Text;					// 文本内容
	var array<StringPair> Environs;		// 环境变量数组
	var array<StringPair> Links;		// 链接数组
};

/**
 * 商店结构
 * 存储商店相关信息
 */
struct Shop 
{
	var string NpcName;					// NPC名称
	var array<string> Categories;		// 分类数组
};
var ShopItems ShopItems;				// 商店物品

// 第二技能相关
var Skill SecondSkill;					// 第二技能
var Actor SecondSkillTarget;			// 第二技能目标
var Character SavedTarget;				// 保存的目标
var Name SavedState;					// 保存的状态
var vector HitActorLocation;			// 命中Actor位置

/**
 * 城堡信息结构
 * 存储城堡相关信息
 */
struct native CastleInfo
	{
	var string CastleName;		// 城堡名称
	var string ClanName;		// 公会名称
	var string ClanMasterName;	// 公会会长名称
	var string CastleMoney;		// 城堡资金
	var float NormalTaxRate;	// 普通税率
	var float BoothTaxRate;		// 摊位税率
};
var CastleInfo OwnedCastle;		// 拥有的城堡信息

var bool bBackward;				// 是否后退

/**
 * 震动因子结构
 * 用于摄像机震动效果
 */
struct ShakingFactor
{
	var int MaxCount;		// 最大计数
	var int CurCount;		// 当前计数
	var int TickCount;		// 滴答计数
	var vector Offset;		// 偏移量
	var vector OldOffset;	// 旧偏移量
};

var ShakingFactor ShakeFactor;	// 震动因子
var bool bCameraShaking;		// 摄像机是否震动



const USAVersion = 0;


var EnchantBox EnchantBox;





struct native SkillUseInfo
	{
	
	var string skillname;
	
	var int usecount;
};

var float stopwatch_starttime;


var array<SkillUseInfo> stopwatch_useinfo_array;




var array<float> ArStepTime;

var int AttackAniChannel;

var float AttackEndTime;

var bool bAttackStart;

var bool bAttackEnd;


var int nDamaged; 

var int nNoteUnread;				
var int nHelperUnread;				

var string	strMentorName;
var int	nMentorLevel;
var name	MentorJob;


var string tmp, Atext;
var name NullName;

/**
 * 学徒信息结构
 * 存储学徒相关信息
 */
struct MenteeInfo
{
	var int		nSlotIndex;		// 槽位索引
	var string	strMenteeName;	// 学徒名称
	var int		nLevel;			// 等级
	var name	JobName;			// 职业名称
	var bool	IsEnabled;		// 是否启用
	var int		nReputePoint;	// 声望点数
};

var array<MenteeInfo>	aMentees;	// 学徒信息数组

// 位置同步加速追赶相关（仅用于其他玩家角色）
var float SyncSpeedMultiplier;		// 同步速度倍数（用于加速追赶服务器位置）
var bool bSyncingPosition;			// 是否正在同步位置
var float SyncCloseDistance;		// 同步接近距离（小于此距离恢复正常速度，默认30单位）
var float OriginalGroundSpeed;		// 保存的原始地面速度

// 卡地形检测相关（仅用于其他玩家角色）
var vector LastSyncLocation;			// 上次同步的位置（用于检测是否卡住）
var float StuckCheckTime;			// 卡住检测时间
var float StuckThreshold;			// 卡住阈值（位置变化小于此值认为卡住，默认5单位）
var float StuckTimeLimit;			// 卡住时间限制（超过此时间强制同步，默认0.5秒）

/**
 * 调试日志输出
 * @param message 要输出的消息
 */
function DebugLog(string message)
{
	Level.GetLocalPlayerController().myHud.AddMessage(1,"DebugLog ClientController: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

/**
 * 将字符串转换为Name类型
 * @param AString 要转换的字符串
 * @return 转换后的Name值
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
 * 秒表功能 - 开始/停止计时并统计技能使用次数
 */
exec function SepStopWatch()
{
	local float elapsed;
	local int i;

	if( stopwatch_starttime == 0 )
	{
		

		stopwatch_starttime = TimeStamp();

		stopwatch_useinfo_array.Remove(0, stopwatch_useinfo_array.Length);

		myHud.AddMessage(254,"start : "@stopwatch_starttime,class'Canvas'.Static.MakeColor(255,255,255));
	}
	else 
	{
		

		elapsed = TimeStamp() - stopwatch_starttime;

		myHud.AddMessage(2,"stop : "@elapsed,class'Canvas'.Static.MakeColor(255,255,255));

		for( i = 0; i < stopwatch_useinfo_array.Length;++i )
		{
			myHud.AddMessage(254,"skill : "@stopwatch_useinfo_array[i].skillname@" count="@stopwatch_useinfo_array[i].usecount,
				class'Canvas'.Static.MakeColor(255,255,255));
		}


		stopwatch_starttime = 0;
	}
}

/**
 * 增加技能使用计数（用于秒表统计）
 * @param skillname 技能名称
 */
function Stopwatch_IncSkillUseCount(string skillname)
{
	local int i;
	local int array_length;

	if( stopwatch_starttime == 0 )
		return;
	
	array_length = stopwatch_useinfo_array.Length;
	for( i = 0; i < array_length;++i )
	{
		if( stopwatch_useinfo_array[i].skillname == skillname )
		{
			break;
		}
	}
	if( i == array_length )
	{
		stopwatch_useinfo_array.Insert(array_length, 1);
		i = array_length;
	}

	stopwatch_useinfo_array[i].skillname = skillname;
	stopwatch_useinfo_array[i].usecount++;
}



// 原生函数：获取物品出售价格字符串
native function string GetItemSellPriceString(string ItemSellPrice);
// 原生函数：获取物品修理价格字符串
native function string GetItemRepairPriceString(string ItemRepairPrice);

/**
 * 打开对话框菜单
 * @param NpcSI NPC服务器信息
 * @param Dialog 对话框数据
 */
event OpenDialogMenu(NpcServerInfo NpcSI, Dialog Dialog);

/**
 * 打开商店菜单
 * @param NpcSI NPC服务器信息
 * @param Shop 商店数据
 */
event OpenShopMenu(NpcServerInfo NpcSI, Shop Shop);
// 原生函数：关闭商店菜单
native final function CloseShopMenu();
/**
 * 更新商店物品
 * @param Items 商店物品数据
 */
event UpdateShopItems(ShopItems Items);

/**
 * 打开银行菜单
 * @param NpcSI NPC服务器信息
 * @param Bank 银行数据
 */
event OpenBankMenu(NpcServerInfo NpcSI, Bank Bank);
/**
 * 打开仓库
 * @param StashItems 仓库物品数据
 */
event OpenDepository(StashItems StashItems);
/**
 * 更新仓库信息
 * @param StashId 仓库ID
 */
event UpdateStashInfo(int StashId);
// 原生函数：关闭银行菜单
native final function CloseBankMenu(Bank Bank);

event OnSmithDlg();				// 打开铁匠对话框
event OnNPCSearch(string sName);	// NPC搜索
event OpenCompoundMenu(array<int> Dealings);	// 打开合成菜单

function OnInGameShopBuy();		// 游戏内商店购买

// 原生函数
native final function actor FindActor(name name);		// 查找Actor
native final function bool IsFullscreen();				// 是否全屏
native final function float TimeStamp();				// 获取时间戳
native final function SelectActor(actor Actor);			// 选择Actor
native final function SortPortals(byte Compare);		// 排序传送门

// 移动相关函数
function MovePawnToMove(Actor Target,vector Loc);		// 移动到指定位置
function MovePawnToTalk(Actor Target);					// 移动到对话目标
function MovePawnToAttackMelee(Actor Target);			// 移动到近战攻击目标
function MovePawnToPick(Actor Target);					// 移动到拾取目标
function MovePawnToTrace(Actor Target);					// 移动到追踪目标
function bool MovePawnToAttackRange(Actor Target, vector Loc);	// 移动到远程攻击位置
function MovePawnToAttackBow(Actor Target, vector Loc);	// 移动到弓箭攻击位置

// 原生函数：检查丢失的子对象
native function bool LostChild_Check(Actor Child);

// 64位整数运算原生函数
native function int		CmpInt64(string a, string b);	// 比较
native function string	AddInt64(string a, string b);	// 加法
native function string	SubInt64(string a, string b);	// 减法
native function string	MulInt64(string a, string b);	// 乘法
native function string	DivInt64(string a, string b);	// 除法
native function string	ModInt64(string a, string b);	// 取模

event UpdateBuddyInfo();		// 更新好友信息
event UpdateSkillCredit();		// 更新技能点数
function RClickActionEnd();		// 右键动作结束


/**
 * 摄像机震动事件
 * @param OffsetX X轴偏移
 * @param OffsetY Y轴偏移
 * @param OffsetZ Z轴偏移
 * @param MaxCount 最大震动次数
 */
event CameraShake(float OffsetX, float OffsetY, float OffsetZ, int MaxCount);


/**
 * 变形（变身）
 */
native final function Transformation();
/**
 * 解除变形
 */
native final function UnTransformation();

/**
 * 落地处理
 * @param HitNormal 碰撞法线
 */
function Landfloor(vector HitNormal)
{
	if( Pawn != None )
		Destination = Pawn.Location;
}


/**
 * 偏移摄像机高度
 * @param offset 偏移量
 */
function OffsetCamera(int offset)
{
	if ( ZSI != None ) 
	{
		CameraHeight = clamp(ShakeFactor.OldOffset.Z + offset, -300, 300);
	}
}

/**
 * 偏移摄像机（相对）
 * @param offset 偏移量
 */
function BiasCamera(int offset)
{
	if ( ZSI != None ) 
	{
		// 限制偏移范围在-300到300之间
		CameraBias = clamp(ShakeFactor.OldOffset.X + offset, -300, 300);
	}
}

/**
 * 偏移摄像机（绝对）
 * @param amount 偏移量
 */
function BiasCameraAbs(int amount)
{
	if( ZSI != None )
	{
		// 限制偏移范围在-300到300之间
		CameraBias = clamp(amount, -300, 300);
	}
}

/**
 * 缩放摄像机
 * @param zoom 缩放值
 */
function ZoomCamera(int zoom)
{
	local Rotator rot;

	if ( ViewType != FirstPerson ) 
	{
		// 限制摄像机距离在最小和最大距离之间
		CameraDist = clamp(ShakeFactor.OldOffset.Y + zoom, MinCameraDist, MaxCameraDist);
		if( ViewType == QuaterView ) 
		{
			// 四分之三视角需要调整俯仰角
			rot = Rotation;
			rot.Pitch = -8192.0 * (CameraDist - MinCameraDist) / (MaxCameraDist - MinCameraDist);
			SetRotation(rot);
		}
	}
}

/**
 * 震动视图
 * 处理摄像机震动效果
 * @param CameraLocation 摄像机位置（输出）
 */
event ShakingView(out vector CameraLocation)
{
	local float OffsetX, OffsetY, OffsetZ;

	if( bCameraShaking ) 
	{
		// 如果达到最大震动次数，停止震动
		if( ShakeFactor.TickCount == ShakeFactor.MaxCount )
		{
			ShakeFactor.CurCount = 0;
			bCameraShaking = False;
			OffsetX = 0;
			OffsetY = 0;
			OffsetZ = 0;
		}
		// 偶数次震动：反向偏移并衰减
		else if(ShakeFactor.TickCount % 2 == 0)	
		{
			OffsetX = -1 * ShakeFactor.Offset.X;
			OffsetY = -1 * ShakeFactor.Offset.Y;
			OffsetZ = -1 * ShakeFactor.Offset.Z;

			// 每次衰减一半
			ShakeFactor.Offset.X = ShakeFactor.Offset.X / 2;
			ShakeFactor.Offset.Y = ShakeFactor.Offset.Y / 2;
			ShakeFactor.Offset.Z = ShakeFactor.Offset.Z / 2;
		}
		// 奇数次震动：正向偏移
		else 
		{
			OffsetX = ShakeFactor.Offset.X;
			OffsetY = ShakeFactor.Offset.Y;
			OffsetZ = ShakeFactor.Offset.Z;
		}
		// 应用偏移
		BiasCamera(int(OffsetX));
		ZoomCamera(int(OffsetY));
		OffsetCamera(int(OffsetZ));
		ShakeFactor.TickCount++;
	}
}



/**
 * Tick事件
 * 每帧调用，用于更新状态
 * @param DeltaTime 时间增量
 */
event Tick(float DeltaTime)
{
	// 如果最后攻击的敌人存在且未删除，检查是否超过3秒
	if( LastHitEnemy != None && !LastHitEnemy.bDeleteMe )
	{
		if( LastHitTime != 0 && Level.TimeSeconds - LastHitTime >= 3 )
		{
			// 超过3秒后清除最后攻击的敌人信息
			LastHitEnemy = None;
			LastHitTime = 0;
		}
	}
}

/**
 * 检查界面是否打开
 * @param InterfaceName 界面名称
 * @return 界面是否打开
 */
function bool CheckInterface(string InterfaceName);

/**
 * 添加动作到动作池
 * @param SkillName 技能名称
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 * @param Speed 速度
 * @param CC 连击计数
 */
function AddActionPool(string SkillName, character Target, vector TargetLoc, float Speed, int CC)
{
	local ActionEntry A;
	A.SkillName = SkillName;
	A.Target = Target;
	A.TargetLocation = TargetLoc;
	A.Speed = Speed;
	A.ComboCount = CC;
	ActionPool[ActionPool.Length] = A;
}

/**
 * 更新动作池
 * 从动作池中取出第一个动作并执行
 */
function UpdateActionPool()
{
	local int i;
	local Skill Skill;
	local float AttackSpeed;

	if ( ActionPool.Length > 0 ) 
	{
		// 查询技能
		Skill = GameManager(Level.Game).QueryStaticSkillByName(ActionPool[0].SkillName);
		if ( Skill != None ) 
		{
			// 旋转到目标位置
			if ( ActionPool[0].Target != None && !ActionPool[0].Target.bDeleteMe )
				RotatePawnTo(ActionPool[0].Target.Location);
			else
				RotatePawnTo(ActionPool[0].TargetLocation);
			bRotateToDesired = False;
			// 只对本地玩家重置 Acceleration，其他玩家（第三视野）需要保持移动能力
			if ( Character(Pawn).IsAvatar() )
				Pawn.Acceleration = vect(0,0,0);
			AttackSpeed = ActionPool[0].Speed;
			// 根据技能类型执行不同的动作
			if ( Skill.IsCombo() ) 
			{
				ComboCount = ActionPool[0].ComboCount - 1;
				NetRecv_StartCombo(Skill,ComboCount,AttackSpeed);
			}
			else if (Skill.IsFinish()) 
			{
				ComboCount = -1;
				NetRecv_StartFinish(Skill,AttackSpeed);
			}
		}

		// 移除已执行的动作（队列前移）
		for ( i = 0;i < ActionPool.Length - 1;i++ )
			ActionPool[i] = ActionPool[i + 1];
		ActionPool.Remove(ActionPool.Length - 1,1);
	}
}

/**
 * 旋转Pawn到指定位置
 * @param Dest 目标位置
 */
function RotatePawnTo(vector Dest)	
{
	local Rotator Rot;
	if ( Pawn != None ) 
	{
		Rot = Pawn.Rotation;
		// 计算朝向目标位置的偏航角
		Rot.Yaw = Rotator(Dest - Pawn.Location).Yaw;
		Pawn.SetRotation(Rot);
	}
}

/**
 * 获取按键状态
 * @param Key 要检查的按键
 * @return 按键是否被按下
 */
function bool GetKeyState(Interaction.EInputKey Key)
{
	local int KeyState;
	local int KeyCheck;
	if ( Player != None ) 
	{
		KeyCheck = -1;
		switch (Key) 
		{
			case IK_Ctrl:
				KeyCheck = Player.MOUSE_Ctrl;
				break;
			case IK_Alt:
				KeyCheck = Player.MOUSE_Alt;
				break;
			case IK_Shift:
				KeyCheck = Player.MOUSE_Shift;
				break;
			case IK_LeftMouse:
				KeyCheck = Player.MOUSE_Left;
				break;
			case IK_RightMouse:
				KeyCheck = Player.MOUSE_Right;
				break;
			case IK_MiddleMouse:
				KeyCheck = Player.MOUSE_Middle;
				break;
		}
		if ( KeyCheck > -1 ) 
		{
			KeyState = Player.WindowsButtonFlags & KeyCheck;
			if ( KeyState == KeyCheck )
				return True;
		}
	}
}

/**
 * 检查目标是否已锁定
 * @return 目标是否有效且已锁定
 */
function bool TargetLocked()
{
	return (LockedTarget != None && !LockedTarget.bDeleteMe && !LockedTarget.bIsDead);
}

/**
 * 检查是否可以与目标对话
 * @param Target 目标对象
 * @return 是否可以对话
 */
function bool CanTalk(Actor Target)
{
	return (Target != None && !Target.bDeleteMe && (Target.IsA('Npc') || (Target.IsA('Hero') && Target != Pawn && !PSI.PkState)));
}

function bool CanStop(float Distance);

function HitDetectCore();
function AchieveGoal();

/**
 * 跳跃功能
 * @param F 可选的跳跃力度参数
 */
exec function Jump( optional float F )
{
	if ( Pawn.Physics != PHYS_Falling && Hero(Pawn).bServerAdmitJump && !PlayerReplicationInfo.bOnlySpectator )
	{
		Character(Pawn).bJustDamaged = False;  
		bPressedJump = True;
	}
}

/**
 * 玩家跳跃
 * 广播跳跃动作
 */
function PlayerJump()
{
	BroadcastJump();
}

/**
 * 键盘移动模式
 * 切换到键盘控制移动模式
 */
exec function KeyboardMove()
{
	if ( Pawn != None && PSI.bIsAlive ) 
	{
		bMouseMove = False;
		bKeyboardMove = True;
		bCameraReversed = False;
		// 如果刚受伤，清除受伤标志
		if ( Character(Pawn).bJustDamaged )
			Character(Pawn).bJustDamaged = False; 
		Destination = Pawn.Location;
		// 如果不是作弊飞行模式，切换到导航状态
		if ( !bCheatFlying )
			GotoState('Navigating');
	}
}

function Stopped();		// 停止移动

event NetRecv_SoloAct(name ActName,float ActParam);	// 网络接收单人动作

/**
 * 播放社交动画
 * @param AnimName 动画名称
 * @param Rate 播放速率
 * @param TweenTime 过渡时间
 */
function PlaySocialAnim(name AnimName, float Rate, float TweenTime)
{
	if( IsInState('Attacking') )
		return;

	if ( PSI != None && PSI.ArmState )
		ToggleArmState();

	if ( Pawn != None )
		Pawn.PlayAnim(AnimName, Rate, TweenTime);
	Net.NotiActSolo(string(AnimName));
}


/**
 * 播放玩家动画
 * @param AnimName 动画名称
 * @param Rate 播放速率
 * @param TweenTime 过渡时间
 */
function PlayerAnimation(name AnimName, float Rate, float TweenTime)
{
	if ( Pawn != None )
		Pawn.PlayAnim(AnimName, Rate, TweenTime);
	// 通知服务器播放单人动作
	Net.NotiActSolo(string(AnimName));
}

/**
 * 接近状态
 * 处理玩家接近目标时的行为
 */
state Approaching extends PlayerWalking
{
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel)
	{
		local name AnimName;
		local float AnimFrame, AnimRate;

		if (PSI != None && PSI.bIsAlive) 
		{
			// 如果不在攻击状态，播放行走动画
			if (!IsInState('MeleeAttacking') && !IsInState('BowAttacking'))  
				Character(Pawn).CHAR_PlayerWalkingAnim();
			// 如果目标锁定且距离不够，播放行走动画
			else if (TargetLocked() && !CanStop(VSize(LockedTarget.Location - Pawn.Location)))
				Character(Pawn).CHAR_PlayerWalkingAnim();
		}

		Pawn.GetAnimParams(Channel, AnimName, AnimFrame, AnimRate);
		// 如果是受伤动画且刚受伤，切换到等待状态
		// 注意：击退动画的处理已移至 Knockbacking 状态中
		if (AnimName == 'Pain' && Character(Pawn).bJustDamaged) 
		{
			Character(Pawn).bJustDamaged = False;
			Character(Pawn).CHAR_TweenToWaiting(0.1);
		}
	}
	/**
	 * 处理移动
	 * @param DeltaTime 时间增量
	 * @param NewAccel 新加速度
	 * @param DoubleClickMove 双击移动方向
	 * @param DeltaRot 旋转增量
	 */
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local bool bIsTurning, bTurningLeft;
		local vector OldAccel;
		local float AnimFrame, AnimRate;
		local name AnimSeq;

		// 如果Buff禁止行动，直接返回
		if(PSI != None && PSI.CheckBuffDontAct()) 
			return ;

		OldAccel = Pawn.Acceleration;
		// 判断是否在转向（旋转速度超过阈值）
		bIsTurning = (Abs(DeltaRot.Yaw / DeltaTime) > 5000);
		bTurningLeft = (DeltaRot.Yaw < 0);
		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
		if (PSI != None && PSI.bIsAlive) 
		{
			Pawn.GetAnimParams(0,AnimSeq, AnimFrame, AnimRate);
			// 如果是基础动画，检查行走动画
			if (Hero(Pawn).IsBasicAnim(AnimSeq))
				Character(Pawn).CHAR_CheckWalkAnim(OldAccel,bIsTurning,bTurningLeft);
			// 如果目标锁定且距离不够，检查行走动画
			else if (TargetLocked() && !CanStop(VSize(LockedTarget.Location - Pawn.Location)))
			{
				// 如果正在使用第二技能，直接返回
				if(IsInState('SecondSkillAttacking')) 
					return;		

				Character(Pawn).CHAR_CheckWalkAnim(OldAccel,bIsTurning,bTurningLeft);
			}
		}
	}
	/**
	 * 玩家移动
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		local vector vecTarget;
		local float AnimFrame, AnimRate;
		local name AnimSeq;
		local float DistToTarget;
		local vector vDiff;
		local float DistanceMoved;
		local vector DestDiff;
		local float DestDistance;
		local vector NewLocation;
	    
		// 如果Buff禁止行动，直接返回
		if(PSI != None && PSI.CheckBuffDontAct()) 
			return ;

		Pawn.GetAnimParams(0,AnimSeq, AnimFrame, AnimRate);
		bBackward = False;

		// 移动宠物
		if(PetController != None && PSI != None && PSI.bIsAlive)	
			PetController.MovePet(Destination);
		// 如果不是玩家角色，处理动画和位置同步
		if (PSI != None && !Character(Pawn).IsAvatar() && PSI.bIsAlive) 
		{
			// 检查位置同步状态
			if ( bSyncingPosition && Pawn != None )
			{
				// 计算当前位置与目标位置的2D距离
				vecTarget = Destination - Pawn.Location;
				vecTarget.Z = 0;
				DistToTarget = VSize(vecTarget);
				
				// 如果接近目标位置，恢复正常速度
				if ( DistToTarget < SyncCloseDistance && OriginalGroundSpeed > 0 )
				{
					Pawn.GroundSpeed = OriginalGroundSpeed;
					bSyncingPosition = False;
					OriginalGroundSpeed = 0;  // 重置，下次需要时重新保存
				}
			}
			
			// 卡地形检测和立即同步
			if ( Pawn != None )
			{
				// 初始化阈值（如果未设置）
				if ( StuckThreshold == 0 )
					StuckThreshold = 50.0;
				if ( StuckTimeLimit == 0 )
					StuckTimeLimit = 0.3;
				
				// 计算从上次同步位置移动的距离
				vDiff = Pawn.Location - LastSyncLocation;
				vDiff.Z = 0;  // 只考虑2D距离
				DistanceMoved = VSize(vDiff);
				
				// 如果位置变化很小，但还在尝试移动（有加速度或Destination很远），可能卡住了
				if ( DistanceMoved < StuckThreshold )
				{
					DestDiff = Destination - Pawn.Location;
					DestDiff.Z = 0;
					DestDistance = VSize(DestDiff);
					
					// 如果目标距离较远但位置几乎没变，说明卡住了
					if ( DestDistance > 500.0 )
					{
						StuckCheckTime += DeltaTime;
					
						// 如果卡住时间超过限制，强制同步到服务器位置
						if ( StuckCheckTime >= StuckTimeLimit )
						{
							//DebugLog("PlayerMove StuckCheckTime >= StuckTimeLimit:  "$StuckCheckTime);
							NewLocation = Destination;
							NewLocation.Z = Pawn.Location.Z + 100;  // 保持Z轴
							Pawn.SetLocation(NewLocation);
							//DebugLog("PlayerMove NewLocation: "$NewLocation);
							// 重置检测
							LastSyncLocation = Pawn.Location;
							StuckCheckTime = 0;
							bSyncingPosition = False;  // 停止加速同步
							if ( OriginalGroundSpeed > 0 )
							{
								Pawn.GroundSpeed = OriginalGroundSpeed;
								OriginalGroundSpeed = 0;
							}
						}
					}
					else
					{
						// 目标很近，重置卡住检测
						StuckCheckTime = 0;
					}
				}
				else
				{
					// 位置有明显变化，重置卡住检测
					StuckCheckTime = 0;
					LastSyncLocation = Pawn.Location;
				}
			}
			
			// 如果正在远程攻击或弓箭攻击且有加速度（正在移动），强制切换到行走动画
			if (Hero(Pawn).IsBasicAnim(AnimSeq))
			{
				Character(Pawn).CHAR_CheckWalkAnim(Pawn.Acceleration,False,False);
			}
			else if (TargetLocked() && !CanStop(VSize(LockedTarget.Location - Pawn.Location)))
			{
				if(IsInState('SecondSkillAttacking')) 
					return;

				Character(Pawn).CHAR_CheckWalkAnim(Pawn.Acceleration,False,False);
			}
			return;
		}

		// 调整玩家速度
		if (Hero(Pawn) != None && PSI != None && !bGodMode)
			Hero(Pawn).AdjustPlayerSpeed(PSI);
		// 如果不是鼠标移动且有加速度，旋转到摄像机方向
		if (Pawn != None && !bMouseMove && (Pawn.Acceleration.X != 0 || Pawn.Acceleration.Y != 0))
			RotateToCamera();
		Super.PlayerMove(DeltaTime);

		// 检查是否到达交互目标
		vecTarget = Destination - Pawn.Location;
		vecTarget.Z = 0;
		if (InteractTo != None && CanStop(VSize(vecTarget))) 
		{
			// 到达目标，执行目标动作
			Destination = Pawn.Location;
			AchieveGoal();
			Stopped();
			InteractTo = None;
		}
		// 如果没有加速度，关闭键盘移动
		if (Pawn != None && Pawn.Acceleration.X == 0 && Pawn.Acceleration.Y == 0)
			bKeyboardMove = False;
	}
Move:
	// 如果Buff禁止行动，关闭鼠标移动
	if(PSI != None && PSI.CheckBuffDontAct()) 
		bMouseMove = False;
	else
	{
		bMouseMove = True;
		// 如果刚受伤，清除受伤标志
		if (Character(Pawn).bJustDamaged)
			Character(Pawn).bJustDamaged = False;  
		// 移动到目标位置
		MoveTo(Destination,None,Pawn.bIsWalking);
	}
}

/**
 * 改变游戏状态
 * @param State 新状态
 */
function ChangeGameState(int State)
{
	if ( Player != None && Player.GameState != State ) 
	{
		Player.GameState = State;
		ConsoleCommand("CHECKCURSOR");
	}
}

// 光标状态切换函数
function CursorToNormal() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Normal); 
}

function CursorToAttack() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Attack); 
}

function CursorToMinimap() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Minimap); 
}

function CursorToRepair() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Repair); 
}

function CursorToSell() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Sell); 
}

function CursorToInterface() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Interface); 
}

function CursorToPressButton() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Button); 
}

function CursorToGauge() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Gauge); 
}

function CursorToDialogLink() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_DialogLink); 
}

function CursorToTalk() 
{ 
	if ( Player != None ) ChangeGameState(Player.GM_Talk); 
}

function ActivateTickInterfaceController();	// 激活Tick接口控制器

/**
 * 导航状态
 * 默认的玩家移动状态
 */
auto state Navigating extends Approaching
{
	/**
	 * 状态开始
	 */
	function BeginState()
	{
		// 如果不是玩家角色，重置移动计时器
		if (Pawn != None && !Character(Pawn).IsAvatar())
			MoveTimer = -1;
		ActivateTickInterfaceController();
		LockedTarget = None;
		// 清除受伤标志
		if (Pawn != None)
			Character(Pawn).bJustDamaged = False;
	}
	
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel)
	{
		Super.AnimEnd(Channel);

		// 如果动作阶段不是无或结束，设置为结束
		if (Pawn.ActionStage != STAGE_None && Pawn.ActionStage != STAGE_End)
			Pawn.SetActionStage(STAGE_End);
	}
	
	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 是否可以停止（距离小于30）
	 */
	function bool CanStop(float Distance) 
	{ 
		return Distance < 30; 
	}
	
	function AchieveGoal() 
	{
	}
	
	/**
	 * 更新旋转
	 * @param DeltaTime 时间增量
	 * @param maxPitch 最大俯仰角
	 */
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local int camera_yaw;
		local Rotator Rot;

		Super.UpdateRotation(DeltaTime,maxPitch);
		// 如果启用了摄像机追踪
		if (bool(ConsoleCommand("GETOPTIONI TraceCamera"))) 
		{
			if (Pawn.Velocity != vect(0,0,0) && !bKeyboardMove) 
			{ 
				// 计算摄像机偏航角差值
				camera_yaw = Rotation.Yaw - Rotator(Destination - Pawn.Location).Yaw;
				camera_yaw = camera_yaw % 65536;
				// 规范化角度到-32768到32768范围
				if( camera_yaw < -32768 ) camera_yaw = camera_yaw + 65536;
				else if( camera_yaw > 32768 ) camera_yaw = camera_yaw - 65536;
				// 如果角度差在合理范围内，平滑调整摄像机
				if( camera_yaw > -7000 && camera_yaw < 7000 ) 
				{
					rot = Rotation;
					// 根据角度差和方向调整偏航角
					if( camera_yaw < -50 ) rot.Yaw = Rotation.Yaw + abs(camera_yaw) ** 0.6 * 1.15 * DeltaTime / 0.05;
					else if( camera_yaw > 50 ) rot.Yaw = Rotation.Yaw - abs(camera_yaw) ** 0.6 * 1.15 * DeltaTime / 0.05;
					SetRotation(rot);
				}
			}
		}
	}
}

event TargetDead();		// 目标死亡事件
function StopAction();		// 停止动作

function BroadcastAction(Skill Skill,float Speed,float Delay);	// 广播动作

function TweenToFinish();	// 过渡到完成状态

/**
 * 播放动作（技能）
 * @param Skill 要播放的技能
 * @param GivenSpeed 给定的速度（0表示使用技能默认速度）
 * @param TweenTime 过渡时间（可选）
 * @return 是否成功播放
 */
function bool PlayAction(Skill Skill,float GivenSpeed,optional float TweenTime)
{
	local float Speed, Delay;
	local int ActionStep;

	bIsActing = True;

	// 根据技能类型计算速度和延迟
	if ( Skill.SlotType == class'GConst'.Default.SSMagic ) 
	{
		// 魔法技能：使用施法速度
		if ( GivenSpeed == 0 && Skill.MagicCastingSpeed > 0.0 )
			Speed = 1000.0 / Skill.MagicCastingSpeed;
		else
			Speed = GivenSpeed;
		Delay = Skill.MagicCastingDelay / 1000.f;
	}
	else 
	{
		// 近战技能：使用攻击时间
		if ( GivenSpeed == 0 && Skill.MeleeAttackTime > 0.0 )
			Speed = Skill.MeleeAttackTime / 1000.0;
		else
			Speed = GivenSpeed;
		Delay = 0.f;
	}
	
	// 确定动作步骤（连击或普通）
	if ( Skill.IsCombo() )
		ActionStep = ComboCount - 1;
	else 
		ActionStep = -1;

	if ( Speed > 0 )
	{
		ThisSkill = Skill;

		// 广播动作到服务器
		if ( Net != None )
			BroadcastAction(Skill,Speed,Delay);

		// 生成动作特效
		SpawnActionEffect(Skill);

		// 清空步骤时间数组
		if( ArStepTime.Length > 0 )
			ArStepTime.Remove(0,ArStepTime.Length);

		// 播放动画动作
		Character(Pawn).GetPlayAnimAction(Skill.AnimSequence,AttackAniChannel,ArStepTime,AttackEndTime,ActionStep,Speed,TweenTime);

		// 增加技能使用计数（用于秒表统计）
		Stopwatch_IncSkillUseCount(Skill.SkillName);		

		return True;
	}
	else 
	{
		bIsActing = False;
		bIsActingFinish = False;
		return False;
	}
}

function SpawnImmuneEffect(Pawn pawn);	// 生成免疫特效
function SpawnMissEffect(optional Pawn Attacker);				// 生成未命中特效

/**
 * 受伤事件
 * 处理玩家受到伤害时的各种效果
 * @param Attacker 攻击者
 * @param Skill 使用的技能
 * @param bPain 是否疼痛
 * @param bKnockback 是否击退
 * @param bCritical 是否暴击
 * @param bMiss 是否未命中
 * @param bBlock 是否格挡
 * @param bImmune 是否免疫
 */
event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune)
{
	local string SoundString;
	local Sound HitSound;
	local bool bFinish;
	local int nRand;

	// 判断是否为终结技能
	if ( Skill != None && Skill.SlotType == Skill.SkillSlotType.SSLOT_Finish )
		bFinish = True;
	else
		bFinish = False;

	nRand = Rand(2);
	
	// 如果未命中或格挡，统一生成未命中特效
	if ( bMiss || bBlock ) 
	{
		SpawnMissEffect(Attacker);
	}
	else
	{
		// 普通伤害：生成疼痛特效
		if ( !bPain && !bKnockback && !bCritical && !bMiss && !bBlock && !bImmune )
			SpawnPainEffect();
		else 
		{
			// 疼痛效果
			if ( !bBlock && bPain ) 
			{
				Pain();
				// 如果不在攻击状态，播放疼痛动画
				if ( !IsInState('Attacking') )
					Hero(Pawn).PlayPain();
				// 如果不是暴击，生成疼痛特效
				if ( !bCritical )
					SpawnPainEffect();
			}
			// 击退效果
			if ( bKnockback ) 
			{
				Pain();
				// 播放击退动画并进入击退状态（击退应该能够中断攻击）
				// 进入击退状态（这会自动禁用所有移动和攻击）
				GotoState('Knockbacking');
				Hero(Pawn).PlayAnimAction('Knockback', -1,1.0,0.3);
				Hero(Pawn).SetAnimFrame(0);
				// 如果不是暴击，生成击退特效
				if ( !bCritical )
					SpawnKnockbackEffect();
			}
			// 暴击效果
			if ( bCritical )
				SpawnCriticalEffect();

			// 免疫效果
			if ( bImmune )
				SpawnImmuneEffect(Self.Pawn);
			// 注意：格挡效果已统一到未命中特效处理，此处不再单独处理
		}
	}

	// 播放命中音效
	if ( Attacker != None && ((!bBlock && bPain) || bKnockback || bCritical || bFinish) && Skill != None ) 
	{
		SoundString = "EffectSound.Hit.";
		// 根据技能类型选择音效前缀
		switch (Skill.BookName) 
		{
			case "BareHand":
				SoundString = SoundString$"Hand_";
				break;
			case "BareFoot":
				SoundString = SoundString$"Kick_";
				break;
			case "OneHand":
				SoundString = SoundString$"Sword_";
				break;
			case "Staff":
				SoundString = SoundString$"Staff_";
				break;
			default:
				return;
		}
		// 根据伤害类型选择音效后缀
		if ( bCritical )
			SoundString = SoundString$"Critical";
		else if (bFinish)
			SoundString = SoundString$"Finish";
		else
			SoundString = SoundString$"Hit";

		// 加载并播放音效
		HitSound = Sound(DynamicLoadObject(SoundString, class'Sound'));
		if ( HitSound != None && Pawn != None )
			Pawn.PlaySound(HitSound,SLOT_Interact);
	}
}







/**
 * 攻击状态
 * 处理玩家攻击时的行为
 */
state Attacking extends Approaching
{
	function bool StartAction();		// 开始动作
	function BroadcastAction(Skill skill, Float speed, Float delay);	// 广播动作
	function BroadcastHit(Skill skill);	// 广播命中
	/**
	 * 达到目标
	 */
	function AchieveGoal()
	{
		StartAction();
	}
	/**
	 * 查找最近的物品
	 * 在攻击状态下查找并拾取最近的物品
	 */
	exec function FindNearestItem()
	{
		local int i;
		local float Dist,MinDist;
		local Attachment Item,NearestItem;

		MinDist = 1000000.f;
		// 遍历所有地面物品
		for (i = 0;i < GameManager(Level.Game).GroundItems.Length;i++) 
		{
			Item = GameManager(Level.Game).GroundItems[i];
			if (Item != None && !Item.bDeleteMe && Item.Info != None) 
			{
				// 检查是否可以拾取
				if (Item.Info.CanPickup(PSI.PlayName)) 
				{
					Dist = VSize(Item.Location - Pawn.Location);
					// 查找距离最近且在拾取范围内的物品
					if (Dist < MinDist && Dist <= 1500.f) 
					{
						MinDist = Dist;
						NearestItem = Item;
					}
				}
			}
		}

		if (NearestItem != None && !NearestItem.bDeleteMe)
		{
			InteractTo = NearestItem;

			// 如果是金钱，直接拾取
			if (NearestItem.IsA('Money'))
				Net.NotiPickUpMoney(NearestItem.Info.PanID);
			else
			{
				// 如果是封印物品，显示确认对话框
				if ( NearestItem.Info.xSealFlag == NearestItem.Info.eSEALFLAG.SF_USED )
				{
					class'CMessageBox'.Static.MessageBox(CMultiInterface(myHud), "Sealed Item", Localize("Modals", "PickupSealedItem", "Sephiroth"), MB_YesNo, IDM_SEALEDITEM);
				}
				else
				{
					// 普通物品直接拾取
					Net.NotiPickupItem(NearestItem.Info.PanID);
					InteractTo = None;
				}
			}
		}
	}
Attack:
	AchieveGoal();
}

/**
 * 网络接收开始连击
 * @param Skill 技能对象
 * @param CC 连击计数
 * @param Speed 速度
 */
function NetRecv_StartCombo(Skill Skill,int CC,float Speed)
{
	GotoState('MeleeAttacking');
	ComboCount = CC;
	PlayAction(Skill,Speed,0);
}

/**
 * 网络接收开始终结技
 * @param Skill 技能对象
 * @param Speed 速度
 */
function NetRecv_StartFinish(Skill Skill,float Speed)
{
	GotoState('MeleeAttacking');
	PlayAction(Skill,Speed,0);
}

function PlanNextAction();	// 计划下一个动作

/**
 * 查找最近的怪物
 * 查找并锁定最近的怪物作为攻击目标
 */
exec function FindNearestMonster()
{
	local int i;
	local float Dist,MinDist;
	local Rotator Rot;
	local Creature Creature,Nearest;
	MinDist = 100000.0f;
	// 遍历所有生物
	for ( i = 0;i < GameManager(Level.Game).Creatures.Length;i++ ) 
	{
		Creature = GameManager(Level.Game).Creatures[i];
		// 查找怪物类型
		if ( Creature != None && !Creature.bDeleteMe && Creature.IsA('Monster') ) 
		{
			Dist = VSize(Creature.Location - Pawn.Location);
			// 更新最近距离
			if ( Dist < MinDist ) 
			{
				MinDist = Dist;
				Nearest = Creature;
			}
		}
	}
	if ( Nearest != None && !Nearest.bDeleteMe ) 
	{
		// 锁定目标
		if ( LockedTarget == None )
			LockedTarget = Nearest;
		// 旋转到目标方向
		Rot = Pawn.Rotation;
		Rot.Yaw = Rotator(LockedTarget.Location - Pawn.Location).Yaw;
		Pawn.SetRotation(Rot);
		// 根据距离决定移动或直接攻击
		if ( MinDist > 120 + LockedTarget.CollisionRadius ) 
		{
			InteractTo = LockedTarget;
			Destination = LockedTarget.Location;
			GotoState('MeleeAttacking','Move');
		}
		else
			GotoState('MeleeAttacking','Attack');
	}
}

/**
 * 查找最近的物品
 * 查找并移动到最近的物品进行拾取
 */
exec function FindNearestItem()
{
	local int i;
	local float Dist,MinDist;
	local Attachment Item,NearestItem;

	// 如果Buff禁止行动，直接返回
	if( PSI.CheckBuffDontAct() ) 
		return ;

	MinDist = 1000000.f;
	// 遍历所有地面物品
	for ( i = 0;i < GameManager(Level.Game).GroundItems.Length;i++ ) 
	{
		Item = GameManager(Level.Game).GroundItems[i];
		if ( Item != None && !Item.bDeleteMe && Item.Info != None ) 
		{
			// 检查是否可以拾取
			if ( Item.Info.CanPickup(PSI.PlayName) ) 
			{
				Dist = VSize(Item.Location - Pawn.Location);
				// 查找距离最近且在拾取范围内的物品
				if ( Dist < MinDist && Dist <= 1500.f ) 
				{
					MinDist = Dist;
					NearestItem = Item;
				}
			}
		}
	}
	if ( NearestItem != None && !NearestItem.bDeleteMe ) 
	{
		InteractTo = NearestItem;
		RotatePawnTo(NearestItem.Location);
		// 根据距离决定移动或直接拾取
		if ( MinDist > 100 + InteractTo.CollisionRadius ) 
		{
			Destination = InteractTo.Location;
			GotoState('Picking','Move');
		}
		else
			GotoState('Picking','Pick');
	}
}

/**
 * 拾取一个物品
 * 执行拾取操作
 */
function PickupOne()
{
	local Attachment Item;
	Item = Attachment(InteractTo);
	
	if ( Item != None && !Item.bDeleteMe )
	{
		// 如果是金钱，直接拾取
		if ( Item.IsA('Money') )
		{
			Net.NotiPickUpMoney(Item.Info.PanID);
		}
		else if ( Item.Info != None )
		{
			// 如果是封印物品，不处理（需要确认对话框）
			if ( Item.Info.xSealFlag == Item.Info.eSEALFLAG.SF_USED )
			{
				// 封印物品需要用户确认
			}
			else
			{
				// 普通物品直接拾取
				Net.NotiPickupItem(Item.Info.PanID);
			}
		}
	}

	InteractTo = None;
}



/**
 * 拾取附近物品
 * 根据白名单或黑名单拾取附近的物品
 * @param PickupItems 要拾取的物品列表（白名单）
 * @param NotPickupIems 不拾取的物品列表（黑名单）
 */
exec function PickupNearItems(array<string> PickupItems,array<string> NotPickupIems)
{
	local int i,j;
	local float Dist;
	local Attachment Item,NearestItem;

	// 如果Buff禁止行动，直接返回
	if( PSI.CheckBuffDontAct() ) 
		return ;

	// 遍历所有地面物品
	for ( i = 0;i < GameManager(Level.Game).GroundItems.Length;i++ ) 
	{
		Item = GameManager(Level.Game).GroundItems[i];
		if ( Item != None && !Item.bDeleteMe && Item.Info != None ) 
		{
			if ( Item.Info.CanPickup(PSI.PlayName) ) 
			{
				Dist = VSize(Item.Location - Pawn.Location);
				// 检查是否在拾取范围内
				if ( Dist <= 2000.f ) 
				{   
					NearestItem = Item;

					// 如果有白名单，只拾取白名单中的物品
					if( PickupItems.Length != 0 )
					{
						for( j = 0;j < PickupItems.Length;++j )
						{
							if( PickupItems[j] == NearestItem.Info.LocalizedDescription )
							{					
								InteractTo = NearestItem;
								PickupOne();
							}
						}
					}
					else
					{
						// 如果有黑名单，排除黑名单中的物品
						if( NotPickupIems.Length != 0 )
						{
							for( j = 0;j < NotPickupIems.Length;++j )
							{
								if( NotPickupIems[j] == NearestItem.Info.LocalizedDescription )
								{
									break;
								}
							}
							// 如果不在黑名单中，拾取
							if( j == NotPickupIems.Length )
							{
								InteractTo = NearestItem;
								PickupOne();
							}
							continue;
						}
						
						// 没有白名单和黑名单，拾取所有物品
						InteractTo = NearestItem;
						PickupOne();
					}
				}
			}
		}
	}
}

/**
 * 收集附近物品信息
 * 收集附近所有可拾取的物品信息
 * @return 附近物品数组
 */
exec function array<Attachment> CollectNearItemsInfo()
{
	local int i;
	local float Dist,MinDist;
	local Attachment Item;
	local array<Attachment> AroundItems;

	MinDist = 1000000.f;
	// 遍历所有地面物品
	for ( i = 0;i < GameManager(Level.Game).GroundItems.Length;i++ ) 
	{
		Item = GameManager(Level.Game).GroundItems[i];
		if ( Item != None && !Item.bDeleteMe && Item.Info != None ) 
		{
			// 检查是否可以拾取
			if ( Item.Info.CanPickup(PSI.PlayName) ) 
			{
				Dist = VSize(Item.Location - Pawn.Location);
				// 添加到数组
				if ( Dist < MinDist ) 
				{
					AroundItems[AroundItems.Length] = Item;
				}
			}
		}
	}
	return AroundItems;
}

/**
 * 查找最近的怪物进行攻击
 * @param DirectionalScale 方向范围
 * @return 找到的怪物，未找到返回None
 */
exec function Creature FindNearestMonsterToAttack(float DirectionalScale)
{
	local int i;
	local float Dist,MinDist;
	local Rotator Rot;
	local Creature Creature,Nearest;
	
	MinDist = DirectionalScale;
	// 遍历所有生物
	for ( i = 0;i < GameManager(Level.Game).Creatures.Length;i++ ) 
	{
		Creature = GameManager(Level.Game).Creatures[i];
		// 查找活着的怪物
		if ( Creature != None && !Creature.bDeleteMe && Creature.IsA('Monster') && !Creature.bIsDead ) 
		{
			Dist = VSize(Creature.Location - Pawn.Location);
			// 更新最近距离
			if ( Dist < MinDist ) 
			{
				MinDist = Dist;
				Nearest = Creature;
			}
		}
	}
	if ( Nearest != None && !Nearest.bDeleteMe ) 
	{
		// 锁定目标
		if ( LockedTarget == None )
			LockedTarget = Nearest;
		
		// 返回找到的怪物
		return Nearest;
	}
	return None;
}



/**
 * 查找并远程攻击
 * 查找最近的怪物进行远程攻击，如果没找到则按方向移动
 * @param num 移动方向（0-3：前、右、后、左）
 */
exec function FindAndRangeAttack(int num)
{
	local int i;
	local float Dist,MinDist;
	local Rotator Rot;
	local Creature Creature,Nearest;
	local vector MoveVector;
	MinDist = 100000.0f;

	// 如果Buff禁止行动，直接返回
	if( PSI.CheckBuffDontAct() ) 
		return ;

	// 遍历所有生物查找最近的怪物
	for ( i = 0;i < GameManager(Level.Game).Creatures.Length;i++ ) 
	{
		Creature = GameManager(Level.Game).Creatures[i];
		if ( Creature != None && !Creature.bDeleteMe && Creature.IsA('Monster') ) 
		{
			Dist = VSize(Creature.Location - Pawn.Location);
			if ( Dist < MinDist ) 
			{
				MinDist = Dist;
				Nearest = Creature;
			}
		}
	}
	// 如果找到怪物，进行远程攻击
	if ( Nearest != None && !Nearest.bDeleteMe ) 
	{
		if ( LockedTarget == None )
			LockedTarget = Nearest;
		// 旋转到目标方向
		Rot = Pawn.Rotation;
		Rot.Yaw = Rotator(LockedTarget.Location - Pawn.Location).Yaw;
		Pawn.SetRotation(Rot);
		GotoState('BowAttacking','Attack');
	}
	else
	{
		// 如果没找到怪物且不在拾取状态，按指定方向移动
		if( !IsInState('Picking') )
		{
			// 根据方向参数设置移动向量
			if( num == 0 )
				MoveVector = vect(250, 0, 0);
			else if(num == 1)
				MoveVector = vect(0, 250, 0);
			else if(num == 2)
				MoveVector = vect(-250, 0, 0);
			else if(num == 3)
				MoveVector = vect(0, -250, 0);
			Destination = Pawn.Location + MoveVector; 
			Rot = Pawn.Rotation;
			Rot.Yaw = Rotator(Destination - Pawn.Location).Yaw;
			Pawn.SetRotation(Rot);			
			GotoState('Approaching', 'Move');
		}
	}
}

function DereferenceActor(Actor actor);	// 取消Actor引用

/**
 * 近战攻击状态
 * 处理玩家近战攻击时的行为
 */
state MeleeAttacking extends Attacking
{
	ignores KeyboardMove;	// 忽略键盘移动

	/**
	 * 落地处理
	 * @param HitNormal 碰撞法线
	 */
	function Landfloor(vector HitNormal) 
	{
	}
	
	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 是否可以停止
	 */
	function bool CanStop(float Distance) 
	{
		// 如果有锁定目标，计算包含目标碰撞半径的距离
		if (LockedTarget != None)
			return Distance < sqrt(2.0) * (2 * Pawn.CollisionRadius + LockedTarget.CollisionRadius);
		else
			return Distance < sqrt(2.0) * (2 * Pawn.CollisionRadius);
	}
	
	/**
	 * 状态开始
	 */
	function BeginState()
	{
		Super.BeginState();
		// 如果未装备武器，装备武器
		if (!PSI.ArmState)
			ToggleArmState();	
	}
	
	/**
	 * 状态结束
	 */
	function EndState()
	{
		ComboCount = -1;
		bIsActing = False;
		bIsActingFinish = False;
		ActionEnd(True,0.3);
		DestroyActionEffect();
	}
	/**
	 * 开始动作
	 * @return 是否成功开始
	 */
	function bool StartAction()
	{
		// 如果Buff禁止行动，返回失败
		if(PSI.CheckBuffDontAct()) 
			return False;

		// 检查连击技能是否可用
		if (PSI.Combo == None || (Character(Pawn).IsAvatar() && (!PSI.Combo.bLearned || !PSI.Combo.bEnabled))) 
		{
			GotoState('Navigating');
			return False;
		}

		// 检查技能点数
		if (Character(Pawn).IsAvatar() && PSI.Combo.bHasSkillPoint && PSI.Combo.SkillPoint == 0) 
		{
			myHud.AddMessage(2,Localize("Warnings","NeedSkillPoint","Sephiroth")@PSI.Combo.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return False;
		}

		// 如果是玩家角色，计划下一个技能
		if (Character(Pawn).IsAvatar()) 
		{
			if (ComboCount > -1) 
			{
				// 如果连击计数达到最大值，使用终结技
				if (ComboCount >= PSI.Combo.ComboCount - 1)
				{
					NextSkill = PSI.Finish;
					nComboStartCount = 0;
				}
				else
					NextSkill = PSI.Combo;
			}
			else 
			{
				// 如果动作完成，重置连击
				if (bIsActingFinish) 
				{
					ComboCount = -1;
					NextSkill = PSI.Combo;
				}
				// 如果不在动作中，开始连击
				else if (!bIsActing)
					StartCombo();
			}
		}
		return True;
	}

	/**
	 * 开始连击
	 * 处理连击开始逻辑，包括宏检测
	 */
	function StartCombo()
	{
		local vector v2d;
		
		// 如果连击开始计数小于30，开启宏检测
		if(nComboStartCount < 30) 
			bOnMacroKiller = True;

		// 红蓝职业重置计数
		if(PSI.JobName == 'Red' || PSI.JobName == 'Blue') 
			nComboStartCount = 0; 

		if(bOnMacroKiller)
		{
			// 如果计数小于10，可以开始连击
			if(nComboStartCount < 10) 
			{
				// 计算到目标的2D距离
				v2d = lockedtarget.location - pawn.location;
				v2d.z = 0;
				// 如果距离足够近，开始连击
				if (canstop(vsize(v2d)))
				{
					ComboCount = 0;
					nComboStartCount++; 
					PlayAction(PSI.Combo,0,0);
					NextSkill = None;
				}
				else
					GotoState('Navigating');

				fBlockedTime = Level.TimeSeconds;
			}
			else
				// 如果计数为5，显示警告
				if(nComboStartCount == 5)
					myHud.AddMessage(2, Localize("Warnings", "CannotUseSkill", "Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));

			// 根据计数范围衰减计数
			if(nComboStartCount < 3)
			{
				// 小于3时，0.3秒后衰减
				if(Level.TimeSeconds - fBlockedTime > 0.3f) 
					if(nComboStartCount > 0)
						nComboStartCount--;
			}
			else
			{
				// 大于等于3时，1秒后衰减
				if(Level.TimeSeconds - fBlockedTime > 1) 
					if(nComboStartCount > 0)
						nComboStartCount--;
			}

			fLastAttackTime = Level.TimeSeconds;
			// 如果超过1.5秒没有攻击，重置计数
			if(Level.TimeSeconds - fLastAttackTime > 1.5f) 
				nComboStartcount = 0; 
		}
	}

	/**
	 * 推进连击
	 */
	function AdvanceCombo()
	{
		local vector v2d;
		v2d = lockedtarget.location - pawn.location;
		v2d.z = 0;
		
		if (canstop(vsize(v2d)))
		{
			ComboCount++;
			PlayAction(PSI.Combo,0,0);
			NextSkill = None;
		}
		else
			GotoState('Navigating');
	}

	/**
	 * 开始终结技
	 * 执行终结技能
	 */
	function StartFinish()
	{
		local vector v2d;
		// 计算到目标的2D距离
		v2d = lockedtarget.location - pawn.location;
		v2d.z = 0;
		// 如果距离足够近，执行终结技
		if (canstop(vsize(v2d))) 
		{
			ComboCount = -1;
			bIsActingFinish = True;
			PlayAction(PSI.Finish,0,0);
			nComboStartCount = 0; 
			NextSkill = None;
		}
		else
			GotoState('Navigating');
	}
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel)
	{
		if (Character(Pawn).IsAvatar()) 
		{
			Super.AnimEnd(Channel);
		}
		AnimStep(Channel);
	}
	
	/**
	 * 计划下一个动作
	 * 根据当前状态决定下一个要执行的技能
	 */
	function PlanNextAction()
	{
		DestroyActionEffect();
		// 如果没有下一个技能，返回导航状态
		if (NextSkill == None)
			GotoState('Navigating');
		else 
		{
			// 检查技能点数
			if (NextSkill.bHasSkillPoint && NextSkill.SkillPoint == 0) 
			{
				myHud.AddMessage(2,Localize("Warnings","NeedSkillPoint","Sephiroth")@NextSkill.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				ActionEnd(True,0.3);
				GotoState('Navigating');
			}
			else 
			{
				// 如果是连击技能
				if (NextSkill.IsCombo()) 
				{
					bIsActingFinish = False;
					if (ComboCount > -1)
						AdvanceCombo();
					else
						StartCombo();
				}
				// 如果是终结技
				else if (NextSkill.IsFinish())
					StartFinish();
			}
		}
	}
	/**
	 * 动画步骤
	 * 处理动画步骤完成后的逻辑
	 * @param Channel 动画通道
	 */
	function AnimStep(int Channel)
	{
		DestroyActionEffect();
		// 如果是玩家角色且有当前技能
		if (Character(Pawn).IsAvatar() && ThisSkill != None) 
		{
			bIsActing = False;
			bIsActingFinish = False;
			ActionEnd(False, 0.2);
			PlanNextAction();
		}
		// 如果不是玩家角色（网络复制的角色）
		else if (!Character(Pawn).IsAvatar()) 
		{
			// 如果动作池有动作，更新动作池
			if (ActionPool.Length > 0)
				UpdateActionPool();
			else 
			{
				// 动作池为空，结束动作并返回导航状态
				ActionEnd(True,0.3);
				GotoState('Navigating');
			}
		}
	}
	
	/**
	 * 过渡到终结技
	 */
	function TweenToFinish()
	{
		if (NextSkill != None && NextSkill.IsFinish())
			AnimStep(0);
	}
	
	/**
	 * 动作结束事件
	 * @param bTweenToIdle 是否过渡到待机
	 * @param TweenTime 过渡时间
	 */
	event ActionEnd(bool bTweenToIdle, optional float TweenTime)
	{
		Character(Pawn).StartIdle(bTweenToIdle, TweenTime);
		// 如果是玩家，清除命中检测信息
		if (bIsPlayer) 
		{
			HDI.bCheckHit = False;
			HDI.CheckBone = '';
		}
		ThisSkill = None;
		Destination = Pawn.Location;
	}

	
	
	
	/**
	 * 广播动作（近战）
	 * 向服务器发送近战攻击动作
	 * @param Skill 技能对象
	 * @param Speed 速度
	 * @param Delay 延迟
	 */
	function BroadcastAction(Skill Skill,float Speed,float Delay)
	{
		local int Seq,PanID;
		// 检查技能和目标有效性
		if (Skill == None || Skill.IsMagic()
				|| LockedTarget == None || LockedTarget.bIsDead || LockedTarget.bDeleteMe
				|| Speed == 0.f)
			return;
		Seq = SkillFrame.AdvanceFrame();
		// 获取目标ID
		if (Hero(LockedTarget) != None)
			PanID = ClientController(LockedTarget.Controller).PSI.PanID;
		else
			PanID = ServerController(LockedTarget.Controller).MSI.PanID;
		// 根据技能类型发送不同的网络消息
		if (Skill.IsCombo())
		{
			// 如果等待攻击结果计数小于3，发送连击消息
			if(PSI.nWaitingAttackResultCnt < 3)	
			{
				Net.NotiActMeleeCombo(Skill.SkillName,Seq,PanID,LockedTarget.Location,Character(Pawn).ActionSpeedRate,ComboCount + 1);
				PSI.nWaitingAttackResultCnt = 0; 
			}
		}
		else 
		{		
			// 如果等待攻击结果计数小于3，发送终结技消息
			if(PSI.nWaitingAttackResultCnt < 3)	
			{
				Net.NotiActMeleeFinish(Skill.SkillName,Seq,PanID,LockedTarget.Location,Character(Pawn).ActionSpeedRate);
				PSI.nWaitingAttackResultCnt = 0; 
			}
		}
		SkillFrame.NewSkillFrame(Seq,SkillFrame.STATE_Melee);
	}
	/**
	 * 广播命中（近战）
	 * 向服务器发送近战攻击命中消息
	 * @param Skill 技能对象
	 */
	function BroadcastHit(Skill Skill)
	{
		local int Seq,PanID;
		// 检查技能和目标有效性
		if (Skill == None || Skill.IsMagic()
				|| LockedTarget == None || LockedTarget.bIsDead || LockedTarget.bDeleteMe)
			return;
		// 获取目标ID
		if (Hero(LockedTarget) != None)
			PanID = ClientController(LockedTarget.Controller).PSI.PanID;
		else
			PanID = ServerController(LockedTarget.Controller).MSI.PanID;
		Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Melee);
		// 发送命中消息
		Net.NotiHitMelee(Seq,Pawn.Location,PanID,LockedTarget.Location,0);
	}
	/**
	 * 命中检测
	 * 检测攻击是否命中目标
	 * @param Bone 检测的骨骼名称
	 * @param bApplyHitEffect 是否应用命中特效（可选）
	 */
	function HitDetect(name Bone,optional bool bApplyHitEffect)
	{
		// 只有玩家才进行命中检测
		if (!bIsPlayer)
			return;
		if (ThisSkill == None)
			return;
		if (LockedTarget == None || LockedTarget == Pawn)
			return;

		// 设置命中检测信息
		HDI.bCheckHit = True;
		HDI.CheckSkill = ThisSkill;
		HDI.CheckAttachment = None;
		HDI.CheckBone = Bone;
		// 根据技能类型设置检测附件
		if (ThisSkill.BookName == "OneHand") 
		{
			HDI.CheckAttachment = Hero(Pawn).Attachments[Hero(Pawn).AT_RightHand];
			if (HDI.CheckAttachment == None) 
			{
				HDI.bCheckHit = False;
				return;
			}
		}
		else if (ThisSkill.BookName == "Staff") 
		{
			HDI.CheckAttachment = Hero(Pawn).Attachments[Hero(Pawn).AT_BothHand];
			if (HDI.CheckAttachment == None) 
			{
				HDI.bCheckHit = False;
				return;
			}
		}

		HitDetectCore();
	}
	/**
	 * 命中检测核心逻辑
	 * 计算是否命中目标
	 */
	simulated function HitDetectCore()
	{
		local bool bHit;
		local vector MyLocation, TargetLocation;

		bHit = False;
		if (HDI.bCheckHit && HDI.CheckSkill != None) 
		{
			MyLocation = Pawn.Location;
			TargetLocation = LockedTarget.Location;
			TargetLocation.Z = MyLocation.Z;
			
			// 计算2D距离，判断是否在攻击范围内
			if (VSize(MyLocation - TargetLocation) < sqrt(2.0) * (2 * Pawn.CollisionRadius + LockedTarget.CollisionRadius))
				bHit = True;
			// 如果命中，广播命中消息
			if (bHit) 
			{
				BroadcastHit(ThisSkill);
				HDI.bCheckHit = False;
				HDI.CheckBone = '';
			}
		}
	}
	
	/**
	 * 玩家移动
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		// 如果不在连击状态，禁止移动
		if(ComboCount == -1) 
		{
			aForward = 0;
			aStrafe = 0;
		}

		Super.PlayerMove(DeltaTime);
		HitDetectCore();
	}
	
	/**
	 * 停止动作
	 */
	function StopAction()
	{
		TargetDead();
	}
	
	/**
	 * 目标死亡事件
	 */
	event TargetDead()
	{
		// 如果不在连击状态或目标无效，结束攻击
		if(ComboCount == -1 || LockedTarget == None || LockedTarget.bIsDead || LockedTarget.bDeleteMe)
		{
			DereferenceActor(LockedTarget);
			ComboCount = -1;
			ActionEnd(True,0.3f);
			nComboStartCount = 0; 
			PSI.nWaitingAttackResultCnt = 0; 
			GotoState('Navigating');
		}
	}
}

function PlayerArmed();	// 玩家装备武器

/**
 * 远程攻击状态
 * 处理玩家远程攻击（魔法）时的行为
 */
state RangeAttacking extends Attacking
{
	ignores KeyboardMove, Jump;	// 忽略键盘移动和跳跃

	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 总是返回True（远程攻击可以随时停止）
	 */
	function bool CanStop(float Distance) 
	{ 
		return True; 
	}
	
	/**
	 * 状态结束
	 */
	function EndState()
	{
		// 如果正在动作且刚发射，设置冷却时间
		if (bIsActing && bJustFired && PSI != None && PSI.Magic != None)
			CoolTime = PSI.Magic.MagicCastingDelay / 1000.f;
		bIsActing = False;
		bJustFired = False;
		ActionEnd(True,0.3);
		DestroyActionEffect();
		RClickActionEnd();	
	}
	/**
	 * 开始动作
	 * @return 是否成功开始
	 */
	function bool StartAction()
	{
		// 检查是否可以使用所有技能
		if(!CanUseAllSkill())		
		{
			myHud.AddMessage(2,
				Localize("Warnings", "CannotUseSkill", "Sephiroth"),
				class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return False;
		}

		// 检查魔法技能是否可用
		if (PSI == None || PSI.Magic == None || (Character(Pawn).IsAvatar() && (!PSI.Magic.bLearned || !PSI.Magic.bEnabled))) 
		{
			GotoState('Navigating');
			return False;
		}

		// 检查Buff是否禁止行动
		if(PSI.CheckBuffDontAct()) 
		{
			myHud.AddMessage(2, Localize("Warnings", "CannotAction", "Sephiroth"),class'Canvas'.Static.MakeColor(55,55,200));
			return False;
		}

		// 检查目标是否有效（服务器命中检测）
		if (PSI.Magic.bServerHitCheck && LockedTarget != None && !LockedTarget.bDeleteMe && LockedTarget.bIsDead) 
		{
			GotoState('Navigating');
			return False;
		}

		// 检查魔法值是否足够
		if (PSI.Mana < PSI.Magic.ManaConsumption) 
		{
			myHud.AddMessage(2,Localize("Warnings","NeedMana","Sephiroth")@PSI.Magic.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return False;
		}

		// 如果正在动作，返回失败
		if (bIsActing)
			return False;

		// 如果是玩家角色
		if (Character(Pawn).IsAvatar()) 
		{
			// 如果未装备武器，装备武器
			if (!PSI.ArmState)
				ToggleArmState();
			else 
			{
				ThisSkill = PSI.Magic;
				StartCast();
			}
		}
		return True;
	}
	/**
	 * 动画步骤
	 * @param Channel 动画通道
	 */
	function AnimStep(int Channel)
	{
		DestroyActionEffect();
		StartFire();
		bJustFired = True;
	}
	
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel)
	{
		local name OldName;
		local float OldFrame, OldRate;

		Pawn.GetAnimParams(Channel,OldName,OldFrame,OldRate);

		// 如果是当前技能的动画结束
		if (ThisSkill != None && OldName == ThisSkill.AnimSequence) 
		{
			bIsActing = False;
			PlanNextAction();
		}
		// 如果是基础动画结束
		else if (Hero(Pawn).IsBasicAnim(OldName)) 
		{
			if (Character(Pawn).IsAvatar()) 
			{
				ThisSkill = PSI.Magic;
				StartCast();
			}
			else 
			{
				if (!bIsActing) 
				{
					ThisSkill = PSI.Magic;
					StartCast();
				}
				else
				{
					GotoState('Navigating');
				}
			}
		}
	}
	
	/**
	 * 计划下一个动作
	 */
	function PlanNextAction()
	{
		ActionEnd(True,0.3);
		bJustFired = False;
		GotoState('Navigating');
	}
	
	/**
	 * 动作结束事件
	 * @param bTweenToIdle 是否过渡到待机
	 * @param TweenTime 过渡时间
	 */
	event ActionEnd(bool bTweenToIdle, optional float TweenTime)
	{
		Character(Pawn).StartIdle(bTweenToIdle, TweenTime);
		ThisSkill = None;
	}

	
	
	
	/**
	 * 广播动作（远程）
	 * 向服务器发送远程攻击（魔法）动作
	 * @param Skill 技能对象
	 * @param Speed 速度
	 * @param Delay 延迟
	 */
	function BroadcastAction(Skill Skill,float Speed,float Delay)
	{
		local int Seq,PanID;
		// 检查技能有效性
		if (Skill == None || !Skill.IsMagic() || Speed == 0.f)
			return;
		// 如果不是服务器命中检测且目标无效，重置技能帧
		if (!Skill.bServerHitCheck && (LockedTarget == None || LockedTarget.bDeleteMe || LockedTarget.bIsDead)) 
		{
			SkillFrame.ResetSkillFrame();
			return;
		}
		// 如果技能帧状态不是无，重置
		if (SkillFrame.LastState != SkillFrame.STATE_None)
			SkillFrame.ResetSkillFrame();
		Seq = SkillFrame.AdvanceFrame();
		// 获取目标ID
		if (Hero(LockedTarget) != None)
			PanID = ClientController(LockedTarget.Controller).PSI.PanID;
		else if (Creature(LockedTarget) != None)
			PanID = ServerController(LockedTarget.Controller).MSI.PanID;
		else
			PanID = 0;
		// 发送施法消息
		if (LockedTarget != None)
			Net.NotiCast(Skill.SkillName,Seq,PanID,LockedTarget.Location,1.0);
		else
			Net.NotiCast(Skill.SkillName,Seq,PanID,ActionTarget.Location,1.0);
		SkillFrame.NewSkillFrame(Seq,SkillFrame.STATE_Cast);
	}
	/**
	 * 广播发射（魔法技能）
	 * @param Skill 技能对象
	 * @return 序列号，失败返回-1
	 */
	function int BroadcastFire(Skill Skill)
	{
		local int Seq, PanID;
		local vector TargetLocation;
		if (Skill == None || !Skill.IsMagic())
			return -1;
		
		if (!Skill.bServerHitCheck && (LockedTarget == None || LockedTarget.bDeleteMe || LockedTarget.bIsDead)) 
		{
			SkillFrame.ResetSkillFrame();
			return -1;
		}
		Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Cast);
		if (Hero(LockedTarget) != None)
			PanID = ClientController(LockedTarget.Controller).PSI.PanID;
		else if (Creature(LockedTarget) != None)
			PanID = ServerController(LockedTarget.Controller).MSI.PanID;
		else
			PanID = 0;
		if (LockedTarget != None)
			TargetLocation = LockedTarget.Location;
		else
			TargetLocation = ActionTarget.Location;
		Net.NotiFire(Seq,PanID,TargetLocation);
		return Seq;
	}
	/**
	 * 广播发射失败
	 * @param Skill 技能对象
	 */
	function BroadcastFireFail(Skill Skill)
	{
		if (Skill == None || !Skill.IsMagic())
			return;
		Net.NotiFireFail(SkillFrame.SequenceNumber);
		SkillFrame.ResetSkillFrame();
	}
	
	function BroadcastHit(Skill Skill)
	{
	}
	
	/**
	 * 开始施法
	 */
	function StartCast()
	{
		// 如果Buff禁止行动，直接返回
		if(PSI.CheckBuffDontAct()) 
			return ;

		// 检查技能点数
		if (ThisSkill.bHasSkillPoint && ThisSkill.SkillPoint == 0) 
		{
			myHud.AddMessage(2,Localize("Warnings","NeedSkillPoint","Sephiroth")@ThisSkill.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			ActionEnd(True,0.3);
			GotoState('Navigating');
		}
		else 
		{
			// 播放动作并生成施法特效
			if (PlayAction(ThisSkill,0,0.3))
			{
				SpawnCastEffect(ThisSkill);
			}
		}
	}
	
	/**
	 * 开始发射
	 */
	function StartFire()
	{
		local int Seq;

		Seq = BroadcastFire(ThisSkill);

		// 如果不是范围技能且有目标，生成发射特效
		if (!ThisSkill.bIsSplash && LockedTarget != None && !LockedTarget.bDeleteMe) 
		{
			LastFiredEffect = SpawnFireEffect(ThisSkill, LockedTarget, LockedTarget.Location, Seq);
		}
		// 如果不是服务器命中检测，生成爆炸特效
		else if (!ThisSkill.bServerHitCheck) 
		{
			if (TargetLocked())
				SpawnExploEffect(ThisSkill, LockedTarget, LockedTarget.Location);
			else
				SpawnExploEffect(ThisSkill,None,ActionTarget.Location);
		}
	}
	
	function CancelFire()
	{
	}
	
	/**
	 * 玩家跳跃
	 */
	function PlayerJump()
	{
		Global.PlayerJump();
		GotoState('Navigating');
	}
	
	/**
	 * 玩家移动
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		// 远程攻击时禁止移动
		aForward = 0;
		aStrafe = 0;

		Super.PlayerMove(DeltaTime);
	}
	
	event TargetDead()
	{
	}
	
	/**
	 * 切换装备状态
	 */
	exec function ToggleArmState()
	{
		if (!bIsActing)
			Super.ToggleArmState();
	}
}


/**
 * 拾取状态
 * 处理玩家拾取物品时的行为
 */
state Picking extends Approaching
{
	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 是否可以停止
	 */
	function bool CanStop(float Distance) 
	{ 
		return Distance < 100 + InteractTo.CollisionRadius; 
	}
	
	/**
	 * 达到目标（拾取物品）
	 */
	function AchieveGoal()
	{
		local Attachment Item;
		Item = Attachment(InteractTo);
		
		if (Item != None && !Item.bDeleteMe)
		{
			// 如果是金钱，直接拾取
			if (Item.IsA('Money'))
			{
				Net.NotiPickUpMoney(Item.Info.PanID);
			}
			else if ( Item.Info != None )
			{
				// 如果是封印物品，显示确认对话框
				if ( Item.Info.xSealFlag == Item.Info.eSEALFLAG.SF_USED )
				{
					class'CMessageBox'.Static.MessageBox(CMultiInterface(myHud), "Sealed Item", Localize("Modals", "PickupSealedItem", "Sephiroth"), MB_YesNo, IDM_SEALEDITEM);
				}
				else
				{
					// 普通物品直接拾取
					Net.NotiPickupItem(Item.Info.PanID);
				}
			}
		}

		InteractTo = None;
		GotoState('Navigating');
	}
Pick:
	AchieveGoal();
}

function bool IsTalking();	// 是否正在对话

/**
 * 对话状态
 * 处理玩家与NPC对话时的行为
 */
state Talking extends Approaching
{
	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 是否可以停止
	 */
	function bool CanStop(float Distance) 
	{ 
		return Distance < InteractTo.CollisionRadius + 500; 
	}
	
	/**
	 * 达到目标（开始对话）
	 */
	function AchieveGoal()
	{
		// 如果是NPC且可以对话，发送对话请求
		if (CanTalk(InteractTo) && Npc(InteractTo) != None && !IsTalking()) 
		{
			Net.NotiNpcDialog(ServerController(Npc(InteractTo).Controller).MSI.PanID, "");
		}
		// 如果是玩家角色
		else if (CanTalk(InteractTo) && Hero(InteractTo) != None)
		{
			// 如果是摊位卖家，询问是否访问摊位
			if( ClientController(Hero(InteractTo).Controller).PSI.IsBoothSeller() )
				AskBoothVisit(Hero(InteractTo));
			else
				// 否则打开玩家菜单
				OpenXMenu(Hero(InteractTo));
		}
		ForceFinishInteraction(InteractTo);

		InteractTo = None;
		GotoState('Navigating');
	}
	
	/**
	 * 落地处理
	 * @param HitNormal 碰撞法线
	 */
	function Landfloor(vector HitNormal) 
	{ 
	}
Talk:
	AchieveGoal();
}

function ForceFinishInteraction(actor Actor);	// 强制完成交互

function OpenXMenu(Hero Hero);		// 打开玩家菜单
function AskBoothVisit(Hero Hero);	// 询问访问摊位

/**
 * 模态状态
 * 处理模态对话框时的行为
 */
state Modal extends PlayerWalking
{
	ignores KeyboardMove;	// 忽略键盘移动
	
	/**
	 * 状态开始
	 */
	function BeginState()
	{
		Character(Pawn).CHAR_TweenToWaiting(0.3);
	}
	
	/**
	 * 玩家移动
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		// 模态状态下禁止移动
		aForward = 0;
		aStrafe = 0;
		Super.PlayerMove(DeltaTime);
	}
}

/**
 * 是否为测试模式
 * @return 是否测试模式
 */
function bool IsTest()
{
	return False;
}


/**
 * 初始化输入系统
 * 创建各种管理器
 */
event InitInputSystem()
{
	Super.InitInputSystem();
	if ( bIsPlayer && !IsA('PC_Lobby') ) 
	{
		// 创建队伍管理器
		PartyMgr = new(Self) class'PartyManager';
		PartyMgr.PlayerOwner = Self;
		PartyMgr.Init();
		// 创建技能帧管理器
		SkillFrame = new(Self) class'SkillFrame';
		
		// 创建好友管理器
		BuddyMgr = new(Self) class'BuddyManager';
		
		// 创建公会管理器
		ClanManager = new(Self) class'ClanManager';
	}
}

/**
 * 游戏开始后调用
 * 初始化摄像机视角
 */
function PostBeginPlay()
{
	Super.PostBeginPlay();

	bBehindView = True;
	SetViewTarget(Pawn);

	// 根据配置设置视角类型
	if ( bIsPlayer && Level.Game.IsA('GameManager') ) 
	{
		switch (int(ConsoleCommand("GETOPTIONI ViewType"))) 
		{
			case 0: SetFirstPersonView(); break;
			case 1: SetBehindFreeView(); break;
			case 2: SetQuaterView(); break;
		}
	}

	// 创建附魔盒
	EnchantBox = class'EnchantBox'.Static.Create(Self, Self);
}

/**
 * 销毁时调用
 * 清理所有资源
 */
function Destroyed()
{
	Super.Destroyed();

	// 清空动作池
	ActionPool.Remove(0,ActionPool.Length);

	if ( Player != None ) 
	{
		// 卸载各种管理器
		DynamicUnloadObject(PartyMgr);
		DynamicUnloadObject(SkillFrame);
		DynamicUnloadObject(BuddyMgr);
		DynamicUnloadObject(ClanManager);
		
		// 销毁镜头光晕特效
		DestroyLenzFlareEffect();
	}

	// 卸载附魔盒
	DynamicUnloadObject(EnchantBox);
	EnchantBox = None;
}

/**
 * 切换视角
 * 在不同视角类型之间切换
 */
function ToggleView()
{
	switch (int(ConsoleCommand("GETOPTIONI ViewType"))) 
	{
		case 0: SetQuaterView(); break;
		case 1: SetFirstPersonView(); break;
		case 2: SetBehindFreeView(); break;
	}
}

/**
 * 计算第一人称视角
 * @param CameraLocation 摄像机位置（输出）
 * @param CameraRotation 摄像机旋转（输出）
 */
function CalcFirstPersonView(out vector CameraLocation, out rotator CameraRotation)
{
	local int V;

	// 如果摄像机未设置，根据配置设置
	if ( bIsPlayer && !bCameraSet ) 
	{
		V = int(ConsoleCommand("GETOPTIONI ViewType"));
		switch (V) 
		{
			case 0: SetFirstPersonView(); break;
			case 1: SetBehindFreeView(); break;
			case 2: SetQuaterView(); break;
		}
		bCameraSet = True;
	}

	// 设置摄像机旋转和位置
	CameraRotation = Rotation;
	CameraLocation = CameraLocation + Pawn.EyePosition() + ShakeOffset;
}

/**
 * 计算背后视角
 * @param CameraLocation 摄像机位置（输出）
 * @param CameraRotation 摄像机旋转（输出）
 * @param Dist 距离
 */
function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local actor HitActor;
	local float ViewDist;

	
	if ( bIsPlayer && !bCameraSet ) 
	{
		switch (int(ConsoleCommand("GETOPTIONI ViewType"))) 
		{
			case 0: SetFirstPersonView(); break;
			case 1: SetBehindFreeView(); break;
			case 2: SetQuaterView(); break;
		}
		bCameraSet = True;
	}

	// 调整摄像机高度
	if ( ZSI == None || !ZSI.bUnderSiege || !bBehindView ) 
	{
		if ( bBehindView )
			CameraLocation.Z += CameraHeight;
		else if (Pawn != None)
			CameraLocation.Z += Pawn.EyeHeight;
	}

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	// 追踪摄像机前方是否有障碍物
	HitActor = Trace(HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation);
	if ( HitActor != None ) 
	{
		// 如果追踪到的Actor改变，移除旧Actor的样式
		if ( CameraTraceActor != None && HitActor != CameraTraceActor ) 
		{
			CameraTraceActor.RemoveStyle();
			CameraTraceActor = None;
		}
		// 如果是可透明化的静态网格（树木、石头等）
		if ( HitActor.IsA('StaticMeshActor') && (InStr(HitActor.Group, "Invis") != -1 || InStr(HitActor.Group, "invis") != -1 || InStr(HitActor.Group, "tree") != -1 || InStr(HitActor.Group, "stoneweed") != -1) ) 
		{
			if ( HitActor != CameraTraceActor ) 
			{
				CameraTraceActor = HitActor;
				CameraTraceActor.CreateStyle();
				CameraTraceActor.AdjustAlphaFade(100);
			}
			// 再次追踪检查是否完全遮挡
			if ( TraceEx(HitLocation, HitNormal, TCST_Reserved3, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation) != None )
				ViewDist = FMin((CameraLocation - HitLocation) Dot View, Dist);
			else
				ViewDist = Dist;
		}
		else 
		{
			// 如果是地形，使用完整距离
			if ( HitActor.IsA('TerrainInfo') )
				ViewDist = Dist;
			else
				ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );

			// 根据法线方向调整距离
			if ( HitNormal.Z >= 0 ) 
			{
				ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
			}
			else 
			{
				// 如果法线向下，减少距离避免穿透
				if ( HitActor.IsA('TerrainInfo') )
					ViewDist = Dist;
				else 
				{
					ViewDist = FMin((CameraLocation - HitLocation) Dot View, Dist) - 30;
				}
			}
		}
	}
	else 
	{
		// 没有障碍物，移除透明Actor样式
		if ( CameraTraceActor != None ) 
		{
			CameraTraceActor.RemoveStyle();
			CameraTraceActor = None;
		}
		ViewDist = Dist;
	}
	// 根据计算的距离调整摄像机位置
	CameraLocation -= (ViewDist - 30) * View;
	// 应用摄像机偏移
	if ( ZSI == None || !ZSI.bUnderSiege || !bBehindView ) 
	{
		if ( CameraBias != 0 )
			CameraLocation += CameraBias * vect(0,1,0) >> CameraRotation;
	}
}

/**
 * 玩家计算视图
 * 计算玩家视角
 * @param ViewActor 视图Actor（输出）
 * @param CameraLocation 摄像机位置（输出）
 * @param CameraRotation 摄像机旋转（输出）
 */
event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
	// 更新控制器位置和旋转
	SetLocation(CameraLocation);
	SetRotation(CameraRotation);
}

/**
 * 控制Pawn
 * 当控制器开始控制一个Pawn时调用
 * @param aPawn 要控制的Pawn
 */
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	GotoState('Navigating');
	if ( Player != None ) 
	{
		Player.GameState = Player.GM_Normal;
		ConsoleCommand("CHECKCURSOR");
	}
}

/**
 * 追踪并检查命中
 * 从鼠标位置追踪并检查是否命中目标
 * @param TR 追踪结果（输出）
 * @param DirectionalScale 方向缩放
 * @param Situation 追踪调用情况
 * @param bTraceMe 是否追踪自身（可选）
 */
function TraceAndCheckHit(out TraceResult TR, float DirectionalScale, ETraceCallSituation Situation,optional bool bTraceMe)
{
	local vector ViewOrigin, Direction, MousePos;
	ViewOrigin = Location;
	// 获取鼠标位置
	MousePos.X = Player.WindowsMouseX;
	MousePos.Y = Player.WindowsMouseY;
	// 将屏幕坐标转换为世界方向
	Direction = Player.Console.ScreenToWorld(MousePos);
	// 执行追踪
	TR.Actor = TraceEx(TR.Location,TR.Normal,Situation,ViewOrigin + DirectionalScale * Direction,ViewOrigin,True);
	TR.Direction = Rotator(Direction);
}

/**
 * 旋转到摄像机方向
 * 将Pawn旋转到摄像机朝向
 */
exec function RotateToCamera()
{
	local rotator Rot;
	if ( Pawn != None ) 
	{
		Rot = Pawn.Rotation;
		// 如果摄像机反转，调整偏航角
		if ( bCameraReversed )
			Rot.Yaw = (Rotation.Yaw + 32768) % 65536;
		else
			Rot.Yaw = Rotation.Yaw;
		Pawn.SetRotation(Rot);
	}
}

/**
 * 设置体力值
 * 根据玩家状态更新体力值
 * @param DeltaTime 时间增量
 */
function SetStamina(float DeltaTime)
{
	local Hero Hero;

	Hero = Hero(Pawn);
	if ( Hero != None && PSI != None ) 
	{
		// 如果是上帝模式或透明模式，体力满值
		if ( bGodMode || IsTransparent() )
			PSI.Stamina = PSI.MaxStamina;
		else 
		{
			// 如果跳跃或奔跑，消耗体力
			if ( ZSI != None && !ZSI.bNoStamina && (Hero.IsJumping() || Hero.IsRunning()) ) 
				PSI.Stamina -= DeltaTime;
			// 如果行走，缓慢恢复体力
			else if (Hero.IsWalking())
				PSI.Stamina += (0.5 + PSI.PlayLevel / 80 + float(PSI.Str) / 400. + float(PSI.Vigor) / 200.) * DeltaTime;
			// 如果静止，快速恢复体力
			else
				PSI.Stamina += (1 + PSI.PlayLevel / 40 + float(PSI.Str) / 200. + float(PSI.Vigor) / 100.) * DeltaTime;

			// 如果体力耗尽，设置为0
			if( PSI.IsSTMBreak() ) 
				PSI.Stamina = 0;

			// 限制体力值范围
			if ( PSI.Stamina < 0 ) PSI.Stamina = 0;
			if ( PSI.Stamina > PSI.MaxStamina ) PSI.Stamina = PSI.MaxStamina;
			// 如果体力为0且正在奔跑，强制切换为行走
			if ( PSI.Stamina == 0. && PSI.RunState ) 
			{
				bForceToWalk = True;
				ToggleRunState();
			}
			// 如果体力恢复到10且之前被强制行走，恢复奔跑
			if ( PSI.Stamina >= 10 && !PSI.RunState && bForceToWalk ) 
			{
				bForceToWalk = False;
				ToggleRunState();
			}
		}
	}
}

/**
 * 玩家Tick
 * 每帧调用，更新冷却时间和体力
 * @param DeltaTime 时间增量
 */
function PlayerTick(float DeltaTime)
{
	// 更新冷却时间
	if ( CoolTime > 0 )
	{
		CoolTime -= DeltaTime;

		// 避免浮点数精度问题
		if( CoolTime == 0.0 ) 
			CoolTime = -0.01;
	}

	// 如果是玩家角色且存活，调用父类Tick并更新体力
	if ( Pawn != None && !Character(Pawn).bIsDead && Character(Pawn).IsAvatar() ) 
	{
		Super.PlayerTick(DeltaTime);
		SetStamina(DeltaTime);
	}
	else
		PlayerMove(DeltaTime);
}

function ClientUpdatePosition() 
{
}

/**
 * 处理行走状态
 * 根据运行状态设置Pawn的行走标志
 */
function HandleWalking()
{
	if ( Pawn != None && PSI != None )
		Pawn.SetWalking(!PSI.RunState);
}

/**
 * 生成动作特效
 * @param Skill 技能对象
 */
function SpawnActionEffect(Skill Skill)
{
	local Hero Hero;
	Hero = Hero(Pawn);

	if ( Hero != None && Skill != None ) 
	{
		if ( Hero.Attachments[Hero.AT_RightHand] != None ) 
		{
			Hero.Attachments[Hero.AT_RightHand].TraceMaterial = Skill.EffectMaterial;
			Hero.Attachments[Hero.AT_RightHand].SpawnActionEffect();
		}
		else if (Hero.Attachments[Hero.AT_BothHand] != None) 
		{
			Hero.Attachments[Hero.AT_BothHand].TraceMaterial = Skill.EffectMaterial;
			Hero.Attachments[Hero.AT_BothHand].SpawnActionEffect();
		}
	}
}

/**
 * 销毁动作特效
 */
function DestroyActionEffect()
{
	local Hero Hero;
	Hero = Hero(Pawn);

	if ( Hero != None ) 
	{
		if ( Hero.Attachments[Hero.AT_RightHand] != None )
			Hero.Attachments[Hero.AT_RightHand].DestroyActionEffect();
		if ( Hero.Attachments[Hero.AT_BothHand] != None )
			Hero.Attachments[Hero.AT_BothHand].DestroyActionEffect();
		Hero.HideAfterImage();
	}
}

event ActionEnd(bool bTweenToIdle,float TweenTime);
function HitDetect(name Bone, optional bool bApplyHitEffect);

/**
 * 远程攻击命中检测
 * @param HitActor 被命中的对象
 * @param HitLocation 命中位置
 * @param SkillName 技能名称
 * @param ActionID 动作ID
 */
function RangeHit_Detected(actor HitActor, vector HitLocation, string SkillName, int ActionID)
{
	local int Seq, PanID;
	
	local Skill Skill;
	Skill = QuerySkillByName(SkillName);
	

	// 处理幻影火焰技能
	if( SkillName == "PhantomFire" ) 
	{
		if ( Character(HitActor) != None && (Character(HitActor).bIsDead || HitActor.bDeleteMe) )
			return;

		if ( Character(Pawn).IsAvatar() )
		{
			Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Pull);
			// 获取目标ID
			if ( Hero(HitActor) != None )
				PanID = ClientController(Hero(HitActor).Controller).PSI.PanID;
			else
				PanID = 0;

			// 如果是第二技能，发送第二技能命中消息
			if( Skill.IsA('SecondSkill') )
				Net.NotiSkill2ndHit(Skill.SkillName, PanID, HitLocation);
		}
	}
	else
	{
		Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Fire);
		// 检查目标有效性
		if ( Character(HitActor) == None || Character(HitActor).bIsDead || HitActor.bDeleteMe )
			return;
		// 获取目标ID
		if ( Hero(HitActor) != None )
			PanID = ClientController(Hero(HitActor).Controller).PSI.PanID;
		else if (Creature(HitActor) != None)
			PanID = ServerController(Creature(HitActor).Controller).MSI.PanID;
		else
			PanID = 0;
		
		// 如果是第二技能
		if( Skill.IsA('SecondSkill') )
		{
			// 根据技能类型选择目标位置
			if( SecondSkill(Skill).SkillType == 4 )
			{
				Net.NotiSkill2ndHit(Skill.SkillName, PanID, SecondSkillTarget.Location);
			}
			else
			{
				Net.NotiSkill2ndHit(Skill.SkillName, PanID, HitLocation);
			}
		}
		// 普通魔法技能
		else
			Net.NotiHitMagic(ActionID,Pawn.Location,PanID,HitLocation);
	}
}






/**
 * 摊位出售状态
 * 玩家在摊位出售物品时的状态，禁止移动、攻击等操作
 */
state BoothSelling extends Approaching
{
	// 忽略的操作：禁止键盘移动、各种移动操作、攻击、拾取、追踪、社交动画、跳跃
	ignores KeyboardMove,
	MovePawnToMove,
	MovePawnToTalk,
	MovePawnToAttackMelee,
	MovePawnToPick,
	MovePawnToTrace,
	MovePawnToAttackRange,
	MovePawnToAttackBow,
	FindNearestItem,
	PlaySocialAnim,
	Jump;

	/**
	 * 状态开始
	 * 初始化摊位出售状态
	 */
	function BeginState()
	{
		// 停止所有移动
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
		bPressedJump = False;
		// 播放坐下动画
		Character(Pawn).CHAR_PlayAnim('SitDown',1,0.3);
		// 设置随机定时器（0-60秒），用于叫卖动画
		SetTimer(Rand(60), False);

		// 设置角色为坐下状态
		if( Character(Pawn) != None )
			Character(Pawn).bIsSit = True;

		// 如果装备了武器，卸下武器
		if( PSI != None && PSI.ArmState )
			ToggleArmState();
		// 如果开启了PK状态，关闭PK状态
		if( PSI != None && PSI.PkState )
			TogglePkState();
	}
	
	/**
	 * 定时器回调
	 * 处理摊位叫卖动画的循环播放
	 */
	function Timer()
	{
		// 如果角色已死亡，停止定时器
		if( Character(Pawn).bIsDead )
		{
			SetTimer(0, False);
			return ;
		}

		// 初始化叫卖计数
		if( BoothToutCount == -1 )
		{
			// 设置每60秒触发一次的定时器
			SetTimer(60, True);
			BoothToutCount = 0;
		}
		else
		{
			// 如果启用了叫卖功能，播放站起动画
			if( Pawn != None && PSI != None && PSI.bUseTout )
				Character(Pawn).CHAR_PlayAnim('SitUp',1,0.3);

			// 根据叫卖计数选择不同的叫卖动画
			if( BoothToutCount < 7 )
			{
				if( BoothToutCount == 0 )
					ToutName = 'CharmingHi';		// 迷人打招呼
				else if( BoothToutCount == 1 )
					ToutName = 'YooHoo';			// 哟呵
				else if( BoothToutCount == 2 )
					ToutName = 'DullTime';		// 无聊时光
				else if( BoothToutCount == 3 )
					ToutName = 'Hi';				// 打招呼
				else if( BoothToutCount == 4 )
					ToutName = 'Anger';			// 生气
				else if( BoothToutCount == 5 )
					ToutName = 'Choicechoice';	// 选择
				else if( BoothToutCount == 6 )
					ToutName = 'Skydance';		// 天空之舞
				BoothToutCount++;
			}
			else
			{
				// 循环到第8个动画后重置
				ToutName = 'LoveYou';			// 爱你
				BoothToutCount = 0;
			}
		}
	}
	
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel)
	{
		local name AnimName;
		local float AnimFrame, AnimRate;

		Pawn.GetAnimParams(0, AnimName, AnimFrame, AnimRate);
		
		// 处理叫卖动画的循环播放
		if( Pawn != None && Character(Pawn) != None && !Character(Pawn).bIsDead )
		{
			// 如果站起动画结束，播放叫卖动画
			if( AnimName == 'SitUp' )
				Pawn.PlayAnim(ToutName, 1, 0.3);
			// 如果叫卖动画结束，播放坐下动画
			else if( AnimName != 'SitDown' && AnimName != 'IdleSit' )
				Character(Pawn).CHAR_PlayAnim('SitDown',1,0.3);
			// 如果坐下动画结束，播放待机动画
			else if( AnimName == 'SitDown' )
				Character(Pawn).CHAR_PlayWaiting();
		}
	}
	
	/**
	 * 受伤事件
	 * 摊位出售状态下忽略受伤
	 * @param Attacker 攻击者
	 * @param Skill 使用的技能
	 * @param bPain 是否疼痛
	 * @param bKnockback 是否击退
	 * @param bCritical 是否暴击
	 * @param bMiss 是否未命中
	 * @param bBlock 是否格挡
	 * @param bImmune 是否免疫
	 */
	event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune) 
	{
		// 摊位出售状态下不受伤害
	}
	
	/**
	 * 玩家移动
	 * 摊位出售状态下禁止移动，只允许摄像机旋转
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime) 
	{
		local rotator OldRotation, ViewRotation;

		// 禁止所有移动
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
		bPressedJump = False;

		// 处理摄像机俯仰角
		GroundPitch = 0;
		ViewRotation = Rotation;
		if ( Pawn.Physics == PHYS_Walking )
		{
			// 如果不在观察状态且满足条件
			if ( (bLook == 0)
				&& (((Pawn.Acceleration != Vect(0,0,0)) && bAlwaysLevel && bSnapToLevel) || !bKeyboardLook) )
			{
				// 如果启用楼梯观察或对齐到水平
				if ( bLookUpStairs || bSnapToLevel )
				{
					GroundPitch = FindStairRotation(deltaTime);
					ViewRotation.Pitch = GroundPitch;
				}
				// 如果启用中心视图，平滑调整俯仰角
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					// 平滑衰减俯仰角
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}
		}
		else
		{
			// 非行走状态下的俯仰角处理
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;
			}
		}
		
		// 应用旋转
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);
	}
	
	/**
	 * 状态结束
	 * 清理摊位出售状态
	 */
	function EndState()
	{
		// 恢复角色状态
		if( Pawn != None && Character(Pawn) != None )
		{
			Character(Pawn).bIsSit = False;
			// 如果角色存活，播放待机和站起动画
			if( PSI.bIsAlive )
			{
				Character(Pawn).CHAR_PlayWaiting();
				Character(Pawn).CHAR_PlayAnim('SitUp',1,0.3);
			}
		}
		// 停止定时器并重置叫卖计数
		SetTimer(0, False);
		BoothToutCount = -1;
	}
}

/**
 * 曾经摊位出售状态
 * 摊位出售状态的子状态，用于特殊动画帧设置
 */
state WasBoothSelling extends BoothSelling
{
	/**
	 * 状态开始
	 * 设置动画帧到100
	 */
	function BeginState()
	{
		Super.BeginState();
		// 设置动画帧到100（用于特殊显示效果）
		SetAnimFrame(100);
	}
}

/**
 * 摊位访问状态
 * 玩家访问其他玩家摊位时的状态，禁止移动和攻击
 */
state BoothVisiting
{
	// 忽略的操作：禁止键盘移动、各种移动操作、攻击、拾取、追踪、社交动画、跳跃
	ignores KeyboardMove,
	MovePawnToMove,
	MovePawnToTalk,
	MovePawnToAttackMelee,
	MovePawnToPick,
	MovePawnToTrace,
	MovePawnToAttackRange,
	MovePawnToAttackBow,
	FindNearestItem,
	PlaySocialAnim,
	Jump;

	/**
	 * 状态开始
	 * 初始化摊位访问状态
	 */
	function BeginState()
	{
		// 停止所有移动
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
		bPressedJump = False;
	}
	
	/**
	 * 玩家移动
	 * 摊位访问状态下禁止移动，只允许摄像机旋转
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		local rotator OldRotation, ViewRotation;

		// 禁止所有移动
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
		bPressedJump = False;

		// 处理摄像机俯仰角
		GroundPitch = 0;
		ViewRotation = Rotation;
		if ( Pawn.Physics == PHYS_Walking )
		{
			// 如果不在观察状态且满足条件
			if ( (bLook == 0)
				&& (((Pawn.Acceleration != Vect(0,0,0)) && bAlwaysLevel && bSnapToLevel) || !bKeyboardLook) )
			{
				// 如果启用楼梯观察或对齐到水平
				if ( bLookUpStairs || bSnapToLevel )
				{
					GroundPitch = FindStairRotation(deltaTime);
					ViewRotation.Pitch = GroundPitch;
				}
				// 如果启用中心视图，平滑调整俯仰角
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					// 平滑衰减俯仰角
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}
		}
		else
		{
			// 非行走状态下的俯仰角处理
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;
			}
		}
		
		// 应用旋转
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

	}
	
	/**
	 * 状态结束
	 * 清理摊位访问状态
	 */
	function EndState() 
	{
		// 无特殊清理操作
	}
	
	/**
	 * 更新旋转
	 * 处理摄像机追踪功能
	 * @param DeltaTime 时间增量
	 * @param maxPitch 最大俯仰角
	 */
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local int camera_yaw;
		local Rotator Rot;

		Super.UpdateRotation(DeltaTime,maxPitch);
		// 如果启用了摄像机追踪
		if (bool(ConsoleCommand("GETOPTIONI TraceCamera"))) 
		{
			if (!bKeyboardMove) 
			{ 
				// 计算摄像机偏航角差值
				camera_yaw = Rotation.Yaw - Rotator(Destination - Pawn.Location).Yaw;
				camera_yaw = camera_yaw % 65536;
				// 规范化角度到-32768到32768范围
				if( camera_yaw < -32768 ) camera_yaw = camera_yaw + 65536;
				else if( camera_yaw > 32768 ) camera_yaw = camera_yaw - 65536;
				// 如果角度差在合理范围内，平滑调整摄像机
				if( camera_yaw > -7000 && camera_yaw < 7000 ) 
				{
					rot = Rotation;
					// 根据角度差和方向调整偏航角（使用幂函数实现平滑过渡）
					if( camera_yaw < -50 ) rot.Yaw = Rotation.Yaw + abs(camera_yaw) ** 0.6 * 1.15 * DeltaTime / 0.05;
					else if( camera_yaw > 50 ) rot.Yaw = Rotation.Yaw - abs(camera_yaw) ** 0.6 * 1.15 * DeltaTime / 0.05;
					SetRotation(rot);

				}
			}
		}
	}
}



/**
 * 玩家刚死亡
 * 玩家死亡时的回调函数
 */
function PlayerJustDead();

/**
 * 刚死亡状态
 * 玩家死亡后的短暂状态，播放死亡动画并等待3秒后触发死亡事件
 */
state JustDead
{
	// 忽略键盘移动和跳跃
	ignores KeyboardMove, Jump;
	
	/**
	 * 状态开始
	 * 初始化死亡状态
	 */
	function BeginState()
	{
		// 调用玩家刚死亡回调
		PlayerJustDead();
		// 播放死亡动画
		Character(Pawn).CHAR_PlayAnim('Die',1,0.3);
		// 设置3秒定时器，用于触发死亡事件
		SetTimer(3,False);
	}
	
	/**
	 * 动画结束事件
	 * @param Channel 动画通道
	 */
	function AnimEnd(int Channel) 
	{
		// 死亡状态下不处理动画结束
	}
	
	/**
	 * 定时器事件
	 * 3秒后触发死亡事件
	 */
	event Timer()
	{
		// 通知网络接收死亡事件
		NetRecv_Dead();
	}
	
	/**
	 * 受伤事件
	 * 死亡状态下忽略受伤
	 * @param Attacker 攻击者
	 * @param Skill 使用的技能
	 * @param bPain 是否疼痛
	 * @param bKnockback 是否击退
	 * @param bCritical 是否暴击
	 * @param bMiss 是否未命中
	 * @param bBlock 是否格挡
	 * @param bImmune 是否免疫
	 */
	event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune) 
	{
		// 死亡状态下不受伤害
	}
	
	/**
	 * 玩家移动
	 * 死亡状态下禁止移动，确保播放死亡动画
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		local name AnimName;
		local float AnimFrame, AnimRate;

		// 禁止所有移动
		Pawn.Acceleration = vect(0,0,0);
		aForward = 0;
		aStrafe = 0;
		bPressedJump = False;
		Global.PlayerMove(DeltaTime);

		// 确保始终播放死亡动画
		Pawn.GetAnimParams(0, AnimName, AnimFrame, AnimRate);
		if(AnimName != 'Die')
			Character(Pawn).CHAR_PlayAnim('Die',1,0.3);
	}
}

/**
 * 网络接收死亡事件
 * @param bVanished 是否消失
 */
event NetRecv_Die(bool bVanished)
{
	GotoState('JustDead');
}

/**
 * 网络接收死亡
 * 处理玩家死亡后的网络同步
 */
function NetRecv_Dead();



/**
 * 显示调试信息
 * 在调试模式下显示玩家状态信息
 * @param Canvas 画布对象
 * @param YL 行高
 * @param YPos Y位置（输出）
 */
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float Difference;
	local vector vDiff;
	Super.DisplayDebug(Canvas, YL, YPos);

	// 设置黄色文字
	Canvas.SetDrawColor(255,255,0);
	// 计算目标位置与当前位置的2D距离差
	vDiff = Destination - Pawn.Location;
	vDiff.Z = 0;
	Difference = VSize(vDiff);
	Canvas.DrawText("Destination: "$Destination$" Difference: "$Difference);
	YPos += YL;

	// 显示技能信息
	if ( PSI.Combo != None )	T = T$" Combo Skill: "$PSI.Combo.SkillName$"("$ComboCount$")";
	if ( PSI.Finish != None )	T = T$" Finish Skill: "$PSI.Finish.SkillName;
	if ( PSI.Magic != None )	T = T$" Magic Skill: "$PSI.Magic.SkillName;
	if ( NextSkill != None )	T = T$" Next Skill: "$NextSkill.SkillName;
	if ( T != "" ) 
	{
		Canvas.DrawText(T);
		YPos += YL;
	}
	// 显示当前技能和动作完成状态
	if ( ThisSkill != None )
		T = " This Skill: "$ThisSkill.SkillName$" bIsActingFinish: "$bIsActingFinish;
	else
		T = " This Skill: None"$" bIsActingFinish: "$bIsActingFinish;
	Canvas.DrawText(T);
	YPos += YL;

	// 显示其他调试信息
	Canvas.DrawText("LockedTarget: "$LockedTarget); YPos += YL;
	Canvas.DrawText("CameraTraceActor: "$CameraTraceActor); YPos += YL;
	Canvas.DrawText("bJustDamaged: "$Character(Pawn).bJustDamaged); YPos += YL;
	Canvas.DrawText("PlayerSpeed: "$Pawn.GroundSpeed); YPos += YL;
}

/**
 * 网络接收玩家移动
 * 从服务器接收玩家移动同步数据
 * @param Loc 位置
 * @param Rot 旋转
 * @param Acc 加速度
 * @param bJump 是否跳跃
 * @param JumpZ 跳跃力度
 */
event NetRecv_PlayerMove(vector Loc,rotator Rot,vector Acc,bool bJump,float JumpZ)
{
	local Rotator CRot;
	local vector vDiff;
	local float Distance2D;
	local float SpeedMultiplier;
	local vector NewLocation;

	// 设置期望旋转
	DesiredRotation = Rot;
	// 更新Pawn的旋转（只更新偏航角）
	CRot = Pawn.Rotation;
	CRot.Yaw = Rot.Yaw;
	Pawn.SetRotation(CRot);
	Pawn.bRotateToDesired = False;

	// 如果服务器通知跳跃
	if ( bJump ) 
	{
		Character(Pawn).bJustDamaged = False;  
		Pawn.Acceleration = Acc;
		Pawn.JumpZ = JumpZ;
		Pawn.DoJump(True);
	}

	// 位置同步加速追赶处理（仅用于其他玩家角色）
	if ( Pawn != None && !Character(Pawn).IsAvatar() )
	{
		if ( SyncCloseDistance == 0 )
			SyncCloseDistance = 30.0;
		
		// 计算当前位置与服务器位置的2D距离
		vDiff = Loc - Pawn.Location;
		vDiff.Z = 0;
		Distance2D = VSize(vDiff);
		
		//("NetRecv_PlayerMove Distance2D: "$Distance2D);

		// 根据距离设置速度倍数（分段线性加速）
		if ( Distance2D > 3000.0 ) 
		{
			// 距离非常大，直接瞬移到服务器位置
			NewLocation = Loc;
			NewLocation.Z = Pawn.Location.Z;  // 保持Z轴
			Pawn.SetLocation(NewLocation);
			bSyncingPosition = False;
			SpeedMultiplier = 1.0;
		}
		else if ( Distance2D > 2000.0 )
		{
			// 2000-3000: 10-20倍线性加速
			// SpeedMultiplier = 10.0 + ((Distance2D - 2000.0) / 1000.0) * (20.0 - 10.0)
			SpeedMultiplier = 10.0 + (Distance2D - 2000.0) / 1000.0 * 10.0;
			bSyncingPosition = True;
		}
		else if ( Distance2D > 1000.0 )
		{
			// 1000-2000: 5-10倍线性加速
			// SpeedMultiplier = 5.0 + ((Distance2D - 1000.0) / 1000.0) * (10.0 - 5.0)
			SpeedMultiplier = 5.0 + (Distance2D - 1000.0) / 1000.0 * 5.0;
			bSyncingPosition = True;
		}
		else if ( Distance2D > 500.0 )
		{
			// 500-1000: 3-5倍线性加速
			// SpeedMultiplier = 3.0 + ((Distance2D - 500.0) / 500.0) * (5.0 - 3.0)
			SpeedMultiplier = 3.0 + (Distance2D - 500.0) / 500.0 * 2.0;
			bSyncingPosition = True;
		}
		else if ( Distance2D > 0.0 )
		{
			// 0-500: 1-3倍线性加速
			// SpeedMultiplier = 1.0 + (Distance2D / 500.0) * (3.0 - 1.0)
			SpeedMultiplier = 1.0 + Distance2D / 500.0 * 0.5;
			bSyncingPosition = True;
		}


		//DebugLog("NetRecv_PlayerMove SpeedMultiplier: "$SpeedMultiplier);
		
		// 保存原始速度（如果还没有保存）
		if ( OriginalGroundSpeed == 0 && Character(Pawn).CurrentGroundSpeed > 0 )
			OriginalGroundSpeed = Character(Pawn).CurrentGroundSpeed;
		
		// 应用速度倍数
		if ( bSyncingPosition && OriginalGroundSpeed > 0 )
		{
			SyncSpeedMultiplier = SpeedMultiplier;
			Pawn.GroundSpeed = OriginalGroundSpeed * SpeedMultiplier;
		}
		else if ( !bSyncingPosition && OriginalGroundSpeed > 0 )
		{
			// 恢复正常速度
			Pawn.GroundSpeed = OriginalGroundSpeed;
			OriginalGroundSpeed = 0;  // 重置，下次需要时重新保存
		}
		
		// 更新上次同步位置，用于卡地形检测
		LastSyncLocation = Pawn.Location;
		StuckCheckTime = 0;  // 重置卡住检测时间
	}
	else
	{
		// 玩家自己，不使用同步加速
		bSyncingPosition = False;
	}

	// 根据当前状态处理移动
	if ( IsInState('Attacking') ) 
	{
		// 攻击状态下移动到目标位置
		Destination = Loc;
		HandleWalking();

		//DebugLog("NetRecv_PlayerMove else "@GetStateName());
		// 其他攻击状态（如 MeleeAttacking）有 Move 标签，可以切换
		GotoState(GetStateName(), 'Move');
		
	}
	else if (IsInState('BoothSelling')) 
	{
		// 摊位出售状态下只更新位置，不移动
		Destination = Loc;
	}
	else if(PSI.CheckBuffDontAct()) 
	{
		// Buff禁止行动状态下只更新位置
		Destination = Loc;
	}
	else 
	{
		// 正常状态下移动到目标位置
		Destination = Loc;
		HandleWalking();
		GotoState('Navigating', 'Move');
	}
}

// 网络接收连接相关事件
event NetRecv_ConnectResult(string Result);			// 连接结果
event NetRecv_LoginResult(string Result, int Reason);	// 登录结果
event NetRecv_BanchLoginResult(string Result, int Reason);	// 分支登录结果
event NetRecv_NewCharacterResult(string Result);		// 创建角色结果
event NetRecv_DeleteCharacterResult(string Result);		// 删除角色结果
event NetRecv_StartPlayResult(string Result);			// 开始游戏结果
event NetRecv_Disconnected(string Result);				// 断开连接
event NetRecv_DisconnectError(string Result);			// 断开连接错误

/**
 * 网络接收玩家模式改变
 * 从服务器接收玩家状态模式改变通知
 * @param ModeName 模式名称（Arm/Disarm/HideHelmet/Run/Walk/PK/NotPK）
 */
event NetRecv_PlayerModeChange(string ModeName)
{
	// 根据模式名称执行相应操作
	if ( ModeName == "Arm" ) Hero(Pawn).Arm();				// 装备武器
	else if (ModeName == "Disarm") Hero(Pawn).Disarm();		// 卸下武器
	else if (ModeName == "HideHelmet") Hero(Pawn).HideHelmet();	// 隐藏头盔
	else if (ModeName == "Run") Pawn.SetWalking(False);		// 奔跑模式
	else if (ModeName == "Walk") Pawn.SetWalking(True);		// 行走模式
	else if (ModeName == "PK") ;								// PK模式（空实现）
	else if (ModeName == "NotPK") ;							// 非PK模式（空实现）
}


/**
 * 网络接收玩家动画
 * 从服务器接收其他玩家的动画播放通知
 * @param sName 动画名称（字符串）
 */
event NetRecv_PlayerAnimation(string sName)
{
	// 将字符串转换为Name类型并播放动画
	PlayerAnimation(StrToName(sName), 1.0f, 0.3f);
}

// 网络接收技能相关事件
event NetRecv_AssignSkill(int Index, string SkillName);	// 分配技能
event NetRecv_UpdateSkill(Skill Skill);					// 更新技能
event NetRecv_LearnSkill(Skill Skill);					// 学习技能

// 网络接收区域和移动相关事件
event NetRecv_UpdateZone();								// 更新区域
event NetRecv_MoveSpeedChange();							// 移动速度改变
event NetRecv_NpcDialog(NpcServerInfo NpcSI, string Dialog);	// NPC对话

/**
 * 网络接收近战连击动作
 * 从服务器接收其他玩家的近战连击动作
 * @param SkillName 技能名称
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 * @param Speed 速度
 * @param CC 连击计数
 */
event NetRecv_ActMeleeCombo(string SkillName, character Target, vector TargetLoc, float Speed, int CC)
{
	local Skill Skill;

	// 如果动作池为空，立即执行动作
	if ( ActionPool.Length == 0 ) 
	{
		// 查询技能对象
		Skill = GameManager(Level.Game).QueryStaticSkillByName(SkillName);
		// 旋转到目标位置
		RotatePawnTo(TargetLoc);
		bRotateToDesired = False;
		// 设置连击计数（减1因为计数从0开始）
		ComboCount = CC - 1;
		// 停止移动
		Pawn.Acceleration = vect(0,0,0);
		// 开始连击
		NetRecv_StartCombo(Skill,CC - 1,Speed);
	}
	else
		// 如果动作池不为空，添加到动作池中等待执行
		AddActionPool(SkillName,Target,TargetLoc,Speed,CC);
}

/**
 * 网络接收近战终结技动作
 * 从服务器接收其他玩家的近战终结技动作
 * @param SkillName 技能名称
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 * @param Speed 速度
 */
event NetRecv_ActMeleeFinish(string SkillName, character Target, vector TargetLoc, float Speed)
{
	local Skill Skill;

	// 如果动作池为空，立即执行动作
	if ( ActionPool.Length == 0 ) 
	{
		// 查询技能对象
		Skill = GameManager(Level.Game).QueryStaticSkillByName(SkillName);
		// 旋转到目标位置
		RotatePawnTo(TargetLoc);
		bRotateToDesired = False;
		// 重置连击计数
		ComboCount = -1;
		// 开始终结技
		NetRecv_StartFinish(Skill,Speed);
	}
	else
		// 如果动作池不为空，添加到动作池中等待执行（连击计数为-1表示终结技）
		AddActionPool(SkillName,Target,TargetLoc,Speed, -1);
}

/**
 * 网络接收开始施法
 * 从服务器接收其他玩家开始施法的通知
 * @param Skill 技能对象
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 * @param Speed 速度
 */
event NetRecv_StartCast(Skill Skill, character Target, vector TargetLoc, float Speed)
{
	local float	realAnimRate;

	// 旋转到目标位置（优先使用目标角色位置）
	if ( Target != None && !Target.bDeleteMe )
		RotatePawnTo(Target.Location);
	else
		RotatePawnTo(TargetLoc);

	// 如果技能有效，播放施法动画和特效
	if ( Skill != None ) 
	{
		// 清除受伤标志并停止移动
		Character(Pawn).bJustDamaged = False;  
		Pawn.Acceleration = vect(0,0,0);  

		// 计算实际动画速率（速度的倒数）
		realAnimRate = 1.0 / Speed;
		// 播放施法动画
		Character(Pawn).PlayAnimAction(Skill.AnimSequence, -1,realAnimRate,0.3);
		// 生成施法特效
		SpawnCastEffect(Skill);
	}
}

/**
 * 网络接收开始发射
 * 从服务器接收其他玩家技能发射的通知
 * @param Skill 技能对象
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 */
event NetRecv_StartFire(Skill Skill, character Target, vector TargetLoc)
{
	if ( Skill != None ) 
	{
		// 根据技能类型生成不同的特效
		if ( !Skill.bIsSplash ) 
			// 非范围技能：生成投射物特效
			SpawnFireEffect(Skill, Target, TargetLoc);
		else
			// 范围技能：生成爆炸特效
			SpawnExploEffect(Skill, Target, TargetLoc);
	}
}

// 网络接收远程攻击动作
event NetRecv_ActRange(Skill Skill, Actor TargetActor, vector TargetLocation, float ActRatio, int ActPitch);

// 网络接收精神施法
event NetRecv_SpiritCast(Skill Skill);

// 网络接收精神魔法
event NetRecv_SpiritMagic(string SpiritName, bool bSet);
// 网络接收升级
event NetRecv_LevelUp();
// 网络接收开始物品变形
event NetRecv_StartItemTransform();
// 网络接收弓箭攻击发射
event NetRecv_BowAttackFire(actor Target);

/**
 * 设置第一人称视角
 * 将摄像机设置为第一人称视角（摄像机距离为0，视野角度90度）
 */
exec function SetFirstPersonView()
{
	local rotator crot;
	// 重置旋转：俯仰角为0，偏航角与Pawn一致
	crot = Rotation;
	crot.pitch = 0;
	crot.yaw = Pawn.Rotation.Yaw;
	SetRotation(crot);
	// 设置摄像机距离为0（第一人称）
	CameraDist = 0;
	bBehindView = False;
	// 设置视野角度为90度
	SetFOV(90);
	ViewType = FirstPerson;
	// 保存设置到配置文件
	ConsoleCommand("SETOPTIONI ViewType"@ViewType);
	ConsoleCommand("SAVEOPTION");
}

/**
 * 设置背后自由视角
 * 将摄像机设置为背后自由视角（摄像机距离5-40，默认20，视野角度80度）
 */
exec function SetBehindFreeView()
{
	// 设置摄像机距离范围
	MinCameraDist = 5;
	MaxCameraDist = 40;
	CameraDist = 20;	// 默认距离
	// 设置视野角度为80度
	SetFOV(80);
	ViewType = BehindFree;
	bBehindView = True;
	// 保存设置到配置文件
	ConsoleCommand("SETOPTIONI ViewType"@ViewType);
	ConsoleCommand("SAVEOPTION");
}

/**
 * 设置四分之三视角
 * 将摄像机设置为四分之三视角（摄像机距离25-40，默认30，视野角度80度，带俯仰角）
 */
exec function SetQuaterView()
{
	local rotator crot;

	// 设置摄像机距离范围
	MinCameraDist = 25;
	MaxCameraDist = 40;
	CameraDist = 30;	// 默认距离
	// 设置视野角度为80度
	SetFOV(80);
	ViewType = QuaterView;
	bBehindView = True;

	// 根据摄像机距离计算俯仰角（距离越远，俯仰角越大）
	crot = Rotation;
	crot.Pitch = -8192.0 * (CameraDist - MinCameraDist) / (MaxCameraDist - MinCameraDist);
	SetRotation(crot);

	// 保存设置到配置文件
	ConsoleCommand("SETOPTIONI ViewType"@ViewType);
	ConsoleCommand("SAVEOPTION");
}

/**
 * 屏蔽功能
 * 设置屏蔽标志，屏蔽指定的消息或音效类型
 * @param Flag 屏蔽标志（BLOCK_Tell/BLOCK_Shout/BLOCK_Yell/BLOCK_Whisper/BLOCK_Message/BLOCK_BGM/BLOCK_Sound）
 */
function Block(int Flag)
{
	local string Message;
	local string Postfix;

	Postfix = " Blocked";
	// 使用位运算设置屏蔽标志
	BlockFlag = BlockFlag | Flag;
	// 根据标志类型设置消息字符串（用于日志或显示）
	switch (Flag) 
	{
		case BLOCK_Tell: Message = "TELL"; break;		// 屏蔽密语
		case BLOCK_Shout: Message = "SHOUT"; break;		// 屏蔽喊话
		case BLOCK_Yell: Message = "YELL"; break;		// 屏蔽大叫
		case BLOCK_Whisper: Message = "WHISPER"; break;	// 屏蔽私语
		case BLOCK_Message: Message = "MESSAGE"; break;	// 屏蔽消息
		case BLOCK_BGM: Message = "BGM"; break;			// 屏蔽背景音乐
		case BLOCK_Sound: Message = "SOUND"; break;		// 屏蔽音效
	}
}

/**
 * 取消屏蔽功能
 * 清除屏蔽标志，恢复指定的消息或音效类型
 * @param Flag 屏蔽标志
 */
function Unblock(int Flag)
{
	local string Message;
	local string Postfix;

	Postfix = " Freed";
	// 使用位运算清除屏蔽标志
	BlockFlag = BlockFlag & ~Flag;
	// 根据标志类型设置消息字符串（用于日志或显示）
	switch (Flag) 
	{
		case BLOCK_Tell: Message = "TELL"; break;		// 取消屏蔽密语
		case BLOCK_Shout: Message = "SHOUT"; break;		// 取消屏蔽喊话
		case BLOCK_Yell: Message = "YELL"; break;		// 取消屏蔽大叫
		case BLOCK_Whisper: Message = "WHISPER"; break;	// 取消屏蔽私语
		case BLOCK_Message: Message = "MESSAGE"; break;	// 取消屏蔽消息
		case BLOCK_BGM: Message = "BGM"; break;			// 取消屏蔽背景音乐
		case BLOCK_Sound: Message = "SOUND"; break;		// 取消屏蔽音效
	}
}


/**
 * 切换装备状态
 * 切换武器的装备/卸下状态
 */
exec function ToggleArmState() 
{
	if ( PSI != None && Net != None ) 
	{
		// 如果正在摊位出售，不允许切换装备状态
		if( PSI.BoothState != BS_None )
			return;
		// 如果未装备，通知服务器装备武器
		if ( PSI.ArmState == False )
			Net.NotiArmed();
		// 如果已装备且不在攻击状态，通知服务器卸下武器
		else if ( !IsInState('Attacking') )			
			Net.NotiDisarmed();
	}
}


/**
 * 切换奔跑/行走状态
 * 切换玩家的移动模式（奔跑/行走）
 */
exec function ToggleRunState() 
{
	if ( PSI != None && Net != None ) 
	{
		// 如果正在摊位出售，不允许切换移动状态
		if( PSI.BoothState != BS_None )
			return;
		// 如果当前是行走状态，切换到奔跑
		if ( PSI.RunState == False ) Net.NotiRun();
		// 如果当前是奔跑状态，切换到行走
		else Net.NotiWalk();
	}
}

/**
 * 切换PK状态
 * 切换玩家的PK（玩家对战）状态
 */
exec function TogglePkState() 
{
	// 如果区域禁止PVP，不允许切换PK状态
	if ( ZSI != None && ZSI.bNoPvp ) 
	{
		return;
	}

	// 如果正在比赛中且有队伍，不允许切换PK状态
	if ( ( PSI.MatchName != "" ) && ( (PSI.TeamName != "") && (PSI.TeamName != "NONE") ) ) 
	{	
		myHud.AddMessage(2, Localize("Information", "NoPvPatMatch", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
		return;
	}

	// 切换PK状态
	if ( PSI != None ) 
	{
		// 如果正在摊位出售，不允许切换PK状态
		if( PSI.BoothState != BS_None )
			return;
		// 如果当前未开启PK，开启PK
		if ( PSI.PkState == False ) Net.NotiPK();
		// 如果当前已开启PK，关闭PK
		else Net.NotiNotPK();
	}
}




/**
 * 获取热键技能
 * 获取指定索引的热键技能名称
 * @param Index 索引（0=连击技能，1=终结技，2=魔法技能）
 * @return 技能名称
 */
function string GetHotSkill(byte Index) 
{
	if ( PSI != None ) 
	{
		if ( Index == 0 ) return PSI.ComboSkill;		// 连击技能
		if ( Index == 1 ) return PSI.FinishSkill;		// 终结技
		if ( Index == 2 ) return PSI.MagicSkill;		// 魔法技能
	}
}

/**
 * 设置热键技能
 * 设置指定索引的热键技能
 * @param Index 索引
 * @param SkillName 技能名称
 */
function SetHotSkill(byte Index, string SkillName) 
{
	if ( PSI != None )
		// 通知服务器分配技能
		Net.NotiSkillAssign(Index, SkillName);
}

/**
 * 获取热键
 * 获取指定索引的快捷键名称
 * @param Index 索引
 * @return 快捷键名称
 */
function string GetHotKey(byte Index) 
{
	local int QuickSlotTotalNum;
	// 计算快捷键总数量（列数 × 行数）
	QuickSlotTotalNum = class 'QuickKeyConst'.Default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.Default.QuickSlotRows;

	// 检查索引有效性
	if ( Index >= 0 && Index < QuickSlotTotalNum && PSI != None ) 
	{
		return PSI.QuickKeys[Index].KeyName;
	}
}

/**
 * 获取热键类型
 * 获取指定索引的快捷键类型
 * @param Index 索引
 * @return 快捷键类型
 */
function byte GetHotKeyType(byte Index) 
{
	local int QuickSlotTotalNum;
	// 计算快捷键总数量
	QuickSlotTotalNum = class 'QuickKeyConst'.Default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.Default.QuickSlotRows;

	// 检查索引有效性
	if ( Index >= 0 && Index < QuickSlotTotalNum && PSI != None )
		return PSI.QuickKeys[Index].Type;
	// 如果索引无效，返回无类型
	return class'GConst'.Default.BTNone;
}

/**
 * 设置热键
 * 设置指定索引的快捷键
 * @param Index 索引
 * @param Type 类型
 * @param KeyName 快捷键名称
 */
function SetHotKey(byte Index, byte Type, string KeyName) 
{
	local int QuickSlotTotalNum;
	// 计算快捷键总数量
	QuickSlotTotalNum = class 'QuickKeyConst'.Default.QuickSlotColumns;
	QuickSlotTotalNum *= class 'QuickKeyConst'.Default.QuickSlotRows;

	// 检查索引有效性并设置快捷键
	if ( Index >= 0 && Index < QuickSlotTotalNum && PSI != None ) 
	{
		PSI.QuickKeys[Index].Type = Type;
		PSI.QuickKeys[Index].KeyName = KeyName;
	}
}

/**
 * 通过索引查询技能
 * 在指定技能书中通过坐标查询技能
 * @param BookName 技能书名称
 * @param X X坐标
 * @param Y Y坐标
 * @return 技能对象，未找到返回None
 */
function Skill QuerySkillByIndex(string BookName, byte X, byte Y)
{
	local int i;
	// 遍历所有技能书
	for ( i = 0;i < PSI.SkillBooks.Length;i++ )
		if ( PSI.SkillBooks[i].BookName == BookName )
			return PSI.SkillBooks[i].QuerySkillByIndex(X,Y);
	return None;
}

/**
 * 通过名称查询技能
 * 在所有技能书中通过名称查询技能
 * @param SkillName 技能名称
 * @return 技能对象，未找到返回None
 */
function Skill QuerySkillByName(string SkillName)
{
	local byte i;
	local Skill Skill;
	// 如果技能名称为空，返回None
	if ( SkillName == "" )
		return None;
	// 遍历所有技能书
	for ( i = 0;i < PSI.SkillBooks.Length;i++ ) 
	{
		Skill = PSI.SkillBooks[i].QuerySkillByName(SkillName);
		if ( Skill != None )
			return Skill;
	}
	
	// 在第二技能书中查询
	Skill = PSI.SecondSkillBook.QuerySkillByName(SkillName);
	if( Skill != None )
		return Skill;
	
	return None;
}

/**
 * 网络接收刚死亡
 * 从服务器接收玩家刚死亡的通知
 */
event NetRecv_JustDead()
{
	// 检查Pawn和PSI有效性，以及是否存活
	if ( Pawn == None || PSI == None || PSI.bIsAlive )
		return;
	// 切换到刚死亡状态
	GotoState('JustDead');
}

/**
 * 广播跳跃
 * 向服务器通知玩家跳跃
 */
function BroadcastJump()
{
	if ( Net != None ) 
	{
		Net.NotiJump();
	}
}

// 设置伤害（事件）
event SetDamage(Pawn aPawn,int Damage,optional int Type); 

/**
 * 重置等待攻击结果计数
 * 重置等待服务器攻击结果返回的计数器
 */
event ResetWaitingAttackResult()
{
	PSI.nWaitingAttackResultCnt = 0;
}



/**
 * 生成爆炸之刃特效（调试命令）
 * 在玩家位置生成爆炸之刃特效
 */
exec function BlastBlade()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_BlastBlade",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function BlastFist()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_BlastFist",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function DeadlyCount()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_DeadlyCount",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function RestraintShot() 
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_DeadlyCount",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function FireFury()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_FireFury",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function IceFury()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_IceFury",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function ManaBarrier()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_ManaBarrier",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function RainbowArrow()
{
	local Actor Fx;
	local class<Actor> Effect;
	Effect = class<Actor>(DynamicLoadObject("ActiveFx.Active_RainbowArrow_Second",class'Class'));
	/*local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_RainbowArrow",class'Class'));*/
	Fx = Spawn(Effect,Pawn,,Location);
	MagicSplash(Fx).SetRadius(800);

}

exec function SoulBlade()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_SoulBlade",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function SoulFist()
{
	local class<EffectProjectile> Effect;
	Effect = class<EffectProjectile>(DynamicLoadObject("ActiveFx.Active_SoulFist",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

exec function SpawnStun()
{
	local class<EnchantType> stun;
	stun = class<EnchantType>(DynamicLoadObject("EnchantFx.Stun",class'Class'));

	Spawn(stun,Pawn, ,Pawn.Location);
}





exec function SpawnEffect(string EffectName)
{
	local class<Emitter> Effect;
	Effect = class<Emitter>(DynamicLoadObject("TransFx."$EffectName,class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}




function SpawnLenzFlareEffect(int GameTime)
{
	local	Rotator Rot;
	local	class<LenzFlareEmitter> Lenz;

	Rot = Rotation;
	Rot.Yaw += -Rot.Yaw;
	if ( Flare == None ) 
	{
		Lenz = class<LenzFlareEmitter>(DynamicLoadObject("SpecialFx.SunLenzFlare",class'Class'));
		Flare = Spawn(Lenz,Self,,Location,Pawn.Rotation);


		Flare.iFlareTime = GameTime % 24;
		
	}
	Flare.iFlareTime = GameTime % 24;
	
}

function DestroyLenzFlareEffect()
{
	if ( Flare != None ) 
	{
		Flare.Destroy();
		Flare = None;
	}
}

event SpawnLenzFlare(int GameTime)
{
	
	
}



function bool CheckChatEraser();

/**
 * 生成施法特效
 * @param Skill 技能对象
 */
function SpawnCastEffect(Skill Skill)
{
	local class<Emitter> CastClass;
	local vector BoneLocation;

	local Emitter CastEmitter;
	local Sound CastSound;

	
	if ( !Character(Pawn).IsAvatar() ) 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	CastClass = Skill.CastClass;
	
	if ( CastClass != None )
	{
		BoneLocation = Pawn.GetBoneCoords(Skill.FireBone).Origin; 
		CastEmitter = Spawn(CastClass,,,BoneLocation,Pawn.Rotation);

		if ( CastEmitter.SpawnSoundString != "" )
			CastSound = Sound(DynamicLoadObject(CastEmitter.SpawnSoundString,class'Sound'));

		if ( CastSound != None )
			PlaySound(CastSound, SLOT_None, 0.8, False, 128, 1, False);
	}
}

/**
 * 生成发射特效（投射物）
 * 该函数用于在指定位置生成技能发射的投射物特效，支持多发射物扇形分布
 * @param Skill 技能对象，包含发射物类型、发射骨骼、发射数量等信息
 * @param TargetActor 目标角色对象，如果为None则使用TargetLocation作为目标点
 * @param TargetLocation 目标位置向量，当TargetActor无效时使用此位置
 * @param Sequence 动作序列号（可选），用于标识此次发射的动作ID
 * @return 返回最后生成的投射物对象，如果生成失败则返回None
 */
function Actor SpawnFireEffect(Skill Skill, Actor TargetActor, vector TargetLocation, optional int Sequence)
{
	// 发射物类：技能配置的投射物类型（如箭矢、火球等）
	local class<Actor> FireClass;
	// 生成的投射物实例
	local Actor Shot;
	// 发射位置：从角色骨骼获取的发射点坐标
	local vector BoneLocation;
	// 瞄准旋转：投射物发射时的朝向角度
	local rotator AimRotation;
	// 循环计数器：用于生成多个投射物
	local int i;
	// 角度偏移：用于计算多发射物的扇形分布角度
	local float rot;
	
	// 验证目标有效性：如果目标对象为空或已被标记删除
	if ( TargetActor == None || TargetActor.bDeleteMe ) 
	{
		// 特殊处理：如果是SecondSkill类型，且技能类型为4（可能是范围技能），允许继续执行
		// 否则直接返回None，因为无法确定发射方向
		if( Skill.IsA('SecondSkill') )
		{
			// 只有SkillType为4的SecondSkill可以在无目标时发射（可能是范围技能）
			if( SecondSkill(Skill).SkillType != 4 )
				return None;
		}
		else
			// 普通技能必须有有效目标才能发射
			return None;
	}

	// 获取技能配置的发射物类型
	FireClass = Skill.FireClass;
	// 确保发射物类型有效
	if ( FireClass != None )
	{
		// 获取发射骨骼的世界坐标位置（如手部、武器等骨骼）
		BoneLocation = Pawn.GetBoneCoords(Skill.FireBone).Origin;
		
		// 循环生成多个投射物（根据技能配置的NumOfShot数量）
		for( i = 0;i < Skill.NumOfShot;i++ )
		{
			// 计算瞄准方向：从发射点指向目标
			if ( TargetActor != None )
				// 如果有目标角色，计算指向目标位置的旋转角度
				AimRotation = Rotator(TargetActor.Location - BoneLocation);
			else
				// 如果没有目标角色，计算指向目标位置的旋转角度
				AimRotation = Rotator(TargetLocation - BoneLocation);

			// 多发射物扇形分布：第一个投射物（i=0）直射，后续投射物添加角度偏移
			if( i > 0 )
			{
				// 计算角度偏移量：每两个投射物为一组，偏移角度递增
				// 公式：(i+1)/2 * 200 度，例如：i=1时为200度，i=2时为300度，i=3时为400度
				rot = (i + 1) / 2 * 200;
				// 偶数索引的投射物向左偏移（负角度），奇数索引向右偏移（正角度）
				// 形成左右交替的扇形分布效果
				if( i%2 == 0 )
					rot = -1 * rot;
				// 将偏移角度添加到Yaw轴（水平旋转）
				AimRotation.Yaw = AimRotation.Yaw + rot;
			}

			// 在发射位置生成投射物实例
			// 参数：投射物类型、拥有者、生成器、位置、旋转
			Shot = Pawn.Spawn(FireClass,Pawn,,BoneLocation,AimRotation);
			
			// 如果成功生成且是EffectProjectile类型，设置投射物属性
			if ( Shot != None && Shot.IsA('EffectProjectile') )
			{
				// 设置投射物的发起者（造成伤害的源头）
				EffectProjectile(Shot).Instigator = Pawn;
				// 设置投射物的发射者（角色对象）
				EffectProjectile(Shot).Shooter = Character(Pawn);
				// 设置目标角色
				EffectProjectile(Shot).TargetActor = TargetActor;
				// 设置伤害类型（箭矢、分裂箭、云、吐息、天启、箭雨等）
				EffectProjectile(Shot).DamageType = Skill.DamageType;
				// 设置目标位置：优先使用目标角色的当前位置
				if ( TargetActor != None && !TargetActor.bDeleteMe )
					EffectProjectile(Shot).TargetLocation = TargetActor.Location;
				else
					// 如果目标无效，使用传入的目标位置
					EffectProjectile(Shot).TargetLocation = TargetLocation;
				// 设置技能名称，用于伤害计算和特效识别
				EffectProjectile(Shot).SkillName = Skill.SkillName; 
				// 设置是否跳过命中检测（附魔类技能可能不需要检测）
				EffectProjectile(Shot).bNoCheckHit = Skill.bEnchant;
				// 设置动作ID，用于同步和追踪
				EffectProjectile(Shot).ActionID = Sequence;
				// 调整投射物的初始位置（可能根据骨骼位置微调）
				EffectProjectile(Shot).AdjustLocation(BoneLocation);
			}
		}
	}
	// 返回最后生成的投射物对象（用于后续追踪或引用）
	return Shot;
}

/**
 * 生成爆炸特效
 * @param Skill 技能对象
 * @param TargetActor 目标对象
 * @param TargetLocation 目标位置
 */
function SpawnExploEffect(Skill Skill, Actor TargetActor, vector TargetLocation)
{
	local class<Actor> ExploClass;

	
	if ( Skill.IsA('SecondSkill') && Skill.ExtraClass != None )
		ExploClass = Skill.ExtraClass;
	else
		ExploClass = Skill.FireClass;

	if ( ExploClass != None ) 
	{
		if ( TargetActor != None && !TargetActor.bDeleteMe )
			Spawn(ExploClass,,,TargetActor.Location);
		else
			Spawn(ExploClass,,,TargetLocation);
	}
}

/**
 * 龙息测试（调试命令）
 * 生成龙息轨迹特效用于测试
 */
exec function DBTest()
{
	local class<Emitter> DBClass;
	local Emitter DBActor;

	DBClass = class<Emitter>(DynamicLoadObject("RedFx.RED_DragonBreath_Trail",class'Class'));
	if ( DBClass != None ) 
	{
		// 在玩家前方生成特效
		DBActor = Spawn(DBClass,Pawn,,Pawn.Location + vect(1,0,0)>>Pawn.Rotation,Pawn.Rotation);
	}
}

/**
 * 生成升级特效（调试命令）
 * 在玩家位置生成升级特效
 */
exec function SpawnLevelupEffect()
{
	local class<Emitter> Effect;
	local class<Actor> PawnEffect;

	// 生成基础升级特效
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Basic_LevelUp",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);

	// 生成飞行升级特效
	PawnEffect = class<Actor>(DynamicLoadObject("SpecialFx.Levelup_fly",class'Class'));
	if( PawnEffect != None )
		Spawn(PawnEffect,Self,,Pawn.Location);

	
	
}

/**
 * 生成开始特效（调试命令）
 * 在玩家位置生成开始特效
 */
exec function SpawnStartEffect()
{
	local class<Emitter> Effect;
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Basic_Start",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

/**
 * 生成传送特效（调试命令）
 * 在玩家位置生成传送特效
 */
exec function SpawnTeleportEffect()
{
	local class<Emitter> Effect;
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Basic_Teleport",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

/**
 * 生成疼痛特效
 * 当玩家受到伤害时生成疼痛特效和播放疼痛音效
 */
function SpawnPainEffect()
{
	local class<Emitter> Effect;
	local string EffectString;
	local int Random;
	local Sound Sound;
	local string SoundString;

	// 根据特效细节设置决定是否生成特效
	if ( !Character(Pawn).IsAvatar() ) 
	{
		// 非玩家角色：特效细节>=2时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		// 玩家角色：特效细节==3时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	// 随机选择三种疼痛特效之一
	EffectString = "SpecialFx.Skill_HitPain";
	Random = Rand(3);
	if ( Random == 0 )
		EffectString = EffectString$"One_B";		// 第一种疼痛特效
	else if (Random == 1)
		EffectString = EffectString$"Three_B";	// 第三种疼痛特效
	else
		EffectString = EffectString$"Two_B";		// 第二种疼痛特效

	// 生成疼痛特效
	Effect = class<Emitter>(DynamicLoadObject(EffectString,class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
	
	// 根据种族和性别构建疼痛音效路径
	SoundString = "SHero.Pain_";
	SoundString = SoundString$Left(string(PSI.RaceName), 1);	// 种族首字母
	if ( PSI.bIsMale )
		SoundString = SoundString$"M";	// 男性
	else
		SoundString = SoundString$"F";	// 女性
	if ( PSI.RaceName == 'Human' )
		SoundString = SoundString$"01";	// 人类特殊编号
	// 加载并播放疼痛音效
	Sound = Sound(DynamicLoadObject(SoundString, class'Sound'));
	if ( Sound != None )
		Pawn.PlaySound(Sound);
}

/**
 * 生成击退特效
 * 当玩家被击退时生成击退特效
 */
function SpawnKnockbackEffect()
{
	local class<Emitter> Effect;

	// 根据特效细节设置决定是否生成特效
	if ( !Character(Pawn).IsAvatar() ) 
	{
		// 非玩家角色：特效细节>=2时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		// 玩家角色：特效细节==3时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	// 生成击退特效
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitKnockback_B",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

/**
 * 生成暴击特效
 * 当玩家受到暴击伤害时生成暴击特效
 */
function SpawnCriticalEffect()
{
	local class<Emitter> Effect;

	// 根据特效细节设置决定是否生成特效
	if ( !Character(Pawn).IsAvatar() ) 
	{
		// 非玩家角色：特效细节>=2时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		// 玩家角色：特效细节==3时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	// 生成暴击特效
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitCritical_B",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

/**
 * 生成格挡特效
 * 当玩家成功格挡攻击时生成格挡特效
 * @param AttackRotation 攻击者的旋转方向
 */
function SpawnBlockEffect(rotator AttackRotation)
{
	local class<Emitter> Effect;
	local Emitter BlockEffect;
	local vector X, Y, Z;
	local vector vLook;

	// 根据特效细节设置决定是否生成特效
	if ( !Character(Pawn).IsAvatar() ) 
	{
		// 非玩家角色：特效细节>=2时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		// 玩家角色：特效细节==3时不生成
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	// 生成格挡特效
	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitBlock", class'Class'));
	// 获取Pawn的坐标轴
	GetAxes(Pawn.Rotation, X, Y, Z);
	// 计算攻击方向
	vLook = vector(AttackRotation);
	// 在玩家位置前方50单位处生成格挡特效（朝向攻击方向）
	BlockEffect = Spawn(Effect,Pawn,,Pawn.Location - 50 * Normal(vLook), AttackRotation);
}

/**
 * 反转摄像机
 * 将摄像机旋转180度，实现摄像机反转效果
 */
function ReverseCamera()
{
	local Rotator Rot;
	Rot = Rotation;
	// 偏航角加180度（32768 = 180度）并取模
	Rot.Yaw = (Rot.Yaw + 32768) % 65536;
	SetRotation(Rot);
	// 切换摄像机反转标志
	bCameraReversed = !bCameraReversed;
}


/**
 * 检测敌人（自动面向最近的敌人）
 * 查找最近的敌人并自动面向该敌人
 */
exec function DetectEnemy()
{
	local int i;
	local float Dist, MinDist;
	local Rotator Rot;
	local vector EnemyLocation;
	local Creature Creature, Nearlist;
	MinDist = 100000.0f;

	// 如果正在打开某些界面，不允许检测敌人
	if( CheckInterface("Inventory") || CheckInterface("StashBox") || CheckInterface("Store") || CheckInterface("Exchange") || CheckInterface("Booth") )
		return;
	
	// 优先使用最后攻击的敌人位置
	if( LastHitEnemy != None && !LastHitEnemy.bDeleteMe )
		EnemyLocation = LastHitEnemy.Location;
	else
	{
		// 遍历所有生物，查找最近的怪物
		for( i = 0 ; i < GameManager(Level.Game).Creatures.Length ; i++ )
		{
			Creature = GameManager(Level.Game).Creatures[i];
			if( Creature != None && !Creature.bDeleteMe && Creature.IsA('Monster') )
			{
				Dist = VSize(Creature.Location - Pawn.Location);
				// 更新最近距离和最近敌人
				if( Dist < MinDist ) 
				{
					MinDist = Dist;
					Nearlist = Creature;
				}
			}
		}
		// 如果找到敌人，使用其位置
		if( Nearlist != None )
			EnemyLocation = Nearlist.Location;
		else
			return;	// 未找到敌人，直接返回
	}

	// 旋转Pawn和摄像机朝向敌人位置
	RotatePawnTo(EnemyLocation);
	Rot = Rotation;
	Rot.Yaw = Pawn.Rotation.Yaw;
	SetRotation(Rot);
	Enemy = None;
}


/**
 * 跟随玩家
 * 设置跟随目标并切换到追踪状态
 * @param Player 要跟随的玩家
 */
function FollowPlayer(Hero Player)
{
	if ( Player != None && !Player.bDeleteMe ) 
	{
		// 设置追踪标志和目标
		bTracePlayer = True;
		TracePlayer = Player;
		// 切换到追踪状态
		GotoState('Tracing','Trace');
	}
}

/**
 * 网络接收追踪玩家移出
 * 当追踪的玩家移出视野时调用
 */
event NetRecv_TracePlayerMovedOut();

/**
 * 追踪状态
 * 玩家跟随其他玩家时的状态
 */
state Tracing extends Navigating
{
	/**
	 * 网络接收追踪玩家移出
	 * 停止追踪并返回导航状态
	 */
	event NetRecv_TracePlayerMovedOut()
	{
		Destination = Location;
		GotoState('Navigating');
	}
	
	/**
	 * 状态结束
	 * 清理追踪标志和目标
	 */
	function EndState()
	{
		bTracePlayer = False;
		TracePlayer = None;
	}
	
	/**
	 * 检查是否可以停止
	 * @param Distance 距离
	 * @return 距离小于400时可以停止
	 */
	function bool CanStop(float Distance) 
	{ 
		return Distance < 400; 
	}
	
	/**
	 * 重复状态
	 * 重新进入追踪状态
	 */
	function RepeatState()
	{
		GotoState('Tracing','Trace');
	}
	
	/**
	 * 玩家移动
	 * 追踪目标玩家，保持一定距离
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		// 如果追踪标志无效或目标不存在，返回导航状态
		if (!bTracePlayer || TracePlayer == None) 
		{
			GotoState('Navigating');
		}
		else 
		{
			// 如果距离目标太远，移动到目标位置
			if (!CanStop(VSize(TracePlayer.Location - Pawn.Location))) 
			{
				Destination = TracePlayer.Location;
				RepeatState();
			}
			else
				// 距离足够近，停止移动
				Destination = Pawn.Location;
			Super.PlayerMove(DeltaTime);
		}
	}
	
	/**
	 * 更新旋转
	 * 朝向追踪目标旋转
	 * @param DeltaTime 时间增量
	 * @param MaxPitch 最大俯仰角
	 */
	function UpdateRotation(float DeltaTime,float MaxPitch)
	{
		// 如果追踪标志无效或目标不存在，返回导航状态
		if (!bTracePlayer || TracePlayer == None) 
		{
			GotoState('Navigating');
		}
		else 
		{
			// 如果有加速度，旋转朝向目标
			if (Pawn.Acceleration.X != 0 && Pawn.Acceleration.Y != 0)
				RotatePawnTo(TracePlayer.Location);
			Super.UpdateRotation(DeltaTime,MaxPitch);
		}
	}
	
	/**
	 * 玩家Tick
	 * 每帧检查追踪状态
	 * @param DeltaTime 时间增量
	 */
	event PlayerTick(float DeltaTime)
	{
		Global.PlayerTick(DeltaTime);
		// 如果追踪标志无效或目标不存在，返回导航状态
		if (!bTracePlayer || TracePlayer == None) 
		{
			GotoState('Navigating');
		}
	}
Trace:
	// 移动到目标位置
	MoveTo(Destination,None,Pawn.bIsWalking);
}

/**
 * 阻止交易请求
 * @param PlayerName 玩家名称
 */
function BlockExchange(name PlayerName)
{
	if ( !IsExchangeBlocked(PlayerName) ) 
	{
		ExchangeBlockedPlayer[ExchangeBlockedPlayer.Length] = PlayerName;
		myHud.AddMessage(2,PlayerName$Localize("Information","DisallowExchangeRequestFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
	}
}

/**
 * 阻止消息
 * @param PlayerName 玩家名称
 */
function BlockMessage(name PlayerName)
{
	if ( !IsMessageBlocked(PlayerName) ) 
	{
		MessageBlockedPlayer[MessageBlockedPlayer.Length] = PlayerName;
		myHud.AddMessage(2,PlayerName$Localize("Information","DisallowMessageFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
	}
	else
		myHud.AddMessage(2,PlayerName$Localize("Information","DisallowedMessageFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
}

/**
 * 取消阻止交易请求
 * 从屏蔽列表中移除指定玩家，允许其交易请求
 * @param PlayerName 玩家名称
 */
function UnblockExchange(name PlayerName)
{
	local int i,index;
	// 初始化索引为数组长度（表示未找到）
	index = ExchangeBlockedPlayer.Length;
	// 查找玩家在屏蔽列表中的位置
	for ( i = 0;i < ExchangeBlockedPlayer.Length;i++ )
		if ( PlayerName == ExchangeBlockedPlayer[i] )
			index = i;
	// 如果找到玩家，从列表中移除
	if ( index < ExchangeBlockedPlayer.Length ) 
	{
		ExchangeBlockedPlayer.Remove(index,1);
		myHud.AddMessage(2,PlayerName$Localize("Information","AllowExchangeRequestFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
	}
}

/**
 * 取消阻止消息
 * 从屏蔽列表中移除指定玩家，允许其发送消息
 * @param PlayerName 玩家名称
 */
function UnblockMessage(name PlayerName)
{
	local int i,index;
	// 初始化索引为数组长度（表示未找到）
	index = MessageBlockedPlayer.Length;
	// 查找玩家在屏蔽列表中的位置
	for ( i = 0;i < MessageBlockedPlayer.Length;i++ )
		if ( PlayerName == MessageBlockedPlayer[i] )
			index = i;
	// 如果找到玩家，从列表中移除
	if ( index < MessageBlockedPlayer.Length ) 
	{
		MessageBlockedPlayer.Remove(index,1);
		myHud.AddMessage(2,PlayerName$Localize("Information","AllowMessageFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
	}
	else
		// 如果玩家不在屏蔽列表中，提示已允许
		myHud.AddMessage(2,PlayerName$Localize("Information","AllowedMessageFrom","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
}

/**
 * 检查是否阻止了交易请求
 * 检查指定玩家是否在交易屏蔽列表中
 * @param PlayerName 玩家名称
 * @return 如果玩家被屏蔽返回True，否则返回False
 */
function bool IsExchangeBlocked(name PlayerName)
{
	local int i;
	// 遍历屏蔽列表查找玩家
	for ( i = 0;i < ExchangeBlockedPlayer.Length;i++ )
		if ( PlayerName == ExchangeBlockedPlayer[i] )
			return True;
	// 未找到，返回False
	return False;
}

/**
 * 检查是否阻止了消息
 * 检查指定玩家是否在消息屏蔽列表中
 * @param PlayerName 玩家名称
 * @return 如果玩家被屏蔽返回True，否则返回False
 */
function bool IsMessageBlocked(name PlayerName)
{
	local int i;
	// 遍历屏蔽列表查找玩家
	for ( i = 0;i < MessageBlockedPlayer.Length;i++ )
		if ( PlayerName == MessageBlockedPlayer[i] )
			return True;
	// 未找到，返回False
	return False;
}


/**
 * 网络接收玩家消息
 * 从服务器接收其他玩家发送的消息
 * @param TellerInfo 发送者信息
 * @param Teller 发送者名称
 * @param Type 消息类型
 * @param Message 消息内容
 * @param HitSizeX 命中区域X大小
 * @param HitSizeY 命中区域Y大小
 * @param HitText 命中文本
 */
event NetRecv_PlayerMessage(int TellerInfo,string Teller,string Type,string Message,float HitSizeX,float HitSizeY,string HitText);

/**
 * 移动摄像机
 * 根据摄像机距离和范围设置摄像机偏移
 * @param R 偏移范围
 */
function MoveCamera(Range R)
{
	// 根据摄像机距离在范围内线性插值计算偏移量
	CameraBias = R.Min + (R.Max - R.Min) * (CameraDist - MinCameraDist) / (MaxCameraDist - MinCameraDist);
}

/**
 * 丢失子对象事件
 * 当子对象被销毁时调用
 * @param Child 被销毁的子对象
 */
event LostChild(Actor Child)
{
	Super.LostChild(Child);
	// 如果是魔法爆炸特效且通过检查，直接返回
	if ( Child.IsA('MagicSplash') && LostChild_Check(Child) )
		return;

	// 如果是最发射的特效，清除引用
	if( Child == LastFiredEffect )
		LastFiredEffect = None;
}

// 网络接收Actor移出
event NetRecv_ActorOut(ServerInfo ISI,Actor Actor);
// 物品移出事件
event ItemOut(SephirothItem Item);

/**
 * 加载物品精灵纹理
 * 根据物品和玩家信息加载对应的物品图标纹理
 * @param Item 物品对象
 * @return 物品精灵纹理
 */
function Texture LoadItemSprite(SephirothItem Item)
{
	local string Race, Gender;
	if ( Item != None && PSI != None ) 
	{
		Race = string(PSI.RaceName);
		// 根据性别设置性别标识
		if ( PSI.bIsMale )
			Gender = "M";	// 男性
		else
			Gender = "F";	// 女性
		// 如果是身体部位或圣诞帽，需要根据种族和性别加载
		if ( Item.AttachPlace == class'GConst'.Default.IPBody || InStr(Item.ModelName,"SantaCap") != -1 )
			return Texture(DynamicLoadObject("ItemSprites."$Item.ModelName$Left(Race,1)$Gender,class'Texture'));
		// 其他物品直接加载
		return Texture(DynamicLoadObject("ItemSprites."$Item.ModelName,class'Texture'));
	}
	return None;
}

/**
 * 设置动画速率（调试命令）
 * 设置指定动画序列的播放速率
 * @param Sequence 动画序列名称
 * @param Rate 速率（秒）
 */
exec function SetAnimRate(name Sequence,float Rate)
{
	local Hero Hero;
	local int i;
	Hero = Hero(Pawn);
	if ( Hero != None && Hero.CAnimAction != None ) 
	{
		// 查找指定动画序列
		for ( i = 0;i < Hero.CAnimAction.Actions.Length;i++ )
			if ( Hero.CAnimAction.Actions[i].Sequence == Sequence ) 
			{
				// 设置动画时间（转换为毫秒）
				Hero.CAnimAction.Actions[i].AnimTime = Rate * 1000.f;
				return;
			}
	}
}

/**
 * 获取动画速率（调试命令）
 * 计算并显示指定动画序列的播放速率
 * @param Sequence 动画序列名称
 * @param BaseRate 基础速率
 * @param TargetTime 目标时间（秒）
 */
exec function GetAnimRate(name Sequence,int BaseRate,float TargetTime)
{
	local Hero Hero;
	local int i;
	Hero = Hero(Pawn);
	if ( Hero != None && Hero.CAnimAction != None ) 
	{
		// 查找指定动画序列
		for ( i = 0;i < Hero.CAnimAction.Actions.Length;i++ )
			if ( Hero.CAnimAction.Actions[i].Sequence == Sequence ) 
			{
				// 计算并显示动画速率
				myHud.AddMessage(1,"Sequence="$Sequence$" TargetTime="$TargetTime$" sec "$"AnimRate="$Hero.CAnimAction.Actions[i].Frames / float(BaseRate) * TargetTime,class'Canvas'.Static.MakeColor(255,255,255));
				return;
			}
	}
}

// 网络接收队伍相关事件
event NetRecv_PartyJoinRequest(string Requester, int level);		// 队伍加入请求
event NetRecv_PartyInviteRequest(string Requester, int level);		// 队伍邀请请求

// 网络接收打开商店
event NetRecv_OpenShop();

// 网络接收交易相关事件
event NetRecv_ExchangeRequest(PlayerServerInfo Requester);		// 交易请求
event NetRecv_ExchangeStart();									// 交易开始
event NetRecv_ExchangeOkPressed(bool bySelf);					// 交易确认按下
event NetRecv_ExchangeOkReleased(bool bySelf);					// 交易确认释放
event NetRecv_ExchangeEnd();									// 交易结束

// 网络接收导师系统相关事件
event NetRecv_MentorRequest(string strName, int nOccuID);		// 导师请求
event NetRecv_FollowerRequest(string strName, int nOccuID);		// 学徒请求
event NetRecv_SetMentor(string strName, int nLevel, name MentorJob);	// 设置导师
event NetRecv_SetMentee(int nSlotIndex, string strMenteeName, int nLevel, bool IsEnable, int nReputePoint, Name JobName);	// 设置学徒
event NetRecv_LeaveMentorSystem(int nSlotIndex);				// 离开导师系统
event NetRecv_ResetMentorSystem();								// 重置导师系统
event NetRecv_MentorPreInfo(string strName, int MaxLevel, int nCurrMenteeNum, int nEmptySlots, int nCurrReputationPoint);	// 导师预览信息
event NetRecv_UpdateMentorLevel(int nLevel);					// 更新导师等级

// 网络接收摊位相关事件
event NetRecv_BoothFee(string FeeString);						// 摊位费用
event NetRecv_BoothOpen();										// 摊位打开
event NetRecv_BoothState();										// 摊位状态
event NetRecv_BoothVisit(PlayerServerInfo Seller);				// 访问摊位
event NetRecv_SellerBoothClose();								// 卖家摊位关闭
event NetRecv_GuestBoothClose();								// 访客摊位关闭

// 网络接收仓库相关事件
event NetRecv_StashLobbyOpen();		// 仓库大厅打开
event NetRecv_StashOpen();				// 仓库打开

/**
 * 网络接收重启
 * 从服务器接收玩家重启/复活的通知，重置玩家状态
 */
event NetRecv_Restart()
{
	// 设置玩家为存活状态
	PSI.bIsAlive = True;
	// 如果正在追踪玩家，停止追踪
	if ( bTracePlayer )
		NetRecv_TracePlayerMovedOut();
	bTracePlayer = False;
	TracePlayer = None;
	// 清除锁定目标
	LockedTarget = None;

	// 重置Pawn状态
	if( Pawn != None )
	{
		// 清除受伤标志
		Character(Pawn).bJustDamaged = False;   

		// 播放待机动画
		Character(Pawn).CHAR_PlayWaiting();

		// 如果当前是行走状态，切换到奔跑状态
		if( !PSI.RunState )
			ToggleRunState();

		// 如果体力足够且之前被强制行走，恢复奔跑状态
		if ( PSI.Stamina >= 10 && !PSI.RunState && bForceToWalk ) 
		{
			bForceToWalk = False;
			ToggleRunState();
		}
	}

	// 清理摄像机追踪Actor
	if ( CameraTraceActor != None ) 
	{
		CameraTraceActor.RemoveStyle();
		CameraTraceActor = None;
	}
}

// 网络接收阅读任务完成
event NetRecv_ReadingQuestDone();

// 网络接收城堡信息
event NetRecv_CastleInfo();		

// 网络接收公会相关事件
event NetRecv_ClanMemberInfo();			// 公会成员信息
event NetRecv_ClanApplicantsInfo();		// 公会申请人信息
event NetRecv_ClanApplying(string ClanName);	// 申请加入公会

// 网络接收物品改造相关事件
event NetRecv_RemodelItemDialog(int npcID, string npcName);		// 物品改造对话框
event NetRecv_RemodelItemDesc(bool bAbleRemodeling, string npcDialog);	// 物品改造描述

// 网络接收消息框
event NetRecv_MessageBox(int nType, int nResult);

/**
 * 生成红色施法特效（调试命令）
 * 生成指定名称的红色施法特效
 * @param Name 特效名称
 */
exec function RedCast(string Name)
{
	local class<Emitter> EffectClass;
	local Emitter EffectActor;
	local vector BoneLocation;

	// 从RedFx包中动态加载施法特效类
	EffectClass = class<Emitter>(DynamicLoadObject("RedFx.RED_"$Name$"_Cast",class'Class'));
	if ( EffectClass != None ) 
	{
		// 在玩家前方100单位处生成特效
		BoneLocation = Pawn.Location + (100 * vect(1,0,0) >> Pawn.Rotation);
		EffectActor = Spawn(EffectClass,,,BoneLocation,Pawn.Rotation);
	}
}

/**
 * 生成红色发射特效（调试命令）
 * 生成指定名称的红色发射特效
 * @param Name 特效名称
 */
exec function RedFire(string Name)
{
	local class<Emitter> EffectClass;
	local Emitter EffectActor;
	local vector BoneLocation;

	// 从RedFx包中动态加载发射特效类
	EffectClass = class<Emitter>(DynamicLoadObject("RedFx.RED_"$Name$"_Fire",class'Class'));
	if ( EffectClass != None ) 
	{
		// 在玩家位置生成特效
		BoneLocation = Pawn.Location;
		EffectActor = Spawn(EffectClass,,,BoneLocation,Pawn.Rotation);
	}
}

/**
 * 添加附魔（调试命令）
 * 为玩家添加指定名称的附魔效果
 * @param Name 附魔名称
 */
exec function AddEnchant(string Name)
{
	local class<EnchantType> EnchantClass;
	local EnchantType EnchantType;

	// 从EnchantFx包中动态加载附魔类
	EnchantClass = class<EnchantType>(DynamicLoadObject("EnchantFx."$Name, class'Class'));
	if ( EnchantClass != None ) 
	{
		// 生成附魔对象并添加到玩家的附魔列表
		EnchantType = Spawn(EnchantClass, Pawn);
		EnchantType.EnchantDesc = Name;
		Character(Pawn).EnchantTypes[Character(Pawn).EnchantTypes.Length] = EnchantType;
	}
}

/**
 * 设置附魔旋转（调试命令）
 * 设置指定附魔的旋转角度
 * @param Name 附魔名称
 * @param Pitch 俯仰角
 * @param Yaw 偏航角
 * @param Roll 翻滚角
 */
exec function SetEnchantRotation(string Name, int Pitch, int Yaw, int Roll)
{
	local int i;
	local EnchantType EnchantType;
	local Rotator RelativeRot;

	// 设置相对旋转
	RelativeRot.Pitch = Pitch;
	RelativeRot.Yaw = Yaw;
	RelativeRot.Roll = Roll;

	// 查找指定名称的附魔
	for ( i = 0;i < Character(Pawn).EnchantTypes.Length;i++ ) 
	{
		EnchantType = Character(Pawn).EnchantTypes[i];
		// 如果找到匹配的附魔，跳出循环
		if ( EnchantType != None && EnchantType.EnchantDesc != Name )
			break;
	}
	// 如果找到附魔，设置其发射器的相对旋转
	if ( i < Character(Pawn).EnchantTypes.Length ) 
	{
		EnchantType = Character(Pawn).EnchantTypes[i];
		if ( EnchantType.EnchantEmitter != None )
			EnchantType.EnchantEmitter.SetRelativeRotation(RelativeRot);
	}
}

/**
 * 移除附魔（调试命令）
 * 移除指定名称的附魔效果
 * @param Name 附魔名称
 */
exec function RemoveEnchant(string Name)
{
	local int i;
	local EnchantType EnchantType;

	// 查找指定名称的附魔
	for ( i = 0;i < Character(Pawn).EnchantTypes.Length;i++ ) 
	{
		EnchantType = Character(Pawn).EnchantTypes[i];
		// 如果找到匹配的附魔，跳出循环
		if ( EnchantType != None && EnchantType.EnchantDesc == Name )
			break;
	}
	// 如果找到附魔，销毁并从列表中移除
	if ( i < Character(Pawn).EnchantTypes.Length ) 
	{
		EnchantType = Character(Pawn).EnchantTypes[i];
		EnchantType.Destroy();
		Character(Pawn).EnchantTypes.Remove(i, 1);
	}
}

/**
 * 检查是否透明模式
 * 检查玩家是否处于透明模式（观察模式）
 * @return 如果PlayMode为1（透明模式）返回True，否则返回False
 */
function bool IsTransparent()
{
	if ( PSI != None && PSI.PlayMode == 1 )
		return True;
	return False;
}

/**
 * 游戏模式改变事件
 * 当玩家游戏模式改变时调用，更新Pawn的显示和碰撞状态
 */
event PlayModeChanged()
{
	if ( Pawn == None )
		return;
	// 如果切换到透明模式
	if ( IsTransparent() ) 
	{
		// 隐藏Pawn并禁用碰撞
		Pawn.bHidden = True;
		Pawn.SetCollision(False,False,False);
		Pawn.EnableChannelNotify(0,0);
	}
	else 
	{
		// 显示Pawn并启用碰撞
		Pawn.bHidden = False;
		Pawn.SetCollision(True,True,True);
		Pawn.EnableChannelNotify(0,1);
	}
}

/**
 * 更新比赛信息
 * 更新当前比赛的详细信息
 */
event UpdateMatchInfo();

/**
 * 精神施法结束
 * 精神技能施法结束时的回调
 * @param SpiritName 精神名称
 */
function SpiritCastEnd(string SpiritName);

/**
 * 地图改变前事件
 * 在地图切换前调用，用于清理资源
 */
event PreMapChange();

/**
 * 移除物品事件
 * 当从背包中移除物品时调用
 * @param Item 被移除的物品
 */
event OnRemoveInventoryItem(SephirothItem Item);

/**
 * 疼痛
 * 玩家受到伤害时的疼痛回调（空实现）
 */
function Pain()
{
}




function bool Start2ndSkillAction(Skill Skill, actor Target, vector TargetLocation)
{
	if( IsInState('SecondSkillAttacking') || !PSI.bIsAlive )
		return False;

	
	if( Character(Pawn).IsAvatar() && PSI.JobName != 'Bare' && PSI.JobName != 'Red' && PSI.JobName != 'Blue' ) 
	{
		if( Hero(Pawn).GetRightHand() == None )
		{
			myHud.AddMessage(2,Localize("Warnings","NeedArms","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			return False;
		}
	}

	if( Character(Pawn).IsAvatar() && PSI.Mana < Skill.ManaConsumption )
	{
		myHud.AddMessage(2,Localize("Warnings","NeedMana","Sephiroth")@Skill.SkillName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
		return False;
	}

	if ( Target != None && (Target.bWorldGeometry || Target.IsA('TerrainInfo') || Target.IsA('StaticMeshActor')) )
		Target = None;

	SecondSkill = Skill;
	SecondSkillTarget = Target;

	HitActorLocation = TargetLocation;

	if( SecondSkill(SecondSkill).SkillType == 6 )
	{
		Net.NotiTransform();
		return False;
	}
	else
		GotoState('SecondSkillAttacking', 'To2ndSkill');

	return True;
}


state SecondSkillAttacking extends Attacking
{
	ignores KeyboardMove,
	MovePawnToMove,
	MovePawnToTalk,
	MovePawnToAttackMelee,
	MovePawnToPick,
	MovePawnToTrace,
	MovePawnToAttackRange,
	MovePawnToAttackBow,
	FindNearestItem,
	Jump;

	function BeginState()
	{
		Super.BeginState();
		if (!PSI.ArmState)
			ToggleArmState();
	}

	function EndState()
	{
		RClickActionEnd();		
		if(PSI.ArmState)
			Hero(Pawn).DisArm();
		if(SecondSkill(SecondSkill).SkillType == 6)
		{
			Transformation();	
			SecondSkill(SecondSkill).bCharged = True;
		}
		Hero(Pawn).Arm();
	}

	function AnimEnd(int Channel)
	{
		Character(Pawn).bJustDamaged = False;
		Super.AnimEnd(Channel);
		GotoState('Navigating');
	}

	function AnimStep(int Channel)
	{
		if(SecondSkill(SecondSkill).SkillType == 2)
		{
			if(Character(Pawn).IsAvatar())
			{
				BroadCast2ndSkillHit(SecondSkill, SecondSkillTarget);
				SpawnExploEffect(SecondSkill, SecondSkillTarget, SecondSkillTarget.Location);
			}
		}
		else if (SecondSkill(SecondSkill).SkillType == 1 || SecondSkill(SecondSkill).SkillName == "RainbowArrow" ||
			SecondSkill(SecondSkill).SkillName == "PhantomFire" ) 
		{
			SpawnFireEffect(SecondSkill, SecondSkillTarget, HitActorLocation/*SecondSkillTarget.Location*/);
		}
		else if(SecondSkill(SecondSkill).SkillType == 3)
		{
			SpawnExploEffect(SecondSkill, SecondSkillTarget, Pawn.Location);
		}
	}

	function StartSecondSkill()
	{
		
		
		if(SecondSkill(SecondSkill).SkillName == "ManaRecovery"
			|| SecondSkill(SecondSkill).SkillName == "Increase"
			|| SecondSkill(SecondSkill).SkillName == "ManaBarrier")
		{
			if(Character(Pawn).IsAvatar())
			{
				SecondSkill(SecondSkill).bCharged = False;
				SecondSkill(SecondSkill).ChargeStartTime = Level.TimeSeconds;

				PlaySecondSkill();
			}
		}
		else
		{
			PlaySecondSkill();
		}
	}

	function PlaySecondSkill()
	{
		local vector TargetLoc;

		local float TotalFrames;
		local float DefaultRate;
		local float DesiredAnimTime;
		local float AnimRate;


		if(SecondSkill == None)
			return;

		TargetLoc = HitActorLocation;
		if(SecondSkillTarget != None)
		{
			if(SecondSkillTarget.IsA('Monster') || SecondSkillTarget.IsA('Hero'))
				TargetLoc = SecondSkillTarget.Location;
		}
		if(SecondSkill(SecondSkill).SkillType != 3 && SecondSkill(SecondSkill).SkillType != 5)
			RotatePawnTo(TargetLoc);

		if(Character(Pawn).IsAvatar() && SecondSkill(SecondSkill).SkillType != 6)
			BroadCast2ndSkillAct(SecondSkill, SecondSkillTarget);
		SpawnCastEffect(SecondSkill);

		
		if(SecondSkill.SkillName == "FireBurst" || SecondSkill.SkillName == "DistressArrow") 
		{
			if (Hero(Pawn).GetRightHand().IsA('CrossBow'))
				SecondSkill.AnimSequence = 'ShotC';
			else
				SecondSkill.AnimSequence = 'Shot';
		}

		if(SecondSkill.SkillName == "DeadlyCount" || (PSI.JobName == 'Bow' && SecondSkill(SecondSkill).Grade == 2) )
		{
			if (Hero(Pawn).GetRightHand().IsA('CrossBow'))
				SecondSkill.AnimSequence = 'ShotC';
			else
				SecondSkill.AnimSequence = 'Shot';
		}

		
		if(SecondSkill.SkillName == "RestraintShot" || (PSI.JobName == 'Bow' && SecondSkill(SecondSkill).Grade == 2) ) 
		{
			if (Hero(Pawn).GetRightHand().IsA('CrossBow'))
				SecondSkill.AnimSequence = 'ShotC';
			else
				SecondSkill.AnimSequence = 'Shot';
		}

		if(SecondSkill.SkillName == "RainbowArrow")
		{
			if (Hero(Pawn).GetRightHand().IsA('CrossBow'))
				SecondSkill.AnimSequence = 'ShotC30';
			else
				SecondSkill.AnimSequence = 'RainbowArrow';
		}

		DesiredAnimTime = 0.5; 
		Character(Pawn).AnimationInfo(SecondSkill.AnimSequence, TotalFrames, DefaultRate);
		AnimRate = TotalFrames / (DesiredAnimTime * DefaultRate);
		if(SecondSkill.SkillName == "Transformation")
			AnimRate = 1;

		Character(Pawn).PlayAnimAction(SecondSkill.AnimSequence, -1,AnimRate,0.3);
	}

	
	function BroadCast2ndSkillAct(Skill Skill, actor Target)
	{
		local int PanID;

		if(Skill == None || !Skill.IsA('SecondSkill'))
			return;
		if(SecondSkill(Skill).SkillType < 3 && Target == None)
			return;
		if(SecondSkill(Skill).SkillType == 6)
			return;

		if(Hero(Target) != None)
			PanID = ClientController(Character(Target).Controller).PSI.PanID;
		else if(Creature(Target) != None)
			PanID = ServerController(Character(Target).Controller).MSI.PanID;
		else
			PanID = 0;

		if(SecondSkill(Skill).SkillType == 5)
			PanID = PSI.PanID;

		if(Target != None)
			Net.NotiSkill2ndAct(Skill.SkillName, PanID, Target.Location);
		else if(SecondSkill(Skill).SkillType == 4)
			Net.NotiSkill2ndAct(Skill.SkillName, PanID, HitActorLocation);
		else
			Net.NotiSkill2ndAct(Skill.SkillName, PanID, Pawn.Location);
	}

	function BroadCast2ndSkillHit(Skill Skill, actor Target)
	{
		local int PanID;

		if(Skill == None || !Skill.IsA('SecondSkill'))
			return;
		if( SecondSkill(Skill).SkillType < 3 && Target == None)
			return;
		if(!Hero(Pawn).IsAvatar())
			return;

		if(Hero(Target) != None)
			PanID = ClientController(Character(Target).Controller).PSI.PanID;
		else if(Creature(Target) != None)
			PanID = ServerController(Character(Target).Controller).MSI.PanID;
		else
			PanID = 0;

		if(Target != None)
			Net.NotiSkill2ndHit(Skill.SkillName, PanID, Target.Location);
	}


	function PlayerMove(float DeltaTime)
	{
		aForward = 0;
		aStrafe = 0;
		Character(Pawn).bJustDamaged = False;
		Super.PlayerMove(DeltaTime);
	}

To2ndSkill:
	StartSecondSkill();
}

/**
 * 击退状态
 * 玩家被击退时进入此状态，禁止所有移动和交互操作
 * 直到击退动画播放完成
 */
state Knockbacking extends Navigating
{
	ignores KeyboardMove,        // 忽略键盘移动
	MovePawnToMove,              // 忽略鼠标移动
	MovePawnToTalk,              // 忽略对话移动
	MovePawnToAttackMelee,       // 忽略近战攻击移动
	MovePawnToPick,              // 忽略拾取移动
	MovePawnToTrace,             // 忽略追踪移动
	MovePawnToAttackRange,       // 忽略远程攻击移动
	MovePawnToAttackBow,         // 忽略弓箭攻击移动
	FindNearestItem,             // 忽略寻找物品
	Jump;                        // 忽略跳跃

	function BeginState()
	{
		// 状态开始时可以添加日志或特效
	}

	function EndState()
	{
		// 状态结束时恢复控制
		Character(Pawn).bJustDamaged = False;
	}

	function PlayerMove(float DeltaTime)
	{
		local name AnimName;
		local float AnimFrame, AnimRate;
		
		// 强制清除移动输入，确保无法移动
		aForward = 0;
		aStrafe = 0;
		
		// 作为备用机制：检查当前动画，如果已经切换到 Idle，退出状态
		// 这样可以防止 AnimEnd 没有被正确触发的情况
		Pawn.GetAnimParams(0, AnimName, AnimFrame, AnimRate);
		if (AnimName == 'Idle')
		{
			// 如果动画已经切换到 Idle，说明击退动画已经完成，退出状态
			Character(Pawn).CHAR_TweenToWaiting(0.1);
			GotoState('Navigating');
			return;
		}
		
		Super.PlayerMove(DeltaTime);
	}
	
	/**
	 * 动画结束事件
	 * 当击退动画播放完成时，自动退出击退状态
	 */
	function AnimEnd(int Channel)
	{
		local name AnimName;
		local float AnimFrame, AnimRate;
		
		Pawn.GetAnimParams(Channel, AnimName, AnimFrame, AnimRate);
		
		//DebugLog("Knockbacking AnimEnd: "$AnimName);
		
		// 如果击退动画结束，或者已经切换到后续动画（Pain/Idle），退出击退状态
		// 因为击退动画播放完成后，系统会自动切换到 Pain 或 Idle 动画
		if (AnimName == 'Knockback' || AnimName == 'Pain' || AnimName == 'Idle')
		{
			Character(Pawn).CHAR_TweenToWaiting(0.1);
			GotoState('Navigating');
		}
		else
		{
			// 其他动画结束事件交给父类处理
			Super.AnimEnd(Channel);
		}
	}
}

/**
 * 网络接收开始第二技能动作
 * @param Skill 技能对象
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 */
event NetRecv_Start2ndSkillAct(Skill Skill, character Target, vector TargetLoc)
{
	
	
	if ( Skill != None ) 
	{
		Character(Pawn).bJustDamaged = False;
		Pawn.Acceleration = vect(0,0,0);
		Start2ndSkillAction(Skill, Target, TargetLoc);
	}
}

/**
 * 网络接收第二技能命中
 * @param Skill 技能对象
 * @param Target 目标角色
 * @param TargetLoc 目标位置
 */
event NetRecv_Start2ndSkillHit(Skill Skill, character Target, vector TargetLoc)
{
	if( Skill != None && Skill.IsA('SecondSkill') )
	{
		
		if( SecondSkill(Skill).SkillType == 2 )
			SpawnExploEffect(Skill, Target, TargetLoc);
	}
}

event NetRecv_SetActiveSkillCoolTime(Skill Skill)
{
	
	if( Character(Pawn).IsAvatar() )
	{
		SecondSkill(Skill).bCharged = False;
		SecondSkill(Skill).ChargeStartTime = Level.TimeSeconds;
	}
}





function SpawnEggGlow()
{
	local class<Actor> EffectClass;
	local Emitter Effect;

	if ( Pet == None || Pet.bDeleteMe )
		return;

	EffectClass = class<Actor>(DynamicLoadObject("SpecialFx.Pet_Egg",class'Class'));
	if( EffectClass == None )
		return;
	Effect = Emitter(Spawn(EffectClass, Pet, , Pet.Location, Pet.Rotation));
	Pet.GlowEffect = Effect;
	Effect.SetBase(Pet);
}

function SpawnPetInOutEffect(string MeshName)
{
	local class<Actor> Effect;

	
	if ( !Character(Pawn).IsAvatar() ) 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	if( MeshName == "Egg" || MeshName == "egg" ) 
	{
		if ( Pet == None || Pet.bDeleteMe )
			return;
		Effect = class<Actor>(DynamicLoadObject("SpecialFx.Pet_egg_Inventoryinout",class'Class'));
		if( Effect != None )
			Spawn(Effect, Pet, , Pet.Location, Pet.Rotation);
	}
	else if(MeshName != "Egg" && MeshName != "egg") 
	{
		if ( SPet == None || SPet.bDeleteMe )
			return;
		Effect = class<Actor>(DynamicLoadObject("SpecialFx.Pet_InOut_Inventory",class'Class'));
		if( Effect != None )
			Spawn(Effect, SPet, , SPet.Location, SPet.Rotation);
	}

}

function SpawnPetChangeEffect(string MeshName)
{
	local class<Actor> Effect;
	if( /*PetSI == None || */SPet == None || SPet.bDeleteMe )
		return;

	
	if ( !Character(Pawn).IsAvatar() ) 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
			return;
	}
	
	else 
	{
		if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) == 3 )
			return;
	}

	if( MeshName == "Puppy_Black" || MeshName == "Puppy_White" || MeshName == "Puppy_Brown" )
		Effect = class<Actor>(DynamicLoadObject("SpecialFx.Pet_egg_ToPet",class'Class'));
	else
		Effect = class<Actor>(DynamicLoadObject("SpecialFx.Pet_FirstConversion",class'Class'));
	if( Effect == None )
		return;
	Spawn(Effect, SPet, , SPet.Location, SPet.Rotation);
}

function bool Pet_Create()
{
	local vector PetLocation;

	if( PetSI.MeshName == "Egg" )
	{
		Pet = Spawn(class'Pet', Pawn, , Pawn.Location, Pawn.Rotation);
		if( Pet == None )
			return False;
		Pet.SetBase(Pawn);
	}
	else
	{
		PetLocation = Pawn.Location + (vect(200,0,0) >> Pawn.Rotation);
		SPet = Spawn(class'Guardian'/*, , , PetLocation, Pawn.Rotation*/);
		if( SPet == None )
			return False;

		SPet.SetOwnPlayer(Character(Pawn));
		PetController = Spawn(class'PetController',Pawn);
		if( PetController == None )
			return False;
		
	}
	return True;
}

function Pet_Destroy()
{

	if( Pet != None && !Pet.bDeleteMe )
	{
		if( Pet.GlowEffect != None && !Pet.GlowEffect.bDeleteMe )
		{
			Pet.GlowEffect.SetBase(None);
			Pet.GlowEffect.Destroy();
			Pet.GlowEffect = None;
		}
		Pet.SetBase(None);
		Pet.Destroy();
		Pet = None;
	}
	if ( PetController != None && !PetController.bDeleteMe ) 
	{
		if ( PetController.Pawn != None ) 
		{
			PetController.Pawn.SetOwner(None);
			PetController.Pawn.Controller = None;
			Guardian(PetController.Pawn).SetOwnPlayer(None);
			Guardian(PetController.Pawn).Destroy();
			PetController.Pawn = None;
			SPet = None;
		}
		PetController.SetOwner(None);
		PetController.Destroy();
		PetController = None;
	}
	/*
	if(PetController != None)
	{
		PetController.SetOwner(None);
		PetController.Pawn = None;
		PetController.Destroy();
		PetController = None;
	}
	*/
	if( SPet != None && !SPet.bDeleteMe )
	{
		SPet.SetOwnPlayer(None);
		SPet.Controller = None;
		SPet.SetOwner(None);
		SPet.Destroy();
		SPet = None;
	}
	if ( PetSI != None && !PetSI.bDeleteMe ) 
	{
		PetSI.SetOwner(None);
		PetSI.Destroy();
		PetSI = None;
	}
}

/**
 * 改变宠物网格
 * @param MeshName 网格名称
 * @param AnimName 动画名称
 * @return 是否成功
 */
function bool Pet_ChangeMesh(string MeshName, string AnimName)
{
	local vector PetLocation;
	local vector TempOffset;
	local string SkinColor;

	
	if( MeshName == "Egg" && Pet != None && !Pet.bDeleteMe ) 
	{
		TempOffset = vect(0, -20, 0);
		TempOffset.Z = Pawn.CollisionHeight - 20;
		Pet.SetRelativeLocation(TempOffset);
		if( Pet.ChangePetMesh(MeshName, AnimName) ) 
		{

			return True;
		}
	}
	else 
	{
		if( MeshName == "Banderscon" || MeshName == "Coromon" || MeshName == "Drake" || MeshName == "MiniLycan" )
		{
			
			if( PetSI.PetColor == 0 )
				SkinColor = "-White";
			else if(PetSI.PetColor == 1)
				SkinColor = "-Red";
			else if(PetSI.PetColor == 2)
				SkinColor = "-Blue";
			else if(PetSI.PetColor == 3)
				SkinColor = "-Yellow";
			else if(PetSI.PetColor == 4)
				SkinColor = "-Black";
			if( SkinColor != "" )
				MeshName = MeshName$SkinColor;
		}
		if( SPet != None && !SPet.bDeleteMe && SPet.ChangePetMesh(MeshName, AnimName) ) 
		{
			SPet.SetPosition(1);
			PetLocation = Pawn.Location + ((SPet.LocationOffset + vect(-100,0,0)) >> Pawn.Rotation);
			
			SPet.SetLocation(PetLocation);
			SPet.SetRotation(Pawn.Rotation);
			if ( PetController != None && !PetController.bDeleteMe ) 
			{
				PetController.Possess(SPet);
				PetController.RecallPet();
			}
			return True;
		}
	}
	return False;
}

event NetRecv_PetMovedIn()
{
	if( PetSI == None )
		return;
	if( !Pet_Create() )
	{

		Pet_Destroy();
		return;
	}
	if( !Pet_ChangeMesh(PetSI.MeshName, PetSI.AnimName) ) 
	{

		Pet_Destroy();
	}
}

event NetRecv_PetMovedOut()
{
	Pet_Destroy();
}


event NetRecv_PetInvenResize(int Width, int Height);
event OpenPetDialogInterface();


function OnPetCreate();
function OnPetDestroy();


/**
 * 网络接收创建宠物
 */
event NetRecv_PetCreate()
{
	if( PetSI == None )
		return;

	
	if( !Pet_Create() ) 
	{

		Pet_Destroy();
		return;
	}
	
	if( Pet_ChangeMesh(PetSI.MeshName, PetSI.AnimName) )
	{
		SpawnPetInOutEffect(PetSI.MeshName);
		if( Pet != None )
			SpawnEggGlow();
		OnPetCreate();
	}
	else 
	{

		Pet_Destroy();
	}
}


event NetRecv_PetDestroy()
{
	
	SpawnPetInOutEffect(PetSI.MeshName);

	Pet_Destroy();

	OnPetDestroy();
}

event NetRecv_PetChange()
{
	if( PetSI == None || (Pet == None && SPet == None) )
		return;

	if( SPet != None && PetSI.MeshName == string(SPet.MeshName) )
		return;

	if( Pet != None && Pet.GlowEffect != None )
	{
		Pet.GlowEffect.Destroy();
		Pet.GlowEffect = None;
	}

	if( Pet != None )
	{
		SpawnPetInOutEffect(string(Pet.MeshName));
		if( Pet != None )
		{
			if( Pet.GlowEffect != None )
			{
				Pet.GlowEffect.SetBase(None);
				Pet.GlowEffect.Destroy();
				Pet.GlowEffect = None;
			}
			Pet.SetBase(None);
			Pet.Destroy();
			Pet = None;
		}
		if( PetController != None )
		{
			PetController.Destroy();
			PetController = None;
		}

		if( !Pet_Create() ) 
		{

			Pet_Destroy();
			return;
		}
	}

	if( Pet_ChangeMesh(PetSI.MeshName, PetSI.AnimName) )
	{
		SpawnPetChangeEffect(PetSI.MeshName);

		CInterface(myHud).LoadPetfaceTexture();
	}
	else 
	{

		Pet_Destroy();
	}
}

event PetTest(string MeshName)
{
	local vector PetLocation;

	PetController = Spawn(class'PetController',Pawn);
	if( PetController == None )
		return;
	SPet = Spawn(class'Guardian');
	if( SPet == None )
		return;
	if( InStr(MeshName,"Puppy") != -1 )
		SPet.ChangePetMesh(MeshName, "Puppy");
	else
		SPet.ChangePetMesh(MeshName,MeshName);
	SPet.SetPosition(1);
	PetLocation = SPet.LocationOffset;
	PetLocation.Y += 300;
	SPet.SetLocation(Pawn.Location + (PetLocation >> Pawn.Rotation));
	SPet.SetRotation(Pawn.Rotation);
	PetController.Possess(SPet);
	PetController.RecallPet();
}

exec function PetChange(string MeshName)
{
	if( SPet == None )
		return;
	Pet_ChangeMesh(MeshName, MeshName);
}

event PetPosition(int Radius)
{
	if( SPet != None ) 
	{
		SPet.PetRadius = Radius;
	}
}

event PetAction(string ActionName)
{


	PetController.PetAction(StrToName(ActionName));
}



event NetRecv_StartStun(bool bySelf);
event NetRecv_FinishStun(bool bySelf);



event NetRecv_PlaySound(string SoundName)
{
	local Sound Sound;
	local string SoundString;

	if( InStr(SoundName,".") != -1 ) 
	{
		SoundString = SoundName;
	}
	else 
	{
		SoundString = "InterfaceSound.";
		SoundString = SoundString$SoundName;
	}

	Sound = Sound(DynamicLoadObject(SoundString, class'Sound'));
	if( Sound != None )
		Pawn.PlaySound(Sound);
}

/**
 * 变形（变身）
 */
exec function Trans()
{
	SecondSkill = SecondSkill(PSI.SecondSkillBook.QuerySkillByName("Transformation"));
	SpawnEffect("Transformation");
	SecondSkillTarget = None;
	GotoState('SecondSkillAttacking', 'To2ndSkill');
}

/**
 * 解除变形
 */
exec function UnTrans()
{
	UnTransformation();
	if( !(bool(ConsoleCommand("GETOPTIONI ArmHelmet"))) )
		Hero(Pawn).DisArmByTransformation();

	Hero(Pawn).Arm();
}

/**
 * 网络接收变形启用状态
 * @param bTransEnable 是否启用变形
 */
event NetRecv_TransformEnable(bool bTransEnable)
{
	local Skill skill;
	skill = PSI.SecondSkillBook.QuerySkillByName("Transformation");
	if( skill != None )
	{
		if( bTransEnable )
			skill.bEnabled = True;
		else
			skill.bEnabled = False;
	}

}
event NetRecv_ScreenEffectStart(int Id, int R, int G, int B, int A);
event NetRecv_ScreenEffectEnd(int Id);

event NetRecv_Transformation(bool bTrans)
{
	local Skill skill;
	local int i;
	if( bTrans ) 
	{
		if( Character(Pawn).IsAvatar() ) 
		{
			skill = PSI.SecondSkillBook.QuerySkillByName("Transformation");
			skill.bEnabled = False;
		}
		else 
		{
			for( i = 0; i < GameManager(Level.Game).Static2ndSkillBooks.length; i++ ) 
			{
				skill = GameManager(Level.Game).Static2ndSkillBooks[i].QuerySkillByName("Transformation");
				if( skill != None )
					break;
			}
		}
		SecondSkill = skill;
		SecondSkillTarget = None;
		GotoState('SecondSkillAttacking', 'To2ndSkill');
	}
	else 
	{
		UnTransformation();	
		if( !(bool(ConsoleCommand("GETOPTIONI ArmHelmet"))) )
			Hero(Pawn).DisArmByTransformation();
		Hero(Pawn).Arm();
	}
}



event NetRecv_UpdateUsedReputationPoint(int nPoint)
{
	PSI.nUsedReputationPoint = nPoint;
}

event NetRecv_UpdateCurrReputationPoint(int nPoint)
{
	PSI.nCurrReputationPoint = nPoint;
}





event ChangeManaState();

event UpdateChannel(bool bForceOn, bool bLeftEar);		


simulated function BattleNotiPlayerKillMessage(string killPlayerName, string killPlayerTeam, string deathPlayerName, string deathPlayerTeam);

/**
 * 设置自定义UI绘制状态
 * @param bVisible 是否可见
 */
simulated function SetCustomBrowserVisible(bool bVisible);

/**
 * 设置自定义UI内容
 * @param content 内容
 */
simulated function SetCustomBrowserContent(string content);

event OnUpdatePkPts(int type, int value)		
{
	local string message;
	local color msgcolor;
	

	switch(type) 
	{		
		
		case PCPVPPkPts:
			PSI.PkPts = value;
			break;
		case PCMaxPvpInfo:	
			PSI.PkPtsMax = value;
			break;
		case PCPVPKills:
			PSI.Kills = value;
			break;
		case PCPVPDeads:
			PSI.Deads = value;
			break;
		case PCPVPMatch:
			PSI.Match = value;
			break;
		case PCPVPWin:
			PSI.Win = value;
			break;
		case PCPVPLose:
			PSI.Lose = value;
			break;
		case PCPVPDraw:
			PSI.Draw = value;
			break;
	}



	if( USAVersion == 0 )
		return;










	else if(type == PCPVPPkPts) 
	{		
		
		if( bIsPlayer )	
		{
			msgcolor = class'Canvas'.Static.MakeColor(252,241,44);
			message = Localize("Terms","CurrentPKPts","Sephiroth")@":"@value;

			GameManager(Level.Game).PlayerOwner.myHUD.AddMessage(2, message, msgcolor);
		}
	}

	









	
	Character(Pawn).UpdateHaloEffectShader(PSI.GetHaloEffectShaderName());
}

event OnUpdateCanPVP(bool CanPVP)
{
	local color msgcolor;

	PSI.CanPVP = CanPVP;

	if( USAVersion == 0 )
		return;

	







	if( bIsPlayer )
	{
		msgcolor = class'Canvas'.Static.MakeColor(252,241,44);

		if( CanPVP )
			GameManager(Level.Game).PlayerOwner.myHUD.AddMessage(2, Localize("Information","PVPRequirementOn","Sephiroth"), msgcolor);
		else
			GameManager(Level.Game).PlayerOwner.myHUD.AddMessage(2, Localize("Information","PVPRequirementOff","Sephiroth"), msgcolor);
	}

	
	if( !PSI.CanPVP && PSI.PkState )
	{
		TogglePkState();
	}
}



native event OnSerialize();


event OnUpdateHPGauge(int gauge_effect);




event NetRecv_PetAutoPotion_UpdateHPSetting(int value);
event NetRecv_PetAutoPotion_UpdateMPSetting(int value);


event NetRecv_NotiEnterMatch(string MatchName, int remain_sec);	
event NetRecv_NotiMatchWait(string MatchName, int WaitTime);		
event NetRecv_NotiStartMatch(string MatchName, int DurationTime);			
event NetRecv_NotiEndMatch(string MatchName, int Result, int MatchWaitQuitTime);			
event NetRecv_NotiUpdateMatchScore(string MatchName, int KTeamScore, int DTeamScore);		
event NetRecv_NotiPlayerKillMessage(string MatchName, string Kill_player_Name, string kill_player_Team, string death_player_Name, string death_player_team);	

event NetRecv_NotiResponeOtp(int Otp, int ServerID);		
event NetRecv_NotiResponeconfirmNewGrantItem(int nNewGrantItem);	
event NetRecv_NotiRandomBoxResult( string strTypeName, string strModelName, string LocalizedDescription );	


event NetRecv_NotiSubInvenInfoUpdate(int Index, string EndTime, int Validity, bool bCommandOpen);

event NetRecv_NotiDissolveOpen( string strCategoryName );


event NetRecv_NotiDissolveResult( int nErrCode, array<string> strItem, array<string> strModel, array<int> nItemCount );
event NetRecv_NotiExtendedCMD(string cmd);



event EnchantBox_AddEnchant(name enchant_name)
{
	EnchantBox.AddEnchant(enchant_name);
}

event EnchantBox_RemoveEnchant(name enchant_name)
{
	EnchantBox.RemoveEnchant(enchant_name);
}


event OnUpdateUI_EnchantBox()
{
	
}



event InitUnreadCounts()	
{

	nNoteUnread = 0;
	nHelperUnread = 0;
}


event UpdateUnreadNoteCount(bool bIncr)	
{

	if ( bIncr )
		nNoteUnread++;
	else if ( nNoteUnread > 0 )
		nNoteUnread--;
}


event UpdateUnreadHelperCount(bool bIncr)	
{

	if ( bIncr )
		nHelperUnread++;
	else if ( nHelperUnread > 0 )
		nHelperUnread--;
}

event RemoveNote(int nID)	
{

	local int i;

	for ( i = 0 ; i < InBoxNotes.Length ; i++ )	
	{

		if ( InBoxNotes[i].NoteID == nID )	
		{

			
			if ( !InBoxNotes[i].bRead )	
			{

				if ( InStr(InBoxNotes[i].From, "SYS@") == -1 )		
					nNoteUnread--;
				else												
					nHelperUnread--;
			}

			InBoxNotes.Remove(i, 1);
			break;
		}
	}

}

event ReadNote(int nID)	
{

	local int i;

	for ( i = 0 ; i < InBoxNotes.Length ; i++ )	
	{

		if ( InBoxNotes[i].NoteID == nID )	
		{

			if ( InBoxNotes[i].bRead != True )	
			{
			
				InBoxNotes[i].bRead = True;

				
				if ( InStr(InBoxNotes[i].From, "SYS@") == -1 )		
					nNoteUnread--;
				else												
					nHelperUnread--;

				break;
			}
		}
	}
}

event int GetSymbolFromQuests(string strNPC)
{
	local int n;

	for ( n = 0 ; n < LiveQuests.Length ; n++ )
	{
		if ( LiveQuests[n].strNpcName == strNPC )
			return LiveQuests[n].nSymbol;
	}
	return 0;
}




/**
 * 检查任务是否已完成
 * @param strStepName 步骤名称
 * @return 是否已完成
 */
event bool IsQuestFinished(string strStepName)
{
	local int n;

	for ( n = 0 ; n < DoneQuests.Length ; n++ )
	{
		if ( DoneQuests[n].strStepName == strStepName )
			return True;
	}
	return False;
}



/**
 * 检查任务是否正在进行中
 * @param strStepName 步骤名称
 * @return 是否正在进行中
 */
event bool IsQuestInProgress(string strStepName)
{
	local int n;

	for ( n = 0 ; n < LiveQuests.Length ; n++ )
	{
		if ( LiveQuests[n].strStepName == strStepName )
			return True;
	}
	return False;
}


event SetOwnedQuestInfo(int nIndex, string strStepName, int nStepValue, string strNpc, int nSymbol, string strLocaleName, string strHudTitle, string strHudDesc, array<int> aProgressCount)
{
	if ( nIndex >= LiveQuests.Length )
		LiveQuests.Insert(LiveQuests.Length, 1);

	LiveQuests[nIndex].strStepName = strStepName;
	LiveQuests[nIndex].nStepValue = nStepValue;
	LiveQuests[nIndex].strNpcName = strNpc;
	LiveQuests[nIndex].nSymbol = nSymbol;
	LiveQuests[nIndex].strLocaleName	= strLocaleName;
	LiveQuests[nIndex].strHudTitle = strHudTitle;
	LiveQuests[nIndex].strHudDesc = strHudDesc;

	LiveQuests[nIndex].aProgressCount	= aProgressCount;

	if( nStepValue == 0 )	
		LiveQuests[nIndex].bShowMain = False;

	LiveQuests[nIndex].nLastUpdateTime	= Level.TimeSeconds;	
}

event SetOwnedQuestInfoShow(int nIndex, string strStepName, int nStepValue, string strNpc, int nSymbol, string strLocaleName, string strHudTitle, string strHudDesc, array<int> aProgressCount)
{
	if ( nIndex >= LiveQuests.Length )
		LiveQuests.Insert(LiveQuests.Length, 1);

	LiveQuests[nIndex].strStepName = strStepName;
	LiveQuests[nIndex].nStepValue = nStepValue;
	LiveQuests[nIndex].strNpcName = strNpc;
	LiveQuests[nIndex].nSymbol = nSymbol;
	LiveQuests[nIndex].strLocaleName	= strLocaleName;
	LiveQuests[nIndex].strHudTitle = strHudTitle;
	LiveQuests[nIndex].strHudDesc = strHudDesc;
	LiveQuests[nIndex].aProgressCount	= aProgressCount;

	if( nStepValue == 0 )	
		LiveQuests[nIndex].bShowMain = False;
	else
		LiveQuests[nIndex].bShowMain = True;

	LiveQuests[nIndex].nLastUpdateTime	= Level.TimeSeconds;	
}

/**
 * 删除任务信息
 * @param StepName 步骤名称
 */
event DeleteQuestInfo(string StepName)
{
	local int nIndex;
	local int n;

	for ( n = 0 ; n < LiveQuests.Length ; n++ )
	{
		if ( LiveQuests[n].strStepName == StepName )
		{
			LiveQuests.Remove(n, 1);
		}
	}
}



/**
 * 设置任务进度计数
 * @param nIndex 任务索引
 * @param nSubIndex 子索引
 * @param nCount 计数
 * @param strDesc 描述
 */
event SetProgressCount(int nIndex, int nSubIndex, int nCount, string strDesc)
{
	LiveQuests[nIndex].aProgressCount[nSubIndex]	= nCount;
	LiveQuests[nIndex].nLastUpdateTime	= Level.TimeSeconds;	
	LiveQuests[nIndex].strHudDesc = strDesc;
}


/**
 * 设置已完成的任务信息
 * @param nIndex 索引
 * @param strStepName 步骤名称
 */
event SetFinishedQuestInfo(int nIndex, String strStepName)
{
	DoneQuests[nIndex].strStepName = strStepName;
}




/**
 * 检查是否可以使用所有技能
 * @return 是否可以使用
 */
function bool CanUseAllSkill();
/**
 * 检查是否可以使用第二技能
 * @return 是否可以使用
 */
function bool CanUse2ndSkill();
/**
 * 检查是否可以使用物品
 * @return 是否可以使用
 */
function bool CanUseItemNow();

defaultproperties
{
	MaxCameraDist=24
	MinCameraDist=4
	CameraHeight=44
	ComboCount=-1
	CoolTime=-1.000000
	BoothToutCount=-1
	bBehindView=True
	bFreeCamera=True
	CameraDist=12.000000
	CheatClass=Class'Sephiroth.ClientCheat'
}
