class MysticBow_07_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MysticBow_07_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_07_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_07_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MysticBow_07_Mesh'
     AppClassTag="MysticBow"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
