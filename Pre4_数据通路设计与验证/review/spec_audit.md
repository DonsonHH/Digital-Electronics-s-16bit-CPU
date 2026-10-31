# Pre4 v1.4 specification audit

Audit date: 2026-10-08. Source: `source.txt`, extracted from `CPU核心设计/16位流水线CPU核心设计文档.docx`. This audit defines expected behavior before RTL execution; it does not claim any simulation result.

## Baseline and scope

Use v1.4 machine encodings throughout: `0 MOV reg`, `1 MOV imm`, `2 LDR`, `3 STR`, `4 ADD reg`, `5 ADD imm`, `6 SUB reg`, `7 SUB imm`, `8 AND`, `9 OR`, `A CMP`, `B reserved`, `C JUMP`, `D JZ`, `E HALT`, `F reserved`. There are 14 legal opcodes. All old ISA images and decoders must be excluded from this integration.

The source is internally consistent on the architectural behavior and key timing contract. Some details intentionally permit more than one physical implementation: RAM output registers may implement the logical IF/ID and MEM/WB boundary. The presentation must identify the actual implementation mapping, because adding a same-edge IR or MDR register changes instruction/data alignment and the documented 17-cycle reference.

The instructions, data and PC are 16 bits. R0 is ordinary writable state. Addresses are words; PC increments by 1. Result/address arithmetic is modulo 65536 before capacity checking. For example `FFFF + 1 = 0000` is a legal wrapped address, whereas a completed EA of `0100` or `FFFF` cannot access a 256-word memory.

## Edge contract: checks that must be in the testbench

1. Synchronous IM samples `im_addr` at the end of IF. In the following ID cycle, `im_dout` and the registered instruction pc/valid/fetch_fault describe the same accepted fetch. With `im_en=0`, IM output holds. If fetch is out of range, do not physically read RAM; still create an effective IF/ID fault token with its full pc.
2. Synchronous DM samples an accepted LDR in MEM. Its output is usable in WB the following cycle, and the RF writes at the WB end edge. A load cannot be forwarded out of M as if its EA were loaded data. A separate `w_load_data <= dm_dout` at the same MEM end edge captures the previous response unless the memory mapping is explicitly adjusted.
3. Qualified STR writes at the MEM end edge and creates a WB bubble. A faulting STR preserves valid+fault into WB and cannot use this success-STR bubble rule.
4. EX HALT/fault does not suppress legal older MEM/ WB actions. MEM fault suppresses the younger EX instruction, including branch/HALT/RF and flag intentions, but older WB remains eligible.
5. HALT/fault status changes only when the valid stop token is consumed at the WB end edge and next-state pipeline valids are empty. A HALT in MEM is not yet halted.
6. Redirect kills D and the current IF response, and im_en is suppressed on that event. The target is accepted into IF next cycle. A younger reserved opcode or fetch_fault must be cancellable before EX confirmation.
7. load-use holds PC and D only; X becomes a bubble; older M/W continue. LDR followed by MOV-immediate to the same register has no real source dependency and must not stall.
8. Each state uses synchronous reset; all effective write/redirect/RAM access qualifiers are disabled during asserted reset. RAM contents survive reset. Completed pre-reset stores survive; a pending store at the reset edge is blocked.

Pre-edge sample memory enables and side effects, then check architectural state after NBA updates. Using `!==` makes X/Z outputs count as failures. For sequential state, a tiny TB settling delay is an observation method, not a hardware timing claim.

## Priority and producer selection

Event priority is reset > older MEM fault > EX fault/HALT > EX redirect > load-use > normal advance. mode is RUN, DRAIN_HALT, DRAIN_FAULT, HALTED, FAULTED; all stages still advance/drain where allowed. A global IF-to-WB FSM would violate the required overlapping pipeline.

Data forwarding is the nearest valid qualified M RF producer, then W, then captured ID operand. Only non-load M values are ready. An unready nearest M load must not be bypassed by an older same-address W producer. Normal control should prevent this combination reaching a consumer; assert it if it does.

