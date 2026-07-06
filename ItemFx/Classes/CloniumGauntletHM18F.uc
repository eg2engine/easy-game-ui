class CloniumGauntletHM18F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM18F_Mesh MODELFILE=Models/CloniumGauntletHM_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM18F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_18_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM18F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
