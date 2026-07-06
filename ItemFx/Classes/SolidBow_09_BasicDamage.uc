class SolidBow_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=SolidBow_09_Mesh MODELFILE=Models/SolidBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=SolidBow_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.SolidBow_09_Mesh'
     AppClassTag="SolidBow"
     RelativeRotation=(Yaw=16384)
     bDivineItem=True
}
