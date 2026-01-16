class Macro_DropAll13 extends UnitTest
	config(TestConfig);

var int MacorTick;

event Timer()
{
	if(MacorTick == 0)
		DropItems();

	if(MacorTick == 1)
		Finish();

	MacorTick++;
}

function DropItems()
{
	local PlayerServerInfo PSI;
	local SepNetInterface Net;
	local name Job;

	PSI = SephirothPlayer(Interface.PlayerOwner).PSI;
	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (PSI == None || Net == None)
		return;

	Job = PSI.JobName;

	if (Job == 'OneHand') {
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Weapon BasicDamage17 LastDamage17 CriticalRate17 MaxDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Head BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Leg BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Chest BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_OneHand_Shield DodgeRate17 AllResist17 HitRate17 OffsetBlock17");
	}
	else if (Job == 'Bare') {
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Weapon BasicDamage17 LastDamage17 CriticalRate17 MaxDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Head BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Leg BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Chest BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bare_Shield DodgeRate17 AllResist17 HitRate17 OffsetBlock17");
	}
	else if (Job == 'Red') {
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Weapon SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");//마법 스킬 공격력, 마법 공격력 순서는 잘..
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Head BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Leg BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Red_Chest BasicDefenseDamage17 AllResist17 StrengthAdd17 ManaRegenAdd17");
	}
	else if (Job == 'Blue') {
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Weapon SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Chest BasicDefenseDamage17 AllResist17 StrengthAdd17 ManaRegenAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Leg BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Blue_Head BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
	}
	else if (Job == 'Bow') {
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Weapon BasicDamage17 LastDamage17 CriticalRate17 OffsetBlock17");
		Net.NotiTell(1, "\\\\DropItem FirstGradeQuiver");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Leg BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Arm BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Head BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem L13A_Bow_Chest BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");
	}

	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");//방어력, 마법 방어력, 민첩성, 원기
	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem MagicShell AbsDefenseAdd05 AbsResistAdd18");

	if (Job == 'Bow' || Job == 'OneHand' || Job == 'Bare')
	{
	}
	else if(Job == 'Red' || Job == 'Blue')
	{
	}

	Net.NotiTell(1, "\\\\DropItem HunterBelt_H");


	Net.NotiTell(1, "\\\\DropItem Market_GoldSetF");
	Net.NotiTell(1, "\\\\DropItem Market_HPPotion");		//어메이징 체력, 마나 포션 (순간적 30%)
	Net.NotiTell(1, "\\\\DropItem Market_MPPotion");
	Net.NotiTell(1, "\\\\DropItem Market_HMPPotion");



	//부적 - 에디, 생회, 마회	
	Net.NotiTell(1, "\\\\DropMagicItem Charm_RedSp RedSpAdd10"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_RedSp RedSpAdd20"); 

	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd06");
	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd05"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd04"); 

	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd06"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd05"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd04"); 
	
	//귀걸이
	Net.NotiTell(1, "\\\\DropMagicItem VehellEarring AtkUndead09 AtkCreature09 AtkSummon09 AtkMutant09");
	Net.NotiTell(1, "\\\\DropMagicItem VehellEarring AtkUndead09 AtkCreature09 AtkSummon09 AtkMutant09");
}

defaultproperties
{
}
