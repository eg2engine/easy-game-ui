class CloniumSword15A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword15A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword15A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_15_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword15A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
