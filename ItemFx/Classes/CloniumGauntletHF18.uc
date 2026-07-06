class CloniumGauntletHF18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF18_Mesh MODELFILE=Models/CloniumGauntletHF_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF18_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_18_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
