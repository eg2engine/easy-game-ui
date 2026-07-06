class GladiatorSword_10_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GladiatorSword_10_Mesh MODELFILE=Models/GladiatorSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=GladiatorSword_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GladiatorSword_10_Mesh'
     AppClassTag="GladiatorSword"
     bDivineItem=True
}
