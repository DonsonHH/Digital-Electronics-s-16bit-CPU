from pathlib import Path
from html import escape
import hashlib, json, re
from PIL import ImageFont
BODYFONT=ImageFont.truetype(r'C:\Windows\Fonts\msyh.ttc',36)
HEADFONT=ImageFont.truetype(r'C:\Windows\Fonts\msyhbd.ttc',40)

WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
CORE=ROOT/'CPU核心设计'
OUT=WORK/'figures';OUT.mkdir(exist_ok=True)
MAP=[
 ('全局运行模式FSM','core内部状态与组合逻辑','mode/mode_next；m_fault_event、x_fault_event、qualified_halt、drain_done、rst','mode_active、stop_pending、halted、fault；不直接产生所有级使能'),
 ('IFCU 取指控制','core内部组合逻辑＋pc16 u_pc','mode、frontend_kill、load_use、fetch_in_range、qualified_redirect、branch_target','fetch_accept、pc_hold、im_en；pc16执行reset > redirect > hold > +1'),
 ('IDCU 译码与发射','isa_decode u_decode＋core资格逻辑','d_inst16、d_valid、d_fetch_fault、load_use、frontend_kill','d_rd/rs各2、d_imm8、d_use_rd/rs、d_alu_*、副作用意图、d_fault、x_valid_next'),
 ('EXCU 运算与决策','core内部组合逻辑','x_*控制、ALU非法标记、blocked_rd/rs、z_effective、较老MEM故障','ALU选择、branch_req、halt_req、x_fault_event、qualified_redirect/qualified_halt'),
 ('MEMCU 访存保护','core内部组合逻辑','m_valid/fault、m_mem_read/write、完整m_exec_value16、rst、mode_active','m_address_in_range、m_access_fault、m_fault_event、dm_en、dm_we'),
 ('WBCU 架构写入','core内部组合逻辑','w_valid/fault、w_reg_write/z_write/cv_write、mode_active、rst','wb_ok、rf_we、z_we、cv_we；STR有效WB不写入'),
 ('操作数前递','operand_forward u_forward','x实际源/use与保存值；M/W目标、RW、valid/fault、M就绪状态','rd_fwd/rs_fwd各16、rd_fwd_sel/rs_fwd_sel各2、blocked_rd/rs；M匹配load阻断旧W'),
 ('WB至ID旁路','regfile4x16 u_rf 内部组合逻辑','rf_we、w_rd2、wb_data16与d_rd/d_rs','d_rd_value/d_rs_value各16；同地址返回当前WB值'),
 ('Z来源选择','core内部组合逻辑','有效无故障M/W的ZW与cmp_z，已保存Z','z_effective、z_fwd_sel；M > W > Z，候选0同样覆盖'),
 ('跨级冒险与事件仲裁','core内部组合逻辑','D真实源、X的MR/rd、MEM/EX事件、rst、mode、各级valid_next','load_use、frontend_kill、d_kill、x_kill、各级valid_next；年龄优先级见3.5节'),
 ('四个流水边界','core内寄存器＋外部同步RAM输出','本条指令的数据、pc、索引、valid/fault与剩余控制','D/X/M/W载荷见表15；IM dout是D指令、DM dout是W加载数据，不另加IR/MDR')
]
(WORK/'block_signal_map.json').write_text(json.dumps({'baseline':'v1.6-timing-AC1 / ISA v1.5','rows':[dict(zip(['block','implementation','inputs','outputs'],r)) for r in MAP]},ensure_ascii=False,indent=2),encoding='utf-8')

