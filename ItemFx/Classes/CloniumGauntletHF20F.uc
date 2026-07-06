class CloniumGauntletHF20F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Gauntlet_EF.utx PACKAGE=Gauntlet_EF
#exec MESH MODELIMPORT MESH=CloniumGauntletHF20F_Mesh MODELFILE=Models/CloniumGauntletHF_EF_03.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumGauntletHF20F_Mesh NUM=0 TEXTURE=Gauntlet_EF.CloniumGauntlet_EF_20_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumGauntletHF20F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
