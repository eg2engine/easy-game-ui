class AblazeStaff_17_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AblazeStaff_17_Mesh MODELFILE=Models/AblazeStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AblazeStaff_17_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AblazeStaff_17_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
