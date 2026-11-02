"""Translate the reviewed complete SVGs and retain editable native geometry."""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET
from PIL import ImageFont

B=Path(__file__).resolve().parent
NS='http://www.w3.org/2000/svg'
ET.register_namespace('',NS)
EN={
'CPU整体控制与数据通路架构':'Complete CPU control and datapath',
'数据 / 载荷':'Data / payload','控制 / 资格':'Control / eligibility','前递 / 反馈':'Forwarding / feedback','取消 / 停止':'Cancel / stop',
'●连接；无点交叉不连':'Dot = connected; crossing alone = no connection','浅蓝带为现有流水边界':'Blue bands = existing pipeline boundaries',
'datapath_core 执行核心（CU + DP） · 同一clk · rst同步高有效':'datapath_core (CU + DP) / one clock / synchronous active-high reset',
'Pipeline CU  ·  当前控制意图 + 流水资格 + 跨级协调':'Pipeline CU / control intentions, eligibility and coordination',
'全局运行模式FSM':'Global mode FSM','HALTED / FAULTED：停止标记到WB且排空':'HALTED / FAULTED: stop token reaches WB; pipeline empty',
'跨级冒险与事件仲裁':'Cross-stage hazards and event arbitration',
'Reset > MEM fault > EX停止 > redirect > load_use':'Reset > MEM fault > EX stop > redirect > load-use',
'UPD：推进 / 保持 / bubble / 年轻取消':'UPD: advance / hold / bubble / kill younger slots',
'事件':'Events','模式资格':'Mode eligibility','前端资格反馈':'Front-end eligibility',
'IDCU 译码 d_ctrl':'IDCU decode d_ctrl','IFCU 取指资格':'IFCU fetch eligibility','IF  唯一PC':'IF: single PC',
'IDCU 发射资格':'IDCU issue eligibility','保持 / 取消 / 发射':'Hold / cancel / issue','ID  读源与扩展':'ID: read and extend',
'EXCU 执行资格':'EXCU execution eligibility','ALU选择 / redirect':'ALU select / redirect','halt / fault请求':'halt / fault request',
'EX  计算与决策':'EX: compute and decide','Z选择 / u_target':'Z select / u_target',
'MEMCU 访问资格':'MEMCU access eligibility','完整EA与有效槽':'Full EA / valid slot','MEM  访存或传递':'MEM: access or pass',
'同步DM访问资格':'Synchronous DM eligibility','WBCU 写入资格':'WBCU write eligibility','有效W槽 + 写入意图':'Valid W / write intention',
'WB  架构写入':'WB: architectural writes','wb_data16选择':'wb_data16 selection','RF与Z/C/V写入':'RF and Z/C/V writes',
'源/use':'Sources / use','eq/分支/停止':'eq / branch / stop','目标/valid/标记':'Destination / valid / tags','FB → 事件/排空':'Feedback: events / drain',
'外部同步IM · 256×16':'External synchronous IM / 256 x 16','外部同步DM · 256×16':'External synchronous DM / 256 x 16',
'由mode译出':'Decoded from mode',
'局部CU为职责；CW_X/M/W为既有字段组；u_*为实例。浅蓝带同存数据/控制/标签，IM/DM承担数据边界，不加IR/MDR。':'Local CU names denote responsibilities. CW_X/M/W are existing fields; u_* are instances. Data, control and tags align; no added IR/MDR.',
'五级Datapath详细连接':'Complete five-stage datapath',
'pc16内部':'Inside pc16','下一值选择':'Next-PC select','重定向>保持':'Redirect > hold','+1顺序推进':'+1 sequential advance','PC状态':'PC state',
'外部同步IM':'External sync IM','dout16 已寄存':'Registered dout16','源与控制意图':'Sources / intentions',
'Rd/Rs两读一写':'Rd/Rs: 2 reads, 1 write','内含WB→ID旁路':'Includes WB-to-ID bypass','R0普通可写':'R0 is writable',
'零/符号扩展':'Zero / sign extension','u_target 目标地址':'u_target branch target','JUMP绝对 / JZ相对':'JUMP absolute / JZ relative',
'Z候选选择':'Z candidate select','M>W>保存Z':'M > W > saved Z','仅合格CMP':'Eligible CMP only','分支判定':'Branch decision',
'仲裁后redirect':'Qualified redirect','branch_target16 → PC选择输入':'branch_target16 to next-PC select',
'Rd前递':'Rd forwarding','Rs前递':'Rs forwarding','ID/EX保存值':'Saved ID/EX value','M: exec16（非load）':'M: exec16 (not load)',
'前递检查目标/use':'Check dest / use','有效/RW/寄存fault':'Valid / RW / producer fault','M load阻断旧W':'M load blocks older W',
'结果16':'Result16','eq候选':'eq candidate','C/V候选':'C/V candidates','MEM访问资格':'MEM access eligibility','有效且无故障':'Valid and fault-free',
'外部同步DM':'External sync DM','MEM边沿读或写':'Read / write at MEM edge','DM使能':'DM enables','WB结果选择':'WB result select',
'eq/C/V各1':'eq / C / V: 1 bit each','Z1（已保存）':'Saved Z1','WB级控制':'WB stage control','W控制与资格':'W intentions / eligibility',
'RF / Z / CV使能':'RF / Z / CV enables','inst16=IM寄存输出':'inst16 = registered IM output','pc,rd/rs,源值,imm16':'pc, rd/rs, source values, imm16',
'① ADD→ADD相关':'1. ADD to ADD dependency','M→EX前递，0停顿；WB才写RF':'M-to-EX: 0 stalls; RF write at WB',
'② 默认AC1 LDR→STR':'2. Default AC1: LDR to STR','前端停1拍，再W→EX；MEM写DM':'Hold front 1 cycle; W-to-EX; DM write in MEM',
'最新Z决定条件；EX取分支才清年轻槽':'Newest Z selects condition; accepted EX redirect kills younger slots',
'文件启动系统与停止观测':'File-boot system and stop observation','clk 同域 · rst 同步高有效':'One clk / synchronous active-high rst',
'IM_INIT_FILE / DM_INIT_FILE  →  配置时写入初值':'IM_INIT_FILE / DM_INIT_FILE: initialization at configuration',
'完整 256 字镜像；核心 reset 不重载镜像，也不清除已提交 DM':'Full 256-word images; core reset preserves committed DM and does not reload files',
'同步 IM':'Synchronous IM','一拍读':'One-cycle read','en=0 输出保持':'en=0: hold output','dout 为 D 边界':'dout supplies D boundary',
'原前递、停顿、取消与排空逻辑':'Forwarding, hold, flush and drain','ISA v1.5 · 原架构写入边沿':'ISA v1.5 / original write edges',
'reason_X / M / W 只随有效标签传播':'reason_X/M/W travel with valid tags','同步 DM':'Synchronous DM','一拍读 · 写一次':'One-cycle read / one store write',
'写周期输出保持':'Hold output during store','dout 为 W 边界':'dout supplies W boundary','EA / 写入':'EA / write data',
'核心先检查完整 EA16，再索引 DM8':'Check full EA16 before indexing DM8',
'WB标签≠RF写入；fault标签≠合法完成':'WB token does not imply RF write; fault token is not normal completion',
'只读观测与稳定现场（不参与执行）':'Read-only observation and stable stop state',
'RF 写回影子 · 最近成功 store · MEM 总线事件':'RF writeback shadow / last successful store / MEM events',
'观测不反馈控制；停止现场保持至 reset；无额外 IR / MDR、FIFO 或执行级':'Observations do not control execution; stop state holds until reset; no added IR/MDR, FIFO or stage',
'EES-331 板级时钟、复位与程序观测':'EES-331 clock, reset and program observation','M19 / 100 MHz 晶振':'M19 / 100 MHz oscillator','LVCMOS33 · 单端输入':'LVCMOS33 / single-ended input',
'JTAG / VIO 常开':'JTAG / always-on VIO','in0：状态256位':'in0: state256','in1：计数160位':'in1: counters160','out0：复位请求1位':'out0: reset request1',
'初值1；准备好观测后由JTAG释放':'Initial 1; JTAG releases after observers are ready',
'同步复位与释放去抖':'Synchronized reset and stable release','3级请求同步':'3-stage request synchronizer','21位稳定释放计数':'21-bit release counter','有效 core_reset 寄存':'Registered core_reset',
'S1 / L18：低有效请求':'S1 / L18: active-low request','cpu_system · 稳定AC1':'cpu_system / default AC1','配置时初始化；core reset保留DM':'File initialization; core reset preserves DM',
'性能观察':'Performance counters','周期 / N / stall':'Cycles / N / stalls','各32位，停止保持':'32 bits each; hold when stopped','有效复位清计数':'Effective reset clears counters',
'RF / flags / 停止现场 / 构建身份':'RF / flags / stop state / build identity',
'LED：状态 / 心跳（辅助）；程序结果与停止状态从VIO读取':'LEDs: status / heartbeat. VIO reads program results and stop state.',
'逻辑分区，不新增CPU流水级':'Logical partitions; no additional CPU stages',
'产物：bitstream + LTX + routed checkpoint；板级实测需连接并确认实际EES-331目标':'Outputs: bitstream, LTX and routed checkpoint. Physical tests require the confirmed EES-331 target.'
}


