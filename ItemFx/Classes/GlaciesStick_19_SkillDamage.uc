class GlaciesStick_19_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GlaciesStick_19_Mesh MODELFILE=Models/GlaciesStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=GlaciesStick_19_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GlaciesStick_19_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
