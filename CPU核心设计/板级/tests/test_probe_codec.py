"""Decode a real simulated public VIO-layout sample; this is not a hardware test."""
from pathlib import Path
import sys,unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from probe_codec import decode,probe_integer
class ProbeLayout(unittest.TestCase):
 def test_actual_c0_last_vcd_sample(self):
  # cpu345_board_pjn0kj4p/board_application.vcd, c0.state/perf final values.
  state='123456789abcdef000000000000000005002080095c800960020000500050005'
  perf='100000002000000010000001000000019'
  d=decode(state,perf)
  self.assertEqual(d['rf'],[5,5,5,32]);self.assertEqual(d['flags'],[1,1,0])
  self.assertEqual(d['build_id'],'123456789abcdef0')
  self.assertEqual([d[k] for k in ['stop_pc','stop_reason','stop_valid','stop_pc_valid','halted','fault']],[18,1,1,1,1,0])
  self.assertEqual([d[k] for k in ['last_completed_pc','last_store_valid','last_store_addr','last_store_data','core_reset','reserved']],[18,1,32,5,0,0])
  self.assertEqual([d[k] for k in ['cycles','completed','stalls','redirects','stores']],[25,16,1,2,1])
 def test_unknown_and_oversized_probe_values_fail(self):
  for value in ['xxxxxxxx','z','']:
   with self.assertRaises(ValueError):probe_integer(value,256)
  with self.assertRaises(ValueError):probe_integer('100',8)
if __name__=='__main__':unittest.main()
