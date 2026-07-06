class CrowStinger_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=CrowStinger_08_Mesh MODELFILE=Models/CrowStinger.psk
#exec MESHMAP SETTEXTURE MESHMAP=CrowStinger_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CrowStinger_08_Mesh'
     AppClassTag="CrowStinger"
     bDivineItem=True
}
