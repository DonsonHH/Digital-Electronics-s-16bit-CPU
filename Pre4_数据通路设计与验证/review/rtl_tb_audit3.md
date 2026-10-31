# Pre4 v1.4 第三轮独立 RTL / TB 审查

审查日期：2026-10-09。结论：在以下源码、规格和有限验证范围内，未发现新的 RTL 功能缺陷或需要修改生产测试台的错误。本轮追加的 12 个定向用例及 4 个停止状态复位后重新运行用例已在 XSim 2025.2 实跑，`AUDIT3_PASS directed=12 reset_restart=4 total=16 failures=0`。结论不代表 CPU 状态空间穷举、100 MHz 时序通过、实际存储 IP 已集成或上板成功。

## 1. 审查基线与独立性

- 交付目录：`D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre4_数据通路设计与验证`。
- 规格：`CPU核心设计/16位流水线CPU核心设计文档.docx`，版本 1.4；本轮重新读取 SHA-256：`FEABA5CDD726E514632113A11C8D692F9DD22756E50A49A2175E99AD2CDD232A`。
- 规格提取文本：`C:/Users/Donson/Documents/ChatGPT/Shudian/pre4_20261008/source.txt`，SHA-256：`BD387A94919208FABADB6A137CDA91196B75DFF089D8398E443D82940224B35D`。
- 逐模块重读 13 个 RTL 文件、3 个生产 TB 及实际日志，不以旧审查报告代替源码分析。
- 生产 RTL/TB 未改。本轮 `tb_audit3.sv`、命令文件、日志和 13 个完全相同的 RTL 副本仅写入此第三轮审查目录；逐文件重新比较后 `13/13 StageMatch=True`。
- 追加测试的预期完成事件为手工填写，未调用生产 TB 的 `reference()`、DUT 译码器、ALU候选值或任何 DUT 控制输出来生成预期值。前沿观察实际完成事件以定位，边沿后比较全部 RF、Z/C/V 和 256 字 DM，既检查事件数量/pc/目的/数值，也检查未获准修改的状态保持。

## 2. 逐模块检查

| 源码 | 本轮重新检查的关键关系 | 判断 |
|---|---|---|
| `cla4_pg.v` | XOR传播、各位展开进位、P/G独立于cin、sum=p XOR carry | 与规格两层CLA的组内关系一致 |
| `cla16.v` | K1至K4均为组超前展开式；local_cout未串接下一组cin | 无组间纹波连接、无组合环 |
| `addsub16_cla.v` | SUB=a+~b+1；原始b参与V公式；C为无借位；不接保存C | 与ADD/SUB语义一致 |
| `alu16.v` | 0至4合法、5至7安全非法默认；eq独立；非算术C/V=0 | 不将组合C/V默认误写架构状态 |
| `isa_decode.v` | 16种opcode控制、14合法/B/F非法、真实源掩码、STR双源和LDR只读Rs | 与规格表11/12一致；未知opcode未用casex |
| `imm_ext16.v` | MOV/ADD/SUB/JUMP零扩展；LDR/STR/JZ符号扩展 | 与v1.4一致 |
| `regfile4x16.v` | R0普通可写；同步reset优先；WB到ID两读端同址旁路 | 不依赖时序块执行顺序 |
| `pc16.v` | reset > redirect > hold > increment；16位回绕 | 满足前端年龄仲裁后的更新契约 |
| `branch_target16.v` | JZ使用本条x_pc+1+SExt；JUMP绝对u8；模16位 | 不使用超前PC_fetch或ALU安全默认值 |
| `flags_reg.v` | 同步reset、Z与C/V独立写掩码、同时写互不覆盖 | 架构状态只在WB合格写入 |
| `operand_forward.v` | M优先W；M load不把EA当值，也不越过最近未就绪生产者使用旧W；Rd/Rs独立 | 与load-use一拍互锁共同满足RAW契约 |
| `datapath_core.sv` | 同步IM/DM边界、valid/pc随行、年龄优先、STR成功bubble/故障token区别、停止边沿 | 下述逐项检查及新增定向仿真未发现反例 |
| `sync_memories.v` | IM disabled保持、固定一边沿读；DM store写边沿/read后见新值；核心先守卫完整EA | 它是行为存储模型，不能推定任意BRAM IP配置均兼容 |

