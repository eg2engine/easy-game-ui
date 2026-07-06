class CloniumGauntletHF16F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF16F_Mesh MODELFILE=Models/CloniumGauntletHF_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF16F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_16_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF16F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
