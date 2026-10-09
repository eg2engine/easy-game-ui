// 管理金龙眼部覆盖、眼光和电弧，统一停止并清理子效果。
class GoldenDragonEyes extends Actor;
#exec STATICMESH IMPORT NAME=GoldenDragonEyeRim FILE=Models\GoldenDragonEyeRim.lwo
#exec STATICMESH IMPORT NAME=GoldenDragonEyeAmber FILE=Models\GoldenDragonEyeAmber.lwo
#exec STATICMESH IMPORT NAME=GoldenDragonEyeGold FILE=Models\GoldenDragonEyeGold.lwo
#exec STATICMESH IMPORT NAME=GoldenDragonEyePupil FILE=Models\GoldenDragonEyePupil.lwo
#exec STATICMESH IMPORT NAME=GoldenDragonEyeGlint FILE=Models\GoldenDragonEyeGlint.lwo

var GoldenDragonEyeLayer Layers[4];
var StaticMesh LayerMeshes[4];
var Color LayerColors[4];
var ColorModifier RimMaterial;
var GoldenDragonEyeGlow Glows[2];
var GoldenDragonEyeArc Arcs[2];
var vector GlowOffsets[2], ArcStarts[2], ArcEnds[2];
var bool bStopping;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    RimMaterial=new(Self) class'ColorModifier';
    if (RimMaterial!=None)
    {
        RimMaterial.Material=Texture'Engine.WhiteTexture';
        RimMaterial.Color.R=62; RimMaterial.Color.G=30; RimMaterial.Color.B=6;
        RimMaterial.Color.A=255;
        RimMaterial.AlphaBlend=False;
        RimMaterial.RenderTwoSided=False;
        Skins[0]=RimMaterial;
    }
}

simulated function vector OnHead(coords Frame, vector Offset, float Scale)
{
    return Frame.Origin+Scale*(Normal(Frame.XAxis)*Offset.X
        +Normal(Frame.YAxis)*Offset.Y+Normal(Frame.ZAxis)*Offset.Z);
}

// 先清空眼光和电弧引用，再销毁旧效果。
simulated function ClearSpecial()
{
    local int I;
    local Actor OldEffect;
    for (I=0; I<2; I++)
    {
        OldEffect=Glows[I];
        Glows[I]=None;
        if (OldEffect!=None && !OldEffect.bDeleteMe) OldEffect.Destroy();
        OldEffect=Arcs[I];
        Arcs[I]=None;
        if (OldEffect!=None && !OldEffect.bDeleteMe) OldEffect.Destroy();
    }
}

// 幂等地永久停止更新并清理所属资源；不在此函数内递归销毁自身。
simulated function StopWork()
{
    local int I;
    local GoldenDragonEyeLayer OldLayer;
    if (bStopping)
        return;
    bStopping=True;
    Disable('Tick');
    bHidden=True;
    for (I=0; I<4; I++)
    {
        OldLayer=Layers[I];
        Layers[I]=None;
        if (OldLayer!=None)
        {
            OldLayer.StopWork();
            if (!OldLayer.bDeleteMe) OldLayer.Destroy();
        }
    }
    ClearSpecial();
    RimMaterial=None;
}

// 仅在眼部与宿主存活时同步骨骼；装备资格控制附加眼光与电弧。
simulated function SyncEyes(Guardian Source, bool Eligible)
{
    local coords Head;
    local int I;
    local float Scale, Pulse, ArcPhase;
    local vector P,A,B;
    if (bStopping || Source==None || Source.bDeleteMe)
        return;
    Head=Source.GetBoneCoords('Bone017_060');
    if (VSize(Head.XAxis)<0.5 || VSize(Head.YAxis)<0.5 || VSize(Head.ZAxis)<0.5)
    { bHidden=True; for (I=0; I<4; I++) if (Layers[I]!=None) Layers[I].bHidden=True; ClearSpecial(); return; }
    bHidden=False;
    Scale=Source.DrawScale;
    SetLocation(Head.Origin);
    SetRotation(OrthoRotation(Normal(Head.XAxis),Normal(Head.YAxis),Normal(Head.ZAxis)));
    SetDrawScale(Scale);
    for (I=0; I<4; I++)
    {
        if (Layers[I]==None || Layers[I].bDeleteMe)
        {
            Layers[I]=Spawn(class'GoldenDragonEyeLayer',Self,,Location,Rotation);
            if (Layers[I]!=None) Layers[I].InitializeLayer(LayerMeshes[I],LayerColors[I]);
        }
        if (Layers[I]!=None) Layers[I].SyncLayer(Self);
    }
    // The inlays use actual UV-mapped head-local coordinates, not guessed eye sockets.
    if (!Eligible) { ClearSpecial(); return; }
    Pulse=1+0.10*Sin(Level.TimeSeconds*2.513274);
    for (I=0; I<2; I++)
    {
        P=OnHead(Head,GlowOffsets[I],Scale);
        if (Glows[I]==None || Glows[I].bDeleteMe) Glows[I]=Spawn(class'GoldenDragonEyeGlow',Self,,P);
        if (Glows[I]!=None) Glows[I].SyncGlow(P,Scale,Pulse);
        A=OnHead(Head,ArcStarts[I],Scale); B=OnHead(Head,ArcEnds[I],Scale);
        if (Arcs[I]==None || Arcs[I].bDeleteMe) Arcs[I]=Spawn(class'GoldenDragonEyeArc',Self,,A);
        if (Arcs[I]!=None)
        {
            Arcs[I].SetEnds(A,B);
            ArcPhase=Level.TimeSeconds/0.8+I*0.5;
            Arcs[I].bHidden=(ArcPhase-int(ArcPhase))>0.14;
        }
    }
}

// 每帧先检查所属对象的停止或生命周期状态，失效时不继续访问效果资源。
simulated event Tick(float DT)
{
    if (bStopping)
        return;
    if (Owner==None || Owner.bDeleteMe) Destroy();
}

// 销毁时先停止所属增强或效果，再执行父类清理。
simulated event Destroyed()
{
    StopWork();
    Super.Destroyed();
}

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'GoldenDragonEyeRim'
    Skins(0)=Texture'Engine.WhiteTexture'
    bHidden=False
    bUnlit=False
    AmbientGlow=128
    bUseDynamicLights=True
    bStaticLighting=False
    bShadowCast=False
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=False
    RemoteRole=ROLE_None
    LayerMeshes(0)=StaticMesh'GoldenDragonEyeAmber'
    LayerColors(0)=(R=204,G=126,B=19,A=255)
    LayerMeshes(1)=StaticMesh'GoldenDragonEyeGold'
    LayerColors(1)=(R=242,G=165,B=32,A=255)
    LayerMeshes(2)=StaticMesh'GoldenDragonEyePupil'
    LayerColors(2)=(R=12,G=7,B=3,A=255)
    LayerMeshes(3)=StaticMesh'GoldenDragonEyeGlint'
    LayerColors(3)=(R=255,G=236,B=177,A=255)

    GlowOffsets(0)=(X=35.477641,Y=-4.885040,Z=-0.442596)
    ArcStarts(0)=(X=33.918225,Y=-5.707195,Z=-0.630978)
    ArcEnds(0)=(X=34.390836,Y=-5.515527,Z=-0.173680)
    GlowOffsets(1)=(X=35.477640,Y=4.884374,Z=-0.442597)
    ArcStarts(1)=(X=33.918224,Y=5.706528,Z=-0.630979)
    ArcEnds(1)=(X=34.390836,Y=5.514860,Z=-0.173681)
}
