class UILifetime extends Object;
// These methods only accept private, unlinked objects owned by the caller.
static function ReleasePair(out FinalBlend Blend, out ConstantColor Color, Object Host)
{
    local FinalBlend F;
    local ConstantColor C;
    F=Blend; C=Color; Blend=None; Color=None;
    if (F != None && F.Class == class'OwnedBlend' && F.Outer == Host)
    { F.Material=None; DynamicUnloadObject(F); }
    if (C != None && C.Class == class'OwnedConstant' && C.Outer == Host)
        DynamicUnloadObject(C);
}
static function ReleaseMap(out FinalBlend Blend, out Combiner Combine, out TexScaler Scale, Object Host)
{
    local FinalBlend F;
    local Combiner C;
    local TexScaler S;
    F=Blend; C=Combine; S=Scale;
    Blend=None; Combine=None; Scale=None;
    // Sever the whole chain before any material or referenced texture is released.
    if (F != None && F.Class == class'OwnedBlend' && F.Outer == Host) F.Material=None;
    if (C != None && C.Class == class'OwnedCombiner' && C.Outer == Host)
    { C.Material1=None; C.Material2=None; C.Mask=None; }
    if (S != None && S.Class == class'OwnedScaler' && S.Outer == Host) S.Material=None;
    if (F != None && F.Class == class'OwnedBlend' && F.Outer == Host) DynamicUnloadObject(F);
    if (C != None && C.Class == class'OwnedCombiner' && C.Outer == Host) DynamicUnloadObject(C);
    if (S != None && S.Class == class'OwnedScaler' && S.Outer == Host) DynamicUnloadObject(S);
}
static function ReleaseEnchant(EnchantInfoInstance I, EnchantBox Host)
{
    if (I == None || I.Class != class'OwnedEnchant' || I.Outer != Host) return;
    I.Info=None; DynamicUnloadObject(I);
}
static function ReleaseBox(out EnchantBox Box, Object Host)
{
    local EnchantBox B;
    local EnchantInfoInstance I;
    B=Box; Box=None;
    if (B == None) return;
    if (B.Class == class'OwnedEnchantBox' && B.Outer != Host) return;
    while (B.EnchantInfoMap.Length > 0)
    {
        I=B.EnchantInfoMap[B.EnchantInfoMap.Length-1];
        B.EnchantInfoMap.Remove(B.EnchantInfoMap.Length-1,1);
        ReleaseEnchant(I,B);
    }
    if (B.Class == class'OwnedEnchantBox' && B.Outer == Host)
    { B.OwnerController=None; DynamicUnloadObject(B); }
    else DynamicUnloadObject(B);
}
static function ReleaseQuickInfo(out QuickKeyInfo Info, Object Host)
{
    local QuickKeyInfo I;
    I=Info; Info=None;
    if (I == None || I.Class != class'OwnedQuickInfo' || I.Outer != Host) return;
    I.Skill_ref=None; I.ISI_ref=None; I.QuickKeyButton=None; I.PlayerOwner=None;
    DynamicUnloadObject(I);
}

defaultproperties
{
}
