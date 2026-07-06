class TheurgicalEdge_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=TheurgicalEdge_08_Mesh MODELFILE=Models/TheurgicalEdge.psk
#exec MESHMAP SETTEXTURE MESHMAP=TheurgicalEdge_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.TheurgicalEdge_08_Mesh'
     AppClassTag="TheurgicalEdge"
     bDivineItem=True
}
