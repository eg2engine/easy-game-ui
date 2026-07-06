class AblazeStaff_16_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AblazeStaff_16_Mesh MODELFILE=Models/AblazeStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AblazeStaff_16_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AblazeStaff_16_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
