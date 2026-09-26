class GoldenDragonLightning extends Emitter;
simulated function SetEnds(vector A, vector B)
{
    local BeamEmitter Beam;
    Beam=BeamEmitter(Emitters[0]);
    if (Beam==None) return;
    SetLocation(A);
    SetRotation(Rotator(B-A));
    Beam.BeamEndPoints[0].Offset.X.Min=VSize(B-A);
    Beam.BeamEndPoints[0].Offset.X.Max=VSize(B-A);
}
defaultproperties
{
    Begin Object Class=BeamEmitter Name=GoldLightning
        CoordinateSystem=PTCS_Relative
        DetermineEndPointBy=PTEP_Offset
        BeamEndPoints(0)=(Offset=(X=(Min=25,Max=25)),Weight=1)
        RotatingSheets=3
        BeamDistanceRange=(Min=25,Max=25)
        StartVelocityRange=(X=(Min=0,Max=0))
        UseColorScale=True
        ColorScale(0)=(Color=(R=255,G=245,B=100,A=255))
        ColorScale(1)=(RelativeTime=0.5,Color=(R=255,G=200,B=25,A=255))
        ColorScale(2)=(RelativeTime=1,Color=(R=80,G=45,B=0,A=0))
        ColorMultiplierRange=(X=(Min=1.5,Max=1.5),Y=(Min=1.5,Max=1.5),Z=(Min=1.5,Max=1.5))
        MaxParticles=1
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=10
        StartSizeRange=(X=(Min=1.2,Max=2),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        LowFrequencyPoints=5
        HighFrequencyPoints=12
        LowFrequencyNoiseRange=(X=(Min=-1,Max=1),Y=(Min=-3,Max=3),Z=(Min=-3,Max=3))
        HighFrequencyNoiseRange=(X=(Min=-0.5,Max=0.5),Y=(Min=-1,Max=1),Z=(Min=-1,Max=1))
        DynamicHFNoiseRange=(Y=(Min=-1,Max=1),Z=(Min=-1,Max=1))
        DynamicTimeBetweenNoiseRange=(Min=0.035,Max=0.055)
        Texture=Texture'EffectTextureA.Common.particle05'
        DrawStyle=PTDS_Additive
        AlphaTest=False
        ZTest=True
        ZWrite=False
        LifetimeRange=(Min=0.10,Max=0.16)
        SecondsBeforeInactive=0
    End Object
    Emitters(0)=BeamEmitter'GoldLightning'
    RemoteRole=ROLE_None
    bHidden=False
    bUnlit=True
    bNoDelete=False
    bCollideActors=False
    AutoDestroy=False
}
