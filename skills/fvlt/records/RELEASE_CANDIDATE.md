# FVLT v3.2.6 — release candidate (not locked)

Robin assigned the label v3.2.6 on 2026-10-12 and ruled to lock the Farey and Goldbach items (relayed on issue #3).

This candidate is not a release. The v3.2.5 baseline remains the locked release of record until Robin's release lock.

## Identity

| Artifact | SHA-256 |
|---|---|
| `kernel/next/kernel.md` (stage `v3.2.6-release-candidate`) | `b99f61181a62f9c5dac4a9306b9510af0d6d9b7e3cc18511f6184127d82e7119` |
| `kernel/next/bibliography.md` | `f109a7e1097275795bb44fa481d4f63422dce7456c3dbbd7e7348f3468a4c474` |
| v3.2.5 base `kernel/base/v3.2.5/kernel_v3_2_5.md` | `ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef` |

## Contents relative to v3.2.5

Every change from the base is exactly one declared segment in `kernel/next/ITEMS.json`. `tools/verify_kernel_next.py` establishes integrity and traceability:
- the stage hash;
- each segment's anchor and content hash;
- the declared base replacements;
- the native ids;
- every pinned authority and fold-source hash.

For the fold segments it also checks a minimum number of lines that occur verbatim in the fold source. It does not establish that a source *authorizes* new wording.

The editorial release segments (`header-3-rc`, `header-5-rc`, and the retitled headings in `concordance-rc` and `VII8-post-v3.2.5-notation-rc`) cite the working assembly they replace as `fold_source`, with a verbatim minimum of 0. That source does not state or authorize the release wording. The authority for that wording is Robin's decision of 2026-10-12, recorded on issue #3 (comment 6118120506). Mathematical standing comes only from the cited reviews, cold passes and lock records, never from a verifier PASS.

| Segment | Change | PR | Review |
|---|---|---|---|
| `fold-II.23.9` | Def II.23.9 – Cor II.23.9d, folded verbatim from the locked entry (item-locked by Robin 2026-07-23) | #8 | Codex cleared |
| `fold-Farey-II.5g-k` | Lemma II.5g – Prop II.5k, mechanical fold (independently cold-passed, numbered) | #8 | Codex cleared |
| `fold-Goldbach-II.23.5c-e` | Cor II.23.5c, Def–Prop II.23.5d, Def II.23.5e, mechanical fold (ATTESTED, machine PASS, seated: false) | #8 | Codex cleared |
| `concordance-rc` | Post-v3.2.5 fold concordance (VII.2a) | #8, #14 | Codex cleared; heading retitled here |
| `KG-04-warm`, `KG-04-declared-shell` | Prime-support notation 𝒫(N) in Rmk 1.6a and the declared-shell restriction | #9 | Codex cleared |
| `KG-06-s2-closure` | Record of the locked S2 efficiency closure at Rmk II.5a | #10 | Codex cleared |
| `KG-07-comb-pointer` | ALG-5 extension-boundary pointer to the centered-comb companion | #11 | Codex cleared |
| BIB-01 (bibliography) | [GS20] entry; the bibliography is byte-identical to its pinned source | #14 | Codex cleared |
| `VII8-post-v3.2.5-notation-rc` | VII.8 notation entries: 𝒫(N), 𝒫(S), 𝒫_N, π(N), ω(N) (#15) and comb(m) (#19) | #15, #19 | Codex cleared; heading retitled here |
| `L93-SCOPE` | Ω = 2 ring statement scoped to the exponent-two profile | #20 | Codex cleared |
| `header-3-rc`, `header-5-rc` | Title, version paragraph and release-candidate changelog (editorial; authority is Robin's decision, not the fold source) | #21 | in review |

The item standings are as recorded in the post-v3.2.5 concordance. This candidate does not change them; that happens at release lock (below).

## Verification

```powershell
python tools/verify_kernel_base.py
python tools/verify_kernel_next.py --input-root kernel/inputs/2026-10-11/sources --input-root kernel/inputs/2026-10-11-bibliography/sources
python -m unittest discover -s tools/tests
python tools/check_omega2_rings.py
```

The input roots exist on `main` once #6 and #12 are merged.

## Release-lock procedure (one commit, after Robin's verbatim lock statement)

Run every step from the repository root on the merged `main`.

1. **Finalize the lock records.** In `docs/releases/v3.2.6/LOCK_RECORD_FAREY_II.5g-k.md` and `LOCK_RECORD_GOLDBACH_II.23.5c-e.md`, enter Robin's verbatim lock statement and its date, and remove the DRAFT status. Change nothing else. The native-id tags and the standing sections stay as reviewed.
2. **Pin the finalized records as item authority.** Compute each record's SHA-256. Append `{"path": "docs/releases/v3.2.6/LOCK_RECORD_<…>.md", "sha256": "<hash>"}` to the `authority` list of each of the seven Farey items (II.5g–II.5k) and each of the three Goldbach items (II.23.5c–e) in `kernel/next/ITEMS.json`. This mirrors how the II.23.9 items cite their pinned lock record.
3. **Update standings and metadata in `ITEMS.json`:**
   - those ten items move to `item_locked`;
   - set `release.status` to "locked", `release.assembled_release_locked: true`, and record the release-lock statement;
   - each correction's `release_status` becomes "included in v3.2.6 (locked)".
4. **Edit the kernel text:**
   - the concordance rows for II.5g–II.5k and II.23.5c–e change from "item lock pending" to "item-locked by Robin, <date>". Goldbach keeps "ATTESTED; machine PASS", "seated: false" and its not-claimed clauses;
   - the title (line 3), version paragraph (line 5) and changelog comment (line 7) take their locked v3.2.6 form;
   - the "(v3.2.6 release candidate)" headings become "(v3.2.6)".
5. **Re-declare every edited segment and the stage**, not just the stage hash. The edited segments are `header-3-rc`, `header-5-rc`, `concordance-rc` and `VII8-post-v3.2.5-notation-rc`. Each spec entry must name its predecessor with `replaces`. The tool refuses to write `ITEMS.json` if any previously declared segment disappears without an explicit `replaces` or `retire`. The lock commit must not retire any content segment.
   ```powershell
   python tools/declare_kernel_segments.py v3.2.6-locked "<spec JSON: one entry per edited hunk, with replaces = its -rc id>" kernel/inputs/2026-10-11/sources
   ```
6. **Verify with an input root that resolves the new authority paths.** `.` is the repository root, which contains `docs/releases/v3.2.6/`:
   ```powershell
   python tools/verify_kernel_base.py
   python tools/verify_kernel_next.py --input-root kernel/inputs/2026-10-11/sources --input-root kernel/inputs/2026-10-11-bibliography/sources --input-root .
   python -m unittest discover -s tools/tests
   python tools/check_omega2_rings.py
   ```
   All four must pass, with no MISSING INPUT. The verifier then also checks that the cited lock-record bytes match their pins, and that every mapped item id is still present in `kernel/next/kernel.md`.
7. **Final check.** Codex re-runs these checks on the lock commit, confirms the lock records quote Robin verbatim, and confirms that no standing changed beyond "item lock pending" becoming "item-locked".

## Known carry-overs

- `kernel/next/bibliography.md` is carried byte-identical to its pinned source (BIB-01), so its changelog paragraph still names the working assembly. Changing it requires a newly declared source. That is outside this candidate.
- The graph slice (#18) is held until after the release. Its export must be rebuilt against the final stage.
- The ambiguous "Def 9.7 (product-torus / Clifford-family shells)" reference in the locked II.23.9 dependency list is recorded by the graph slice. It is not changed here.
