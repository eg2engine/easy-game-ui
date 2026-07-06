class CloniumSword16F extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword16F_Mesh MODELFILE=Models/CloniumSword_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword16F_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_16_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword16F_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
