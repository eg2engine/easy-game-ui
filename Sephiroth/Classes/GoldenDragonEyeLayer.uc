// 维护眼部材质覆盖层，停止后不再同步来源对象。
class GoldenDragonEyeLayer extends Actor;
var ColorModifier EyeMaterial;
var bool bStopping;
simulated function InitializeLayer(StaticMesh Shape, Color Tint)
{
    SetStaticMesh(Shape);
    EyeMaterial=new(Self) class'ColorModifier';
    if (EyeMaterial!=None)
    {
        EyeMaterial.Material=Texture'Engine.WhiteTexture';
        EyeMaterial.Color=Tint;
        EyeMaterial.AlphaBlend=False;
        EyeMaterial.RenderTwoSided=False;
        Skins[0]=EyeMaterial;
    }
}
// 仅在覆盖层和来源对象有效时同步位置、旋转与缩放。
simulated function SyncLayer(Actor Source)
{
    if (bStopping || Source==None || Source.bDeleteMe)
        return;
    SetLocation(Source.Location);
    SetRotation(Source.Rotation);
    SetDrawScale(Source.DrawScale);
    bHidden=Source.bHidden;
}
// 每帧先检查所属对象的停止或生命周期状态，失效时不继续访问效果资源。
simulated event Tick(float DT)
{
    if (bStopping)
        return;
    if (Owner==None || Owner.bDeleteMe) Destroy();
}

// 幂等地永久停止更新并清理所属资源；不在此函数内递归销毁自身。
simulated function StopWork()
{
    if (bStopping)
        return;
    bStopping=True;
    Disable('Tick');
    bHidden=True;
    Skins[0]=Texture'Engine.WhiteTexture';
    EyeMaterial=None;
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
}
