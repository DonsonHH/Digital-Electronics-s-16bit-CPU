"""Frozen public output contract; no DUT logic is used as the expectation."""
from pathlib import Path
import json,subprocess,sys,tempfile,unittest
BASE=Path(__file__).resolve().parents[1]
FROZEN=BASE.parent/'验证记录/independent_48_saved'
class GeneratorContract(unittest.TestCase):
 def test_reproduce_frozen_48_from_new_directory_and_refuse_overwrite(self):
  with tempfile.TemporaryDirectory(prefix='cpu_generator_test_') as td:
   out=Path(td)/'cases'
   proc=subprocess.run([sys.executable,'-B','-X','utf8',str(BASE/'generate_independent.py'),'--output',str(out)],cwd=td,capture_output=True,text=True,encoding='utf-8',errors='replace')
   self.assertEqual(proc.returncode,0,proc.stdout+proc.stderr)
   self.assertEqual(json.loads((out/'cases.json').read_text()),json.loads((FROZEN/'cases.json').read_text()))
   for name in ['case_config.svh','case_count.svh']:
    self.assertEqual((out/name).read_text(),(FROZEN/name).read_text(),name)
   frozen=json.loads((FROZEN/'cases.json').read_text());consumed=set()
   for case in frozen:
    for c,prefix in [(case,case['prefix'])]+([(case['restart'],case['prefix']+'_restart')] if 'restart' in case else []):
     consumed.update(prefix+'_'+n+'.mem' for n in ['im','dm','rf','events','final_dm','final_rf'])
     if c['expected']['stores']:consumed.add(prefix+'_stores.mem')
   expected={name:(FROZEN/'programs'/name).read_text() for name in consumed}
   self.assertEqual({p.name:p.read_text() for p in (out/'programs').iterdir()},expected)
   again=subprocess.run([sys.executable,'-B','-X','utf8',str(BASE/'generate_independent.py'),'--output',str(out)],cwd=td,capture_output=True,text=True,encoding='utf-8',errors='replace')
   self.assertNotEqual(again.returncode,0)
   self.assertEqual(json.loads((out/'manifest.json').read_text())['case_count'],48)
if __name__=='__main__':unittest.main()
