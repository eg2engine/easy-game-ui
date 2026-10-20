class LiveRegistry extends Object;
native(3500) static final function bool IsRegistered(Object Candidate);
native(3501) static final function int Diagnostic(int Metric);
static function bool IsLiveActor(Object Candidate, LevelInfo Scope)
{
    local Actor A;
    if (Scope == None || !IsRegistered(Scope) || !IsRegistered(Candidate))
        return False;
    if (Scope.bDeleteMe)
        return False;
    A=Actor(Candidate);
    if (A == None || A.bDeleteMe)
        return False;
    // Base controller, UI markers and pawns can occupy different streamed levels.
    // Validate the actor's own level without requiring identity with the caller's level.
    if (!IsRegistered(A.Level))
        return False;
    return !A.Level.bDeleteMe;
}

defaultproperties
{
}
