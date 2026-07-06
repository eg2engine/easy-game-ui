class CloniumSword17A extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword17A_Mesh MODELFILE=Models/CloniumSword_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword17A_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_17_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword17A_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
