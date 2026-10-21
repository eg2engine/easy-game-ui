/* Freestanding x86 implementation embedded in the version-locked Core patch.
   All data comes through State; all engine addresses are module-base relative.
   Candidate addresses are used only as bitmap keys, never dereferenced here. */
typedef unsigned int U32;
typedef unsigned char U8;
typedef unsigned short U16;
typedef void * Ptr;
extern "C" {
long __cdecl _InterlockedExchange(long volatile *, long);
#pragma intrinsic(_InterlockedExchange)
typedef struct Leaf { U32 count; U32 bits[512]; } Leaf;
typedef struct State {
    Leaf *dir[65536];
    volatile long lock;
    U32 live, leaves, allocations, frees;
    U16 tag[5]; // Persistent tag, also safe for allocators retaining this pointer.
} State;
typedef Ptr (__thiscall *MallocFn)(Ptr, U32, const U16 *);
typedef void (__thiscall *FreeFn)(Ptr, Ptr);
typedef void (__thiscall *StepFn)(Ptr, Ptr, Ptr);

static void Acquire(State *s) {
    while (_InterlockedExchange(&s->lock,1)) { __asm { pause } }
}
static void Release(State *s) { _InterlockedExchange(&s->lock,0); }
static Ptr Allocate(State *s,U32 base) {
    Ptr allocator=*(Ptr *)(base+0xf6018);
    MallocFn fn=*(MallocFn *)(*(U32 *)allocator);
    s->tag[0]='S'; s->tag[1]='G'; s->tag[2]='6'; s->tag[3]='0'; s->tag[4]=0;
    return fn(allocator,sizeof(Leaf),s->tag);
}
static void Free(U32 base, Ptr p) {
    Ptr allocator=*(Ptr *)(base+0xf6018);
    FreeFn fn=*(FreeFn *)(*(U32 *)allocator+8);
    fn(allocator,p);
}
__declspec(dllexport) void __cdecl GuardAdd(State *s,U32 base,Ptr object,Ptr query,Ptr diagnostic) {
    U32 p=(U32)object,slot,word,mask,i;
    Leaf *leaf;
    /* The two reserved native slots are restored after normal Core bootstrap. */
    *(Ptr *)(base+0x121c60+3500*4)=query;
    *(Ptr *)(base+0x121c60+3501*4)=diagnostic;
    if (!p || (p&3)) return;
    slot=p>>16; word=(p&0xffff)>>7; mask=1u<<((p>>2)&31);
    Acquire(s);
    leaf=s->dir[slot];
    if (!leaf) {
        leaf=(Leaf *)Allocate(s,base);
        if (!leaf) { Release(s); return; }
        leaf->count=0;
        for (i=0;i<512;i++) ((volatile U32 *)leaf->bits)[i]=0;
        s->dir[slot]=leaf; s->leaves++; s->allocations++;
    }
    if (!(leaf->bits[word]&mask)) { leaf->bits[word]|=mask; leaf->count++; s->live++; }
    Release(s);
}
__declspec(dllexport) void __cdecl GuardRemove(State *s,U32 base,Ptr object) {
    U32 p=(U32)object,slot,word,mask;
    Leaf *leaf;
    if (!p || (p&3)) return;
    slot=p>>16; word=(p&0xffff)>>7; mask=1u<<((p>>2)&31);
    Acquire(s); leaf=s->dir[slot];
    if (leaf && (leaf->bits[word]&mask)) {
        leaf->bits[word]&=~mask; leaf->count--; s->live--;
        if (!leaf->count) {
            s->dir[slot]=0; s->leaves--; s->frees++;
            Free(base,leaf);
        }
    }
    Release(s);
}
__declspec(dllexport) U32 __cdecl GuardContains(State *s,Ptr object) {
    U32 p=(U32)object,result=0; Leaf *leaf;
    if (!p || (p&3)) return 0;
    Acquire(s); leaf=s->dir[p>>16];
    if (leaf) result=(leaf->bits[(p&0xffff)>>7]>>((p>>2)&31))&1;
    Release(s); return result;
}
static void Finish(U32 base,Ptr frame) {
    U8 **code=(U8 **)((U32)frame+0xc);
    (*code)++; /* EX_EndFunctionParms */
    if (**code==0x42) {
        Ptr ignored=0;
        ((StepFn)(base+0x108f0))(frame,*(Ptr *)((U32)frame+8),&ignored);
    }
}
__declspec(dllexport) void __cdecl GuardExec(State *s,U32 base,Ptr self,Ptr frame,Ptr result) {
    Ptr object=0;
    (void)self;
    ((StepFn)(base+0x108f0))(frame,*(Ptr *)((U32)frame+8),&object);
    Finish(base,frame);
    *(U32 *)result=GuardContains(s,object);
}
__declspec(dllexport) void __cdecl GuardDiagnostic(State *s,U32 base,Ptr self,Ptr frame,Ptr result) {
    U32 metric=0,value=0;
    (void)self;
    ((StepFn)(base+0x108f0))(frame,*(Ptr *)((U32)frame+8),&metric);
    Finish(base,frame); Acquire(s);
    if (metric==0) value=s->live;
    else if (metric==1) value=s->leaves;
    else if (metric==2) value=s->allocations;
    else if (metric==3) value=s->frees;
    Release(s); *(U32 *)result=value;
}
}
