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
var float ServerCooldownEndTime;

function SetServerRemainingCoolTime(int RemainingMs, float Seconds)
{
	if (RemainingMs > 0)
	{
		ServerCooldownEndTime = Seconds + float(RemainingMs) / 1000.0;
		bCharged = false;
	}
	else
	{
		ClearServerRemainingCoolTime();
		bCharged = true;
		ChargeStartTime = Seconds - (CoolTime + 500) / 1000.0;
		if (ChargeStartTime == 0.0)
			ChargeStartTime = -0.001;
	}
}

function ClearServerRemainingCoolTime()
{
	ServerCooldownEndTime = 0.0;
}

function float GetServerRemainingCoolTime(float Seconds)
{
	local float RemainingSeconds;

	if (ServerCooldownEndTime <= 0.0)
		return 0.0;

	RemainingSeconds = ServerCooldownEndTime - Seconds;
	if (RemainingSeconds <= 0.0)
		return 0.0;

	return RemainingSeconds;
}

function float GetChargeRate(int iAvilityLevel, float Seconds)
{
	local float ChargeRate, curtime, decCoolTime, effectiveTotalMs, remainingSeconds;

	decCoolTime = 0;
	if (iAvilityLevel >= 3 && iAvilityLevel <= 5)
	{
		if (SkillName == "DeathHand")
			decCoolTime = 15000;
		else if (SkillName == "BlindMaker")
			decCoolTime = 10000;
	}
	effectiveTotalMs = CoolTime-decCoolTime + 500;

	if (ServerCooldownEndTime > 0.0)
	{
		remainingSeconds = GetServerRemainingCoolTime(Seconds);
		if (remainingSeconds <= 0.0)
		{
			ClearServerRemainingCoolTime();
			bCharged = true;
			if (effectiveTotalMs > 0.0)
				ChargeStartTime = Seconds - effectiveTotalMs / 1000.0;
			else
				ChargeStartTime = Seconds;
			if (ChargeStartTime == 0.0)
				ChargeStartTime = -0.001;
			return 1.0;
		}
		if (effectiveTotalMs <= 0.0)
		{
			bCharged = false;
			return 0.0;
		}

		bCharged = false;
		return FClamp(1.0 - remainingSeconds * 1000.0 / effectiveTotalMs, 0.0, 1.0);
	}

	if(ChargeStartTime != 0){
		if (effectiveTotalMs <= 0.0)
		{
			bCharged = true;
			return 1.0;
		}
		
		curtime = Seconds;
		ChargeRate = ((curtime - ChargeStartTime) * 1000) / effectiveTotalMs;
		
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
