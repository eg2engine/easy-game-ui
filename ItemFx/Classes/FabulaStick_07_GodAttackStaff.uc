class FabulaStick_07_GodAttackStaff extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=FabulaStick_07_Mesh MODELFILE=Models/FabulaStick_E.psk
#exec MESHMAP SETTEXTURE MESHMAP=FabulaStick_07_Mesh NUM=0 TEXTURE=ItemEffectTextures.IE_11_LMShader1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.FabulaStick_07_Mesh'
     AppClassTag="FabulaStick"
     bDivineItem=True
     PivotLoc=(X=0.850000,Y=0.850000,Z=0.850000)
}
