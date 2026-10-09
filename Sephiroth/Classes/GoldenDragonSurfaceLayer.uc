// Separate transparent mesh pass, driven by the original Guardian's pose.
// 维护跟随宿主姿态的透明覆盖层，停止时解除宿主绑定。
class GoldenDragonSurfaceLayer extends Actor;
var bool bStopping;

// 幂等地永久停止更新并清理所属资源；不在此函数内递归销毁自身。
simulated function StopWork()
{
    if (bStopping)
        return;
    bStopping=True;
    Disable('Tick');
    bHidden=True;
    bAnimByOwner=False;
    SetBase(None);
    Skins[0]=None;
}

// 同步宿主姿态与覆盖材质；宿主失效时停止并销毁本层。
simulated function SyncSurface(Guardian Source, Material LayerMaterial)
{
    if (bStopping)
        return;
    if (Source==None || Source.bDeleteMe)
    {
        StopWork();
        Destroy();
        return;
    }
    if (Mesh!=Source.Mesh) LinkMesh(Source.Mesh);
    if (Base!=Source) SetBase(Source);
    SetLocation(Source.Location);
    SetRotation(Source.Rotation);
    SetDrawScale(Source.DrawScale);
    SetDrawScale3D(Source.DrawScale3D);
    PrePivot=Source.PrePivot;
    if (Skins.Length==0) Skins.Length=1;
    Skins[0]=LayerMaterial;
    bHidden=Source.bHidden;
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
    DrawType=DT_Mesh
    bAnimByOwner=True
    bUnlit=True
    Style=STY_Translucent
    bHidden=False
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=False
    RemoteRole=ROLE_None
}
