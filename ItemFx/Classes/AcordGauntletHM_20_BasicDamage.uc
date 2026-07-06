class AcordGauntletHM_20_BasicDamage extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffect_T
#exec MESH MODELIMPORT MESH=AcordGauntletHM_20_Mesh MODELFILE=Models/AcordGauntletHM.psk
#exec MESHMAP SETTEXTURE MESHMAP=AcordGauntletHM_20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.AcordGauntletHM_20_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
