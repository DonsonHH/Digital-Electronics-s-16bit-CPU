"""Validate the isolated WB/MEM candidate against ISA events and its new cycle contract."""
from pathlib import Path
import argparse,csv,hashlib,json,re,shutil,sys,tempfile,uuid

E=Path(__file__).resolve().parent;P=E.parent;V=P/'Vivado';B=P/'板级'
sys.path[:0]=[str(V),str(B)]
from tool_config import add_tool_arguments,resolve_tools
from generate_independent import generate,write_case
from run_independent import load_case_package
from verification.isa_reference import ins,oracle
from candidate_registry import apply_candidate
import negative_test_support as native

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

PORTS='datapath_core dut(.clk(clk),.rst(rst),.im_addr(im_addr),.im_en(im_en),.im_dout(im_dout),.dm_addr(dm_addr),.dm_en(dm_en),.dm_we(dm_we),.dm_din(dm_din),.dm_dout(dm_dout),.halted(halted),.fault(fault));'

CHECKS=r'''
  integer candidate_late=0,candidate_pending=0,candidate_base_stalls=0;
  task automatic candidate_checks;
    reg expected_interlock,use_d,use_s;
    reg [3:0] opc;
    begin
      // This predicate is decoded independently from the raw ISA word.
      // STR Rd is consumed in MEM; its Rs address is still consumed in EX.
      expected_interlock=0;use_d=0;use_s=0;opc=dut.d_inst[15:12];
      case(opc)
        0,8,9:use_s=1;
        2,3,4,6,10:begin use_d=1;use_s=1;end
        5,7:use_d=1;
        default:begin end
      endcase
      if(!rst && dut.x_valid && !dut.x_fault && dut.x_mem_read && dut.d_valid && !dut.d_fault)
        expected_interlock=(use_d && dut.d_inst[11:10]==dut.x_rd)
                          ||(use_s && dut.d_inst[9:8]==dut.x_rd);
      if(!rst && dut.load_use!==expected_interlock)$fatal(1,"WB_HDU_RAW_ISA %s",label);
      if(dut.x_store_late===1'b1 && !(dut.x_valid && !dut.x_fault && dut.x_mem_write
          && dut.blocked_rd && !dut.blocked_rs && dut.m_valid && dut.m_mem_read
          && !dut.m_fault && dut.m_rd==dut.x_rd))$fatal(1,"WB_BAD_LATE_QUALIFIER");
      if(dut.m_store_pending===1'b1 && !(dut.m_valid && !dut.m_fault && dut.m_mem_write))
        $fatal(1,"WB_PENDING_SLOT");
      if(dm_we===1'b1 && dut.m_store_pending===1'b1)begin
        if(!(dut.w_valid && !dut.w_fault && dut.w_reg_write && dut.w_wb_sel
             && !dut.w_store && !dut.w_halt && dut.w_rd==dut.m_rd)
             || dm_din!==dut.wb_data)$fatal(1,"WB_PENDING_DATA");
      end
      if(dut.m_store_data_fault===1'b1 && {dm_en,dm_we}!==0)$fatal(1,"WB_MISSING_DATA_WRITE");
      if(rst && {im_en,dm_en,dm_we,dut.rf_we,dut.z_we,dut.cv_we}!==0)$fatal(1,"WB_RESET_GATES");
      if(dut.stop_valid && dut.stop_pc_valid)begin
        if(halted && dut.stop_reason!==1)$fatal(1,"WB_HALT_REASON");
        if(fault)begin
          if(dut.stop_pc>255)begin if(dut.stop_reason!==3)$fatal(1,"WB_FETCH_REASON");end
          else case(im[dut.stop_pc][15:12])
            11,15:if(dut.stop_reason!==2)$fatal(1,"WB_OPCODE_REASON");
            8,9:if(dut.stop_reason!==4)$fatal(1,"WB_ADDRESS_REASON");
            default:$fatal(1,"WB_UNEXPECTED_ISA_FAULT");
          endcase
        end
      end
    end
  endtask
'''

