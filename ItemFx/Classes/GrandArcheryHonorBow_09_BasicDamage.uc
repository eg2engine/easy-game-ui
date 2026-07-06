class GrandArcheryHonorBow_09_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GrandArcheryHonorBow_09_Mesh MODELFILE=Models/GrandArcheryHonorBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=GrandArcheryHonorBow_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GrandArcheryHonorBow_09_Mesh'
     AppClassTag="bow10"
     bDivineItem=True
}
