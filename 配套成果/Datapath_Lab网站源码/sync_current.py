"""Bind the viewer to the current AC1 RTL; migrate the changed functional edges.

Source documents/RTL are read-only inputs. Preserve existing geometry except
the retired MEM fault OR and the new WB store-observation field/connections.
"""
from pathlib import Path
import argparse
import copy
import hashlib
import heapq
import json
import re
import xml.etree.ElementTree as ET

BASE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--source', type=Path, default=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电\CPU核心设计'))
args = parser.parse_args()
rtl = args.source / 'Vivado/rtl'
original = (BASE / 'base.html').read_text(encoding='utf-8')
decoder = json.JSONDecoder()
model = decoder.raw_decode(original.split('window.CPU_MODEL=', 1)[1])[0]
svg_text = decoder.raw_decode(original.split('window.CPU_SVG=', 1)[1])[0]
ns = 'http://www.w3.org/2000/svg'
ET.register_namespace('', ns)
root = ET.fromstring(svg_text)
graph = next(e for e in root.iter() if e.get('class') == 'graph')
files = {n: (rtl / n).read_text(encoding='utf-8-sig') for n in model['sourceHashes']}
model['aliases']={k:('m_fault' if v=='m_fault || m_access_fault' else v) for k,v in model['aliases'].items()}
core = files['datapath_core.sv']
if 'w_valid_next = m_valid;' not in core or '.m_fault(m_fault)' not in core or 'wide_sum' not in files['addsub16_cla.v']:
    raise SystemExit('Current sources do not match the audited AC1 contract')

def node(identifier):
    return next(n for n in model['nodes'] if n['id'] == identifier)

def group(identifier):
    return next(e for e in graph if e.get('data-node') == identifier and e.get('class') == 'node')

def net(signal):
    return next(n for n in model['nets'] if n['signal'] == signal)

def remove_port(identifier, port):
    n = node(identifier)
    n['ins'] = [p for p in n['ins'] if p['id'] != port['id']]
    n['ports'] = [p for p in n.get('ports', []) if p['id'] != port['id']]
    g = group(identifier)
    x = n['x'] + (n['width'] if n.get('reverse') else 0)
    y = n['y'] + port['y']
    for e in list(g):
        if e.get('class') == 'port-dot' and abs(float(e.get('cx')) - x) < .01 and abs(float(e.get('cy')) - y) < .01:
            g.remove(e)
        elif e.get('class') == 'port-label' and ''.join(e.itertext()) == port['label']:
            g.remove(e)

def add_port(identifier, signal, role, y, index):
    n = node(identifier)
    port = {'signal': signal, 'width': 1, 'label': signal, 'id': f'{identifier}.{role}.{index}', 'role': role, 'side': 'WEST' if role == 'in' else 'EAST', 'y': y}
    n['ins' if role == 'in' else 'outs'].append(port)
    g = group(identifier)
    west = (role == 'in') != bool(n.get('reverse'))
    x = n['x'] if west else n['x'] + n['width']
    yy = n['y'] + y
    ET.SubElement(g, f'{{{ns}}}circle', {'class':'port-dot','cx':str(x),'cy':str(yy),'r':'4'})
    label = ET.SubElement(g, f'{{{ns}}}text', {'class':'port-label','x':str(x + (14 if west else -14)),'y':str(yy+5.5),'text-anchor':'start' if west else 'end'})
    label.text = signal
    return port

# AC1 gives operand_forward the captured m_fault directly. The MEM access
# fault cancels younger EX through m_fault_event; the former OR box is obsolete.
model['nodes'] = [n for n in model['nodes'] if n['id'] != 'mfwd_fault']
model['semantics'].pop('mfwd_fault')
model['nets'] = [n for n in model['nets'] if n['sourceNode'] != 'mfwd_fault']
for n in model['nets']:
    n['targets'] = [t for t in n['targets'] if t['node'] != 'mfwd_fault']
for e in list(graph):
    if e.get('data-node') == 'mfwd_fault' or e.get('data-net') == 'mfwd_fault.out.0':
        graph.remove(e)
fwd_port = next(p for p in node('fwd_select')['ins'] if p['id'] == 'fwd_select.in.5')
fwd_port['signal'] = fwd_port['label'] = 'm_fault'
for e in group('fwd_select'):
    if e.get('class') == 'port-label' and 'm_fault' in ''.join(e.itertext()):
        e.text = 'm_fault'
net('m_fault')['targets'].append({'node':'fwd_select','signal':'m_fault','port':fwd_port['id'],'width':1,'slice':None})

