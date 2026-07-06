class GodSpeed_Bare_Tr_GauntletHF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_GauntletHF_Mesh01 MODELFILE=Models/Bare_Tr_GauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_GauntletHF_Mesh01 NUM=0 TEXTURE=Transformation_T.GodSpeed04S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_GauntletHF_Mesh01'
     AppClassTag="GodSpeed_Bare_Tr_GauntletHF"
     bDivineItem=True
     DrawScale3D=(X=1.200000,Y=1.200000,Z=1.200000)
}
