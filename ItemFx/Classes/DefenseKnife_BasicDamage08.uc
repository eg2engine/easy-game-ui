class DefenseKnife_BasicDamage08 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=TriumphusSword_06_Mesh MODELFILE=Models/TriumphusSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=TriumphusSword_06_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.TriumphusSword_06_Mesh'
     AppClassTag="DefenseKnife"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
