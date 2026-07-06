class CloniumBow20F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow20F_Mesh MODELFILE=Models/CloniumBow_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow20F_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_20_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow20F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
