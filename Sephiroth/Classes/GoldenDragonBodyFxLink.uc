class GoldenDragonBodyFxLink extends Actor;
var Guardian Dragon;
var GoldenDragonEyes Eyes;
var Emitter Lights[18];
var name Bones[18];
var string RequiredModels[25];
var float CheckDelay;
var string Status;
var bool bEligible;
var int LiveLights, FailedSpawns, TextureFailures;
var GoldenDragonLightning Arcs[30];
var GoldenDragonHeadLightning HeadArcs[12];
var GoldenDragonFineLightning WhiskerArcs[4];
var GoldenDragonPearlLightning PearlArcs[12];
var GoldenDragonPearl Pearl;
var GoldenDragonMouthFlame MouthFlames[2];
var name WhiskerBones[6];
var vector PearlUpperJawOffset, PearlLowerJawOffset;
var GoldenDragonTailTrail TailFx;
var GoldenDragonTailBurst TailBurst;
var GoldenDragonPawBurst PawBursts[4];
var vector PreviousPawLocal[4];
var float PawBurstCooldown[4];
var bool bPawHistoryReady;
var float BoneSpan, PawSpan;
var int LiveArcs, RenderedParticles, TailParticles, PawParticles;
var GoldenDragonSurfaceLayer SurfaceLayers[4];
var FinalBlend SurfaceMaterials[2];
var bool bSurfaceApplied;
var bool bSurfaceUnsupported;
var int SurfaceLayerCount;
var string FxState;

// One texture and a vertex-color modifier, without Shader/ConstantColor fallbacks.
simulated function FinalBlend MakeSurfaceLayer(Material Pattern, byte R, byte G, byte B)
{
    local ColorModifier Tint;
    local FinalBlend F;
    Tint=new(Self) class'ColorModifier';
    F=new(Self) class'FinalBlend';
    if (Tint==None || F==None) return None;
    Tint.Material=Pattern;
    Tint.Color.R=R; Tint.Color.G=G; Tint.Color.B=B; Tint.Color.A=255;
    Tint.AlphaBlend=False;
    Tint.RenderTwoSided=False;
    F.Material=Tint;
    // Black texels contribute no light; there is no opaque black fallback material.
    F.FrameBufferBlending=FB_Translucent;
    F.ZTest=True; F.ZWrite=False; F.AlphaTest=False; F.TwoSided=False;
    return F;
}

simulated function bool SurfaceRenderRejected()
{
    local int I;
    for (I=0; I<2; I++)
        if (SurfaceMaterials[I]!=None)
        {
            if (SurfaceMaterials[I].UseFallback) return True;
            if (SurfaceMaterials[I].Material!=None && SurfaceMaterials[I].Material.UseFallback) return True;
        }
    return False;
}

simulated function ApplySurface()
{
    local Material Plasma, LightMove;
    local int I;
    if (bSurfaceUnsupported || SurfaceRenderRejected())
    {
        bSurfaceUnsupported=True;
        RestoreSurface();
        FxState="SURFACE_RENDER_REJECTED";
        return;
    }
    if (SurfaceMaterials[0]==None || SurfaceMaterials[1]==None)
    {
        Plasma=Material(DynamicLoadObject("ItemEffectTextures.IE_DGprazma_l01",class'Material',True));
        LightMove=Material(DynamicLoadObject("ItemEffectTextures.LightMove_d00",class'Material',True));
        if (Plasma==None || LightMove==None) { FxState="SURFACE_TEXTURE_MISSING"; return; }
        // Use animated RGB highlights; intensity is controlled by RGB, not opacity.
        if (SurfaceMaterials[0]==None) SurfaceMaterials[0]=MakeSurfaceLayer(Plasma,192,36,2);
        if (SurfaceMaterials[1]==None) SurfaceMaterials[1]=MakeSurfaceLayer(LightMove,160,112,6);
    }
    SurfaceLayerCount=0;
    for (I=0; I<4; I++)
    {
        if (SurfaceMaterials[I%2]==None) continue;
        if (SurfaceLayers[I]==None || SurfaceLayers[I].bDeleteMe)
            SurfaceLayers[I]=Spawn(class'GoldenDragonSurfaceLayer',Dragon,,Dragon.Location,Dragon.Rotation);
        if (SurfaceLayers[I]!=None)
        {
            SurfaceLayers[I].SyncSurface(Dragon,SurfaceMaterials[I%2]);
            SurfaceLayerCount++;
        }
    }
    bSurfaceApplied=SurfaceLayerCount==4;
}

