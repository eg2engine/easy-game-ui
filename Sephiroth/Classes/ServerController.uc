class ServerController extends AIController
	native;

var ModelServerInfo MSI;
var bool bInitialAction;

event NetRecv_PlayerMove(vector Dest,float Speed)
{
}

event NetRecv_CreatureMove(vector Dest,float Speed)
{
	if ( Speed != 0.0 && !Character(Pawn).IsInState('NetState_JustDead') ) 
	{
		Focus = None;
		Character(Pawn).AdjustRotation(Dest);
		Character(Pawn).SpeedAssignment(VSize(Dest - Pawn.Location) / Speed);  
		Destination = Dest;
		if ( Pawn.ActionStage != STAGE_None )
			Pawn.SetActionStage(STAGE_End);
		GotoState('CreatureWalking','Begin');
	}
	else if (Speed != 0.0) 
	{
		Destination = Dest;
		Pawn.SetLocation(Dest);
	}
}

//@by wj(040311)------
event NetRecv_StartStun()
{
	Character(Pawn).PlayAnimAction('Idle',1,0.1);
}
//--------------------

function SpawnPainEffect()
{
	local class<Emitter> Effect;
	local string EffectString;
	local int Random;

	if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
		return;

	EffectString = "SpecialFx.Skill_HitPain";
	Random = Rand(3);
	if ( Random == 0 )
		EffectString = EffectString$"One_A";
	else if (Random == 1)
		EffectString = EffectString$"Three_A";
	else
		EffectString = EffectString$"Two_A";
	//EffectString = EffectString $ "Three_A";
	Effect = class<Emitter>(DynamicLoadObject(EffectString,class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

function SpawnKnockbackEffect()
{
	local class<Emitter> Effect;

	if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
		return;

	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitKnockback_A",class'Class'));
	Spawn(Effect,Pawn,,Pawn.Location);
}

function SpawnCriticalEffect()
{
	local class<Emitter> Effect;

	if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
		return;

	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitCritical_A", class'Class'));
	Spawn(Effect, Pawn,, Pawn.Location);
}

function SpawnImmuneEffect(Pawn Attacker) 
{
	local ClientController CC;
	if ( Character(Attacker).IsAvatar() ) 
	{
		CC = ClientController(Attacker.Controller);
		CC.SpawnImmuneEffect(Self.Pawn);
	}
}


function SpawnSpecialPainEffect()
{
	local class<Emitter> Effect;

	if ( int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2 )
		return;

	if( InStr(MSI.ModelName, "Mist_Hermetheryne") != -1 )
	{
		Effect = class<Emitter>(DynamicLoadObject("SpecialFx.ManaBarrierBlue", class'Class'));
	}

	if( Effect != None )
		Spawn(Effect, Pawn,, Pawn.Location);
}

function SpawnMissEffect();
function SpawnBlockEffect();

/**
 * 受击事件处理（怪物/NPC专用）
 * 当怪物/NPC受到攻击时，服务器调用此函数处理受击效果
 * 包括播放受击动画、生成受击特效、播放受击音效等
 * 
 * @param Attacker 攻击者角色对象，造成此次伤害的源头
 * @param Skill 使用的技能对象，包含技能类型、名称等信息
 * @param bPain 是否产生疼痛效果（普通伤害）
 * @param bKnockback 是否产生击退效果（被击退）
 * @param bCritical 是否产生暴击效果（暴击伤害）
 * @param bMiss 是否未命中（攻击未命中目标）
 * @param bBlock 是否格挡（成功格挡攻击）
 * @param bImmune 是否免疫（免疫此次伤害）
 */
event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune)
{
	// 旋转角度：用于调整怪物面向攻击者的方向
	local rotator Rot;
	// 是否为终结技能：判断技能是否为终结技（Finish技能）
	local bool bFinish;
	// 音效路径字符串：用于构建受击音效的完整路径
	local string SoundString;
	// 受击音效对象：加载后的音效资源
	local Sound HitSound;

	// ========== 第一步：判断是否为终结技能 ==========
	// 如果技能存在且技能槽类型为终结技能（Finish），标记为终结技能
	if ( Skill != None && Skill.SlotType == Skill.SkillSlotType.SSLOT_Finish )
		bFinish = True;
	else
		bFinish = False;

	// ========== 第二步：调整怪物面向攻击者 ==========
	// 如果产生疼痛或击退效果，需要让怪物面向攻击者
	if ( bPain || bKnockback ) 
	{
		if ( Attacker != None ) 
		{
			// 获取怪物当前的旋转角度
			Rot = Pawn.Rotation;
			// 计算怪物面向攻击者的Yaw角度（水平旋转）
			Rot.Yaw = Rotator(Attacker.Location - Pawn.Location).Yaw;
			// 设置怪物的旋转角度，使其面向攻击者
			Pawn.SetRotation(Rot);
		}
	}

	// ========== 第三步：处理疼痛效果 ==========
	// 如果产生疼痛效果（普通伤害）
	if ( bPain ) 
	{
		// 播放疼痛动画
		Creature(Pawn).PlayPain();
		// 生成特殊疼痛特效（某些特殊怪物有独特的疼痛特效）
		SpawnSpecialPainEffect();
		// 如果不是暴击，生成普通疼痛特效（暴击有独立的特效，不需要普通疼痛特效）
		if ( !bCritical )
			SpawnPainEffect();
	}

	// ========== 第四步：处理击退效果 ==========
	// 如果产生击退效果或终结技能效果
	if ( bKnockback || bFinish ) 
	{
		// 如果是击退效果，播放击退动画
		if ( bKnockback )
			Character(Pawn).PlayAnimAction('Knockback', -1, 1.0, 0.3);
		// 如果不是暴击，生成击退特效（暴击有独立的特效，不需要击退特效）
		if ( !bCritical )
			SpawnKnockbackEffect();
	}
	
	// ========== 第五步：处理暴击效果 ==========
	// 如果产生暴击效果，生成暴击特效（暴击特效优先级最高）
	if ( bCritical )
		SpawnCriticalEffect();
	
	// ========== 第六步：处理未命中效果 ==========
	// 如果攻击未命中，生成未命中特效
	if ( bMiss )
		SpawnMissEffect();
	
	// ========== 第七步：处理免疫效果 ==========
	// 如果免疫此次伤害，生成免疫特效（在攻击者客户端显示）
	if ( bImmune )
		SpawnImmuneEffect(Attacker);
	
	// ========== 第八步：处理格挡效果 ==========
	// 如果成功格挡攻击，生成格挡特效
	if ( bBlock )
		SpawnBlockEffect();

	// ========== 第九步：播放受击音效 ==========
	// 只有在未命中或格挡的情况下才不播放音效（其他情况都需要播放音效）
	if ( !bMiss && !bBlock && Skill != None )
	{
		// 构建音效路径的基础部分
		SoundString = "EffectSound.Hit.";
		
		// 根据技能类型（武器类型）选择音效前缀
		switch (Skill.BookName)
		{
			case "BareHand":
				// 空手技能：使用手部攻击音效
				SoundString = SoundString$"Hand_";
				break;
			case "BareFoot":
				// 脚部技能：使用踢击音效
				SoundString = SoundString$"Kick_";
				break;
			case "OneHand":
				// 单手武器技能：使用剑类攻击音效
				SoundString = SoundString$"Sword_";
				break;
			case "Staff":
				// 法杖技能：使用法杖攻击音效
				SoundString = SoundString$"Staff_";
				break;
			default:
				// 其他技能类型不支持音效，直接返回
				return;
		}

		// 根据伤害类型选择音效后缀
		if ( bCritical )
			// 暴击伤害：使用暴击音效
			SoundString = SoundString$"Critical";
		else if (bFinish)
			// 终结技能：使用终结音效
			SoundString = SoundString$"Finish";
		else
			// 普通伤害：使用普通命中音效
			SoundString = SoundString$"Hit";

		// 动态加载音效资源
		HitSound = Sound(DynamicLoadObject(SoundString, class'Sound'));
		// 如果音效加载成功，播放音效
		if ( HitSound != None )
			Pawn.PlaySound(HitSound,SLOT_Interact);
	}
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	aPawn.bRotateToDesired = False;
}

function Initialize(ServerInfo ServerInfo, Creature Creature)
{
	MSI = ModelServerInfo(ServerInfo);
	MSI.SetOwner(Self);
	if ( MSI != None ) 
	{
		Possess(Creature);
	}
}

function MonsterMove(float DeltaTime); // 03.6.18 by BK

function DebugLog(string Message)
{
	Level.GetLocalPlayerController().myHud.AddMessage(1,"DebugLog ServerController: "@message,class'Canvas'.Static.MakeColor(128,255,255));;
}

event Tick(float DeltaTime)  // 2003.6.18 by BK
{
	Super.Tick(DeltaTime);
	MonsterMove(DeltaTime);
}

auto state CreatureWalking
{
	function AnimEnd(int Channel)
	{
		local float Rate, Frame;
		local name AnimName;

		if (Pawn != None && !Pawn.bDeleteMe) 
		{
			Pawn.GetAnimParams(0,AnimName, Frame, Rate);
		
			if (AnimName != Creature(Pawn).BasicAnim[0] && AnimName != Creature(Pawn).BasicAnim[1] && AnimName != Creature(Pawn).BasicAnim[2] && AnimName != Creature(Pawn).BasicAnim[3])
				Pawn.AppInstTag = 0;
			if (Channel == 0 && !Character(Pawn).bIsDead) 
			{
				Character(Pawn).HideAfterImage();
				Character(Pawn).SetActionStage(STAGE_End);
				Character(Pawn).CHAR_CreatureWalkingAnim();
			}
		}
	}

	function MonsterMove(float DeltaTime)  // 2003.6.18 by BK
	{
		local float Rate, Frame;
		local name AnimName;

		Pawn.GetAnimParams(0,AnimName, Frame, Rate);

		if((AnimName == Creature(Pawn).BasicAnim[1]) && (Creature(Pawn).bWalkAnim == False))
			Creature(Pawn).bWalkAnim = True;
	}

Begin:
	if (!Character(Pawn).bIsDead) 
	{
//		Character(Pawn).CHAR_CheckCreatureWalkAnim(); // delete 2003.7.1 by BK
		if (Destination != vect(0,0,0) && Destination != Pawn.Location) 
		{
			Character(Pawn).CHAR_PlayWalking(); // 2003.7.1 by BK
			MoveTo(Destination);
		}
	}
}

defaultproperties
{
}
