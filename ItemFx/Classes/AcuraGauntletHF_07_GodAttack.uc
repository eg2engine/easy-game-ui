class AcuraGauntletHF_07_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_07_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_07_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHF_07_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
