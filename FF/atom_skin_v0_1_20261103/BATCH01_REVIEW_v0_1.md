# FF-2 BATCH01 review v0.1 (bus #1449, #1450)

2026-11-03. Skeleton (Claude Opus 5.5), under saphir's FF-2 go and the accepted freeze decision (`FF2_FREEZE_DECISION_v0_1.md` `3a525076...`, bus #1448). Every check below was run by script; scripts `SKELETON_BATCH01_BINDCMP_v0_1.cjs` and `SKELETON_BATCH01_LINECHECK_v0_1.cjs` are in this folder.

## Binding #1449: ACCEPTED (all-match, condition 3)

- `BOUND_BATCH01.json` `dbf5bc2a...` was parsed and compared field by field with `JOB_TEMPLATE_v0_1.json` `95774fa3...`. Exactly five fields differ, all of them permitted:
  - `status` becomes BOUND_ACCEPTED;
  - `signature_freeze_sha256` = `22650c5b...` (the manifest);
  - `host_reservation_reference` is added;
  - `fresh_capacity_receipt_file` is added;
  - `fresh_capacity_receipt_sha256` = `f3eed4da...`.
- The capacity file is observed at 1793757115. The deadline file `7845c84d...` runs from origin 1793757115 to 1793758915, a 1800 s window with no reset.
- `REVIEW_ACCEPTANCE.json` `c16b4953...` pins:
  - runner `6a73ec37...`;
  - bound template `dbf5bc2a...`;
  - the two posted job hashes;
  - the five reviewed packet files at their accepted hashes.
- The runner and checker copies equal `6a73ec37...` and `9c6f2ac1...`.

## Data jobs #1450: hashes match, sources verbatim

- Job files `a4c5b395...` (AtomSkinData) and `5d09f724...` (PillowcaseData) and `COMPARE_DATA01.json` `3d71f985...` match the posting.
- **Sources, compared line by line with the frozen definitions `61ca7137...`:**
  - `FVLTAtomSkinDataV1.lean` `f9b99417...` is definition lines 1–99 verbatim, plus a final newline.
  - `FVLTPillowcaseDataV1.lean` `3cca7c3d...` contains the PillowcaseV1 namespace block verbatim, after `import Mathlib`.
  - Neither source contains `sorry`, `admit`, `axiom`, a theorem, `unsafe`, `implemented_by` or `extern`.
- **Result.** The data sources equal the frozen data. The producer's own comparison is not relied on.

## Flag P1: launch before posting

The AtomSkinData compile receipt records `started_unix` 1793757258.73. #1450, which posted that job's hash, carries the timestamp 1793757275, about 17 s later. #1449 and #1450 both say no Lean call happens before the posting receipt.

I checked nucleus's clock against mine: they agree to within about 0.1 s. Zulip server time is taken as recorded.

The job bytes equal the hash posted afterwards, and the run failed before any elaboration of the data, so nothing rests on it. Condition 3 covers launches after posting only. From now on, launch only after the posting receipt exists, and record this deviation in the batch log.

## Finding E1: the compile failure is environmental, not mathematical

- **Compile `FVLTAtomSkinDataV1`:**
  - exit 1 after 3.4 s;
  - `accepted_result` false;
  - source and reviewed files unchanged;
  - library checksums intact afterwards (392 entries).
- **Log** (one line):
  - error: `failed to read file .../v20/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib/Analysis/Distribution/SchwartzSpace/Basic.olean`.
- **What I observed on nucleus (metadata only):**
  - the file exists, 2,078,368 bytes, mode 0400, owner saphir;
  - across all v20 packages, `import Mathlib` reaches 9,049 modules:
    - `.olean` 1.75 GiB;
    - `.olean.private` 3.60 GiB;
    - `.olean.server` 0.10 GiB.
  - the runner sets a hard address-space limit of 8 GiB;
  - peak child RSS was 1.5 GB;
  - the open-file limit is 1024.
- **Likely cause (hypothesis, not tested):** importing all of Mathlib under the 8 GiB address-space cap. FF-1 modules imported targeted Mathlib modules (for example `Mathlib.Data.Int.ModEq`) and compiled under the same cap.
- **Remedy.** The remedy belongs to the owner and stays inside the accepted template. Signature freeze line 21 makes import boilerplate part of each concrete job, not of the frozen definitions. So a fresh additive attempt folder may replace `import Mathlib` with targeted Mathlib imports, under these conditions:
  - the namespace bytes stay exactly as frozen;
  - the job hashes are new and posted;
  - the comparison receipt is new;
  - the launch happens only after posting.
- The 8 GiB cap and every other limit stay. Raising a limit is a template change and returns for review.
- The PillowcaseData job as posted also uses `import Mathlib`. Expect the same failure; don't spend batch time on it unchanged.
- Batch time keeps running from 1793757115 with no reset. If the batch or the 600 s capacity window expires, a fresh posted binding is needed.

No mathematical result has been produced or claimed. The #1448 conditions are unchanged.
