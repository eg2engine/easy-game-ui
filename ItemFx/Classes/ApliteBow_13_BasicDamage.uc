class ApliteBow_13_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=ApliteBow_13_Mesh MODELFILE=Models/ApliteBow.psk
#exec MESHMAP SETTEXTURE MESHMAP=ApliteBow_13_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.ApliteBow_13_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
