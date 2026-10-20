// Independent controller module inheriting cumulative SephirothPlayer fixes.
class CommandMeleePlayer extends SephirothPlayer;

// CM_VARIABLES_BEGIN
var bool CMEnabled, CMPlaying, CMAdvance, CMFinish;
var bool CMStunActive;
var int CMPartSerial, CMCompletedSerial, CMConsumedSerial, CMCycleSerial, CMFinishCycle;
var float CMEndFrame, CMObservedFrame, CMProgressAt;
var array<name> CMHitBones;
var array<float> CMHitFrames;
var string CMStopReason;
var int CMPendingID, CMSequence, CMComboIndex, CMComboTotal, CMChannel;
var float CMRange, CMDeadline, CMStartFrame, CMLastHitFrame, CMArmRetryAt;
var float CMMouseResumeAt;
var name CMLastHitBone;
var Monster CMTarget;
var Skill CMComboSkill, CMFinishSkill, CMActiveSkill;
var byte CMQueuedSkill[3], CMWaitingSkill[3];
var string CMQueuedSkillName[3], CMWaitingSkillName[3];
var float CMSkillWaitUntil;
var Pawn CMStrafePawn;
var bool CMOldCanStrafe;
var Character CMManualTarget;
var float CMManualRetryAt;
// CM_VARIABLES_END

function bool CMControlBlocked()
{
    local int I;
    local SephirothInterface UI;
    local SephirothController IC;
    if (CMStunActive || IsInState('Stunning'))
        return True;
    if (PSI != None)
    {
        if (PSI.CheckBuffDontAct())
            return True;
        for (I = 0; I < PSI.EnchantMagics.Length; I++)
            if (PSI.EnchantMagics[I] ~= "Stun"
                || PSI.EnchantMagics[I] ~= "Stunning")
                return True;
    }
    UI = SephirothInterface(myHud);
    if (UI != None)
    {
        IC = SephirothController(UI.Controller);
        if (IC != None && IC.bLostControl)
            return True;
    }
    return False;
}

event NetRecv_StartStun(bool bySelf)
{
    CMStunActive = True;
    CMStopReason = "stun notification";
    // Preserve the original Stunning state and local input lock.
    Super.NetRecv_StartStun(bySelf);
}

event NetRecv_FinishStun(bool bySelf)
{
    CMStunActive = False;
    Super.NetRecv_FinishStun(bySelf);
}

function bool CMPlayerValid()
{
    return Pawn != None && !Pawn.bDeleteMe && Hero(Pawn) != None
        && Character(Pawn).IsAvatar() && !Character(Pawn).bIsDead
        && PSI != None && PSI.bIsAlive && !PSI.PkState
        && Net != None && SkillFrame != None
        && (PSI.JobName == 'Bare' || PSI.JobName == 'OneHand')
        && !CMControlBlocked() && (ZSI == None || !ZSI.bNoUseSkill);
}

function SetHotSkill(byte Index, string SkillName)
{
    if (Index < 3 && CMEnabled && IsInState('CommandMelee'))
    {
        // Coalesce repeated selection into the latest request, without touching
        // this part's animation, native action stage, sequence or shot count.
        CMQueuedSkill[Index] = 1;
        CMQueuedSkillName[Index] = SkillName;
        return;
    }
    Super.SetHotSkill(Index, SkillName);
}

event NetRecv_AssignSkill(int Index, string SkillName)
{
    Super.NetRecv_AssignSkill(Index, SkillName);
    if (Index >= 0 && Index < 3 && CMWaitingSkill[Index] != 0
        && SkillName == CMWaitingSkillName[Index])
        CMWaitingSkill[Index] = 0;
}

function bool CMApplySkillChanges()
{
    local int I;
    local bool bSent;
    for (I = 0; I < 3; I++)
        if (CMWaitingSkill[I] != 0)
        {
            if (Level.TimeSeconds > CMSkillWaitUntil)
                CMStop("skill selection confirmation timeout");
            return False;
        }
    // Mark all outstanding acknowledgements before the first native send.
    for (I = 0; I < 3; I++)
        if (CMQueuedSkill[I] != 0)
        {
            CMQueuedSkill[I] = 0;
            if (CMQueuedSkillName[I] != GetHotSkill(I))
            {
                CMWaitingSkill[I] = 1;
                CMWaitingSkillName[I] = CMQueuedSkillName[I];
                bSent = True;
            }
        }
    if (!bSent) return True;
    CMSkillWaitUntil = Level.TimeSeconds + 3.0;
    for (I = 0; I < 3; I++)
        if (CMWaitingSkill[I] != 0)
            Super.SetHotSkill(I, CMWaitingSkillName[I]);
    return False;
}

function CMFlushSkillChanges()
{
    local int I;
    // Exiting for a manual skill must not lose the user's latest selection.
    for (I = 0; I < 3; I++)
    {
        CMWaitingSkill[I] = 0;
        if (CMQueuedSkill[I] != 0)
        {
            CMQueuedSkill[I] = 0;
            Super.SetHotSkill(I, CMQueuedSkillName[I]);
        }
    }
    CMSkillWaitUntil = 0;
}

