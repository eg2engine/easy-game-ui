class AntickSlenderStaff_10_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AntickSlenderStaff_10_Mesh MODELFILE=Models/AntickSlenderStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AntickSlenderStaff_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AntickSlenderStaff_10_Mesh'
     AppClassTag="AntickSlenderStaff"
     bDivineItem=True
}
