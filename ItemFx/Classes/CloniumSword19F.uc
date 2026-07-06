class CloniumSword19F extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword19F_Mesh MODELFILE=Models/CloniumSword_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword19F_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_19_02

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword19F_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
