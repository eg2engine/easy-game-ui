class GodSpeed_Bare_Tr_ProtectorHM extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_ProtectorHM_Mesh MODELFILE=Models/Bare_Tr_ProtectorHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_ProtectorHM_Mesh NUM=0 TEXTURE=Transformation_T.GodSpeed04S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_ProtectorHM_Mesh'
     AppClassTag="GodSpeed_Bare_Tr_ProtectorHM"
     bDivineItem=True
     DrawScale3D=(X=1.300000,Y=1.300000,Z=1.300000)
}