function CMStop(string Reason, optional bool bPriorityTakeover, optional bool bMouseTakeover)
{
    local bool bResumeMouseMove;
    local vector MoveDestination;
    CMStopReason = Reason;
    ;
    if (IsInState('CommandMelee'))
    {
        bResumeMouseMove = !bPriorityTakeover && bMouseMove;
        MoveDestination = Destination;
        // Keep this deadline outside CMReset. Command requests cannot extend it.
        if (bMouseTakeover)
            CMMouseResumeAt = Level.TimeSeconds + 1.0;
        GotoState('Navigating');
        // EndState still runs under CommandMelee's animation protection.
        // Restore only after leaving it, and never ahead of a priority skill.
        if (!bPriorityTakeover)
            CMRestoreBasePose();
        if (bResumeMouseMove && CMCanResumeMouseMove())
            Global.MovePawnToMove(None, MoveDestination);
    }
}

function bool CMCanResumeMouseMove()
{
    return IsInState('Navigating') && Pawn != None && !Pawn.bDeleteMe
        && Character(Pawn) != None && !Character(Pawn).bIsDead
        && PSI != None && PSI.bIsAlive && !CMControlBlocked();
}

// These global overrides also run after the first mouse operation has already
// left CommandMelee. Every new manual attack renews the one-second priority.
function CMMouseAttackPriority(string Reason)
{
    CMMouseResumeAt = Level.TimeSeconds + 1.0;
    if (IsInState('CommandMelee'))
        CMStop(Reason, True);
}

function MovePawnToAttackMelee(Actor MoveTarget)
{
    local bool bCommandTakeover;
    bCommandTakeover = CMEnabled && IsInState('CommandMelee');
    CMMouseAttackPriority("manual melee priority");
    if (CMManualTarget != Character(MoveTarget) || !IsInState('MeleeAttacking'))
        CMManualRetryAt = 0;
    CMManualTarget = Character(MoveTarget);
    Super.MovePawnToAttackMelee(MoveTarget);
    if (bCommandTakeover && IsInState('MeleeAttacking') && InteractTo != None)
        CMRefreshManualMovePose();
}

function MovePawnToMove(Actor MoveTarget, vector Loc)
{
    local bool bCommandTakeover;
    CMManualTarget = None;
    CMManualRetryAt = 0;
    if (Character(MoveTarget) != None && MoveTarget != Pawn)
    {
        bCommandTakeover = CMEnabled && IsInState('CommandMelee');
        CMMouseAttackPriority("manual target approach priority");
    }
    Super.MovePawnToMove(MoveTarget, Loc);
    if (bCommandTakeover)
        CMRefreshManualMovePose();
}

function MovePawnToTalk(Actor MoveTarget)
{
    local bool bCommandTakeover;
    if (MoveTarget == None || MoveTarget.bDeleteMe) return;
    if (CMNearTalk(MoveTarget)) return;
    CMManualTarget = None;
    CMManualRetryAt = 0;
    bCommandTakeover = CMEnabled && IsInState('CommandMelee');
    CMMouseAttackPriority("manual character interaction priority");
    Super.MovePawnToTalk(MoveTarget);
    if (bCommandTakeover && IsInState('Talking'))
        CMRefreshManualMovePose();
}

function bool CMNearTalk(Actor MoveTarget)
{
    local vector D;
    local ServerController NpcController;
    local ClientController HeroController;
    if (!CMEnabled || !IsInState('CommandMelee')
        || Pawn == None || Pawn.bDeleteMe
        || MoveTarget == None || MoveTarget.bDeleteMe)
        return False;
    if (Npc(MoveTarget) == None && Hero(MoveTarget) == None) return False;
    D = MoveTarget.Location - Pawn.Location;
    D.Z = 0;
    if (VSize(D) > MoveTarget.CollisionRadius + 500) return False;

    // Talking.Talk immediately returns to Navigating, resetting the attack.
    // In range, perform only its interaction work; leave animation, pending
    // hits, movement and command target owned by the current attack part.
    if (CanTalk(MoveTarget) && Npc(MoveTarget) != None && !IsTalking())
    {
        NpcController = ServerController(Npc(MoveTarget).Controller);
        if (Net != None && NpcController != None && NpcController.MSI != None)
            Net.NotiNpcDialog(NpcController.MSI.PanID, "");
    }
    else if (CanTalk(MoveTarget) && Hero(MoveTarget) != None)
    {
        HeroController = ClientController(Hero(MoveTarget).Controller);
        if (HeroController != None && HeroController.PSI != None)
        {
            if (HeroController.PSI.IsBoothSeller())
                AskBoothVisit(Hero(MoveTarget));
            else
                OpenXMenu(Hero(MoveTarget));
        }
    }
    ForceFinishInteraction(MoveTarget);
    return True;
}

