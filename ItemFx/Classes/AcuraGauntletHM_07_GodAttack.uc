class AcuraGauntletHM_07_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHM_07_Mesh MODELFILE=Models/AcuraGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHM_07_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHM_07_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
