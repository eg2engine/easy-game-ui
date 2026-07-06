class DeathHand_Bare_Tr_GauntletHF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Transformation_T.utx PACKAGE=Transformation_T
#exec MESH MODELIMPORT MESH=Bare_Tr_GauntletHF_Mesh MODELFILE=Models/Bare_Tr_GauntletHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=Bare_Tr_GauntletHF_Mesh NUM=0 TEXTURE=Transformation_T.DeathHand01S

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.Bare_Tr_GauntletHF_Mesh'
     AppClassTag="DeathHand_Bare_Tr_GauntletHF"
     bDivineItem=True
}
