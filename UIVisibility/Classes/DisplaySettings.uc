class DisplaySettings extends Object config(SephirothUI);
var config bool bHasSliders;
var config float FogRatio;
var config int FilterDistance;
static function SaveSliders(float Fog,int Distance)
{
    Fog=FClamp(Fog,0,2);
    Distance=Clamp(Distance,0,16000);
    if (Default.bHasSliders && Default.FogRatio == Fog && Default.FilterDistance == Distance) return;
    Default.bHasSliders=True;
    Default.FogRatio=Fog;
    Default.FilterDistance=Distance;
    StaticSaveConfig();
}
static function RestoreSliders(PlayerController P)
{
    if (P == None || P.bDeleteMe || !Default.bHasSliders) return;
    P.ConsoleCommand("SETOPTIONF FogRatio"@Default.FogRatio);
    P.ConsoleCommand("SETOPTIONF FilterDistance"@Default.FilterDistance);
}

defaultproperties
{
}
