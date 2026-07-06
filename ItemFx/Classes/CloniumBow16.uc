class CloniumBow16 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow16_Mesh MODELFILE=Models/CloniumBow_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow16_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_16_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow16_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
