/*=======================================================

	SephirothController
	Sephiroth control interface defined
	(c)2002-2003 Imazic Entertainment. All Rights Reserved

	History:
		Long days ago,	jhjung created
		March, 2003		woojin modified
		2003.4.21		jhjung refactoring

========================================================*/

class SephirothController extends CInterfaceController;

var int debugCount;

var float DetectStartTime, ReleaseStartTime;
var float DetectInterval, ReleaseInterval;
var float CancelDelta;

var LockupDecal Decal, DecalAfter;

var EInputKey InteractionKey;
var bool bReverseKeyPressed;

var int m_Language;
var float ProbeTicks;

const Korean = 1;
const SimplifiedChinese = 2;
const TraditionalChinese = 3;

var EInputKey ItemPickupKey;
var EInputKey ArmKey;

//@cs added for auto pickup
var bool bAutoPickup;
var float fTimePicking;
var array<string> PickupItems;
var array<string> NotPickupItems;

//@cs added for auto Attack
var bool bPluginAutoAttackEnabled;
//var array<bool> bPluginAutoEnChantEnabled;
var bool bPluginAutoEnChantEnabled;
var bool bPluginAutoEnChantEnabled1;
var bool bPluginAutoEnChantEnabled2;

var float fTimeAttacking; 
var bool bPluginAutoAttack;
var bool bPluginAutoCast;
var Skill PrevMagicBackup;
var Skill UsedMagicBackup;
var float fTimeEnchanting;
var float fTimeAutoAttack;
var bool bIsKeyMoving;

//@cs added for auto drink
var float fTimeDrinking;

//@cs added for auto chat
var bool bPluginAutoChatEnabled;
var float fTimeChating;
var array<string> Illegals;

var struct TraceContext 
	{
		var actor Actor;
		var vector Location;
		var vector Normal;
		var float MouseX;
		var float MouseY;
		var bool Dirty;
	} 
	ActionContext, HoverContext, NextActionContext;	//@by wj(040114) NextActionContext ���� ����� ������ �� �׼��� ���� �ϱ� ����

var bool bRightClickActing;		//@by wj(040113)
var bool bFinishInteraction;		//@by wj(040113)

var bool bLostControl;	//@by wj(040303) for stun -player lost control-

//add neive : ���� �ɽ�Ʈ -----------------------------------------------------
var bool bAutoCast;
const OnAutoCast = 3;
var int nAutoCastCount;
var float AutoCastStartTime; // ���� �ɽ����� ���۵� �ð�
//-----------------------------------------------------------------------------

var float fMouseRClickX, fMouseRClickY;		// ��Ŭ�� �������� üũ�� ���콺 ��ġ ���� Xelloss
var bool bMagicUsed;

var bool bPickingKeyPressed;
var float timePicking;
var float timeDrinkingBloodDelay;   //dont drink too much one time
var float timeDrinkingMagicDelay;   //dont drink too much one time
var CTextFile FileLoader;

enum EFilterResult
{
	FR_None,
	FR_Movable,
	FR_Attackable,
	FR_Talkable,
	FR_Pickable,
	FR_NotOwnedPickable,
	FR_Self,
	FR_Enchantable,
	FR_OwnedGuardStone
};

enum EInteractType
{
	IT_None,
	IT_Move,
	IT_AttackMelee,
	IT_AttackRange,
	IT_Talk,
	IT_Pick,
	IT_Enchant,
	IT_AttackBow,
};

event Initialized()
{
	local string LangExt;
	local int i;

	debugCount = 0;

	Super.Initialized();
	GotoState('Standing');

	LangExt = ViewportOwner.Actor.ConsoleCommand("LANGEXT");
	if ( LangExt == "KOR" )
		m_Language = Korean;
	else if (LangExt == "CHN")
		m_Language = SimplifiedChinese;
	else if (LangExt == "CHT")
		m_Language = TraditionalChinese;

	if ( m_Language == Korean )
		ItemPickupKey = IK_Shift;
	else
		ItemPickupKey = IK_Z;

	ArmKey = IK_Tilde;

	bAutoCast = False; //add neive : ���� �ɽ�Ʈ
	AutoCastStartTime = 0;

	timePicking = ViewportOwner.Actor.Level.TimeSeconds; // Xelloss

	//@cs added for plugin
	bAutoPickup = class'PagePlugin'.Default.bAutoPickupSwitch; //cd added
	fTimePicking = ViewportOwner.Actor.Level.TimeSeconds;	
	timeDrinkingBloodDelay = ViewportOwner.Actor.Level.TimeSeconds;
	timeDrinkingMagicDelay = ViewportOwner.Actor.Level.TimeSeconds;
	//class'CMessageBox'.static.MessageBox(Self,"debug","debuginfo:"@string(class'PagePlugin'.default.bAutoPickupSwitch),MB_Ok);
	for( i = 0;i < class'PagePlugin'.Default.arrayPickupItems.Length;++i )
	{
		PickupItems[i] = class'PagePlugin'.Default.arrayPickupItems[i].strLocaleName;
	}
	for( i = 0;i < class'PagePlugin'.Default.arrayNoPickupItems.Length;++i )
	{
		NotPickupItems[i] = class'PagePlugin'.Default.arrayNoPickupItems[i].strLocaleName;
	}

	//@cs added for plugin  auto Attack
	bPluginAutoAttackEnabled = class'PageAttack'.Default.bPluginAutoAttack;
	fTimeAttacking = ViewportOwner.Actor.Level.TimeSeconds;
	bPluginAutoEnChantEnabled = class'PageAttack'.Default.bPluginAutoEnchant;
	bPluginAutoEnChantEnabled1 = class'PageAttack'.Default.bPluginAutoEnchant1;
	bPluginAutoEnChantEnabled2 = class'PageAttack'.Default.bPluginAutoEnchant2;
	bIsKeyMoving = False;

	fTimeEnchanting = ViewportOwner.Actor.Level.TimeSeconds;
	fTimeDrinking = ViewportOwner.Actor.Level.TimeSeconds;
	fTimeAutoAttack = ViewportOwner.Actor.Level.TimeSeconds;
	fTimeChating = -300;//always enable first auto chat
	LoadIllegalText();
}

function SwitchingPickupKey()
{
	if( ItemPickupKey == IK_Shift )
	{
		ItemPickupKey = IK_Tilde;
		ArmKey = IK_Shift;
	}
	else
	{
		ItemPickupKey = IK_Shift;
		ArmKey = IK_Tilde;
	}
}

/**
 * 追踪并创建上下文函数
 * 从鼠标屏幕位置发射射线追踪，检测鼠标指向的游戏世界中的目标
 * 
 * @param TC 输出的追踪上下文，包含追踪到的Actor、碰撞位置、法线等信息
 * @param DirectionalScale 追踪距离缩放因子（单位：Unreal单位）
 *                       例如：5000表示追踪距离为5000单位
 * @param Situation 追踪调用情况类型（ETraceCallSituation枚举）
 *                 - TCST_Click: 点击追踪（左键按下时）
 *                 - TCST_Reserved2: 普通悬停追踪（鼠标移动时）
 *                 用于区分不同的追踪场景，可能影响追踪行为
 * 
 * 工作流程：
 * 1. 获取摄像机位置作为射线起点
 * 2. 将鼠标屏幕坐标转换为世界空间方向向量
 * 3. 从起点向鼠标方向发射射线，追踪第一个碰撞到的Actor
 * 4. 将追踪结果保存到TraceContext中
 * 
 * 注意：TraceEx是native函数，只返回第一个碰撞到的Actor
 *       如果友方和敌方重叠，会优先返回距离更近的（通常是友方）
 */
function TraceAndMakeContext(out TraceContext TC, float DirectionalScale, Actor.ETraceCallSituation Situation)
{
	local vector ViewOrigin;		// 射线起点：摄像机/玩家位置
	local vector Direction;		// 射线方向：从屏幕坐标转换而来的世界空间方向向量
	local vector MousePos;		// 鼠标屏幕坐标（X, Y）

	// ========== 第一步：获取射线起点 ==========
	// 使用玩家/摄像机的当前位置作为射线追踪的起点
	ViewOrigin = ViewportOwner.Actor.Location;

	// ========== 第二步：获取鼠标屏幕坐标 ==========
	// 将鼠标的屏幕坐标（像素坐标）保存到向量中
	// MouseX, MouseY 是当前鼠标在屏幕上的位置
	MousePos.X = MouseX;
	MousePos.Y = MouseY;

	// ========== 第三步：屏幕坐标转世界方向 ==========
	// 将鼠标的屏幕坐标转换为世界空间中的方向向量
	// 这个方向向量表示从摄像机指向鼠标指向的世界空间方向
	Direction = ScreenToWorld(MousePos);

	// ========== 第四步：执行射线追踪 ==========
	// TraceEx: native函数，执行射线追踪
	// 参数说明：
	//   - TC.Location: 输出参数，碰撞点的世界坐标位置
	//   - TC.Normal: 输出参数，碰撞点的法线向量
	//   - Situation: 追踪情况类型，用于区分不同的追踪场景
	//   - ViewOrigin + DirectionalScale * Direction: 射线终点
	//     从起点(ViewOrigin)沿方向(Direction)延伸DirectionalScale距离
	//   - ViewOrigin: 射线起点
	//   - True: bTraceActors参数，表示追踪Actor（包括玩家、怪物等）
	// 
	// 返回值：第一个碰撞到的Actor，如果没有碰撞到任何物体则返回None
	// 注意：如果多个Actor重叠，只返回距离最近的第一个
	TC.Actor = ViewportOwner.Actor.TraceEx(TC.Location, TC.Normal, Situation, ViewOrigin + DirectionalScale * Direction, ViewOrigin, True);

	// ========== 第五步：保存鼠标坐标到上下文 ==========
	// 将当前鼠标位置保存到追踪上下文中，用于后续处理
	TC.MouseX = MouseX;
	TC.MouseY = MouseY;

	// ========== 第六步：标记追踪结果状态 ==========
	// 如果追踪没有命中任何Actor，标记为Dirty（无效）
	// 如果追踪到了Actor，标记为有效
	if ( TC.Actor == None )
		TC.Dirty = True;		// 追踪失败，上下文无效
	else
		TC.Dirty = False;		// 追踪成功，上下文有效
}

/**
 * 增强版追踪并创建上下文函数（智能穿透友方检测）
 * 
 * 功能说明：
 * 这是 TraceAndMakeContext 的增强版本，专门用于解决友方遮挡敌方的问题。
 * 当第一个追踪到的目标是友方时，会自动穿透友方查找后面的敌方目标。
 * 
 * 工作流程：
 * 1. 首先使用 TraceEx 快速获取第一个目标（保持原有性能）
 * 2. 判断第一个目标类型：
 *    - 如果是敌方（FR_Attackable）→ 直接返回（性能最优路径）
 *    - 如果是地面/地形（FR_Movable）→ 直接返回（正常路径）
 *    - 如果是友方（FR_Talkable）或其他非攻击目标 → 进入步骤3
 * 3. 使用 TraceActors 遍历射线路径上的所有Actor，查找后面的敌方
 * 4. 如果找到敌方，返回第一个敌方；否则返回第一个目标（保持原逻辑）
 * 
 * @param TC 输出的追踪上下文，包含追踪到的Actor、碰撞位置、法线等信息
 * @param DirectionalScale 追踪距离缩放因子（单位：Unreal单位）
 *                       例如：5000表示追踪距离为5000单位
 * @param Situation 追踪调用情况类型（ETraceCallSituation枚举）
 *                 - TCST_Click: 点击追踪（左键按下时）
 *                 - TCST_Reserved2: 普通悬停追踪（鼠标移动时）
 *                 用于区分不同的追踪场景，可能影响追踪行为
 * 
 * 性能说明：
 * - 正常情况（无遮挡或直接命中敌方）：性能开销与 TraceAndMakeContext 几乎相同
 * - 友方遮挡情况：增加一次 TraceActors 遍历，开销约 +50-100%
 * - 仅在鼠标悬停检测时使用，不影响其他追踪逻辑
 * 
 * 使用场景：
 * 主要用于 OnProbe() 函数中的鼠标悬停检测，解决友方遮挡敌方导致无法显示攻击光标的问题
 */
