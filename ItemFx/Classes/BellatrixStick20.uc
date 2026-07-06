class BellatrixStick20 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixStick20_Mesh MODELFILE=Models/BellatrixStick.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixStick20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixStick20_Mesh'
     AppClassTag="VastStaff"
     RelativeRotation=(Roll=-16384)
     bDivineItem=True
}
