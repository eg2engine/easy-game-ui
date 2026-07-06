class BellatrixJamadharHF19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHF19_Mesh MODELFILE=Models/BellatrixJamadharHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHF19_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHF19_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
