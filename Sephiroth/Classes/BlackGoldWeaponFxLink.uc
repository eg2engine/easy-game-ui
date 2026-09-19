// Script-only hardening; retain V40 visuals and the five-distinct-affix gate.
class BlackGoldWeaponFxLink extends Actor config(WeaponFxDiagnostics);

var Attachment Weapon;
var Actor Visual;
var float CheckDelay;

// Append script state only. Never insert fields into a native attachment/item.
var config bool bDebugTrace;
var SephirothItem ActiveItem;
var class<DesignedWeaponFxBase> ActiveClass;
var float RetryDelay;
var int RetryAttempt;
var array<class<Emitter> > InvalidDetailClasses;
var name StatusReason;
var int StatusMount;
var bool bEligible;
var array<name> TracedStages;
var array<int> TracedValues;

// WornItems slot constants (this UE2 compiler lacks class-qualified const access).
const EquipRightHand = 8;
const EquipLeftHand = 9;
const EquipBothHands = 16;
const MountFist = 32; // Internal marker, NOT an equipment or Hero slot.
const AttachBothHands = 256;
const DetailGlove = 10;

static function bool HasRequiredAffixes(SephirothItem Item)
{
    local int I, J, Count;
    local bool Duplicate;
    if (Item == None)
        return False;
    for (I = 0; I < Item.Affixes.Length; I++)
    {
        if (Item.Affixes[I].AffixName == "" || Item.Affixes[I].AffixValue < 17)
            continue;
        Duplicate = False;
        for (J = 0; J < I; J++)
            if (Item.Affixes[J].AffixName ~= Item.Affixes[I].AffixName
                && Item.Affixes[J].AffixValue >= 17)
                Duplicate = True;
        if (!Duplicate)
            Count++;
        if (Count >= 5)
            return True;
    }
    return False;
}

// Normalize package-qualified mesh names, including the two gauntlet variants.
static function string RawModelKey(string ModelName)
{
    local int Dot;
    ModelName = Caps(ModelName);
    Dot = InStr(ModelName, ".");
    while (Dot >= 0)
    {
        ModelName = Mid(ModelName, Dot + 1);
        Dot = InStr(ModelName, ".");
    }
    if (ModelName == "NONE")
        return "";
    return ModelName;
}

static function string ModelKey(string ModelName)
{
    ModelName = RawModelKey(ModelName);
    if (ModelName == "ACORDGAUNTLETHMB" || ModelName == "ACORDGAUNTLETHFB"
        || ModelName == "ACORDGAUNTLETBHM" || ModelName == "ACORDGAUNTLETBHF")
        return "ACORDGAUNTLETB";
    return ModelName;
}

static function bool IsWeaponSlot(int Slot)
{
    return Slot == EquipRightHand || Slot == EquipLeftHand || Slot == EquipBothHands;
}

static function bool IsFistMount(Attachment W)
{
    local Hero H;
    if (W == None || W.bDeleteMe || Gauntlet(W) == None)
        return False;
    H = Hero(W.Base);
    if (H == None || H.bDeleteMe)
        return False;
    return H.Attachments[H.AT_LeftFist] == W || H.Attachments[H.AT_RightFist] == W;
}

static function int GetMountSlot(Attachment W)
{
    local Hero H;
    if (W == None || W.bDeleteMe)
        return -1;
    H = Hero(W.Base);
    if (H == None || H.bDeleteMe)
        return -1;
    if (IsFistMount(W))
        return MountFist;
    if (H.Attachments[H.AT_RightHand] == W)
        return EquipRightHand;
    if (H.Attachments[H.AT_LeftHand] == W)
        return EquipLeftHand;
    if (H.Attachments[H.AT_BothHand] == W)
        return EquipBothHands;
    return -1;
}

static function bool MatchesModel(Attachment W, SephirothItem Item)
{
    local string Key;
    if (W == None || W.bDeleteMe || Item == None)
        return False;
    Key = ModelKey(Item.ModelName);
    if (Key == "")
        return False;
    return (W.Mesh != None && Key == ModelKey(string(W.Mesh)))
        || (W.StaticMesh != None && Key == ModelKey(string(W.StaticMesh)));
}

