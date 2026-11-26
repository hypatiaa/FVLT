# FVLT current-work navigation — 2026-10-12

Proposed navigation metadata alongside the locked release. This index has no mathematical authority.

Captured from repository commit `00764e7b9e14177dad911df0f53688f9334c1a40`. It is a dated snapshot, not a live feed.

The JSON companion is `CURRENT_WORK_INDEX.json` in the skill, or `INDEX.json` in the catalog. Search it by catalog ID, KG ID, title or family before loading a source. Every available repository source has an immutable URL and full SHA-256. A missing source stays missing; request its recorded pin rather than substituting current bytes.

## How to use the standings

Read the released kernel and applicable locks for mathematical claims. `included` is limited by each row's scope; `external` and `proposed` never confer kernel authority. `unassessed` records a coverage gap rather than a guessed classification. Catalog labels are copied as historical attribution. Tests, audits, locks, seating and deployment remain distinct.

The 34 research comparisons target the earlier PR15 kernel (`d01cb344…`), not the current locked kernel. Their line numbers and coverage verdicts remain historical. Reassess a proposed action against v3.2.6 before applying it; the line-93 scope and comb(m) notation findings were already addressed by this release.

## Coverage

- 118 catalog contributions across 16 inherited families, with original standing and source pins.
- 15 newly folded release items, plus the release corrections.
- 34 historical clause-comparison cases, with recorded proposals and non-kernel boundaries.
- 27 companion/software/design routes. Their source code, proofs and database exports remain outside the skill.
- This is selected catalog/repository coverage, not a complete inventory of Robin's local corpus.

## Released additions

| Item | Standing from release metadata |
|---|---|
| Def II.23.9 | item_locked |
| Lemma II.23.9a | item_locked |
| Rmk II.23.9b | item_locked |
| Prop II.23.9c | item_locked |
| Cor II.23.9d | item_locked |
| Lemma II.5g | item_locked |
| Definition II.5h | item_locked |
| Lemma II.5i | item_locked |
| Corollary II.5i.1 | item_locked |
| Corollary II.5j | item_locked |
| Corollary II.5j.1 | item_locked |
| Proposition II.5k | item_locked |
| Corollary II.23.5c | item_locked_attested_seated_false |
| Definition-Proposition II.23.5d | item_locked_attested_seated_false |
| Definition II.23.5e | item_locked_attested_seated_false |

Quote each item's own kernel status, including Goldbach's conditional/not-claimed clauses and attestation seated:false. This table does not replace the item text.

## Companion and software routes

