class BenumbGauntletHF_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BenumbGauntletHF_08_Mesh MODELFILE=Models/BenumbGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BenumbGauntletHF_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BenumbGauntletHF_08_Mesh'
     AppClassTag="BenumbGauntletF"
     RelativeRotation=(Yaw=16384,Roll=-16384)
     bDivineItem=True
}
