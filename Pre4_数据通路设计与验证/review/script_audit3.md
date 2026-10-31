# 第三轮交付脚本与工程安全审查

日期：2026-10-09。审查对象：`Pre4_数据通路设计与验证/Vivado` 的运行脚本、工程创建/EDA Tcl、桌面启动包装器、波形查看 Tcl 和已交付 XPR。生产文件只读。本报告所列故障桩与真正 XSim 微型试验都在 `script_probe` 下；未启动完整 EDA、未休眠电脑。

## 结论

存在一个需要修正的实测问题：三个独立仿真 CMD 把“工具退出 0”直接视为成功，会接受真正 XSim `$fatal` 失败，也会接受没有新输出的空跑。外层 `run_verify.ps1` 已拒绝 Fatal 和旧 PASS，因此此问题主要影响文档明确支持的独立 CMD 入口。

另有两个已复现的验收收紧点：PowerShell PASS 正则没有行首/行尾约束；EDA 只检查当前日志 PASS 子串和产物存在，没有要求所有产物由本轮新生成。负退出码、Windows PowerShell 5.1、既有 XPR 保护与包内源引用检查通过。

## 实测问题与建议

### P1：三个独立 CMD 对 Fatal+退出 0、空跑、无 PASS 均返回成功

位置：原 `run_datapath.cmd:9-12`、`run_units.cmd:9-12`、`run_stress.cmd:9-12`。

真正 XSim 微型试验使用 Vivado/XSim 2025.2，测试模块在 1 ns 调用 `$fatal(1,"native_fatal_probe")`，脚本与交付一致采用 `run all` 后 `quit`。实际日志包含：

```text
Fatal: native_fatal_probe
Time: 1 ns ...
$finish called at time : 1 ns
## quit
NATIVE_XSIM_EXIT=0
DESKTOP_EXIT 0
```

因此不是仅靠故障桩推断“XSim 可能退出 0”：本机原生执行已确认。原生证据文件为 `script_probe/native/native_fatal.log`，测试源为 `fatal_probe.sv`，执行脚本为 `run_fatal.cmd`。

隔离副本对以下三类故障的结果完全一致：

| 桩行为 | run_datapath.cmd | run_units.cmd | run_stress.cmd |
|---|---:|---:|---:|
| 新日志包含 Fatal；退出 0 | 0，误接受 | 0，误接受 | 0，误接受 |
| 不写任何新日志；保留旧 PASS；退出 0 | 0，误接受 | 0，误接受 | 0，误接受 |
| 新日志仅“Simulation ended with no receipt”；退出 0 | 0，误接受 | 0，误接受 | 0，误接受 |

建议三个入口都在编译/仿真前保留各自旧日志和结果，执行后要求新日志、准确且独立成行的 PASS、无 Fatal/FATAL_ERROR/ERROR，并检查对应新结果非空；非零状态仍需先拒绝。仅加 PASS 搜索而不移走旧文件，会继续接受空跑后留下的旧 PASS。

### P2：run_verify.ps1 接受嵌在任意前后文中的 PASS 子串

位置：原 `run_verify.ps1:31,36,58`。

故障桩生成新日志，完整 PASS 被包装为 `PREFIX <PASS> SUFFIX`，其余新结果复制有效交付 fixture。Windows PowerShell 5.1 实际输出 `PRE4_VERIFIED datapath=128 reset=16 legal_opcodes=14 unit_receipts=PASS`，退出 0。

这说明 PASS 正则允许前后无关内容，而不是接受一条真正完成回执。对于 stress，`.*` 又放宽了中间字段。建议对三条 PASS 使用 `(?m)^...\r?$` 等明确完整行边界；固定计数最好明确写出或从 JSON 核对。若独立 CMD 先完成严格校验，外层当前调用路径会受其保护，但仍应让 PowerShell 自身的判据准确。

### P2：run_eda.cmd 不要求所有 EDA 产物为本轮新生成且非空

