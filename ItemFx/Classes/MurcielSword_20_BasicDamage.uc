class MurcielSword_20_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=MurcielSword_20_Mesh MODELFILE=Models/MurcielSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=MurcielSword_20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.MurcielSword_20_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
