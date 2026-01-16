class PetController extends AIController
	native;

var bool bActionPlaying;
//var Actor Target;
var bool bDead;

function bool CanStop(float Distance);

event Tick(float DeltaTime)
{
	//MovePet(Character(Owner).Controller.Destination);
	PetMoving();
}

function PetMoving();

function RecallPet()
{
	local vector PetDest;

	PetDest = Character(Owner).Location + (Guardian(Pawn).LocationOffset >> Character(Owner).Rotation);
	PetDest.Z = Pawn.Location.Z;

	Destination = PetDest;
	Pawn.SetRotation(Rotator(PetDest - Pawn.Location));
	Guardian(Pawn).GroundSpeed = Character(Owner).GroundSpeed;
	if(bActionPlaying)
		bActionPlaying = false;
	GotoState('PetWalking','Begin');
}

function MovePet(vector Dest)
{
	local vector PetDest;

	PetDest = Character(Owner).Location + (Guardian(Pawn).LocationOffset >> Character(Owner).Rotation);
	PetDest.Z = Pawn.Location.Z;
	
	if(Dest != vect(0,0,0) && !CanStop(VSize(PetDest-Pawn.Location)))
	{
		Destination = PetDest;
		if(!Hero(Owner).IsJumping())
			Pawn.SetRotation(Rotator(PetDest - Pawn.Location));
		Guardian(Pawn).GroundSpeed = Character(Owner).GroundSpeed;
		GotoState('PetWalking','Begin');
	}
}

event PetRevive()
{
	bActionPlaying = false;
	if (Pawn != None && !Pawn.bDeleteMe)
	Guardian(Pawn).PET_PlayWaiting();
}

function PetAction(name AnimName)
{
	bActionPlaying = true;
	if (Pawn != None && !Pawn.bDeleteMe)
	Guardian(Pawn).PET_PlayAction(AnimName);
}

function SetPetPosition()
{
	if (Pawn != None && !Pawn.bDeleteMe)
		Destination = Character(Owner).Location + (Guardian(Pawn).LocationOffset >> Character(Owner).Rotation);
}

function HitDetect();

auto state PetWalking
{
	function AnimEnd(int Channel)
	{
		local float AnimRate, AnimFrame;
		local name AnimName;

		if(Pawn != None && !Pawn.bDeleteMe) {
			Pawn.GetAnimParams(0,AnimName, AnimFrame, AnimRate);
			if(AnimName == 'Die'){
				return;
			}
			if(Channel == 0 && !Character(Owner).bIsDead && !Character(Owner).bDeleteMe) {
				if(Guardian(Pawn).PET_AlreadyPlayingWaiting(AnimName))
					Guardian(Pawn).PET_PlayWaiting();
				else if (bActionPlaying){
					//Guardian(Pawn).PET_TweenToWaiting(0.01);
					Guardian(Pawn).PET_PlayWaiting();
					SetPetPosition();
					Guardian(Pawn).SetLocation(Destination);
					bActionPlaying = false;
				}
				else {
					if(Hero(Owner).bIsWalking)
						Guardian(Pawn).PET_PlayWalking();
					else
						Guardian(Pawn).PET_PlayRunning();
				}
			}
		}
	}
	function bool CanStop(float Distance) { return Distance < 30; }

	function PetMoving()
	{
		local float vectDest;
		local float AnimRate, AnimFrame, OwnerAnimRate, OwnerAnimFrame;
		local name AnimName;
		local name OwnerAnimName;
		local vector ResetPos;

		if (Pawn == None || Pawn.bDeleteMe)
			return;

		Destination.Z = Pawn.Location.Z;
		vectDest = VSize(Destination - Pawn.Location);
		Pawn.GetAnimParams(0,AnimName,AnimFrame,AnimRate);
		Hero(Owner).GetAnimParams(0, OwnerAnimName, OwnerAnimFrame,OwnerAnimRate);

		if(bActionPlaying)
			return;
			
		//vectDest.Z = Pawn.Location.Z;
		if(VSize(Pawn.Location - Character(Owner).Location) >= 1000) {			
			ResetPos = Character(Owner).Location + (vect(0,100,0) >> Character(Owner).Rotation);
			Guardian(Pawn).SetLocation(ResetPos);
			ResetPos.Z = Pawn.Location.Z;
			Destination = ResetPos;
		}

//		if(OwnerAnimName == Hero(Owner).BasicAnim[3]){
//			//bActionPlaying = true;
//			Guardian(Pawn).PET_PlayInAir();
//		}
//		else 
		if(CanStop(vectDest)) {
			if(Guardian(Pawn).PET_AlreadyPlayingWaiting(AnimName))
				Guardian(Pawn).PET_PlayWaiting();
			else
				Guardian(Pawn).PET_TweenToWaiting(0.01);
			//Destination = Character(Owner).Location + (Guardian(Pawn).LocationOffset >> Character(Owner).Rotation);
			if(OwnerAnimName != Hero(Owner).BasicAnim[3])
			Pawn.SetRotation(Character(Owner).Rotation);
		}
		else {
			if(Hero(Owner).bIsWalking)
				Guardian(Pawn).PET_PlayWalking();
			else
				Guardian(Pawn).PET_PlayRunning();
			GotoState('PetWalking','Begin');
		}
	}
Begin:
	if(Pawn != None && !Pawn.bDeleteMe && !Character(Pawn).bIsDead) {
		//Log("=====>PetController MoveTo"@Destination);
		if(Destination != vect(0,0,0) && Destination != Pawn.Location) {
			//Guardian(Pawn).PET_TweenToRunning(0.01);
				MoveTo(Destination,None,Hero(Owner).bIsWalking);
			bActionPlaying = false;
		}
	}
}

defaultproperties
{
}
