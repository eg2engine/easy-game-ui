class NephilimPlayer extends SephirothPlayer;

var bool bFireComplete;
var int FireCompleteNum;
var SpiritType SpiritType;
var string CurrentSpiritName;

var struct UsedSkillType
	{
		var int Seq;
		var string Name;
	} 
	UsedSkill;

function MovePawnToAttackBow(Actor Target, vector Loc)
{
	if ( CoolTime >= 0 )
		return;

	if ( ZSI != None && ZSI.bNoUseSkill )
		return;

	if( PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� �������� �ʱ�
	{
		LockedTarget = None;	   //�������� ���ϰ� �԰� ���ÿ� Ÿ�� ���� Ǭ��
		return ;
	}

//	if (LockedTarget == None)
	LockedTarget = Character(Target);

	if ( LockedTarget != None && !LockedTarget.bDeleteMe && !LockedTarget.bIsDead ) 
	{
		RotatePawnTo(Target.Location);
		GotoState('BowAttacking','PullString');
	}
}

function bool MovePawnToAttackRange(Actor Target, vector Loc)
{
	/* do not affect from CoolTime */
	if ( Target == Pawn && PSI.JobName == 'Bow' ) 
	{
		GotoState('SummonSpirit', 'Summon');
		return True;
	}
	else
		/* CoolTime affects Super's */
		return Super.MovePawnToAttackRange(Target, Loc);
}

//add neive : ��ü ���� ������ ����Ű�� �ڱ⿡�� ���� �Ѵ� --------------------
function bool SelfBuff()
{
    if (class'BowAttackRuntime.RoundStore'.static.SupportActive(Self)) return True;
	if( PSI.JobName == 'Bow' )
	{
		GotoState('SummonSpirit', 'Summon');
		return True;		
	}

	if( PSI.JobName == 'Red' || PSI.JobName == 'Blue' )
	{
		if ( PSI.Magic.bSelf )
		{
			LockedTarget = Character(Pawn);
			GotoState('RangeAttacking','Attack');
			return True;
		}
	}
}
//-----------------------------------------------------------------------------


function Pull(Skill Skill, Actor TargetActor, float GivenSpeed)
{
    local Pawn MovePawn;
    local vector MoveVelocity,MoveAcceleration,MoveDestination;
    local float MoveDesired,MoveGroundSpeed;
    local Actor.EPhysics MovePhysics;
    local bool HoldMovement,MoveMouse,MoveSync;

	local BowSkill BowSkill;
	local name ShotName;
	local float Speed;
	// ryu dualcore
	local array<float> notifyTime;
	local int notifyAniChannel;
	local float EndTime;
	local int i;
	local int TimeCount;
    HoldMovement=IsRemotePlayerPawn() && Pawn!=None && !Pawn.bDeleteMe
        && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive && !Character(Pawn).bIsDead
        && !IsRemoteHardControlActive() && !IsRemoteSkillDashLockActive();
    if (HoldMovement)
    {
        MovePawn=Pawn; MovePhysics=Pawn.Physics;
        MoveVelocity=Pawn.Velocity; MoveAcceleration=Pawn.Acceleration;
        MoveDesired=Pawn.DesiredSpeed; MoveGroundSpeed=Pawn.GroundSpeed;
        MoveDestination=Destination; MoveMouse=bMouseMove; MoveSync=bSyncingPosition;
        Pawn.bCanStrafe=True;
    }

	//====================

	if ( TargetActor == None || Skill == None )
		{
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }

	if( PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� Ȱ���� ����			
		{
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }

	if ( Net != None ) 
	{
		if ( Hero(Pawn).GetRightHand() == None || Hero(Pawn).GetLeftHand() == None || BowSkill(PSI.Combo) == None ) 
		{
			if ( Hero(Pawn).GetLeftHand() == None )
				myHud.AddMessage(2, Localize("Warnings","NeedQuiver","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
		}
		if ( PSI.Combo.bHasSkillPoint && PSI.Combo.SkillPoint == 0 ) 
		{
			myHud.AddMessage(2, Localize("Warnings","NeedSkillPoint","Sephiroth")@PSI.Combo.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
		}
	}

	BowSkill = BowSkill(Skill);
	RotatePawnTo(TargetActor.Location);
	BowSkill.bParabola = False;
	if ( Hero(Pawn).GetRightHand().IsA('CrossBow') )
		ShotName = 'ShotC';
	else
		ShotName = 'Shot';

	if ( Net != None ) 
	{
		NotifyPull(Skill, TargetActor);
		bIsActing = True;
	}

	if ( GivenSpeed == 0 && Skill.MeleeAttackTime > 0.0 )
		Speed = Skill.MeleeAttackTime / 1000.0;
	else
		Speed = GivenSpeed;

	// ryu dualcore
//	//Log("Pull IN 1"@class@AppSeconds()@ArStepTime.Length,'RYU TEST');
	if( ArStepTime.Length > 0 )
		ArStepTime.Remove(0,ArStepTime.Length);

//	Character(Pawn).PlayAnimAction(ShotName,-1,Speed,0);
	Character(Pawn).GetPlayAnimAction(ShotName,notifyAniChannel,notifyTime,EndTime, -1,Speed,0);

	TimeCount = 0;
	for( i = 0;i < notifyTime.Length;i++ )
	{
		if( notifyTime[i] > 0.01f )
		{
			ArStepTime[TimeCount++] = Level.TimeSeconds + notifyTime[i];
		}
	}
	AttackEndTime = Level.TimeSeconds + EndTime;
	AttackAniChannel = notifyAniChannel;
    if (IsRemotePlayerPawn() && PSI!=None) class'RemoteMotionSys.QueueIndex'.static.NoteAction(Self,PSI.PanID,1,ShotName);

	//Log("Pull IN "@class@Speed@EndTime@notifyTime[0]@Level.TimeSeconds@AttackEndTime@ArStepTime[0]@notifyTime.Length@ArStepTime.Length,'RYU TEST');
//	//Log("Pull IN 2"@class@AppSeconds(),'RYU TEST');
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
    if (!IsRemotePlayerPawn() && RoundSkill(Skill)!=None
        && notifyTime.Length>0)
        class'BowAttackRuntime.RoundStore'.static.Bind(Self,Skill,TargetActor,
            RoundSkill(Skill).ActionID,AttackAniChannel,AttackEndTime,ArStepTime[0]);

}

function NotifyPull(Skill Skill, Actor TargetActor)
{
	local int Seq, PanID;

	if ( Skill == None )
		return;

	if ( TargetActor == None || TargetActor.bDeleteMe )
		return;
	if ( Character(TargetActor) != None && Character(TargetActor).bIsDead )
		return;
	if ( SkillFrame.LastState != SkillFrame.STATE_None )
		SkillFrame.ResetSkillFrame();
	Seq = SkillFrame.AdvanceFrame();
	if ( Hero(TargetActor) != None )
		PanID = ClientController(Pawn(TargetActor).Controller).PSI.PanID;
	else if (Creature(TargetActor) != None)
		PanID = ServerController(Pawn(TargetActor).Controller).MSI.PanID;
	else
		PanID = 0;
//	//Log(Seq @ Self @ "NotifyPull" @ Skill);
	UsedSkill.Seq = Seq;
	UsedSkill.Name = Skill.SkillName;
    // Capture the locally generated ID before the native send can reenter.
    if (!IsRemotePlayerPawn() && RoundSkill(Skill)!=None
        && RoundSkill(Skill).Driver==Self && RoundSkill(Skill).Active)
        RoundSkill(Skill).ActionID=Seq;
	Net.NotiActRange(Skill.SkillName, Seq, PanID, TargetActor.Location,0);
	SkillFrame.NewSkillFrame(Seq,SkillFrame.STATE_Pull);
}

function FireBowOneShot(Skill Skill, Actor TargetActor)
{
	local class<EffectProjectile> FireClass;
	local EffectProjectile Shot;
	local vector SpawnLocation;
	local rotator SpawnRotation;
	local BowSkill BowSkill;
    local RoundSkill R;
    if (!IsRemotePlayerPawn())
    {
        R=RoundSkill(Skill);
        if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,Skill)
            || !R.Fired || FireCompleteNum<=0 || Level.TimeSeconds<R.NextArrowAt) return;
        TargetActor=R.RoundTarget;
    }


	if ( TargetActor == None || TargetActor.bDeleteMe ) 
	{
		GotoState('Navigating');
		return;
	}

	if( PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� ������ ����		
		return ;

	BowSkill = BowSkill(Skill);
	if ( BowSkill == None )
		return;
	FireClass = class<EffectProjectile>(Skill.FireClass);
	if ( FireClass != None ) 
	{
		SpawnLocation = Pawn.GetBoneCoords('Bip01 L Hand').Origin;
		SpawnRotation = Rotator(TargetActor.Location - SpawnLocation);
		Shot = Pawn.Spawn(FireClass,,,SpawnLocation,SpawnRotation);
		if ( Shot != None ) 
		{
			Shot.Instigator = Pawn;
			Shot.Shooter = Character(Pawn);
			Shot.TargetActor = TargetActor;
			//Shot.TargetLocation = TargetActor.Location;
			Shot.DamageType = BowSkill.DamageType;
			Shot.SkillName = BowSkill.SkillName;
			if ( SkillFrame != None )
				if (R!=None) Shot.ActionID=R.ActionID;
                else Shot.ActionID=SkillFrame.FindSkillFrame(SkillFrame.STATE_Pull);
			Shot.bGuided = BowSkill.bGuided;
			//Shot.bParabola = BowSkill.bParabola;
		}
	}
	FireCompleteNum--;
    if (R!=None) R.NextArrowAt=Level.TimeSeconds+FMax(0.001,R.DelayOfContinuousShot);
	if ( FireCompleteNum > 0 )
		SetTimer(BowSkill.DelayOfContinuousShot, False);
    else if (R!=None)
    { SetTimer(0,False); bFireComplete=True; }
    else GotoState('Navigating');
}

function FireBow(Skill Skill, Actor TargetActor)
{
	local int i;
	local class<EffectProjectile> FireClass;
	local EffectProjectile Shot;
	local vector SpawnLocation;
	local rotator SpawnRotation, RealRotation;
	local BowSkill BowSkill;
	local int Yaw;
	local int Seq;
    local RoundSkill R;
    if (!IsRemotePlayerPawn())
    {
        R=RoundSkill(Skill);
        if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,Skill)
            || R.Fired || Level.TimeSeconds<R.FirstFireAt) return;
        R.Fired=True;
        TargetActor=R.RoundTarget;
    }


	if ( TargetActor == None || TargetActor.bDeleteMe ) 
	{
		GotoState('Navigating');
		return;
	}

	if( PSI.CheckBuffDontAct() ) //add neive : 12�� ������ ���̽� ������ ȿ�� ������ ����		
		return ;

	BowSkill = BowSkill(Skill);
	if ( BowSkill == None )
		return;

    if (!IsRemotePlayerPawn()) Seq=R.ActionID;
    else
    {
	if ( SkillFrame != None ) 
	{
		Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Pull);
		if ( UsedSkill.Seq != Seq || UsedSkill.Name != BowSkill.SkillName ) 
		{
			GotoState('Navigating');
			return;
		}
	}

    }

	FireClass = class<EffectProjectile>(Skill.FireClass);
	if ( FireClass != None ) 
	{
		SpawnLocation = Pawn.GetBoneCoords('Bip01 L Hand').Origin;
		SpawnRotation = Rotator(TargetActor.Location - SpawnLocation);
		if ( !BowSkill.bContinuousShot ) 
		{
			if ( BowSkill.NumberOfShot % 2 == 0 )
				SpawnRotation.Yaw = SpawnRotation.Yaw - BowSkill.AngleOfShot;
			RealRotation = SpawnRotation;
			for ( i = 0;i < BowSkill.NumberOfShot;i++ ) 
			{
				if ( i > 0 ) 
				{
					Yaw = (i + 1) / 2 * BowSkill.AngleOfShot;
					if ( i % 2 == 0 )
						Yaw = -1 * Yaw;
					RealRotation.Yaw = SpawnRotation.Yaw + Yaw;
				}
				Shot = Pawn.Spawn(FireClass,,,SpawnLocation,RealRotation);
				if ( Shot != None ) 
				{
					Shot.Instigator = Pawn;
					Shot.Shooter = Character(Pawn);
					Shot.TargetActor = TargetActor;
					Shot.DamageType = BowSkill.DamageType;	//@by wj(09/16)
					//Shot.TargetLocation = TargetActor.Location;
					Shot.SkillName = BowSkill.SkillName;
					if ( Seq != 0 )
						Shot.ActionID = Seq;
					Shot.bGuided = BowSkill.bGuided;
					//Shot.bParabola = BowSkill.bParabola;
				}
			}
			bFireComplete = True;
		}
		else 
		{
			FireCompleteNum = BowSkill.NumberOfShot;
			FireBowOneShot(Skill, TargetActor);
		}
	}
}

state BowAttacking extends Attacking
{
	function BeginState()
	{

        if (!IsRemotePlayerPawn())
        {
            SetTimer(0,False); FireCompleteNum=0;
            class'BowAttackRuntime.RoundStore'.static.Cancel(Self,False);
        }

		bFireComplete = False;
		if (!PSI.ArmState)
			ToggleArmState();
	}
	function EndState()
	{

        if (!IsRemotePlayerPawn())
        {
            SetTimer(0,False); FireCompleteNum=0;
            class'BowAttackRuntime.RoundStore'.static.Cancel(Self,False);
        }

		// �ü����� �ǴϽ� �����̸� ���� �ʴ´�.
		// ������ �����϶��� �ǴϽ� �����̸� �ش�.
		if (bIsActing && bJustFired)
			CoolTime = 0.2;
		bIsActing = False;
		bJustFired = False;
        // EndState also runs after the explicit completion cleanup. Preserve
        // an airborne pose here instead of tweening a second time to idle.
        if (!IsRemotePlayerPawn() && Pawn!=None && Pawn.Physics==PHYS_Falling)
            ActionEnd(False,0);
        else ActionEnd(True,0);
	}

	// ryu dualcore
	event PlayerTick( float DeltaTime )
	{
		local int OccuID;
		local int Count;
		local name AnimName;
		local float AnimFrame, AnimRate;

		Super.PlayerTick( DeltaTime );
        if (!IsRemotePlayerPawn())
        {
            if (!IsInState('BowAttacking')) return;
            // The state label starts Pull after the first input/tick dispatch.
            // An unbound round is pending startup, not a failed active attack.
            if (RoundSkill(ThisSkill)==None || RoundSkill(ThisSkill).ActionID<=0
                || RoundSkill(ThisSkill).Channel<0) return;
            if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill))
            { GotoState('Navigating'); return; }
            if (!bJustFired && ArStepTime.Length>0
                && Level.TimeSeconds-ArStepTime[0]>=0.03) AnimStep(AttackAniChannel);
            // Jump/rebuild can replace the shot channel before AnimEnd. The
            // round still owns its authored end time and pending arrows, not
            // the replacement jump/idle clip's completion callback.
            if (IsInState('BowAttacking') && Level.TimeSeconds>=AttackEndTime)
            {
                Pawn.GetAnimParams(AttackAniChannel,AnimName,AnimFrame,AnimRate);
                if (AnimName!='Shot' && AnimName!='ShotC'
                    && Hero(Pawn).IsBasicAnim(AnimName))
                    RoundSkill(ThisSkill).ClipFinished=True;
            }
            // A naturally completed clip may still report IsAnimating during
            // its native callback. Never wait for that flag to clear first.
            if (IsInState('BowAttacking') && bFireComplete && FireCompleteNum<=0
                && Level.TimeSeconds>=AttackEndTime
                && (RoundSkill(ThisSkill).ClipFinished || !Pawn.IsAnimating(AttackAniChannel)))
                AnimEnd(AttackAniChannel);
            return;
        }


		if(ArStepTime.Length < 1)
			return;

		if( Level.TimeSeconds - AttackEndTime >= 0.03f )
		{
//			//Log("PlayerTick IN AttackEnd"@class@Level.TimeSeconds,'RYU TEST');
			ArStepTime.Remove(0,ArStepTime.Length);
			if (Net == None)
			{
				GotoState('Navigating');
				return;
			}

			if (bFireComplete) 
			{
				bJustFired = False;
				ActionEnd(True, 0);
				GotoState('Navigating');
				return;
			}

			Pawn.GetAnimParams(AttackAniChannel, AnimName, AnimFrame, AnimRate);
			if (Net != None && AnimName == Hero(Pawn).BasicAnim[0])
			{
				StartAction();
				return;
			}

			if (Net != None && AnimName == Hero(Pawn).BasicAnim[3]) 
			{
				bIsActing = False;
				return;
			}
		}
		else
		{
			for(Count = 0;Count < ArStepTime.Length;Count++)
			{
				if( Level.TimeSeconds - ArStepTime[Count] >= 0.03f )
				{
//					//Log("PlayerTick IN Attack Start"@class@Count@Level.TimeSeconds,'RYU TEST');
					if (Net != None)
					{
						ArStepTime[Count] = AttackEndTime + 1.0f;
						Hero(Pawn).DisarmArrow();
						FireBow(ThisSkill, LockedTarget);
						bJustFired = True;

						//@cs debug
						//myHud.AddMessage(2, "FireBow 1",class'Canvas'.static.MakeColor(255,255,255));

						if (Hero(LockedTarget) != None)
							OccuID = ClientController(LockedTarget.Controller).PSI.PanID;
						else if (Monster(LockedTarget) != None)
							OccuID = ServerController(LockedTarget.Controller).MSI.PanID;
						else if (GuardStone(LockedTarget) != None)
							OccuID = GuardStone(LockedTarget).GSI.PanID;
						Net.NotiActSolo("BowAttackFire"@OccuID);
					}
				}
			}
		}
	}
	//==============================================
	function bool CanStop(float Distance) 
	{ 
		return True; 
	}
	function bool StartAction()
	{

        if (!IsRemotePlayerPawn())
        {
            // Mutable global action flags cannot restart a bound live round.
            if (class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)) return True;
            bIsActing=False;
            if (class'BowAttackRuntime.DefinitionStore'.static.ResolveSelected(Self)==None) return False;
        }

		if (bIsActing) 
		{
            if (IsRemotePlayerPawn()) ThisSkill=PSI.Combo;
			return True;
		}

		if(PSI.CheckBuffDontAct()) //add neive : 12�� ������ ���̽� ������ ȿ�� Ȱ���� ����			
			return False;

		if (Hero(Pawn).GetRightHand() == None || Hero(Pawn).GetLeftHand() == None || BowSkill(PSI.Combo) == None) 
		{
			if (!bIsActing) 
			{
				if (Hero(Pawn).GetLeftHand() == None)
					myHud.AddMessage(2, Localize("Warnings","NeedQuiver","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				GotoState('Navigating');
			}
			return False;
		}
		if (PSI.Combo.bHasSkillPoint && PSI.Combo.SkillPoint == 0) 
		{
			myHud.AddMessage(2, Localize("Warnings","NeedSkillPoint","Sephiroth")@PSI.Combo.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return False;
		}
        ThisSkill=PSI.Combo;
        if (!IsRemotePlayerPawn())
        {
            ThisSkill=class'BowAttackRuntime.RoundStore'.static.Begin(Self,PSI.Combo,False);
            if (ThisSkill==None) return False;
            SetTimer(0,False); FireCompleteNum=0; bFireComplete=False; bJustFired=False;
        }
		Pull(ThisSkill, LockedTarget, 0);
		return True;
	}

	function AnimStep(int Channel)
	{
		local int OccuID;
		local int i;
        local RoundSkill R;
        if (!IsRemotePlayerPawn())
        {
            R=RoundSkill(ThisSkill);
            if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)
                || Channel!=R.Channel || R.Fired || Level.TimeSeconds<R.FirstFireAt) return;
            bJustFired=True;
            Hero(Pawn).DisarmArrow();
            FireBow(ThisSkill,R.RoundTarget);
            if (R.RoundTarget!=None && !R.RoundTarget.bDeleteMe)
            {
                if (Hero(R.RoundTarget)!=None) OccuID=ClientController(Hero(R.RoundTarget).Controller).PSI.PanID;
                else if (Creature(R.RoundTarget)!=None) OccuID=ServerController(Creature(R.RoundTarget).Controller).MSI.PanID;
                else if (GuardStone(R.RoundTarget)!=None) OccuID=GuardStone(R.RoundTarget).GSI.PanID;
                Net.NotiActSolo("BowAttackFire"@OccuID);
            }
            for(i=0;i<ArStepTime.Length;i++) ArStepTime[i]=AttackEndTime+1;
            return;
        }


		// ryu dualcore
		if(ArStepTime.Length < 1)
			return;

		for(i = 0;i < ArStepTime.Length;i++)
		{
			if( ArStepTime[i] > AttackEndTime )
			{
				return;
			}
		}
		//========================

//		//Log("AnimStep IN 1"@class@Level.TimeSeconds,'RYU TEST');

		if (Net != None) 
		{
			Hero(Pawn).DisarmArrow();
			FireBow(ThisSkill, LockedTarget);
			bJustFired = True;

			//@cs debug
			//myHud.AddMessage(2, "FireBow 2",class'Canvas'.static.MakeColor(255,255,255));

			if (Hero(LockedTarget) != None)
				OccuID = ClientController(LockedTarget.Controller).PSI.PanID;
			else if (Monster(LockedTarget) != None)
				OccuID = ServerController(LockedTarget.Controller).MSI.PanID;
			else if (GuardStone(LockedTarget) != None)
				OccuID = GuardStone(LockedTarget).GSI.PanID;
			Net.NotiActSolo("BowAttackFire"@OccuID);
		}

		// ryu dualcore
		for(i = 0;i < ArStepTime.Length;i++)
		{
			if (Net != None)
			{
				ArStepTime[i] = AttackEndTime + 1.0f;
			}
		}
	}
	function AnimEnd(int Channel)
	{
    local RoundSkill R;
    local name EndSequence;
    local float EndFrame,EndRate;

		local name AnimName;
		local float AnimFrame, AnimRate;
    if (IsRemotePlayerPawn())
    {
        if (Channel!=0 || Pawn==None || Pawn.bDeleteMe || Hero(Pawn)==None) return;
        if (Character(Pawn).bIsDead || IsRemoteHardControlActive()) return;
        Pawn.GetAnimParams(0,EndSequence,EndFrame,EndRate);
        if (EndFrame<0 || Pawn.IsAnimating(0)
            || Hero(Pawn).IsBasicAnim(EndSequence) || EndSequence=='Spirits') return;
        bIsActing=False; bIsActingFinish=False; bJustFired=False;
        ArStepTime.Length=0;
        ActionEnd(True,0.1);
        GotoState('Navigating');
        return;
    }


        if (!IsRemotePlayerPawn())
        {
            R=RoundSkill(ThisSkill);
            if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)
                || Channel!=AttackAniChannel || !bJustFired || !R.Fired) return;
            Pawn.GetAnimParams(Channel,AnimName,AnimFrame,AnimRate);
            if (AnimName!='Shot' && AnimName!='ShotC')
            {
                if (!Hero(Pawn).IsBasicAnim(AnimName)
                    || !R.ClipFinished || Level.TimeSeconds<AttackEndTime) return;
            }
            else if (AnimFrame<0) return;
            // This is the native AnimEnd notification, or a tick retry after it.
            // IsAnimating means a channel is live; it is not a completion test.
            R.ClipFinished=True;
            if (!bFireComplete || FireCompleteNum>0 || Level.TimeSeconds<AttackEndTime) return;
            ArStepTime.Length=0;
            // Keep the original simultaneous-shot cooldown behavior. The
            // existing 0.2s EndState cooldown belongs to continuous mouse shots.
            if (!BowSkill(ThisSkill).bContinuousShot) bJustFired=False;
            ActionEnd(Pawn.Physics!=PHYS_Falling,0); GotoState('Navigating'); return;
        }
		if(ArStepTime.Length < 1) // ryu dualcore
			return;

		if (Net == None) 
		{
			GotoState('Navigating');
			return;
		}

		if (bFireComplete) 
		{
			ArStepTime.Remove(0,ArStepTime.Length); // ryu dualcore
			bJustFired = False;
			/*!@ 2004.2.16 jhjung, to accept unknown delay
			if (ThisSkill == None) {
			ActionEnd(true,0);
			GotoState('Navigating');
			}
			else {
				Pull(ThisSkill, LockedTarget, 0);
			}
			*/
			ActionEnd(True, 0);
			GotoState('Navigating');
			return;
		}

		Pawn.GetAnimParams(Channel, AnimName, AnimFrame, AnimRate);
		if (Net != None && AnimName == Hero(Pawn).BasicAnim[0]) 
		{
			StartAction();
			return;
		}

		if (Net != None && AnimName == Hero(Pawn).BasicAnim[3]) 
		{
			bIsActing = False;
			return;
		}
	}

	event ActionEnd(bool bTweenToIdle, optional float TweenTime)
	{
        local Character C;
        local name BaseSequence;
        local float BaseRate;
    local name CurrentSequence;
    local float CurrentFrame,CurrentRate;
    local bool bCurrentPlaying;
        C=Character(Pawn);
    if (IsRemotePlayerPawn() && C!=None && !C.bDeleteMe)
    {
        // A stale ordinary cleanup must never take the advanced/support channel.
        if (IsInState('SecondSkillAttacking')) return;
        C.GetAnimParams(0,CurrentSequence,CurrentFrame,CurrentRate);
        bCurrentPlaying=C.IsAnimating(0);
        if (bCurrentPlaying && !Hero(Pawn).IsBasicAnim(CurrentSequence)
            && (ThisSkill==None || CurrentSequence!=ThisSkill.AnimSequence)) return;
    }

        if (!IsRemotePlayerPawn())
        {
            if (C!=None) C.StartIdle(bTweenToIdle,TweenTime);
        }
        else if (bTweenToIdle && C!=None && !C.bDeleteMe && !C.bIsDead
            && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
            && !IsRemoteHardControlActive())
        {
            // End of a received action owns pose recovery, not movement.
            // A moving queue is not a reason to leave a finished attack frozen.
            BaseRate=1.0;
            if (Pawn.Physics==PHYS_Falling)
                BaseSequence=C.BasicAnim[3];
            else if (Pawn.PrePivot.Z==Pawn.Default.PrePivot.Z+200
                && Pawn.HasAnim('FlyIdle') && Pawn.HasAnim('FlyForward'))
            {
                if (Pawn.Acceleration==vect(0,0,0)
                    && Pawn.Velocity.X*Pawn.Velocity.X+Pawn.Velocity.Y*Pawn.Velocity.Y<1000)
                    BaseSequence='FlyIdle';
                else BaseSequence='FlyForward';
            }
            else if (Pawn.Acceleration==vect(0,0,0)
                && Pawn.Velocity.X*Pawn.Velocity.X+Pawn.Velocity.Y*Pawn.Velocity.Y<1000)
                BaseSequence=C.BasicAnim[0];
            else
            {
                BaseRate=C.AnimSpeed;
                if (!(BaseRate>0 && BaseRate<100)) BaseRate=1.0;
                if (Pawn.bIsWalking) BaseSequence=C.BasicAnim[1];
                else BaseSequence=C.BasicAnim[2];
            }
            if (BaseSequence=='' || !Pawn.HasAnim(BaseSequence))
            { BaseSequence=C.BasicAnim[0]; BaseRate=1.0; }
            if (BaseSequence!='' && Pawn.HasAnim(BaseSequence)
                && !(bCurrentPlaying && Hero(Pawn).IsBasicAnim(CurrentSequence)))
                C.CHAR_LoopAnim(BaseSequence,BaseRate,0.1,0);
        }
		// 如果是玩家，清除命中检测信息
		ThisSkill = None;

	}

	event Timer()
	{
        local RoundSkill R;
        if (!IsRemotePlayerPawn())
        {
            R=RoundSkill(ThisSkill);
            if (!class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)
                || !R.Fired || FireCompleteNum<=0) { SetTimer(0,False); return; }
            if (Level.TimeSeconds<R.NextArrowAt)
            { SetTimer(FMax(0.001,R.NextArrowAt-Level.TimeSeconds),False); return; }
        }

		FireBowOneShot(ThisSkill, LockedTarget);
	}
	function PlayerMove(float DeltaTime)
	{
		// 本地角色才禁止移动
		if ( Character(Pawn).IsAvatar())
		{
			aForward = 0;
			aStrafe = 0;
		}
		Super.PlayerMove(DeltaTime);
		
	}

