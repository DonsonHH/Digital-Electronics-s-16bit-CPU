# Pre6 CPU集成与验证

日常使用目录：`D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre6_CPU集成与验证`。相邻的`CPU核心设计`已同步当前AC1架构版r4正式文档、源码、工具与证据。Git仓库保留制作与版本管理源。

打开 [英文PPT](Pre6_Group2_CPU_Integration_EN.pptx) 和 [五人英文讲稿与答辩](Pre6_英文讲稿与答辩.docx)。PPT为23页连续正文；讲稿包含逐页英文、中文指图提示、交接句、答辩和Vivado操作步骤。

| 老师要求 | 正文页 |
|---|---|
| ISA设计 | 2–3：完整16项Opcode、字段、真实源、立即数及标志语义 |
| 设计流程 | 4：ISA、资源、时序、控制、集成、验证之间的依赖 |
| CPU结构与接口 | 5–15：完整架构、datapath、CU、系统、板级、接口及执行实例 |
| 功能验证 | 16–18：验证链、实际XSim波形、实板五程序及S1 |
| 性能验证 | 19–22：计数口径、周期构成、CPI、布线结果、两项候选 |

| 讲者 | 页码 | 负责内容 | 预算 |
|---|---|---|---|
| A | 1–4 | ISA、设计流程 | 2:35 |
| B | 5–9 | 完整架构、datapath、系统接口 | 2:45 |
| C | 10–13 | 完整CU、模式、冒险、load-to-store | 3:00 |
| D | 14–18 | 控制流、功能验证、实板结果 | 2:50 |
| E | 19–23 | 性能、候选、交付 | 2:50 |

英文正文约1,302词，预算14分钟，另留1分钟交接和指图停顿。预算用于五人实际排练；完整编码表与连接图供讲解时定位，不逐格朗读。

## 直接自行验证

1. 双击 [Vivado工程](Vivado/工程/project/pre6_cpu.xpr)。默认仿真程序为`copy_checksum`，simulation top为`tb_selected_program`，design top为`cpu_system`。
2. 在Vivado运行 **Run Simulation → Run Behavioral Simulation → Run All**。TB自动检查每次WB、store、标志、停止状态及计数；正常结束输出`BOARD_SELECTED_PASS`和55周期。
3. 双击 [运行全部验证](Vivado/Run_Pre6_Verification.cmd)，或在本目录运行：

```powershell
.\Vivado\run_tests.ps1 -Program all
```

依次运行`all_ops`、`baseline`、`loop`、`memory_copy`、`copy_checksum`和`system`。也可单选程序。每次新建记录，不覆盖已有记录；`最近运行.json`指向本次结果，失败会保留`FAIL`。

[Vivado说明](Vivado/README.md)介绍测试入口、文件、看波形和更换工具路径。本次已实际完成六套工程验证，并在D盘重开课堂工程、重新仿真55周期；D盘PowerShell入口也已实际复跑通过。运行记录保留原始输入、日志、CSV、WDB/VCD和XPR。`工程`是便于GUI使用的工作副本，原始记录另存。

## 设计和证据口径

基线为`9475f210c7e567cb41f3856ff3bcebc6611ac991` / `cpu-v1.6-ac1-ees331-verified`：CPU v1.6、ISA v1.5、默认AC1、EES-331（xc7z020clg484-1）。CPU的ISA、生产RTL、流水时序和验收标签保持不变。

- 第13–15页的8/9/6周期执行表来自已绑定的独立仿真CSV。第17页展示本次baseline的C6–C13采样窗口，CSV与VCD逐边沿对照；C9同时有前端停顿和较老store。
- 第18页为 **Decoded archived VIO snapshots**，RF读数是写回影子。S1实板结论限于CPU停止后的复位重启；本轮没有重新连接、烧录板卡。
- 第19–20页的周期来自既有实板计数；`C=N+4+S+2R`用于这五个正常HALT程序，N含HALT。时间换算采用设计100MHz；没有独立频率或墙钟测量。
- 第21页是含VIO、存储器和观测逻辑的完整board top布线结果。第22页的两项候选保持离线身份，默认AC1为实板验收版本。

逐页来源、预期、实际与SHA256见 [来源索引](配套源文件/source_map.json)，每页备注也保留同一来源。冻结输入按Git原字节核对；新运行的输入和保留输出逐项核哈希。

## 制作源

- [narrative_v2.py](配套源文件/narrative_v2.py)：23页英文正文、中文提示、分工与预算；Word和PPT备注同源。
- [collect_v2.py](配套源文件/collect_v2.py)：核对冻结基线与实际运行，生成数据、讲稿源和来源表。
- [diagram_layouts.mjs](配套源文件/diagram_layouts.mjs)：六张投影版完整图，同源生成可编辑SVG与原生PPT几何；[图源](配套源文件/图源)还保留四张规范原图及英文版。
- [build_slides_v2.mjs](配套源文件/build_slides_v2.mjs)、[build_script_word.py](配套源文件/build_script_word.py)：生成正式PPT和Word。图表含内嵌XLSX；波形保留WaveJSON、SVG和离线编辑HTML。
- [check_delivery.py](配套源文件/check_delivery.py)：核查23页/备注/讲稿、原生表格和图表、非空媒体、工程输入、真实运行与来源哈希。

输出先在临时目录生成，经过原生PowerPoint和Word渲染后发布。完整核心规范继续由相邻`CPU核心设计`维护。
