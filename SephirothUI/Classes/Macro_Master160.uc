class Macro_Master160 extends UnitTest
	config(TestConfig);

var int m_nTick;

struct StatBase
{
	var float Str;
	var float Dex;
	var float Vigor;
	var float Mp;
};

var StatBase Basis[3];
var StatBase Weight[4];

event Timer()
{
	m_nTick++;
	switch (m_nTick)
	{
	case 1:
		LevelUp();
		break;
	case 2:
		MasterSkill2nd();
		break;
	case 3:
		AutoStat();
		break;
	case 4:
		MasterSkill();
		break;
	case 5:
		RechargeSkill();
		break;
	case 6:
		EarnMoney();
		break;
	case 7:
		DropItems();
		break;
	case 8:
		Finish();
		break;
	}
}

function LevelUp()
{
	local SepNetInterface Net;

	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (Net == None)
		return;

	Net.NotiTell(1, "\\\\MyExpUp 1461748169");
	Net.NotiTell(1, "\\\\SetAlignment 255");		//modified by yj  명성치도 같이
}

function AutoStat()
{
	local name Job;
	local int LocalLevel;
	local StatBase StatBase;
	local PlayerServerInfo PSI;
	local SepNetInterface Net;
	local int MP;
	local float Sum;
	local int Str, Dex, Vigor, Black, Blue, Red, White, Yellow;

	PSI = SephirothPlayer(Interface.PlayerOwner).PSI;
	Net = SephirothPlayer(Interface.PlayerOwner).Net;

	if (PSI == None || Net == None)
		return;

	MP = PSI.White + PSI.Red + PSI.Blue + PSI.Yellow + PSI.Black;
	LocalLevel = PSI.PlayLevel;
	Job = PSI.JobName;

	if (Job == 'OneHand') {
		StatBase.Str = Basis[0].Str + ((LocalLevel-1)*10.0*Weight[0].Str);
		StatBase.Dex = Basis[0].Dex + ((LocalLevel-1)*10.0*Weight[0].Dex);
		StatBase.Vigor = Basis[0].Vigor + ((LocalLevel-1)*10.0*Weight[0].Vigor);
		StatBase.Mp = Basis[0].Mp + ((LocalLevel-1)*10.0*Weight[0].Mp);
	}
	else if (Job == 'Bare') {		//modified by yj
		StatBase.Str = Basis[0].Str + ((LocalLevel-1)*10.0*Weight[3].Str);
		StatBase.Dex = Basis[0].Dex + ((LocalLevel-1)*10.0*Weight[3].Dex);
		StatBase.Vigor = Basis[0].Vigor + ((LocalLevel-1)*10.0*Weight[3].Vigor);
		StatBase.Mp = Basis[0].Mp + ((LocalLevel-1)*10.0*Weight[3].Mp);
	}
	else if (Job == 'Red' || Job == 'Blue' || Job == 'Yellow') {
		StatBase.Str = Basis[1].Str + ((LocalLevel-1)*10.0*Weight[1].Str);
		StatBase.Dex = Basis[1].Dex + ((LocalLevel-1)*10.0*Weight[1].Dex);
		StatBase.Vigor = Basis[1].Vigor + ((LocalLevel-1)*10.0*Weight[1].Vigor);
		StatBase.Mp = Basis[1].Mp + ((LocalLevel-1)*10.0*Weight[1].Mp);
	}
	else if (Job == 'Bow') {
		StatBase.Str = Basis[2].Str + ((LocalLevel-1)*10.0*Weight[2].Str);
		StatBase.Dex = Basis[2].Dex + ((LocalLevel-1)*10.0*Weight[2].Dex);
		StatBase.Vigor = Basis[2].Vigor + ((LocalLevel-1)*10.0*Weight[2].Vigor);
		StatBase.Mp = Basis[2].Mp + ((LocalLevel-1)*10.0*Weight[2].Mp);
	}

	StatBase.Str = max(0, StatBase.Str - PSI.Str);
	StatBase.Dex = max(0, StatBase.Dex - PSI.Dex);
	StatBase.Vigor = max(0, StatBase.Vigor - PSI.Vigor);
	StatBase.Mp = max(0, StatBase.Mp - MP);
	Sum = StatBase.Str + StatBase.Dex + StatBase.Vigor + StatBase.Mp;

	StatBase.Str = int(PSI.LevelPoint * StatBase.Str / Sum);
	StatBase.Dex = int(PSI.LevelPoint * StatBase.Dex / Sum);
	StatBase.Vigor = int(PSI.LevelPoint * StatBase.Vigor / Sum);
	StatBase.Mp = int(PSI.LevelPoint * StatBase.Mp / Sum);
	Sum = StatBase.Str + StatBase.Dex + StatBase.Vigor + StatBase.Mp;

	Str = StatBase.Str;
	Dex = StatBase.Dex;
	Vigor = StatBase.Vigor;
	if (Job == 'OneHand' || Job == 'Bare')
		Black = StatBase.Mp;
	else if (Job == 'Bow' || Job == 'Blue')
		Blue = StatBase.Mp;
	else if (Job == 'Red')
		Red = StatBase.Mp;

	if (Str>0) 
		Net.NotiUsePoint(0,Str);
	if (Dex>0) 
		Net.NotiUsePoint(1,Dex);
	if (Vigor>0) 
		Net.NotiUsePoint(2,Vigor);
	if (White>0) 
		Net.NotiUsePoint(3,White);
	if (Red>0) 
		Net.NotiUsePoint(4,Red);
	if (Blue>0) 
		Net.NotiUsePoint(5,Blue);
	if (Yellow>0) 
		Net.NotiUsePoint(6,Yellow);
	if (Black>0) 
		Net.NotiUsePoint(7,Black);
}

