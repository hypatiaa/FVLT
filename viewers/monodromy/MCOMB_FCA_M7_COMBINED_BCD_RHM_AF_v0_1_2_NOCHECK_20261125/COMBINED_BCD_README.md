# Combined B/C/D viewer v0.1 (candidate, unsealed)

2026-10-01. Idea: saphir. Specifications, corrections and audits: Astra. Build and checks: combined builder (Claude), under handoff `COMBINED_BCD_VIEWER_HANDOFF_v0_2_1_20261001` (MANIFEST `4715910c…`).

**Standing: builder candidate for the oversight re-run and Astra's integration audit.** Not accepted, sealed or seated. The individual panel passes do not establish a combined pass.

## What it is

The frozen Basel host link v0.1.2 (`MCOMB_FCA_M7_BASEL_LINK_v0_1_2_20260928`, viewer `3ff3e3c5…9650`) plus three blocks immediately before `</body>`, in the order B, C, D:

| Block markers | Panel | Accepted standalone |
|---|---|---|
| `COMBINED_BCD_V0_1_RECIPROCAL_BEGIN/END` | B: reciprocal record readout | `MCOMB_FCA_M7_RECIPROCAL_LINK_v0_1_20260929` |
| `COMBINED_BCD_V0_1_SHELL_PRIME_COUNT_BEGIN/END` | C: shell prime-count readout | `MCOMB_FCA_M7_SHELL_PRIME_COUNT_v0_1_1_20260930` |
| `COMBINED_BCD_V0_1_TOOTH_CONTACT_BEGIN/END` | D: per-tooth contact panel | `MCOMB_FCA_M7_TOOTH_CONTACT_v0_1_3_20260930` |

Each block is its accepted builder's assembly, byte for byte, with only the markers and the build-pins line replaced. The module files beside the viewer are byte copies of the accepted modules. Removing all three blocks (markers inclusive, plus one LF each) restores the frozen viewer.

The DOM order is Basel, then D, C, B (`#bz-panel`, `#tc-panel`, `#spc-panel`, `#rr-panel`), because each UI module inserts itself directly after the Basel panel.

## Differences from the frozen Basel package

- `monodromy-31-linked-reduction.html`: the three blocks.
- `BUILD_PINS.json`: new `viewerSha256`; `localBridge["server.cjs"]` = `20caf539…`; top-level `serverSha256`; new sections `combined`, `reciprocalLinkCombined`, `shellPrimeCountCombined`, `toothContactCombined`. Every inherited section is otherwise unchanged.
- `server.cjs`: the repaired `/assess` server (`20caf5398cef57f988700adc27c8cdbe49dbe538d7e570ebfa482926d8424311`), byte-identical to `ASSESS_SERVER_REPAIR_v0_1_20260930/server.cjs`. Its comment refers to `TESTS.md`; read `SERVER_NOTE.md`, which points to the repair `REPORT.md`.
- Added: the nine module files, `SERVER_NOTE.md`, this README, and the package's own `MANIFEST.sha256`.

The inherited `seal.cjs` compares `server.cjs` with an older baseline and so no longer matches; it is provenance of the earlier seal and is not run by the launcher or the server.

## Identity

- Combined identity (`MCOMB_FCA_M7_COMBINED_BCD_HOST_IDENTITY_V1`): `BUILD_PINS.combined.combinedIdentity`.
- Per-panel identities: `McombReciprocalLinkBuildPins`, `McombShellPrimeCountBuildPins`, `McombToothContactBuildPins` (`hostSha256`), each its accepted schema with `build`, `version` and an added `combinedIdentity` changed.
- The viewer-file digest appears only in `BUILD_PINS.viewerSha256`, the MANIFEST and the report.

## Use

`launch.ps1` (or `node server.cjs`) serves the viewer on an ephemeral 127.0.0.1 port. Opening the HTML file directly also works for the panels; `/assess` needs the server.

The builder's checks and report are in `COMBINED_BCD_WORK_v0_1_20261001/`.
