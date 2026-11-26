# FVLT v3.4.0: minor release candidate (release lock pending saphir)

**Standing: release candidate; lock pending saphir.** v3.4.0 is not locked. Until saphir locks it, v3.3.1 stays the release of record. There is no `RELEASE_LOCK.md` in this folder because there is no lock.

## Label

saphir was asked for the label of the successor that adds Rmk 9.7j.1, with the proposal "v3.4.0, a minor release". saphir answered, on 2026-11-03:

> lets go

So the label is **v3.4.0**. The lock was not asked for in that exchange and has not been given. The policy (`docs/governance/KERNEL_ITEM_ADDITIONS_v0_2.md`, rule 6) requires at least a minor version for an added item, and leaves labels and locks to saphir.

## What is in the candidate

| Artifact | SHA-256 |
|---|---|
| `kernel/post-v3.3.1/kernel.md`, **v3.4.0 release candidate** (600,931 bytes, 5,624 LF-terminated lines, 187 native tags) | `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d` |
| The same content before the label round, as checked by the fix-round-1 verifier (commit `1f6cd7a`) | `eb898511022c25d0ab43d836ca238893ca7452b3d8fd58f5e3abde0120ef859f` |
| The first build, as checked by the plan verifier (commit `a7ccc2d`) | `07ff8b9fdbe57fafd37e3b815115cd2071b450052f6a09da30dfc686db3ef408` |
| Predecessor `kernel/post-v3.3.0/kernel.md`: v3.3.1, LOCKED by saphir 2026-10-30 ("v3.3.1, lock it"), unchanged | `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| `kernel/post-v3.3.1/CORRECTIONS.json` (the plan; status `RELEASE_CANDIDATE_v3.4.0`) | `cba5b57dea1e44fa8c7ec870d13bf85a318b63ad89e56b6d5c1ff0b898993da4` |
| `kernel/post-v3.3.1/ASSEMBLY.json` (17 active segments) | `0deeba82f9bf45d6e18d516b81a4f72ee158aa26f7f7e62edef3abd0a87f90c5` |
| `kernel/post-v3.3.1/CORRECTIONS.diff` | `f4820701f0cca6f4e02d4765c09cc96072d25df406ffd3922cc5714bd223469f` |
| `kernel/post-v3.3.1/ITEMS_ADDED.json` (item index, rule 8; Lean link, rule 9) | `3f9403586cd2af1520fda5f9c1ab8ae42a4a2d02a9f355341d97753f5de24b9e` |

The folder keeps its name `kernel/post-v3.3.1/`, as v3.3.1 lives in `kernel/post-v3.3.0/`. Its README and BUILD_NOTES are not pinned here; they are edited after the jobs.

## What v3.4.0 adds

One declared native item, under the item-addition policy adopted by saphir 2026-11-03 ("1. Yes, adopt."); this is its first use (rule 10), ordered by saphir the same day ("2. Go after 1."):

- **Rmk 9.7j.1 (Symmetric Chain Decomposition by the Diagonal Tensor Rule)**, Part II / II.17, directly after Rmk 9.7j. Tag:
  `<!-- id: RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION | register: remark | status: unconditional (classical, cited) + interpretive (address) | provenance: adapted-classical | depends: 9.7j -->`
  It enters with the status in its tag (rule 7). Kernel line 2124, byte 244409. From candidate v0.1.2 (below), with the wording adaptations listed in `kernel/post-v3.3.1/README.md`.

With it come three bookkeeping changes:
- **VII.2a:** a new table "Post-v3.3.1 item additions (v3.4.0)" with the row for Rmk 9.7j.1 (rule 8).
- **VII.9:** a short note "v3.4.0 citations (Rmk 9.7j.1)" naming the three works the remark cites.
- **Release scope:** "all 186 inherited native item identities and their order are kept, and v3.4.0 inserts one declared native item …, for 187 native item identities in total."

And release metadata: the title, the version paragraph (the v3.3.1 record is kept as history), the v3.4.0 changelog comment (earlier changelogs kept) and the footer.

There are 8 replacements against the v3.3.1 bytes. The 186 inherited native identities keep their order and their tags are byte-identical; `allowed_native_tag_changes` is empty.

## Builder

`tools/build_successor_kernel_v2.py` (`2a16b1ba15bfeccedeb360f7c83d57efb27bb7bf2aa877994d84548422ce1e1a`) builds and checks this plan. **v1** (`tools/build_successor_kernel.py`, `94f8f4b31df85971610cb4018ae796b79aa1cb99b3ed13bb82f395a4a144523a`) **refuses it by design** (`ValueError: Native identities or their order changed`), as the policy says. v2's tests: `tools/tests/test_build_successor_kernel_v2.py` (`669d9d5eba04ab8ece4cf8a7b56c5c431924dea3c0da76e977a18d8b52052b05`).

## Reviews and verification records

| Record | Path | SHA-256 | Outcome |
|---|---|---|---|
| Policy | `docs/governance/KERNEL_ITEM_ADDITIONS_v0_2.md` | `6f7acb1995253d359eb615de127a767d1b58bbd3259a215f8e7d4762229db85c` | ADOPTED by saphir 2026-11-03 |
| Check spec (the reviewer's) | `docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/FVLT_SCD_CHECKS_v0_1_20261103/inputs/SCD_9_7j_1_CHECK_SPEC_v0_1.md` | `77b928390270aa7128cd73d3877fac2e7e4b51fe56e9ea1f5f451f1a48c37855` | spec for S-01 to S-03 and L-01 to L-03 |
| Check runs (S-01 to S-03d, L-01 to L-03) | `docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/FVLT_SCD_CHECKS_v0_1_20261103/SHA256SUMS.txt` | `b753a8abc2237db42b195ef61c559f36700444a26dd355dc51442f6404e8334d` | S-01 20,008 pass / 0 fail; S-02 0 mismatches (34,434 edges); S-03 8/8; S-03d 60,980 strings, 0 invariant spans; L-01/L-03 PASS; L-02 partial |
| Lean report | `docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/FVLT_SCD_CHECKS_v0_1_20261103/lean/LEAN_REPORT.md` | `7edd873c27928a90f604fb27b272cc1b703d7fd6305977d94c07323444e6ee8a` | module `4ae59ae4…3625`, 47 theorems, no sorryAx |
| Investigation index | `docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/README.md` | `beaa98735a482f0aee2e11895fb13c60cfab695f610b45c0abfb63633b93cbd0` | candidate standing |
| Candidate v0.1 (superseded) | `…/FVLT_SCD_CANDIDATE_v0_1_20261103/CANDIDATE_RMK_9_7j_1_SYMMETRIC_CHAINS_v0_1.md` | `5f92883be58b4db11451aae548e668fad9b629cc02dfb08877fee49c38514c18` | the Lean builder's pin |
| Candidate v0.1.1 (superseded) | `…/FVLT_SCD_CANDIDATE_v0_1_1_20261103/CANDIDATE_RMK_9_7j_1_SYMMETRIC_CHAINS_v0_1_1.md` | `2855dd328d2e1e2cb50334f6255c9a05491884f12010ae6086c958536d60ec4d` | check-spec fixes R-1 to R-3 |
| **Candidate v0.1.2** (the text applied) | `…/FVLT_SCD_CANDIDATE_v0_1_2_20261103/CANDIDATE_RMK_9_7j_1_SYMMETRIC_CHAINS_v0_1_2.md` | `fd13dc858a80ba76704e25f96b8b7c726174107b9cffa34766363dc57ea527bf` | after the line review on PR #73; route R-4 by saphir ("I like your leans, go with them") |
| Plan verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/VERIFY_REPORT.md` | `746744b9b7b04a75bd72994577b6d8b6638c4a87ba4a1a56eb06e2a10a0014bc` | PASS WITH FLAGS on `07ff8b9f…` (F-1 to F-6) |
| Statement-match review (rule 9) | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/statement_match/STATEMENT_MATCH_REVIEW.md` | `d8ebda6b144c3c564148d54ba95322c897f4ae8274168ef572155e1c4c9372d7` | MATCH WITH CORRECTIONS on `07ff8b9f…` (folder sums `c67668be1b4406f4ee17ed570cfffe0b646932b124e6f09db0d937e2c4391b28`) |
| Fix-round-1 verify | `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/fix1_verify/VERIFY_REPORT.md` | `4bc52f4d00826a89634d25037518ceff1340713ec5fcd0dcb1dd974dff963390` | PASS WITH FLAGS on `eb898511…`; the statement-match verdict carries over (scout probe SMR2-01); its two wording flags applied at `1f6cd7a` (folder sums `c0aa46231fa3865ab5d435dd02802da786158f521b8d9b363ce9699d4b0ca29b`) |
| Label-round build | `kernel/post-v3.3.1/BUILD_NOTES.md`, section "Label round" | not pinned | jobs V340L-01, V340L-02 (below) |

The flags of the two verify reports: F-1 (statement-match review) and F-4, F-5 were fixed in fix round 1; F-2 (release records, skill bundle) is answered by this folder and open item (c); F-3 is open item (b); F-6 is kept (the folder keeps its name). The fix-1 verifier's two wording flags are in the companion text, applied at `1f6cd7a`.

**The label round itself has not been independently verified.** It changes release metadata only (8 kernel lines, listed in `kernel/post-v3.3.1/README.md`, "Label round"), and the builder's own checks (V340L-01/02) find the item body and all 187 tags byte-identical to `eb898511…`. An independent check of `eb898511…` → `516fbbc5…` is for the owner before the lock.

## Item-locked text

`ITEM_LOCK_INTERSECTIONS.json` (`ff0d2bcc8ca5ea9a5ed8bf4b46a6c71bed41401099676016bd2952731f2f92e4`) is the output of `scripts/item_lock_check.py` (`cf4f024d41474f99c27be55b859e3e5c89e2c6cf2793693bdea50be9a31f2811`), an additive copy of `docs/releases/v3.3.1/scripts/item_lock_check.py` (unchanged, committed bytes `9475c93f…efda2`) adapted to this plan.

- **Spans:** the 17 of `docs/releases/v3.3.0/ITEM_LOCK_INTERSECTIONS_v2.json` (committed bytes `2c4c3d2dae54b5830967b4d5f4710b2291cd996cd413e72a458851a0c7918617`), complete for its five lock sources, compared by their strict v3.2.7 line ranges, as the v3.3.1 script does.
- **Locating a replacement in v3.2.7 lines:** directly if its `old` text occurs once in v3.2.7 (`kernel/next/kernel.md`, `b8266896…2a81`); otherwise through the unique owner whose `new` text contains it, first in the v3.3.1 plan, then in the v3.3.0 plan, each step strictly earlier (an anchor-style insertion repeats its own `old` text in its `new`, so a plan is never searched for its own owners).
- **Result:** `"in_lock_spans": []`. No replacement of v3.4.0 falls in an item-lock span. The item lands at v3.2.7 lines 2126–2128 (II.17, the §G heading), VII.2a at 4644–4645, VII.9 at 5393, and the header, version, release-scope, changelog and footer hunks at lines 3–7 and 5552 through their v3.3.1 and v3.3.0 owners.
- **Cor 14.5a loose bound.** The span file also gives each span a loose range, to the next native tag. Cor 14.5a is the last native tag of v3.2.7, so its loose range runs to the end of the file (5167–5552), past its strict end at 5250 (the line before "### §14.2d"; VII.7 begins at 5255). Two replacements fall in that loose range only: `SCD-BIB-VII9` (5393) and `POST331-FOOTER` (5552). Neither is Cor 14.5a text. The script decides by strict ranges and lists these two under `loose_only_hits` with the reason, so the artifact is visible rather than silently dropped. The plan verifier reached the same reading.
- **Control:** the unchanged v3.3.1 script still reproduces its committed `ITEM_LOCK_INTERSECTIONS.json` byte for byte (V340L-02).

The candidate edits no item-locked text and renews no attestation.

## Standing

- No status label is upgraded. No existing native tag changes. The added item enters with the status in its tag: unconditional (classical, cited) + interpretive (address).
- The Lean link (`ITEMS_ADDED.json`) covers finite instances (N = 720, 30030, 720720, ascending prime order, Div(N) as the exponent box) and general one-step rank lemmas only. It does not prove the remark in general. `status_effect: none` for the link and for the review (rule 9).
- No Goldbach, RH/Landau or centered-comb standing changes. `kernel/next/` (the locked v3.2.7 stage: kernel, `ITEMS.json`, bibliography) is unchanged.

## Reproduce

From the repository root, on LF bytes. `.json` and `.diff` are not `eol=lf` in `.gitattributes`, so on a Windows checkout with `core.autocrlf=true` use a copy from `git -c core.autocrlf=false archive`:

```
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.1 --check   # PASS, draft 516fbbc5…, 8 replacements, 186 preserved, 1 addition
python tools/build_successor_kernel.py --folder kernel/post-v3.3.1 --check      # refuses (exit 1), by design
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.0 --check   # v3.3.1 unchanged: PASS, e4953308…
python tools/build_successor_kernel.py --folder kernel/post-v3.3.0 --check      # PASS, e4953308…
python tools/tests/test_build_successor_kernel_v2.py                            # 11 tests OK
python -I -B docs/releases/v3.4.0/scripts/item_lock_check.py > out.json         # byte-identical to ITEM_LOCK_INTERSECTIONS.json (on Linux)
python -I -B tools/verify_kernel_next.py --input-root kernel/inputs/2026-10-11/sources --input-root kernel/inputs/2026-10-11-bibliography/sources --input-root .
python -I -B tools/verify_kernel_base.py
python tools/tests/test_fvlt_skill_bundle.py                                    # needs .git (reads git blobs)
```

Receipts (membrane, `run_capped_v2.sh`, 4096 MiB / 600 s; library check OK before and after):

| Job | What | Runner exit | RECEIPT.json sha256 | stdout.txt sha256 |
|---|---|---|---|---|
| V340L-01 | plan check, independent draft hash, v2 `--write`/`--check` PASS, v1 refuses, changed lines, tag/body checks | 1 (only my own framing check was wrong, fixed for V340L-02; everything else passed) | `ba185599e3adc9950f3e238a4f0861d14c0ec53cf88fcf2c3bad4ead44747997` | `d103f4d031a0d83ce33387bc1bdf9d508ef4d8cfe563035b2eeb8bc50d39bc04` |
| V340L-02 | the full check suite above, all PASS; item-lock output; skill-bundle test in a git clone | 0 | `822a98053f6ea654fb3975dba857df2672aebbbce6e9ac74f21f92c08033081c` | `1edfcb1c229989932ab5bec1af030d94ccae80d20ba48b728fcb303dad86b8a8` |

Details are in `kernel/post-v3.3.1/BUILD_NOTES.md`, "Label round".

## Open items for lock time

**(a) saphir's lock word.** The lock is saphir's and has not been given. At lock, as at `857ac96` for v3.3.1: the version paragraph and changelog (`POST331-HEADER-VERSION`, `POST331-CHANGELOG`) change "release candidate; lock pending saphir" to the lock wording with saphir's words, the plan `status` becomes `LOCKED_RELEASE_v3.4.0` and its `release.lock` is filled, `ITEMS_ADDED.json` `status` follows, and a `RELEASE_LOCK.md` is added here. The title and footer already carry the label and need no change. The kernel hash changes at lock; the lock record should pin it with the candidate hash `516fbbc5…` as the content checked.

**(b) F-3: bibliographic details in VII.9 are not checked against sources.** The VII.9 note gives *Nieuw Archief voor Wiskunde* (2) 23, 191–193 for de Bruijn, van Ebbenhorst Tengbergen and Kruyswijk (1951), and the title "Strong versions of Sperner's theorem," *J. Combin. Theory Ser. A* 20, 80–88 for Greene and Kleitman (1976). These came from the build order and agree with the builder's and the verifier's recollection, but no one has checked them against the sources (no downloads were allowed), nor what arXiv:1809.00114 is. Whether to check them before the lock is saphir's call.

**(c) The FVLT skill package for v3.4.0.** The local FVLT skills describe locked releases (one copy v3.3.1, one v3.3.0); v3.3.1's was packaged after its lock, and a v3.4.0 package would follow the same way, after the lock and with saphir's checkpoint. The repository's skill bundle is **not affected** by this release. Read precisely:
- `skills/fvlt/v3.2.6/fvlt/` is the v3.2.6 bundle. `tools/build_fvlt_skill_bundle.py` (`SOURCE_COMMIT = e45bac611ae3fd2cbd5e5dbd73382d0dabb3066c`) reads every copied file with `git show e45bac61…:<path>`, so it never reads the working tree.
- `skills/fvlt/v3.2.6/fvlt/scripts/verify_bundle.py` (`NATIVE_IDS = 186`) counts the tags in the bundle's own copy `kernel_v3_2_6.md`, pinned to `4a23d62e…` (the v3.2.6 kernel).
- `tools/tests/test_fvlt_skill_bundle.py` compares the bundle copies with the blobs of `kernel/next/kernel.md`, `bibliography.md` and `ITEMS.json` at that commit, and asserts 186 tags there.
- None of them reads `kernel/post-v3.3.1/` or `kernel/post-v3.3.0/`. Run in a git clone of this branch's HEAD with the label-round files on top (V340L-02): the test 11/11 OK, `verify_bundle.py` PASS (186 native-id tags), the bundle builder PASS (22 files from `e45bac6`). (The v3.3.1 lock record says this test failed on main then; on this HEAD it passes.)
- So the policy follow-up "update `verify_bundle.py` (`NATIVE_IDS = 186`) and `test_fvlt_skill_bundle.py`" does not apply to these files: 186 is correct for the v3.2.6 bundle, and setting it to 187 would make both fail. A v3.4.0 bundle, if one is made in the repository, would be a new bundle with its own count (187).

**(d) Full bibliography entries.** Full entries for the three works belong in `kernel/next/bibliography.md`, which belongs to the locked v3.2.7 stage and is not edited by this release. That is a separate follow-up.

**(e) An independent check of the label round** (`eb898511…` → `516fbbc5…`, release metadata only), as noted above.

## Not in this release

- `kernel/post-v3.3.0/` (v3.3.1), `kernel/successor/` (v3.3.0) and `kernel/next/` (v3.2.7) are unchanged.
- No tool, test, skill or governance file is edited.
- Body text that says "successor draft" (inherited edit records and notes; 8 uses, as in v3.3.1) is left as written; the inherited release-scope sentence says what it means. The inherited sentence "The v3.3.0 and v3.3.1 release standings cover the assembled kernel as a whole …" is a historical statement about those releases and is unchanged.