function TraceAndMakeContextEx(out TraceContext TC, float DirectionalScale, Actor.ETraceCallSituation Situation)
{
	local vector ViewOrigin;		// 射线起点：摄像机/玩家位置
	local vector Direction;		// 射线方向：从屏幕坐标转换而来的世界空间方向向量
	local vector MousePos;		// 鼠标屏幕坐标（X, Y）
	
	local Actor FirstActor;		// 第一次追踪得到的第一个Actor
	local vector FirstHitLoc;	// 第一个Actor的碰撞位置
	local vector FirstHitNorm;	// 第一个Actor的碰撞法线
	
	local Actor HitActor;		// TraceActors遍历时命中的Actor
	local vector HitLoc;		// TraceActors遍历时命中的位置
	local vector HitNorm;		// TraceActors遍历时命中的法线
	
	local EFilterResult FirstFilterResult;	// 第一个目标的过滤结果
	local EFilterResult HitFilterResult;		// 遍历时每个目标的过滤结果
	local bool bFoundEnemy;					// 是否找到敌方目标
	local float FirstDistance;					// 第一个目标到起点的距离
	local float HitDistance;					// 遍历时每个目标到起点的距离
	local float ClosestEnemyDistance;			// 最近的敌方距离
	local Actor ClosestEnemy;					// 最近的敌方Actor
	local vector ClosestEnemyLoc;				// 最近的敌方位置
	local vector ClosestEnemyNorm;				// 最近的敌方法线

	// ========== 第一步：获取射线起点和方向 ==========
	// 使用玩家/摄像机的当前位置作为射线追踪的起点
	ViewOrigin = ViewportOwner.Actor.Location;
	
	// 将鼠标的屏幕坐标（像素坐标）保存到向量中
	MousePos.X = MouseX;
	MousePos.Y = MouseY;
	
	// 将鼠标的屏幕坐标转换为世界空间中的方向向量
	Direction = ScreenToWorld(MousePos);

	// ========== 第二步：快速追踪获取第一个目标 ==========
	// 使用 TraceEx 快速获取第一个碰撞到的Actor（保持原有性能）
	// 这是性能优化的关键：大多数情况下（无遮挡或直接命中敌方），性能开销与原来相同
	FirstActor = ViewportOwner.Actor.TraceEx(FirstHitLoc, FirstHitNorm, Situation, 
		ViewOrigin + DirectionalScale * Direction, ViewOrigin, True);
	
	// 保存鼠标坐标到上下文
	TC.MouseX = MouseX;
	TC.MouseY = MouseY;

	// ========== 第三步：判断第一个目标类型 ==========
	// 如果没有命中任何目标，直接返回
	if ( FirstActor == None )
	{
		TC.Actor = None;
		TC.Dirty = True;		// 追踪失败，上下文无效
		return;
	}

	// 计算第一个目标到起点的距离（用于后续比较）
	FirstDistance = VSize(FirstHitLoc - ViewOrigin);
	
	// 使用 FilterActor 判断第一个目标的类型
	FirstFilterResult = FilterActor(FirstActor);

	// ========== 情况1：第一个目标是敌方 ==========
	// 性能最优路径：直接返回第一个目标，无需额外追踪
	if ( FirstFilterResult == FR_Attackable )
	{
		TC.Actor = FirstActor;
		TC.Location = FirstHitLoc;
		TC.Normal = FirstHitNorm;
		TC.Dirty = False;		// 追踪成功，上下文有效
		return;					// 性能最优路径 ✓
	}

	// ========== 情况2：第一个目标是地面/地形 ==========
	// 正常路径：直接返回地面目标，无需额外追踪
	if ( FirstFilterResult == FR_Movable )
	{
		TC.Actor = FirstActor;
		TC.Location = FirstHitLoc;
		TC.Normal = FirstHitNorm;
		TC.Dirty = False;		// 追踪成功，上下文有效
		return;					// 正常路径 ✓
	}

	// ========== 情况3：第一个目标是友方或其他非攻击目标 ==========
	// 需要穿透检测：使用 TraceActors 遍历射线路径上的所有Actor，查找后面的敌方
	// 这是解决友方遮挡问题的核心逻辑
	
	bFoundEnemy = False;
	ClosestEnemy = None;
	ClosestEnemyDistance = 999999.0;	// 初始化为很大的值
	
	// 使用 TraceActors 遍历射线路径上的所有Actor
	// TraceActors 是 native 迭代器函数，会按距离从近到远返回所有命中的Actor
	foreach ViewportOwner.Actor.TraceActors(class'Actor', HitActor, HitLoc, HitNorm,
	ViewOrigin + DirectionalScale * Direction, ViewOrigin)
	{
		// 跳过第一个目标（已经判断过了，是友方）
		if ( HitActor == FirstActor )
			continue;
		
		// 计算当前目标到起点的距离
		HitDistance = VSize(HitLoc - ViewOrigin);
		
		// 跳过距离比第一个目标更远的Actor（理论上不应该发生，但作为安全检查）
		if ( HitDistance <= FirstDistance )
			continue;
		
		// 判断当前目标是否为敌方
		HitFilterResult = FilterActor(HitActor);
		
		if ( HitFilterResult == FR_Attackable )
		{
			// 找到敌方，记录最近的敌方（TraceActors按距离返回，第一个敌方就是最近的）
			if ( !bFoundEnemy || HitDistance < ClosestEnemyDistance )
			{
				ClosestEnemy = HitActor;
				ClosestEnemyLoc = HitLoc;
				ClosestEnemyNorm = HitNorm;
				ClosestEnemyDistance = HitDistance;
				bFoundEnemy = True;
			}
		}
	}
	
	// ========== 第四步：返回结果 ==========
	if ( bFoundEnemy )
	{
		// 找到敌方，返回第一个（最近的）敌方
		// 这解决了友方遮挡敌方的问题 ✓
		TC.Actor = ClosestEnemy;
		TC.Location = ClosestEnemyLoc;
		TC.Normal = ClosestEnemyNorm;
		TC.Dirty = False;		// 追踪成功，上下文有效
	}
	else
	{
		// 没有找到敌方，返回第一个目标（可能是友方、NPC等）
		// 保持原有逻辑，确保向后兼容
		TC.Actor = FirstActor;
		TC.Location = FirstHitLoc;
		TC.Normal = FirstHitNorm;
		TC.Dirty = False;		// 追踪成功，上下文有效
	}
}

function MakeContext(out TraceContext TC, Actor Actor, vector Location, vector Normal, optional float MX, optional float MY)
{
	TC.Actor = Actor;
	TC.Location = Location;
	TC.Normal = Normal;
	if ( MX != 0 )
		TC.MouseX = MX;
	else
		TC.MouseX = MouseX;
	if ( MY != 0 )
		TC.MouseY = MY;
	else
		TC.MouseY = MouseY;
	TC.Dirty = False;
}

function CopyContext(out TraceContext NewContext, TraceContext OldContext, optional bool bPositionUpdate)
{
	NewContext.Actor = OldContext.Actor;
	NewContext.Location = OldContext.Location;
	NewContext.Normal = OldContext.Normal;
	if ( bPositionUpdate ) 
	{
		NewContext.MouseX = MouseX;
		NewContext.MouseY = MouseY;
	}
	else 
	{
		NewContext.MouseX = OldContext.MouseX;
		NewContext.MouseY = OldContext.MouseY;
	}
	NewContext.Dirty = OldContext.Dirty;
}

function ClearContext(out TraceContext Context)
{
	Context.Actor = None;
	Context.Dirty = True;
}

function bool IsValidContext(out TraceContext Context, optional float Delta)
{
	local Monster Mob;

	if ( Context.Actor == None )
		Context.Dirty = True;
	Mob = Monster(Context.Actor);
	if ( Mob != None && Mob.bIsDead )
		Context.Dirty = True;

	if ( Context.Dirty )
		return False;

	if ( Delta != 0 ) 
	{
		if ( abs(Context.MouseX - MouseX) > Delta || abs(Context.MouseY - MouseY) > Delta ) 
		{
			Context.Dirty = True;
			return False;
		}
	}
	return True;
}