simulated function RestoreSurface()
{
    local int I;
    for (I=0; I<4; I++)
    {
        if (SurfaceLayers[I]!=None) SurfaceLayers[I].Destroy();
        SurfaceLayers[I]=None;
    }
    SurfaceLayerCount=0;
    bSurfaceApplied=False;
}

simulated function ClearLights()
{
    local int I;
    LiveLights=0;
    LiveArcs=0;
    RenderedParticles=0;
    TailParticles=0; PawParticles=0;
    FxState="OFF";
    RestoreSurface();
    for (I=0; I<12; I++)
    {
        if (HeadArcs[I]!=None) HeadArcs[I].Destroy();
        HeadArcs[I]=None;
    }
    if (Pearl!=None) Pearl.Destroy();
    Pearl=None;
    for (I=0; I<2; I++)
    {
        if (MouthFlames[I]!=None) MouthFlames[I].Destroy();
        MouthFlames[I]=None;
    }
    for (I=0; I<4; I++)
    {
        if (WhiskerArcs[I]!=None) WhiskerArcs[I].Destroy();
        WhiskerArcs[I]=None;
    }
    for (I=0; I<12; I++)
    {
        if (PearlArcs[I]!=None) PearlArcs[I].Destroy();
        PearlArcs[I]=None;
    }
    bPawHistoryReady=False;
    for (I=0; I<4; I++)
    {
        if (PawBursts[I]!=None) PawBursts[I].Destroy();
        PawBursts[I]=None;
        PawBurstCooldown[I]=0;
    }
    for (I=0; I<30; I++)
    {
        if (Arcs[I]!=None) Arcs[I].Destroy();
        Arcs[I]=None;
    }
    if (TailFx!=None) TailFx.Destroy();
    TailFx=None;
    if (TailBurst!=None) TailBurst.Destroy();
    TailBurst=None;
    for (I=0; I<18; I++)
    {
        if (Lights[I] != None) Lights[I].Destroy();
        Lights[I] = None;
    }
}

static function int AffixCount(SephirothItem Item)
{
    local int I,J,N;
    local bool Duplicate;
    if (Item == None) return 0;
    for (I=0; I<Item.Affixes.Length; I++)
    {
        if (Item.Affixes[I].AffixName == "" || Item.Affixes[I].AffixValue < 17) continue;
        Duplicate=False;
        for (J=0; J<I; J++)
            if (Item.Affixes[J].AffixName ~= Item.Affixes[I].AffixName && Item.Affixes[J].AffixValue >= 17) Duplicate=True;
        if (!Duplicate) N++;
    }
    return N;
}

simulated function bool CheckEquipment()
{
    local Hero H;
    local ClientController CC;
    local SephirothItem Item, Found;
    local int I,G,Part,SetIndex,Slot,N;
    local string Key;
    H=Hero(Dragon.OwnPlayer);
    if (H == None) { Status="NO_OWNER"; return False; }
    CC=ClientController(H.Controller);
    if (CC == None || CC.PSI == None || CC.PSI.WornItems == None)
    { Status="NO_WORN_DATA"; return False; }
    SetIndex=-1;
    for (I=0; I<CC.PSI.WornItems.Items.Length; I++)
    {
        Item=CC.PSI.WornItems.Items[I];
        if (Item == None || (Item.EquipPlace != 8 && Item.EquipPlace != 16)) continue;
        Key=class'BlackGoldWeaponFxLink'.static.ModelKey(Item.ModelName);
        for (G=0; G<5; G++)
            if (Key ~= RequiredModels[G*5+4]) SetIndex=G;
    }
    if (SetIndex < 0) { Status="MISSING_BLACKGOLD_WEAPON"; return False; }
    for (Part=0; Part<5; Part++)
    {
        Slot=Part+1;
        if (Part==4) Slot=8;
        Found=None;
        for (I=0; I<CC.PSI.WornItems.Items.Length; I++)
        {
            Item=CC.PSI.WornItems.Items[I];
            if (Item == None) continue;
            if (Item.EquipPlace != Slot && !(Part==4 && Item.EquipPlace==16)) continue;
            Key=class'BlackGoldWeaponFxLink'.static.ModelKey(Item.ModelName);
            if (Key ~= RequiredModels[SetIndex*5+Part])
            {
                if (Found != None) { Status="DUPLICATE_SLOT=" $ Slot; return False; }
                Found=Item;
            }
        }
        if (Found == None) { Status="MISSING=" $ RequiredModels[SetIndex*5+Part]; return False; }
        N=AffixCount(Found);
        if (N<5) { Status="AFFIX=" $ RequiredModels[SetIndex*5+Part] $ ":" $ N $ "/5>=17"; return False; }
    }
    Status="ON:5_ITEMS_PASS shield=ignored";
    return True;
}