位置：原 `run_eda.cmd:5-10,14-18`。

脚本只保存旧 `eda.log`，而保留 `eda/` 中全部旧 PDF/DCP/网表/报告；PASS 搜索也仅是子串。隔离桩本轮只写一条新的标准 `PRE4_EDA_PASS`，没有生成任何 EDA 产物，之前放置的 11 个旧文件全部故意使用同一份 JSON 内容（包括 `.pdf`/`.dcp`），仍退出 0。

这是验收器实测允许陈旧/错误类型产物的证据，不能据此声称真实 `eda.tcl` 已产生错误文件。真实 Tcl 在所有写操作后才输出 PASS，且 ERROR/CRITICAL WARNING 另被拒绝，正常成功运行仍有较强证据。建议将旧 11 项产物一起移到归档（或每轮使用新 EDA 输出目录），要求新产物存在且非空，并锚定完整 PASS 行。可在最终交付复核单独检查 PDF/DCP/网表有效性，不必在 CMD 内实现全面文件格式解析。

### 小范围稳健性补充：继承的 ERRORLEVEL 环境变量能遮蔽动态退出码

所有 CMD 使用 `%errorlevel%`。隔离进程继承 `ERRORLEVEL=0` 后，`xvlog` 桩实际退出 -1，原 `run_datapath.cmd` 仍返回 0；清除该环境变量后返回 1。这是明确但非常规的环境前置条件，当前环境未发现这一变量，不把它当作本次正常复跑已失败。

建议在 `setlocal` 后 `set "ERRORLEVEL="`，防止继承环境名遮蔽 CMD 动态状态；不要把判据退回 `if errorlevel 1`，那会重新漏掉负 NTSTATUS。新验证/归档 CMD 若继续依赖 `%errorlevel%`，同样应清除该名字。

## 通过的检查与边界

- `xvlog`、`xelab`、`xsim` 分别注入 -1，原 `run_datapath.cmd` 都返回 1。正常环境下非零/负退出码处理已修正。
- Windows PowerShell `5.1.26100.9549` 实际执行 `run_verify.ps1`；无解析失败；Fatal 桩退出 1；有效 fixture 与前后文 PASS 桩能走完原 suite 的 CSV/JSON/波形检查。这验证了脚本语法/语义兼容性，但本子任务没有另跑完整真实数据通路/单元/stress 套件。
- PowerShell 在运行前保存旧结果；Fatal 桩后旧结果仍在 `previous_runs`，未用旧日志补新结果；`finally` 恢复 `PRE4_VIVADO_BIN` 和原工作目录。
- `desktop_launch.py` 成功创建本轮多个桌面子进程，原生 XSim 输出可见，普通 CMD 的退出状态被传回。其 DWORD 退出码 >=128 归一化为 1，可保留成功/失败区别；此审查不要求保留每种 NTSTATUS 的原始数值。
- `create_project.tcl` 不含 `-force` 或删除/重置命令；既有工程保护明显优于覆盖重建。可选输出目录由调用者给出，不用于隐式覆盖当前 XPR。此结论是当前源码审查，不重复父任务已经安排的实际工程打开检查。
- `eda.tcl` 只创建内存工程，没有 `open_project`、删除源工程或重置源工程动作；写入范围为 `eda/` 的分析产物。`write_* -force` 只用于这些明确产物，与源 XPR 的保护无冲突。
- XPR 16 个源/TB引用均为 `$PPRDIR/../rtl` 或 `$PPRDIR/../tb`；解析后缺失 0、包外 0。XML 顶层 `Project Path` 保留原保存位置，但源文件引用本身可搬移；没有据此误判成源路径不便携。
- `view_wave.tcl` 从自身路径定位 `datapath.wdb`；本轮没有打开波形 GUI，不能把静态路径检查写成已验证波形渲染。
- `-Python`、`-VivadoBin` 允许覆盖本机默认安装路径；文档说明完整目录拷贝至英文短路径后复跑，未要求修改用户其他目录。

