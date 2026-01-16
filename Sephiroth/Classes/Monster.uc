class Monster extends Creature;

var vector OldLocation;

//event Destroyed()
//{
//	Super.Destroyed();
//	if(!bIsDead)
//	{
//		//Log("Delete Error Monster"@self@MonsterServerInfo(ServerController(Controller).MSI).Fullname);
//	}
//}

function int GetPlayLevel()
{
	local MonsterServerInfo MSI;
	if (Controller != None) {
		MSI = MonsterServerInfo(ServerController(Controller).MSI);
		if (MSI != None)
			return MSI.nMonsterLevel;
	}
}


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( PatternInfo == None )
		PatternInfo = new(None) class'Pattern';

	if ( PatternInfo != None )
		EffController.eState = PS_FINISHED;

	bPatternAnimating = false;

	OldLocation = Location;
}


function PatternEffect()
{
	switch ( EffController.eState )
	{
	case PS_WAITING :

		if ( Controller.Level.TimeSeconds - EffController.timeStart >= PatternInfo.fEffDelay )
		{
			EffController.timeStart = Controller.Level.TimeSeconds;
			EffController.eState = PS_PLAYING;
			PlayPatternEffect(PatternInfo.strEffRes);
		}

		break;

	case PS_PLAYING :

		if ( Controller.Level.TimeSeconds - EffController.timeStart >= PatternInfo.fEffPlaying )
		{
			StopPatternEffect(PatternInfo.strEffRes);

			EffController.nCount--;

			if ( EffController.nCount <= 0 )
				EffController.eState = PS_FINISHED;
			else
				EffController.eState = PS_RESTING;
		}

		break;

	case PS_RESTING :

		if ( Controller.Level.TimeSeconds - EffController.timeStart >= PatternInfo.fEffInterval )
		{
			EffController.timeStart = Controller.Level.TimeSeconds;
			EffController.eState = PS_PLAYING;
			PlayPatternEffect(PatternInfo.strEffRes);
		}

		break;

	default :
		break;
	}
}


function PatternAnimation()
{
	switch ( AniController.eState )
	{
	case PS_WAITING :

		if ( Controller.Level.TimeSeconds - AniController.timeStart >= PatternInfo.fAniDelay )
		{
			bPatternAnimating = true;
			PlayAnim(PatternInfo.strAniRes, 1.0, 0.3);
//			PlayAnim('KnockBack', 1.0, 0.3);
			AniController.timeStart = Controller.Level.TimeSeconds;
			AniController.eState = PS_PLAYING;
		}

		break;

	case PS_PLAYING :

		if ( Controller.Level.TimeSeconds - AniController.timeStart >= PatternInfo.fAniPlaying )
		{
			AniController.nCount--;
			bPatternAnimating = false;

			if ( AniController.nCount <= 0 )
				AniController.eState = PS_FINISHED;
			else
				AniController.eState = PS_RESTING;
		}

		break;

	case PS_RESTING :

		if ( Controller.Level.TimeSeconds - AniController.timeStart >= PatternInfo.fAniInterval )
		{
			PlayAnim(PatternInfo.strAniRes, 1.0, 0.3);
//			PlayAnim('Knockback', 1.0, 0.3);
			bPatternAnimating = true;

			AniController.timeStart = Controller.Level.TimeSeconds;
			AniController.eState = PS_PLAYING;
		}

		break;

	default :
		break;
	}
}


/*
function PatternAnimation()
{
	switch ( AniController.eState )
	{
	case PS_WAITING :

		if ( Controller.Level.TimeSeconds - AniController.timeStart >= PatternInfo.fAniDelay )
		{
			PlayAnim(PatternInfo.strAniRes, 1.0, 0.3);
//			PlayAnim('KnockBack', 1.0, 0.3);

			AniController.timeStart = Controller.Level.TimeSeconds;
			AniController.nCount--;

			if ( AniController.nCount <= 0 )
				AniController.eState = PS_FINISHED;
			else
			{
				AniController.eState = PS_RESTING;
				bPatternAnimating = true;
				//Log("Xelloss : Pattern Animation Start"@Controller.Level.TimeSeconds);
			}
		}

		break;

	case PS_RESTING :

		if ( Controller.Level.TimeSeconds - AniController.timeStart >= PatternInfo.fAniInterval )
		{
			PlayAnim(PatternInfo.strAniRes, 1.0, 0.3);
//			PlayAnim('Knockback', 1.0, 0.3);

			AniController.timeStart = Controller.Level.TimeSeconds;
			AniController.nCount--;

			if ( AniController.nCount <= 0 )
				AniController.eState = PS_FINISHED;
		}

		break;

	default :
		break;
	}
}
*/

