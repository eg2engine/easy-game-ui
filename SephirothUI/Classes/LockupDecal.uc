class LockupDecal extends Actor;

var int MAXDECALS;

var actor LockupActor;
var vector LockupLocation;
var float ProjTextureSize;
var float CameraDistance;

var StaticMesh		PickingPoint;			// Xelloss
var Array<CDecal>	aDecals;

var enum EDecalState {
	DS_None,
	DS_Detecting,
	DS_Lockup,
	DS_Releasing
} DecalState;

var float FovBias;
var bool IsVoodoo;


function PostBeginPlay()
{
	local int i;

	if (Owner != None)
		IsVoodoo = bool(Owner.ConsoleCommand("IsVoodoo"));

	if (IsVoodoo)
		disable('Tick');

	PickingPoint = StaticMesh(DynamicLoadObject("JEF_Environment_ST.MovePoint_St1F", class'StaticMesh'));

	MAXDECALS = 3;
	aDecals.Insert(0, MAXDECALS);

	for ( i = 0 ; i < MAXDECALS ; i++ )
	{
		aDecals[i] = Spawn(class'CDecal');
		aDecals[i].SetMaterial("JEF_Environment_T.MovePoint_T"$(i+1)$"F");
	}
}


function Tick(float Delta)
{
	if (LockupActor != None && !LockupActor.bDeleteMe)
		UpdateDecal(Delta);
}


function UpdateDecal(float Delta)
{
	local int i;
	local float Radius;
	local float FOV_local;
	local vector vPos;
	local float fScale;
	
	if ( LockupActor != None && !LockupActor.bDeleteMe )	{
		
		Radius = LockupActor.CollisionRadius;
		FOV_local = Atan( Radius, CameraDistance) * 180 / PI + GetFovBias(Delta);

		if ( LockupActor.DrawType == DT_Mesh && LockupActor.Mesh != None )
			vPos = LockupActor.GetBoneCoords('').Origin + vect(0, 0, 50);
		else
			vPos = LockupActor.Location + vect(0, 0, 50);

	}
	else if ( LockupLocation != vect(0, 0, 0) )	{

		FOV_local = 30 + GetFovBias(Delta);
		vPos = LockupLocation + vect(0, 0, 100);
	}

	fScale = CameraDistance * tan(0.5 * FOV_local * PI / 180) / ProjTextureSize;
	SetLocation(LockupLocation);

	for ( i = 0 ; i < MAXDECALS ; i++ )	{
	
		aDecals[i].DetachProjector(true);

		if ((LockupActor == None || LockupActor.bDeleteMe) && LockupLocation == vect(0,0,0))
			continue;

		if ( aDecals[i].ProjTexture == None && DecalState == DS_None )
			continue;

		aDecals[i].SetLocation(vPos);
		aDecals[i].SetRotation(Rotator(Normal(vect(0, 0, -1))));
		aDecals[i].SetDrawScale(fScale);

		aDecals[i].AttachProjector();
	}
}


function float GetFovBias(float Delta)
{
	switch (DecalState)	{

	case DS_Detecting :

		FovBias = (FovBias + 60.0f*Delta);
		break;

	case DS_Releasing:

		FovBias = (FovBias - 60.0f*Delta);
		break;
	}

	return FovBias;
}

function SetCameraDistance(float Distance)
{
	CameraDistance = Distance;

	if (LockupActor != None)
		CameraDistance = max(CameraDistance, LockupActor.Location.Z+30);
}


function SetLockupActor(actor Actor, optional vector Loc)
{
	local int i;

	if (IsVoodoo)
		return;

	LockupActor = Actor;
	LockupLocation = Loc;

	if (Actor != None && (Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor')))
		LockupActor = None;

	FovBias = 0;

	if (Actor == None && Loc == vect(0,0,0)) {

		for ( i = 0 ; i < MAXDECALS ; i++ )
			aDecals[i].ProjTexture = None;

		DecalState = DS_None;
		SetStaticMesh(None);
	}
	UpdateDecal(0);
}

function Detecting()
{
	local int i;

	for ( i = 0 ; i < MAXDECALS ; i++ )
		aDecals[i].ProjTexture = None;
	
	aDecals[0].ProjTexture = aDecals[0].DetectingMaterial;

	DecalState = DS_Detecting;
	ProjTextureSize = 256;
}

function Lockup()
{
	local int i;

	for ( i = 0 ; i < MAXDECALS ; i++ )
		aDecals[i].ProjTexture = None;
	
	aDecals[0].ProjTexture = aDecals[0].LockupMaterial;

	DecalState = DS_Lockup;
	ProjTextureSize = 256;
}

function Releasing()
{
	local int i;

	for ( i = 0 ; i < MAXDECALS ; i++ )
		aDecals[i].ProjTexture = None;
	
	aDecals[0].ProjTexture = aDecals[0].ReleasingMaterial;

	DecalState = DS_Releasing;
	ProjTextureSize = 256;
}

function Moving(vector InDir)
{
	local int i;
	local vector vDir, vLeft;

	// 노멀벡터를 이용하여 데칼을 위한 방향 벡터를 만든다.
	vLeft = InDir Cross vect(0, 0, 1);		// 노멀벡터의 X, Y를 고정하기 위해서 Z(UP)을 기준으로 크로스하여 Left벡터를 구하고
	vDir = InDir Cross vLeft;				// 다시 Left벡터와 노멀벡터를 크로스하면 기울어진 방향을 가리키는 전방벡터를 구할 수 있다.
	SetRotation(Rotator(vDir));

	if ( PickingPoint != None )
		SetStaticMesh(PickingPoint);

	for ( i = 0 ; i < MAXDECALS ; i++ )
		aDecals[i].ProjTexture = aDecals[i].TrackMaterial;

	DecalState = DS_None;
	ProjTextureSize = 256;
}

defaultproperties
{
     ProjTextureSize=256.000000
     CameraDistance=500.000000
     DrawType=DT_StaticMesh
     bUnlit=True
}
