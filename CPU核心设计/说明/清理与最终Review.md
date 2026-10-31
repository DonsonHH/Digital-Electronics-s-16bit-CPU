# 清理与最终 Review

2026-10-14：先完整复核并修正迁移路径/创建入口，再完成归档校验、核心独立验证和实际删除。清理67个目标、22个链接对象；移除的50652个普通文件原字节已完整归档，未追踪删除链接的外部目标。

当前只使用CPU核心设计：42页AC1候选Word、5页Buffer/Interlock、13RTL/11TB及r1入口、程序镜像、实际新创建Vivado project、必要原始证据。RTL/TB指纹未变；当前Word仅修正6处失效路径，原32表/9图保留，变化5页重渲染检查，其他37页与已检查版同像素。

迁移后实际创建project并校验13源/9TB+2头/1XDC全部指向本目录；中文路径入口故障已修正。独立48例使用新ID cpu_ac1_independent_q25y6hjh真实执行通过、952逐拍行与原AC1相同。旧九套72d99981原始118文件在删除旧目录后再次历史核验通过，new_xsim_execution=false，未以复制冒充新执行。

CPU实现_v1.5/v1.6/v1.6_timing三目录已不存在；Shudian临时材料/重复副本已清理，仅入口说明及隐藏Git元数据。课程原始课件、教材及Pre1–Pre4正式成果保留，仅删除可重建的.Xil/xsim.dir/__pycache__缓存。

完整恢复归档位于C:\Users\Donson\Documents\ChatGPT_CPU_归档\20261014_会话清理_01a13444，ZIP SHA256=93e07f09a1c0af1f4c1f057bdfb82706b4ca80621673cbac00e040441cb0dfce。原冻结v1.6 Word SHA=e7d1d4af741117bab268faab69c2767fb1a160f7f91c0adf615c7c0b3ef5f171，已保存原字节，可恢复；历史记录编号与身份不改写。

当前候选仍v1.6-timing-AC1/ISA1.5/vtools-r1，OOC为287 LUT/260 FF、WNS+2.620/TNS0/零失败端点。布局布线、实际setup/hold、板级RAM/时钟复位/IO/比特流/下板及全算术/全状态形式验证仍未验收。此阶段不开展Pre5或新优化。
