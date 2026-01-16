class UnitTest extends Actor
	config(TestConfig);

var config float TestTimer;
var bool bTesting;
var CInterface Interface;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (TestTimer == 0.0)
		TestTimer = Default.TestTimer;
	SaveConfig();
}

function Start(CInterface InInterface)
{
	Interface = InInterface;
	bTesting = true;
	SetTimer(TestTimer, True);
	//Log(Self @ "Starting UnitTest" @ TestTimer @ "with" @ Interface);
}

function SetTime(float InTimer)
{
	TestTimer = InTimer;
	SaveConfig();
	if (bTesting)
		SetTimer(TestTimer, True);
}

function Finish()
{
	SetTimer(0, False);
	bTesting = false;
	//Log(Self @ "Finishing UnitTest" @ TestTimer);
}

event Timer()
{
	//Log(Self @ "Timer");
}

defaultproperties
{
     TestTimer=4.000000
}
