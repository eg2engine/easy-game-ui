class AcuraGauntletHF_09_GodAttack extends SepEffect;

/** backup
#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffect_T
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_09_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_09_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE_09ComS
**/
#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_09_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHF_09_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
