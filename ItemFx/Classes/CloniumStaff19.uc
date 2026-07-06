class CloniumStaff19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff19_Mesh MODELFILE=Models/CloniumStaff_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff19_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_19_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff19_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
