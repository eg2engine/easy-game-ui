class TriumphusSword_10_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=TriumphusSword_10_Mesh MODELFILE=Models/TriumphusSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=TriumphusSword_10_Mesh NUM=0 TEXTURE=IE_11_LMShader4

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.TriumphusSword_10_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
