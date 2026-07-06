class CloniumGauntletHF20SF extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF20SF_Mesh MODELFILE=Models/CloniumGauntletHF_EF_04.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF20SF_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_20_03

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF20SF_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
