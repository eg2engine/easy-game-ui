// Version-locked UE2 x86 layouts, verified against the shipped Engine/Core.
// FName contains one 32-bit index; the original Core operators compare it.
// No index/pose cache, allocation, object reference or animation state change.
typedef unsigned int U32;
typedef unsigned char Byte;
static U32 Read(const void* p, U32 offset) { return *(const U32*)((const Byte*)p+offset); }
static int Count(const void* p, U32 offset) { return *(const int*)((const Byte*)p+offset); }

// __fastcall with an unused EDX parameter has the entry/return ABI of thiscall:
// ECX = this, name = stack argument, callee pops 4, nonvolatile registers saved.
extern "C" __declspec(dllexport) int __fastcall BoneIndex(void* mesh, void*, U32 name)
{
    if (!name) return -1; // Unlike sequence lookup, bone lookup excludes None.
    int count=Count(mesh,0x2F8);
    const U32* aliases=(const U32*)Read(mesh,0x2F4);
    for (int i=0;i<count;++i)
        if (aliases[i]==name) {
            name=((const U32*)Read(mesh,0x300))[i];
            break; // Resolve one alias, first match, exactly like the original.
        }
    count=Count(mesh,0x1E8);
    const Byte* bones=(const Byte*)Read(mesh,0x1E4);
    for (int i=0;i<count;++i)
        if (*(const U32*)(bones+i*0x40)==name) return i;
    return -1;
}

extern "C" __declspec(dllexport) void* __fastcall AnimSequence(void* animation, void*, U32 name)
{
    const Byte* sequences=(const Byte*)Read(animation,0x48);
    int count=Count(animation,0x4C);
    for (int i=0;i<count;++i)
        if (*(const U32*)(sequences+i*0x2C)==name)
            return (void*)(sequences+i*0x2C);
    return 0; // None may itself be a stored sequence name; do not special-case it.
}

extern "C" __declspec(dllexport) void* __fastcall AnimMovement(void* animation, void*, U32 name)
{
    const Byte* sequences=(const Byte*)Read(animation,0x48);
    int count=Count(animation,0x4C);
    for (int i=0;i<count;++i)
        if (*(const U32*)(sequences+i*0x2C)==name)
            return (Byte*)Read(animation,0x3C)+i*0x58;
    return 0;
}
