class CloniumSword19 extends WeaponEnchantFx;

#exec MESH MODELIMPORT MESH=CloniumSword19_Mesh MODELFILE=Models/CloniumSword_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword19_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_15_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword19_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
