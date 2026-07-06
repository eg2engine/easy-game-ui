class CloniumGauntletHM19F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM19F_Mesh MODELFILE=Models/CloniumGauntletHM_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM19F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_19_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM19F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
