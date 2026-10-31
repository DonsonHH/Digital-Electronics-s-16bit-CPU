# AC1 最终文档一致性 Review

日期：2026-10-14。结论：文档与v1.6-timing-AC1实际结构已同步，可以结束本次文档收尾。冻结v1.6及ISA v1.5原件、生产和候选RTL均未修改。

## Step 1 结构核对

冻结版addsub16_cla实例化两层cla16/cla4_pg；AC1同名模块内部为显式无符号17位a+(b XOR sub)+sub，综合推断FPGA进位链。carry/no-borrow、overflow、eq和写掩码不变。AC1 u_forward.m_fault只接寄存m_fault；m_access_fault/m_fault_event、DM保护、年轻EX取消、WB故障标记及老WB完成保留。

这种资格化简适用于本ISA的有效指令与固定即时MEM fault契约；不能由此推断任意内部控制故障容错或可变延迟接口正确。M load仍不转发EA，阻断旧W；非load RF生产者不访问DM。未改变副作用阶段、valid/年龄、stall或pipeline边界。

## Step 2 候选核心文档

以冻结Word为副本，局部同步首页、2.4.3/算术公式、图1–4及相关表格、MEM前递连接、源码验证身份与OOC说明。历史CLA公式仍可查，但明确不是AC1的ALU路径；历史VCD图8/9没有冒充AC1新波形。原ISA和控制表完整保留。

实际Word16更新目录/题注后为42页。32表、9图和原页面几何保留；28表文字完全相同、图5–9媒体逐字节相同。题注SEQ域保留，图1–9/表1–32连续且无重复编号。51处段落/单元格修订按范围记录。Word刷新可能重新序列化包元数据/XML，已另外核查技术内容、结构、图和页面，不能将重新保存的整个包SHA等同原件。

## Step 3 五页冲突指南

无需修订：全文无CLA物理结构陈述，矩阵/use来源、最新M优先W、M load阻断旧值、一拍load-use、CMP/JZ的Z前递、Flush、Reset和年龄优先级适用于AC1。

对照已存AC1独立48例记录中的DOC_ADD_ADD、DOC_LOAD_STR、DOC_CMP_JZ、DOC_STR_HALT，机器字及初值对应指南；37个有效D/X/M/W逐拍位置匹配。指南中的IF请求与取消同样由保存CSV和原48例通过记录支持；本次仅读取核对，不重新运行。这四例的周期、stalls、store和最终状态按已有独立记录保留。

## Step 4 最终一致性与视觉核查

候选42页、指南5页均用本机Microsoft Word16真实PDF导出，并由运行时Poppler以150dpi生成全部PNG，逐页打开检查。图、公式、表格、页码无裁切、重叠、溢出、缺字或重复编号；保留原章节留白及分页。目录2.4.3为12页、3.5为25页、4.1为28页、4.10为40页，与正文对应。打包render_docx.py已尝试，但本环境无soffice.exe；未声称LibreOffice已渲染。

AC1实际九套记录attempt：72d99981-0aef-4b1d-8c13-e8d7bc624cf9；其绑定的13RTL指纹与当前推荐源码一致。时序证据为AC_decoupled_carry_synth_7dc8dbed3ed74afda0982a83cf74cccc；输入及全部报告哈希匹配同一源码，287 LUT、260 FF、WNS+2.620ns、TNS0、0失败端点。

这些数值是datapath_core的同条件OOC综合估算，未place/route；IM/DM在核心端口外。33输入/53输出缺I/O delay，实际板级顶层/时钟复位/RAM/XDC/setup/hold仍需独立集成验收。没有已实现100MHz、完整算术穷举或CPU全状态形式证明声明。原冻结Timing FAIL身份仍保留。

冻结原核心SHA256：e7d1d4af741117bab268faab69c2767fb1a160f7f91c0adf615c7c0b3ef5f171。

五页指南SHA256：8b33d94a3dc24881b63c3a5fd95b92aa27a739c9c4a4bb6733bfde372cadbf2d（本次复制原样）。

新AC1核心SHA256：52103716229cc2b2025be1004a79bf923d7c396fd8e2d1b0761be174c916d5cf。

生产目录全部1868文件、正式核心目录、当前AC1 RTL/TB及以前最终ZIP/Review指纹保持。仅新增候选Word及本次文档说明/清单；不覆盖旧交付ZIP，文档补充包明确绑定旧AC1主包。没有新仿真、新综合、生产RTL修改、Pre5或额外时序优化。本任务结束。
