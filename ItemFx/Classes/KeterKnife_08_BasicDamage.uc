class KeterKnife_08_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=KeterKnife_08_Mesh MODELFILE=Models/KeterKnife.psk
#exec MESHMAP SETTEXTURE MESHMAP=KeterKnife_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_DG_Shader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.KeterKnife_08_Mesh'
     AppClassTag="Keterknife"
     RelativeRotation=(Pitch=32768,Roll=16384)
     bDivineItem=True
}
