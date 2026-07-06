class FlockBow_10_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FlockBow_10_Mesh MODELFILE=Models/FlockBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=FlockBow_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FlockBow_10_Mesh'
     AppClassTag="FlockBow"
     RelativeRotation=(Yaw=-16384)
     bDivineItem=True
}