static function SephirothItem ResolveItem(Attachment W)
{
    local Pawn Wearer;
    local ClientController CC;
    local WornItems Equipped;
    local SephirothItem Item, Candidate;
    local int I, Slot, Pass;
    Slot = GetMountSlot(W);
    if (Slot < 0)
        return None;
    Wearer = Pawn(W.Base);
    if (Wearer == None || Wearer.bDeleteMe)
        return None;
    CC = ClientController(Wearer.Controller);
    if (CC == None || CC.bDeleteMe || CC.PSI == None || CC.PSI.WornItems == None)
        return None;
    Equipped = CC.PSI.WornItems;
    // The equipment UI reads this list too. Never prefer a detached/shallow Info
    // object over the current equipped item, even when Info is non-null.
    for (I = 0; I < Equipped.Items.Length; I++)
    {
        Item = Equipped.Items[I];
        if (Item != None && IsWeaponSlot(Item.EquipPlace))
            if ((Slot != MountFist || Item.DetailType == DetailGlove)
                && (Item.Model == W || Item == W.Info))
            {
                if (Candidate != None && Candidate != Item)
                    return None;
                Candidate = Item;
            }
    }
    if (Candidate != None)
        return Candidate;
    // Fist slot numbers are NOT equipment slots. No model-only inference.
    if (Slot == MountFist)
        return None;
    // First try the actual slot. The only model-only cross-slot exception is
    // Hero's BothHand attachment -> IP_RHand for AP_BHand (see WornItems).
    for (Pass = 0; Pass < 2; Pass++)
    {
        if (Pass == 1 && Slot != EquipBothHands)
            break;
        Candidate = None;
        for (I = 0; I < Equipped.Items.Length; I++)
        {
            Item = Equipped.Items[I];
            if (Item == None)
                continue;
            if ((Pass == 0 && Item.EquipPlace == Slot)
                || (Pass == 1 && Item.EquipPlace == EquipRightHand
                    && (Item.AttachPlace & AttachBothHands) != 0))
            {
                if (!MatchesModel(W, Item))
                    continue;
                if (Candidate != None && Candidate != Item)
                    return None;
                Candidate = Item;
            }
        }
        if (Candidate != None)
            return Candidate;
    }
    return None;
}

static function int ModelGender(string ModelName)
{
    ModelName = RawModelKey(ModelName);
    if (ModelName == "ACORDGAUNTLETHFB" || ModelName == "ACORDGAUNTLETBHF")
        return 1;
    if (ModelName == "ACORDGAUNTLETHMB" || ModelName == "ACORDGAUNTLETBHM")
        return 0;
    return -1;
}

static function class<DesignedWeaponFxBase> EffectClassFor(Attachment W, SephirothItem Item)
{
    local string Key, MeshKey, StaticKey;
    local int Gender, StaticGender;
    local Pawn Wearer;
    local ClientController CC;
    if (W == None || W.bDeleteMe || Item == None)
        return None;
    // Only called after a current equipment identity and affix gate are known.
    // None guards do not claim to validate arbitrary corrupted native pointers.
    Gender = -1;
    StaticGender = -1;
    if (W.Mesh != None)
    {
        MeshKey = RawModelKey(string(W.Mesh));
        Gender = ModelGender(MeshKey);
        MeshKey = ModelKey(MeshKey);
    }
    if (W.StaticMesh != None)
    {
        StaticKey = RawModelKey(string(W.StaticMesh));
        StaticGender = ModelGender(StaticKey);
        StaticKey = ModelKey(StaticKey);
    }
    if (MeshKey == "" && StaticKey == "")
        return None;
    Key = ModelKey(Item.ModelName);
    if (Key == "")
    {
        Key = MeshKey;
        if (Key == "")
            Key = StaticKey;
    }
    if ((MeshKey != "" && MeshKey != Key) || (StaticKey != "" && StaticKey != Key))
        return None;
    if (Key == "MURCIELSWORDB")
        return class'Designed_MurcielSwordB_Attached';
    if (Key == "ABLAZESTAFFB")
        return class'Designed_AblazeStaffB_Attached';
    if (Key == "GLACIESSTICKB")
        return class'Designed_GlaciesStickB_Attached';
    if (Key == "APLITEBOWB")
        return class'Designed_ApliteBow_HJ_Attached';
    if (Key == "ACORDGAUNTLETB")
    {
        if (Gender >= 0 && StaticGender >= 0 && Gender != StaticGender)
            return None;
        if (Gender < 0)
            Gender = StaticGender;
        if (Gender < 0)
        {
            Wearer = Pawn(W.Base);
            if (Wearer == None || Wearer.bDeleteMe)
                return None;
            CC = ClientController(Wearer.Controller);
            if (CC == None || CC.bDeleteMe || CC.PSI == None)
                return None;
            if (CC.PSI.bIsMale)
                Gender = 0;
            else
                Gender = 1;
        }
        if (Gender == 1)
            return class'Designed_AcordGauntletHF_Attached';
        return class'Designed_AcordGauntletHM_Attached';
    }
    return None;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    Weapon = Attachment(Owner);
    StatusMount = -1;
    StatusReason = 'WaitingMount';
    if (Weapon == None)
        Destroy();
}

