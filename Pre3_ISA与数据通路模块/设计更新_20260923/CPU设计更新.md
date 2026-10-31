# 16位流水线CPU设计更新

CLA加减核心与Carry Overflow标志    2026年9月30日修订

本版把Pre2的超前进位要求与Pre3的carry、overflow要求统一为下一阶段实现规格。主线是：组内统一ISA，完成可辨认的16位CLA结构，再构成加减运算核心，产生C/V候选值，最后接入按指令控制的标志寄存器和流水线。

本文件是设计基线更新，不是新RTL或新实验的通过报告。本轮仅修改设计文档、整理文件；既有汇报PPT、讲稿、HDL和日志不被改写。下文“应”“必须”均表示新版本的实现与验收义务。

9月30日修订补齐译码控制表、流水载荷字段、标志写入资格、可复现的集成验收用例和工程配置登记项。第1至9节共同构成当前增量规格；目录沿用原名称以保持引用稳定。文档完善不代表组内尚待冻结的选择已获教师批准。

## 版本与证据范围

当前指令编码取自用户提供的pre3_g2.pptx实际第2页。文件SHA256为A067A4AE95782BCCF33068943E79EF4C8B67E7332795307E25BB1149AE1DE252。它重新排列Opcode，并增加SUB立即数形式，不能继续使用原Pre1机器字和旧isa_decode控制表。

老师要求（用户明确转述）：Pre2使用超前进位加法器；Pre3补carry和overflow。本版选择：两层分组CLA；减法C表示无借位；ADD/SUB写C/V，CMP只写Z；标志在WB有序更新。这些具体约定是本组拟采用的工程决策，不冒称老师逐项指定。

上次Pre2保存的modules.v包含ripple_adder与adder_rtl，没有可辨认的CLA结构。旧Pre3 alu16只有result、eq、illegal，没有C/V输出。旧文档中的“carry和overflow可选”“只保留Z”等表述，在本版范围内被替代；旧结果作为历史证据保留。

## 前后课程的连续逻辑

Pre2回答“进位怎样计算”：通过generate/propagate与超前进位表达式减少逻辑层面的串行依赖。Pre3回答“计算结果怎样解释”：保留低16位的同时，分别产生无符号进位C和有符号溢出V。后续数据通路与CU回答“谁有资格保存或使用标志”：必须考虑指令类型、流水有效位、冲刷和程序顺序。

保持16位、单发射、顺序五级流水线和独立IM/DM。新增C/V不自动意味着必须增加ADDC、SUBB、JC或溢出异常。本轮不占用保留Opcode；以后确需读取C/V时再定义相应指令和标志依赖。

# 1 当前ISA与兼容性

格式保持Opcode[15:12]、Rd[11:10]、Rs[9:8]、imm[7:0]。R0至R3全部可写。地址按16位字寻址，顺序PC加1。表中写请求是架构意图，最终仍需流水资格控制。

| Hex | 指令 | 运算语义与副作用 |
| --- | --- | --- |
| 0 | MOV Rd,Rs | Rd=Rs，标志保持 |
| 1 | MOV Rd,#u8 | Rd=ZExt(imm8)，标志保持 |
| 2 | LDR Rd,[Rs+s8] | EA=low16(Rs+SExt(imm8))；内存返回数据写Rd |
| 3 | STR Rd,[Rs+s8] | 同上计算EA；DM[EA]=Rd；不写RF |
| 4 | ADD Rd,Rs | Rd=low16(Rd+Rs)，更新C/V |
| 5 | ADD Rd,#u8 | Rd=low16(Rd+ZExt(imm8))，更新C/V |
| 6 | SUB Rd,Rs | Rd=low16(Rd-Rs)，更新C/V |
| 7 | SUB Rd,#u8 | Rd=low16(Rd-ZExt(imm8))，更新C/V |
| 8 | AND Rd,Rs | 按位AND，标志保持 |
| 9 | OR Rd,Rs | 按位OR，标志保持 |
| A | CMP Rd,Rs | Z=(Rd==Rs)，不写RF，C/V保持 |
| B | Reserved | 非法指令处理，无写请求 |
| C | JUMP #u8 | 绝对目标ZExt(imm8)，标志保持 |
| D | JZ #s8 | Z满足条件时目标low16(branch_pc+1+SExt(imm8)) |
| E | HALT | 停止取新指令并排空，标志保持 |
| F | Reserved | 非法指令处理，无写请求 |

SUB立即数采用零扩展，是与ADD立即数一致的本版选择；若组内另定有符号立即数，必须一起改ISA、扩展模式、例程和TB。旧汇报表本身未完整写出此语义，不能把这个选择当作图片已证明的事实。

