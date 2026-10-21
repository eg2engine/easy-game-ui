class FreeviewSettings extends Object config(User);
var config int FreeviewDistance;
var config bool bHasAutoAngle;
// Shared by both camera modes; retain the     config key for compatibility.
var config rotator AutoAngle;
var rotator PendingAngle;
var float PendingSince;
var bool bPendingAngle;
static function CopySavedValues(FreeviewSettings Settings)
{
    Settings.FreeviewDistance=Default.FreeviewDistance;
    Settings.bHasAutoAngle=Default.bHasAutoAngle;
    Settings.AutoAngle=Default.AutoAngle;
}
static function SaveAngle(rotator Angle)
{
    Angle.Pitch=Angle.Pitch & 65535;
    Angle.Yaw=Angle.Yaw & 65535;
    Angle.Roll=0;
    if (Default.bHasAutoAngle && Default.AutoAngle == Angle) return;
    Default.bHasAutoAngle=True;
    Default.AutoAngle=Angle;
    StaticSaveConfig();
}
static function ObserveAngle(rotator Angle,float Time)
{
    Angle.Pitch=Angle.Pitch & 65535;
    Angle.Yaw=Angle.Yaw & 65535;
    Angle.Roll=0;
    if (!Default.bPendingAngle || Default.PendingAngle != Angle || Time < Default.PendingSince)
    {
        Default.PendingAngle=Angle;
        Default.PendingSince=Time;
        Default.bPendingAngle=True;
        return;
    }
    if (Time-Default.PendingSince >= 0.3) SaveAngle(Angle);
}
static function int AutoDistanceForAngle(rotator Angle)
{
    local int Pitch;
    Pitch=Angle.Pitch & 65535;
    if (Pitch > 32767) Pitch-=65536;
    return Clamp(25.5-Pitch*15.0/8192.0,25,40);
}
static function int LoadDistance()
{
    return Clamp(Default.FreeviewDistance,5,200);
}
static function SaveDistance(int Distance)
{
    Distance=Clamp(Distance,5,200);
    if (Distance == Default.FreeviewDistance) return;
    Default.FreeviewDistance=Distance;
    StaticSaveConfig();
}

defaultproperties
{
     FreeviewDistance=20
}
