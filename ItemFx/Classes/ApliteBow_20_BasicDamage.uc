class ApliteBow_20_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=ApliteBow_20_Mesh MODELFILE=Models/ApliteBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=ApliteBow_20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.ApliteBow_20_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