function MasterSkill()
{
	local PlayerServerInfo PSI;
	local SepNetInterface Net;
	local name Job;

	PSI = SephirothPlayer(Interface.PlayerOwner).PSI;
	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (PSI == None || Net == None)
		return;

	Job = PSI.JobName;

	/* Master Skill */
	if (Job == 'OneHand') {
		Net.NotiTell(1, "\\\\MySkillLevelUp VSwing 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Prod 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Splash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TripleSwing 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp OH_Combination 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp OH_Concentration 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Absolute 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BusterMove 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BladeDash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DragonFly 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FrontSplash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Butterfly 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ComboSplash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BladeCombination 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BloodySplash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp GushFly 100");
	}
	else if (Job == 'Bare') {
		Net.NotiTell(1, "\\\\MySkillLevelUp UpperCombo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TwinShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Bash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp OneTwo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp HammerChop 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp MegaBoil 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp UpperStraight 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp SpeedCombo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ShotUpperCut 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp MegaGush 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Clinching 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp HammerBlow 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BH_Combination 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp SpinHammer 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ElbowDash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp EagleHook 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Strike 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp PartCombo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FeintJab 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Hurricane 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp DoubleKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TwinKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp JumpKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DeepKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp SwingKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FlyCombo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp LowCombo 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Pushing 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp OverKick 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Valkyrie 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireSpin 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp PowerfulBlade 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp OneTwoThree 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ShadowBlade 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TearingShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WindMill 100");
	}
	else if (Job == 'Red') {
		Net.NotiTell(1, "\\\\MySkillLevelUp TaTack 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp StaffStrike 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ExtendHit 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DeadlySwing 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Dash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Cyclone 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp StaffCombination 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Blow 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Perforation 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Performance 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp EarthQuake 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp FireArrow 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireBreath 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireBall 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BurningArrow 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DragonBreath 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireCloud 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DracoSpirit 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Salamander 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Apocalypse 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireRain 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FlameEdge 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BurstEdge 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Meteoric 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp MeteoricShower 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp Warm 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FireWarm 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WarmOther 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ResistNature 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WindOfFire 100");
	}
	else if (Job == 'Bow') {
		Net.NotiTell(1, "\\\\MySkillLevelUp Shot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DoubleShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BowTwinShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BowConcentration 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp LockDown 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BoreShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TripleShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp TwinBoreShot 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp LockDownTriple 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Fiend 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp SpecialArrow 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp Undine 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Sylph 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp SpiritSalamander 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Gnome 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Dryad 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Naiad 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Nereid 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Oread 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Alseide 100");
	}
	else if (Job == 'Blue') {
		Net.NotiTell(1, "\\\\MySkillLevelUp TaTack 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp StaffStrike 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ExtendHit 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp DeadlySwing 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Dash 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Cyclone 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp StaffCombination 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Blow 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Perforation 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Performance 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp EarthQuake 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp IceBolt 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WaterEdge 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FrozenGas 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FrozenBall 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WaterPump 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp IceFlower 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp IceCrush 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WaterBlade 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp Blizzard 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp IceCrystal 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp BlueMeteoric 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp IceDriver 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FreezingCircle 100");

		Net.NotiTell(1, "\\\\MySkillLevelUp ColdEnemy 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WindOfIce 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp WaveOfIce 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp FrostEnemy 100");
		Net.NotiTell(1, "\\\\MySkillLevelUp ResistFire 100");
	}
}

