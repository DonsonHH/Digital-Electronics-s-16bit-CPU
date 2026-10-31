from pathlib import Path
import hashlib,json,subprocess,sys,tempfile,unittest
BASE=Path(__file__).resolve().parents[1];sys.path.insert(0,str(BASE))
from generate_independent import generate
from run_independent import load_case_package
class CasePackageIntegrity(unittest.TestCase):
 def test_valid_then_reject_empty_hashes_and_rehashed_input_change(self):
  with tempfile.TemporaryDirectory(prefix='cpu_packet_') as td:
   p=Path(td)/'good';generate(p);load_case_package(p)
   manifest=json.loads((p/'manifest.json').read_text());saved=json.loads(json.dumps(manifest))
   manifest['input_sha256']={};(p/'manifest.json').write_text(json.dumps(manifest))
   with self.assertRaises(ValueError):load_case_package(p)
   f=p/'programs/case_00_im.mem';text=f.read_text();f.write_text('1002'+text[4:])
   saved['input_sha256']['programs/case_00_im.mem']=hashlib.sha256(f.read_bytes()).hexdigest();(p/'manifest.json').write_text(json.dumps(saved))
   with self.assertRaises(ValueError):load_case_package(p)
 def test_reject_replayed_outputs_and_launcher_before_execution(self):
  with tempfile.TemporaryDirectory(prefix='cpu_replay_') as td:
   p=Path(td)/'packet';generate(p)
   (p/'desktop_launch.py').write_text('raise SystemExit(0)\n')
   (p/'private.log').write_text('ADVERSARIAL_PASS cases=48 reset_witnesses=10 failures=0 oracle=external_python memory=independent_sync\n')
   with self.assertRaises(ValueError):load_case_package(p)
if __name__=='__main__':unittest.main()
