class UnitTest_SummonSpirit extends UnitTest;



event Timer()
{
	local NephilimPlayer CC;
	CC = NephilimPlayer(Interface.PlayerOwner);
	if( CC != None )
			CC.DoSummonSpirit();
}

defaultproperties
{
     TestTimer=6.000000
}
