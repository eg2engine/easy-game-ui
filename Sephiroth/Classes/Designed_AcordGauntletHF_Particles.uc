class Designed_AcordGauntletHF_Particles extends Emitter;

// V14: blue channel isolation, restrained yellow arcs, reinforced staff crown.
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=AcordGauntletHFCoreBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=145,G=25,B=255,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=145,G=25,B=255,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.45
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.1,Max=0.1))
        MaxParticles=24
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=30
        StartLocationRange=(X=(Min=-5.95,Max=5.95),Y=(Min=-3,Max=3),Z=(Min=-10.2,Max=15.299999999999999))
        StartSizeRange=(X=(Min=14.28,Max=20.40))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=4,Max=4))
    End Object
    Emitters(0)=SpriteEmitter'AcordGauntletHFCoreBase'

    Begin Object Class=SpriteEmitter Name=AcordGauntletHFCoronaBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=145,G=25,B=255,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=145,G=25,B=255,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.45
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.1,Max=0.1))
        MaxParticles=14
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=18
        StartLocationRange=(X=(Min=-7.6499999999999995,Max=7.6499999999999995),Y=(Min=-3,Max=3),Z=(Min=-6.8,Max=17))
        StartSizeRange=(X=(Min=19.04,Max=27.20))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=12,Max=12))
    End Object
    Emitters(1)=SpriteEmitter'AcordGauntletHFCoronaBase'

    Begin Object Class=SpriteEmitter Name=AcordGauntletHFLightningBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=235,B=30,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=235,B=30,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.45
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.1,Max=0.1))
        MaxParticles=4
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        StartLocationRange=(X=(Min=-8.5,Max=8.5),Y=(Min=-3,Max=3),Z=(Min=-10.2,Max=20.4))
        StartSizeRange=(X=(Min=16.18,Max=23.12))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=0,Max=0))
    End Object
    Emitters(2)=SpriteEmitter'AcordGauntletHFLightningBase'

    Begin Object Class=SpriteEmitter Name=AcordGauntletHFSparksBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=220,B=100,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=220,B=100,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.45
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.1,Max=0.1))
        MaxParticles=26
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=33
        StartLocationRange=(X=(Min=-10.2,Max=10.2),Y=(Min=-3,Max=3),Z=(Min=-12.75,Max=21.25))
        StartSizeRange=(X=(Min=2.97,Max=4.25))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=18,Max=18))
    End Object
    Emitters(3)=SpriteEmitter'AcordGauntletHFSparksBase'

    Begin Object Class=SpriteEmitter Name=V12ElementArcs
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=235,B=30,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=235,B=30,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=1.4,Max=1.4),Z=(Min=1.4,Max=1.4))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.03
        FadeOutStartTime=0.18
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.35,Max=0.35))
        MaxParticles=6
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=17
        StartLocationRange=(X=(Min=-8,Max=8),Y=(Min=-5,Max=5),Z=(Min=-20,Max=25))
        StartSizeRange=(X=(Min=19.04,Max=27.20))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.28,Max=0.38)
    End Object
    Emitters(4)=SpriteEmitter'V12ElementArcs'

    bNoDelete=False
    bUnlit=True
    bDirectional=True
    RemoteRole=ROLE_None
}