## 复现资料

故障桩矩阵入口：`script_probe/run_matrix.ps1`；原脚本快照：`script_probe/sut`；工具桩：`script_probe/vendor_stub`；有效结果 fixture：`script_probe/fixtures`。桩行为与源 HDL 无关，仅用于验收器拒绝条件测试。

本轮审查时生产脚本（修正前）SHA-256：

```text
run_verify.ps1    FCDDDB51547937F07FC44E2223D99D328B35F5FC05E1764E1ACA61A4687A858E
run_datapath.cmd  2FD7E79C43C1E87313B3874D2E3FCEC55F0A8FD7BB65D1CFB695228DD48B5C83
run_units.cmd     4E0449083D3190114D97417C817F464C4A476B4A4134AF9098894D04B8B3F5DE
run_stress.cmd    27EBB63EF5E693E60A39641EC451D31059C9E8984DE3C1D94253FF3EFF57AAAB
run_eda.cmd       687170804691BF53819F105C044263255F68D3D58B26EE77E7198EADE933DED3
compile_sources.cmd 63279D790390BAB4E8759B19E8A95A7257B99904CB18077D8A0BCA6DF7B0BCEC
```

修复后应在新副本重跑拒绝矩阵，并由主任务运行完整真实验证和 EDA；本报告不提前登记修复通过。

## 第一次修复后隔离复核

父任务提供 `C:/Users/Donson/Documents/ChatGPT/Shudian/pre4_20261008` 暂存补丁；仍未向 public 写入。本轮使用新的 `script_probe/fixed_runs` 各场景独立副本，入口 `run_fixed_matrix.ps1`，工具桩 `vendor_stub_v2`。所有数字是实际运行结果，而非仅源码推断。

三套独立 CMD：

| 场景 | datapath | units | stress | 判断 |
|---|---:|---:|---:|---|
| Fatal+退出 0 | 1 | 1 | 1 | 已修复 |
| 标准 PASS 后再 Fatal+退出 0 | 1 | 1 | 1 | 已修复 |
| 存在旧 PASS，本轮不输出 | 1 | 1 | 1 | 已修复，旧结果归档 |
| PREFIX 标准 PASS | 1 | 1 | 1 | 已修复行首约束 |
| 标准 PASS SUFFIX | 0 | 0 | 0 | `/B` 未约束行尾，需 `/X /L` |
| 无 PASS 的新日志 | 1 | 1 | 1 | 已修复 |
| 标准 PASS+有效 fixture | 0 | 0 | 0 | 正控通过 |
| 标准 PASS+新零字节结果 | 0 | 0 | 0 | 仅 exist 检查仍接受，需非空文件检查 |
| 标准 PASS+新同名目录结果 | 0 | 0 | 0 | 仅 exist 检查仍接受，需 regular file 检查 |

在继承 `ERRORLEVEL=0` 的进程中，分别让 xvlog/xelab/xsim 退出 -1，datapath 三个场景均退出 1。父任务采用 `if errorlevel 1` 与 `if not errorlevel 0` 双检查，直接读取 CMD 原生状态，因此不再依赖会被环境名遮蔽的 `%errorlevel%`，也无需删除继承的同名环境变量。此修复路径已实际验证。

Windows PowerShell 5.1 对 PREFIX 和 SUFFIX 都退出 1；有效 fixture 正控默认包含 stress，输出 `PRE4_VERIFIED` 和 `PRE4_STRESS_VERIFIED` 后退出 0。原外层未锚定的问题已修复；CMD 行尾问题不会绕过当前完整 PowerShell 路径，但仍影响独立入口。

EDA：本轮只有新的标准 PASS 但无新产物、全部新产物零字节、新 `mapped_core.pdf` 为目录、标准 PASS 后有 ERROR、PREFIX PASS，这五类场景均退出 1；新非空 regular files 正控退出 0。正常有效性正控使用 JSON fixture 复制成不同后缀，验证的是文件新鲜度/存在/非空/regular-file 判据，不能据此声明真实 PDF/DCP 文件格式已验证。

