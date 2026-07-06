class ZodiacStaff_08_SkillDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=ZodiacStaff_08_Mesh MODELFILE=Models/ZodiacStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=ZodiacStaff_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.ZodiacStaff_08_Mesh'
     AppClassTag="ZodiacStaff"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
