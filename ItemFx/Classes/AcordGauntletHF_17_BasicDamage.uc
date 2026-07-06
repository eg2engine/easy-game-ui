class AcordGauntletHF_17_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcordGauntletHF_17_Mesh MODELFILE=Models/AcordGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcordGauntletHF_17_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcordGauntletHF_17_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
