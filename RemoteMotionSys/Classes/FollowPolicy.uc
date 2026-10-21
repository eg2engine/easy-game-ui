class FollowPolicy extends Object;
static function float Speed(float Distance,float TargetAlong,float OwnMax,bool WasMoving)
{
    if (Distance<=300 || OwnMax<=0) return 0;
    if (!WasMoving && TargetAlong<1 && Distance<=420) return 0;
    return FClamp(FMax(TargetAlong,0)+(Distance-350)*3,0,OwnMax);
}

defaultproperties
{
}
