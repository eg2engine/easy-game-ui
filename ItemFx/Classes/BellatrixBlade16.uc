class BellatrixBlade16 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixBlade16_Mesh MODELFILE=Models/BellatrixBlade.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixBlade16_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixBlade16_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