未使用字段在程序镜像中置0，当前拟议译码器忽略它们；不得用casex隐藏未知控制位。B/F是保留指令；ALU op=5至7是未定义内部控制，两者必须分别检测。

## 指令Opcode与ALU控制

ALU内部op仍为3位：0=PASS_B，1=ADD，2=SUB，3=AND，4=OR；5至7返回result=0、illegal=1、carry=0、overflow=0。eq始终独立比较a与b，只有CMP有Z写意图。

新Opcode 4/5都译码为ALU ADD；6/7都译码为ALU SUB。LDR/STR也使用ADD求地址，但不获得C/V写权限。MOV的寄存器或扩展立即数必须选择到ALU b输入。SUB立即数读取Rd旧值作为a，零扩展立即数作为b。

示例机器字：ADD R0,#1为5001；LDR R2,[R3-1]为2BFF；JZ -1为D0FF。旧2001、8BFF、B0FF在新ISA下意义已改变，必须重编码，不能仅修改文字注释。

## 译码操作数控制表

以下控制均来自当前指令并随它进入ID/EX。use_rd/use_rs表示是否实际读取相应寄存器，既用于冒险检测，也用于转发资格；Rd同时可能是目的地址，不能因此自动置use_rd。先分别转发得到rd_value和rs_value，再选择ALU输入。STR的store_data独立取转发后的rd_value。

选择编码约定：alu_a_sel为2位，0=常数0、1=rd_value、2=rs_value，3保留；alu_b_sel为2位，0=常数0、1=rs_value、2=扩展立即数，3保留。表内用0、Rd、Rs、Imm表示这些来源。imm_signed=1表示符号扩展，否则零扩展；未使用立即数时仍输出确定的0模式。

| Opcode | use_rd | use_rs | ALU a | ALU b | alu_op | imm_signed |
| --- | --- | --- | --- | --- | --- | --- |
| 0 MOV寄存器 | 0 | 1 | 0 | Rs | 0 | 0 |
| 1 MOV立即数 | 0 | 0 | 0 | Imm | 0 | 0 |
| 2 LDR | 0 | 1 | Rs | Imm | 1 | 1 |
| 3 STR | 1 | 1 | Rs | Imm | 1 | 1 |
| 4 ADD寄存器 | 1 | 1 | Rd | Rs | 1 | 0 |
| 5 ADD立即数 | 1 | 0 | Rd | Imm | 1 | 0 |
| 6 SUB寄存器 | 1 | 1 | Rd | Rs | 2 | 0 |
| 7 SUB立即数 | 1 | 0 | Rd | Imm | 2 | 0 |
| 8 AND | 1 | 1 | Rd | Rs | 3 | 0 |
| 9 OR | 1 | 1 | Rd | Rs | 4 | 0 |
| A CMP | 1 | 1 | Rd | Rs | 0 | 0 |
| B 保留 | 0 | 0 | 0 | 0 | 0 | 0 |
| C JUMP | 0 | 0 | 0 | 0 | 0 | 0 |
| D JZ | 0 | 0 | 0 | 0 | 0 | 1 |
| E HALT | 0 | 0 | 0 | 0 | 0 | 0 |
| F 保留 | 0 | 0 | 0 | 0 | 0 | 0 |

CMP的alu_op=0只是确定的合法默认值，result不写RF；eq仍比较选入的Rd与Rs。JUMP/JZ使用独立branch_target16和该分支的pc，不借用本表中已置0的ALU结果。JZ仍把符号扩展立即数送往目标计算路径。

## 译码副作用与分支控制表

下面RW、MR、MW、ZW、CVW分别对应reg_write、mem_read、mem_write、z_write、cv_write。它们只是意图，不是物理端口最终使能。LDR的wb_sel=1选择DM返回值，其他指令wb_sel=0选择exec_value；没有RW时该选择无副作用。

| Opcode | RW | MR | MW | ZW | CVW | 其他控制 |
| --- | --- | --- | --- | --- | --- | --- |
| 0 1 | 1 | 0 | 0 | 0 | 0 | wb_sel=0 |
| 2 | 1 | 1 | 0 | 0 | 0 | wb_sel=1 |
| 3 | 0 | 0 | 1 | 0 | 0 | wb_sel=0 |
| 4 5 6 7 | 1 | 0 | 0 | 0 | 1 | wb_sel=0 |
| 8 9 | 1 | 0 | 0 | 0 | 0 | wb_sel=0 |
| A | 0 | 0 | 0 | 1 | 0 | wb_sel=0 |
| B F | 0 | 0 | 0 | 0 | 0 | illegal=1 |
| C | 0 | 0 | 0 | 0 | 0 | jump_abs=1 |
| D | 0 | 0 | 0 | 0 | 0 | jump_z=1 |
| E | 0 | 0 | 0 | 0 | 0 | halt=1 |

