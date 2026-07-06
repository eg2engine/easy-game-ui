class UltraEndure_OneHand_Tr_Shield extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=OneHand_Tr_Shield_Mesh MODELFILE=Models/OneHand_Tr_Shield.psk
#exec MESHMAP SETTEXTURE MESHMAP=OneHand_Tr_Shield_Mesh NUM=0 TEXTURE=Transformation_T.UltraEndure03SP

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.OneHand_Tr_Shield_Mesh'
     AppClassTag="Shield"
     bDivineItem=True
}
