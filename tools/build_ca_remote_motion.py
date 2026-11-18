"""隔离构建当前脚本和指定 CA 原生候选；无原生参数时保留历史基线对照，不部署。"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import ctypes
from ctypes import wintypes
import time

ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = ROOT.parent
BASELINE = 'e20b332cee1cff232a85f0a6b2aa67ff752ff281694f66fd30b402ece3376209'
PACKAGES = ('Sephiroth', 'SephirothUI')
SDK_KEY = bytes.fromhex(
    '15 79 98 A8 29 B9 D9 8E 8F 7A 98 23 98 58 39 10 E0 F8 B8 C8 A8 D8 F8 39 '
    '20 E8 39 A0 92 57 81 90 DF 8B 82 83 D9 F7 98 C9 73 25 03 98 91 27 A8 78 '
    'E8 D8 B7 83 28 C8 34 8F 87 39 F7 83 9A 9E 87 89 F9 C9 E8 F7 23 61 78 '
    '57 9A 78 B9 8C 87 23 90 18 38 34 82 98 48 39 7A 87 B8 7C 8D 89 E8 F7 '
    '38 29 19 82 73 84')


def digest(path):
    """固定输入或输出摘要，防止误用历史候选。"""
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def source_manifest(folder):
    """记录本次实际进入编译的脚本，包含未跟踪的既有脚本。"""
    return {p.relative_to(folder).as_posix(): digest(p) for p in sorted(folder.rglob('*.uc'))}


def encode(data, key=SDK_KEY):
    """沿用现有客户端资源编码，编译原包与运行副本分别保存。"""
    return bytes(((v ^ key[i % 100]) + i % 79) & 255 for i, v in enumerate(data))


def decode(data, key=SDK_KEY):
    """用于完整往返核对，不把编码完成当作运行验证。"""
    return bytes((((v - i % 79) & 255) ^ key[i % 100]) for i, v in enumerate(data))


def run_ucc(binary, arguments, log, timeout=180):
    """在隔离目录执行项目 UCC；完整保留失败输出。"""
    result = subprocess.run([str(binary/'UCC.exe'), *arguments], cwd=binary,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=timeout, creationflags=subprocess.CREATE_NO_WINDOW)
    log.write_bytes(result.stdout)
    text = result.stdout.decode('gbk', 'replace')
    if result.returncode:
        raise RuntimeError('UCC 执行失败：'+str(log)+'\n'+text[-4000:])
    return text


class ModuleEntry(ctypes.Structure):
    """Windows 模块枚举结构；只读取本工具创建的 UCC 子进程。"""
    _fields_ = [('dwSize', wintypes.DWORD), ('th32ModuleID', wintypes.DWORD),
                ('th32ProcessID', wintypes.DWORD), ('GlblcntUsage', wintypes.DWORD),
                ('ProccntUsage', wintypes.DWORD), ('modBaseAddr', ctypes.c_void_p),
                ('modBaseSize', wintypes.DWORD), ('hModule', ctypes.c_void_p),
                ('szModule', wintypes.WCHAR*256), ('szExePath', wintypes.WCHAR*260)]


def check_loaded_modules(binary, log):
    """运行类加载探针并核对实际 DLL 路径和摘要，不把加载通过当成地图或 ABI 全面验收。"""
    kernel = ctypes.WinDLL('kernel32', use_last_error=True)
    kernel.CreateToolhelp32Snapshot.argtypes = [wintypes.DWORD, wintypes.DWORD]
    kernel.CreateToolhelp32Snapshot.restype = wintypes.HANDLE
    kernel.Module32FirstW.argtypes = [wintypes.HANDLE, ctypes.POINTER(ModuleEntry)]
    kernel.Module32NextW.argtypes = [wintypes.HANDLE, ctypes.POINTER(ModuleEntry)]
    kernel.CloseHandle.argtypes = [wintypes.HANDLE]
    loaded = {}
    with log.open('wb') as stream:
        process = subprocess.Popen([str(binary/'UCC.exe'), 'CARemoteLoad.Check',
                                    'ini=CAMotionBuild.ini', '-unattended'], cwd=binary,
                                   stdout=stream, stderr=subprocess.STDOUT,
                                   creationflags=subprocess.CREATE_NO_WINDOW)
        started = time.monotonic()
        while process.poll() is None:
            if time.monotonic()-started > 40:
                process.kill()
                process.wait()
                raise RuntimeError('类加载探针超时')
            snapshot = kernel.CreateToolhelp32Snapshot(0x18, process.pid)
            if snapshot and snapshot != ctypes.c_void_p(-1).value:
                entry = ModuleEntry()
                entry.dwSize = ctypes.sizeof(entry)
                ok = kernel.Module32FirstW(snapshot, ctypes.byref(entry))
                while ok:
                    name = entry.szModule.lower()
                    if name in ('sephiroth.dll', 'engine.dll', 'core.dll'):
                        loaded[name] = entry.szExePath
                    ok = kernel.Module32NextW(snapshot, ctypes.byref(entry))
                kernel.CloseHandle(snapshot)
            time.sleep(0.01)
    if process.returncode:
        raise RuntimeError('类加载探针退出失败')
    if 'CA_REMOTE_LOAD_OK' not in log.read_bytes().decode('gbk', 'replace'):
        raise RuntimeError('类加载标记缺失')
    if set(loaded) != {'sephiroth.dll', 'engine.dll', 'core.dll'}:
        raise RuntimeError('未观察到完整的实际模块列表：'+repr(loaded))
    for name, path in loaded.items():
        if Path(path).resolve() != (binary/name).resolve():
            raise RuntimeError('加载了隔离目录之外的 DLL：'+path)
    return {name: dict(path=path, sha256=digest(path)) for name, path in loaded.items()}


def delivery_key(reference):
    """使用两份已保存的完整目标客户端原包对验证交付密钥，拒绝猜测编码。"""
    keys = []
    for name in PACKAGES:
        plain = (reference/(name+'.baseline.u')).read_bytes()
        encoded = (reference/(name+'.target.spg')).read_bytes()
        if len(plain) != len(encoded):
            raise ValueError('资源参考长度不匹配：'+name)
        key = bytes((((encoded[i]-i % 79) & 255) ^ plain[i]) for i in range(100))
        if encode(plain, key) != encoded:
            raise ValueError('完整资源参考校验失败：'+name)
        keys.append(key)
    if keys[0] != keys[1]:
        raise ValueError('两份目标资源的编码不一致')
    return keys[0]


def native_candidate(path):
    """只接受配套清单完整的 CA 三处候选，拒绝误传 Main 或其他历史补丁。"""
    if path is None:
        return None
    path = path.resolve()
    if not path.is_relative_to((WORKSPACE/'.tmp').resolve()):
        raise ValueError('原生候选必须位于工作区 .tmp')
    from build_ca_remote_movement_dll import MODE, SITES, QUERY
    report = json.loads(path.with_suffix('.patch.json').read_text('utf-8'))
    if report.get('mode') != MODE:
        raise ValueError('不是本轮 CA 三处原生候选')
    if report.get('source_sha256') != BASELINE:
        raise ValueError('原生候选的生产基线不匹配')
    if report.get('output_sha256') != digest(path):
        raise ValueError('原生候选摘要与清单不一致')
    if report.get('retains_walking') is not True:
        raise ValueError('原生候选未声明保留 Walking')
    if report.get('query') != QUERY:
        raise ValueError('原生门禁查询不匹配')
    if {entry['rva'] for entry in report['hooks']} != set(SITES):
        raise ValueError('原生候选入口范围不匹配')
    return dict(path=str(path), patch=report)


def main():
    """冻结当前源码和可选原生候选，构建并核对实际加载；已有目录拒绝覆盖。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    parser.add_argument('--template', type=Path, default=ROOT/'.weapon-fx-work/builds/remote-main-adapt-20261108/stage')
    parser.add_argument('--reference', type=Path, default=ROOT/'.weapon-fx-work/builds/transparent-prototype-20261104-215311/target-reference')
    parser.add_argument('--native-candidate', type=Path, help='由 build_ca_remote_movement_dll.py 生成的独立候选')
    args = parser.parse_args()
    output = Path(args.output).resolve()
    if not output.is_relative_to((WORKSPACE/'.tmp').resolve()):
        raise ValueError('过程输出必须位于工作区 .tmp')
    if output.exists():
        raise ValueError('输出目录已存在，拒绝覆盖：'+str(output))
    source_dll = ROOT/'Bin/Sephiroth.dll'
    if digest(source_dll) != BASELINE:
        raise ValueError('生产 DLL 与已审基线不同，必须重新分析')
    native = native_candidate(args.native_candidate)
    selected_dll = Path(native['path']) if native else source_dll
    selected_hash = digest(selected_dll)
    key = delivery_key(args.reference)
    before = {name: source_manifest(ROOT/name/'Classes') for name in PACKAGES}
    stage, binary = output/'stage', output/'stage/Bin'
    template = args.template.resolve()

    def ignore(folder, names):
        """模板只提供 SDK 和资源，排除历史源码、历史产物及测试包。"""
        folder = Path(folder)
        if folder == template:
            return {n for n in names if n in PACKAGES or n in ('RemoteMotionTests', 'NativeLoadCheck')}
        if folder == template/'Bin':
            return {n for n in names if n in ('Sephiroth.u', 'SephirothUI.u', 'Sephiroth.dll', 'RemoteMotionTests.u', 'NativeLoadCheck.u')}
        return set()

    shutil.copytree(template, stage, ignore=ignore)
    for name in PACKAGES:
        shutil.copytree(ROOT/name, stage/name)
    for name in ('Sephiroth.dll', 'Engine.dll', 'Core.dll'):
        shutil.copy2(ROOT/'Bin'/name, binary/name)
    if native:
        shutil.copy2(selected_dll, binary/'Sephiroth.dll')
    delivery = output/'delivery/Bin'
    delivery.mkdir(parents=True)
    # 显式传入 CA 原生候选时，构建、类加载和交付必须使用同一 DLL；默认仍可复现旧对照。
    shutil.copy2(selected_dll, delivery/'Sephiroth.dll')
    if native:
        (output/'native-patch.json').write_text(json.dumps(native['patch'], ensure_ascii=False, indent=2), encoding='utf-8')
    check = stage/'CARemoteLoad/Classes/Check.uc'
    check.parent.mkdir(parents=True)
    check.write_text('''/** 仅加载本次脚本类及生产原生绑定，不连接游戏。 */
class Check extends Commandlet;
/** 返回零表示目标类可由当前隔离 SDK 加载；不代表游戏验收。 */
event int Main(string Params)
{
    local Object ControllerClass, PlayerClass, HeroClass;
    ControllerClass = DynamicLoadObject("Sephiroth.ClientController", class'Class');
    PlayerClass = DynamicLoadObject("SephirothUI.NephilimPlayer", class'Class');
    HeroClass = DynamicLoadObject("Sephiroth.Hero", class'Class');
    if (ControllerClass == None) return 1;
    if (PlayerClass == None) return 2;
    if (HeroClass == None) return 3;
    Log("CA_REMOTE_LOAD_OK");
    return 0;
}
defaultproperties
{
    IsClient=False
    IsEditor=True
    IsServer=False
    LogToStdout=True
    ShowErrorCount=True
}
''', encoding='utf-8')
    ini = (binary/'Build.ini').read_text()
    ini += '\n[Editor.EditorEngine]\nEditPackages=CARemoteLoad\n'
    (binary/'CAMotionBuild.ini').write_text(ini)
    text = run_ucc(binary, ['make', 'ini=CAMotionBuild.ini', '-unattended'], output/'build.log')
    if not re.search(r'Success\s*-\s*0 error\(s\)', text):
        raise RuntimeError('编译未报告零错误，参见 build.log')
    plain_dir = output/'plain'
    plain_dir.mkdir()
    artifacts = {}
    for name in (*PACKAGES, 'CARemoteLoad'):
        path = binary/(name+'.u')
        data = path.read_bytes()
        if data[:4] != bytes.fromhex('c1832a9e'):
            raise ValueError('编译产物不是明文 U 包：'+name)
        (plain_dir/(name+'.u')).write_bytes(data)
        encoded = encode(data)
        if decode(encoded) != data:
            raise ValueError('SDK 编码往返失败：'+name)
        path.write_bytes(encoded)
        if name in PACKAGES:
            spg = encode(data, key)
            if decode(spg, key) != data:
                raise ValueError('目标 SPG 往返失败：'+name)
            (delivery/(name+'.spg')).write_bytes(spg)
            artifacts[name] = dict(u_sha256=digest(plain_dir/(name+'.u')), spg_sha256=digest(delivery/(name+'.spg')))
    loaded = check_loaded_modules(binary, output/'class-load.log')
    for name in PACKAGES:
        if source_manifest(ROOT/name/'Classes') != before[name]:
            raise RuntimeError('构建期间源码发生变化')
        if source_manifest(stage/name/'Classes') != before[name]:
            raise RuntimeError('暂存源码与工作树不同')
    if digest(source_dll) != BASELINE:
        raise RuntimeError('生产原文件被改变')
    if digest(delivery/'Sephiroth.dll') != selected_hash:
        raise RuntimeError('交付 DLL 与冻结候选不同')
    if digest(binary/'Sephiroth.dll') != selected_hash:
        raise RuntimeError('暂存 DLL 与冻结候选不同')
    if loaded['sephiroth.dll']['sha256'] != selected_hash:
        raise RuntimeError('实际加载 DLL 与冻结候选不同')
    original_data, selected_data = source_dll.read_bytes(), selected_dll.read_bytes()
    changed = sum(a != b for a, b in zip(original_data, selected_data))
    report = dict(source_dll=str(source_dll), source_dll_sha256=BASELINE,
                  dll_sha256=selected_hash, dll_bytes_changed=changed,
                  dll_bytes_added=len(selected_data)-len(original_data), native_candidate=native,
                  source_hashes=before, artifacts=artifacts, build_errors=0,
                  warnings=len(re.findall(r' : Warning,', text)), class_load=True,
                  loaded_modules=loaded,
                  spg_reference_and_roundtrip=True, actual_game_tested=False, deployed=False)
    (output/'manifest.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps(dict(output=str(output), delivery=str(delivery), warnings=report['warnings']), ensure_ascii=False))


if __name__ == '__main__':
    main()