各行未列出的jump_abs、jump_z、halt、illegal均为0。译码先给全部控制安全默认值，再用普通case覆盖；未知有效控制位由仿真断言报告。新增z_write/cv_write替代旧flag_write，不能保留含义不明的同名接口。

内部未定义ALU op或保留的操作数选择码在有效EX指令上构成执行故障，禁止它写RF、DM或标志；bubble上的组合illegal不得触发停机。保留Opcode在ID标记、EX确认，允许更老分支先将其取消。

# 2 CLA加减核心

新增cla4_pg与cla16两层结构。cla4_pg接收4位a/b和cin，输出sum、组传播P、组产生G和cout；cla16接收16位a/b与cin，包含四个4位组，并用顶层组间超前网络同时求各组输入进位。

把四个CLA4的cout依次串到下一组cin，只能称“组内超前、组间纹波”。本版明确采用组间也超前的结构，避免只换模块名称却保留完整串行进位链。行为表达式a+b+cin保留为功能对照，不拿它单独证明手工CLA结构完成。

以下为实现记号而非门延迟承诺：&为AND，^为XOR，OR为逻辑或。位编号由低到高，c0=cin。

    p[i] = a[i] ^ b[i]
    g[i] = a[i] & b[i]
    sum[i] = p[i] ^ c[i]
    c1 = g0 OR (p0 & c0)
    c2 = g1 OR (p1 & g0) OR (p1 & p0 & c0)
    c3 = g2 OR (p2 & g1) OR (p2 & p1 & g0) OR (p2 & p1 & p0 & c0)
    P = p3 & p2 & p1 & p0
    G = g3 OR (p3 & g2) OR (p3 & p2 & g1) OR (p3 & p2 & p1 & g0)
    c4 = G OR (P & c0)

四个组的传播/产生分别记P0至P3、G0至G3；顶层组入口记K0至K4，其中K0=cin、K1=c4、K2=c8、K3=c12、K4=c16。

    K1 = G0 OR (P0 & K0)
    K2 = G1 OR (P1 & G0) OR (P1 & P0 & K0)
    K3 = G2 OR (P2 & G1) OR (P2 & P1 & G0) OR (P2 & P1 & P0 & K0)
    K4 = G3 OR (P3 & G2) OR (P3 & P2 & G1) OR (P3 & P2 & P1 & G0) OR (P3 & P2 & P1 & P0 & K0)

组P/G不得依赖组输入进位，才能避免顶层与子模块的组合循环。检查RTL图时应能定位P/G生成和顶层K表达式。综合器可能将等价逻辑映射到LUT与CARRY资源；CARRY4本身不证明源码属于CLA，也不保证手写CLA在FPGA上更快。

## 加减复用

addsub16_cla输入a16、b16、sub；ADD时sub=0，SUB时sub=1。它复用同一个cla16：

    b_mod = b ^ {16{sub}}
    cin = sub
    {raw_carry, result} = CLA16(a, b_mod, cin)

因此ADD计算a+b，SUB计算a+~b+1。当前ALU不接架构C作为cin；上述cin只用于加减选择。ADDC/SUBB不在当前ISA中。ALU的逻辑/传送结果与加减结果经result选择器输出；eq为独立比较路径。

# 3 Carry与Overflow的准确含义

carry是加减核心的c16。ADD时表示无符号加法超出65535。SUB时约定为“无借位”：a不小于b时carry=1，否则carry=0。需要borrow用于调试时，SUB下borrow=NOT carry；不要同时把carry=1解释成借位。

overflow判断有符号结果是否超出-32768至32767。必须使用原始a/b的符号位，不能把补码变换后的b_mod直接代入下面减法公式。

    ADD_V = NOT(a[15] ^ b[15]) AND (result[15] ^ a[15])
    SUB_V = (a[15] ^ b[15]) AND (result[15] ^ a[15])

对正确的二进制加减进位链，可用V=c15 XOR c16交叉检查，但主验证预期值应由有符号整数结果是否越界得到，而非只复制同一个进位表达式。

非加减操作的ALU组合carry/overflow输出定义为0；这不等于清除架构C/V。非法op也给确定的0输出，illegal优先表明该结果不可使用。eq在非法op下仍是a==b的组合值，但不得因此写Z。

