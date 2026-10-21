"""Compile cumulative source bodies in an isolated donor package.

Requires the matching UCC runtime and decrypted baseline packages. This is a
syntax/type check, not a deployable rebuild: native class layouts are inherited;
final functions get validation-only names, and default particle object references
are omitted only from runtime copies to avoid duplicate editor import objects.
Never deploy this working directory. Defaults are checked by separate gates.
"""
from pathlib import Path
import argparse, json, re, shutil, struct, subprocess
from unreal_package import Package, Reader, compact
from unreal_source import read_source as text, mask, blocks, method_map
import unreal_properties as property_tags
from audit_compile_warnings import audit

repo=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime-bin',type=Path,required=True)
parser.add_argument('--original-bin',type=Path,required=True)
parser.add_argument('--config',type=Path,required=True)
parser.add_argument('--asset-root',type=Path,required=True)
parser.add_argument('--work-root',type=Path,default=repo/'.weapon-fx-work/source-validation')
args=parser.parse_args()
if not args.work_root.resolve().is_relative_to((repo/'.weapon-fx-work').resolve()):
    parser.error('Validation output must remain under .weapon-fx-work')
manifest=json.loads((repo/'tests/client-sync-manifest.json').read_text('utf8'))
def fullnorm(s):return re.sub(r'\s+',' ',s).strip()
def repair(s):
    out=[]
    for line in s.split('\n'):
        for _ in range(2):
            try: fixed=line.encode('latin1').decode('utf8')
            except (UnicodeEncodeError,UnicodeDecodeError):break
            if fixed==line:break
            line=fixed
        out.append(line)
    return '\n'.join(out)
def source_pkg(p):
    result={}
    for i,e in enumerate(p.exp):
        if p.obj(e['cls']).split('.')[-1]=='TextBuffer' and p.obj(i+1).endswith('.ScriptText'):
            result[p.obj(i+1).split('.')[0]]=repair(Reader(p.payload(e),9).string().replace('\r\r\n','\n').replace('\r\n','\n'))
    return result
# Rewrite external asset paths for this machine while keeping native options.
configuration=text(args.config)
configuration=re.sub(r'(?im)^Paths=.*\n?','',configuration)
paths=['Paths=..\\Bin\\*.u']
for directory,extensions in [('Textures',['spi','utx']),('Animations',['spa','ukx']),('Models',['spd','usx']),('Sounds',['sps','uax']),('Maps',['spm','unr'])]:
    for ext in extensions:paths.append('Paths='+str((args.asset_root/directory).resolve())+'/*.'+ext)
configuration=re.sub(r'(?im)^\[Core.System\]\s*$',lambda m:m[0]+'\n'+'\n'.join(paths),configuration)
def config_text():return configuration

stage=args.work_root.resolve();b=stage/'Bin';b.mkdir(parents=True,exist_ok=True)
runtime=args.runtime_bin.resolve()
for f in runtime.iterdir():
 if f.is_file() and f.suffix.lower() in ['.dll','.exe','.u','.int','.ini','.urt'] and f.name.lower()!='toolys.dll':shutil.copy2(f,b/f.name)
for f in runtime.glob('*.u'):shutil.copy2(f,b/f.name)

property_tags._property_types={}
typeids={'ByteProperty':1,'IntProperty':2,'BoolProperty':3,'FloatProperty':4,'ObjectProperty':5,'ClassProperty':5,'NameProperty':6,'StrProperty':13,'ArrayProperty':9,'StructProperty':10}
for f in b.glob('*.u'):
 if f.stem=='SyncValidation':continue
 q=Package(f)
 for entry in q.exp:
  typ=typeids.get(q.obj(entry['cls']).rsplit('.',1)[-1])
  if typ:property_tags._property_types.setdefault(q.names[entry['name']][0],set()).add(typ)