EDA 的旧 11 项产物确实保留：各场景的 `eda/previous_runs/manual_*` 有 11 个文件。不过 `archive_results.cmd --eda` 先执行 `shift`，随后才在 `:choose` 用 `%~dp0` 生成归档目录；CMD 的 SHIFT 默认会移动 `%0`，因此此处解析到新的当前目录 `eda`，而非原脚本根目录。数据没有丢失，但位置与设计的根目录 `previous_runs` 不一致。建议在 SHIFT 前保存一个脚本根变量，后续生成归档路径一直使用它，或用 `shift /1` 保持 `%0`。

归档助手的路径限制实测通过：`..\outside_receipt.json` 被拒绝（退出 1），包外测试文件 SHA-256 未变。但目录防护没有通过：本机 `if exist "<directory>\NUL"` 未识别测试目录，空目录和包含 `sentinel.json` 的非空目录都被助手移到归档并返回 0。此操作仍可从隔离归档恢复，但验收器不应把目录当结果文件移动。应在 move 前按 `%~a1` 的目录属性拒绝，不能依赖 NUL 路径判据。

已将 PASS 行尾、sim 新结果非空/regular-file、EDA 归档位置和归档助手目录防护这四项残余反馈主任务。仍需下一版隔离复核，不能把本小节写成最终修复全部通过。

## 最终补丁隔离复核：本审查发现项均已修复

最终快照来自父任务同一暂存目录，故障矩阵副本为 `script_probe/fixed_runs_final2`。本轮纳入新增 `check_receipts.cmd`，共 42 个案例全部符合预期：37 个拒绝场景退出 1，5 个有效正控退出 0。较早的 `fixed_runs_final` 演练遗漏新增 helper，正控因此失败；该演练不作为产品修复证据，已经用包含全部 helper 的全新副本完整重跑。

最终判定：

| 类别 | 实测结果 |
|---|---|
| 三套独立 CMD 的 Fatal+0、PASS+Fatal、旧 PASS 空跑、PREFIX、SUFFIX、无 PASS | 全部退出 1 |
| 三套独立 CMD 的新零字节或同名目录结果 | 全部退出 1 |
| 三套独立 CMD 的标准 PASS+有效新 fixture | 全部退出 0 |
| xvlog/xelab/xsim 分别 -1，继承 ERRORLEVEL=0 | 全部退出 1 |
| EDA 旧产物空跑、新零字节、新目录、PASS 后 ERROR、PREFIX | 全部退出 1 |
| EDA 新非空 regular files 正控 | 退出 0 |
| Windows PowerShell 5.1 PREFIX/SUFFIX | 退出 1 |
| Windows PowerShell 5.1 有效默认全套 fixture，含 stress | 两条 VERIFIED 回执，退出 0 |
| 归档助手路径穿越、空目录、非空目录 | 全部退出 1，两个原目录仍在，包外文件 SHA-256 未变 |

三套 CMD 最终使用 `/X /L` 完整行匹配，并经 `check_receipts.cmd` 拒绝零字节和目录。归档助手最终用 `%~a1` 目录属性检查，不再依赖 NUL 探测；`shift /1` 保持 `%0`。EDA 四个复核副本各在根目录 `previous_runs` 保留 11 个旧文件，没有错误建立 `eda/previous_runs`。

最终隔离脚本 SHA-256：

