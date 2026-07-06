class HeavyGauntletHF_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HeavyGauntletHF_08_Mesh MODELFILE=Models/HeavyGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=HeavyGauntletHF_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HeavyGauntletHF_08_Mesh'
     AppClassTag="HeavyGuntletF"
     RelativeRotation=(Yaw=16384,Roll=32768)
     bDivineItem=True
}
