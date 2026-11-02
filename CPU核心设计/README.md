# CPU核心设计当前入口

当前正式文档为 **AC1架构版r4**，CPU v1.6、ISA v1.5，课程目标EES-331（xc7z020clg484-1）。默认生产核心和两个隔离候选保持0d888cc原字节；本轮在用户确认仅连接EES-331并恢复任务后，复用既有bitstream完成默认AC1五程序和真实S1复位验证。Pre4、Pre5及旧快照保留原版本语义。

## 阅读与源码

- [核心Word](16位流水线CPU核心设计文档_AC1候选版.docx)：Word内分级目录，包含两张主图、文件启动图及板级时钟复位与观测图。
- [核心RTL](Vivado/rtl)：13份；阶段2扩展了datapath_core的被动观测及sync_memories的文件初始化。架构版r3保持这些源码原字节，未改变执行仲裁与写入边沿。
- [最小系统顶层](系统/rtl/cpu_system.sv)：第14份系统源码，连接一拍同步IM/DM，提供RF写回影子与最后store观测。
- [系统契约](系统/接口与停止现场契约.md) · [文件启动镜像与manifest](系统/programs) · [既有Buffer说明](CPU流水线冒险与Buffer_Interlock完整设计方案.docx) · [证据索引](证据索引.json)。
- [系统图SVG](架构图/03_文件启动系统与停止观测.svg) · [PNG](架构图/03_文件启动系统与停止观测.png)。原整体图、五级datapath、F/Q/G和模式FSM仍适用原执行路径。
- [板级工程与接板入口](板级/README.md) · [板级SVG](架构图/04_EES331板级系统.svg) · [PNG](架构图/04_EES331板级系统.png) · [性能基线](实验/性能基线.json) · [前递比较](实验/前递候选比较.json) · [WB到MEM比较](实验/WB_MEM候选比较.json)。
- [文档维护源](文档源/README.md)：`architecture.json`组织章节和契约，`sections.json`保存成熟正文，`content.json`补充总体说明；统一由新生成入口维护单一核心Word。

| 章节 | 阅读目的 |
|---|---|
| 第一章 设计目标与指令契约 | 默认实现、ISA、接口、同步存储边沿、设计依赖和课程流程 |
| 第二章 数据通路与状态边界 | 总体架构、部件、唯一RF/flags、数据/CW/元数据载荷和指令数据流 |
| 第三章 流水控制与跨级协调 | 控制所有权、ID意图、局部动作、冒险、仲裁、全局FSM及五个实际逐拍例 |
| 第四章 系统集成与验证结果 | core/system/board层次、文件启动、观察与复位、功能证据、性能和隔离实验 |

## 工具配置与复跑

需要Windows、Python 3.11或更新版本、Vivado 2025.2。复制tools.example.json为不提交的tools.local.json并填写本机路径，或使用CPU_VIVADO_BIN/CPU_PYTHON及PATH。优先级：显式CLI > 项目配置 > 环境变量 > PATH。直接用某个Python启动时，回执记录该实际解释器。

从本目录执行；在其他目录可使用脚本绝对路径：

```powershell
# 九套回归、独立48例、五类错误注入、X/Z、证据校验、生命周期
python -B -X utf8 .\Vivado\verify.py --suite all
# 7项存储检查、11程序、系统OOC、同镜像网表回放、真实工程仿真
python -B -X utf8 .\系统\run_system.py --test all
```

两个入口都新建attempt并保存失败，不以旧成功替代本次结果。系统检查可单独选择memory、system、synthesis或project。synthesis同时回放all_ops网表；project实际创建工程并launch_simulation，不只是注册文件。原core-only入口Vivado/run_synthesis.ps1仍可用，但资源和顶层与系统OOC不同。

独立48例的维护生成入口不再依赖归档脚本：

```powershell
python -B -X utf8 .\Vivado\generate_independent.py --output C:\Temp\cpu_cases_new
python -B -X utf8 .\Vivado\run_independent.py --cases C:\Temp\cpu_cases_new
```

输出目录必须尚不存在。冻结373份消费输入（含369份MEM）保持内容契约；私有执行TB仅把原12端口的.*替换为显式连接，以兼容新增观测输出，所有断言不变，原包及执行后指纹分别保存。

