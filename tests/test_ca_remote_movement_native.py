"""执行实际候选 x86，核对 CA 三处分支、原生回退、Walking、ABI 与浮点状态。

引擎调用和脚本门禁在此使用受控替身；真实 UCC 门禁互操作另行验证。
"""

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

import pefile
from keystone import Ks, KS_ARCH_X86, KS_MODE_32
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
import unicorn.x86_const as x86

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from build_ca_remote_movement_dll import BASELINE, MODE, QUERY, FIND_FUNCTION, SITES


class Machine:
    """按真实重定位映射 DLL；只替换无法在模拟器内提供的引擎/VM 边界。"""

    controller, pawn, psi, message = 0x30000000, 0x30002000, 0x30004000, 0x30006000
    level, vlevel, vpawn, vcontroller = 0x30008000, 0x30009000, 0x3000A000, 0x3000B000
    fx_before, fx_after = 0x3000C000, 0x3000C400
    stubs, frame, stack = 0x50000000, 0x40018000, 0x40017F88
    api = {name: 0x50000000 + n * 0x100 for n, name in enumerate(
        ['get_core', 'get_proc', 'fname', 'find_function', 'process_event', 'far_move',
         'set_physics', 'stop', 'seed', 'save_before', 'save_after'])}

    def __init__(self, data, base, policy='allow'):
        """固定合法消息和原函数栈帧；policy 控制缺包、缺接口和业务拒绝。"""
        self.base, self.policy = base, policy
        self.pe = pefile.PE(data=data)
        self.pe.relocate_image(base)
        self.uc = Uc(UC_ARCH_X86, UC_MODE_32)
        self.uc.mem_map(0, 0x1000)
        self.uc.mem_map(base, (self.pe.OPTIONAL_HEADER.SizeOfImage + 4095) & ~4095)
        self.uc.mem_write(base, self.pe.get_memory_mapped_image())
        self.uc.mem_map(0x30000000, 0x10000)
        self.uc.mem_map(0x40000000, 0x20000)
        self.uc.mem_map(self.stubs, 0x10000)
        self.events, self.queries, self.stopped = [], [], False
        for at, value in [(self.controller, self.vcontroller),
                          (self.controller + 0x9C, self.level),
                          (self.controller + 0x3CC, self.pawn),
                          (self.controller + 0xAC0, self.psi),
                          (self.level, self.vlevel), (self.pawn, self.vpawn),
                          (self.vlevel + 0xBC, self.api['far_move']),
                          (self.vpawn + 0x138, self.api['set_physics']),
                          (self.vcontroller + 0x10, self.api['process_event']),
                          (base + 0x11A994, self.api['get_core']),
                          (base + 0x11A900, self.api['get_proc']),
                          (base + 0x11A03C, self.api['fname']),
                          (self.frame, 0x4001F000), (self.frame + 4, self.api['stop']),
                          (self.frame - 0x6C, 0xAABBCC01),
                          (self.frame - 0x70, 0xAABBCC02),
                          (self.frame - 0x74, 0xAABBCC03)]:
            self.put(at, value)
        self.uc.mem_write(self.message, struct.pack('<3f3i', 140, 100, 100, 0, 1234, 0))
        self.uc.mem_write(self.psi + 0x424, struct.pack('<3f', 100, 100, 100))
        self.uc.mem_write(self.psi + 0x430, struct.pack('<3f', 140, 100, 100))
        self.uc.mem_write(self.message + 0x28, struct.pack('<4f', 1, 2, 3, 600))
        self.uc.mem_write(self.message + 0x48, struct.pack('<f', 580))
        self.uc.mem_write(self.pawn + 0x78, b'\x02')
        # 外部 sqrt 只替换为等价 x87 数学指令，距离分支仍执行真实 DLL 指令。
        self.uc.mem_write(base + 0xE5C40, bytes.fromhex('d9 fa c3'))
        ks = Ks(KS_ARCH_X86, KS_MODE_32)
        for name, source in [
            ('process_event', 'fninit; fldpi; pxor xmm0, xmm0; pxor xmm7, xmm7; ret 12'),
            ('seed', 'fninit; fldpi; fld1'),
            ('save_before', f'fxsave [0x{self.fx_before:x}]'),
            ('save_after', f'fxsave [0x{self.fx_after:x}]'),
        ]:
            self.uc.mem_write(self.api[name], bytes(ks.asm(source)[0]))
        for reg, value in [(x86.UC_X86_REG_EAX, 0x12345), (x86.UC_X86_REG_ECX, 0x23456),
                           (x86.UC_X86_REG_EDX, 0x34567),
                           (x86.UC_X86_REG_EBX, self.psi + 0x424),
                           (x86.UC_X86_REG_ESI, self.message),
                           (x86.UC_X86_REG_EDI, self.controller),
                           (x86.UC_X86_REG_EBP, self.frame), (x86.UC_X86_REG_ESP, self.stack),
                           (x86.UC_X86_REG_EFLAGS, 0x246),
                           (x86.UC_X86_REG_XMM0, 0x112233445566778899AABBCCDDEEFF00),
                           (x86.UC_X86_REG_XMM7, 0xA1B2C3D4E5F60718293A4B5C6D7E8F90)]:
            self.uc.reg_write(reg, value)
        self.uc.hook_add(UC_HOOK_CODE, self.observe)

    def put(self, address, value):
        """按原始位模式写 32 位字段。"""
        self.uc.mem_write(address, struct.pack('<I', value))

    def get(self, address):
        """读取原始位模式，不把 NaN 或负零预先归一化。"""
        return struct.unpack('<I', self.uc.mem_read(address, 4))[0]

    def wstring(self, address):
        """读取测试中的短 UTF-16 名称，验证门禁没有使用错误字符串地址。"""
        result = bytearray()
        for n in range(120):
            unit = bytes(self.uc.mem_read(address + n * 2, 2))
            if unit == b'\0\0':
                return result.decode('utf-16-le')
            result.extend(unit)
        raise AssertionError('测试字符串未终止')

    def finish(self, argument_bytes, result=1):
        """按 Win32 thiscall/stdcall 弹出参数，保留调用方寄存器 ABI。"""
        sp = self.uc.reg_read(x86.UC_X86_REG_ESP)
        target = self.get(sp)
        self.uc.reg_write(x86.UC_X86_REG_ESP, sp + 4 + argument_bytes)
        self.uc.reg_write(x86.UC_X86_REG_EIP, target)
        self.uc.reg_write(x86.UC_X86_REG_EAX, result)

    def observe(self, uc, address, size, unused):
        """观察真实调用结果；VM 替身故意破坏浮点寄存器以检查门禁恢复。"""
        sp = uc.reg_read(x86.UC_X86_REG_ESP)
        if address == self.api['stop']:
            self.stopped = True
            uc.emu_stop()
        elif address == self.api['get_core']:
            assert self.wstring(self.get(sp + 4)) == 'Core.dll'
            self.finish(4, 0 if self.policy == 'core_missing' else 0x10100000)
        elif address == self.api['get_proc']:
            needle = FIND_FUNCTION.encode() + b'\0'
            assert bytes(uc.mem_read(self.get(sp + 8), len(needle))) == needle
            self.finish(8, 0 if self.policy == 'api_missing' else self.api['find_function'])
        elif address == self.api['fname']:
            assert self.wstring(self.get(sp + 4)) == QUERY
            assert self.get(sp + 8) == 0  # FNAME_Find，不增添名称。
            target = uc.reg_read(x86.UC_X86_REG_ECX)
            self.put(target, 0 if self.policy == 'name_missing' else 73)
            self.finish(8, target)
        elif address == self.api['find_function']:
            assert uc.reg_read(x86.UC_X86_REG_ECX) == self.controller
            assert self.get(sp + 4) == 73
            self.finish(8, 0 if self.policy == 'function_missing' else 0x3000D000)
        elif address == self.api['process_event']:
            assert uc.reg_read(x86.UC_X86_REG_ECX) == self.controller
            assert self.get(sp + 4) == 0x3000D000
            assert self.get(sp + 12) == 0
            self.put(self.get(sp + 8), int(self.policy == 'allow'))
            self.queries.append(self.policy)
            # 继续执行临时 VM 替身的 FNINIT/FLDPI/XMM 清零及 RET12。
        elif address == self.api['far_move']:
            self.events.append(('far_move', bytes(uc.mem_read(sp + 4, 28)).hex()))
            self.finish(28)
        elif address == self.api['set_physics']:
            physics = self.get(sp + 4)
            self.events.append(('physics', physics))
            uc.mem_write(self.pawn + 0x78, bytes([physics]))
            self.finish(20)
        elif address == self.base + 0x160F0:
            args = bytes(uc.mem_read(sp + 4, 44))
            self.events.append(('move_event', args.hex()))
            if struct.unpack_from('<I', args, 36)[0]:
                uc.mem_write(self.pawn + 0x78, b'\x02')
            self.finish(44)

    def run(self, start):
        """从原生分支运行到真实函数返回，验证参数栈和被调用方寄存器恢复。"""
        self.uc.emu_start(self.base + start, self.base + self.pe.OPTIONAL_HEADER.SizeOfImage,
                          count=10000)
        assert self.stopped, '未返回调用方'
        assert self.uc.reg_read(x86.UC_X86_REG_ESP) == self.frame + 12, '参数栈不平衡'
        for reg, value in [(x86.UC_X86_REG_EBX, 0xAABBCC01),
                           (x86.UC_X86_REG_ESI, 0xAABBCC02),
                           (x86.UC_X86_REG_EDI, 0xAABBCC03),
                           (x86.UC_X86_REG_EBP, 0x4001F000)]:
            assert self.uc.reg_read(reg) == value, '原生函数破坏被调用方寄存器'
        return dict(events=self.events, ground_speed=self.get(self.pawn + 0x450),
                    message_speed=self.get(self.message + 0x48),
                    history=bytes(self.uc.mem_read(self.psi + 0x424, 12)).hex(),
                    physics=bytes(self.uc.mem_read(self.pawn + 0x78, 1)).hex())

    def check_gate_state(self, gate_rva):
        """独立验证门禁结果及 GPR/EFLAGS、x87 运算状态、XMM/MXCSR 恢复。"""
        seed = self.api['seed']
        self.uc.emu_start(seed, seed + 6)
        save = self.api['save_before']
        self.uc.emu_start(save, save + 7)
        regs = [x86.UC_X86_REG_EBX, x86.UC_X86_REG_ECX, x86.UC_X86_REG_EDX,
                x86.UC_X86_REG_ESI, x86.UC_X86_REG_EDI, x86.UC_X86_REG_EBP,
                x86.UC_X86_REG_EFLAGS]
        before = [self.uc.reg_read(r) for r in regs]
        sp = self.stack - 8
        self.put(sp, self.api['stop'])
        self.put(sp + 4, self.controller)
        self.uc.reg_write(x86.UC_X86_REG_ESP, sp)
        self.uc.emu_start(self.base + gate_rva, self.base + self.pe.OPTIONAL_HEADER.SizeOfImage,
                          count=10000)
        assert self.stopped
        assert self.uc.reg_read(x86.UC_X86_REG_ESP) == self.stack
        assert self.uc.reg_read(x86.UC_X86_REG_EAX) == int(self.policy == 'allow')
        assert before == [self.uc.reg_read(r) for r in regs]
        save = self.api['save_after']
        self.uc.emu_start(save, save + 7)
        before_fx = bytearray(self.uc.mem_read(self.fx_before, 512))
        after_fx = bytearray(self.uc.mem_read(self.fx_after, 512))
        # Unicorn 的 FXRSTOR 不还原末次 x87 指令地址；该诊断地址不参与后续运算。
        # 控制字、状态字、标记、80 位值、MXCSR 与全部 XMM 仍逐字节比较。
        before_fx[8:12] = after_fx[8:12] = bytes(4)
        assert before_fx == after_fx