simulated function UpdateHeadEffects(vector Head, vector Neck)
{
    local vector Forward,Side,Up,Nodes[6],A,B;
    local float Scale;
    local int I,J,K;
    Forward=Normal(Head-Neck);
    if (VSize(Forward)<0.5) return;
    Side=Normal(Forward Cross vect(0,0,1));
    if (VSize(Side)<0.1) Side=Normal(vect(0,1,0) >> Dragon.Rotation);
    Up=Normal(Side Cross Forward);
    Scale=Dragon.DrawScale;
    // A small crown/cheek loop, anchored in the animated head's frame.
    Nodes[0]=Head+(Forward*12+Up*2)*Scale;
    Nodes[1]=Head+(Forward*2+Side*12+Up*6)*Scale;
    Nodes[2]=Head+(-Forward*8+Side*10+Up*12)*Scale;
    Nodes[3]=Head+(-Forward*12+Up*17)*Scale;
    Nodes[4]=Head+(-Forward*8-Side*10+Up*12)*Scale;
    Nodes[5]=Head+(Forward*2-Side*12+Up*6)*Scale;
    if (GoldenDragonHeadGlow(Lights[0])!=None)
        GoldenDragonHeadGlow(Lights[0]).SetHeadFrame(Forward,Side,Up,Scale);
    for (I=0; I<12; I++)
    {
        K=I%6;
        J=(K+1)%6;
        A=Nodes[K]; B=Nodes[J];
        if (I>=6)
        {
            A+=(Forward*4+Up*3)*Scale;
            B+=(Forward*4+Up*3)*Scale;
        }
        if (HeadArcs[I]==None || HeadArcs[I].bDeleteMe)
            HeadArcs[I]=Spawn(class'GoldenDragonHeadLightning',Self,,A);
        if (HeadArcs[I]!=None) HeadArcs[I].SetEnds(A,B);
    }
    UpdateMouthEffects(Forward,Side,Up,Scale);
}

