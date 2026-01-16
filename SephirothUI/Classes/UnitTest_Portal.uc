class UnitTest_Portal extends UnitTest;

event Timer()
{
	local CMapInterface Interf;
	Interf = CMapInterface(Interface);
	if (Interf == None) {
		Finish();
		return;
	}
	Interf.TimerProc();
}

defaultproperties
{
     TestTimer=6.000000
}
