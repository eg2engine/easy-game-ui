class CloniumSword20A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword20A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword20A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_20_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword20A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
