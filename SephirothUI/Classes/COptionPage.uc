class COptionPage extends CPage;

function LoadOption();
function SaveOption();

function ApplyOption()
{
	ConsoleCommand("SAVEOPTION");
	ConsoleCommand("APPLYOPTION");
}

function UpdateComponents();

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoadOption();
	UpdateComponents();
}

function OnPreRender(Canvas C)
{
	LoadOption();
	UpdateComponents();
}

function Apply()
{
	SaveOption();
	ApplyOption();
}

defaultproperties
{
}