def adapted_checker(frozen=False):
    text=(V/'verification/tb_adversarial.sv').read_text(encoding='utf-8')
    substitutions={
      'datapath_core dut(.*);':PORTS,
      '  task automatic known_controls;':CHECKS+'\n  task automatic known_controls;',
      '      if($isunknown({im_en':'      candidate_checks();\n      if($isunknown({im_en',
      '      if(pre_stall)stalls++;':'      if(dut.x_store_late)candidate_late++;\n      if(dm_we && dut.m_store_pending)candidate_pending++;\n      if(pre_stall && dut.d_inst[15:12]==9)candidate_base_stalls++;\n      if(pre_stall)stalls++;',
      '      for(integer k=0;k<4;k++)if(dut.u_rf.regs[k]!==0)':
        '      if(dut.m_store_pending!==0)$fatal(1,"WB_RESET_PENDING");\n      for(integer k=0;k<4;k++)if(dut.u_rf.regs[k]!==0)',
      '    $fclose(fd);$fclose(tracefd);$finish;':
        '    if(candidate_late<1 || candidate_pending<1)$fatal(1,"WB_MISSING_PENDING_WITNESS");\n    $display("WB_CANDIDATE_WITNESSES late=%0d pending_stores=%0d base_stalls=%0d",candidate_late,candidate_pending,candidate_base_stalls);\n    $fclose(fd);$fclose(tracefd);$finish;'
    }
    if frozen:
        # The frozen oracle/config bytes stay untouched. Only these two OLD
        # timing predicates are inapplicable. New cycle/control assertions above
        # remain active; the separate directed suite has exact new cycle counts.
        for marker in ['      if(reset_kind==0 && expect_cycles>=0 && cycles!=expect_cycles)$fatal(1,"AUDIT_CYCLES %s got=%0d expected=%0d",label,cycles,expect_cycles);',
                       '      if(reset_kind==0 && expect_stalls>=0 && stalls!=expect_stalls)$fatal(1,"AUDIT_STALLS %s got=%0d expected=%0d",label,stalls,expect_stalls);']:
            substitutions[marker]='      // Baseline-only timing expectation; checked by the candidate cycle contract.'
    else:
        substitutions['if(total!=CASES||reset_total!=10)']='if(total!=CASES||reset_total!=0)'
    for old,new in substitutions.items():
        if text.count(old)!=1:raise ValueError('Reviewed checker seam changed: '+old[:70])
        text=text.replace(old,new)
    return text

