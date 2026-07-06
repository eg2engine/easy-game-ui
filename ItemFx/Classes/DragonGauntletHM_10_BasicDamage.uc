class DragonGauntletHM_10_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=DragonGauntletHM_10_Mesh MODELFILE=Models/DragonGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=DragonGauntletHM_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.DragonGauntletHM_10_Mesh'
     AppClassTag="DragonGauntletHm"
     RelativeRotation=(Pitch=21230,Yaw=-1400,Roll=-100)
     bDivineItem=True
}
