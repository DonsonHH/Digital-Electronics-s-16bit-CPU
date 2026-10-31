"""Explicit single-file experiment overlays; production AC1 sources stay unchanged."""
from pathlib import Path
import hashlib,json,shutil
B=Path(__file__).resolve().parent;P=B.parent
CANDIDATES={'ac1':None,'forward_onehot':('operand_forward.v',)}
def apply_candidate(work,name):
 baseline=json.loads((P/'验证/cpu_system_n0r4buws/result.json').read_text(encoding='utf-8'))['input_sha256']
 for folder in [P/'Vivado/rtl',P/'系统/rtl']:
  for file in folder.iterdir():
   if file.is_file() and hashlib.sha256(file.read_bytes()).hexdigest()!=baseline['rtl/'+file.name]:raise ValueError('Stable production RTL differs: '+file.name)
 if name=='ac1':return {}
 folder=P/'实验/候选'/name;expected=set(CANDIDATES[name])
 actual={p.name for p in folder.iterdir() if p.suffix in ['.v','.sv']}
 if actual!=expected:raise ValueError('Unreviewed candidate overlay inventory')
 for file in expected:shutil.copy2(folder/file,Path(work)/'rtl'/file)
 return {file:hashlib.sha256((folder/file).read_bytes()).hexdigest() for file in sorted(expected)}
