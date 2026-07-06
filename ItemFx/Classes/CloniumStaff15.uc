class CloniumStaff15 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff15_Mesh MODELFILE=Models/CloniumStaff_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff15_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_15_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff15_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
