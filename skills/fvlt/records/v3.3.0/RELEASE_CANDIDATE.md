# FVLT v3.3.0: minor release candidate (release lock pending saphir)

> **Correction round 2 (2026-10-28).** The delta verification (`VERIFY_REPORT_DELTA.md`, FAIL, R-09) found the round-1 item-lock list incomplete: it took its spans only from ITEMS.json. saphir chose option A. The corrected candidate kernel is `3e32818ea4e12957a53b4e85d8dcd16213d7f52653995102c14258603f85e6bc`, and the release lock is pending saphir's re-confirmation of that hash. The corrections are marked "[corrected, round 2]".
>
> **Correction round 1 (2026-10-28).** The independent verification (`VERIFY_REPORT.md`, FAIL) found this record incomplete on two points:
> - **R-01.** It named three item-locked edits where eight declared replacements change item-locked text.
> - **R-02.** It said "No standing changes", but eleven native tags changed.
>
> The corrections are made in place below and marked "[corrected, round 1]". The corrected candidate kernel was `8d436beb67ed5499f7d9cb1a1b79b6997db52e5da056018169a95699713ecc23`, and the release lock is pending saphir's re-confirmation of that hash. The lock of 2026-10-28 on `edb6528a…` is superseded before publication (see `RELEASE_LOCK.md`).

saphir assigned the label v3.3.0 on 2026-10-28, answering "Which version label should the merged successor kernel get?" with "v3.3.0". The two options offered were v3.3.0 (minor release: the reviewed corrections across 14 repair topics, a notation table and edits to locked items, with no standing upgraded) and v3.2.8 (point release).

## What is released