simulated function ClearVisual()
{
    local Actor OldVisual;
    OldVisual = Visual;
    Visual = None;
    if (OldVisual != None && !OldVisual.bDeleteMe)
        OldVisual.Destroy();
}

simulated function ResetActive()
{
    ClearVisual();
    ActiveItem = None;
    ActiveClass = None;
    bEligible = False;
    RetryDelay = 0;
    RetryAttempt = 0;
    // InvalidDetailClasses deliberately survives unequip/re-equip on this Link.
}

// Fixed stage names and primitive values only. Never stringify a UObject here.
// Each stage/value pair is emitted only on change, not on every check/Tick.
simulated function TraceStage(name Stage, int Value)
{
    local int I;
    if (!bDebugTrace)
        return;
    for (I = 0; I < TracedStages.Length; I++)
        if (TracedStages[I] == Stage)
        {
            if (TracedValues[I] == Value)
                return;
            TracedValues[I] = Value;
            Log("[BGFX] stage=" $ Stage $ " value=" $ Value);
            return;
        }
    I = TracedStages.Length;
    TracedStages.Length = I + 1;
    TracedValues.Length = I + 1;
    TracedStages[I] = Stage;
    TracedValues[I] = Value;
    Log("[BGFX] stage=" $ Stage $ " value=" $ Value);
}

simulated function SetStatus(name Reason)
{
    if (StatusReason == Reason)
        return;
    StatusReason = Reason;
    if (bDebugTrace)
        Log("[BGFX] status=" $ Reason);
}

// Explicit command reports cached scalar state without traversing more objects.
simulated function ReportToLog()
{
    Log("[BGFX] status=" $ StatusReason $ " mount=" $ StatusMount
        $ " eligible=" $ bEligible $ " visual=" $ (Visual != None)
        $ " retry=" $ RetryAttempt $ " retryDelay=" $ RetryDelay
        $ " blockedClasses=" $ InvalidDetailClasses.Length);
}

simulated function bool IsDetailBlocked(class<Emitter> DetailType)
{
    local int I;
    for (I = 0; I < InvalidDetailClasses.Length; I++)
        if (InvalidDetailClasses[I] == DetailType)
            return True;
    return False;
}

// Record-only callback: safe while a particle is validating its own structure.
// In particular, remember the fault before an unequip can destroy its Visual.
simulated function RememberInvalidDetail(class<Emitter> DetailType)
{
    local int I;
    if (!IsDetailBlocked(DetailType))
    {
        I = InvalidDetailClasses.Length;
        InvalidDetailClasses.Length = I + 1;
        InvalidDetailClasses[I] = DetailType;
        TraceStage('InvalidDetailClass', I + 1);
    }
}

simulated function BlockDetail(class<Emitter> DetailType)
{
    RememberInvalidDetail(DetailType);
    ClearVisual();
    RetryDelay = 0;
    RetryAttempt = 0;
    SetStatus('StructureInvalid');
}

simulated function ScheduleRetry()
{
    RetryAttempt = Min(RetryAttempt + 1, 3);
    if (RetryAttempt == 1)
        RetryDelay = 0.5;
    else if (RetryAttempt == 2)
        RetryDelay = 1.0;
    else
        RetryDelay = 2.0;
    SetStatus('Retry');
    TraceStage('RetryStep', RetryAttempt);
}

