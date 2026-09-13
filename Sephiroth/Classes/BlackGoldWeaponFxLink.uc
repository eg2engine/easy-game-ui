// V42: equipped-item resolution fix; V40 visuals and V41 affix threshold.
class BlackGoldWeaponFxLink extends Actor;

var Attachment Weapon;
var Actor Visual;
var float CheckDelay;

// WornItems slot constants (this UE2 compiler lacks class-qualified const access).
const EquipRightHand = 8;
const EquipLeftHand = 9;
const EquipBothHands = 16;

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
static function string ModelKey(string ModelName)
{
    local int Dot;
    ModelName = Caps(ModelName);
    Dot = InStr(ModelName, ".");
    while (Dot >= 0)
    {
        ModelName = Mid(ModelName, Dot + 1);
        Dot = InStr(ModelName, ".");
    }
    if (ModelName == "ACORDGAUNTLETHMB" || ModelName == "ACORDGAUNTLETHFB"
        || ModelName == "ACORDGAUNTLETBHM" || ModelName == "ACORDGAUNTLETBHF")
        return "ACORDGAUNTLETB";
    return ModelName;
}

static function bool IsWeaponSlot(int Slot)
{
    return Slot == EquipRightHand || Slot == EquipLeftHand || Slot == EquipBothHands;
}

static function bool MatchesModel(Attachment W, SephirothItem Item)
{
    local string Key;
    if (W == None || Item == None)
        return False;
    Key = ModelKey(Item.ModelName);
    if (Key == "" || Key == "NONE")
        return False;
    return (W.Mesh != None && Key == ModelKey(string(W.Mesh)))
        || (W.StaticMesh != None && Key == ModelKey(string(W.StaticMesh)));
}

static function SephirothItem ResolveItem(Attachment W)
{
    local Pawn Wearer;
    local Hero H;
    local ClientController CC;
    local WornItems Equipped;
    local SephirothItem Item, Candidate;
    local int I, Slot;
    if (W == None)
        return None;
    Wearer = Pawn(W.Base);
    if (Wearer == None)
        return None;
    CC = ClientController(Wearer.Controller);
    if (CC == None || CC.PSI == None || CC.PSI.WornItems == None)
        return None;
    Equipped = CC.PSI.WornItems;
    // The equipment UI reads this list too. Never prefer a detached/shallow Info
    // object over the current equipped item, even when Info is non-null.
    for (I = 0; I < Equipped.Items.Length; I++)
    {
        Item = Equipped.Items[I];
        if (Item != None && IsWeaponSlot(Item.EquipPlace))
            if (Item.Model == W || Item == W.Info)
                return Item;
    }
    // Native attachments need not populate Info or the reverse Model pointer.
    // Resolve their actual hand slot, verifying the mesh during equip transitions.
    Slot = -1;
    H = Hero(Wearer);
    if (H != None)
    {
        if (H.Attachments[H.AT_RightHand] == W)
            Slot = EquipRightHand;
        else if (H.Attachments[H.AT_LeftHand] == W)
            Slot = EquipLeftHand;
        else if (H.Attachments[H.AT_BothHand] == W)
            Slot = EquipBothHands;
    }
    if (Slot >= 0)
    {
        Item = Equipped.FindItem(Slot);
        if (MatchesModel(W, Item))
            return Item;
    }
    // Some two-handed weapons render in a different hand slot. Accept only a
    // unique matching equipped weapon on THIS wearer; never scan inventories,
    // other players, or choose an item based on whether its affixes qualify.
    for (I = 0; I < Equipped.Items.Length; I++)
    {
        Item = Equipped.Items[I];
        if (Item != None && IsWeaponSlot(Item.EquipPlace) && MatchesModel(W, Item))
        {
            if (Candidate != None && Candidate != Item)
                return None;
            Candidate = Item;
        }
    }
    return Candidate;
}

