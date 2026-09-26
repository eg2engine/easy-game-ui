class GoldenDragonEyeLayer extends Actor;
var ColorModifier EyeMaterial;
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
simulated function SyncLayer(Actor Source)
{
    SetLocation(Source.Location);
    SetRotation(Source.Rotation);
    SetDrawScale(Source.DrawScale);
    bHidden=Source.bHidden;
}
simulated event Tick(float DT)
{
    if (Owner==None || Owner.bDeleteMe) Destroy();
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
