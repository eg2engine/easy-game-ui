class GlaciesStick_14_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GlaciesStick_14_Mesh MODELFILE=Models/GlaciesStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=GlaciesStick_14_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GlaciesStick_14_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
