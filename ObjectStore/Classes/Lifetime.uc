class Lifetime extends Object;
static function CleanupCharacter(Character A)
{
    if (Creature(A) != None)
    {
        ReleasePattern(Creature(A));
        ReleaseStyles(A);
    }
}
// Only private objects created by this package enter the native release gate.
static function ReleasePattern(Creature C)
{
    local Pattern P;
    if (C == None) return;
    P=C.PatternInfo; C.PatternInfo=None;
    if (P != None && P.Class == class'OwnedPattern' && P.Outer == C)
        DynamicUnloadObject(P);
}
static function ReleaseColor(ColorModifier M, Actor Host)
{
    if (M == None || M.Class != class'OwnedColor' || M.Outer != Host) return;
    M.Material=None;
    DynamicUnloadObject(M);
}
static function ReleaseBlend(FinalBlend M, Actor Host)
{
    local ColorModifier Tint;
    if (M == None || M.Class != class'OwnedBlend' || M.Outer != Host) return;
    Tint=ColorModifier(M.Material); M.Material=None;
    DynamicUnloadObject(M);
    ReleaseColor(Tint,Host);
}
static function ReleaseStyles(Character A)
{
    local int I;
    local ColorModifier C;
    local FinalBlend F;
    // Detach every skin before deleting any private wrapper.
    for (I=0; I<A.Skins.Length; I++)
        if (I<A.ColorStyle.Length && A.Skins[I]==A.ColorStyle[I]
            && I<A.BlendStyle.Length && A.BlendStyle[I]!=None)
            A.Skins[I]=A.BlendStyle[I].Material;
    for (I=0; I<A.ColorStyle.Length; I++)
    {
        C=A.ColorStyle[I]; A.ColorStyle[I]=None;
        ReleaseColor(C,A);
    }
    for (I=0; I<A.BlendStyle.Length; I++)
    {
        F=A.BlendStyle[I]; A.BlendStyle[I]=None;
        ReleaseBlend(F,A);
    }
    A.ColorStyle.Length=0; A.BlendStyle.Length=0;
    A.bStyleCreated=False;
}

defaultproperties
{
}