def directed_cases():
    cases=[]
    def add(label,words,rf=None,memory=None,stalls=0,redirects=0):
        image=list(words)+[0xb000]*(256-len(words));dm=[0]*256
        dm[32]=33;dm[33]=0xbeef
        if memory:
            for addr,value in memory.items():dm[addr]=value
        expected=oracle(image,dm,rf or [32]*4)
        normal=bool(expected['halt'])
        cases.append(dict(label=label,image=image,initial_dm=dm,initial_rf=rf or [32]*4,
                          initial_flags=[0]*3,expected=expected,reset=0,stalls=stalls if normal else -1,
                          cycles=len(expected['events'])+4+stalls+2*redirects if normal else -1))
    # All register identities, including writable R0, Rd==Rs, both-source
    # dependency, gap-1 WB forwarding and gap-2 WB->ID bypass.
    for prod in range(4):
      for d in range(4):
       for s in range(4):
        for gap in range(3):
          padding=[ins(1,(prod+2)%4,b=32)]*gap
          load=ins(8,prod,(prod+1)%4)
          add(f'STR_P{prod}_D{d}_S{s}_G{gap}',[load]+padding+[ins(9,d,s,1),ins(14)],stalls=int(gap==0 and s==prod))
          for op in [0,2,3,4,5,6,7,8,10]:
            use_d=op in [2,3,4,5,6,7,10];use_s=op in [0,2,3,4,6,8,10]
            dependent=(use_d and d==prod)or(use_s and s==prod)
            add(f'LOAD_P{prod}_OP{op}_D{d}_S{s}_G{gap}',[load]+padding+[ins(op,d,s,1 if op in [5,7] else 0),ins(14)],stalls=int(gap==0 and dependent))
    for prod in range(4):
      base=(prod+1)%4
      add(f'NEW_LOAD_BLOCKS_OLD_W_R{prod}',[ins(1,prod,b=17),ins(8,prod,base),ins(9,prod,base,1),ins(14)])
      add(f'NEW_ALU_OVERRIDES_LOAD_R{prod}',[ins(8,prod,base),ins(1,prod,b=34),ins(9,prod,base,1),ins(14)])
      add(f'TWO_STORES_R{prod}',[ins(8,prod,base),ins(9,prod,base,1),ins(9,prod,base,2),ins(14)])
      add(f'STORE_THEN_SAME_ADDRESS_LOAD_R{prod}',[ins(8,prod,base),ins(9,prod,base,1),ins(8,prod,base,1),ins(14)])
    add('WRONG_PATH_LOAD_STORE',[ins(10,0,0),ins(13,b=2),ins(8,0,3),ins(9,0,3,1),ins(14)],redirects=1)
    add('LOAD_FAULT_KILLS_YOUNG_STR',[ins(1,0,b=17),ins(8,0,3,1),ins(9,0,2),ins(14)],rf=[32,32,32,255])
    add('PENDING_STR_ADDRESS_FAULT',[ins(8,0,2),ins(9,0,3,1),ins(14)],rf=[32,32,32,255])
    add('OLDER_PENDING_STR_BEFORE_OPCODE_FAULT',[ins(8,0,3),ins(9,0,3,1),ins(11),ins(9,1,3,2)])
    add('PENDING_STR_BEFORE_HALT',[ins(8,0,3),ins(9,0,3,1),ins(14),ins(9,1,3,2)])
    # Fixed-seed structured stress: independent oracle gives every architectural
    # event, not just a checksum. Base R3 stays 32; target/data registers vary.
    import random
    rng=random.Random(0x57424d31)
    for k in range(64):
      words=[];stalls=0
      for _ in range(16):
        d=rng.randrange(3);offset=rng.randrange(8);choice=rng.randrange(4)
        words.append(ins(8,d,3,offset))
        if choice==0:words.append(ins(9,d,3,offset+16))
        elif choice==1:words.append(ins(5,d,b=rng.randrange(256)));stalls+=1
        elif choice==2:words+=[ins(1,d,b=rng.randrange(256)),ins(9,d,3,offset+16)]
        else:words+=[ins(10,d,d),ins(9,d,3,offset+16)];stalls+=1
      words.append(ins(14));add('SEEDED_STRESS_'+str(k),words,stalls=stalls,memory={32+i:rng.randrange(65536)for i in range(8)})
    return cases

def write_directed(root):
    root.mkdir();cases=directed_cases();config=[]
    for i,c in enumerate(cases):
        prefix=f'candidate_{i:04d}';write_case(c,prefix,root)
        config.append(f'{i}:begin label="{c["label"]}";prefix="{prefix}";token_count={len(c["expected"]["events"])};store_count={len(c["expected"]["stores"])};initial_flags=0;expect_cycles={c["cycles"]};expect_stalls={c["stalls"]};reset_kind=0;end')
    (root/'case_count.svh').write_text(f'localparam CASES = {len(cases)};\n',encoding='ascii')
    (root/'case_config.svh').write_text('case(case_id)\n'+'\n'.join(config)+'\ndefault:$fatal(1,"BAD_CASE_ID");\nendcase\n',encoding='ascii')
    (root/'cases.json').write_text(json.dumps(cases,indent=2),encoding='utf-8')
    return cases

