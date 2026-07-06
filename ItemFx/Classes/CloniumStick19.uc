class CloniumStick19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/NephilimStick_EF.utx PACKAGE=NephilimStick_EF
#exec MESH MODELIMPORT MESH=CloniumStick19_Mesh MODELFILE=Models/CloniumStick_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumStick19_Mesh NUM=0 TEXTURE=NephilimStick_EF.CloniumStick_EF_19_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumStick19_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
