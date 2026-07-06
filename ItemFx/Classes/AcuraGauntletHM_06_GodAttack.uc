class AcuraGauntletHM_06_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHM_06_Mesh MODELFILE=Models/AcuraGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHM_06_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHM_06_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
