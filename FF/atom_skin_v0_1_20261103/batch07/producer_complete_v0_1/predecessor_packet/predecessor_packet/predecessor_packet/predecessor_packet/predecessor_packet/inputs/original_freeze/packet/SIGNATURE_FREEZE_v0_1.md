# FF-2 input, signature and job-template review packet v0.1

Status: PROPOSED, awaiting Skeleton's input/signature/template acceptance. No FF-2 proof, Lean invocation or numerical check has run. Robin's execution go and the accepted FF-2-before-FF-3 sequence are already recorded; this is the existing technical review gate, not a renewed permission request.

## Exact declaration bytes

The authoritative proposed definition text is `FF2_DEFINITIONS_PROPOSED_v0_1.lean.txt`. The authoritative proposed theorem-header text is `FF2_HEADERS_PROPOSED_v0_1.lean.txt`. Both are intentionally review text, not an executable file with admitted proofs. There are 28 named headers: 21 for A1–A8, 7 for B1–B2, including the explicit data/coordinate bridge lemmas needed to avoid weakening those rows. `TARGET_INDEX_v0_1.json` records the exact names and module allocation.

All proposition hypotheses are explicit declaration binders. No section-level mathematical hypotheses, chosen prime list, upper dimension bound, bounded test universe, or optional abstract group action is part of these statements. Bound witnesses in `cyclicDir`, `mkEdge` and `squareAt` are construction proof fields included in the proposed data definition bytes; no target theorem proof is supplied. Any necessary change to those data definitions or to a target header returns to signature review, including a change discovered at first elaboration.

Implementation layout:

| Module | Frozen contents/targets |
|---|---|
| FVLTAtomSkinDataV1 | The complete AtomSkinV1 definition namespace in the definition text, preceded by import Mathlib and open scoped BigOperators. |
| FVLTAtomSkinCountsV1 | Import the data module; A1–A6 headers (16 theorems), in the same namespace. |
| FVLTAtomSkinPenV1 | Import the data module; A7–A8 headers (5 theorems), in the same namespace. |
| FVLTPillowcaseDataV1 | The complete PillowcaseV1 definition namespace in the definition text, preceded by import Mathlib. |
| FVLTPillowcaseV1 | Import the pillowcase data module; B1–B2 headers (7 theorems), in the same namespace. |

The two data modules have generated declarations even though they have no target theorem headers; they must also receive nonempty strict all-constant replay. Their declaration counts are not guessed before elaboration. Data extraction preserves the complete relevant namespace contents byte-for-byte; import/module boilerplate is separately pinned in each concrete job. Public helper definitions or additional theorem statements require an additive reviewed freeze successor. Private proof helpers may be added under the reviewed template, must keep explicit hypothesis binders, and are included in strict replay and the support inventory.

## Semantic boundaries to review

- A1 chi is computed from actual subtype cardinalities, rather than defined by the desired formula.
- A2 identifies both actual incident-square constructors and proves they are distinct, exhaustive and exactly two.
- A3 supplies the actual incident-edge/direction equivalence and identifies square-incidence link adjacency with the labelled cyclic relation. It does not define link adjacency to be the desired cycle.
- A4 gives opposite integer edge coefficients and the zero total Finsupp boundary.
- A5 connects the representative edges to the full cube adjacency and proves an actual finite-prefix path witness.
- A6 keeps all subtractions involving chi and omega minus four in integers; omega=3 has numerical genus zero. There is no topological genus or realization theorem.
- A7 states both incidence and the directed incoming/outgoing coefficient equalities, with the same sign factor. Sharing a square alone is insufficient.
- A8 returns the whole vertex/back-direction state at four, rules out steps one through three, and identifies the exact four-corner set.
- B1 uses the corrected tagged boundary/front/back key of the template and the declared arithmetic relation, not the withdrawn raw net equality.
- B2 defines the fixing equation explicitly: `(2ia-X, 2jb-Y)=(X,Y)`. The origin half-turn is permitted, with a separate theorem that every half-turn map is nonidentity. Nonzero translations fix nothing. The fixing set is exactly the union of four distinct arithmetic classes. There is no asserted continuous branched cover or unnamed stabilizer action.

## Inputs and environment

`INPUT_FREEZE_v0_1.json` pins the closed copied input files, including the exact accepted order, owner review, conditional go, sequencing record, governing FF-1 rules, three-host library readiness receipt, viewer template and generated page. The template and page independently matched their work-order pins. The skin is instrument-tier; no kernel-native item is being added or promoted.

Library v20 is current by a fresh nucleus directory-only probe. Its complete SHA256SUMS passed, the file-mode scan printed no writable regular files, and the Lean executable and inspected API sources are pinned in `API_INSPECTION_v0_1.md`. This is current read-only evidence on nucleus, not a fresh owner rebuild on three hosts. Opus's recorded readiness supplies the separately attributed three-host checks. No mathematical execution occurred on Neo or nucleus during this preparation.

## Concrete execution gate

`JOB_TEMPLATE_v0_1.json` and `RUN_FF2_v0_1.py` are proposed exact review artifacts. The runner has not been executed. It requires recorded input/signature/template acceptance, an accepted bound template hash, accepted concrete job hashes, an independently reviewable source/signature/import-closure comparison receipt, fresh capacity evidence and a host reservation before launch. The signature-freeze hash in that binding names the accepted packet manifest. The proposed template itself has no acceptance status and cannot satisfy the runner's BOUND_ACCEPTED check.

Each concrete job pins all staged sources and dependency objects, names its prerequisites, and uses an isolated fresh attempt/build area. Replay and named-axiom jobs require the exact successful own-compile receipt and object hash. No writes into the library or its caches are allowed. Project imports are checked recursively against the reviewed closure; G1 is excluded. The current files need no FF-1 or Rule 30 module import merely to express their mathematical targets.

One CPU, 8 GiB address space, Lean M7680 and s65536, 256-process ceiling, 64 MiB output ceiling, 240 seconds per child, and 1800 seconds per development batch starting before staging are proposed. Fresh capacity/reservation precedes each binding. A newer library version requires rebinding review rather than silently using v20. The runner rechecks library pins and complete checksums before and after each child. Only the owned child's process group is terminated on timeout.

Proof-body iteration may use additive attempt folders under the accepted development template; a failed compile stops dependent calls. A changed definition/header, genuine final checker/axiom failure or statement mismatch returns the affected line to review. Compile, named theorem axiom reporting and strict replay have separate records. Strict replay audits every introduced constant, including constructors, recursors and private helpers; imported dependencies are reused, not replayed by that check.

No FF-3 build, Part C, viewer edit, commit, library sync or kernel change follows from acceptance of this packet. The producer result still needs independent statement-fidelity review and independent recompile/replay before any final PASS. Historical false and superseded proposals remain preserved outside this additive packet.
