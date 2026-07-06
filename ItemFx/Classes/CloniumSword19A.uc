class CloniumSword19A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword19A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword19A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_19_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword19A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
