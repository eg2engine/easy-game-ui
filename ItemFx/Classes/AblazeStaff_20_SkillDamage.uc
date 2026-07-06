class AblazeStaff_20_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffect_T
#exec MESH MODELIMPORT MESH=AblazeStaff_20_Mesh MODELFILE=Models/AblazeStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=AblazeStaff_20_Mesh NUM=0 TEXTURE=11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AblazeStaff_20_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