| Artifact | SHA-256 |
|---|---|
| `kernel/successor/kernel.md`, corrected release candidate (correction round 2) [corrected, round 2] | `3e32818ea4e12957a53b4e85d8dcd16213d7f52653995102c14258603f85e6bc` |
| `kernel/successor/kernel.md`, correction round 1 candidate (commit `739f0b8`; item-lock list incomplete) | `8d436beb67ed5499f7d9cb1a1b79b6997db52e5da056018169a95699713ecc23` |
| `kernel/successor/kernel.md`, first labelled release candidate (label commit `e2d95c4`) | `748e4ee3660ba664e4ee3533dc2871c66cc4c19367d005fbc3af460f236a9dcb` |
| `kernel/successor/kernel.md`, locked on 2026-10-28 and superseded before publication (lock commit `552ce0f`) [corrected, round 1] | `edb6528a5b8c46c4c5e9b3286d311dfa1259185f074312db9497fdc1a93eaae6` |
| The same file as Astra cleared it at `4c89fba` (review 5680901178), merged as `8c74c86` (PR #67) | `eccec3efb8ffd856dbbf3979b3f520898279811119f973a3378d8926a6a10e57` |
| Predecessor `kernel/next/kernel.md`: v3.2.7, LOCKED by Robin 2026-10-20, unchanged | `b8266896dad305356faa76c7248338d3aed37115f8c434f7727475f28ad42a81` |

## Promotion path

The repository has no documented procedure for promoting `kernel/successor/` to a release. v3.2.6 and v3.2.7 were labelled and locked in place in the working kernel file (`kernel/next/kernel.md`). v3.3.0 follows the same pattern in its own working file:

- The release stays at `kernel/successor/kernel.md`. Nothing is copied over `kernel/next/`, so the locked v3.2.7 bytes and the `CORRECTIONS.json` base pin (`kernel/next/kernel.md`, `b8266896…`) stay valid.
- The label is applied as declared replacements in `CORRECTIONS.json`:
  - `REPAIR-HUNK-001` (header) has its `new` text amended.
  - `REPAIR-HUNK-002` (version paragraph) has its `new` text amended.
  - `REPAIR14-D-20` (footer) has its `new` text amended.
  - `REL330-CHANGELOG` is a new replacement. It adds the v3.3.0 changelog comment in front of the inherited v3.2.7 changelog line.
- `tools/build_successor_kernel.py --write` regenerates `kernel.md`, `ASSEMBLY.json` and `CORRECTIONS.diff`. All byte offsets in `ASSEMBLY.json` are recomputed.
- The line count is unchanged.
- One tool line changes: `ASSEMBLY.json` now takes its `status` from `CORRECTIONS.json`, which defaults to the old `DRAFT_VERSION_UNASSIGNED`. Before this change, `DRAFT_VERSION_UNASSIGNED` was hard-coded.

The record is `kernel/successor/repairs/2026-10-28/release-v3.3.0/UNITS.json`, together with `INCREMENTAL_label.diff` (`eccec3ef…` to `748e4ee3…`). The apply script checks that every changed line of the successor lies inside one of these four release-metadata units. The changed lines are 3, 5, 7, 9 and 5558, and nothing else. Correction round 1 changes lines 5, 7 and 9 only (`INCREMENTAL_correction1.diff`, `edb6528a…` to `8d436beb…`); outside those release-metadata lines the body is byte-identical to the text Astra cleared. [corrected, round 1]

## Contents relative to v3.2.7

The v3.2.7 bytes are pinned in `CORRECTIONS.json`. Against them, the release applies:

- the integrated corrections of 2026-10-24;
- repair topics 1–13 of 2026-10-25, with the Opus follow-up (PR #66);
- topic 14 of 2026-10-28, read-review corrections with fix rounds 1–4 (PR #67).

~~There are 292 reviewed replacements. Two of them, `REPAIR-HUNK-001` and `-002`, are the header units, so there are 290 corrections.~~ [corrected, round 1: the figure counts replacement hunks, not correction units.] There are 292 replacement hunks against v3.2.7: 290 excluding the two header hunks (`REPAIR-HUNK-001`, `-002`), including the footer metadata hunk `REPAIR14-D-20` and the 2026-10-24 integrated corrections, which belong to no repair topic. The topic records hold 278 replacements in units (220 for topics 1–13, 58 for topic 14). `REL330-CHANGELOG` brings the total to 293. Each topic's units are in `kernel/successor/repairs/`.

| Topic | Subject | Record |
|---|---|---|
| 1 | Divisor objects, lenses and finite actions | `repairs/2026-10-25/01-arithmetic/` |
| 2 | Algorithm and output cost models | `02-cost-models/` |
| 3 | Vernier phases, spin and contact rules | `03-vernier/` |
| 4 | Channel tilt, persistent state and walk boundaries | `04-energy-memory/` |
| 5 | Crystal coordinates, grades and projected fibres | `05-crystal/` |
| 6 | Chirality sufficiency and symmetry states | `06-chirality/` |
| 7 | Measurement operators, phase and diagnostics | `07-measurements/` |
| 8 | Factorial bridge selection and finite examples | `08-factorial/` |
| 9 | Ordered profiles and transport scope | `09-profiles/` |
| 10 | Analytic and geometric comparison boundaries | `10-analytic-bridges/` |
| 11 | Categorical, signal and completion domains | `11-completions/` |
| 12 | Interpolation and iteration domains | `12-interpolation/` |
| 13 | Status, notation and source navigation | `13-authority/`, and `opus-followup/` |
| 14 | Read-review corrections, fix rounds 1–4 | `repairs/2026-10-28/14-read-review/` |

The release keeps all 186 native identities and their order, and the 11 reviewed native-metadata changes are on the allowlist. No mathematical text changes in the label step.

## Item-locked text: correction round 2 (supersedes the round-1 table below)

[corrected, round 2] The round-1 list came only from ITEMS.json, so it was incomplete (`VERIFY_REPORT_DELTA.md`, R-09). saphir chose option A. The list below is complete with respect to five lock sources: (a) item-locked folds in `kernel/next/ITEMS.json`; (b) native-tag lock fields (`locked: … (item)`, `LEMMA LOCKED`, `kernel-body LOCKED`); (c) in-body item-lock records; (d) version-history item-lock records; (e) bodies described as locked. All 108 lock-word occurrences in the v3.2.7 kernel are classified by `scripts/locked_span_intersections_v2.py` (output `ITEM_LOCK_INTERSECTIONS_v2.json` and `.txt`; v1 and its output are kept). Bibliography-tier and companion locks outside the kernel are not covered.

**Sources (a)–(d), item-locked text: 22 replacements in 8 spans** (v3.2.7 line numbers):

| Span | Source | Earlier lock | Replacements |
|---|---|---|---|
| Farey II.5g–k fold (894–1283) | (a) | item-locked by Robin 2026-10-12 | REPAIR14-A-11 (1216), REPAIR-HUNK-041 (1228), REPAIR-HUNK-042 (1230–1232) |
| Goldbach II.23.5c–e fold (2773–2933) | (a) | item-locked by Robin 2026-10-12; seated: false | REPAIR-HUNK-133 (2882), REPAIR-HUNK-134 (2890), REPAIR14-PR60-LAMBDAG (2892–2902) |
| II.23.9 fold (3028–3258) | (a) | item-locked by Robin 2026-07-23 | REPAIR14-C-02-POINTER (3053–3055), REPAIR-HUNK-146 (3133) |
| Thm II.3c (526–556) | (b) | `locked: Robin 2026-07-14 (item)` | REPAIR-HUNK-024 (543): phase-loss identity wording |
| Rmk II.5f (878–931) | (b) | `locked: Robin 2026-07-14 v1.0 (item)`, with the body SHA-256 pinned | REPAIR-HUNK-040 (883) |
| Rmk 9.7z (1955–2008) | (c) | `Lock: lock_record_2026-06-09_chi-W-coincidence` | REPAIR-HUNK-101 to REPAIR-HUNK-109 (1955–2006) |
| Note 14.5 (4831–5166) | (c), (d) | "Locked 2026-07-01"; v3.2.3 "[LOCKED 2026-07-04 …]" | REPAIR-HUNK-230 (4933): completion wording |
| Cor 14.5a (5167–5250) | (d) | v3.2.3 "[LOCKED 2026-07-04 by Robin's word]" | REPAIR-HUNK-231 (5204): p-adic tree relation as a fixed-level statement; REPAIR14-D-09 (5216): "120 cases" to "121 cases" |

**Corrections to the mathematics of locked statements:**
- **REPAIR-HUNK-040** changes Rmk II.5f(i), which is tagged unconditional. "is the path graph on V in value order" becomes "is the induced subgraph on V of the integer path (generally a union of paths)".
- **REPAIR-HUNK-101 to REPAIR-HUNK-109** change Rmk 9.7z. The locked iff is weakened to sufficiency, with necessity open, and the lock record is relabelled "Historical lock".

**Locked spans with no edits:**
- Lemma 9.2a and Rmk 9.3j (source b);
- the S2-closure record, LOCKED 2026-08-19 (source c);
- Cor 9.7c.1, Rmk 9.7y and Rmk II.5b, from the 2026-06-07 lock (source d).

**Source (e), described as locked, lock scope not recorded.** The v3.1.21 version-history entry says "pointer to three locked bodies". The edits to those bodies are 6 replacements:
- Lemma 9.7a (1739–1749): REPAIR-HUNK-087, REPAIR-HUNK-088, REPAIR-HUNK-089.
- Rmk 9.7h (2075–2087): REPAIR-HUNK-112, REPAIR-HUNK-113, REPAIR-HUNK-114.
- Note 9.3a.1: no hits.

**Lock status.** None of these attestations or item locks is renewed, and seated: false is kept for Goldbach. **Standing:** no status is upgraded, and the list of eleven native-tag changes below is unchanged. The one change of wording is R-13: in Rmk 9.7z the iff is weakened to sufficiency (necessity open). It is not a label split.

## Item-locked text edited in this successor (round 1; superseded by the section above)

[corrected, round 1] The superseded text of this section is kept as a quotation after the corrected version.

The v3.3.0 release covers the assembled kernel as a whole. It does not re-attest, or renew the lock on, any edited item-locked text. Eight declared, reviewed replacements change text inside the item-locked spans of v3.2.7. The list is complete by construction: `scripts/locked_span_intersections.py` intersects every correction segment of `kernel/successor/ASSEMBLY.json` with the item-locked fold spans recorded in `kernel/next/ITEMS.json`. Its output is in `ITEM_LOCK_INTERSECTIONS.json` and `.txt`.

| Item-locked span (v3.2.7 lines) | Earlier lock | Replacement (v3.2.7 lines) | Change | Status in v3.3.0 |
|---|---|---|---|---|
| Farey II.5g–k fold (894–1283) | Item-locked by Robin 2026-10-12 (independent cold pass) | `REPAIR14-A-11` (1216) | Census line: "in §7" to "of Prop II.5k" (edit record `REPAIR14-FIX2-A-11-RECORD`) | Edited by a declared, reviewed correction; attestation not renewed |
| | | `REPAIR-HUNK-041` (1228) | Rupture record: "order `n-1`" to "admissible denominator `n-1`" | Same |
| | | `REPAIR-HUNK-042` (1230–1232) | Killed-guess paragraph: "order" to "denominator"; "for this denominator-based guess" added | Same |
| Goldbach II.23.5c–e fold (2773–2933) | Item-locked by Robin 2026-10-12; ATTESTED, machine PASS, seated: false | `REPAIR-HUNK-133` (2882) | Def–Prop II.23.5d Status paragraph: the Rmk 5.7a calibration sentence rewritten | Same; seated: false kept |
| | | `REPAIR-HUNK-134` (2890) | Def II.23.5e defining sentence: "For even `N≥4`, define" to "For any positive integer `r`, define …"; comparator use restricted to even `N≥4` | Same |
| | | `REPAIR14-PR60-LAMBDAG` (2892–2902) | Def II.23.5e displays and the sentence between them: `N` to `r` (edit records `REPAIR14-FIX2-LAMBDAG-RECORD`, `REPAIR14-FIX3-LAMBDAG-RECORD`) | Same |
| II.23.9 fold (3028–3258) | Item-locked by Robin 2026-07-23; folded in v3.2.6; byte-unchanged in v3.2.7 | `REPAIR14-C-02-POINTER` (3053–3055) | Def II.23.9: pointer to the VII.2a parameter note | Same |
| | | `REPAIR-HUNK-146` (3133) | Rmk II.23.9b: reciprocal shell-swap gloss | Same |

The kernel carries edit records only for `REPAIR14-A-11` and `REPAIR14-PR60-LAMBDAG`. `REPAIR-HUNK-041`, `-042`, `-133` and `-134` have no in-kernel edit record; adding one would change body text and is left open.

**Standing.** No standing is upgraded. Eleven native tags change against v3.2.7, each by a reviewed correction. The list is taken by script from `allowed_native_tag_changes` and is also in `ITEM_LOCK_INTERSECTIONS.json`:
- **Withdrawn or downgraded:**
  - THM-6.2-RESONANCE-PURITY, THM-8.14a-CLOSURE-EXHAUSTION and THM-8.20h.3-SELECTION-OF-N0: register proved to conditional, status unconditional to open.
  - RMK-8.20h.4-S6-MAXIMALITY: unconditional to open.
- **Label splits:**
  - RMK-9.7z-CHI-W-COINCIDENCE [corrected, round 2: the iff is weakened to sufficiency (necessity open); this is not a label split]: "unconditional (iff; four-state collapse) + interpretive …" to "unconditional (κ-palindromic sufficiency; at-most-two states) + open (weighted-height multiset necessity) + interpretive …".
  - RMK-1.2-DIVISOR-LATTICE-AS-MEASUREMENT-BASIS: unconditional to "interpretive (apparatus reading) + unconditional (divisor-label facts)".
  - RMK-3.6-GEOMETRIC-CONTENT: unconditional to "unconditional (algebraic identities) + interpretive (metric reading)".
- **Dependency lists only:**
  - DEF-5.1-AMPLITUDE-EXPONENT: 1.2, 5.2 to 1.2.
  - DEF-5.2-WEIGHTED-RAMANUJAN-SUMS: 5.1 to none.
  - RMK-9.4a-WALK-REGIME-TAXONOMY: 5.1b, 9.4 to 9.4.
  - NOTE-9.4b-FAREY-BOUNDARY: 5.1b, 5.4b, 9.4, 9.4a to 9.4, 9.4a.

No Goldbach, RH/Landau or centered-comb standing is upgraded. C-01 stays explicitly unresolved.

Superseded text of this section, as first written:

> The v3.3.0 release covers the assembled kernel as a whole. It does not re-attest, or renew the lock on, any edited item-locked text. Three items were item-locked in v3.2.6 or v3.2.7 and have changed text here:
>
> | Item | Earlier lock | Declared edits | Status in v3.3.0 |
> |---|---|---|---|
> | II.23.9 | Item-locked by Robin 2026-07-23; folded in v3.2.6; byte-unchanged in v3.2.7 | `REPAIR-HUNK-146`, `REPAIR14-C-02-POINTER`; lock note in VII.2a | Item-locked text from v3.2.7, edited by declared, reviewed corrections; attestation not renewed |
> | Def II.23.5e | Goldbach II.23.5c–e item-locked by Robin 2026-10-12 (ATTESTED, machine PASS, seated: false) | `REPAIR14-PR60-LAMBDAG`; edit records `REPAIR14-FIX2-LAMBDAG-RECORD`, `REPAIR14-FIX3-LAMBDAG-RECORD` | Same |
> | Farey census line (A-11) | Farey II.5g–k item-locked by Robin 2026-10-12 (independent cold pass) | `REPAIR14-A-11`; edit record `REPAIR14-FIX2-A-11-RECORD` | Same |
>
> The kernel's own edit records already say that the historical attestations cover the original bytes only. No standing changes. No Goldbach, RH/Landau or centered-comb standing is upgraded, and C-01 stays explicitly unresolved.

## Release wording

The header units take their wording from saphir's label assignment of 2026-10-28. The exact text is in `CORRECTIONS.json` under `REPAIR-HUNK-001`, `REPAIR-HUNK-002`, `REL330-CHANGELOG` and `REPAIR14-D-20`, and in the `release` block of the same file.

## Not in this release

- `kernel/next/` (the locked v3.2.7 kernel, `ITEMS.json` and bibliography) is unchanged. The successor has no `ITEMS.json` of its own.
- `kernel/next/bibliography.md` is unchanged. The repository bibliography is still the v3.2.5-era text and is out of scope here.
- Body text that says "successor draft" (edit records and notes) is left as written. The version paragraph says that this phrase means this release's text as changed from v3.2.7.
- The in-repository skill bundle `skills/fvlt/v3.2.6/` is unchanged. The v3.3.0 skill bundle is built outside the repository.
