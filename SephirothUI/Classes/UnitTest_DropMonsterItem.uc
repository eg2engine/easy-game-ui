class UnitTest_DropMonsterItem extends UnitTest;

var name MonsterName;
var int SimulationCount, CurrentCount;

event Timer()
{
	if (SimulationCount > 0 && CurrentCount < SimulationCount) {
		SephirothPlayer(Interface.PlayerOwner).Net.NotiTell(1, "\\\\MonsterDropItem" @ string(MonsterName));
		CurrentCount++;
	}
	else {
		SimulationCount = 0;
		CurrentCount = 0;
	}
}

defaultproperties
{
     TestTimer=0.300000
}
