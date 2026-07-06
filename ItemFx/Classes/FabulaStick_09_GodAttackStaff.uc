class FabulaStick_09_GodAttackStaff extends SepEffect;

/** backup
#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffect_T
#exec MESH MODELIMPORT MESH=FabulaStick_09_Mesh MODELFILE=Models/FabulaStick_E.psk
#exec MESHMAP SETTEXTURE MESHMAP=FabulaStick_09_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE_09ComS
**/
#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FabulaStick_09_Mesh MODELFILE=Models/FabulaStick_E.psk
#exec MESHMAP SETTEXTURE MESHMAP=FabulaStick_09_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FabulaStick_09_Mesh'
     AppClassTag="FabulaStick"
     bDivineItem=True
     PivotLoc=(X=0.850000,Y=0.850000,Z=0.850000)
}