function CMRefreshManualMovePose()
{
    local vector D;
    local Character C;
    local name AirSequence;
    if (CMEnabled || IsInState('CommandMelee') || bIsActing
        || Pawn == None || Pawn.bDeleteMe || PSI == None || !PSI.bIsAlive
        || CMControlBlocked()) return;
    C = Character(Pawn);
    if (C == None || C.bIsDead) return;
    if (!IsInState('Navigating') && !IsInState('MeleeAttacking')
        && !IsInState('Talking')) return;
    if (IsInState('MeleeAttacking') && InteractTo == None) return;
    D = Destination - Pawn.Location;
    D.Z = 0;
    if (CanStop(VSize(D))) return;
    if (Pawn.Physics == PHYS_Falling)
    {
        C.CHAR_PlayInAir();
        return;
    }
    if (Pawn.PrePivot.Z == Pawn.Default.PrePivot.Z + 200)
    {
        // Travel follows the existing flight presentation rather than running.
        if (Pawn.HasAnim('FlyForward')) AirSequence = 'FlyForward';
        else if (Pawn.HasAnim('Fly')) AirSequence = 'Fly';
        else if (Pawn.HasAnim('Flying')) AirSequence = 'Flying';
        if (AirSequence != '')
        {
            C.AnimSequence = AirSequence;
            Pawn.LoopAnim(AirSequence, 1.0, 0.15, 0);
        }
        else
        {
            AirSequence = C.BasicAnim[3];
            if (AirSequence == '' || !Pawn.HasAnim(AirSequence)) AirSequence = 'Jump';
            if (!Pawn.HasAnim(AirSequence)) return;
            C.AnimSequence = AirSequence;
            Pawn.PlayAnim(AirSequence, 1.0, 0.15, 0);
            Pawn.FreezeAnimAt(0.45, 0);
        }
        return;
    }
    if (Pawn.bIsWalking) C.CHAR_PlayWalking();
    else C.CHAR_PlayRunning();
}

function bool MovePawnToAttackRange(Actor MoveTarget, vector Loc)
{
    CMManualTarget = None;
    CMManualRetryAt = 0;
    CMMouseAttackPriority("manual right skill priority");
    return Super.MovePawnToAttackRange(MoveTarget, Loc);
}

function MovePawnToAttackBow(Actor MoveTarget, vector Loc)
{
    CMManualTarget = None;
    CMManualRetryAt = 0;
    CMMouseAttackPriority("manual bow priority");
    Super.MovePawnToAttackBow(MoveTarget, Loc);
}

function bool Start2ndSkillAction(Skill S, Actor Target, vector Loc)
{
    CMManualTarget = None;
    CMManualRetryAt = 0;
    // Advanced skills keep their normal priority without adding mouse delay.
    if (IsInState('CommandMelee'))
        CMStop("advanced skill priority", True);
    return Super.Start2ndSkillAction(S, Target, Loc);
}

function CMRestoreBasePose()
{
    local Character C;
    local name AirSequence, BaseSequence;
    local float BaseRate;
    local bool bDedicated;
    if (!IsInState('Navigating') || CMEnabled || Pawn == None || Pawn.bDeleteMe
        || CMControlBlocked())
        return;
    C = Character(Pawn);
    if (C == None || C.bIsDead || PSI == None || !PSI.bIsAlive || !C.IsAvatar())
        return;
    C.bJustDamaged = False;
    if (Pawn.Physics == 2)
    {
        // CMReset stopped the native channels; the old cached sequence may
        // already be Jump. CHAR_PlayInAir then does nothing. Start a real
        // finite jump pose now without changing velocity or jumping again.
        BaseSequence=C.BasicAnim[3];
        if (BaseSequence=='' || !Pawn.HasAnim(BaseSequence)) BaseSequence='Jump';
        BaseRate=C.AnimSpeed;
        if (!(BaseRate>0 && BaseRate<100)) BaseRate=1.0;
        if (BaseSequence!='' && Pawn.HasAnim(BaseSequence))
        {
            C.AnimSequence=BaseSequence;
            Pawn.PlayAnim(BaseSequence,BaseRate,0.1,0);
            if (Hero(Pawn)!=None) Hero(Pawn).SetWingsAnimation(BaseSequence);
        }
        return;
    }
    if (Pawn.PrePivot.Z != Pawn.Default.PrePivot.Z + 200)
    {
        // CMReset has stopped every channel. Restart the base loop directly;
        // do not wait for a one-shot idle/run tween to emit another AnimEnd.
        BaseRate = 1.0;
        if (Pawn.Acceleration == vect(0,0,0)
            && Pawn.Velocity.X * Pawn.Velocity.X + Pawn.Velocity.Y * Pawn.Velocity.Y < 1000)
            BaseSequence = C.BasicAnim[0];
        else
        {
            BaseRate = C.AnimSpeed;
            if (!(BaseRate > 0 && BaseRate < 100)) BaseRate = 1.0;
            if (Pawn.bIsWalking)
                BaseSequence = C.BasicAnim[1];
            else if (bBackward && C.BasicAnim[4] != '' && Pawn.HasAnim(C.BasicAnim[4]))
                BaseSequence = C.BasicAnim[4];
            else
                BaseSequence = C.BasicAnim[2];
        }
        if (BaseSequence == '' || !Pawn.HasAnim(BaseSequence))
        {
            BaseSequence = C.BasicAnim[0];
            BaseRate = 1.0;
        }
        if (BaseSequence != '' && Pawn.HasAnim(BaseSequence))
        {
            C.AnimSequence = BaseSequence;
            Pawn.LoopAnim(BaseSequence, BaseRate, 0.1, 0);
            if (Hero(Pawn) != None)
                Hero(Pawn).SetWingsAnimation(BaseSequence);
        }
        return;
    }
    // Same flight selection as the cumulative player's normal pose updater.
    if (Pawn.Acceleration == vect(0,0,0) && Pawn.HasAnim('FlyIdle'))
        AirSequence = 'FlyIdle';
    else if (Pawn.Acceleration != vect(0,0,0) && Pawn.HasAnim('FlyForward'))
        AirSequence = 'FlyForward';
    else if (Pawn.HasAnim('Fly'))
        AirSequence = 'Fly';
    else if (Pawn.HasAnim('Flying'))
        AirSequence = 'Flying';
    bDedicated = AirSequence != '';
    if (!bDedicated)
    {
        AirSequence = C.BasicAnim[3];
        if (AirSequence == '' || !Pawn.HasAnim(AirSequence))
            AirSequence = 'Jump';
    }
    if (!Pawn.HasAnim(AirSequence))
        return;
    C.AnimSequence = AirSequence;
    if (bDedicated)
        Pawn.LoopAnim(AirSequence, 1.0, 0.15, 0);
    else
    {
        Pawn.PlayAnim(AirSequence, 1.0, 0.15, 0);
        Pawn.FreezeAnimAt(0.45, 0);
    }
}

