class SanctionStick_09_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=SanctionStick_09_Mesh MODELFILE=Models/SanctionStick_E.psk
#exec MESH ORIGIN MESH=SanctionStick_09_Mesh X=0.1 Y=0.1 Z=10
#exec MESHMAP SETTEXTURE MESHMAP=SanctionStick_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_SS_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.SanctionStick_09_Mesh'
     AppClassTag="SanctionStaff"
     bDivineItem=True
     DrawScale3D=(X=1.050000,Y=1.050000)
}