# All diagram labels are native SVG text. Each named bundle resolves to these
# existing RTL signals; it does not introduce ports, a packed bus, or registers.
GROUPS={
 'CTRL_X':['x_use_rd','x_use_rs','x_alu_a_sel','x_alu_b_sel','x_alu_op','x_reg_write','x_mem_read','x_mem_write','x_z_write','x_cv_write','x_wb_sel','x_jump_abs','x_jump_z','x_halt'],
 'CTRL_M':['m_reg_write','m_mem_read','m_mem_write','m_z_write','m_cv_write','m_wb_sel','m_halt'],
 'CTRL_W':['w_reg_write','w_z_write','w_cv_write','w_wb_sel','w_halt'],
 'FB':['d_rd','d_rs','d_use_rd','d_use_rs','x_rd','x_mem_read','d_valid','x_valid','m_valid','w_valid','d_fault','x_fault','m_fault','w_fault','m_rd','w_rd','alu_eq','alu_illegal','blocked_rd','blocked_rs','fetch_in_range','m_address_in_range','w_halt','w_store','branch_req','halt_req','m_fault_event','x_fault_event','z_effective','w_stop_token','pipeline_empty_next'],
 'UPD':['d_valid_next','x_valid_next','m_valid_next','w_valid_next','d_kill','x_kill'],
 'IM':['im_addr','im_en','im_dout'], 'DM':['dm_addr','dm_din','dm_dout','dm_en','dm_we']
}
rtl='\n'.join(p.read_text(encoding='utf-8') for p in (CORE/'Vivado'/'rtl').glob('*') if p.suffix in ['.v','.sv'])
assert all(re.search(r'\b'+re.escape(s)+r'\b',rtl) for g in GROUPS.values() for s in g)

C={'data':'#24384B','ctrl':'#2B68A6','fwd':'#087C7C','kill':'#BD4E26','muted':'#536477','line':'#BCC8D2','pale':'#F1F5F8'}
class SVG:
 def __init__(self,title,desc):
  self.a=['<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="1500" viewBox="0 0 2400 1500" role="img">',f'<title>{escape(title)}</title><desc>{escape(desc)}</desc>',
   '<defs>'+''.join(f'<marker id="a_{k}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="3" markerHeight="3" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="{v}"/></marker>' for k,v in C.items())+'</defs>',
   '<style>text{font-family:"Microsoft YaHei","Noto Sans CJK SC",Arial,sans-serif;fill:#162B3E;font-size:36px} .title{font-size:48px;font-weight:700}.head{font-size:40px;font-weight:700}.label{font-size:36px}.small{font-size:36px}.mono{font-family:Consolas,"Microsoft YaHei",monospace;font-size:36px}</style>',
   '<rect width="2400" height="1500" fill="white"/>']
  self.nets=[];self.nodes=[]
 def rect(self,id,x,y,w,h,fill='white',stroke=None,dash=None,rx=12):
  self.nodes.append({'id':id,'x':x,'y':y,'width':w,'height':h})
  self.a.append(f'<rect id="{id}" x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke or C["line"]}" stroke-width="3"'+(f' stroke-dasharray="{dash}"' if dash else '')+'/>')
 def text(self,x,y,text,cls='label',anchor='start',color=None):
  lines=text if isinstance(text,(list,tuple)) else [text]
  self.a.append(f'<text x="{x}" y="{y}" class="{cls}" text-anchor="{anchor}"'+(f' style="fill:{color}"' if color else '')+'>')
  for i,line in enumerate(lines):self.a.append(f'<tspan x="{x}" dy="{0 if i==0 else 46}">{escape(str(line))}</tspan>')
  self.a.append('</text>')
 def box(self,id,x,y,w,h,head,lines=(),kind='data',fill='white',dash=None):
  for txt,font in [(head,HEADFONT)]+[(z,BODYFONT) for z in lines]:
   if font.getlength(txt)>w-32:print('TEXT_WIDTH',id,round(font.getlength(txt)),w-32,txt)
  if lines and 88+46*(len(lines)-1)>h-9:print('TEXT_HEIGHT',id)
  self.rect(id,x,y,w,h,fill,C[kind],dash)
  self.text(x+18,y+46,head,'head')
  if lines:self.text(x+18,y+88,lines)
 def line(self,id,pts,kind='data',arrow=True,dash=None,signals=()):
  self.nets.append({'id':id,'signals':list(signals),'points':pts})
  path='M '+' L '.join(f'{x},{y}' for x,y in pts)
  # A white casing makes crossings legible. Dots alone indicate junctions.
  self.a.append(f'<path id="{id}_clearance" d="{path}" fill="none" stroke="white" stroke-width="11" stroke-linejoin="round"/>')
  self.a.append(f'<path id="{id}" d="{path}" fill="none" stroke="{C[kind]}" stroke-width="4" stroke-linejoin="round"'+(f' marker-end="url(#a_{kind})"' if arrow else '')+(f' stroke-dasharray="{dash or "12 8"}"' if kind=='ctrl' or dash else '')+'/>')
 def dot(self,x,y,kind='data'):self.a.append(f'<circle cx="{x}" cy="{y}" r="7" fill="{C[kind]}"/>')
 def badge(self,x,y,txt,kind='ctrl'):
  self.a.append(f'<circle cx="{x}" cy="{y}" r="27" fill="white" stroke="{C[kind]}" stroke-width="3"/>');self.text(x,y+12,txt,anchor='middle',color=C[kind])
 def legend(self,y=105):
  for x,k,t in [(60,'data','数据 / 载荷'),(485,'ctrl','控制 / 资格'),(935,'fwd','前递 / 反馈'),(1395,'kill','取消 / 停止')]:
   self.line('legend_'+k,[(x,y-12),(x+75,y-12)],k);self.text(x+95,y,t)
  self.text(1875,78,['●连接；无点交叉不连','同字母为同网连接'])
 def save(self,name):
  self.a.append('</svg>');(OUT/(name+'.svg')).write_text('\n'.join(self.a),encoding='utf-8')
  return {'file':name+'.svg','nodes':self.nodes,'nets':self.nets}

