// V96: bounded, event-maintained predecessor hints for FD3D9Resource.
// Existing allocation, virtual destruction, COM Release and hash removal remain native.
// No scene/resource polling, allocations, eviction policy or actor references.
typedef unsigned int U32;
struct Hint { U32 Key; U32 Link; };
static __forceinline U32& Word(void* p, U32 off) {
    return *(U32*)((char*)p + off);
}
static __forceinline Hint& Slot(Hint* table, U32 key) {
    return table[((key >> 4) ^ (key >> 16)) & 32767];
}
static __forceinline void Set(Hint* table, U32 key, U32 link) {
    Hint& h = Slot(table, key);
    h.Key = key;
    h.Link = link;
}
extern "C" __declspec(dllexport) void __fastcall AfterInsert(
    void* resource, void* device, Hint* table) {
    U32 self = (U32)resource;
    Set(table, self, (U32)device + 0xd4);
    U32 next = Word(resource, 0x18);
    if (next) Set(table, next, self + 0x18);
}
extern "C" __declspec(dllexport) void __fastcall Unlink(
    void* resource, void* device, Hint* table) {
    U32 self = (U32)resource;
    Hint& h = Slot(table, self);
    U32* link;
    if (h.Key == self && h.Link && *(U32*)h.Link == self) {
        link = (U32*)h.Link;
    } else {
        // Direct-mapped collisions only discard an optimization hint.
        // The original list is always authoritative, with no capacity limit.
        link = (U32*)((char*)device + 0xd4);
        while (*link && *link != self) link = (U32*)(*link + 0x18);
    }
    if (h.Key == self) { h.Key = 0; h.Link = 0; }
    if (*link == self) {
        U32 next = Word(resource, 0x18);
        *link = next;
        if (next) Set(table, next, (U32)link);
    }
    // Caller resumes original FD3D9Resource destructor at RVA 0x1b9a7.
    // That code clears Next, unlinks the resource hash, and clears HashNext.
}
