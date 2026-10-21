from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from audit_compile_warnings import audit, inspect_unused_local, parse_warnings


class WarningAudit(unittest.TestCase):
    def test_counts_duplicate_donor_warnings(self):
        log = ("C:\\stage\\UI\\Classes\\Bar2.uc(1) : Warning, Class names shouldn't end in a digit\n"
               "C:\\stage\\SyncValidation\\Classes\\Sync_Bar2.uc(1) : Warning, Class names shouldn't end in a digit\n"
               'Success - 0 error(s), 2 warning(s)\n')
        rows = parse_warnings(log)
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[1]['path'], 'SyncValidation/Classes/Sync_Bar2.uc')

    def test_rejects_incomplete_warning_inventory(self):
        with self.assertRaises(ValueError):
            parse_warnings('Success - 0 error(s), 1 warning(s)\n')

    def test_member_names_comments_and_strings_are_not_local_uses(self):
        source = '''class Test extends Object;
function Draw() {
 local byte A;
 Target.Color.A = 255;
 Target.Color . A = 128;
 // A was formerly used here.
 Consume("A");
}'''
        result = inspect_unused_local(source, 'a', 3)
        self.assertTrue(result['declaration_only'])
        self.assertEqual(result['unqualified_occurrences'], 1)

    def test_rejects_assignment_to_claimed_unused_local(self):
        source = 'class Test extends Object;\nfunction Run() { local int I; I=4; }'
        self.assertFalse(inspect_unused_local(source, 'I', 2)['declaration_only'])

    def test_rejects_missing_declaration(self):
        with self.assertRaises(ValueError):
            inspect_unused_local('class Test extends Object;', 'Ghost', 1)

    def test_flags_return_shadow_and_unknown_warnings(self):
        messages = ['Run: Missing return value', "'Tag' obscures 'Tag' defined in base class 'Actor'.",
                    'New compiler diagnostic']
        log = ''.join(f'C:/stage/UI/Classes/Test.uc(1) : Warning, {message}\n' for message in messages)
        log += 'Success - 0 error(s), 3 warning(s)\n'
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report = audit(log, root, root, root)
        self.assertEqual(report['requires_review'], 3)
        self.assertEqual(report['categories'], {'missing_return': 1, 'shadowed_name': 1, 'unrecognized_warning': 1})


if __name__ == '__main__':
    unittest.main()
