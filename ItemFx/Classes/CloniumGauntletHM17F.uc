class CloniumGauntletHM17F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM17F_Mesh MODELFILE=Models/CloniumGauntletHM_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM17F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_17_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM17F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
