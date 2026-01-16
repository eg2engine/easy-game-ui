class Weapon_HandGauntletHF extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter29
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=254,G=242,R=241,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=27,G=216,R=231,A=255))
         ColorMultiplierRange=(X=(Max=7.000000),Y=(Max=7.000000),Z=(Max=7.000000))
         FadeOutStartTime=0.140000
         FadeInEndTime=0.065000
         CoordinateSystem=PTCS_Relative
         MaxParticles=60
         StartLocationOffset=(X=10.000000)
         StartLocationRange=(X=(Min=30.000000,Max=30.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=30.000000,Max=30.000000)
         StartLocationPolarRange=(X=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(X=0.370000)
         SpinsPerSecondRange=(X=(Max=2.000000))
         StartSizeRange=(X=(Min=0.500000,Max=2.000000),Y=(Min=0.500000,Max=2.000000),Z=(Min=0.500000,Max=2.000000))
         InitialParticlesPerSecond=3000.000000
         DrawStyle=PTDS_Darken
         Texture=Texture'EffectTextureA.Common.particle05'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Z=(Min=-50.000000,Max=80.000000))
     End Object
     Emitters(1)=SpriteEmitter'KillingWeaponFx.SpriteEmitter29'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=140,G=242,R=237,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=82,G=200,R=224,A=255))
         FadeOutStartTime=0.230000
         FadeInEndTime=0.130000
         CoordinateSystem=PTCS_Relative
         MaxParticles=45
         StartLocationOffset=(Z=20.000000)
         StartLocationRange=(Z=(Min=-40.000000,Max=10.000000))
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=10.000000,Max=20.000000),Z=(Min=10.000000,Max=20.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EffectTexture.M_Disciple.castingsaint01_02'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(5)=SpriteEmitter'KillingWeaponFx.SpriteEmitter30'

     Begin Object Class=MeshEmitter Name=MeshEmitter27
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.HandGauntletHF_B04'
         RenderTwoSided=True
         UseParticleColor=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
         ColorScale(1)=(Color=(B=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.600000,Max=0.600000))
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(8)=MeshEmitter'KillingWeaponFx.MeshEmitter27'

     Begin Object Class=MeshEmitter Name=MeshEmitter26
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.HandGauntletHF_OutL'
         RenderTwoSided=True
         UseParticleColor=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
         ColorScale(1)=(Color=(B=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.600000,Max=0.600000))
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         SizeScale(0)=(RelativeSize=0.900000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=0.900000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.900000)
         StartSizeRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(11)=MeshEmitter'KillingWeaponFx.MeshEmitter26'

     bLightChanged=True
     bNoDelete=False
     DrawScale=0.500000
     bUnlit=False
     bDirectional=True
}
