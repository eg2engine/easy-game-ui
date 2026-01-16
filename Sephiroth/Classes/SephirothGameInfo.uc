class SephirothGameInfo extends GameInfo
	native;	// keios - cuz of compile error

var BaseGUIController GUIController;
var string MainMenuClass;

event PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);
	if (MainMenuClass != "" && NewPlayer.Player != None && NewPlayer.Player.InteractionMaster != None) {
		GUIController = BaseGUIController(NewPlayer.Player.InteractionMaster.AddInteraction(
			"XInterface.GUIController", None
			));
		//Log(Self @ "initialized GUI Controller" @ GUIController);
		if (GUIController != None) {
			GUIController.ViewportOwner = NewPlayer.Player;
			GUIController.InitializeController();
			GUIController.OpenMenu(MainMenuClass, "", "");
			//Log(GUIController @ "open Main Menu" @ MainMenuClass);
		}
	}
}

defaultproperties
{
     bDelayedStart=False
}
