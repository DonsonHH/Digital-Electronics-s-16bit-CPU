from pathlib import Path
from html import escape
from PIL import ImageFont
import json,re
WORK=Path(__file__).parent
ROOT=Path(r'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电')
CORE=ROOT/'CPU核心设计';OUT=WORK/'figures';OUT.mkdir(exist_ok=True)
PREV=Path(r'C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261031_架构图更新_01a0c80f\本次修订与检查')
GROUPS=json.loads((PREV/'figure_semantics.json').read_text(encoding='utf-8'))['signal_groups']
MAP=json.loads((PREV/'block_signal_map.json').read_text(encoding='utf-8'))
for r in MAP['rows']:
 if r['block']=='操作数前递':r['outputs']='rd_fwd/rs_fwd各16；合格M非load > W的wb_data > ID/EX保存值；最近M load阻断旧W'
 if r['block']=='Z来源选择':r['outputs']='z_effective送branch_req条件，不进入u_target地址计算；M > W > 保存Z，候选0同样覆盖'
(WORK/'block_signal_map.json').write_text(json.dumps(MAP,ensure_ascii=False,indent=2),encoding='utf-8')
rtl='\n'.join(p.read_text(encoding='utf-8') for p in (CORE/'Vivado/rtl').glob('*') if p.suffix in ['.v','.sv'])
C={'data':'#24384B','ctrl':'#2867A5','fwd':'#087C7C','kill':'#BD4E26','muted':'#536477','line':'#BDCBD5','pale':'#F2F6F9'}
FONT=ImageFont.truetype(r'C:\Windows\Fonts\msyh.ttc',36);HEAD=ImageFont.truetype(r'C:\Windows\Fonts\msyhbd.ttc',40)
class SVG:
 def __init__(self,title,height=1500):
  self.title=title;self.height=height;self.bg=[];self.wires=[];self.shapes=[];self.labels=[];self.dots=[];self.nodes=[];self.nets=[];self.fits=[];self.texts=[]
 def rect(self,id,x,y,w,h,fill='white',stroke='line',dash=None,container=False,rx=10):
  out=f'<rect id="{id}" x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{C.get(stroke,stroke)}" stroke-width="3"'+(f' stroke-dasharray="{dash}"' if dash else '')+'/>'
  (self.bg if container else self.shapes).append(out);self.nodes.append(dict(id=id,x=x,y=y,width=w,height=h,container=container,stroke=stroke))
 def text(self,x,y,txt,head=False,color='data',anchor='start',step=46):
  lines=txt if isinstance(txt,(list,tuple)) else [txt]
  font=HEAD if head else FONT
  for i,t in enumerate(lines):
   left,top,right,bottom=font.getbbox(str(t),anchor='ls');shift=font.getlength(str(t))/2 if anchor=='middle' else 0
   self.texts.append(dict(text=str(t),bbox=[x+left-shift,y+i*step+top,x+right-shift,y+i*step+bottom]))
  self.labels.append(f'<text x="{x}" y="{y}" font-size="{40 if head else 36}" font-weight="{700 if head else 400}" text-anchor="{anchor}" fill="{C.get(color,color)}">'+''.join(f'<tspan x="{x}" dy="{0 if i==0 else step}">{escape(str(t))}</tspan>' for i,t in enumerate(lines))+'</text>')
 def box(self,id,x,y,w,h,title,lines=(),kind='data',fill='white',dash=None):
  for txt,font in [(title,HEAD)]+[(v,FONT) for v in lines]:
   if font.getlength(txt)>w-28:self.fits.append((id,txt,round(font.getlength(txt)),w-28))
  if lines and 84+42*(len(lines)-1)>h-9:self.fits.append((id,'height',84+42*(len(lines)-1),h-9))
  self.rect(id,x,y,w,h,fill,kind,dash);self.text(x+14,y+44,title,True)
  if lines:self.text(x+14,y+84,lines,step=42)
 def line(self,id,pts,kind='data',signals=(),arrow=True):
  assert all(re.search(r'\b'+re.escape(n)+r'\b',rtl) for n in signals),(id,signals)
  path='M '+' L '.join(f'{x},{y}' for x,y in pts)
  self.wires.extend([f'<path d="{path}" fill="none" stroke="white" stroke-width="11" stroke-linejoin="round"/>',f'<path id="{id}" d="{path}" fill="none" stroke="{C[kind]}" stroke-width="4" stroke-linejoin="round"'+(' stroke-dasharray="12 8"' if kind=='ctrl' else '')+(f' marker-end="url(#a_{kind})"' if arrow else '')+'/>'])
  self.nets.append(dict(id=id,signals=list(signals),points=pts,kind=kind))
 def dot(self,x,y,kind='data'):self.dots.append(f'<circle cx="{x}" cy="{y}" r="7" fill="{C[kind]}"/>')
 def mux(self,id,x,y,w,h,letter):
  self.shapes.append(f'<path id="{id}" d="M{x},{y} L{x+w},{y+25} V{y+h-25} L{x},{y+h} Z" fill="white" stroke="{C["data"]}" stroke-width="3"/>')
  self.nodes.append(dict(id=id,x=x,y=y,width=w,height=h,container=False));self.text(x+w/2,y+h/2+12,letter,True,anchor='middle')
 def legend(self):
  self.text(60,57,self.title,True)
  for x,k,t in [(60,'data','数据 / 载荷'),(500,'ctrl','控制 / 资格'),(950,'fwd','前递 / 反馈'),(1410,'kill','取消 / 停止')]:
   self.line('legend_'+k,[(x,94),(x+75,94)],k);self.text(x+95,107,t)
  self.text(1880,84,['●连接；无点交叉不连','浅蓝带为现有流水边界'],step=42)
 def save(self,name):
  defs='<defs>'+''.join(f'<marker id="a_{k}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="3" markerHeight="3" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 Z" fill="{v}"/></marker>' for k,v in C.items())+'</defs>'
  contents=[f'<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="{self.height}" viewBox="0 0 2400 {self.height}"><title>{escape(self.title)}</title>',defs,'<style>text{font-family:"Microsoft YaHei","Noto Sans CJK SC",Arial,sans-serif}</style>',f'<rect width="2400" height="{self.height}" fill="white"/>',*self.bg,*self.wires,*self.shapes,*self.labels,*self.dots,'</svg>']
  (OUT/(name+'.svg')).write_text('\n'.join(contents),encoding='utf-8')
  for f in self.fits:print('FIT',*f)
  return dict(file=name+'.svg',width=2400,height=self.height,nodes=self.nodes,nets=self.nets,text_fit_warnings=self.fits,text_boxes=self.texts)

