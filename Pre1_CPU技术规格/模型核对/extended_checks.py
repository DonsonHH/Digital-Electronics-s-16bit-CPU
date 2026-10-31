from pathlib import Path
import json,random
from pipeline_model import Pipeline,reference,enc,validate
root=Path(__file__).parent
rng=random.Random(20260909)
mixed=[]
for k in range(200):
 words=[]
 for _ in range(40):
  op=rng.choice([0,1,2,3,4,5,6,8,9,10,11]);d=rng.randrange(3);s=rng.randrange(4)
  if op in (8,9):s=3;i=rng.randrange(16)
  elif op==11:i=rng.randrange(3)
  else:i=rng.randrange(256)
  words.append(enc(op,d,s,i))
 words.extend([enc(12)]*3)
 mem={32+i:rng.randrange(65536) for i in range(16)};regs=[rng.randrange(65536) for _ in range(3)]+[32]
 p=validate('mixed'+str(k),words,mem=mem,r=regs)
 q=validate('mixedstall'+str(k),words,mem=mem,r=regs,disabled='stall_only')
 assert p.r==q.r and p.mem==q.mem and p.events==q.events
 mixed.append((p.cycles,q.cycles,p.stalls,p.branches))
program=[enc(0,0),enc(0,1,i=1),enc(0,2,i=6),enc(3,0,1),enc(2,1,i=1),enc(10,1,2),enc(11,i=1),enc(7,i=3),enc(0,3,i=32),enc(9,0,3),enc(8,2,3),enc(12)]
fast=validate('sum-forward',program);slow=validate('sum-stall',program,disabled='stall_only')
assert fast.events==slow.events
def ripple(a,b,ci,n):
 out=0;c=ci
 for i in range(n):
  x=a>>i&1;y=b>>i&1;p=x^y;g=x&y
  out|=(p^c)<<i;c=g|(p&c)
 return out|(c<<n)
for a in range(16):
 for b in range(16):
  for c in (0,1):assert ripple(a,b,c,4)==a+b+c
for _ in range(1000):
 a=rng.randrange(65536);b=rng.randrange(65536)
 assert ripple(a,b,0,16)==a+b
 assert (ripple(a,b^65535,1,16)&65535)==((a-b)&65535)
for x in range(256):
 assert ((x|0xff00) if x&128 else x)&65535 == ((x-256 if x&128 else x)&65535)
class SyncRead:
 def __init__(self,m):self.m=m;self.q=0
 def edge(self,en,a):
  old=self.q
  if en:self.q=self.m[a]
  return old
m=SyncRead({0:0x0401,1:0x0806,2:0x3100});expected=[];bad_capture=[]
for en,a in [(1,0),(1,1),(0,2),(1,2)]:
 old=m.edge(en,a);expected.append(m.q);bad_capture.append(old)
assert expected==[0x0401,0x0806,0x0806,0x3100]
assert bad_capture!=expected
report={'scope':'Python architecture/cycle/Boolean/edge-contract checks, not RTL or real IP',
 'mixed_programs':200,'mixed_seed':20260909,'mixed_ops':'ALU/MOV/CMP/forward-only JZ/LDR/STR/HALT',
 'comparison':{'forwarded_cycles':fast.cycles,'stall_only_cycles':slow.cycles,'instructions':len(fast.events),'same_clock_ideal_speedup':slow.cycles/fast.cycles,'forward_stalls':fast.stalls,'stall_only_stalls':slow.stalls,'qualification':'same fixed memory latency and nominal clock only; no measured frequency or area'},
 'boolean_checks':{'exhaustive_4bit_add':512,'random_16bit_add_sub_pairs':1000,'sign_extension_inputs':256},
 'memory_contract':{'expected_dout':expected,'incorrect_extra_register_output':bad_capture,'incorrect_mapping_detected':True}}
(root/'extended_results.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print(json.dumps(report,indent=2))
