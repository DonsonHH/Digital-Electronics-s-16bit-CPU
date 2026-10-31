# Pre4 independent RTL and testbench review

Review scope: v1.4 extracted source, first implemented datapath and memory modules, and `tb/tb_datapath.sv`. Review date 2026-10-08. This record is read-only advice; the main agent owns fixes and simulation.

## Static RTL result

No functional core defect found in current static inspection. Specific paths reviewed include synchronous-memory data/tag alignment, true-source masking, M-over-W RF forwarding, load readiness blocking, independent STR data forwarding, M-over-W Z forwarding including zero candidates, ADD/SUB C/V versus CMP Z writes, successful STR WB bubble, fault STR WB token retention, older WB write under younger MEM fault, EX HALT/fault drain, MEM-fault precedence over EX branch/HALT, and cancellable out-of-range fetch markers.

CLA16 contains four local CLA4 groups and explicit K1..K4 expressions independent of chained local cout. CLA4's P/G depend on a/b only. ADD/SUB candidate C and V logic matches the source. Unused local cout nets can be optimized away; this is not itself a functional issue.

The current `m_fault_event` is qualified by mode RUN. That is correct under the specification's synchronous, non-delayed error contract: every older MEM fault is already checked when EX HALT is accepted. It should not be generalized to a future delayed-error memory interface without revisiting the state graph.

## Required TB improvements

### R1: exact WB action masks and destination

Currently a WB event matches the pc, then only checks data or flag candidates *if actual write enables are asserted*. Require masks independently from expected opcode:

| Expected op | RF write | Z write | C/V write | HALT token |
|---|---:|---:|---:|---:|
| 0,1,2 | 1 | 0 | 0 | 0 |
| 4,5,6,7 | 1 | 0 | 1 | 0 |
| 8,9 | 1 | 0 | 0 | 0 |
| A | 0 | 1 | 0 | 0 |
| C,D | 0 | 0 | 0 | 0 |
| E | 0 | 0 | 0 | 1 |

For RF writes additionally require w_rd equal the reference instruction's Rd. For LDR require w_wb_sel=1, others=0 where relevant. A W event with expected STR is always wrong because legal STR completes at M. Record raw expected Rd and opcode in the reference event. Then compare candidate data and masks with case inequality (`!==`). This catches omitted/misdirected actions even when final state happens to agree after later overwrites.

### R2: generic pre/post-edge stop assertions

Before each active clock edge, snapshot mode and the current W token; after NBA updates inspect updated state:

- If pre-mode is DRAIN_HALT and pre-W is valid HALT, post-mode must be HALTED with halted1/fault0 and all D/X/M/W valids0.
- If pre-mode is DRAIN_FAULT and pre-W is valid fault, post-mode must be FAULTED with fault1/halted0 and all D/X/M/W valids0.
- Without a valid W stop token, halted/fault may not rise during RUN or DRAIN. This catches stopping in the M cycle.
- No writes or memory accesses are allowed for a fault W token. When final stopped, require mode/output stability, all valids0 and all memory/RF/flag enables0 over at least3 edges.
- Snapshot enables at the sampling edge rather than only inspecting post-NBA enables, since those already describe the next instruction.

Checking `drain_done` against itself is insufficient. Require the observable stop event at the exact old W token edge, then verify the resulting empty pipeline independently.

### R3: mandatory event ordering and cancellation witnesses

| Test | Pre-edge witness | Post-NBA check |
|---|---|---|
| T05 C5 | M=LDR pc1 EA0100, dm_en0, W=ADD pc0 rf_we1/cv_we1 | R0=8000 C/V=0/1; mode DRAIN_FAULT; W fault pc1; D/X/M invalid |
| T07 C5 | M HALT pc1, W older LDR pc0; halted0 | R1=1234; HALT now valid W; halted still0 |
| T07 C6 | W HALT pc1 | halted1, all valids0 |
| T08 C5 | X LDR pc2, D ADD pc3, load_use1; W ADD pc0 cv_we1 | flags C/V=0/1; D held; X bubble; older load advances M |
| T16 C4 | M fault LDR pc0, X HALT pc1, qualified_halt0 | mode DRAIN_FAULT directly; X HALT absent M; fault marker valid W |
| T17a/b C5 | M STR pc1 EA0100/FFFF, dm_en0/dm_we0, W older op0 | W valid fault pc1; no successful-STR bubble; older action done |
| T18a C5 | fetch_addr0100, im_en0 | D valid fetch_fault with pc0100 |
| T18a C7 | X valid fault pc0100; older MOV M pc00FF | DRAIN_FAULT, preserve MOV for WB C8 |
| T18b C6 | X JUMP pc00FF, D fetch_fault pc0100, qualified_redirect1 | D/X young fault canceled; PC=0002; no X fault0100 ever |

