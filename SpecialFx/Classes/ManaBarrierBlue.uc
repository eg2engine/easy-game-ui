class ManaBarrierBlue extends SepEmitter;

simulated function PostBeginPlay()
{
	local int i;
	local float SizeScale;
	local class<Hero> HeroClass;

	Super.PostBeginPlay();

	HeroClass = class<Hero>(DynamicLoadObject("Heroes.HumanMale",class'Class'));
	SizeScale = Owner.CollisionHeight / HeroClass.Default.CollisionHeight;

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].StartSizeRange.X.Min *= SizeScale;
		Emitters[i].StartSizeRange.X.Max *= SizeScale;
		Emitters[i].StartSizeRange.Y.Min *= SizeScale;
		Emitters[i].StartSizeRange.Y.Max *= SizeScale;
		Emitters[i].StartSizeRange.Z.Min *= SizeScale;
		Emitters[i].StartSizeRange.Z.Max *= SizeScale;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter27
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=-50.000000)
         SpinsPerSecondRange=(X=(Max=0.010000))
         StartSpinRange=(X=(Max=10.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.050000)
         SizeScale(2)=(RelativeTime=2.000000,RelativeSize=1.050000)
         StartSizeRange=(X=(Min=160.000000,Max=160.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AllUseSkill_T.Barrier_Blue_T01'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'SpecialFx.ManaBarrierBlue.SpriteEmitter27'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=-50.000000)
         SpinsPerSecondRange=(X=(Max=0.010000))
         StartSpinRange=(X=(Max=10.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.050000)
         SizeScale(2)=(RelativeTime=2.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=190.000000,Max=190.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AllUseSkill_T.Barrier_Blue_T03'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(1)=SpriteEmitter'SpecialFx.ManaBarrierBlue.SpriteEmitter28'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter29
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-50.000000)
         MaxParticles=20
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-60.000000,Max=100.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=2.000000)
         SizeScaleRepeats=5.000000
         StartSizeRange=(X=(Min=8.000000,Max=10.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AllUseSkill_T.Barrier_Blue_T04'
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=80.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(2)=SpriteEmitter'SpecialFx.ManaBarrierBlue.SpriteEmitter29'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=-50.000000)
         SpinsPerSecondRange=(X=(Max=0.030000))
         StartSpinRange=(X=(Max=10.000000))
         SizeScale(0)=(RelativeSize=0.980000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=2.000000,RelativeSize=0.980000)
         StartSizeRange=(X=(Min=190.000000,Max=190.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AllUseSkill_T.Barrier_Blue_T05'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(3)=SpriteEmitter'SpecialFx.ManaBarrierBlue.SpriteEmitter31'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=8.000000
     bNoRotation=True
     bNoBoneLoc=True
}
