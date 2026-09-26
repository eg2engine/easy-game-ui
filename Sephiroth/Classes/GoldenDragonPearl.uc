// Solid spherical pearl; the old soft sprite blob is intentionally retired.
class GoldenDragonPearl extends Actor;

#exec STATICMESH IMPORT NAME=GoldenDragonPearlSphere FILE=Models\GoldenDragonPearl.lwo

var ColorModifier GoldSurface;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    GoldSurface=new(Self) class'ColorModifier';
    if (GoldSurface!=None)
    {
        GoldSurface.Material=Texture'Engine.WhiteTexture';
        GoldSurface.Color.R=255;
        GoldSurface.Color.G=210;
        GoldSurface.Color.B=20;
        GoldSurface.Color.A=255;
        GoldSurface.AlphaBlend=False;
        GoldSurface.RenderTwoSided=False;
        Skins.Length=1;
        Skins[0]=GoldSurface;
    }
}

simulated function SyncPearl(vector Center, float Radius)
{
    SetLocation(Center);
    SetDrawScale(Radius);
}

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'GoldenDragonPearlSphere'
    Skins(0)=Texture'Engine.WhiteTexture'
    bHidden=False
    bUnlit=False
    AmbientGlow=160
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
