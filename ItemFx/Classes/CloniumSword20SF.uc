class CloniumSword20SF extends WeaponEnchantFx;

#exec mesh MODELIMPORT MESH=CloniumSword20SF_Mesh MODELFILE=Models/CloniumSword_EF_05.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumSword20SF_Mesh NUM=0 TEXTURE=Sword_EF.weapon_magicline_EF_20_03

defaultproperties
{
     Mesh=SkeletalMesh'ItemFx.CloniumSword20SF_Mesh'
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
