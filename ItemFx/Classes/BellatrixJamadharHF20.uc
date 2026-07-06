class BellatrixJamadharHF20 extends SepEffect;

#exec OBJ LOAD FILE=../Textures/ItemEffectTextures.utx PACKAGE=ItemEffectTextures
#exec MESH MODELIMPORT MESH=BellatrixJamadharHF20_Mesh MODELFILE=Models/BellatrixJamadharHF.psk
#exec MESHMAP SETTEXTURE MESHMAP=BellatrixJamadharHF20_Mesh NUM=0 TEXTURE=ItemEffect_T.11IE10_ComS

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'ItemFx.BellatrixJamadharHF20_Mesh'
     AppClassTag="USword"
     RelativeRotation=(Pitch=32768)
     bDivineItem=True
}
