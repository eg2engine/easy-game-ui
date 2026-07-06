class CloniumSword20F extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword20F_Mesh MODELFILE=Models/CloniumSword_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword20F_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_20_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword20F_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
