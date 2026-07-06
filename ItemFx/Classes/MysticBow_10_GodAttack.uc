class MysticBow_10_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MysticBow_10_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_10_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_10_Mesh NUM=0 TEXTURE=IE_11_LMShader4

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MysticBow_10_Mesh'
     AppClassTag="MysticBow"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
