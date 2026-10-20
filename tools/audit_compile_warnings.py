"""Classify UCC warnings and fail on warnings needing functional review.

Unused locals are accepted only after checking the function body: the name must
occur only in its declaration (comments, strings and member names do not count).
No compiler output is suppressed. Dependency sources can be read from the
isolated runtime when a class is not part of this source checkout.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import sys

from unreal_package import Package, Reader
from unreal_source import mask, method_map, read_source


def parse_warnings(log):
    rows = []
    for line in log.splitlines():
        match = re.match(r'^(.+?)\((\d+)\) : Warning, (.+)$', line)
        if not match:
            continue
        absolute, number, message = match.groups()
        absolute = absolute.replace('\\', '/')
        relative = re.search(r'([^/]+/Classes/[^/]+\.uc)$', absolute)
        if not relative:
            raise ValueError(f'Unknown source path in compiler warning: {absolute}')
        rows.append({'path': relative[1], 'line': int(number), 'message': message})
    summary = re.search(r'Success - 0 error\(s\), (\d+) warning\(s\)', log)
    if not summary or int(summary[1]) != len(rows):
        raise ValueError('Warning inventory does not match a successful compiler summary')
    return rows


def inspect_unused_local(source, variable, warning_line):
    code = mask(source)
    candidates = []
    for function, entries in method_map(source).items():
        for block in entries:
            body = code[block['body'] + 1:block['end'] - 1]
            for declaration in re.finditer(r'\blocal\s+[^;]+;', body, re.I):
                if not re.search(r'\b' + re.escape(variable) + r'\b', declaration[0], re.I):
                    continue
                line = source[:block['body'] + 1 + declaration.start()].count('\n') + 1
                references = [m for m in re.finditer(r'\b' + re.escape(variable) + r'\b', body, re.I)
                              if not body[:m.start()].rstrip().endswith('.')]
                candidates.append((abs(line - warning_line), function, line, len(references)))
    if not candidates:
        raise ValueError(f'Local declaration not found: {variable}')
    _, function, line, references = min(candidates, key=lambda entry: entry[0])
    return {'function': function, 'declaration_line': line, 'unqualified_occurrences': references,
            'declaration_only': references == 1}


def audit(log, repository, runtime_bin, stage):
    rows = parse_warnings(log)
    packages = {}
    for row in rows:
        path = Path(row['path'])
        donor = path.parts[0] == 'SyncValidation'
        row['origin'] = 'validation_donor' if donor else 'client_source'
        message = row['message']
        if message == "Class names shouldn't end in a digit":
            row.update(category='numeric_class_name', requires_review=False)
        elif re.fullmatch(r"'([^']+)' : unreferenced local variable", message):
            variable = re.fullmatch(r"'([^']+)' : unreferenced local variable", message)[1]
            location = stage / path if donor else repository / path
            if location.exists():
                source = read_source(location)
            else:
                package_name = path.parts[0]
                if package_name not in packages:
                    packages[package_name] = Package(runtime_bin / (package_name + '.u'))
                package = packages[package_name]
                entry = next(e for i, e in enumerate(package.exp)
                             if package.obj(i + 1) == path.stem + '.ScriptText')
                source = Reader(package.payload(entry), 9).string().replace('\r\r\n', '\n').replace('\r\n', '\n')
                row['origin'] = 'dependency_package'
            evidence = inspect_unused_local(source, variable, row['line'])
            row.update(category='unused_local', variable=variable, evidence=evidence,
                       requires_review=not evidence['declaration_only'])
        elif 'Missing return value' in message:
            row.update(category='missing_return', requires_review=True)
        elif ' obscures ' in message:
            row.update(category='shadowed_name', requires_review=True)
        else:
            row.update(category='unrecognized_warning', requires_review=True)
    return {'total': len(rows), 'categories': dict(Counter(row['category'] for row in rows)),
            'origins': dict(Counter(row['origin'] for row in rows)),
            'requires_review': sum(row['requires_review'] for row in rows), 'warnings': rows}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--log', type=Path, required=True)
    parser.add_argument('--runtime-bin', type=Path, required=True)
    parser.add_argument('--stage', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--report-only', action='store_true')
    args = parser.parse_args()
    repository = Path(__file__).resolve().parents[1]
    result = audit(read_source(args.log), repository, args.runtime_bin, args.stage)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', 'utf8')
    print(json.dumps({key: value for key, value in result.items() if key != 'warnings'}, ensure_ascii=False))
    if result['requires_review'] and not args.report_only:
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
