class AntickSlenderStaff_09_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AntickSlenderStaff_09_Mesh MODELFILE=Models/AntickSlenderStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AntickSlenderStaff_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AntickSlenderStaff_09_Mesh'
     AppClassTag="AntickSlenderStaff"
     bDivineItem=True
}
