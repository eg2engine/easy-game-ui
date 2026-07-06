class BenumbGauntletHM_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BenumbGauntletHM_09_Mesh MODELFILE=Models/BenumbGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=BenumbGauntletHM_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BenumbGauntletHM_09_Mesh'
     AppClassTag="BenumbGauntletM"
     RelativeRotation=(Yaw=16384,Roll=-16384)
     bDivineItem=True
}
