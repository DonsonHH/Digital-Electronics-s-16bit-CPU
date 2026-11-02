"""Publish unchanged AC1 sources and executable classroom verification inputs."""
from pathlib import Path
import hashlib
import json
import shutil
import sys
import tempfile

B = Path(__file__).resolve().parent
DEST = B.parent / 'Vivado'
CORE = B.parents[1] / 'CPU核心设计'
sys.path.insert(0, str(CORE / '板级'))
from benchmark_programs import PROGRAMS, prepare_selected


def main():
    for name in ['rtl', 'tb', 'programs', 'benchmarks', 'constraints', 'tools']:
        (DEST / name).mkdir(parents=True, exist_ok=True)
    copied = {}
    groups = [(CORE/'Vivado/rtl', DEST/'rtl'), (CORE/'系统/rtl', DEST/'rtl'),
              (CORE/'系统/tb', DEST/'tb'), (CORE/'系统/programs', DEST/'programs')]
    for src, target in groups:
        for p in src.iterdir():
            if p.is_file():
                shutil.copy2(p, target/p.name)
                copied[(target/p.name).relative_to(DEST).as_posix()] = p.relative_to(CORE.parent).as_posix()
    for source, target in [(CORE/'板级/rtl/ees331_application.sv', DEST/'rtl/ees331_application.sv'),
                           (CORE/'板级/tb/tb_selected_program.sv', DEST/'tb/tb_selected_program.sv'),
                           (CORE/'系统/constraints/system_ooc.xdc', DEST/'constraints/system_ooc.xdc'),
                           (CORE/'Vivado/desktop_launch.py', DEST/'tools/desktop_launch.py')]:
        shutil.copy2(source, target)
        copied[target.relative_to(DEST).as_posix()] = source.relative_to(CORE.parent).as_posix()
    expected = {}
    for program in PROGRAMS:
        w = Path(tempfile.mkdtemp(prefix='pre6_inputs_'))
        (w/'tb').mkdir(); (w/'programs').mkdir()
        exp, gold = prepare_selected(w, CORE/'系统', program, 'ac1')
        target = DEST/'benchmarks'/program
        target.mkdir(exist_ok=True)
        for p in (w/'programs').iterdir():
            shutil.copy2(p, target/p.name)
        shutil.copy2(w/'tb/selected_expected.svh', target/'selected_expected.svh')
        expected[program] = {**exp, 'RF':gold['rf'], 'flags':gold['flags'], 'stop_pc':gold['events'][-1]['pc']}
    manifest = {'baseline_commit':'9475f210c7e567cb41f3856ff3bcebc6611ac991',
                'CPU':'v1.6', 'ISA':'v1.5', 'implementation':'AC1', 'part':'xc7z020clg484-1',
                'production_rtl_count':13, 'system_rtl_count':1, 'application_rtl_count':1,
                'source_mapping':copied, 'programs':expected,
                'sha256':{p.relative_to(DEST).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
                          for group in ['rtl','tb','programs','benchmarks','constraints','tools']
                          for p in (DEST/group).rglob('*') if p.is_file()}}
    (DEST/'source_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('PRE6_VIVADO_INPUTS_READY',len(manifest['sha256']), 'files; 15 RTL')


if __name__ == '__main__':
    main()
