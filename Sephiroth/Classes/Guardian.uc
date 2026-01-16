class Guardian extends Character
	native;

var vector LocationOffset;
var name MeshName;
var name AnimationName;
var name PlayAnimName;

var INT PetPosition;
var INT PetHeight;
var INT PetRadius;

var bool bJump;
var bool bChangePosition;

var Character OwnPlayer;

// Ag Blue 2023/7/17
var string tmp, Atext;
var name NullName;

enum PositionType{
	LeftStand,
	RightStand
};

// Ag Blue 2023/7/17

final function name StrToName(string AString)
{
	local Name TempName;
	tmp = AString;
	SetPropertyText("NullName",GetPropertyText("tmp"));
	TempName = NullName;
	NullName = '';
	tmp = "";
	return TempName;
}

function InitPetSize()
{
	local string PetName;
	local int Space;

	PetName = string(MeshName);	
	Space = InStr(PetName,"-");
	if(Space != -1)
		PetName = Left(PetName,Space);
//	else
//		PetName = string(MeshName);
	if(PetName == "Puppy_Black" || PetName == "Puppy_White" || PetName == "Puppy_Brown"){
		PetHeight = 21;
		PetRadius = 55;
	}
	else if(PetName == "Crid"){
		PetHeight = 53;
		PetRadius = 65;
	}
	else if(PetName == "GreenSkink"){
		PetHeight = 28;
		PetRadius = 70;
	}
	else if(PetName == "Martis"){
		PetHeight = 26;
		PetRadius = 55;
	}
	else if(PetName == "Coro"){
		PetHeight = 18;
		PetRadius = 65;
	}
	else if(PetName == "Banderscon"){
		PetHeight = 56;
		PetRadius = 90;
	}
	else if(PetName == "Coromon"){
		PetHeight = 37;
		PetRadius = 100;
	}
	else if(PetName == "Drake"){
		PetHeight = 80;
		PetRadius = 95;
	}
	else if(PetName == "MiniLycan"){

		PetHeight = 75;
		PetRadius = 108;
	}
}

function SetOwnPlayer(Character Player)
{
	OwnPlayer = Player;
}

function SetPosition(INT Position)
{	
	local vector Offset;

//	//Log("=====>SetPosition "$OwnPlayer);
	if(MeshName == 'Egg')
		return;
	
	switch(Position)
	{
		case PositionType.LeftStand:
			if(PetPosition == PositionType.LeftStand)
				return;
			Offset.Y = -1 * PetRadius;
			LocationOffset = Offset;
			break;

		case PositionType.RightStand:
			if(PetPosition == PositionType.RightStand)
				return;
			Offset.Y = PetRadius;
			LocationOffset = Offset;
			break;
	}
	PetPosition = Position;
	SetLocation(OwnPlayer.Location + (LocationOffset >> OwnPlayer.Rotation));
}

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native final function bool LoadModel(string NewMeshName, string NewAnimName);

function bool ChangePetMesh(string NewMeshName, string NewAnimName)
{
	if(LoadModel(NewMeshName, NewAnimName))
	{
		if(Shadow != None && !Shadow.bDeleteMe) {
			ShadowProjector(Shadow).ShadowActor = Self;
			ShadowProjector(Shadow).UpdateShadow();
		}
//		MeshName = name(NewMeshName);  // Modify by Blue 2023/7/17
		MeshName = StrToName(NewMeshName);
//		AnimationName = name(NewAnimName);  // Modify by Blue 2023/7/17
		AnimationName = StrToName(NewAnimName);
		InitPetSize();

		return true;
	}

	return false;
}
/*
event NetRecv_PetAction(string ActionName)
{
	PET_PlayAction(name(ActionName));
}
*/
function CHAR_LoopAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel)
{
}

function bool PET_AlreadyPlayingWaiting(name AnimName)
{
	return (AnimName == 'Idle');// || AnimName == 'RightStand');
}
function bool PET_ShouldTweenToMoving(name AnimName)
{
	if (OwnPlayer.bIsWalking)
		return (AnimName != 'Walk');
	else
	{
		if(MeshName == 'Coro')
			return (AnimName != 'Walk');
		else
			return (AnimName != 'Run');
	}
}
function PET_TweenToWaiting(float TweenTime)
{
//	if (PetPosition == PositionType.RightStand)
//		TweenAnim('RightStand',TweenTime);
//	else if (PetPosition == PositionType.LeftStand)
//		TweenAnim('LeftStand',TweenTime);
	//@by wj(040622)------
	if (bChangePosition) {
		if (PetPosition == PositionType.LeftStand)
			SetPosition(PositionType.RightStand);
		else if (PetPosition == PositionType.RightStand)
			SetPosition(PositionType.LeftStand);
		bChangePosition = false;
	}
	//--------------------
	TweenAnim('Idle',TweenTime);
}
function PET_TweenToRunning(float TweenTime)
{
	if (OwnPlayer.bIsWalking)
		TweenAnim('Walk',TweenTime*2);
	else
	{
		if(MeshName == 'Coro')
			TweenAnim('Walk',TweenTime);
		else
			TweenAnim('Run',TweenTime);
	}
}
function PET_TweenToWalking(float TweenTime)
{
	TweenAnim('Walk',TweenTime);
}
function PET_PlayWalking()
{
	local float Rate;
	Rate = OwnPlayer.AnimSpeed * 2;
	if(MeshName != '')
		LoopAnim('Walk',Rate,0.05);
}
function PET_PlayRunning()
{
	local float Rate;

	if (MeshName == 'Coro')
	{
		Rate = OwnPlayer.AnimSpeed * 2.2;
		LoopAnim('Walk',Rate,0.05);
	}
	else if(MeshName != '')
	{
		Rate = OwnPlayer.AnimSpeed * 1.8;
		LoopAnim('Run',Rate,0.05);
	}
}
function PET_PlayWaiting()
{
	if(bJump){
		bJump = false;
		if(Owner != None && !Owner.bDeleteMe && PetController(Owner).bActionPlaying)
			Petcontroller(Owner).bActionPlaying = false;
	}

	if (bChangePosition) {
		if (PetPosition == PositionType.LeftStand)
			SetPosition(PositionType.RightStand);
		else if (PetPosition == PositionType.RightStand)
			SetPosition(PositionType.LeftStand);
		bChangePosition = false;
	}

//	if (PetPosition == PositionType.RightStand)
//		LoopAnim('RightStand',1.0,0);
//	else if (PetPosition == PositionType.LeftStand)
//		LoopAnim('LeftStand',1.0,0);
	if(MeshName != '')
		LoopAnim('Idle',1.0,0);
}
function PET_PlayAction(name Anim)
{
	if (Anim == 'RightLeft' || Anim == 'LeftRight') {
		if (PetPosition == PositionType.LeftStand && Anim == 'RightLeft')
			return;
		if (PetPosition == PositionType.RightStand && Anim == 'LeftRight')
			return;
		bChangePosition = true;
	}
	PlayAnimName = Anim;
	PlayAnim(PlayAnimName, 1.0, 0.1);
}
function PlayPain()
{
	if (PlayAnimName != 'Hit')
		PET_PlayAction('Hit');
}
function PET_PlayInAir()
{
	if(PlayAnimName != 'Jump')
	{
		bJump = true;
		PET_PlayAction('Jump');
	}
}

defaultproperties
{
     ActionClass=None
     bNoShadow=True
     ControllerClass=None
     bCollideActors=False
     bProjTarget=False
}
