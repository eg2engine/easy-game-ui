class CloniumGauntletHF19F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF19F_Mesh MODELFILE=Models/CloniumGauntletHF_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF19F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_19_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF19F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
