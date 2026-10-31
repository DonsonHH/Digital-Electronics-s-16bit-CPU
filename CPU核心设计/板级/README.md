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

用户已确认课程板尚未连接。曾只读扫描到另一条xc7z020 JTAG链，未配置设备；不能将其视为EES-331验收。当前结果只证明仿真与已布线设计，不证明真实板上100MHz运行、物理按键行为或实际程序运行时间。后续接板必须读取构建身份、寄存器、标志、停止PC/原因和计数，不能仅观察LED。

接板后的入口为run_hardware.py：必须显式指定已确认的EES-331目标和经过校验的实现attempt；默认只采集，program-device和run-program分别控制配置与CPU重启。Python前置、拒绝未知板型的Tcl检查及真实仿真样本解码通过；测试使用替身，不访问真实设备。硬件流程尚未执行，不能据此标为下板通过。

```powershell
python -B -X utf8 .\板级\run_hardware.py --implementation .\验证\某个有效实现 --target "确认后的完整JTAG目标名" --confirmed-board EES-331 --program-device --run-program
```

脚本检查实际构建身份后才操作CPU复位，读取两份停止快照并比较RF、标志、PC、计数及最后store；失败不发布硬件PASS。不要把当前其他设备的目标名代入此命令。

## 固定基线与候选

run_matrix.py每次运行五个固定工作负载，原始结果分别位于显式的新attempt。基线见../实验/性能基线.json，两个候选比较见../实验/前递候选比较.json和../实验/WB_MEM候选比较.json。候选通过registry覆盖私有执行目录，生产RTL不改；forward_onehot只改operand_forward.v，wb_mem只改datapath_core.sv，两者不组合。

三组五程序均完成实际布局布线和独立报告复核；共同板级/RAM/VIO/约束/工具配方不变，每个程序成对比较。WB候选仅改变特定STR数据停顿规则，独立检查ISA事件和新周期；不要求旧轨迹逐字节一致。最新保护验证为12项正向、6类被捕获错误变体，额外拒绝超时、被中断或来源不匹配的负向“通过”。
