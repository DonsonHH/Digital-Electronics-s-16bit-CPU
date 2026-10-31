"""Mismatched but individually complete matrices must not author the core Word."""
from pathlib import Path
import json,subprocess,sys,tempfile,unittest
P=Path(__file__).resolve().parents[1]
BASE=P/'验证/performance_ac1_9b449e40f5d44bd78936f207953b77d6/result.json'
WB=P/'验证/performance_wb_mem_9107d27100194667a0734312336b3952/result.json'

class DocumentBinding(unittest.TestCase):
    def check_mismatch(self,which):
        paths={'baseline-matrix':BASE,'forward-comparison':P/'实验/前递候选比较.json',
               'wb-matrix':WB,'wb-validation':P/'验证/wb_mem_validation_0uubusdk/result.json',
               'wb-guards':P/'验证/wb_mem_guards_ih7si0_i/result.json','wb-comparison':P/'实验/WB_MEM候选比较.json'}
        with tempfile.TemporaryDirectory(prefix='cpu_doc_wrong_graph_')as tmp:
            root=Path(tmp);data=json.loads(paths[which].read_text(encoding='utf-8'))
            # Keep status/rows/child references valid, but change the matrix
            # receipt identity so it no longer belongs to either comparison.
            data['review_probe']='different complete matrix receipt'
            altered=root/'matrix.json';altered.write_text(json.dumps(data),encoding='utf-8');paths[which]=altered
            output=root/'must_not_be_authored.docx'
            cmd=[sys.executable,'-B','-X','utf8',str(P/'板级/update_core_document.py'),'--output',str(output)]
            for key,value in paths.items():cmd+=['--'+key,str(value)]
            run=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            self.assertNotEqual(run.returncode,0)
            self.assertIn('comparison',run.stdout.decode('utf-8','replace').lower())
            self.assertFalse(output.exists())
    def test_different_baseline_matrix_is_rejected(self):self.check_mismatch('baseline-matrix')
    def test_different_wb_matrix_is_rejected(self):self.check_mismatch('wb-matrix')
if __name__=='__main__':unittest.main()
