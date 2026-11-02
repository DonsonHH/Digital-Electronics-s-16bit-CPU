# Pre6 Vivado工程入口

从D盘本目录双击：

| 入口 | 用途 | 已实际检查的流程 |
|---|---|---|
| [Open_CPU_Project.cmd](Open_CPU_Project.cmd) | CPU代码、RTL结构和功能验证 | 行为仿真、真实OOC综合、综合后功能仿真；重置后重新运行 |
| [Open_EES331_Project.cmd](Open_EES331_Project.cmd) | EES-331完整板级工程 | 行为仿真、综合、布局布线、DRC、生成bitstream |

入口自动在`C:/Users/Donson/Documents/CPU_Pre6/CPU`或`EES331`创建并打开工作工程。源码、程序、测试和记录保存在D盘本目录。英文工作路径处理Vivado GUI的`codecvt`路径转换和VIO输出产品生成问题，无需手动搬工程。

首次创建失败时，再次双击会保留未完成目录并重新创建；已存在的可用工作工程和本地修改会保留。旧工程已备份在课程目录的`_Pre6_历史备份`及`C:/Users/Donson/Documents/ChatGPT_CPU_归档`。

## CPU工程直接操作

工作工程为`C:/Users/Donson/Documents/CPU_Pre6/CPU/project/pre6_cpu.xpr`，design top为`pre6_cpu_top`，simulation top为`tb_pre6_cpu`。默认程序为`copy_checksum`。

1. **Run Simulation → Run Behavioral Simulation → Run All**。
2. **Run Synthesis → Open Synthesized Design**。
3. **Run Simulation → Run Post-Synthesis Functional Simulation → Run All**。

两类仿真都自动比较每次WB、store、标志、停止现场及计数，正常输出：

```text
PRE6_CPU_PASS program=copy_checksum cycles=55 completed=35 stalls=16 redirects=0 stores=8
```

在Scope展开`tb_pre6_cpu/check/dut/u_cpu_system_inst/core`，可查看`x_valid/m_valid/w_valid`、`x_alu_a_sel/x_alu_b_sel`、`load_use`、`rd_fwd/rs_fwd`和`rf_we/z_we/cv_we`。CW_X/M/W是这些控制字段的逻辑分组。

CPU工程使用真实`-mode out_of_context`综合。板级I/O、VIO和bitstream在EES331工程中完成。

## EES-331工程

工作工程为`C:/Users/Donson/Documents/CPU_Pre6/EES331/project/pre6_cpu.xpr`，top为`pre6_ees331_top`，目标`xc7z020clg484-1`。

它包含M19的100MHz时钟、L18的S1、八个LED引脚、BUFG、同步复位释放和VIO。可以依次运行 **Run Synthesis → Run Implementation → Generate Bitstream**。本轮GUI验收的setup/hold裕量为1.530/0.073ns。bitstream保存在`project/pre6_cpu.runs/impl_1/`。

行为仿真的VIO复位释放由TB模拟，复位释放计数缩短为3位；实际板级默认参数保持21位。入口只打开/编译工程，板卡下载由后续明确的上板操作完成。

## 自行复跑程序

在本目录PowerShell运行：

```powershell
.\run_tests.ps1 -Program all
.\run_tests.ps1 -Program baseline
.\run_tests.ps1 -Program copy_checksum -Mode full
```

`full`同时检查行为、综合和综合后功能仿真。每次生成新的独立工作区，记录到`验证记录/`；日志来自真实Vivado，遇到error、critical warning、Fatal、缺少结束标记或结果不符即失败。

| 程序 | C | N | S | R | stores |
|---|---:|---:|---:|---:|---:|
| all_ops | 25 | 16 | 1 | 2 | 1 |
| baseline | 17 | 10 | 1 | 1 | 1 |
| loop | 30 | 18 | 0 | 4 | 0 |
| memory_copy | 15 | 7 | 2 | 1 | 1 |
| copy_checksum | 55 | 35 | 16 | 0 | 8 |

`rtl/`保留15份原版RTL，以及固定镜像配置的两层薄封装；CPU逻辑和流水时序不变。`pre6_cpu_top.port-map.json`记录34个端口的直通映射。数据文件以basename登记，综合与仿真使用同一组`dut_im.mem/dut_dm.mem`，可随运行目录重建。工作工程由源码创建，可写缓存由Vivado自行生成。

更完整的九套回归、48个独立用例、错误注入及X/Z检查，入口见相邻[CPU核心设计](../../CPU核心设计/README.md)。OOC设置参照[AMD AR59168](https://adaptivesupport.amd.com/s/article/59168?language=en_US)，仿真模式参照[UG835 launch_simulation](https://docs.amd.com/r/2023.2-English/ug835-vivado-tcl-commands/launch_simulation)。
