import type {AppModel,Net,Node,Selection} from './types';
export const normal=(s:string)=>s.replace(/\s/g,'');
export function resolveNet(m:AppModel,value:string):Net|undefined {
 const raw=value.trim(),key=normal(raw);
 const direct=m.nets.find(n=>normal(n.signal)===key)||m.nets.find(n=>n.targets.some(t=>normal(t.signal)===key));if(direct)return direct;
 const match=raw.match(/^(.*?)\s*\[(\d+):(\d+)\]$/);const base=(match?match[1]:raw).trim();
 const n=m.nets.find(n=>normal(n.signal)===normal(m.aliases[base]||base));
 if(match&&(!n||+match[2]>=n.width||+match[3]>+match[2]))return undefined;
 return n;
}
export const netLabel=(n:Net)=>n.signal+(n.width>1?` [${n.width-1}:0]`:'');
export const nodeShort=(n:Node)=>n.title.split('|')[0].trim();
export function selectedNets(m:AppModel,s:Selection|null):string[]{if(!s)return [];return s.kind==='net'?[s.id]:m.nets.filter(n=>n.sourceNode===s.id||n.targets.some(t=>t.node===s.id)).map(n=>n.id);}
/** Node focus is one-hop adjacency; net focus is the signal's complete fanout.
 * Other loads sharing a node's input are not that node's own downstream logic.
 * Keep every incident net intact; this changes emphasis, never connectivity. */
export function selectionFocus(m:AppModel,s:Selection|null):{nets:string[];nodes:string[]} {
 if(!s)return {nets:[],nodes:[]};
 const nets=selectedNets(m,s),ids=new Set(nets),nodes=new Set<string>();
 if(s.kind==='node')nodes.add(s.id);
 for(const n of m.nets){
  if(!ids.has(n.id))continue;
  nodes.add(n.sourceNode);
  if(s.kind==='net'||n.sourceNode===s.id)n.targets.forEach(t=>nodes.add(t.node));
 }
 return {nets,nodes:[...nodes]};
}
export function getCapture(m:AppModel,nodeId:string,input:string){
 const n=m.nodes.find(n=>n.id===nodeId),pair=n?.pairs?.find(p=>p[0]===input);if(!pair)return null;
 const rule=m.captureRules.find(r=>r.node===nodeId&&r.output===pair[1]);
 if(!rule)return null;return {...rule,enable:nodeId==='dreg'&&rule.output==='d_pc'?'fetch_accept = 1':'',next:m.nets.find(n=>n.signal===pair[1]),qualified:normal(rule.rhs)!==normal(rule.input)};
}
export function netMeaning(n:Net):string {
 const s=n.signal;
 const exact:Record<string,string>={PC_fetch:'当前取指字地址；完整地址先检查，再使用低八位访问 IM。',im_dout:'同步 IM 已寄存的指令输出，直接进入 decoder。',rd_fwd:'经过前递选择的 Rd；ALU 运算和 STR 写入值从此处分支。',rs_fwd:'经过独立前递选择的 Rs；可作为访存基址或 ALU 操作数。',m_exec_value:'EX/MEM 的结果字段：普通指令是结果，LDR/STR 是地址；load 在这里尚未得到数据。',m_store_data:'独立保存的 STR 写入值，直达 DM.din，不经过 ALU 或 WB。',wb_data:'WB MUX 选定的值，返回 RF 写端口及两个 EX 前递 MUX。',dm_dout:'外部 DM 的寄存读输出；它就是 load 的 WB 数据边界。',branch_target:'分支目标地址数据；只有 qualified_redirect 才使 PC 采用它。',z_effective:'从合格 MEM CMP、WB CMP 或架构 Z 中选出的分支条件。',rf_we:'当前 WB 写寄存器的实际使能，已经过 reset、mode、valid、fault 和写意图资格。',dm_we:'实际内存写使能，不能与译码产生的 mem_write 意图混同。',dm_en:'允许访问物理 RAM；使用完整 16 位有效地址进行范围检查。',load_use:'当前 EX load 与 ID 实际源有依赖：保持前端、下一 EX 置气泡。',w_stop_token:'有效 WB 的 HALT/fault token；与普通寄存器/标志写入无关。',clk:'共同上升沿时钟，确定同步寄存器和存储器何时采样。',rst:'同步复位及副作用资格输入；RAM 没有清空复位端口。'};
 if(exact[s])return exact[s];
 if(/valid/.test(s))return '流水位置的占用/有效标签。有效不一定能写状态，还要检查 fault 和写掩码。';
 if(/fault/.test(s))return '故障标签或故障事件；沿接收端可查看它怎样禁止写入、取消年轻指令或触发排空。';
 if(/_sel/.test(s))return '选择控制信号。它决定 MUX 的哪个数据输入实际生效；高亮线路本身并不表示已被选择。';
 if(/_write|_use_|use_rd|use_rs/.test(s))return '随指令传递的用途或写入意图，需结合有效位、故障和资格门理解。';
 if(/_pc$/.test(s))return '该流水位置所携带指令的 PC 标签，与正在取指的 PC_fetch 不同。';
 if(/_imm/.test(s))return '立即数数据或扩展控制；数据与本条指令一起捕获后使用。';
 return '这条信号从一个驱动源连接到列出的全部接收端。点击接收模块可查看其使用条件与下一输出。';
}