def execute_case_suite(root,source,rtl,tools,frozen=False):
    root.mkdir();shutil.copytree(rtl,root/'rtl');shutil.copytree(source/'programs',root/'programs')
    for name in ['case_count.svh','case_config.svh']:shutil.copy2(source/name,root/name)
    shutil.copy2(V/'desktop_launch.py',root/'desktop_launch.py')
    (root/'tb_adversarial.sv').write_text(adapted_checker(frozen),encoding='ascii')
    sources=' '.join('rtl/'+p.name for p in sorted((root/'rtl').iterdir())if p.suffix in ['.v','.sv'])
    bins=tools['vivado_bin']
    (root/'run.cmd').write_text(f'@echo off\ncall "{bins}\\xvlog.bat" --sv -i . {sources} tb_adversarial.sv\nif errorlevel 1 exit /b 1\ncall "{bins}\\xelab.bat" tb_adversarial -s candidate_sim -debug typical\nif errorlevel 1 exit /b 1\ncall "{bins}\\xsim.bat" candidate_sim -tclbatch run.tcl -log private.log\nexit /b %errorlevel%\n',encoding='ascii')
    (root/'run.tcl').write_text('run all\nquit\n',encoding='ascii')
    code=native.execute(root,'candidate',timeout=1200)
    log=(root/'private.log').read_text(encoding='utf-8',errors='replace')if(root/'private.log').exists()else''
    console=(root/'candidate_console.log').read_text(encoding='utf-8',errors='replace')
    count=48 if frozen else len(directed_cases());resets=10 if frozen else 0
    terminal=f'ADVERSARIAL_PASS cases={count} reset_witnesses={resets} failures=0 oracle=external_python memory=independent_sync'
    if code or re.search(r'(?im)^ERROR:|^Fatal:|FATAL_ERROR',log+'\n'+console)or log.splitlines().count(terminal)!=1 or '$finish called at time'not in log:raise RuntimeError('WB/MEM suite failed: '+str(root))
    with(root/'independent_results.csv').open(newline='',encoding='utf-8-sig')as f:rows=list(csv.DictReader(f))
    if len(rows)!=count+resets or len({(r['case'],r['epoch'])for r in rows})!=len(rows):raise ValueError('Candidate result rows missing or duplicated')
    if len(re.findall(r'^AUDIT_RESET_WITNESS ',log,re.M))!=resets:raise ValueError('Reset witness count differs')
    execution=json.loads((root/'candidate_execution.json').read_text())
    for name,digest in execution['input_sha256'].items():
        if sha(root/name)!=digest:raise ValueError('Native input changed: '+name)
    witnesses=re.search(r'^WB_CANDIDATE_WITNESSES late=(\d+) pending_stores=(\d+) base_stalls=(\d+)$',log,re.M)
    if not witnesses:raise ValueError('Real late-store witnesses missing')
    return dict(status='PASS',cases=count,rows=len(rows),reset_witnesses=resets,
                witnesses=dict(zip(['late','pending_stores','base_stalls'],map(int,witnesses.groups()))),
                private_checker_sha256=sha(root/'tb_adversarial.sv'),log_sha256=sha(root/'private.log'),
                results_sha256=sha(root/'independent_results.csv'),cycles_sha256=sha(root/'independent_cycles.csv'),
                scope='ISA events and every-clock RF/DM/flags/order/stop; raw-ISA HDU; candidate pending/forwarding. '+('Frozen old cycle totals excluded only; original packet preserved.'if frozen else'Exact new cycles and stalls for all normal HALT programs.'))

def main():
    parser=argparse.ArgumentParser(description=__doc__);add_tool_arguments(parser);a=parser.parse_args()
    tools=resolve_tools(a.vivado_bin,python=sys.executable,config=a.config);native.configure(tools['vivado_bin'])
    work=Path(tempfile.mkdtemp(prefix='wb_mem_validation_'));dest=P/'验证'/work.name
    result=dict(status='RUNNING',candidate='wb_mem',tools=tools,physical_board_validated=False,seed='0x57424d31')
    try:
        shutil.copytree(V/'rtl',work/'rtl');result['overlay']=apply_candidate(work,'wb_mem')
        result['candidate_rtl_sha256']=sha(work/'rtl/datapath_core.sv')
        result['executed_rtl_sha256']={p.name:sha(p)for p in(work/'rtl').iterdir()if p.is_file()}
        frozen=work/'frozen48_packet';generate(frozen);load_case_package(frozen)
        result['frozen_packet_manifest_sha256']=sha(frozen/'manifest.json')
        directed=work/'directed_packet';cases=write_directed(directed)
        print('WB_VALIDATE_START frozen48',flush=True)
        result['frozen48']=execute_case_suite(work/'frozen48_execution',frozen,work/'rtl',tools,True)
        print('WB_VALIDATE_PASS frozen48',flush=True)
        print('WB_VALIDATE_START directed cases='+str(len(cases)),flush=True)
        result['directed']=execute_case_suite(work/'directed_execution',directed,work/'rtl',tools)
        print('WB_VALIDATE_PASS directed',flush=True)
        load_case_package(frozen)
        result['status']='PASS'
    except BaseException as exc:result.update(status='FAIL',error=str(exc));raise
    finally:
        result['runner_sha256']=sha(__file__)
        (work/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
        shutil.copytree(work,dest,ignore=shutil.ignore_patterns('.Xil','xsim.dir','__pycache__'))
        print('WB_VALIDATE_RECORD='+str(dest),flush=True)
if __name__=='__main__':main()
