"""Design-level cycle model: not RTL, BRAM IP simulation, or timing closure."""
import json, random
from pathlib import Path
from copy import deepcopy

def enc(o,d=0,s=0,i=0):return o<<12|d<<10|s<<8|(i&255)
def sext(v):return v if v<128 else v-256
def decode(w,pc,tag=0,fetch_error=False):
 o=w>>12;d=w>>10&3;s=w>>8&3;i=w&255
 uses_d=o in (2,3,4,5,6,9,10);uses_s=o in (1,3,4,5,6,8,9,10)
 return dict(o=o,d=d,s=s,i=i,pc=pc,tag=tag,err=fetch_error or o>12,
             srcs=[d if uses_d else None,s if uses_s else None],rw=o in range(7) or o==8)

def reference(prog,mem,initial,initial_z=0,limit=1000):
 r=initial.copy();z=initial_z;pc=0;events=[];mem=mem.copy();fault=False;halt=False
 for _ in range(limit):
  if pc not in prog or not 0<=pc<256:fault=True;break
  w=prog[pc];o=w>>12;d=w>>10&3;s=w>>8&3;i=w&255;a=r[d];b=r[s];n=(pc+1)&65535
  ev={'pc':pc,'word':w,'reg':None,'flag':None,'store':None}
  if o==0:v=i
  elif o==1:v=b
  elif o==2:v=(a+i)&65535
  elif o==3:v=(a+b)&65535
  elif o==4:v=(a-b)&65535
  elif o==5:v=a&b
  elif o==6:v=a|b
  elif o==7:n=i
  elif o in (8,9):
   ea=(b+sext(i))&65535
   if ea>=256:fault=True;break
   if o==8:v=mem.get(ea,0)
   else:mem[ea]=a;ev['store']=[ea,a]
  elif o==10:z=int(a==b);ev['flag']=z
  elif o==11:n=(pc+1+sext(i))&65535 if z else n
  elif o==12:halt=True;n=pc
  else:fault=True;break
  if o in range(7) or o==8:r[d]=v;ev['reg']=[d,v]
  events.append(ev);pc=n
  if halt:break
 else:raise AssertionError('reference timeout')
 return r,z,mem,events,halt,fault

