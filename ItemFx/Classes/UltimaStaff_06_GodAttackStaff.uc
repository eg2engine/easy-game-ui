class UltimaStaff_06_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=UltimaStaff_06_Mesh MODELFILE=Models/UltimaStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=UltimaStaff_06_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.UltimaStaff_06_Mesh'
     AppClassTag="stick"
     bDivineItem=True
}
