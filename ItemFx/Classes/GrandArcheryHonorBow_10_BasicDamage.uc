class GrandArcheryHonorBow_10_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GrandArcheryHonorBow_10_Mesh MODELFILE=Models/GrandArcheryHonorBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=GrandArcheryHonorBow_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GrandArcheryHonorBow_10_Mesh'
     AppClassTag="bow10"
     bDivineItem=True
}
