class DragonGauntletHF_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=DragonGauntletHF_08_Mesh MODELFILE=Models/DragonGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=DragonGauntletHF_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.DragonGauntletHF_08_Mesh'
     AppClassTag="DragonGauntletHf"
     RelativeRotation=(Pitch=21230,Yaw=-1400,Roll=-100)
     bDivineItem=True
}