## Vivado工程

原Vivado/create_project.ps1生成core-only项目。新系统入口为系统/create_project.tcl，top=cpu_system、sim top=tb_cpu_system，登记13份核心RTL加1份系统RTL；已有输出目录拒绝覆盖。

`run_system.py --test project`已验证该Tcl的创建和实际仿真路径。新attempt保留XPR、源码及相对programs镜像；打开输出记录中的project/cpu_system.xpr可以查看。本机原执行临时目录中的工程也保留。完整快照移动时须一起移动rtl、tb、programs、constraints和project，不能只复制XPR。更换程序后新建工程，避免用旧镜像副本。

## 当前验收范围

阶段0固定7753502与2947份历史文件；阶段1固定独立生成及统一工具，提交76950d1；阶段2添加最小系统与被动观测。原五级组织和ISA保持：STR只在MEM写一次、WB保留标签；JUMP/JZ在EX重定向后继续推进；HALT/故障标记在原WB排空边沿停止。reset禁止写入并清观测状态，保留DM。

接受证据分别为验证/tools_50040838e0ec474680085bb91e8fb001和验证/cpu_system_n0r4buws。后者含12行系统epoch结果、2次受控诊断注入、all_ops同拍网表回放和真实工程启动；baseline为17拍，all_ops为25拍。前者包括九套19步、独立48例/10 reset见证/58行、五类mutant、X/Z、证据和生命周期检查。

阶段2系统OOC：376 LUT、431 FF、2 RAMB18、15 CARRY4；10 ns下WNS +1.363 ns。阶段3至5含VIO的ees331_top已完成布局布线及setup/hold/脉宽检查，五程序setup裕量1.434至2.101 ns、hold为正、均用2个BRAM18。当前五程序及S1已真实上板；未确认目标的旧尝试仍不计通过。各顶层资源边界不变。

[实板验收记录](验证/hardware_ac1_20261102_3dw9zgb5/result.json)保存每程序两份VIO停止快照及S1按住、松开后的实际样本。all_ops、baseline、loop、memory_copy、copy_checksum分别为25、17、30、15、55周期；RF、Z/C/V、停止PC、最后store及全部计数吻合预期。S1按住时清零，松开后checksum在55周期重新HALT。本次只接受有限默认AC1程序，未独立测量频率或直接运行时间。

两个候选均隔离于实验/候选，不改变生产13份RTL及cpu_system：前递one-hot改写周期不变、四个负载的setup余量下降，未采用；WB到MEM只免除STR数据相关停顿，基址相关仍停一拍，内存复制15→14拍、复制校验和55→47拍。后者在校验和负载增加86 LUT、2 FF。所有时间差均按已布线100MHz计算，不是板上实测。

候选验证与性能复跑：

```powershell
python -B -X utf8 .\板级\run_matrix.py --candidate ac1
python -B -X utf8 .\板级\run_matrix.py --candidate forward_onehot
python -B -X utf8 .\板级\run_matrix.py --candidate wb_mem
python -B -X utf8 .\实验\run_wb_validation.py
python -B -X utf8 .\实验\run_wb_guards.py
```

WB到MEM验证包含48例/10复位见证、2005个候选用例（2002个正常程序查精确周期、3个故障查逐拍行为）、12项保护及6个被捕获错误变体。XSim的Fatal可能返回退出码0；入口同时检查日志标记、正常生命周期、输入和输出指纹，不能仅看进程退出码。独立48例原包不改，只有私有候选TB排除两个旧总周期期待，并增加候选逐拍检查。

本版Word维护入口为文档源/build_core_document.py，要求指定新48例记录，核对当前14份生产/系统RTL及冻结输入，并把实际CSV绑定到0d888cc同源记录的固化输出。第一章设计流程、第二章状态/载荷、第三章控制和逐拍例、第四章集成/验证不再靠旧Word段落下标追加。

板级/update_core_document.py与系统/build_core_document.py作为历史复现入口保留；它们会拒绝覆盖架构版Word，可用其他`--output`路径复现旧稿。生成后仍须用Word刷新目录、导出并逐页检查。文件SHA256.json反映其生成时刻的受跟踪交付；历史导入清单保持7753502原快照身份。两份用户已确认删除的旧ZIP不会被误记为已恢复。