PullString:
	StartAction();
}

/**
 * 调试日志输出
 * @param message 要输出的消息
 */
function DebugLog(string message)
{
	Level.GetLocalPlayerController().myHud.AddMessage(1,"DebugLog ClientController: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

/**
 * 召唤精神状态
 * 玩家召唤或结束精神（Spirit）时的状态
 * 在此状态下，玩家不能进行移动、攻击、拾取等操作，只能等待召唤完成或超时
 */
state SummonSpirit extends Navigating
{
	// ========== 忽略的操作列表 ==========
	// 在此状态下，以下操作将被忽略（无法执行）
	ignores KeyboardMove,			// 键盘移动
	MovePawnToMove,					// 移动到指定位置
	MovePawnToTalk,					// 移动到对话目标
	MovePawnToAttackMelee,			// 移动到近战攻击目标
	MovePawnToPick,					// 移动到拾取目标
	MovePawnToTrace,				// 移动到追踪目标
	MovePawnToAttackRange,			// 移动到远程攻击目标
	MovePawnToAttackBow,			// 移动到弓箭攻击目标
	FindNearestItem;				// 查找最近物品

	/**
	 * 状态开始
	 * 当进入召唤精神状态时调用
	 */
	function BeginState()
	{
		// 设置4秒定时器，如果4秒内没有完成召唤，自动返回导航状态
		SetTimer(4, False);
	}

	/**
	 * 状态结束
	 * 当离开召唤精神状态时调用
	 */
	function EndState()
	{
    SetTimer(0,False);
    class'BowAttackRuntime.RoundStore'.static.CancelSupport(Self);
		// 结束右键动作（召唤精神通常通过右键触发）
		RClickActionEnd();
	}

	/**
	 * 定时器事件
	 * 4秒后自动触发，防止状态卡死
	 */
	event Timer()
	{
    local name Sequence;
    local float Frame,Rate;
    if (class'BowAttackRuntime.RoundStore'.static.SupportActive(Self) && Pawn!=None)
    {
        Pawn.GetAnimParams(0,Sequence,Frame,Rate);
        if (Sequence=='Spirits' && Pawn.IsAnimating(0)) return;
    }

		// 超时后自动返回导航状态
		GotoState('Navigating');
	}

	/**
	 * 是否可以停止
	 * @param Distance 距离参数（未使用）
	 * @return 总是返回True，表示可以随时停止
	 */
	function bool CanStop(float Distance) 
	{ 
		return True; 
	}
	
	/**
	 * 执行召唤精神
	 * 核心逻辑：检查条件并召唤或结束精神
	 */
	function DoSpirit()
	{
    if (class'BowAttackRuntime.RoundStore'.static.SupportActive(Self)) return;
		// ========== 第一步：检查是否可以释放所有技能 ==========
		// 如果当前不能使用所有技能（可能被某些状态禁止），显示警告并返回
		if(!CanUseAllSkill())
		{
			myHud.AddMessage(2, 
				Localize("Warnings", "CannotUseSkill", "Sephiroth"), 
				class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return;
		}

		// ========== 第二步：判断是召唤还是结束精神 ==========
		// 如果当前已经有精神在（CurrentSpiritName不为空），则结束该精神
		if (CurrentSpiritName != "") 
		{
			// 结束当前精神
			FinishSpirit(CurrentSpiritName);
			// 返回导航状态
			GotoState('Navigating');
		}
		// ========== 第三步：召唤新精神 ==========
		else 
		{
			// 获取当前配置的魔法技能
			ThisSkill = PSI.Magic;
			
			// 检查技能是否有效（已启用且已学习）
			if (ThisSkill != None && (!ThisSkill.bEnabled || !ThisSkill.bLearned)) 
			{
				// 技能无效，返回导航状态
				GotoState('Navigating');
				return;
			}
			
			// 检查是否为精神技能类型
			if (ThisSkill != None && ThisSkill.IsA('SpiritSkill')) 
			{
				// ---------- 检查魔法值是否足够 ----------
				if (PSI.Mana < ThisSkill.ManaConsumption) 
				{
					// 魔法值不足，显示警告消息
					myHud.AddMessage(2, Localize("Warnings", "NeedMana", "Sephiroth")@ThisSkill.FullName@Localize("Warnings", "CannotUseSkill", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
					GotoState('Navigating');
				}
				// ---------- 检查技能点数是否足够 ----------
				else if (PSI.Magic.bHasSkillPoint && PSI.Magic.SkillPoint == 0) 
				{
					// 技能点数不足，显示警告消息
					myHud.AddMessage(2, Localize("Warnings","NeedSkillPoint","Sephiroth")@PSI.Combo.FullName@Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
					GotoState('Navigating');
				}
				// ---------- 所有条件满足，生成精神特效 ----------
				else 
				{
					// 生成精神召唤特效
					SpawnSpiritEffect(ThisSkill);
					// 清除交互目标（召唤精神不需要交互目标）
					InteractTo = None;
				}
			}
		}
	}

	/**
	 * 受击事件处理
	 * 在召唤精神状态下受到攻击时的处理
	 * 注意：禁用了疼痛效果（bPain设为False），避免打断召唤过程
	 * 
	 * @param Attacker 攻击者
	 * @param Skill 使用的技能
	 * @param bPain 是否疼痛（被强制设为False）
	 * @param bKnockback 是否击退
	 * @param bCritical 是否暴击
	 * @param bMiss 是否未命中
	 * @param bBlock 是否格挡
	 * @param bImmune 是否免疫
	 */
	event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune)
	{
		// 调用全局的受击处理，但禁用疼痛效果（避免打断召唤动画）
		Global.Damaged(Attacker, Skill, False, bKnockback, bCritical, bMiss, bBlock, bImmune);
	}

	/**
	 * 网络接收精神魔法消息
	 * 当服务器下发精神魔法状态变化时调用
	 * 
	 * @param SpiritName 精神名称
	 * @param bSet 是否设置精神（True=召唤，False=结束）
	 */
	event NetRecv_SpiritMagic(string SpiritName, bool bSet)
	{
		// 调用全局的精神魔法处理函数
		Global.NetRecv_SpiritMagic(SpiritName, bSet);
		// 处理完成后返回导航状态
        if (!class'BowAttackRuntime.RoundStore'.static.SupportActive(Self))
            GotoState('Navigating');
	}
	
	/**
	 * 玩家移动
	 * 在召唤精神状态下禁止移动
	 * 
	 * @param DeltaTime 时间增量
	 */
	function PlayerMove(float DeltaTime)
	{
		// 禁止前后移动
		aForward = 0;
		// 禁止左右移动
		aStrafe = 0;
		// 调用父类的移动处理（但移动量已被清零）
		Super.PlayerMove(DeltaTime);
	}
	
	/**
	 * 跳跃
	 * 在召唤精神状态下禁止跳跃
	 * 
	 * @param F 跳跃力度（未使用）
	 */
	exec function Jump( optional float F )
	{
		// 空实现，禁止跳跃
	}
	
	// ========== 状态入口点 ==========
	// 当进入此状态时，自动执行DoSpirit()函数
Summon:
	DoSpirit();
}

/**
 * 远程攻击命中检测（Nephilim玩家专用）
 * 当远程攻击（弓箭、魔法等）命中目标时，此函数被调用来处理命中逻辑
 * 针对弓箭手（Bow）职业有特殊的处理逻辑，其他职业使用父类的实现
 * 
 * @param HitActor 被命中的目标角色对象
 * @param HitLocation 命中位置的世界坐标
 * @param SkillName 使用的技能名称
 * @param ActionID 动作序列ID，用于同步和追踪
 */
function RangeHit_Detected(actor HitActor, vector HitLocation, string SkillName, int ActionID)
{
	// 动作序列号：用于技能帧同步
	local int Seq;
	// 目标ID：目标的唯一标识符（玩家ID或怪物ID）
	local int PanID;
	// 技能对象：通过技能名称查询到的技能配置信息
	local Skill Skill; //@by wj(08/24)

	// ========== 第一步：查询技能对象 ==========
	// 通过技能名称查询技能配置信息
	Skill = QuerySkillByName(SkillName);

	// ========== 第二步：检查目标有效性 ==========
	// 如果目标是角色类型，检查目标是否已死亡或已被标记删除
	// 如果目标无效，直接返回，不处理命中
	if ( Character(HitActor) != None && (Character(HitActor).bIsDead || HitActor.bDeleteMe) )
		return;
	
	// ========== 第三步：处理命中逻辑（仅玩家角色） ==========
	// 只有玩家角色（Avatar）才需要发送命中消息到服务器
	if ( Character(Pawn).IsAvatar() )
	{
		// ---------- 情况1：弓箭手职业的特殊处理 ----------
		// 如果当前职业是弓箭手（Bow），使用特殊的命中处理逻辑
		if( PSI.JobName == 'Bow' )
		{
			// 查找拉弓状态的技能帧（弓箭手使用拉弓状态，而不是发射状态）
			Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Pull);
			
			// 获取目标的唯一标识符（PanID）
			if ( Hero(HitActor) != None )
				// 如果目标是玩家角色（Hero），获取玩家的PanID
				PanID = ClientController(Hero(HitActor).Controller).PSI.PanID;
			else if (Creature(HitActor) != None)
				// 如果目标是怪物/NPC（Creature），获取怪物的PanID
				PanID = ServerController(Creature(HitActor).Controller).MSI.PanID;
			else
				// 如果目标类型未知，PanID设为0
				PanID = 0;
			
			// 根据技能类型发送不同的命中消息
			if( Skill.IsA('SecondSkill') )
			{
				// 如果是第二技能，发送第二技能命中消息到服务器
				Net.NotiSkill2ndHit(Skill.SkillName, PanID, HitLocation);
			}
			// ---------- 普通远程技能 ----------
			else 
			{
				// 如果是普通远程技能，发送远程攻击命中消息到服务器
				// 参数：动作ID、攻击者位置、目标ID、命中位置
				Net.NotiHitRange(ActionID, Pawn.Location, PanID, HitLocation);
			}
		}
		// ---------- 情况2：非弓箭手职业 ----------
		else 
		{
			// 如果不是弓箭手职业，使用父类的标准处理逻辑
			Super.RangeHit_Detected(HitActor, HitLocation, SkillName, ActionID);
		}
	}
}

event NetRecv_ActRange(Skill Skill, Actor TargetActor, vector TargetLocation, float ActRatio, int ActPitch)
{
    local Pawn MovePawn;
    local vector MoveVelocity,MoveAcceleration,MoveDestination;
    local float MoveDesired,MoveGroundSpeed;
    local Actor.EPhysics MovePhysics;
    local bool HoldMovement,MoveMouse,MoveSync;

    local name PrioritySequence;
    local float PriorityFrame,PriorityRate;

	local bool bIsMoving;

    // Local ordinary bow pulls are initiated locally, including their real arrows.
    // A late self echo must not install a raw Skill in a snapshot-owned state.
    if (!IsRemotePlayerPawn() && BowSkill(Skill)!=None) return;









    // Only the local mouse owner suppresses an ordinary bow action echo.
    // Nearby actors and advanced/support casts retain their original handlers.
    if (!IsRemotePlayerPawn() && BowSkill(Skill)!=None
        && class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)) return;








    HoldMovement=IsRemotePlayerPawn() && Pawn!=None && !Pawn.bDeleteMe
        && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive && !Character(Pawn).bIsDead
        && !IsRemoteHardControlActive() && !IsRemoteSkillDashLockActive();
    if (HoldMovement)
    {
        MovePawn=Pawn; MovePhysics=Pawn.Physics;
        MoveVelocity=Pawn.Velocity; MoveAcceleration=Pawn.Acceleration;
        MoveDesired=Pawn.DesiredSpeed; MoveGroundSpeed=Pawn.GroundSpeed;
        MoveDestination=Destination; MoveMouse=bMouseMove; MoveSync=bSyncingPosition;
        Pawn.bCanStrafe=True;
    }

    // Ordinary actions are discarded, never buffered. Movement is independent.
    if (IsRemotePlayerPawn() && PSI!=None && !class'RemoteMotionSys.QueueIndex'.static.AllowAction(Self,PSI.PanID,1)) {
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }
    if (IsRemotePlayerPawn() && Pawn!=None && PSI!=None && PSI.JobName=='Bow')
    {
        Pawn.GetAnimParams(0,PrioritySequence,PriorityFrame,PriorityRate);
        // A self-support cast may have received its BUFF acknowledgement before
        // its one-shot character animation ends. Do not cut that animation short.
        if (PrioritySequence=='Spirits' && Pawn.IsAnimating(0)) {
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }
    }

	bIsMoving = bSyncingPosition;
    if (IsRemotePlayerPawn())
    {
        if (Skill == None) {
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }
        if (TargetActor != None && !TargetActor.bDeleteMe) RotatePawnTo(TargetActor.Location);
        else RotatePawnTo(TargetLocation);
        GotoState('BowAttacking');
        ThisSkill=Skill;
        Character(Pawn).bJustDamaged=False;
        if (IsRemoteHardControlActive()) Pawn.Acceleration=vect(0,0,0);
        Pull(ThisSkill,TargetActor,ActRatio);
            if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
        return;
    }
	if ( Skill != None ) 
	{
		if ( TargetActor != None && !TargetActor.bDeleteMe )
			RotatePawnTo(TargetActor.Location);
		else
			RotatePawnTo(TargetLocation);
		ThisSkill = Skill;
		Character(Pawn).bJustDamaged = False;  // by BK
		// 鍙�瀵规湰鍦扮帺瀹堕噸缃� Acceleration锛屽叾浠栫帺瀹讹紙绗�涓夎�嗛噹锛夐渶瑕佷繚鎸佺Щ鍔ㄨ兘鍔�
		if ( Character(Pawn).IsAvatar() || !bIsMoving )
			Pawn.Acceleration = vect(0,0,0); // by BK 
		Pull(ThisSkill, TargetActor, ActRatio);
		GotoState('BowAttacking');
	}
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
}

event NetRecv_BowAttackFire(Actor Target)
{
    local name PrioritySequence;
    local float PriorityFrame,PriorityRate;

    // Native local animation notifications and the authored one-shot timer own fire.
    // The server echo must not change bJustFired during a transition/new pull.
    if (!IsRemotePlayerPawn()) return;



    if (!IsRemotePlayerPawn()
        && class'BowAttackRuntime.RoundStore'.static.ValidMouse(Self,ThisSkill)) return;


    // Ordinary actions are discarded, never buffered. Movement is independent.
    if (IsRemotePlayerPawn() && IsInState('SecondSkillAttacking')) return;
    if (IsRemotePlayerPawn() && Pawn!=None && PSI!=None && PSI.JobName=='Bow')
    {
        Pawn.GetAnimParams(0,PrioritySequence,PriorityFrame,PriorityRate);
        // A self-support cast may have received its BUFF acknowledgement before
        // its one-shot character animation ends. Do not cut that animation short.
        if (PrioritySequence=='Spirits' && Pawn.IsAnimating(0)) return;
    }


	Hero(Pawn).DisarmArrow();
	FireBow(ThisSkill, Target);
	bJustFired = True;		
}

event NetRecv_SpiritCast(Skill Skill)
{
	if( Pawn != None )
		Character(Pawn).bJustDamaged = False; // by BK

	SpawnSpiritEffect(Skill);
}

event NetRecv_SpiritMagic(string SpiritName, bool bSet)
{
	if ( bSet )
		CurrentSpiritName = SpiritName;
	else
		CurrentSpiritName = "";
}

exec function SpawnSpiritEffect(Skill Skill)
{
    local Pawn MovePawn;
    local vector MoveVelocity,MoveAcceleration,MoveDestination;
    local float MoveDesired,MoveGroundSpeed;
    local Actor.EPhysics MovePhysics;
    local bool HoldMovement,MoveMouse,MoveSync;

    local name PrioritySequence;
    local float PriorityFrame,PriorityRate;
    local bool PlaySupportPose;
    if (!IsRemotePlayerPawn() && PSI!=None && PSI.JobName=='Bow')
    {
        if (!class'BowAttackRuntime.RoundStore'.static.BeginSupport(Self)) return;
        if (!IsInState('SummonSpirit')) GotoState('SummonSpirit');
    }
    HoldMovement=IsRemotePlayerPawn() && Pawn!=None && !Pawn.bDeleteMe
        && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive && !Character(Pawn).bIsDead
        && !IsRemoteHardControlActive() && !IsRemoteSkillDashLockActive();
    if (HoldMovement)
    {
        MovePawn=Pawn; MovePhysics=Pawn.Physics;
        MoveVelocity=Pawn.Velocity; MoveAcceleration=Pawn.Acceleration;
        MoveDesired=Pawn.DesiredSpeed; MoveGroundSpeed=Pawn.GroundSpeed;
        MoveDestination=Destination; MoveMouse=bMouseMove; MoveSync=bSyncingPosition;
        Pawn.bCanStrafe=True;
    }


    PlaySupportPose=True;
    if (IsRemotePlayerPawn())
    {
        if (PSI==None || !class'RemoteMotionSys.QueueIndex'.static.AllowAction(Self,PSI.PanID,3)) PlaySupportPose=False;
        else if (Pawn!=None)
        {
            Pawn.GetAnimParams(0,PrioritySequence,PriorityFrame,PriorityRate);
            if (PrioritySequence=='Spirits' && Pawn.IsAnimating(0))
                PlaySupportPose=False;
        }
    }
    // Retain effect creation even when a repeated BUFF must not restart the pose.
    if (PlaySupportPose)
    {
        Pawn.PlayAnim('Spirits',1.0,0.3);
        if (IsRemotePlayerPawn() && PSI!=None) class'RemoteMotionSys.QueueIndex'.static.NoteAction(Self,PSI.PanID,3,'Spirits');
    }
	SpiritType = Spawn(Skill.SpiritClass, Pawn, , Pawn.Location, Pawn.Rotation);
	if ( SpiritType != None ) 
	{
		if ( Net != None )
			Net.NotiSpiritCast(Skill.SkillName);
		SpiritType.HeadVector = Pawn.GetBoneCoords('Bip01 Head').Origin;
		if ( Character(Pawn).IsAvatar() )
			SpiritType.SummonSpirit(Pawn, Skill.SkillName);
		else
			SpiritType.SummonSpirit(None, Skill.SkillName);
	}
    if (HoldMovement && Pawn==MovePawn && !Pawn.bDeleteMe
        && Pawn.Physics==MovePhysics && PSI!=None && !PSI.bDeleteMe && PSI.bIsAlive
        && !Character(Pawn).bIsDead && !IsRemoteHardControlActive()
        && !IsRemoteSkillDashLockActive())
    {
        Pawn.Velocity.X=MoveVelocity.X; Pawn.Velocity.Y=MoveVelocity.Y;
        Pawn.Acceleration.X=MoveAcceleration.X; Pawn.Acceleration.Y=MoveAcceleration.Y;
        Pawn.DesiredSpeed=MoveDesired; Pawn.GroundSpeed=MoveGroundSpeed;
        Pawn.bCanStrafe=True; Destination=MoveDestination;
        bMouseMove=MoveMouse; bSyncingPosition=MoveSync;
    }
}

exec function DoSummonSpirit()
{
	if( CurrentSpiritName == "" && !IsInState('SummonSpirit') )
		GotoState('SummonSpirit', 'Summon');
}

function SpiritCastEnd(string SpiritName)
{
	if ( Net != None )
		Net.NotiSpiritMagic(SpiritName, True);
}

exec function FinishSpirit(string SpiritName)
{
	if ( Net != None && SpiritName != "" )
		Net.NotiSpiritMagic(SpiritName, False);
}

exec function ShotTest()
{
	Pawn.LoopAnim('Shot');
}



defaultproperties
{
}
