# 独立ISA v1.5参考契约

基线7753502，16位指令：Opcode[15:12]、Rd[11:10]、Rs[9:8]、imm8[7:0]。R0至R3均为16位普通可写寄存器。未使用字段忽略，规范程序置零；地址单位为16位字，顺序pc+1。

| Opcode | 行为 | 标志写入 |
|---|---|---|
| 0 | MOV Rd,Rs：Rd=Rs | 无 |
| 1 | MOV Rd,#u8：Rd=零扩展imm8 | 无 |
| 2/3 | AND/OR Rd,Rs：两源分别为旧Rd/Rs | 无 |
| 4/5 | ADD Rd,Rs / ADD Rd,#u8：结果低16位 | C/V |
| 6/7 | SUB Rd,Rs / SUB Rd,#u8：结果低16位 | C/V |
| 8 | LDR Rd,[Rs+s8]：EA=low16(Rs+符号扩展imm8)，读取DM[EA]至Rd | 无 |
| 9 | STR Rd,[Rs+s8]：同上EA，DM[EA]=旧Rd | 无 |
| A | CMP：Z=(Rd==Rs)，不写RF | Z |
| B/F | 保留编码，正确路径上产生故障token，不写架构数据 | 无 |
| C | JUMP：目标零扩展imm8 | 无 |
| D | JZ：仅Z=1时，目标low16(本条pc+1+符号扩展imm8) | 无 |
| E | HALT：取消年轻载荷，老指令与停止token排空至WB | 无 |

ADD的C是第16位进位；SUB的C=unsigned(a)>=unsigned(b)，表示无借位。V表示精确有符号结果超出[-32768,32767]。ADD/SUB保持Z，CMP保持C/V。

先取16位EA，再检查256字物理容量；EA 0100/FFFF不得按低8位访问，FFFF+1回绕0000合法。取指越界先形成可取消标签。MEM故障优先于年轻EX事件，老WB仍可提交。同步reset清RF/flags/PC/在途状态并禁止当拍写入，已提交DM保持。

所有存活指令按IF/ID/EX/MEM/WB组织。普通RF及flags在WB写入；STR仅在MEM写一次，WB仍有有效无写入标签；分支在EX重定向后自身继续。相邻load-use保持PC/ID一拍并插X bubble，后端继续；只比较真实源。M非load优先W，再ID/EX保存值；M匹配load不能回退旧W；Z选择M合格CMP、W合格CMP、保存Z，候选0仍覆盖旧1。

独立顺序oracle只定义ISA结果与有序架构事件，不复制流水控制。冻结48例、10次reset重启见证及逐拍期待另由审阅的test_manifest.json与Testbench保持；改变数量必须明确修订契约，不能让生成结果自动成为验收标准。
