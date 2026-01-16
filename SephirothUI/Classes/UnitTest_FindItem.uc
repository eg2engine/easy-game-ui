class UnitTest_FindItem extends UnitTest;

event Timer()
{
	SephirothPlayer(Interface.PlayerOwner).FindNearestItem();
}

defaultproperties
{
     TestTimer=0.500000
}
