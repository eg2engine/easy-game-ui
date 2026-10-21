class RoundStore extends Object;
var RoundSkill MouseRound, CommandRound;
var ClientController SupportOwner;
var Pawn SupportPawn;
var bool SupportLocked, SupportBluePending;
var string SupportBlueName;
var bool SupportRedPending,SupportMagicPending;
var string SupportRedName,SupportMagicName;
static function bool SupportActive(ClientController CC)
{
    return CC!=None && default.SupportLocked && default.SupportOwner==CC
        && CC.Pawn==default.SupportPawn && CC.Pawn!=None && !CC.Pawn.bDeleteMe;
}
static function bool BeginSupport(ClientController CC)
{
    if (CC==None || CC.Pawn==None || CC.Pawn.bDeleteMe || CC.PSI==None
        || CC.PSI.JobName!='Bow' || CC.IsRemotePlayerPawn()) return False;
    if (SupportActive(CC)) return False;
    default.SupportOwner=CC; default.SupportPawn=CC.Pawn;
    default.SupportLocked=True; default.SupportBluePending=False; default.SupportBlueName="";
    default.SupportRedPending=False; default.SupportMagicPending=False;
    default.SupportRedName=""; default.SupportMagicName="";
    return True;
}
static function CancelSupport(ClientController CC)
{
    if (default.SupportOwner!=CC) return;
    default.SupportLocked=False; default.SupportBluePending=False;
    default.SupportBlueName=""; default.SupportOwner=None; default.SupportPawn=None;
    default.SupportRedPending=False; default.SupportMagicPending=False;
    default.SupportRedName=""; default.SupportMagicName="";
}
static function bool DeferSupportSelection(ClientController CC, byte Index, string Name)
{
    if (Index>=3 || !SupportActive(CC)) return False;
    if (Index==0) { default.SupportBluePending=True; default.SupportBlueName=Name; }
    else if (Index==1) { default.SupportRedPending=True; default.SupportRedName=Name; }
    else { default.SupportMagicPending=True; default.SupportMagicName=Name; }
    return True;
}
static function bool FinishSupport(ClientController CC, int Channel)
{
    local name Sequence;
    local float Frame,Rate,Frames,BaseRate;
    local bool Pending,RedPending,MagicPending;
    local string NextBlue,NextRed,NextMagic;
    if (Channel!=0 || !SupportActive(CC) || !CC.IsInState('SummonSpirit')) return False;
    CC.Pawn.GetAnimParams(0,Sequence,Frame,Rate);
    if (Sequence!='Spirits' || Frame<0
        || !Character(CC.Pawn).AnimationInfo('Spirits',Frames,BaseRate)
        || Frames<=1 || Frame<(Frames-1)/Frames-0.0001) return False;
    Pending=default.SupportBluePending; NextBlue=default.SupportBlueName;
    RedPending=default.SupportRedPending; NextRed=default.SupportRedName;
    MagicPending=default.SupportMagicPending; NextMagic=default.SupportMagicName;
    CancelSupport(CC);
    // Clear before sending: synchronous assignment callbacks cannot replay it.
    CC.SetTimer(0,False);
    if (Pending && CC.Net!=None && CC.PSI!=None && CC.PSI.bIsAlive
        && !Character(CC.Pawn).bIsDead)
        CC.Net.NotiSkillAssign(0,NextBlue);
    if (RedPending && CC.Net!=None && CC.PSI!=None && CC.PSI.bIsAlive
        && !Character(CC.Pawn).bIsDead) CC.Net.NotiSkillAssign(1,NextRed);
    if (MagicPending && CC.Net!=None && CC.PSI!=None && CC.PSI.bIsAlive
        && !Character(CC.Pawn).bIsDead) CC.Net.NotiSkillAssign(2,NextMagic);
    return True;
}

