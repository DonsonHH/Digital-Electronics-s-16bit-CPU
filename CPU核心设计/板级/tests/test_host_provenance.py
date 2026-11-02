"""Future captures preserve host rules and runtime identity without accessing hardware."""
from pathlib import Path
from unittest.mock import patch
import json,sys,tempfile,unittest
B=Path(__file__).resolve().parents[1];sys.path.insert(0,str(B))
from run_hardware import P,archive_host_context,native_versions_from_log,sha

class HostProvenance(unittest.TestCase):
 def test_source_archive_is_complete_and_independent(self):
  with tempfile.TemporaryDirectory(prefix='cpu_host_context_')as tmp:
   work=Path(tmp);context=archive_host_context(work,{'vivado_bin':'test-vivado/bin'})
   self.assertEqual(set(context['source_sha256']),{'板级/run_hardware.py','板级/probe_codec.py','板级/verify_board_results.py','Vivado/tool_config.py','Vivado/verification/isa_reference.py'})
   self.assertEqual(json.loads((work/'host_context.json').read_text(encoding='utf-8')),context)
   self.assertEqual(context['python_executable'],sys.executable)
   for name,digest in context['source_sha256'].items():
    self.assertEqual(sha(work/'host_sources'/name),digest);self.assertEqual(sha(P/name),digest)
   name='板级/probe_codec.py';copy=work/'host_sources'/name;copy.write_bytes(copy.read_bytes()+b'\n')
   self.assertEqual(sha(P/name),context['source_sha256'][name]);self.assertNotEqual(sha(copy),context['source_sha256'][name])
 def test_missing_git_is_explicit_not_a_fabricated_clean_commit(self):
  with tempfile.TemporaryDirectory(prefix='cpu_host_no_git_')as tmp,patch('run_hardware.subprocess.run',side_effect=FileNotFoundError):
   context=archive_host_context(Path(tmp),{'vivado_bin':'test-vivado/bin'})
   self.assertFalse(context['git']['available']);self.assertIsNone(context['git']['commit']);self.assertIsNone(context['git']['tracked_sources_dirty'])
 def test_native_versions_require_exact_runtime_markers(self):
  text='HARDWARE_VIVADO_VERSION=2025.2\r\nHARDWARE_TCL_VERSION=8.6.12\r\n'
  self.assertEqual(native_versions_from_log(text),{'vivado':'2025.2','tcl':'8.6.12'})
  for invalid in ['',text.replace('2025.2','2026.1'),text+'HARDWARE_TCL_VERSION=8.6.12\n']:
   with self.subTest(log=invalid),self.assertRaises(ValueError):native_versions_from_log(invalid)
if __name__=='__main__':unittest.main()