| 运算 | result | C | V |
| --- | --- | --- | --- |
| FFFF + 0001 | 0000 | 1 | 0 |
| 7FFF + 0001 | 8000 | 0 | 1 |
| 8000 + 8000 | 0000 | 1 | 1 |
| 0005 - 0003 | 0002 | 1 | 0 |
| 0000 - 0001 | FFFF | 0 | 0 |
| 8000 - 0001 | 7FFF | 1 | 1 |
| 7FFF - FFFF | 8000 | 0 | 1 |
| 1234 - 1234 | 0000 | 1 | 0 |

上表是人工定义的验收向量，不是本轮仿真记录。C与V的四种组合均有意义；不能把result最高位当overflow，也不能把carry当signed overflow。

# 4 ALU输出与架构标志分层

第一阶段先完成组合ALU：a[15:0]、b[15:0]、op[2:0]输入；result[15:0]、eq、illegal、carry、overflow输出。模块不保存状态，不增加clk/rst端口。新端口会影响TB和顶层实例化，建议全部采用命名连接，避免位置参数错位。

第二阶段再增加独立flags_reg，保存Z/C/V。老师要求carry/overflow并不必然要求立即实现全部标志指令；本版选择提供可扩展的状态接口，为后续数据通路集成做准备。

| 指令类别 | Z寄存器 | C和V寄存器 |
| --- | --- | --- |
| ADD或SUB 两种寻址形式 | 保持 | 合格WB更新 |
| CMP | 合格WB更新eq | 保持 |
| MOV AND OR | 保持 | 保持 |
| LDR STR 地址运算 | 保持 | 保持 |
| JUMP JZ HALT | 保持 | 保持 |
| bubble 非法或被取消指令 | 保持 | 保持 |
| 同步复位 | 清0 | 清0 |

flags_reg输入clk、rst、z_we、cv_we、z_in、c_in、v_in，输出Z/C/V。rst最高优先级；否则z_we和cv_we分别使能各自字段，不使用覆盖全部标志的单一无掩码写入。合法单发射指令通常不会同时请求两类更新，但模块应明确定义同时有效时分别写入对应字段。

ISA当前只由JZ读取Z；没有读C/V指令。C/V仍可通过调试接口观察，不等同于软件已可读。需要新增JC、JO或ADDC时另做ISA变更，不提前实现未定义行为。

## 标志的观察与采样

仿真基线由TB通过层次路径或bind读取flags_reg的Z/C/V，并同时记录所属WB的pc、valid、z_write/cv_write和候选值。RTL层次名称由实现者登记在TB中，不把尚不存在的实例路径写成现成接口。上板观察方式暂未冻结，可选ILA或明确的只读调试输出；本版不新增软件可读状态寄存器指令。

时序检查应在上升沿非阻塞赋值完成后采样架构标志，同时保留边沿前WB标签用于对账。组合ALU波形只证明候选值，不能单独证明flags_reg在正确指令、正确周期更新。调试接口不得反向影响标志写入资格。

# 5 流水线与其他模块的接口

EX产生result、eq及C/V候选值。EX/MEM与MEM/WB必须保存相应候选值、z_write/cv_write意图、valid和必要PC标签；WB按程序顺序更新架构标志。不得用当前ID的Opcode去控制较老WB指令写标志。

WB写资格必须由所属WB指令的状态决定。前端stall不能阻止更老WB完成，年轻MEM/EX故障也不能误清较老WB结果。以逻辑AND/NOT表示的规范如下，rst在同步寄存器内部仍有最高优先级：

    wb_commit = wb_valid AND NOT wb_killed AND NOT wb_fault
    rf_we = NOT rst AND wb_commit AND wb_reg_write
    z_we  = NOT rst AND wb_commit AND wb_z_write
    cv_we = NOT rst AND wb_commit AND wb_cv_write

wb_fault表示该WB载荷自身的故障，不是全局fault或stop_pending。wb_commit只表示WB槽提交资格，并非全CPU的“每条指令退休”事件，STR在MEM完成，不能用它统计全部动态指令。若kill已通过清valid表示，wb_killed可作为概念条件而非额外实体寄存器；TB仍须验证取消效果。

CMP后紧邻JZ仍需读取最近较老CMP产生的Z：EX/MEM候选优先，其次MEM/WB候选，最后架构Z；被kill的候选不得转发。当前没有C/V消费者，因此不必提前增加C/V转发选择器。将来加入读取C/V的指令时，必须另设计同类相关处理。

