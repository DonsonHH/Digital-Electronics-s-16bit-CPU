"""Fresh native file-boot system verification and OOC synthesis (not board closure)."""
from pathlib import Path
import argparse
import csv
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

SYSTEM = Path(__file__).resolve().parent
PACKAGE = SYSTEM.parent
V = PACKAGE / 'Vivado'
sys.path.insert(0, str(V))
from tool_config import add_tool_arguments, resolve_tools


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def validate_images(root):
    """Reject missing/truncated/stale images before launching native tools."""
    manifest = json.loads((root / 'programs/manifest.json').read_text(encoding='utf-8'))
    actual = {p.name for p in (root / 'programs').glob('*.mem')}
    if actual != set(manifest['input_sha256']):
        raise ValueError('System program inventory differs from manifest')
    for name, digest in manifest['input_sha256'].items():
        path = root / 'programs' / name
        if sha(path) != digest:
            raise ValueError('System program hash mismatch: ' + name)
        if name.endswith(('_im.mem', '_dm.mem')):
            words = path.read_text(encoding='ascii').splitlines()
            if len(words) != 256 or any(re.fullmatch(r'[0-9a-fA-F]{4}', w) is None for w in words):
                raise ValueError('System boot image must contain 256 four-hex-digit words: ' + name)
    if manifest['case_count'] != 11 or len(manifest['cases']) != 11 or manifest['normal_case_rows'] != 12:
        raise ValueError('Reviewed system case counts changed')
    return manifest


