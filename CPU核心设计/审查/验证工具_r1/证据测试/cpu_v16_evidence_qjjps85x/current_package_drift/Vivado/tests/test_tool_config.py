from pathlib import Path
import importlib,json,os,sys,tempfile,unittest
from unittest.mock import patch
BASE=Path(__file__).resolve().parents[1];sys.path.insert(0,str(BASE))
class ToolConfiguration(unittest.TestCase):
 def test_cli_then_project_then_environment_and_missing_fails(self):
  config=importlib.import_module('tool_config')
  with tempfile.TemporaryDirectory(prefix='cpu_tools_') as td:
   root=Path(td);a=root/'cli';b=root/'project';c=root/'env'
   for p in [a,b,c]:
    p.mkdir()
    for n in ['vivado.bat','xvlog.bat','xelab.bat','xsim.bat']:(p/n).touch()
   local=root/'tools.json';local.write_text(json.dumps({'vivado_bin':str(b),'python':sys.executable}))
   with patch.dict(os.environ,{'CPU_VIVADO_BIN':str(c)},clear=True):
    self.assertEqual(config.resolve_tools(vivado_bin=str(a),config=local)['vivado_bin'],str(a.resolve()))
    self.assertEqual(config.resolve_tools(config=local)['vivado_bin'],str(b.resolve()))
    with patch.object(config,'DEFAULT_CONFIG',root/'absent'):
     self.assertEqual(config.resolve_tools()['vivado_bin'],str(c.resolve()))
    with self.assertRaises(ValueError):config.resolve_tools(config=root/'explicit_missing')
   with patch.dict(os.environ,{},clear=True):
    with patch.object(config,'DEFAULT_CONFIG',root/'absent'):
     with self.assertRaises(ValueError):config.resolve_tools()
if __name__=='__main__':unittest.main()
