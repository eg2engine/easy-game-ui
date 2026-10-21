class HailStorm_Explosion extends SepEmitter;

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 40, false, 128, 1, false);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter32
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeInEndTime=1.000000
         MaxParticles=3
         StartLocationOffset=(Z=480.000000)
         StartSpinRange=(X=(Max=32768.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=3.000000)
         InitialParticlesPerSecond=20.000000
         Texture=Texture'Blue_T.Bubble'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-500.000000,Max=-500.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=-1.000000,Max=-1.000000))
     End Object
     Emitters(0)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter32'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter33
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=20
         StartLocationOffset=(Z=280.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.100000))
         StartSpinRange=(X=(Max=32768.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=150.000000,Max=180.000000))
         InitialParticlesPerSecond=16.000000
         Texture=Texture'Blue_T.BlueMeteoricT1'
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-45.000000,Max=45.000000),Y=(Min=-45.000000,Max=45.000000),Z=(Min=180.000000,Max=190.000000))
         VelocityLossRange=(X=(Min=-1.000000,Max=0.200000),Y=(Min=-1.000000,Max=0.200000),Z=(Min=0.500000,Max=0.600000))
     End Object
     Emitters(1)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter33'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter34
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeInEndTime=0.200000
         MaxParticles=30
         StartLocationOffset=(Z=500.000000)
         StartLocationRange=(X=(Min=-160.000000,Max=160.000000),Y=(Min=-160.000000,Max=160.000000))
         StartSpinRange=(X=(Max=32768.000000))
         StartSizeRange=(X=(Min=20.000000,Max=60.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'Blue_T.IceBreak'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-120.000000,Max=-150.000000))
         VelocityLossRange=(X=(Min=-7.000000,Max=-9.000000),Y=(Min=-7.000000,Max=-9.000000),Z=(Min=-8.000000,Max=-9.800000))
     End Object
     Emitters(2)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter34'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter35
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=2
         StartLocationOffset=(Z=500.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=32768.000000))
         StartSizeRange=(X=(Min=70.000000,Max=70.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'Blue_T.IceBreak'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-80.000000,Max=-80.000000))
         VelocityLossRange=(Z=(Min=-10.000000,Max=-10.000000))
     End Object
     Emitters(3)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter35'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter36
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         StartLocationOffset=(Z=-80.000000)
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=150.000000,Max=250.000000))
         InitialParticlesPerSecond=25.000000
         Texture=Texture'Blue_T.BlueMeteoricT1'
         LifetimeRange=(Min=0.400000,Max=0.400000)
         InitialDelayRange=(Min=3.400000,Max=3.400000)
     End Object
     Emitters(4)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter36'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter37
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         MaxParticles=20
         StartLocationOffset=(Z=-80.000000)
         StartLocationRange=(X=(Min=-350.000000,Max=350.000000),Y=(Min=-350.000000,Max=350.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000))
         StartSpinRange=(X=(Min=10.000000,Max=32768.000000))
         StartSizeRange=(X=(Min=5.000000,Max=40.000000))
         InitialParticlesPerSecond=60.000000
         Texture=Texture'Blue_T.IceBreak'
         InitialDelayRange=(Min=3.400000,Max=3.400000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=350.000000,Max=700.000000))
         VelocityLossRange=(Z=(Min=1.000000,Max=2.000000))
     End Object
     Emitters(5)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter37'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter38
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=15
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=-380.000000,Max=380.000000),Y=(Min=-380.000000,Max=380.000000))
         StartSpinRange=(X=(Max=32768.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Max=130.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'Blue_T.Bubble'
         LifetimeRange=(Min=1.700000,Max=2.000000)
         InitialDelayRange=(Min=3.400000,Max=3.400000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Max=20.000000))
     End Object
     Emitters(6)=SpriteEmitter'ActiveFx.HailStorm_Explosion.SpriteEmitter38'

     AutoDestroy=True
     bLightChanged=True
     bNoDelete=False
     LifeSpan=15.000000
     Region=(iLeaf=2,ZoneNumber=1)
     Tag="HailStorm_Explosion"
     Location=(X=-1.064329,Y=-403.936829,Z=-33.132713)
     bSelected=True
     SpawnSoundString="ActiveSound.HailStorm"
}
