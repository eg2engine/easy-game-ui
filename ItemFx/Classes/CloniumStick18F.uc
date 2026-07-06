class CloniumStick18F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/NephilimStick_EF.utx PACKAGE=NephilimStick_EF
#exec MESH MODELIMPORT MESH=CloniumStick18F_Mesh MODELFILE=Models/CloniumStick_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStick18F_Mesh NUM=0 TEXTURE=NephilimStick_EF.CloniumStick_EF_18_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStick18F_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
