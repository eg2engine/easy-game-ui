// Separate transparent mesh pass, driven by the original Guardian's pose.
class GoldenDragonSurfaceLayer extends Actor;

simulated function SyncSurface(Guardian Source, Material LayerMaterial)
{
    if (Source==None || Source.bDeleteMe) { Destroy(); return; }
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

simulated event Tick(float DT)
{
    if (Owner==None || Owner.bDeleteMe) Destroy();
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
