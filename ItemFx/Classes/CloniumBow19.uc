class CloniumBow19 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow19_Mesh MODELFILE=Models/CloniumBow_EF_00.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow19_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_19_01

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow19_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
