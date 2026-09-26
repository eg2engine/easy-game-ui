class GoldenDragonTailTrail extends Emitter;
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=GoldenTailFlow
        CoordinateSystem=PTCS_Independent
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=220,B=95,A=255))
        ColorScale(1)=(RelativeTime=0.35,Color=(R=245,G=150,B=25,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeOut=True
        FadeOutStartTime=0.06
        UniformSize=True
        MaxParticles=22
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=55
        StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-1,Max=2))
        StartSizeRange=(X=(Min=5,Max=9))
        StartVelocityRange=(Z=(Min=2,Max=5))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.22,Max=0.35)
        SecondsBeforeInactive=0
    End Object
    Emitters(0)=SpriteEmitter'GoldenTailFlow'
    RemoteRole=ROLE_None
    bHidden=False
    bUnlit=True
    bNoDelete=False
    bCollideActors=False
    AutoDestroy=False
}
