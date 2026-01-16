class CLobbyInfo extends GameInfo
	config;

var globalconfig string LoginURL;
var SkillBook BareHandSkillAnimation, BareFootSkillAnimation, OneHandSkillAnimation, StaffSkillAnimation, BowSkillAnimation;

event PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);
	NewPlayer.ConsoleCommand("LobbyStart");

	BareHandSkillAnimation = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BareHandBook",class'Class'));
	BareFootSkillAnimation = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BareFootBook",class'Class'));
	OneHandSkillAnimation = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.OneHandBook",class'Class'));
	StaffSkillAnimation = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.StaffBook",class'Class'));
	BowSkillAnimation = new(None) class<SkillBook>(DynamicLoadObject("SkillBooks.BowBook",class'Class'));
}

event Destroyed()
{
	Super.Destroyed();
	DynamicUnloadObject(BareHandSkillAnimation);
	DynamicUnloadObject(BareFootSkillAnimation);
	DynamicUnloadObject(OneHandSkillAnimation);
	DynamicUnloadObject(StaffSkillAnimation);
	DynamicUnloadObject(BowSkillAnimation);
}

function LoginURLInfo(out string URL)
{
	URL = LoginURL;
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

defaultproperties
{
     HUDType="SephirothUI.CLobby"
     PlayerControllerClassName="SephirothUI.CLobbyController"
}
