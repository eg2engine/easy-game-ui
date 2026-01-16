class CLobbyController extends ClientController;


state auto NoWalking
{
}

exec function SetBehindFreeView()
{
	MinCameraDist = 10;
	MaxCameraDist = 40;
	CameraDist = 11;
	SetFOV(60);
	ViewType = BehindFree;
}

exec function SetQuaterView()
{
}

exec function SetFirstPersonView()
{
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	if (!bCameraSet)
	{
		SetBehindFreeView();
		bCameraSet = true;
	}

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

event NetRecv_NewCharacterResult(string Result)
{
	CLobby(myHud).NewCharacterResult(Result);
}

event NetRecv_StartPlayResult(string Result)
{
	CLobby(myHud).StartPlayResult(Result);
}

event NetRecv_Disconnected(string Result)
{
	CLobby(myHud).OnDisconnected();
}

event NetRecv_DisconnectError(string Result)
{
	CLobby(myHud).OnDisconnected(Result);
}

defaultproperties
{
     CheatClass=None
}
