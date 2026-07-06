class HokhmahStaff_09_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HokhmahStaff_09_Mesh MODELFILE=Models/HokhmahStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=HokhmahStaff_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HokhmahStaff_09_Mesh'
     AppClassTag="HokahmahStaff"
     bDivineItem=True
}