## 3. 核心危险组合与边沿

1. **背靠背load对齐**：DM的输出寄存器直接承担WB数据边界，标签/控制在同一MEM结束边沿进入W。下一次读的NBA更新发生在旧W采样以后，不会将旧load写成下一load的值。本轮用 `00A5` / `5A00` 两个不同数据检查连续load，再分别测试不同目的及相同目的；消费者均只停1拍并取得最新正确值。
2. **同名生产者年龄**：M普通结果优先旧W load；M load不能用EA转发或退回旧W值，ID互锁插bubble，消费者在load进入W后使用正确数据。对应 `M_RESULT_OVER_OLD_LOAD` 和 `NEW_LOAD_OVER_OLD_VALUE` 均通过真实选择码见证。
3. **STR多源**：`rd_fwd`独立供store_data，`rs_fwd`独立供EA加法。Rd来自W/Rs来自M及反向组合均实跑；Rd=Rs时也分别检查普通M转发及load W转发，地址与数据均正确。
4. **Z的M/W/架构链**：M只在有效、无fault、ZW=1时覆盖；M=ADD而W=CMP时选择W，M新CMP的0覆盖W旧CMP的1；合法算术和地址ADD没有ZW。新测试显式见证选择W的1及选择M的0，避免只有最终状态正确却未触达条件。
5. **C/V与取消**：RF/ZW/CVW由所属W的valid/fault、mode_active和reset资格共同控制；地址ADD和非算术0候选未获得CVW。老CMP的Z写入、老load的RF写入与年轻MEM故障同边沿均正确保留，故障自己及年轻操作无副作用。
6. **年龄优先**：MEM越界取消EX及更年轻槽并阻断自身DM；老W不被年轻fault全局屏蔽。EX fault/HALT仍让老合法MEM STR完成。EX branch取消年轻fetch_fault/非法opcode，无法越过老MEM错误。本轮重读这些组合条件，并核对生产T05/T16/T17/T18与附加年龄见证。
7. **fault_pc**：未要求新增诊断端口。生产TB检查WB fault token的w_pc等于独立模型的未完成最老pc，且之前所有正常事件数量吻合；新测试对两种MEM fault都手写fault_pc=1并核对停止token年龄。
8. **退出边沿**：成功STR形成WB气泡；故障STR保留w_valid/w_fault；HALT/fault均在W停止标记消费边沿且valid_next全部为空时进入终态。测试边沿前采样使能、边沿后等待NBA检查停止和架构状态，未采用同沿IR/MDR再捕获造成额外延迟。
9. **复位抢占与恢复**：rst组合屏蔽IM/DM/RF/flags资格，实际同步状态在下一上升沿清空。生产16个复位探针覆盖pending MEM store与已完成store、RUN/DRAIN/终态。本轮追加HALT/fault的WB消费前复位、已经终止后复位，均检查DM保存，并撤销reset后实际从pc0运行`MOV R0,#7; HALT`，6周期完成。

## 4. 生产测试与已存在实际日志的核对

此处核对的是交付目录内 2026-10-09 01:03 的已有实跑日志；主审本轮重跑另行登记，不能将以下已有日志冒称本子审查进程重跑。

