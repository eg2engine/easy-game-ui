class GoldenDragonHeadGlow extends Emitter;
// Particle locations are relative to this head actor, which sits 4 units above the bone.
simulated function SetHeadFrame(vector Forward, vector Side, vector Up, float Scale)
{
    local int I;
    local vector Offset;
    if (Emitters.Length<5) return;
    for (I=2; I<5; I++)
    {
        if (I==2) Offset=(Forward*2+Up*11)*Scale;
        else if (I==3) Offset=(Forward*6+Side*9+Up*3)*Scale;
        else Offset=(Forward*6-Side*9+Up*3)*Scale;
        Offset.Z-=4*Scale;
        Emitters[I].StartLocationRange.X.Min=Offset.X-1;
        Emitters[I].StartLocationRange.X.Max=Offset.X+1;
        Emitters[I].StartLocationRange.Y.Min=Offset.Y-1;
        Emitters[I].StartLocationRange.Y.Max=Offset.Y+1;
        Emitters[I].StartLocationRange.Z.Min=Offset.Z-1;
        Emitters[I].StartLocationRange.Z.Max=Offset.Z+1;
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=DragonCrownLight
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=220,G=170,B=25,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=220,B=65,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeOut=True
        FadeInEndTime=0.06
        FadeOutStartTime=0.20
        UniformSize=True
        MaxParticles=6
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=14
        StartLocationRange=(X=(Min=-4,Max=4),Y=(Min=-4,Max=4),Z=(Min=-1,Max=3))
        StartSizeRange=(X=(Min=18,Max=26))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.3,Max=0.35)
        SecondsBeforeInactive=0
    End Object
    Emitters(0)=SpriteEmitter'DragonCrownLight'
    Begin Object Class=SpriteEmitter Name=DragonHeadElectric
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=245,B=85,A=255))
        ColorScale(1)=(RelativeTime=0.4,Color=(R=255,G=210,B=15,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        UniformSize=True
        SpinParticles=True
        StartSpinRange=(X=(Min=0,Max=1))
        MaxParticles=6
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=34
        StartLocationRange=(X=(Min=-8,Max=8),Y=(Min=-8,Max=8),Z=(Min=-5,Max=7))
        StartSizeRange=(X=(Min=16,Max=22))
        Texture=Texture'EffectTexture.effect001.elect02'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.12,Max=0.18)
        SecondsBeforeInactive=0
    End Object
    Emitters(1)=SpriteEmitter'DragonHeadElectric'
    Begin Object Class=SpriteEmitter Name=HeadForeheadGold
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=230,B=25,A=255))
        ColorScale(1)=(RelativeTime=0.45,Color=(R=255,G=210,B=10,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeInEndTime=0.035
        FadeOut=True
        FadeOutStartTime=0.14
        UniformSize=True
        MaxParticles=3
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        StartSizeRange=(X=(Min=5,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.20,Max=0.28)
        SecondsBeforeInactive=0
    End Object
    Emitters(2)=SpriteEmitter'HeadForeheadGold'
    Begin Object Class=SpriteEmitter Name=HeadCheekGoldLeft
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=230,B=25,A=255))
        ColorScale(1)=(RelativeTime=0.45,Color=(R=255,G=210,B=10,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeInEndTime=0.035
        FadeOut=True
        FadeOutStartTime=0.14
        UniformSize=True
        MaxParticles=3
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        StartSizeRange=(X=(Min=5,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.20,Max=0.28)
        SecondsBeforeInactive=0
    End Object
    Emitters(3)=SpriteEmitter'HeadCheekGoldLeft'
    Begin Object Class=SpriteEmitter Name=HeadCheekGoldRight
        CoordinateSystem=PTCS_Relative
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=230,B=25,A=255))
        ColorScale(1)=(RelativeTime=0.45,Color=(R=255,G=210,B=10,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=0,G=0,B=0,A=0))
        FadeIn=True
        FadeInEndTime=0.035
        FadeOut=True
        FadeOutStartTime=0.14
        UniformSize=True
        MaxParticles=3
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=8
        StartSizeRange=(X=(Min=5,Max=8))
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.20,Max=0.28)
        SecondsBeforeInactive=0
    End Object
    Emitters(4)=SpriteEmitter'HeadCheekGoldRight'
    RemoteRole=ROLE_None
    bHidden=False
    bUnlit=True
    bNoDelete=False
    bCollideActors=False
    AutoDestroy=False
}
