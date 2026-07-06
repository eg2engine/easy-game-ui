class BellatrixCrossbow20 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixCrossbow20_Mesh MODELFILE=Models/BellatrixCrossbow.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixCrossbow20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixCrossbow20_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