simulated function UpdateMouthEffects(vector Forward, vector Side, vector Up, float Scale)
{
    local vector W[6], Center, A, B, Direction, UpperJaw,LowerJaw,RingSide;
    local float Angle, NextAngle, Sign, PearlRadius;
    local coords UpperFrame, LowerFrame;
    local int I,K;
    for (I=0; I<6; I++) W[I]=Dragon.GetBoneCoords(WhiskerBones[I]).Origin;
    // A few thin arcs trace each whisker's first two animated sections.
    for (I=0; I<4; I++)
    {
        K=I;
        if (I>=2) K=I+1;
        A=W[K]; B=W[K+1];
        if (VSize(B-A)<1) continue;
        if (WhiskerArcs[I]==None || WhiskerArcs[I].bDeleteMe)
            WhiskerArcs[I]=Spawn(class'GoldenDragonFineLightning',Self,,A);
        if (WhiskerArcs[I]!=None) WhiskerArcs[I].SetEnds(A,B);
    }
    // Calibrated on the posed mesh: use inner-mouth points, not jaw joint origins.
    UpperFrame=Dragon.GetBoneCoords('Bone018_061');
    LowerFrame=Dragon.GetBoneCoords('Bone020_062');
    UpperJaw=UpperFrame.Origin+Scale*(Normal(UpperFrame.XAxis)*PearlUpperJawOffset.X
        +Normal(UpperFrame.YAxis)*PearlUpperJawOffset.Y+Normal(UpperFrame.ZAxis)*PearlUpperJawOffset.Z);
    LowerJaw=LowerFrame.Origin+Scale*(Normal(LowerFrame.XAxis)*PearlLowerJawOffset.X
        +Normal(LowerFrame.YAxis)*PearlLowerJawOffset.Y+Normal(LowerFrame.ZAxis)*PearlLowerJawOffset.Z);
    Center=(UpperJaw+LowerJaw)*0.5;
    PearlRadius=FClamp(VSize(UpperJaw-LowerJaw)*0.38,2.8*Scale,4.5*Scale);
    if (Pearl==None || Pearl.bDeleteMe) Pearl=Spawn(class'GoldenDragonPearl',Self,,Center);
    if (Pearl!=None) Pearl.SyncPearl(Center,PearlRadius);
    // A finely segmented ring stays on the sphere rather than cutting through its center.
    RingSide=Side*Cos(Level.TimeSeconds*1.2)+Forward*Sin(Level.TimeSeconds*1.2);
    for (I=0; I<12; I++)
    {
        Angle=Level.TimeSeconds*2+I*0.5235988;
        NextAngle=Angle+0.5235988;
        A=Center+(RingSide*Cos(Angle)+Up*Sin(Angle))*(PearlRadius*1.06);
        B=Center+(RingSide*Cos(NextAngle)+Up*Sin(NextAngle))*(PearlRadius*1.06);
        if (PearlArcs[I]==None || PearlArcs[I].bDeleteMe)
            PearlArcs[I]=Spawn(class'GoldenDragonPearlLightning',Self,,A);
        if (PearlArcs[I]!=None) PearlArcs[I].SetEnds(A,B);
    }
    for (I=0; I<2; I++)
    {
        Sign=1;
        if (I==1) Sign=-1;
        A=Center+Side*(Sign*(PearlRadius+1.5*Scale))-Forward*(1.5*Scale)-Up*(PearlRadius*0.25);
        Direction=Normal(-Forward*0.85+Side*(0.65*Sign)-Up*0.35);
        if (MouthFlames[I]==None || MouthFlames[I].bDeleteMe)
            MouthFlames[I]=Spawn(class'GoldenDragonMouthFlame',Self,,A,Rotator(Direction));
        if (MouthFlames[I]!=None)
        {
            MouthFlames[I].SetLocation(A);
            MouthFlames[I].SetRotation(Rotator(Direction));
        }
    }
}

simulated function ClearEyes()
{
    if (Eyes!=None) Eyes.Destroy();
    Eyes=None;
}