function bool CMSkillValid(Skill S, bool bFinish)
{
    if (S == None || !S.bLearned || !S.bEnabled || S.MeleeAttackTime <= 0
        || S.IsA('SecondSkill') || S.IsMagic())
        return False;
    if (S.bHasSkillPoint && S.SkillPoint <= 0)
        return False;
    if (bFinish)
        return S.IsFinish();
    return S.IsCombo();
}

function bool CMMonsterValid(Monster M)
{
    local vector D;
    local ServerController SC;
    if (M == None || M.bDeleteMe || M.bIsDead || Pawn == None)
        return False;
    SC = ServerController(M.Controller);
    if (SC == None || SC.bDeleteMe || SC.MSI == None)
        return False;
    D = M.Location - Pawn.Location;
    D.Z = 0;
    return VSize(D) <= CMRange;
}

function Monster CMFindMonster(int TargetID)
{
    local GameManager GM;
    local Monster M;
    local ServerController SC;
    local int I;
    GM = GameManager(Level.Game);
    if (GM == None || TargetID <= 0)
        return None;
    for (I = 0; I < GM.Creatures.Length; I++)
    {
        M = Monster(GM.Creatures[I]);
        if (M == None || M.bDeleteMe)
            continue;
        SC = ServerController(M.Controller);
        if (SC != None && !SC.bDeleteMe && SC.MSI != None
            && SC.MSI.PanID == TargetID && CMMonsterValid(M))
            return M;
    }
    return None;
}

function CMFaceTarget()
{
    if (!CMEnabled || !IsInState('CommandMelee') || !CMPlayerValid()
        || !CMMonsterValid(CMTarget))
        return;
    // Face this animation's bound target, not the next pending target ID.
    RotatePawnTo(CMTarget.Location);
    Pawn.DesiredRotation = Pawn.Rotation;
}

function CMFinishGroundMove()
{
    local vector D;
    local SephirothInterface UI;
    if (!IsInState('CommandMelee') || !bMouseMove || Pawn == None || Pawn.bDeleteMe)
        return;
    D = Destination - Pawn.Location;
    D.Z = 0;
    if (VSize(D) > 30)
        return;
    bMouseMove = False;
    InteractTo = None;
    Destination = Pawn.Location;
    UI = SephirothInterface(myHud);
    if (UI != None && SephirothController(UI.Controller) != None)
        // Original UI clears DS_None ground decals, preserving actor lock decals.
        Global.Stopped();
}

function bool CMCanContinuePart()
{
    local vector D;
    if (!CMPlayerValid())
        return False;
    // A queued replacement may finish the old animation after its victim dies;
    // CMHit suppresses all hits on the old invalid object in this case.
    if (CMTarget == None || CMTarget.bDeleteMe || CMTarget.bIsDead)
        return CMFindMonster(CMPendingID) != None;
    D = CMTarget.Location - Pawn.Location;
    D.Z = 0;
    return VSize(D) <= CMRange && CMMonsterValid(CMTarget);
}

function bool CMManualSpiritPlaying()
{
    local name Sequence;
    local float Frame, Rate;
    if (CMEnabled || Pawn == None || Pawn.bDeleteMe) return False;
    Pawn.GetAnimParams(0, Sequence, Frame, Rate);
    return Sequence == 'Spirits' && Pawn.IsAnimating(0);
}

// Call this exec on the game thread. Repeated calls update the request only.
exec function CmdMelee(int TargetID, float MaxDistance)
{
    local float PreviousRange;
    if (Level.TimeSeconds < CMMouseResumeAt)
        return;
    // Spirit BUFF acknowledgement can return to Navigating before cast AnimEnd.
    if (CMManualSpiritPlaying())
        return;
    if (TargetID <= 0 || !(MaxDistance > 0))
        return;
    if (!CMPlayerValid())
        return;
    // Never steal an existing manual attack, spell, preparation or UI state.
    if (!IsInState('CommandMelee') && (!IsInState('Navigating')
        || bIsActing || CoolTime >= 0 || Pawn.ActionStage == STAGE_Prepare))
        return;
    PreviousRange = CMRange;
    CMRange = MaxDistance;
    if (CMFindMonster(TargetID) == None)
    {
        CMRange = PreviousRange;
        return;
    }
    CMPendingID = TargetID;
    if (CMEnabled && IsInState('CommandMelee'))
        return;
    if (!CMSkillValid(PSI.Combo, False))
        return;
    // Weapon preparation belongs to the original game. Do not overlap it.
    if (!PSI.ArmState)
    {
        if (Level.TimeSeconds >= CMArmRetryAt)
        {
            CMArmRetryAt = Level.TimeSeconds + 1.0;
            ToggleArmState();
        }
        return;
    }
    CMEnabled = True;
    CMManualTarget = None;
    CMManualRetryAt = 0;
    CMStopReason = "external state transition";
    if (bMouseMove && !bKeyboardMove)
        GotoState('CommandMelee', 'Move');
    else
        GotoState('CommandMelee');
}