function RechargeSkill()
{
	local PlayerServerInfo PSI;
	local SepNetInterface Net;
	local name Job;
	local int i;

	PSI = SephirothPlayer(Interface.PlayerOwner).PSI;
	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (PSI == None || Net == None)
		return;

	Job = PSI.JobName;

	/* Master Skill */
	if (Job == 'OneHand') {
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BusterMove");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FrontSplash");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ComboSplash");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BladeCombination");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BladeDash");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill DragonFly");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ButterFly");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BloodySplash");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill GushFly");
	}
	else if (Job == 'Bare') {
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ShotUpperCut");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Clinching");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BH_Combination");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill PartCombo");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FeintJab");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill MegaGush");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill HammerBlow");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill SpinHammer");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ElbowDash");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill EagleHook");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Strike");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Hurricane");

		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Pushing");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill PowerfulBlade");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill OneTwoThree");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WindMill");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill TearingShot");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill OverKick");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Valkyrie");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FireSpin");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ShadowBlade");
	}
	else if (Job == 'Red') {
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Cyclone");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill StaffCombination");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Perforation");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Performance");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Blow");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill EarthQuake");

		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FireCloud");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill DracoSpirit");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Salamander");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Apocalypse");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FireRain");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FlameEdge");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Meteoric");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BurstEdge");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill MeteoricShower");

		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FireWarm");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WarmOther");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ResistNature");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WindOfFire");
	}
	else if (Job == 'Bow') {
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill LockDown");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BoreShot");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill TripleShot");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill TwinBoreShot");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill LockDownTriple");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Fiend");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill SpecialArrow");
	}
	else if (Job == 'Blue') {
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Cyclone");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill StaffCombination");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Perforation");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Performance");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Blow");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill EarthQuake");

		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill IceFlower");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill IceCrush");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WaterBlade");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill Blizzard");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill IceCrystal");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill BlueMeteoric");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FreezingCircle");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill IceDriver");

		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WindOfIce");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill WaveOfIce");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill FrostEnemy");
		for (i=0;i<4;i++) Net.NotiTell(1, "\\\\RechargeSkill ResistFire");
	}
}

function EarnMoney()
{
	local SepNetInterface Net;

	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (Net == None)
		return;

	/* Money */
	Net.NotiTell(1, "\\\\MyMoneyUp 10000000");
}

