class CloniumBow15 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow15_Mesh MODELFILE=Models/CloniumBow_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow15_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_15_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow15_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
