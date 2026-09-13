class Designed_AblazeStaffB_Particles extends Emitter;

// V34: preserve shaft emitters verbatim; rebuild the head as a unified molten crown.
var float CycleTime;
var float CrownTime;
var vector LastTip;
var bool bTipReady;
var float MotionBlend;

var vector LastTail;
var bool bTailReady;
var float TailMotion;
var float TailTime;

simulated event Tick(float DeltaTime)
{
    local vector TailLocal, TailWorld;
    local float TailSpeed, GlowPulse;
    local float TravelTime, Bloom, Pulse;
    local vector P, Tip, TipVelocity;
    local float Speed;
    TravelTime = (79.0 - Emitters[0].StartLocationRange.Z.Min) / Emitters[0].StartVelocityRange.Z.Min;
    CycleTime = (CycleTime + DeltaTime) % (TravelTime + 2.4);
    CrownTime += DeltaTime;
    Bloom = 0;
    if (CycleTime >= TravelTime && CycleTime < TravelTime + 1.8)
        Bloom = Sin((CycleTime - TravelTime) / 1.8 * 3.141593);
    Pulse = 0.5 + 0.5 * Sin(CrownTime * 1.4);
    Emitters[7].ColorMultiplierRange.X.Min = 0.65 + Pulse * 0.15 + Bloom * 0.2;
    Emitters[7].ColorMultiplierRange.X.Max = 0.65 + Pulse * 0.15 + Bloom * 0.2;
    // V38: continuous crown; burst changes its size and arc intensity only.
    Emitters[8].StartSizeRange.X.Min = 22 + Bloom * 5;
    Emitters[8].StartSizeRange.X.Max = 32 + Bloom * 8;
    Emitters[9].StartSizeRange.X.Min = 25 + Bloom * 5;
    Emitters[9].StartSizeRange.X.Max = 37 + Bloom * 8;
    Emitters[12].Disabled = False;
    Emitters[12].InitialParticlesPerSecond = 8 + Bloom * 10;
    // Measure tip travel, including swings; clamp teleports and first-frame spikes.
    P.X = 0; P.Y = 0; P.Z = 79;
    Tip = Location + (P >> Rotation);
    Speed = 0;
    TipVelocity.X = 0; TipVelocity.Y = 0; TipVelocity.Z = 0;
    if (bTipReady && DeltaTime > 0.001 && VSize(Tip - LastTip) < 180)
    {
        TipVelocity = (Tip - LastTip) / DeltaTime;
        Speed = FMin(VSize(TipVelocity) / 450.0, 1.0);
    }
    LastTip = Tip;
    bTipReady = True;
    MotionBlend += (Speed - MotionBlend) * FMin(DeltaTime * 6, 1.0);
    Emitters[18].StartLocationOffset = P >> Rotation;
    Emitters[18].LifetimeRange.Min = 0.12 + MotionBlend * 0.28;
    Emitters[18].LifetimeRange.Max = 0.16 + MotionBlend * 0.32;
    Emitters[18].ColorScale[0].Color.A = byte(65 + MotionBlend * 100);
    // World-space tail embers drift independently after spawning.
    P.Z = -96;
    Emitters[19].StartLocationOffset = P >> Rotation;
    TailTime += DeltaTime;
    GlowPulse = 0.5 + 0.5 * Sin(TailTime * 1.5);
    Emitters[20].ColorMultiplierRange.Z.Min = 1.1 + GlowPulse * 0.5;
    Emitters[20].ColorMultiplierRange.Z.Max = 1.1 + GlowPulse * 0.5;
    Emitters[21].ColorMultiplierRange.X.Min = 0.8 + GlowPulse * 0.4;
    Emitters[21].ColorMultiplierRange.X.Max = 0.8 + GlowPulse * 0.4;
    TailLocal.X = 0; TailLocal.Y = 0; TailLocal.Z = -99;
    TailWorld = Location + (TailLocal >> Rotation);
    TailSpeed = 0;
    if (bTailReady && DeltaTime > 0.001 && VSize(TailWorld - LastTail) < 180)
        TailSpeed = FMin(VSize(TailWorld - LastTail) / DeltaTime / 420.0, 1.0);
    LastTail = TailWorld;
    bTailReady = True;
    TailMotion += (TailSpeed - TailMotion) * FMin(DeltaTime * 7, 1.0);
    Emitters[23].StartLocationOffset = TailLocal >> Rotation;
    Emitters[23].LifetimeRange.Min = 0.12 + TailMotion * 0.3;
    Emitters[23].LifetimeRange.Max = 0.18 + TailMotion * 0.4;
    Emitters[23].ColorScale[0].Color.A = byte(55 + TailMotion * 130);
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=V23Ascent
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        SpinParticles=False
        Disabled=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=55,B=20,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=55,B=20,A=0))
        ColorMultiplierRange=(X=(Min=1.8,Max=1.8),Y=(Min=1.1,Max=1.1),Z=(Min=0.35,Max=0.35))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=3.8
        MaxParticles=132
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=32
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-99,Max=-99))
        StartSizeRange=(X=(Min=11,Max=20))
        Texture=Texture'EffectEnvTextureD.A.fire_long'
        TextureUSubdivisions=5
        TextureVSubdivisions=5
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=4.1,Max=4.1)
        StartVelocityRange=(Z=(Min=47,Max=47))
    End Object
    Emitters(0)=SpriteEmitter'V23Ascent'

    Begin Object Class=SpriteEmitter Name=V23Embers
        CoordinateSystem=PTCS_Relative
        Disabled=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=145,B=35,A=230))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=145,B=35,A=0))
        ColorMultiplierRange=(X=(Min=1.8,Max=1.8),Y=(Min=1.1,Max=1.1),Z=(Min=0.35,Max=0.35))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.05
        FadeOutStartTime=0.8250000000000001
        MaxParticles=16
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=7
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-95,Max=76))
        StartSizeRange=(X=(Min=1.4,Max=2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=1.5)
        StartVelocityRange=(Z=(Min=12,Max=18))
    End Object
    Emitters(1)=SpriteEmitter'V23Embers'

    Begin Object Class=SpriteEmitter Name=V24LowerMantle
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        SpinParticles=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=55,B=20,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=55,B=20,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.6
        MaxParticles=24
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=24
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-99,Max=-43))
        StartSizeRange=(X=(Min=11.50,Max=18.40))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(Z=(Min=16,Max=22))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.75)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.1)
    End Object
    Emitters(2)=SpriteEmitter'V24LowerMantle'

    Begin Object Class=SpriteEmitter Name=V24MiddleMantle
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        SpinParticles=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=75,B=25,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=75,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.6
        MaxParticles=29
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=29
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-43,Max=16))
        StartSizeRange=(X=(Min=16.10,Max=26.45))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(Z=(Min=16,Max=22))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.75)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.1)
    End Object
    Emitters(3)=SpriteEmitter'V24MiddleMantle'

    Begin Object Class=SpriteEmitter Name=V24UpperMantle
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        SpinParticles=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=100,B=30,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=100,B=30,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.6
        MaxParticles=32
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=32
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=16,Max=72))
        StartSizeRange=(X=(Min=23.00,Max=34.50))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(Z=(Min=16,Max=22))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.75)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.1)
    End Object
    Emitters(4)=SpriteEmitter'V24UpperMantle'

    Begin Object Class=SpriteEmitter Name=V24GoldenCurrent
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        SpinParticles=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=155,B=45,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=155,B=45,A=0))
        ColorMultiplierRange=(X=(Min=1.4,Max=1.4),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=3.8
        MaxParticles=30
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=7
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-99,Max=-96))
        StartSizeRange=(X=(Min=14,Max=23))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=4.1,Max=4.1)
        StartVelocityRange=(Z=(Min=47,Max=47))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.3)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.45)
    End Object
    Emitters(5)=SpriteEmitter'V24GoldenCurrent'

    Begin Object Class=SpriteEmitter Name=V25SoftGold
        CoordinateSystem=PTCS_Relative
        Disabled=False
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=155,B=45,A=130))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=155,B=45,A=0))
        ColorMultiplierRange=(X=(Min=1.2,Max=1.2),Y=(Min=0.9,Max=0.9),Z=(Min=0.35,Max=0.35))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=3.8
        MaxParticles=124
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=30
        UniformSize=True
        StartLocationOffset=(Z=0)
        StartSizeRange=(X=(Min=7,Max=12))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=4.1,Max=4.1)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.7)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.15)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=-99,Max=-99))
        StartVelocityRange=(Z=(Min=47,Max=47))
    End Object
    Emitters(6)=SpriteEmitter'V25SoftGold'

    Begin Object Class=SpriteEmitter Name=V34MoltenHeart
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=4
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=195,B=90,A=130))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=195,B=90,A=0))
        ColorMultiplierRange=(X=(Min=0.65,Max=0.65),Y=(Min=0.65,Max=0.65),Z=(Min=0.7,Max=0.7))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.48
        MaxParticles=3
        UniformSize=True
        StartLocationRange=(X=(Min=-0,Max=0),Y=(Min=-2,Max=2),Z=(Min=77,Max=81))
        StartSizeRange=(X=(Min=10,Max=15))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(7)=SpriteEmitter'V34MoltenHeart'

    Begin Object Class=SpriteEmitter Name=V34RedBed
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=40
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=105,B=30,A=150))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=105,B=30,A=0))
        ColorMultiplierRange=(X=(Min=1.35,Max=1.35),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.42
        MaxParticles=30
        UniformSize=True
        StartLocationRange=(X=(Min=-12,Max=12),Y=(Min=-5,Max=5),Z=(Min=65,Max=99))
        StartSizeRange=(X=(Min=18,Max=24))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(Z=(Min=3,Max=5))
    End Object
    Emitters(8)=SpriteEmitter'V34RedBed'

    Begin Object Class=SpriteEmitter Name=V34LeftCrown
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=24
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=155,B=45,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=155,B=45,A=0))
        ColorMultiplierRange=(X=(Min=1.35,Max=1.35),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.44999999999999996
        MaxParticles=18
        UniformSize=True
        StartLocationRange=(X=(Min=-12,Max=12),Y=(Min=-5,Max=5),Z=(Min=65,Max=99))
        StartSizeRange=(X=(Min=19.5,Max=26))
        Texture=Texture'EffectEnvTextureD.A.fire_long'
        TextureUSubdivisions=5
        TextureVSubdivisions=5
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.75,Max=0.75)
        StartVelocityRange=(Z=(Min=3,Max=5))
    End Object
    Emitters(9)=SpriteEmitter'V34LeftCrown'

    Begin Object Class=SpriteEmitter Name=V34HighCrown
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=140,B=35,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=140,B=35,A=0))
        ColorMultiplierRange=(X=(Min=1.35,Max=1.35),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.44999999999999996
        MaxParticles=0
        UniformSize=True
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=19.5,Max=26))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.75,Max=0.75)
        StartVelocityRange=(Z=(Min=3,Max=5))
    End Object
    Emitters(10)=SpriteEmitter'V34HighCrown'

    Begin Object Class=SpriteEmitter Name=V34RightCrown
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=90,B=25,A=190))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.35,Max=1.35),Y=(Min=0.95,Max=0.95),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.14
        FadeOutStartTime=0.44999999999999996
        MaxParticles=0
        UniformSize=True
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=19.5,Max=26))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.75,Max=0.75)
        StartVelocityRange=(Z=(Min=3,Max=5))
    End Object
    Emitters(11)=SpriteEmitter'V34RightCrown'

    Begin Object Class=SpriteEmitter Name=V34BurstArcs
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=12
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=205,B=45,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=205,B=45,A=0))
        ColorMultiplierRange=(X=(Min=0.75,Max=0.75),Y=(Min=0.65,Max=0.65),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.21
        MaxParticles=5
        UniformSize=True
        StartLocationRange=(X=(Min=-9,Max=9),Y=(Min=-2,Max=2),Z=(Min=68,Max=94))
        StartSizeRange=(X=(Min=23.25,Max=31))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.35,Max=0.35)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(12)=SpriteEmitter'V34BurstArcs'

    Begin Object Class=SpriteEmitter Name=V34BurstGold
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=160,B=35,A=130))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=160,B=35,A=0))
        ColorMultiplierRange=(X=(Min=0.75,Max=0.75),Y=(Min=0.65,Max=0.65),Z=(Min=0.3,Max=0.3))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.36
        MaxParticles=0
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-2,Max=2),Z=(Min=77,Max=81))
        StartSizeRange=(X=(Min=18.75,Max=25))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(13)=SpriteEmitter'V34BurstGold'

    Begin Object Class=SpriteEmitter Name=V35Violet14
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=80,B=25,A=85))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=80,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.2,Max=1.2),Y=(Min=0.7,Max=0.7),Z=(Min=0.25,Max=0.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.6
        MaxParticles=0
        UniformSize=True
        StartLocationOffset=(Z=84)
        StartLocationRange=(X=(Min=-8,Max=8),Y=(Min=-2,Max=2),Z=(Min=-7,Max=7))
        StartSizeRange=(X=(Min=26,Max=36))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
    End Object
    Emitters(14)=SpriteEmitter'V35Violet14'

    Begin Object Class=SpriteEmitter Name=V35Violet15
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=80,B=25,A=195))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=80,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.2,Max=1.2),Y=(Min=0.7,Max=0.7),Z=(Min=0.25,Max=0.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.3
        MaxParticles=0
        UniformSize=True
        StartLocationOffset=(Z=79)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-2,Max=2),Z=(Min=-1,Max=1))
        StartSizeRange=(X=(Min=7,Max=12))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.55,Max=0.55)
    End Object
    Emitters(15)=SpriteEmitter'V35Violet15'

    Begin Object Class=SpriteEmitter Name=V35Violet16
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=80,B=25,A=195))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=80,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.2,Max=1.2),Y=(Min=0.7,Max=0.7),Z=(Min=0.25,Max=0.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.3
        MaxParticles=0
        UniformSize=True
        StartLocationOffset=(Z=79)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-2,Max=2),Z=(Min=-1,Max=1))
        StartSizeRange=(X=(Min=7,Max=12))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.55,Max=0.55)
    End Object
    Emitters(16)=SpriteEmitter'V35Violet16'

    Begin Object Class=SpriteEmitter Name=V35Violet17
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=80,B=25,A=195))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=80,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1.2,Max=1.2),Y=(Min=0.7,Max=0.7),Z=(Min=0.25,Max=0.25))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.10
        FadeOutStartTime=0.3
        MaxParticles=0
        UniformSize=True
        StartLocationOffset=(Z=79)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-2,Max=2),Z=(Min=-1,Max=1))
        StartSizeRange=(X=(Min=7,Max=12))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.55,Max=0.55)
    End Object
    Emitters(17)=SpriteEmitter'V35Violet17'

    Begin Object Class=SpriteEmitter Name=V36MotionAfterglow
        CoordinateSystem=PTCS_Absolute
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=115,B=30,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=115,B=30,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.0525
        FadeOutStartTime=0.1575
        MaxParticles=20
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=36
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=11.2,Max=16))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.35,Max=0.35)

    End Object
    Emitters(18)=SpriteEmitter'V36MotionAfterglow'

    Begin Object Class=SpriteEmitter Name=V36TailEmbers
        CoordinateSystem=PTCS_Absolute
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=135,B=25,A=160))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=135,B=25,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.12
        FadeOutStartTime=0.675
        MaxParticles=10
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UniformSize=True
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=1.4,Max=2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=1.5)
        StartVelocityRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-5,Max=-2))
    End Object
    Emitters(19)=SpriteEmitter'V36TailEmbers'

    Begin Object Class=SpriteEmitter Name=V39PurpleHead
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=6
        UseColorScale=True
        ColorScale(0)=(Color=(R=150,G=35,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=150,G=35,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=5
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=73,Max=90))
        StartSizeRange=(X=(Min=16.799999999999997,Max=24))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.2,Max=0.2),Z=(Min=1.5,Max=1.5))
    End Object
    Emitters(20)=SpriteEmitter'V39PurpleHead'

    Begin Object Class=SpriteEmitter Name=V39PurpleTail
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UseColorScale=True
        ColorScale(0)=(Color=(R=150,G=35,B=255,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=150,G=35,B=255,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.35
        MaxParticles=4
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-101,Max=-95))
        StartSizeRange=(X=(Min=9.1,Max=13))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.2,Max=0.2),Z=(Min=1.5,Max=1.5))
    End Object
    Emitters(21)=SpriteEmitter'V39PurpleTail'

    Begin Object Class=SpriteEmitter Name=V39TailFlame
        CoordinateSystem=PTCS_Relative
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=10
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=105,B=30,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=105,B=30,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.28
        MaxParticles=7
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=-101,Max=-97))
        StartSizeRange=(X=(Min=17,Max=24))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.5,Max=0.7)
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        StartVelocityRange=(Z=(Min=4,Max=7))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.35)
        SizeScale(1)=(RelativeTime=0.3,RelativeSize=1.15)
        SizeScale(2)=(RelativeTime=1,RelativeSize=0.5)
    End Object
    Emitters(22)=SpriteEmitter'V39TailFlame'

    Begin Object Class=SpriteEmitter Name=V39FireTailTrail
        CoordinateSystem=PTCS_Absolute
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=40
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=95,B=30,A=180))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=95,B=30,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.225
        MaxParticles=24
        UniformSize=True
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=10,Max=18))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.45,Max=0.45)

        StartVelocityRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-8,Max=-3))
        Acceleration=(Z=-18)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.7)
        SizeScale(1)=(RelativeTime=0.25,RelativeSize=1.1)
        SizeScale(2)=(RelativeTime=1,RelativeSize=0.2)
    End Object
    Emitters(23)=SpriteEmitter'V39FireTailTrail'

    bNoDelete=False
    bUnlit=True
    bDirectional=True
    RemoteRole=ROLE_None
}
