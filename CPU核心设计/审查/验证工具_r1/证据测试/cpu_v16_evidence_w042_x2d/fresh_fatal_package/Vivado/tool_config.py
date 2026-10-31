"""Tool resolution shared by maintained Python entry points; no machine path is required."""
from pathlib import Path
import argparse,json,os,shutil,sys
DEFAULT_CONFIG=Path(__file__).resolve().parents[1]/'tools.local.json'
def resolve_tools(vivado_bin=None,python=None,config=None):
 path=Path(config) if config is not None else DEFAULT_CONFIG
 values=json.loads(path.read_text(encoding='utf-8-sig')) if path.is_file() else {}
 found=shutil.which('vivado.bat') or shutil.which('vivado')
 candidate=vivado_bin or values.get('vivado_bin') or os.environ.get('CPU_VIVADO_BIN') or (str(Path(found).parent) if found else None)
 if not candidate:raise ValueError('Vivado is not configured: use --vivado-bin, tools.local.json, CPU_VIVADO_BIN or PATH')
 bins=Path(candidate).expanduser().resolve()
 missing=[n for n in ['vivado.bat','xvlog.bat','xelab.bat','xsim.bat'] if not (bins/n).is_file()]
 if missing:raise ValueError('Vivado bin is incomplete: '+', '.join(missing))
 py=python or values.get('python') or os.environ.get('CPU_PYTHON') or sys.executable
 executable=Path(shutil.which(str(py)) or py).expanduser().resolve()
 if not executable.is_file():raise ValueError('Python executable is missing: '+str(executable))
 return {'vivado_bin':str(bins),'python':str(executable),'config_file':str(path.resolve()) if path.exists() else None}
def add_tool_arguments(parser):
 parser.add_argument('--vivado-bin');parser.add_argument('--config',type=Path)
def main():
 p=argparse.ArgumentParser();add_tool_arguments(p);p.add_argument('--python');a=p.parse_args()
 print(json.dumps(resolve_tools(a.vivado_bin,a.python,a.config)))
if __name__=='__main__':main()
