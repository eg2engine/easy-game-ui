class CloniumBow20SF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow20SF_Mesh MODELFILE=Models/CloniumBow_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow20SF_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_20_03

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow20SF_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