# Normal STR keeps a valid WB slot and a qualified w_store observation field.
old = next(p for p in node('occupancy')['ins'] if p['signal'] == 'm_mem_write')
remove_port('occupancy', old)
net('m_mem_write')['targets'] = [t for t in net('m_mem_write')['targets'] if t['port'] != old['id']]
new_in = add_port('wreg', 'm_mem_write', 'in', 682, 15)
new_out = add_port('wreg', 'w_store', 'out', 682, 13)
new_sink = add_port('trace', 'w_store', 'in', 226, 3)
node('wreg')['pairs'].append(['m_mem_write','w_store'])
net('m_mem_write')['targets'].append({'node':'wreg','signal':'m_mem_write','port':new_in['id'],'width':1,'slice':None})
model['nets'].append({'id':new_out['id'],'signal':'w_store','width':1,'sourceNode':'wreg','edgeIds':[],'targets':[{'node':'trace','signal':'w_store','port':new_sink['id'],'width':1,'slice':None}],'bounds':{'x':0,'y':0,'width':0,'height':0}})
node('alu')['title'] = 'alu16 · AC1  |  u_alu'
node('wreg')['notes'] = ['Every surviving instruction has a valid WB slot', 'w_store observes a qualified STR; no second memory write', 'Fault tokens remain valid until WB']
node('occupancy')['notes'] = [s.replace('successful STR retires in MEM','STR writes in MEM; its completion tag reaches WB') for s in node('occupancy')['notes']]
for e in root.iter():
    if e.text:
        e.text = e.text.replace('alu16 + CLA16','alu16 · AC1').replace('Successful STR: valid=0; fault STR: valid fault token','STR: valid WB slot; qualified w_store tag').replace('successful STR retires in MEM','STR writes in MEM; valid WB slot')

sem = model['semantics']
sem['alu']['how'][2] = 'AC1 的 addsub16_cla 使用显式 17 位补码加减表达式推断 FPGA 进位链；接口名称保留，但不实例化 CLA16。'
sem['wreg']['how'][1] = '正常 STR 在 MEM 写 DM 一次，随后仍有有效 WB 槽位；w_store 记录合格 STR，不再写 RF 或 DM。'
sem['occupancy']['how'][2] = 'w_valid_next=m_valid：所有存活指令进入 WB；故障 STR 也保留有效故障标记。'
sem['trace']['how'][0] = 'w_pc、w_store、C、V 可用于测试与调试；w_store 不是再次写 DM 的使能。'
sem['mem_guard']['how'].append('AC1 共享 m_address_in_range=(m_exec_value[15:8]==0)，同时用于访问故障与内存使能资格。')
str_guide = next(g for g in model['guides'] if g['id'] == 'str')
str_guide['instruction'] = 'STR R1, [R2 + 4] · 0x9604'
str_guide['steps'][-1][3] = 'MEM 资格允许时，DM 在边沿写入一次。正常 STR 随后保留有效 WB 槽位；不在 WB 再次写入。'
str_guide['steps'].append(['w_store','trace','保留 WB 完成标签','w_store = w_valid_next && !w_fault_next && m_mem_write。它标识合格 STR 的 WB 完成槽位，不产生第二次内存写入。'])
next(g for g in model['guides'] if g['id'] == 'ldr')['instruction'] = 'LDR R1, [R2 + 4] · 0x8604'
next(g for g in model['guides'] if g['id'] == 'add')['steps'][2][3] += ' AC1 使用 17 位加减表达式；结果与 C/V 候选随指令标签推进。'

# Replace every source snippet with an exact contiguous slice of current RTL.
lengths = {'decode':74,'wreg':13,'mreg':13,'xreg':20,'occupancy':32,'mode':17,'trace':12,'hazard':2,'x_illegal':3,'events':18}
for identifier, s in sem.items():
    filename = s['source']['file']
    lines = files[filename].splitlines()
    if filename != 'datapath_core.sv':
        s['source'] = {'file':filename,'start':1,'text':'\n'.join(lines)+'\n'}
        continue
    first = s['source']['text'].splitlines()[0].strip()
    if identifier == 'trace': first = next(line.strip() for line in lines if 'reg ' in line and 'w_valid' in line and 'w_fault' in line)
    candidates = [i for i,line in enumerate(lines) if line.strip() == first]
    if not candidates:
        raise RuntimeError('Cannot bind exact current source anchor: '+identifier+' '+first)
    start = candidates[-1] if '<=' in first else candidates[0]
    count = lengths.get(identifier, len(s['source']['text'].splitlines()))
    s['source'] = {'file':filename,'start':start+1,'text':'\n'.join(lines[start:start+count])+'\n'}
