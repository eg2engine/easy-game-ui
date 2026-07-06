class DragonGauntletHM_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=DragonGauntletHM_08_Mesh MODELFILE=Models/DragonGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=DragonGauntletHM_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.DragonGauntletHM_08_Mesh'
     AppClassTag="DragonGauntletHm"
     RelativeRotation=(Pitch=21230,Yaw=-1400,Roll=-100)
     bDivineItem=True
}
