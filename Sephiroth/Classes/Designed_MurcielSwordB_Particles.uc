class Designed_MurcielSwordB_Particles extends Emitter;

// V8: continuous black-gold flame silhouette, calibrated on weapon +Z.
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=BlackGoldCoreBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=235,B=170,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=235,B=170,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.358
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=44
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=68
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=12,Max=110))
        StartSizeRange=(X=(Min=18,Max=28))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.65,Max=0.65)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=12,Max=12))
    End Object
    Emitters(0)=SpriteEmitter'BlackGoldCoreBase'

    Begin Object Class=SpriteEmitter Name=BlackGoldFlameBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=150,B=55,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=150,B=55,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.440
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=26
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=33
        StartLocationRange=(X=(Min=-6,Max=6),Y=(Min=-3,Max=3),Z=(Min=18,Max=104))
        StartSizeRange=(X=(Min=26,Max=40))
        Texture=Texture'EffectEnvTextureD.A.fire_long'
        TextureUSubdivisions=5
        TextureVSubdivisions=5
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=24,Max=24))
    End Object
    Emitters(1)=SpriteEmitter'BlackGoldFlameBase'

    Begin Object Class=SpriteEmitter Name=BlackGoldArcBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=220,B=140,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=220,B=140,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.248
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=8
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=18
        StartLocationRange=(X=(Min=-4,Max=4),Y=(Min=-3,Max=3),Z=(Min=25,Max=112))
        StartSizeRange=(X=(Min=26,Max=38))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.45,Max=0.45)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=0,Max=0))
    End Object
    Emitters(2)=SpriteEmitter'BlackGoldArcBase'

    Begin Object Class=SpriteEmitter Name=BlackGoldEmberBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=210,B=90,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=210,B=90,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.385
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=28
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=40
        StartLocationRange=(X=(Min=-8,Max=8),Y=(Min=-3,Max=3),Z=(Min=8,Max=105))
        StartSizeRange=(X=(Min=2,Max=5))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=-10,Max=10),Z=(Min=28,Max=28))
    End Object
    Emitters(3)=SpriteEmitter'BlackGoldEmberBase'

    Begin Object Class=SpriteEmitter Name=BlackGoldGuardBase
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=200,B=95,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=200,B=95,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.468
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=4
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=5,Max=14))
        StartSizeRange=(X=(Min=22,Max=30))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.85,Max=0.85)
        StartVelocityRange=(X=(Min=-2,Max=2),Z=(Min=8,Max=8))
    End Object
    Emitters(4)=SpriteEmitter'BlackGoldGuardBase'

    bNoDelete=False
    bUnlit=True
    bDirectional=True
    RemoteRole=ROLE_None
}
