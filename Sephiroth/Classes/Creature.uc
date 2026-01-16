class Creature extends Character
	native;

/* Display */
var(Display) array<string> SkinNames;
var(Display) array<Material> SkinMaterials;

struct native CreatureAnim
	{
	var() name SeqName;
	var() float AnimRate;
	var() float TweenTime;
};

var() array<CreatureAnim> MeleeAnims;
var() const float TransientMeleeAnimRate;
var() const float TransientMeleeTweenTime;
var() array<CreatureAnim> RangeActAnims;
var() const float TransientRangeActAnimRate;
var() const float TransientRangeActTweenTime;
var() array<CreatureAnim> MagicActAnims;
var() const float TransientMagicActAnimRate;
var() const float TransientMagicActTweenTime;

var() string RangeActEffectString;
var() string MagicActEffectString;

// chkim
var int SkinIndex;

var bool bWalkAnim; // 2003.6.18 by BK

var Material DeResMat0, DeResMat1;

enum PATTERN_STATE
{
	PS_WAITING,
	PS_PLAYING,
	PS_RESTING,
	PS_FINISHED,
};

struct native PATTERN_CONTROLLER
	{
	var float			timeStart;
	var PATTERN_STATE	eState;
	var int				nCount;
};

// Xelloss
var Pattern	PatternInfo;
var PATTERN_CONTROLLER	EffController;
var PATTERN_CONTROLLER	AniController;
var PATTERN_CONTROLLER	SndController;
var PATTERN_CONTROLLER	MsgController;

var BOOL	bPatternAnimating;

var string	strRealName;		// Xelloss - ������ SD���� ���Ǵ� �̸�
var int		nSymbol;			//			- �Ӹ����� ����� ��ȣ��
var string	strShortName;		//			- �˻��� ���� �̸�(��)

var CNpcInformation	sInfoMesh;			// ���� ǥ�ÿ� �޽�

native final function CopySkinMaterialsToSkins();

native function PlayPatternEffect(string strEffRes);
native function StopPatternEffect(string strEffRes);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


/*
event Destroyed()
{
	local int i;
	Super.Destroyed();
	for (i=0;i<GameManager(Level.Game).Creatures.Length;i++) {
		if (GameManager(Level.Game).Creatures[i] == Self) {
			GameManager(Level.Game).Creatures.Remove(1, i);
			break;
		}
	}
}
*/

simulated function PlayWaiting()
{
	if ( Physics == PHYS_Falling )
		PlayFalling();
	else
		AnimateStanding();
}

simulated function PlayMoving()
{
	AnimateWalking();
}

function PlayDying(class<DamageType> DamageType, vector HitLoc) 
{ 
	SetPhysics(PHYS_Walking); 
}

function GibbedBy(actor Other) 
{
}

function TakeFallingDamage() 
{
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
}

event NetRecv_BeginPlay()
{
	// should be called when occupant moved in and the occupant is a player type
	// for the locally controlled player, shouldn't be called
	Super.NetRecv_BeginPlay();
	Controller = Spawn(class'ServerController');
	Controller.Possess(Self);
	Controller.SetRotation(Rotation);
}

/* LoopIfNeeded()
play looping idle animation only if not already animating
*/
simulated function LoopIfNeeded(name NewAnim, float NewRate, float BlendIn)
{
	local name OldAnim;
	local float frame,rate;

	GetAnimParams(0,OldAnim,frame,rate);

	// FIXME - get tween time from anim
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, BlendIn);
	else
		LoopAnim(NewAnim, NewRate);
}

simulated function AnimateStanding()
{
	LoopIfNeeded('Idle',1.0,0.1);
}

simulated function AnimateWalking()
{
	MovementAnims[0] = 'Walk';
	MovementAnims[1] = 'Walk';
	MovementAnims[2] = 'Walk';
	MovementAnims[3] = 'Walk';
}

function AnimEnd(int Channel)
{
	Super.AnimEnd(Channel);

	if ( ActionStage != STAGE_None )
	{
//		//Log(Self $ " AnimEnd");
		SetActionStage(STAGE_End);
		CHAR_TweenToWaiting(0.1);
	}
}

