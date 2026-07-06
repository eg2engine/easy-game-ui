class UltimaStaff_08_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=UltimaStaff_08_Mesh MODELFILE=Models/UltimaStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=UltimaStaff_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.UltimaStaff_08_Mesh'
     AppClassTag="stick"
     bDivineItem=True
}
