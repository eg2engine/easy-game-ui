class BenumbGauntletHF_10_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BenumbGauntletHF_10_Mesh MODELFILE=Models/BenumbGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BenumbGauntletHF_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BenumbGauntletHF_10_Mesh'
     AppClassTag="BenumbGauntletF"
     RelativeRotation=(Yaw=16384,Roll=-16384)
     bDivineItem=True
}