exec function CmdMeleeStop()
{
    if (IsInState('CommandMelee'))
        CMStop("explicit stop");
}

exec function CmdMeleeStatus()
{
    ;
}

function CMReset()
{
    CMEnabled = False;
    CMManualTarget = None;
    CMManualRetryAt = 0;
    CMPlaying = False;
    CMAdvance = False;
    CMTarget = None;
    CMActiveSkill = None;
    CMComboSkill = None;
    CMFinishSkill = None;
    CMPendingID = 0;
    CMComboIndex = 0;
    CMComboTotal = 0;
    CMSequence = 0;
    CMHitBones.Length = 0;
    CMHitFrames.Length = 0;
    if (SkillFrame != None)
        SkillFrame.ResetSkillFrame();
    ThisSkill = None;
    NextSkill = None;
    LockedTarget = None;
    ComboCount = -1;
    bIsActing = False;
    bIsActingFinish = False;
    HDI.bCheckHit = False;
    HDI.CheckSkill = None;
    HDI.CheckAttachment = None;
    HDI.CheckBone = '';
    if (ArStepTime.Length > 0)
        ArStepTime.Remove(0, ArStepTime.Length);
    DestroyActionEffect();
    if (Pawn != None && !Pawn.bDeleteMe)
    {
        Pawn.SetActionStage(STAGE_End);
        Pawn.StopAnimating();
    }
    if (CMStrafePawn != None && !CMStrafePawn.bDeleteMe)
        CMStrafePawn.bCanStrafe = CMOldCanStrafe;
    CMStrafePawn = None;
    CMFlushSkillChanges();
}

function bool CMBeginPart()
{
    local float Speed, EndTime, Frame, AnimRate, TotalFrames, BaseRate;
    local array<float> UnusedTimes;
    local int Step, TargetID, I, ActionIndex;
    local name Sequence;
    if (!CMPlayerValid())
        return False;
    CMTarget = CMFindMonster(CMPendingID);
    if (CMTarget == None)
        return False;
    CMFaceTarget();
    if (CMComboTotal == 0)
    {
        CMComboSkill = PSI.Combo;
        CMFinishSkill = PSI.Finish;
        if (!CMSkillValid(CMComboSkill, False))
            return False;
        CMComboTotal = CMComboSkill.ComboCount;
        if (CMComboTotal <= 0)
            CMComboTotal = CMComboSkill.MaxComboCount;
        if (CMComboTotal <= 0)
            return False;
        CMComboIndex = 0;
        CMFinish = False;
        CMCycleSerial++;
    }
    CMActiveSkill = CMComboSkill;
    if (CMFinish)
        CMActiveSkill = CMFinishSkill;
    if (!CMSkillValid(CMActiveSkill, CMFinish)
        || !Pawn.HasAnim(CMActiveSkill.AnimSequence))
        return False;
    // One finish action request per completed blue cycle.
    if (CMFinish && CMFinishCycle == CMCycleSerial)
        return False;
    Speed = CMActiveSkill.MeleeAttackTime / 1000.0;
    Step = CMComboIndex - 1;
    if (CMFinish)
        Step = -1;
    // Validate the segment before calling the native function, whose invalid
    // Step path asserts rather than returning a script-level failure.
    if (Character(Pawn).CAnimAction == None)
        return False;
    ActionIndex = -1;
    for (I = 0; I < Character(Pawn).CAnimAction.Actions.Length; I++)
        if (Character(Pawn).CAnimAction.Actions[I].Sequence == CMActiveSkill.AnimSequence)
        {
            ActionIndex = I;
            break;
        }
    if (ActionIndex < 0)
        return False;
    if (Step >= Character(Pawn).CAnimAction.Actions[ActionIndex].ActionTime.Length && Step >= 0)
        return False;
    CMPlaying = True;
    CMAdvance = False;
    CMSequence = 0;
    bIsActing = True;
    bIsActingFinish = CMFinish;
    ThisSkill = CMActiveSkill;
    CMLastHitFrame = -2;
    CMLastHitBone = '';
    CMHitBones.Length = 0;
    CMHitFrames.Length = 0;
    CMPartSerial++;
    Character(Pawn).GetPlayAnimAction(CMActiveSkill.AnimSequence,
        CMChannel, UnusedTimes, EndTime, Step, Speed, 0);
    Pawn.GetAnimParams(CMChannel, Sequence, Frame, AnimRate);
    if (Sequence != CMActiveSkill.AnimSequence || EndTime <= 0)
        return False;
    CMStartFrame = Frame;
    CMObservedFrame = Frame;
    CMProgressAt = Level.TimeSeconds;
    if (!Character(Pawn).AnimationInfo(CMActiveSkill.AnimSequence, TotalFrames, BaseRate)
        || TotalFrames <= 1)
        return False;
    CMEndFrame = (TotalFrames - 1.0) / TotalFrames;
    if (!CMFinish && Character(Pawn).CAnimAction != None)
    {
        for (I = 0; I < Character(Pawn).CAnimAction.Actions.Length; I++)
            if (Character(Pawn).CAnimAction.Actions[I].Sequence == CMActiveSkill.AnimSequence)
            {
                if (CMComboIndex < Character(Pawn).CAnimAction.Actions[I].ActionTime.Length)
                    CMEndFrame = Character(Pawn).CAnimAction.Actions[I].ActionTime[CMComboIndex] / TotalFrames;
                break;
            }
    }
    if (CMEndFrame <= CMStartFrame || CMEndFrame > 1)
        return False;
    CMDeadline = Level.TimeSeconds + EndTime + 1.0;
    TargetID = ServerController(CMTarget.Controller).MSI.PanID;
    CMSequence = SkillFrame.AdvanceFrame();
    SkillFrame.NewSkillFrame(CMSequence, SkillFrame.STATE_Melee);
    if (CMFinish)
    {
        CMFinishCycle = CMCycleSerial;
        Net.NotiActMeleeFinish(CMActiveSkill.SkillName, CMSequence,
            TargetID, CMTarget.Location, Character(Pawn).ActionSpeedRate);
    }
    else
        Net.NotiActMeleeCombo(CMActiveSkill.SkillName, CMSequence,
            TargetID, CMTarget.Location, Character(Pawn).ActionSpeedRate,
            CMComboIndex + 1);
    SpawnActionEffect(CMActiveSkill);
    return True;
}

