# Pre5 控制单元设计交付包

先打开根目录的PPT、英文讲稿和五人分工指南。正文16页，隐藏备用页6页；英文汇报目标15分钟。A讲1–3页，B讲4–6页，C讲7–9页，D讲10–12页，E讲13–16页。

第一次准备时，先按`分工与准备指南.md`中的“全员先理解什么”和“共同的Vivado操作”完成一遍，再练自己的Word段落。指南已给出老师要求与页码的对应关系、中文术语解释，以及五个人各自要完成的操作和检查标准。

## 文件用途

| 内容 | 位置 |
|---|---|
| 英文PPT，含逐页英文备注及可编辑图表 | `Pre5_Group2_CU_EN.pptx` |
| 正文讲稿、指图提示、备用页讲解及12题答辩 | `Pre5_英文讲稿与答辩.docx` |
| 五人任务、准备方法与排练要点 | `分工与准备指南.md` |
| RTL、TB、建工程与仿真脚本、真实结果和波形 | `Vivado/` |

本包不含SVG、页面预览、重复PPT、审计报告、临时缓存或Pre6材料。原CPU核心和历史Pre4未修改。

## Vivado文件

`Vivado/rtl`有13份生产RTL；`tb`有9个TB入口和2份共享头文件。`程序镜像`保留基准汇编及机器字。`source_manifest.json`记录本包输入指纹；修改源码后不能沿用旧PASS。

`验证记录`保存本包实际复跑的九套回归、独立48例及其日志；独立参考输入在`验证记录/independent_48_saved`，用于复跑，不是另一套CPU源码。`control_traces`保存11个用例的逐边沿CSV/JSON。准确的运行目录见`control_evidence.json`与`验证结果.json`。

`independent_48_saved/generate_cases.py`保留参考结果的生成逻辑供阅读溯源；其原始完整审计目录不在本包内，不要直接运行它的`main`。本包的独立48例复跑入口是下文的`pre5_verification.py --stage independent`。

CPU为v1.6-timing-AC1、ISA v1.5；Vivado 2025.2，器件`xc7z020clg484-1`。本次仅调整交付路径和运行入口，生产RTL和TB保持不变。没有接入Hybrid实验、添加新CU实体、改变ISA或下载FPGA。

## 创建并打开工程

已附可直接打开的`Vivado/project/cpu_v16.xpr`。如需从源码重建，在本包根目录打开PowerShell：

```powershell
$pre5Python = 'C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
.\Vivado\create_project.ps1 -Python $pre5Python -ProjectDirectoryName project_new
```

重建后打开`Vivado/project_new/cpu_v16.xpr`。脚本不覆盖已有工程；需要再次创建时换一个目录名。其他电脑需要改为本机Python路径；Vivado安装路径不同时用`-VivadoBin`指定。

工程RTL顶层是`datapath_core`，仿真顶层是`tb_datapath`。查看电路可使用RTL Analysis；仿真时执行Run All。该GUI操作不会自动发布九套回归的PASS记录。

## 完整复跑

在本包根目录执行：

```powershell
$pre5Python = 'C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $pre5Python -B -X utf8 .\Vivado\pre5_verification.py --stage regression
if ($LASTEXITCODE -ne 0) { throw '九套回归失败，请检查本次日志' }
& $pre5Python -B -X utf8 .\Vivado\pre5_verification.py --stage independent
if ($LASTEXITCODE -ne 0) { throw '独立验证失败，请检查本次日志' }
& $pre5Python -B -X utf8 .\Vivado\extract_control_evidence.py
if ($LASTEXITCODE -ne 0) { throw '证据核对或提取失败' }
```

前两条实际调用XSim；第三条只核对已有证据并提取时序，不是新仿真。运行器为每次尝试创建独立目录，保存超时、中断和失败记录。新失败不能由旧成功代替。默认原生工具位置为`C:\AMDDesignTools\2025.2\Vivado\bin`。

以上完整复跑入口按本机2025.2安装位置配置；`create_project.ps1`的`-VivadoBin`仅改变建工程工具位置，不会同时改变独立48例运行器中的工具路径。其他电脑若安装目录不同，可先用附带XPR在本机Vivado中学习和仿真；不要把只改建工程参数误认为全部命令已适配。

## 查看波形和使用边界

打开本次运行目录中的`datapath.wdb`或`trace.wdb`查看波形；`datapath.vcd`、`interlock.vcd`也供兼容查看器使用。CSV内`pre_`是边沿前值，`post_`是同时间戳更新稳定后的值；每张PPT另标出周期口径。

九套回归、独立48例为有限功能验证。65,536个二进制译码输入已遍历，不等于ALU全部输入或CPU全状态穷举。10ns约束或TB时钟不等于板级100MHz通过。未新增布局布线、硬件性能或下板验收。英文正文约1,622词，仍需全组带PPT计时排练。

2026-10-19复核补充：隔离副本中的九套回归与独立48例再次通过，生产RTL、TB、PPT和讲稿未因本次复核改动。证据提取器补上了独立48例原始仿真日志及控制台日志的SHA-256核对；两种错误指纹均已验证会被拒绝。包内原有2026-10-17运行记录保留原日期与身份，本次隔离复跑记录不替换包内历史记录。

已从`independent_48_saved/programs`移出14份不再被当前用例配置读取的旧镜像，并同步输入清单；可恢复备份位于`C:\Users\Donson\.codex\visualizations\2026\10\19\pre5_final_review\backup\unused_fixtures`。历史运行目录内的原始快照不作清理。
