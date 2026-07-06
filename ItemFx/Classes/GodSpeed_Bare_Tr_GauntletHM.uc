class GodSpeed_Bare_Tr_GauntletHM extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_GauntletHM_Mesh01 MODELFILE=Models/Bare_Tr_GauntletHM.psk
#exec MESH ORIGIN MESH=Bare_Tr_GauntletHM_Mesh01 Pitch=-1.5
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_GauntletHM_Mesh01 NUM=0 TEXTURE=Transformation_T.GodSpeed04S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_GauntletHM_Mesh01'
     AppClassTag="GodSpeed_Bare_Tr_GauntletHM"
     bDivineItem=True
     DrawScale3D=(X=0.900000,Y=0.950000,Z=0.850000)
}
