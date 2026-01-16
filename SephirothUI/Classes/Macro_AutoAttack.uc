class Macro_AutoAttack extends UnitTest
	config(TestConfig);

/*
var int Turn;

event Timer()
{
	Turn = (Turn + 1) % 2;
	if (Turn == 0)
		Interface.Controller.KeyEvent(IK_Ctrl, IST_Release, 0);
	if (Turn == 1)
		Interface.Controller.KeyEvent(IK_LeftMouse, IST_Press, 0);
}

event Tick(float DeltaTime)
{
	SephirothPlayer(Interface.PlayerOwner).ConsoleCommand("Axis aBaseY  Speed=+1200.0");
}

defaultproperties
{
	TestTimer=0.1
}
*/

defaultproperties
{
}