class Pipeline:
 def __init__(self,p,mem=None,r=None,z=0,disable=None):
  self.prog=p;self.mem=(mem or {}).copy();self.r=(r or [0]*4).copy();self.z=z
  self.pc=0;self.D=self.X=self.M=self.W=None;self.cycles=0;self.seq=0
  self.stop=False;self.pending=False;self.halted=False;self.fault=False
  self.events=[];self.timeline=[];self.stalls=0;self.branches=0;self.parallel=0
  self.disable=disable;self.forward_log=[]
 def event(self,t):
  return dict(pc=t['pc'],word=self.prog[t['pc']],reg=None,flag=None,store=None)
 def step(self):
  self.cycles+=1;D,X,M,W=self.D,self.X,self.M,self.W
  row={'cycle':self.cycles,'F':self.pc,'D':D['pc'] if D else None,'X':X['pc'] if X else None,
       'M':M['pc'] if M else None,'W':W['pc'] if W else None,'stall':False,'redirect':None}
  completions=[];nw=nm=nx=nd=None;mfault=False;redirect=None;kill=False
  oldr=self.r.copy()
  if W:
   e=self.event(W)
   if W['rw']:self.r[W['d']]=W['value'];e['reg']=[W['d'],W['value']]
   if W['o']==10:self.z=W['cmp'];e['flag']=self.z
   if W['o']==12:self.halted=True
   completions.append((W['tag'],e))
  if M and not self.halted:
   if M['o'] in (8,9) and M['ea']>=256:mfault=True;self.stop=True;self.pending=True
   elif M['o']==9:
    self.mem[M['ea']]=M['store'];e=self.event(M);e['store']=[M['ea'],M['store']];completions.append((M['tag'],e))
   else:
    nw=M.copy()
    if M['o']==8:nw['value']=self.mem.get(M['ea'],0)
  def operand(k):
   idx=X['srcs'][k]
   if idx is None:return 0
   if self.disable not in ('forward','stall_only') and M and M['rw'] and M['d']==idx:
    assert M['o']!=8, 'uninterlocked load-use'
    self.forward_log.append('M');return M['value']
   if self.disable not in ('forward','stall_only') and W and W['rw'] and W['d']==idx:
    self.forward_log.append('W');return W['value']
   return X['vals'][k]
  if X and not mfault and not self.halted:
   if X['err']:self.pending=True;self.stop=True;kill=True
   else:
    a,b=operand(0),operand(1);o=X['o'];i=X['i'];nm=X.copy()
    if o==0:nm['value']=i
    elif o==1:nm['value']=b
    elif o==2:nm['value']=(a+i)&65535
    elif o==3:nm['value']=(a+b)&65535
    elif o==4:nm['value']=(a-b)&65535
    elif o==5:nm['value']=a&b
    elif o==6:nm['value']=a|b
    elif o in (8,9):nm['ea']=(b+sext(i))&65535;nm['store']=a
    elif o==10:nm['cmp']=int(a==b)
    elif o in (7,11):
     flag=self.z
     if self.disable not in ('zforward','stall_only'):
      if M and M['o']==10:flag=M['cmp'];self.forward_log.append('Z_M')
      elif W and W['o']==10:flag=W['cmp'];self.forward_log.append('Z_W')
     if o==7 or flag:
      redirect=i if o==7 else (X['pc']+1+sext(i))&65535
      self.branches+=1;kill=self.disable!='flush'
    elif o==12:self.stop=True;kill=True
  hazard=(D and X and not X['err'] and X['o']==8 and X['d'] in D['srcs'])
  if self.disable=='stall_only' and D:
   hazard=any(t and not t['err'] and ((t['rw'] and t['d'] in D['srcs']) or (D['o']==11 and t['o']==10)) for t in (X,M))
  if self.disable=='interlock':hazard=False
  if mfault or self.halted:nm=None;kill=True
  if redirect is not None:self.pc=redirect;row['redirect']=redirect
  if not kill and not self.stop:
   if hazard:
    nd=D;self.stalls+=1;row['stall']=True
   else:
    if D:
     nx=D.copy();nx['vals']=[(self.r[x] if self.disable!='wb_id' else oldr[x]) if x is not None else 0 for x in D['srcs']]
    if redirect is None:
     if M and M['o'] in (8,9):self.parallel+=1
     w=self.prog.get(self.pc,enc(15));nd=decode(w,self.pc,self.seq,self.pc not in self.prog or self.pc>=256)
     self.seq+=1;self.pc=(self.pc+1)&65535
  self.D,self.X,self.M,self.W=nd,nx,nm,nw
  if self.pending and not nw and not nm:self.fault=True
  self.events.extend(e for _,e in sorted(completions))
  row['completions']=len(completions)
  self.timeline.append(row)
 def run(self):
  for _ in range(5000):
   if self.halted or self.fault:return self
   self.step()
  raise AssertionError('pipeline timeout')

def validate(name,words,mem=None,r=None,z=0,disabled=None):
 prog=words if isinstance(words,dict) else dict(enumerate(words))
 ref=reference(prog,mem or {},r or [0]*4,z)
 p=Pipeline(prog,mem,r,z,disabled).run()
 assert (p.r,p.z,p.mem,p.events,p.halted,p.fault)==ref,(name,p.r,ref[0],p.events,ref[3])
 return p

