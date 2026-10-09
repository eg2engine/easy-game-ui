// 维护红法粒子动画，仅在所属武器 Link 允许时更新。
class Designed_AblazeStaffB_Particles extends Emitter;

// Continuous red-gold fire wraps the entire head; the charged core stays separate.
var float CycleTime;
var float CrownTime;
var vector LastTip;
var bool bTipReady;
var float MotionBlend;

var vector LastTail;
var vector LastTailOrigin;
var bool bTailReady;
var bool bTailTrailing;
var float TailMotion;
var float TailTime;

// Initial local calibration; adjust these centers after front/side client checks.
var vector HeadGlowCenter;
var vector HeadWrapCenter;
var float HeadSurfaceDepth;
var float WrapPhase;
var vector TailGlowCenter;
var vector TailWrapCenter;
var float TailSurfaceDepth;
var vector TailTrailCenter;

simulated function SyncGlowCenters()
{
    local vector HeadSide, TailSide;
    HeadSide.Y = HeadSurfaceDepth;
    TailSide.Y = TailSurfaceDepth;
    Emitters[7].StartLocationOffset = HeadGlowCenter;
    Emitters[17].StartLocationOffset = HeadGlowCenter;
    Emitters[20].StartLocationOffset = HeadWrapCenter;
    Emitters[8].StartLocationOffset = HeadWrapCenter + vect(0,0,-22);
    Emitters[9].StartLocationOffset = HeadWrapCenter + vect(-12,-2,-10);
    Emitters[13].StartLocationOffset = HeadWrapCenter + vect(-13,2,8);
    Emitters[14].StartLocationOffset = HeadWrapCenter + vect(0,0,20);
    Emitters[15].StartLocationOffset = HeadWrapCenter + vect(16,-2,10);
    Emitters[16].StartLocationOffset = HeadWrapCenter + vect(14,2,-8);
    Emitters[28].StartLocationOffset = HeadWrapCenter + vect(0,0,-18) + HeadSide;
    Emitters[29].StartLocationOffset = HeadWrapCenter + vect(0,0,-18) - HeadSide;
    Emitters[30].StartLocationOffset = HeadWrapCenter + vect(-10,0,6) + HeadSide;
    Emitters[31].StartLocationOffset = HeadWrapCenter + vect(-10,0,6) - HeadSide;
    Emitters[32].StartLocationOffset = HeadWrapCenter + vect(12,0,8) + HeadSide;
    Emitters[33].StartLocationOffset = HeadWrapCenter + vect(12,0,8) - HeadSide;
    Emitters[34].StartLocationOffset = HeadWrapCenter + vect(11,0,-6) + HeadSide;
    Emitters[35].StartLocationOffset = HeadWrapCenter + vect(11,0,-6) - HeadSide;
    Emitters[21].StartLocationOffset = TailWrapCenter;
    Emitters[22].StartLocationOffset = TailGlowCenter;
    Emitters[24].StartLocationOffset = TailGlowCenter;
    Emitters[26].StartLocationOffset = TailWrapCenter + vect(3,0,3) + TailSide;
    Emitters[27].StartLocationOffset = TailWrapCenter + vect(-2,0,-4) + TailSide;
    Emitters[36].StartLocationOffset = TailWrapCenter + vect(3,0,3) - TailSide;
    Emitters[37].StartLocationOffset = TailWrapCenter + vect(-2,0,-4) - TailSide;
}

