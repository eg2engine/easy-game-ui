class BellatrixJamadharHF14 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHF14_Mesh MODELFILE=Models/BellatrixJamadharHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHF14_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHF14_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
