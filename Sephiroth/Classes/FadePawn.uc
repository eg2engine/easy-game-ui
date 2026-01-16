class FadePawn extends Pawn
	native;

var float Time;
var color FadeColor;
var bool FadeIn;
var float FadeInEndTime;
var bool FadeOut;
var float FadeOutStartTime;
var vector SpawnOffset;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	AdjustLocation();
}

function AdjustLocation()
{
	local vector X, Y, Z;
	GetAxes(Owner.Rotation, X, Y, Z);
	SetLocation(Owner.Location+SpawnOffset.X*X+SpawnOffset.Y*Y+SpawnOffset.Z*Z);
}

defaultproperties
{
     FadeColor=(B=255,G=255,R=255,A=255)
     SpawnOffset=(X=-100.000000)
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
}
