class CloniumStaff20SF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff20SF_Mesh MODELFILE=Models/CloniumStaff_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff20SF_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_20_03

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff20SF_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
