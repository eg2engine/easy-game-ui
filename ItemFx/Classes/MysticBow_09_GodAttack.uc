class MysticBow_09_GodAttack extends SepEffect;

/** backup
#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffect_T
#exec MESH MODELIMPORT MESH=MysticBow_09_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_09_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_09_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE_09ComS
**/
#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MysticBow_09_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_09_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MysticBow_09_Mesh'
     AppClassTag="MysticBow"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
