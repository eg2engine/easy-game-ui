"""Static cumulative-client checks. These do not simulate a connected game."""
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from unreal_source import blocks, calls, mask, method_map, read_source


def native_prefix(source):
    code = mask(source)
    first = re.search(r'(?im)^\s*(?:(?:native(?:\(\d+\))?|final|simulated|static|exec)\s+)*(?:function|event)\b', code)
    return re.sub(r'\s+', ' ', code[:first.start()] if first else code).strip()


def native_declarations(source):
    declarations = re.findall(r'(?im)^\s*(?:(?:native(?:\(\d+\))?|static|final|simulated)\s+)+(?:function|event)\b[^;]*;', mask(source))
    return '|'.join(re.sub(r'\s+', ' ', d).strip() for d in declarations if re.search(r'\bnative\b', d))


manifest = json.loads((ROOT / 'tests/client-sync-manifest.json').read_text('utf8'))
methods = 0
for row in manifest['sources']:
    path = ROOT / row['path']
    source = read_source(path)
    assert not re.search(r'(?m)^<<<<<<< |^>>>>>>> ', source), path
    mapping = method_map(source)
    assert all(len(items) == 1 for items in mapping.values()), f'Duplicate method: {path}'
    methods += len(mapping)
    code = mask(source)
    assert code.count('{') == code.count('}'), f'Unbalanced braces: {path}'
    assert 'FlightVisualLog' not in source, f'Removed logging dependency: {path}'
    if row.get('native_prefix_sha256'):
        digest = hashlib.sha256(native_prefix(source).encode()).hexdigest()
        assert digest == row['native_prefix_sha256'], f'Native ABI prefix changed: {path}'
    if row.get('native_declarations_sha256'):
        digest = hashlib.sha256(native_declarations(source).encode()).hexdigest()
        assert digest == row['native_declarations_sha256'], f'Native entry declaration changed: {path}'
    allowed = set(row['allowed_log_signatures'])
    assert all(item['signature'] in allowed for item in calls(source)), f'Added runtime output: {path}'

controller = read_source(ROOT / 'Sephiroth/Classes/ClientController.uc')
mapping = method_map(controller)
for name in ['AddActionPool', 'PlayAction', 'NetRecv_ActMeleeFinish']:
    assert len(mapping[name]) == 1, name
finish = mapping['NetRecv_ActMeleeFinish'][0]
assert 'QueueIndex' in controller[finish['start']:finish['end']]
bow = method_map(read_source(ROOT / 'SephirothUI/Classes/NephilimPlayer.uc'))
assert 'BowAttacking.ActionEnd' in bow and 'ActionEnd' not in bow
assert (ROOT / 'RemoteMotionSys/Classes/FollowPolicy.uc').exists()
assert not (ROOT / 'FlightVisualLog').exists()
for recipe in (ROOT / 'native/patches').glob('*.json'):
    data = json.loads(recipe.read_text('utf8'))
    assert data['format'] == 1
    assert all(len(bytes.fromhex(h['before'])) == len(bytes.fromhex(h['after'])) for h in data['replacements'])
print(f'PASS: {len(manifest["sources"])} source files, {methods} methods, native prefixes, logging and recovery guards.')
print('Static checks only; connected-client regression remains required after review.')