event NetRecv_PlayMelee(name GivenMelee,optional float GivenAnimRate,optional float GivenTweenTime)
{
	local int i;
	local float AnimRate,TweenTime;
	local name AnimName;

	//Log(Self@"NetRecv_PlayMelee"@GivenMelee@GivenAnimRate@GivenTweenTime);
	//Log("TEST TEST PlayMelee");
	if ( GivenMelee == '' || GivenMelee == 'None' ) 
	{
		i = Rand(MeleeAnims.Length);
		AnimName = MeleeAnims[i].SeqName;
		AnimRate = MeleeAnims[i].AnimRate;
		TweenTime = MeleeAnims[i].TweenTime;
	}
	else 
	{
		AnimName = GivenMelee;
		AnimRate = GivenAnimRate;
		TweenTime = GivenTweenTime;
	}

	if ( AnimName != '' )
	{
		if ( AnimRate == 0.0 )
			AnimRate = TransientMeleeAnimRate;

		if ( TweenTime == 0.0 )
			TweenTime = TransientMeleeTweenTime;

		if ( !IsA('Monster') || !bPatternAnimating )
			PlayAnimAction(AnimName, -1, AnimRate, TweenTime);

		AppInstTag = 1;
	}
}


event NetRecv_ActRange(Skill Skill, name GivenRange,float GivenAnimRate, float GivenTweenTime, Actor TargetActor,vector TargetLocation,float ActRatio,int ActPitch)
{
	local int i;
	local float AnimRate, TweenTime;
	local name AnimName;
	local class<Actor> MobFxClass;
	local Actor MobFx;

	if ( GivenRange == '' || GivenRange == 'None' )
	{
		i = Rand(RangeActAnims.Length);
		AnimName = RangeActAnims[i].SeqName;
		AnimRate = RangeActAnims[i].AnimRate;
		TweenTime = RangeActAnims[i].TweenTime;
	}
	else
	{
		AnimName = GivenRange;
		AnimRate = GivenAnimRate;
		TweenTime = GivenTweenTime;
	}

	if ( AnimName != '' )
	{
		if ( AnimRate == 0.0 )
			AnimRate = TransientRangeActAnimRate;

		if ( TweenTime == 0.0 )
			TweenTime = TransientRangeActTweenTime;
			
		// keios - �ӽ�: Modelcache���� RangeActEffectString�� �����ϸ� �װ��� ����Ѵ�.
		// keios - ����: Skill�� None�� ��츸 RangeActEffectString�� ����Ѵ�.
		if ( Skill != None )
			MobFxClass = Skill.FireClass;
		else if(RangeActEffectString != "")
			MobFxClass = class<Actor>(DynamicLoadObject(RangeActEffectString, class'class'));

		if ( MobFxClass != None )
		{
			MobFx = Spawn(MobFxClass,,,Location,Rotation);

			if ( MobFx != None )
			{
				if ( MobFx.IsA('EffectProjectile') )
				{
					EffectProjectile(MobFx).TargetActor = TargetActor;
					EffectProjectile(MobFx).bTouchOnlySeek = True;
					EffectProjectile(MobFx).DamageType = 2;

					EffectProjectile(MobFx).FlyingType = FT_Guided;	// keios - always guided for monster skills
				}
			}
		}

		if ( !IsA('Monster') || !bPatternAnimating )
			PlayAnimAction(AnimName, -1, AnimRate, TweenTime);

		AppInstTag = 1;
	}
}


event NetRecv_Cast(Skill Skill, Actor TargetActor, vector TargetLocation, float Duration)
{
	local name AnimName;
	local int i;

	i = Rand(MagicActAnims.Length);
	AnimName = MagicActAnims[i].SeqName;
	if ( AnimName == '' )
		AnimName = 'Magic';

	if ( HasAnim(AnimName) )
	{
		if ( !IsA('Monster') || !bPatternAnimating )
			PlayAnim(AnimName, 1.0, 0.3);
	}

}


