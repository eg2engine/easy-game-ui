class HandGauntletHM_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HandGauntletHM_08_Mesh MODELFILE=Models/HandGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=HandGauntletHM_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HandGauntletHM_08_Mesh'
     AppClassTag="HandguntletM"
     RelativeRotation=(Pitch=31676)
     bDivineItem=True
}
