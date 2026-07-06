class GladiatorSword_09_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GladiatorSword_09_Mesh MODELFILE=Models/GladiatorSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=GladiatorSword_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GladiatorSword_09_Mesh'
     AppClassTag="GladiatorSword"
     bDivineItem=True
}
