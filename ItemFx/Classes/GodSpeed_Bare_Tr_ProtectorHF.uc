class GodSpeed_Bare_Tr_ProtectorHF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_ProtectorHF_Mesh MODELFILE=Models/Bare_Tr_ProtectorHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_ProtectorHF_Mesh NUM=0 TEXTURE=Transformation_T.GodSpeed04S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_ProtectorHF_Mesh'
     AppClassTag="GodSpeed_Bare_Tr_ProtectorHF"
     bDivineItem=True
     DrawScale3D=(X=1.450000,Y=1.450000,Z=1.450000)
}
