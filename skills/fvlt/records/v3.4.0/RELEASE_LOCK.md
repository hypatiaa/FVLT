# FVLT v3.4.0: release lock

**Locked by saphir on 2026-11-03.** The lock word, verbatim:

> v3.4.0, lock it

saphir had assigned the label the same day ("lets go", in answer to the proposed v3.4.0, a minor release; `RELEASE_CANDIDATE.md`). v3.4.0 is a minor release on the locked v3.3.1. It becomes the release of record, and v3.3.1 is superseded. The v3.3.1 bytes and their records are unchanged and stay as history.

## Locked artifacts

| Artifact | SHA-256 |
|---|---|
| `kernel/post-v3.3.1/kernel.md`, v3.4.0 LOCKED (600,959 bytes, 5,624 LF-terminated lines, 187 native tags) | `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2` |
| The same content as the release candidate (label round, commit `c2a40d4`), independently label-verified | `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d` |
| The same body before the label round, as checked by the fix-round-1 verifier (commit `1f6cd7a`) | `eb898511022c25d0ab43d836ca238893ca7452b3d8fd58f5e3abde0120ef859f` |
| `kernel/post-v3.3.1/CORRECTIONS.json`, the plan (status `LOCKED_RELEASE_v3.4.0`) | `9d1309712ab2fac9210a688c3a8195e81ae862e490e59fdda668adabd80e8d5e` |
| `kernel/post-v3.3.1/ASSEMBLY.json` (17 active segments) | `26ebb53225219b3a765ed3c20941fa0af5fd8884e53f28d6ee1216ab5df7b63e` |
| `kernel/post-v3.3.1/CORRECTIONS.diff` | `bb1f6b41faf706faad7f134e15c4a62fe406e2c7e9cfc0a54517242c68b86f83` |
| `kernel/post-v3.3.1/ITEMS_ADDED.json` (item index, policy rule 8; Lean link, rule 9) | `7c602cdf21f27205d85ac17745ef01929d489edbe760c9a8808b48c16aec4fc2` |
| `kernel/post-v3.3.0/kernel.md`, v3.3.1 (superseded; the base pin of the plan) | `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| `kernel/successor/kernel.md`, v3.3.0 (superseded) | `35ca26ee4cc68fee56013a769070eb14240ddf8aa8376b038a29c3d470e2b5ce` |
| `kernel/next/kernel.md`, v3.2.7 (superseded) | `b8266896dad305356faa76c7248338d3aed37115f8c434f7727475f28ad42a81` |

The folder keeps its name `kernel/post-v3.3.1/`, as v3.3.1 lives in `kernel/post-v3.3.0/`. The hashes are of the LF bytes (`.json` and `.diff` are not `eol=lf` in `.gitattributes`; on a Windows checkout with `core.autocrlf=true`, hash a copy from `git -c core.autocrlf=false archive`).

## What v3.4.0 changes

There is one addition, under the item-addition policy adopted by saphir on 2026-11-03 (`docs/governance/KERNEL_ITEM_ADDITIONS_v0_2.md`, policy v0.2, sha256 `6f7acb1995253d359eb615de127a767d1b58bbd3259a215f8e7d4762229db85c`; "1. Yes, adopt."; merged PR #72, `bdc725b`, with the v2 builder). It is the policy's first use, ordered by saphir the same day ("2. Go after 1."). It came from candidate v0.1.2 (`docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/FVLT_SCD_CANDIDATE_v0_1_2_20261103/CANDIDATE_RMK_9_7j_1_SYMMETRIC_CHAINS_v0_1_2.md`, sha256 `fd13dc858a80ba76704e25f96b8b7c726174107b9cffa34766363dc57ea527bf`), after the line review on PR #73; the item route R-4 was saphir's ("I like your leans, go with them").
- **Rmk 9.7j.1 (Symmetric Chain Decomposition by the Diagonal Tensor Rule)**, `RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION`, Part II / II.17, directly after Rmk 9.7j. Tag:
  `<!-- id: RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION | register: remark | status: unconditional (classical, cited) + interpretive (address) | provenance: adapted-classical | depends: 9.7j -->`
  It enters with the status in its tag (rule 7). Kernel line 2124, byte 244437.

There are 8 replacements against the v3.3.1 bytes in `kernel/post-v3.3.1/CORRECTIONS.json`:

| Replacement | What it does |
|---|---|
| `SCD-RMK-9.7j.1-ITEM` | Inserts the tag and Rmk 9.7j.1 (the declared native item addition) |
| `SCD-CONCORDANCE-VII2a` | VII.2a: new table "Post-v3.3.1 item additions (v3.4.0)" with the row for Rmk 9.7j.1 (rule 8) |
| `SCD-BIB-VII9` | VII.9: note "v3.4.0 citations (Rmk 9.7j.1)" naming the three cited works |
| `SCD-RELEASE-SCOPE` | Release scope: 186 inherited identities in order, plus one declared addition, 187 in total |
| `POST331-HEADER-TITLE`, `POST331-HEADER-VERSION`, `POST331-CHANGELOG`, `POST331-FOOTER` | Release metadata: title, version paragraph, changelog comment and footer for v3.4.0 (LOCKED). The v3.3.1 version record and the earlier changelogs are kept as history |

The 186 inherited native identities keep their order and their tags are byte-identical to v3.3.1; 187 tags in all. `allowed_native_tag_changes` is empty. The v2 builder `tools/build_successor_kernel_v2.py` builds the plan; the v1 builder refuses it by design, because the plan declares a native item addition.

Compared with the release candidate `516fbbc5…`, the lock changes release metadata only: kernel lines 5 (version paragraph) and 9 (changelog comment), from "release candidate; lock pending saphir" to the lock wording with saphir's words, and the sentence "Until the lock, v3.3.1 stays the release of record." becomes "It supersedes v3.3.1 (…, LOCKED by saphir 2026-10-30) …", as at the v3.3.1 lock (`857ac96`). The title and footer already carried the label. The text of Rmk 9.7j.1 and its tag are byte-identical to the candidate. Details: `kernel/post-v3.3.1/README.md` and `BUILD_NOTES.md`, "Lock round".

## Item-locked text

`ITEM_LOCK_INTERSECTIONS.json` (`62c48f78f7b9ba4f9bd4bbc220f2b080f8c46ab2b546297a07920c97efb3c2df`) is the output of `scripts/item_lock_check.py` (`188655896b0323d7dd703d461931179a4dc568c60aa9cbdbc83cd24ae5b94dc7`), regenerated at the lock after its `release` string was set to the locked form. Against the candidate's output (`ff0d2bcc8ca5ea9a5ed8bf4b46a6c71bed41401099676016bd2952731f2f92e4`) only two fields differ: `release`, and `plan_sha256` (the plan's hash changed with the lock metadata). Every row, `in_lock_spans` and `loose_only_hits` are unchanged.

- **Result:** `"in_lock_spans": []`. No replacement of v3.4.0 falls in any of the 17 v3.2.7 item-lock spans of `docs/releases/v3.3.0/ITEM_LOCK_INTERSECTIONS_v2.json` (strict ranges).
- **Loose-only hits:** `SCD-BIB-VII9` (v3.2.7 line 5393) and `POST331-FOOTER` (5552) fall only in Cor 14.5a's loose range, which runs to the end of the file because Cor 14.5a is the last native tag of v3.2.7; its strict span ends at 5250. Neither is Cor 14.5a text (`RELEASE_CANDIDATE.md`, "Item-locked text").

v3.4.0 edits no item-locked text and renews no attestation.

**Stale pin in the candidate record.** `RELEASE_CANDIDATE.md` pins `scripts/item_lock_check.py` as `cf4f024d41474f99…`. That pin predates the C-2 docstring fix made in `c2a40d4` after the label verify; the script committed at `c2a40d4` hashes to `97251b3adf15e5a2…`. Only the docstring changed, and the candidate output `ff0d2bcc…` is unaffected. The candidate record is left unedited; the script as locked is pinned above.

## Verification chain

| Record | Path | SHA-256 | Outcome |
|---|---|---|---|
| Plan verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/VERIFY_REPORT.md` | `746744b9b7b04a75bd72994577b6d8b6638c4a87ba4a1a56eb06e2a10a0014bc` | PASS WITH FLAGS on the first build `07ff8b9fdbe57fafd37e3b815115cd2071b450052f6a09da30dfc686db3ef408` (F-1 to F-6) |
| Statement-match review (rule 9) | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/statement_match/STATEMENT_MATCH_REVIEW.md` | `d8ebda6b144c3c564148d54ba95322c897f4ae8274168ef572155e1c4c9372d7` | MATCH WITH CORRECTIONS on `07ff8b9f…`; corrections applied in fix round 1 |
| Fix-round-1 verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/fix1_verify/VERIFY_REPORT.md` | `4bc52f4d00826a89634d25037518ceff1340713ec5fcd0dcb1dd974dff963390` | PASS WITH FLAGS on `eb898511022c25d0ab43d836ca238893ca7452b3d8fd58f5e3abde0120ef859f`; the statement-match verdict carries over |
| Label verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/label_verify/VERIFY_REPORT.md` | `d79e956e14a4d6ee8f0999578412e8f77ad41cb2a540a6dea4c140b1b46836a4` | PASS WITH FLAGS on the release candidate `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d` (flag F-1; cosmetic C-1, C-2 fixed at `c2a40d4`) |
| Lock verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/lock_verify/VERIFY_REPORT.md` | `5f09ded13ebb4772117675b35dc12076f4db26fec6ae9ea91d5d0ec023196f78` | PASS WITH FLAGS on `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2` (findings 1, 3, 4 applied in the lock commit; finding 2 cosmetic, left as is) |

