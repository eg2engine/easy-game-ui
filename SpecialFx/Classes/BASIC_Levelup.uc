class BASIC_LevelUp extends SepEmitter;

//var Pawn LevelupPawn;

simulated function PostBeginPlay()
{
//	local vector HitLocation, HitNormal;
//	local actor HitActor;
//	local vector Start, End;
//	local float EmitOffset;
//	local int i;

	local int i;
	local class<Hero> HeroClass;

	Super.PostBeginPlay();

//	Start = Owner.Location;
//	End = Start;
//	HitActor = Owner.Trace(HitLocation, HitNormal, End, Start, true);

//	if(HitActor != None)
		for (i=0;i<Emitters.Length;i++)
		{
			Emitters[i].StartLocationOffset.Z += Owner.CollisionHeight * 2;
		}

/*
	Super.PostBeginPlay();
	if (Owner == None) {
		Destroy();
		return;
	}

	Start = Owner.Location;
	End = Start;
	End.Z -= 1000;
	HitActor = Owner.Trace(HitLocation, HitNormal, End, Start, true);
	if (HitActor != None && (HitActor.bWorldGeometry || HitActor.IsA('TerrainInfo') || HitActor.IsA('StaticMeshActor'))) {
		EmitOffset = Owner.Location.Z - HitLocation.Z;
		for (i=0;i<Emitters.Length;i++) {
			Emitters[i].StartLocationOffset.Z = -1 * EmitOffset;
		}
	}
*/
	//LevelupPawn = Spawn(class'Levelup_fly',Owner );
	//Spawn(class'Levelup_fly',Owner,,Owner.Location,Owner.Rotation );
	Spawn(class'Levelup_fly',Owner);
}

function PlaySpawnSound(Sound Snd)
{
	PlaySound(Snd, SLOT_None, 0.5, false, 64, 1, false);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter25
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=50.000000)
         FadeOutStartTime=0.200000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeSize=0.950000)
         StartSizeRange=(X=(Min=70.000000,Max=70.000000),Y=(Min=70.000000,Max=70.000000),Z=(Min=70.000000,Max=70.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'JEF_Environment_T.LevelUp_Mark01'
         LifetimeRange=(Min=0.750000,Max=0.750000)
         StartVelocityRange=(Z=(Min=60.000000,Max=60.000000))
     End Object
     Emitters(0)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter25'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-45.000000)
         FadeOutStartTime=0.700000
         FadeInEndTime=0.200000
         MaxParticles=20
         StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-80.000000,Max=80.000000))
         SpinsPerSecondRange=(X=(Max=1.500000))
         StartSpinRange=(X=(Min=10.000000,Max=100.000000))
         StartSizeRange=(X=(Min=7.000000,Max=18.000000),Y=(Min=7.000000,Max=18.000000),Z=(Min=7.000000,Max=18.000000))
         InitialParticlesPerSecond=80.000000
         Texture=Texture'JEF_Environment_T.Feather'
         LifetimeRange=(Min=1.200000,Max=1.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Min=100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=0.100000,Max=0.200000))
     End Object
     Emitters(1)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter26'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-20.000000)
         FadeOutStartTime=0.850000
         FadeInEndTime=0.250000
         MaxParticles=18
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-50.000000,Max=100.000000))
         StartSizeRange=(X=(Min=2.000000,Max=10.000000),Y=(Min=2.000000,Max=10.000000),Z=(Min=2.000000,Max=10.000000))
         InitialParticlesPerSecond=40.000000
         Texture=Texture'JEF_Environment_T.LLighting_YR'
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(2)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter28'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter29
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-25.000000)
         FadeOutStartTime=0.750000
         FadeInEndTime=0.300000
         MaxParticles=14
         StartLocationRange=(X=(Min=-110.000000,Max=110.000000),Y=(Min=-100.000000,Max=110.000000),Z=(Min=-20.000000,Max=100.000000))
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000))
         StartSpinRange=(X=(Max=100.000000))
         StartSizeRange=(X=(Min=2.000000,Max=15.000000),Y=(Min=2.000000,Max=15.000000),Z=(Min=2.000000,Max=15.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.LLighting_R2'
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(3)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter29'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.800000
         MaxParticles=1
         StartSizeRange=(X=(Min=240.000000,Max=240.000000),Y=(Min=240.000000,Max=240.000000),Z=(Min=240.000000,Max=240.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Blow04'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter30'

     Begin Object Class=MeshEmitter Name=MeshEmitter5
         StaticMesh=StaticMesh'JEF_Environment_ST.LevelUpLine_ST_FT02'
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=0.300000
         MaxParticles=12
         StartLocationOffset=(Z=-200.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.700000,Max=0.700000))
         StartSpinRange=(X=(Max=100.000000))
         StartSizeRange=(X=(Min=0.800000,Max=1.400000),Y=(Min=0.800000,Max=1.400000),Z=(Min=0.800000,Max=1.400000))
         InitialParticlesPerSecond=40.000000
         LifetimeRange=(Min=0.700000,Max=0.800000)
         StartVelocityRange=(Z=(Min=320.000000))
     End Object
     Emitters(5)=MeshEmitter'SpecialFx.BASIC_Levelup.MeshEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.400000
         MaxParticles=40
         StartLocationOffset=(Z=-250.000000)
         StartLocationRange=(Y=(Min=-100.000000,Max=100.000000),Z=(Max=100.000000))
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=100.000000))
         StartSizeRange=(X=(Min=5.000000,Max=20.000000),Y=(Min=5.000000,Max=20.000000),Z=(Min=5.000000,Max=20.000000))
         InitialParticlesPerSecond=40.000000
         Texture=Texture'JEF_Environment_T.LLighting_R3'
         LifetimeRange=(Min=0.600000,Max=0.800000)
         StartVelocityRange=(Z=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(6)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter19'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.700000
         MaxParticles=1
         StartLocationOffset=(Z=-240.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=140.000000,Max=140.000000),Y=(Min=140.000000,Max=140.000000),Z=(Min=140.000000,Max=140.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.RLighting01'
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(7)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter20'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         UseDirectionAs=PTDU_Normal
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.700000
         MaxParticles=1
         StartLocationOffset=(Z=-240.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=-0.500000))
         StartSizeRange=(X=(Min=140.000000,Max=140.000000),Y=(Min=140.000000,Max=140.000000),Z=(Min=140.000000,Max=140.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.RLighting01'
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(8)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter22
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.600000
         MaxParticles=1
         StartLocationOffset=(Z=-120.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'JEF_Environment_T.Blow03'
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(9)=SpriteEmitter'SpecialFx.BASIC_Levelup.SpriteEmitter22'

     AutoDestroy=True
     bLightChanged=True
     bNoDelete=False
     Physics=PHYS_Trailer
     LifeSpan=8.000000
     bSelected=True
     SpawnSoundString="EffectSound.Basic.LevelUp"
}