simulated function UpdateEffects(float DT)
{
    local int I,J,K;
    local vector P,Direction,Side,Up,A,B,LocalP;
    local vector Points[18],Shell[28];
    local float Angle,Radius,PawSpeed;
    Dragon=Guardian(Owner);
    if (Dragon==None || Dragon.bDeleteMe || Dragon.OwnPlayer==None) { Destroy(); return; }
    CheckDelay-=DT;
    if (CheckDelay<=0)
    {
        CheckDelay=0.25; bEligible=CheckEquipment();
    }
    if (Dragon.bHidden || Dragon.OwnPlayer.bHidden || Dragon.OwnPlayer.bIsDead)
    { ClearEyes(); ClearLights(); return; }
    Dragon.BoneRefresh();
    if (Eyes==None || Eyes.bDeleteMe) Eyes=Spawn(class'GoldenDragonEyes',Self,,Dragon.Location);
    if (Eyes!=None) Eyes.SyncEyes(Dragon,bEligible);
    if (!bEligible) { ClearLights(); return; }
    for (I=0; I<18; I++) Points[I]=Dragon.GetBoneCoords(Bones[I]).Origin;
    BoneSpan=VSize(Points[13]-Points[0]);
    PawSpan=VSize(Points[16]-Points[17]);
    if (BoneSpan<1 || PawSpan<1) { ClearLights(); FxState="ANCHORS_COLLAPSED"; return; }
    FxState="ACTIVE";
    ApplySurface();
    LiveLights=0; LiveArcs=0; TextureFailures=0; RenderedParticles=0;
    TailParticles=0; PawParticles=0;
    for (I=0; I<18; I++)
    {
        P=Points[I]; P.Z+=4*Dragon.DrawScale;
        if (Lights[I]==None || Lights[I].bDeleteMe)
        {
            if (I==0) Lights[I]=Spawn(class'GoldenDragonHeadGlow',Self,,P);
            else if (I>=14) Lights[I]=Spawn(class'GoldenDragonClawGlow',Self,,P);
            else Lights[I]=Spawn(class'GoldenDragonBodyGlow',Self,,P);
            if (Lights[I]==None) FailedSpawns++;
        }
        if (Lights[I]!=None)
        {
            LiveLights++;
            Lights[I].SetLocation(P); Lights[I].SetRotation(Dragon.Rotation);
            for (J=0; J<Lights[I].Emitters.Length; J++)
            {
                if (Lights[I].Emitters[J].Texture==None) TextureFailures++;
                RenderedParticles+=Lights[I].Emitters[J].RenderableParticles;
                if (I>=14) PawParticles+=Lights[I].Emitters[J].RenderableParticles;
            }
        }
    }
    UpdateHeadEffects(Points[0],Dragon.GetBoneCoords('Bone015_058').Origin);
    // Remove rigid translation/yaw before measuring paw motion.
    for (I=0; I<4; I++)
    {
        LocalP=(Points[I+14]-Dragon.Location) << Dragon.Rotation;
        PawBurstCooldown[I]=FMax(0,PawBurstCooldown[I]-DT);
        P=Points[I+14]-vect(0,0,1)*(6*Dragon.DrawScale);
        if (PawBursts[I]!=None && !PawBursts[I].bDeleteMe) PawBursts[I].SetLocation(P);
        if (bPawHistoryReady && DT>0 && DT<=0.1)
        {
            PawSpeed=VSize(LocalP-PreviousPawLocal[I])/DT;
            if (PawSpeed>14*Dragon.DrawScale && PawBurstCooldown[I]<=0)
            {
                if (PawBursts[I]==None || PawBursts[I].bDeleteMe)
                    PawBursts[I]=Spawn(class'GoldenDragonPawBurst',Self,,P);
                if (PawBursts[I]!=None) PawBursts[I].Pulse();
                PawBurstCooldown[I]=0.18;
            }
        }
        PreviousPawLocal[I]=LocalP;
    }
    bPawHistoryReady=True;
    for (I=0; I<14; I++)
    {
        if (I==0) Direction=Normal(Points[1]-Points[0]);
        else if (I==13) Direction=Normal(Points[13]-Points[12]);
        else Direction=Normal(Points[I+1]-Points[I-1]);
        Side=Normal(Direction Cross vect(0,0,1));
        if (VSize(Side)<0.1) Side=vect(1,0,0);
        Up=Normal(Side Cross Direction);
        Angle=Level.TimeSeconds*4-I*0.85; Radius=10*Dragon.DrawScale;
        Shell[I]=Points[I]+Radius*(Cos(Angle)*Side+Sin(Angle)*Up);
        Shell[I+14]=Points[I]-Radius*(Cos(Angle)*Side+Sin(Angle)*Up);
    }
    for (I=0; I<30; I++)
    {
        if (I<26)
        {
            K=I;
            if (I>=13) K=I+1;
            A=Shell[K]; B=Shell[K+1];
        }
        else
        {
            P=Points[I-12]; Angle=Level.TimeSeconds*7+I;
            Side=vect(0,1,0) >> Dragon.Rotation;
            A=P+Side*(9*Cos(Angle))+vect(0,0,1)*(4+6*Sin(Angle));
            B=P-Side*(9*Cos(Angle))+vect(0,0,1)*(4-6*Sin(Angle));
        }
        if (Arcs[I]==None || Arcs[I].bDeleteMe) Arcs[I]=Spawn(class'GoldenDragonLightning',Self,,A);
        if (Arcs[I]!=None)
        {
            Arcs[I].SetEnds(A,B); LiveArcs++;
            RenderedParticles+=Arcs[I].Emitters[0].RenderableParticles;
        }
        else FailedSpawns++;
    }
    Direction=Normal(Points[13]-Points[12]);
    if (VSize(Direction)<0.5) Direction=Vector(Dragon.Rotation);
    P=Points[13];
    if (TailBurst==None || TailBurst.bDeleteMe) TailBurst=Spawn(class'GoldenDragonTailBurst',Self,,P,Rotator(Direction));
    if (TailBurst!=None)
    {
        TailBurst.SetLocation(P); TailBurst.SetRotation(Rotator(Direction));
        for (J=0; J<TailBurst.Emitters.Length; J++) TailParticles+=TailBurst.Emitters[J].RenderableParticles;
        RenderedParticles+=TailParticles;
    }
    if (TailFx==None || TailFx.bDeleteMe) TailFx=Spawn(class'GoldenDragonTailTrail',Self,,P);
    if (TailFx!=None) { TailFx.SetLocation(P); TailFx.SetRotation(Dragon.Rotation); }
}
simulated event Destroyed()
{
    ClearEyes();
    ClearLights();
    Super.Destroyed();
}
defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
    bCollideActors=False
    RequiredModels(0)="MurcielHelmetB"
    RequiredModels(1)="MurcielArmorB"
    RequiredModels(2)="MurcielBootsB"
    RequiredModels(3)="MurcielVambraceB"
    RequiredModels(4)="MurcielSwordB"
    RequiredModels(5)="AcordHelmetB"
    RequiredModels(6)="AcordArmorB"
    RequiredModels(7)="AcordBootsB"
    RequiredModels(8)="AcordVambraceB"
    RequiredModels(9)="AcordGauntletB"
    RequiredModels(10)="AblazeHelmetB"
    RequiredModels(11)="AblazeGarmentB"
    RequiredModels(12)="AblazeBootsB"
    RequiredModels(13)="AblazeVambraceB"
    RequiredModels(14)="AblazeStaffB"
    RequiredModels(15)="GlaciesCapB"
    RequiredModels(16)="GlaciesGownB"
    RequiredModels(17)="GlaciesSandalB"
    RequiredModels(18)="GlaciesSleeveletB"
    RequiredModels(19)="GlaciesStickB"
    RequiredModels(20)="ApliteCapB"
    RequiredModels(21)="ApliteGarbB"
    RequiredModels(22)="ApliteSandalB"
    RequiredModels(23)="ApliteSleeveletB"
    RequiredModels(24)="ApliteBowB"
    PearlUpperJawOffset=(X=13,Y=0,Z=-5)
    PearlLowerJawOffset=(X=15,Y=0,Z=1.2)
    WhiskerBones(0)="Bone066(mirrored)_063"
    WhiskerBones(1)="Bone068(mirrored)_065"
    WhiskerBones(2)="Bone071(mirrored)_068"
    WhiskerBones(3)="Bone066_084"
    WhiskerBones(4)="Bone068_086"
    WhiskerBones(5)="Bone071_089"
    Bones(0)="Bone017_060"
    Bones(1)="Bone001_01"
    Bones(2)="Bone002_02"
    Bones(3)="Bone003_03"
    Bones(4)="Bone004_04"
    Bones(5)="Bone005_05"
    Bones(6)="Bone006_06"
    Bones(7)="Bone007_07"
    Bones(8)="Bone008_08"
    Bones(9)="Bone009_09"
    Bones(10)="Bone010_010"
    Bones(11)="Bone011_011"
    Bones(12)="Bone012_012"
    Bones(13)="Bone013_013"
    Bones(14)="Bone052_016"
    Bones(15)="Bone052(mirrored)_027"
    Bones(16)="Bone024(mirrored)_038"
    Bones(17)="Bone024_049"
}