def overall():
 s=SVG('CPU整体控制与数据通路架构','AC1现有硬连线Pipeline CU与五级数据通路，逻辑功能分区不等于新增RTL模块。')
 s.text(60,58,'CPU整体控制与数据通路架构','title');s.legend()
 s.rect('core_boundary',40,135,2320,1075,stroke=C['data'],rx=18)
 s.text(65,180,'datapath_core  ·  同一clk  ·  rst同步高有效','head')
 s.rect('pipeline_cu',65,200,2270,605,fill='#F6F9FC',stroke=C['ctrl'])
 s.text(85,248,'Pipeline CU  硬连线控制区域','head')
 s.box('mode_fsm',90,270,910,175,'全局运行模式FSM', ['RUN / DRAIN_HALT / DRAIN_FAULT','HALTED / FAULTED  ·  标记到WB且排空才停止'],'ctrl')
 s.box('cross_stage_arbiter',1100,270,1205,175,'跨级冒险与事件仲裁', ['load_use；较老MEM故障优先；EX停止/分支','UPD：各级valid_next与kill；Reset最高优先'],'kill')
 s.line('events_to_mode',[(1100,315),(1000,315)],'kill',signals=['m_fault_event','x_fault_event','qualified_halt','drain_done'])
 s.text(1038,292,'事件',anchor='middle',color=C['kill'])
 # The common mode bus qualifies each stage; it is not an opcode sequencer.
 s.line('mode_bus',[(320,445),(320,472),(2240,472)],'ctrl',False,signals=['mode','mode_active','stop_pending'])
 s.text(110,466,'mode',color=C['ctrl'])
 s.line('arbitration_bus',[(1710,445),(1710,502),(150,502)],'kill',False,signals=GROUPS['UPD']+['load_use','frontend_kill','qualified_redirect'])
 s.line('arbitration_bus_w',[(1710,502),(2240,502)],'kill',False,signals=['w_valid_next'])
 s.dot(1710,502,'kill')
 xs=[90,535,980,1425,1870]
 heads=['IFCU 取指','IDCU 译码','EXCU 执行','MEMCU 访问','WBCU 写入']
 bodies=[['fetch_accept','pc_hold / im_en'],['u_decode: d_inst','真实源 + 控制意图'],['x_ctrl / 运算选择','redirect / halt请求'],['全16位EA检查','dm_en / dm_we'],['有效W槽资格','rf_we / z_we / cv_we']]
 for i,(x,h,b) in enumerate(zip(xs,heads,bodies)):
  s.box('stage_control_'+str(i),x,535,410,175,h,b,'ctrl')
  s.line('mode_stage_'+str(i),[(x+335,472),(x+335,535)],'ctrl',signals=['mode_active','mode'])
  s.dot(x+335,472,'ctrl')
  s.line('arb_stage_'+str(i),[(x+35,502),(x+35,535)],'kill',signals=GROUPS['UPD'])
  s.dot(x+35,502,'kill')
  s.line('control_to_data_'+str(i),[(x+210,710),(x+210,815)],'ctrl',signals=[['pc_hold','im_en'],['d_alu_op','d_reg_write'],['x_alu_a_sel','x_alu_b_sel'],['dm_en','dm_we'],['rf_we','z_we','cv_we']][i])
 for j,(x,label) in enumerate([(535,'d_ctrl'),(980,'CTRL_X'),(1425,'CTRL_M'),(1870,'CTRL_W')]):
  s.rect('ctrl_band_'+str(j),x,758,410,43,fill='#EAF2FA',stroke=C['ctrl'],rx=0)
  s.text(x+200,791,label,anchor='middle',color=C['ctrl'])
  if j<3:s.line('carried_ctrl_'+str(j),[(x+410,780),(x+445,780)],'ctrl',signals=GROUPS[['CTRL_X','CTRL_M','CTRL_W'][j]])
 # Datapath row and the four logical boundaries.
 dataheads=['IF  唯一PC','ID  读源与扩展','EX  计算与比较','MEM  存储访问','WB  架构写入']
 datalines=[['u_pc / PC_fetch16','+1 / hold / redirect'],['u_rf: 4×16, 2R1W','u_ext: imm8 → 16'],['u_forward / u_alu','u_target / 最新Z'],['EA16 / store_data16','外部同步DM接口'],['wb_data16选择','RF与Z/C/V写入']]
 for i,(x,h,b) in enumerate(zip(xs,dataheads,datalines)):
  s.box('datapath_stage_'+str(i),x,815,410,185,h,b)
  if i<4:
   bx=x+431
   stage_payloads=[['im_dout','d_pc','d_valid','d_fetch_fault'],['d_rd_value','d_rs_value','d_imm_ext','d_pc','d_rd','d_rs'],['alu_result','x_store_data','alu_eq','alu_c','alu_v','x_pc','x_rd'],['m_exec_value','m_cmp_z','m_c','m_v','m_pc','m_rd']]
   s.line('stage_data_'+str(i),[(x+410,895),(x+445,895)],signals=stage_payloads[i])
   s.a.append(f'<path d="M{bx},807 V1005" stroke="{C["line"]}" stroke-width="7"/>')
   s.text(bx,1053,['IF/ID','ID/EX','EX/MEM','MEM/WB'][i],anchor='middle')
  s.line('feedback_'+str(i),[(x+335,1000),(x+335,1100)],'fwd',False,signals=GROUPS['FB'])
  s.dot(x+335,1100,'fwd')
 s.line('feedback_bus',[(165,1100),(2320,1100),(2320,510),(2305,510),(2305,445)],'fwd',signals=GROUPS['FB'])
 for x in xs:s.dot(x+335,1100,'fwd')
 s.text(90,1150,'反馈FB：真实源/目的与use、valid/fault、eq/Z候选、地址范围、停止标记/请求及valid_next → 事件与排空判断')
 # Explicit carried-control flow; not a duplicate set of state registers.
 s.text(90,1193,'上方控制带与下方数据线共用四个流水边界：数据、pc、valid/fault与剩余控制属于同一条指令。',color=C['ctrl'])
 s.box('external_im',90,1250,680,175,'外部同步IM · 256×16',['im_addr16 / im_en → IM','IM → im_dout16 (= d_inst)'],dash='12 8')
 s.box('external_dm',1200,1250,760,175,'外部同步DM · 256×16',['dm_addr16 / dm_din16 / dm_en / dm_we','DM → dm_dout16 (= w_load_data)'],dash='12 8')
 s.line('im_ports_request',[(140,1000),(140,1225),(180,1225),(180,1250)],signals=['im_addr','im_en'])
 s.line('im_ports_return',[(680,1250),(680,1217),(720,1217),(720,1000)],signals=['im_dout'])
 s.line('dm_ports_request',[(1600,1000),(1600,1250)],signals=['dm_addr','dm_din','dm_en','dm_we'])
 s.line('dm_ports_return',[(1960,1385),(2295,1385),(2295,1000)],signals=['dm_dout'])
 s.badge(1040,405,'S','kill');s.line('mode_status',[(1000,405),(1013,405)],'kill',False,signals=['halted','fault'])
 s.badge(2040,1263,'S','kill');s.text(2000,1330,['halted / fault','全局模式输出'],color=C['kill'])
 s.text(90,1475,'逻辑分区≠新增模块；CTRL/FB/UPD是信号组，S为同网标记。同步IM/DM输出承担数据边界，不加IR/MDR。',color=C['muted'])
 return s.save('01_CPU整体架构')

