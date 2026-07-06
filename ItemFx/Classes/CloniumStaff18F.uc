class CloniumStaff18F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff18F_Mesh MODELFILE=Models/CloniumStaff_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff18F_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_18_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff18F_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