function bool KeyEvent(EInputKey Key,EInputAction Action,float Delta)
{
	local bool ReverseKeyOnly;
	local int ReverseMethod;

	local int RotateViewControl;
	local string InfoMessage;

	/*
	if (!bAltUtil && bAltPressed && Key == IK_Alt && Action == IST_Release) {
		SephirothPlayer(ViewportOwner.Actor).TogglePkState();
		return true;
	}
	*/

	if ( Action == IST_Release )
	{
		if( bCtrlPressed && bShiftPressed && Key == IK_Tilde )
		{
			//SwitchingPickupKey(); //del neive : ���Ű ��ȯ ����
			return True;
		}
	}

	if ( Action == IST_Release )	
	{

		switch (Key)	
		{

			case IK_LeftMouse :

				if ( ValidInput(Key) )
					OnFinishInteraction();

				break;

			case IK_RightMouse :

			// Ÿ���� ���� ������ ���� ���콺 ���� ���� ������ Release���� ó���ǵ���
				if ( bMagicUsed || SephirothPlayer(ViewportOwner.Actor).PSI.Magic == None )
					break;

				if ( ValidInput(Key) && SephirothPlayer(ViewportOwner.Actor).PSI.Magic.bServerHitCheck &&
					abs(fMouseRClickX - MouseX) < 10 && abs(fMouseRClickY - MouseY) < 10 )	
				{

					if ( !HudInterface.PointCheck() && DragObject == None && !bMouseDrag )	
					{

					//OnStartInteraction();
						OnRightInteraction();
					}
				}

				break;

			case IK_W:
			case IK_S:
			case IK_Q:
			case IK_E:
			case IK_Up:
			case IK_Down :

				if ( !ViewportOwner.Console.bTyping && !bProcessingKeyType && OnMove() )
					return True;

				break;
		}
	}

	if ( Super.KeyEvent(Key,Action,Delta) )
		return True;

	if ( !SephirothPlayer(ViewportOwner.Actor).PSI.bIsAlive )
		return True;

	if ( Action == IST_Press )	
	{

		switch (Key)	
		{

			case IK_LeftMouse :

				AutoCastingOff(); //add neive : ���� �ɽ�Ʈ - �ٸ� �� �ϸ� �ʱ�ȭ

				if ( ValidInput(Key) )	
				{

					if ( !HudInterface.PointCheck() && DragObject == None && !bMouseDrag )	
					{
						OnLeftInteraction();
					}
				}
	
				break;

			case IK_RightMouse :

				if ( SephirothPlayer(ViewportOwner.Actor).PSI.Magic == None )
					break;

				RotateViewControl = int(ViewportOwner.Actor.ConsoleCommand("GETOPTIONI RotateView"));

				fMouseRClickX = MouseX;
				fMouseRClickY = MouseY;
				bMagicUsed = False;			// Release���� �������� ���ϰ� �÷��׸� �д�

			// Ÿ���� �ִ� ������ ���� Push���� �̺�Ʈ �߻�
			// ���콺�� �����̵��ϴ� �� ������ ���콺�� ������ Release, ��Ÿ�� ���� ����ó�� Push���� �ߵ�
				if ( ValidInput(Key) && (RotateViewControl != 1 || !SephirothPlayer(ViewportOwner.Actor).PSI.Magic.bServerHitCheck) )	
				{

					bMagicUsed = True;

					if ( !HudInterface.PointCheck() && DragObject == None && !bMouseDrag )	
					{

					//OnStartInteraction();
						OnRightInteraction();
					}
				}

				break;

			case IK_W :
			case IK_S :
			case IK_Q :
			case IK_E :
			case IK_Up :
			case IK_Down :
				AutoCastingOff(); //add neive : ���� �ɽ�Ʈ - �ٸ� �� �ϸ� �ʱ�ȭ
				return !ViewportOwner.Console.bTyping && !bProcessingKeyType && OnMove();

			case IK_Space:
				AutoCastingOff(); //add neive : ���� �ɽ�Ʈ - �ٸ� �� �ϸ� �ʱ�ȭ
				SephirothPlayer(ViewportOwner.Actor).Jump();
				return True;
			case IK_X:
				if( bCtrlPressed && bPluginAutoAttackEnabled )
				{
				/*
				//cd added for auto Attack shot key
				bPluginAutoCast = !bPluginAutoCast;
				bPluginAutoAttack = false;
				if(bPluginAutoCast)
					InfoMessage = Localize("Setting","PluginAutoCastEnabled","Sephiroth");
				else
					InfoMessage = Localize("Setting","PluginAutoCastDisabled","Sephiroth");					
				SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,InfoMessage,class'Canvas'.static.MakeColor(255,255,0));
				 */
				}
				else
				{
					SephirothPlayer(ViewportOwner.Actor).bShowItemName = True;
				}
				return True;
			case ItemPickupKey :
				if( bCtrlPressed && bPluginAutoAttackEnabled )
				{
				/* 
				//@cd added for auto Attack shot key
				bPluginAutoAttack = !bPluginAutoAttack;
				bPluginAutoCast = false;
				if(bPluginAutoAttack)
					InfoMessage = Localize("Setting","PluginAutoAttackEnabled","Sephiroth");
				else
					InfoMessage = Localize("Setting","PluginAutoAttackDisabled","Sephiroth");					
				SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,InfoMessage,class'Canvas'.static.MakeColor(255,255,0));
				*/
				}
				else
				{
					bPickingKeyPressed = True;
				}
				break;

			case IK_C:  //@cs added for auto pickup hot key
			//SwitchAutoPickup();
				return True;
		}
	}

	if ( Action == IST_Release ) 
	{
		//@by wj(07/22)------
		//del neive : ctrl Ű�� �� ��ġ ��� ����
		/*		
		if(Key == IK_Ctrl) {
			SephirothPlayer(ViewportOwner.Actor).DetectEnemy();
			return true;
		}*/
		//-------------------
		if ( Key == ItemPickupKey && bPickingKeyPressed ) 
		{			
			bPickingKeyPressed = False;
			SephirothPlayer(ViewportOwner.Actor).FindNearestItem();
			return True;
		}

		if ( Key == IK_X ) 
		{
			SephirothPlayer(ViewportOwner.Actor).bShowItemName = False;
			return True;
		}
	}

	if ( Action == IST_Axis && Key == IK_MouseY && SephirothPlayer(ViewportOwner.Actor).ViewType == QuaterView )
		return True;

	ReverseKeyOnly = bool(ViewportOwner.Actor.ConsoleCommand("GETOPTIONI Turn180KeyboardOnly"));
	ReverseMethod = int(ViewportOwner.Actor.ConsoleCommand("GETOPTIONI Turn180"));

	switch (Action) 
	{
		case IST_Press:
			if ( Key == IK_V && !bReverseKeyPressed ) 
			{
				SephirothPlayer(ViewportOwner.Actor).ReverseCamera();
				bReverseKeyPressed = True;
				return True;
			}
			if ( !ReverseKeyOnly ) 
			{
				switch (ReverseMethod) 
				{
					case 0:
						if ( Key == IK_MiddleMouse ) 
						{
							SephirothPlayer(ViewportOwner.Actor).ReverseCamera();
							return True;
						}
						break;
					case 1:
						if ( Key == IK_RightMouse ) 
						{
							SephirothPlayer(ViewportOwner.Actor).ReverseCamera();
							return True;
						}
						break;
					case 2:
						if ( Key == IK_RightMouse && bAltPressed ) 
						{
							SephirothPlayer(ViewportOwner.Actor).ReverseCamera();
							return True;
						}
						break;
				}
			}
			break;
		case IST_Release:
			if ( Key == IK_V ) 
			{
				bReverseKeyPressed = False;
				return True;
			}
			break;
	}
	return False;
}

//check neive : Ű�Է��� �޾� �̵�
function bool KeyType(EInputKey Key,optional string Unicode)
{
	if ( Super.KeyType(Key,Unicode) )
		return True;
	switch (Key) 
	{
		case IK_W:
		case IK_S:
		case IK_Q:
		case IK_E:
		case IK_Up:
		case IK_Down:
			return OnMove();
	}
}

//function OnStartInteraction();
function OnFinishInteraction();

//@by wj(040113)------
function OnSecondSkillStart(Skill Skill, Actor Target, vector Loc)
{
	//@by wj (040303) for stun
	if( bLostControl )
		return;

	if ( SephirothPlayer(ViewportOwner.Actor).Start2ndSkillAction(Skill, Target, Loc) && IsInState('LockupBase') )
		bRightClickActing = True;
}
function OnLeftInteraction();

function OnRightInteraction()
{
	local TraceContext TC;
	local EInteractType InteractType;

	//@by wj (040303) for stun
	if( bLostControl )
		return;

	if( IsValidContext(HoverContext) )
		CopyContext(TC,HoverContext);
	else
		TraceAndMakeContext(TC, 5000, TCST_Reserved1);

	if( IsValidContext(TC) ) 
	{
		InteractType = GetRButtonInteractType(TC.Actor);
		if( InteractType == IT_AttackRange || InteractType == IT_Enchant )
		{
			
			//if (!bRightClickActing && SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackRange(TC.Actor, TC.Location) && IsInState('LockupBase')){ //cs changed for ��������Ŀ��״̬�¸�Ƶ��ʹ��ħ�������� rollbacked
			if ( SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackRange(TC.Actor, TC.Location) && IsInState('LockupBase') )
			{
				bRightClickActing = True;
			}

			//add neive : ���� �ɽ�Ʈ - ���� ���� Ƚ���� ���� Ƚ�� �̻��̸� �����
			nAutoCastCount++;
			if( OnAutoCast < nAutoCastCount )
			{
				nAutoCastCount = OnAutoCast + 1;
				if( bAutoCast == False )
				{
					bAutoCast = True;
					AutoCastStartTime = ViewportOwner.Actor.Level.TimeSeconds;
				}

				bAutoCast = True;
			}
			else
				bAutoCast = False;
			//---------------------------------------------------------
		}
	}
}

function bool OnSelfInteraction()
{
	if ( SephirothPlayer(ViewportOwner.Actor).SelfBuff() )
	{
		bRightClickActing = True;
		return True;
	}

	return False;
}

function AutoAttacking()
{
	local TraceContext TC;
	local EInteractType InteractType;

	if( IsValidContext(ActionContext) )
		TC = ActionContext;

	if( Character(TC.Actor).bIsDead )
		return;

	// ������ ��忡���� ���õ� Ÿ���� ���󰡵��� �Ѵ�. ������ ĳ���͸� ���󰡵��� �Ǿ� �ִ�.
	if ( SephirothPlayer(ViewportOwner.Actor).IsTransparent() ) 
	{
		SephirothPlayer(ViewportOwner.Actor).MovePawnToTrace(TC.Actor);
		return;
	}

	InteractType = GetLButtonInteractType(TC.Actor);

	if( InteractType == IT_AttackMelee )
		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackMelee(TC.Actor);
	else if(InteractType == IT_AttackBow)
	{
		if( bPluginAutoAttack && VSize( TC.Location - ViewportOwner.Actor.Pawn.Location) > 2000 )
		{
		//@cs added
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"AutoAttack Moving",class'Canvas'.static.MakeColor(255,255,0));
			SephirothPlayer(ViewportOwner.Actor).MovePawnToMove(TC.Actor,(ViewportOwner.Actor.Pawn.Location + (TC.Location - ViewportOwner.Actor.Pawn.Location) / 3));
		}
		else
			SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackBow(TC.Actor, TC.Location);
	}
}

function AutoCasting()
{
	local TraceContext TC;
	local EInteractType InteractType;

	if( IsValidContext(ActionContext) )
		TC = ActionContext;

	if( Character(TC.Actor).bIsDead )
		return;

	InteractType = GetRButtonInteractType(TC.Actor);

	if( InteractType == IT_AttackRange )
		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackRange(TC.Actor, TC.Location);
		//OnRightInteraction();
}

function AutoCastingEx()
{
	local TraceContext TC;
	local EInteractType InteractType;

	if( IsValidContext(ActionContext) )
		TC = ActionContext;

	if( Character(TC.Actor).bIsDead )
		return;

	InteractType = GetRButtonInteractType(TC.Actor);

	if( InteractType == IT_AttackRange )
		if( bPluginAutoCast && VSize( TC.Location - ViewportOwner.Actor.Pawn.Location) > 2000 )
		{
		//@cs added
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"AutoAttack Moving",class'Canvas'.static.MakeColor(255,255,0));
			SephirothPlayer(ViewportOwner.Actor).MovePawnToMove(TC.Actor,(ViewportOwner.Actor.Pawn.Location + (TC.Location - ViewportOwner.Actor.Pawn.Location) / 3));
		}
	else
		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackRange(TC.Actor, TC.Location);
		//OnRightInteraction();
}

//add neive : ���� �ɽ��� ����
function AutoCastingOff()
{
	bAutoCast = False;
	nAutoCastCount = 0;
	AutoCastStartTime = 0;
}

function RightClickActionEnd();
//--------------------

function bool OnMove();
function OnTick(float DeltaTime);
function OnProbe();

/* Dereference dangling pointers */
function OnActorOut(Actor Actor)
{
	/*!@ 2004.2.25 jhjung */
	if ( NextActionContext.Actor == Actor )
		ClearContext(NextActionContext);
	/**/
	if (HoverContext.Actor == Actor)
		ClearContext(HoverContext);
	if (ActionContext.Actor == Actor) {
		ClearContext(ActionContext);
		if (IsInState('Lockup'))
			GotoState('LockupReleasing');
		else if (Decal != None && IsInState('LockupDetecting'))
			Decal.SetLockupActor(None);
	}
	if (Decal != None && Actor == Decal.LockupActor)
		Decal.SetLockupActor(None);
	if (DecalAfter != None && Actor == DecalAfter.LockupActor)
		DecalAfter.SetLockupActor(None);
}

