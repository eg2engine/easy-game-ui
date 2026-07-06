class AcuraGauntletHF_10_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_10_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_10_Mesh NUM=0 TEXTURE=IE_11_LMShader4

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHF_10_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
