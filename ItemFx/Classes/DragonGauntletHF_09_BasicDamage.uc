class DragonGauntletHF_09_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=DragonGauntletHF_09_Mesh MODELFILE=Models/DragonGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=DragonGauntletHF_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.DragonGauntletHF_09_Mesh'
     AppClassTag="DragonGauntletHf"
     RelativeRotation=(Pitch=21230,Yaw=-1400,Roll=-100)
     bDivineItem=True
}