def verify_pe(source, candidate, meta):
    """限定既有文件只改 PE 必要字段与三处六字节入口，导入导出重定位保持。"""
    assert hashlib.sha256(source).hexdigest() == BASELINE == meta['source_sha256']
    assert meta['mode'] == MODE
    assert hashlib.sha256(candidate).hexdigest() == meta['output_sha256']
    old, new = pefile.PE(data=source), pefile.PE(data=candidate)
    allowed = set()
    for item, field, width in [(old.FILE_HEADER, 'NumberOfSections', 2),
                               (old.OPTIONAL_HEADER, 'SizeOfCode', 4),
                               (old.OPTIONAL_HEADER, 'SizeOfImage', 4),
                               (old.OPTIONAL_HEADER, 'CheckSum', 4)]:
        at = item.get_field_absolute_offset(field)
        allowed.update(range(at, at + width))
    at = old.sections[0].get_file_offset() + 40 * len(old.sections)
    allowed.update(range(at, at + 40))
    assert {x['rva'] for x in meta['hooks']} == set(SITES)
    for rva, expected in SITES.items():
        assert old.get_data(rva, len(expected)) == expected
        at = old.get_offset_from_rva(rva)
        allowed.update(range(at, at + len(expected)))
    assert all(a == b or n in allowed for n, (a, b) in enumerate(zip(source, candidate)))
    exports = lambda p: [(e.name, e.ordinal, e.address) for e in p.DIRECTORY_ENTRY_EXPORT.symbols]
    imports = lambda p: [(d.dll, [(e.name, e.ordinal, e.address) for e in d.imports])
                         for d in p.DIRECTORY_ENTRY_IMPORT]
    relocs = lambda p: [(e.rva, e.type) for d in p.DIRECTORY_ENTRY_BASERELOC for e in d.entries]
    assert exports(old) == exports(new)
    assert imports(old) == imports(new)
    assert relocs(old) == relocs(new)
    assert new.verify_checksum()
    assert new.get_data(0x6596C, 4) == old.get_data(0x6596C, 4) == bytes.fromhex('ff d0 eb 7e')
    assert new.sections[-1].Name.rstrip(b'\0') == b'.camove'
    assert new.sections[-1].Characteristics == 0x60000020  # 可读可执行，不可写。


