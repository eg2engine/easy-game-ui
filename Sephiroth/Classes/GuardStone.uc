class GuardStone extends Creature
	native;

#EXEC OBJ LOAD FILE=../Animations/GuardStone.ukx	PACKAGE=GuardStone

var array<string>	OffenseSkinNames;
// tf ���� 
var array<string>	DefenseSkinNames_1;
var array<string>	DefenseSkinNames_2;
var array<string>	DefaultSkinNames;

var class<Actor>	BlueEffectClass, RedEffectClass, WhiteEffectClass;
var Actor			GlowEffect;

var GuardStoneServerInfo GSI;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native final function SetSkin(INT Index);

native final function bool LoadModel(string NewMeshName, string NewAnimName);

event GuardStoneChange() 
{
//	//Log(Self @ GetStateName());
}

function SpawnPainEffect()
{
	local class<Emitter> Effect;
	local string EffectString;
	local int Random;

	if (int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2)
		return;

	EffectString = "SpecialFx.Skill_HitPain";
	Random = Rand(2);
	if (Random == 0)
		EffectString = EffectString $ "One";
	else if (Random == 1)
		EffectString = EffectString $ "Three";
	else
		EffectString = EffectString $ "Two";
	Effect = class<Emitter>(DynamicLoadObject(EffectString,class'Class'));
	Spawn(Effect,Self,,Location);
}

function SpawnKnockbackEffect()
{
	local class<Emitter> Effect;

	if (int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2)
		return;

	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitKnockback",class'Class'));
	Spawn(Effect,Self,,Location);
}

function SpawnCriticalEffect()
{
	local class<Emitter> Effect;

	if (int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail")) >= 2)
		return;

	Effect = class<Emitter>(DynamicLoadObject("SpecialFx.Skill_HitCritical", class'Class'));
	Spawn(Effect,Self,,Location);
}

function SpawnMissEffect();
function SpawnBlockEffect();

event Damaged(Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune)
{
	local bool bFinish;
	local string SoundString;
	local Sound HitSound;

	if (Skill != None && Skill.SlotType == Skill.SkillSlotType.SSLOT_Finish)
		bFinish = true;
	else
		bFinish = false;

	if (bPain && !bCritical)
		SpawnPainEffect();

	if ((bKnockback || bFinish) && !bCritical)
		SpawnKnockbackEffect();

	if (bCritical)
		SpawnCriticalEffect();

	if (bMiss)
		SpawnMissEffect();

	if (bBlock)
		SpawnBlockEffect();

	if (!bMiss && !bBlock && Skill != None) {
		SoundString = "EffectSound.Hit.";
		switch (Skill.BookName) {
		case "BareHand":
			SoundString = SoundString $ "Hand_";
			break;
		case "BareFoot":
			SoundString = SoundString $ "Kick_";
			break;
		case "OneHand":
			SoundString = SoundString $ "Sword_";
			break;
		case "Staff":
			SoundString = SoundString $ "Staff_";
			break;
		default:
			return;
		}
		if (bCritical)
			SoundString = SoundString $ "Critical";
		else if (bFinish)
			SoundString = SoundString $ "Finish";
		else
			SoundString = SoundString $ "Hit";

		HitSound = Sound(DynamicLoadObject(SoundString, class'Sound'));
		if (HitSound != None)
			PlaySound(HitSound,SLOT_Interact);
	}
}

auto state IdleState
{
	function BeginState()
	{
//		//Log(Self @ "Starting IdleState");
		bBlockZeroExtentTraces = True;
		if (HasAnim('Idle'))
			LoopIfNeeded('Idle', 1.0, 0.1);
	}
	event GuardStoneChange()
	{
		Global.GuardStoneChange();
		if (GSI != None) {
			if (GSI.Helth == 0)
				GotoState('DeadState');
		}
	}
}

state DeadState
{
	ignores CHAR_CheckCreatureWalkAnim,
			CHAR_CreatureWalkingAnim,
			CHAR_CheckWalkAnim,
			CHAR_PlayerWalkingAnim,
			AnimateStanding,
			AnimEnd,
			CHAR_TweenToWaiting,
			CHAR_PlayWaiting;

	function BeginState()
	{
//		//Log(Self @ "Starting DeadState");
		bBlockZeroExtentTraces = False;
		if(GlowEffect != None) {
			DetachFromBone(GlowEffect);
			GlowEffect.Destroy();
			GlowEffect = None;
		}
		if (HasAnim('Die'))
			PlayAnim('Die', 1.0);
	}
	event GuardStoneChange()
	{
		Global.GuardStoneChange();
		if (GSI != None) {
			if (GSI.Helth == GSI.MaxHelth)
				GotoState('IdleState');
		}
	}
}

//@by wj(12/20)------
static function bool IsGuardStoneAttackable(GuardStoneServerInfo GSI, PlayerServerInfo PSI)
{
//	//Log("=====>IsGuardStoneAttackable "@GSI.WarState@PSI.WarState@GSI.ClanName@PSI.ClanName);
	if(GSI.Helth == 0)
		return false;

	//if(GSI.WarState == 1 || PSI.WarState == 1)
	//	return false;
	if(GSI.WarState <= 1 || GSI.WarState > 3 || PSI.WarState <= 1 || PSI.WarState > 3)
		return false;

	if(GSI.WarState != PSI.WarState)
		return true;

	if(GSI.WarState == 3 && GSI.ClanName != PSI.ClanName)
		return true;

	return false;
}
//--------------------

defaultproperties
{
     AppClassTag="Npc"
}