/**
 * 网络接收技能发射事件（怪物/NPC专用）
 * 当服务器广播其他角色（玩家或怪物）的技能发射时，怪物/NPC客户端接收并生成相应的特效
 * 
 * @param Skill 技能对象，包含技能配置信息（特效类型、发射数量等）
 * @param TargetActor 目标角色对象，如果为None则使用TargetLocation作为目标点
 * @param TargetLocation 目标位置向量，当TargetActor无效时使用此位置
 */
event NetRecv_Fire(Skill Skill, Actor TargetActor, vector TargetLocation)
{
	// 特效类：用于生成技能特效的类（爆炸特效或投射物）
	local class<Actor> MobFxClass;
	// 生成的特效实例
	local Actor MobFx;
	// 特效生成位置
	local vector SpawnLocation;
	// 特效生成旋转
	local rotator SpawnRotation;

	// 投射物相关变量
	local vector BoneLocation;		// 发射骨骼位置（如手部、武器等）
	local rotator AimRotation;		// 瞄准旋转角度
	local int i;						// 循环计数器（用于多发射物）
	local float rot;					// 角度偏移量（用于多发射物扇形分布）

	// ========== 第一步：生成施法特效 ==========
	// 如果技能配置了施法特效类（CastClass），在怪物位置生成施法特效
	if ( Skill != None && Skill.CastClass != None )
	{
		Spawn(Skill.CastClass, , , Location, Rotation);
	}

	// ========== 第二步：确定特效类型 ==========
	// 优先使用ExtraClass（第二技能的特殊特效类），否则使用FireClass（普通发射特效类）
	if ( Skill != None && Skill.ExtraClass != None )
		MobFxClass = Skill.ExtraClass;
	else 
		MobFxClass = Skill.FireClass;

	// ========== 第三步：根据特效类型生成不同的特效 ==========
	if ( MobFxClass != None )
	{
		// ---------- 情况1：范围技能（爆炸类特效）----------
		// 判断是否为范围技能：ApocalypseType（天启类型）或 MagicSplash（魔法爆炸）
		if ( ClassIsChildOf(MobFxClass, class'ApocalypseType') || ClassIsChildOf(MobFxClass, class'MagicSplash') )
		{
			// 确定爆炸特效的生成位置：优先使用目标角色位置，否则使用目标位置
			if ( TargetActor != None )
				SpawnLocation = TargetActor.Location;
			else
				SpawnLocation = TargetLocation;

			// 使用怪物自身的旋转作为爆炸特效的旋转
			SpawnRotation = Rotation;
			
			// 在目标位置生成爆炸特效
			MobFx = Spawn(MobFxClass,,,SpawnLocation,SpawnRotation);
		}
		// ---------- 情况2：投射物技能（需要飞行轨迹的特效）----------
		else if (ClassIsChildOf(MobFxClass, class'EffectProjectile'))
		{
			// 初始化发射位置和旋转
			SpawnLocation = Location;
			SpawnRotation = Rotation;
			// 获取发射骨骼的世界坐标位置（如手部、武器等骨骼）
			BoneLocation = GetBoneCoords(Skill.FireBone).Origin;

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
				if ( i > 0 )
				{
					// 计算角度偏移量：每两个投射物为一组，偏移角度递增
					// 公式：(i+1)/2 * 100 度，例如：i=1时为100度，i=2时为150度，i=3时为200度
					rot = (i + 1) / 2 * 100;
					// 偶数索引的投射物向左偏移（负角度），奇数索引向右偏移（正角度）
					// 形成左右交替的扇形分布效果
					if( i%2 == 0 ) 
						rot = -1 * rot;
					// 将偏移角度添加到Yaw轴（水平旋转）
					AimRotation.Yaw = AimRotation.Yaw + rot;
					// 同时调整骨骼位置（用于视觉效果，使发射点也偏移）
					BoneLocation.X = BoneLocation.X + rot;
					BoneLocation.Y = BoneLocation.Y + rot;
				}

				// 在发射位置生成投射物实例
				MobFx = Spawn(MobFxClass,,,BoneLocation,AimRotation);

				// 如果成功生成且是EffectProjectile类型，设置投射物属性
				if ( MobFx != None )
				{
					if ( MobFx.IsA('EffectProjectile') ) 
					{
						// 设置目标角色（投射物会追踪此目标）
						EffectProjectile(MobFx).TargetActor = TargetActor;
						// 设置技能名称，用于伤害计算和特效识别
						EffectProjectile(MobFx).SkillName = Skill.SkillName;
						// 设置是否跳过命中检测（附魔类技能可能不需要检测）
						EffectProjectile(MobFx).bNoCheckHit = Skill.bEnchant;
						// 设置伤害类型（箭矢、分裂箭、云、吐息、天启、箭雨等）
						EffectProjectile(MobFx).DamageType = Skill.DamageType;
						// 设置只追踪目标（不会碰撞其他对象，只追踪指定目标）
						EffectProjectile(MobFx).bTouchOnlySeek = True;
						
						// 强制设置为追踪模式（怪物技能始终使用追踪模式，确保命中目标）
						EffectProjectile(MobFx).FlyingType = FT_Guided;	// keios - always guided for monster skills
					}
				}
			}
		}

		// ========== 第四步：设置特效的最终属性 ==========
		if ( MobFx != None ) 
		{
			// 如果是投射物类型，再次确认设置属性（防止循环外遗漏）
			if ( MobFx.IsA('EffectProjectile') ) 
			{
				EffectProjectile(MobFx).TargetActor = TargetActor;
				EffectProjectile(MobFx).SkillName = Skill.SkillName;
				EffectProjectile(MobFx).bNoCheckHit = Skill.bEnchant;
				EffectProjectile(MobFx).DamageType = Skill.DamageType;
				EffectProjectile(MobFx).bTouchOnlySeek = True;
			}
			// 如果是魔法爆炸类型，设置爆炸半径（固定为800单位）
			if ( MobFx.IsA('MagicSplash') ) 
			{
				MagicSplash(MobFx).SetRadius(800);
			}
		}
	}
}


