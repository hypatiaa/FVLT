# FF-4 final audit v0.1: PASS

2026-11-05. Skeleton (Claude Opus 5.5), on saphir's "go". This is the final audit routed in bus #1610, and the final-PASS condition of `FF4_FREEZE_DECISION_v0_1.md` (`5195a4be…`, #1563).

**Outcome: FF-4 PASS.**
- All 33 frozen statements are proved in Lean 4.35.0 against library v23, using only `propext`, `Classical.choice` and `Quot.sound`.
- Each states what WORK_ORDER v0.2 (`d28dfd0e…`) asks for.
- **What FF-4 establishes:** the combinatorial side of the Ford-to-bulb map. Ψ sends a reduced p/q ∈ (0, 1) to an exact rational angle pair. That pair:
  - lies on one period-q cycle of doubling, with rotation number p/q;
  - is the cycle's unique unit gap;
  - is ordered like the fractions;
  - respects mediants.

  The bulb root and multiplier algebra are proved, and the mediant is shown to be the smallest denominator between Farey neighbours.

## 1. Sealed packet (read-only checks by script)

- **Packet:** `final_source_packet_v0_1/`, manifest `ad0fd106…`; all **101 of 101** entries re-hash correctly.
- **Sources:**

  | Module | SHA-256 | Note |
  |---|---|---|
  | Data | `19fcd5d3…` | byte-identical to the frozen definitions, imports included |
  | Parameter | `1e1eef97…` | |
  | Combinatorics | `41db1fb6…` | |

- **Statement comparison** with `SKELETON_FF3_HEADER_COMPARE_v0_2.cjs`:
  - **33 of 33** public theorems, all distinct, each identical to the frozen headers `c5b569b1…`, with none missing;
  - 44 private helpers;
  - no public non-theorems;
  - no `sorry`, `admit`, `axiom`, `unsafe` or `extern`;
  - LF line endings.

## 2. Independent rebuild on nucleus

- **Setup:**
  - folder `~/skeleton_audit/ff4_final_20261105/`, starting from an empty `build/`;
  - my own runner `run_ff4_final_audit.sh` (`8efe4142…`);
  - my own axiom file `SkeletonAuditFF4.lean` (`7401d6d5…`), naming the 33 targets taken from the frozen headers and the 31 data declarations taken from the frozen definitions;
  - checker `9c6f2ac1…`, Lean `bf8d54e4…`, and library v23, which is the latest, with checksums at 0 failures before and after;
  - template limits.

| Module | Compile | Strict replay |
|---|---|---|
| FVLTFordBulbDataV1 | exit 0, empty log | PASS 54/54, kernel completed, 0 fail/unsafe/partial |
| FVLTFordBulbParameterV1 | exit 0, empty log | PASS 4/4 |
| FVLTFordBulbCombinatoricsV1 | exit 0, warnings only (deprecations), no `sorry` | PASS 161/161 |

- **Totals:** 219 constants replayed. The only axioms are the standard three.
- **Named axioms** (my own file, log `024dbc9e…`): 64 lines, every one using only the standard three.
- **Integrity:** sources unchanged, and the library intact.
- **Reproducibility:**
  - all three replay logs are byte-identical to the producer's final logs (`db5957eb…`, `be96b6a2…`, `db12620d…`);
  - all three compiled objects are byte-identical to the producer's (`21df17bc…`, `a2673af4…`, `60ca6a26…`).

## 3. Independent statement fidelity

- **Reviewer:** a separate subagent (Claude Opus), spawned with a closed file list. It ran no Lean, used no network and posted nothing.
- **Signoff:** `FIDELITY_REVIEW_v0_1/FIDELITY_SIGNOFF_v0_1.json` (`034639fc…`) and `.md` (`d6e860cf…`). Parsed by script:
  - **33 of 33 targets MATCH**;
  - **31 of 31 definitions MATCH**;
  - no other verdicts.
- **Specific points confirmed:**
  - the Fin-q digit weights and the `lowerIndex` guard;
  - the wrap gap (M + x₀) − x_{q−1};
  - rank as a count strictly below;
  - the B2 and B4 residues equivalent to the congruences;
  - C1 general;
  - C2 with both endpoints in Ψ's domain and both separations;
  - C3 with its equality case;
  - the `HasDerivAt` argument order;
  - `IsPrimitiveRoot` with order q.
- **Its own mirror check:** 17,432 checks, 0 failures; finite evidence. Five negative controls all fail as they should, and a mutated header is caught.
- **A harness bug in its own script** was disclosed: a mediant lookup range that was too small, fixed before the final run.
- **Advisories, none a defect:**
  - C3 is quantified over all of ℚ, which is the literal order text. If the guarded domain is read as governing C3, the Lean is a harmless generalization of it.
  - `psi` is not named in any target.
  - `directedGap`'s natural-number subtraction never truncates.

## 4. Standing and limits

- **Proved:** the exact combinatorial and algebraic statements A1a–A1c, B0–B5 and C1–C3.
- **Not claimed:**
  - parameter-ray landing, the complex-plane wake, limb geometry and analytic dynamics, which are cited (Milnor, Douady–Hubbard, Goldberg) and never formalized;
  - B6 uniqueness, which is deferred;
  - any Rule 30 claim.
- **Not done here:** no kernel adoption, commit or release.
- **Library sync:** v24 follows under saphir's standing rule.

Credit: the observation that the fraction fan maps the Mandelbrot bulbs, and the instruments: saphir. The design review, the C1 route and the proof architecture: the formalization owner. "The framework was assembled by Robin Miller; its components are classical results of others."
