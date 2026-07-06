class GladiatorSword_08_BasicDamage extends SepEffect;


#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=GladiatorSword_08_Mesh MODELFILE=Models/GladiatorSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=GladiatorSword_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.GladiatorSword_08_Mesh'
     AppClassTag="GladiatorSword"
     bDivineItem=True
}
