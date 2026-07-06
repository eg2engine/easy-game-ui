class VastStaff_08_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=VastStaff_08_Mesh MODELFILE=Models/VastStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=VastStaff_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.VastStaff_08_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