function OnPlayerStopped()
{
	if (Decal != None && Decal.DecalState == DS_None)
		Decal.SetLockupActor(None,vect(0,0,0));
}

function SelectTargetCursor(EFilterResult Result)
{
	if (Result == FR_Talkable)
		SephirothPlayer(ViewportOwner.Actor).CursorToTalk();
	else if (Result == FR_Pickable)
		SephirothPlayer(ViewportOwner.Actor).CursorToInterface();
	else if (!SephirothPlayer(ViewportOwner.Actor).PSI.bBlind && Result == FR_Attackable)
		SephirothPlayer(ViewportOwner.Actor).CursorToAttack();
	else
		SephirothPlayer(ViewportOwner.Actor).CursorToNormal();
}

//@cs added
function ApplyPluginItem(string ItemLocalDesc)
{
	local SephirothPlayer PC;
	local SephirothItem Item;

	PC = SephirothPlayer(ViewportOwner.Actor);
	Item = PC.PSI.SepInventory.FirstMatched(3, ItemLocalDesc);
	if (Item != None && Item.isPotion())
	{
		if(Item.IsMarket())
		{
			if (Item != None){
				if(Item.IsHPotion()){
					if(ViewportOwner.Actor.Level.TimeSeconds - timeDrinkingBloodDelay > 1){
						PC.Net.NotiItemUseShotcut(Item.TypeName);
						timeDrinkingBloodDelay = ViewportOwner.Actor.Level.TimeSeconds;
					}					
				}else if(Item.IsMPotion()){
					if(ViewportOwner.Actor.Level.TimeSeconds - timeDrinkingMagicDelay > 1){
						PC.Net.NotiItemUseShotcut(Item.TypeName);
						timeDrinkingMagicDelay = ViewportOwner.Actor.Level.TimeSeconds;
					}	
				}				
			}
		}
		else
		{
		if (Item != None && Item.Amount > 0)
			if(Item.IsHPotion()){
				if(ViewportOwner.Actor.Level.TimeSeconds - timeDrinkingBloodDelay > 1){
					PC.Net.NotiItemUseShotcut(Item.TypeName);
					timeDrinkingBloodDelay = ViewportOwner.Actor.Level.TimeSeconds;
				}					
			}else if(Item.IsMPotion()){
				if(ViewportOwner.Actor.Level.TimeSeconds - timeDrinkingMagicDelay > 1){
					PC.Net.NotiItemUseShotcut(Item.TypeName);
					timeDrinkingMagicDelay = ViewportOwner.Actor.Level.TimeSeconds;
				}	
			}
		}

		return;
	}
}

function CheckForEnchantingSelf(int skillsId){
	local SephirothPlayer PC;
	Local Skill CurSkill;
	local int i,j,k;
	local array<string> CurSkills;
	local bool bPluginAutoEnChantEnabledSwitch;

	if(CInterface(SephirothPlayer(ViewportOwner.Actor).myHud).bIgnoreKeyEvents) return;   //��ֹ��̯�����ʱ���ͷ�ħ��
	if(SephirothPlayer(ViewportOwner.Actor).IsInState('BoothSelling')) return;

	PC = SephirothPlayer(ViewportOwner.Actor);

	/*
	for(k=0;k<PC.PSI.EnchantMagics.length;++k){
		SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"EnchantMagics:"@string(k)@PC.PSI.EnchantMagics[k],class'Canvas'.static.MakeColor(255,255,255));
	}
	for(k=0;k<PC.PSI.BuffList.length;++k){
		SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BuffList:"@string(k)@PC.PSI.BuffList[k].sName,class'Canvas'.static.MakeColor(255,255,255));
	}
	*/

	if( skillsId == 0 ) 
	{
		CurSkills = class'PageAttack'.Default.Skills; bPluginAutoEnChantEnabledSwitch = bPluginAutoEnChantEnabled;
	}
	if( skillsId == 1 ) 
	{
		CurSkills = class'PageAttack'.Default.Skills1; bPluginAutoEnChantEnabledSwitch = bPluginAutoEnChantEnabled1;
	}
	if( skillsId == 2 ) 
	{
		CurSkills = class'PageAttack'.Default.Skills2; bPluginAutoEnChantEnabledSwitch = bPluginAutoEnChantEnabled2;
	}

	//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"skillsId:"@string(skillsId)@"bPluginAutoEnChantEnabledSwitch"@string(bPluginAutoEnChantEnabledSwitch)@"PrevMagicBackup"@string(PrevMagicBackup)
	//	,class'Canvas'.static.MakeColor(255,255,255));

	if( !bPluginAutoEnChantEnabledSwitch 
		|| PrevMagicBackup != None ) return;	

	//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"skillsId:"@string(skillsId),class'Canvas'.static.MakeColor(255,255,255));


	for ( i = 0;i < PC.PSI.SkillBooks.Length;++i ) 
	{
		for( j = 0;j < PC.PSI.SkillBooks[i].Skills.Length;++j )
		{
			CurSkill = PC.PSI.SkillBooks[i].Skills[j];
			if( CurSkill != None && CurSkill.bLearned && ( (CurSkill.bSelf && CurSkill.bEnchant) || CurSkill.IsA('SpiritSkill') ) )
			{ 
		//������ѧ�����ҿ���Ϊ�Լ�ʹ�õļ���
				if( CurSkill.FullName == CurSkills[class'PageAttack'.Static.GetJobTypeFromJobName(PC.PSI.JobName)] )
				{
					for( k = 0;k < PC.PSI.EnchantMagics.length;++k )
					{
						//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"Buff:"@string(k)@PC.PSI.EnchantMagics[k],class'Canvas'.static.MakeColor(255,255,255));
						if( string(CurSkill.Name) == PC.PSI.EnchantMagics[k] ) break;
					}
					/*
					for(k=0;k<PC.PSI.BuffList.length;++k){
						SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"Buff:"@string(k)@PC.PSI.BuffList[k].sName,class'Canvas'.static.MakeColor(255,255,255));
						if(string(CurSkill.Name) == PC.PSI.BuffList[k].sName) break;
					}*/
					if( PC.PSI.EnchantMagics.length == k )
					{
						PrevMagicBackup = PC.PSI.Magic;
						UsedMagicBackup = CurSkill;
						PC.PSI.Magic = CurSkill;
						PC.SelfBuff();
						//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"SelfBuff"@string(CurSkill.Name)@CurSkill.FullName,class'Canvas'.static.MakeColor(255,255,255));
					}
				}
			}
		}
	}
}

//@cs
function RemoveSpaces(out string Message)
{
	if ( Message == "" )
		return;
	while ( Left(Message, 1) == " " )
		Message = Mid(Message, 1);
}

//@cs
function LoadIllegalText()
{
    //local string IllegalText;
    //local int i;


   // FileLoader = pawn(class'CTextFile');
   // FileLoader.LoadTextDec("Illegals.dat");
   // IllegalText = FileLoader.FileText;
   // FileLoader.Destroy();

    //class'CNativeInterface'.static.WrapStringToArray(IllegalText, Illegals, 10000, ",");

    //i = 0;
    //Illegals[i] = "����"; ++i;


}

//@cs
function CheckForAutoChatting()
{

	local SephirothPlayer PC;
	local string MessageText;
	local string Message, Extra;
    //local name AnimName;
	local string LChannelStr,RChannelStr;
	local int i;

	PC = SephirothPlayer(ViewportOwner.Actor);

	MessageText = class'PageChat'.Default.CurrentContent;
	if ( MessageText == "" )  return;

	RemoveSpaces(MessageText);
	if ( MessageText == "\\\\" ) return;

	Message = MessageText;

	for ( i = 0;i < Illegals.Length;i++ ) 
	{
		//Log("cs debug Illegals err0");
		if ( InStr(Message, Illegals[i]) != -1 ) 
		{
			/*
            TextPool.AddMessage(Localize("Information","IllegalTextUsed","Sephiroth"),
                class'Canvas'.static.MakeColor(255,255,0),
                12, 4, 2, false, 0, 0, "",
                true,
                class'Canvas'.static.MakeColor(0,0,0),
                2);
			*/
			class'CMessageBox'.Static.MessageBox(CMultiInterface(ViewportOwner.Actor.myHUD),"debug",Localize("Information","IllegalTextUsed","Sephiroth"),MB_Ok);

			break;
		}
	}
	
	//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"CheckForAutoChatting"@class'PageChat'.default.CurrentChannel,class'Canvas'.static.MakeColor(200,100,200));
	
	LChannelStr = PC.PSI.GetLeftChannel();
	RChannelStr = PC.PSI.GetRightChannel();
	switch (class'PageChat'.Default.CurrentChannel) 
	{
    //case EChannelMode.Chan_Whisper:
    //    Extra = WhisperEdit.GetText();
    //    break;
		case RChannelStr:
			if ( RChannelStr == "" ) return;
			PC.Net.NotiTellChannel(RChannelStr, Message);
			break;
		case LChannelStr:
			if ( LChannelStr == "" ) return;
			PC.Net.NotiTellChannel(LChannelStr, Message);
			break;
		case Localize("Terms", "Shout", "Sephiroth"):
			PC.Net.NotiTell(2, Message);
			break;
		case Localize("Terms", "Tell", "Sephiroth"):
			PC.Net.NotiTell(1, Message);
			break;
		case Localize("Terms", "Party", "Sephiroth"):
			PC.Net.NotiPartyTell(Message);
			break;
		case Localize("Terms", "Team", "Sephiroth"):
			PC.Net.NotiTellTeam(Message);
			break;
		case Localize("Terms", "Clan", "Sephiroth"):
			Extra = PC.PSI.ClanName;
			if ( Extra == "" ) return;
			PC.Net.NotiClanTell(Extra, string(PC.PSI.PlayName), Message);
			break;
		default:
			Extra = "";
			break;
	}    
}