def overall():
 s=SVG('CPU整体控制与数据通路架构');s.legend()
 s.rect('core',40,140,2320,1090,stroke='data',container=True);s.text(65,185,'datapath_core  ·  同一clk  ·  rst同步高有效',True)
 s.rect('cu',65,205,2270,615,fill='#F6F9FC',stroke='ctrl',container=True);s.text(85,248,'Pipeline CU  ·  当前控制意图 + 流水资格 + 跨级协调',True)
 s.box('mode_fsm',90,270,910,165,'全局运行模式FSM',['RUN / DRAIN_HALT / DRAIN_FAULT','HALTED / FAULTED：停止标记到WB且排空'],'ctrl')
 s.box('arbiter',1100,270,1205,165,'跨级冒险与事件仲裁',['Reset > MEM fault > EX停止 > redirect > load_use','UPD：推进 / 保持 / bubble / 年轻取消'],'kill')
 s.line('events_mode',[(1100,320),(1000,320)],'kill',['m_fault_event','x_fault_event','qualified_halt','drain_done']);s.text(1040,304,'事件',anchor='middle',color='kill')
 s.line('mode_bus',[(320,435),(320,470),(2300,470)],'ctrl',['mode','mode_active','stop_pending'],False);s.text(95,480,'模式资格',color='ctrl')
 s.line('upd_bus',[(1710,435),(1710,510),(100,510)],'kill',GROUPS['UPD'],False);s.line('upd_bus_right',[(1710,510),(2300,510)],'kill',GROUPS['UPD'],False);s.dot(1710,510,'kill')
 xs=[90,535,980,1425,1870]
 for i,x in enumerate(xs[:-1]):
  bx=[520,965,1410,1855][i]
  s.rect('boundary_'+str(i),bx-11,535,22,285,fill='#DBE9F5',stroke='#A2B7C9',container=True,rx=0)
  s.rect('boundary_'+str(i)+'_data',bx-11,866,22,204,fill='#DBE9F5',stroke='#A2B7C9',container=True,rx=0)
  s.text(bx,853,['IF/ID','ID/EX','EX/MEM','MEM/WB'][i],anchor='middle')
 s.text(105,584,['PC_fetch / range','前端资格反馈'],color='muted')
 for i,label in enumerate(['译码 d_ctrl','CTRL_X','CTRL_M','CTRL_W']):
  x=xs[i+1]+30;s.box('control_input_'+str(i),x,550,350,82,label,kind='ctrl',fill='#EAF2FA')
  if i<3:s.line('carry_ctrl_'+str(i),[(x+350,589),(xs[i+2]+30,589)],'ctrl',GROUPS[['CTRL_X','CTRL_M','CTRL_W'][i]])
  sigs=[n.replace('x_','d_',1) for n in GROUPS['CTRL_X']] if i==0 else GROUPS[['CTRL_X','CTRL_X','CTRL_M','CTRL_W'][i]]
  s.line('ctrl_to_stage_'+str(i+1),[(x+175,632),(x+175,665)],'ctrl',sigs)
 hs=['IFCU 取指资格','IDCU 发射资格','EXCU 执行资格','MEMCU 访问资格','WBCU 写入资格']
 ls=[['fetch_accept/pc_hold','im_en'],['保持 / 取消 / 发射','x_valid_next'],['ALU选择 / redirect','halt / fault请求'],['完整EA与有效槽','dm_en / dm_we'],['有效W槽 + 写入意图','rf_we / z_we / cv_we']]
 dh=['IF  唯一PC','ID  读源与扩展','EX  计算与决策','MEM  访存或传递','WB  架构写入'];dl=[['u_pc / PC_fetch16','+1 / hold / redirect'],['u_rf: 4×16, 2R1W','u_ext: imm8 → 16'],['u_forward / u_alu','Z选择 / u_target'],['EA16 / store_data16','同步DM访问资格'],['wb_data16选择','RF与Z/C/V写入']]
 for i,x in enumerate(xs):
  s.box('stage_control_'+str(i),x,665,410,145,hs[i],ls[i],'ctrl')
  for xx,y,kind,sigs in [(x+400,470,'ctrl',['mode','mode_active']),(x+10,510,'kill',GROUPS['UPD'])]:
   s.line('qual_'+str(i)+'_'+kind,[(xx,y),(xx,665)],kind,sigs);s.dot(xx,y,kind)
  s.line('enable_to_datapath_'+str(i),[(x+205,810),(x+205,880)],'ctrl',[['pc_hold','im_en'],['x_valid_next'],['x_alu_a_sel','x_alu_b_sel','qualified_redirect'],['dm_en','dm_we'],['rf_we','z_we','cv_we']][i])
  s.box('data_stage_'+str(i),x,880,410,185,dh[i],dl[i])
  if i<4:s.line('data_next_'+str(i),[(x+410,950),(x+445,950)],signals=[['im_dout','d_pc'],['d_rd_value','d_rs_value','d_imm_ext'],['alu_result','x_store_data','alu_eq','alu_c','alu_v'],['m_exec_value','m_cmp_z','m_c','m_v']][i])
  s.line('fb_'+str(i),[(x+335,1065),(x+335,1125)],'fwd',GROUPS['FB'],False)
 s.line('feedback_bus',[(145,1125),(2320,1125),(2320,475),(2305,475),(2305,435)],'fwd',GROUPS['FB'])
 for x in xs:s.dot(x+335,1125,'fwd')
 for x,t in [(200,'PC/range'),(540,'源/use'),(985,'eq/分支/停止'),(1430,'EA/fault'),(1875,'目标/valid/标记')]:s.text(x,1095,t,color='fwd')
 s.text(200,1180,'FB → 事件/排空',color='fwd')
 s.box('im',90,1270,680,155,'外部同步IM · 256×16',['im_addr16 / im_en → IM','IM → im_dout16 (= d_inst)'],dash='12 8')
 s.box('dm',1200,1270,760,155,'外部同步DM · 256×16',['dm_addr16 / dm_din16 / dm_en / dm_we','DM → dm_dout16 (= w_load_data)'],dash='12 8')
 s.line('im_req',[(145,1065),(145,1250),(180,1250),(180,1270)],signals=['im_addr','im_en']);s.line('im_ret',[(680,1270),(680,1245),(720,1245),(720,1065)],signals=['im_dout'])
 s.line('dm_req',[(1600,1065),(1600,1270)],signals=['dm_addr','dm_din','dm_en','dm_we']);s.line('dm_ret',[(1960,1390),(2290,1390),(2290,1065)],signals=['dm_dout'])
 s.text(2000,1300,['halted / fault','由mode译出'],color='kill')
 s.line('mode_status_outputs',[(90,400),(70,400),(70,1438),(2080,1438),(2080,1370)],'kill',['halted','fault'])
 s.text(90,1480,'IFCU至WBCU是core职责；u_*为RTL实例；浅蓝带是既有流水状态。IM/DM输出承担数据边界，不加IR/MDR。',color='muted')
 return s.save('01_CPU整体架构')

