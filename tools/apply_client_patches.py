"""Reproduce cumulative native/resource patches against hash-locked originals.

Writes to a separate output directory; it never updates an installed client.
The JSON recipes contain byte replacements, not complete DLL/asset copies.
"""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import zlib


def sha(data):
    return hashlib.sha256(data).hexdigest()


def apply_recipe(original, recipe):
    if recipe.get('format') != 1:
        raise ValueError('Unsupported recipe format')
    if len(original) != recipe['source_size'] or sha(original) != recipe['source_sha256']:
        raise ValueError('Original file does not match the supported revision')
    result = bytearray(original)
    end = 0
    for change in recipe['replacements']:
        offset = change['offset']
        before, after = bytes.fromhex(change['before']), bytes.fromhex(change['after'])
        if offset < end or not before or offset + len(before) > len(original):
            raise ValueError('Overlapping or out-of-range replacement')
        if len(before) != len(after) or result[offset:offset + len(before)] != before:
            raise ValueError('Invalid replacement precondition')
        result[offset:offset + len(before)] = after
        end = offset + len(before)
    if recipe.get('append_zlib_base64'):
        result.extend(zlib.decompress(base64.b64decode(recipe['append_zlib_base64'], validate=True)))
    if len(result) != recipe['target_size'] or sha(result) != recipe['target_sha256']:
        raise ValueError('Patched file failed integrity validation')
    return bytes(result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--original-root', required=True, type=Path)
    parser.add_argument('--output-root', required=True, type=Path)
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    original_root, output_root = args.original_root.resolve(), args.output_root.resolve()
    if original_root == output_root or output_root in original_root.parents or original_root in output_root.parents:
        parser.error('Output must be separate from the original client tree')
    recipes = Path(__file__).resolve().parents[1] / 'native' / 'patches'
    # Validate the complete set before writing any output.
    outputs = []
    for path in sorted(recipes.glob('*.json')):
        recipe = json.loads(path.read_text('utf8'))
        relative = Path(recipe['path'])
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError('Unsafe recipe path')
        data = apply_recipe((original_root / relative).read_bytes(), recipe)
        target = output_root / relative
        if target.exists() and sha(target.read_bytes()) != sha(data):
            raise ValueError(f'Refusing to overwrite a different file: {target}')
        outputs.append((target, data))
    for target, data in outputs:
        if not args.verify_only:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        print(f'PASS {target.name}: {sha(data)}')


if __name__ == '__main__':
    main()
