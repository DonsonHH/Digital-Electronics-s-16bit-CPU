# Final review — 2026-10-11

Status: produced, source-reviewed and browser-tested; user acceptance pending.

## Previous version review

The previous enhanced page's tests passed, but its manually drawn framework contained misleading relationships: a decoder-to-extender line visually traversed RF, RF outputs bypassed forwarding in some drawn paths, immediate/PC inputs were combined imprecisely, and a second RF-looking WB box obscured the single shared RF. The new app uses the single audited continuous graph throughout.

Other corrected behaviors: the newer legacy capture inspector omitted d_pc's fetch_accept requirement; tab changes could mark a tab active without rendering its panel; diagram export could retain temporary visual emphasis; guide history and free exploration state were mixed. The new app gives explicit selection/history/guide state, source-grounded capture rules and clean full-diagram export.

## New implementation review and repairs

- Each of the 37 drawn nodes now has a reviewed purpose, operation notes and source excerpt. Each of the 134 nets exposes one driver and all sink endpoints.
- 54 register D/Q mappings remain source-bound; qualified expressions and enabled d_pc capture are displayed before continuing.
- All six walkthroughs (32 steps) point to a real graph source or sink. Values remain explicitly teaching examples; the app is not a simulator.
- Actual canvas node and wire clicks are exercised, not just internal selection calls. Search handles aliases, bounded bit ranges, exact modules and instruction routes.
- Camera updates do not rebuild the inspector. Pending camera focus survives the canvas being hidden on mobile. Keyboard guide navigation, Back, fit, minimap and pointer cancellation are covered by implementation and representative interactions.
- One root Sonner toaster supplies success/error feedback. No notifications are emitted for routine browsing.
- SVG export clears transient selection and emphasis while preserving every net. Session import validates version, CPU source identity, selection, guide step and finite camera bounds before changing state.
- Modal background is inert with focus containment and Escape dismissal. Layout checked at desktop, 1100 px, 760 px and 480 px widths.

## Evidence

- TypeScript check passes.
- `review/model-tests.json`: 8 model/source checks pass, including 13 current RTL hashes and exact source excerpts.
- `review/web-tests.json`: 32 browser checks pass, including all 37 explanations and 134 sink lists, file exports/imports and zero external network dependency.
- `review/01-overview.png` through `review/07-phone.png` plus `review/mobile-final.png`: rendered visual review.

The old page is backed up before replacing its entry with the reviewed application. Existing SVG/PNG artifacts and production RTL are preserved. The detailed graph remains a grouped RTL architecture, not a native EDA capture or a new simulation/formal proof.

## Readability revision and final re-review

| Before | After | Why |
| --- | --- | --- |
| Floating “顺着一条线” card covers the drawing | Card removed, along with corner counters, redundant subtitles and print-sheet microtext | Keep the drawing unobstructed |
| Common UI text at 9–13 px | Body 16 px; most controls/ports 14–16 px; roomier side panels | Improve reading comfort without browser zoom |
| Whole-sheet fit opens with tiny port text | Readable PC view by default; overview uses measured compact module labels | Separate navigation from detailed reading |
| Clicking the canvas only highlights a node | All 37 nodes focus at a readable scale when clicked | Make clicking useful immediately |
| Heavy selected wires at close zoom | Restrained signal strokes, same physical path and arrow geometry | Reduce visual weight without changing meaning |
| View resize could shrink focused text | Preserve readable module framing on resize | Avoid returning to a miniature diagram |
| Wide modules lose their title on phones | Align title/input side; retain pan for the rest | Prefer readable detail over fitting unreadable content |

During the actual render review, three overview labels overflowed their boxes. The final implementation measures their real SVG text widths instead of estimating from character count. A second review fixed stale pending module focus overriding a hidden-canvas restore, and blocked zoom shortcuts from corrupting a hidden canvas's coordinates.

Final verification for this revision:

- TypeScript passes; 8 model/source checks, 32 browser-functional checks and 26 readability checks pass (66 total).
- All 37 actual canvas node clicks select and zoom correctly. Minimum focused port text in the tested desktop layouts: 15.64 px. Body text: 16 px.
- All 134 nets / 227 sink endpoints and all geometric elements match the existing audited graph. The 54 register continuation rules and 13 production RTL source hashes remain intact.
- Widths 1920, 1536, 1366, 1100, 900, 820, 760, 480 and 375 px have no page-level horizontal overflow. This is browser viewport testing, not a claim of physical-device testing.
- `review/readability/01-default-pc.png` through `10-phone-circuit.png` are the new visual-review evidence. Existing earlier screenshots are historical, not this revision.
- Exported SVG strips temporary navigation labels and emphasis and retains all nets. Offline operation, guide steps, source tabs, bookmarks, import/export and modal keyboard behavior remain covered.

The original standalone SVG, source model, CPU RTL and PPT are not rewritten. This is a webpage readability/interaction change, not a new CPU verification run. No new external publication or computer sleep action is performed.

## Selection-focus revision and complete review — 2026-10-11

Before changing the UI, the previous build's typecheck and all 66 existing checks were rerun successfully. The production HTML hash matched the previous delivery record. Baseline receipts are preserved under `review/focus_baseline_20261011/`.

| Before | After | Why |
| --- | --- | --- |
| Overview CSS forced every block to full opacity | Unrelated blocks use 18% opacity and grayscale at every zoom | Keep attention on the selected relationship |
| Node selection expanded through shared input fanout | Selected module plus direct drivers and receivers only | RF and DM sharing a clock does not make DM part of RF's own downstream logic |
| No separate cue for the chosen block | Distinct 2.4 px screen-space outline | Separate the chosen module from its relevant neighbors |
| Minimap stayed equally bright everywhere | Minimap shares the same focus rule as the canvas | Keep the navigation view consistent |
| Selected net was about 0.4 px at overview scale | Selected net remains 1.6 px in overview | Make the complete route visually traceable |

The first browser check reproduced the RF/DM issue: both had opacity 1, including in overview. The repaired build leaves RF at 1 and unrelated DM at 0.18. Explicitly selecting `clk` still highlights both as real clock receivers. All incident signal geometry stays intact even where node emphasis is narrower than a shared input's full fanout.

Final checks: TypeScript passes; **11 model/source + 32 browser-functional + 26 readability + 19 focus checks = 88 checks**, all passing. In particular:

- Real canvas clicks traverse all 37 blocks, including dimmed ones. Focused modules and direct neighbors exactly match the graph.
- All 134 net selections preserve their complete source/fanout and dim every unrelated block. Actual wire-click behavior is separately exercised.
- Overview, readable zoom, minimap, wire emphasis, only-locate, Back, instruction guides, Clear, save/import and reduced-motion mode retain consistent selection state.
- SVG export contains all 37 blocks and 134 nets, with no selected/picked/net-selection/temporary label classes.
- Sonner has one root mount, produces no ordinary-navigation toasts, and still supplies action feedback. Its empty list is not rendered until there is a toast; tests account for that library behavior.
- Existing graph geometry, 227 sink connections, 54 register capture rules and 13 RTL file hashes are unchanged. No new hardware simulation or formal proof is claimed.

Visual evidence: `review/focus/01-rf-overview.png`, `02-wb-data-overview.png`, `03-cleared-overview.png`, `04-narrow-selected.png`, plus refreshed general view captures. The user-facing HTML and old entry are refreshed only after prior hashes are checked and a backup is made. User acceptance is still pending.
