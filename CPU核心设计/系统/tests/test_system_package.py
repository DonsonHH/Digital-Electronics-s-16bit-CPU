"""System input and terminal-result contract checks through the runner API."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import tempfile
import unittest

SYSTEM = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('system_runner', SYSTEM / 'run_system.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class SystemContract(unittest.TestCase):
    def test_document_cli_rejects_incomplete_inventory_and_native_steps(self):
        source=json.loads((SYSTEM.parent/'验证/cpu_system_n0r4buws/result.json').read_text())
        document=SYSTEM.parent/'16位流水线CPU核心设计文档_AC1候选版.docx'
        before=hashlib.sha256(document.read_bytes()).hexdigest()
        with tempfile.TemporaryDirectory(prefix='cpu_bad_receipt_') as directory:
            for mode,detail in [('inventory','execution inventory'),('steps','step sequence')]:
                data=json.loads(json.dumps(source))
                if mode=='inventory':data['input_sha256'].pop('rtl/datapath_core.sv')
                else:data['steps'].pop()
                bad=Path(directory)/(mode+'.json');bad.write_text(json.dumps(data))
                result=subprocess.run([sys.executable,'-B','-X','utf8',str(SYSTEM/'build_core_document.py'),
                    '--system-receipt',str(bad),'--tools-receipt',str(SYSTEM.parent/'验证/tools_50040838e0ec474680085bb91e8fb001/result.json')],capture_output=True,text=True,encoding='utf-8')
                self.assertNotEqual(result.returncode,0);self.assertIn(detail,result.stderr)
        self.assertEqual(hashlib.sha256(document.read_bytes()).hexdigest(),before)

    def test_document_cli_rejects_stale_receipt_before_touching_word(self):
        document=SYSTEM.parent/'16位流水线CPU核心设计文档_AC1候选版.docx'
        before=hashlib.sha256(document.read_bytes()).hexdigest()
        run=subprocess.run([sys.executable,'-B','-X','utf8',str(SYSTEM/'build_core_document.py'),
            '--system-receipt',str(SYSTEM.parent/'验证/cpu_system_q38z9y_0/result.json'),
            '--tools-receipt',str(SYSTEM.parent/'验证/tools_50040838e0ec474680085bb91e8fb001/result.json')],capture_output=True,text=True,encoding='utf-8')
        self.assertNotEqual(run.returncode,0)
        self.assertIn('Stale system input',run.stderr)
        self.assertEqual(hashlib.sha256(document.read_bytes()).hexdigest(),before)

    def test_reset_epoch_cannot_be_removed_by_editing_the_manifest(self):
        manifest = json.loads((SYSTEM / 'programs/manifest.json').read_text())
        manifest['cases'][9]['reset_kind'] = 0
        saved = SYSTEM.parent / '验证/cpu_system_q38z9y_0/system.log'
        log = saved.read_text(encoding='utf-8')
        shortened = '\n'.join(line for line in log.splitlines() if not line.startswith('SYSTEM_CASE_PASS name=reset_after_halt epoch=1 '))
        with self.assertRaises(ValueError):
            runner.check_simulation(shortened, 'cpu_system_q38z9y_0', 'system', manifest)

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
