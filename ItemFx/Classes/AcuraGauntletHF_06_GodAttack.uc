class AcuraGauntletHF_06_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_06_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_06_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHF_06_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
