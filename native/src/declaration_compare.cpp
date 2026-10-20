// Actual D3D9 FShaderDeclaration equality: only active streams/components count.
// Comparing the whole struct with memcmp would incorrectly compare unused data.
typedef unsigned int U32;
typedef unsigned char Byte;
static int Count(const Byte* p, U32 offset) { return *(const int*)(p+offset); }
extern "C" __declspec(dllexport) int __fastcall DeclarationEqual(const Byte* left, void*, const Byte* right)
{
    int streams=Count(left,0x440);
    if (streams!=Count(right,0x440)) return 0;
    for (int i=0;i<streams;++i) {
        const Byte* a=left+i*0x44;
        const Byte* b=right+i*0x44;
        int components=Count(a,0x40);
        if (components!=Count(b,0x40)) return 0;
        for (int j=0;j<components;++j) {
            // Keep the original pair order and stop on the first difference.
            if (*(const U32*)(a+j*8)!=*(const U32*)(b+j*8)) return 0;
            if (*(const U32*)(a+j*8+4)!=*(const U32*)(b+j*8+4)) return 0;
        }
    }
    return 1;
}