static function RoundSkill Begin(ClientController CC, Skill Source, bool Command)
{
    local RoundSkill R;
    local BowSkill S;
    // The source argument can refer to a replaced instance. Do not dereference it
    // when an authoritative selected identity is available.
    if(CC!=None && CC.PSI!=None && CC.PSI.ComboSkill!="")
        S=class'DefinitionStore'.static.ResolveSelected(CC);
    else S=BowSkill(Source);
    class'DefinitionStore'.static.Refresh(CC,S);
    if (CC==None || CC.bDeleteMe || S==None || S.SkillName==""
        || !S.bLearned || !S.bEnabled || !(S.MeleeAttackTime>0)
        || S.MeleeAttackTime>100000 || S.NumberOfShot<=0
        || (S.bHasSkillPoint && S.SkillPoint<=0)) return None;
    if (Command) R=default.CommandRound;
    else R=default.MouseRound;
    if (R==None || R.Driver!=CC)
    {
        R=new(CC) class'RoundSkill';
        if (Command) default.CommandRound=R;
        else default.MouseRound=R;
    }
    R.Active=False;
    R.Driver=CC; R.SourceSkill=None; R.CommandRound=Command;
    R.RoundTarget=None; R.ActionID=0; R.Channel=-1;
    R.FirstFireAt=0; R.ClipEndAt=0; R.NextArrowAt=0;
    R.Fired=False; R.ClipFinished=False; R.Serial++;
    R.SkillName=S.SkillName;
    R.FullName=S.FullName;
    R.FullNameLocalized=S.FullNameLocalized;
    R.BookName=S.BookName;
    R.SlotType=S.SlotType;
    R.AnimSequence=S.AnimSequence;
    R.SkillLevel=S.SkillLevel;
    R.SuccessRate=S.SuccessRate;
    R.ComboCount=S.ComboCount;
    R.MaxComboCount=S.MaxComboCount;
    R.MeleeAttackTime=S.MeleeAttackTime;
    R.MagicCastingSpeed=S.MagicCastingSpeed;
    R.MagicCastingDelay=S.MagicCastingDelay;
    R.ManaConsumption=S.ManaConsumption;
    R.AttackRange=S.AttackRange;
    R.bHasSkillPoint=S.bHasSkillPoint;
    R.SkillPoint=S.SkillPoint;
    R.bLearned=S.bLearned;
    R.bEnabled=S.bEnabled;
    R.bServerHitCheck=S.bServerHitCheck;
    R.bIsSplash=S.bIsSplash;
    R.EffectMaterial=S.EffectMaterial;
    R.NumOfShot=S.NumOfShot;
    R.CastEffect=S.CastEffect;
    R.CastBone=S.CastBone;
    R.FireEffect=S.FireEffect;
    R.FireBone=S.FireBone;
    R.FireOffset=S.FireOffset;
    R.bEnchant=S.bEnchant;
    R.bSelf=S.bSelf;
    R.CastClass=S.CastClass;
    R.FireClass=S.FireClass;
    R.ExtraClass=S.ExtraClass;
    R.SupportClass=S.SupportClass;
    R.SpiritClass=S.SpiritClass;
    R.DamageType=S.DamageType;
    R.bPullUp=S.bPullUp;
    R.NumberOfShot=S.NumberOfShot;
    R.AngleOfShot=S.AngleOfShot;
    R.bContinuousShot=S.bContinuousShot;
    R.DelayOfContinuousShot=S.DelayOfContinuousShot;
    R.bGuided=S.bGuided;
    R.bParabola=S.bParabola;
    // Reject a refresh crossing the copy boundary rather than publish a mixed round.
    if (S.SkillName!=R.SkillName || S.AnimSequence!=R.AnimSequence
        || S.MeleeAttackTime!=R.MeleeAttackTime || S.NumberOfShot!=R.NumberOfShot
        || S.bContinuousShot!=R.bContinuousShot
        || S.DelayOfContinuousShot!=R.DelayOfContinuousShot
        || S.FireClass!=R.FireClass || !S.bLearned || !S.bEnabled) return None;
    class'DefinitionStore'.static.Apply(CC,R,S);
    R.Active=True;
    return R;
}
static function Bind(ClientController CC, Skill S, Actor Target, int ActionID,
    int Channel, float EndAt, float FireAt)
{
    local RoundSkill R;
    R=RoundSkill(S);
    if (R==None || R.Driver!=CC || !R.Active || ActionID<=0) return;
    R.ActionID=ActionID; R.RoundTarget=Target; R.Channel=Channel;
    R.ClipEndAt=EndAt; R.FirstFireAt=FireAt; R.NextArrowAt=FireAt;
}
static function bool ValidMouse(ClientController CC, Skill S)
{
    local RoundSkill R;
    R=RoundSkill(S);
    return CC!=None && R!=None && R==default.MouseRound && R.Driver==CC && R.Active
        && !R.CommandRound && R.ActionID>0 && CC.IsInState('BowAttacking')
        && CC.ThisSkill==R && CC.Net!=None && CC.SkillFrame!=None
        && CC.Pawn!=None && !CC.Pawn.bDeleteMe && CC.PSI!=None
        && CC.PSI.bIsAlive && !CC.PSI.CheckBuffDontAct();
}
static function Cancel(ClientController CC, bool Command)
{
    local RoundSkill R;
    if (Command) R=default.CommandRound;
    else R=default.MouseRound;
    if (R!=None && R.Driver==CC)
    { R.Active=False; R.RoundTarget=None; R.ActionID=0; }
}
static function Release(ClientController CC)
{
    local RoundSkill R;
    CancelSupport(CC);
    R=default.MouseRound;
    if (R!=None && R.Driver==CC)
    {
        R.Active=False; R.Driver=None; R.RoundTarget=None; R.SourceSkill=None;
        if (CC.ThisSkill==R) CC.ThisSkill=None;
        default.MouseRound=None;
    }
    R=default.CommandRound;
    if (R!=None && R.Driver==CC)
    {
        R.Active=False; R.Driver=None; R.RoundTarget=None; R.SourceSkill=None;
        if (CC.ThisSkill==R) CC.ThisSkill=None;
        default.CommandRound=None;
    }
    // No native forced free while a stack/projectile may still reference it.
    // Detached private snapshots are collected by the engine's normal GC.
}

defaultproperties
{
}
