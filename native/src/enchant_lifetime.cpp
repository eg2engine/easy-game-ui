// Version-locked Sephiroth V63 generic enchant gates. No allocations, timers or scene scans.
typedef unsigned int U32;
typedef unsigned short U16;
typedef int (__stdcall *ModuleFn)(const char *);
typedef U32 (__cdecl *ContainsFn)(void *,void *);
typedef int (__thiscall *EqualFn)(void *,const U16 *);
typedef int (__thiscall *DestroyFn)(void *,void *,int);
typedef void (__thiscall *RemoveFn)(void *,int,int);
struct Context { U32 seph,core; };
static U32 Field(U32 p,U32 off) { return *(U32 *)(p+off); }
static int Setup(Context *c,U32 base) {
    char name[9]={'C','o','r','e','.','d','l','l',0};
    c->seph=base;
    c->core=((ModuleFn)Field(base,0x11a9c0))(name);
    if (!c->core) return 0;
    // Fail open to the original path if the bundled V60/V63 registry is absent.
    U16 *tag=(U16 *)(c->core+0x26f000+0x40014);
    return tag[0]=='S' && tag[1]=='G' && tag[2]=='6' && tag[3]=='0';
}
static int Registered(Context *c,U32 p) {
    return ((ContainsFn)(c->core+0x26e110))((void *)(c->core+0x26f000),(void *)p)!=0;
}
static int Enchant(Context *c,U32 p) {
    if (!Registered(c,p)) return 0;
    U32 k=Field(p,0x28),n=0;
    while (k && n++<64) {
        if (!Registered(c,k)) return 0;
        if (k==c->seph+0x1b30a0) return 1;
        k=Field(k,0x2c);
    }
    return 0;
}
extern "C" __declspec(dllexport) U32 __cdecl ReuseEnchant(U32 base,U32 owner,U32 type,const U16 *name) {
    Context c;
    if (!type || !name || !Setup(&c,base) || !Registered(&c,owner)) return 0;
    int n=(int)Field(owner,0x97c);
    U32 *a=(U32 *)Field(owner,0x978);
    if (!a) return 0;
    for (int i=0;i<n;i++) {
        U32 p=a[i];
        if (!Enchant(&c,p) || (Field(p,0x70)&0x1000) || Field(p,0x28)!=type) continue;
        // Use exactly the FString comparison used by the native remove path.
        if (((EqualFn)Field(base,0x11a1b0))((void *)(p+0x3d8),name)) return 1;
    }
    return 0;
}
extern "C" __declspec(dllexport) U32 __cdecl RemoveEnchantMatches(U32 base,U32 owner,const U16 *name) {
    Context c;
    if (!name || !Setup(&c,base)) return 0;
    if (!Registered(&c,owner)) return 1;
    int i=0;
    while (Registered(&c,owner) && i<(int)Field(owner,0x97c)) {
        U32 *a=(U32 *)Field(owner,0x978);
        if (!a) return 1;
        U32 p=a[i];
        if (!Enchant(&c,p) || (Field(p,0x70)&0x1000)) {
            ((RemoveFn)(base+0x13520))((void *)(owner+0x978),i,1);
            continue;
        }
        if (!((EqualFn)Field(base,0x11a1b0))((void *)(p+0x3d8),name)) { i++; continue; }
        U32 level=Field(owner,0x9c);
        if (!Registered(&c,level)) return 1;
        DestroyFn destroy=(DestroyFn)Field(Field(level,0),0xc4);
        if (!destroy((void *)level,(void *)p,0)) { i++; continue; }
        // Destruction callbacks may remove/reorder entries or remove the owner.
        if (!Registered(&c,owner)) return 1;
        a=(U32 *)Field(owner,0x978);
        int count=(int)Field(owner,0x97c);
        for (int j=0;a && j<count;j++) if (a[j]==p) {
            ((RemoveFn)(base+0x13520))((void *)(owner+0x978),j,1);
            break;
        }
        i=0;
    }
    return 1;
}
