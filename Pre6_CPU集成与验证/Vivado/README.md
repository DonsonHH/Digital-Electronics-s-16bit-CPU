# Pre6 Vivado验证包

本包提供可直接查看和复跑的默认AC1系统：13份核心RTL、1份`cpu_system`、1份`ees331_application`，以及原版TB、五程序镜像、独立ISA期望事件和约束。源码复制关系及输入指纹见`source_manifest.json`。

## GUI入口

打开 [工程/project/pre6_cpu.xpr](工程/project/pre6_cpu.xpr)，器件为`xc7z020clg484-1`，Vivado 2025.2。

默认 **simulation top = tb_selected_program**，程序为`copy_checksum`。运行 **Run Behavioral Simulation**，再 **Run All**。正常日志为：

```text
BOARD_SELECTED_PASS program=copy_checksum cycles=55 completed=35 stalls=16 redirects=0 stores=8
```

在波形Scope展开`tb_selected_program/dut/system_i/core`，添加`x_valid/m_valid/w_valid`、`load_use`、`x_alu_a_sel/x_alu_b_sel`、`x_reg_write`、`rd_fwd/rs_fwd`、`dm_we`与`rf_we/z_we/cv_we`。CW_X/M/W是字段组名称，对应这些已有字段。顶层`ev`和`perf`提供稳定打包事件与计数。波形记录随工程提供；也可重新仿真，`log_wave -r /*`记录层次对象。

选择`tb_cpu_system`作为simulation top可运行完整系统套件。它包含11个程序、12条epoch结果、复位场景、故障场景和两项受控诊断检查；终止标记是`SYSTEM_PASS`。仿真的reset释放计数采用TB参数缩短，板级实际释放计数保持原版21位。

## 一键或命令行

双击 [Run_Pre6_Verification.cmd](Run_Pre6_Verification.cmd)，或在本目录执行：

```powershell
.\run_tests.ps1 -Program all
.\run_tests.ps1 -Program memory_copy
.\run_tests.ps1 -Program system
```

| 程序 | C | N | S | R | stores |
|---|---:|---:|---:|---:|---:|
| all_ops | 25 | 16 | 1 | 2 | 1 |
| baseline | 17 | 10 | 1 | 1 | 1 |
| loop | 30 | 18 | 0 | 4 | 0 |
| memory_copy | 15 | 7 | 2 | 1 | 1 |
| copy_checksum | 55 | 35 | 16 | 0 | 8 |

脚本先核对输入指纹，再建立独立工程，真实调用Vivado/XSim。判定同时检查日志、正常`$finish`、终止标记与精确结果，不能只看进程退出码。失败保留记录并返回失败，不读取旧PASS替代本次运行。

每次输出到`运行记录/pre6_xsim_*`，内容包括：

- `result.json`、`console.log`及真实输入/输出指纹。
- `project/pre6_cpu.xpr`和相对位置的`rtl`、`tb`、`programs`、`constraints`。
- `project/pre6_cpu.sim/sim_1/behav/xsim/`下的CSV、WDB、VCD和仿真日志。

`工程`是课堂GUI工作副本，可重新打开运行；`工程来源.json`说明其初始来源。已有运行记录保留各自的PASS/FAIL和执行时间。更换程序应通过入口创建新工程，使MEM和期望事件同步更新。

## 工具路径与进一步验证

默认Vivado路径为本机`C:/AMDDesignTools/2025.2/Vivado/bin`。其他路径可传给`run_tests.ps1 -VivadoBin ...`或`run_project.py --vivado-bin ...`。Python入口优先使用本机已配置运行时，否则使用PATH中的Python。

本工程的design top为`cpu_system`，用于功能仿真与系统OOC；所示完整板级PPA属于`ees331_top`。板级RTL、XDC、VIO生成和实现入口已同步在 [CPU核心设计/板级](../../CPU核心设计/板级)，例如：

```powershell
python -B -X utf8 ..\..\CPU核心设计\板级\run_board.py --mode simulate --program copy_checksum --candidate ac1
```

默认AC1、前递MUX候选和WB→MEM候选各自独立；需比较时按核心README的入口建立新attempt。完整九套回归与48例独立测试见相邻 [CPU核心设计/README.md](../../CPU核心设计/README.md)。本Pre6入口不连接Hardware Manager、不下载bitstream。
