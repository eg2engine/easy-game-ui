class BellatrixStick15 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixStick15_Mesh MODELFILE=Models/BellatrixStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixStick15_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixStick15_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
