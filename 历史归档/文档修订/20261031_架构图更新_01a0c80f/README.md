# CPU核心设计 当前使用入口

当前源码为v1.6-timing-AC1独立候选，ISA v1.5、验证协议1.6-vtools-r1，运行包装增加job1生命周期补丁。打开根目录AC1核心Word和五页Buffer/Interlock说明即可；原冻结v1.6规范及旧工程已移入外部可恢复归档。

## 2026-10-29 文档修订

核心Word已合入Pre5确认后的CU设计说明，现为44页，保留四章结构和Word内54项可点击分级目录。重点查阅2.6节（第16–17页）的F/Q/G、内部功能与信号归属，以及3.7节（第27–29页）的五状态FSM、输入条件、当前输出与WB排空完成。4.4.2节（第34页）保留Pre5实际执行记录的日期、路径和覆盖口径。

本次为文档修订，CPU实现版本、ISA、13份生产RTL、全部TB与XDC不变。停止图只展开mode，HALT/故障标记在WB消费且valid_next全空后才停止；Reset直接清在途状态，不等待排空。加减仍采用原生17位`+`表达式，没有接入Hybrid。Pre5的结构图职责不表示新增cu.v、FIFO/cache或resume端口。

Pre5同源验证位于相邻目录`../Pre5_控制单元设计/Vivado`：九套回归attempt为`440e0d7a-1244-4333-a4f8-5adf612f9833`，独立48例记录为`cpu_ac1_independent_glok75my`。合入前已复核其原始证据与11份逐拍记录；这是历史复核，不是2026-10-29新运行XSim。英文排练版和后续中文教师查阅版各保留原用途，不按旧演讲页码定位核心规范。

修改前Word、README、索引与指纹保存在`C:/Users/Donson/Documents/ChatGPT_CPU_归档/20261029_Pre5文档合入_01a0c80f`。当前文档摘要与证据位置见`证据索引.json`；`文件SHA256.json`同步文档指纹，历史执行receipt不改写。

## 创建及打开 Vivado

已创建项目：Vivado/project/cpu_v16.xpr。器件xc7z020clg484-1，设计top=datapath_core，默认仿真top=tb_datapath。源码和约束全部从本目录登记。双击Vivado/run_project.cmd或运行下面命令会创建项目；已有project时请用另一个目录名，不会删除现有工程。

```powershell
.\Vivado\create_project.ps1 -ProjectDirectoryName project_new
```

## 验证与综合

从本目录运行：
```powershell
.\Vivado\run_verify.ps1
.\Vivado\run_synthesis.ps1
```
完整功能入口真实调用九套XSim并创建新attempt及19步记录；失败不会冒充旧成功。OOC综合只分析核心，仍不代表板级。GUI的单独Run All只运行所选TB，不自动得到九套绑定PASS。

独立48例或已有负向检查：
```powershell
$cpuPy='C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $cpuPy -X utf8 .\Vivado\run_independent.py
& $cpuPy -X utf8 .\Vivado\run_mutations.py
& $cpuPy -X utf8 .\Vivado\run_unknown_controls.py
& $cpuPy -X utf8 .\Vivado\run_evidence_tests.py
```
evidence测试放在完整run_verify之后执行；正常runner更新最近运行。2026-10-14落实job1后已重新实际执行九套，当前attempt为eae32d52-1b00-4d6d-a524-cd3902d502d0，19步均通过。原始九套attempt 72d99981-0aef-4b1d-8c13-e8d7bc624cf9及其118文件保留原身份；复制不生成新运行。最近运行以其JSON中的状态、attempt和路径为准。

仅读取复核历史原始证据：
```powershell
& $cpuPy -B -X utf8 .\Vivado\verify_results.py --run .\验证记录\cpu_v16_72d999810aef4b1d8c13e8d7bc624cf9 --output .\historical_recheck_new.json
```
预期HISTORICAL_REVALIDATION_PASS/new_xsim_execution=false，不能当作新XSim执行。上面的旧记录按其原始输入快照核验，不加--package；否则job1包装脚本的预期差异会被判为当前驱动不兼容。当前完整九套记录可另加--package .核对当前输入。每次指定尚不存在的--output文件名，避免覆盖历史复核结果。

原迁移操作只适配创建包装入口和文档路径，并验证创建入口及独立48例。后续job1仅修补执行包装、独立入口及负向测试辅助工具；13份生产RTL、全部TB、ISA和XDC均不变。旧执行快照不会被新脚本覆盖。

## 进程生命周期自测（job1）

```powershell
& $cpuPy -B -X utf8 .\Vivado\test_process_lifecycle.py
```
检查正常/失败退出、启动失败、强制结束后的两级子进程清理、主进程正常退出后的遗留子进程清理，以及负向入口超时记录；无关哨兵进程须保持存活。包装器使用本次调用专属、句柄不继承的Windows Job，并在CreateProcess时绑定，未对现有Vivado或系统Job修改策略。独立48例默认超时600秒，可用--timeout指定正的有限秒数；超时/中断返回失败并保存部分日志，不发布PASS。

修改前脚本和根目录记录保存在C:/Users/Donson/Documents/ChatGPT_CPU_归档/20261014_进程清理补丁_job1/修改前。自测与补丁证据位于验证记录/工具生命周期_job1_20261014；这不是新的CPU版本、架构变更或板级验收。

AC1已存OOC为287 LUT/260 FF、WNS+2.620ns、TNS0、0失败端点。缺真实板级顶层、时钟/复位/RAM集成和完整I/O约束，尚未布局布线/实际setup-hold/比特流/下板。未完成完整算术穷举和全状态形式证明。禁止把OOC或功能PASS写成已实现板级100MHz。

证据位置见证据索引.json；旧绝对执行路径仅属原上下文，不是当前源码入口。说明/内历史原件保留身份；新整理Review说明当前目录。所有移除材料及原冻结文档的恢复位置见说明/归档位置.md。
