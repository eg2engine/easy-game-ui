
 pushfd
 pushad
 cmp dword ptr [esp+0x38],0
 je original
 cmp dword ptr [esp+0x28],0
 jne original
 mov esi,ecx
 cmp dword ptr [esi+0x104],1
 jl original
 mov edi,dword ptr [esi+0x100]
 test edi,edi
 je original
 cmp dword ptr [edi+0x30],0
 jne original
 mov eax,dword ptr [esp+0x2c]
 cmp eax,dword ptr [edi+8]
 jne original
 call pc
pc:
 pop ebx
 sub ebx,pc
 mov ebp,dword ptr [esi+0x60]
 test ebp,ebp
 je original
 mov edi,dword ptr [ebp+0x28]
 mov edx,32
pawn_loop:
 test edi,edi
 je original
 lea eax,[ebx+5413080]
 cmp edi,eax
 je pawn_ok
 mov edi,dword ptr [edi+0x2c]
 dec edx
 jnz pawn_loop
 jmp original
pawn_ok:
 mov ebp,dword ptr [ebp+0x3cc]
 test ebp,ebp
 je original
 mov edi,dword ptr [ebp+0x28]
 mov edx,32
client_loop:
 test edi,edi
 je original
 lea ecx,[edi+0x24]
 push edi
 push edx
 lea edi,[ebx+client_name]
 mov edx,17
 call name_is
 pop edx
 pop edi
 test eax,eax
 jnz client_ok
 mov edi,dword ptr [edi+0x2c]
 dec edx
 jnz client_loop
 jmp original
client_ok:
 mov eax,dword ptr [esi+0x60]
 cmp eax,dword ptr [ebp+0x3cc]
 jne original
 mov edi,dword ptr [ebp+0xb38]
 test edi,edi
 je original
 mov ecx,dword ptr [edi+0x28]
 test ecx,ecx
 je original
 add ecx,0x24
 push edi
 lea edi,[ebx+round_name]
 mov edx,11
 call name_is
 pop edi
 test eax,eax
 je original
 cmp dword ptr [edi+0x134],ebp
 jne original
 test byte ptr [edi+0x13c],1
 jz original
 cmp dword ptr [edi+0x140],0
 jle original
 cmp dword ptr [edi+0x144],0
 jne original
 test byte ptr [edi+0x124],1
 jz original
 cmp dword ptr [edi+0x11c],1
 jle original
 lea ecx,[esp+0x2c]
 push edi
 lea edi,[ebx+shot_name]
 mov edx,5
 call name_is
 pop edi
 test eax,eax
 jnz block
 lea ecx,[esp+0x2c]
 push edi
 lea edi,[ebx+shotc_name]
 mov edx,6
 call name_is
 pop edi
 test eax,eax
 je original
block:
 popad
 popfd
 mov eax,1
 ret 0x14
original:
 popad
 popfd
 push ebp
 mov ebp,esp
 push -1
 jmp 1763893
name_is:
 push esi
 push edi
 push edx
 call dword ptr [ebx+0x26c428]
 mov esi,eax
 mov ecx,dword ptr [esp]
 cld
 repe cmpsw
 sete al
 movzx eax,al
 pop edx
 pop edi
 pop esi
 ret
client_name:
 .byte 67,0,108,0,105,0,101,0,110,0,116,0,67,0,111,0,110,0,116,0,114,0,111,0,108,0,108,0,101,0,114,0,0,0
round_name:
 .byte 82,0,111,0,117,0,110,0,100,0,83,0,107,0,105,0,108,0,108,0,0,0
shot_name:
 .byte 83,0,104,0,111,0,116,0,0,0
shotc_name:
 .byte 83,0,104,0,111,0,116,0,67,0,0,0
