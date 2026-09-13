class Designed_ApliteBow_HJ_Particles extends Emitter;

// V12: profession-colored aura; relative coordinates follow the weapon.
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=ApliteBow_HJThemeBase0
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=90,G=255,B=190,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=90,G=255,B=190,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.07
        FadeOutStartTime=0.55
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=22
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=25
        StartLocationOffset=(X=-8)
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-72,Max=-8))
        StartSizeRange=(X=(Min=10.40,Max=16.00))
        Texture=Texture'EffectTexture.mesh004.berserker_twi'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.9,Max=0.9)
        StartVelocityRange=(Z=(Min=6,Max=6))
    End Object
    Emitters(0)=SpriteEmitter'ApliteBow_HJThemeBase0'

    Begin Object Class=SpriteEmitter Name=ApliteBow_HJThemeBase1
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=90,G=255,B=190,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=90,G=255,B=190,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.07
        FadeOutStartTime=0.55
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=22
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=25
        StartLocationOffset=(X=-8)
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=8,Max=72))
        StartSizeRange=(X=(Min=10.40,Max=16.00))
        Texture=Texture'EffectTexture.mesh004.berserker_twi'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.9,Max=0.9)
        StartVelocityRange=(Z=(Min=-6,Max=-6))
    End Object
    Emitters(1)=SpriteEmitter'ApliteBow_HJThemeBase1'

    Begin Object Class=SpriteEmitter Name=ApliteBow_HJThemeBase2
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=90,G=255,B=190,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=90,G=255,B=190,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.07
        FadeOutStartTime=0.55
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=10
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=12
        StartLocationOffset=(X=0)
        StartLocationRange=(X=(Min=-4,Max=4),Y=(Min=-3,Max=3),Z=(Min=-8,Max=8))
        StartSizeRange=(X=(Min=22.88,Max=35.20))
        Texture=Texture'EffectTexture.M_Disciple.mana_regeenration02'
        TextureUSubdivisions=3
        TextureVSubdivisions=3
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.9,Max=0.9)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(2)=SpriteEmitter'ApliteBow_HJThemeBase2'

    Begin Object Class=SpriteEmitter Name=ApliteBow_HJThemeBase3
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=90,G=255,B=190,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=90,G=255,B=190,A=0))
        ColorMultiplierRange=(X=(Min=2,Max=2),Y=(Min=2,Max=2),Z=(Min=2,Max=2))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.07
        FadeOutStartTime=0.55
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.15,Max=0.15))
        MaxParticles=22
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=25
        StartLocationOffset=(X=0)
        StartLocationRange=(X=(Min=-6,Max=6),Y=(Min=-3,Max=3),Z=(Min=-72,Max=72))
        StartSizeRange=(X=(Min=4.16,Max=6.40))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.9,Max=0.9)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(3)=SpriteEmitter'ApliteBow_HJThemeBase3'

    Begin Object Class=SpriteEmitter Name=V12ElementArcs
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=65,G=255,B=205,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=65,G=255,B=205,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=1.4,Max=1.4),Z=(Min=1.4,Max=1.4))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.03
        FadeOutStartTime=0.18
        UniformSize=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.35,Max=0.35))
        MaxParticles=16
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=48
        StartLocationRange=(X=(Min=-8,Max=8),Y=(Min=-5,Max=5),Z=(Min=-72,Max=72))
        StartSizeRange=(X=(Min=22.40,Max=32.00))
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
