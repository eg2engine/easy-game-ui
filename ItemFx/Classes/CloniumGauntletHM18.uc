class CloniumGauntletHM18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM18_Mesh MODELFILE=Models/CloniumGauntletHM_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM18_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_18_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
