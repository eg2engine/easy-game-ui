class weapon_FogMothBow_Ten extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter28
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.Bow01'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.503571,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScaleRepeats=5.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=MeshEmitter'KillingWeaponFx.MeshEmitter28'

     Begin Object Class=MeshEmitter Name=MeshEmitter29
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.Bow02'
         RenderTwoSided=True
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
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=MeshEmitter'KillingWeaponFx.MeshEmitter29'

     Begin Object Class=MeshEmitter Name=MeshEmitter31
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.Bow03'
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
     Emitters(2)=MeshEmitter'KillingWeaponFx.MeshEmitter31'

     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'Killing_Weapon_Effect_ST.Bow04'
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
     Emitters(3)=MeshEmitter'KillingWeaponFx.MeshEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
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
         StartLocationRange=(Z=(Min=-40.000000,Max=10.000000))
         UseRotationFrom=PTRS_Offset
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=12.000000,Max=22.000000),Y=(Min=12.000000,Max=22.000000),Z=(Min=12.000000,Max=22.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EffectTexture.M_Disciple.castingsaint01_02'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(4)=SpriteEmitter'KillingWeaponFx.SpriteEmitter28'

     bLightChanged=True
     bNoDelete=False
     DrawScale=0.500000
     bUnlit=False
     bDirectional=True
}
