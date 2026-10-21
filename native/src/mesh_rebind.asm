
wrapper:
 push ebp
 mov ebp,esp
 sub esp,0x10
 push ebx
 push esi
 push edi
 mov dword ptr [ebp-4],ecx
 mov dword ptr [ebp-8],-1
 mov dword ptr [ebp-12],0
 mov dword ptr [ebp-16],0x504f5345
 call pc
pc:
 pop ebx
 sub ebx,pc
 mov esi,dword ptr [ecx+0xb8]
 test esi,esi
 je invoke
 mov eax,dword ptr [esi+0x28]
 mov edx,dword ptr [ebx+0x11a760]
 mov edi,32
mesh_class:
 test eax,eax
 je invoke
 cmp eax,edx
 je mesh_ok
 mov eax,dword ptr [eax+0x2c]
 dec edi
 jnz mesh_class
 jmp invoke
mesh_ok:
 mov esi,dword ptr [ecx+0xdc]
 test esi,esi
 je invoke
 cmp dword ptr [esi+0x60],ecx
 jne invoke
 cmp dword ptr [esi+0x104],1
 jl invoke
 mov esi,dword ptr [esi+0x100]
 test esi,esi
 je invoke
 mov eax,dword ptr [esi+8]
 mov dword ptr [ebp-12],eax
 lea ecx,[ebp-12]
 call dword ptr [ebx+0x11a160]
 test eax,eax
 je invoke
 cmp dword ptr [eax],0x00680053
 jne invoke
 cmp dword ptr [eax+4],0x0074006f
 jne invoke
 cmp word ptr [eax+8],0
 je remember
 cmp dword ptr [eax+8],0x00000043
 jne invoke
remember:
 xor eax,eax
 cmp dword ptr [esi+0x30],0
 setne al
 mov dword ptr [ebp-8],eax
invoke:
 push dword ptr [ebp+12]
 push dword ptr [ebp+8]
 mov ecx,dword ptr [ebp-4]
 call native_entry
 pop edi
 pop esi
 pop ebx
 mov esp,ebp
 pop ebp
 ret 8
native_entry:
 sub esp,0xc
 push esi
 mov esi,ecx
 jmp 312598
replay_stub:
 mov ecx,dword ptr [esp+8]
 cmp dword ptr [ecx-16],0x504f5345
 jne native_loop
 cmp dword ptr [ecx-4],esi
 jne native_loop
 cmp dword ptr [ecx-12],eax
 jne native_loop
 cmp dword ptr [ecx-8],0
 jne native_loop
 push 0
 jmp replay_args
native_loop:
 push 1
replay_args:
 sub esp,8
 jmp 313116