- `datapath.log`：128程序、16 reset_probes、3380正常完成事件、14/14合法opcode、0失败；基准17周期/10动态指令/1load-use/1redirect。`case_results.csv`的每例 `witness_seen` 与 `witness_required` 一致，定时条件不能未触达而空通过。
- `units.log` / `unit_results.json`：CLA4 512、CLA16 564300、ADD/SUB 564300、ALU 2257200、新译码65536、立即数512、flags状态转移512、RF 262161、PC 65539、目标3584，PASS。C/V oracle以精确整数范围与unsigned a>=b判断，不复用DUT V布尔式。
- `stress.log` / `stress_results.json`：4696例、33134正常完成事件、1408 fault token、taken3636/not_taken2155、全部8种初始flags、14合法opcode，PASS。含3584访存有符号offset/边界、100有限循环、500有限控制流、512 JZ边界。
- 三个TB有明确超时退出；预期与输出比较使用四态不等。主TB对所有正常事件检查pc/副作用资格/目标/值及最终全DM，独立stress逐边沿检查全架构状态。计数没有把fault token、bubble或取消指令升级为正常完成指令。
- 保留范围限制：CLA16与ADD/SUB未全穷举2^33，ALU未全穷举2^35，CPU也未全穷举状态空间；stress中taken JZ -1的无穷自环通过强制Z=0避免非终止测试，日志明确说明。

## 5. 本轮新增实跑记录

工具：XSim v2025.2；实跑会话 2026-10-09 09:19:23 至 09:19:25（本地时间）。证据：本目录 `tb_audit3.sv`、`run_audit3.cmd`、`audit3_run_all.tcl`、`audit3.log`；日志记录16条逐例PASS及最终总PASS，进程退出码0。

| 用例 | 周期 | load-use | 要求实际出现的关系 |
|---|---:|---:|---|
| BACK_LOAD_DIFFERENT | 9 | 1 | 两次返回数据不同；ADD使用正确两个load值 |
| BACK_LOAD_SAME_DEST | 9 | 1 | 第二个load覆盖第一个；消费者从W取得5A00 |
| M_RESULT_OVER_OLD_LOAD | 8 | 0 | M的2优先W旧load的00A5 |
| NEW_LOAD_OVER_OLD_VALUE | 9 | 1 | 新load优先旧同名1；消费者从W取00A5 |
| STR_DATA_W_BASE_M | 8 | 0 | store Rd选择W、Rs选择M |
| STR_DATA_M_BASE_W | 8 | 0 | store Rd选择M、Rs选择W |
| STR_SAME_SOURCE_M | 7 | 0 | 同源Rd/Rs均选择M；DM[32]=32 |
| LOAD_STR_BOTH_SOURCES_W | 8 | 1 | 同源Rd/Rs均选择W；DM[33]=33 |
| Z_W_CMP_THROUGH_M_ADD | 10 | 0 | Z选择W的1，M算术不遮挡CMP |
| Z_NEW_M_ZERO_OVER_W_ONE | 9 | 0 | Z选择M的0，JZ不跳 |
| OLD_CMP_WB_WITH_MEM_STORE_FAULT | 6 | 0 | 老CMP更新Z；fault_pc=1；全DM保持 |
| OLD_LOAD_WB_WITH_YOUNGER_LOAD_FAULT | 6 | 0 | 老load写CAFE；年轻load无写；fault_pc=1 |
| RESET_RESTART_fault0_consumption1 | 6（重启） | 0 | HALT消费边沿前复位后实际重新运行 |
| RESET_RESTART_fault1_consumption1 | 6（重启） | 0 | fault消费边沿前复位后实际重新运行 |
| RESET_RESTART_fault0_consumption0 | 6（重启） | 0 | HALTED状态复位后实际重新运行 |
| RESET_RESTART_fault1_consumption0 | 6（重启） | 0 | FAULTED状态复位后实际重新运行 |

运行命令（在本目录执行）：

```powershell
& 'C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'D:\OneDrive - University of Glasgow\同步文件夹\大三上\Courses\数电\Pre4_数据通路设计与验证\Vivado\desktop_launch.py' $env:ComSpec /d /c run_audit3.cmd
```