sem['alu']['extraSources'] = [{'file':'addsub16_cla.v','start':1,'text':files['addsub16_cla.v']}]
for rule in model['captureRules']:
    matches = re.findall(r'\b'+re.escape(rule['output'])+r'\s*<=\s*([^;]+);', core)
    if not matches: raise RuntimeError('No current capture assignment: '+rule['output'])
    rule['rhs'] = re.sub(r'\s+',' ',matches[-1].strip())
model['captureRules'].append({'node':'wreg','input':'m_mem_write','output':'w_store','rhs':'w_valid_next && !w_fault_next && m_mem_write'})
field = ET.SubElement(group('wreg'), f'{{{ns}}}g', {'class':'field-transfer','data-input':'m_mem_write','data-output':'w_store'})
ET.SubElement(field, f'{{{ns}}}path', {'class':'transfer','d':'M 8326 970 H 7866'})
ET.SubElement(field, f'{{{ns}}}text', {'x':'8096','y':'963','font-size':'16','text-anchor':'middle'}).text = 'G'
for e in root.iter():
    if e.get('class') == 'field-transfer':
        rule = next((r for r in model['captureRules'] if r['output'] == e.get('data-output')),None)
        if rule: e.set('data-capture', rule['output']+' <= '+rule['rhs']+'; rst clears state')

# Reroute only four changed nets. Visibility-grid A* keeps them outside every
# module body. Exact endpoints use the SVG's port dots, including reverse banks.
old_port_points = {}
for n in model['nodes']:
    dots = [e for e in group(n['id']) if e.get('class') == 'port-dot']
    # Newly appended dots are at the end, so original input/output ordering
    # cannot be used directly for these changed nodes: match label positions.
    for role in ['ins','outs']:
        for p in n[role]:
            west = (role == 'ins') != bool(n.get('reverse'))
            x = n['x'] if west else n['x'] + n['width']
            y = n['y'] + p['y']
            dot = min(dots,key=lambda e:abs(float(e.get('cx'))-x)+abs(float(e.get('cy'))-y))
            if abs(float(dot.get('cx'))-x)+abs(float(dot.get('cy'))-y)>30:
                raise RuntimeError('Port geometry mismatch: '+p['id'])
            old_port_points[p['id']] = (float(dot.get('cx')),float(dot.get('cy')))

rects=[(n['x']-12,n['y']-12,n['x']+n['width']+12,n['y']+n['height']+12) for n in model['nodes']]
def blocked(x,y): return any(l<x<r and t<y<b for l,t,r,b in rects)
def edge_ok(a,b):
    x,y=a; xx,yy=b
    if x==xx:return not any(l<x<r and max(min(y,yy),t)<min(max(y,yy),bot) for l,t,r,bot in rects)
    return not any(t<y<bot and max(min(x,xx),l)<min(max(x,xx),r) for l,t,r,bot in rects)

def route(start,end):
    xs=sorted({start[0],end[0],0,model['width']-160,*[v for r in rects for v in [r[0],r[2]]]})
    ys=sorted({start[1],end[1],0,model['height']-570,*[v for r in rects for v in [r[1],r[3]]]})
    s=(xs.index(start[0]),ys.index(start[1]));goal=(xs.index(end[0]),ys.index(end[1]))
    queue=[(0,0,s)];cost={s:0};previous={}
    while queue:
        _,g,current=heapq.heappop(queue)
        if g!=cost[current]:continue
        if current==goal:break
        i,j=current
        for ni,nj in [(i+1,j),(i-1,j),(i,j+1),(i,j-1)]:
            if not (0<=ni<len(xs) and 0<=nj<len(ys)):continue
            a=(xs[i],ys[j]);b=(xs[ni],ys[nj])
            if blocked(*b) or not edge_ok(a,b):continue
            value=g+abs(b[0]-a[0])+abs(b[1]-a[1])+1
            nxt=(ni,nj)
            if value<cost.get(nxt,float('inf')):
                cost[nxt]=value;previous[nxt]=current
                h=abs(b[0]-end[0])+abs(b[1]-end[1]);heapq.heappush(queue,(value+h,value,nxt))
    if goal not in cost:raise RuntimeError('No body-safe route between '+str((start,end)))
    keys=[goal]
    while keys[-1]!=s:keys.append(previous[keys[-1]])
    return [(xs[i],ys[j]) for i,j in reversed(keys)]

