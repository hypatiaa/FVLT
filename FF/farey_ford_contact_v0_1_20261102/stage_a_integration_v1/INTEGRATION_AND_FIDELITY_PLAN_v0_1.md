# FF-1 final integration and statement-fidelity review

2026-11-03. **REVIEW PAPERWORK ONLY. No integration execution, new proof development or independent fidelity sign-off.** Robin's Stage A go carries forward. Manager R5 PASS #1435 / ledger 1438 is now recorded in parent `R5_AUDIT_v0_1.md`, SHA256 `832e76cca510f26261313691754d906a198b652f57b0adb5f36a746ba24f0b4e`, independently matched and read in full. All 60 original targets have individual independent compile/replay audits. The 12 computable-bridge links are additional.

## Two final obligations, kept distinct

1. **Integrated package build:** rebuild the eight Stage A modules plus both bridge modules from their exact accepted source bytes in one isolated nucleus folder, then type-check an entry point exposing all 60 original names and 12 bridge names together. Each rebuilt source module receives strict all-constant kernel replay.
2. **Independent statement fidelity:** a reviewer other than the producer reads every frozen statement, its actual namespace/definitions/hypotheses and the cited kernel paragraph, signing each row separately. Compilation and earlier byte-for-byte header audits do not supply this meaning review.

Either review may find an issue. Its classification must distinguish a translation defect, a scope/hypothesis difference, a prose defect or unresolved meaning. A harmless generalization is recorded explicitly, not silently promoted into kernel standing. A changed formal statement returns for review. A kernel correction can only become a separately reviewed Idea Catalog candidate; no kernel bytes are edited here.

## Closed review inputs

`src/` contains byte-identical copies of the ten accepted source modules, independently checked against their audited source hashes. No previous source or object was overwritten. `INTEGRATION_JOB_TEMPLATE_v0_1.json` pins those files, all twenty historical source/object files, eight manager records, expected compiler/library/checker inputs and the prospective runner.

The original v3.3.1 kernel, v0.3 work order, signature freeze and E1/S1 are copied as **REFERENCE** files, byte-identical to their pinned originals. They remain reference inputs, not editable successors. The input freeze and errata retain their exact standing. The bridge's source is also frozen; no deferred converse or new geometry result is added.

`FIDELITY_MATRIX_v0_1.json` has exactly 60 unique A rows plus 12 separate B bridge rows. Each records the actual Lean name, module, source file/hash/line and exact frozen header; A rows also carry a proposed kernel/source locator and standing description. These locators are **producer routing proposals**, not independent verdicts. `FIDELITY_INDEX_v0_1.md` is a readable index. Every independent reviewer/verdict/sign-off field is pending.

`SUPPORT_DECLARATIONS_v0_1.json` separately inventories definitions, instances and 23 private helper theorems. It assigns no new kernel standing. Its lexical source scan also checks that no additional public theorem has escaped the 60+12 lists. Generated compiler auxiliaries are covered by module replay; this source inventory is not a substitute for that replay.

## Proposed integrated build

Use `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_integration_v1`, with `src/` and initially empty `build/`. The dependency path contains **only** the new build directory and the pinned library/Mathlib cache paths. It excludes the historical parent, completion and bridge object directories. Historical objects are hash-protected but never copied into `build/` or reused as project dependencies.

Compile calls use `src/` as their working directory so module identities remain the original flat names; outputs go only to `build/`. Replay calls use the package root containing the checker. The runner records the working directory and refuses any project object in `src/`.

Fixed serial order:

1. FVLTFareyContactV1
2. FVLTFordGeometryV1
3. FVLTFareyCertificatesV1
4. FVLTFareyArithmeticCompletionV1
5. FVLTFordGeometryCompletionV1
6. FVLTUnitFractionSpineV1
7. FVLTPhasePartnersV1
8. FVLTFareyFixturesCompletionV1
9. FVLTFordRationalV1
10. FVLTFordExactCoordinatesV1

For each, compile then strict replay before proceeding. Historical target-declaration counts are 2, 20, 61, 29, 21, 33, 40, 18, 11 and 19, totaling **254**; these are declaration counts, not 254 new mathematical results. All target-module declarations, including private/generated helpers, must replay cleanly with only standard axioms. Standard library imports are reused, not fully replayed.

