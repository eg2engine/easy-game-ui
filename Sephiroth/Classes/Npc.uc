class NPC extends Creature;

var Pawn DialogPawn;
var SepNetInterface Net;
var bool bJustDialogStarted;

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	SetPhysics(PHYS_None);
}

event Destroyed()
{
	Super.Destroyed();

	if ( sInfoMesh != None )
	{
		sInfoMesh.Destroy();
		sInfoMesh = None;
	}
}


function Tick(float Delta)
{
	local vector vLook;
	local rotator tRot;

	if ( GameManager(Controller.Level.Game).PlayerOwner == None )
		return;

	vLook = GameManager(Controller.Level.Game).PlayerOwner.Location - Location;

	tRot = rotator(vLook);
	tRot.Pitch = 0;
	tRot.Roll = 0;
	tRot.Yaw = (tRot.Yaw + 16384) % 65536;

	if ( sInfoMesh != None )
	{
		sInfoMesh.SetRotation(tRot);
	}
}


function StartDialog(ClientController Player)
{
	DialogPawn = Player.Pawn;
	Net = Player.Net;
	GotoState('Dialog','Start');
}

function FinishDialog()
{
	DialogPawn = None;
	Net = None;
	GotoState('');
}

function Talk();
function ServiceDialog(string DialogMsg);

state Dialog
{
	function BeginState()
	{
//		local rotator Rot;
		if (DialogPawn == None)
			GotoState('');
		else {
			bJustDialogStarted = true;
			Net.NotiNpcDialog(ServerController(Controller).MSI.PanID, "");
		}
	}
	function EndState()
	{
		bJustDialogStarted = false;
	}
	function Talk()
	{
		if (HasAnim('Talk'))
			PlayAnim('Talk');
	}
	function ServiceDialog(string DialogMsg)
	{
		Net.NotiNpcDialog(ServerController(Controller).MSI.PanID, DialogMsg);
	}
Start:
	if (DialogPawn == None)
		GotoState('');
	else if (!bJustDialogStarted)
		Net.NotiNpcDialog(ServerController(Controller).MSI.PanID, "");
	bJustDialogStarted = false;
}

function DrawName(Canvas C,int X,int Y,int XL,int YL)
{
	local string MyName;

	MyName = NpcServerInfo(ServerController(Controller).MSI).FullnameLocalized;
	C.SetKoreanFont(0);
	C.SetKoreanTextAlign(C.DT_Center|C.DT_VCenter);
	C.DrawKoreanText(MyName,X,Y,XL,YL);
}

function DrawInfo(Canvas C,int X,int Y,int XL,int YL)
{
	local string TheName;
	TheName = "["$NpcServerInfo(ServerController(Controller).MSI).PanID$"]";
	TheName = TheName$NpcServerInfo(ServerController(Controller).MSI).FullnameLocalized;
	C.SetKoreanFont(0);
	C.SetKoreanTextAlign(C.DT_Center|C.DT_VCenter);
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(NpcServerInfo(ServerController(Controller).MSI).FullnameLocalized,X,Y,XL,YL);
}

defaultproperties
{
     DesiredSpeed=0.000000
     AppClassTag="'"
}
