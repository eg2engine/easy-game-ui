class UnitTest_Interface extends UnitTest;

event Timer()
{
	local int Tick;
	local SephirothInterface Interf;

	Interf = SephirothInterface(Interface);
	if (Interf == None) {
		Finish();
		return;
	}

	Tick = Rand(25);

	switch (Tick) {
	case 0:
		Interf.ShowInventoryBag();
		break;
	case 1:
		Interf.ShowSkillTree();
		break;
	case 2:
		Interf.ShowInfo();
		break;
	case 3:
		Interf.ShowMainInterface();
		break;
	case 4:
		Interf.ShowChannelManager();
		break;
	case 5:
		Interf.ShowMinimap();
		break;
	case 6:
		Interf.ShowQuest();
		break;
	case 7:
		Interf.ShowPortal();
		break;
	case 8:
		Interf.HideInfo();
		break;
	case 9:
		Interf.HideMainInterface();
		break;
	case 10:
		Interf.HideChannelManager();
		break;
	case 11:
		Interf.HideMinimap();
		break;
	case 12:
		Interf.ShowMessenger();
		break;
	case 13:
		Interf.HideMessenger();
		break;
	case 14:
		Interf.ShowOption();
		break;
	case 15:
		Interf.HideOption();
		break;
	case 16:
		Interf.ShowAnimationMenu();
		break;
	case 17:
		Interf.HideAnimationMenu();
		break;
	case 18:
		Interf.ShowMainMenu();
		break;
	case 19:
		Interf.HideMainMenu();
		break;
	case 20:
		Interf.ShowDialog();
		break;
	case 21:
		Interf.HideDialog();
		break;
	case 22:
		Interf.ShowExchange();
		break;
	case 23:
		Interf.ShowCompound();
		break;
	case 24:
		Interf.ShowStore();
		break;
	}
}

defaultproperties
{
     TestTimer=3.000000
}
