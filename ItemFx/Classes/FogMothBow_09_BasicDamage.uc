class FogMothBow_09_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FogMothBow_09_Mesh MODELFILE=Models/FogMothBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=FogMothBow_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FogMothBow_09_Mesh'
     AppClassTag="FogMothBow"
     RelativeRotation=(Yaw=16384)
     bDivineItem=True
}
