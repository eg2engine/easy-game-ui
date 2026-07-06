class CloniumSword20 extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword20_Mesh MODELFILE=Models/CloniumSword_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword20_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_15_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword20_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
