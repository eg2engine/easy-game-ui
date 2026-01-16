class SephirothLocalPlayer extends NephilimPlayer;

function Possess(Pawn aPawn)
{
	Super.Possess(Pawn);
	PSI = spawn(class'PlayerServerInfo');
	if (PSI != None)
		PSI.RunState = true;
	ConsoleCommand("HACKCONSOLE");
	SetBehindFreeView();
}

exec function R()
{
	PSI.RunState = true;
}

exec function W()
{
	PSI.RunState = false;
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

defaultproperties
{
}
