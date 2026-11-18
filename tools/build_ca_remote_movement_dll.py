"""从固定生产 DLL 生成 CA 三处远端移动候选；保留 Walking，不覆盖原件。

门禁同步调用现有 CanApplyRemoteCAMotion，不复制原生对象字段或特殊业务规则。
输出及清单只允许写到工作区 .tmp；依赖沿用 requirements-remote-movement.txt。
"""

import argparse
import hashlib
import json
from pathlib import Path
import struct

import pefile
from keystone import Ks, KS_ARCH_X86, KS_MODE_32


WORKSPACE = Path(__file__).resolve().parents[2]
BASELINE = 'e20b332cee1cff232a85f0a6b2aa67ff752ff281694f66fd30b402ece3376209'
MODE = 'ca-three-sites-with-walking-v1'
SITES = {
    0x656FA: bytes.fromhex('ff d2 51 d9 46 34'),
    0x65843: bytes.fromhex('75 17 dd d8 8b 06'),
    0x658D8: bytes.fromhex('0f 85 92 00 00 00'),
}
QUERY = 'CanApplyRemoteCAMotion'
FIND_FUNCTION = '?FindFunction@UObject@@QAEPAVUFunction@@VFName@@H@Z'
IMPORTS = {
    0x11A03C: ('core.dll', '??0FName@@QAE@PB_WW4EFindName@@@Z'),
    0x11A900: ('kernel32.dll', 'GetProcAddress'),
    0x11A994: ('kernel32.dll', 'GetModuleHandleW'),
}


def align(value, boundary):
    """沿 PE 对齐规则添加新段，不移动原有代码、资源及重定位。"""
    return (value + boundary - 1) // boundary * boundary


def assemble_gate(assembler, section_rva, strings):
    """生成同步脚本门禁，旧包或查询缺失时回退；只返回 EAX 布尔值。

    调用线程沿用原网络事件线程，不保存 UObject/UFunction 引用。FXSAVE/FNINIT/
    FXRSTOR 隔离脚本调用对 x87、MXCSR 和 XMM 的影响，其余寄存器与标志恢复。
    """
    assembly = f'''
        push ebp
        mov ebp, esp
        pushfd
        pushad
        sub esp, 0x220
        and esp, -16
        fxsave [esp]
        fninit
        mov ebx, esp
        mov edi, dword ptr [ebp+8]
        mov dword ptr [ebp-8], 0
        test edi, edi
        jz finish
        call module_base
    module_base:
        pop esi
        sub esi, 0x11111111
        lea eax, [esi+{strings['core']}]
        push eax
        call dword ptr [esi+0x11a994]
        test eax, eax
        jz finish
        lea edx, [esi+{strings['find_function']}]
        push edx
        push eax
        call dword ptr [esi+0x11a900]
        test eax, eax
        jz finish
        mov dword ptr [ebx+0x208], eax
        lea eax, [esi+{strings['query']}]
        push 0
        push eax
        lea ecx, [ebx+0x200]
        call dword ptr [esi+0x11a03c]
        mov eax, dword ptr [ebx+0x200]
        test eax, eax
        jz finish
        push 0
        push eax
        mov ecx, edi
        call dword ptr [ebx+0x208]
        test eax, eax
        jz finish
        mov dword ptr [ebx+0x204], 0
        push 0
        lea edx, [ebx+0x204]
        push edx
        push eax
        mov ecx, edi
        mov edx, dword ptr [edi]
        call dword ptr [edx+0x10]
        xor eax, eax
        cmp dword ptr [ebx+0x204], 0
        setne al
        mov dword ptr [ebp-8], eax
    finish:
        fxrstor [ebx]
        lea esp, [ebp-0x24]
        popad
        popfd
        pop ebp
        ret 4
    '''
    preview = bytes(assembler.asm(assembly, addr=section_rva)[0])
    base_return = section_rva + preview.index(bytes.fromhex('e8 00 00 00 00 5e')) + 5
    assembly = assembly.replace('0x11111111', hex(base_return))
    code = bytes(assembler.asm(assembly, addr=section_rva)[0])
    if section_rva + code.index(bytes.fromhex('e8 00 00 00 00 5e')) + 5 != base_return:
        raise ValueError('门禁模块基址计算不稳定')
    return code, assembly


def assemble_hook(assembler, gate_rva, rva, accepted, original):
    """包装三处局部分支，门禁前后恢复原 CPU 状态，未命中重放原指令。"""
    assembly = f'''
        pushfd
        pushad
        push edi
        call {gate_rva}
        test eax, eax
        jz original
        popad
        popfd
        {accepted}
    original:
        popad
        popfd
        {original}
    '''
    return bytes(assembler.asm(assembly, addr=rva)[0]), assembly


