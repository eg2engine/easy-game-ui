class QueueIndex extends Object;
var MoveQueue Heads[256];

static function MoveQueue Get(PlayerController C,int Key,bool Create)
{
    local MoveQueue Q;
    local int B;
    if (C==None || C.bDeleteMe || C.Pawn==None || C.Pawn.bDeleteMe) return None;
    B=Key&255; Q=default.Heads[B];
    while (Q!=None)
    {
        if (Q.Driver==C) { Q.Bind(C); return Q; }
        Q=Q.Next;
    }
    if (!Create) return None;
    Q=new(None) class'MoveQueue'; Q.Driver=C; Q.Bind(C);
    Q.Next=default.Heads[B]; default.Heads[B]=Q;
    return Q;
}

static function Release(PlayerController C)
{
    local MoveQueue Q,P,N;
    local int B;
    // Lifecycle event only; this never walks the scene or runs on a timer.
    for (B=0;B<256;B++)
    {
        P=None; Q=default.Heads[B];
        while (Q!=None)
        {
            N=Q.Next;
            if (Q.Driver==C)
            {
                if (P==None) default.Heads[B]=N;
                else P.Next=N;
                Q.Dispose();
            }
            else P=Q;
            Q=N;
        }
    }
}

static function ClearAll()
{
    local MoveQueue Q,N;
    local int B;
    for (B=0;B<256;B++)
    {
        Q=default.Heads[B]; default.Heads[B]=None;
        while (Q!=None) { N=Q.Next; Q.Dispose(); Q=N; }
    }
}

static function bool AllowAction(PlayerController C,int Key,byte Kind)
{
    local MoveQueue Q;
    Q=Get(C,Key,True);
    return Q!=None && C.Level!=None && Q.AllowDisplay(Kind,C.Level.TimeSeconds);
}
static function NoteAction(PlayerController C,int Key,byte Kind,name Sequence)
{
    local MoveQueue Q;
    Q=Get(C,Key,True);
    if (Q!=None && C.Level!=None) Q.NoteDisplay(Kind,Sequence,C.Level.TimeSeconds);
}

defaultproperties
{
}
