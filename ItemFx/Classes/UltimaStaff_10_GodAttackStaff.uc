class UltimaStaff_10_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=UltimaStaff_10_Mesh MODELFILE=Models/UltimaStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=UltimaStaff_10_Mesh NUM=0 TEXTURE=IE_11_LMShader4

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.UltimaStaff_10_Mesh'
     AppClassTag="stick"
     bDivineItem=True
}
