import base64
import copy
import hashlib
import sys
import unittest
from pathlib import Path
import zlib

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from apply_client_patches import apply_recipe


class PatchPreconditions(unittest.TestCase):
    def setUp(self):
        self.original = b'original-data'
        self.target = b'Original-data-tail'
        self.recipe = {
            'format': 1,
            'source_size': len(self.original),
            'source_sha256': hashlib.sha256(self.original).hexdigest(),
            'target_size': len(self.target),
            'target_sha256': hashlib.sha256(self.target).hexdigest(),
            'replacements': [{'offset': 0, 'before': '6f', 'after': '4f'}],
            'append_zlib_base64': base64.b64encode(zlib.compress(b'-tail')).decode(),
        }

    def test_reproduce_without_mutating_input(self):
        original = bytearray(self.original)
        self.assertEqual(apply_recipe(original, self.recipe), self.target)
        self.assertEqual(original, self.original)

    def test_reject_other_revision(self):
        with self.assertRaises(ValueError):
            apply_recipe(b'Original-data', self.recipe)

    def test_reject_wrong_instruction_preimage(self):
        recipe = copy.deepcopy(self.recipe)
        recipe['replacements'][0]['before'] = '00'
        with self.assertRaises(ValueError):
            apply_recipe(self.original, recipe)

    def test_reject_overlapping_hunks(self):
        recipe = copy.deepcopy(self.recipe)
        recipe['replacements'] *= 2
        with self.assertRaises(ValueError):
            apply_recipe(self.original, recipe)

    def test_reject_outside_original(self):
        for offset in [-1, len(self.original)]:
            recipe = copy.deepcopy(self.recipe)
            recipe['replacements'][0]['offset'] = offset
            with self.assertRaises(ValueError):
                apply_recipe(self.original, recipe)

    def test_reject_incorrect_result(self):
        recipe = copy.deepcopy(self.recipe)
        recipe['target_sha256'] = '0' * 64
        with self.assertRaises(ValueError):
            apply_recipe(self.original, recipe)


if __name__ == '__main__':
    unittest.main()
