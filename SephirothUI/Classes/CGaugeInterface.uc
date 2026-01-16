class CGaugeInterface extends CInterface
	Abstract;
/***********************
	This class is a base class for our HP/MP Gauge Interface.
	Sephiroth has two different types of interface,	and each interface has own type of Gauge Interface.
	This is just base class. (So declared abstract type)
	We will use CGaugeInterface_Type1 and CGaugeInterface_Type2 to implement real instance of Sephiroth's Interface.
	Please check CGaugeInterface_Type1.uc and CGaugeInterface_Type2.uc.
	- 2009.11.10.Sinhyub
***********************/

//Gauge Position
var config float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;

//Move GageInterface (is called in SephirothInterface, maybe)
var int iOffsetX;
var int iOffsetY;
var bool bOnSimpleMode;

#exec texture import name=Keymap file=Textures/Keymap.tga mips=off flags=2

//Gauge effect
const ManaNormal = 0;
const ManaSaver = 1;
const ManaRebirth = 2;

// HP UI id
const ID_HP = 1;

// Effect id
const GAUGEEFFECT_NORMAL = 0;
const GAUGEEFFECT_POISON = 1;


function OnInit();
function OnFlush(){	SaveConfig(); }
function ScaleComponents(float ScaleX, optional float ScaleY)
{
	local int i;
	for(i=0;i<Components.Length;i++)
		ScaleComponent(Components[i], ScaleX, ScaleY);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta);
function Layout(Canvas C);

/*	�Ŀ� �ٱ�/�ȱ� ǥ���Ҷ� �������� �� �� ���ƿ�. -Sinhyub
function bool PushComponentBool(int CmpId)
{
	switch (CmpId) {
	case 5: // Run/Walk
		return SephirothPlayer(PlayerOwner).PSI.RunState;
	case 6: // Arm/Disarm
		return SephirothPlayer(PlayerOwner).PSI.ArmState;
	case 7: // SmoothCam/NoSmoothCam
		return bool(ConsoleCommand("GETOPTIONI TraceCamera"));
	}

	return false;
}
*/
function MoveGaugeInterface(int offsetX, int offsetY)
{
	iOffsetX = offsetX;
	iOffsetY = offsetY;
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	switch (CmpId) {
	case 1: // Health
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Health;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxHealth;
		break;
	case 2: // Mana
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Mana;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxMana;
		break;
	case 3: // Stamina
		V.X = 0;
		V.Y = SephirothPlayer(PlayerOwner).PSI.Stamina;
		V.Z = SephirothPlayer(PlayerOwner).PSI.MaxStamina;
		break;
	}
	return V;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command);
function OnPreRender(Canvas C);
function OnPostRender(HUD H, Canvas C);

function UpdateManaGauge();// keios - hp ���� ����
function UpdateHPGauge();

function ResetDefaultPosition()
{
	local string Resolution;
	local int pos;
	local int ClipX,ClipY;

	Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");	
	pos = InStr(Resolution, "x");

	ClipX=int(Left(Resolution, pos));
	ClipY=int(Mid(Resolution,pos+1));
	
	if(ClipX == 800) {
		PageX = 2;
		PageY = 2;
	}
	else if(ClipX==1024)	{
		PageX = 2;
		PageY = 2;
	}
	else{
		PageX = ClipX/2 - 727/2 - Components[0].XL;
		PageY = ClipY - Components[0].YL;
	}
	bNeedLayoutUpdate = true;
	SaveConfig();
}

defaultproperties
{
}
