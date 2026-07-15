class MurcielSword15_KillingEffect extends Emitter;

function Texture LoadParticleTexture(string ResourceName)
{
    local Texture LoadedTexture;

    LoadedTexture = Texture(DynamicLoadObject(ResourceName, class'Texture'));
    if (LoadedTexture == None)
        Log("MurcielSword15_KillingEffect failed to load texture" @ ResourceName);

    return LoadedTexture;
}

event PostBeginPlay()
{
    if (Emitters.Length > 0)
        Emitters[0].Texture = LoadParticleTexture("EffectTexture.M_Disciple.mana_regeenration02");
    if (Emitters.Length > 1)
        Emitters[1].Texture = LoadParticleTexture("EffectTexture.M_Disciple.mana_regeenration02");
    if (Emitters.Length > 2)
        Emitters[2].Texture = LoadParticleTexture("EffectTextureA.Common.particle05");
    if (Emitters.Length > 3)
        Emitters[3].Texture = LoadParticleTexture("EffectTexture.effect001.elect02");
    if (Emitters.Length > 4)
        Emitters[4].Texture = LoadParticleTexture("EffectTexture.effect001.elect02");
    if (Emitters.Length > 5)
        Emitters[5].Texture = LoadParticleTexture("EffectTexture.effect001.circle0005a");
    if (Emitters.Length > 6)
        Emitters[6].Texture = LoadParticleTexture("EffectTexture.effect001.circle0005a");
    if (Emitters.Length > 7)
        Emitters[7].Texture = LoadParticleTexture("EffectTextureA.Common.particle05");

    Super.PostBeginPlay();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=Murciel15RedEdge
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=105,G=30,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=235,G=55,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=155,G=25,R=210,A=255))
         FadeInEndTime=0.120000
         FadeOutStartTime=0.680000
         CoordinateSystem=PTCS_Relative
         MaxParticles=18
         StartLocationOffset=(X=-5.500000,Z=25.000000)
         StartLocationRange=(X=(Min=-1.500000,Max=1.500000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-55.000000,Max=55.000000))
         SpinsPerSecondRange=(X=(Min=-0.040000,Max=0.040000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.650000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.650000)
         StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=28.000000,Max=42.000000),Z=(Min=5.000000,Max=8.000000))
         InitialParticlesPerSecond=15.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.850000,Max=1.150000)
     End Object
     Emitters(0)=SpriteEmitter'Sephiroth.Murciel15RedEdge'

     Begin Object Class=SpriteEmitter Name=Murciel15BlueEdge
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=255,G=150,R=40,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=235,R=170,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=110,R=30,A=255))
         FadeInEndTime=0.120000
         FadeOutStartTime=0.680000
         CoordinateSystem=PTCS_Relative
         MaxParticles=18
         StartLocationOffset=(X=5.500000,Z=25.000000)
         StartLocationRange=(X=(Min=-1.500000,Max=1.500000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-55.000000,Max=55.000000))
         SpinsPerSecondRange=(X=(Min=-0.040000,Max=0.040000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.650000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.650000)
         StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=28.000000,Max=42.000000),Z=(Min=5.000000,Max=8.000000))
         InitialParticlesPerSecond=15.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.850000,Max=1.150000)
     End Object
     Emitters(1)=SpriteEmitter'Sephiroth.Murciel15BlueEdge'

     Begin Object Class=SpriteEmitter Name=Murciel15EnergyNodes
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=190,G=30,R=145,A=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=90,R=245,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=235,R=235,A=255))
         FadeInEndTime=0.080000
         FadeOutStartTime=0.700000
         CoordinateSystem=PTCS_Relative
         MaxParticles=24
         StartLocationOffset=(Z=-35.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-8.000000,Max=28.000000))
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.350000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.150000)
         StartSizeRange=(X=(Min=6.000000,Max=12.000000))
         InitialParticlesPerSecond=24.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.800000,Max=1.100000)
         StartVelocityRange=(Z=(Min=95.000000,Max=135.000000))
     End Object
     Emitters(2)=SpriteEmitter'Sephiroth.Murciel15EnergyNodes'

     Begin Object Class=SpriteEmitter Name=Murciel15FineArcs
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=90,R=150,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=220,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=210,G=40,R=150,A=255))
         FadeInEndTime=0.040000
         FadeOutStartTime=0.240000
         CoordinateSystem=PTCS_Relative
         MaxParticles=24
         StartLocationOffset=(Z=22.000000)
         StartLocationRange=(X=(Min=-6.000000,Max=6.000000),Y=(Min=-6.000000,Max=6.000000),Z=(Min=-50.000000,Max=50.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=0.350000,RelativeSize=0.800000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=28.000000
         DrawStyle=PTDS_Brighten
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.280000,Max=0.450000)
         StartVelocityRange=(Z=(Min=65.000000,Max=110.000000))
     End Object
     Emitters(3)=SpriteEmitter'Sephiroth.Murciel15FineArcs'

     Begin Object Class=SpriteEmitter Name=Murciel15StrongArcs
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=130,R=220,A=255))
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=255,G=245,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=70,R=175,A=255))
         ColorMultiplierRange=(X=(Min=1.500000,Max=2.500000),Y=(Min=1.500000,Max=2.500000),Z=(Min=1.500000,Max=2.500000))
         FadeInEndTime=0.060000
         FadeOutStartTime=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(Z=28.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-35.000000,Max=35.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.350000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
         StartSizeRange=(X=(Min=20.000000,Max=30.000000))
         InitialParticlesPerSecond=1.300000
         DrawStyle=PTDS_Brighten
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.900000,Max=1.250000)
     End Object
     Emitters(4)=SpriteEmitter'Sephiroth.Murciel15StrongArcs'

     Begin Object Class=SpriteEmitter Name=Murciel15GuardHalo
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=80,R=180,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=210,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=210,G=45,R=155,A=255))
         FadeInEndTime=0.250000
         FadeOutStartTime=1.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(Z=-38.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.160000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=22.000000,Max=28.000000))
         InitialParticlesPerSecond=0.700000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=1.400000,Max=1.600000)
     End Object
     Emitters(5)=SpriteEmitter'Sephiroth.Murciel15GuardHalo'

     Begin Object Class=SpriteEmitter Name=Murciel15TipCore
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=170,R=85,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=250,R=230,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=115,R=55,A=255))
         FadeInEndTime=0.120000
         FadeOutStartTime=0.620000
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         StartLocationOffset=(Z=92.000000)
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-3.000000,Max=3.000000))
         SpinsPerSecondRange=(X=(Min=-0.300000,Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.400000)
         StartSizeRange=(X=(Min=10.000000,Max=16.000000))
         InitialParticlesPerSecond=6.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.700000,Max=0.950000)
     End Object
     Emitters(6)=SpriteEmitter'Sephiroth.Murciel15TipCore'

     Begin Object Class=SpriteEmitter Name=Murciel15TipSparks
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=255,G=160,R=190,A=255))
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=255,G=245,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=75,R=165,A=255))
         FadeInEndTime=0.035000
         FadeOutStartTime=0.260000
         CoordinateSystem=PTCS_Relative
         MaxParticles=22
         StartLocationOffset=(Z=92.000000)
         StartLocationRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=2.000000,Max=6.000000))
         InitialParticlesPerSecond=22.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.280000,Max=0.500000)
         StartVelocityRange=(X=(Min=-28.000000,Max=28.000000),Y=(Min=-28.000000,Max=28.000000),Z=(Min=85.000000,Max=155.000000))
     End Object
     Emitters(7)=SpriteEmitter'Sephiroth.Murciel15TipSparks'

     bLightChanged=True
     bNoDelete=False
     DrawScale=0.500000
     bUnlit=False
     bDirectional=True
}
