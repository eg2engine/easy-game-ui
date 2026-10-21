/* Version-locked FD3D9InternalState light submission cache. No heap or COM
   ownership is introduced. Pending/current light arrays belong to the driver. */
typedef unsigned int U32;
extern "C" {
long __cdecl _InterlockedExchange(long volatile *,long);
#pragma intrinsic(_InterlockedExchange)
struct Cache { volatile long lock; U32 state,valid; };
static void Lock(Cache *s) { while (_InterlockedExchange(&s->lock,1)) { __asm { pause } } }
static void Unlock(Cache *s) { _InterlockedExchange(&s->lock,0); }
static void Select(Cache *s,U32 state) {
    if (s->state!=state) { s->state=state; s->valid=0; }
}
__declspec(dllexport) U32 __cdecl MustSend(Cache *s,U32 state,U32 slot) {
    U32 send=1,i;
    if (slot>=8) return 1;
    Lock(s); Select(s,state);
    // Disabled -> enabled must submit even if the copied light bytes match.
    if ((s->valid&(1u<<slot)) && *(U32 *)(state+0x12ac+slot*4)) {
        U32 *pending=(U32 *)(state+0x608+slot*0x68);
        U32 *current=(U32 *)(state+0xf6c+slot*0x68);
        for (i=0;i<26;i++) if (pending[i]!=current[i]) break;
        send=(i!=26);
    }
    Unlock(s); return send;
}
__declspec(dllexport) void __cdecl Sent(Cache *s,U32 state,U32 slot,long result) {
    if (slot>=8) return;
    Lock(s); Select(s,state);
    if (result>=0) s->valid|=1u<<slot;
    else s->valid&=~(1u<<slot); // Retry after any failed SetLight call.
    Unlock(s);
}
__declspec(dllexport) void __cdecl Reset(Cache *s) {
    Lock(s); s->state=0; s->valid=0; Unlock(s);
}
}
