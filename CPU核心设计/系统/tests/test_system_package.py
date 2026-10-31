"""System input and terminal-result contract checks through the runner API."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest

SYSTEM = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('system_runner', SYSTEM / 'run_system.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class SystemContract(unittest.TestCase):
    def test_missing_and_malformed_boot_files_are_rejected(self):
        with tempfile.TemporaryDirectory(prefix='cpu_image_contract_') as directory:
            root = Path(directory)
            shutil.copytree(SYSTEM / 'programs', root / 'programs')
            runner.validate_images(root)
            target = root / 'programs/all_ops_im.mem'
            target.unlink()
            with self.assertRaisesRegex(ValueError, 'inventory'):
                runner.validate_images(root)
            target.write_text('e000\n', encoding='ascii')
            manifest_path = root / 'programs/manifest.json'
            manifest = json.loads(manifest_path.read_text())
            manifest['input_sha256'][target.name] = hashlib.sha256(target.read_bytes()).hexdigest()
            manifest_path.write_text(json.dumps(manifest))
            with self.assertRaisesRegex(ValueError, '256 four-hex-digit'):
                runner.validate_images(root)

    def test_finish_marker_alone_cannot_publish_a_system_pass(self):
        manifest = json.loads((SYSTEM / 'programs/manifest.json').read_text())
        fake = ('SYSTEM_ATTEMPT=local\nSYSTEM_PASS cases=11 boot=file_only reset_kinds=2 debug_injections=2\n'
                '$finish called at time : 1 ns\n')
        with self.assertRaisesRegex(ValueError, 'rows'):
            runner.check_simulation(fake, 'local', 'system', manifest)


if __name__ == '__main__':
    unittest.main()
