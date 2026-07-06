class CloniumSword17 extends WeaponEnchantFx;

#exec MESH MODELIMPORT MESH=CloniumSword17_Mesh MODELFILE=Models/CloniumSword_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword17_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_15_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword17_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
