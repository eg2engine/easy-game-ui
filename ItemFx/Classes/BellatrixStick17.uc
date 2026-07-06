class BellatrixStick17 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixStick17_Mesh MODELFILE=Models/BellatrixStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixStick17_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixStick17_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
