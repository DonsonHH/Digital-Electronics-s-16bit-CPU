"""Prepared hardware-flow preflight checks. No actual Labtools/device commands."""
from pathlib import Path
import copy,json,sys,tkinter,unittest
B=Path(__file__).resolve().parents[1];P=B.parent;sys.path.insert(0,str(B))
from run_hardware import expected_before_device_access,verify_stopped_captures
class HardwarePreflight(unittest.TestCase):
 def physical_capture_fixture(self):
  capture=json.loads((P/'验证/cpu345_hardware_mhdc67ya/result.json').read_text())
  root=P/'验证/cpu345_board_dzb2hgao';expected=json.loads((root/'result.json').read_text())['selected_result']
  packet=int((root/'programs/selected_stores.mem').read_text().splitlines()[-1],16)
  return copy.deepcopy(capture['snapshots']),expected,packet
 def test_both_real_stopped_captures_match_expected(self):
  verify_stopped_captures(*self.physical_capture_fixture())
 def test_first_stopped_capture_is_fully_checked(self):
  for field in ['rf','last_store_data']:
   with self.subTest(field=field):
    snapshots,expected,packet=self.physical_capture_fixture()
    if field=='rf':snapshots[0]['rf'][0]^=1
    else:snapshots[0][field]^=1
    with self.assertRaisesRegex(ValueError,'Hardware (differs|last-store differs)'):verify_stopped_captures(snapshots,expected,packet)
 def _run_tcl_identity_guard(self,actual,expected):
  # Execute the real complete Tcl entry with every hardware/file command stubbed.
  interp=tkinter.Tcl();printed=[];exits=[];programmed=[]
  interp.createcommand('version',lambda *args:'2025.2')
  interp.createcommand('puts',lambda *args:printed.append(args[-1]) or '')
  interp.createcommand('exit',lambda *args:exits.append(args[0] if args else '0') or '')
  for name in ['open_hw_manager','connect_hw_server','current_hw_target','set_property','open_hw_target','current_hw_device','refresh_hw_device','refresh_hw_vio','after','close_hw_target','disconnect_hw_server','close_hw_manager','close']:
   interp.createcommand(name,lambda *args:'')
  interp.createcommand('open',lambda *args:'fake_capture')
  interp.createcommand('get_hw_targets',lambda *args:'test_target')
  interp.createcommand('get_hw_devices',lambda *args:'test_fpga')
  interp.createcommand('get_hw_vios',lambda *args:'test_vio')
  interp.createcommand('get_hw_probes',lambda name,*args:name)
  interp.createcommand('get_property',lambda key,probe:(actual+'0'*48)if probe=='state_probe'else'0')
  interp.createcommand('program_hw_devices',lambda *args:programmed.append(args)or'')
  values={'CPU_CONFIRMED_BOARD':'EES-331','CPU_HW_TARGET':'test_target','CPU_HW_LTX':'unused.ltx','CPU_HW_PROGRAM':'0','CPU_HW_RUN':'0','CPU_HW_BUILD_ID':expected,'CPU_HW_ATTEMPT':'identity_test','CPU_HW_STATE_NET':'state_probe','CPU_HW_PERF_NET':'perf_probe','CPU_HW_RESET_NET':'reset_probe'}
  for key,value in values.items():interp.setvar('env('+key+')',value)
  interp.eval((B/'hardware_session.tcl').read_text())
  self.assertEqual(programmed,[])
  return printed,exits
 def test_tcl_identity_guard_preserves_all_64_bits(self):
  for value in ['00000000deadbeef','5b9305e20eac5015','8000000000000001','ffffffffffffffff']:
   with self.subTest(build_id=value):
    printed,exits=self._run_tcl_identity_guard(value,value)
    self.assertEqual(exits,['0'])
    self.assertIn('HARDWARE_CAPTURE_COMPLETE attempt=identity_test',printed)
 def test_tcl_identity_guard_rejects_different_upper_half(self):
  printed,exits=self._run_tcl_identity_guard('11223344cafebabe','00000000cafebabe')
  self.assertEqual(exits[0],'1')
  self.assertIn('HARDWARE_SESSION_FAILED=Programmed build identity differs',printed)
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