运行脚本使用本目录13份哈希相同的RTL副本以避免Windows批处理解析中文目录造成的启动问题；命令文件使用CRLF。初次启动的批处理路径/换行解析失败没有执行有效仿真，不计入任何PASS；修正测试目录命令后重新完整编译、展开与实跑才形成以上证据。

## 6. 哈希绑定

| 文件 | SHA-256 |
|---|---|
| `rtl/addsub16_cla.v` | 5E11B2314FF55A995F41962FF337D31307642EF5BDF20DF76F91FE8D10E30EE3 |
| `rtl/alu16.v` | AC1E94A66EE28698F906DA1927B50C96B80F3B04989B3C75B9CF6DF5DDE509E9 |
| `rtl/branch_target16.v` | 7C48A5E0E8AF99CCCF66C6111B78F99E0FC8F096802E2D1C122FB7A04CB2739E |
| `rtl/cla16.v` | 8D3221021088D0362FAF8CB4E39128D0BC2E8B6E145DFE30A5F11D1E44218D42 |
| `rtl/cla4_pg.v` | 1E9B013B5710956632032EED5660A3EDE77BB12D8E86A78E5BCA070CD4FAECC1 |
| `rtl/datapath_core.sv` | CE1EAD66BB74B9029ECB2111760DE5647B8AEABB8054E65CF61E5015742FEF38 |
| `rtl/flags_reg.v` | FE0ABC775C5A99EC4A77AD2BF45A750C1FE9D9CF0FD9BFE65CEAB96D46EB50AC |
| `rtl/imm_ext16.v` | 1763C72EE94458DC3C193D4E9B2096851926A6E05A50EE0D4889608A7BA22178 |
| `rtl/isa_decode.v` | 43EEBFBC44AAFD11D5455C92AD38ABB72C82DF21CFAF5178942140E9A5A7C8F4 |
| `rtl/operand_forward.v` | 30513341D5B60A4393A1784DCC0CB756FD251206655A458F2E2C17E01D1FAA65 |
| `rtl/pc16.v` | 969F0729A1F09740BC9627294BA7F0D8E39F3EAA9F0071504455B42B45405A38 |
| `rtl/regfile4x16.v` | 06A3CB9622B766909A141C6DCE572EA8D41E62FD91C7A44214DFA284E45A1029 |
| `rtl/sync_memories.v` | 87BD522F24B792F91C6D4C6C53AD8A4834F0E6A71F50292123E33C95FF429D6C |
| `tb_audit3.sv` | 5E97A8CCE544174E9CB2521CCDEAB79CFDB164E98CDF53CF4DA71770B9A7AD8A |
| `audit3.log` | A90D86C2D7B761892C6F0C19FF97527F4D7145B0DA77BC800B1972A8052A44BF |

## 7. 仍应保留的实现限制

交付 `post_synth_timing.rpt` 是 `xc7z020clg484-1`、10 ns核心时钟约束下的OOC综合后报告。直接读取报告仍为 setup WNS=-0.810 ns / TNS=-1.273 ns（3 failing endpoints），hold worst slack=0.271 ns。它不是布局布线后的全路径收敛结果，外部接口延迟也未被该OOC核心报告完整约束，不能宣称100 MHz运行、Fmax或上板通过。本轮没有扩展到布局布线、时序优化或实际BRAM IP/板级验证。

本轮生产RTL/TB无需修正；新增定向测试提升的是证据明确性。硬件部署前仍需要实际板卡约束、实际存储IP契约、实现后setup/hold/DRC及上板验证，作为另一阶段的验收。


## 交付版便携复跑补充

上面的命令和目录描述记录最初独立审查过程。交付包复现时，把完整包复制到英文路径，进入review后运行run_audit3.cmd即可；该入口使用../Vivado/rtl，不依赖私有13份副本。最终便携入口已经重新完整执行得到AUDIT3_RECEIPT_ACCEPTED；表中audit3.log哈希刷新为此次交付复跑日志。主XPR的13RTL加3主要TB共16个引用不变。