## Flags carried at the lock

- **F-1 (label verify).** Policy v0.2, line 63, lists "update the skill-bundle count to 187" as a v3.4.0 follow-up. It does not apply: the repository bundle `skills/fvlt` is the v3.2.6 package, where 186 is correct, and the v3.4.0 skill will be a new local package built after the lock. F-1 was reported to saphir before the lock word; the lock was given with it reported.
- **F-3 (plan verify; `RELEASE_CANDIDATE.md`, open item (b)).** The bibliographic details in the VII.9 note (journal data for de Bruijn, van Ebbenhorst Tengbergen and Kruyswijk (1951) and for Greene and Kleitman (1976), and what arXiv:1809.00114 is) are not checked against the papers. This is an open limitation carried by the release, not resolved.

## Standing

- No standing upgraded, and no status label change on any inherited item. No existing native tag changes. The added item enters with the status in its tag: unconditional (classical, cited) + interpretive (address).
- The Lean link (`ITEMS_ADDED.json`) covers finite instances (N = 720, 30030, 720720) and general one-step rank lemmas only; it does not prove the remark in general. `status_effect: none` (rule 9).
- `kernel/post-v3.3.0/` (v3.3.1), `kernel/successor/` (v3.3.0) and `kernel/next/` (v3.2.7, with `ITEMS.json` and the bibliography) are unchanged. `kernel/post-v3.3.0/README.md` gains a "Superseded (2026-11-03)" paragraph only.

