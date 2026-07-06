class CloniumGauntletHF16 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF16_Mesh MODELFILE=Models/CloniumGauntletHF_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF16_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_16_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF16_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
