class SecondSkill extends Skill
	native;

enum SecondSkillType{
	SST_Passive,			// 0 PassiveSkill
	SST_ActiveTargetOnly,	// 1 SoulBlade, SoulFist, DeadlyCount, DeathHand
	SST_ActiveFury,			// 2 FireFury, IceFury, WideFury
	SST_ActiveBlast,		// 3 BlastBlade, BlastFist, BattleCry, AuraOfFury, SilenceAura
	SST_ActiveRainbowArrow, // 4 RainbowArrow
	SST_ActiveBarrier,		// 5 ManaBarrier, UltraEndure, AbsoluteDefense, GodSpeed, ManaSaver,
	SST_Transformation,		// 6 Transformation	@by wj(040723)
};

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var byte SkillType;
var float CoolTime;
var bool bCharged;
var float ChargeStartTime;
var int ShootingRange;
var int Grade;	// 0 : SecondSkill / 1 : Transformation / 2 : 3th Skill

function float GetChargeRate(int iAvilityLevel, float Seconds)
{
	local float ChargeRate, curtime, decCoolTime;

	if(ChargeStartTime != 0){
		decCoolTime = 0;
		if (iAvilityLevel >= 3 && iAvilityLevel <= 5)
		{
			if (SkillName == "DeathHand")
				decCoolTime = 15000;
			else if (SkillName == "BlindMaker")
				decCoolTime = 10000;
		}
		
		curtime = Seconds;
		ChargeRate = ((curtime - ChargeStartTime) * 1000) / (CoolTime-decCoolTime + 500);
		
		if(ChargeRate >= 1){
			ChargeRate = 1;
			bCharged = true;
		}
		else if(ChargeRate <= 0){
			ChargeRate = 0;
			ChargeStartTime = Seconds;
		}
	}
	return ChargeRate;
}

defaultproperties
{
     bEnabled=True
}
