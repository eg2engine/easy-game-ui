class TheurgicalEdge_10_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=TheurgicalEdge_10_Mesh MODELFILE=Models/TheurgicalEdge.psk
#exec MESHMAP SETTEXTURE MESHMAP=TheurgicalEdge_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.TheurgicalEdge_10_Mesh'
     AppClassTag="TheurgicalEdge"
     bDivineItem=True
}
