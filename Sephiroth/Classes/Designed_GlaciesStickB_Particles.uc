class Designed_GlaciesStickB_Particles extends Emitter;

// V16: silver-blue shaft, crystal crown, orbiting shards and slow frost rings.
var float FrostPhase;
var float ArcDelay;

var vector LastTail;
var bool bTailReady;
var float TailMotion;
var float TailTime;

simulated event Tick(float DeltaTime)
{
    local vector TailLocal, TailWorld;
    local float TailSpeed, GlowPulse;
    local int I;
    local float Angle, Breath, Surge;
    local vector P;
    FrostPhase += DeltaTime * 0.8;
    // V38: one connected energy crown instead of orbiting head points.
    Surge = FMax(Sin(FrostPhase * 0.7), 0.0);
    Surge = Surge * Surge * Surge;
    Emitters[2].StartSizeRange.X.Min = 19 + Surge * 4;
    Emitters[2].StartSizeRange.X.Max = 29 + Surge * 7;
    Emitters[3].StartSizeRange.X.Min = 23 + Surge * 4;
    Emitters[3].StartSizeRange.X.Max = 34 + Surge * 7;
    // Two blue beads spiral up the shaft.
    for (I = 10; I <= 11; I++)
    {
        Angle = FrostPhase * 3 + float(I - 10) * 3.141593;
        P.X = Cos(Angle) * 7;
        P.Y = Sin(Angle) * 7;
        P.Z = -85 + (0.5 + 0.5 * Sin(FrostPhase + float(I - 10) * 3.141593)) * 145;
        Emitters[I].StartLocationOffset = P;
    }
    // Absolute particles fall in world-down, independent of the held staff angle.
    P.X = 0;
    P.Y = 0;
    P.Z = 86;
    Emitters[5].StartLocationOffset = P >> Rotation;
    Breath = 0.65 + 0.2 * Sin(FrostPhase * 1.5);
    Emitters[15].ColorMultiplierRange.Z.Min = Breath;
    Emitters[15].ColorMultiplierRange.Z.Max = Breath;
    Emitters[16].ColorMultiplierRange.Z.Min = Breath;
    Emitters[16].ColorMultiplierRange.Z.Max = Breath;
    ArcDelay -= DeltaTime;
    if (ArcDelay <= 0)
    {
        ArcDelay = 0.10 + FRand() * 0.18;
        P.X = -5 + FRand() * 10; P.Y = 0; P.Z = -65 + FRand() * 120;
        Emitters[17].StartLocationOffset = P;
        P.X += 7; P.Z += 10;
        Emitters[18].StartLocationOffset = P;
        Emitters[17].Disabled = FRand() < 0.25;
        Emitters[18].Disabled = FRand() < 0.45;
    }
    TailTime += DeltaTime;
    GlowPulse = 0.5 + 0.5 * Sin(TailTime * 1.5);

    TailLocal.X = 0; TailLocal.Y = 0; TailLocal.Z = -92;
    TailWorld = Location + (TailLocal >> Rotation);
    TailSpeed = 0;
    if (bTailReady && DeltaTime > 0.001 && VSize(TailWorld - LastTail) < 180)
        TailSpeed = FMin(VSize(TailWorld - LastTail) / DeltaTime / 420.0, 1.0);
    LastTail = TailWorld;
    bTailReady = True;
    TailMotion += (TailSpeed - TailMotion) * FMin(DeltaTime * 7, 1.0);
    Emitters[23].StartLocationOffset = TailLocal >> Rotation;
    Emitters[24].StartLocationOffset = TailLocal >> Rotation;
    Emitters[23].LifetimeRange.Min = 0.12 + TailMotion * 0.3;
    Emitters[23].LifetimeRange.Max = 0.18 + TailMotion * 0.4;
    Emitters[23].ColorScale[0].Color.A = byte(55 + TailMotion * 130);
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=IceSilverFlow
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=230))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.24
        FadeOutStartTime=0.88
        MaxParticles=64
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=52
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-92,Max=85))
        UniformSize=True
        StartSizeRange=(X=(Min=8,Max=14))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.6,Max=1.6)
        StartVelocityRange=(Z=(Min=15,Max=23))
    End Object
    Emitters(0)=SpriteEmitter'IceSilverFlow'

    Begin Object Class=SpriteEmitter Name=IceCrystalCore
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=240))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.21
        FadeOutStartTime=0.77
        MaxParticles=6
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=3.75
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=81,Max=87))
        UniformSize=True
        StartSizeRange=(X=(Min=9,Max=14))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.4,Max=1.4)
    End Object
    Emitters(1)=SpriteEmitter'IceCrystalCore'

    Begin Object Class=SpriteEmitter Name=IceOrbitA
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=150))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.36
        MaxParticles=18
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=24
        StartLocationRange=(X=(Min=-11,Max=11),Y=(Min=-5,Max=5),Z=(Min=71,Max=99))
        UniformSize=True
        StartSizeRange=(X=(Min=4.50,Max=7.20),Y=(Min=1.3,Max=2),Z=(Min=1,Max=2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartLocationOffset=(Z=0)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.06,Max=0.10))
    End Object
    Emitters(2)=SpriteEmitter'IceOrbitA'

    Begin Object Class=SpriteEmitter Name=IceOrbitB
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=150))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.36
        MaxParticles=14
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=20
        StartLocationRange=(X=(Min=-11,Max=11),Y=(Min=-5,Max=5),Z=(Min=71,Max=99))
        UniformSize=True
        StartSizeRange=(X=(Min=4.50,Max=7.20),Y=(Min=1.3,Max=2),Z=(Min=1,Max=2))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartLocationOffset=(Z=0)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.06,Max=0.10))
    End Object
    Emitters(3)=SpriteEmitter'IceOrbitB'

    Begin Object Class=SpriteEmitter Name=IceOrbitC
        CoordinateSystem=PTCS_Relative
        Disabled=True
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=230))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.36
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=0,Max=0))
        UniformSize=True
        StartSizeRange=(X=(Min=4.50,Max=7.20),Y=(Min=1.3,Max=2),Z=(Min=1,Max=2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.65,Max=0.65)
        StartLocationOffset=(X=-8.5,Y=-14.7,Z=84)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.06,Max=0.10))
    End Object
    Emitters(4)=SpriteEmitter'IceOrbitC'

    Begin Object Class=SpriteEmitter Name=IceFallingFrost
        CoordinateSystem=PTCS_Absolute
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.45
        FadeOutStartTime=1.65
        MaxParticles=28
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=10
        StartLocationRange=(X=(Min=-7,Max=7),Y=(Min=-7,Max=7),Z=(Min=0,Max=0))
        UniformSize=True
        StartSizeRange=(X=(Min=1.5,Max=3.5))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=3,Max=3)
        StartVelocityRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-14,Max=-7))
    End Object
    Emitters(5)=SpriteEmitter'IceFallingFrost'

    Begin Object Class=SpriteEmitter Name=IceFineMist
        CoordinateSystem=PTCS_Relative
        Disabled=True
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=55))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.27
        FadeOutStartTime=0.99
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        StartLocationRange=(X=(Min=-9,Max=9),Y=(Min=-9,Max=9),Z=(Min=75,Max=93))
        UniformSize=True
        StartSizeRange=(X=(Min=10.00,Max=17.50),Y=(Min=1.3,Max=2),Z=(Min=1,Max=2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.8,Max=1.8)
        StartVelocityRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=2))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.7)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.5)
    End Object
    Emitters(6)=SpriteEmitter'IceFineMist'

    Begin Object Class=SpriteEmitter Name=IceFrostRing
        CoordinateSystem=PTCS_Relative
        Disabled=True // V37: all blue ring layers disabled; indices retained for Tick.
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=150))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.48
        FadeOutStartTime=1.76
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=84,Max=86))
        UniformSize=True
        StartSizeRange=(X=(Min=15.00,Max=20.00),Y=(Min=1.3,Max=2),Z=(Min=1,Max=2))
        Texture=Texture'EffectTexture.effect001.circle0005a'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=3.2,Max=3.2)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.35)
        SizeScale(1)=(RelativeTime=1,RelativeSize=2.3)
    End Object
    Emitters(7)=SpriteEmitter'IceFrostRing'

    Begin Object Class=SpriteEmitter Name=V17IceCrown
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=220))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.45
        MaxParticles=5
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=10
        UniformSize=True
        StartLocationRange=(X=(Min=-13,Max=13),Y=(Min=-8,Max=8),Z=(Min=72,Max=98))
        StartSizeRange=(X=(Min=20,Max=29))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.9)
    End Object
    Emitters(8)=SpriteEmitter'V17IceCrown'

    Begin Object Class=SpriteEmitter Name=V18BlueShaftVeil
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=210))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.1
        FadeOutStartTime=0.5
        MaxParticles=42
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=46
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-2,Max=2),Z=(Min=-90,Max=68))
        StartSizeRange=(X=(Min=20,Max=32))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.85,Max=0.85)
        StartVelocityRange=(Z=(Min=9,Max=12))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.6)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1)
    End Object
    Emitters(9)=SpriteEmitter'V18BlueShaftVeil'

    Begin Object Class=SpriteEmitter Name=V19BlueSpiral10
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=220))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.2
        MaxParticles=8
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=18
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=13))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.4,Max=0.4)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(10)=SpriteEmitter'V19BlueSpiral10'

    Begin Object Class=SpriteEmitter Name=V19BlueSpiral11
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=220))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.2
        MaxParticles=8
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=18
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=13))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.4,Max=0.4)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(11)=SpriteEmitter'V19BlueSpiral11'

    Begin Object Class=SpriteEmitter Name=V20BlueShaftRings
        CoordinateSystem=PTCS_Relative
        Disabled=True // V37: all blue ring layers disabled; indices retained for Tick.
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=220))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.6050000000000001
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-85,Max=65))
        StartSizeRange=(X=(Min=13.5,Max=18))
        Texture=Texture'EffectTexture.effect001.circle0005a'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(Z=(Min=16,Max=16))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.35)
        SizeScale(1)=(RelativeTime=0.5,RelativeSize=0.8500000000000001)
        SizeScale(2)=(RelativeTime=1,RelativeSize=1.35)
    End Object
    Emitters(12)=SpriteEmitter'V20BlueShaftRings'

    Begin Object Class=SpriteEmitter Name=V36CounterRing13
        CoordinateSystem=PTCS_Relative
        Disabled=True // V37: all blue ring layers disabled; indices retained for Tick.
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.675
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=83,Max=83))
        StartSizeRange=(X=(Min=16.099999999999998,Max=23))
        Texture=Texture'EffectTexture.effect001.circle0005a'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=1.5)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.12,Max=0.12))
    End Object
    Emitters(13)=SpriteEmitter'V36CounterRing13'

    Begin Object Class=SpriteEmitter Name=V36CounterRing14
        CoordinateSystem=PTCS_Relative
        Disabled=True // V37: all blue ring layers disabled; indices retained for Tick.
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.675
        MaxParticles=0
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=88,Max=88))
        StartSizeRange=(X=(Min=22.4,Max=32))
        Texture=Texture'EffectTexture.effect001.circle0005a'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=1.5)
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=-0.08,Max=-0.08))
    End Object
    Emitters(14)=SpriteEmitter'V36CounterRing14'

    Begin Object Class=SpriteEmitter Name=V36BreathingHalo15
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.36000000000000004
        MaxParticles=3
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=4
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8.399999999999999,Max=12))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(15)=SpriteEmitter'V36BreathingHalo15'

    Begin Object Class=SpriteEmitter Name=V36BreathingHalo16
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.36000000000000004
        MaxParticles=3
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=4
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-91,Max=-91))
        StartSizeRange=(X=(Min=7,Max=10))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(16)=SpriteEmitter'V36BreathingHalo16'

    Begin Object Class=SpriteEmitter Name=V36ForkArc17
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.033
        FadeOutStartTime=0.099
        MaxParticles=4
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=15.399999999999999,Max=22))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.22,Max=0.22)
        SpinParticles=True
        StartSpinRange=(X=(Min=-0.3,Max=0.3))
    End Object
    Emitters(17)=SpriteEmitter'V36ForkArc17'

    Begin Object Class=SpriteEmitter Name=V36ForkArc18
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.033
        FadeOutStartTime=0.099
        MaxParticles=4
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=10.5,Max=15))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.22,Max=0.22)
        SpinParticles=True
        StartSpinRange=(X=(Min=-0.3,Max=0.3))
    End Object
    Emitters(18)=SpriteEmitter'V36ForkArc18'

    Begin Object Class=SpriteEmitter Name=V36GatheringStars
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.54
        MaxParticles=4
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=3
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=59,Max=64))
        StartSizeRange=(X=(Min=1.75,Max=2.5))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.2,Max=1.2)
        StartVelocityRange=(Z=(Min=17,Max=20))
    End Object
    Emitters(19)=SpriteEmitter'V36GatheringStars'

    Begin Object Class=SpriteEmitter Name=V39ShaftFrost
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=20
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.8
        MaxParticles=34
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-92,Max=83))
        StartSizeRange=(X=(Min=2.0999999999999996,Max=3))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.6,Max=1.6)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        StartVelocityRange=(X=(Min=-1,Max=1),Z=(Min=-4,Max=-2))
    End Object
    Emitters(20)=SpriteEmitter'V39ShaftFrost'

    Begin Object Class=SpriteEmitter Name=V39HeadFrost
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.7
        MaxParticles=12
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=75,Max=99))
        StartSizeRange=(X=(Min=3.5,Max=5))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.4,Max=1.4)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
        StartVelocityRange=(X=(Min=-3,Max=3),Y=(Min=-2,Max=2),Z=(Min=1,Max=3))
    End Object
    Emitters(21)=SpriteEmitter'V39HeadFrost'

    Begin Object Class=SpriteEmitter Name=V39TailFrost
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.5
        MaxParticles=8
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-96,Max=-88))
        StartSizeRange=(X=(Min=4.8999999999999995,Max=7))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1,Max=1)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(22)=SpriteEmitter'V39TailFrost'

    Begin Object Class=SpriteEmitter Name=V39FrostTailTrail
        CoordinateSystem=PTCS_Absolute
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=40
        UseColorScale=True
        ColorScale(0)=(Color=(R=235,G=245,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=50,G=125,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.225
        MaxParticles=24
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=4.8999999999999995,Max=7))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.45,Max=0.45)
        ColorMultiplierRange=(X=(Min=0.95,Max=0.95),Y=(Min=1,Max=1),Z=(Min=1.25,Max=1.25))
    End Object
    Emitters(23)=SpriteEmitter'V39FrostTailTrail'

    Begin Object Class=SpriteEmitter Name=V40TailSnow
        CoordinateSystem=PTCS_Absolute
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=9
        UseColorScale=True
        ColorScale(0)=(Color=(R=245,G=250,B=255,A=210))
        ColorScale(1)=(RelativeTime=0.65,Color=(R=155,G=205,B=255,A=140))
        ColorScale(2)=(RelativeTime=1,Color=(R=75,G=145,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.8
        MaxParticles=20
        UniformSize=True
        StartLocationRange=(X=(Min=-5,Max=5),Y=(Min=-5,Max=5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=1.2,Max=3))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.6,Max=2)
        StartVelocityRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-14,Max=-7))
        Acceleration=(Z=-2)
    End Object
    Emitters(24)=SpriteEmitter'V40TailSnow'

    bNoDelete=False
    bUnlit=True
    bDirectional=True
    RemoteRole=ROLE_None
}
