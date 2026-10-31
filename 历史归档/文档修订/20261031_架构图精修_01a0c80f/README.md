# CPU核心设计 当前使用入口

当前源码为v1.6-timing-AC1独立候选，ISA v1.5、验证协议1.6-vtools-r1，运行包装增加job1生命周期补丁。打开根目录AC1核心Word和五页Buffer/Interlock说明即可；原冻结v1.6规范及旧工程已移入外部可恢复归档。

## 2026-10-31 架构图修订

核心Word现为46页，保留四章结构和Word内56项可点击分级目录。第2.1.1、2.1.2节分别为整体控制与数据通路架构图、五级Datapath详细图，独占第9、10页横向图页；其余正文为纵向。两张主图与现有F/Q/G、冒险网络及五状态FSM相互对应。

可编辑源图和3600×2250 PNG位于`架构图/`：`01_CPU整体架构.svg/.png`、`02_五级Datapath.svg/.png`。第2.6节（第17–19页）的表14给出方框、实际RTL及输入输出对应；IFCU至WBCU是core内部职责分区，CTRL_X/M/W是既有随行控制字段集合。第3.7节（第29–31页）继续解释运行模式与WB排空边界；第4.4.2节（第36页）保留Pre5执行记录的原日期及覆盖口径。

本轮只修订图文，CPU实现版本、ISA、13份生产RTL、全部TB与XDC不变。加减仍采用原生17位`+`表达式，没有接入Hybrid。图中同步IM输出承担D级指令数据边界，DM输出承担W级load数据边界；没有新增IR/MDR、独立五级控制器、FIFO/cache或resume端口。

本轮按当前源码重新核对ADD相关、LDR到STR、CMP/JZ、HALT排空、MEM故障与Reset；只读重解析Pre5原始VCD的4,824个上升沿，逐项核对11份CSV/JSON。所用九套回归attempt仍为`440e0d7a-1244-4333-a4f8-5adf612f9833`，独立48例仍为`cpu_ac1_independent_glok75my`，均位于相邻`../Pre5_控制单元设计/Vivado`。这是历史证据复核，不是2026-10-31新运行XSim、综合或下板。

修改前Word、README、索引与指纹保存在`C:/Users/Donson/Documents/ChatGPT_CPU_归档/20261031_架构图更新_01a0c80f`，此前10月29日文档修订的归档继续保留。当前文档与图形摘要见`证据索引.json`，`文件SHA256.json`同步当前指纹；原有执行receipt不改写。清单中原有缺失的`验证记录/AC1已验收负向原始证据.zip`仍保留原记录，本轮未恢复该历史文件。

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
