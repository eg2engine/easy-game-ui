class TriumphusSword_08_GodAttack extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=TriumphusSword_08_Mesh MODELFILE=Models/TriumphusSword.psk
#exec MESHMAP SETTEXTURE MESHMAP=TriumphusSword_08_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.TriumphusSword_08_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