function CMConsumeCompletedPart()
{
    if (!CMAdvance || CMCompletedSerial != CMPartSerial
        || CMConsumedSerial == CMPartSerial)
        return;
    if ((CMFinish || (CMComboIndex >= CMComboTotal - 1
        && !CMSkillValid(CMFinishSkill, True))) && !CMApplySkillChanges())
        return;
    CMConsumedSerial = CMPartSerial;
    CMAdvance = False;
    CMPlaying = False;
    DestroyActionEffect();
    if (CMFinish)
    {
        CMComboTotal = 0;
        CMFinish = False;
    }
    else
    {
        CMComboIndex++;
        if (CMComboIndex >= CMComboTotal)
        {
            if (CMSkillValid(CMFinishSkill, True))
                CMFinish = True;
            else
                CMComboTotal = 0;
        }
    }
    if (!CMBeginPart())
        CMStop("cannot begin next part");
}

function CMHit(name Bone)
{
    local name Sequence;
    local float Frame, AnimRate;
    local int TargetID, I;
    if (!CMEnabled || !CMPlaying || CMAdvance || !CMPlayerValid()
        || !CMMonsterValid(CMTarget) || CMSequence <= 0)
        return;
    Pawn.GetAnimParams(CMChannel, Sequence, Frame, AnimRate);
    if (Sequence != CMActiveSkill.AnimSequence || Frame < CMStartFrame)
        return;
    // A native frame wrap cannot generate another red damage pass.
    if (CMFinish && Frame + 0.0001 < CMObservedFrame
        && Level.TimeSeconds + 0.03 >= (CMDeadline - 1.0)) return;
    // Remember all notify positions in this part, including interleaved bones.
    for (I = 0; I < CMHitFrames.Length; I++)
        if (Abs(Frame - CMHitFrames[I]) < 0.00001 && Bone == CMHitBones[I])
            return;
    CMHitBones[CMHitBones.Length] = Bone;
    CMHitFrames[CMHitFrames.Length] = Frame;
    CMLastHitFrame = Frame;
    CMLastHitBone = Bone;
    TargetID = ServerController(CMTarget.Controller).MSI.PanID;
    Net.NotiHitMelee(CMSequence, Pawn.Location, TargetID, CMTarget.Location, 0);
}

function CMPartFinished(int Channel, optional bool bEndEvent, optional bool bFinishWindow)
{
    local name Sequence;
    local float Frame, AnimRate;
    if (!CMEnabled || !CMPlaying || CMAdvance || Pawn == None
        || Channel != CMChannel || CMCompletedSerial == CMPartSerial)
        return;
    Pawn.GetAnimParams(CMChannel, Sequence, Frame, AnimRate);
    if (Sequence != CMActiveSkill.AnimSequence) return;
    if (CMFinish)
    {
        if (bFinishWindow) return;
        // AnimEnd can observe frame zero or a lower frame after native wrap.
        // Validate its timing against this part's native duration, not its frame.
        if (bEndEvent)
        {
            if (Level.TimeSeconds + 0.03 < (CMDeadline - 1.0)) return;
        }
        else
        {
            // A Tick/AnimStep is not an authentic AnimEnd. Require time plus
            // an endpoint, observed wrap, or an already stopped animation.
            if (Level.TimeSeconds < (CMDeadline - 1.0) + 0.03) return;
            if (Frame + 0.0001 < CMEndFrame
                && !(CMObservedFrame > CMStartFrame + 0.0001
                    && Frame + 0.0001 < CMObservedFrame)
                && Pawn.IsAnimating(CMChannel)) return;
        }
    }
    else
    {
        if (Frame <= CMStartFrame) return;
        if (bFinishWindow)
        {
            if (CMComboIndex != CMComboTotal - 1
                || !CMSkillValid(CMFinishSkill, True)) return;
        }
        else if (Frame + 0.0001 < CMEndFrame) return;
    }
    // Claim completion before native calls; callbacks consume the part once.
    CMAdvance = True;
    CMCompletedSerial = CMPartSerial;
    CMPlaying = False;
    if (CMFinish)
    {
        Pawn.SetActionStage(STAGE_End);
        Pawn.StopAnimating();
    }
}

