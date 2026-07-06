class FabulaStick_10_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffect_T.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FabulaStick_10_Mesh MODELFILE=Models/FabulaStick_E.psk
#exec MESHMAP SETTEXTURE MESHMAP=FabulaStick_10_Mesh NUM=0 TEXTURE=IE_11_LMShader4

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FabulaStick_10_Mesh'
     AppClassTag="FabulaStick"
     bDivineItem=True
     PivotLoc=(X=0.850000,Y=0.850000,Z=0.850000)
}
