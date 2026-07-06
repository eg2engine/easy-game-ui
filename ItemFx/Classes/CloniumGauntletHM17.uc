class CloniumGauntletHM17 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM17_Mesh MODELFILE=Models/CloniumGauntletHM_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM17_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_17_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM17_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
