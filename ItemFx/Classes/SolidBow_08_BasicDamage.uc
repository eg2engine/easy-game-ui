class SolidBow_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=SolidBow_08_Mesh MODELFILE=Models/SolidBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=SolidBow_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.SolidBow_08_Mesh'
     AppClassTag="SolidBow"
     RelativeRotation=(Yaw=16384)
     bDivineItem=True
}
