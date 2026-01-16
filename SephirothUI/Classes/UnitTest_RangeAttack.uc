class UnitTest_RangeAttack extends UnitTest;

var int count;
var int unit_count;

event Timer()
{
	count++;
	if(count < unit_count)
		SephirothPlayer(Interface.PlayerOwner).FindAndRangeAttack(0);
	else if(count < unit_count*2)
		SephirothPlayer(Interface.PlayerOwner).FindAndRangeAttack(1);
	else if(count < unit_count*3)
		SephirothPlayer(Interface.PlayerOwner).FindAndRangeAttack(2);
	else if(count < unit_count*4)
		SephirothPlayer(Interface.PlayerOwner).FindAndRangeAttack(3);
	else if(count == unit_count*4)
		count=0;
}

defaultproperties
{
     unit_count=25
     TestTimer=0.300000
}
