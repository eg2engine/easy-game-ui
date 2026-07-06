class BellatrixStick19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixStick19_Mesh MODELFILE=Models/BellatrixStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixStick19_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixStick19_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