if __name__=='__main__':
 cases={
 'sum':([enc(0,0,i=0),enc(0,1,i=1),enc(0,2,i=6),enc(3,0,1),enc(2,1,i=1),enc(10,1,2),enc(11,i=1),enc(7,i=3),enc(0,3,i=32),enc(9,0,3),enc(8,2,3),enc(12)],{}),
 'alu_forward':([enc(0,1,i=7),enc(3,2,1),enc(12)],{}),
 'load_use':([enc(8,1,0),enc(3,2,1),enc(12)],{'mem':{0:7}}),
 'load_store_data':([enc(8,1,0),enc(9,1,0,i=1),enc(12)],{'mem':{0:9}}),
 'load_store_base':([enc(8,1,0),enc(9,2,1),enc(12)],{'mem':{0:32},'r':[0,0,9,0]}),
 'wb_id':([enc(0,1,i=9),enc(0,2,i=2),enc(0,3,i=3),enc(3,0,1),enc(12)],{}),
 'latest_waw':([enc(0,1,i=1),enc(0,1,i=2),enc(3,0,1),enc(12)],{}),
 'flag_forward':([enc(10,0,1),enc(11,i=1),enc(0,2,i=7),enc(12)],{'r':[0,1,0,0],'z':1}),
 'flush_store':([enc(7,i=3),enc(9,1,0),enc(0,2,i=7),enc(12)],{'r':[0,9,0,0]}),
 'halt_kills_store':([enc(12),enc(9,1,0)],{'r':[0,9,0,0]}),
 'store_load':([enc(9,1,0),enc(8,2,0),enc(12)],{'r':[0,9,0,0]}),
 'load_no_false_dependency':([enc(8,1,0),enc(0,1,i=5),enc(12)],{'mem':{0:7}}),
 'fault_kills_younger_store':([enc(8,1,0,i=255),enc(9,2,3),enc(12)],{'r':[0,0,9,0]}),
 'illegal_drains_older':([enc(0,1,i=7),enc(15),enc(9,1,0),enc(12)],{}),
 'wrong_path_fault':([enc(7,i=3),enc(15),enc(15),enc(12)],{}),
 'flag_priority':([enc(10,0,0),enc(10,0,1),enc(11,i=1),enc(0,2,i=7),enc(12)],{'r':[0,1,0,0]}),
 'mem_fault_beats_redirect':([enc(0,2,i=8),enc(8,1,0,i=255),enc(7,i=4),enc(9,2,3),enc(12)],{'r':[0,0,0,0]}),
 'fault_drains_load':([enc(8,1,0),enc(15),enc(9,1,0)],{'mem':{0:13}}),
 'branch_kills_halt':([enc(7,i=3),enc(12),enc(15),enc(0,1,i=7),enc(12)],{}),
 }
 reports={}
 for name,(w,kw) in cases.items():
  p=validate(name,w,**kw);reports[name]={'cycles':p.cycles,'completed':len(p.events),'stalls':p.stalls,'taken_branches':p.branches,'if_mem_overlap_cycles':p.parallel,'registers':p.r,'fault':p.fault,'max_completions_per_cycle':max(x['completions'] for x in p.timeline)}
  if name=='sum':sumtrace=p.timeline;assert p.r==[15,6,15,32] and len(p.events)==31
  if name.startswith('load_') and name not in ('load_no_false_dependency',):assert p.stalls==1
  if name in ('fault_kills_younger_store','mem_fault_beats_redirect','fault_drains_load','illegal_drains_older'):assert p.fault
 assert reports['load_no_false_dependency']['stalls']==0
 mutations={}
 for feature,name in [('forward','alu_forward'),('interlock','load_use'),('wb_id','wb_id'),('zforward','flag_forward'),('flush','flush_store')]:
  try:validate(name,*cases[name][:1],**cases[name][1],disabled=feature)
  except AssertionError:mutations[feature]='detected'
  else:raise AssertionError('mutation survived '+feature)
 rng=random.Random(20260909)
 for k in range(200):
  w=[]
  for _ in range(30):
   op=rng.choice([0,1,2,3,4,5,6,10]);w.append(enc(op,rng.randrange(4),rng.randrange(4),rng.randrange(256)))
  w.append(enc(12));validate('random'+str(k),w,r=[rng.randrange(65536) for _ in range(4)])
 result={'evidence':'Python cycle model versus instruction-level reference; not RTL/IP/timing validation',
         'directed_cases':reports,'random_programs':200,'seed':20260909,'mutation_checks':mutations,'sum_timeline':sumtrace}
 Path(__file__).with_name('model_results.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
 print(json.dumps({'directed':len(reports),'random_programs':200,'mutations':mutations,'sum':reports['sum']},indent=2))
