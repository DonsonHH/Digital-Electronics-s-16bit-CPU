"""Document acceptance must stay bound to the physical raw observations; no hardware access."""
from pathlib import Path
import hashlib,json,shutil,sys,tempfile,unittest
B=Path(__file__).resolve().parents[1];sys.path.insert(0,str(B))
from source_validation import P,read,verify_board_validation
class BoardEvidence(unittest.TestCase):
 def test_missing_or_empty_acceptance_pin_fails_closed(self):
  for value in [None,{},False]:
   plan=read(B/'architecture.json');plan['board_validation']=value
   with self.subTest(value=value),self.assertRaisesRegex(ValueError,'pin is required'):verify_board_validation(plan)
  plan=read(B/'architecture.json');plan.pop('board_validation')
  with self.assertRaisesRegex(ValueError,'pin is required'):verify_board_validation(plan)
 def test_real_physical_record_is_read_only_valid(self):
  result=verify_board_validation(read(B/'architecture.json'))
  self.assertEqual(len(result['programs']),5);self.assertTrue(result['physical_S1_verified'])
 def changed_summary(self,change,message):
  plan=read(B/'architecture.json');source=P/plan['board_validation']['record']
  with tempfile.TemporaryDirectory(prefix='cpu_board_doc_')as tmp:
   root=Path(tmp)/'evidence';shutil.copytree(source.parent,root)
   path=root/'result.json';result=read(path);change(result)
   path.write_text(json.dumps(result,ensure_ascii=False),encoding='utf-8')
   plan['board_validation']={'record':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
   with self.assertRaisesRegex(ValueError,message):verify_board_validation(plan)
 def test_changed_program_summary_cannot_replace_raw_data(self):
  self.changed_summary(lambda r:r['verified_programs'][0]['actual']['rf'].__setitem__(0,123),'Physical summary differs')
 def test_changed_button_summary_cannot_replace_raw_data(self):
  self.changed_summary(lambda r:r['button_samples'][1]['decoded']['rf'].__setitem__(0,123),'Button raw observations differ')
if __name__=='__main__':unittest.main()