Finally compile `FVLTStageAIntegrationV1`. This entry point imports R5 and the exact bridge and issues `#check` and `#print axioms` for the 72 fully qualified target names. It introduces **no new theorem or axiom**. Its purpose is combined presence/type/axiom inventory; do not label a vacuous 0/0 replay of it as mathematical verification. The ten nonempty source modules supply the strict replay evidence.

The plan has 21 fixed Lean calls: ten compile/replay pairs and one entry-point compile. Each concrete job pins every staged source and every already built project dependency object it uses. The prospective runner checks sources, historical source/object pins and gate records before and after, records the expanded dependency path and actual new object hashes, and enforces successful prior pairs. New object byte equality with historical objects is informational, not a proof requirement.

## Explicit gates and limits requested

This is a **new integration template**, not an automatic R6 receipt substitution. Opus must accept its runner, source/object strategy, entry-point role and concrete workflow before execution. After that, perform fresh metadata-only nucleus/Tailscale checks of latest library, all expected/observed pins, compiler/Mathlib identity, full checksums, read-only state, capacity, sources and manager gates. If the library moved or any pin differs, return for review. Do not silently switch from v19.

The final bound receipt/template needs explicit manager acceptance unless that decision expressly grants all-match acceptance on verified posting. No such grant is assumed by this draft. Concrete template-bound manifest self-acceptance is requested, with timestamped logs and snapshots, rather than inferred.

Request one independent **1800-second active execution allowance**, starting before remote source staging/build setup, after dispatch acceptance. Local review-paper preparation used no Lean and transfers no prior timing allowance. Same resource caps: one CPU, nice 19, hard 8 GiB, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, at most 240 seconds/call or the remaining deadline, process cap 256, file/output cap 64 MiB, no cores, parent serial lock and no automatic retries.

All mathematical source bytes are fixed. **No proof-body or signature iteration is authorized by this integration job.** A genuine compile/replay/axiom/integrity failure stops it and returns evidence. A pre-verdict harness/path problem is preserved, repaired and resubmitted as needed under the reviewed control policy. A budget failure does not authorize an extension or a mathematical conclusion. No source/module omissions are allowed to make the job pass.

## Independent meaning review protocol

Review every A row against the copied pinned kernel and actual source, not just the routing description. Check field/domain, every explicit hypothesis, guards, quantifier scope, graph/certificate semantics, signs/scales, and exactly what the conclusion asserts. Check the cited item's standing and omitted clauses. Review B rows separately as additional interface theorems, and inspect the support inventory for accidental claim promotion.

The reviewer writes an **additive successor sign-off artifact**, preserving this producer matrix unchanged. It must identify the exact reviewed source/kernel hashes, reviewer identity, one verdict and scope note per A row, disposition of any mismatch and a hash-pinned overall receipt. Suggested verdicts: MATCH, HARMLESS_GENERALIZATION, NARROWER_THAN_SOURCE, TRANSLATION_DEFECT, PROSE_CORRECTION_CANDIDATE, UNRESOLVED; the reviewer explains any non-MATCH rather than treating labels as self-justifying. Classical helpers with no directly named kernel theorem are explicitly classified as such, not given fabricated native IDs.

Independent review can begin on these closed source inputs while the build is pending, if Opus accepts that review scope. It supplies no build verdict, and the build supplies no fidelity sign-off. The producer will not sign its own fidelity rows.

## Final delivery and authorized next step

Deliver integrated source/definition/target inventories, exact accepted control inputs, all 21 job manifests and run receipts/logs, ten nonempty strict reports, 72-name/type/axiom entry-point output, complete integrity receipts, actual object hashes and a closed final manifest. Opus independently checks or reproduces the integrated result under its accepted audit plan. The independent fidelity report stays a separate signed artifact.

Only after the required integrated and fidelity outcomes are recorded can the order's corresponding §10 statuses be assigned. **Robin has now separately authorized library synchronization**, recorded in `CONDITIONAL_LIBRARY_SYNC_AUTHORIZATION_20261103.md`; do not ask the same permission again. That authorization is conditional on both outcomes and still requires a concrete additive synchronization/version/provenance plan, observing the library current at that time and checking nucleus/scout. No sync was performed in this preparation.

No automatic kernel adoption, public release, commit, viewer change, Stage B or FF-2/FF-3 execution follows. Their own scope and gates remain. This packet changes none of the locked or accepted historical files.
