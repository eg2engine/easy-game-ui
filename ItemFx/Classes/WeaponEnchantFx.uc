class WeaponEnchantFx extends SepEffect
	config(WEffect);

var config rotator RotationWeapon;
var config vector LocationWeapon;

event PostBeginPlay()
{
	//Log("TEST Effect rot"@RotationWeapon@class@self);
	EffectOffsetRot = RotationWeapon;
	EffectOffsetLot = LocationWeapon;
	//Log("TEST Effect rot"@RotationRate@class);

//	Log("TEST Effect TEST"@RotationRate@EffectOffsetLot@EffectOffsetRot@class);
}

#exec OBJ LOAD FILE=../Textures/Sword_EF.utx PACKAGE=Sword_EF

defaultproperties
{
     DrawType=DT_Mesh
     AppClassTag="USword"
}
