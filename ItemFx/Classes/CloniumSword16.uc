class CloniumSword16 extends WeaponEnchantFx;

#exec MESH MODELIMPORT MESH=CloniumSword16_Mesh MODELFILE=Models/CloniumSword_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword16_Mesh NUM=0 TEXTURE=Sword_EF.CloniumSword_EF_15_01

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword16_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
