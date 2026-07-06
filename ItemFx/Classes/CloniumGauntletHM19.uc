class CloniumGauntletHM19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM19_Mesh MODELFILE=Models/CloniumGauntletHM_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM19_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_19_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM19_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
