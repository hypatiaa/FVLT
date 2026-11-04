# FF-3 final audit v0.1: PASS

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "you're on". This is the final audit routed in bus #1552, and the final-PASS condition of `FF3_FREEZE_DECISION_v0_1.md` (`9e7d01b9...`, #1511).

**Outcome: FF-3 PASS.** All 37 frozen statements are proved in Lean 4.35.0 against library v22, using only `propext`, `Classical.choice` and `Quot.sound`. Each one states what WORK_ORDER v0.2 asks for. The map is discrete, on lifted data, from rosette addresses to Ford circles, with exact rational certificates on tangent edges.

## 1. Closed source packet (read-only checks by script)

- **`final_source_packet_v0_1/`:**
  - manifest `2b4ac17a...`, with all **99 of 99** entries re-hashing correctly;
  - comparison `33a3c637...`;
  - check index `0bd4e836...`.
- **Sources:**

  | Module | SHA-256 | Note |
  |---|---|---|
  | Data | `02814fa1...` | byte-identical to the accepted repaired definitions, #1517 |
  | Phase | `2a48f1c6...` | CRLF line endings, kept as delivered |
  | Arithmetic | `f74e1a1d...` | |
  | Sweep | `1d982d2e...` | |
  | Endpoints | `53ea5f08...` | CRLF line endings, kept as delivered |

- **Statement comparison** with `SKELETON_FF3_HEADER_COMPARE_v0_2.cjs`. This successor of the FF-2 script strips CR and handles statements containing `let ... :=`. Results:
  - **37 of 37** public theorems, all distinct, each identical to the frozen headers `b8a052dc...`, with none missing;
  - 8 private helpers;
  - no public non-theorems;
  - no `sorry`, `admit`, `axiom`, `unsafe` or `extern`.

## 2. Independent rebuild on nucleus

- **Setup:**
  - folder `~/skeleton_audit/ff3_final_20261104/`, starting from an empty `build/`;
  - my own runner `SKELETON_FINAL_AUDIT/run_ff3_final_audit.sh` (`9d5f0c99...`);
  - my own axiom file `SkeletonAuditFF3.lean` (`89d0fb2d...`), naming the 37 targets taken from the frozen headers and the 19 data declarations;
  - checker `9c6f2ac1...`, Lean `bf8d54e4...`, and library v22, which is the latest, with checksums at 0 failures before and after;
  - template limits: one CPU, nice 19, 8 GiB, `-j1 -s65536 -M7680 -D Elab.async=false`, and 240 s per call.
- **Order:** Data, Phase, Arithmetic, Endpoints, Sweep.

| Module | Compile | Strict replay |
|---|---|---|
| FVLTRosetteFordDataV1 | exit 0, empty log | PASS 64/64, kernel completed, 0 fail/unsafe/partial |
| FVLTRosetteFordPhaseV1 | exit 0, warnings only | PASS 9/9 |
| FVLTRosetteFordArithmeticV1 | exit 0, warnings only | PASS 31/31 |
| FVLTRosetteFordEndpointsV1 | exit 0, empty log | PASS 13/13 |
| FVLTRosetteFordSweepV1 | exit 0, warnings only | PASS 44/44 |

- **Totals:** 161 introduced constants replayed, with no `sorry` in any log. Imported FF-1 modules and Mathlib are reused, not replayed. The only axioms are the standard three.
- **Named axioms** (my own file, log `5a4ff70c...`): 56 lines, every one using only the standard three.
- **Integrity:** sources unchanged, and the library intact.
- **Reproducibility:** all five replay logs are byte-identical to the producer's final replay logs.

## 3. Independent statement fidelity

- **Reviewer:** a separate subagent (Claude Opus), spawned with a closed file list. It ran no Lean, used no network and posted nothing.
- **Signoff:** `FIDELITY_REVIEW_v0_1/FIDELITY_SIGNOFF_v0_1.json` (`abbf810a...`) and `.md` (`4ccb739a...`). Parsed by script:
  - **37 of 37 targets MATCH**;
  - **19 of 19 definitions MATCH**;
  - no other verdicts.
- **Its own mirror check:** 939,644 checks, 0 failures. This is finite evidence, not proof. Its 7 negative controls all fail as they should, including the r = 0 and s < 0 guards, which shows those guards are needed.
- **Advisories, none a defect:**
  - the local `IsIntegral` shares a name with Mathlib's root `IsIntegral`. The meaning is unchanged, but a file that opens this namespace may see an ambiguity;
  - a few guards are unneeded but harmless: `hn3` in the phase statements, `1 ≤ B` in the sweep membership statements, and `hk0`;
  - `EdgeKind.gap` is the order's "break";
  - `liftedPhasor` is defined but no statement uses it.

## 4. Standing and limits

- **Proved:**
  - the phase law, including its integer-spin parity specialization and the M3 non-descent example;
  - P1 to P4 in multiplication form, including the signed column with `|u|`, the stall and the s = 1 spine;
  - the P5 shell sweep: its events, the deduplicated set equal to F_B, and consecutive determinant 1, proved directly without Lemma 6a;
  - the P6 edge trichotomy, with exact rational kiss-point certificates on tangent edges.
- **Not claimed:**
  - oriented or continuous arcs;
  - recovering an address from an unlabelled phasor;
  - any register identification;
  - any factoring advantage;
  - viewer work.
- **Not done here:** no kernel adoption, commit or release.
- **Kernel §9.4 row.** It may now get an Idea Catalog correction candidate that describes exactly this construction. That goes through review; there is no automatic adoption.
- **Library sync:** v23 follows under saphir's standing rule.

Credit: the question of the map, the rosette and the instruments: saphir. "The framework was assembled by Robin Miller; its components are classical results of others."