function FireRange()
{
}


function PlayPain()
{
	SetActionStage(STAGE_None);
	Super.PlayPain();
	
	if ( !IsA('Monster') || !bPatternAnimating )
		PlayAnim('Pain', 2, 0.3);
}

//check neive : ���� ��� ƽ, �׾��� �� ������ ������� �� ���⼭ �ϴ� ��
event DeadTimer(float AfterDeadTime)
{
	local int i;
	local Combiner combTex;
	local FinalBlend FinalTex;
	local bool bShowDeadFx;

	if ( AfterDeadTime >= 0.5f )
		SetCollision(False, False, False);

	if ( AfterDeadTime >= 2.0f && Shadow != None )
		Shadow.bHidden = True;

	if( AfterDeadTime >= 0.85f && Level.DetailMode == DM_SuperHigh )
	{
		if ( !bStyleCreated )
		{
			bShowDeadFx = bool(ConsoleCommand("GETOPTIONI ShowDeadEffect"));
			//if(bShowDeadFx)
			//	return;
			CreateStyle();
			if ( bStyleCreated )
			{
				if( bShowDeadFx )
				{
					//AdjustColorStyle(class'Canvas'.static.MakeColor(127,127,127));
					AdjustColorStyle(class'Canvas'.Static.MakeColor(255,255,255));

					//// ��Ų ��ü��.. ��Ⱑ �°ڱ�.	
					for ( i = 0;i < Skins.Length;i++ )
					{
						//Skins[i] = FinalBlend(DynamicLoadObject("AlpTest_T.AlpTest_Final",class'FinalBlend'));
						//ColorStyle[i].Material = FinalBlend(DynamicLoadObject("AlpTest_T.AlpTest_Final",class'FinalBlend'));
						//combTex.Material1 = FinalBlend(DynamicLoadObject("AlpTest_T.AlpTest_Final",class'FinalBlend'));
						//combTex.Material2 = BlendStyle[i].Material;
						//ColorStyle[i].Material = Combiner(DynamicLoadObject("AlpTest_T2.AlpTestDie",class'Combiner'));
						//FinalTex = FinalBlend(DynamicLoadObject("AlpTest_T.AlpTest_Final",class'FinalBlend'));
						//ColorStyle[i].Material = FinalTex;
						combTex = Combiner(DynamicLoadObject("AlpTest_T2.AlpTestDie",class'Combiner'));
						combTex.Material1 = BlendStyle[i].Material;
						combTex.Material2 = FinalBlend(DynamicLoadObject("AlpTest_T.AlpTest_Final",class'FinalBlend'));
						combTex.Mask = combTex.Material2;
						combTex.CombineOperation = CO_Subtract;
						combTex.AlphaOperation = AO_Multiply;
						ColorStyle[i].Material = combTex;

						//ColorStyle[i].Material = FinalBlend(DynamicLoadObject("JEF_Monster_T0123.Die_AlpTest_T01F",class'FinalBlend'));
						//BlendStyle[i].Material = Texture(DynamicLoadObject("AlpTest_T.AlpTestMap",class'Texture'));
						ColorStyle[i].Material = FinalBlend(DynamicLoadObject("JEF_Monster_T.Die_FinalBlend_F",class'FinalBlend'));
						ColorStyle[i].Color.A = 255;
						Skins[i] = ColorStyle[i];
					}
					//for (i = 0;i < Skins.Length;i++)
					//{
					//	ColorStyle[i].Material = DeResMat0;
					//	ColorStyle[i].Color.A = 255;
					//	Skins[i] = ColorStyle[i];
					//	//Skins[i] = DeResMat0;
					//}
				}
				else
				{
					AdjustColorStyle(class'Canvas'.Static.MakeColor(127,127,127));
				}
			}
		}
		if ( bStyleCreated )
			AdjustAlphaFade(255 - FClamp((AfterDeadTime - 0.85f) / 4.0, 0.0, 1.0) * 255);
			//AdjustAlphaFade(255 - FClamp(AfterDeadTime / 3.0, 0.0, 1.0) * 255);
	}
}

