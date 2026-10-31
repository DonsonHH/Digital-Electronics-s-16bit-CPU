from pathlib import Path
import hashlib,json,shutil,subprocess,sys,tempfile,unittest
BASE=Path(__file__).resolve().parents[1]
class FailedPreflight(unittest.TestCase):
 def test_bad_tools_record_failed_attempt_without_replacing_previous_success(self):
  with tempfile.TemporaryDirectory(prefix='cpu_preflight_') as td:
   root=Path(td);v=root/'Vivado';v.mkdir()
   for n in ['tool_config.py','tool_config.ps1','run_verify.ps1','run_synthesis.ps1']:shutil.copy2(BASE/n,v/n)
   for script,index,success in [('run_verify.ps1','最近运行.json','验证结果.json'),('run_synthesis.ps1','最近综合.json','综合结果.json')]:
    previous=root/success;previous.write_text('{"historical_success":true}');before=hashlib.sha256(previous.read_bytes()).hexdigest()
    p=subprocess.run([shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(v/script),'-Python',sys.executable,'-VivadoBin',str(root/'missing')],capture_output=True)
    self.assertNotEqual(p.returncode,0)
    self.assertEqual(json.loads((root/index).read_text(encoding='utf-8-sig'))['status'],'failed')
    self.assertEqual(hashlib.sha256(previous.read_bytes()).hexdigest(),before)
if __name__=='__main__':unittest.main()