state CommandMelee extends Attacking
{
    function BeginState()
    {
        if (Pawn != None && CMStrafePawn == None)
        {
            CMStrafePawn = Pawn;
            CMOldCanStrafe = Pawn.bCanStrafe;
            Pawn.bCanStrafe = True;
        }
        CMComboTotal = 0;
        ActionPool.Length = 0;
        ArStepTime.Length = 0;
        LockedTarget = None;
        InteractTo = None;
        HDI.bCheckHit = False;
        if (!CMBeginPart())
            CMStop("cannot begin first part");
    }

    function EndState()
    {
        ;
        Global.CMReset();
    }

    function PlayerTick(float DeltaTime)
    {
        local name Sequence;
        local float Frame, AnimRate;
        if (!CMCanContinuePart())
        {
            CMStop("invalid player, control lock, target or range");
            return;
        }
        // Preserve original position/input replication and other cumulative fixes.
        Global.PlayerTick(DeltaTime);
        if (!IsInState('CommandMelee') || !CMEnabled)
            return;
        CMFaceTarget();
        CMFinishGroundMove();
        Pawn.GetAnimParams(CMChannel, Sequence, Frame, AnimRate);
        if (Sequence == CMActiveSkill.AnimSequence && Frame > CMObservedFrame + 0.00001)
        {
            CMObservedFrame = Frame;
            CMProgressAt = Level.TimeSeconds;
        }
        // Use an observed endpoint if its native callback was missed.
        // This never synthesizes hits or restarts the active animation.
        if (!CMAdvance)
            CMPartFinished(CMChannel, False);
        if (CMAdvance)
            CMConsumeCompletedPart();
        else if (Level.TimeSeconds > CMDeadline && Level.TimeSeconds - CMProgressAt > 1.0)
        {
            CMStop("animation completion timeout");
        }
    }

    function UpdateRotation(float DeltaTime, float MaxPitch)
    {
        Super.UpdateRotation(DeltaTime, MaxPitch);
        CMFaceTarget();
    }

    event NetRecv_PlayerMove(vector Loc, rotator Rot, vector Acc, bool bJump, float JumpZ)
    {
        local vector MouseDestination;
        local bool bKeepMouseDestination;
        bKeepMouseDestination = CMEnabled && bMouseMove && !bKeyboardMove
            && Pawn != None && !Pawn.bDeleteMe && Character(Pawn) != None
            && Character(Pawn).IsAvatar() && !CMControlBlocked();
        if (bKeepMouseDestination)
            MouseDestination = Destination;
        // Preserve the original sync metadata, jump handling and server logic.
        Super.NetRecv_PlayerMove(Loc, Rot, Acc, bJump, JumpZ);
        if (bKeepMouseDestination && CMEnabled && IsInState('CommandMelee')
            && Pawn != None && !Pawn.bDeleteMe && !CMControlBlocked())
        {
            Destination = MouseDestination;
            bMouseMove = True;
        }
    }

    function HitDetect(name Bone, optional bool bApplyHitEffect)
    {
        CMHit(Bone);
    }
    event Damaged(Pawn Attacker, Skill S, bool bPain, bool bKnockback,
        bool bCritical, bool bMiss, bool bBlock, bool bImmune)
    {
        // Original visuals, sounds, damage metadata and real knockback remain.
        Global.Damaged(Attacker, S, bPain, bKnockback,
            bCritical, bMiss, bBlock, bImmune);
        if (CMEnabled && IsInState('CommandMelee') && !bKnockback
            && Pawn != None && !Pawn.bDeleteMe && Character(Pawn) != None
            && !Character(Pawn).bIsDead && !CMControlBlocked())
            Character(Pawn).bJustDamaged = False;
    }
    function AnimStep(int Channel) { CMPartFinished(Channel, False); }
    function AnimEnd(int Channel) { CMPartFinished(Channel, True); }
    function TweenToFinish() { CMPartFinished(CMChannel, False, True); }
    function AchieveGoal() {}
    // Landing must not overwrite an independent mouse movement destination.
    function Landfloor(vector HitNormal) {}
    function TargetDead() {}
    function StopAction() {}
    function NetRecv_StartCombo(Skill S, int CC, float Speed) {}
    function NetRecv_StartFinish(Skill S, float Speed) {}
    // Own command actions are already playing. Server echoes cannot queue them
    // again, stop movement, or install a remote dash lock on the local actor.
    event NetRecv_ActMeleeCombo(string N, Character Target, vector Loc, float Speed, int CC) {}
    event NetRecv_ActMeleeFinish(string N, Character Target, vector Loc, float Speed) {}
    event NetRecv_StartCast(Skill S, Character Target, vector Loc, float Speed)
    {
        if (S == None)
            return;
        if (S.IsA('SecondSkill'))
        {
            CMStop("server advanced cast priority", True);
            Global.NetRecv_StartCast(S, Target, Loc, Speed);
        }
        else
        {
            // Ordinary/passive buff casting keeps its visual effect, but may
            // not replace the command-owned character animation or movement.
            SpawnCastEffect(S);
        }
    }
    function PlayerAnimation(name N, float Rate, float TweenTime)
    {
        ;
    }
    function bool CanStop(float Distance) { return Distance < 30; }

    // Engine PlayerWalking.ProcessMove, without Approaching's walk-animation
    // substitution. Input still changes position; it does not restart the skill.
    function ProcessMove(float DeltaTime, vector NewAccel,
        eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        if (Pawn == None || !CMPlayerValid())
            return;
        // MoveTo owns mouse acceleration. Zero keyboard input must not brake it.
        if (!bMouseMove || bKeyboardMove)
            Pawn.Acceleration = NewAccel;
        if (bDoubleJump && (bUpdating || Pawn.CanDoubleJump()))
            Pawn.DoDoubleJump(bUpdating);
        else if (bPressedJump)
            Pawn.DoJump(bUpdating);
        Pawn.SetViewPitch(Rotation.Pitch);
        if (Pawn.Physics != PHYS_Falling)
        {
            if (bDuck == 0)
                Pawn.ShouldCrouch(False);
            else if (Pawn.bCanCrouch)
                Pawn.ShouldCrouch(True);
        }
    }

    exec function KeyboardMove()
    {
        bMouseMove = False;
        bKeyboardMove = True;
        bCameraReversed = False;
        if (Pawn != None)
            Destination = Pawn.Location;
    }

    function MovePawnToMove(Actor MoveTarget, vector Loc)
    {
        if (Pawn == None)
            return;
        CMManualTarget = None;
        CMManualRetryAt = 0;
        // Auto-attacking may first request an approach toward a character.
        // That is a manual target interaction, not a ground-only command move.
        if (Character(MoveTarget) != None && MoveTarget != Pawn)
        {
            Global.MovePawnToMove(MoveTarget, Loc);
            return;
        }
        if (!CMCanContinuePart())
        {
            CMStop("ground move after invalid attack target", True);
            Global.MovePawnToMove(MoveTarget, Loc);
            // The ground click has no skill animation of its own. After its
            // movement request, restore this local pawn's explicit base loop.
            CMRestoreBasePose();
            return;
        }
        InteractTo = None;
        LockedTarget = None;
        bKeyboardMove = False;
        bMouseMove = True;
        Destination = Loc;
        GotoState('CommandMelee', 'Move');
    }

    // Manual attack wins. Leaving this state clears all command-owned notifies.
    function MovePawnToAttackMelee(Actor MoveTarget)
    {
        Global.MovePawnToAttackMelee(MoveTarget);
    }
    function bool MovePawnToAttackRange(Actor MoveTarget, vector Loc)
    {
        return Global.MovePawnToAttackRange(MoveTarget, Loc);
    }
    function MovePawnToAttackBow(Actor MoveTarget, vector Loc)
    {
        Global.MovePawnToAttackBow(MoveTarget, Loc);
    }
    function bool Start2ndSkillAction(Skill S, Actor Target, vector Loc)
    {
        // Also covers transformation skills which send a request without
        // entering SecondSkillAttacking immediately.
        return Global.Start2ndSkillAction(S, Target, Loc);
    }

Begin:
    Stop;
Move:
    bMouseMove = True;
    MoveTo(Destination, CMTarget, Pawn.bIsWalking);
    CMFinishGroundMove();
    bMouseMove = False;
    Stop;
}

