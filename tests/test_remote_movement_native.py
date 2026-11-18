"""执行候选 DLL 中真实 x86 分支，验证远端门禁、参数、回退及重定位。

依赖 pefile、unicorn。此测试替代了事件回调，不代表客户端联网或物理验收。
"""

import argparse
import hashlib
import json
from pathlib import Path
import struct

import pefile
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
from unicorn.x86_const import (
    UC_X86_REG_EAX, UC_X86_REG_EBX, UC_X86_REG_ECX, UC_X86_REG_EDX,
    UC_X86_REG_ESI, UC_X86_REG_EDI, UC_X86_REG_EBP, UC_X86_REG_ESP,
    UC_X86_REG_EIP, UC_X86_REG_EFLAGS,
)


class Machine:
    """隔离映射实际 PE，使用受控角色内存和可观察的脚本事件替身。"""

    controller, pawn, psi, message, entity = (0x30000000, 0x30002000, 0x30004000,
                                             0x30006000, 0x30008000)

    def __init__(self, data, base):
        """按指定模块基址加载并应用原有重定位，初始化合法远端角色。"""
        self.base = base
        self.pe = pefile.PE(data=data)
        self.pe.relocate_image(base)
        self.uc = Uc(UC_ARCH_X86, UC_MODE_32)
        size = (self.pe.OPTIONAL_HEADER.SizeOfImage+4095) & ~4095
        self.uc.mem_map(base, size)
        self.uc.mem_write(base, self.pe.get_memory_mapped_image())
        self.uc.mem_map(0x30000000, 0x10000)
        self.uc.mem_map(0x40000000, 0x20000)
        self.write(self.controller+0x3CC, self.pawn)
        self.write(self.controller+0xAC0, self.psi)
        self.write(self.entity+0x44, self.controller)
        self.uc.mem_write(self.message, struct.pack('<3f3i', 100, 200, 50, 0, 1234, 0))
        self.uc.mem_write(self.message+0x28, struct.pack('<4f', 1, 2, 0, 600))
        self.uc.mem_write(self.psi+0x430, struct.pack('<3f', 100, 200, 50))
        self.write(self.message+0x48, 0x44110000)
        self.write(self.pawn+0x450, 0x44110000)
        for reg, value in [(UC_X86_REG_EAX, 0x12345), (UC_X86_REG_ECX, 0x23456),
                           (UC_X86_REG_EDX, 0x34567), (UC_X86_REG_EBX, self.psi+0x424),
                           (UC_X86_REG_ESI, self.message), (UC_X86_REG_EDI, self.controller),
                           (UC_X86_REG_EBP, 0x40011000), (UC_X86_REG_ESP, 0x40010000),
                           (UC_X86_REG_EFLAGS, 0x246)]:
            self.uc.reg_write(reg, value)
        self.events, self.stopped = [], None

    def write(self, address, value):
        """原样写入 32 位字段，保留异常浮点位模式。"""
        self.uc.mem_write(address, struct.pack('<I', value))

    def read(self, address):
        """读取原始 32 位字段用于比较写入副作用。"""
        return struct.unpack('<I', self.uc.mem_read(address, 4))[0]

    def run(self, start, stops):
        """执行真实入口；截获脚本包装记录参数，按 thiscall 语义返回。"""
        def hook(uc, address, size, unused):
            """记录实际续接点和事件，防止执行未建模的游戏/系统外部调用。"""
            rva = address-self.base
            if rva in stops:
                self.stopped = rva
                uc.emu_stop()
            elif rva == 0x160F0:
                esp = uc.reg_read(UC_X86_REG_ESP)
                self.events.append(bytes(uc.mem_read(esp+4, 44)))
                self.write(self.pawn+0x19C, 2)  # 事件后的物理标记不可被候选改为 Walking。
                uc.reg_write(UC_X86_REG_ESP, esp+48)
                uc.reg_write(UC_X86_REG_EIP, self.read(esp))
        self.uc.hook_add(UC_HOOK_CODE, hook)
        self.uc.emu_start(self.base+start, self.base+self.pe.OPTIONAL_HEADER.SizeOfImage,
                          count=3000)
        assert self.stopped in stops, f'未到预期续接点：{self.stopped}'