| Work | Relation | Source standing |
|---|---|---|
| [Kernel graph schema v0](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/schema/KERNEL_GRAPH_SCHEMA_v0.json) | external | PROPOSED DRAFT FOR REVIEW; not an accepted schema, database choice, ingestion authorization, or proof authority. Traceability metadata only. |
| [II.23.9 curated graph slice](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/SLICE.json) | external | Draft review slice for five item-locked clauses; export/query identity and navigation only; not accepted schema or ingestion authorization. |
| [II.23.9 external graph ID map](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/GRAPH_ID_MAP.json) | external | Separate external-key map for five item-locked clauses; exact source-span identity/navigation. Human-reviewed standing labels; no database choice or ingestion authorization. |
| [II.23.9 deterministic graph export](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/export/graph.json) | external | Committed JSON export; 22 nodes and 52 edges per saved ArcadeDB report. Offline source-navigation artifact, not a database deployment. |
| [Offline depends-on fixture for Def II.23.9](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/queries/depends-on__fvlt_Def_II.23.9.json) | external | Committed offline query fixture; saved ArcadeDB report records byte-identical result. |
| [Offline depends-on fixture for Cor II.23.9d](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/queries/depends-on__fvlt_Cor_II.23.9d.json) | external | Committed offline query fixture; saved ArcadeDB report records byte-identical result. |
| [Offline supported-by fixture for Cor II.23.9d](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/queries/supported-by__fvlt_Cor_II.23.9d.json) | external | Committed offline query fixture; saved ArcadeDB report records byte-identical result. Recorded standing is reported metadata, not fresh proof verification. |
| [Offline open-points fixture for Cor II.23.9d](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/queries/open-points__fvlt_Cor_II.23.9d.json) | external | Committed offline query fixture; saved ArcadeDB report records byte-identical result. |
| [Bounded ArcadeDB throwaway-test record](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/experiments/arcadedb_bounded/README.md) | external | Saved record describes one Robin-approved bounded compatibility run, not production schema acceptance or ingestion authorization. Reported setup/teardown are operator-reported and lack a retained transcript certifying lifecycle. |
| [Saved bounded ArcadeDB test results](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/graph/ii23_9/experiments/arcadedb_bounded/results/REPORT.json) | external | Recorded result PASS, discrepancies empty; round-trip identical for 22 nodes/52 edges; four fixtures byte-identical; negative control detected. This is a saved test record, not a run in this inspection. Operator lifecycle claims remain separately reported, not transcript-certified. |
| [Serena Tissue offline preview README](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/preview/README.md) | external | DRAFT; approved first offline increment per README. In-memory fake transport only; all proposals pending, Zettel views unpromoted; live ArcadeDB schema acceptance, durable receipts, and promotion remain unfinished. |
| [Serena Tissue offline preview report](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/preview/SERENA_TISSUE_PREVIEW_REPORT_2026-10-08.html) | external | Report labels itself DRAFT / Robin review / Neo / offline only. Historical recorded evidence: 98 pending candidates, 113 SourceDocument proposals, 197 source refs, 407 held relationships; no live-write or promotion receipt. Historical checks were reported there, not rerun here. |
| [Reconciled RC1 schema baseline](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/preview/baseline/tissue_schema_reconciled_rc1.sql) | external | Pinned reference only; explicitly never executed in the preview; no live schema acceptance. Repository intake status is SOURCE_INTAKE_ONLY_NOT_SCHEMA_ADOPTION. |
| [Historical v2 Scout types SQL](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/inputs/2026-10-11/_v2_scout_types.sql) | external | Byte-preserved historical reference package; not live acceptance and not schema adoption per intake manifest. |
| [RC1 schema reconciliation report](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/inputs/2026-10-11/schema_reconciliation_report.md) | external | Historical report says SCHEMA-RECONCILED / LOAD-SMOKE-TESTED, with live ArcadeDB, live Neo4j, deploy/install held. Those are report-recorded checks; source intake explicitly does not adopt the schema or establish live acceptance. |
| [Bounded ReviewQueue writer excerpt](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/inputs/2026-10-11/membrane_perception.review_queue.lines2142-2159.py.txt) | external | Static bounded source excerpt shows proposal path inserts ReviewQueue status=pending and returns queued. It is not evidence of a deployed runtime; whole source withheld due credential-related literals per manifest. |
| [Kernel-to-Neo4j schema requirements](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/inputs/2026-10-11/sources/serena/serena%20early/serena_transfer_2026-07-01/graph/kernel_neo4j_schema_requirements.md) | external | PROPOSED; document says no schema exists yet and it is not staged for a build. Design requirements only; separate from Serena ontology-instance graph requirements. |
| [Kernel graph profile derivation contract](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/inputs/2026-10-11/sources/serena/serena%20early/serena_transfer_2026-07-01/graph/kernel_graph_derivation_contract.md) | external | FROZEN output contract for a future derivation; derivation explicitly NOT DONE. Declared Div720720 profile is scaffold_example, not substrate; no measured derived profile exists. |
| [Catalog current snapshot pointer](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/catalog/CURRENT.json) | external | Pointer names catalog/snapshots/2026-10-11. It is a mutable navigation pointer to an immutable dated snapshot, not a separate evidence result. |
| [Catalog consistency checker source](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/tools/check_catalog_consistency.py) | external | Static checker source present; not executed in this inventory. Checker code is not itself a PASS or snapshot acceptance claim. |
| [2026-10-11 catalog build summary](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/catalog/snapshots/2026-10-11/build_summary.json) | external | Exact recorded summary: curated_records=118, coverage_areas=96, primary_sources=213; also 16 families, 38 negative/boundary records, 61 gap cases. Counts are snapshot metadata, not exhaustive corpus review or proof certification. |
| [2026-10-11 catalog coverage detail](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/catalog/snapshots/2026-10-11/coverage.json) | external | Static coverage detail contains 96 distinct area entries. Build summary records 213 primary_sources. Coverage README says counts include generated evidence/duplicates and that metadata/sample coverage is not exhaustive content review. |
| [2026-10-11 scheduled catalog snapshot README](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/catalog/snapshots/2026-10-11/README.md) | external | Dated snapshot documentation. Build summary scope is October 11 scheduled explicit-backlog reconciliation; no new modified research; original sources read-only. |
| [Centered m-comb companion](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/inputs/2026-10-11/sources/fourier_handoff_clifford/fvlt_centered_comb_lemma.md) | external | Instrument/bibliography-tier lock2026-08-05, outside mathematical kernel; m>=3 EXT at its own gate. Kernel comb(m) notation imports no hypothesis or lemma. |
| [Research intake and exact-clause comparison records (#17)](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/README.md) | external | Historical documentary comparison against PR15;34cases419clauses. Not a proof review or comparison with current lockedv3.2.6. |
| [Zettelkasten intake decisions and unexplained TODO observation](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/zettelkasten/inputs/2026-10-11/README.md) | external | SOURCE INTAKE ONLY / DECISIONS PROPOSED / NO LIVE EFFECT. Preserve unexplained historical TODO hash; proposals and schema/writer drift are not adopted decisions. |
| [Virasoro/Fock and other non-normative kernel history](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/kernel/next/kernel.md) | external | Quarantined/non-normative research and history at II.21-II.22; not active theorem authority. No reinstatement or admission by indexing. |

Graph schema-v0 and its test records remain historical/proposed design evidence. The bounded ArcadeDB PASS does not establish production use; lifecycle claims remain operator-reported. RC1/v2 source shape is not accepted ontology authority. No tool is executed or database written by following this index.

## Research comparison routes

| Case | Work | Recorded proposed action |
|---|---|---|
| [KG-15](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-15.json) | Review elliptic and arithmetic-Fourier candidates before proposing seats | needs Robin decision |
| [KG-23](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-23.json) | Resolve remaining exact-clause comparisons without filename-based conclusions | needs Robin decision (candidates: new remark at II.5 after Cor II.5i.1 stating the classical gap identity &#124;a/q−c/s&#124; = 1/(qs) for det-1 pairs and the filled/open mediant split with an interval-only frontier fence; definitional note in II.13 §9.1a for the degenerate n=1, n=2 cases and the Collapse/Lift bullets; everything else none) |
| [KG-27](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-27.json) | Preserve the central M-comb/Chowla cosine-kernel identity and inspector boundaries | pointer (extend the ALG-5 'Extension boundary (centered comb companion)' pointer at kernel_next.md:4543 to name the parity-specific cosine-kernel identity K_m = delta + 2F_P as companion content; any Chowla attribution needs Robin decision) |
| [KG-29](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-29.json) | Basel/Fourier evaluator and host-link scope versus kernel seating | needs Robin decision |
| [KG-30](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-30.json) | Factorial-oracle chord geometry, pi computation and early S6 interpretation | none |
| [KG-31](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-31.json) | Typed quotient-lift fibre-address calculus | needs Robin decision |
| [KG-32](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-32.json) | Collapse hierarchy: weighted multiplicity versus phase-carrier quotient | needs Robin decision |
| [KG-33](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-33.json) | Fourier-Farey prime-rung realizability and its coverage boundary | needs Robin decision |
| [KG-34](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-34.json) | Derived atoms versus basis fit: a bounded provenance scaffold | pointer |
| [KG-35](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-35.json) | Historical Collapse Atlas missing-core loading failure and standalone repair | none |
| [KG-36](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-36.json) | Selected DFT characters, declared continuous lift and contact versus conjugacy | pointer |
| [KG-37](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-37.json) | Irrational integer-radian near-contacts and pi approximation | none |
| [KG-38](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-38.json) | Farey helix chord joints, contact endpoints and needle-tube separation | needs Robin decision (optional guard remark after Lemma 9.3a / Note 9.3a.1: Lemma 9.3a covers smooth curves only; straight chord polygons meet at exactly-known n = 3 joints and needle segments are pairwise disjoint; only after a cold pass, since the source standing is scoped internal PASS) |
| [KG-39](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-39.json) | Signed-radius helicoid rulings and limits of the torus-bend analogy | none |
| [KG-40](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-40.json) | Cube-sum rational points and hexagonal shape versus arithmetic data | none |
| [KG-41](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-41.json) | PC2 exact saved-crop reconstruction with unresolved pixel residuals | none |
| [KG-42](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-42.json) | RA-3 positive adapter scale, forced RZ1 tuple and conditional audit basis | none |
| [KG-43](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-43.json) | CH-1 reversible byte-chain with derived intermediate expectations | none |
| [KG-44](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-44.json) | Mu3 descent reading and finite Eisenstein shadow of Div(30030) | needs Robin decision (possible finite remark at II.14 after Def 9.7: for squarefree N with m = 6, the xy-shadow of P is ℤ[ω] cut at norm ≤ 4 with multiplicities 10/6/2/1; the source is author-reported only, so a cold pass comes first) |
| [KG-45](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-45.json) | Rhombic period-lattice prototype with separately attached arithmetic | none |
| [KG-46](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-46.json) | Cubic factorial oracle character lift, contact rule and generator repair | none |
| [KG-47](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-47.json) | Historical corrected mathematical-home maps with unvalidated correspondences | none |
| [KG-48](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-48.json) | Jacobian support grading and JSW-B1 blind instrument recoverability | none |
| [KG-51](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-51.json) | Coupled Wilson frequency and branch-gated exact character certificates | needs Robin decision |
| [KG-52](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-52.json) | Farey shell discrepancy, signed gap covariance and Franel growth | needs Robin decision |
| [KG-53](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-53.json) | Divisor comb polynomials, Poisson GCD norms and p-adic Gram realization | needs Robin decision |
| [KG-54](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-54.json) | Signed prime-axis energy and the RH-equivalent coherent scalar | needs Robin decision |
| [KG-55](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-55.json) | Signed correlations, orthogonal prime pairs and recovered block cancellation | needs Robin decision |
| [KG-56](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-56.json) | Elliptic carrier, conjugate endpoints and exact phase addresses | pointer |
| [KG-57](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-57.json) | Cumulative complex-walk sphere versus per-step Clifford lift | pointer |
| [KG-58](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-58.json) | Divisor-comb partial walks and exact spectral gearbox stops | needs Robin decision |
| [KG-59](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-59.json) | Prime-valuation distance bias and precision-limited rotary proposal | needs Robin decision |
| [KG-60](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-60.json) | Exact doubling updates and a conditional coherent-energy scale recurrence | needs Robin decision |
| [KG-61](https://github.com/hypatiaa/idea-catalog/blob/00764e7b9e14177dad911df0f53688f9334c1a40/docs/reviews/2026-10-12-uncertain-cases/KG-61.json) | Prime-extraction local transfer and the cubic recombination obstruction | needs Robin decision |

## Further review routes

- [Def9.7/ALG5 source investigation (PR28)](https://github.com/hypatiaa/idea-catalog/pull/28): Reviewed documentary investigation at the pinned head; prior R2 hold resolved. R1 and parameter choices R2a/R2b remain proposed for Robin, with a separate G4 zero-winding errata candidate. No mathematical correction or admission adopted.
- [Kernel follow-up plan](https://github.com/hypatiaa/idea-catalog/issues/3#issuecomment-6119932681): Coordination proposal. Decisions and review remain separate; this mutable discussion link is not a source-byte pin.
- [Claude skill re-upload/sync observation](https://github.com/hypatiaa/idea-catalog/issues/25#issuecomment-6121131578): Partner-reported single-upload byte-identity and verifierPASS for #27; not a guarantee of future platform behavior.
- [CAT0 line93 evidence draft (PR22)](https://github.com/hypatiaa/idea-catalog/pull/22): Separate historical evidence draft, outside release and index admission. Prior reported retarget/line-ending-pin issues require current review.

## Snapshot refresh

A later refresh gets its own dated/revisioned snapshot and review. Recompute source pins and availability; do not silently repin a drifted source, rewrite this snapshot as though it always described the latest work, or treat a merged proposal as a mathematical ruling.