simulated function SyncWrapFlow(float Surge)
{
    local vector P, Outward;
    local float Radius, SizeBoost, GoldBoost;
    Radius = 1.0 - 0.25 * Surge;
    P.X = Cos(WrapPhase) * 18 * Radius;
    P.Y = Sin(WrapPhase * 2) * 6 * Radius;
    P.Z = Sin(WrapPhase) * 24 * Radius;
    Outward = Normal(P) * 3;
    P += HeadWrapCenter;
    Emitters[10].StartLocationOffset = P;
    Emitters[11].StartLocationOffset = P;
    Emitters[12].StartLocationOffset = P;
    Emitters[25].StartLocationOffset = P;
    Emitters[25].StartVelocityRange.X.Min = Outward.X;
    Emitters[25].StartVelocityRange.X.Max = Outward.X;
    Emitters[25].StartVelocityRange.Y.Min = Outward.Y;
    Emitters[25].StartVelocityRange.Y.Max = Outward.Y;
    Emitters[25].StartVelocityRange.Z.Min = Outward.Z;
    Emitters[25].StartVelocityRange.Z.Max = Outward.Z;
    SizeBoost = 1.0 + 0.12 * Surge;
    Emitters[8].StartSizeRange.X.Min = 15.4 * SizeBoost;
    Emitters[8].StartSizeRange.X.Max = 19.8 * SizeBoost;
    Emitters[9].StartSizeRange.X.Min = 16.5 * SizeBoost;
    Emitters[9].StartSizeRange.X.Max = 22 * SizeBoost;
    Emitters[13].StartSizeRange.X.Min = 17.6 * SizeBoost;
    Emitters[13].StartSizeRange.X.Max = 24.2 * SizeBoost;
    Emitters[14].StartSizeRange.X.Min = 15.4 * SizeBoost;
    Emitters[14].StartSizeRange.X.Max = 22 * SizeBoost;
    Emitters[15].StartSizeRange.X.Min = 17.6 * SizeBoost;
    Emitters[15].StartSizeRange.X.Max = 24.2 * SizeBoost;
    Emitters[16].StartSizeRange.X.Min = 16.5 * SizeBoost;
    Emitters[16].StartSizeRange.X.Max = 22 * SizeBoost;
    GoldBoost = 1.0 + 0.2 * Surge;
    Emitters[10].ColorMultiplierRange.X.Min = GoldBoost;
    Emitters[10].ColorMultiplierRange.X.Max = GoldBoost;
    Emitters[10].ColorMultiplierRange.Y.Min = GoldBoost;
    Emitters[10].ColorMultiplierRange.Y.Max = GoldBoost;
    Emitters[10].ColorMultiplierRange.Z.Min = GoldBoost;
    Emitters[10].ColorMultiplierRange.Z.Max = GoldBoost;
    Emitters[12].InitialParticlesPerSecond = 4 + 6 * Surge;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    SyncGlowCenters();
    SyncWrapFlow(0);
}

