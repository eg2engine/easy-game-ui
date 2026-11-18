"""在固定生产 Sephiroth.dll 上生成独立的远端运动候选，不覆盖生产文件。

依赖 pefile、keystone-engine；所有跳转使用模块内相对地址，无新增绝对重定位。
运行方法：python tools/build_remote_movement_dll.py --input 输入 --output 候选
"""

import argparse
import hashlib
import json
from pathlib import Path
import struct

import pefile
from keystone import Ks, KS_ARCH_X86, KS_MODE_32


PRODUCTION_SHA256 = 'e20b332cee1cff232a85f0a6b2aa67ff752ff281694f66fd30b402ece3376209'
SITES = {
    0x656BA: bytes.fromhex('837e24000f84ae000000'),
    0xA2838: bytes.fromhex('d98630040000'),
    0xA2A68: bytes.fromhex('d98630040000'),
}


def align(value, boundary):
    """按 PE 文件或内存段对齐，不改变已有段的位置。"""
    return (value + boundary - 1) // boundary * boundary


def build(source, destination):
    """生成三入口候选与核对清单；输入哈希或原指令不匹配时拒绝输出。"""
    source, destination = Path(source), Path(destination)
    if source.resolve() == destination.resolve():
        raise ValueError('候选不能覆盖输入生产 DLL')
    raw = source.read_bytes()
    if hashlib.sha256(raw).hexdigest() != PRODUCTION_SHA256:
        raise ValueError('仅支持已审核的生产 DLL，禁止跨版本套用 RVA')
    pe = pefile.PE(data=raw)
    for site, expected in SITES.items():
        if pe.get_data(site, len(expected)) != expected:
            raise ValueError(f'原指令不匹配：{site:#x}')
    section_rva = align(max(s.VirtualAddress + max(s.Misc_VirtualSize, s.SizeOfRawData)
                            for s in pe.sections), pe.OPTIONAL_HEADER.SectionAlignment)
    assembler = Ks(KS_ARCH_X86, KS_MODE_32)
    # 门禁沿 Main：拒绝已删除对象、本地 Player、Avatar 和失效 PSI；不增加坐标拒绝。
    gate_source = '''
        push esi
        mov esi, dword ptr [esp+8]
        test esi, esi
        jz reject
        test dword ptr [esi+0x70], 0x1000
        jnz reject
        cmp dword ptr [esi+0x57c], 0
        jne reject
        mov eax, dword ptr [esi+0x3cc]
        test eax, eax
        jz reject
        test dword ptr [eax+0x70], 0x1000
        jnz reject
        test dword ptr [eax+0x948], 1
        jnz reject
        mov eax, dword ptr [esi+0xac0]
        test eax, eax
        jz reject
        test dword ptr [eax+0x70], 0x1000
        jnz reject
        mov eax, 1
        pop esi
        ret
    reject:
        xor eax, eax
        pop esi
        ret
    '''
    gate = bytes(assembler.asm(gate_source, addr=section_rva)[0])
    main_rva = section_rva + align(len(gate), 16)
    # 原样保留生产 x87 比较及 unordered 行为；不能以整数限幅改变 NaN 的原处理。
    # 保留原入口的前置辅助处理和 PSI 新坐标写入，跳过跳包 FarMove/普通包 Walking。
    main_source = f'''
        pushfd
        pushad
        push edi
        call {section_rva}
        add esp, 4
        test eax, eax
        jz original
        popad
        popfd
        cmp dword ptr [esi+0x24], 0
        jne jump_event
        call module_base
    module_base:
        pop edx
        sub edx, 0x11111111
        fld dword ptr [esi+0x48]
        fcomp qword ptr [edx+0x129e80]
        fnstsw ax
        test ah, 5
        jnp fallback_speed
        fld dword ptr [esi+0x48]
        fcomp qword ptr [edx+0x124018]
        fnstsw ax
        test ah, 0x41
        jne speed_ready
    fallback_speed:
        fld dword ptr [edx+0x129e78]
        fstp dword ptr [esi+0x48]
    speed_ready:
        mov edx, dword ptr [edi+0x3cc]
        fld dword ptr [esi+0x48]
        fstp dword ptr [edx+0x450]
        push 0
        push 0
        push 0
        push 0
        push 0
        jmp location_args
    jump_event:
        push dword ptr [esi+0x34]
        push 1
        push dword ptr [esi+0x30]
        push dword ptr [esi+0x2c]
        push dword ptr [esi+0x28]
    location_args:
        push dword ptr [esi+0x14]
        push dword ptr [esi+0x10]
        push dword ptr [esi+0xc]
        push dword ptr [esi+8]
        push dword ptr [esi+4]
        push dword ptr [esi]
        mov ecx, edi
        call 0x160f0
        jmp 0x659ee
    original:
        popad
        popfd
        cmp dword ptr [esi+0x24], 0
        je 0x65772
        jmp 0x656c4
    '''
    preview = bytes(assembler.asm(main_source, addr=main_rva)[0])
    base_return = main_rva + preview.index(bytes.fromhex('e8000000005a')) + 5
    main_source = main_source.replace('0x11111111', hex(base_return))
    main = bytes(assembler.asm(main_source, addr=main_rva)[0])
    if main_rva + main.index(bytes.fromhex('e8000000005a')) + 5 != base_return:
        raise ValueError('模块基址计算位置发生变化')
    section = bytearray(gate)
    section.extend(bytes(main_rva-section_rva-len(section)))
    section.extend(main)
    entries = {0x656BA: main_rva}
    sources = {'gate': gate_source, 'main': main_source}
    # 仅跨过两条近战消息的位置块，继续执行原攻击处理；门禁失败重放被覆盖的 fld。
    for label, site, next_instruction, continuation in [
            ('melee_combo', 0xA2838, 0xA283E, 0xA28F7),
            ('melee_finish', 0xA2A68, 0xA2A6E, 0xA2B27)]:
        rva = section_rva + align(len(section), 16)
        assembly = f'''
            pushfd
            pushad
            push dword ptr [ebx+0x44]
            call {section_rva}
            add esp, 4
            test eax, eax
            jz original
            popad
            popfd
            jmp {continuation}
        original:
            popad
            popfd
            fld dword ptr [esi+0x430]
            jmp {next_instruction}
        '''
        code = bytes(assembler.asm(assembly, addr=rva)[0])
        section.extend(bytes(rva-section_rva-len(section)))
        section.extend(code)
        entries[site] = rva
        sources[label] = assembly

    header_offset = pe.sections[0].get_file_offset() + 40*len(pe.sections)
    if raw[header_offset:header_offset+40] != bytes(40):
        raise ValueError('PE 头没有可用段槽，拒绝移动原有资源')
    file_alignment = pe.OPTIONAL_HEADER.FileAlignment
    offset = align(len(raw), file_alignment)
    raw_size = align(len(section), file_alignment)
    result = bytearray(raw) + bytes(offset-len(raw)) + section + bytes(raw_size-len(section))
    result[header_offset:header_offset+40] = struct.pack(
        '<8sIIIIIIHHI', b'.rmove', len(section), section_rva,
        raw_size, offset, 0, 0, 0, 0, 0x60000020)
    struct.pack_into('<H', result, pe.FILE_HEADER.get_field_absolute_offset('NumberOfSections'),
                     len(pe.sections)+1)
    struct.pack_into('<I', result, pe.OPTIONAL_HEADER.get_field_absolute_offset('SizeOfImage'),
                     align(section_rva+len(section), pe.OPTIONAL_HEADER.SectionAlignment))
    struct.pack_into('<I', result, pe.OPTIONAL_HEADER.get_field_absolute_offset('SizeOfCode'),
                     pe.OPTIONAL_HEADER.SizeOfCode+raw_size)
    for site, target in entries.items():
        start = pe.get_offset_from_rva(site)
        length = len(SITES[site])
        result[start:start+length] = b'\xe9' + struct.pack('<i', target-site-5) + b'\x90'*(length-5)
    parsed = pefile.PE(data=bytes(result))
    struct.pack_into('<I', result, parsed.OPTIONAL_HEADER.get_field_absolute_offset('CheckSum'),
                     parsed.generate_checksum())
    if not pefile.PE(data=bytes(result)).verify_checksum():
        raise ValueError('输出校验和失败')
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(result)
    report = {
        'source_sha256': PRODUCTION_SHA256,
        'output_sha256': hashlib.sha256(result).hexdigest(),
        'section_rva': section_rva, 'section_size': len(section),
        'gate_rva': section_rva,
        'hooks': [{'rva': site, 'target_rva': target,
                   'original': SITES[site].hex()} for site, target in entries.items()],
        'retains_production_coordinate_validation_and_prefix': True,
        'retains_production_speed_x87_including_unordered': True,
        'new_absolute_relocations': 0,
        'assembly': sources,
    }
    destination.with_suffix('.patch.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    return report


def main():
    """命令行只输出独立候选；运行时不部署、不覆盖当前生产 DLL。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    report = build(args.input, args.output)
    print(json.dumps({key: report[key] for key in ['output_sha256', 'section_rva', 'section_size']}))


if __name__ == '__main__':
    main()
