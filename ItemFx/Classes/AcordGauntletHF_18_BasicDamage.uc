class AcordGauntletHF_18_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcordGauntletHF_18_Mesh MODELFILE=Models/AcordGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcordGauntletHF_18_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcordGauntletHF_18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
