class ZodiacStaff_09_SkillDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=ZodiacStaff_09_Mesh MODELFILE=Models/ZodiacStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=ZodiacStaff_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.ZodiacStaff_09_Mesh'
     AppClassTag="ZodiacStaff"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
