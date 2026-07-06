class CloniumBow17F extends SepEffect;

#exec OBJ LOAD FILE=../Textures/Bow_EF.utx PACKAGE=Bow_EF
#exec MESH MODELIMPORT MESH=CloniumBow17F_Mesh MODELFILE=Models/CloniumBow_EF_01.PSK
#exec MESHMAP SETTEXTURE MESHMAP=CloniumBow17F_Mesh NUM=0 TEXTURE=Bow_EF.CloniumBow_EF_17_02

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.CloniumBow17F_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