RF保持4×16、双读单写、同步复位和WB读旁路；R0可写。立即数扩展器保持零扩展/符号扩展两种模式，但新译码器必须把Opcode 5/7设为零扩展，2/3/D设为符号扩展。

PC保持reset > qualified redirect > hold > increment。相对目标仍以branch_pc为基准。C/V不是PC自动跳转条件；没有JC/JO就不能凭carry/overflow自行重定向。

IM/DM继续使用独立、固定同步延迟接口，不恢复没有实际协议转换用途的Adapter。若实际存储延迟改变，必须修改流水时序与互锁，不把问题藏进Adapter名称。

## 流水载荷字段

下表是逻辑载荷契约，不要求使用某一种HDL结构体。括号内为位宽；同一组字段必须与所属valid一起推进。故障标记fault为1位，fault_pc可复用随行pc；故障原因编码属于可选调试，不强制增加到核心接口。

| 边界 | 数据与标签 | 控制字段 |
| --- | --- | --- |
| IF/ID | inst(16) pc(16) | valid(1) fetch_fault(1) |
| ID/EX | pc(16) rd(2) rs(2) rd_value(16) rs_value(16) imm_ext(16) | valid fault各1；use_rd/use_rs各1；alu_a_sel/alu_b_sel各2；alu_op(3)；RW/MR/MW/ZW/CVW各1；wb_sel、jump_abs、jump_z、halt各1 |
| EX/MEM | pc(16) rd(2) exec_value(16) store_data(16) cmp_z/c/v各1 | valid fault各1；RW/MR/MW/ZW/CVW各1；wb_sel halt各1 |
| MEM/WB | pc(16) rd(2) exec_value(16) load_data(16) cmp_z/c/v各1 | valid fault各1；RW/ZW/CVW各1；wb_sel halt各1 |

imm_ext在ID按本指令模式生成，ID/EX无需再保存imm_signed。rd/rs源索引保留到EX完成转发；之后只有目的rd仍需携带。MEM/WB的load_data可以由同步DM输出寄存器承担，不应再无条件串接同沿MDR而增加一拍。上表未要求无用数据每拍清零；无效载荷可不复位，关键valid、架构状态和停止状态必须复位。

STR的store_data只在EX/MEM保存并在MEM消费；其MEM/WB对应槽必须为bubble。普通ALU结果不得跳过MEM传递槽直接抢写RF。分支的无写入标签允许继续流动用于跟踪，但不能在WB再次redirect。HALT结束标记随流水排空，不写RF或标志。

## 推进与取消的逐级规则

| 事件 | 前端与ID/EX | EX/MEM与MEM/WB |
| --- | --- | --- |
| 同步复位 | PC清0 所有valid清0 停止状态清0 | 所有valid清0 RF及Z/C/V清0 禁止DM写 |
| 普通推进 | 接收下一条有效载荷 | 数据 控制 标签 valid一起推进 |
| load use停顿 | PC与IF/ID保持 IM禁止覆盖 ID/EX插bubble | 当前EX的load仍推进 老MEM/WB继续完成 |
| EX有效重定向 | PC取目标 两个年轻槽取消 错误路径取指丢弃 | 老MEM/WB完成 分支不产生数据写入 |
| EX故障或HALT | 停取新指令 取消年轻槽 | 老MEM/WB完成 EX停止标记不写数据或标志 |
| MEM自身故障 | 停前端 取消包括当前EX在内的年轻动作 | 禁止故障MEM访问及后续写回 老WB仍完成 |

每级按年龄处理冲突：复位 > 较老MEM故障 > EX故障或HALT > EX重定向 > load use停顿 > 普通推进。stop_pending只停止新指令进入，不冻结老指令排空。最终halted或fault在相应停止标记及更老操作完成后置位，直到复位。

MEM端口资格必须在物理RAM采样边沿前完成：mem_access_ok = NOT rst AND m_valid AND NOT m_killed AND NOT m_fault AND address_in_range；dm_en再与MR或MW相与，dm_we再与MW相与。EX停止事件不取消较老MEM的合法STR。越界地址不得先截为8位再访问RAM。

Z转发仅考虑有效、未取消、无自身故障且ZW=1的生产者，优先M再W。M级ADD即使更新C/V也不能遮挡W级CMP的Z；比较值0同样有转发资格。若MEM故障取消当前EX，则即使组合分支条件为真也不得产生有效redirect。

## 原规格的继承与替代

原规格路径为课程目录下Pre1_CPU技术规格/CPU技术规格正文.md。继续继承其固定同步存储边沿契约、实际源掩码冒险判断、M/W到EX转发、WB到ID读旁路、load use停1拍、STR基址和数据均在EX转发、分支取消两个年轻槽、HALT排空及附录A故障年龄规则。

