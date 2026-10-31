# CPU Datapath Lab

## Authorized scope

Extend the existing local CPU datapath artifact into a usable, logically clear interactive web application. Review the previous version first, implement fixes and features, then review the actual final application. Preserve all prior CPU/Pre4 constraints: source-grounded 16-bit ISA v1.4, complete continuous connections, correct arrows, synchronous IM/DM data boundaries, STR separation, forwarding readiness, write qualification and stop-token semantics. English technical labels; Chinese explanatory help is appropriate.

Keep the work local/offline, consistent with the existing delivered local HTML. Do not publish course source/data to an external site. No production RTL or previous PPT edits are required. Current production source and historical VCD receipts are read-only inputs.

## Implementation decisions

- Reuse the latest source-audited optimized graph, all 227 sink connections and 134 nets. Rebuild application behavior and inspection UI around this graph.
- Avoid reusing the hand-authored simplified framework: its long decoder-to-extender arrow visually crosses the RF, and its reduced paths can be mistaken for detailed connectivity.
- User clarified: controllable means clicking every node/net to understand its operation and follow the process. Focus this build on topology exploration and instructional walkthroughs. Do not add a CPU execution/configuration simulator or spend time on waveform playback in this scope.
- One Sonner Toaster at the root; use it for copy/export/error outcomes, not every navigation action.
- Guided route steps include capture qualification and links to source statements. Keep reset/capture gating visible.
- Final review checks source mapping, input invariants, register capture semantics, browser operations, responsive layout, downloadable artifacts, and offline loading. No live simulation or waveform replay is implemented in this scope.

## Review findings before implementation

The current enhanced legacy UI passed its existing automated tests. Source review nevertheless found: the simplified overview uses a decoder-to-extender path through the RF rectangle; IF/ID PC continuation omitted its capture-enable explanation in the newer runtime; tab changes could change only the active tab without rendering the corresponding panel; instructional steps were mixed with global Back history; SVG export could retain dimmed/highlight state and display emphasis. Existing tests did not establish correctness of these behaviors.

Use the explicit user-requested ask-matt flow for local implementation and final review. Its issue-tracker setup is not required for this file-bound task; no tracker or external task coordination is in scope.

## Readability revision — 2026-10-11

The user explicitly requested removal of the floating introduction and irrelevant corner microtext, larger typography and more comfortable layout. Preserve the already audited geometry and continuous connections. Remove only page/print-sheet decorative microtext, not signal endpoints or source-grounded explanations. Default to a readable PC view; Overview is navigation with concise labels, and all drawn/listed module clicks focus the selected block. Focused port labels remain at least 15 px. On small screens, align to the module's top/input side and allow panning instead of shrinking the whole block into illegibility. Do not add busy animations to repeated navigation.

The published HTML and source archive are refreshed in place after hash checks and a recoverable backup. Keep the original standalone audited SVG and production RTL unchanged. Review status remains produced/reviewed, not user-validated.

## Selection-focus revision — 2026-10-11

The user requested a complete re-review first, then stronger focus when selecting any module or wire: dim every uninvolved module so relevant parts stand out. The preceding revision passed its 66 existing checks before modification. Its low-detail override kept all nodes opaque, and its node-focus algorithm promoted all co-receivers of shared inputs; both conflict with this new goal.

Use one `selectionFocus` interface for canvas and minimap. Node selection highlights the chosen node, direct input drivers and direct output receivers, without recursively following the graph or lighting all other consumers of clock/reset. Preserve entire incident nets: this is an emphasis change, not a cut in topology. Explicit net selection always highlights its true source and complete fanout, including when the selected net is clock or reset. Inactive nodes remain visible/clickable at reduced opacity. A distinct selected-node outline and a minimum visible net stroke in overview provide clear focus without new animations, onboarding clutter or navigation toasts.

Clear, Back, source inspection, next-Q traversal, instruction steps, session import and SVG export must retain their earlier behavior. Full SVG export removes all transient focus classes. Do not modify RTL, ISA or production schematic geometry.
