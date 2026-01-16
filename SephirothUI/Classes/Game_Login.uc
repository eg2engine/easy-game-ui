class Game_Login extends GameInfo
	config;

var globalconfig string ServerHost;
var globalconfig int ServerPort;
var string LobbyURL;
var globalconfig string Company;

var int LaunchingValue; 

function GameServerInfo(out string Host,out int Port)
{
	Host = ServerHost;
	Port = ServerPort;
	if(ServerPort > 10000)
		LaunchingValue = ServerPort % 100;
}

function GetHomeURL(out string URL, int LaunchingIndex)
{
	if(LaunchingIndex == 1)
		URL = Localize("WWW", "GameLampURL", "Sephiroth");
	else if(LaunchingIndex == 2)
		URL = Localize("WWW", "Club5678URL", "Sephiroth");
	else
		URL = Localize("WWW", "SmileGateURL", "Sephiroth");
}

function GetShopURL(out string URL)
{
	if(LaunchingValue == 1)
		URL = Localize("WWW", "GameLampURL", "Sephiroth");
	else if(LaunchingValue == 2)
		URL = Localize("WWW", "Club5678URL", "Sephiroth");
	else
		URL = Localize("WWW", "SmileGateURL", "Sephiroth");	
}

function SettlementURLInfo(out string URL)
{
	URL = Localize("WWW", "SettlementURL" $ Company, "Sephiroth");
}

function LobbyURLInfo(out string URL)
{
	URL = LobbyURL;
}

defaultproperties
{
     LobbyURL="Gray_SEL?Game=SephirothUI.CLobbyInfo"
     HUDType="SephirothUI.Hud_Login"
     PlayerControllerClassName="SephirothUI.Player_Login"
}
