class FlightPoseWorker extends Info;
var ClientController Viewer;
static function Bind(Hero H, ClientController CC, int Mode)
{
    local FlightPoseWorker W, Existing;
    if (H == None || H.bDeleteMe) return;
    foreach H.ChildActors(class'FlightPoseWorker',W)
        if (W.Owner == H && !W.bDeleteMe)
        {
            if (Mode == 0) W.Destroy();
            else Existing=W;
        }
    if (Mode == 0 || H == CC.Pawn || Existing != None) return;
    W=H.Spawn(class'FlightPoseWorker',H);
    if (W != None) W.Viewer=CC;
}
static function Unbind(Hero H)
{
    local FlightPoseWorker W;
    foreach H.ChildActors(class'FlightPoseWorker',W)
        if (W.Owner == H && !W.bDeleteMe) W.Destroy();
}
event Tick(float DeltaTime)
{
    local Hero H;

    local name CurrentSequence, AirSequence;
    local float Frame, Rate;
    local bool Dedicated, bAnimating;
    local ClientController CC;
    H=Hero(Owner);
    if (H == None || H.bDeleteMe || Viewer == None || Viewer.bDeleteMe
        || H.PrePivot.Z != H.Default.PrePivot.Z + 200)
    { Destroy(); return; }




    if (H == Viewer.Pawn || H.bIsDead || H.Physics == PHYS_Falling)
        return;
    CC = ClientController(H.Controller);
    if (CC == None || CC.bDeleteMe || CC.PSI == None || CC.PSI.bDeleteMe
        || CC.PSI.CheckBuffDontAct()) return;
    if (CC.IsInState('Attacking') || CC.IsInState('MeleeAttacking')
        || CC.IsInState('RangeAttacking') || CC.IsInState('BowAttacking')
        || CC.IsInState('SecondSkillAttacking') || CC.IsInState('EnchantSupport')
        || CC.IsInState('JustDead') || CC.IsInState('Stunning')
        || CC.IsInState('Knockbacking')) return;
    H.GetAnimParams(0, CurrentSequence, Frame, Rate);
    bAnimating=H.IsAnimating(0);
    if (H.bJustDamaged && bAnimating) return;
    if (bAnimating && CurrentSequence != H.BasicAnim[0]
        && CurrentSequence != H.BasicAnim[1] && CurrentSequence != H.BasicAnim[2]
        && CurrentSequence != H.BasicAnim[3] && CurrentSequence != H.BasicAnim[4]
        && CurrentSequence != 'Fly' && CurrentSequence != 'Flying'
        && CurrentSequence != 'FlyIdle' && CurrentSequence != 'FlyForward') return;
    if (H.Acceleration == vect(0,0,0) && H.HasAnim('FlyIdle')) AirSequence = 'FlyIdle';
    else if (H.Acceleration != vect(0,0,0) && H.HasAnim('FlyForward')) AirSequence = 'FlyForward';
    else if (H.HasAnim('Fly')) AirSequence = 'Fly';
    else if (H.HasAnim('Flying')) AirSequence = 'Flying';
    Dedicated = AirSequence != '';
    if (!Dedicated)
    {
        AirSequence=H.BasicAnim[3];
        if (AirSequence == '' || !H.HasAnim(AirSequence)) return;
    }
    if (Dedicated)
    {
        if (CurrentSequence != AirSequence || !bAnimating)
        {
            H.AnimSequence = AirSequence;
            H.LoopAnim(AirSequence, 1, 0.15, 0);
        }
    }
    else if (CurrentSequence != AirSequence || Rate != 0)
    {
        H.AnimSequence = AirSequence;
        H.PlayAnim(AirSequence, 1, 0.15, 0);
        H.FreezeAnimAt(0.45, 0);
    }

}

defaultproperties
{
}