def css_rules(root):
    css=''.join(n.text or '' for n in root.findall('{'+NS+'}style'))
    result={}
    for selector,body in re.findall(r'([^{}]+)\{([^{}]+)\}',css):
        props=dict(x.split(':',1)for x in body.split(';')if ':'in x)
        result[selector.strip()]={k.strip():v.strip()for k,v in props.items()}
    return result


def convert(root):
    rules=css_rules(root); out=[]
    for n in list(root):
        tag=n.tag.rsplit('}',1)[-1]
        if tag in ['defs','style','title','desc']:continue
        a={**rules.get(tag,{}),**rules.get('.'+n.get('class',''),{}),**n.attrib}
        if tag=='text':
            size=float(a.get('font-size','24').replace('px',''));font=ImageFont.truetype(r'C:/Windows/Fonts/arial.ttf',round(size))
            x=float(a.get('x',0));y=float(a.get('y',0));children=list(n)or[n]
            for t in children:
                if t is not n:
                    x=float(t.get('x',x));y=float(t.get('y',y))+float(t.get('dy',0))
                val=t.text or '';width=font.getlength(val)+8
                xx=x-width/2 if a.get('text-anchor')=='middle' else x-width if a.get('text-anchor')=='end'else x
                out.append({'kind':'text','text':val,'x':xx,'y':y-size*.94,'w':width,'h':size*1.25,'size':size,
                            'fill':a.get('fill','#172d42'),'bold':a.get('font-weight')in['700','bold']})
        elif tag in ['rect','circle']:
            if tag=='rect':x,y,w,h=[float(a.get(k,0))for k in ['x','y','width','height']]
            else:
                r=float(a['r']);x=float(a['cx'])-r;y=float(a['cy'])-r;w=h=2*r
            out.append({'kind':tag,'x':x,'y':y,'w':w,'h':h,'fill':a.get('fill','none'),'stroke':a.get('stroke','none'),'width':float(a.get('stroke-width',1))})
        elif tag=='path':
            d=a['d'];assert not re.search(r'[AQSTaqst]',d),d
            tokens=re.findall(r'[MLHVZCmlhvzc]|-?\d+(?:\.\d+)?',d);points=[];i=0;cmd='M';x=y=0
            while i<len(tokens):
                if tokens[i].isalpha():cmd=tokens[i].upper();i+=1
                if cmd=='Z':
                    points.append(points[0]);continue
                if cmd=='C':
                    x1,y1,x2,y2,x3,y3=map(float,tokens[i:i+6]);i+=6
                    for step in range(1,9):
                        t=step/8;u=1-t
                        points.append([u*u*u*x+3*u*u*t*x1+3*u*t*t*x2+t*t*t*x3,u*u*u*y+3*u*u*t*y1+3*u*t*t*y2+t*t*t*y3])
                    x=x3;y=y3;continue
                if cmd in ['M','L']:x=float(tokens[i]);y=float(tokens[i+1]);i+=2
                elif cmd=='H':x=float(tokens[i]);i+=1
                elif cmd=='V':y=float(tokens[i]);i+=1
                points.append([x,y])
            out.append({'kind':'path','points':points,'stroke':a.get('stroke','#24384B'),
                        'width':float(a.get('stroke-width',4)),'arrow':'marker-end'in a,'dashed':'stroke-dasharray'in a})
    return out