// Inherit all original melee actions, movement, hit checks and packet timing.
state MeleeAttacking
{
	function StartCombo()
	{
		local vector v2d;

		// 如果连击开始计数小于30，开启宏检测
		if(nComboStartCount < 30)
			bOnMacroKiller = True;

		// 红蓝职业重置计数
		if(PSI.JobName == 'Red' || PSI.JobName == 'Blue')
			nComboStartCount = 0;

		if(bOnMacroKiller)
		{
			// 如果计数小于10，可以开始连击
			if(nComboStartCount < 10)
			{
				// 计算到目标的2D距离
				v2d = lockedtarget.location - pawn.location;
				v2d.z = 0;
				// 如果距离足够近，开始连击
				if (canstop(vsize(v2d)))
				{
					ComboCount = 0;
					nComboStartCount++;
					PlayAction(PSI.Combo,0,0);
					NextSkill = None;
				}
				else
					GotoState('Navigating');

				fBlockedTime = Level.TimeSeconds;
			}
			else
				// 如果计数为5，显示警告
				if(nComboStartCount == 5)
					myHud.AddMessage(2, Localize("Warnings", "CannotUseSkill", "Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));

			// 根据计数范围衰减计数
			if(nComboStartCount < 3)
			{
				// 小于3时，0.3秒后衰减
				if(Level.TimeSeconds - fBlockedTime > 0.3f)
					if(nComboStartCount > 0)
						nComboStartCount--;
			}
			else
			{
				// 大于等于3时，1秒后衰减
				if(Level.TimeSeconds - fBlockedTime > 1)
					if(nComboStartCount > 0)
						nComboStartCount--;
			}

			fLastAttackTime = Level.TimeSeconds;
			// 如果超过1.5秒没有攻击，重置计数
			if(Level.TimeSeconds - fLastAttackTime > 1.5f)
				nComboStartcount = 0;
		}
	}

    function PlayerTick(float DeltaTime)
    {
        Super.PlayerTick(DeltaTime);
    }
}

defaultproperties
{
}
