class CrowStinger_10_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=CrowStinger_10_Mesh MODELFILE=Models/CrowStinger.psk
#exec MESHMAP SETTEXTURE MESHMAP=CrowStinger_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CrowStinger_10_Mesh'
     AppClassTag="CrowStinger"
     bDivineItem=True
}
