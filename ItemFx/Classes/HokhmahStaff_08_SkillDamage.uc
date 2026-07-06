class HokhmahStaff_08_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HokhmahStaff_08_Mesh MODELFILE=Models/HokhmahStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=HokhmahStaff_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HokhmahStaff_08_Mesh'
     AppClassTag="HokahmahStaff"
     bDivineItem=True
}