def build(source, destination):
    """锁定输入与 IAT/指令，输出独立候选及可审计配方；拒绝覆盖任何现有产物。"""
    source, destination = Path(source).resolve(), Path(destination).resolve()
    if source == destination:
        raise ValueError('候选不能覆盖输入 DLL')
    if not destination.is_relative_to((WORKSPACE / '.tmp').resolve()):
        raise ValueError('候选必须位于工作区 .tmp 独立任务目录')
    sidecar = destination.with_suffix('.patch.json')
    if destination.exists():
        raise ValueError('候选已存在，拒绝覆盖')
    if sidecar.exists():
        raise ValueError('候选清单已存在，拒绝覆盖')
    raw = source.read_bytes()
    if hashlib.sha256(raw).hexdigest() != BASELINE:
        raise ValueError('生产 DLL 不匹配已审核基线，禁止套用 RVA')
    pe = pefile.PE(data=raw)
    for site, expected in SITES.items():
        if pe.get_data(site, len(expected)) != expected:
            raise ValueError(f'原指令不匹配：{site:#x}')
    imports = {s.address - pe.OPTIONAL_HEADER.ImageBase:
               (d.dll.decode().lower(), s.name.decode() if s.name else None)
               for d in pe.DIRECTORY_ENTRY_IMPORT for s in d.imports}
    for rva, expected in IMPORTS.items():
        if imports.get(rva) != expected:
            raise ValueError(f'导入槽不匹配：{rva:#x}')
    section_rva = align(max(s.VirtualAddress + max(s.Misc_VirtualSize, s.SizeOfRawData)
                            for s in pe.sections), pe.OPTIONAL_HEADER.SectionAlignment)
    assembler = Ks(KS_ARCH_X86, KS_MODE_32)
    # 固定字符串区与门禁分离，原函数名仅查找，不向 FName 表添加新名称。
    strings, payload = {}, bytearray()
    for name, value in [('core', 'Core.dll'.encode('utf-16-le') + b'\0\0'),
                        ('find_function', FIND_FUNCTION.encode('ascii') + b'\0'),
                        ('query', QUERY.encode('utf-16-le') + b'\0\0')]:
        strings[name] = section_rva + 0x400 + len(payload)
        payload.extend(value)
    gate, gate_source = assemble_gate(assembler, section_rva, strings)
    if len(gate) > 0x400:
        raise ValueError('门禁超出预留代码区')
    section = bytearray(gate) + bytes(0x400 - len(gate)) + payload
    recipes = [
        # 跳包仅取消 FarMove，同时回收其原本由被调用方弹出的 28 字节，保持生产 ABI。
        (0x656FA, 'jump_before_far_move',
         'add esp, 0x1c; push ecx; fld dword ptr [esi+0x34]; jmp 0x65700',
         'call edx; push ecx; fld dword ptr [esi+0x34]; jmp 0x65700'),
        # 原 JNE 使用进入钩子前的 TEST 标志，回退还须重放 fstp 与 mov。
        (0x65843, 'zero_horizontal_delta', 'jmp 0x6585c',
         'jne 0x6585c; fstp st(0); mov eax, dword ptr [esi]; jmp 0x65849'),
        (0x658D8, 'small_delta', 'jmp 0x658de',
         'jne 0x65970; jmp 0x658de'),
    ]
    hooks, assembly = [], {'gate': gate_source}
    for site, label, accepted, original in recipes:
        target = section_rva + align(len(section), 16)
        code, text = assemble_hook(assembler, section_rva, target, accepted, original)
        section.extend(bytes(target - section_rva - len(section)))
        section.extend(code)
        hooks.append(dict(label=label, rva=site, target_rva=target,
                          original=SITES[site].hex(), bytes=len(code)))
        assembly[label] = text

    header = pe.sections[0].get_file_offset() + 40 * len(pe.sections)
    if raw[header:header + 40] != bytes(40):
        raise ValueError('PE 头无新段槽，拒绝移动原资源')
    offset = align(len(raw), pe.OPTIONAL_HEADER.FileAlignment)
    raw_size = align(len(section), pe.OPTIONAL_HEADER.FileAlignment)
    result = bytearray(raw) + bytes(offset - len(raw)) + section + bytes(raw_size - len(section))
    result[header:header + 40] = struct.pack(
        '<8sIIIIIIHHI', b'.camove', len(section), section_rva, raw_size, offset,
        0, 0, 0, 0, 0x60000020)
    for item, field, value, fmt in [
        (pe.FILE_HEADER, 'NumberOfSections', len(pe.sections) + 1, '<H'),
        (pe.OPTIONAL_HEADER, 'SizeOfImage',
         align(section_rva + len(section), pe.OPTIONAL_HEADER.SectionAlignment), '<I'),
        (pe.OPTIONAL_HEADER, 'SizeOfCode', pe.OPTIONAL_HEADER.SizeOfCode + raw_size, '<I'),
    ]:
        struct.pack_into(fmt, result, item.get_field_absolute_offset(field), value)
    for entry in hooks:
        site, target = entry['rva'], entry['target_rva']
        start, length = pe.get_offset_from_rva(site), len(SITES[site])
        result[start:start + length] = b'\xe9' + struct.pack('<i', target - site - 5) + b'\x90' * (length - 5)
    parsed = pefile.PE(data=bytes(result))
    struct.pack_into('<I', result, parsed.OPTIONAL_HEADER.get_field_absolute_offset('CheckSum'),
                     parsed.generate_checksum())
    if not pefile.PE(data=bytes(result)).verify_checksum():
        raise ValueError('候选 PE 校验和失败')
    if source.read_bytes() != raw:
        raise RuntimeError('生成期间输入发生变化，拒绝输出')
    report = dict(mode=MODE, source_sha256=BASELINE,
                  output_sha256=hashlib.sha256(result).hexdigest(),
                  section_rva=section_rva, section_size=len(section), gate_rva=section_rva,
                  query=QUERY, hooks=hooks, strings=strings, assembly=assembly,
                  retains_walking=True, retains_production_prefix_speed_and_overdistance=True,
                  new_absolute_relocations=0, native_object_references_cached=False,
                  actual_game_tested=False, deployed=False)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('xb') as stream:
        stream.write(result)
    with sidecar.open('x', encoding='utf-8') as stream:
        json.dump(report, stream, ensure_ascii=False, indent=2)
    return report


def main():
    """只生成独立文件及清单，不自动加载或部署游戏。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    report = build(args.input, args.output)
    print(json.dumps({key: report[key] for key in
                      ['mode', 'output_sha256', 'section_rva', 'section_size']}))


if __name__ == '__main__':
    main()
