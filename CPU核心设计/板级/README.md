# EES331板级工程

本目录在阶段2的AC1系统之外增加板级时钟、复位、VIO和性能观察。13份核心RTL及系统cpu_system保持原字节，ISA v1.5和现有CPU周期规则不变。目标EES-331、xc7z020clg484-1，Vivado2025.2。

从CPU核心设计目录运行：

```powershell
python -B -X utf8 .\板级\run_board.py --mode all --program all_ops
```

simulate只运行应用和选定镜像的仿真；implement运行完整综合、布局布线和bitstream生成；all依次执行两者。入口读取共用tools.local.json/环境变量/CLI配置，每次新建cpu345_board_* attempt；失败保留原始日志，不覆盖既有成功。默认程序用同一dut_im.mem/dut_dm.mem路径启动仿真与综合。独立ISA模型提供预期架构事件，周期数另用已审查的静态契约检查。

板级仅有10个逻辑IO：M19的100MHz晶振、L18的S1按键和8个LED，均为LVCMOS33。S1低有效，LED高有效，依据EES-331手册PDF第5、7、29至30页。按键或VIO复位请求先经过3级同步，再寄存为有效core_reset；有效复位同步禁止RF/DM写入并清CPU/观察状态，已提交DM不回滚。请求传递之前的合法写入可以完成。请求撤销后继续保持2^21周期（约20.97ms），过滤释放抖动。仿真将该宽度缩为3以检查相同逻辑。

禁止将异步复位寄存器直接用于RAM使能。human_io.xdc只豁免按钮到第一级同步器D，以及没有同步外部接收器的LED输出；所有CPU数据、控制和有效复位路径均接受时序检查。报告必须满足setup、hold、pulse、内部约束覆盖和实际IO绑定，不能只看WNS。

结果通过100MHz时钟域的VIO读取。probe_in0为256位状态，probe_in1为160位计数，probe_out0为复位请求且初值1：配置后先保持CPU复位，准备观测后再由JTAG释放。VIO没有被CPU复位，停止后仍能读取完整现场。LED仅作辅助。

| 状态位 | 含义 |
|---|---|
| 63:0 | RF影子，R3/R2/R1/R0各16位 |
| 66:64 | Z/C/V |
| 82:67 | stop_pc |
| 85:83 | stop_reason，沿用核心编码 |
| 86、87、88、89 | stop_valid、stop_pc_valid、halted、fault |
| 90、106:91 | last_completed_valid、last_completed_pc |
| 107、123:108、139:124 | last_store_valid、地址、数据 |
| 140、141 | 有效复位、自由运行心跳 |
| 191:142、255:192 | 保留0、64位构建身份 |

计数位从低到高为cycles、completed、stalls、redirects、stores，每项32位。cycles从首次有效IF采样边沿计至WB停止消费边沿，排除按键去抖、复位和JTAG交互。completed计无故障WB标签，包含STR、分支与HALT。停止后计数保持，复位清零。构建身份只依赖硬件源码、选定镜像、约束、实现脚本和工具配方，测试/报告脚本变化不改变硬件身份。

产物位于新attempt的output/ees331.bit、debug.ltx、routed.dcp；reports/有原始时序、引脚、DRC和资源报告。资源采用report_utilization的物理Total LUTs，不能将LUT原语个数当作器件LUT占用。独立复核入口：

```powershell
python -B -X utf8 .\板级\verify_board_results.py --run .\验证\某个已完成attempt --output C:\Temp\新复核文件.json
```

当前DRC允许的已审查Warning限于debug hub的PDCN-1569、无负载RTSTAT-10以及仅PL/JTAG设计的ZPS7-1；没有降级任何DRC。CPU RAM异步控制REQP-1840、错误引脚、未加载镜像和任何新Warning均不能自动接受。PS时钟、DDR和MIO未使用，ZPS7-1对应的实际板卡启动/配置仍需接板验证。

方法学提示也单独核查：LUTAR-1仅允许厂商debug hub内部复位同步；SYNTH-6仅允许当前IM/DM保留一拍读、未另加输出流水寄存器。生成的4项bus-skew约束逐项检查并保存报告指纹。普通警告按代码和作用范围审查，完整处置在验证JSON中；向量无活动输入的功耗估算不作为测量结论。执行工具必须确为2025.2，其他安装即使可调用也不能冒充本基线配方。

2026年11月2日，用户恢复任务并确认仅EES-331连接USB/JTAG、PYNQ数据线已拔下；八灯现象确认后，默认AC1五个既有镜像实际下载并通过VIO核对。每程序两份停止快照均核对RF、标志、停止PC、最后store和计数。真实S1按住清零、松开后checksum重新完成55周期。[原始记录](../验证/hardware_ac1_20261102_3dw9zgb5/result.json)保留实际日志及失败尝试。

本次发现并修复两处主机验收问题：Windows Tcl的%x截断64位构建身份；Python缩进使部分结果仅检查第二份快照。修复后的14项工具检查及五程序全部10份实际快照重放记录保留原执行身份。CPU RTL和bitstream未改。实板RF读数来自写回影子，S1测试在CPU停止后进行；早期目标未确认的尝试不计通过。实验候选、独立频率和直接运行时间仍未验证。

重新接板或更换USB/JTAG连接后，仍须核对目标与实物。电脑可能同时连接EES-331与PYNQ，不能仅凭xc7z020、FTDI序号或Programmed状态选择设备；应结合实际拔插或已确认的单板连接，再读取构建身份、RF/flags、停止PC/原因及计数。

接板入口为run_hardware.py：必须显式指定已确认的EES-331目标和经过校验的实现attempt；默认只采集，program-device和run-program分别控制配置与CPU重启。软件前置测试使用替身，不访问设备；上述五程序和S1结果则来自本次真实设备，分别保留证据。

```powershell
python -B -X utf8 .\板级\run_hardware.py --implementation .\验证\某个有效实现 --target "确认后的完整JTAG目标名" --confirmed-board EES-331 --program-device --run-program
```

脚本检查实际构建身份后才操作CPU复位，读取两份停止快照并比较RF、标志、PC、计数及最后store；失败不发布硬件PASS。不要把当前其他设备的目标名代入此命令。

## 新采集记录的主机上下文

今后通过`run_hardware.py`新建的采集会在设备访问前写入`host_context.json`和`host_sources/`，保存主机入口、探针解码器、实现校验器、工具配置读取器及ISA参考模型的源码和指纹，同时记录Python版本、Git提交及相关源码是否有未提交修改。Git不可用时明确记录未知，文件快照仍保留。

Vivado与Tcl版本由实际原生日志中的运行时标记记录。所有嵌套源码快照也计入输入指纹；缺失或重复的版本标记不能发布新的采集通过结论。此增强仅用于以后新建的采集，既有五程序与S1记录保持原字节，本轮收尾没有重新上板。

## 固定基线与候选

run_matrix.py每次运行五个固定工作负载，原始结果分别位于显式的新attempt。基线见../实验/性能基线.json，两个候选比较见../实验/前递候选比较.json和../实验/WB_MEM候选比较.json。候选通过registry覆盖私有执行目录，生产RTL不改；forward_onehot只改operand_forward.v，wb_mem只改datapath_core.sv，两者不组合。

三组五程序均完成实际布局布线和独立报告复核；共同板级/RAM/VIO/约束/工具配方不变，每个程序成对比较。WB候选仅改变特定STR数据停顿规则，独立检查ISA事件和新周期；不要求旧轨迹逐字节一致。最新保护验证为12项正向、6类被捕获错误变体，额外拒绝超时、被中断或来源不匹配的负向“通过”。
