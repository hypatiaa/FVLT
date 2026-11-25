# Combined B/C/D viewer + G. Robin margin panel v0.1 (candidate, unsealed)

2026-10-01. Idea: saphir. Criteria mapping: Opus. Specifications, corrections and audits: Astra. Handoff: fable (Claude). Build and checks: RH margin builder (Claude), under handoff `RH_MARGIN_PANEL_HANDOFF_v0_1_1_20261001` (MANIFEST `33d5e758…`).

**Standing: builder candidate for the verifier, the orchestrator and Astra's audit.** Not accepted, sealed or seated. Stage 2 (the step ledger) is not in this package.

## What it is

The combined B/C/D viewer v0.1 (`MCOMB_FCA_M7_COMBINED_BCD_v0_1_20261001`, viewer `3cd1352f…da9c`) plus one block, `<!-- RH_MARGIN_V0_1_BEGIN -->` … `<!-- RH_MARGIN_V0_1_END -->`, immediately before `</body>`, after the three existing blocks. Removing that block (markers inclusive, plus its one LF) restores `3cd1352f…da9c` byte for byte.

The block holds `window.McombRhMarginBuildPins`, the embedded worker source `window.McombRhMarginWorkerSourceV1` (`rhm-core.js` + LF + `rhm-worker.js`), then `rhm-core.js` (a BigInt port of the accepted reference `rh-criteria-readout` 0.1.0, `build_atom` path) and `rhm-ui.js` (the panel). The record is built in an embedded Web Worker (message prefix `rhm/`), with epoch and stale-result rejection, because a cold build exceeded 50 ms on the main thread.

The panel opens with the micro-button **G. Robin margin**. It sits after `#rr-panel`, so the panel order is Basel, D, C, B, RH (`#bz-panel`, `#tc-panel`, `#spc-panel`, `#rr-panel`, `#rhm-panel`). For the host's shell base B it shows the `rh_atom_margins` record: σ(B)/B against the certified enclosure of e^γ ln ln B (G. Robin (1984) criterion), B/φ(B) for the Nicolas (1983) primorial criterion, the constants, and a display-only per-prime factor table. The margin is value minus threshold. It exports the record's canonical bytes with `source.host_build` = this package's name and `source.host_sha256` = `BUILD_PINS.rhMargin.hostSha256`.

Finite value of an RH-equivalent quantity. Finitely many satisfied cases do not establish RH; a certified violation inside a criterion's quantified range would refute RH. No counterexample search is performed.

## Differences from the combined package

- `monodromy-31-linked-reduction.html`: the one block.
- `BUILD_PINS.json`: new `viewerSha256`; new section `rhMargin`. Every other section is unchanged.
- Added: `rhm-core.js`, `rhm-worker.js`, `rhm-ui.js`, this README, and the package's own `MANIFEST.sha256`.

## Use

Opening the HTML file directly works (`file://`). `launch.ps1` (or `node server.cjs`) serves it on an ephemeral 127.0.0.1 port. The live controls reach direct bases 2 to 6,227,020,800 and factorial indices 3 to 13; B = 1 is not reachable in the host.

The builder's checks and report are in `RH_MARGIN_PANEL_WORK_v0_1_20261001/`.
