Use case: scientific-educational.
Create one new English-language CPU architecture infographic titled "16-bit Pipelined Datapath". Subtitle "ISA v1.4 / Single issue, in order / Word-addressed memories". This is a complete MODULE-LEVEL LOGIC MAP with a separately expanded signal-flow map, not a pin-level wiring schematic. Use the highest available native landscape resolution, white background, crisp navy sans-serif typography, pale stage colors, teal/blue/orange/purple flow accents and generous whitespace. Main body labels must be large enough to read. No perspective, photo, gradients, shadows or chip clip art.

MOST IMPORTANT LAYOUT RULE:
Do not draw wires or arrows between module cards WITHIN a stage, and do not draw physical wires from the external RAM boxes to the core. Modules are grouped by stage in the upper half. Their real directed connections are defined by the labelled signal-flow rows in the lower half. This deliberately avoids inventing serial dependencies or ambiguous pin connections. Do not add an ALU-to-branch arrow, flags-to-stop arrow, store-to-forwarding arrow or RF-to-immediate arrow. There are NO internal vertical chaining arrows in the architecture region.

TOP REGION: EXTERNAL MEMORIES, OUTSIDE THE CORE
Two clear horizontal memory boxes above the five-stage core:
"IM 256 x 16"
"Input: IF address16 + enable"
"Output: registered instruction16 to ID"
"DM 256 x 16"
"Input: MEM address16, store16, enable, write-enable"
"Output: registered load16 to WB"
Small shared note: "One synchronous read edge. en=0 holds dout."
These are outside a dashed outline labelled "datapath_core". Do NOT draw physical RAM pin arrows, so no input/output direction can become ambiguous. Do not imply rst clears RAM contents.

MIDDLE REGION: FIVE-STAGE CORE COMPOSITION
Five clearly separated left-to-right stage groups with large headings "IF", "ID", "EX", "MEM", "WB". A thin gray horizontal PIPELINE-PACKET ribbon across their top has only four right-pointing transitions. Align the four boundary labels with those transitions: "IF/ID*", "ID/EX", "EX/MEM", "MEM/WB*". This ribbon means instruction progression and aligned payloads, not a combinational wire through all modules.

Inside each group, use simple module labels and short descriptions with NO inter-module arrows:

IF:
"pc16" / "PC_fetch; sequential +1 word"
"Fetch range guard" / "Full address: 0x0000..0x00FF"
"PC priority" / "reset > qualified redirect > hold > +1"

ID:
"isa_decode" / "Rd, Rs, imm8; use masks; controls"
"regfile4x16" / "R0-R3; 2 read ports, 1 WB write port"
"imm_ext16" / "Zero / sign extension"
"WB-to-ID bypass" / "Qualified same-address WB data at RF read outputs"
This is the ONLY register-file storage block in the image. Do not print register-index bit slices.

EX:
"operand_forward" / "Rd and Rs independently"
"Operand MUXes" / "A: 0 / Rd / Rs; B: 0 / Rs / imm16"
"alu16 + CLA16" / "result16; eq/C/V candidates"
"branch_target16" / "JUMP absolute; JZ uses captured x_pc"
"Z selection" / "M CMP > W CMP > saved Z"
All EX functions are grouped, not chained vertically. Forwarding serves RF operands; immediate enters the MUX independently. Branch calculation is independent of ALU result.

MEM:
"MEM access guard" / "Full EA range before 8-bit indexing"
"Ordinary value / address" / "m_exec_value"
"Separate STR value" / "m_store_data"
"Qualified DM access" / "dm_en = mem_ok AND (MR OR MW)"
                           "dm_we = mem_ok AND MW"

WB:
"Writeback MUX" / "w_exec_value or registered dm_dout"
"WB write qualification" / "active, !rst, valid, !fault; RW/ZW/CVW masks"
"flags_reg" / "Architectural Z/C/V; independent masks"
"Stop-token consumption" / "WB valid/fault/HALT tags; orderly drain"
These are parallel functions driven by the appropriate instruction fields. Do not chain Write qualification -> flags_reg -> Stop token. Fault stop tokens work even when normal write qualification is false.

One slim gray control strip INSIDE the core outline, below all five groups:
"Pipeline coordination"
"Load-use holds PC + IF/ID, injects EX bubble; older stages advance"
"Reset > MEM fault > EX fault/HALT > redirect > load-use"
Core input labels "clk / rst" and output labels "halted / fault" may be printed at the border, with no arbitrary wires. Extend the dashed core boundary around the entire composition and this coordination strip. No external CU block.

LOWER REGION: KEY SIGNAL FLOWS, EXPANDED FOR READABILITY
Use flat horizontal labelled rows, not another physical module diagram. Each row is a precise source-to-destination map referring to the modules above. Draw simple left-to-right arrows BETWEEN the specified text endpoints. Do not attach these arrows to unrelated boxes in the upper composition.

Row "Instruction" in teal:
"IF request" -> "IM registered dout" -> "ID decode + PC/valid tags"

Row "Ordinary result" in teal:
"EX ALU result" -> "EX/MEM m_exec_value" -> "MEM pass" -> "WB result select" -> "qualified RF write"

Row "STR value" in orange:
"EX rd_fwd" -> "EX/MEM m_store_data" -> "MEM store port" -> "DM.din"
Short note: "STR address is computed separately by ALU and checked in MEM. No STR data goes to WB."

Row "LDR value" in blue:
"MEM qualified read" -> "DM registered dout" -> "WB load select" -> "qualified RF write"

Compact "Return / control map", using text pairs with correctly directed arrows:
"M ready non-load exec_value -> EX operand_forward"
"W selected wb_data -> EX operand_forward"
"Qualified WB data/address/enable -> ID RF write port and bypass"
"M CMP / W CMP / saved Z -> EX Z selection -> JZ qualification"
"Qualified EX target -> IF pc16"
These are logical connections, not new hardware instances. Do not draw a second RF or memory in these rows.

BOTTOM SAFETY NOTES, SHORT AND READABLE
"Forwarding: eligible ready M > W > captured operand. Newest unready M load blocks old values."
"Eligible: valid, fault-free, register-write intent, matching destination."
"mem_ok: active mode, !rst, valid, !fault, EA in range. MR/MW are read/write intents."
"Successful STR completes in MEM and leaves a WB bubble. Fault STR keeps a valid stop token."
"Data, controls and PC/valid/fault tags stay paired through the pipeline."
"* Registered IM/DM outputs supply the data boundaries. No extra IR/MDR."

Disclosure (verbatim):
"Module-level logical overview based on ISA v1.4 RTL. Not a Vivado RTL Analysis capture."

Accuracy constraints:
No adapters, caches, extra RF, IR/MDR, external standalone CU, register-zero constant, speculative architectural writes, arithmetic-result-dependent branch target, flag-dependent fault token, load-address-as-load-data, unsupported C/V branch instructions, timing/Fmax/board claims, invented ports or fabricated simulation evidence. Keep all arrows confined to the packet-progression ribbon and the explicitly listed flow rows. Each main-stage module card remains UNWIRED, because detailed dependencies are in the signal-flow map. The image must be one coherent overview, not multiple alternative diagrams.