本版替代原规格的旧Opcode及机器字、单一FlagWrite接口、仅Z架构状态和C/V可选表述。原机器字、控制表、周期模型程序和通过日志不能直接作为新ISA的验收来源。未变的存储边沿契约为：周期k内地址/en稳定，k结束边沿采样，k+1内数据供ID或WB使用，k+1结束边沿由ID/EX或RF消费。

# 6 地址计算与算术标志必须分开

LDR/STR用ADD算地址，ALU可能产生C/V，但译码不使能架构C/V写入。例如0020+FFFF的低16位为001F，正确表示基址0020加位移-1；最终carry=1不能据此判地址错误。

本版沿用16位模地址：先取low16，再检查物理范围。若DM只有256个字，EA=0100不合法，必须在写使能前拦截；不能只接低8位变成00。0000加-1得到FFFF，会被256字范围检查拒绝。

FFFF加1回绕0000在本版模地址语义中允许，若课程要求禁止这种跨16位边界回绕，需要另增加扩宽的地址范围判断，不能仅套用算术C标志。这个选择必须作为地址语义变更记录。

STR在MEM写数据，无RF write-back。LDR的ALU结果是地址，DM返回值才是RF写入值。CMP使用eq，result可忽略；不要为了新增C/V把CMP改成未经说明的“减法自动写所有标志”。

# 7 验证方案与独立预期值

原验证证明的是精确旧源码在原测试范围内的行为，不能给新的CLA、标志输出或新译码器直接贴PASS。新版本应有自己的源码哈希、日志、测试数量、种子、工具与器件记录。

## 分层测试

CLA4：穷举4位a、4位b、1位cin，共512组；检查sum/cout，并分别检查P/G是否不依赖cin。CLA16：长进位、组间进位、交替位、边界及随机差分；检查结构中组入口由超前表达式产生。若教师继续要求全量，对a16/b16/cin的全部2^33组合运行，分段时记录连续区间与精确完成数。

ADD/SUB核心：两个16位输入与sub构成2^33组合。ADD与SUB各2^32；它与CLA16通用cin测试不是相同测试对象，不能交换计数。输出必须比较result、carry、overflow，不能只比低16位。

ALU：覆盖全部5种合法功能、3种非法选择，以及独立eq；检查非算术C/V为0。新增标志后旧2,177,160例可以复用输入集但必须重跑并扩展断言；没有全量日志就仍称模式/随机回归。

新译码器：穷举65536个指令字，使用本版Opcode表验证alu_op、源掩码、扩展模式、RF/DM/Z/CV写意图。B/F非法，新E为HALT；旧D/F非法规则不能残留。

flags_reg：同步复位、仅z_we、仅cv_we、都不写、两类同时写、不同先前状态；另在集成TB检查无效、冲刷、错误路径、stall与较老WB更新。Z/C/V只有8种状态，但控制与时序也应完整覆盖。

## 参考计算方法

先用上表固定手算值核对TB。ADD预期采用至少17位无符号精确求和，C为是否大于65535；SUB的C预期直接用unsigned(a)>=unsigned(b)，不复制DUT的c16表达式。

V预期：把输入映射到有符号整数（最高位为1则减65536），在至少32位有符号整数中做加减，判断结果是否小于-32768或大于32767。result预期取该算术值的低16位。这样验证算法与DUT符号位/CLA逻辑不同，但仍不能宣称测试参考绝对不会出错。

输出比较采用四态不等比较!==，未知输出导致失败；输入穷举范围为0/1二进制，不包括X/Z组合。组合检查等待仿真更新稳定，#1不是实测门延迟。长回归不输出每组波形或CSV，只保存进度、失败反例、最终计数。

增加反例检查：故意让SUB的C极性反转、V固定0、禁止某条合法指令写C/V、错误允许LDR写C/V，确认对应测试能发现。这是测试有效性检查，不等于形式化证明。

## 标志与控制的集成验收用例

以下均为待实现的测试规格，不是已运行结果。每例独立复位，地址和数据均用十六进制；寄存器初值在第一条取指前由TB预置，属于测试装置，不代表ISA有16位立即数加载指令。未列寄存器、Z/C/V及DM默认0。除T09外，IM从0000顺序装入表中机器字，末尾HALT；IM/DM深度均设为256字。