def main():
    outdir=B/'图源';records={}
    for p in list(outdir.glob('0[1-4]_*.svg')):
        if p.stem.endswith('_EN'):continue
        root=ET.parse(p).getroot()
        for n in root.iter():
            if n.tag.rsplit('}',1)[-1]in['text','tspan']and n.text:
                n.text=EN.get(n.text,n.text)
                assert not re.search(r'[\u4e00-\u9fff]',n.text),n.text
        for n in root.findall('{'+NS+'}style'):
            n.text=re.sub(r'font-family:[^;}]+','font-family:Arial',n.text or '')
        rules=css_rules(root);canvas=float(root.get('width'))
        boxes=[tuple(float(n.get(k,0))for k in ['x','y','width','height'])for n in root.findall('{'+NS+'}rect')]
        for n in root.findall('{'+NS+'}text'):
            a={**rules.get('text',{}),**rules.get('.'+n.get('class',''),{}),**n.attrib}
            size=float(a.get('font-size','24').replace('px',''));x=float(a.get('x',0));y=float(a.get('y',0))
            containing=[r for r in boxes if r[2]>100 and r[3]>40 and r[0]<=x<=r[0]+r[2] and r[1]<=y<=r[1]+r[3]]
            r=min(containing,key=lambda r:r[2]*r[3])if containing else(0,0,canvas,10000)
            available=(2*min(x-r[0],r[0]+r[2]-x)-20)if a.get('text-anchor')=='middle'else(r[0]+r[2]-x-16)
            font=ImageFont.truetype(r'C:/Windows/Fonts/arial.ttf',round(size))
            width=max(font.getlength(t.text or '')for t in(list(n)or[n]))+8
            if 0<available<width:n.set('font-size',str(round(size*available/width,3)))
        target=outdir/(p.stem+'_EN.svg');ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
        records[p.name[:2]]={'width':float(root.get('width')),'height':float(root.get('height')),'source':target.name,'objects':convert(root)}
    (B/'diagram_geometry.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('COMPLETE_ENGLISH_DIAGRAMS',len(records))


if __name__=='__main__':main()
