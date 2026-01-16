class SephirothGame extends GameManager
	config;

var globalconfig string ServerGroupName;
var globalconfig int ServerSetId;
var globalconfig string ServerSetInfo;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Environments[0] = Spawn(class'HumanEnvironment');
	Environments[1] = Spawn(class'NephilimEnvironment');
	Environments[2] = Spawn(class'TitaanEnvironment');
	Environments[3] = Spawn(class'IceLandEnvironment');
	Environments[4] = Spawn(class'GhostTownEnvironment');
}

event Destroyed()
{
	Super.Destroyed();
	Environments[0].Destroy();
	Environments[1].Destroy();
	Environments[2].Destroy();
	Environments[3].Destroy();
}

function GetServerId(out string Sg, out int Si)
{
	local string LocalServerGroup;
	local int ServerIndex;
	LocalServerGroup = ConsoleCommand("ServerSetName");
	ServerIndex = int(ConsoleCommand("ServerSetID"));
	Sg = LocalServerGroup;
	Si = ServerIndex;
}

//function GetServerInfo(out string ServerGroup, out int ServerIndex, out array<string> IpList)
function GetServerInfoEx(out string outServerGroup, out int ServerIndex, out array<string> IpList)
{
	IpList.Remove(0,IpList.Length);
	if (ServerSetInfo != "")
		class'CNativeInterface'.static.WrapStringToArray(ServerSetInfo, IpList, 10000, "|");
	ServerGroupName = ConsoleCommand("ServerSetName");
	ServerSetId = int(ConsoleCommand("ServerSetID"));
	outServerGroup = ServerGroupName;
	ServerIndex = ServerSetId - 1;
}

defaultproperties
{
     HUDType="SephirothUI.SephirothInterface"
     PlayerControllerClass=Class'SephirothUI.SephirothPlayer'
}
