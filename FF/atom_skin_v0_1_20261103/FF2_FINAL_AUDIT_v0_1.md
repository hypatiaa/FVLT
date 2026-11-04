# FF-2 final audit v0.1: PASS

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "Yes, start it" for the final audit routed in bus #1505. This is the final-PASS step required by condition 5 of `FF2_FREEZE_DECISION_v0_1.md` (`3a525076...`, #1448): my own recompile and strict replay on nucleus, plus an independent statement-fidelity review.

**Outcome: FF-2 PASS. All 28 frozen statements are proved in Lean 4.35.0 against library v20, using only `propext`, `Classical.choice` and `Quot.sound`. Each states what WORK_ORDER_v0_3 asks for.**

## 1. Producer packet (read-only checks by script)

- The closed packet `batch07/producer_complete_v0_1/` contains:
  - result `8d86d71a...`;
  - manifest `7b658a10...`, with all **334 of 334** entries re-hashing correctly;
  - new-theorems list `e381a87e...`;
  - audit handoff `91f1f6f9...`.
- **Sources:**

  | Module | SHA-256 |
  |---|---|
  | AtomSkinData | `8d165af9...` |
  | AtomSkinCounts | `57be3051...` |
  | AtomSkinPen | `62be605e...` |
  | PillowcaseData | `b8a03b38...` |
  | Pillowcase | `27e7c00d...` |

- **Statement comparison** with script `SKELETON_FF2_HEADER_COMPARE_v0_1.cjs` (`a4949a61...`):
  - 28 public theorems, all distinct, each **byte-identical** to the frozen headers `b4484f6e...`;
  - 98 helpers, all private;
  - no public non-theorem declarations;
  - no `sorry`, `admit`, `axiom`, `unsafe` or `extern`.
- **Data modules:** AtomSkinV1 equals the accepted repair `a1ea047d...` (`REPAIR_DECISION_v0_1.md`, `d6a666bd...`). PillowcaseV1 equals the original freeze `61ca7137...`.

## 2. Independent rebuild on nucleus

- **Setup:**
  - folder `~/skeleton_audit/ff2_final_20261104/`, starting from an empty `build/`;
  - my own runner `SKELETON_FINAL_AUDIT/run_ff2_final_audit.sh` (`c98e4983...`) and my own axiom file `SkeletonAuditFF2.lean` (`2ec4a335...`), which names the 28 targets; the name list was diffed against the freeze by script;
  - the pinned checker `IndependentFVLTReplay435.lean` (`9c6f2ac1...`), Lean `bf8d54e4...`, and library v20, still the latest, with pins `a2933a5c...`, `4e318f9b...`, `1f0e0c1c...` and `ca5f1f60...`;
  - `LEAN_PATH` is the new build plus the v20 library and Mathlib only. No producer objects were used.
  - template limits: one CPU, nice 19, 8 GiB, `-j1 -s65536 -M7680 -D Elab.async=false`, and 240 s per call.
- **Attempt 1** (logs kept in `SKELETON_FINAL_AUDIT/logs_attempt1_harness_path_bug/`) failed before any Lean call. My runner used a relative log path inside `src/`. I fixed the path and reran from the still-empty build.

**Results (attempt 2), logs in `SKELETON_FINAL_AUDIT/logs/`:**

| Module | Compile | Strict replay |
|---|---|---|
| FVLTAtomSkinDataV1 | exit 0, empty log | PASS 53/53, kernel completed, 0 fail/unsafe/partial |
| FVLTAtomSkinCountsV1 | exit 0, warnings only | PASS 100/100, kernel completed, 0 fail/unsafe/partial |
| FVLTAtomSkinPenV1 | exit 0, warnings only | PASS 87/87, kernel completed, 0 fail/unsafe/partial |
| FVLTPillowcaseDataV1 | exit 0, empty log | PASS 55/55, kernel completed, 0 fail/unsafe/partial |
| FVLTPillowcaseV1 | exit 0, warnings only | PASS 119/119, kernel completed, 0 fail/unsafe/partial |

- **Totals:** 414 introduced constants replayed. Imported Mathlib is reused, not replayed. Across all constants the only axioms are `propext`, `Classical.choice` and `Quot.sound`.
- **Named axioms** (my own file, log `37e9ba24...`): all 28 targets depend only on the standard three. Five pillowcase statements use only `propext` and `Quot.sound`.
- **Warnings:**
  - no `sorry` anywhere;
  - only linter messages: deprecated `if_pos`/`if_neg`, unused simp arguments, a `<;>` style note, and unused binders `hω`, `ha`, `hb`, `hm`.
  - The unused binders are frozen hypotheses that the proofs don't need. Each statement still carries its guard, so none is stated more generally than frozen. The fidelity review treats the guards as harmless.
- **Integrity:**
  - library checksums: 0 failures before and 0 after;
  - sources unchanged after the run;
  - the five replay logs are byte-identical to the producer's final replay logs (`094986ba...`, `f7bf0e12...`, `7502783b...`, `d042a050...`, `e46e7b4b...`).
- **Objects:**
  - the data objects equal the producer's (`5d7862ee...` and `6b656127...`);
  - the three proof objects differ from the producer's;
  - as in FF-1, object byte equality is informational, not a requirement.

## 3. Independent statement fidelity

- **Reviewer:** a separate subagent (Claude Opus), spawned with a closed file list. It ran no Lean, used no network and posted nothing.
- **Signoff:** `FIDELITY_REVIEW_v0_1/FIDELITY_SIGNOFF_v0_1.json` (`63831157...`) and `.md` (`4956f950...`). Parsed by script:
  - **28 of 28 targets MATCH**;
  - **21 of 21 definitions MATCH**;
  - no other verdicts.
- **Mirror check:** the reviewer's own script, `mirror_check_v0_1.cjs` (`82c71d6f...`):
  - 2,153,901 checks, 0 failures;
  - covers ω = 3..9 and pillowcase grids a, b ≤ 6;
  - negative controls behave as expected: dropping ε(v) breaks A4, and flipping the pen's sense fails in every state;
  - this is finite evidence, not proof.
- **Scope notes inside MATCH:**
  - `link_cycle` is stated as an adjacency relation; multiplicity one follows from A2, and the finite check confirms it.
  - The B2 stabilizer is read through the order's own gloss; no group object is defined.
  - `fixingHalfTurn_iff_multiples` is a supporting statement the order does not list by name.
  - `boundary` and `coefficient` are noncomputable, so they cannot be evaluated as certificates.
  - The pen template file was outside the reviewer's closed file list. `step` and `key` were checked against the order's prose.
  - A cosmetic leftover comment remains in the data sources.

## 4. Standing and limits

- **What FF-2 proves.** It proves exact combinatorial and numerical statements:
  - counts and the Euler characteristic;
  - the numerical genus formula;
  - incidence and boundary cancellation;
  - the cube graph and the link at each vertex;
  - the pen laws for a fixed sign from a full state;
  - the pillowcase key classification and the corner classes.
- **What it does not claim:**
  - no surface realization or topological classification;
  - nothing about pen behaviour under arbitrary signs, and nothing that forces Rule 30 periodicity;
  - no certification of viewer implementations;
  - no kernel adoption.
- **Not done here:** no library sync, commit, publication or kernel change. Each needs its own decision.
- **FF-3 builds** may proceed now that FF-2 has a recorded outcome, under FF-3's own gates.

Credit: the framework was assembled by Robin Miller; its components are classical results of others.
