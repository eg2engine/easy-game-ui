//=============================================================================
// BASIC_MissonClear.
//=============================================================================
class BASIC_MissonClear extends SepEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.400000
         FadeInEndTime=0.100000
         MaxParticles=1
         StartLocationOffset=(Z=50.000000)
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.900000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.890000)
         StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=80.000000,Max=80.000000),Z=(Min=80.000000,Max=80.000000))
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'JEF_Environment_T.MissonClear_Mark02'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter19'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter25
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=50.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Blow03'
         LifetimeRange=(Min=0.050000,Max=0.050000)
     End Object
     Emitters(1)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter25'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter23
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.650000
         MaxParticles=15
         StartLocationOffset=(Z=50.000000)
         StartLocationRange=(Y=(Min=-105.000000,Max=105.000000),Z=(Min=-105.000000,Max=105.000000))
         StartSizeRange=(X=(Min=1.000000,Max=7.000000),Y=(Min=1.000000,Max=7.000000),Z=(Min=1.000000,Max=7.000000))
         InitialParticlesPerSecond=75.000000
         Texture=Texture'JEF_Environment_T.LLighting_YR'
         LifetimeRange=(Min=1.000000,Max=1.400000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
     End Object
     Emitters(2)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter23'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter24
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.300000
         MaxParticles=2
         StartLocationOffset=(Z=35.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.020000,Max=0.020000))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.025000,RelativeSize=1.000000)
         InitialParticlesPerSecond=20.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'JEF_Environment_T.Lens01'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(3)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter24'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.600000
         MaxParticles=20
         StartLocationOffset=(Z=50.000000)
         StartLocationRange=(Y=(Min=-115.000000,Max=115.000000),Z=(Min=-115.000000,Max=115.000000))
         StartSizeRange=(X=(Min=4.000000,Max=8.000000),Y=(Min=4.000000,Max=8.000000),Z=(Min=4.000000,Max=8.000000))
         InitialParticlesPerSecond=80.000000
         Texture=Texture'JEF_Environment_T.LLighting_R'
         LifetimeRange=(Min=1.000000,Max=1.400000)
         StartVelocityRange=(Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
     End Object
     Emitters(4)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter26'

     Begin Object Class=MeshEmitter Name=MeshEmitter4
         StaticMesh=StaticMesh'JEF_Environment_ST.MissonClearLine_ST_FT01'
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=0.050000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         MaxParticles=14
         StartLocationOffset=(Z=-240.000000)
         StartLocationRange=(Z=(Min=-10.000000,Max=60.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=2.500000,Max=2.500000))
         StartSpinRange=(X=(Max=100.000000))
         StartSizeRange=(X=(Min=0.600000,Max=1.200000),Y=(Min=0.600000,Max=1.200000),Z=(Min=0.600000,Max=1.200000))
         InitialParticlesPerSecond=28.000000
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(Z=(Min=360.000000,Max=360.000000))
         VelocityLossRange=(Z=(Min=0.500000,Max=0.500000))
     End Object
     Emitters(5)=MeshEmitter'SpecialFx.BASIC_MissonClear.MeshEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.800000
         MaxParticles=1
         StartLocationOffset=(Z=-240.000000)
         StartSizeRange=(X=(Min=140.000000,Max=140.000000),Y=(Min=140.000000,Max=140.000000),Z=(Min=140.000000,Max=140.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Gloss03_Alp'
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(6)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.700000
         MaxParticles=1
         StartLocationOffset=(Z=-145.000000)
         StartSizeRange=(X=(Min=120.000000,Max=120.000000),Y=(Min=120.000000,Max=120.000000),Z=(Min=120.000000,Max=120.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Blow04'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(7)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter22
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.400000
         MaxParticles=30
         StartLocationOffset=(Z=-200.000000)
         StartLocationRange=(Y=(Min=-80.000000,Max=80.000000),Z=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000))
         StartSizeRange=(X=(Min=3.000000,Max=14.000000),Y=(Min=3.000000,Max=14.000000),Z=(Min=3.000000,Max=14.000000))
         InitialParticlesPerSecond=25.000000
         Texture=Texture'JEF_Environment_T.LLighting_R2'
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(Z=(Min=200.000000,Max=200.000000))
     End Object
     Emitters(8)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter22'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter27
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.700000
         MaxParticles=1
         StartLocationOffset=(Z=15.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=200.000000,Max=200.000000),Z=(Max=200.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Blow04'
         LifetimeRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(9)=SpriteEmitter'SpecialFx.BASIC_MissonClear.SpriteEmitter27'

     AutoDestroy=True
     bLightChanged=True
     bNoDelete=False
     LifeSpan=8.000000
     bSelected=True
}
