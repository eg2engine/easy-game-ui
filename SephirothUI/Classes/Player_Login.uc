class Player_Login extends ClientController;

auto state WaitingLogin
{
}

event NetRecv_LoginResult(string Result, int Reason)
{
	local string LobbyURL;
	if (Result == "Success") {

		Hud_Login(myHud).Destroy();
		Game_Login(Level.Game).LobbyURLInfo(LobbyURL);
		if (LobbyURL != "")
			ClientTravel(LobbyURL,TRAVEL_Absolute,false);
		return;
	}
	Hud_Login(myHud).SetLoginResult(Result, Reason);
}

event NetRecv_BanchLoginResult(string Result, int Reason)
{
	//local string LobbyURL;
	if (Result == "Success") {

		Hud_Login(myHud).Destroy();
		//Game_Login(Level.Game).LobbyURLInfo(LobbyURL);
		//if (LobbyURL != "")
		//	ClientTravel(LobbyURL,TRAVEL_Absolute,false);
		return;
	}
	Hud_Login(myHud).SetLoginResult(Result, Reason);
}

event NetRecv_ConnectResult(string Result)
{
	local string Foo;
	local int Space;
	local float CurrentTick,TimeLimit;

	Space = InStr(Result," ");
	if (Space != -1) {
		if (Left(Result,Space) == "CONNECTING") {
			Foo = Mid(Result,Space+1);
			Space = InStr(Foo," ");
			if (Space != -1) {
				CurrentTick = float(Left(Foo,Space));
				TimeLimit = float(Mid(Foo,Space+1));
				Hud_Login(myHud).ConnectTick(CurrentTick,TimeLimit);
			}
		}
		else
			Hud_Login(myHud).SetLoginResult(Result, 0);
	}
	else
		Hud_Login(myHud).SetLoginResult(Result, 0);
}

defaultproperties
{
}