def detailed():
 s=SVG('五级Datapath详细连接',1680);s.legend()
 for x,w,name in [(60,340,'IF'),(450,350,'ID'),(870,640,'EX'),(1550,350,'MEM'),(1980,350,'WB')]:
  s.rect('stage_'+name,x,140,w,1265,fill='#FAFCFE',stroke='none',container=True);s.text(x+w/2,182,name,True,anchor='middle')
 for i,(x,n) in enumerate([(420,'IF/ID'),(840,'ID/EX'),(1510,'EX/MEM'),(1940,'MEM/WB')]):
  top=535 if i==0 else 300
  s.rect('boundary_'+str(i),x-18,top,36,1405-top,fill='#DBE9F5',stroke='#A2B7C9',container=True,rx=0);s.text(x,218,n,True,anchor='middle')
 s.rect('pc16_scope',80,720,300,320,stroke='data',container=True);s.text(95,762,'pc16内部',True)
 s.box('pc_next',100,795,260,150,'下一值选择',['重定向>保持','+1顺序推进']);s.box('pc_state',100,955,260,75,'PC状态')
 s.line('pc_next_state',[(230,945),(230,955)],signals=['PC_fetch']);s.line('pc_hold_plus1',[(100,990),(88,990),(88,850),(100,850)],signals=['PC_fetch']);s.text(92,1080,['rst > redirect','    > hold > +1'],color='ctrl',step=42)
 s.box('im',80,1140,300,175,'外部同步IM',['addr16 / im_en','dout16 已寄存'],dash='12 8');s.line('pc_im',[(360,990),(390,990),(390,1130),(280,1130),(280,1140)],signals=['im_addr'])
 s.box('decode',470,540,310,150,'u_decode',['Rd/Rs/imm8','源与控制意图']);s.box('rf',470,820,310,230,'u_rf · 4×16',['Rd/Rs两读一写','内含WB→ID旁路','R0普通可写']);s.box('ext',470,1150,310,140,'u_ext · 8→16',['零/符号扩展','d_imm_ext16'])
 s.line('im_inst',[(380,1230),(430,1230),(430,610),(470,610)],signals=['im_dout','d_inst']);s.line('decode_rf_addr',[(740,690),(740,820)],signals=['d_rd','d_rs']);s.text(475,795,'d_rd2 / d_rs2')
 s.line('imm8_ext',[(780,610),(795,610),(795,1120),(630,1120),(630,1150)],signals=['d_imm']);s.line('sign_ext',[(780,655),(810,655),(810,1210),(780,1210)],'ctrl',['d_imm_signed'])
 s.box('target',1060,350,420,120,'u_target 目标地址',['JUMP绝对 / JZ相对']);s.text(530,405,'x_pc16 / imm8');s.line('target_pc_imm',[(858,420),(1060,420)],signals=['x_pc','x_imm_ext'])
 s.line('target_relative_mode',[(858,460),(1040,460),(1040,450),(1060,450)],'ctrl',['x_jump_z']);s.text(600,448,'x_jump_z',color='ctrl')
 s.box('z_mux',900,590,260,150,'Z候选选择',['M>W>保存Z','仅合格CMP'],'fwd');s.box('branch_qual',1220,590,260,150,'分支判定',['branch_req','合格redirect1'],'kill');s.line('z_to_request',[(1160,665),(1220,665)],'fwd',['z_effective'])
 s.line('x_branch_controls',[(858,755),(1200,755),(1200,710),(1220,710)],'ctrl',['x_jump_abs','x_jump_z','x_valid','x_fault'])
 s.line('target_to_pc',[(1480,420),(1500,420),(1500,340),(30,340),(30,835),(100,835)],signals=['branch_target']);s.text(65,308,'branch_target16 → PC选择输入')
 s.line('redirect_to_pc',[(1480,665),(1500,665),(1500,515),(45,515),(45,870),(100,870)],'kill',['qualified_redirect']);s.text(65,385,'qualified_redirect1',color='kill');s.text(65,445,['JUMP=ZExt(imm8)','JZ=x_pc+1+SExt(imm8)'])
 s.rect('forward_scope',895,760,265,420,fill='#F2FAF9',stroke='fwd',container=True);s.text(910,803,'u_forward',True);s.box('rd_forward',910,820,230,100,'Rd前递',['rd_fwd16'],'fwd');s.box('rs_forward',910,1060,230,100,'Rs前递',['rs_fwd16'],'fwd');s.text(910,980,['M > W >','ID/EX保存值'],color='fwd',step=42)
 s.line('x_rd_saved',[(780,880),(820,880),(820,900),(910,900)],signals=['x_rd_value']);s.line('x_rs_saved',[(780,995),(820,995),(820,1140),(910,1140)],signals=['x_rs_value']);s.line('fwd_x_tags',[(858,780),(895,780)],'ctrl',['x_use_rd','x_use_rs','x_rd','x_rs'])
 s.line('W_return',[(2300,980),(2345,980),(2345,245),(865,245),(865,1115),(910,1115)],'fwd',['wb_data']);s.line('W_to_rd',[(865,875),(910,875)],'fwd',['wb_data']);s.dot(865,875,'fwd');s.text(1985,300,'W: wb_data16',color='fwd')
 s.line('M_return',[(1540,980),(1540,310),(885,310),(885,1090),(910,1090)],'fwd',['m_exec_value']);s.line('M_to_rd',[(885,850),(910,850)],'fwd',['m_exec_value']);s.dot(885,850,'fwd');s.text(1000,290,'M: exec16（非load）',color='fwd');s.text(1570,350,['前递检查目标/use','有效/RW/寄存fault','M load阻断旧W'],color='fwd')
 s.mux('a_mux',1190,800,90,130,'A');s.mux('b_mux',1190,1040,90,130,'B');s.line('zero_a',[(1235,785),(1235,800)]);s.text(1235,774,'0',anchor='middle');s.line('zero_b',[(1235,1025),(1235,1040)]);s.text(1235,1013,'0',anchor='middle')
 s.line('rd_to_a',[(1140,875),(1190,875)],signals=['rd_fwd']);s.line('rd_store',[(1165,875),(1165,1260),(1570,1260)],signals=['x_store_data','m_store_data','dm_din']);s.dot(1165,875);s.text(920,1245,'store_data16')
 s.line('rs_to_a',[(1140,1115),(1180,1115),(1180,900),(1190,900)],signals=['rs_fwd']);s.line('rs_to_b',[(1180,1115),(1190,1115)],signals=['rs_fwd']);s.dot(1180,1115)
 s.line('imm_to_b',[(780,1230),(815,1230),(815,1325),(1235,1325),(1235,1170)],signals=['x_imm_ext']);s.text(925,1305,'x_imm_ext16 → B')
 s.box('alu',1310,900,170,230,'u_alu',['结果16','eq独立','C/V各1']);s.line('a_to_alu',[(1280,870),(1295,870),(1295,970),(1310,970)],signals=['alu_a']);s.line('b_to_alu',[(1280,1115),(1295,1115),(1295,1060),(1310,1060)],signals=['alu_b']);s.line('result_to_m',[(1480,980),(1570,980)],signals=['alu_result','m_exec_value']);s.dot(1540,980)
 s.box('ea_guard',1570,900,310,150,'MEM访问资格',['EA[15:8]=0','有效且无故障'],'ctrl');s.box('dm',1570,1130,310,180,'外部同步DM',['addr16 / data16','MEM边沿读或写','dout16 已寄存'],dash='12 8')
 s.line('M_control_input',[(1528,1020),(1570,1020)],'ctrl',['m_valid','m_fault','m_mem_read','m_mem_write'])
 s.line('ea_dm_addr',[(1540,980),(1540,1185),(1570,1185)],signals=['dm_addr']);s.line('ea_enable',[(1725,1050),(1725,1130)],'ctrl',['dm_en','dm_we']);s.text(1570,1100,'DM使能',color='ctrl')
 s.line('exec_to_w',[(1540,980),(1540,860),(1975,860),(1975,950),(2000,950)],signals=['m_exec_value','w_exec_value']);s.dot(1540,980);s.text(1600,845,'exec_value16')
 s.box('wb_mux',2000,900,300,180,'WB结果选择',['w_wb_sel','exec16/load16','wb_data16']);s.line('dm_load_to_w',[(1880,1220),(1915,1220),(1915,1110),(2150,1110),(2150,1080)],signals=['dm_dout','w_load_data']);s.text(2000,1155,'dm_dout16')
 s.box('flags',2000,1190,300,145,'u_flags',['Z / C / V','z_we / cv_we']);s.line('rf_writeback',[(2345,980),(2345,1410),(450,1410),(450,1080),(620,1080),(620,1050)],'fwd',['wb_data']);s.dot(2345,980,'fwd');s.text(480,1370,'wb_data16 → RF',color='fwd');s.text(1020,1370,'w_rd2 / rf_we',color='ctrl')
 s.line('cmp_cv_pipeline',[(1400,1130),(1400,1370),(1970,1370),(1970,1250),(2000,1250)],signals=['alu_eq','alu_c','alu_v','m_cmp_z','m_c','m_v','w_cmp_z','w_c','w_v']);s.text(1580,1358,'eq/C/V各1')
 s.line('M_Z_return',[(1895,1370),(1895,500),(930,500),(930,590)],'fwd',['m_cmp_z']);s.dot(1895,1370,'fwd');s.line('W_Z_return',[(1960,1370),(1960,530),(1010,530),(1010,590)],'fwd',['w_cmp_z']);s.dot(1960,1370,'fwd');s.line('saved_Z_return',[(2300,1250),(2375,1250),(2375,560),(1090,560),(1090,590)],'fwd',['Z'])
 s.text(2000,365,['m_cmp_z1（M）','w_cmp_z1（W）','Z1（已保存）'],color='fwd')
 s.box('wb_control',2000,620,300,190,'WB级控制',['W控制与资格','RF / Z / CV使能'],'ctrl')
 s.line('W_control_input',[(1958,700),(2000,700)],'ctrl',GROUPS['CTRL_W']+['w_valid','w_fault','w_rd'])
 s.line('W_control_trunk',[(2300,750),(2320,750),(2320,1220),(2300,1220)],'ctrl',['rf_we','z_we','cv_we','w_rd'])
 s.line('rf_write_control',[(2320,1220),(2320,1390),(465,1390),(465,1100),(670,1100),(670,1050)],'ctrl',['w_rd','rf_we']);s.dot(2320,1220,'ctrl')
 cards=[(60,'① IF/ID',['pc16 / valid / fetch_fault','inst16=IM寄存输出']),(650,'② ID/EX',['pc,rd/rs,源值,imm16','valid/fault + CTRL_X']),(1235,'③ EX/MEM',['exec/store16,pc/rd,eq/C/V','valid/fault + CTRL_M']),(1820,'④ MEM/WB',['exec/load16,pc/rd,eq/C/V','valid/fault/store + CTRL_W'])]
 for i,(x,h,ls) in enumerate(cards):
  s.box('payload_'+str(i),x,1430,515,145,h,ls,fill='#F1F5F8');bx=[420,840,1510,1940][i];s.line('payload_attach_'+str(i),[(bx,1405),(bx,1420),(x+257,1420),(x+257,1430)],'ctrl',[],False)
 for x,h,t in [(60,'① ADD→ADD相关','M→EX前递，0停顿；WB才写RF'),(850,'② LDR→STR相关','前端停1拍，再W→EX；MEM写DM'),(1640,'③ CMP→JZ','最新Z决定条件；EX取分支才清年轻槽')]:s.text(x,1618,h,True);s.text(x,1664,t)
 return s.save('02_五级Datapath')

figs=[overall(),detailed()]
(WORK/'figure_semantics.json').write_text(json.dumps({'revision':'2026-10-31-refined','baseline':'v1.6-timing-AC1','ISA':'v1.5','signal_groups':GROUPS,'figures':figs},ensure_ascii=False,indent=2),encoding='utf-8')
print('FIGURES_BUILT',len(figs),'mapping_rows',len(MAP['rows']))
