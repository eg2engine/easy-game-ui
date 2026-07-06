class BellatrixCrossbow18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixCrossbow18_Mesh MODELFILE=Models/BellatrixCrossbow.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixCrossbow18_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixCrossbow18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
