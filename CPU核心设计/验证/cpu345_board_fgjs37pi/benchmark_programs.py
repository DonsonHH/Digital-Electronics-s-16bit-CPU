"""Fixed reviewed benchmarks; ISA events and static cycle contracts are independent."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'Vivado'))
from verification.isa_reference import ins,oracle,pack

# cycles, completed instructions, stalls, redirects for the stable AC1 pipeline.
PROGRAMS={'all_ops':(25,16,1,2),'baseline':(17,10,1,1),'loop':(30,18,0,4),
          'memory_copy':(15,7,2,1),'copy_checksum':(55,35,16,0)}

def checksum_program():
 words=[ins(1,3,b=32),ins(1,1,b=0)]
 for i in range(8):words += [ins(8,0,3,i),ins(9,0,3,i+32)]
 for i in range(8):words += [ins(8,0,3,i+32),ins(4,1,0)]
 words.append(ins(14));image=words+[0xb000]*(256-len(words));memory=[0]*256
 memory[32:40]=[0xffff,1,0x8000,0x7fff,0x1234,0xa5a5,0x5a5a,0]
 expected=oracle(image,memory)
 assert len(words)==35 and len(expected['events'])==35 and len(expected['stores'])==8
 assert expected['rf']==[0,0x1232,0,32] and expected['flags']==[0,0,0]
 return image,memory

def prepare_selected(work,system,program):
 work,system=Path(work),Path(system)
 c,n,stalls,redirects=PROGRAMS[program]
 if program=='copy_checksum':image,memory=checksum_program()
 else:
  image=[int(x,16) for x in (system/'programs'/(program+'_im.mem')).read_text().splitlines()]
  memory=[int(x,16) for x in (system/'programs'/(program+'_dm.mem')).read_text().splitlines()]
 assert len(image)==256 and len(memory)==256
 gold=oracle(image,memory);assert len(gold['events'])==n and gold['halt'] and not gold['fault']
 for name,values,width in [('dut_im.mem',image,4),('dut_dm.mem',memory,4),('selected_events.mem',[pack(e) for e in gold['events']],16),
                           ('selected_stores.mem',[pack(e)|(e['sequence']<<63) for e in gold['stores']] or [0],20)]:
  (work/'programs'/name).write_text(''.join(f'{value:0{width}x}\n' for value in values),encoding='ascii')
 expected={'CYCLES':c,'N':n,'STALLS':stalls,'REDIRECTS':redirects,'STORES':len(gold['stores'])}
 config='localparam PROGRAM="'+program+'";\n'+''.join('localparam EXPECTED_'+k+'='+str(v)+';\n' for k,v in expected.items())
 config+=f"localparam[63:0] EXPECTED_RF=64'h{sum(v<<(16*i) for i,v in enumerate(gold['rf'])):016x};\nlocalparam[2:0] EXPECTED_FLAGS=3'd{gold['flags'][0]*4+gold['flags'][1]*2+gold['flags'][2]};\nlocalparam[15:0] EXPECTED_PC=16'd{gold['events'][-1]['pc']};\n"
 (work/'tb/selected_expected.svh').write_text(config,encoding='ascii')
 return expected,gold
