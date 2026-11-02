"""Edited CSVs and repeated import must fail without changing authoritative content."""
from pathlib import Path
import json,shutil,sys,tempfile,unittest
B=Path(__file__).resolve().parents[1];sys.path.insert(0,str(B))
from source_validation import verify_independent,P
from import_baseline import migrate
RUN=P/'验证记录/cpu_ac1_independent_lh6jb16m'

class SourceIntegrity(unittest.TestCase):
    def test_same_length_cycle_edit_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix='cpu_r3_csv_')as tmp:
            copy=Path(tmp)/'record';shutil.copytree(RUN,copy)
            path=copy/'independent_cycles.csv';text=path.read_bytes()
            old=b'DOC_ADD_ADD,0,1,0000,';new=b'DOC_ADD_ADD,0,1,00fe,'
            self.assertEqual(text.count(old),1);path.write_bytes(text.replace(old,new));self.assertEqual(path.stat().st_size,len(text))
            with self.assertRaisesRegex(ValueError,'canonical CSV'):verify_independent(copy)
    def test_existing_import_destination_is_not_modified(self):
        with tempfile.TemporaryDirectory(prefix='cpu_r3_import_')as tmp:
            root=Path(tmp);(root/'sections.json').write_text('{"edited":true}')
            (root/'assets').mkdir();asset=root/'assets/F03.png';asset.write_bytes(b'edited image')
            with self.assertRaises(ValueError):migrate(root)
            self.assertTrue(asset.read_bytes()==b'edited image','Importer overwrote an existing edited asset')
            self.assertEqual((root/'sections.json').read_text(),'{"edited":true}')
if __name__=='__main__':unittest.main()
