class Weapon_VastStaff_Ten extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         ColorScale(0)=(Color=(B=255,G=230,R=231,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=157,G=155,R=255,A=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.110000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationOffset=(Z=50.000000)
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=-20.000000))
         UseRotationFrom=PTRS_Offset
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=70.000000
         Texture=Texture'EffectTexture.mesh004.berserker_twi'
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(Z=(Max=-350.000000))
     End Object
     Emitters(0)=SpriteEmitter'KillingWeaponFx.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
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
         StartLocationOffset=(Z=-10.000000)
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
     Emitters(1)=SpriteEmitter'KillingWeaponFx.SpriteEmitter1'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.VastStaff_OutL'
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
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(2)=MeshEmitter'KillingWeaponFx.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=202,G=244,R=242,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=39,G=210,R=224,A=255))
         FadeOutStartTime=0.140000
         FadeInEndTime=0.080000
         CoordinateSystem=PTCS_Relative
         MaxParticles=12
         StartLocationOffset=(Z=20.000000)
         StartLocationRange=(Z=(Min=-90.000000,Max=60.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'EffectTexture.effect001.circle0005a'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(3)=SpriteEmitter'KillingWeaponFx.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
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
         MaxParticles=12
         StartLocationOffset=(Z=20.000000)
         StartLocationRange=(Z=(Min=-90.000000,Max=60.000000))
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EffectTexture.M_Disciple.castingsaint01_02'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(5)=SpriteEmitter'KillingWeaponFx.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
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
         MaxParticles=12
         StartLocationOffset=(Z=20.000000)
         StartLocationRange=(Z=(Min=-90.000000,Max=60.000000))
         UseRotationFrom=PTRS_Offset
         StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EffectTexture.M_Disciple.castingsaint01'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(6)=SpriteEmitter'KillingWeaponFx.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=123,G=171,R=242,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=68,G=98,R=219,A=255))
         FadeOutStartTime=0.720000
         FadeInEndTime=0.070000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         UseRotationFrom=PTRS_Offset
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.500000,Max=10.000000),Y=(Min=0.500000,Max=10.000000),Z=(Min=0.500000,Max=10.000000))
         InitialParticlesPerSecond=200.000000
         Texture=Texture'EffectEnvTextureD.A.fire_long'
         TextureUSubdivisions=5
         TextureVSubdivisions=5
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-100.000000,Max=-140.000000))
     End Object
     Emitters(8)=SpriteEmitter'KillingWeaponFx.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         Acceleration=(Z=10.000000)
         ColorScale(0)=(Color=(B=123,G=171,R=242,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=68,G=98,R=219,A=255))
         FadeOutStartTime=0.490000
         FadeInEndTime=0.070000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         UseRotationFrom=PTRS_Offset
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=1.000000,Max=15.000000),Y=(Min=1.000000,Max=15.000000),Z=(Min=1.000000,Max=15.000000))
         InitialParticlesPerSecond=200.000000
         Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-6.000000,Max=6.000000),Y=(Min=-6.000000,Max=6.000000),Z=(Min=-100.000000,Max=-140.000000))
     End Object
     Emitters(9)=SpriteEmitter'KillingWeaponFx.SpriteEmitter9'

     Begin Object Class=MeshEmitter Name=MeshEmitter10
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.VastStaff_C02'
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
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(10)=MeshEmitter'KillingWeaponFx.MeshEmitter10'

     Begin Object Class=MeshEmitter Name=MeshEmitter11
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.VastStaff_B04'
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
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(11)=MeshEmitter'KillingWeaponFx.MeshEmitter11'

     bLightChanged=True
     bNoDelete=False
     DrawScale=0.500000
     bUnlit=False
     bDirectional=True
}
