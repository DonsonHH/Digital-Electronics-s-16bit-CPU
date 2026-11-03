# 核心文档维护入口

此目录维护单一正式核心Word的内容和结构。当前为架构版r5语言整理版；默认AC1、ISA v1.5及现有流水周期不变。正文按指令契约、数据通路、流水控制、系统实现与验证四章组织，历史编码和运行来源、复现维护、参考资料分别放入附录A至C。文档生成只读已完成的验证记录，不连接、扫描或烧录板卡。

- `architecture.json`：四章顺序、顶层契约、控制所有权、CW字段、级间载荷和五个例子的稳定ID。
- `sections.json`：从已审阅r2迁入的成熟段落、表格、公式与引用。节的key是稳定锚点；可修改其title和内容，不用原Word段落下标定位。
- `content.json`：新增架构说明。`assets/`保留原有图件；整体图、详细DP、系统图继续使用核心目录的可编辑SVG及其PNG。
- `canonical_outputs.json`：当前48例输出的不可自证基准。两个CSV摘要取自提交`0d888cc`中已经提交的清单，参考运行须与当前13份RTL和冻结输入一致；新CSV必须逐字节匹配，不能仅按行数通过。
- `architecture.json`中的`board_validation`为本版必需的实板证据指纹。生成前核对五程序各两份原始VIO快照、实际bitstream及S1清零/重启记录；缺失或空指纹直接拒绝，不能仅凭摘要文字生成“实板通过”。
- `build_core_document.py`：读取上述内容，生成Word的分级标题、目录域、图表序号及可点击交叉引用。旧Word仅作为样式模板，正文不从旧段落重新套回。
- `validate_document.py`：静态内容、引用、源文件和正文身份检查。它不替代原生Word渲染和逐页视觉检查。

正文引用使用`[[F01]]`、`[[T14]]`、`[[N_SIGNAL_CLASSES]]`或`[[S:PAYLOAD]]`。迁移材料中的`[[S:2.7]]`是稳定旧锚点的兼容别名，不是新文档当前节号。所有表号列表的成员都应分别写成锚点。

从仓库根目录复跑，或改用脚本绝对路径：

```powershell
python -B -X utf8 CPU核心设计/Vivado/run_independent.py
python -B -X utf8 CPU核心设计/文档源/build_core_document.py --independent-run CPU核心设计/验证记录/某个新48例记录 --proof-output C:/Temp/architecture-proof.json
python -B -X utf8 CPU核心设计/文档源/validate_document.py --document CPU核心设计/16位流水线CPU核心设计文档_AC1候选版.docx --proof C:/Temp/architecture-proof.json
python -B -X utf8 -m unittest discover -s CPU核心设计/文档源/tests -v
```

生成后用Word更新全部域与目录、导出PDF并逐页检查；字段更新不应改变正文身份摘要。新源文件、图件或正文发生变化时，要重新生成和核对证据，不能沿用旧的视觉验收结论。

本版沿用r3已真实执行、与当前默认RTL一致的48例记录并保留原运行身份；只更新文档时不因此声称再次运行XSim。实板证据来自单独的真实设备流程，有限五程序及S1通过不扩大为独立频率、直接计时或实验候选的通过。

`import_baseline.py`仅用于一次性迁移；目标内容或素材已存在时，在任何写入前拒绝。两个旧生成入口仍保留历史复现功能，并会拒绝覆盖`AC1-architecture-*`版本的Word；要复现旧稿，显式指定其他`--output`文件。
