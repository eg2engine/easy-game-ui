class CloniumBow18F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow18F_Mesh MODELFILE=Models/CloniumBow_EF_02.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow18F_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_18_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow18F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
