class FlockStick_10_SkillDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FlockStick_10_Mesh MODELFILE=Models/FlockStick.psk
#exec MESH ORIGIN MESH=FlockStick_10_Mesh Z=25
#exec MESHMAP SETTEXTURE MESHMAP=FlockStick_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_SS_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FlockStick_10_Mesh'
     AppClassTag="FlockStick"
     RelativeRotation=(Roll=32768)
     bDivineItem=True
     DrawScale3D=(X=1.050000,Y=1.050000)
}
