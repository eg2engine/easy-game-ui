class MatchStone extends Creature
	native;

//#EXEC OBJ LOAD FILE=../Animations/MatchStone.ukx	PACKAGE=MatchStone

var array<string>	OffenseSkinNames;
var array<string>	DefenseSkinNames;
var array<string>	DefaultSkinNames;

var MatchStoneServerInfo MSI;

// (cpptext)
// (cpptext)
// (cpptext)

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
		bBlockZeroExtentTraces = True;
		if (HasAnim('Idle'))
			LoopIfNeeded('Idle', 1.0, 0.1);
	}
}

defaultproperties
{
     AppClassTag="Npc"
}