function CheckForDrugUsing()
{
	local SephirothPlayer PC;
	local float nCurrentHPPercent;
	local float nCurrentMPPercent;
	local float nBlood0Percent;
	local float nBlood1Percent;
	local float nMagic0Percent;
	local float nMagic1Percent;

	local float A,B,C;

	PC = SephirothPlayer(ViewportOwner.Actor);//SephirothPlayer(PlayerOwner);

	nCurrentHPPercent = (float(PC.PSI.Health) / float(PC.PSI.MaxHealth)) * 100f;
	nCurrentMPPercent = (float(PC.PSI.Mana) / float(PC.PSI.MaxMana)) * 100f;

	nBlood0Percent = class'PagePlugin'.Default.nAutoAddBlood0;
	nBlood1Percent = class'PagePlugin'.Default.nAutoAddBlood1;
	nMagic0Percent = class'PagePlugin'.Default.nAutoAddMagic0;
	nMagic1Percent = class'PagePlugin'.Default.nAutoAddMagic1;

	A = nCurrentHPPercent - nBlood0Percent;
	B = nCurrentHPPercent - nBlood1Percent;
	C = nBlood0Percent - nBlood1Percent;

	//class'CMessageBox'.static.MessageBox(CMultiInterface(ViewportOwner.Actor.myHUD),"debug","hp:"@string(nCurrentHPPercent)@string(nCurrentMPPercent)@string(A)@string(B)@string(C)
	//	@string(nBlood0Percent)@string(nBlood1Percent)@string(nMagic0Percent)@string(nMagic1Percent),
	//	MB_Ok);

	//HP
	if( A >= 0 && B >= 0 )
	{
		//do nothing
	}
	else if(A < 0 && B < 0)
	{
		if( C >= 0 )
		{
			if( class'PagePlugin'.Default.bAutoBlood1 )
			{
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[1]);
			}
			else
			{
				if( class'PagePlugin'.Default.bAutoBlood0 )
					ApplyPluginItem(class'PagePlugin'.Default.Drugs[0]);
			}
		}
		else
		{
			if( class'PagePlugin'.Default.bAutoBlood0 )
			{
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[0]);
			}
			else
			{
				if( class'PagePlugin'.Default.bAutoBlood1 )
					ApplyPluginItem(class'PagePlugin'.Default.Drugs[1]);
			}
		}
	}
	else
	{
		if( A < 0 )
		{
			if( class'PagePlugin'.Default.bAutoBlood0 )
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[0]);
		}
		else
		{
			if( class'PagePlugin'.Default.bAutoBlood1 )
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[1]);
		}
	}

	//MP
	A = nCurrentMPPercent - nMagic0Percent;
	B = nCurrentMPPercent - nMagic1Percent;
	C = nMagic0Percent - nMagic1Percent;

	if( A >= 0 && B >= 0 )
	{
		//do nothing
	}
	else if(A < 0 && B < 0)
	{
		if( C >= 0 )
		{
			if( class'PagePlugin'.Default.bAutoMagic1 )
			{
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[3]);
			}
			else
			{
				if( class'PagePlugin'.Default.bAutoMagic0 )
					ApplyPluginItem(class'PagePlugin'.Default.Drugs[2]);
			}
		}
		else
		{
			if( class'PagePlugin'.Default.bAutoMagic0 )
			{
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[2]);
			}
			else
			{
				if( class'PagePlugin'.Default.bAutoMagic1 )
					ApplyPluginItem(class'PagePlugin'.Default.Drugs[3]);
			}
		}
	}
	else
	{
		if( A < 0 )
		{
			if( class'PagePlugin'.Default.bAutoMagic0 )
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[2]);
		}
		else
		{
			if( class'PagePlugin'.Default.bAutoMagic1 )
				ApplyPluginItem(class'PagePlugin'.Default.Drugs[3]);
		}
	}
}

event Tick(float DeltaTime)
{
	/* */
	if ( !SephirothPlayer(ViewportOwner.Actor).PSI.bIsAlive ) 
	{
		bRequiresTick = False;
		if ( IsInState('LockupBase') ) 
		{
			ClearContext(ActionContext);
			Decal.SetLockupActor(None);
			GotoState('Standing');
		}
		SephirothPlayer(ViewportOwner.Actor).GotoState('JustDead');
		return;
	}

	OnTick(DeltaTime);

	/* 
	//@cs added for plugin
	if(ViewportOwner.Actor.Level.TimeSeconds - fTimeDrinking > 1){
		CheckForDrugUsing();
		fTimeDrinking = ViewportOwner.Actor.Level.TimeSeconds;
	}


	//@cs added for plugin auto Enchant
	//if(Player.IsInState('Navigating')){
	if(ViewportOwner.Actor.Level.TimeSeconds - fTimeEnchanting > 3){
		CheckForEnchantingSelf(0);
		CheckForEnchantingSelf(1);
		CheckForEnchantingSelf(2);
		fTimeEnchanting = ViewportOwner.Actor.Level.TimeSeconds;
	}

	//@cs
	if(bPluginAutoChatEnabled && ViewportOwner.Actor.Level.TimeSeconds - fTimeChating > class'PageChat'.default.nPluginAutoChatInterval){
		//CheckForEnchantingSelf();		
		CheckForAutoChatting();
		fTimeChating = ViewportOwner.Actor.Level.TimeSeconds;
	}

	//add neive : ���� �ɽ�Ʈ -------
	if(bAutoCast)	{
		OnRightInteraction();

		if ( ViewportOwner.Actor.Level.TimeSeconds - AutoCastStartTime > 60 )
			AutoCastingOff();
	}
	//-------------------------------

	//cs added for plugin auto pickup
	if(bAutoPickup){
			//if(ViewportOwner.Actor.Level.TimeSeconds - fTimePicking > 0.2){
				SephirothPlayer(ViewportOwner.Actor).PickupNearItems(PickupItems,NotPickupItems);
				fTimePicking = ViewportOwner.Actor.Level.TimeSeconds;
			//}
	}
	*/

	ProbeTicks += DeltaTime;
	if ( ProbeTicks >= 0.1 )	
	{

		OnProbe();
		ProbeTicks = 0.0;
	}

/*	if ( bPickingKeyPressed && (ViewportOwner.Actor.Level.TimeSeconds - timePicking > 0.2) )	{

		SephirothPlayer(ViewportOwner.Actor).FindNearestItem();
		timePicking = ViewportOwner.Actor.Level.TimeSeconds;
	}*/

}


// ���콺 ���� Ŭ���� �ش��ϴ� Action�� ClientController�� �Ѱ��ش�. ���콺 ������ Ŭ���� �ش��ϴ� Action�� 
// OnRightInteraction()���� ���� �Ѱ� �ش�.
function ControllerReceiveContext(TraceContext TC, optional EInteractType InteractType)
{
	// ������ ��忡���� ���õ� Ÿ���� ���󰡵��� �Ѵ�. ������ ĳ���͸� ���󰡵��� �Ǿ� �ִ�.
	if ( SephirothPlayer(ViewportOwner.Actor).IsTransparent() ) 
	{
		if ( InteractType == IT_AttackMelee )
			SephirothPlayer(ViewportOwner.Actor).MovePawnToTrace(TC.Actor);
		return;
	}

	if ( InteractType == IT_None )
		InteractType = GetLButtonInteractType(TC.Actor);

	if ( !IsInState('LockupBase') && bMouseDrag && InteractType != IT_Move )
		ResetDragAndDropAll();

	// ���;׼� Ÿ���� ���� ������ Ŀ�ǵ带 ��Ʈ�ѷ����� �ش�.
	if ( InteractType == IT_Move ) // �̵�
	{
		if( bMouseDrag ) 
			return;
		SephirothPlayer(ViewportOwner.Actor).MovePawnToMove(TC.Actor, TC.Location);
	}
	else if (InteractType == IT_Talk) // ��ȭ
		SephirothPlayer(ViewportOwner.Actor).MovePawnToTalk(TC.Actor);
	else if (InteractType == IT_Pick) // �ݱ�
		SephirothPlayer(ViewportOwner.Actor).MovePawnToPick(TC.Actor);
//	else if (InteractType == IT_Enchant || InteractType == IT_AttackRange) // ��������/��� ��..
//		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackRange(TC.Actor, TC.Location);
	else if (InteractType == IT_AttackMelee)
		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackMelee(TC.Actor); // �и�����
	else if (InteractType == IT_AttackBow)
		SephirothPlayer(ViewportOwner.Actor).MovePawnToAttackBow(TC.Actor, TC.Location); // �ü� ����
}

/*
function bool PawnIsMoving(){
	local SephirothPlayer Player;
	Player = SephirothPlayer(ViewportOwner.Actor);
	if(Player.Destination != vect(0,0,0)){
		//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"VSize(Player.Destination-Player.Pawn.Location)"@string(VSize(Player.Destination-Player.Pawn.Location)),class'Canvas'.static.MakeColor(200,100,200));
		return VSize(Player.Destination-Player.Pawn.Location) > 200;
	}
	return false;
}
*/

