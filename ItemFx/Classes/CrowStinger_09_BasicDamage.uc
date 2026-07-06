class CrowStinger_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=CrowStinger_09_Mesh MODELFILE=Models/CrowStinger.psk
#exec MESHMAP SETTEXTURE MESHMAP=CrowStinger_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CrowStinger_09_Mesh'
     AppClassTag="CrowStinger"
     bDivineItem=True
}
