class CloniumStaff16F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/HumanStaff_EF.utx PACKAGE=HumanStaff_EF
#exec MESH MODELIMPORT MESH=CloniumStaff16F_Mesh MODELFILE=Models/CloniumStaff_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStaff16F_Mesh NUM=0 TEXTURE=HumanStaff_EF.CloniumStaff_EF_16_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStaff16F_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
