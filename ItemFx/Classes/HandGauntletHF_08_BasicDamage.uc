class HandGauntletHF_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HandGauntletHF_08_Mesh MODELFILE=Models/HandGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=HandGauntletHF_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HandGauntletHF_08_Mesh'
     AppClassTag="HandguntletF"
     RelativeRotation=(Pitch=31676)
     bDivineItem=True
}
