# Pre4 第三轮材料独立审查

日期：2026-10-09。只读生产包：`D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre4_数据通路设计与验证`。

审查入口 PPT SHA256：`9A32E55901D389F35FA8C12B5933A238CE10E7746584B63D1BD269ADBC55F7CB`。共26页，18页正文及8页备份。

规格来源已定位至课程目录 `CPU核心设计/16位流水线CPU核心设计文档.docx`；实际 SHA256 为 `FEABA5CDD726E514632113A11C8D692F9DD22756E50A49A2175E99AD2CDD232A`，与指定v1.4绑定相同。对照文本为 `C:/Users/Donson/Documents/ChatGPT/Shudian/pre4_20261008/source.txt`。

## 结论与边界

未发现新的P1/P2材料技术矛盾。三套结果、ISA、逐拍流程、波形、原生PPT文字与讲稿之间一致。发现1项P3计词数字误差，见下文。

本分支完整读取26页原生文字及备注、全部5份docs文档与根导航，核查5张逻辑SVG及其PNG、3张波形SVG及其PNG；读取三套日志终止凭据和JSON/CSV，对照OOC时序报告。本分支没有运行HDL或打开PowerPoint，因此不把读取现有PASS升级为第三轮重新仿真，也不把图片检查等同于本轮26页PowerPoint渲染。主任务负责这些独立验证。

## 发现 MATERIAL3-01：收尾词数写成43，实际为39

优先级：P3，仅排练元数据。

`docs/五人分工与排练.md:37`称第18页“已缩短到43词”；`review/二次完整审查与修正.md:15`亦称43词、约103词/分钟。实际第18页PPT备注和外部讲稿正文相同，按空白分词为39词，25秒对应93.6词/分钟。正文没有连字符复合词造成不同分词口径，因而43不是现有文本的空格词数。

建议当前排练说明改成39词；二次总结中的数字可更正并注明第三轮计数。旧 `material_second_audit.md:46` 属于当时提案快照，可保留并由新总结说明更正。无需改第18页正文、备注、时间或PPT，仅统一计词记录即可。

18页正文实际共1554个空白分隔词，原总结“约1554词”正确。总目标时间855秒，即14分15秒；五人时间与页内时间相加一致。

## 逐页备注、内嵌图和来源

只读核查脚本为同目录 `audit_materials3.py`，实际运行完成并返回 `MATERIAL SCRIPT PASS`。

- 26页备注的叙述正文及Sources，与 `docs/英文逐页讲稿.md` 对应部分逐字一致。
- 第12/13/15页内嵌图分别与 `figures/wave_load.png`、`wave_branch.png`、`wave_fault.png` 的SHA256完全相同。
- 第17页内嵌图与core/ALU阅读PNG一致；第22–26页与CLA16、ALU、forwarding、flags及mapped core阅读PNG一致。未出现旧图留在PPT而PNG已更新的情况。
- Sources中的17项具体相对路径均实际存在；按根导航说明，rtl/tb/eda位于Vivado内，diagrams/review位于包根。八项裸文件名日志、CSV、JSON与EDA脚本也全部存在于Vivado内。
- 原规格DOCX在上述课程位置可定位，并有版本日期和哈希绑定。BASELINE/T02/T15/T17a/T16/T18b及LOAD_MOV_NO_FALSE_STALL等见证名称可在当前 `datapath.log`、`case_results.csv` 及TB中定位。

## 波形与CSV的直接核对

脚本独立读取原VCD，按case_timings.csv的起点和SVG横坐标反算绝对ps。对每个标注总线段及标量高低段，检查区间首尾及区间内所有VCD变化，不仅检查中点。

| 图 | 用例及相对区间 | 完整区间核对段数 | 结果 |
|---|---|---:|---|
| wave_load | BASELINE，65–115ns；起点30000ps | 39 | 全部一致 |
| wave_branch | BASELINE，95–145ns；起点30000ps | 31 | 全部一致 |
| wave_fault | T17a，20–70ns；起点2420000ps | 30 | 全部一致 |

共100段，全部与VCD一致。PNG人工阅读中显示的valid与SVG一致：第12页x/m/w PC均有对应valid；第13页x/m PC均有对应valid；第15页m_exec_value及w_pc分别有m_valid/w_valid。

baseline CSV的C9停顿、C10 EX与WB bubble、C11 W-load向CMP转发、C12 M-CMP候选决定JZ、C13目标取指、C15/16/17的HALT EX/MEM/WB，与讲稿、典型流程文档和PPT附录一致。T17a C5为相对35–45ns，C6为45–55ns，故障停止在55ns结束边沿；排练稿已正确，没有旧40–50ns区间。

## 三套数字与技术关系

当前日志明确具有完整终止凭据：

```text
UNITS_PASS CLA4=512 CLA16=564300 ADD_SUB=564300 ALU=2257200 DECODE=65536 IMM=512 FLAGS=512 RF=262161 PC=65539 TARGET=3584
DATAPATH_PASS cases=128 reset_probes=16 retired=3380 failures=0 legal_opcode_coverage=14/14
STRESS_PASS cases=4696 memory_offset_boundary=3584 loops=100 random_control_flow=500 branch_offset_edges=512 completed=33134 fault_tokens=1408 taken=3636 not_taken=2155 legal_opcodes=14/14 failures=0 seed=A9D41009
```

case_results.csv实际128行，retired合计3380；BASELINE为17周期/10完成/1stall/1redirect。主套件28基准或定向加100受限随机与附加4696压力套件没有混计。3584+100+500+512=4696；压力JSON与日志的33134完成、1408故障标记、3636 taken、2155 not-taken、8/8初始标志一致。

CLA16及addsub各564300，ALU2257200与当前单元结果一致；512/65536/512/512的精确空间均指CLA4/译码/扩展/flags，不把16位算术大空间标成全量。PPT第16页与讲稿明确保留有限空间边界。

ISA 14种合法Opcode与B/F非法、新旧Pre3不兼容、R0可写、u8/s8、CMP只写Z、ADD/SUB只写C/V、SUB C为无借位、JZ自身pc+1、模16位EA后容量检查，在PPT/讲稿/ISA文档/典型图之间一致。成功STR的MEM完成与WB bubble、故障STR的有效WB停止token、同步RAM输出承担对应数据边界、load-use只停前端及年龄资格，也保持一致。

详细总图已修复M转发来源：SVG第31行从 `M915 362`（MEM access guard的m_exec_value入口边界）发出，不再从EX组合输出线路发出；PNG清晰标为registered m_exec_value，返回operand_forward。五张逻辑图明确标注解释图，未冒充实际RTL analysis。CLA16 K1–K4公式、四组输入和P/G独立性表述一致。

## 状态与性能证据

PPT第17页和讲稿保留WNS=-0.810ns、10ns OOC约束未满足的结论；导航及最终报告保留TNS=-1.273ns、3个失败端点、33输入及53输出未设置I/O延迟、HD.CLK_SRC未设。`post_synth_timing.rpt`支持这些数字。没有将仿真10ns时钟、OOC资源或CLA结构升级成100MHz收敛、布局布线通过或上板结果。

源DOCX中的“新RTL尚待实现/验收”和旧review中的pending是规格形成时或过程审查时的历史状态；当前材料的有限通过由当前源码及终止日志支撑。此处没有修改原DOCX，也没有把它的抽象17周期排程单独当成实测证明。第三轮新仿真与native显示结论仍应由主任务新证据登记。

生产材料未由本分支修改；唯一建议是上面的计词数字统一。
