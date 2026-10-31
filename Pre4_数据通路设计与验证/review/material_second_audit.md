# Pre4 第二轮材料与讲解逻辑审查

审查时间：2026-10-09。此报告为只读审查结果，修正及最终重新打包由主执行者落实。审查入口PPT SHA256为 `CD948F62196CA3E18DB93256925BAE32749A368D2DF068DCC78DB8F00E1299FA`，不是后续修正后的哈希。

## 审查范围

完整检查26页PPT的原生XML文字与逐页备注，18页主讲稿及8页答辩讲稿、五人分工、ISA文档、典型指令逐拍文档、导航与交付清单、5张逻辑SVG的文本和线路坐标。独立阅读用户v1.4规格的架构、接口、译码、CLA、流水载荷、典型流程、优先级及验收规则，并对照交付RTL、baseline_trace.csv、case_timings.csv及成功日志。

本分支未重新打开PowerPoint做视觉渲染、未重跑HDL、未修改交付材料；这些检查及修正由其他审查分支负责，不能由本报告推断已经再次通过。

课件检查采用既有PowerPoint文本提取，并重新校对当前文件/ZIP成员哈希：

- CHA Lec 01-B：`26DC5BB8EF973AF5915D6DDAA1C5200145022D5DF13FD7CEDB08F4C7AE577C54`。第14–20页明确五级流水与ISA→DP→CU设计顺序。
- 第三次-第四次课.zip内Lec17：`6123A8BB4DC7CFA0A2309F632D1A0A96E45BBDE8717B32670A71CD8429B4367B`。第18、25–35页的16位4+2+2+8格式、RF/ALU/PC/PSW、结构实例化方法是有关参考。
- 第二次课.zip内Lec17：`F47D0B1D96D507E2678294BC3D216D1C61D7415CB89E9607C7545280851D3540`。不同示例Opcode不能直接拼接到本次v1.4。
- 第二次课.zip内Lec14：`829940A56CBC56BD795A6D7247190E64636075DC40F19A2DDE0161B62C12B5C8`。刺激、DUT、监测、自检查及等待有效采样边沿对应本次TB方法。

## 需要修正的发现

### MATERIAL-01：详细总图的M转发源连接到了EX组合输出线路

重要级别：P2；文件 `diagrams/datapath_overview.svg` 第31行。

`M: ready non-load result` 的反馈线路从 `(881,456)` 起始。该坐标落在第23行的 `M850 497 H882 V345 H915` EX组合结果→MEM入口线路上，并非MEM级已寄存的 `m_exec_value`。反馈箭头又返回EX的operand_forward，因此图形含义会像当前EX结果回到自身，误导读者认为有组合环。

RTL实际使用 `m_exec_value` 寄存字段，该图应从MEM框内/边界的已寄存值发出，例如从MEM access guard框的m_exec_value一侧出线，绕过其他线路下行再反馈至EX，并明确标注 `M: registered m_exec_value, non-load and ready`。修正后重生成同名PNG，核查SVG/PNG一致。正文PPT的简化原生五级图没有这个具体坐标错误。

### MATERIAL-02：所显示PC总线缺少匹配valid，不能单靠当前曲线辨认气泡

重要级别：P2；正文PPT第12、13页及其 `figures/wave_load`、`wave_branch`，第15页同样宜处理。

第12页显示x_pc/x_valid，但m_pc/w_pc没有m_valid/w_valid。页内要求“PC只在匹配valid=1时计数”，读者却看不到后两者的valid。实际baseline C10中w_valid=0、w_pc=0005，C12中w_valid=0、w_pc=0007，这些未复位载荷会被误读成有效指令。第13页x_pc/m_pc也无匹配valid；图并不直接证明C13 EX清空。第15页w_fault需要与w_valid一起表示有效故障token。

修正方案二选一：显示每个已展示PC的对应valid；或由真实VCD派生 `EX/MEM/WB: valid pc or bubble` 阅读轨道，明确写出无效区间。不要只增加一句“需看valid”而仍不提供valid。可删去非核心原始PC轨道保持字号。保留原VCD/WDB以便核查。

### MATERIAL-03：最后一页口述时间明显过密

重要级别：P2；第18页备注与 `docs/英文逐页讲稿.md`。

原第18页74个空格分隔词，目标25秒，约178词/分钟。其余1–17页约96–130词/分钟。全套14分15秒相加正确，但收尾页不符合其余页面给学生英文指图讲解留出的节奏。

建议在不改变页码、五人分工及总时间下，将第18页缩为：

> The Pre4 package connects our current ISA to datapath source, instruction traces and Vivado evidence. The next milestone explains the control unit. Board constraints, routed timing and system performance remain unverified. Detailed source and backup slides support implementation questions.

约43词/25秒，约103词/分钟。同步修改PPT备注源与外部讲稿，重新生成PPT并校对备注一致，更新相关哈希及总词数说明。

## 未发现需要改变设计的矛盾

1. ISA 0/1 MOV、2/3 LDR/STR、4/5 ADD、6/7 SUB、8 AND、9 OR、A CMP、C JUMP、D JZ、E HALT以及B/F非法，在PPT、ISA文档、机器字示例及RTL之间一致。R0可写，u8/s8扩展、JZ自身pc+1、16位模地址后全地址容量检查均一致。
2. 四CLA4和独立K1–K4组間超前公式正确。SUB C=无借位，ADD/SUB只写C/V，CMP只写Z，访存候选不改标志；没有把教学示例borrow/unsigned overflow错称为本次C或V。
3. 同步IM/DM输出与有效标签对齐、没有额外同沿IR/MDR、成功STR的WB气泡与故障STR的WB停止token，在文档及讲稿中描述一致。
4. baseline实际17周期、10有效指令、1停顿、1taken分支、最终RF 8/2/8/32及ZCV110与CSV和讲稿一致。C9为相对75–85ns，C12为105–115ns；T17a C5为35–45ns、C6为45–55ns，与case起点归一说明一致。
5. 128个程序、16次复位、3380有效完成事件、14/14 Opcode覆盖的表述没有扩大成CPU程序空间穷举。16位大空间算术回归明确为受限验证。
6. 10ns OOC估算WNS=-0.810ns明确未满足，不把仿真周期或305 LUT/259 FF当作板级频率/性能通过。IM/DM在核心外，资源排除存储的说明一致。part按EES-331参考器件登记，没有跨封装引脚约束或实际板卡验证宣称。

## 教师要求与附加实现边界

Pre4的四项明确请求有对应材料：ISA第2–3页、框图/I/O/功能第4–9页、典型处理第10–15页、源码和带说明仿真/EDA第12–17页及附录。详细源码、逻辑SVG、实际RTL analysis PDF、日志和原始波形皆可按导航找到。

译码、转发、load-use、年龄资格、HALT/fault排空控制是让流水数据通路可运行的必要实现，不能把这些已存在的代码解释成提前完成Pre5专门CU汇报。功能周期和OOC报告是补充证据，不能解释成完成Pre6布局布线、上板和CPU性能验收。Lec17中的4级示例和不同Opcode是教学例子，采用用户明确的五级v1.4而不照搬示例属于合理来源区分。

## 修正后验收要求

主执行者落实上述3项后，需重新核对相应SVG/PNG、PPT备注/外部讲稿、波形来源/valid表示，并更新最终PPT、受影响文档及ZIP哈希。HDL功能未因材料修正而改变；是否另有代码/脚本修正与复跑需要由功能审查分支确认。本报告不将待落实建议计作已完成。
