class DefinitionStore extends Object;
struct SkillShape
{
    var string Key;
    var string BookName;
    var byte SlotType;
    var name AnimSequence;
    var int ComboCount;
    var int MaxComboCount;
    var int NumberOfShot;
    var int NumOfShot;
    var int AngleOfShot;
    var bool bContinuousShot;
    var bool bPullUp;
    var bool bGuided;
    var bool bParabola;
    var float DelayOfContinuousShot;
    var class<Actor> FireClass;
    var class<Emitter> CastClass;
    var class<Actor> ExtraClass;
    var class<Actor> SupportClass;
    var string FireEffect;
    var name FireBone;
    var vector FireOffset;
    var string CastEffect;
    var name CastBone;
    var Skill.SkillDamageType DamageType;
    var bool bSelf;
    var bool bEnchant;
    var bool bIsSplash;
    var bool bServerHitCheck;
    var Material EffectMaterial;
};
var array<SkillShape> Rows;
var int CharacterID;
var string CharacterName;
var bool Ready;
static function ClearAll()
{
    class'RoundStore'.static.CancelSupport(class'RoundStore'.default.SupportOwner);
    default.Rows.Length=0; default.Ready=False;
    default.CharacterID=0; default.CharacterName="";
}
static function int Find(string Key)
{
    local int I;
    for (I=0;I<default.Rows.Length;I++) if (default.Rows[I].Key~=Key) return I;
    return -1;
}
static function int Remember(BowSkill S)
{
    local int I;
    if (S==None || S.SkillName=="") return -1;
    I=Find(S.SkillName); if (I>=0) return I;
    I=default.Rows.Length; default.Rows.Length=I+1;
    default.Rows[I].Key=S.SkillName;
    default.Rows[I].BookName=S.BookName;
    default.Rows[I].SlotType=S.SlotType;
    default.Rows[I].AnimSequence=S.AnimSequence;
    default.Rows[I].ComboCount=S.ComboCount;
    default.Rows[I].MaxComboCount=S.MaxComboCount;
    default.Rows[I].NumberOfShot=S.NumberOfShot;
    default.Rows[I].NumOfShot=S.NumOfShot;
    default.Rows[I].AngleOfShot=S.AngleOfShot;
    default.Rows[I].bContinuousShot=S.bContinuousShot;
    default.Rows[I].bPullUp=S.bPullUp;
    default.Rows[I].bGuided=S.bGuided;
    default.Rows[I].bParabola=S.bParabola;
    default.Rows[I].DelayOfContinuousShot=S.DelayOfContinuousShot;
    default.Rows[I].FireClass=S.FireClass;
    default.Rows[I].CastClass=S.CastClass;
    default.Rows[I].ExtraClass=S.ExtraClass;
    default.Rows[I].SupportClass=S.SupportClass;
    default.Rows[I].FireEffect=S.FireEffect;
    default.Rows[I].FireBone=S.FireBone;
    default.Rows[I].FireOffset=S.FireOffset;
    default.Rows[I].CastEffect=S.CastEffect;
    default.Rows[I].CastBone=S.CastBone;
    default.Rows[I].DamageType=S.DamageType;
    default.Rows[I].bSelf=S.bSelf;
    default.Rows[I].bEnchant=S.bEnchant;
    default.Rows[I].bIsSplash=S.bIsSplash;
    default.Rows[I].bServerHitCheck=S.bServerHitCheck;
    default.Rows[I].EffectMaterial=S.EffectMaterial;
    return I;
}
static function Capture(ClientController CC)
{
    local int I,J;
    local BowSkill S;
    if (CC==None || CC.PSI==None || CC.Pawn==None || CC.Pawn.bDeleteMe
        || Character(CC.Pawn)==None || !Character(CC.Pawn).IsAvatar()
        || CC.PSI.SkillBooks.Length==0) return;
    if (default.CharacterName!="" && default.CharacterName!=string(CC.PSI.PlayName))
        ClearAll();
    if (default.Ready) { default.CharacterID=CC.PSI.PanID; return; }
    default.CharacterID=CC.PSI.PanID; default.CharacterName=string(CC.PSI.PlayName);
    // One pass over initialized local skill books, never a frame/scene scan.
    for (I=0;I<CC.PSI.SkillBooks.Length;I++)
        if (CC.PSI.SkillBooks[I]!=None)
            for (J=0;J<CC.PSI.SkillBooks[I].Skills.Length;J++)
            {
                S=BowSkill(CC.PSI.SkillBooks[I].Skills[J]);
                if (S!=None) Remember(S);
            }
    default.Ready=default.Rows.Length>0;
}
static function RestoreAt(BowSkill S, int I)
{
    if (S==None || I<0 || I>=default.Rows.Length) return;
    S.SkillName=default.Rows[I].Key;
    S.BookName=default.Rows[I].BookName;
    S.SlotType=default.Rows[I].SlotType;
    S.AnimSequence=default.Rows[I].AnimSequence;
    S.ComboCount=default.Rows[I].ComboCount;
    S.MaxComboCount=default.Rows[I].MaxComboCount;
    S.NumberOfShot=default.Rows[I].NumberOfShot;
    S.NumOfShot=default.Rows[I].NumOfShot;
    S.AngleOfShot=default.Rows[I].AngleOfShot;
    S.bContinuousShot=default.Rows[I].bContinuousShot;
    S.bPullUp=default.Rows[I].bPullUp;
    S.bGuided=default.Rows[I].bGuided;
    S.bParabola=default.Rows[I].bParabola;
    S.DelayOfContinuousShot=default.Rows[I].DelayOfContinuousShot;
    S.FireClass=default.Rows[I].FireClass;
    S.CastClass=default.Rows[I].CastClass;
    S.ExtraClass=default.Rows[I].ExtraClass;
    S.SupportClass=default.Rows[I].SupportClass;
    S.FireEffect=default.Rows[I].FireEffect;
    S.FireBone=default.Rows[I].FireBone;
    S.FireOffset=default.Rows[I].FireOffset;
    S.CastEffect=default.Rows[I].CastEffect;
    S.CastBone=default.Rows[I].CastBone;
    S.DamageType=default.Rows[I].DamageType;
    S.bSelf=default.Rows[I].bSelf;
    S.bEnchant=default.Rows[I].bEnchant;
    S.bIsSplash=default.Rows[I].bIsSplash;
    S.bServerHitCheck=default.Rows[I].bServerHitCheck;
    S.EffectMaterial=default.Rows[I].EffectMaterial;
}
static function Refresh(ClientController CC, Skill Skill)
{
    local BowSkill S;
    if (CC==None || CC.PSI==None || !default.Ready
        || default.CharacterName!=string(CC.PSI.PlayName)) return;
    S=BowSkill(Skill);
    if (S!=None) RestoreAt(S,Find(S.SkillName));
    // SkillLevel, SkillPoint, MeleeAttackTime, learned/enabled/control status
    // remain authoritative live data. No network action counter is overwritten.
}
// Resolve by the server-confirmed selected identity, never by an old object address.
static function BowSkill ResolveSelected(ClientController CC)
{
    local int I,J,N;
    local string Key;
    local BowSkill S;
    if (CC==None || CC.bDeleteMe || CC.PSI==None) return None;
    Key=CC.PSI.ComboSkill;
    if (Key=="") return None;
    Capture(CC);
    for(I=0;I<CC.PSI.SkillBooks.Length;I++)
        if(CC.PSI.SkillBooks[I]!=None)
            for(J=0;J<CC.PSI.SkillBooks[I].Skills.Length;J++)
            {
                S=BowSkill(CC.PSI.SkillBooks[I].Skills[J]);
                if(S!=None && S.SkillName~=Key)
                {
                    N=Find(Key);
                    // A missing definition must not be learnt from a possibly partial refresh.
                    if(default.Ready && N<0) { CC.PSI.Combo=None; return None; }
                    RestoreAt(S,N);
                    CC.PSI.Combo=S;
                    return S;
                }
            }
    CC.PSI.Combo=None;
    return None;
}
static function Apply(ClientController CC, BowSkill Round, BowSkill Source)
{
    local int I;
    Capture(CC);
    if (!default.Ready || Source==None) return;
    I=Find(Source.SkillName);
    // Only initialization captures definitions; refresh/use cannot replace them.
    RestoreAt(Round,I);
}

defaultproperties
{
}