def verify(source_path, candidate_path):
    """在两个模块基址比较真实分支，分别验证 CA 行为、生产回退及异常速度位模式。"""
    source, candidate = Path(source_path).read_bytes(), Path(candidate_path).read_bytes()
    meta = json.loads(Path(candidate_path).with_suffix('.patch.json').read_text('utf-8'))
    verify_pe(source, candidate, meta)
    cases = [((100, 100, 100), (100, 100, 100), False),
             ((100, 100, 100), (120, 100, 100), False),
             ((100, 100, 100), (130, 100, 100), False),
             ((100, 100, 100), (140, 100, 100), False),
             ((100, 100, 100), (100, 100, 200), False),
             ((100, 100, 100), (2100, 100, 100), False),
             ((100, 100, 100), (2101, 100, 100), False),
             ((100, 100, 100), (100, 100, 2101), False),
             ((0, 100, 100), (50, 100, 100), False),
             ((100, 100, 100), (140, 100, 100), True)]
    policies = ['allow', 'deny', 'core_missing', 'api_missing', 'name_missing', 'function_missing']
    rows, gate_checks, speed_checks = [], 0, 0
    for base in [0x10000000, 0x13000000]:
        for policy in policies:
            Machine(candidate, base, policy).check_gate_state(meta['gate_rva'])
            gate_checks += 1
            for old, target, jump in cases:
                original, patched = Machine(source, base), Machine(candidate, base, policy)
                for machine in [original, patched]:
                    machine.uc.mem_write(machine.psi + 0x424, struct.pack('<3f', *old))
                    machine.uc.mem_write(machine.message, struct.pack('<3f', *target))
                    machine.put(machine.message + 0x24, int(jump))
                before, after = original.run(0x656BA), patched.run(0x656BA)
                if policy != 'allow':
                    assert after == before, (base, policy, old, target, jump, before, after)
                else:
                    distance = sum((a - b) ** 2 for a, b in zip(old, target)) ** 0.5
                    kinds = [e[0] for e in after['events']]
                    if jump:
                        assert kinds == ['move_event']
                        assert after['physics'] == '02'
                    elif old[0] == 0:
                        assert not kinds
                    elif distance > 2000:
                        assert kinds == ['far_move', 'physics']
                        assert after['events'][-1] == ('physics', 0)
                    else:
                        assert kinds == ['move_event', 'physics']
                        assert after['events'][-1] == ('physics', 1)
                    assert after['ground_speed'] == before['ground_speed']
                    assert after['message_speed'] == before['message_speed']
                    assert after['history'] == before['history']
                rows.append(dict(base=hex(base), policy=policy, old=old, target=target,
                                 jump=jump, before=before['events'], after=after['events']))
        # 边界及异常浮点输入继续由原生产 x87 地速代码处理。
        for bits in [0, 0x80000000, 0x43C7FFFF, 0x43C80000, 0x447A0000, 0x447A0001,
                     0x7F800000, 0xFF800000, 0x7FC00000, 0x7F800001, 0xBF800000]:
            old, new = Machine(source, base), Machine(candidate, base)
            for machine in [old, new]:
                machine.put(machine.message + 0x48, bits)
            assert old.run(0x656BA) == new.run(0x656BA)
            speed_checks += 1
    return dict(mode=MODE, branch_cases=len(rows), gate_state_cases=gate_checks,
                speed_cases=speed_checks, module_bases=['0x10000000', '0x13000000'],
                pe_imports_exports_relocations_and_walking_preserved=True,
                full_function_return_and_callee_saved_registers=True,
                gate_x87_xmm_mxcsr_eflags_preserved=True,
                unicorn_fx_diagnostic_address_bytes_excluded=[8, 9, 10, 11], cases=rows,
                actual_game_tested=False, script_query_stubbed=True)


def main():
    """输出二进制检查与受控执行记录，不启动或部署游戏。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True)
    parser.add_argument('--candidate', required=True)
    parser.add_argument('--report', required=True)
    args = parser.parse_args()
    report = verify(args.source, args.candidate)
    Path(args.report).write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'cases'}, ensure_ascii=False))


if __name__ == '__main__':
    main()
