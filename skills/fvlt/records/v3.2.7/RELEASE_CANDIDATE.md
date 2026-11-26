# FVLT v3.2.7 — point release (LOCKED by Robin 2026-10-20)

Robin assigned the label v3.2.7 on 2026-10-20 ("its a point upgrade, so update it to v3.2.7"). Robin locked it on 2026-10-20: "I lock it, we will worry about the rest in another session." It is the release of record; v3.2.6 is superseded. The lock was given before Codex's review of PR #44 completed; that review stays open as a follow-up, not a gate.

## Contents relative to v3.2.6 (errata only)

| Correction | Kernel change | Record |
|---|---|---|
| W1 | II.8 Def 5.2: formula replaced by the weighted Kluyver form; basis sentence narrowed to $A_N$; attribution narrowed to [FGK14, Thm 3.15]; correction note. Same line count. | `docs/errata/next/W1_II8_def52_weighted_ramanujan.md`; checks `docs/investigations/DEF_5_2_weighted_ramanujan_2026-10-20/` |
| R1, R2b | Additive notes at the end of VII.2a (adopted by Robin 2026-10-12) | `docs/errata/next/R1_…md`, `R2b_…md` |
| G4 | Additive note at the end of VII.2a (Codex finding; applied at saphir's instruction 2026-10-20) | `docs/errata/next/G4_…md` |

Every change from the v3.2.5 base is one declared segment in `kernel/next/ITEMS.json`; `tools/verify_kernel_next.py` (completed stage, all `kernel/inputs/*` roots) establishes integrity and traceability, not mathematical authority.

## Release wording (fold source for the header segments)

The editorial header segments `header-3-v3.2.7` and `header-5-v3.2.7-locked` take their wording from this file; the authority for it is Robin's label assignment and lock of 2026-10-20.

## FVLT — v3.2.7 (on the v3.2.0 Semantic-Correction Baseline)

**Version:** 3.2.7 (current, **LOCKED release of record**, Robin 2026-10-20: "I lock it"; a point release on v3.2.6, label assigned by Robin 2026-10-20: "its a point upgrade, so update it to v3.2.7"). It supersedes v3.2.6 (SHA-256 `4a23d62e15ada3819defe6919e56fe9f2ef6a9a10eb7f5c4082e4b6b442cdb94`, locked by Robin 2026-10-12) as the release of record; v3.2.6 superseded v3.2.5 (SHA-256 `ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef`). Relative to v3.2.6, this release applies errata only: W1 corrects Definition 5.2 (II.8), whose displayed formula did not reduce to the classical Ramanujan sum at $w \equiv 1$; R1, R2b and G4 add notes on II.23.9 at the end of the fold concordance (Part VII / VII.2a), leaving the II.23.9 text byte-unchanged. The v3.2.6 contents relative to v3.2.5 are as recorded in its changelog below. Item standings, limitations and not-claimed clauses are as recorded in the item tags and the post-v3.2.5 concordance (Part VII); no status is upgraded, and no other base wording changes.

<!-- v3.2.7 changelog (LOCKED by Robin 2026-10-20): apply errata W1 (Def 5.2 weighted Ramanujan sums: Kluyver-form formula, basis sentence narrowed to A_N, attribution narrowed to [FGK14, Thm 3.15]) and the additive VII.2a notes R1, R2b, G4 on II.23.9; errata records in docs/errata/next/. --> <!-- v3.2.6 changelog (LOCKED by Robin 2026-10-12): fold the Robin-locked II.23.9 entry; fold independently cold-passed, fixed-numbered Farey II.5g–II.5k; fold ATTESTED Goldbach II.23.5c–e with the [GS20] normalization citation, retaining seated: false; apply corrections KG-04, KG-06, KG-07, BIB-01, KG-04-VII8, COMB-M-VII8 and L93-SCOPE. Farey and Goldbach were item-locked by Robin on 2026-10-12 with their reviewed standings and limitations preserved; lock records are in docs/releases/v3.2.6/. -->

## Not in this release

- `kernel/next/bibliography.md` is unchanged (bibliography later, per saphir).
- The installed skill bundle `skills/fvlt/v3.2.6/` is unchanged; a v3.2.7 bundle needs Robin's checkpoint.
- Open after W1: the $c_n(s;\alpha)$ notation row (VII.8) and the §5.5 "extends to weighted cases" line.
