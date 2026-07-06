class CloniumStaff20F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff20F_Mesh MODELFILE=Models/CloniumStaff_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff20F_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_20_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff20F_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
