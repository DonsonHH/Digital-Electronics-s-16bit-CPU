# CPU核心设计当前入口

当前为 **AC1系统准备r1**，CPU v1.6、ISA v1.5，目标课程EES-331（xc7z020clg484-1）。开发入口是本Git工作副本。核心Word保持四章架构；第2.10和4.11节补充文件启动、结果观测、稳定停止与真实系统验证。Pre4、Pre5及旧执行快照保留当时的版本语义。

## 阅读与源码

- [核心Word](16位流水线CPU核心设计文档_AC1候选版.docx)：50页、Word内分级目录。第9–10页是两张原有主图，第47页新增文件启动系统图。
- [核心RTL](Vivado/rtl)：13份；本轮只扩展datapath_core的被动观测，以及sync_memories的文件初始化。原执行仲裁、写入边沿及11份其他RTL保持。
- [最小系统顶层](系统/rtl/cpu_system.sv)：第14份系统源码，连接一拍同步IM/DM，提供RF写回影子与最后store观测。
- [系统契约](系统/接口与停止现场契约.md) · [文件启动镜像与manifest](系统/programs) · [既有Buffer说明](CPU流水线冒险与Buffer_Interlock完整设计方案.docx) · [证据索引](证据索引.json)。
- [系统图SVG](架构图/03_文件启动系统与停止观测.svg) · [PNG](架构图/03_文件启动系统与停止观测.png)。原整体图、五级datapath、F/Q/G和模式FSM仍适用原执行路径。

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

系统OOC：376 LUT、431 FF、2 RAMB18、15 CARRY4；10 ns下WNS +1.363 ns、TNS 0、0失败端点。它包含观测与影子资源，不能与旧core-only的287 LUT/260 FF直接混比。尚未布局布线、完整IO约束、实际setup/hold、比特流或下板；ZPS7-1 Warning仍在。没有合入WB→MEM免停、单步、暂停或可变延迟存储。

正式Word生成器要求显式指定完整通过回执，并核对当前源码及回归TB指纹；旧PASS或改过源码的记录会被拒绝：

```powershell
python -B -X utf8 .\系统\build_core_document.py --system-receipt .\验证\cpu_system_n0r4buws\result.json --tools-receipt .\验证\tools_50040838e0ec474680085bb91e8fb001\result.json
```

生成后仍须用Word刷新目录、导出并逐页检查。文件SHA256.json只反映其生成时刻的受跟踪交付；历史导入清单保持7753502原快照身份。两份用户已确认删除的旧ZIP不会被误记为已恢复。
