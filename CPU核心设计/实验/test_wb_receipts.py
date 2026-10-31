"""Regression checks for fatal-then-timeout false acceptance; no HDL/device execution."""
from pathlib import Path
import hashlib,json,sys,tempfile,unittest
from unittest.mock import patch
E=Path(__file__).resolve().parent;sys.path[:0]=[str(E),str(E.parent/'板级')]
import run_wb_guards as guards
from compare_wb_results import native_receipt

class LifecycleTests(unittest.TestCase):
    def fixture(self,root,code=0,error=None):
        console=root/'guards_console.log';console.write_text('Vivado Simulator v2025.2\n',encoding='utf-8')
        (root/'private.log').write_text('Fatal: GUARD_STORE_VALUE\n$finish called at time : 75 ns\n',encoding='utf-8')
        (root/'guards_execution.json').write_text(json.dumps(dict(exit_code=code,error=error,input_sha256={},console_sha256=hashlib.sha256(console.read_bytes()).hexdigest())))
    def test_integer_fatal_exit_zero_is_complete_but_not_positive(self):
        with tempfile.TemporaryDirectory()as tmp:
            root=Path(tmp);self.fixture(root)
            self.assertEqual(native_receipt(root,'guards')['exit_code'],0)
            with patch.object(guards.native,'prepare'),patch.object(guards.native,'execute',return_value=0):
                code,log=guards.execute(root,root);self.assertIn('Fatal: GUARD_STORE_VALUE',log);self.assertNotIn('WB_GUARDS_PASS',log)
    def test_incomplete_lifecycle_rejected_despite_intended_fatal(self):
        for code,error in [('timeout','terminated'),('interrupted','terminated'),('launch_failed','OS error'),(0,'interrupted'),(-1,None),(True,None)]:
            with self.subTest(code=code,error=error),tempfile.TemporaryDirectory()as tmp:
                root=Path(tmp);self.fixture(root,code,error)
                with self.assertRaises(ValueError):native_receipt(root,'guards')
                with patch.object(guards.native,'prepare'),patch.object(guards.native,'execute',return_value=1),self.assertRaises(RuntimeError):guards.execute(root,root)
    def test_replaced_console_rejected(self):
        with tempfile.TemporaryDirectory()as tmp:
            root=Path(tmp);self.fixture(root);(root/'guards_console.log').write_text('changed')
            with self.assertRaises(ValueError):native_receipt(root,'guards')
if __name__=='__main__':unittest.main()
