# ISA v1.4 完整指令语义

基准来自用户2026-10-08核心设计文档v1.4。本次实现与本表一致，旧Pre3的Opcode及机器字镜像不再兼容。

指令为16位：Opcode[15:12]、Rd[11:10]、Rs[9:8]、imm8[7:0]。四个寄存器R0–R3都可写。地址单位为16位字，顺序PC加1。结果与地址计算保留低16位，再检查物理256字存储范围。

| Hex | 指令 | 实际读取源 | 立即数 | 结果与架构副作用 |
| --- | --- | --- | --- | --- |
| 0 | MOV Rd,Rs | Rs | 不使用 | R[d]=R[s]；Z/C/V保持 |
| 1 | MOV Rd,#u8 | 无 | 零扩展 | R[d]=ZExt(imm8)；Z/C/V保持 |
| 2 | LDR Rd,[Rs+s8] | Rs | 符号扩展 | EA=low16(R[s]+SExt(imm8))；合法MEM读后WB写R[d]；标志保持 |
| 3 | STR Rd,[Rs+s8] | Rd数据、Rs基址 | 符号扩展 | EA同上；合法MEM结束边沿DM[EA]=R[d]；成功WB空槽；标志保持 |
| 4 | ADD Rd,Rs | Rd、Rs | 不使用 | R[d]=low16(R[d]+R[s])；WB更新C/V，Z保持 |
| 5 | ADD Rd,#u8 | Rd | 零扩展 | R[d]=low16(R[d]+ZExt(imm8))；WB更新C/V，Z保持 |
| 6 | SUB Rd,Rs | Rd、Rs | 不使用 | R[d]=low16(R[d]−R[s])；WB更新C/V，Z保持 |
| 7 | SUB Rd,#u8 | Rd | 零扩展 | R[d]=low16(R[d]−ZExt(imm8))；WB更新C/V，Z保持 |
| 8 | AND Rd,Rs | Rd、Rs | 不使用 | 按位AND写R[d]；标志保持 |
| 9 | OR Rd,Rs | Rd、Rs | 不使用 | 按位OR写R[d]；标志保持 |
| A | CMP Rd,Rs | Rd、Rs | 不使用 | Z=(R[d]==R[s])；不写RF；C/V保持 |
| B | Reserved | 无 | 不使用 | 非法指令，阻止自身写入并按年龄排空故障 |
| C | JUMP #u8 | 无 | 零扩展 | EX请求目标ZExt(imm8)，合格后重定向及取消年轻槽 |
| D | JZ #s8 | 最新较老CMP的Z | 符号扩展 | Z=1时EX目标low16(x_pc+1+SExt(imm8))，否则顺序 |
| E | HALT | 无 | 不使用 | EX确认停止请求，取消年轻指令，WB结束边沿排空完成 |
| F | Reserved | 无 | 不使用 | 同B，非法编码 |

## 字段与标志规则

未用字段在程序镜像中置0，硬件译码忽略；use_rd/use_rs只按实际源产生，不能因为某个目标索引与load相同而误停。bubble以valid=0表示，MOV R0,#0仍是合法有副作用的指令。

ADD C为最高位进位。SUB C为无借位（unsigned a≥b），不是借位本身；若需要borrow诊断量则为SUB下~C。V为16位补码精确运算超出−32768..32767，独立于C。只有CVW写对应保存值，地址ADD和非算术候选不会改变保存标志。

CMP产生组合eq并随ZW送入M/W；JZ可用尚未写回的候选。最新合法M级CMP优先W级CMP再架构Z，候选0也能覆盖旧1。ADD不会更新Z，不能用result==0代替CMP的Z策略。

## 地址与故障

位移FF表示−1，基址0020加FF得到001F。16位模地址回绕FFFF+1得到0000；EA低16位确定后再检查0000..00FF物理范围。

越界0100和FFFF不能只取低8位访问0000或00FF。IM越界产生有效fetch_fault标签，DM越界在使能前阻断；错误可被更老的分支/HALT取消。故障STR保留WB有效停止标记，不采用成功STR的WB气泡规则。

## 汇编编码例子

word=(opcode<<12)|(rd<<10)|(rs<<8)|(imm8&255)。编码工具须检查Opcode、Rd/Rs和立即数范围；负位移使用8位补码。

| 指令 | 机器字 | 数据路径重点 |
| --- | --- | --- |
| ADD R0,#1 | 5001 | Rd转发＋零扩展＋CLA，RF/CV写回 |
| ADD R2,R2 | 4A00 | 两源同址仍分别参加匹配 |
| LDR R2,[R3−1] | 2BFF | Rs转发＋符号扩展，DM返回值写RF |
| STR R2,[R1+0] | 3900 | Rs算地址，Rd独立store_data |
| CMP R0,R1 | A100 | eq候选只供Z策略 |
| JZ −1 | D0FF | 使用本条PC标签而非PC_fetch |
| HALT | E000 | 有效结束标记必须到WB |

当前ISA没有ADDC、SUBB、JC、JO、中断返回或可恢复异常。C/V作为架构状态被保存并用于测试观察，软件没有读取它们的指令。
