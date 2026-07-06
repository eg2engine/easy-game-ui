class VastStick_09_SkillDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=VastStick_09_Mesh MODELFILE=Models/VastStick.psk
#exec MESH ORIGIN MESH=VastStick_09_Mesh Z=17
#exec MESHMAP SETTEXTURE MESHMAP=VastStick_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_SS_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.VastStick_09_Mesh'
     AppClassTag="VastStick"
     RelativeRotation=(Roll=32768)
     bDivineItem=True
}