// Overload PreCreateStyle
function PreCreateStyle()
{
	CopySkinMaterialsToSkins();
}

function CreateStyle()
{
	local int i;

	PreCreateStyle();
	for ( i = 0;i < Skins.Length;i++ ) 
	{
		if ( Skins[i] == None )
			break;
		if ( !bStyleCreated ) 
		{
			ColorStyle[i] = new(None) class'ColorModifier';
			BlendStyle[i] = new(None) class'FinalBlend';
		}
		BlendStyle[i].Material = Skins[i];
		BlendStyle[i].AlphaTest = True;
		BlendStyle[i].FrameBufferBlending = BlendStyle[i].EFrameBufferBlending.FB_AlphaBlend;
		ColorStyle[i].Material = BlendStyle[i];
		ColorStyle[i].Color.A = 255;
		Skins[i] = ColorStyle[i];
	}
	if ( Skins.Length > 0 )
		bStyleCreated = True;
}

event NetRecv_PatternInfo(Pattern sInfo)
{
	// ���� �������� ������ �ִٸ� ��� �����Ѵ�.
	if ( PatternInfo.strEffRes != "" )
		StopPatternEffect(PatternInfo.strEffRes);

	if ( PatternInfo.strAniRes != '' )
		bPatternAnimating = False;

	PatternInfo.strKey = sInfo.strKey;

	// Effect����
	PatternInfo.strEffRes = sInfo.strEffRes;
	PatternInfo.strEffAttach	= sInfo.strEffAttach;
	PatternInfo.fEffDelay = sInfo.fEffDelay;
	PatternInfo.fEffPlaying = sInfo.fEffPlaying;
	PatternInfo.nEffRepeat = sInfo.nEffRepeat;
	PatternInfo.fEffInterval	= sInfo.fEffInterval;

	EffController.timeStart = Controller.Level.TimeSeconds;
	EffController.nCount	= PatternInfo.nEffRepeat;
	EffController.eState	= PS_WAITING;
	
	// Animation����
	PatternInfo.strAniRes = sInfo.strAniRes;
	PatternInfo.fAniDelay = sInfo.fAniDelay;
	PatternInfo.fAniPlaying = sInfo.fAniPlaying;
	PatternInfo.nAniRepeat = sInfo.nAniRepeat;
	PatternInfo.fAniInterval	= sInfo.fAniInterval;

	AniController.timeStart = Controller.Level.TimeSeconds;
	AniController.nCount = PatternInfo.nAniRepeat;
	AniController.eState = PS_WAITING;
	
	// Animation����
	PatternInfo.strSndRes = sInfo.strSndRes;
	PatternInfo.fSndDelay = sInfo.fSndDelay;
	PatternInfo.nSndRepeat = sInfo.nSndRepeat;
	PatternInfo.fSndInterval	= sInfo.fSndInterval;

	SndController.timeStart = Controller.Level.TimeSeconds;
	SndController.nCount = PatternInfo.nSndRepeat;
	SndController.eState = PS_WAITING;
	
	// Message����
	PatternInfo.strMsgRes = sInfo.strMsgRes;
	PatternInfo.fMsgDelay = sInfo.fMsgDelay;
	PatternInfo.nMsgRepeat = sInfo.nMsgRepeat;
	PatternInfo.fMsgInterval	= sInfo.fMsgInterval;

	MsgController.timeStart = Controller.Level.TimeSeconds;
	MsgController.nCount	= PatternInfo.nMsgRepeat;
	MsgController.eState	= PS_WAITING;
	
	PlayerController(Controller).myHud.AddMessage(255, "Xelloss Test", class'Canvas'.Static.MakeColor(255, 255, 255));
}