changed=['m_fault','m_access_fault','m_mem_write','w_store']
routes=[]
for signal in changed:
    n=net(signal)
    n['edgeIds']=[n['id']+'->'+t['port'] for t in n['targets']]
    for e in list(graph):
        if e.get('data-net')==n['id']:graph.remove(e)
    g=ET.Element(f'{{{ns}}}g',{'class':'net','data-net':n['id']})
    ET.SubElement(g,f'{{{ns}}}title').text=signal
    src=node(n['sourceNode']);p=next(p for p in src['outs'] if p['signal']==signal);sp=old_port_points[p['id']]
    departure=(sp[0]+(-24 if src.get('reverse') else 24),sp[1])
    all_points=[]
    segments=[]
    for target in n['targets']:
        sink=node(target['node']);tp=old_port_points[target['port']]
        arrival=(tp[0]+(24 if sink.get('reverse') else -24),tp[1])
        points=[sp]+route(departure,arrival)+[tp];all_points+=points
        segments.extend(zip(points,points[1:]))
        # Each path has its own white separator and hit region. A white bridge
        # separator indicates crossing; only explicit dots indicate junctions.
        d='M '+' L '.join(f'{x:g} {y:g}' for x,y in points)
        ET.SubElement(g,f'{{{ns}}}path',{'d':d,'stroke':'white','fill':'none','stroke-width':'7','stroke-linejoin':'round'})
        ET.SubElement(g,f'{{{ns}}}path',{'class':'wire control','d':d,'stroke':'#9638D1'})
        ET.SubElement(g,f'{{{ns}}}path',{'class':'hit','d':d})
        direction=-1 if sink.get('reverse') else 1
        arrow=f'M {tp[0]-direction*11:g} {tp[1]-5:g} L {tp[0]:g} {tp[1]:g} L {tp[0]-direction*11:g} {tp[1]+5:g} Z'
        ET.SubElement(g,f'{{{ns}}}path',{'d':arrow,'fill':'#9638D1'})
        routes.append({'signal':signal,'target':target['port'],'points':points})
    # Merge shared runs conceptually and mark every true branch/crossing inside
    # this signal. Other-wire intersections deliberately get no junction dot.
    vertices=set(all_points)
    horizontal=[(a,b) for a,b in segments if a[1]==b[1]]
    vertical=[(a,b) for a,b in segments if a[0]==b[0]]
    for a,b in horizontal:
        for c,d in vertical:
            if min(a[0],b[0])<=c[0]<=max(a[0],b[0]) and min(c[1],d[1])<=a[1]<=max(c[1],d[1]):vertices.add((c[0],a[1]))
    adjacency={p:set() for p in vertices}
    for a,b in segments:
        points=sorted((p for p in vertices if (a[0]==b[0]==p[0] and min(a[1],b[1])<=p[1]<=max(a[1],b[1])) or (a[1]==b[1]==p[1] and min(a[0],b[0])<=p[0]<=max(a[0],b[0]))),key=lambda p:p[1] if a[0]==b[0] else p[0])
        for left,right in zip(points,points[1:]):adjacency[left].add(right);adjacency[right].add(left)
    for (x,y),neighbors in adjacency.items():
        if len(neighbors)>=3:ET.SubElement(g,f'{{{ns}}}circle',{'cx':str(x),'cy':str(y),'r':'5','fill':'#9638D1','stroke':'white','stroke-width':'1.7'})
    n['bounds']={'x':min(x for x,y in all_points),'y':min(y for x,y in all_points),'width':max(x for x,y in all_points)-min(x for x,y in all_points),'height':max(y for x,y in all_points)-min(y for x,y in all_points)}
    # Keep wire groups beneath boxes and port labels.
    graph.insert(0,g)

model['connectionCount']=sum(len(n['targets']) for n in model['nets'])
model['sourceHashes']={name:hashlib.sha256((rtl/name).read_bytes()).hexdigest() for name in files}
model['review']={'registerFields':len(model['captureRules']),'sourceDate':'2026-10-14','version':'v1.6-timing-AC1','isaVersion':'1.5','changedRoutes':len(routes),'scope':'website source and topology checks; no new CPU simulation'}
model['semantics']['trace']['purpose']='保留提交标签、w_store 和架构 C/V 的观察入口，不新增架构指令或副作用。'
# Remove retired print-sheet captions while retaining every current circuit
# label, port and wire. These captions still describe the private Pre4 baseline.
for element in list(root):
    if element.tag.rsplit('}',1)[-1] in ('text','path'):
        root.remove(element)

data=BASE/'data';data.mkdir(exist_ok=True)
(data/'model.json').write_text(json.dumps(model,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
(data/'schematic.svg').write_text(ET.tostring(root,encoding='unicode'),encoding='utf-8')
(data/'changed-routes.json').write_text(json.dumps(routes,indent=2),encoding='utf-8')
reference=BASE/'source';reference.mkdir(exist_ok=True)
for name in files:(reference/name).write_bytes((rtl/name).read_bytes())
print(f'AC1 snapshot: {len(model["nodes"])} blocks, {len(model["nets"])} nets, {model["connectionCount"]} sinks, {len(model["captureRules"])} capture rules')
