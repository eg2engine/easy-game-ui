class BenumbGauntletHM_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BenumbGauntletHM_08_Mesh MODELFILE=Models/BenumbGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=BenumbGauntletHM_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BenumbGauntletHM_08_Mesh'
     AppClassTag="BenumbGauntletM"
     RelativeRotation=(Yaw=16384,Roll=-16384)
     bDivineItem=True
}