event SetNpcInfo(int nIndex)
{
/*	local string	strMesh;

	if ( nIndex == 0 )
	{
		if ( sInfoMesh != None )
		{
			sInfoMesh.Destroy();
			sInfoMesh = None;
		}
	}
	else
	{
		if ( nSymbol > 0 )
		{
			sInfoMesh.Destroy();
			sInfoMesh = None;
		}

		sInfoMesh.SetMesh(nIndex);
	}*/

	if ( sInfoMesh == None )
		sInfoMesh = Spawn(class'CNpcInformation', Self,,Location + vect(0, 0, 130));

	nSymbol = nIndex;

	if ( sInfoMesh != None )
	{
		//Log("SetNpcInfo sInfoMesh != None nSymbol"@string(nSymbol));
		sInfoMesh.SetMesh(nSymbol);
	}

	//Log("SetNpcInfo"@strRealName@string(Location + vect(0, 0, 130)));
}

function DebugLog(string message)
{
	PlayerController(Controller).myHud.AddMessage(1,"DebugLog Creature: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}


event SetNpcRealName(string strName)
{
	strRealName = strName;
}

defaultproperties
{
	MeleeAnims(0)=(SeqName="Melee",AnimRate=1.000000)
	TransientMeleeAnimRate=1.000000
	TransientMeleeTweenTime=0.300000
	RangeActAnims(0)=(SeqName="Range",AnimRate=1.000000)
	TransientRangeActAnimRate=1.000000
	TransientRangeActTweenTime=0.300000
	MagicActAnims(0)=(SeqName="Magic",AnimRate=1.000000)
	TransientMagicActAnimRate=1.000000
	TransientMagicActTweenTime=0.300000
	SkinIndex=-1
	bWalkAnim=True
	DeResMat0=FinalBlend'DeRez.Shaders.DeRezFinalBody'
	DeResMat1=FinalBlend'DeRez.Shaders.DeRezFinalHead'
	BasicAnim(0)="Idle"
	BasicAnim(1)="Walk"
	BasicAnim(2)="Walk"
	BasePivot="Bip01 L Toe0"
	ControllerClass=None
}
