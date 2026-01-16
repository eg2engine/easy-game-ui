class UnitTest_MeleeAttack extends UnitTest;

event Timer()
{
	SephirothPlayer(Interface.PlayerOwner).FindNearestMonster();
}

defaultproperties
{
     TestTimer=0.300000
}
