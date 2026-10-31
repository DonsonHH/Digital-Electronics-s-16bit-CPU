"""Prepared hardware-flow preflight checks. No actual Labtools/device commands."""
from pathlib import Path
import json,sys,tkinter,unittest
B=Path(__file__).resolve().parents[1];P=B.parent;sys.path.insert(0,str(B))
from run_hardware import expected_before_device_access
class HardwarePreflight(unittest.TestCase):
 def test_legacy_run_is_rejected_before_access_but_readonly_is_allowed(self):
  old=P/'验证/cpu345_board_hm1gthqt';data=json.loads((old/'result.json').read_text())
  with self.assertRaisesRegex(ValueError,'complete selected_result'):expected_before_device_access(data,old,True)
  self.assertEqual(expected_before_device_access(data,old,False),(None,None))
 def test_checksum_run_has_complete_independent_expected_state(self):
  root=P/'验证/cpu345_board_5prio5st';data=json.loads((root/'result.json').read_text())
  expected,packet=expected_before_device_access(data,root,True)
  self.assertEqual(expected['rf'],[0,0x1232,0,32]);self.assertEqual(expected['cycles'],55)
  self.assertEqual((packet>>47)&0xffff,71);self.assertEqual((packet>>22)&0xffff,0)
 def test_tcl_confirmation_guard_reads_process_environment_before_hardware(self):
  interp=tkinter.Tcl();printed=[];exits=[];hardware=[]
  interp.createcommand('version',lambda *args:'2025.2')
  interp.createcommand('puts',lambda *args:printed.append(args[-1]) or '')
  interp.createcommand('exit',lambda *args:exits.append(args[0] if args else '0') or '')
  interp.createcommand('open_hw_manager',lambda *args:hardware.append('FORBIDDEN') or '')
  interp.setvar('env(CPU_CONFIRMED_BOARD)','OTHER-BOARD')
  interp.eval((B/'hardware_session.tcl').read_text())
  self.assertIn('HARDWARE_SESSION_FAILED=Physical board confirmation missing',printed)
  self.assertEqual(exits[0],'1');self.assertEqual(hardware,[])
if __name__=='__main__':unittest.main()