Every special-case assertion also needs a `witness_seen` counter/bit required at the end, so a test cannot silently pass because its condition never occurred. Tests T05/17 additionally compare all DM256 words, already present in final-state check. T18 cases require sparse IM[00FF], already loaded correctly.

T05 correction: its LDR target R2 is immediately read by ADD R2,#1. Therefore the load-use stall is **C4**, and at C5's MEM fault the young ADD is still in D with X bubble. Require T05 stalls=1. Use T16/T17b for actual EX-HALT conflict, and add a separate non-source EX-branch conflict case if desired.

### R4: reset T09

Reset tests must assert rst on a falling edge before the desired active upper edge, inspect pre-edge enables0, and verify after NBA that PC/RF/flags/all valids/stop state reset. Deassert on a later falling edge. Include active D/X/M/W cases, a pending legal M STR that otherwise would write at that reset edge, previously completed store preservation, both drain modes, HALTED and FAULTED. Snapshot RAM before reset and compare all words after; core reset must neither clear RAM nor permit that pending store.

## Inline reference-model audit

The current v1.4 sequential model's machine-word decoding and program images agree with the source. `16'($signed(imm8))` correctly sign extends s8, unsigned immediates zero extend, the `16'(...)` EA cast implements modulo address truncation before bounds checking, and setting JUMP's reference PC to target-1 before common increment implements the absolute target even when target0 wraps temporarily. JZ adds signed displacement to current instruction pc before common+1, so D0FD at pc4 goes to2.

Signed overflow expected values use `$signed(a/b)` into32-bit integer and exact signed range checks, which is independent of RTL's overflow formula. Unsigned add C uses widened sum; SUB C compares a≥b. RF and flags initialized in TB before deasserting reset are appropriate fixture preload only; the baseline program establishes its own state normally. Coverage claims should label these two setup methods.

The reference event list has room for500-step bounded executions. Faulting instructions correctly do not become successful retirement events. A successful HALT becomes the final legal event. Event order WB then successful MEM STR matches ages. Random tests constrain memory operands to R3=32 and sixteen offsets with R3 never overwritten; this supports valid-address random regression but not random control-flow or full data-space coverage.

## Recommended additional directed cases

1. **MEM fault beats EX branch:** R1=00FF,R2=55AA, words1001,2901,C004,E000,E000. Old MOV pc0 WB and faulting LDR pc1 M coincide with JUMP pc2 X at C5; redirect rejected; R0=1, R2 remains55AA, stopfault C6, no redirects.
2. **LDR does not falsely stall MOV imm:** R1=0020, DM32=ABCD; words2100,1007,E000. Result R0=7, stalls0, stop C7. The older load still writes ABCD at C5 before later MOV writes7 at C6.
3. **LDR→STR base:** R1=0020,R2=BEEF,DM32=0021; words2100,3800,E000. LDR writes R0=33; STR R2,[R0] writes BEEF toDM33 with exactly1 stall; stop C8.
4. **Legal older STR with younger EX fault:** R0=CAFE,R1=0020; words3100,B000,E000. STR M C4 writesDM32; illegal B X C4 requests drain; fault WB C6. Store must remain.
5. **Wrapped EA:** R1=FFFF,R0=CAFE; words3101,2901,E000. STR writesDM0=CAFE; LDR readsR2=CAFE because FFFF+1 low16=0000; no fault, no stall, stop C7.

## Review status

Current static code agrees with v1.4. TB improvements above are required before describing named tests as proving their detailed stage-specific behavior. Final review must re-read final source and actual logs, confirm each witness was observed, and verify PPT evidence describes the actual source, part, clock/memory configuration and completed coverage.

## Implemented review changes, awaiting rerun

At the main agent's request, updated only `tb/tb_datapath.sv` after exclusive TB edit ownership was assigned. It now requires exact RF/flag/HALT/WB-selector masks and RF destination, validates stop only at a pre-edge valid WB token, checks final pipeline emptiness and stopped-state holding, and records a required/seen witness bitmap. T05/T07/T08/T16/T17a/b/T18a/b and five additional timing cases have explicit pre/post-NBA witnesses; absent witnesses are fatal. T05 now requires one stall. Added the WRAPPED_EA case.

Reset probes now preload nonzero R3 and Z/C/V so clearing is observable, retain a DM marker, explicitly witness a pending legal MEM store and a completed store, and add DRAIN_FAULT/FAULTED reset probes. Total reset probes expected:16. Existing successful-path sweep includes DRAIN_HALT/HALTED. T14a/b calls were unrolled to avoid an observed older XSim temporary-string crash. Dynamic case labels are first stored in persistent named strings and copied before timing waits.

Current edited TB SHA256: `202EEAA54E17F97DDF2B5B6A10EEC464F75FF67BCF91651D0F1988A2C7D6F94F`. No simulation was launched by this reviewer during the main agent's tool troubleshooting. The edit is pending actual XSim compile/run and final PASS validation. A native process exit0 alone is insufficient, because the previous tool run emitted an internal simulator fatal despite exit0.
