class HandGauntletHF_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=HandGauntletHF_09_Mesh MODELFILE=Models/HandGauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=HandGauntletHF_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.HandGauntletHF_09_Mesh'
     AppClassTag="HandguntletF"
     RelativeRotation=(Pitch=31676)
     bDivineItem=True
}
