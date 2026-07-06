class CloniumStaff19F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff19F_Mesh MODELFILE=Models/CloniumStaff_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff19F_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_19_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff19F_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
