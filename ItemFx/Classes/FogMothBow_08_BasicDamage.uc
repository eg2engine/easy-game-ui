class FogMothBow_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FogMothBow_08_Mesh MODELFILE=Models/FogMothBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=FogMothBow_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FogMothBow_08_Mesh'
     AppClassTag="FogMothBow"
     RelativeRotation=(Yaw=16384)
     bDivineItem=True
}
