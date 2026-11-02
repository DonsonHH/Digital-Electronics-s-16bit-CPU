"""Public legacy CLI must not silently roll an architecture Word back to r1/r2."""
from pathlib import Path
import hashlib,subprocess,sys,tempfile,unittest,zipfile
P=Path(__file__).resolve().parents[2]

class LegacyDestinationTests(unittest.TestCase):
    def command(self,output):
        return [sys.executable,'-B','-X','utf8',str(P/'板级/update_core_document.py'),
          '--baseline-matrix',str(P/'验证/performance_ac1_9b449e40f5d44bd78936f207953b77d6/result.json'),
          '--forward-comparison',str(P/'实验/前递候选比较.json'),
          '--wb-matrix',str(P/'验证/performance_wb_mem_9107d27100194667a0734312336b3952/result.json'),
          '--wb-validation',str(P/'验证/wb_mem_validation_0uubusdk/result.json'),
          '--wb-guards',str(P/'验证/wb_mem_guards_ih7si0_i/result.json'),
          '--wb-comparison',str(P/'实验/WB_MEM候选比较.json'),'--output',str(output)]
    def check_destination(self,command):
        with tempfile.TemporaryDirectory(prefix='cpu_r3_guard_')as tmp:
            output=Path(tmp)/'architecture.docx'
            with zipfile.ZipFile(output,'w')as z:
                z.writestr('docProps/core.xml','<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"><cp:version>AC1-architecture-r3</cp:version></cp:coreProperties>')
            before=hashlib.sha256(output.read_bytes()).hexdigest()
            r=subprocess.run(command(output),stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            self.assertNotEqual(r.returncode,0,'Legacy r2 CLI overwrote an r3 architecture document')
            self.assertIn('architecture',r.stdout.decode('utf-8','replace').lower())
            self.assertEqual(hashlib.sha256(output.read_bytes()).hexdigest(),before)
    def test_board_legacy_cli_refuses_architecture_destination(self):self.check_destination(self.command)
    def test_system_legacy_cli_refuses_architecture_destination(self):
        self.check_destination(lambda output:[sys.executable,'-B','-X','utf8',str(P/'系统/build_core_document.py'),
          '--system-receipt',str(P/'验证/cpu_system_n0r4buws/result.json'),
          '--tools-receipt',str(P/'验证/tools_50040838e0ec474680085bb91e8fb001/result.json'),'--output',str(output)])
if __name__=='__main__':unittest.main()
