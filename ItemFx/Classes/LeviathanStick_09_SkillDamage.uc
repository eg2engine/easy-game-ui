class LeviathanStick_09_SkillDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=LeviathanStick_09_Mesh MODELFILE=Models/LeviathanStick.psk
#exec MESH ORIGIN MESH=LeviathanStick_09_Mesh Z=25
#exec MESHMAP SETTEXTURE MESHMAP=LeviathanStick_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_SS_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.LeviathanStick_09_Mesh'
     AppClassTag="LeviathanStick"
     bDivineItem=True
     DrawScale3D=(X=1.050000,Y=1.050000)
}
