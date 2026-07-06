class CloniumSword18A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword18A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword18A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_18_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword18A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