Z forwarding is nearest M `ZW`, then W `ZW`, then stored Z, regardless of whether a newer M slot is an ADD. A candidate Z=0 is still a producer and overrides older Z=1. ADD/SUB write C/V only; CMP writes Z only. LDR/STR do arithmetic without writing any flag.

C means carry for addition and **no borrow** for subtraction. `u_overflow = raw_carry XOR sub` is a different optional signal. V uses signed exact arithmetic overflow and original b's sign. Non-arithmetic candidate C/V=0 must not overwrite stored flags.

## Exact reference-program schedule

`—` is an invalid slot. `blocked` is a frontend address that is not accepted. Success STR has no W instruction.

| Cycle | IF accepted / request | ID | EX | MEM | WB | End-edge action |
|---:|---|---|---|---|---|---|
| 1 | 0 MOV R0,5 | — | — | — | — | Accept pc0; PC=1 |
| 2 | 1 MOV R1,3 | 0 | — | — | — | Accept pc1 |
| 3 | 2 ADD R0,R1 | 1 | 0 | — | — | X MOV result=5 |
| 4 | 3 SUB R1,1 | 2 | 1 | 0 | — | X MOV result=3 |
| 5 | 4 MOV R3,32 | 3 | 2 | 1 | 0 | R0=5; X ADD uses W R0=5 and M R1=3 |
| 6 | 5 STR R0,[R3] | 4 | 3 | 2 | 1 | R1=3; X SUB forwards R1=3 |
| 7 | 6 LDR R2,[R3] | 5 | 4 | 3 | 2 | R0=8; ADD C/V=0/0 |
| 8 | 7 CMP R0,R2 | 6 | 5 | 4 | 3 | R1=2; SUB C/V=1/0; X STR forwards base R3=32 |
| 9 | pc8 blocked | 7 held | 6 | 5 | 4 | One load-use stall; DM[32]=8; R3=32; X bubble next |
| 10 | 8 JZ +1 | 7 | — | 6 | — | DM read returns8; CMP advances to X |
| 11 | 9 MOV R1,255 | 8 | 7 | — | 6 | R2=8; CMP uses W load=8 and produces eq=1 |
| 12 | pc10 blocked | 9 killed | 8 | 7 | — | JZ uses M Z=1; redirect=10; kill two young slots |
| 13 | 10 HALT | — | — | 8 | 7 | Stored Z=1 |
| 14 | 11 reserved B | 10 | — | — | 8 | JZ completes; HALT advances |
| 15 | pc12 blocked | 11 killed | 10 | — | — | Enter DRAIN_HALT; retain valid HALT token |
| 16 | stopped | — | — | — | 10 | — | halted still0; HALT advances to W |
| 17 | stopped | — | — | — | — | 10 | Consume HALT; halted=1; all valids clear |

Expected final RF `[0008,0002,0008,0020]`, DM[0020]=0008, flags `Z/C/V=1/1/0`, halted=1, fault=0. Expected counters C=17, N=10, load-use stalls=1, taken redirects=1. CPI=1.7, IPC=10/17. This is a cycle count at the specified memory and pipeline contract, not measured Fmax or board throughput.

N must include legal STR at MEM completion, CMP/branch/HALT even when they do not write RF, and exclude killed slots and bubbles. WB and a younger STR can both complete during one edge; record them in age order rather than calling the core dual issue. A fault token is not a successfully retired legal instruction.

## Directed-case independent expectations

All register/state values are hex unless flags. Unlisted state stays at its stated initial value, usually zero. Stop cycle below is optional for the TB, but assumes first accepted IF=C1 and stop-token WB consumption at the cycle end. Changes to reset preparation do not count.

