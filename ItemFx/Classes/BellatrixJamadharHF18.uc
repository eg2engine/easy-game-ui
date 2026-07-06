class BellatrixJamadharHF18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHF18_Mesh MODELFILE=Models/BellatrixJamadharHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHF18_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHF18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
