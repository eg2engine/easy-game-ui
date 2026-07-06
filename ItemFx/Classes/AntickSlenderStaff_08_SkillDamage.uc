class AntickSlenderStaff_08_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AntickSlenderStaff_08_Mesh MODELFILE=Models/AntickSlenderStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AntickSlenderStaff_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AntickSlenderStaff_08_Mesh'
     AppClassTag="AntickSlenderStaff"
     bDivineItem=True
}