| 用例 | 初始条件与机器字序列 | 必须观察到的结果 |
| --- | --- | --- |
| T01 CMP后算术 | R0=0001 R1=0001 R2=FFFF；A100 5801 D001 1C55 E000 | ADD后R2=0000 C=1 V=0；Z仍为1；JZ跳过MOV R3 R3保持0 |
| T02 连续CMP | R0=0001 R1=0002；A000 A100 D001 1855 E000 | 最近CMP输出0覆盖旧1；JZ不跳；R2=0055 Z=0 |
| T03 地址运算保持标志 | R0=7FFF R1=0020 DM[001F]=BEEF；5001 29FF 3900 E000 | ADD置C=0 V=1；负偏移LDR的组合carry可为1但不能写标志；R2及DM[0020]=BEEF；最终C=0 V=1 |
| T04 错误路径写入 | R0=FFFF；C003 5001 A000 E000 | 跳过ADD及CMP；RF和Z/C/V均不受错误路径影响 |
| T05 老WB与年轻故障 | R0=7FFF R1=00FF；5001 2901 5801 E000 | ADD在WB与LDR在MEM越界同拍；R0=8000 C=0 V=1保留；故障load及年轻ADD均无写入；fault排空后为1 |
| T06 load use与CMP | R1=0020 R2=0001 DM[0020]=0001；2100 A200 D001 1C55 E000 | load到CMP停1拍；R0=0001 Z=1；JZ跳过MOV R3；不能把load地址当数据转发 |
| T07 HALT排空 | R0=0020 DM[0020]=1234；2400 E000 3401 | 老LDR须写R1=1234；HALT后STR被取消 DM[0021]仍0；halted最终为1 |
| T08 停顿不冻结WB | R0=7FFF R1=0020 DM[0020]=0001；5001 1C00 2900 4A00 E000 | LDR R2到ADD R2,R2停1拍；同拍老ADD仍写C=0 V=1；末尾R2=0002 C=0 V=0 |

T01的JZ目标为0004；T02与T06相同编码的JZ条件不同。T03同时覆盖load到STR写数据相关，基线应停1拍。测试除最终值外还必须断言对应边沿的写使能、pc/valid、转发来源、stall次数和错误路径无副作用。

T09验证复位优先级：使用T08程序，分别在IF、ID、EX、MEM、WB有有效指令时于下降沿置rst，跨越下一个上升沿；再于下降沿撤销。该上升沿后RF、Z/C/V、PC、全部valid和停止状态应清0，DM不整体清零且复位边沿不得写入。DM中复位前已完成的合法写入不回滚。

flags_reg单元补充穷举：8种旧Z/C/V状态 × 2种rst × 4种z_we/cv_we × 8种z_in/c_in/v_in，共512个状态转移检查。每个旧状态先用合法建立序列设置，再执行一次计数检查；建立状态的时钟不能混入512的覆盖统计。集成中合法单指令不会同时产生ZW与CVW，但模块对二者同时有效仍分别更新。

每个集成用例的日志至少包含源码与镜像哈希、初始状态、随机种子（若使用）、时钟周期、IM/DM配置、断言失败数和结束原因。设置最大周期超时，防止错误的HALT/分支控制使仿真永久等待。上述表不提供未经周期模型或RTL确认的总周期数。

# 8 下一节课的实施顺序与交付

步骤1：组内冻结本版Opcode、SUB立即数解释、减法C极性及标志写策略。当前无借位约定若被教师否定，先改规范与预期表，再写RTL。

步骤2：实现cla4_pg、cla16和addsub16_cla，先通过小位宽穷举及边界测试。保留行为加法作为功能对照，保留旧纹波版本作历史基线，不混合通过声明。

步骤3：更新alu16端口及所有实例化；补C/V断言，重跑全回归。重新导出RTL Analysis图与代表性波形，能在图上定位CLA、result选择与标志逻辑。

步骤4：按新ISA修改isa_decode与机器字例程；测试通过后再接flags_reg和流水载荷，验证WB资格与CMP-JZ相关。单元通过不能代替集成验证。

步骤5：确定真实工程器件、工具版本和约束，重新综合生成资源报告。旧Z010的71 LUT、10 CARRY4、0 FF只属于旧ALU，新增CLA/C/V后失效。Z020工程不得引用Z010的资源数字；没有布局布线与时序约束就不报告Fmax。

步骤6：汇报采用“Pre2进位结构 → Pre3结果与标志 → 下节课流水控制”的连续逻辑。提供新ISA表、接口表、行为/结构HDL、TB、标注波形、RTL图、综合图、结果日志与源码哈希。已定稿的当前PPT与讲稿是历史快照，本轮不修改；下一次汇报再用新证据更新。

