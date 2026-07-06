class MysticBow_08_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MysticBow_08_Mesh MODELFILE=Models/MysticBow_E.psk
#exec MESH ORIGIN MESH=MysticBow_08_Mesh Yaw=128
#exec MESHMAP SETTEXTURE MESHMAP=MysticBow_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MysticBow_08_Mesh'
     AppClassTag="MysticBow"
     RelativeRotation=(Yaw=32768)
     bDivineItem=True
}
