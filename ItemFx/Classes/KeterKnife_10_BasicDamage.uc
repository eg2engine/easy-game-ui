class KeterKnife_10_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=KeterKnife_10_Mesh MODELFILE=Models/KeterKnife.psk
#exec MESHMAP SETTEXTURE MESHMAP=KeterKnife_10_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.KeterKnife_10_Mesh'
     AppClassTag="Keterknife"
     RelativeRotation=(Pitch=32768,Roll=16384)
     bDivineItem=True
}
