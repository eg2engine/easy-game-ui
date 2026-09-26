class GoldenDragonPawBurst extends Emitter;

simulated function Pulse()
{
    if (Emitters.Length<2) return;
    Emitters[0].SpawnParticle(3);
    Emitters[1].SpawnParticle(2);
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=PawBurstCore
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=210,B=95,A=255))
        ColorScale(1)=(RelativeTime=0.35,Color=(R=255,G=135,B=20,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeInEndTime=0.025
        FadeOut=True
        FadeOutStartTime=0.12
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        MaxParticles=8
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-2,Max=0))
        StartSizeRange=(X=(Min=10,Max=15))
        Texture=Texture'EffectEnvTextureD.A.fire_sq001_k'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.22,Max=0.28)
        StartVelocityRange=(X=(Min=-8,Max=8),Y=(Min=-8,Max=8),Z=(Min=10,Max=20))
        SecondsBeforeInactive=0
    End Object
    Emitters(0)=SpriteEmitter'PawBurstCore'
    Begin Object Class=SpriteEmitter Name=PawBurstOuter
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=210,B=95,A=255))
        ColorScale(1)=(RelativeTime=0.35,Color=(R=255,G=135,B=20,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeInEndTime=0.025
        FadeOut=True
        FadeOutStartTime=0.12
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        MaxParticles=6
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=0
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-2,Max=0))
        StartSizeRange=(X=(Min=21,Max=30))
        Texture=Texture'EffectEnvTextureD.A.fire_long'
        TextureUSubdivisions=5
        TextureVSubdivisions=5
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.26,Max=0.32)
        StartVelocityRange=(X=(Min=-8,Max=8),Y=(Min=-8,Max=8),Z=(Min=10,Max=20))
        SecondsBeforeInactive=0
    End Object
    Emitters(1)=SpriteEmitter'PawBurstOuter'
    RemoteRole=ROLE_None
    bHidden=False
    bUnlit=True
    bNoDelete=False
    bCollideActors=False
    AutoDestroy=False
}
