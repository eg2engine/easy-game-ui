class BellatrixStaff17 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixStaff17_Mesh MODELFILE=Models/BellatrixStaff.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixStaff17_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixStaff17_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