# The editor reparses ScriptText of inherited classes as well. Historical
# transplants left stale text (including defaults, which UCC stores separately).
# Replace validation copies only; serialized native layouts/assets remain intact.
for pn in [f.stem for f in b.glob('*.u') if f.stem!='SyncValidation']:
 p=Package(b/f'{pn}.u');raw=bytearray(p.d)
 for e in p.exp:
  if e['cls']!=0:continue
  data=p.payload(e)
  try:offset,props=property_tags.class_defaults(p,e)
  except AssertionError:continue
  emitters=[v for v in props if v['name']=='Emitters' and v['type'] in [5,9]]
  if not emitters:continue
  for v in reversed(emitters):data=data[:v['start']]+data[v['end']:]
  e['offset']=len(raw);e['size']=len(data);raw.extend(data)
 for i,e in enumerate(p.exp):
  if p.obj(e['cls']).split('.')[-1]!='TextBuffer' or not p.obj(i+1).endswith('.ScriptText'):continue
  cn=p.obj(i+1).split('.')[0];sp=repo/pn/'Classes'/f'{cn}.uc'
  src=text(sp) if sp.exists() else repair(Reader(p.payload(e),9).string());dp=re.search(r'(?im)^defaultproperties\b',mask(src))
  if dp:src=src[:dp.start()]
  src=re.sub(r'(?im)^\s*#exec[^\n]*','',src)
  data=p.payload(e)[:9]+compact(-len(src.encode('utf-16le'))//2-1)+src.encode('utf-16le')+b'\0\0'
  e['offset']=len(raw);e['size']=len(data);raw.extend(data)
 struct.pack_into('<i',raw,24,len(raw))
 for e in p.exp:
  raw.extend(compact(e['cls'])+compact(e['super'])+struct.pack('<i',e['outer'])+compact(e['name'])+struct.pack('<I',e['flags'])+compact(e['size']))
  if e['size']:raw.extend(compact(e['offset']))
 (b/f'{pn}.u').write_bytes(raw)
qc=stage/'RemoteMotionSys/Classes';qc.mkdir(parents=True,exist_ok=True)
for f in (repo/'RemoteMotionSys/Classes').glob('*.uc'):(qc/f.name).write_text(text(f),'utf16')
queueini=re.sub(r'(?m)^EditPackages=.*\n?','',config_text())+'\n[Editor.EditorEngine]\nEditPackages=Core\nEditPackages=Engine\nEditPackages=RemoteMotionSys\n'
(b/'queue.ini').write_text(queueini,'utf16');(b/'RemoteMotionSys.u').unlink()
qr=subprocess.run([str(b/'UCC.exe'),'make','ini=queue.ini','-unattended'],cwd=b,capture_output=True,timeout=120)
ql=qr.stdout.decode('gbk',errors='replace');(stage/'queue-compile.txt').write_text(ql,'utf8')
assert qr.returncode==0 and 'Success - 0 error(s)' in ql,ql[-2000:]
c=stage/'SyncValidation/Classes';c.mkdir(parents=True,exist_ok=True)
for generated in c.glob('Sync_*.uc'):generated.unlink()
count=0
for row in manifest['sources']:
 path=repo/row['path'];pn=path.parts[-3];cn=path.stem;s=text(path)
 bs=blocks(s);methods=[v for v in bs if v['kind']=='state' or not any(st['kind']=='state' and st['body']<v['start']<st['end'] for st in bs)]
 original=args.original_bin/f'{pn}.u'
 if original.exists():
  old=source_pkg(Package(original)).get(cn,'');oldmap=method_map(old)
  oldstates={v['name']:[v] for v in blocks(old) if v['kind']=='state'}
  methods=[v for v in methods if v['name'] not in (oldstates if v['kind']=='state' else oldmap) or fullnorm(s[v['start']:v['end']])!=fullnorm(old[(oldstates if v['kind']=='state' else oldmap)[v['name']][0]['start']:(oldstates if v['kind']=='state' else oldmap)[v['name']][0]['end']])]
 if not methods:continue
 source=f'class Sync_{cn} extends {cn};\n'+'\n\n'.join(s[v['start']:v['end']] for v in sorted(methods,key=lambda x:x['start']))
 source=re.sub(r'(?im)^(\s*(?:auto\s+)?state(?:\(\))?\s+\w+)\s+extends\s+\w+',r'\1',source)
 source=re.sub(r'(?im)^(\s*(?:(?:simulated|static)\s+)*final\s+function\s+(?:\w+\s+)?)(\w+)(\s*\()',r'\1SyncFinal_\2\3',source)
 (c/f'Sync_{cn}.uc').write_text(source,'utf16');count+=len(method_map(source))
ini=config_text();ini=re.sub(r'(?m)^EditPackages=.*\n?','',ini)
ini+='\n[Editor.EditorEngine]\nEditPackages=Core\nEditPackages=Engine\nEditPackages=Interface\nEditPackages=Sephiroth\nEditPackages=SephirothUI\nEditPackages=EnchantFx\nEditPackages=ActiveFx\nEditPackages=SpecialFx\nEditPackages=BowAttackRuntime\nEditPackages=CmdMelee\nEditPackages=ObjectStore\nEditPackages=RemoteMotionSys\nEditPackages=SceneRegistry\nEditPackages=UIVisibility\nEditPackages=FreeviewPrefs\nEditPackages=SyncValidation\n'
(b/'sync.ini').write_text(ini,'utf16')
p=b/'SyncValidation.u'
if p.exists():p.unlink()
r=subprocess.run([str(b/'UCC.exe'),'make','ini=sync.ini','-unattended'],cwd=b,capture_output=True,timeout=180)
log=r.stdout.decode('gbk',errors='replace')+r.stderr.decode('gbk',errors='replace');(stage/'compile.txt').write_text(log,'utf8');print(log[-1000:]);print('exit',r.returncode,'methods',count)
assert r.returncode==0 and 'Success - 0 error(s)' in log, 'Compiler failed; inspect compile.txt and Bin/UCC.log'
warning_report=audit(log,repo,b,stage)
(stage/'warnings.json').write_text(json.dumps(warning_report,ensure_ascii=False,indent=2)+'\n','utf8')
assert warning_report['requires_review']==0, 'Warnings require functional review; inspect warnings.json'
(stage/'result.json').write_text(json.dumps({'typecheck':'PASS','donor_methods':count,'warnings':warning_report['total'],'warning_categories':warning_report['categories'],'warning_review':'PASS','runtime_integration_tested':False},indent=2),'utf8')
