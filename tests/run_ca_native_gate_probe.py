"""在隔离 UCC 的原脚本线程调用候选门禁，验证真实 FName/FindFunction/ProcessEvent。

只附加本工具创建的 UCC；测试对象不是实际地图角色，不代表联网验收。
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
import threading

import frida

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from build_ca_remote_motion import encode, run_ucc


SCRIPT = r'''
'use strict';
const core=Process.getModuleByName('Core.dll');
const getName=new NativeFunction(core.getExportByName('?GetName@UObject@@QBEPB_WXZ'),
                                'pointer',['pointer'],'thiscall');
const findObject=new NativeFunction(core.getExportByName('?StaticFindObject@UObject@@SAPAV1@PAVUClass@@PAV1@PB_WH@Z'),
                                   'pointer',['pointer','pointer','pointer','int'],'mscdecl');
const getDefault=new NativeFunction(core.getExportByName('?GetDefaultObject@UClass@@QAEPAVUObject@@XZ'),
                                   'pointer',['pointer'],'thiscall');
let active=false;
let actorIndex=0;
const seen=new Set();
function le32(p){const n=p.toUInt32();return [n&255,(n>>>8)&255,(n>>>16)&255,(n>>>24)&255];}
function invoke(m,object){
    // 仅在本次分析进程新分配页内包装 FXSAVE，夹住真实候选门禁调用。
    const memory=Memory.alloc(4096),before=memory.add(0x200),after=memory.add(0x400);
    memory.writeByteArray(new Uint8Array(4096));
    const code=[0x55,0x8b,0xec,0x0f,0xae,0x05,...le32(before),
                0xff,0x75,0x08,0xb8,...le32(m.base.add(GATE_RVA)),0xff,0xd0,
                0x0f,0xae,0x05,...le32(after),0x8b,0xe5,0x5d,0xc2,0x04,0x00];
    memory.writeByteArray(code);Memory.protect(memory,4096,'rwx');
    const call=new NativeFunction(memory,'uint',['pointer'],'stdcall');
    const result=call(object);
    const a=new Uint8Array(before.readByteArray(512)),b=new Uint8Array(after.readByteArray(512));
    const differences=[];
    for(let i=0;i<512;i++)if(a[i]!==b[i])differences.push(i);
    return {result,fx_differences:differences,
            computational_fx_equal:differences.every(i=>i>=8&&i<24)};
}
Interceptor.attach(core.getExportByName('?execLog@UObject@@QAEXAAUFFrame@@QAX@Z'),{
    onEnter(){
        if(active)return;
        active=true;
        try{
            let object=this.context.ecx;
            const name=getName(object).readUtf16String();
            let label=['GateAllowed','GateDenied','GateMissing'].find(x=>name.startsWith(x));
            if(name.startsWith('GateActorTrigger')){
                label=['GateActorAllowed','GateActorDenied','GateActorNoWorld','GateActorDeleted'][actorIndex++];
                if(!label)return;
                const cls=findObject(ptr(0),ptr(0),Memory.allocUtf16String('TEST_PACKAGE.'+label),0);
                if(cls.isNull())throw new Error('test actor class missing: '+label);
                object=getDefault(cls);
            }
            if(!label||seen.has(label))return;
            seen.add(label);
            const m=Process.getModuleByName('Sephiroth.dll');
            // Actor 的 ProcessEvent 还检查 Level 已开始及删除标记；只在分析 CDO 上临时模拟边界。
            let values;
            if(label.startsWith('GateActor')){
                const oldLevel=object.add(0x98).readPointer(),oldFlags=object.add(0x70).readU32();
                const oldVtable=object.readPointer(),vtable=Memory.alloc(0x400);
                vtable.writeByteArray(oldVtable.readByteArray(0x400));
                // UCC 默认对象使用 UObject 表；只在测试对象强制接入真实 Actor 分发函数。
                vtable.add(0x10).writePointer(Process.getModuleByName('Engine.dll')
                    .getExportByName('?ProcessEvent@AActor@@UAEXPAVUFunction@@PAX1@Z'));
                const level=Memory.alloc(0x800);level.writeByteArray(new Uint8Array(0x800));
                level.add(0x568).writeU32(label==='GateActorNoWorld'?0:4);
                try{
                    object.writePointer(vtable);
                    object.add(0x98).writePointer(level);
                    if(label==='GateActorDeleted')object.add(0x70).writeU32(oldFlags|0x1000);
                    values=invoke(m,object);
                    values.level_boundary_mocked=true;
                    values.actor_dispatch_forced_on_test_default=true;
                }finally{
                    object.writePointer(oldVtable);
                    object.add(0x98).writePointer(oldLevel);object.add(0x70).writeU32(oldFlags);
                }
            }else values=invoke(m,object);
            send({type:'gate',label,name,thread:Process.getCurrentThreadId(),
                  module:m.path,...values});
        }catch(e){send({type:'probe_error',message:String(e)});}
        finally{active=false;}
    }
});
send({type:'ready'});
'''


def main():
    """构建独立测试包，在原生 Log 回调的同一线程内执行门禁并记录结果。"""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', required=True, type=Path)
    parser.add_argument('--name', default='CANativeGateTests')
    args = parser.parse_args()
    build = args.build.resolve()
    if not build.is_relative_to((ROOT.parent / '.tmp').resolve()):
        raise ValueError('只能测试工作区 .tmp 中的隔离构建')
    if not re.fullmatch(r'CANativeGateTests[A-Za-z0-9_]*', args.name):
        raise ValueError('测试包名必须以 CANativeGateTests 开头')
    stage, binary = build / 'stage', build / 'stage/Bin'
    output = build / ('native-gate-probe-' + args.name)
    output.mkdir(exist_ok=False)
    classes = stage / args.name / 'Classes'
    classes.mkdir(parents=True, exist_ok=False)
    for label, value in [('GateAllowed', 'True'), ('GateDenied', 'False')]:
        (classes / (label + '.uc')).write_text(f'''/** 提供真实私有脚本查询的受控对象。 */
class {label} extends Object;
/** 返回受控门禁结果，测试反射私有函数和布尔返回值契约。 */
private function bool CanApplyRemoteCAMotion()
{{
    return {value};
}}
/** 进入原线程 Log 钩子，由观察器同步调用 DLL 门禁。 */
function Emit()
{{
    Log("CA_NATIVE_GATE_PROBE");
}}
''', encoding='utf-8')
    (classes / 'GateMissing.uc').write_text('''/** 模拟没有门禁方法的旧脚本对象。 */
class GateMissing extends Object;
/** 缺失查询必须回退，不能调用会报错的 FindFunctionChecked。 */
function Emit()
{
    Log("CA_NATIVE_GATE_PROBE");
}
''', encoding='utf-8')
    (classes / 'GateActorTrigger.uc').write_text('''/** 提供稳定的原脚本线程测试触发点。 */
class GateActorTrigger extends Object;
/** 由观察器按次序查询四个已加载 Actor 默认对象。 */
function Emit()
{
    Log("CA_NATIVE_ACTOR_TRIGGER");
}
''', encoding='utf-8')
    for label, value in [('GateActorAllowed', 'True'), ('GateActorDenied', 'False'),
                         ('GateActorNoWorld', 'True'), ('GateActorDeleted', 'True')]:
        (classes / (label + '.uc')).write_text(f'''/** 核对真实 Actor ProcessEvent，Level 边界由隔离观察器提供。 */
class {label} extends Actor;
/** 返回固定布尔值，不访问测试替身地图。 */
private function bool CanApplyRemoteCAMotion()
{{
    return {value};
}}
/** 在本类默认对象上触发静态 Log，测试结束后恢复全部临时字段。 */
static function Emit()
{{
    Log("CA_NATIVE_GATE_ACTOR_PROBE");
}}
''', encoding='utf-8')
    (classes / 'Check.uc').write_text('''/** 加载真实候选，在 UCC 原脚本线程触发门禁及 Actor 边界互操作。 */
class Check extends Commandlet;
/** 返回零只表示探针脚本运行完成，结果还须核对原生观察记录。 */
event int Main(string Params)
{
    local Object Loaded;
    local GateAllowed Allowed;
    local GateDenied Denied;
    local GateMissing Missing;
    local GateActorTrigger Trigger;
    Loaded = DynamicLoadObject("Sephiroth.ClientController", class'Class');
    if (Loaded == None)
        return 1;
    Allowed = new(None) class'GateAllowed';
    Denied = new(None) class'GateDenied';
    Missing = new(None) class'GateMissing';
    Allowed.Emit();
    Denied.Emit();
    Missing.Emit();
    Loaded = DynamicLoadObject("TEST_PACKAGE.GateActorAllowed", class'Class');
    Loaded = DynamicLoadObject("TEST_PACKAGE.GateActorDenied", class'Class');
    Loaded = DynamicLoadObject("TEST_PACKAGE.GateActorNoWorld", class'Class');
    Loaded = DynamicLoadObject("TEST_PACKAGE.GateActorDeleted", class'Class');
    Trigger = new(None) class'GateActorTrigger';
    Trigger.Emit();
    Trigger.Emit();
    Trigger.Emit();
    Trigger.Emit();
    Log("CA_NATIVE_GATE_PROBE_DONE");
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
'''.replace('TEST_PACKAGE', args.name), encoding='utf-8')
    ini_name = args.name + '.ini'
    ini = (binary / 'Build.ini').read_text() + '\n[Editor.EditorEngine]\nEditPackages=' + args.name + '\n'
    (binary / ini_name).write_text(ini)
    text = run_ucc(binary, ['make', 'ini=' + ini_name, '-unattended'], output / 'build.log')
    if not re.search(r'Success\s*-\s*0 error\(s\)', text):
        raise RuntimeError('原生门禁探针编译失败')
    package = binary / (args.name + '.u')
    data = package.read_bytes()
    if data[:4] != bytes.fromhex('c1 83 2a 9e'):
        raise ValueError('探针不是明文编译包')
    package.write_bytes(encode(data))
    patch = json.loads((build / 'native-patch.json').read_text('utf-8'))
    records, complete = [], threading.Event()
    device, pid, session = frida.get_local_device(), None, None
    result = dict(actual_game_tested=False, execution='UCC script thread, nested synchronous query')

    def message(item, extra):
        """收集原始事件；只保存少量文本，不转储或缓存业务对象。"""
        records.append(item.get('payload', item))

    try:
        pid = device.spawn([str(binary / 'UCC.exe'), args.name + '.Check',
                            'ini=' + ini_name, '-unattended'], cwd=str(binary), stdio='pipe')
        session = device.attach(pid)
        session.on('detached', lambda reason, crash: complete.set())
        script = session.create_script(SCRIPT.replace('GATE_RVA', str(patch['gate_rva']))
                                       .replace('TEST_PACKAGE', args.name))
        script.on('message', message)
        script.load()
        device.resume(pid)
        if not complete.wait(45):
            raise RuntimeError('原生门禁探针超时')
        observed = {r['label']: r for r in records if r.get('type') == 'gate'}
        if any(r.get('type') in ['probe_error', 'error'] for r in records):
            raise RuntimeError('门禁观察器执行失败')
        expected_results = {'GateAllowed': 1, 'GateDenied': 0, 'GateMissing': 0,
                            'GateActorAllowed': 1, 'GateActorDenied': 0,
                            'GateActorNoWorld': 0, 'GateActorDeleted': 0}
        if set(observed) != set(expected_results):
            raise RuntimeError('真实门禁调用记录不完整')
        for label, expected in expected_results.items():
            record = observed[label]
            if record['result'] != expected:
                raise RuntimeError('真实脚本门禁结果不符：' + label)
            if not record['computational_fx_equal']:
                raise RuntimeError('真实门禁破坏浮点运算状态：' + label)
            if Path(record['module']).resolve() != (binary / 'Sephiroth.dll').resolve():
                raise RuntimeError('加载了隔离目录之外的候选')
        result.update(passed=True, cases=observed,
                      actual_dll_sha256=hashlib.sha256((binary / 'Sephiroth.dll').read_bytes()).hexdigest())
        if result['actual_dll_sha256'] != patch['output_sha256']:
            raise RuntimeError('实际 DLL 与冻结补丁不符')
    except Exception as exc:
        result.update(passed=False, error=repr(exc))
        raise
    finally:
        if pid is not None:
            try:
                device.kill(pid)
            except frida.ProcessNotFoundError:
                pass
        if session is not None:
            try:
                session.detach()
            except frida.InvalidOperationError:
                pass
        result['records'] = records
        (output / 'result.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({k: v for k, v in result.items() if k != 'records'}, ensure_ascii=False))


if __name__ == '__main__':
    main()
