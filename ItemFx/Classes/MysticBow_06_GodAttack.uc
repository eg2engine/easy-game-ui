class MysticBow_06_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MysticBow_06_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_06_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_06_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MysticBow_06_Mesh'
     AppClassTag="MysticBow"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
