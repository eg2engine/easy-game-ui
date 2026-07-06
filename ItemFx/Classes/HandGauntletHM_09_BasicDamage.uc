class HandGauntletHM_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HandGauntletHM_09_Mesh MODELFILE=Models/HandGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=HandGauntletHM_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HandGauntletHM_09_Mesh'
     AppClassTag="HandguntletM"
     RelativeRotation=(Pitch=31676)
     bDivineItem=True
}
