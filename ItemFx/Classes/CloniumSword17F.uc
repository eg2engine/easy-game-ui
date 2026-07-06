class CloniumSword17F extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword17F_Mesh MODELFILE=Models/CloniumSword_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword17F_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_17_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword17F_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
