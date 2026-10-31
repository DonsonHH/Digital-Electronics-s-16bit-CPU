"""Acceptance checks using real native pass/fail artifacts; no fabricated success."""
from pathlib import Path
import sys,unittest
B=Path(__file__).resolve().parents[1];P=B.parent
sys.path.insert(0,str(B))
from verify_board_results import parse_timing,analyze_reports,verify_attempt,require_tool_version,review_console_warnings
GOOD=P/'验证/cpu345_board_oo6rg6jq'
class RoutedEvidence(unittest.TestCase):
 def test_other_tool_version_and_unreviewed_warnings_are_rejected(self):
  with self.assertRaisesRegex(ValueError,'2025.2'):require_tool_version('2026.1')
  with self.assertRaisesRegex(ValueError,'Unreviewed'):review_console_warnings('WARNING: [Synth 8-9999] new issue\n')
  with self.assertRaisesRegex(ValueError,'context'):review_console_warnings("WARNING: [Synth 8-7071] port 'dm_we' of module 'cpu_system' is unconnected for instance 'bad'\n")
 def test_real_routed_report_and_physical_lut_accounting(self):
  result=verify_attempt(GOOD)
  self.assertEqual(result['resources']['lut_total'],1118)
  self.assertEqual(result['resources']['lutram'],24)
  self.assertEqual(result['resources']['ff'],2826)
  self.assertEqual(result['resources']['bram18'],2)
  self.assertEqual(result['timing']['wns_ns'],2.086)
  self.assertEqual(result['timing']['whs_ns'],0.071)
  self.assertFalse(result['board_validated'])
 def test_negative_hold_cannot_be_hidden_by_positive_setup(self):
  text=(GOOD/'reports/timing.rpt').read_text()
  row='      2.086        0.000                      0                 4279        0.071'
  self.assertIn(row,text)
  bad=text.replace(row,row[:-5]+'-0.071',1)
  with self.assertRaisesRegex(ValueError,'slack'):parse_timing(bad)
 def test_bitstream_with_failed_image_initialization_is_rejected(self):
  failed=P/'验证/cpu345_board_dai5gyww'
  self.assertTrue((failed/'output/ees331.bit').exists())
  with self.assertRaisesRegex(ValueError,'memories|Synthesis'):analyze_reports(failed,'2a59204e6a12c32f')
 def test_failed_native_attempt_cannot_be_promoted(self):
  with self.assertRaisesRegex(ValueError,'successfully'):verify_attempt(P/'验证/cpu345_board_fysd61xx')
if __name__=='__main__':unittest.main()
