# Datapath Lab

Offline, source-grounded interactive website for the course's 16-bit CPU, ISA v1.4. The primary use is to click any drawn module or signal and understand its function and next connection. The application does not execute a CPU program or claim to replay a new simulation.

## Use

Open the delivered `index.html` in a browser. It is a single self-contained file: React, Sonner, the full SVG, source excerpts and model data are embedded. No network connection or server is required.

- The page opens at a readable PC view. Common text is 15–16 px, and explicit module focus keeps port labels at least 15 px on screen.
- Click a module: automatically focus it, then read its purpose, working rules, input/output lists and line-numbered RTL.
- Module focus gives the chosen block a distinct outline, keeps its direct input sources/output receivers bright, and dims unrelated blocks. Other loads sharing an input (including clock/reset) are not mistaken for this block's downstream logic.
- Overview is for navigation: compact module names replace unreadable microscopic port labels. Click a block to restore complete detail. All wires remain present in either view.
- Click a wire: complete fanout, source, all sinks and register continuations. Every actual endpoint stays bright; unrelated blocks fade, including in the minimap. In overview, the selected wire keeps a visible 1.6 px screen stroke.
- Faded blocks remain clickable. `Clear` leaves selection focus; Back and imported progress restore it. No routine selection notification is shown.
- `只定位` keeps the selected signal while moving the camera. Opening the module changes the inspector.
- `Next Q` shows the exact captured expression first. IF/ID PC capture enable and reset precedence remain explicit.
- Walkthroughs cover STR, LDR, ADD, CMP/JZ, load-use and fault STR. Example values are instructional, not live trace values. A step is not a clock cycle.
- Back, fit, minimap, bookmarks, keyboard navigation, complete SVG export and exploration-state JSON save/restore are supported.
- On narrow screens, switch between browse/canvas/inspector. Pan across a wide or tall module rather than shrinking its text to fit; module focus aligns its title and input side visibly.

The UI describes the exact existing graph: 37 blocks/groups, 134 driven nets, 227 sink connections. Inline control is grouped into functional blocks; the diagram is not a bit-level gate netlist. Same-name labels do not replace continuous wires.

## Rebuild from source archive

The source archive contains `data/model.json` and `data/schematic.svg` snapshots, so the offline HTML can be rebuilt without the original course checkout:

```powershell
pnpm install --ignore-scripts
pnpm exec tsc --noEmit
pnpm run build
```

Output: `dist/index.html` and `dist/Datapath_Continuous.svg`.

`prepare.mjs` is the original-host data preparation step. It reads the previous audited graph and current production RTL under the documented Windows paths, verifies 13 source hashes and generates source excerpts. Run it only when those source folders are available. Browser test scripts use the Codex-bundled Playwright runtime and installed Chrome on this host. No credentials are needed.

## Verification boundary

Final verification includes TypeScript checking, 11 model/source checks, 32 functional browser checks, 26 readability/responsive checks and 19 selection-focus checks (88 total). Every module explanation and every net's sink list is traversed. All 37 drawn nodes are clicked from the overview, including while dimmed, to verify focus, zoom and font size. The focus suite checks all 134 nets against their real sources/receivers. Tests compare every circuit geometric element with the audited SVG, and exercise register continuation, keyboard walkthroughs, file exports/imports, offline requests, nine viewport widths and hidden-canvas restoration. Source excerpts are freshly compared against current local RTL. No production RTL, prior PPT or CPU behavior was modified.

## Skills applied

ask-matt routed the existing-code task to local implementation and final review. Sonner is mounted once at the application root and is used only for action feedback, at 15 px; ordinary browsing remains silent. Test-first checks reproduced the missing dimming before the fix, and one shared selection rule keeps canvas/minimap emphasis consistent. The design-engineering review informed readable defaults, restrained wire emphasis and immediate navigation. The workflow stays local; no hosted site or external publication is created.