def check_simulation(log, attempt, label, manifest):
    if ('SYSTEM_ATTEMPT=' + attempt not in log or '$finish called at time' not in log
            or re.search(r'(?im)^Fatal:|^ERROR:', log)):
        raise ValueError('Native completion missing: ' + label)
    if label == 'memory':
        if len(re.findall(r'^MEMORY_FILE_CONTRACT_PASS checks=7$', log, re.M)) != 1:
            raise ValueError('Memory contract terminal missing')
        return []
    pattern = (r'^SYSTEM_CASE_PASS name=(\w+) epoch=(\d+) cycles=(\d+) wb=(\d+) stores=(\d+) '
               r'stalls=(\d+) redirects=(\d+) stop_pc=([0-9a-f]+) reason=(\d+) rf=([0-9a-f]+)$')
    rows = [dict(zip(['name', 'epoch', 'cycles', 'wb', 'stores', 'stalls', 'redirects', 'stop_pc', 'reason', 'rf'], m))
            for m in re.findall(pattern, log, re.M)]
    expected = {('all_ops', '0')} if label == 'mapped' else {
        (row['name'], str(epoch)) for row in manifest['cases']
        for epoch in ([0, 1] if row['reset_kind'] == 1 else [1] if row['reset_kind'] == 2 else [0])}
    if len(rows) != len(expected) or {(r['name'], r['epoch']) for r in rows} != expected:
        raise ValueError('System case rows are missing, repeated, or unexpected')
    by_name = {r['name']: r for r in manifest['cases']}
    for row in rows:
        case = by_name[row['name']]
        e = case['epochs'][int(row['epoch'])]
        for key in ['cycles', 'stalls', 'redirects']:
            if int(row[key]) != case[key]:
                raise ValueError('System cycle contract differs: ' + row['name'] + ' ' + key)
        if (int(row['wb']) != e['events'] or int(row['stores']) != e['stores']
                or int(row['reason']) != e['stop_reason'] or int(row['stop_pc'], 16) != e['stop_pc']
                or int(row['rf'], 16) != sum(v << (16*i) for i, v in enumerate(e['rf']))):
            raise ValueError('System architecture result differs: ' + row['name'])
    terminal = ('SYSTEM_MAPPED_PASS cases=1 boot=file_only' if label == 'mapped'
                else 'SYSTEM_PASS cases=11 boot=file_only reset_kinds=2 debug_injections=2')
    if len(re.findall('^' + re.escape(terminal) + '$', log, re.M)) != 1:
        raise ValueError('System terminal missing: ' + label)
    if label == 'system' and len(re.findall(r'^DEBUG_INJECTION_PASS checks=2 scope=controlled_simulation_only$', log, re.M)) != 1:
        raise ValueError('Controlled diagnostic injection terminal missing')
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    add_tool_arguments(parser)
    parser.add_argument('--test', choices=['memory', 'system', 'synthesis', 'project', 'all'], default='all')
    args = parser.parse_args()
    tools = resolve_tools(args.vivado_bin, python=sys.executable, config=args.config)
    work = Path(tempfile.mkdtemp(prefix='cpu_system_'))
    dest = PACKAGE / '验证' / work.name
    receipt = {'status': 'RUNNING', 'attempt_id': work.name,
               'scope': 'System preparation only, not P&R or board validation', 'test': args.test,
               'part': 'xc7z020clg484-1', 'tools': tools, 'started_at_utc': utc(), 'steps': []}
    env = {**os.environ, 'CPU_SYSTEM_ATTEMPT': work.name, 'PYTHONUTF8': '1', 'PYTHONDONTWRITEBYTECODE': '1'}

    def native(tool, label, arguments, timeout=600):
        command = work / (label + '.cmd')
        command.write_text('@echo off\ncall "' + str(Path(tools['vivado_bin']) / (tool + '.bat'))
                           + '" ' + arguments + '\nexit /b %errorlevel%\n', encoding='ascii')
        console = work / (label + '.console.log')
        step = {'tool': tool, 'label': label, 'command_sha256': sha(command), 'started_at_utc': utc()}
        receipt['steps'].append(step)
        process = None
        print('SYSTEM_NATIVE_START ' + label, flush=True)
        with console.open('wb') as output:
            try:
                process = subprocess.Popen([sys.executable, str(work / 'desktop_launch.py'),
                                            r'C:\Windows\System32\cmd.exe', '/d', '/c', str(command)],
                                           cwd=work, env=env, stdout=output, stderr=subprocess.STDOUT)
                step['launcher_pid'] = process.pid
                step['exit'] = process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                step['exit'] = 'timeout'
            finally:
                if process is not None and process.poll() is None:
                    process.kill()
                    process.wait()
                step.update(console_sha256=sha(console), ended_at_utc=utc())
        text = console.read_text(encoding='utf-8', errors='replace')
        if step.get('exit') != 0 or re.search(r'(?im)^ERROR:|^Fatal:|FATAL_ERROR|^CRITICAL WARNING:', text):
            raise RuntimeError('Native system step failed: ' + label + '; ' + str(work))
        print('SYSTEM_NATIVE_PASS ' + label, flush=True)

    def simulate(label, top, manifest):
        native('xelab', 'elab_' + label, top + ' -s ' + label + '_sim -debug typical -L unisims_ver')
        (work / (label + '.tcl')).write_text('puts "SYSTEM_ATTEMPT=$env(CPU_SYSTEM_ATTEMPT)"\nrun all\nquit\n', encoding='ascii')
        native('xsim', label, label + '_sim -tclbatch ' + label + '.tcl -log ' + label + '.log -wdb ' + label + '.wdb')
        rows = check_simulation((work / (label + '.log')).read_text(encoding='utf-8', errors='replace'), work.name, label, manifest)
        receipt[label] = {'status': 'PASS', 'case_rows': len(rows), 'log_sha256': sha(work / (label + '.log'))}
        if rows:
            with (work / (label + '_results.csv')).open('w', encoding='ascii', newline='') as output:
                writer = csv.DictWriter(output, fieldnames=list(rows[0]))
                writer.writeheader()
                writer.writerows(rows)

    try:
        for group in ['rtl', 'tb', 'programs', 'constraints']:
            shutil.copytree(SYSTEM / group, work / group)
        for source in (V / 'rtl').iterdir():
            if source.is_file():
                shutil.copy2(source, work / 'rtl' / source.name)
        shutil.copy2(V / 'desktop_launch.py', work / 'desktop_launch.py')
        for name in ['synth_system.tcl', 'create_project.tcl', 'run_system.py', 'generate_programs.py']:
            shutil.copy2(SYSTEM / name, work / name)
        manifest = validate_images(work)
        receipt['input_sha256'] = {p.relative_to(work).as_posix(): sha(p) for p in work.rglob('*') if p.is_file()}
        if args.test in ['memory', 'system', 'all']:
            sources = ' '.join('rtl/' + p.name for p in sorted((work / 'rtl').iterdir()) if p.suffix in ['.v', '.sv'])
            benches = ' '.join('tb/' + p.name for p in sorted((work / 'tb').glob('*.sv')))
            native('xvlog', 'compile', '--sv -i tb ' + sources + ' ' + benches)
            for label, top in [('memory', 'tb_memory_files'), ('system', 'tb_cpu_system')]:
                if args.test in [label, 'all']:
                    simulate(label, top, manifest)
        if args.test in ['synthesis', 'all']:
            native('vivado', 'synthesis', '-mode batch -source synth_system.tcl -log synthesis.log -nojournal')
            log = (work / 'synthesis.log').read_text(encoding='utf-8', errors='replace')
            if ('SYSTEM_SYNTHESIS_COMPLETE attempt=' + work.name not in log
                    or 'part=xc7z020clg484-1 period_ns=10.000' not in log):
                raise ValueError('System synthesis identity or period missing')
            reports = work / 'eda'
            summary = json.loads((reports / 'synthesis.json').read_text(encoding='ascii'))
            timing = (reports / 'timing.rpt').read_text(encoding='utf-8')
            match = re.search(r'WNS\(ns\)[^\n]*\n[^\n]*\n\s*([-\d.]+)\s+([-\d.]+)\s+(\d+)', timing)
            if not match or summary['part'] != receipt['part'] or summary['bram'] < 2:
                raise ValueError('System timing summary or two mapped IM/DM block RAMs missing')
            summary.update(wns_ns=float(match[1]), tns_ns=float(match[2]), failing_endpoints=int(match[3]),
                           reported_setup_met=float(match[1]) >= 0 and float(match[2]) == 0,
                           timing_closed=False, placed_and_routed=False, board_validated=False,
                           boot_image='programs/all_ops_im.mem', boot_image_sha256=sha(work / 'programs/all_ops_im.mem'),
                           data_image_sha256=sha(work / 'programs/all_ops_dm.mem'))
            (reports / 'synthesis.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
            receipt['synthesis'] = summary
            global_source = Path(tools['vivado_bin']).parent / 'data/verilog/src/glbl.v'
            native('xvlog', 'compile_mapped', '--sv -d POST_SYNTH -i tb eda/system_netlist.v tb/tb_cpu_system.sv "' + str(global_source) + '"')
            simulate('mapped', 'tb_cpu_system_mapped glbl', manifest)
        if args.test in ['project', 'all']:
            native('vivado', 'project', '-mode batch -source create_project.tcl -tclargs project verify -log project.log -nojournal')
            log = (work / 'project.log').read_text(encoding='utf-8', errors='replace')
            if 'SYSTEM_PROJECT_READY top=cpu_system part=xc7z020clg484-1 rtl=14' not in log:
                raise ValueError('System project source registration missing')
            check_simulation(log, work.name, 'system', manifest)
            receipt['project'] = {'status': 'PASS', 'source_registration_sha256': sha(work / 'project/source_registration.tsv'),
                                  'scope': 'Fresh Vivado project creation and behavioral launch; not implementation'}
        for name, digest in receipt['input_sha256'].items():
            if sha(work / name) != digest:
                raise ValueError('System inputs changed during native run: ' + name)
        receipt['output_sha256'] = {p.relative_to(work).as_posix(): sha(p) for p in work.rglob('*')
                                    if p.is_file() and p.suffix in ['.rpt', '.dcp', '.csv', '.wdb', '.vcd']}
        receipt['status'] = 'PASS'
    except BaseException as error:
        receipt['status'] = 'FAIL'
        receipt['error'] = str(error)
        raise
    finally:
        receipt['ended_at_utc'] = utc()
        (work / 'result.json').write_text(json.dumps(receipt, ensure_ascii=False, indent=2), encoding='utf-8')
        dest.parent.mkdir(exist_ok=True)
        shutil.copytree(work, dest, ignore=shutil.ignore_patterns('.Xil', 'xsim.dir', '__pycache__'))
        print('SYSTEM_RECORD=' + str(dest), flush=True)
    print('SYSTEM_PREPARATION_PASS record=' + str(dest), flush=True)


if __name__ == '__main__':
    main()
