class BellatrixJamadharHM19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHM19_Mesh MODELFILE=Models/BellatrixJamadharHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHM19_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHM19_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
