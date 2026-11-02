"""Source-only, writable GUI packages with identical simulation/synthesis images."""
from pathlib import Path
import importlib.util
import hashlib
import json
import re
import shutil
import sys
import tempfile
import argparse

B=Path(__file__).resolve().parent
CORE=B.parents[1]/'CPU核心设计'
OUT=B.parent/'Vivado'
sys.path.insert(0,str(CORE/'板级'))
from benchmark_programs import PROGRAMS,prepare_selected


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    global OUT
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path);args=parser.parse_args()
    OUT=args.output.resolve()if args.output else OUT
    if (OUT/'source_manifest.json').exists():raise ValueError('Source package exists; use --output for a fresh package')
    for n in ['rtl','tb','benchmarks','constraints','tools']:(OUT/n).mkdir(parents=True,exist_ok=True)
    mapping={}
    for p in list((CORE/'Vivado/rtl').iterdir())+[CORE/'系统/rtl/cpu_system.sv',CORE/'板级/rtl/ees331_application.sv']:
        if p.is_file():shutil.copy2(p,OUT/'rtl'/p.name);mapping['rtl/'+p.name]=p.relative_to(CORE.parent).as_posix()
    for p in [CORE/'Vivado/desktop_launch.py']:
        shutil.copy2(p,OUT/'tools'/p.name);mapping['tools/'+p.name]=p.relative_to(CORE.parent).as_posix()
    for n in ['ees331.xdc','human_io.xdc']:
        shutil.copy2(CORE/'板级/constraints'/n,OUT/'constraints'/n);mapping['constraints/'+n]='CPU核心设计/板级/constraints/'+n
    shutil.copy2(CORE/'系统/constraints/system_ooc.xdc',OUT/'constraints/cpu_clock.xdc')
    mapping['constraints/cpu_clock.xdc']='CPU核心设计/系统/constraints/system_ooc.xdc'
    spec=importlib.util.spec_from_file_location('soc_ports',r'C:/Users/Donson/.codex/skills/soc-integrate/scripts/soc_integrate.py')
    soc=importlib.util.module_from_spec(spec);spec.loader.exec_module(soc)
    module=next(m for m in soc.extract_modules(CORE/'系统/rtl/cpu_system.sv')if m.name=='cpu_system')
    assert len(module.ports)==34
    original_params=list(module.params)
    module.params=[(name,'"dut_im.mem"'if name=='IM_INIT_FILE'else'"dut_dm.mem"',width)for name,value,width in module.params]
    wrapper='`timescale 1ns/1ps\n// File-boot configuration only. CPU logic and cycle contract are unchanged.\n'+soc.generate_wrapper(module,'pre6_cpu_top')+'\n'
    (OUT/'rtl/pre6_cpu_top.v').write_text(wrapper,encoding='utf-8')
    generated=soc.extract_modules(OUT/'rtl/pre6_cpu_top.v')[0]
    assert generated.ports==module.ports
    portmap={'generator':'soc-integrate generate_wrapper','source':'CPU核心设计/系统/rtl/cpu_system.sv','source_sha256':sha(CORE/'系统/rtl/cpu_system.sv'),
             'ports':module.ports,'mappings':{name:name for direction,width,name in module.ports},
             'parameters':{'IM_INIT_FILE':'dut_im.mem','DM_INIT_FILE':'dut_dm.mem'},'original_parameters':original_params}
    (OUT/'rtl/pre6_cpu_top.port-map.json').write_text(json.dumps(portmap,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    # EES-331 glue keeps the original pins, BUFG, reset and VIO connectivity.
    board=(CORE/'板级/rtl/ees331_top.sv').read_text(encoding='utf-8')
    board=board.replace('module ees331_top #(parameter [63:0] BUILD_ID=64\'d0)',"module pre6_ees331_top #(parameter [63:0] BUILD_ID=64'd0, parameter RELEASE_BITS=21)")
    board=board.replace('ees331_application #(.BUILD_ID(BUILD_ID))',
                        'ees331_application #(.IM_INIT_FILE("dut_im.mem"),.DM_INIT_FILE("dut_dm.mem"),.RELEASE_BITS(RELEASE_BITS),.BUILD_ID(BUILD_ID))')
    assert 'module pre6_ees331_top'in board and 'IM_INIT_FILE("dut_im.mem")'in board
    (OUT/'rtl/pre6_ees331_top.sv').write_text(board,encoding='utf-8')
    # Keep the reviewed per-edge checker; change only its DUT wrapper and image locations.
    source=(CORE/'系统/tb/tb_cpu_system.sv').read_text(encoding='utf-8')
    checker=source[:source.index('\nendmodule')+len('\nendmodule')]
    checker=checker.replace('module system_checker','module pre6_checker').replace('programs/','')
    checker,n=re.subn(r'`ifdef POST_SYNTH\s+cpu_system dut\(\s+`else\s+cpu_system #\(.+?\) dut\(\s+`endif','pre6_cpu_top dut(',checker,flags=re.S)
    assert n==1
    checker=checker.replace('integer epoch=0,cycles=0','integer trace;integer epoch=0,cycles=0')
    trace_header='''
 initial begin
  trace=$fopen("cpu_trace.csv","w");if(!trace)$fatal(1,"PRE6_TRACE_OPEN");
  $fdisplay(trace,"time_ps,cycle,wb_valid,wb_pc,rf_we,wb_rd,wb_data,z_we,cv_we,dm_we,dm_addr,dm_data,stall,redirect");
 end
'''
    checker=checker.replace(' reg[63:0] e0',trace_header+' reg[63:0] e0')
    checker=checker.replace('cycles=cycles+1;',
       'cycles=cycles+1;\n   $fdisplay(trace,"%0t,%0d,%b,%h,%b,%0d,%h,%b,%b,%b,%h,%h,%b,%b",$time,cycles,wb_valid,pc,rw,rd,data,zw,cvw,mem_we,mem_addr,mem_data,stall,redirect);')
    top='''
module tb_pre6_cpu;
 `include "selected_expected.svh"
 reg clk=0;always #5 clk=~clk;wire done;
 pre6_checker #(.LABEL(PROGRAM),.E0("selected_events.mem"),.E1("selected_events.mem"),
 .S0("selected_stores.mem"),.S1("selected_stores.mem"),.N0(EXPECTED_N),.N1(EXPECTED_N),
 .STORES0(EXPECTED_STORES),.STORES1(EXPECTED_STORES),.CYCLES(EXPECTED_CYCLES),
 .STALLS(EXPECTED_STALLS),.REDIRECTS(EXPECTED_REDIRECTS),.RF0(EXPECTED_RF),.RF1(EXPECTED_RF),
 .FLAGS0(EXPECTED_FLAGS),.FLAGS1(EXPECTED_FLAGS),.STOP_PC(EXPECTED_PC)) check(.clk(clk),.done(done));
 initial begin wait(done);$display("PRE6_CPU_PASS program=%s cycles=%0d completed=%0d stalls=%0d redirects=%0d stores=%0d",PROGRAM,EXPECTED_CYCLES,EXPECTED_N,EXPECTED_STALLS,EXPECTED_REDIRECTS,EXPECTED_STORES);$finish;end
 initial begin $dumpfile("pre6_cpu.vcd");$dumpvars(0,tb_pre6_cpu);end
endmodule
'''
    (OUT/'tb/tb_pre6_cpu.sv').write_text(checker+'\n'+top,encoding='utf-8')
    expected={}
    for name in PROGRAMS:
        work=Path(tempfile.mkdtemp(prefix='pre6_r3_images_'));(work/'programs').mkdir();(work/'tb').mkdir()
        values,gold=prepare_selected(work,CORE/'系统',name,'ac1');dest=OUT/'benchmarks'/name;dest.mkdir(exist_ok=True)
        for p in (work/'programs').iterdir():shutil.copy2(p,dest/p.name)
        shutil.copy2(work/'tb/selected_expected.svh',dest/'selected_expected.svh')
        expected[name]={**values,'rf':gold['rf'],'flags':gold['flags'],'stop_pc':gold['events'][-1]['pc']}
    boardtb=(CORE/'板级/tb/tb_selected_program.sv').read_text(encoding='utf-8').replace('module tb_selected_program','module tb_pre6_board').replace('programs/','')
    before='ees331_application #(.RELEASE_BITS(3),.BUILD_ID(64\'habcdef0123456789)) dut(.clk(clk),.reset_btn_n(btn_n),.debug_reset(reset_request),.state_probe(state),.perf_probe(perf),.event_probe(ev),.led(led),.core_reset(rst));'
    after='''pre6_ees331_top #(.RELEASE_BITS(3),.BUILD_ID(64'habcdef0123456789)) dut(.clk100(clk),.reset_btn_n(btn_n),.led(led));
 assign state=dut.state_probe;assign perf=dut.perf_probe;
 assign ev=dut.application_i.event_probe;assign rst=dut.application_i.core_reset;
 initial begin force dut.debug_reset=reset_request;end'''
    assert before in boardtb;boardtb=boardtb.replace(before,after)
    boardtb=boardtb.replace('BOARD_SELECTED_PASS','PRE6_BOARD_SIM_PASS')
    (OUT/'tb/tb_pre6_board.sv').write_text(boardtb,encoding='utf-8')
    manifest={'CPU':'v1.6','ISA':'v1.5','implementation':'AC1','baseline_commit':'9475f210c7e567cb41f3856ff3bcebc6611ac991','part':'xc7z020clg484-1',
              'source_mapping':mapping,'programs':expected,'ports_snapshot':portmap,
              'adaptations':['CPU wrapper fixes only initialization filenames; original CPU and system RTL remain exact copies.',
                             'Board wrapper preserves pin/reset/VIO wiring and supplies the same flat MEM filenames.',
                             'Primary checker is the reviewed system checker with the DUT replaced by a pin-compatible wrapper.'],
              'sha256':{p.relative_to(OUT).as_posix():sha(p)for group in ['rtl','tb','benchmarks','constraints','tools']for p in (OUT/group).rglob('*')if p.is_file()}}
    (OUT/'source_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('R3_SOURCE_PACKAGE_READY ports=34 frozen_RTL=15 generated_wrappers=2')


if __name__=='__main__':main()
