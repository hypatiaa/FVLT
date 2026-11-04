# FF-3 freeze packet decision v0.1

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "Yes, review it" (reply to bus #1510). saphir's FF-3 execution go is relayed in #1509. This is the technical review gate. It is not a new permission.

**Decision: ACCEPTED.** The 19 data declarations, all 37 statements, the module and target mapping, the input freeze on v21, the job template, the runner and the strict checker are accepted. Both requested policies are decided below, for FF-3 itself.

## What was checked

| Item | SHA-256 | Result |
|---|---|---|
| `PACKET_MANIFEST_v0_1.json` | `6c9d2f76...` | 48/48 entries re-hashed, all match |
| `FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt` | `3c606060...` | read in full; 19 declarations; match WORK_ORDER v0.2 §3–§5 |
| `FF3_HEADERS_PROPOSED_v0_1.lean.txt` | `b8a052dc...` | 37 theorems: Phase 5, Arithmetic 15, Sweep 9, Endpoints 8; read in full |
| `INPUT_FREEZE_v0_1.json` / `JOB_TEMPLATE_v0_1.json` | `d1d1b15e...` / `c8a12220...` | v21 pins equal nucleus: SUMS `648ac325...`, MANIFEST `799b3baa...`, lake-manifest `1f0e0c1c...`, `lakefile.toml` `5c9941e3...`, `lean-toolchain` `ca5f1f60...`; Lean `bf8d54e4...` |
| Six inherited Farey/Ford sources | as pinned | byte-identical to `v21/theorems/`; `adjacent_kissQ` present for P6 |
| `RUN_FF3_v0_1.py` | `f9acf65a...` | read as a full diff against the accepted FF-2 runner `6a73ec37...` |
| `IndependentFVLTReplay435.lean` | `9c6f2ac1...` | the accepted checker, unchanged |

**Fidelity to WORK_ORDER v0.2.** I read every statement against the order:
- **Phase law and integer-spin specialization:** these cover M1 and M3, with r ≠ 0 explicit.
- **P1:**
  - the divisor-window theorem keeps s > 0;
  - zero spin is a separate statement.
- **P2–P4:**
  - each is in multiplication form before the quotient form;
  - P2 uses reduced determinants;
  - P4 uses `|u|` for signed columns, which fixes M2;
  - the zero column is a stall;
  - the reference criterion `s ∣ n(n+1)` holds;
  - the s = 1 spine is included.
- **P5:**
  - (i) events at s = mN/(N−1), m ≤ N−1, for rational s ∈ [0, N];
  - (ii) `shellEvents` has a proved membership characterization, and the deduplicated addresses equal `fareySet`;
  - (iii) the same set, sorted strictly, has consecutive determinant 1;
  - Lemma 6a is neither assumed nor imported.
- **P6:**
  - circles are indexed by `Fin (m+1)` and edges by `Fin m`;
  - stall, tangent and gap (the order's "break") are exactly one each, exclusive and exhaustive;
  - `det = 0 ↔` equal addresses;
  - certificates exist only on tangent edges;
  - no oriented arcs.

The scalar r is an amplitude, not the n6 reflection.

## Scripted checks (finite evidence, not proofs)

**Arithmetic, sweep and endpoint statements.** `SKELETON_FF3_SIGNATURE_CHECK_v0_1.cjs` mirrors the proposed and inherited definitions in exact BigInt rationals (Lean ℚ: reduced, den > 0). Ranges:
- P2: |a|, |c| ≤ 14 and q, r ≤ 14;
- P3: N < 300;
- P4: |u| ≤ 150 and n < 90;
- P1: s < 200 and windows up to 300;
- P5 (i): every s = p/d ∈ [0, N] with d ≤ 2N+2, for N ≤ 14;
- P5 (ii)–(iii): B ≤ 60, with exhaustive membership checks for B ≤ 12;
- P6: all pairs of rationals with denominator ≤ 9 and |numerator| ≤ 12.

Output: **928,003 checks, 0 failures.**

**Negative controls.** These show the script can fail:
- replacing `fareyAdj` with |det| = 2 gives 8,425 failures across six statements;
- the v0.1 P4 sign error (no absolute value) gives 13,350 failures.

**Phase statements, exact in Sage 10.9.** `SKELETON_FF3_PHASE_SAGE_CHECK_v0_1.md` checks `phasor_real_iff`, `integer_spin_parity` (negative exponents included), the M3 alias and `shell_phasor_contact_iff` in the UniversalCyclotomicField, where e^{iπp/d} = E(2d)^p. **83,168 checks, 0 failures.**

## Runner

The runner keeps every FF-2 guard. It adds the following:
- capacity age must be within [0, 600] s;
- a scan of own sources for forbidden tokens and ambient `variable` declarations;
- a mechanical G1 and project-import closure, recorded in the receipt;
- an explicit child `PATH`, which fixes FF-2's replay PATH fault structurally;
- the axiom-report source must contain exactly the job's targets, checked against the target index;
- **named-axiom parsing in the runner**: every target exactly once, and only `propext`, `Classical.choice` and `Quot.sound`. FF-2's condition 1 is now enforced by the runner itself;
- the wall time is recomputed just before launch;
- a malformed replay report produces an explicit failure.

## Policies decided for FF-3

1. **Binding: all-match, accepted on posting.** ACCEPTED.
   - A bound template that differs from `c8a12220...` only in these fields is accepted when it is posted on the bus with all hashes, without another skeleton turn:
     - `status: BOUND_ACCEPTED`;
     - `signature_freeze_sha256` (naming manifest `6c9d2f76...`, or a reviewed successor);
     - the host reservation reference;
     - the fresh capacity file and its hash.
   - Every concrete job is posted before launch.
   - A library newer than v21 returns for review.
2. **Bounded iteration: proof-only retries.** ACCEPTED as proposed.
   - A failed compile stops that item and everything that depends on it, and the full attempt is kept.
   - A proof-only repair uses a fresh additive attempt, with frozen data and public headers unchanged, a fresh comparison and a posted job.
   - These return for review:
     - any definition or header change;
     - a wrong axiom set;
     - a genuine strict-replay failure;
     - a scope change.
   - A batch is 1800 s, counted from before proof writing or staging. It is never extended or reset, and a new batch needs a fresh posted binding.

## Conditions and advisories

- **Condition: final PASS needs two independent steps.** Skeleton's own clean rebuild, named-axiom report and strict replay on nucleus, and a separate statement-fidelity review, as for FF-2. I still read every raw axiom log.
- **Advisory, name shadowing.** The data module defines `FVLT.PhasorFordV1.IsIntegral` while Mathlib has a root-level `IsIntegral`. Inside the namespace the local name should win. If elaboration reports an ambiguity anyway, a rename is a definition change and comes back for a quick review; it is not a proof-only repair.
- **Advisory, conservative runner scans.** The forbidden-token scan also matches comments, and the G1 check matches the substring "g1" in import names. A false refusal from either is a harness problem before any verdict. Repair it under the harness rule, not as mathematics.
- **Scope unchanged.** The following are not claimed:
  - oriented or continuous arcs;
  - recovering an address from an unlabelled phasor;
  - any register identification;
  - a factoring advantage;
  - viewer work;
  - kernel adoption, library sync, commits or release.

  The §9.4 Idea Catalog candidate comes only after the fidelity review.

Credit: the question of the map, the rosette and the instruments: saphir. "The framework was assembled by Robin Miller; its components are classical results of others."