function bool DisableAutoAttack()
{
	if( bPluginAutoAttackEnabled )
	{
		if( bPluginAutoAttack )
		{
			bPluginAutoAttack = False;			
			SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,Localize("Setting","PluginAutoAttackDisabledForMoving","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
			SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,Localize("Setting","PluginAutoAttackDisabled","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
		}
		else if(bPluginAutoCast)
		{
			bPluginAutoCast = False;
			SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,Localize("Setting","PluginAutoAttackDisabledForMoving","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
			SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,Localize("Setting","PluginAutoCastDisabled","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,0));
		}
	}
}

auto state Standing
{
	function BeginState()
	{
		if (Decal != None)
			Decal.SetLockupActor(None);
		bFinishInteraction = False;
	}

	//@cs added for plugin
	function BeginAutoAttack()
	{
		
		local TraceContext TC;
		local EInteractType LInteractType,RInteractType;
		local float DirectionalScale;
		local Creature monster;
		local vector ViewOrigin, Direction, MousePos;


		//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack_enter",class'Canvas'.static.MakeColor(200,100,200));
		
		//for stun
		if(bLostControl)
		{
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack0",class'Canvas'.static.MakeColor(200,100,200));
			return;
		}

		DirectionalScale = 10000f;
		monster = SephirothPlayer(ViewportOwner.Actor).FindNearestMonsterToAttack(DirectionalScale);
		if(monster == None)
		{
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack1",class'Canvas'.static.MakeColor(200,100,200));
			return;	
		}

		if (Decal == None) 
		{
			Decal = ViewportOwner.Actor.Spawn(class'LockupDecal',ViewportOwner.Actor,'MajorDecal');
			Decal.SetLockupActor(None);
		}
		if (DecalAfter == None) 
		{
			DecalAfter = ViewportOwner.Actor.Spawn(class'LockupDecal',ViewportOwner.Actor,'AssistentDecal');
			DecalAfter.SetLockupActor(None);
		}

		//if (IsValidContext(HoverContext)){
		//	CopyContext(TC, HoverContext);
		//	SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack2",class'Canvas'.static.MakeColor(200,100,200));
		//}else {
			//TraceAndMakeContext(TC, DirectionalScale, TCST_Reserved2);//TCST_Click);
		MousePos = WorldToScreen(monster.Location,ViewportOwner.Actor.Location,ViewportOwner.Actor.Rotation);
		MousePos.Z = 0f;
		ViewOrigin = ViewportOwner.Actor.Location;
		Direction = ScreenToWorld(MousePos);
			//TC.Actor = ViewportOwner.Actor.TraceEx(TC.Location, TC.Normal, TCST_Click, ViewOrigin+DirectionalScale*Direction, ViewOrigin, true);
		TC.Actor = monster;
		TC.Location = monster.Location;
		if (TC.Actor == None)
		{
			TC.MouseX = MousePos.X;
			TC.MouseY = MousePos.Y;
			TC.Dirty = True;
		}
		else
			TC.Dirty = False;
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack3",class'Canvas'.static.MakeColor(200,100,200));
		//}

		if (IsValidContext(TC)) 
		{
			if(bPluginAutoAttack)
				LInteractType = GetLButtonInteractType(TC.Actor);
			else if(bPluginAutoCast)
				RInteractType = GetRButtonInteractType(TC.Actor);
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack5"@string(LInteractType),class'Canvas'.static.MakeColor(200,100,200));
			if (LInteractType == IT_AttackMelee || LInteractType == IT_AttackBow || RInteractType == IT_AttackRange) 
			{
				//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"BeginAutoAttack4",class'Canvas'.static.MakeColor(200,100,200));
				//ControllerReceiveContext(TC, LInteractType);
				Decal.Detecting();
				CopyContext(ActionContext, TC);
				DetectStartTime = ViewportOwner.Actor.Level.TimeSeconds;
				GotoState('LockupDetecting');
				Decal.SetLockupActor(TC.Actor, TC.Location);
			}
		}
	}
	function OnLeftInteraction()	//@by wj(040113)
	{
		local TraceContext TC;
		local EInteractType InteractType;

		//@by wj (040303) for stun
		if(bLostControl)
			return;

		if (Decal == None) 
		{
			Decal = ViewportOwner.Actor.Spawn(class'LockupDecal',ViewportOwner.Actor,'MajorDecal');
			Decal.SetLockupActor(None);
		}
		if (DecalAfter == None) 
		{
			DecalAfter = ViewportOwner.Actor.Spawn(class'LockupDecal',ViewportOwner.Actor,'AssistentDecal');
			DecalAfter.SetLockupActor(None);
		}

		// ȣ���� ���� ������, �׳Ѱ� ���;׼� ����.
		if (IsValidContext(HoverContext))
			CopyContext(TC, HoverContext);
		// ������, ���� ����� �׳Ѱ� ���;׼� ����.
		else 
		{
			TraceAndMakeContext(TC, 5000, TCST_Click);
		}

		if (IsValidContext(TC)) 
		{
			InteractType = GetLButtonInteractType(TC.Actor);
			if (InteractType != IT_None) 
			{
				ControllerReceiveContext(TC, InteractType);
				if (InteractType == IT_Move)
					Decal.Moving(TC.Normal);
				//else if (InteractType == IT_AttackRange || InteractType == IT_Enchant)	@by wj(040113) comment
				//	Decal.Lockup();
				else if (InteractType == IT_Talk || InteractType == IT_Pick)
					Decal.Lockup();
				else if(InteractType == IT_AttackMelee || InteractType == IT_AttackBow) 
				{	
		//@by wj(040113)
					Decal.Detecting();
					CopyContext(ActionContext, TC);
					DetectStartTime = ViewportOwner.Actor.Level.TimeSeconds;
					GotoState('LockupDetecting');
				}
				Decal.SetLockupActor(TC.Actor, TC.Location);
			}
		}
	}
	function OnFinishInteraction()
	{
	}
	/**
	 * 鼠标探测函数 - 每帧调用，用于检测鼠标位置下的目标并更新光标状态
	 * 这是鼠标状态变更的核心函数，负责：
	 * 1. 从鼠标位置发射射线追踪目标
	 * 2. 判断目标类型（可攻击、可对话、可移动等）
	 * 3. 根据目标类型更新鼠标光标状态
	 * 4. 处理自动攻击逻辑
	 */
	function OnProbe()
	{
		local TraceContext TC;			// 追踪上下文，包含追踪到的Actor、位置、法线等信息
		local EFilterResult FilterResult;	// 目标过滤结果（可攻击、可对话、可移动等）
		local SephirothPlayer Player;		// 玩家引用

		local bool debugIsMove;			// 调试用：是否在移动

		// ========== 第一部分：处理模态界面和UI交互 ==========
		// 如果当前处于模态界面状态且正在处理界面交互，直接设置光标为界面光标
		if (Modal() && bHandlingInterface)
			SephirothPlayer(ViewportOwner.Actor).CursorToInterface();
		// 如果鼠标不在HUD界面上（即鼠标在游戏世界中）
		else if (!HudInterface.PointCheck()) 
		{
			// ========== 第二部分：处理游戏世界中的目标检测 ==========
			// 如果之前已经有一个有效的悬停上下文（HoverContext），且鼠标没有移动太多
			// 则直接使用该上下文，避免每帧都重新追踪（性能优化）
			if (IsValidContext(HoverContext, CancelDelta))
			{
				// 直接使用缓存的悬停目标，根据目标类型更新光标
				SelectTargetCursor(FilterActor(HoverContext.Actor));
			}
			else 
			{
				// 没有有效的悬停上下文，需要执行新的追踪
				// 清除旧的悬停上下文
				ClearContext(HoverContext);
				
				// 根据是否按下左键，使用不同的追踪情况类型
				// TCST_Click: 点击追踪（左键按下时）
				// TCST_Reserved2: 普通悬停追踪（左键未按下时）
				// 5000: 追踪距离（单位：Unreal单位）
				// 使用 TraceAndMakeContextEx 增强版追踪，解决友方遮挡敌方的问题
				if (bLButtonDown)
					TraceAndMakeContextEx(TC, 5000, TCST_Click);
				else
					TraceAndMakeContextEx(TC, 5000, TCST_Reserved2);

				// 如果追踪到了有效的目标
				if (IsValidContext(TC)) 
				{
					// 过滤目标，判断目标类型（可攻击、可对话、可移动等）
					FilterResult = FilterActor(TC.Actor);

					// ========== 处理可移动目标（地面、地形等）==========
					// 如果左键按下且目标是可移动的（地面），则执行移动操作
					if (bLButtonDown && FilterResult == FR_Movable) 
					{
						SephirothPlayer(ViewportOwner.Actor).SelectActor(None);	// 清除选中目标
						ControllerReceiveContext(TC, IT_Move);					// 接收移动上下文
						Decal.Moving(TC.Normal);									// 设置移动标记
						Decal.SetLockupActor(TC.Actor, TC.Location);				// 锁定移动目标位置
					}
					// ========== 处理无效目标 ==========
					// 如果目标无效，清除选中状态
					else if (FilterResult == FR_None)
						SephirothPlayer(ViewportOwner.Actor).SelectActor(None);
					// ========== 处理有效目标（可攻击、可对话、可拾取等）==========
					else 
					{
						// 如果目标不是可移动的、不是不可拾取的物品、且不是玩家自身
						// 则保存为悬停上下文，用于下一帧的快速检测（避免重复追踪）
						if (FilterResult != FR_Movable && FilterResult != FR_NotOwnedPickable && TC.Actor != ViewportOwner.Actor.Pawn)
							CopyContext(HoverContext, TC);
						
						// 选中当前目标（用于显示目标信息、高亮等）
						SephirothPlayer(ViewportOwner.Actor).SelectActor(TC.Actor);
					}
					
					// 根据过滤结果更新鼠标光标状态
					// 例如：可攻击目标 -> 攻击光标，可对话目标 -> 对话光标等
					SelectTargetCursor(FilterResult);
				}
			}
		}
		// ========== 第三部分：处理HUD界面上的鼠标状态 ==========
		// 如果鼠标在HUD界面上
		else 
		{
			// 如果正在处理界面交互
			if (bHandlingInterface) 
			{
				// 根据界面元素类型设置不同的光标状态
				switch (InterfaceHitType) 
				{
					case class'GConst'.Default.HIT_Minimap:
						SephirothPlayer(ViewportOwner.Actor).CursorToMinimap();		// 小地图光标
						break;
					case class'GConst'.Default.HIT_Gauge:
						SephirothPlayer(ViewportOwner.Actor).CursorToGauge();		// 血条/蓝条光标
						break;
					case class'GConst'.Default.HIT_DialogLink:
						SephirothPlayer(ViewportOwner.Actor).CursorToDialogLink();	// 对话链接光标
						break;
					default:
						SephirothPlayer(ViewportOwner.Actor).CursorToInterface();	// 默认界面光标
						break;
				}
			}
			// 如果不在处理界面交互，设置为普通光标
			else
				SephirothPlayer(ViewportOwner.Actor).CursorToNormal();
		}

		// ========== 第四部分：处理自动攻击逻辑 ==========
		Player = SephirothPlayer(ViewportOwner.Actor);

		// 如果启用了自动攻击插件，且（自动攻击或自动施法）已启用
		// 且距离上次攻击时间超过0.5秒（防止过于频繁的攻击）
		if(bPluginAutoAttackEnabled && (bPluginAutoAttack || bPluginAutoCast) && (ViewportOwner.Actor.Level.TimeSeconds - ftimeAttacking > 0.5))
		{
			// 更新攻击时间戳
			fTimeAttacking = ViewportOwner.Actor.Level.TimeSeconds;
			// 开始自动攻击
			BeginAutoAttack();
		}

	}
	function RightClickActionEnd()
	{
		bRightClickActing = False;
		if(PrevMagicBackup != None && UsedMagicBackup != None)
		{
			if(PrevMagicBackup != SephirothPlayer(ViewportOwner.Actor).PSI.Magic && UsedMagicBackup != SephirothPlayer(ViewportOwner.Actor).PSI.Magic)
			{
				PrevMagicBackup = None;
				UsedMagicBackup = None;
				return;
			}
			SephirothPlayer(ViewportOwner.Actor).PSI.Magic = PrevMagicBackup;
			PrevMagicBackup = None;
			UsedMagicBackup = None;
		}
	}

	function bool OnMove()
	{
		DisableAutoAttack();
		SephirothPlayer(ViewportOwner.Actor).StopAction();
		return False;
	}
}

state LockupBase
{
	function OnTick(float DeltaTime)
	{
		local bool bCanAttack;

		//cs changed for auto attack plugin
		//if(ViewportOwner.Actor.Level.TimeSeconds - fTimeAutoAttack < 0.1) return;
		//bCanAttack = !PawnIsMoving();
		if (IsValidContext(ActionContext))
		{
			//if (bCanAttack){
			fTimeAutoAttack = ViewportOwner.Actor.Level.TimeSeconds;
			if(bPluginAutoAttack)
			{
					//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"AutoAttacking",class'Canvas'.static.MakeColor(255,255,0));
				AutoAttacking();
			}
			else if(bPluginAutoCast)
			{
					//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"AutoCasting",class'Canvas'.static.MakeColor(255,255,0));
				AutoCastingEx();
			}
			else if(!bRightClickActing)
				AutoAttacking();
			//}else{
				//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"bCanAttack = "@string(bCanAttack)@"IsInState"@string(SephirothPlayer(ViewportOwner.Actor).GetStateName()),class'Canvas'.static.MakeColor(200,100,200));	
			//	if(!bRightClickActing)
			//		AutoAttacking();
			//}
		}
		else
		{
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"GotoState('LockupReleasing')"@string(IsValidContext(ActionContext))@string(bRightClickActing),class'Canvas'.static.MakeColor(200,100,200));	
			GotoState('LockupReleasing');
		}
	}
	function OnProbe()
	{
		local TraceContext TC;
		local EFilterResult FilterResult;

		// Ŀ�� ������ �� ��...
		if (IsValidContext(HoverContext, CancelDelta)) 
		{
			SelectTargetCursor(FilterActor(HoverContext.Actor));
			SephirothPlayer(ViewportOwner.Actor).SelectActor(HoverContext.Actor);
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"OnProbe SelectActor(HoverContext.Actor)",class'Canvas'.static.MakeColor(200,100,200));	
		}
		else 
		{
			ClearContext(HoverContext);
			TraceAndMakeContext(TC, 5000, TCST_Reserved2);
			if (IsValidContext(TC)) 
			{
				FilterResult = FilterActor(TC.Actor);
				if (FilterResult == FR_Talkable)
					SephirothPlayer(ViewportOwner.Actor).CursorToTalk();
				else if (FilterResult == FR_Pickable)
					SephirothPlayer(ViewportOwner.Actor).CursorToInterface();
				else if (FilterResult == FR_Attackable)
					SephirothPlayer(ViewportOwner.Actor).CursorToAttack();
				else
					SephirothPlayer(ViewportOwner.Actor).CursorToNormal();
				if (FilterResult != FR_Movable)
					SephirothPlayer(ViewportOwner.Actor).SelectActor(TC.Actor);
				else
					SephirothPlayer(ViewportOwner.Actor).SelectActor(None);
				if (FilterResult == FR_Attackable)
					CopyContext(HoverContext, TC);
			}
			else
			{
				//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"OnProbe ELSE",class'Canvas'.static.MakeColor(200,100,200));	
			}
		}
	}
	function RightClickActionEnd()
	{
		//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"LockupBase RightClickActionEnd",class'Canvas'.static.MakeColor(255,255,0));
		bRightClickActing = False;
//		InteractionKey = IK_LeftMouse;

		if(PrevMagicBackup != None && UsedMagicBackup != None)
		{
			//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"RightClickActionEnd"@string(PrevMagicBackup.Name)@PrevMagicBackup.FullName,class'Canvas'.static.MakeColor(255,255,255));
			//PSI.Magic�Ѿ�ʹ���û����õ�����ֵ��������Ҫ�ָ���ֵ
			if(PrevMagicBackup != SephirothPlayer(ViewportOwner.Actor).PSI.Magic && UsedMagicBackup != SephirothPlayer(ViewportOwner.Actor).PSI.Magic)
			{
				PrevMagicBackup = None;
				UsedMagicBackup = None;
				return;
			}
			//rollback
			SephirothPlayer(ViewportOwner.Actor).PSI.Magic = PrevMagicBackup;
			PrevMagicBackup = None;
			UsedMagicBackup = None;
		}
	}
}

state LockupDetecting extends LockupBase
{
	function EndState()
	{
		DetectStartTime = 0;
	}
/*	function OnStartInteraction()
	{
		ControllerReceiveContext(ActionContext);
		DetectStartTime = ViewportOwner.Actor.Level.TimeSeconds;
	}*/
	function OnFinishInteraction()
	{
		if (!IsValidContext(ActionContext, CancelDelta))
			ClearContext(ActionContext);
		GotoState('Standing');
	}
	function OnTick(float DeltaTime)
	{
		Super.OnTick(DeltaTime);

		if(bFinishInteraction)
		{
			bFinishInteraction = False;
			ClearContext(ActionContext);
			GotoState('Standing');			
		}
		if (DetectStartTime > 0 && ViewportOwner.Actor.Level.TimeSeconds - DetectStartTime > DetectInterval) 
		{
			GotoState('Lockup');
		}
	}
}

state Lockup extends LockupBase
{
	function BeginState()
	{
		Decal.Lockup();
	}
//	function OnStartInteraction()
	function OnLeftInteraction()
	{
		local TraceContext TC;
		local EInteractType InteractType;

		//@by wj (040303) for stun
		if(bLostControl)
			return;

		// �������¿��� OnStartInteraction�� ������ Ǯ���� �ǵ��̰ų�
		// ȣ���Ǿ� �ִ� �ѿ��� �����Ϸ��� �Űų�
		// �̵��Ϸ��� �Űų� ����̴�.

		// ���⼭�� �� � ���ؽ�Ʈ�� ��Ʈ�ѷ����� �ѱ��� �ʰ� �ٸ�
		// LockupReleasing ���·� �����ϰ� ����.

		if (IsValidContext(HoverContext, CancelDelta))
			CopyContext(TC, HoverContext);
		else 
		{
			TraceAndMakeContext(TC, 5000, TCST_Click);
		}

		if (IsValidContext(TC)) 
		{
			InteractType = GetLButtonInteractType(TC.Actor);
			if (InteractType != IT_None) 
			{
				//CopyContext(HoverContext, TC, true);
				CopyContext(NextActionContext, TC, True);	//@by wj(040114)
				if (InteractType == IT_Move)
				{
					DecalAfter.Moving(TC.Normal);
				}
				else if(InteractType == IT_Talk || InteractType == IT_Pick)
					DecalAfter.Lockup();
				else 
				{
					DecalAfter.Detecting();
					DetectStartTime = ViewportOwner.Actor.Level.TimeSeconds;
				}
				DecalAfter.SetLockupActor(TC.Actor, TC.Location);
				DisableAutoAttack();    //@cs added
				GotoState('LockupReleasing');
			}
		}
	}

	function OnFinishInteraction()
	{
		DisableAutoAttack();    //@cs added
	}

	function bool OnMove()
	{
		//SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"Lockup OnMove",class'Canvas'.static.MakeColor(200,100,200));	
		//bIsKeyMoving = true; //@cs 
		//SephirothPlayer(ViewportOwner.Actor).StopAction();//@cs
		DisableAutoAttack();
		GotoState('LockupReleasing');
		return True;
	}
}

state LockupReleasing extends LockupBase
{

	function BeginState()
	{
		ReleaseStartTime = ViewportOwner.Actor.Level.TimeSeconds;
		Decal.Releasing();
		bFinishInteraction = False;
	}

	function OnLeftInteraction()
	{
		local TraceContext TC;
		local EInteractType InteractType;

		//@by wj (040303) for stun
		if(bLostControl)
			return;


		TraceAndMakeContext(TC, 5000, TCST_Click);

		if (IsValidContext(TC)) 
		{
			InteractType = GetLButtonInteractType(TC.Actor);

			if(InteractType == IT_AttackMelee || InteractType == IT_AttackBow) 
			{
				DetectStartTime = ViewportOwner.Actor.Level.TimeSeconds;
				DecalAfter.Detecting();
				DecalAfter.SetLockupActor(TC.Actor, TC.Location);

				CopyContext(NextActionContext, TC);	//@by wj(040114)
				bFinishInteraction = False;
			}
			else if(InteractType == IT_Pick || InteractType == IT_Talk) 
			{
				DecalAfter.Lockup();
				DecalAfter.SetLockupActor(TC.Actor, TC.Location);

				CopyContext(NextActionContext, TC);	//@by wj(040114)
			}
		}
	}
	function OnFinishInteraction()
	{
		bFinishInteraction = True;
	}
	function bool OnMove()
	{ 
		return True; 
	}
	event OnTick(float DeltaTime)
	{
		local EInteractType InteractType;
		local LockupDecal Dummy;

		if (ReleaseStartTime > 0 && ViewportOwner.Actor.Level.TimeSeconds - ReleaseStartTime > ReleaseInterval) 
		{
			//if (IsValidContext(HoverContext)) {
			if(IsValidContext(NextActionContext)) 
			{
				//InteractType = CalcInteractType(HoverContext.Actor);
				InteractType = GetLButtonInteractType(NextActionContext.Actor);
				if (InteractType != IT_None) 
				{
					//if (InteractType != IT_Move && DetectStartTime > 0) {
					if ((InteractType == IT_AttackMelee || InteractType == IT_AttackBow) && DetectStartTime > 0) 
					{
						// Ÿ���� �ٲٷ��� LockedTarget�� Ŭ��������� �Ѵ�.
						SephirothPlayer(ViewportOwner.Actor).LockedTarget = None;
						//ControllerReceiveContext(HoverContext, InteractType);
						//CopyContext(ActionContext, HoverContext);
						//ClearContext(HoverContext);
						ControllerReceiveContext(NextActionContext, InteractType);
						CopyContext(ActionContext, NextActionContext);
						ClearContext(NextActionContext);
						Dummy = DecalAfter;
						DecalAfter = Decal;
						Decal = Dummy;
						DecalAfter.SetLockupActor(None);
						
						if (ViewportOwner.Actor.Level.TimeSeconds - DetectStartTime > DetectInterval && !bFinishInteraction)
							GotoState('Lockup');
						else
							GotoState('LockupDetecting');
						return;
					}
					else if (InteractType == IT_Move || InteractType == IT_Talk || InteractType == IT_Pick) 
					{
						//ControllerReceiveContext(HoverContext, InteractType);
						//ClearContext(HoverContext);
						ControllerReceiveContext(NextActionContext, InteractType);
						ClearContext(NextActionContext);
					}
				}
			}
			DecalAfter.SetLockupActor(None);
			SephirothPlayer(ViewportOwner.Actor).StopAction();
			GotoState('Standing');
		}
	}
}

//@by wj(040116)------
function EInteractType GetLButtonInteractType(optional Actor Actor)
{
	local SephirothPlayer CC, OtherCC;
	local EInteractType InteractType;
	local Creature creature;
	local MonsterServerInfo MSI;
	local NpcServerInfo NSI;

	CC = SephirothPlayer(ViewportOwner.Actor);
	InteractType = IT_None;

	if( Actor != None )
	{
		if( Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor') )
			return IT_Move;
		else if(Actor.IsA('Monster') && !Character(Actor).bIsDead)
		{
			creature = Creature(Actor);
			MSI = MonsterServerInfo(ServerController(creature.Controller).MSI);
			NSI = NpcServerInfo(ServerController(creature.Controller).MSI);
			if ( MSI != None ) 
			{
				if( CC.PSI.Combo != None )
					InteractType = IT_AttackMelee;
			}
			else if (NSI != None) 
			{
				InteractType = IT_Talk;
			}
		}
		else if(Actor.IsA('NPC')) 
		{
			creature = Creature(Actor);
			MSI = MonsterServerInfo(ServerController(creature.Controller).MSI);
			NSI = NpcServerInfo(ServerController(creature.Controller).MSI);
			if ( MSI != None ) 
			{
				if ( CC.PSI.Combo != None )
					InteractType = IT_AttackMelee;
			}
			else if (NSI != None) 
			{
				InteractType = IT_Talk;
			}
		}
		else if(Actor.IsA('GuardStone') && class'PlayerServerInfo'.Static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI))
			InteractType = IT_AttackMelee;
		else if(Actor.IsA('MatchStone') && class'PlayerServerInfo'.Static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI))
			InteractType = IT_AttackMelee;
		else if(Actor.IsA('Hero') && !Character(Actor).bIsDead) 
		{
			OtherCC = SephirothPlayer(Hero(Actor).Controller);
			if( class'PlayerServerInfo'.Static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
				InteractType = IT_AttackMelee;
			else
				InteractType = IT_Talk;
		}
		else if(Actor.ISA('Attachment'))
			if( Attachment(Actor).Info.CanPickup(CC.PSI.PlayName) )
				InteractType = IT_Pick;
	}
	//@by wj(040804)------
	if( CC.PSI.bBlind && InteractType == IT_AttackMelee )
		InteractType = IT_None;
	//--------------------
	if( CC.PSI.JobName == 'Bow' && InteractType == IT_AttackMelee )
		InteractType = IT_AttackBow;

	return InteractType;
}

function EInteractType GetRButtonInteractType(optional Actor Actor)
{
	local Skill MagicSkill;
	local SephirothPlayer CC, OtherCC;
	local EInteractType InteractType;
	local MonsterServerInfo MSI;

	CC = SephirothPlayer(ViewportOwner.Actor);
	MagicSkill = CC.PSI.Magic;
	InteractType = IT_None;

	if( MagicSkill == None )
		return IT_None;

	if( Actor != None )
	{
		if( Actor == CC.Pawn && ((MagicSkill.bSelf && MagicSkill.bEnchant) || MagicSkill.IsA('SpiritSkill')) )
			InteractType = IT_Enchant;
		else if(Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor'))
		{
			if( MagicSkill.bServerHitCheck )
				return IT_AttackRange; //InteractType = IT_AttackRange; @by wj(040804)
		}
		else if (!MagicSkill.IsA('SpiritSkill')) 
		{
			if( Actor.IsA('Monster') && !Character(Actor).bIsDead ) 
			{
				MSI = MonsterServerInfo(ServerController(Creature(Actor).Controller).MSI);
				if ( MSI != None ) 
				{
					if( !MagicSkill.bEnchant )
						InteractType = IT_AttackRange;
					else if(!MagicSkill.bSelf && CC.PSI.JobName != 'Red') 
						InteractType = IT_Enchant;
				}
			}
			else if(Actor.IsA('GuardStone') && !MagicSkill.bEnchant &&
				class'PlayerServerInfo'.Static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI)) 
			{
				InteractType = IT_AttackRange;
			}
			else if(Actor.IsA('MatchStone') && !MagicSkill.bEnchant &&
				class'PlayerServerInfo'.Static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI)) 
			{
				InteractType = IT_AttackRange;
			}
			else if(Actor.IsA('Hero') && !Character(Actor).bIsDead) 
			{
				OtherCC = SephirothPlayer(Hero(Actor).Controller);
				if( MagicSkill.bEnchant && !MagicSkill.bSelf && CC != OtherCC )
					InteractType = IT_Enchant;
				else if(class'PlayerServerInfo'.Static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege))
					InteractType = IT_AttackRange;
			}
		}
	}
	else 
	{
		if( MagicSkill.bSelf )
			InteractType = IT_Enchant;
	}
	if( CC.PSI.bBlind && InteractType == IT_AttackRange )
		InteractType = IT_None;
	if( CC.PSI.bBlind && !MagicSkill.bSelf && InteractType == IT_Enchant )
		InteractType = IT_None;
	return InteractType;
}
//--------------------