## 工程配置与性能验收

本版不把Z010参考报告升级为Z020工程结果，也不凭课程截图决定板卡引脚。生成真实工程或XDC前，由组员登记以下参数；未确定项目保留待确认，不阻碍逻辑规格编写，但阻止宣称上板或性能验收完成。

| 登记项 | 当前状态与实施要求 |
| --- | --- |
| 目标器件与板卡 | 待确认最终完整part与板卡型号；历史报告为xc7z010clg400-1，不能替代实际工程 |
| 工具版本 | 旧单元证据使用Vivado 2025.2；新回归须登记实际版本及补丁，不混用不同组员结果 |
| 目标时钟 | 待组内确定周期及来源；TB的10 ns时钟不等于硬件保证100 MHz |
| IM和DM | 16位字；本验收用例深度256；同域固定一阶段同步读，en=0时IM输出保持 |
| 存储实现 | 登记RTL或IP名称、版本、读延迟、输出寄存器开关、写模式、初始化镜像哈希 |
| 顶层与约束 | 登记top、时钟端口、复位来源、XDC哈希；上板再绑定真实引脚和IO电平 |
| 比较条件 | CLA与行为加法保持相同输入输出寄存器边界、位宽、功能、器件、约束及工具策略 |

核心只有一个逻辑时钟域，按单周期级间路径验收。纯组合ALU的独立性能比较需要统一的寄存器包围测试顶层，或明确的输入输出时序预算；不能以未约束组合模块的资源综合结果代替传播延迟测量。新增包围寄存器的资源必须单列，不能算成ALU本体触发器。

综合先检查锁存器、组合环、未连接端口和高危警告，再完成布局布线。时序验收至少包括WNS≥0、TNS=0、WHS≥0、THS=0，以及所有预期时钟和应分析路径已约束；还应检查适用的脉宽及复位相关要求、DRC和时序例外。报告绑定到该次源码、part和约束，不将一次通过频率称为搜索得到的最大Fmax。

不得通过随意设置false path或multicycle掩盖EX中的转发MUX、CLA、标志产生及下一拍采样的失败。只有功能控制确实提供多周期采样窗口时才允许多周期例外，并同步修改设计和验证；当前基线未定义这种窗口。手写CLA满足教学结构要求不自动证明其FPGA速度优于工具推断专用进位链。

参考资料：AMD UG474 Carry Chain Primitive解释专用进位资源；UG903 Multicycle Paths要求多周期例外与起终点控制行为一致。本文不照搬通用MPSoC模板中的PS、AXI、HLS或PetaLinux流程，自研16位CPU核心不因采用Zynq器件就必须使用它们。

https://docs.amd.com/r/en-US/ug474_7Series_CLB/Carry-Chain-Primitive

https://docs.amd.com/r/2024.1-English/ug903-vivado-using-constraints/Multicycle-Paths

## 五人协作建议

| 负责人 | 实现重点 | 验收交接 |
| --- | --- | --- |
| A | ISA与译码迁移 | 新Opcode、源掩码和标志写意图表 |
| B | RF与flags_reg | 复位、掩码写入、保持与WB读规则 |
| C | CLA加减核心与ALU C/V | result/C/V边界测试、RTL图与映射报告 |
| D | PC及控制资格 | redirect/hold/故障优先级、Z依赖联动 |
| E | 立即数、TB与程序集成 | 新SUB立即数、偏移、机器字与回归证据 |

# 9 来源与未完成事项

设计依据：最新pre3_g2第2页ISA图片；用户明确转述的CLA及carry/overflow要求；课程Lec08 Standard Combinational Components实际第15–22、30–31页的加法/CLA/补码内容；Lec09 Verilog combinational的加法与ALU示例；Lec17的数据通路与寄存器/PC章节；原9月9日CPU技术规格的五级顺序流水与存储契约。

课件CLA页P记号有不同简写，本版统一p=a XOR b、g=a AND b；不把已乘cin的项又当纯传播量使用。综合carry资源与门级CLA的逻辑分类不混为一谈。

保留的历史证据：旧Pre2加法器完成记录；旧Pre3四模块测试、WDB/VCD、源码、DCP、网表和综合图。它们仍可复查，但不是本版通过记录。本轮没有更改这些源码，也没有新增CLA/C/V硬件仿真。

待完成：CLA16真实实现与结构检查；新增ALU标志测试；新ISA译码与例程迁移；flags_reg与流水资格控制；真实器件综合；完整数据通路/CPU集成验证。不得将任一待完成项在讲稿或报告中升级为已验证。
