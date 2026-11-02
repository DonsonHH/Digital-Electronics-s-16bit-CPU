# Pre6 CPU集成与验证

常用目录：`D:/OneDrive - University of Glasgow/同步文件夹/大三上/Courses/数电/Pre6_CPU集成与验证`。

主要材料为[英文PPT](Pre6_Group2_CPU_Integration_EN.pptx)和[五人英文讲稿与答辩](Pre6_英文讲稿与答辩.docx)。本版为24页连续正文，含独立目录及1.1、3.3.1等层级编号；约1,273个英文词，讲解预算14分钟，另留1分钟换页和指图。中文架构原图用于定位，正文和口头讲解为英文。

| 章节与老师要求 | PPT页码 | 主要内容 |
|---|---|---|
| 开场与目录 | 1–2 | 项目身份与六章主线 |
| 1 ISA设计 | 3–4 | 官网完整编码表、真实源、立即数和Z/C/V |
| 2 设计流程 | 5 | 约束→决策→架构后果；实际设计顺序 |
| 3 CPU结构、接口与执行 | 6–16 | 中文整体图/DP、系统、板级、CU、冒险、分支与停止 |
| 4 功能验证 | 17–19 | 模型→预期→XSim→EES-331观测 |
| 5 性能验证与权衡 | 20–23 | 周期与CPI、布线结果、离线优化候选 |
| 6 交付 | 24 | 对应老师要求归纳成果 |

| 讲者 | 页码 | 负责内容 | 预算 |
|---|---|---|---|
| A | 1–5 | ISA与设计流程 | 2:35 |
| B | 6–10 | 整体架构、DP、系统和板级接口 | 2:45 |
| C | 11–14 | 控制协作、模式、依赖与load-to-store | 3:00 |
| D | 15–19 | 分支、精确停止、仿真与实板证据 | 2:50 |
| E | 20–24 | 性能、工程权衡与交付 | 2:50 |

## 直接打开Vivado

在D盘本目录双击：

- [Open_CPU_Project.cmd](Vivado/Open_CPU_Project.cmd)：CPU行为仿真、RTL结构、OOC综合和综合后功能仿真。
- [Open_EES331_Project.cmd](Vivado/Open_EES331_Project.cmd)：带VIO和真实引脚约束的板级综合、布局布线和bitstream生成。

入口自动建立`C:/Users/Donson/Documents/CPU_Pre6/CPU`或`EES331`工作工程，处理Vivado GUI和IP生成对路径的要求，无需手动搬目录。D盘保留源包与测试记录。工作目录从源码创建，避免携带旧缓存的只读属性；综合、仿真登记同一组MEM文件。已有可用工作工程与用户修改会保留；首次创建失败后可直接重试。

默认程序`copy_checksum`；CPU design top为`pre6_cpu_top`，simulation top为`tb_pre6_cpu`。**Run Synthesis**应无错误完成；**Behavioral Simulation**和**Post-Synthesis Functional Simulation**各自检查55周期、35条完成指令、16次hold、0次redirect、8次store。详见[Vivado操作说明](Vivado/README.md)。

在本目录PowerShell复跑：

```powershell
.\Vivado\run_tests.ps1 -Program all
.\Vivado\run_tests.ps1 -Program baseline
.\Vivado\run_tests.ps1 -Program copy_checksum -Mode full
```

五程序周期为25/17/30/15/55。`full`还检查真实OOC综合与综合网表功能；每次在独立英文工作目录运行，原始输入和保留输出写入`Vivado/验证记录`并逐项绑定哈希。完整九套回归和独立/负向检查继续使用相邻[CPU核心设计](../CPU核心设计/README.md)入口。

本轮已重跑五程序、CPU综合前后检查、板级完整构建；还通过原生Vivado GUI模式重置后重复仿真/综合及板级实现。当前板级GUI构建setup/hold裕量1.530/0.073ns；bitstream已生成，本轮未连接或下载板卡。保存的工具原始记录见[运行核对索引](配套源文件/核对/运行核对.json)。

## 技术和证据口径

冻结基线：`9475f210c7e567cb41f3856ff3bcebc6611ac991` / `cpu-v1.6-ac1-ees331-verified`，CPU v1.6、ISA v1.5、默认AC1、EES-331（xc7z020clg484-1）。生产RTL、ISA、流水时序及验收标签保持不变。源包新增的两份配置封装只直通原有接口并统一镜像文件名。

- 第6–11页复用核心规范的中文原图；第3页采用Lab网站ISA原SVG。SVG、PNG及[来源记录](配套源文件/图源/r3/图源来源.json)随源包保存。
- 第14–16页来自真实独立仿真记录。故障例C6中老ADD同拍完成WB、M级LDR越界、年轻JUMP取消，C7进入FAULTED。
- 第18页波形来自本轮baseline实际XSim CSV/VCD逐边沿核对。C9同时发生前端hold和老store；波形不是Vivado界面截图。
- 第19页为**Decoded archived VIO snapshots**。RF为写回影子；实板S1结论限于HALT后的复位重启。平台照片注明手册来源，测试依据为归档VIO。模型代码、镜像、预期值及实际结果均有来源绑定。
- 第20–21页的周期来自已归档实板计数。`C=N+4+S+2R`适用于这五个正常HALT程序，N含HALT；时间换算采用100MHz设计时钟。
- 第22页资源与时序来自原验收版本的五份完整board top布线报告，含存储器、VIO及观测逻辑；与本轮新GUI构建分别记载。第23页两项候选保持离线实验身份。

逐页的“结论→来源→预期→实际→可支持范围”见[来源索引](配套源文件/source_map.json)，同一来源及SHA256保留在PPT备注中。

## 当前制作入口

1. [collect_v3.py](配套源文件/collect_v3.py)：冻结输入、新XSim、ISA预期及图源核对；生成统一内容和证据索引。
2. [narrative_v3.py](配套源文件/narrative_v3.py)：24页英文正文、中文指图提示、章节和时间预算。
3. [build_slides_v3.mjs](配套源文件/build_slides_v3.mjs)和[build_script_word_v3.py](配套源文件/build_script_word_v3.py)：生成PPT和Word；表格、性能图保持原生可编辑，完整中文连接图保留SVG源。
4. [check_delivery.py](配套源文件/check_delivery.py)：检查最终文件、页码/备注/讲稿、媒体、图表工作簿、来源、工程输入和原始运行证据。
5. [sync_course.py](配套源文件/sync_course.py)：带备份和逐文件哈希核对的课程目录同步。

旧版制作脚本保留其版本名，仅供历史追溯，当前材料采用上述v3入口。主要交付仅PPT和讲稿；渲染及运行记录放在配套源中。CPU核心规范继续由相邻`CPU核心设计`维护。
