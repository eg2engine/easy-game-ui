class HokhmahStaff_10_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HokhmahStaff_10_Mesh MODELFILE=Models/HokhmahStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=HokhmahStaff_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HokhmahStaff_10_Mesh'
     AppClassTag="HokahmahStaff"
     bDivineItem=True
}