function MasterSkill2nd()
{
	local PlayerServerInfo PSI;
	local SepNetInterface Net;
	local name Job;
	local int i;

	PSI = SephirothPlayer(Interface.PlayerOwner).PSI;
	Net = SephirothPlayer(Interface.PlayerOwner).Net;
	if (PSI == None || Net == None)
		return;

	Job = PSI.JobName;

	Net.NotiTell(1, "\\\\Skill2ndActivate");
	for(i=0; i<10; i++)
		Net.NotiTell(1, "\\\\Skill2ndLevelUp GuardianProtection");

	if (Job == 'OneHand') {
		for(i=0; i<10; i++) {
			Net.NotiTell(1, "\\\\Skill2ndLevelUp LightningSoul");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp CrashSword");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp GuardianShield");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Might");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Endure");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp SoulBlade");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp BlastBlade");
		}
	}
	else if (Job == 'Bare') {
		for(i=0; i<10; i++) {
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Thrust");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp DynamicFinish");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp PiercingBlast");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Fanatical");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Endure");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp SoulFist");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp BlastFist");
		}
	}
	else if (Job == 'Red') {
		for(i=0; i<10; i++) {
			Net.NotiTell(1, "\\\\Skill2ndLevelUp PhantomFire");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp ManaRecovery");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Increase");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp MentalCommand");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Illusion");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp FireFury");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp ManaBarrier");
		}
	}
	else if (Job == 'Blue') {
		for(i=0; i<10; i++) {
			Net.NotiTell(1, "\\\\Skill2ndLevelUp FreezenGround");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp ManaRecovery");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Increase");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp MentalCommand");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Illusion");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp IceFury");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp ManaBarrier");
		}
	}
	else if (Job == 'Bow') {
		for(i=0; i<10; i++) {
			Net.NotiTell(1, "\\\\Skill2ndLevelUp DistressArrow");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp FireBurst");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Devastator");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Endure");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp Fanatical");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp DeadlyCount");
			Net.NotiTell(1, "\\\\Skill2ndLevelUp RainbowArrow");
		}
	}
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

	if (Job == 'OneHand')
	{
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusSword GodAttack08");
		Net.NotiTell(1, "\\\\DropMagicItem BellatrixBlade BasicDamage17 LastDamage17 CriticalRate17 MaxDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusHelmet BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusBoots BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusArmor BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");
		Net.NotiTell(1, "\\\\DropMagicItem TriumphusShield GodBlock07");

		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");	//물리스킬공격력, 보조물리스킬공격력, 마법방어력
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");
		Net.NotiTell(1, "\\\\DropMagicItem EscapeMisfortuneAmulet PD09 PSD09 IC10");
	}
	else if (Job == 'Bare') {
		Net.NotiTell(1, "\\\\DropMagicItem AcuraGauntlet GodAttack08");
		Net.NotiTell(1, "\\\\DropMagicItem BellatrixJamadhar BasicDamage17 LastDamage17 CriticalRate17 MaxDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraHelmet BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraBoots BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraArmor BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");
		Net.NotiTell(1, "\\\\DropMagicItem AcuraProtector GodBlock07");

		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");	//물리스킬공격력, 보조물리스킬공격력, 마법방어력
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");
		Net.NotiTell(1, "\\\\DropMagicItem EscapeMisfortuneAmulet PD09 PSD09 IC10");
	}
	else if (Job == 'Red') {
		Net.NotiTell(1, "\\\\DropMagicItem AblazeStaff SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");//마법 스킬 공격력, 마법 공격력 순서는 잘..
		Net.NotiTell(1, "\\\\DropMagicItem BellatrixStaff SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem UltimaVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem UltimaVambrace BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem UltimaHelmet BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem UltimaBoots BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem UltimaGarment BasicDefenseDamage17 AllResist17 StrengthAdd17 ManaRegenAdd17");

		Net.NotiTell(1, "\\\\DropMagicItem EscapeMisfortuneAmulet MD09 MSD09 IC09");
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand MSD09 MDEF07 StrengthAdd06");
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand MSD09 MDEF07 StrengthAdd06");
	}
	else if (Job == 'Blue') {
		Net.NotiTell(1, "\\\\DropMagicItem GlaciesStick SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem BellatrixStick SkillDamage17 LastSkillDamage17 MaxMagicalDamage17 MinMagicalDamage17");
		Net.NotiTell(1, "\\\\DropMagicItem FabulaGown BasicDefenseDamage17 AllResist17 StrengthAdd17 ManaRegenAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem FabulaSleevelet BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem FabulaSleevelet BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem FabulaSandal BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem FabulaCap BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");

		Net.NotiTell(1, "\\\\DropMagicItem EscapeMisfortuneAmulet MD09 MSD09 IC09");
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand MSD09 MDEF07 StrengthAdd06");
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand MSD09 MDEF07 StrengthAdd06");
	}
	else if (Job == 'Bow') {
		Net.NotiTell(1, "\\\\DropMagicItem MysticBow GodAttackRange08");
		Net.NotiTell(1, "\\\\DropMagicItem BellatrixCrossbow BasicDamage17 LastDamage17 CriticalRate17 MaxDamage17");
		Net.NotiTell(1, "\\\\DropItem FirstGradeQuiver");
		Net.NotiTell(1, "\\\\DropMagicItem MysticSandal BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem MysticSleevelet BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem MysticSleevelet BasicDefenseDamage17 AllResist17 StrengthAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem MysticCap BasicDefenseDamage17 AllResist17 VigorAdd17 DexterityAdd17");
		Net.NotiTell(1, "\\\\DropMagicItem MysticGarb BasicDefenseDamage17 AllResist17 StrengthAdd17 CriticalRate17");

		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");	//물리스킬공격력, 보조물리스킬공격력, 마법방어력
		Net.NotiTell(1, "\\\\DropMagicItem ZodiacBand PSD09 MDEF07 StrengthAdd06");
		Net.NotiTell(1, "\\\\DropMagicItem EscapeMisfortuneAmulet PD09 PSD09 IC10");
	}

	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");//방어력, 마법 방어력, 민첩성, 원기
	Net.NotiTell(1, "\\\\DropMagicItem MightyRing BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem IncantedMask BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem IncantedMask BasicDefenseDamage06 AllResist06 DexterityAdd20 VigorAdd20");
	Net.NotiTell(1, "\\\\DropMagicItem MagicShell AbsDefenseAdd05 AbsResistAdd18");


	Net.NotiTell(1, "\\\\DropItem Market_GoldSetF");	
	
	//부적 - 에디, 생회, 마회	
	Net.NotiTell(1, "\\\\DropMagicItem Charm_RedSp RedSpAdd10"); 
	
	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd06");
	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd05"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_LifeSp LifeSpAdd04"); 

	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd04"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd05"); 
	Net.NotiTell(1, "\\\\DropMagicItem Charm_ManaSp ManaSpAdd06"); 
	
	//귀걸이
//	Net.NotiTell(1, "\\\\DropMagicItem VehellEarring AtkUndead09 AtkCreature09 AtkSummon09 AtkMutant09");
//	Net.NotiTell(1, "\\\\DropMagicItem VehellEarring AtkUndead09 AtkCreature09 AtkSummon09 AtkMutant09");
	
}

defaultproperties
{
     Basis(0)=(str=64.000000,Dex=42.000000,Vigor=52.000000,Mp=42.000000)
     Basis(1)=(str=44.000000,Dex=41.000000,Vigor=53.000000,Mp=62.000000)
     Basis(2)=(str=45.000000,Dex=60.000000,Vigor=50.000000,Mp=45.000000)
     Weight(0)=(str=0.470000,Dex=0.200000,Vigor=0.250000,Mp=0.047000)
     Weight(1)=(str=0.080000,Dex=0.160000,Vigor=0.300000,Mp=0.460000)
     Weight(2)=(str=0.280000,Dex=0.375000,Vigor=0.240000,Mp=0.095000)
     Weight(3)=(str=0.450000,Dex=0.230000,Vigor=0.290000,Mp=0.047000)
     TestTimer=1.000000
}