// 每帧先检查所属对象的停止或生命周期状态，失效时不继续访问效果资源。
simulated event Tick(float DeltaTime)
{
    local vector TailLocal, TailWorld;
    local float TailSpeed, GlowPulse;
    local float TravelTime, Bloom, Pulse, Surge;
    local bool bBlooming;
    local vector P, Tip, TipVelocity;
    local float Speed, CoreGlow, HaloGlow, SurfaceGlow;
    local int I;
    local DesignedWeaponFxBase FxBase;
    if (bDeleteMe)
        return;
    FxBase = DesignedWeaponFxBase(Owner);
    if (FxBase == None || !FxBase.CanUpdateDetail())
        return;
    SyncGlowCenters();
    TravelTime = (63.0 - Emitters[0].StartLocationRange.Z.Min) / Emitters[0].StartVelocityRange.Z.Min;
    CycleTime = (CycleTime + DeltaTime) % 4.6;
    CrownTime += DeltaTime;
    bBlooming = CycleTime >= TravelTime + 1.1 && CycleTime < TravelTime + 1.7;
    // Orbit phase is independent of recharge; wrap at a full turn only.
    WrapPhase = (WrapPhase + DeltaTime * 2.243995) % 6.283185;
    Surge = 0;
    if (CycleTime >= TravelTime && CycleTime < TravelTime + 1.1)
    {
        Surge = Sin((CycleTime - TravelTime) / 1.1 * 3.141593);
        Surge = Surge * Surge;
    }
    SyncWrapFlow(Surge);
    Bloom = 0;
    if (bBlooming)
    {
        Bloom = Sin((CycleTime - TravelTime - 1.1) / 0.6 * 3.141593);
        // Zero slope at each end avoids a sharp change when recharge starts/stops.
        Bloom = Bloom * Bloom;
    }
    Pulse = 0.5 + 0.5 * Sin(CrownTime * 1.05);
    // Six-second breathing, with a stronger core and a steadier surrounding halo.
    CoreGlow = 0.94 + Pulse * 0.12 + Bloom * 0.08;
    HaloGlow = 0.97 + Pulse * 0.06 + Bloom * 0.04;
    Emitters[7].ColorMultiplierRange.X.Min = CoreGlow;
    Emitters[7].ColorMultiplierRange.X.Max = CoreGlow;
    Emitters[7].ColorMultiplierRange.Y.Min = CoreGlow;
    Emitters[7].ColorMultiplierRange.Y.Max = CoreGlow;
    Emitters[7].ColorMultiplierRange.Z.Min = CoreGlow;
    Emitters[7].ColorMultiplierRange.Z.Max = CoreGlow;
    // The broad, faint gold halo bridges the core and the contour anchors.
    Emitters[20].ColorMultiplierRange.X.Min = HaloGlow;
    Emitters[20].ColorMultiplierRange.X.Max = HaloGlow;
    Emitters[20].ColorMultiplierRange.Y.Min = HaloGlow;
    Emitters[20].ColorMultiplierRange.Y.Max = HaloGlow;
    Emitters[20].ColorMultiplierRange.Z.Min = HaloGlow;
    Emitters[20].ColorMultiplierRange.Z.Max = HaloGlow;
    SurfaceGlow = 0.96 + 0.08 * Pulse + 0.10 * Surge + 0.04 * Bloom;
    for (I = 28; I <= 35; I++)
    {
        Emitters[I].ColorMultiplierRange.X.Min = SurfaceGlow;
        Emitters[I].ColorMultiplierRange.X.Max = SurfaceGlow;
        Emitters[I].ColorMultiplierRange.Y.Min = SurfaceGlow;
        Emitters[I].ColorMultiplierRange.Y.Max = SurfaceGlow;
        Emitters[I].ColorMultiplierRange.Z.Min = SurfaceGlow;
        Emitters[I].ColorMultiplierRange.Z.Max = SurfaceGlow;
    }
    // Measure tip travel, including swings; clamp teleports and first-frame spikes.
    P = HeadGlowCenter;
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
    Emitters[18].ColorScale[0].Color.A = byte(35 + MotionBlend * 60);
    // Tail sparks and fire trails are emitted only during a clear swing.
    P = TailTrailCenter;
    P.Z += 2.5;
    Emitters[19].StartLocationOffset = P >> Rotation;
    TailTime += DeltaTime;
    GlowPulse = 1.0 + 0.04 * Sin(TailTime * 1.05);
    // Fixed relative light points, separate from the motion-only tail fire.
    for (I = 21; I <= 27; I++)
    {
        if (I == 23 || I == 25)
            continue;
        Emitters[I].ColorMultiplierRange.X.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.X.Max = GlowPulse;
        Emitters[I].ColorMultiplierRange.Y.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.Y.Max = GlowPulse;
        Emitters[I].ColorMultiplierRange.Z.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.Z.Max = GlowPulse;
    }
    for (I = 36; I <= 37; I++)
    {
        Emitters[I].ColorMultiplierRange.X.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.X.Max = GlowPulse;
        Emitters[I].ColorMultiplierRange.Y.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.Y.Max = GlowPulse;
        Emitters[I].ColorMultiplierRange.Z.Min = GlowPulse;
        Emitters[I].ColorMultiplierRange.Z.Max = GlowPulse;
    }
    TailLocal = TailTrailCenter;
    TailWorld = Location + (TailLocal >> Rotation);
    TailSpeed = 0;
    if (bTailReady && DeltaTime > 0.001 && VSize(TailWorld - LastTail) < 180)
        // Remove translation: walking alone must not light the tail flame.
        TailSpeed = FMin(VSize((TailWorld - LastTail) - (Location - LastTailOrigin)) / DeltaTime / 420.0, 1.0);
    LastTail = TailWorld;
    LastTailOrigin = Location;
    bTailReady = True;
    TailMotion += (TailSpeed - TailMotion) * FMin(DeltaTime * 7, 1.0);
    // Hysteresis avoids flickering near the idle/swing threshold.
    if (bTailTrailing)
        bTailTrailing = TailMotion > 0.18 && TailSpeed > 0.08;
    else
        bTailTrailing = TailMotion >= 0.35 && TailSpeed >= 0.35;
    Emitters[19].Disabled = !bTailTrailing;
    Emitters[23].Disabled = !bTailTrailing;
    Emitters[23].StartLocationOffset = TailLocal >> Rotation;
    Emitters[23].LifetimeRange.Min = 0.12 + TailMotion * 0.3;
    Emitters[23].LifetimeRange.Max = 0.18 + TailMotion * 0.4;
    Emitters[23].ColorScale[0].Color.A = byte(55 + TailMotion * 130);
}