//@by wj(03/03)----------
function EInteractType CalcInteractType(optional Actor Actor)
{	
	local Skill MagicSkill;
	local SephirothPlayer CC, OtherCC;
	local Creature creature;
	local MonsterServerInfo MSI;
	local NpcServerInfo NSI;

	CC = SephirothPlayer(ViewportOwner.Actor);

	if( Actor != None )
	{
		if( InteractionKey == IK_LeftMouse )
		{		
			if( Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor') )
				return IT_Move;
			if ( Actor.IsA('Monster') && !Character(Actor).bIsDead || Actor.IsA('NPC') ) 
			{
				creature = Creature(Actor);
				MSI = MonsterServerInfo(ServerController(creature.Controller).MSI);
				NSI = NpcServerInfo(ServerController(creature.Controller).MSI);
				if ( MSI != None && CC.PSI.Combo != None )
					return IT_AttackMelee;
				else if (NSI != None)
					return IT_Talk;
			}
			//@by wj(12/19)------
			//*jhjung,2003.12.29
			if ( Actor.IsA('GuardStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.Static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI) )
				return IT_AttackMelee;
			if ( Actor.IsA('MatchStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.Static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI) )
				return IT_AttackMelee;
			if ( Actor.IsA('Hero') && !Character(Actor).bIsDead ) 
			{
				OtherCC = SephirothPlayer(Hero(Actor).Controller);
				if ( CC.PSI.Combo != None && class'PlayerServerInfo'.Static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
					return IT_AttackMelee;
				else
					return IT_Talk;
			}
			//end*
			if( Actor.IsA('Attachment') )
				if( Attachment(Actor).Info.CanPickup(SephirothPlayer(ViewportOwner.Actor).PSI.PlayName) )
					return IT_Pick;			
		}
		else if(InteractionKey == IK_RightMouse)
		{
			MagicSkill = SephirothPlayer(ViewportOwner.Actor).PSI.Magic;

			if( Actor == ViewportOwner.Actor.Pawn && MagicSkill != None && MagicSkill.bSelf && MagicSkill.bEnchant )
				return IT_Enchant;
			if( Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor') )
				if( MagicSkill != None && /*MagicSkill.bIsSplash*/MagicSkill.bServerHitCheck );
			return IT_AttackRange;
			if( Actor.IsA('Monster') && !Character(Actor).bIsDead ) 
			{
				MSI = MonsterServerInfo(ServerController(Creature(Actor).Controller).MSI);
				if ( MSI != None ) 
				{
					if( MagicSkill != None && !MagicSkill.bEnchant )
						return IT_AttackRange;
				}
			}

			if ( Actor.IsA('GuardStone') &&
				MagicSkill != None &&
				!MagicSkill.bSelf &&
				class'PlayerServerInfo'.Static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI) ) 
			{
				return IT_AttackRange;
			}

			if ( Actor.IsA('MatchStone') &&
				MagicSkill != None &&
				!MagicSkill.bSelf &&
				class'PlayerServerInfo'.Static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI) ) 
			{
				return IT_AttackRange;
			}

			if ( Actor.IsA('Hero') && !Character(Actor).bIsDead && MagicSkill != None ) 
			{
				if ( MagicSkill.bEnchant && !MagicSkill.bSelf )
					return IT_Enchant;
				else 
				{
					OtherCC = SephirothPlayer(Hero(Actor).Controller);
					if ( class'PlayerServerInfo'.Static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
						return IT_AttackRange;
				}
			}
		}
	}
	else
	{
		MagicSkill = SephirothPlayer(ViewportOwner.Actor).PSI.Magic;
		if( MagicSkill != None && MagicSkill.bSelf && InteractionKey == IK_RightMouse )
			return IT_Enchant;
	}
	return IT_None;
}
//-----------------------

function EFilterResult FilterActor(Actor Actor)
{
	//@by wj(03/04)----------
	local Skill MagicSkill;
	local Skill ThisSkill;
	local SephirothPlayer CC;
	local SephirothPlayer OtherCC;
	local MonsterServerInfo MSI;
	local NpcServerInfo NSI;

	CC = SephirothPlayer(ViewportOwner.Actor);

	MagicSkill = SephirothPlayer(ViewportOwner.Actor).PSI.Magic;
	ThisSkill = SephirothPlayer(ViewportOwner.Actor).ThisSkill;

	if ( Actor.IsA('Creature') ) 
	{
		MSI = MonsterServerInfo(ServerController(Creature(Actor).Controller).MSI);
		NSI = NpcServerInfo(ServerController(Creature(Actor).Controller).MSI);
	}

	if ( Actor == ViewportOwner.Actor.Pawn && MagicSkill != None && MagicSkill.bSelf )
		return FR_Enchantable;
	//-----------------------
	if ( Actor == ViewportOwner.Actor.Pawn )
		return FR_Self;	
	if ( Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor') )
		return FR_Movable;	

	if ( MSI != None && ThisSkill != None && ThisSkill.bEnchant && !ThisSkill.bSelf )
		return FR_Enchantable;
	if ( NSI != None )
		return FR_Talkable;

	//@by wj(04/15)------
	if ( Actor.IsA('Hero') && ThisSkill != None && ThisSkill.bEnchant && !ThisSkill.bSelf )
		return FR_Enchantable;	
	//*jhjung,2003.12.23
	if ( Actor.IsA('Monster') && !Character(Actor).bIsDead )
		return FR_Attackable;
	if ( Actor.IsA('GuardStone') && class'PlayerServerInfo'.Static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI) )
		return FR_Attackable;
	if ( Actor.IsA('MatchStone') && class'PlayerServerInfo'.Static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI) )
		return FR_Attackable;
	if ( Actor.IsA('Hero') && !Character(Actor).bIsDead ) 
	{
		OtherCC = SephirothPlayer(Hero(Actor).Controller);
		if ( class'PlayerServerInfo'.Static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege) )
			return FR_Attackable;
	}
	//end*
	if ( Actor.IsA('Hero') && SephirothPlayer(ViewportOwner.Actor).PSI.PkState == False )
		return FR_Talkable;
	if ( Actor.IsA('Attachment') ) 
	{
		if ( Attachment(Actor).Info.CanPickup(SephirothPlayer(ViewportOwner.Actor).PSI.PlayName) )
			return FR_Pickable;
		return FR_NotOwnedPickable;
	}
	return FR_None;
}

function DebugLog(string message)
{
	SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,"DebugLog SephirothController: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

function bool ValidInput(EInputKey Key)
{
	local name JobName;
	local TraceContext TC;

	JobName = SephirothPlayer(ViewportOwner.Actor).PSI.JobName;
	switch (JobName) 
	{
		case 'Bare':
		case 'OneHand':
		case 'Bow':
			if ( IsInState('LockupBase') && Key == IK_RightMouse ) 
			{
				if ( JobName == 'Bow' ) 
				{ 
		// �û�� �������¿��� �ڽ������� ������ Ŭ���� �����Ѵ�.
					TraceAndMakeContext(TC, 5000, TCST_Reserved1);
					if ( !IsValidContext(TC) || TC.Actor != ViewportOwner.Actor.Pawn )
						return False;
				}
				else // �������� �Ѽհ������ �������¿��� ������ Ŭ���� �������� �ʴ´�.
					return False;
			}
			break;
		case 'Red':
		case 'Blue':
			if ( IsInState('LockupBase') && Key == IK_RightMouse ) 
			{
			//@by wj(11/20)------
				if( SephirothPlayer(ViewportOwner.Actor).PSI.Magic == None )
					return False;
			//-------------------
			}
			break; 
	}
	return True;
}

function DisplayDebug(Canvas C, out float YL, out float YPos)
{
	local float YY;
	C.SetPos(500,YY);
	C.DrawText(GetStateName());
	YY += 14;
	C.SetPos(500,YY);
	C.DrawText("HoverContext: "@HoverContext.Actor);
	YY += 14;
	C.SetPos(500,YY);
	C.DrawText("ActionContext: "@ActionContext.Actor);
	YY += 14;
	if ( Decal != None ) 
	{
		C.SetPos(500,YY);
		C.DrawText("DecalActor: "@Decal.LockupActor@"State"@Decal.DecalState);
		YY += 14;
	}
	if ( DecalAfter != None ) 
	{
		C.SetPos(500,YY);
		C.DrawText("DecalAfterActor: "@DecalAfter.LockupActor@"State"@DecalAfter.DecalState);
	}
}


//@cs added
function SwitchAutoPickup()
{
	local string InfoMessage;
	if( bAutoPickup )
		InfoMessage = Localize("Setting","PluginAutoPickupDisabled","Sephiroth");
	else
		InfoMessage = Localize("Setting","PluginAutoPickupEnabled","Sephiroth");					
	SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,InfoMessage,class'Canvas'.Static.MakeColor(255,255,0));
	
	if( SephirothInterface(SephirothPlayer(ViewportOwner.Actor).myHud).Plugin != None )
	{
		PagePlugin(SephirothInterface(SephirothPlayer(ViewportOwner.Actor).myHud).Plugin.Pages[0]).EnableAutoPickup(!bAutoPickup);
	}
	else
	{
		bAutoPickup = !bAutoPickup;
		class'PagePlugin'.Default.bAutoPickupSwitch = bAutoPickup;
		class'PagePlugin'.Static.StaticSaveConfig(); //not class'PagePlugin'.SaveConfig();
	}
}

function RecvEventToDisableAutoPickup()
{
	local string InfoMessage;
	if( bAutoPickup )
	{
		InfoMessage = Localize("Setting","PluginAutoPickupDisabledForBagFull","Sephiroth");
		SephirothPlayer(ViewportOwner.Actor).myHud.AddMessage(1,InfoMessage,class'Canvas'.Static.MakeColor(255,255,0));
		SwitchAutoPickup();
	}
}

defaultproperties
{
	DetectInterval=1.000000
	ReleaseInterval=0.500000
	CancelDelta=3.000000
	InterfaceSkin=(B=255,G=255,R=255)
	bActive=True
	bRequiresTick=True
}
