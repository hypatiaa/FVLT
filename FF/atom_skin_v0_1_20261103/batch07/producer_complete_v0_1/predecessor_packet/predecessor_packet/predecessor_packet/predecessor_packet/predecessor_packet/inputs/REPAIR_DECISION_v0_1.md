# FF-2 skin data declaration repair: decision v0.1 (bus #1454, #1456)

2026-11-03. Skeleton (Claude Opus 5.5), under saphir's FF-2 go and the freeze decision `3a525076...` (#1448).

**Decision: ACCEPTED as an additive successor.** `FF2_DEFINITIONS_PROPOSED_v0_3.lean.txt` `a1ea047d...` is accepted with exactly the three declared changes. The original freeze `61ca7137...` stays preserved and pinned.

## What was checked

- **Hashes.** The local files match the postings:
  - request `c9484f41...`;
  - successor `a1ea047d...`;
  - delta `7e09d1b2...`;
  - skin Data02 compile log `50baea4b...` and receipt `4cfff515...`.
- **Diff against `61ca7137...`.** A full `diff` shows exactly:
  - `import Mathlib` replaced by seven targeted imports (boilerplate);
  - `noncomputable` added to `boundary` and `coefficient`, with bodies unchanged;
  - `Fintype` removed from `Sign`'s deriving list, keeping both constructors and `DecidableEq`.

  Nothing else changed.
- **The compile log confirms all three failures:**
  - `boundary` depends on the noncomputable `Finsupp.instSub`, and `coefficient` depends on `boundary`;
  - `Fintype (Edge ω)` and `Fintype (Square ω hω)` were not synthesized;
  - the `deriving Fintype` handler for `Sign` produced an ill-typed `nodup` witness (`Sign.enumList.Nodup` against `(↑Sign.enumList).Nodup`).

  These are declaration and API failures, not false statements.
- **No header depends on the removed instance.** The 28 headers `b4484f6e...` were searched by script:
  - `Sign` appears only as a bound variable `(s : Sign)` in the pen statements, which needs no `Fintype`;
  - `Fintype.card` appears only for `Vertex`, `Edge` and `Square`;
  - `∑ f : Square ω hω` needs `Fintype (Square ω hω)`, which the added `Mathlib.Data.Fintype.Prod` import is meant to supply.

  The headers are unchanged.

## What changes in meaning

- `boundary` and `coefficient` lose code generation only. The statements about them are the same propositions. They can no longer be evaluated (`#eval`) as certificates, and the fidelity review records that. The pen `step`, `key` and all pillowcase definitions stay computable.
- `Sign` has no global `Fintype` instance. If a proof needs one, it may build a local or private instance inside that proof. A public instance or any new public declaration needs a freeze successor.

## Comparison and binding rule from now on

- **AtomSkinData sources** must equal the `FVLT.AtomSkinV1` namespace block of `a1ea047d...` byte for byte, with import boilerplate pinned per job.
- **PillowcaseData** continues against `61ca7137...`. The Data02 source `b8a03b38...` was line-checked: the namespace equals definition lines 100–137 verbatim, and only the import lines differ.
- **Comparison receipts** for skin modules must name:
  - the original freeze manifest `22650c5b...` (kept as the runner's `freeze_sha256`, which the runner asserts);
  - the successor `a1ea047d...`;
  - this decision's hash.
- **Bound templates** keep the condition 3 all-match rule unchanged.
- **Batch clock.** BATCH01 keeps origin 1793757115 and deadline 1793758915. When it expires, the next batch needs a fresh posted binding with a new deadline file, never a reset of this one.
- **All #1448 conditions stand**, including the posted axiom log for every module and my own final recompile, replay and fidelity review.

## Pillowcase data line (recorded, not yet my independent check)

These are the producer's results. I re-hashed them and parsed the logs myself.

- **Compile:**
  - started after posting, exit 0;
  - object `6b656127...`, receipt `172c8926...`.
- **Named axiom report** (`9d54fc92...`): 13 data and constructor names, each with no axioms.
- **Strict replay** (log `d042a050...`, receipt `0ddb6bbd...`):
  - verdict PASS, kernel replay completed;
  - 55 of 55 constants audited, with 0 failures, 0 unsafe and 0 partial;
  - the only axiom used anywhere is `propext`, in generated helpers.
- **Earlier replay attempt.** The replay before the PATH fix failed before any kernel verdict, because the `lean` launcher was missing from PATH. That attempt is preserved as a harness fault.
