class Weapon_TheurgicalEdge_Ten extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.TEST_13'
         UseParticleColor=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.503571,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScaleRepeats=5.000000
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=MeshEmitter'KillingWeaponFx.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.TEST_14'
         UseParticleColor=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.503571,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScaleRepeats=5.000000
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=MeshEmitter'KillingWeaponFx.MeshEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
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
         MaxParticles=60
         StartLocationOffset=(Z=20.000000)
         StartLocationRange=(Z=(Min=-40.000000,Max=100.000000))
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=12.000000,Max=22.000000),Y=(Min=12.000000,Max=22.000000),Z=(Min=12.000000,Max=22.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EffectTexture.M_Disciple.castingsaint01_02'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=SpriteEmitter'KillingWeaponFx.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter38
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=137,G=134,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=116,G=113,R=255,A=255))
         FadeOutStartTime=0.018000
         FadeInEndTime=0.018000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationOffset=(Z=60.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Offset
         SpinsPerSecondRange=(X=(Max=0.010000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.700000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=80.000000
         Texture=Texture'EffectTexture.M_Disciple.mana_regeenration02'
         TextureUSubdivisions=3
         TextureVSubdivisions=3
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(Z=(Max=-100.000000))
     End Object
     Emitters(5)=SpriteEmitter'KillingWeaponFx.SpriteEmitter38'

     Begin Object Class=MeshEmitter Name=MeshEmitter6
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.TheurgicalEdge'
         UseParticleColor=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.503571,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScaleRepeats=5.000000
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         StartSizeRange=(X=(Min=1.010000,Max=1.010000),Y=(Min=1.010000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(6)=MeshEmitter'KillingWeaponFx.MeshEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=252,G=243,R=211,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,A=255))
         ColorMultiplierRange=(X=(Max=3.000000))
         FadeOutStartTime=1.160000
         FadeInEndTime=0.180000
         CoordinateSystem=PTCS_Relative
         MaxParticles=40
         StartLocationRange=(Y=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.260000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=33.000000,Max=33.000000),Y=(Min=33.000000,Max=33.000000),Z=(Min=33.000000,Max=33.000000))
         Texture=Texture'EffectTexture.effect001.elect02'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=20.000000,Max=20.000000))
     End Object
     Emitters(7)=SpriteEmitter'KillingWeaponFx.SpriteEmitter7'

     bLightChanged=True
     bNoDelete=False
     DrawScale=0.500000
     bUnlit=False
     bDirectional=True
}
