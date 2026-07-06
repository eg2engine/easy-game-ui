class DeathHand_Bare_Tr_gauntletHM extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_GauntletHM_Mesh MODELFILE=Models/Bare_Tr_GauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_GauntletHM_Mesh NUM=0 TEXTURE=Transformation_T.DeathHand01S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_GauntletHM_Mesh'
     AppClassTag="DeathHand_Bare_Tr_gauntletHM"
     bDivineItem=True
}