def detailed():
 s=SVG('五级Datapath详细连接','AC1现有数据、前递、分支、写回与四个逻辑流水边界。')
 s.text(60,58,'五级Datapath详细连接','title');s.legend()
 xs=[65,525,985,1445,1905]
 for i,(x,st) in enumerate(zip(xs,['IF','ID','EX','MEM','WB'])):
  s.rect('stage_bg_'+st,x,140,430,1085,fill='#FAFCFE',stroke='#D4DEE6')
  s.text(x+215,184,st,'head','middle')
 for x,name in [(510,'IF/ID'),(970,'ID/EX'),(1430,'EX/MEM'),(1890,'MEM/WB')]:
  s.a.append(f'<path id="boundary_{name.replace("/","_")}" d="M{x},245 V1210" stroke="{C["line"]}" stroke-width="7" stroke-dasharray="14 10"/>')
  s.text(x,230,name,'head','middle')
 # IF: unique state and combinational next value logic.
 s.box('pc_select',95,295,360,145,'PC下一值选择',['重定向 > 保持 > +1'])
 s.box('pc_state',95,525,360,145,'u_pc · 唯一PC',['PC_fetch16','同步rst优先'])
 s.box('pc_plus_one',95,755,360,130,'顺序+1',['PC_fetch+1 低16位'])
 s.box('sync_im',95,965,360,210,'外部同步IM',['im_addr16 / im_en','im_dout16 已寄存','en=0保持输出'],dash='12 8')
 s.line('pc_select_to_pc',[(275,440),(275,525)],signals=['PC_fetch'])
 s.line('pc_to_increment',[(275,670),(275,755)],signals=['PC_fetch'])
 s.line('pc_increment_feedback',[(95,815),(78,815),(78,365),(95,365)],signals=['PC_fetch'])
 s.line('pc_to_im',[(410,670),(470,670),(470,945),(280,945),(280,965)],signals=['im_addr'])
 s.text(120,925,'IFCU: im_en / pc_hold',color=C['ctrl'])
 # ID: instruction identity, RF combinational read (bypass within the module).
 s.box('decode_fields',555,295,360,145,'u_decode 译码',['inst → Rd/Rs/imm','d_ctrl → CTRL_X'])
 s.box('rf_and_bypass',555,535,360,210,'u_rf · 4×16',['Rd/Rs两读，W一写','含WB→ID同址旁路','Rd值 / Rs值 各16'])
 s.box('immediate_ext',555,930,360,145,'u_ext · 8→16',['d_imm_signed选择','d_imm_ext16'])
 s.line('im_dout_to_decode',[(455,1045),(490,1045),(490,360),(555,360)],signals=['im_dout','d_inst'])
 s.text(555,520,'d_rd2 / d_rs2')
 s.line('decode_to_rf',[(890,440),(890,535)],signals=['d_rd','d_rs'])
 s.line('decode_imm_to_ext',[(915,395),(940,395),(940,905),(730,905),(730,930)],signals=['d_imm'])
 s.line('decode_mode_to_ext',[(915,425),(925,425),(925,990),(915,990)],'ctrl',signals=['d_imm_signed'])
 # Forwarding is separate for Rd and Rs, before the ALU input selectors.
 s.box('operand_forward',1015,535,360,180,'u_forward',['前递：M > W > ID','Rd / Rs 独立前递16'])
 s.line('saved_rd_rs_to_forward',[(915,630),(1015,630)],signals=['x_rd_value','x_rs_value'])
 s.text(930,603,'2×16',color=C['data'])
 s.box('a_mux',1015,785,170,110,'选A',['0,Rd,Rs'])
 s.box('b_mux',1205,785,170,110,'选B',['0,Rs,I'])
 s.line('fwd_to_a',[(1095,715),(1095,785)],signals=['rd_fwd','rs_fwd'])
 s.line('fwd_to_b',[(1295,715),(1295,785)],signals=['rs_fwd'])
 s.line('imm_to_b',[(915,1010),(952,1010),(952,753),(1350,753),(1350,785)],signals=['x_imm_ext'])
 s.box('alu',1015,955,360,210,'u_alu · 16位',['ADD/SUB: 17位+','PASS_B,AND,OR','独立eq；C/V候选'])
 s.line('alu_a',[(1095,895),(1095,955)],signals=['alu_a'])
 s.line('alu_b',[(1295,895),(1295,955)],signals=['alu_b'])
 # EX branch target/Z selection occupy the upper area and return by named net.
 s.box('z_select_branch',1015,295,360,175,'Z选择 / u_target',['CMP: M > W > Z','JUMP绝对 / JZ相对'])
 s.badge(1035,500,'R','kill')
 s.line('branch_target_net',[(1035,470),(1035,473)],'kill',False,signals=['branch_target','qualified_redirect'])
 s.text(555,477,'x_pc16 / imm8 →')
 s.line('x_pc_imm_to_target',[(970,475),(995,475),(995,440),(1015,440)],signals=['x_pc','x_imm_ext'])
 s.badge(300,260,'R','kill');s.line('redirect_to_pc',[(300,287),(300,295)],'kill',signals=['qualified_redirect','branch_target'])
 s.text(68,1240,'R：EX合格重定向回PC；JUMP=ZExt(imm8)，JZ=low16(x_pc+1+SExt(imm8))。',color=C['kill'])
 s.text(1500,1240,'load_use：PC/D保持，X bubble',color=C['ctrl'])
 # MEM exec and store data are distinct registered paths.
 s.box('m_exec',1475,535,360,145,'结果 / 地址传递',['m_exec_value16','随行eq/C/V各1'])
 s.line('alu_to_m',[(1375,1050),(1405,1050),(1405,575),(1475,575)],signals=['alu_result','m_exec_value','alu_eq','alu_c','alu_v'])
 s.text(1422,560,'19')
 s.box('ea_guard',1475,745,360,145,'完整EA范围检查',['EA[15:8]必须为0','dm_en / dm_we'],'ctrl')
 s.box('sync_dm',1475,965,360,210,'外部同步DM',['地址16 / 写数据16','MEM边沿读/写一次','dout → W加载值'],dash='12 8')
 s.line('ea_to_guard',[(1660,680),(1660,745)],signals=['m_exec_value'])
 s.line('ea_to_dm',[(1475,575),(1458,575),(1458,940),(1530,940),(1530,965)],signals=['dm_addr'])
 s.line('guard_to_enable',[(1810,890),(1810,965)],'ctrl',signals=['dm_en','dm_we'])
 s.line('store_data_to_mem',[(1335,715),(1390,715),(1390,1190),(1565,1190),(1565,1175)],signals=['x_store_data','m_store_data','dm_din'])
 s.text(1565,935,'STR数据16')
 # W stage mux and architectural state.
 s.box('write_qualify',1935,535,360,145,'WB写入资格',['W有效/无故障/活跃','rf_we,z_we,cv_we'],'ctrl')
 s.box('flags',1935,745,360,145,'u_flags · Z/C/V',['w_cmp_z,w_c,w_v','按z_we / cv_we写入'])
 s.box('wb_mux',1935,965,360,145,'WB结果MUX',['w_wb_sel','exec16 / load16'])
 s.line('exec_to_w',[(1835,575),(1862,575),(1862,945),(2015,945),(2015,965)],signals=['m_exec_value','w_exec_value'])
 s.line('load_to_w',[(1835,1045),(1935,1045)],signals=['dm_dout','w_load_data'])
 s.text(1850,1018,'16')
 s.line('wb_write_to_rf_net',[(2115,1110),(2115,1155)],'fwd',False,signals=['wb_data'])
 s.badge(2115,1183,'W','fwd');s.text(2157,1196,'16',color=C['fwd'])
 s.badge(735,810,'W','fwd');s.line('wb_to_id',[(735,783),(735,745)],'fwd',signals=['wb_data','w_rd','rf_we'])
 s.text(555,862,['W=wb_data16','w_rd2 / rf_we'],color=C['fwd'])
 s.line('w_controls_flags',[(2115,680),(2115,745)],'ctrl',signals=['z_we','cv_we'])
 s.line('flags_to_w',[(1835,645),(1850,645),(1850,815),(1935,815)],signals=['m_cmp_z','m_c','m_v','w_cmp_z','w_c','w_v'])
 # Explicit M/W forwarding source nets with the same labels at consumers.
 s.badge(1640,490,'M','fwd');s.line('m_value_fwd_source',[(1640,535),(1640,517)],'fwd',signals=['m_exec_value'])
 s.badge(1125,490,'M','fwd');s.line('m_to_ex',[(1125,517),(1125,535)],'fwd',signals=['m_exec_value'])
 s.badge(1235,490,'W','fwd');s.line('w_to_ex',[(1235,517),(1235,535)],'fwd',signals=['wb_data'])
 s.text(1475,295,['M/W按目标与资格选','M load阻断EA/旧W','寄存m_fault管前递','新访问故障走取消'],color=C['fwd'])
 s.text(1935,310,['Z反馈组 → EX','M/W.CMP与保存Z','有效且ZW才选候选'],color=C['fwd'])
 s.badge(2115,465,'Z','fwd');s.badge(1335,260,'Z','fwd')
 s.line('z_to_branch',[(1335,287),(1335,295)],'fwd',signals=['m_cmp_z','w_cmp_z','Z','z_effective'])
 # Four boundary payloads. Full CTRL definition remains in Word table15.
 cards=[
 ('d_payload',65,'① IF/ID',['pc16, valid/fetch_fault','d_inst=im_dout16','IM输出就是指令数据边界']),
 ('x_payload',650,'② ID/EX',['pc16, rd/rs各2','Rd值/Rs值/imm各16','valid/fault + CTRL_X']),
 ('m_payload',1235,'③ EX/MEM',['pc16, rd2, exec/store各16','cmp_z/c/v各1','valid/fault + CTRL_M']),
 ('w_payload',1820,'④ MEM/WB',['pc16, rd2, exec/load各16','cmp_z/c/v各1, store1','valid/fault + CTRL_W'])]
 for id,x,h,ls in cards:s.box(id,x,1280,515,195,h,ls,fill='#F1F5F8')
 return s.save('02_五级Datapath')

manifest={'baseline':'v1.6-timing-AC1','isa':'v1.5','editable':'native SVG text, shapes and paths','width':2400,'height':1500,'minimum_font_px':36,'signal_groups':GROUPS,'figures':[overall(),detailed()]}
for f in manifest['figures']:
 for n in f['nets']:
  for sig in n['signals']:assert re.search(r'\b'+re.escape(sig)+r'\b',rtl),(n['id'],sig)
(WORK/'figure_semantics.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print('BLOCK_SIGNAL_MAP_COMPLETE',len(MAP),'groups',len(GROUPS),'SVG_NATIVE_TEXT_COMPLETE',len(manifest['figures']))
