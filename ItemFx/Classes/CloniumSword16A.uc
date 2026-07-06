class CloniumSword16A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword16A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword16A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_16_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword16A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
