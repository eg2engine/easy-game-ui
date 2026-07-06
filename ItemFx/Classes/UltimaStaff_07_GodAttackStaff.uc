class UltimaStaff_07_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=UltimaStaff_07_Mesh MODELFILE=Models/UltimaStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=UltimaStaff_07_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.UltimaStaff_07_Mesh'
     AppClassTag="stick"
     bDivineItem=True
}
