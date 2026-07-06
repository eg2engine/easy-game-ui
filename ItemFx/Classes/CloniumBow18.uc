class CloniumBow18 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow18_Mesh MODELFILE=Models/CloniumBow_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow18_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_18_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow18_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
