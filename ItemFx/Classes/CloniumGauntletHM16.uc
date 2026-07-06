class CloniumGauntletHM16 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHM16_Mesh MODELFILE=Models/CloniumGauntletHM_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHM16_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_16_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHM16_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
