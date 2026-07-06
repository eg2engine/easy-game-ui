class CloniumStaff17 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff17_Mesh MODELFILE=Models/CloniumStaff_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff17_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_17_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff17_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
