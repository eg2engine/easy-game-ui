class Macro_Potion extends UnitTest
	config(TestConfig);

var config int HealthPotionLimit;
var config string HealthPotionName;
var config int ManaPotionLimit;
var config string ManaPotionName;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (HealthPotionLimit == 0)
		HealthPotionLimit = 400;
	if (HealthPotionName == "")
		HealthPotionName = "GreatBitterPotion";
	if (ManaPotionLimit == 0)
		ManaPotionLimit = 100;
	if (ManaPotionName == "")
		ManaPotionName = "SoulPotion";

	SaveConfig();
}

event Timer()
{
	if (SephirothPlayer(Interface.PlayerOwner).PSI.Health < HealthPotionLimit) {
		SephirothPlayer(Interface.PlayerOwner).Net.NotiItemUseShotcut(HealthPotionName);
	}
	if (SephirothPlayer(Interface.PlayerOwner).PSI.Mana < ManaPotionLimit) {
		SephirothPlayer(Interface.PlayerOwner).Net.NotiItemUseShotcut(ManaPotionName);
	}
}

defaultproperties
{
     TestTimer=0.400000
}
