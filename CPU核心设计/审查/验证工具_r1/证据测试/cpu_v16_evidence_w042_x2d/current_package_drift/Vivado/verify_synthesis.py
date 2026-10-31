"""Bind fresh OOC results to executed sources and reports, never claim board closure."""
from pathlib import Path
import argparse, hashlib, json, re
from datetime import datetime, timezone


def require(condition, detail):
    if not condition:
        raise ValueError(detail)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def matching(pattern, text, detail):
    match = re.search(pattern, text, re.M)
    require(match is not None, detail)
    return match


parser = argparse.ArgumentParser()
parser.add_argument('--run', type=Path, required=True)
parser.add_argument('--package', type=Path, required=True)
parser.add_argument('--archive-relative', required=True)
args = parser.parse_args()
run, package = args.run.resolve(), args.package.resolve()
require(not (run / 'synthesis_results.json').exists(), 'Fresh run required: existing synthesis receipt must not be overwritten')
archive_relative = Path(args.archive_relative)
require(not archive_relative.is_absolute() and '..' not in archive_relative.parts,
        'Archive must remain within the package')
require(archive_relative.parts and archive_relative.parts[0] == 'Vivado', 'Unexpected synthesis archive root')
log = (run / 'synthesis.log').read_text(encoding='utf-8', errors='replace')
require(not re.search(r'(?im)ERROR:|CRITICAL WARNING:|Fatal:', log), 'Native synthesis error or critical warning')
marker = matching(r'^CPU_V16_SYNTHESIS_COMPLETE tool=([\d.]+) part=(\S+) constraint_ns=([\d.]+) mode=OOC timing_closure_not_claimed$', log,
                  'Native synthesis completion marker missing')
version, part, period = marker[1], marker[2], float(marker[3])
require(part == 'xc7z020clg484-1' and period == 10, 'Target part or clock contract differs')
require(matching(r'^# Vivado v([\d.]+) \(64-bit\)', log, 'Native tool header missing')[1] == version,
        'Native tool header differs from completion marker')
# Loading after synth_design constrains reporting, not synthesis optimization.
require(log.index('# read_xdc constraints/core_ooc.xdc') < log.index('# synth_design -top datapath_core'),
        'Clock was not loaded before synthesis')
rtl = {}
for source in sorted((package / 'Vivado/rtl').iterdir()):
    if source.is_file():
        require(source.read_bytes() == (run / 'rtl' / source.name).read_bytes(), f'RTL drift: {source.name}')
        rtl[source.name] = sha(source)
require(len(rtl) == 13, 'Unexpected production RTL inventory')
scripts = {}
for name in ('run_synthesis.ps1', 'synth_ooc.tcl', 'run_synth.cmd', 'desktop_launch.py', 'verify_synthesis.py'):
    source = package / 'Vivado' / name
    require(source.read_bytes() == (run / name).read_bytes(), f'Synthesis driver drift: {name}')
    scripts[name] = sha(source)
xdc = package / 'Vivado/constraints/core_ooc.xdc'
require(xdc.read_bytes() == (run / 'constraints/core_ooc.xdc').read_bytes(), 'Constraint drift')
require(len(re.findall(r'^\s*create_clock\b', xdc.read_text(), re.M)) == 1, 'Unexpected number of primary clocks')
files = ('utilization.rpt', 'post_synth_timing.rpt', 'core_synth.dcp', 'core_netlist.v')
for name in files:
    require((run / 'eda' / name).is_file() and (run / 'eda' / name).stat().st_size > 0,
            f'Synthesis artifact missing or empty: {name}')
util = (run / 'eda/utilization.rpt').read_text()
timing = (run / 'eda/post_synth_timing.rpt').read_text()
for report in (util, timing):
    require(matching(r'Tool Version\s*: Vivado v\.([\d.]+)', report, 'Report tool version missing')[1] == version,
            'Report tool version mismatch')
    require('Design State : Synthesized' in report, 'Report is not post-synthesis')
    require('Design       : datapath_core' in report, 'Unexpected top design')
require(f'Device       : {part}' in util, 'Utilization report part differs')
require('Device       : 7z020-clg484' in timing and 'Speed File   : -1 ' in timing, 'Timing report device or speed differs')
row = matching(r'\| datapath_core\s*\|\s*\(top\)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)', util,
               'Top utilization row missing')
summary = matching(r'WNS\(ns\)[^\n]*\n[^\n]*\n\s*([-\d.]+)\s+([-\d.]+)\s+(\d+)', timing, 'Setup summary missing')
wns, tns, endpoints = float(summary[1]), float(summary[2]), int(summary[3])
input_missing = int(matching(r'no_input_delay \((\d+)\)', timing, 'Input-delay coverage missing')[1])
output_missing = int(matching(r'no_output_delay \((\d+)\)', timing, 'Output-delay coverage missing')[1])
require(float(matching(r'^core_clk\s+\{[^}]+\}\s+([\d.]+)\s+', timing, 'Clock summary missing')[1]) == period,
        'Timing report clock period differs')
report = {
    'status': 'completed', 'spec_version': '1.6',
    'completed_at_utc': datetime.now(timezone.utc).isoformat(), 'runtime': str(run),
    'tool': 'Vivado ' + version, 'part': part,
    'scope': 'core-only post-synthesis OOC estimate; not a board system or place-and-route result',
    'reports_relative': archive_relative.as_posix(), 'clock_constraint_ns': period,
    'clock_loaded_before_synthesis': True,
    'wns_ns': wns, 'tns_ns': tns, 'failing_endpoints': endpoints,
    'lut': int(row[1]), 'ff': int(row[5]),
    'missing_input_delay_ports': input_missing, 'missing_output_delay_ports': output_missing,
    'rtl_sha256': rtl, 'xdc_sha256': sha(xdc), 'script_sha256': scripts,
    'evidence_sha256': {name: sha(run / 'eda' / name) for name in files},
    'reported_setup_met': wns >= 0 and tns == 0 and endpoints == 0,
    # Core-only OOC estimates are not final timing closure.
    'timing_constraints_met': False, 'timing_closed': False,
    'placed_and_routed': False, 'board_validated': False,
}
report['evidence_sha256']['synthesis.log'] = sha(run / 'synthesis.log')
(run / 'synthesis_results.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'CPU_V16_SYNTHESIS_CHECKED LUT={report["lut"]} FF={report["ff"]} WNS={wns} TNS={tns} scope=post_synthesis_not_board')