| Case | Final RF [R0,R1,R2,R3] | Z/C/V | Memory / final stop | Required timing | Stop cycle |
|---|---|---|---|---|---:|
| T01 | [0001,0001,0000,0000] | 1/1/0 | halted1 fault0 | ADD preserves CMP Z; JZ skips R3 MOV | 10 |
| T02 | [0001,0002,0055,0000] | 0/0/0 | halted1 fault0 | New CMP candidate0 beats old1; JZ not taken | 9 |
| T03 | [8000,0020,BEEF,0000] | 0/0/1 | DM001F=BEEF and DM0020=BEEF; halted | LDR→STR data stall exactly1; memory ops preserve C/V | 9 |
| T04 | [FFFF,0000,0000,0000] | 0/0/0 | halted; DM unchanged | Wrong-path ADD and CMP have no actions | 8 |
| T05 | [8000,00FF,0000,0000] | 0/0/1 | fault1 halted0; DM unchanged | One load-use stall C4; at C5 MEM LDR EA0100 fault and older ADD WB commits; younger ADD remains D and is canceled | 6 |
| T06 | [0001,0020,0001,0000] | 1/0/0 | DM0020 remains1; halted | LDR→CMP stall1; W data forwarding then M Z forwarding | 11 |
| T07 | [0020,1234,0000,0000] | 0/0/0 | DM0020=1234, DM0021=0; halted | Older load writes C5; HALT MEM C5 still halted0; HALT W C6 | 6 |
| T08 | [8000,0020,0002,0000] | 0/0/0 | DM0020 remains1; halted | C5 front stall while ADD WB C/V=0/1; final ADD restores0/0 | 10 |
| T09 | [0000,0000,0000,0000] after reset | 0/0/0 | modeRUN stopped flags0; DM retained | Assert reset across each active stage, drain/stop states, and legal MEM STR edge; no reset-edge RAM write | — |
| T10 | [000F,000F,0000,0000] | 1/1/1 | halted | MOV register uses forwarded Rs and no old-Rd dependency | 7 |
| T11a | [7FFF,0001,0000,0000] | 1/1/1 | halted | C=no borrow, signed V=1 | 6 |
| T11b | [FFFF,0001,0000,0000] | 1/0/0 | halted | Borrow means C=0; V=0 | 6 |
| T12 | [0505,0F0F,0000,0000] | 1/1/1 | halted | AND holds all stored flags despite candidate C/V=0 | 6 |
| T13 | [A5A5,00A5,0000,0000] | 1/1/1 | halted | OR holds all stored flags | 6 |
| T14a/b | [0001,0000,0000,0000] | 0/0/0 | fault1 halted0 | B/F token confirmed EX C4, stop W C6; older MOV WB C5 | 6 |
| T15 | [0000,0001,0000,0000] | 0/1/0 | halted | D0FD at pc4 targets2; one taken then one not-taken; N=9 | 15 |
| T16 | [0000,00FF,55AA,0000] | 0/0/0 | fault1 halted0 | C4 MEM LDR fault defeats X HALT; directly DRAIN_FAULT | 5 |
| T17a | [8000,00FF,0000,0000] | 1/0/1 | Entire DM unchanged incl DM0=CAFE,DMFF=BEEF; fault | C5 STR EA0100 dm_en=dm_we=0; old ADD WB commits; W fault token retained | 6 |
| T17b | [0001,0000,0000,0000] | 0/0/0 | Entire DM unchanged incl DMFF=BEEF; fault | C5 STR EAFFFF blocked; old MOV WB commits; X HALT canceled | 6 |
| T18a | [0001,0000,0000,0000] | 0/0/0 | Entire DM unchanged; fault1 halted0 | Sparse IM FF=MOV; pc0100 fault D C6/X C7/M C8/W C9; older MOV W C8 | 9 |
| T18b | [0000,0000,0000,0000] | 0/0/0 | DM unchanged; halted1 fault0 | Sparse IM FF=JUMP2; its X C6 cancels young D fetchfault0100; HALT X C9/W C11 | 11 |

