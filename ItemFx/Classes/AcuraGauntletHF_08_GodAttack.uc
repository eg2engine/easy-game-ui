class AcuraGauntletHF_08_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=AcuraGauntletHF_08_Mesh MODELFILE=Models/AcuraGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcuraGauntletHF_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcuraGauntletHF_08_Mesh'
     AppClassTag="NailGauntletHm"
     bDivineItem=True
}
