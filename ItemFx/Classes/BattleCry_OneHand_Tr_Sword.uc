class BattleCry_OneHand_Tr_Sword extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=OneHand_Tr_Sword_Mesh MODELFILE=Models/OneHand_Tr_Sword.psk
#exec MESHMAP SETTEXTURE MESHMAP=OneHand_Tr_Sword_Mesh NUM=0 TEXTURE=Transformation_T.AbsoluteDefense01S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.OneHand_Tr_Sword_Mesh'
     AppClassTag="BattleCry_OneHand_Tr_Sword"
     bDivineItem=True
}
