> **Locked 2026-11-04** (saphir: "v3.4.1, lock it"). The lock record is `RELEASE_LOCK.md`. This file is kept as the record of what was reviewed, and its candidate hash `90134be9…` is the pre-lock state.

# FVLT v3.4.1: point-release candidate (release lock pending saphir)

**Label.** saphir assigned it on 2026-11-04, answering the proposed point-release label v3.4.1: "I like the point release label".
**Adoption.** In the same message saphir adopted correction candidate v0.3 of `FF3-FORD-9.4-ROW` (PR #76): "I approve".
**Lock.** Not given yet. This record becomes the lock record only after saphir's lock word.

## What is in the candidate

| Artifact | SHA-256 |
|---|---|
| `kernel/post-v3.4.0/kernel.md`, v3.4.1 candidate (604,384 bytes, 5,626 lines, 187 native tags) | `90134be97be012da8a0ea0f5b48338a6a863166f36fbf0781f6822ef37886b39` |
| The same body without the release metadata: v3.4.0 with v0.3 applied, as reviewed on PR #76 | `9b6dda3d58f672eec8cac11a2790aec8ca58b0318ee433ed5bad1cba66265625` |
| `kernel/post-v3.3.1/kernel.md`, v3.4.0 (LOCKED; the base pin; unchanged) | `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2` |

The plan and generated files are hashed in the PR description. They change at the lock, because the lock wording is release metadata.

## What v3.4.1 changes

There is one correction, `FF3-FORD-9.4-ROW` v0.3. Its record is in `kernel/post-v3.3.1/repairs/2026-11-04/ff3-ford-9.4-row/`.
- **Part II / II.5, §9.4 Ford circles.** The row said only that a map from Vernier phasor paths to Ford-circle arcs "has not been defined". It is now a short row pointing to an **untagged note** directly below the table. The layout follows saphir: "Short cell + note".
- **What the note states.** The lifted-data map of FF-3, Lean-verified in shared theorem library v23:
  - Φ sends lifted rosette data to the Ford circle at the address x = t₂s/n₃;
  - the phasor lies on the real axis iff the phase address a = k₁s/n₃ is an integer, which extends Rmk II.5a from integer to rational s and also holds for n₆ < 0;
  - on the shells n₃ = N with t₁ = t₂ = 1, the real-axis events give the Farey set F_B with determinant-1 neighbours;
  - every path edge is tangent, stall or break, and each tangent edge has an exact kiss point.
- **What stays undefined and interpretive:** oriented or continuous arcs, maps from phasor values or paths, and dynamics.
- **Release metadata:** the title, the version paragraph, the release-standing sentence (which now names v3.3.0 to v3.4.1), the new v3.4.1 changelog comment, and the footer. The v3.4.0 record is kept as history.

There are 6 replacements against v3.4.0 in `kernel/post-v3.4.0/CORRECTIONS.json`, built with `tools/build_successor_kernel_v2.py`.
- **Identities:** all 187 native identities are kept, in order. No item is added, and no native tag or status label changes. No standing is upgraded.
- **Agreement with the reviewed draft:** the candidate differs from the PR #76 draft (`9b6dda3d…`) only on lines 3, 5, 7, 9 and 5626, all release metadata.

## Item-locked text

`ITEM_LOCK_INTERSECTIONS.json`, from `scripts/item_lock_check.py` (a re-pointed copy of the v3.4.0 script), checks all 6 replacements against the 17 strict v3.2.7 lock spans: **none falls in a lock span**.
- **The Ford row** traces to v3.3.0's `REPAIR-HUNK-035` (v3.2.7 lines 630–631), which is outside every span.
- **The footer** hits only the loose range of Cor 14.5a, which runs to the end of the file. As in v3.4.0, that is not a lock intersection.

## Lean (no status effect, policy v0.2 rule 9)

FF-3 is the shared theorem library v23 modules `FVLTRosetteFord{Data,Phase,Arithmetic,Sweep,Endpoints}V1`.
- **Audit:** final audit PASS (Stack Bus #1554, `cf9f59c9…`), 37/37 statements. The axioms are only propext, Classical.choice and Quot.sound.
- **Fidelity:** 37/37 MATCH (signoff `abbf810a…`).
- **Source:** reported by skeleton. The library is not in this repository and was not re-checked here.
- **Scope of the note:** it states r > 0, a special case of Lean's r ≠ 0. Its n₆ < 0 sentence is the elementary identity Im(−z̄) = Im z.

## Verification

```
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.4.0 --check   # PASS: 6 replacements, 187 identities, 0 additions
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.1 --check   # v3.4.0 unchanged: PASS
python -I -B docs/releases/v3.4.1/scripts/item_lock_check.py                     # reproduces ITEM_LOCK_INTERSECTIONS.json
python -I -B kernel/post-v3.3.1/repairs/2026-11-04/ff3-ford-9.4-row/check_ff3_row.py   # PASS 8557
python -m unittest discover -s tools/tests
```

All `tools/tests` suites pass except `test_fvlt_skill_bundle`. That suite fails identically on `main`, because the repository bundle is the v3.2.6 package.

## Not included
- **Skill bundle:** no change. The v3.4.1 skill package is built after the lock.
- **Lean:** no Lean change in this repository.
