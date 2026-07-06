class BellatrixJamadharHF15 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHF15_Mesh MODELFILE=Models/BellatrixJamadharHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHF15_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHF15_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
