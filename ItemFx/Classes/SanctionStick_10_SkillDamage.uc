class SanctionStick_10_SkillDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=SanctionStick_10_Mesh MODELFILE=Models/SanctionStick_E.psk
#exec MESH ORIGIN MESH=SanctionStick_10_Mesh X=0.1 Y=0.1 Z=10
#exec MESHMAP SETTEXTURE MESHMAP=SanctionStick_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_SS_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.SanctionStick_10_Mesh'
     AppClassTag="SanctionStaff"
     bDivineItem=True
     DrawScale3D=(X=1.050000,Y=1.050000)
}
