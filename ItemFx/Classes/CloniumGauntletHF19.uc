class CloniumGauntletHF19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF19_Mesh MODELFILE=Models/CloniumGauntletHF_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF19_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_19_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF19_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
