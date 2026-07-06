class AbsoluteDefense_OneHand_Tr_Shield extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=OneHand_Tr_Shield_Mesh01 MODELFILE=Models/OneHand_Tr_Shield.psk
#exec MESHMAP SETTEXTURE MESHMAP=OneHand_Tr_Shield_Mesh01 NUM=0 TEXTURE=Transformation_T.AbsoluteDefense01S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.OneHand_Tr_Shield_Mesh01'
     AppClassTag="Shield"
     bDivineItem=True
}
