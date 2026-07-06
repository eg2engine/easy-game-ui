class CloniumSword18F extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword18F_Mesh MODELFILE=Models/CloniumSword_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword18F_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_18_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword18F_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