function PatternSound()
{
	Local Sound PatternSound;

	switch ( SndController.eState )
	{
	case PS_WAITING :

		if ( Controller.Level.TimeSeconds - SndController.timeStart >= PatternInfo.fSndDelay )
		{
			PatternSound = Sound(DynamicLoadObject(PatternInfo.strSndRes, class'Sound'));
		
			if ( PatternSound != None )
				PlaySound(PatternSound);

			SndController.timeStart = Controller.Level.TimeSeconds;
			SndController.nCount--;

			if ( SndController.nCount <= 0 )
				SndController.eState = PS_FINISHED;
			else
			{
				SndController.eState = PS_RESTING;
			}
		}

		break;

	case PS_RESTING :

		if ( Controller.Level.TimeSeconds - SndController.timeStart >= PatternInfo.fSndInterval )
		{
			PatternSound = Sound(DynamicLoadObject(PatternInfo.strSndRes, class'Sound'));
		
			if ( PatternSound != None )
				PlaySound(PatternSound, SLOT_Interact);

			SndController.timeStart = Controller.Level.TimeSeconds;
			SndController.nCount--;

			if ( SndController.nCount <= 0 )
				SndController.eState = PS_FINISHED;
		}

		break;

	default :
		break;
	}
}


function PatternMessage()
{
	switch ( MsgController.eState )
	{
	case PS_WAITING :

		if ( Controller.Level.TimeSeconds - MsgController.timeStart >= PatternInfo.fMsgDelay )
		{
			PlayerController(Controller).myHud.AddMessage(255, PatternInfo.strMsgRes, class'Canvas'.static.MakeColor(255, 255, 255));

			MsgController.timeStart = Controller.Level.TimeSeconds;
			MsgController.nCount--;

			if ( MsgController.nCount <= 0 )
				MsgController.eState = PS_FINISHED;
			else
			{
				MsgController.eState = PS_RESTING;
			}
		}

		break;

	case PS_RESTING :

		if ( Controller.Level.TimeSeconds - MsgController.timeStart >= PatternInfo.fMsgInterval )
		{
			PlayerController(Controller).myHud.AddMessage(255, PatternInfo.strMsgRes, class'Canvas'.static.MakeColor(255, 255, 255));

			MsgController.timeStart = Controller.Level.TimeSeconds;
			MsgController.nCount--;

			if ( MsgController.nCount <= 0 )
				MsgController.eState = PS_FINISHED;
		}

		break;

	default :
		break;
	}
}


function Tick(float DeltaTime)
{
	local float fMonsterDist;
	if ( PatternInfo.strKey == "" )
		return;

	if ( PatternInfo.strEffRes != "" )
		PatternEffect();

	if ( PatternInfo.strAniRes != '' )
		PatternAnimation();

	if ( PatternInfo.strSndRes != "" )
		PatternSound();

//	if ( PatternInfo.strMsgRes != "" )
//		PatternMessage();

	fMonsterDist = VSize(OldLocation - Location);

	if(!bIsDead && fMonsterDist > 10.0f)
	{
		//Log("Position Error Monster"@self@MonsterServerInfo(ServerController(Controller).MSI).Fullname@"OLD Location"@OldLocation@"Current Location"@Location@fMonsterDist);
	}

	OldLocation = Location;

}


event AnimEnd(int Channel)
{
	Super.AnimEnd(Channel);

	if ( bPatternAnimating )
	{
		bPatternAnimating = false;
		AnimateStanding();
	}
}

defaultproperties
{
     ActionClass=Class'Sephiroth.MonsterAnimAction'
     BalloonDuration=10.000000
     AppClassTag="'"
}