static function class<Actor> EffectClassFor(Attachment W, SephirothItem Item)
{
    local string ModelId;
    if (W == None)
        return None;
    ModelId = Caps(string(W.Mesh) $ " " $ string(W.StaticMesh));
    if (Item != None)
        ModelId = ModelId $ " " $ Caps(Item.ModelName);
    if (InStr(ModelId, "MURCIELSWORDB") >= 0)
        return class'Designed_MurcielSwordB_Attached';
    if (InStr(ModelId, "ABLAZESTAFFB") >= 0)
        return class'Designed_AblazeStaffB_Attached';
    if (InStr(ModelId, "GLACIESSTICKB") >= 0)
        return class'Designed_GlaciesStickB_Attached';
    if (InStr(ModelId, "APLITEBOWB") >= 0)
        return class'Designed_ApliteBow_HJ_Attached';
    if (InStr(ModelId, "ACORDGAUNTLETB") >= 0
        || InStr(ModelId, "ACORDGAUNTLETHMB") >= 0 || InStr(ModelId, "ACORDGAUNTLETHFB") >= 0)
    {
        if (InStr(ModelId, "HF") >= 0 || InStr(Caps(string(W.Base)), "FEMALE") >= 0)
            return class'Designed_AcordGauntletHF_Attached';
        return class'Designed_AcordGauntletHM_Attached';
    }
    return None;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    Weapon = Attachment(Owner);
    if (Weapon == None)
        Destroy();
}

simulated function ClearVisual()
{
    if (Visual != None)
        Visual.Destroy();
    Visual = None;
}

// Explicit diagnostic command writes to the engine log only, never to chat.
simulated function ReportToLog()
{
    local SephirothItem Item;
    local int I;
    Item = ResolveItem(Weapon);
    Log("[BGFX-release42] Weapon=" $ string(Weapon)
        $ " Item=" $ string(Item) $ " Eligible=" $ string(HasRequiredAffixes(Item)));
    if (Weapon != None)
        Log("[BGFX-release42] Base=" $ string(Weapon.Base)
            $ " Mesh=" $ string(Weapon.Mesh) $ " Static=" $ string(Weapon.StaticMesh)
            $ " Info=" $ string(Weapon.Info));
    if (Item != None)
        for (I = 0; I < Item.Affixes.Length; I++)
            Log("[BGFX-release42] " $ Item.Affixes[I].AffixName $ "=" $ Item.Affixes[I].AffixValue
                $ " Display=" $ Item.Affixes[I].Display);
}

simulated event Tick(float DeltaTime)
{
    local SephirothItem Item;
    local class<Actor> WantedClass;
    if (Weapon == None || Weapon.bDeleteMe)
    {
        Destroy();
        return;
    }
    if (Visual != None)
    {
        Visual.bHidden = Weapon.bHidden;
        DesignedWeaponFxBase(Visual).DetailAnchor = Weapon;
        DesignedWeaponFxBase(Visual).SyncDetailTransform();
    }
    CheckDelay -= DeltaTime;
    if (CheckDelay > 0)
        return;
    CheckDelay = 0.25;
    Item = ResolveItem(Weapon);
    WantedClass = EffectClassFor(Weapon, Item);
    if (Pawn(Weapon.Base) == None || WantedClass == None || !HasRequiredAffixes(Item))
    {
        ClearVisual();
        return;
    }
    if (Visual != None && Visual.Class != WantedClass)
        ClearVisual();
    // Keep the approved base V40 appearance, not the experimental *_17 variants.
    if (Visual == None)
    {
        Visual = Spawn(WantedClass, Self,, Weapon.Location, Weapon.Rotation);
        if (Visual != None)
        {
            Visual.SetBase(Weapon);
            Visual.SetRelativeLocation(vect(0,0,0));
            Visual.SetRelativeRotation(WantedClass.Default.RelativeRotation);
            Visual.SetDrawScale(Weapon.DrawScale);
            Visual.SetDrawScale3D(Weapon.DrawScale3D);
            Visual.bHidden = Weapon.bHidden;
            DesignedWeaponFxBase(Visual).DetailAnchor = Weapon;
            DesignedWeaponFxBase(Visual).SyncDetailTransform();
        }
    }
}

simulated event Destroyed()
{
    ClearVisual();
    Super.Destroyed();
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
}