## Verification

Run from the repository root, on LF bytes:

```
python -I -B tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.1 --check   # v3.4.0: PASS, 0d6beee2…, 8 replacements, 186 preserved, 1 addition
python -I -B tools/build_successor_kernel.py --folder kernel/post-v3.3.1 --check      # refuses (exit 1), by design
python -I -B tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.0 --check   # v3.3.1 unchanged: PASS, e4953308…
python -I -B tools/build_successor_kernel.py --folder kernel/post-v3.3.0 --check      # PASS, e4953308…
python -I -B tools/build_successor_kernel.py --check                                  # v3.3.0 unchanged: PASS, 35ca26ee…
python -I -B tools/tests/test_build_successor_kernel_v2.py                            # 11 tests OK
python -I -B docs/releases/v3.4.0/scripts/item_lock_check.py                          # reproduces ITEM_LOCK_INTERSECTIONS.json (LF output)
python -I -B tools/verify_kernel_next.py --input-root kernel/inputs/2026-10-11/sources --input-root kernel/inputs/2026-10-11-bibliography/sources --input-root .
python -I -B tools/verify_kernel_base.py
python -I -B tools/tests/test_fvlt_skill_bundle.py                                    # needs .git; checks the v3.2.6 bundle (186)
```

Results at the lock: `kernel/post-v3.3.1/BUILD_NOTES.md`, "Lock round".

## Not included

- **Skill package.** No change to the repository skill bundle `skills/fvlt` (the v3.2.6 package; 186 is correct there). The v3.4.0 skill package is built locally after the lock.
- **Bibliography.** Full entries for the three cited works belong in the working bibliography (`kernel/next/bibliography.md`, part of the locked v3.2.7 stage), which this release does not edit.
- **Lean.** No Lean change in this repository.