Both T18 tests must load IM[00FF] explicitly rather than put the words consecutively from address0. T18a/b are essential to distinguish cancellable fetched errors from global sticky fault at IF/ID.

## Additional high-value integration cases

These close logical gaps outside the mandatory named cases:

- LDR→MOV same destination with immediate operand: no stall, latest MOV replaces loaded register after correct load WB.
- LDR→STR base dependency: one stall; STR uses W-forwarded base while independent store data stays correct.
- Nearest producer priority: two consecutive writes to same RF index followed by consumer; M result beats older W result.
- LDR preceded by older same-register ALU write then consumer: load-use prevents stale W value and load EA from being selected.
- Simultaneous older MEM fault and younger EX branch: no qualified redirect; fault wins, older WB still commits.
- Older legal STR in M while EX illegal instruction/HALT: legal store commits, younger instructions die, stop marker reaches W.
- EA wrapping FFFF+1→0000: legal access due low16-before-capacity semantics, rather than wide address carry causing fault.
- Reset in HALTED/FAULTED returns RUN; no stray effects while stopped before reset.

## Unit-validation requirements and evidence language

CLA4: all512 a/b/cin vectors; check sum/cout/P/G values and invariance of P/G with cin. CLA16: source/RTL diagram proves top-level K1..K4 lookahead, not chained couts. A finite regression proves only its stated input subset; full binary CLA16 and ADD/SUB each need2^33 combinations, ALU including all8 op codes needs2^35. Existing historical long tests are not valid proof for new source.

Decode: all65536 instruction words against current two independent control tables, including ignored fields and safe B/F defaults. Flags: all512 oldstate/rst/mask/newinput transitions; setup clocks do not count as tested transitions. Immediate: all512 input/mode combinations. ALU reference V uses signed exact 32-bit arithmetic/range checks instead of reproducing RTL's overflow Boolean formula.

Proof of correct simulation binds source/TB/IM/DM hashes, tool version and actual memory edge configuration. Schematic/RTL analysis can show connectivity and two-level CLA structure. Synthesized CARRY4 counts show FPGA mapping, not hand-CLA topology or speed advantage. Without implemented clocks and complete setup/hold coverage, report cycle count and synthesis resources only; no Fmax claim.

The course manual identifies xc7z020clg484-1; old clg400 or z010 reports cannot establish this core's actual board implementation. Core ports are internal memory interfaces, not87 device pins. A standalone datapath/core synthesis may be useful evidence, but its part choice must be explicit and any board mismatch left unresolved in the delivered limits.

## Review disposition

No mandatory architecture ambiguity currently requires a new user decision. Implement and test the fixed edge contract and mark all evidence by its actual completion level. The main integration risks are token retention, older-write preservation under stop, ignored-field source masks, flags-only writes, and synchronous-memory alignment. The exact T01..T18 and17-cycle baseline above make these issues reviewable.

## Preliminary implementation review

Read the first available `datapath_core.sv`, `operand_forward.v`, `sync_memories.v`, `isa_decode.v`, `alu16.v` and `tb_datapath.sv` directly. The core's current stop token, RAM boundary, priority and forwarding implementation agrees with the specification on static inspection. This is not an assertion that unexecuted code has passed.

The initial TB correctly compares age-ordered WB and MEM-STR events, all final RF/flag/DM state, timeout, and the17-cycle baseline. One material verification gap remains: WB event comparisons should explicitly require the expected write masks and RF destination rather than only checking data when actual write enables happen to be asserted. Otherwise a missing or misdirected write could be hidden by a later overwrite or bypass. Expected RW is op0/1/2/4/5/6/7/8/9; expected ZW onlyA; expected CVW4/5/6/7; expected halt token onlyE. Also add explicit pre/post-edge assertions for T05/T08/T16/T17/T18 and T09 rather than relying only on final architectural reference results. This feedback was sent to the main agent for implementation.
