class HeavyGauntletHM_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HeavyGauntletHM_09_Mesh MODELFILE=Models/HeavyGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=HeavyGauntletHM_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HeavyGauntletHM_09_Mesh'
     AppClassTag="HeavyGuntletM"
     RelativeRotation=(Yaw=16384,Roll=32768)
     bDivineItem=True
}
