class CloniumStick20SF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/NephilimStick_EF.utx PACKAGE=NephilimStick_EF
#exec MESH MODELIMPORT MESH=CloniumStick20SF_Mesh MODELFILE=Models/CloniumStick_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStick20SF_Mesh NUM=0 TEXTURE=NephilimStick_EF.CloniumStick_EF_20_03

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStick20SF_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
