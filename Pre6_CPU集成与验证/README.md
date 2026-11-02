# Pre6 CPU集成与验证

正式汇报入口为 [英文PPT](Pre6_Group2_CPU_Integration_EN.pptx) 和 [五人英文讲稿与答辩](Pre6_英文讲稿与答辩.docx)。PPT共12页正文、8页备用；Word包含逐页英文讲稿、中文指图提示、五人交接句和常见问题。

| 讲者 | 正文页 | 负责内容 | 讲解预算 |
|---|---|---|---|
| A | 1–3 | ISA、设计流程 | 2:35 |
| B | 4–5 | 系统接口、五级datapath | 2:45 |
| C | 6–7 | 控制协作、数据冒险 | 3:00 |
| D | 8–10 | 分支、功能验证、实板结果 | 2:50 |
| E | 11–12 | 性能、总结 | 2:50 |

正文共1,199个英文词，讲解预算14分钟，另留1分钟给交接和指图停顿。预算经过字数核对，仍需五人实际计时排练；备用页不计入15分钟正文。

## 版本与证据

制作基于 `9475f210c7e567cb41f3856ff3bcebc6611ac991` / `cpu-v1.6-ac1-ees331-verified`：CPU v1.6、ISA v1.5、默认AC1、核心文档r4、EES-331（xc7z020clg484-1）。本次只制作汇报，未改变CPU、历史Pre4或验收标签，也未重新运行CPU仿真、综合或板卡操作。

- 第7、8页逐拍案例来自既有仿真CSV。第7页为真实8周期load→store；第8页为真实9周期CMP→JZ。
- 第10、18页明确标为归档VIO快照解码，RF为写回影子。没有生成仿真GUI截图；S1实板结论限于CPU停止后清零并重新运行。
- 第11页的25、17、30、15、55周期来自五程序实板计数；`C=N+4+S+2R`仅用于这五个正常HALT程序，N含HALT。CPI为`C/N`，不同工作量不按总周期排名。
- 第19页为含VIO、存储器和观测逻辑的完整board top资源及布线后WNS/WHS，不是core-only资源或独立最高频率测量。
- 第20页是WB→MEM候选的既有离线比较；默认AC1仍为实板验收版本。另一项前递MUX候选未采用，其完整记录保留在核心目录。

逐页结论、预期/实际数据、来源文件和SHA256见 [source_map.json](配套源文件/source_map.json)，同一来源也写入每页备注。52份引用输入逐一与冻结提交字节比较，后续输入改变时采集器将拒绝继续。

## 制作源与复核

- [presentation_content.py](配套源文件/presentation_content.py)：唯一英文讲稿与答辩源；生成的`content.json`同时供PPT备注和Word使用。
- [collect_evidence.py](配套源文件/collect_evidence.py)：读取冻结源码、仿真、VIO和P&R记录，输出`evidence.json`及逐页来源索引。只读核查，不启动硬件。
- [build_slides.mjs](配套源文件/build_slides.mjs)：使用`@oai/artifact-tool`创建原生文本、表格、连接图和堆叠图。性能图包含内嵌XLSX，可在PowerPoint编辑数据。
- [build_script_word.py](配套源文件/build_script_word.py)：生成同源讲稿Word。
- [render_powerpoint.vbs](配套源文件/render_powerpoint.vbs)：在私有副本检查原生表格/图表编辑、保存及重开，导出页面用于检查，不关闭用户其他演示文稿。
- [check_delivery.py](配套源文件/check_delivery.py)：重新核对冻结输入、20页/20份备注、英文正文与Word一致性、16个原生表格、图表20个数值及工作簿。
- [图源](配套源文件/图源)：四张已核对的完整SVG，按冻结基线原字节保留。正文使用制作脚本内的原生简化连接图，完整图作为配套查阅材料。
- [核对结果](配套源文件/核对/delivery_check.json)：交付哈希、检查结果和逐页字数/时间预算。原生Office渲染和最终包检查凭据同目录保留；不堆放全部预览图片。

当前机器复跑只读交付检查：

```powershell
$py = 'C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py -B -X utf8 .\Pre6_CPU集成与验证\配套源文件\check_delivery.py
```

重建材料时先运行`collect_evidence.py`，再调用Word生成器的`--output`。PPT构建器参数依次为Pre6目录、临时构建目录、唯一修订名；需使构建器能解析当前机器的`@oai/artifact-tool`，并使用脚本中的已安装presentation工具与Python。输出到临时目录，检查后再发布；不要将`node_modules`、Office临时文件或全部预览图提交。

本次已用本机PowerPoint渲染20页、Word渲染10页并逐页查看；表格、图形和图表保留可编辑。排版自动检查的少量估计警告以原生渲染逐页核对，实际发现的重叠已修正。真人整组排练和可选现场演示需在汇报前安排。