def verify(source_path, candidate_path):
    """比较 PE 保持范围，并在两个模块基址覆盖合法、无效和回退分支。"""
    source, candidate = Path(source_path).read_bytes(), Path(candidate_path).read_bytes()
    meta = json.loads(Path(candidate_path).with_suffix('.patch.json').read_text('utf-8'))
    original, patched = pefile.PE(data=source), pefile.PE(data=candidate)
    assert hashlib.sha256(source).hexdigest() == meta['source_sha256']
    assert hashlib.sha256(candidate).hexdigest() == meta['output_sha256']
    allowed = set()
    for item, field, count in [
            (original.FILE_HEADER, 'NumberOfSections', 2),
            (original.OPTIONAL_HEADER, 'SizeOfCode', 4),
            (original.OPTIONAL_HEADER, 'SizeOfImage', 4),
            (original.OPTIONAL_HEADER, 'CheckSum', 4)]:
        offset = item.get_field_absolute_offset(field)
        allowed.update(range(offset, offset+count))
    header = original.sections[0].get_file_offset()+40*len(original.sections)
    allowed.update(range(header, header+40))
    for entry in meta['hooks']:
        offset = original.get_offset_from_rva(entry['rva'])
        allowed.update(range(offset, offset+len(bytes.fromhex(entry['original']))))
    assert all(a == b or i in allowed for i, (a, b) in enumerate(zip(source, candidate)))
    assert original.get_data(0x65620, 0x9A) == patched.get_data(0x65620, 0x9A)
    exports = lambda p: [(x.ordinal, x.name, x.address) for x in p.DIRECTORY_ENTRY_EXPORT.symbols]
    imports = lambda p: [(d.dll, [(x.name, x.ordinal, x.address) for x in d.imports])
                         for d in p.DIRECTORY_ENTRY_IMPORT]
    relocations = lambda p: [(x.rva, x.type) for d in p.DIRECTORY_ENTRY_BASERELOC for x in d.entries]
    assert exports(original) == exports(patched)
    assert imports(original) == imports(patched)
    assert relocations(original) == relocations(patched)
    assert patched.verify_checksum()
    count = 0
    rejected = [('controller_delete', Machine.controller+0x70, 0x1000),
                ('local_player', Machine.controller+0x57C, 1),
                ('missing_pawn', Machine.controller+0x3CC, 0),
                ('pawn_delete', Machine.pawn+0x70, 0x1000),
                ('avatar', Machine.pawn+0x948, 1),
                ('missing_psi', Machine.controller+0xAC0, 0),
                ('psi_delete', Machine.psi+0x70, 0x1000)]
    speeds = [0, 0x80000000, 0x3F800000, 0x43C7FFFF, 0x43C80000, 0x43C80001,
              0x44110000, 0x4479FFFF, 0x447A0000, 0x447A0001, 0x7F800000,
              0xFF800000, 0x7FC00000, 0x7F800001, 0xFFC00000, 0xBF800000,
              0x7F7FFFFF, 1]
    for base in [0x10000000, 0x13000000]:
        # 与生产真实 x87 地速代码交叉执行，覆盖范围端点及 NaN/无穷/负零。
        for speed in speeds:
            old, new = Machine(source, base), Machine(candidate, base)
            for machine in [old, new]:
                machine.write(machine.message+0x48, speed)
            old.run(0x65772, {0x657AA})
            new.run(0x656BA, {0x659FE})
            assert old.read(old.message+0x48) == new.read(new.message+0x48)
            assert old.read(old.pawn+0x450) == new.read(new.pawn+0x450)
            assert len(new.events) == 1
            assert new.events[0][24:] == bytes(20)
            assert new.read(new.pawn+0x19C) == 2
            assert bytes(new.uc.mem_read(new.psi+0x424, 12)) == new.events[0][:12]
            assert new.uc.reg_read(UC_X86_REG_ESP) == 0x40010000
            count += 1
        for jumping in [False, True]:
            for name, address, value in rejected:
                machine = Machine(candidate, base)
                machine.write(machine.message+0x24, int(jumping))
                machine.write(address, value)
                machine.run(0x656BA, {0x656C4, 0x65772})
                assert machine.stopped == (0x656C4 if jumping else 0x65772), name
                assert not machine.events
                assert machine.uc.reg_read(UC_X86_REG_ESP) == 0x40010000
                assert machine.uc.reg_read(UC_X86_REG_ESI) == machine.message
                assert machine.uc.reg_read(UC_X86_REG_EDI) == machine.controller
                count += 1
        # 保留生产对跳跃参数的位模式传递，不新增 Main 的有限值拒绝。
        for bits in [0, 0x44160000, 0x7FC00000, 0x7F800000, 0xFF800000]:
            machine = Machine(candidate, base)
            machine.write(machine.message+0x24, 1)
            machine.write(machine.message, bits)
            machine.write(machine.message+0x28, bits)
            machine.write(machine.message+0x34, bits)
            machine.run(0x656BA, {0x659FE})
            assert len(machine.events) == 1
            assert machine.events[0][:4] == struct.pack('<I', bits)
            assert machine.events[0][24:28] == struct.pack('<I', bits)
            assert machine.events[0][36:] == struct.pack('<II', 1, bits)
            assert machine.uc.reg_read(UC_X86_REG_ESP) == 0x40010000
            count += 1
        for start, fallback, continuation in [(0xA2838, 0xA283E, 0xA28F7),
                                               (0xA2A68, 0xA2A6E, 0xA2B27)]:
            for rejection in [None] + rejected:
                machine = Machine(candidate, base)
                machine.uc.reg_write(UC_X86_REG_EBX, machine.entity)
                machine.uc.reg_write(UC_X86_REG_ESI, machine.psi)
                if rejection:
                    machine.write(rejection[1], rejection[2])
                registers = [UC_X86_REG_EAX, UC_X86_REG_EBX, UC_X86_REG_ECX,
                             UC_X86_REG_EDX, UC_X86_REG_ESI, UC_X86_REG_EDI,
                             UC_X86_REG_EBP, UC_X86_REG_ESP, UC_X86_REG_EFLAGS]
                before = [machine.uc.reg_read(r) for r in registers]
                machine.run(start, {fallback, continuation})
                assert machine.stopped == (fallback if rejection else continuation)
                assert [machine.uc.reg_read(r) for r in registers] == before
                assert not machine.events
                count += 1
    return {'actual_injected_x86_cases': count, 'module_bases': ['0x10000000', '0x13000000'],
            'production_speed_x87_cross_check': True, 'prefix_imports_exports_relocations_preserved': True,
            'main_nan_rejection_not_added': True, 'online_tested': False}


def main():
    """生成可复查的机器码测试摘要；不启动游戏或改变客户端文件。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True)
    parser.add_argument('--candidate', required=True)
    parser.add_argument('--report')
    args = parser.parse_args()
    report = verify(args.source, args.candidate)
    if args.report:
        Path(args.report).write_text(json.dumps(report, ensure_ascii=False, indent=2), 'utf-8')
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    main()
