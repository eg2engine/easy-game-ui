class GrandArcheryHonorBow_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GrandArcheryHonorBow_08_Mesh MODELFILE=Models/GrandArcheryHonorBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=GrandArcheryHonorBow_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GrandArcheryHonorBow_08_Mesh'
     AppClassTag="bow10"
     bDivineItem=True
}
