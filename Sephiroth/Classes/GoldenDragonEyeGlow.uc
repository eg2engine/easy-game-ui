class GoldenDragonEyeGlow extends Emitter;
simulated function SyncGlow(vector P, float Scale, float Pulse)
{
    local int I;
    SetLocation(P);
    for (I=0; I<Emitters.Length; I++)
    {
        Emitters[I].ColorMultiplierRange.X.Min=Pulse;
        Emitters[I].ColorMultiplierRange.X.Max=Pulse;
        Emitters[I].ColorMultiplierRange.Y.Min=Pulse;
        Emitters[I].ColorMultiplierRange.Y.Max=Pulse;
        Emitters[I].ColorMultiplierRange.Z.Min=Pulse;
        Emitters[I].ColorMultiplierRange.Z.Max=Pulse;
        if (I==0) Emitters[I].StartSizeRange.X.Min=0.8*Scale;
        else Emitters[I].StartSizeRange.X.Min=0.20*Scale;
        Emitters[I].StartSizeRange.X.Max=Emitters[I].StartSizeRange.X.Min;
    }
}
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=EyeGoldHalo
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=64,G=36,B=3,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=64,G=36,B=3,A=255))
        UniformSize=True
        MaxParticles=1
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=20
        StartSizeRange=(X=(Min=0.8,Max=0.8))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.3,Max=0.3)
        SecondsBeforeInactive=0
    End Object
    Emitters(0)=SpriteEmitter'EyeGoldHalo'
    Begin Object Class=SpriteEmitter Name=EyeWetGlint
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=130,G=106,B=48,A=255))
        ColorScale(1)=(RelativeTime=1,Color=(R=130,G=106,B=48,A=255))
        UniformSize=True
        MaxParticles=1
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=20
        StartSizeRange=(X=(Min=0.2,Max=0.2))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.3,Max=0.3)
        SecondsBeforeInactive=0
    End Object
    Emitters(1)=SpriteEmitter'EyeWetGlint'
    RemoteRole=ROLE_None
    bHidden=False
    bUnlit=True
    bNoDelete=False
    bCollideActors=False
    AutoDestroy=False
}
