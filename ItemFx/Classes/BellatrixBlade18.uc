class BellatrixBlade18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixBlade18_Mesh MODELFILE=Models/BellatrixBlade.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixBlade18_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixBlade18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
