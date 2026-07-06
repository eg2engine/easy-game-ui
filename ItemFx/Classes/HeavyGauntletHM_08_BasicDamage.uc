class HeavyGauntletHM_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HeavyGauntletHM_08_Mesh MODELFILE=Models/HeavyGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=HeavyGauntletHM_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HeavyGauntletHM_08_Mesh'
     AppClassTag="HeavyGuntletM"
     RelativeRotation=(Yaw=16384,Roll=32768)
     bDivineItem=True
}
