class BellatrixJamadharHM14 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHM14_Mesh MODELFILE=Models/BellatrixJamadharHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHM14_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHM14_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
