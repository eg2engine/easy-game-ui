class EnchantType extends Actor
	native
	abstract;

var class<Effects> EnchantEffectClass;
var class<Emitter> EnchantEmitterClass;
var class<Projector> EnchantDecalClass;

var string EnchantDesc;
var Character EnchantCharacter;
var Effects EnchantEffect;
var Emitter EnchantEmitter;
var Projector EnchantDecal;
var Name AttachBone;
var Vector AttachOffset;
var Sound EnchantSound;
var bool bAutoCalcOffset;

//@by wj(04/01)------
enum EnchantAttachType
{
	EA_Head,
	EA_Spine,
};

var EnchantAttachType AttachType;

/**
 * PostBeginPlay - 初始化附魔特效系统
 * 当附魔对象被创建时，负责生成并附加所有相关的特效组件
 * 根据怪物模型大小自动调整特效缩放，确保特效与怪物大小匹配
 *
 * 工作流程：
 * 1. 验证所有者对象是否存在
 * 2. 获取角色引用
 * 3. 获取怪物模型缩放信息
 * 4. 创建粒子发射器特效并绑定到角色骨骼
 * 5. 创建效果特效并绑定到角色骨骼
 * 6. 创建贴花投影特效
 * 7. 调用父类的初始化方法
 */
simulated function PostBeginPlay()
{
	local float EffectScale;
	local MonsterServerInfo MSI;


	// ========== 第一步：基础验证 ==========
	// 确保附魔对象有有效的所有者（通常是角色对象）
	// 如果没有所有者，立即销毁自己以防止内存泄漏
	if( Owner == None )
	{
		Destroy();
		return;
	}

	// ========== 第二步：获取角色引用 ==========
	// 将所有者对象转换为Character类型，以便后续操作
	// Character是所有可附魔角色的基类（包括玩家、怪物等）
	EnchantCharacter = Character(Owner);

	// ========== 第二步半：获取怪物缩放信息 ==========
	// 获取怪物的模型缩放值，用于适配特效大小
	// 对于大型怪物，特效也需要相应放大

	EffectScale = 1.0f; // 默认缩放值

	// 如果是怪物，获取其模型缩放值
	if ( Monster(EnchantCharacter) != None )
	{
		MSI = MonsterServerInfo(ServerController(EnchantCharacter.Controller).MSI);
		if ( MSI != None && MSI.ModelScale > 0.0f )
		{
			EffectScale = MSI.ModelScale * 1.5f;
		}
	}

	// ========== 第三步：创建粒子发射器特效 ==========
	// EnchantEmitterClass定义了粒子发射器的类类型
	// 如果配置了粒子发射器类，则创建对应的特效实例
	if ( EnchantEmitterClass != None ) 
	{
		// 在角色位置生成粒子发射器特效，使用角色的位置和旋转
		EnchantEmitter = Spawn(EnchantEmitterClass,Owner,,EnchantCharacter.Location,EnchantCharacter.Rotation);

		// ========== 绑定粒子发射器到角色骨骼 ==========
		// 如果指定了特定的骨骼名称，将特效绑定到该骨骼
		if ( AttachBone != '' && AttachBone != 'None' ) 
		{
			// 使用指定的骨骼名称进行绑定
			EnchantCharacter.AttachToBone(EnchantEmitter, AttachBone);
		}
		// 如果没有指定具体骨骼，使用预定义的骨骼类型
		//@by wj(04/01)------ 骨骼绑定系统改进
		else
		{
			// 根据AttachType枚举值选择合适的骨骼
			if( AttachType == EA_Spine )
			{
				// 绑定到脊柱骨骼（通常是躯干位置）
				EnchantCharacter.AttachToBone(EnchantEmitter, EnchantCharacter.BoneSpine);
			}
			else if(AttachType == EA_Head)
				// 绑定到头部骨骼（通常是头顶位置）
				EnchantCharacter.AttachToBone(EnchantEmitter, EnchantCharacter.BoneHead);
		}

		//-------------------
		// 设置粒子发射器相对于绑定骨骼的偏移位置
		// AttachOffset允许精确控制特效的位置
		EnchantEmitter.SetRelativeLocation(AttachOffset);
	}

	// ========== 第四步：创建效果特效 ==========
	// EnchantEffectClass定义了效果特效的类类型
	// 如果配置了效果特效类，则创建对应的特效实例
	if ( EnchantEffectClass != None )
	{
		// 生成效果特效实例
		EnchantEffect = Spawn(EnchantEffectClass,Owner);
		// ========== 绑定效果特效到角色骨骼 ==========
		// 使用与粒子发射器相同的绑定逻辑
		if ( AttachBone != '' && AttachBone != 'None' )
		{
			EnchantCharacter.AttachToBone(EnchantEffect, AttachBone);
		}
		//@by wj(04/01)------ 骨骼绑定系统改进
		else
		{
			// 根据AttachType枚举值选择合适的骨骼
			if( AttachType == EA_Spine )
			{
				// 根据怪物大小设置效果特效缩放
				EnchantEffect.SetDrawScale(EnchantEffect.DrawScale * EffectScale);
				// 绑定到脊柱骨骼（躯干位置）
				EnchantCharacter.AttachToBone(EnchantEffect, EnchantCharacter.BoneSpine);
			}
			else if(AttachType == EA_Head)
				// 绑定到头部骨骼（头顶位置）
				EnchantCharacter.AttachToBone(EnchantEffect, EnchantCharacter.BoneHead);
		}
		//-------------------
	}

	// ========== 第六步：创建贴花投影特效 ==========
	// EnchantDecalClass定义了贴花投影的类类型
	// 贴花通常用于地面效果或墙壁效果，不需要骨骼绑定
	if ( EnchantDecalClass != None ) 
	{
		// 在角色位置生成贴花投影特效
		EnchantDecal = Spawn(EnchantDecalClass,Owner,,EnchantCharacter.Location,EnchantCharacter.Rotation);
	}

	// ========== 第七步：完成初始化 ==========
	// 调用父类的PostBeginPlay方法，完成Actor的初始化
	Super.PostBeginPlay();
}

function DebugLog(string message)
{
	Level.GetLocalPlayerController().myHud.AddMessage(1,"DebugLog EnchantType: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

function PlaySpawnSound(Sound Snd)
{
	if ( EnchantCharacter != None )
		EnchantCharacter.PlaySound(Snd, SLOT_None, 3.0f);
}

event Destroyed()
{
	if ( EnchantEmitter != None ) 
	{
		if( EnchantCharacter != None )
			EnchantCharacter.DetachFromBone(EnchantEmitter);
		EnchantEmitter.Destroy();
		EnchantEmitter = None;
	}
	if ( EnchantEffect != None ) 
	{
		if( EnchantCharacter != None )
			EnchantCharacter.DetachFromBone(EnchantEffect);
		EnchantEffect.Destroy();
		EnchantEffect = None;		
	}
	if ( EnchantDecal != None ) 
	{
		EnchantDecal.Destroy();
		EnchantDecal = None;
	}
	Super.Destroyed();
}

defaultproperties
{
	bHidden=True
}