```text
run_datapath.cmd  ED1365C32CDAE29BF8E67CEBE9866CB04DF579386F812FE1EFBA220232DC0F67
run_units.cmd     87E63ABBDA619A2581D7BF5DEDE42CF369775DA216CE5CAF354829EDC47EBA9B
run_stress.cmd    CFE24383869AF3BF7F289A45E9C77A9C0271F4B927030232A2D40CBEF2BD346D
run_verify.ps1    E24BB1CAE04839A6B0A040175B1B56D106013BEABFB7BF05F2F7D7D9C8D4861F
archive_results.cmd 16BA33805612BEFDD32FB77DCD4CBAC62CB5481BD77088ED718AD64E2640BF0A
check_receipts.cmd 100E2530DF142C16EF89268942C2726C1952148858D2059885C4F8B8ACF212A4
run_eda.cmd       8DAD0D3BE4E61493F20AE051F1C7CA727B1294A7D7FB385E9D7FA4E44A06B3C4
```

本子任务在最终脚本快照未再发现需要修复的问题。此结论限于所列验收/归档/兼容性矩阵与前述工程安全审查；完整真实数据通路、单元、stress、EDA 文件格式和 public 交付哈希仍由主任务另外复核，本报告不把 fixture 正控升级为原生完整套件通过。

## 原生日志换行差异后的再复核

父任务的真实完整套件发现：XSim 的原生 PASS 行使用 LF，而上述 CMD echo fixture 是 CRLF，导致 `/X` 对原生有效回执误拒绝。之前 42 案例结论没有覆盖 LF，不能升级为完整真实工具兼容性证明。本子任务随后独立对同一标准 PASS 进行 `findstr /X /L` 微型检查：LF 文件退出 1，CRLF 文件退出 0，复现了具体边界。

父任务已用新增 `check_log.ps1` 替换三套 CMD 的 PASS 查找。该检查器在 Windows PowerShell 5.1 逐行读取，以 `-ccontains` 要求 case-exact 的完整回执，并拒绝 Fatal/FATAL_ERROR/ERROR；不改写原始日志。新脚本及全部 helper 拷入 `script_probe/fixed_runs_final3` 独立场景目录。

本轮重跑原有 42 案例，并新增三套 CMD 各 5 类换行案例，共 57 案例全部符合预期：46 个拒绝场景退出 1，11 个有效正控退出 0。

| 新增换行案例 | datapath | units | stress |
|---|---:|---:|---:|
| LF 完整有效回执 | 0 | 0 | 0 |
| LF PREFIX 回执 | 1 | 1 | 1 |
| LF SUFFIX 回执 | 1 | 1 | 1 |
| LF 完整 PASS 后 Fatal | 1 | 1 | 1 |
| CRLF 完整有效回执 | 0 | 0 | 0 |

LF fixture 12 个文件全部确认 CR=0，有效/前缀/后缀文件 LF=2，PASS+Fatal 文件 LF=3。执行后的 12 个日志 SHA-256 均与各自 fixture 一致，检查器没有调整换行或改写原生内容。CRLF 有效场景逐一确认 CR=1、LF=1、末尾字节 `[13,10]`。原有 Fatal/旧 PASS/负退出码/零字节/目录/EDA/PowerShell/归档安全场景也在新快照重跑；没有发现回归。默认 Windows PowerShell 5.1 有效 fixture 全套包含 stress，仍输出两条 VERIFIED 后退出 0。

最新脚本 SHA-256：

```text
check_log.ps1    E65753BF85B9190A28466A0CFAE0EB4D85590C1B990CFEC267EFD5EB97DD39F8
run_datapath.cmd EC1CDBB097D0512CCCD60919A177CB0996EDD7907B6F9F2CCFFA34E9E290A50C
run_units.cmd    144BB6F04BA6A389715D0B1FC1DC74972B5A33A0C3B69680EB130C38AB4C0264
run_stress.cmd   29DABE527C909E3C1A7A2B33A74C23676FC2C0A06FBAE221D1055F58ACD753BA
```

最终脚本验收以本节的 LF/CRLF 检查器版本为准，前节 `/X` 版本只保留为审查过程记录。全部为私有隔离测试；未改 public 文件、未休眠电脑。完整原生 suite 与 EDA 的最终证据由主任务实际运行单独登记。
