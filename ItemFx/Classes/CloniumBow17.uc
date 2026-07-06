class CloniumBow17 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow17_Mesh MODELFILE=Models/CloniumBow_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow17_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_17_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow17_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
