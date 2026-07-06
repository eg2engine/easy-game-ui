class CloniumGauntletHF17F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF17F_Mesh MODELFILE=Models/CloniumGauntletHF_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF17F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_17_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF17F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
