// Compile as freestanding x86. No persistent mesh/bone cache or allocation.
typedef unsigned int U32;
typedef void* (__thiscall *GetMeshFn)(void*);
typedef int (__thiscall *MeshMatchFn)(void*, U32);

// Entry wrapper admits only the original, pure ULodMeshInstance::GetMesh.
// All other overrides run the untouched original instance implementation.
extern "C" __declspec(dllexport) int __cdecl MatchOnce(U32 base, void* instance, U32 boneName)
{
    GetMeshFn getMesh = (GetMeshFn)((*(U32**)instance)[0xB0 / 4]);
    void* mesh = getMesh(instance);
    if (!mesh) return -1;
    // Reuse the engine's original FName/alias/first-match implementation.
    return ((MeshMatchFn)(base + 0x1AF990))(mesh, boneName);
}