simulated event Tick(float DeltaTime)
{
    local SephirothItem Item;
    local class<DesignedWeaponFxBase> WantedClass;
    local DesignedWeaponFxBase Fx;
    local ClientController CC;
    local Hero H;
    if (Weapon == None || Weapon.bDeleteMe)
    {
        Destroy();
        return;
    }
    if (Visual != None && !Visual.bDeleteMe)
        Visual.bHidden = Weapon.bHidden;
    RetryDelay = FMax(0, RetryDelay - DeltaTime);
    CheckDelay -= DeltaTime;
    if (CheckDelay > 0)
        return;
    CheckDelay = 0.75;
    StatusMount = GetMountSlot(Weapon);
    if (StatusMount < 0)
    {
        ResetActive();
        SetStatus('WaitingMount');
        return;
    }
    H = Hero(Weapon.Base);
    CC = ClientController(H.Controller);
    if (CC == None || CC.bDeleteMe || CC.PSI == None || CC.PSI.WornItems == None)
    {
        ResetActive();
        SetStatus('WaitingData');
        return;
    }
    TraceStage('ResolveBefore', 0);
    Item = ResolveItem(Weapon);
    if (Item == None)
    {
        TraceStage('ResolveAfter', 0);
        ResetActive();
        SetStatus('WaitingItem');
        return;
    }
    TraceStage('ResolveAfter', 1);
    CheckDelay = 0.25;
    if (!HasRequiredAffixes(Item))
    {
        TraceStage('Gate', 0);
        ResetActive();
        SetStatus('BelowGate');
        return;
    }
    TraceStage('Gate', 1);
    WantedClass = EffectClassFor(Weapon, Item);
    if (WantedClass == None)
    {
        CheckDelay = 0.75;
        ResetActive();
        SetStatus('UnsupportedModel');
        return;
    }
    if (ActiveItem != Item || ActiveClass != WantedClass)
    {
        ResetActive();
        ActiveItem = Item;
        ActiveClass = WantedClass;
        SetStatus('Pending');
    }
    bEligible = True;
    if (IsDetailBlocked(WantedClass.Default.DetailClass))
    {
        ClearVisual();
        SetStatus('StructureInvalid');
        return;
    }
    if (Visual != None)
    {
        Fx = DesignedWeaponFxBase(Visual);
        if (Visual.bDeleteMe || Fx == None || Visual.Class != WantedClass)
        {
            ClearVisual();
            ScheduleRetry();
            return;
        }
        if (Fx.bDetailStructureInvalid)
        {
            BlockDetail(WantedClass.Default.DetailClass);
            return;
        }
        if (Fx.DetailFx == None || Fx.DetailFx.bDeleteMe)
        {
            // Start a delayed recovery when a previously healthy detail is lost.
            if (RetryAttempt == 0)
            {
                ScheduleRetry();
                return;
            }
        }
        else
        {
            RetryAttempt = 0;
            RetryDelay = 0;
            SetStatus('Ready');
            return;
        }
    }
    else if (StatusReason == 'Ready')
    {
        // The engine may have nulled a destroyed Visual reference.
        ScheduleRetry();
        return;
    }
    if (RetryDelay > 0)
        return;
    if (Visual == None)
    {
        TraceStage('VisualSpawnBefore', 0);
        Fx = Spawn(WantedClass, Self,, Weapon.Location, Weapon.Rotation);
        Visual = Fx;
        if (Fx == None || Fx.bDeleteMe)
        {
            TraceStage('VisualSpawnAfter', 0);
            ClearVisual();
            ScheduleRetry();
            return;
        }
        TraceStage('VisualSpawnAfter', 1);
        Fx.SetBase(Weapon);
        Fx.SetRelativeLocation(vect(0,0,0));
        Fx.SetRelativeRotation(WantedClass.Default.RelativeRotation);
        Fx.SetDrawScale(Weapon.DrawScale);
        Fx.SetDrawScale3D(Weapon.DrawScale3D);
        Fx.bHidden = Weapon.bHidden;
        Fx.DetailAnchor = Weapon;
        Fx.SyncDetailTransform();
        // PostBeginPlay already attempted particle creation: do not retry twice
        // within the same Tick if that first Spawn failed.
        if (Fx.bDetailStructureInvalid)
            BlockDetail(WantedClass.Default.DetailClass);
        else if (Fx.DetailFx == None || Fx.DetailFx.bDeleteMe)
            ScheduleRetry();
        else
        {
            RetryAttempt = 0;
            RetryDelay = 0;
            SetStatus('Ready');
        }
        return;
    }
    if (Fx.EnsureDetailFx())
    {
        RetryAttempt = 0;
        RetryDelay = 0;
        SetStatus('Ready');
    }
    else if (Fx.bDetailStructureInvalid)
        BlockDetail(WantedClass.Default.DetailClass);
    else
        ScheduleRetry();
}

simulated event Destroyed()
{
    ResetActive();
    Super.Destroyed();
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bDebugTrace=False
}