defaultproperties
{
    HeadGlowCenter=(X=4,Y=2,Z=73)
    HeadWrapCenter=(X=5,Y=2,Z=78)
    HeadSurfaceDepth=4
    WrapPhase=-1.570796
    TailGlowCenter=(X=3,Y=2,Z=-99)
    TailWrapCenter=(X=3,Y=2,Z=-103)
    TailSurfaceDepth=3
    TailTrailCenter=(X=3,Y=2,Z=-96.5)
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
        FadeOutStartTime=1.8
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
        LifetimeRange=(Min=2.15,Max=2.15)
        StartVelocityRange=(Z=(Min=80,Max=80))
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
        StartLocationRange=(X=(Min=-3,Max=3),Y=(Min=-3,Max=3),Z=(Min=16,Max=54))
        StartSizeRange=(X=(Min=16,Max=23))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(Z=(Min=12,Max=16))
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
        FadeOutStartTime=1.8
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
        LifetimeRange=(Min=2.15,Max=2.15)
        StartVelocityRange=(Z=(Min=80,Max=80))
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
        FadeOutStartTime=1.8
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
        LifetimeRange=(Min=2.15,Max=2.15)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.7)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.15)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=-99,Max=-99))
        StartVelocityRange=(Z=(Min=80,Max=80))
    End Object
    Emitters(6)=SpriteEmitter'V25SoftGold'

    Begin Object Class=SpriteEmitter Name=HeadChargedCore
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=175,B=65,A=0))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=255,G=175,B=65,A=95))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=255,G=175,B=65,A=95))
        ColorScale(3)=(RelativeTime=1,Color=(R=255,G=175,B=65,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=10
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=20,Max=25.6))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(7)=SpriteEmitter'HeadChargedCore'

    Begin Object Class=SpriteEmitter Name=HeadWrapRoot
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=90,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=90,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=15.4,Max=19.8))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=-3.000000,Max=-3.000000))
    End Object
    Emitters(8)=SpriteEmitter'HeadWrapRoot'

    Begin Object Class=SpriteEmitter Name=HeadWrapLeftLower
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=105,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=105,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=16.5,Max=22))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=-2.286002,Max=-2.286002),Y=(Min=-0.381000,Max=-0.381000),Z=(Min=-1.905002,Max=-1.905002))
    End Object
    Emitters(9)=SpriteEmitter'HeadWrapLeftLower'

    // Continuous gold flow wraps the full head, including front/back depth.
    Begin Object Class=SpriteEmitter Name=HeadWrapOrbitGold
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=36
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=180,B=60,A=145))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=180,B=60,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.03
        FadeOutStartTime=0.16
        MaxParticles=18
        UniformSize=True
        StartLocationOffset=(X=3,Y=2,Z=58)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=6,Max=9))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.4,Max=0.5)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(10)=SpriteEmitter'HeadWrapOrbitGold'

    // Orange fire fragments connect the orbit to the six surrounding flame regions.
    Begin Object Class=SpriteEmitter Name=HeadWrapOrbitFire
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=14
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=100,B=25,A=100))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=100,B=25,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.03
        FadeOutStartTime=0.12
        MaxParticles=8
        UniformSize=True
        StartLocationOffset=(X=3,Y=2,Z=58)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=9,Max=13))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.45,Max=0.55)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(11)=SpriteEmitter'HeadWrapOrbitFire'

    Begin Object Class=SpriteEmitter Name=HeadWrapArcs
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=4
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
        StartLocationRange=(X=(Min=-5,Max=5),Y=(Min=-1,Max=1),Z=(Min=-4,Max=4))
        StartSizeRange=(X=(Min=5,Max=8))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.35,Max=0.35)
        StartVelocityRange=(Z=(Min=0,Max=0))
    End Object
    Emitters(12)=SpriteEmitter'HeadWrapArcs'

    Begin Object Class=SpriteEmitter Name=HeadWrapLeftUpper
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=155,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=155,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=17.6,Max=24.2))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=-2.533322,Max=-2.533322),Y=(Min=0.389742,Max=0.389742),Z=(Min=1.558968,Max=1.558968))
    End Object
    Emitters(13)=SpriteEmitter'HeadWrapLeftUpper'

    Begin Object Class=SpriteEmitter Name=HeadWrapTop
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=165,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=165,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=15.4,Max=22))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=3.000000,Max=3.000000))
    End Object
    Emitters(14)=SpriteEmitter'HeadWrapTop'

    Begin Object Class=SpriteEmitter Name=HeadWrapRightUpper
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=155,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=155,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=17.6,Max=24.2))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=2.529822,Max=2.529822),Y=(Min=-0.316228,Max=-0.316228),Z=(Min=1.581139,Max=1.581139))
    End Object
    Emitters(15)=SpriteEmitter'HeadWrapRightUpper'

    Begin Object Class=SpriteEmitter Name=HeadWrapRightLower
        CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        UseRotationFrom=PTRS_Offset
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=16
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=105,B=25,A=115))
        ColorScale(1)=(RelativeTime=1,Color=(R=255,G=105,B=25,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=0.9,Max=0.9),Z=(Min=0.5,Max=0.5))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.08
        FadeOutStartTime=0.4
        MaxParticles=12
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-1.5,Max=1.5),Z=(Min=-2,Max=2))
        StartSizeRange=(X=(Min=16.5,Max=22))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.7,Max=0.7)
        StartVelocityRange=(X=(Min=2.584921,Max=2.584921),Y=(Min=0.369274,Max=0.369274),Z=(Min=-1.477098,Max=-1.477098))
    End Object
    Emitters(16)=SpriteEmitter'HeadWrapRightLower'

    Begin Object Class=SpriteEmitter Name=HeadChargedGlint
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=230,B=160,A=0))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=255,G=230,B=160,A=70))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=255,G=230,B=160,A=70))
        ColorScale(3)=(RelativeTime=1,Color=(R=255,G=230,B=160,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=6
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=4.2,Max=6))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(17)=SpriteEmitter'HeadChargedGlint'

    Begin Object Class=SpriteEmitter Name=V36MotionAfterglow
        CoordinateSystem=PTCS_Absolute
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=115,B=30,A=35))
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
        StartSizeRange=(X=(Min=5,Max=8))
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
        Disabled=True
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

    Begin Object Class=SpriteEmitter Name=HeadSoftGoldHalo
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=28,G=17,B=5,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=28,G=17,B=5,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=6
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=32,Max=38))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(20)=SpriteEmitter'HeadSoftGoldHalo'

    Begin Object Class=SpriteEmitter Name=TailRedOrangeHalo
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=90,B=35,A=0))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=255,G=90,B=35,A=42))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=255,G=90,B=35,A=42))
        ColorScale(3)=(RelativeTime=1,Color=(R=255,G=90,B=35,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=6
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=16,Max=20))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(21)=SpriteEmitter'TailRedOrangeHalo'

    Begin Object Class=SpriteEmitter Name=TailChargedPoint
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=7
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=185,B=70,A=0))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=255,G=185,B=70,A=100))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=255,G=185,B=70,A=100))
        ColorScale(3)=(RelativeTime=1,Color=(R=255,G=185,B=70,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=9
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=7.5,Max=9.6))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(22)=SpriteEmitter'TailChargedPoint'

    Begin Object Class=SpriteEmitter Name=V39FireTailTrail
        CoordinateSystem=PTCS_Absolute
        Disabled=True
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
        StartSizeRange=(X=(Min=6,Max=10))
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

    // Small gold-white heart shares the tail point center and breathing.
    Begin Object Class=SpriteEmitter Name=TailChargedGlint
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=230,B=160,A=0))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=255,G=230,B=160,A=70))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=255,G=230,B=160,A=70))
        ColorScale(3)=(RelativeTime=1,Color=(R=255,G=230,B=160,A=0))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        FadeInEndTime=0.15
        FadeOutStartTime=0.8
        MaxParticles=6
        UniformSize=True
        StartLocationOffset=(X=0,Y=0,Z=0)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=2.2,Max=3.2))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.1,Max=1.1)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
    End Object
    Emitters(24)=SpriteEmitter'TailChargedGlint'

    Begin Object Class=SpriteEmitter Name=HeadWrapGoldSparks
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        MaxParticles=8
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=200,B=70,A=0))
        ColorScale(1)=(RelativeTime=0.1,Color=(R=255,G=200,B=70,A=160))
        ColorScale(2)=(RelativeTime=1,Color=(R=255,G=125,B=35,A=0))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=3,Y=2,Z=58)
        StartLocationRange=(X=(Min=-1,Max=1),Y=(Min=-1,Max=1),Z=(Min=-1,Max=1))
        StartSizeRange=(X=(Min=1.5,Max=2.5))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Additive
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=-3,Max=-3))
    End Object
    Emitters(25)=SpriteEmitter'HeadWrapGoldSparks'

    // Gold edge points bridge the charged tail heart to the lower metal hook.
    Begin Object Class=SpriteEmitter Name=TailUpperEdgeGold
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0,Max=0)
        MaxParticles=4
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=50,G=30,B=9,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=50,G=30,B=9,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=6,Y=5,Z=-100)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=6,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(26)=SpriteEmitter'TailUpperEdgeGold'

    Begin Object Class=SpriteEmitter Name=TailLowerEdgeGold
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.2,Max=0.2)
        MaxParticles=4
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=50,G=30,B=9,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=50,G=30,B=9,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=1,Y=5,Z=-107)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=6,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(27)=SpriteEmitter'TailLowerEdgeGold'

    // Paired, depth-tested soft gold points bridge the fire to both sides of the metal.
    Begin Object Class=SpriteEmitter Name=HeadSurfaceRootFront
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0,Max=0)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=5,Y=6,Z=60)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=False
        ZWrite=False
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(28)=SpriteEmitter'HeadSurfaceRootFront'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceRootBack
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.075,Max=0.075)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=5,Y=-2,Z=60)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(29)=SpriteEmitter'HeadSurfaceRootBack'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceLeftUpperFront
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.15,Max=0.15)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=-5,Y=6,Z=84)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=False
        ZWrite=False
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(30)=SpriteEmitter'HeadSurfaceLeftUpperFront'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceLeftUpperBack
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.225,Max=0.225)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=-5,Y=-2,Z=84)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(31)=SpriteEmitter'HeadSurfaceLeftUpperBack'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceRightUpperFront
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.3,Max=0.3)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=17,Y=6,Z=86)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=False
        ZWrite=False
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(32)=SpriteEmitter'HeadSurfaceRightUpperFront'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceRightUpperBack
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.375,Max=0.375)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=17,Y=-2,Z=86)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(33)=SpriteEmitter'HeadSurfaceRightUpperBack'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceRightLowerFront
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.45,Max=0.45)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=16,Y=6,Z=72)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=False
        ZWrite=False
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(34)=SpriteEmitter'HeadSurfaceRightLowerFront'

    Begin Object Class=SpriteEmitter Name=HeadSurfaceRightLowerBack
        CoordinateSystem=PTCS_Relative
        Disabled=True
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.525,Max=0.525)
        MaxParticles=3
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=35,G=21,B=6,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=35,G=21,B=6,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=16,Y=-2,Z=72)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=8,Max=11))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.6,Max=0.6)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(35)=SpriteEmitter'HeadSurfaceRightLowerBack'

    Begin Object Class=SpriteEmitter Name=TailUpperEdgeGoldBack
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.1,Max=0.1)
        MaxParticles=4
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=50,G=30,B=9,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=50,G=30,B=9,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=6,Y=-1,Z=-100)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=6,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(36)=SpriteEmitter'TailUpperEdgeGoldBack'

    Begin Object Class=SpriteEmitter Name=TailLowerEdgeGoldBack
        CoordinateSystem=PTCS_Relative
        Disabled=False
        RespawnDeadParticles=True
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5
        InitialDelayRange=(Min=0.3,Max=0.3)
        MaxParticles=4
        UseColorScale=True
        ColorScale(0)=(Color=(R=0,G=0,B=0,A=255))
        ColorScale(1)=(RelativeTime=0.2,Color=(R=50,G=30,B=9,A=255))
        ColorScale(2)=(RelativeTime=0.7,Color=(R=50,G=30,B=9,A=255))
        ColorScale(3)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=255))
        ColorMultiplierRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        FadeIn=False
        FadeOut=False
        UniformSize=True
        StartLocationOffset=(X=1,Y=-1,Z=-107)
        StartLocationRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        StartSizeRange=(X=(Min=6,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        DrawStyle=PTDS_Translucent
        ZTest=True
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.8,Max=0.8)
        StartVelocityRange=(X=(Min=0,Max=0),Y=(Min=0,Max=0),Z=(Min=0,Max=0))
        Acceleration=(X=0,Y=0,Z=0)
    End Object
    Emitters(37)=SpriteEmitter'TailLowerEdgeGoldBack'

    bNoDelete=False
    bUnlit=True
    bDirectional=True
    RemoteRole=ROLE_None
}
