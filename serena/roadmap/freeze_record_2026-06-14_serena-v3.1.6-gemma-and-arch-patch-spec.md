# Freeze Record + Architecture Patch Spec — Serena v3.1.6

**Date:** 2026-06-14
**Authority:** Chris (raven) cold-pass HOLD; Robin ruling to freeze; Opus accepts in full.
**Type:** status record + forward spec. Additive. Freezes one artifact, specifies the next.

---

## FROZEN ARTIFACT

```
serena-v3.1.6-deploy-gemma.tar.gz
SHA-256: e7c6f2c74bda0254bfcd9335b10cb93d53969311a256ecd81051b6df9c72fe30
         (verified against Chris's declared hash 2026-06-14 — byte-identical)
STATUS:  HOLD for deploy
ALLOWED USE: Phase 1 Nucleus kernel/API staging ONLY
```

This artifact is a **model-name patch, not an architecture fix**. The filename `-gemma`
oversells it; its honest scope is "perceiver string repointed to Gemma in some config
surfaces." It is not a deploy bundle. Do not run graph writes or Scout from it unchanged.

### KNOWN ERRATA (logged as findings; NOT to be patched individually)

Per Robin/Chris ruling: do **not** create a third tarball around any single fix. A
one-line patch with its own filename would imply more was repaired than was — the same
overreach that produced this record. These errata travel with the frozen bundle as
documented findings until the coherent architecture patch supersedes it.

1. **Audio capability claimed in comments but not implemented in gateway.** The
   `.env.example` perceiver comments (added 2026-06-14) state "image+audio+video," but
   `scout/membrane_perception.py` has no audio path (no .wav/.mp3/.flac handling, no
   soundfile/librosa). This is a descriptive/empirical register violation introduced by
   the name-patch itself. **Logged, not patched.**
2. **Gemma role still misassigned** in README / DEPLOY_PROMPT — charter still reads as if
   Gemma is the Nucleus *reasoner*. Locked topology: OLMo Think reasons, Gemma perceives.
3. **Scout still old topology** — code runs Scout on Trycoo and writes toward Neo4j
   directly. Locked topology: Scout on Neo, proposals only, no direct writes.
4. **No receipts / adapters / ArcadeDB reconciliation** — `nucleus_store.py`,
   `tissue_store.py`, the receipt ledger, and the v2 tissue merge are all absent.
5. **Scout deps incomplete** — `scout/requirements-membrane.txt` omits `requests` and
   `numpy`, both imported at `membrane_perception.py` lines 43–44. A clean install +
   launch would ImportError. (Verified 2026-06-14.)

### Verified-correct in the frozen bundle (Phase-1 scope)

- `core/config.py` defaults `perceiver_model = "gemma4:12b"`.
- `.env.example` names Gemma 4 12B + optional Neo Scout line.
- `membrane_perception.py` no longer names Molmo as the active perceiver function
  (`molmo_describe`→`perceiver_describe`, `MOLMO_MODEL`→`PERCEIVER_MODEL`).
- Both edited Python files compile; staging smoke 6 pass / 2 skip / 0 fail.
- `measurement_api` reports v3.1.6 in source.
- Stale 3.12 `.pyc` cache removed (41 files, no pre-edit bytecode).

### Note on the variable-name finding (refinement of Chris's list)

The `SERENA_PERCEIVER_MODEL` (env) vs `PERCEIVER_MODEL` (code) naming is **functionally
correct** — the `_env()` helper prepends `SERENA_` automatically — but reads as a mismatch
to an auditor checking correspondence. Classed as a clarity/documentation defect, not a
runtime bug. To be cleaned in the architecture patch.

---

## NEXT ARTIFACT (gated; build then send for audit)

```
serena-v3.1.6-architecture-patch-rc1
```

A coherent architecture patch, **not** another string patch. Built as one piece so no
partial pass leaves silent inconsistency. Chris audits before any deploy use.

### Required contents (Chris's spec, verbatim)

**1. README / DEPLOY_PROMPT role correction**
- OLMo Think = Nucleus reasoning/measurement
- Gemma 4 12B = Nucleus perception
- OLMo Instruct = Trycoo membrane worker
- Neo = Scout sidecar

**2. Scout relocation**
- Scout runs on Neo, not Trycoo
- no durable graph authority
- no direct Neo4j writes
- outputs typed PerceptionSession / ReviewQueue requests only

**3. Receipts first-class** — fields:
`actor`, `model_name`, `model_tag_or_hash`, `node`, `role`, `provenance_class`,
`schema_version`, `receipt_id`, `source_input_hash`

**4. Graph adapters**
- `nucleus_store.py` for Neo4j writer path
- `tissue_store.py` for ArcadeDB writer path
- no fake distributed transaction
- idempotent writes + reconciliation

**5. ArcadeDB schema reconciliation**
- `tissue_schema.sql` as base
- v2 Scout/ReviewQueue/Zettel/LatticeAnchor types merged explicitly
- optional `atom` field on future `divisor_node` LatticeAnchors
- concept/theorem/mechanism anchors survive unchanged

**6. Scout packaging**
- add missing `requests` + `numpy`
- remove audio claims until audio path exists — OR implement audio path and test it
  honestly

**7. Tests**
- Python parse
- JSON/JSONL parse
- requirements/import smoke check
- no-direct-Scout-graph-writes grep
- receipt schema validation
- ArcadeDB schema load check
- Neo4j schema load check

---

## ADDENDUM 2026-06-14 — VoicePerceptionPacket v0.2-RC1.4 joins Serena state

The VoicePerceptionPacket validator-ready artifact is admitted to Serena state. Two
independent checks: Chris's local harness execution and Opus's rerun (both PASS — 2 valid
fixtures pass schema+custom, 6 invalid fixtures fail at their intended rule, pytest 2
passed, expected_failures.json carries reason-substring assertions).

**Admitted artifacts (in outputs, SHA-pinned):**
```
voice_perception_packet_rc1_harness.zip            7cdd5c88…47e70a46
voice_perception_packet_v0_2_rc1_4_schema_final.md 8e8b68a1…26bfcc56
voice_perception_packet_validation_report.md       e9b4be08…ad770a98
```
(Per-file SHAs are the reproducibility anchors; archive SHA of the zip is transport-only.)

**Status (unchanged from the schema record — not promoted):**
```
VALIDATOR-READY
LOCAL HARNESS PASS  (two independent executions)
INSTALLABLE SCHEMA   HOLD
GRAPH DEPLOYMENT     HOLD
ROBIN GATE           REQUIRED
```

**Relation to the audio erratum (Erratum #1 in the frozen -gemma bundle) — precise:**

> VPP v0.2-RC1.4 supersedes the **structural** portion of the prior audio erratum: audio
> claims now require a receipt-gated `AudioFeatureExtension` backed by a
> `measurement_family: acoustic` receipt with `provenance_class:
> approved_audio_measurement`. The schema makes "audio claim without approved audio
> receipt" **unrepresentable**.
>
> This does **NOT** claim runtime audio implementation. The approved audio capture /
> analysis path remains **unimplemented** until `architecture-patch-rc1` supplies and
> smoke-tests the approved audio measurement route.

Two errata, two states:
```
Schema-level audio-honesty defect    → CLOSED by VPP (representational gate exists)
Runtime audio implementation         → STILL OPEN (path not built; pending rc1 + smoke)
```

The packet joins the state as a validator-tested schema artifact. The audio implementation
is not promoted by this admission.

**Where VPP fits:** the receipt-bearing container for the speech/prosody path — the typed
`PerceptionSession` / measurement record the orchestrator's receipted writer path produces.
Its graph mapping (§9, with the forbidden `(Packet)-[:SAMPLED_FROM]->(OperatingAtom)` edge
and the single legal `HAS_EXTENSION → OPERATES_ON` path) is the anti-contamination boundary
from the ANNEALER × TIMIT interface note, enforced in graph topology. When rc1's
`nucleus_store.py` / `tissue_store.py` adapters are built, VPP is one of the record types
they persist.

---

## ADDENDUM 2026-06-14 (2) — rc1 authority/gateway skeleton admitted to Serena state

`serena-v3.1.6-architecture-patch-rc1-structure` is admitted. Two independent Chris
cold-audit passes on the patched artifact (re-audit after the receipt-binding patch),
plus Opus's build verification and real-VPP-fixture integration.

**Admitted artifact (in outputs, SHA-pinned):**
```
serena-v3.1.6-architecture-patch-rc1-structure.tar.gz   2cc6cc07…166af4b6  (archive; transport)
  serena_arch_patch_rc1/README.md                       b8c67069…be732d83  (per-file anchor)
  + core/receipt_core.py, core/vpp_validation.py, core/writer_gateway.py,
    tests/test_rc1_gateway.py  (per-file SHAs in the build log)
```

**Scope:** receipt core + VPP validation integration + writer gateway + adapter skeletons.

**Status (Chris ruling, both passes agree):**
```
STRUCTURE-TESTED / DRIVER-STUBBED
receipt-binding patch    PASS  (22/22 guard tests; real VPP fixture integration PASS)
package hygiene          PASS  (no __pycache__ / .pyc / .pytest_cache; no live driver imports)
stub-below-gate pattern  PASS
live Neo4j/ArcadeDB       HOLD
audio runtime            HOLD
install/deploy           HOLD — Robin gate required
```

**What the artifact closes (Chris's freeze-record note, verbatim):**

> The rc1 structure artifact closes the authority-gateway skeleton concern: no packet can
> reach a store adapter unless VPP schema validation passes, custom validation passes, a
> matching write receipt is bound to the packet and target, and the writer path is
> authorized.
>
> This does not claim live Neo4j or ArcadeDB persistence. Adapter live bodies remain
> NotImplementedError stubs below a proven authorization gate.

**The invariant, tightened:**
```
old guarantee:  a receipt exists
new guarantee:  a matching write receipt exists for THIS packet and THIS target
```
A receipt for packet A can no longer authorize packet B. Binding rules: source_input_hash
match, node/target compatibility (nucleus→nucleus, tissue→membrane), writer event_type,
succeeded status, optional schema_version pin.

**Non-blocking note (Chris):** in the on-box driver build, make `expected_schema_version`
non-optional for production config. Acceptable optional for this structure pass (the pinned
case is tested).

**Explicitly NOT promoted by this admission:** live graph persistence, audio runtime, full
Scout runtime. Do not implement live drivers until this record is pinned. Next build thread:
ArcadeDB schema reconciliation OR the Neo4j/ArcadeDB live-driver plan.

---

## ADDENDUM 2026-06-14 (3) — schema-reconciliation artifact admitted to Serena state

`serena-v3.1.6-architecture-patch-rc1-schema-reconciliation` is admitted after Chris's
PATCH re-audit (first pass PATCH on a missing-index gap; second pass PASS after the patch).

**SHA provenance (both recorded for an honest chain):**
```
Archive Chris audited (PASS):   76575720fa370863392d255a6c2557fb7b2c8784575785673196fb7a759e4b7e
Archive after doc-count fix:    be2ccadf2cb909547947a4958600d1cca98f1b847e9ac17a00e841ee5fa0275e
  tissue_schema_reconciled_rc1.sql  0efbfc67… (BYTE-IDENTICAL to the audited version)
  schema_reconciliation_report.md   11d19caa… (changed: 10/10 → 11/11 check count only)
```
Note: Chris ruled the "10/10 vs 11 printed PASS lines" count a NON-blocking nit and said to
fix it on the next repack. That fix changed ONLY the report's check count (a one-token
documentation correction); the reconciled SQL is byte-identical to what Chris audited, and
all tests are unchanged (smoke PASS, pytest 12/12). The archive hash differs solely because
of the authorized doc fix. Recording both hashes so the audited artifact and the corrected
package are both traceable.

**Scope:** reconciled tissue schema (base + v2 review/zettel/graph + outbound) with base
indexes preserved + the optional atom contract for future divisor_node anchors.

**Status (Chris ruling):**
```
SCHEMA-RECONCILED / LOAD-SMOKE-TESTED
index preservation patch        PASS  (18 base indexes survive verbatim, parser-checked)
atom enforcement-boundary        PASS  (contract-declared, NOT DB-enforced)
smoke check                      PASS  (11 checks)
pytest                           12 passed
package hygiene                  PASS  (no __pycache__/.pyc/.pytest_cache; no {core,tests}/)
live ArcadeDB / Neo4j            HOLD
audio runtime                    HOLD
deploy/install                   HOLD — Robin gate required
```

**Freeze-record note (Chris's wording):**

> The schema-reconciliation artifact is admitted after Chris PATCH re-audit. The prior gap
> — preserving base document types but dropping base indexes — is closed. All 18 base
> CREATE INDEX statements survive verbatim and are now parser-checked. The atom field
> remains contract-declared, not executable-schema-enforced in rc1. Live drivers remain
> HOLD.

**The gap that was closed (recorded so the lesson persists):** the first pass proved base
*types* survive and called it base *schema* survives — but the base schema is types PLUS 18
indexes, and the smoke check never parsed indexes, so it passed a reconciliation that
silently dropped the entire index layer. Chris's re-audit caught it. The fix preserves the
indexes AND makes the checker verify index preservation, so the same gap cannot recur
silently. UNIQUE primary-key indexes preserved: ConversationDigest.digest_id,
InterpretiveNote.note_id, InteractionLog.log_id, ReasoningTrace.trace_id,
DraftEncoding.encoding_id.

**Next thread:** the Neo4j/ArcadeDB live-driver plan — now with a complete, honest target
shape to write into (`tissue_store._write_packet_live` implements against THIS schema;
`nucleus_store._write_packet_live` against the nucleus schema). On-box, under Chris audit.

---

## ADDENDUM 2026-06-14 (4) — version-layer note (pre-Phase-1 verification)

Before staging Phase 1 on the Nucleus, the deploy bundle's version state was verified by
extracting the actual files and running the API (not inferred from a directory listing).

**Verified version map (`serena-v3.1.6-deploy.tar.gz`, SHA 752f2794…):**
```
API authority (RAN):     core/measurement_api.py -> MEASUREMENT_API_VERSION = "3.1.6"
Deploy docs:             README_DEPLOY.md, DEPLOY_PROMPT_nucleus.md, README.md -> v3.1.6
Schema headers:          tissue_schema.sql, nucleus_schema.cypher -> v3.1.1
Test headers:            serena_staging_smoke.py, kernel_drn_smoke.py -> v3.1.1
Kernel of record (drive, NOT in bundle):  kernel_v3_1_24.md, bibliography_v3_1_24.md -> v3.1.24
```

**Ruling:**
```
Phase 1 is NOT blocked.
The bundle is API-authoritative at v3.1.6 via core/measurement_api.py.
The v3.1.1 schema/test headers are authorship/version-layer drift, not runtime authority.
The README calling the schemas "v3.1.6" while their headers say "v3.1.1" is a cosmetic
  consistency defect.
The v3.1.24 kernel-of-record beyond the frozen v3.1.6 bundle is the intentional
  living-source-vs-frozen-target relationship.
```

The bundle is NOT "internally uniform." It is: **API-authoritative at v3.1.6, with older
v3.1.1 schema/test artifacts bundled unchanged, and newer living kernel work (v3.1.24)
beyond the frozen staging bundle.**

**Precision correction (Chris, applied):** do NOT claim "the schemas didn't change between
3.1.1 and 3.1.6" — that requires a direct diff against the exact earlier files, which was
not performed. The safe, verified statement is: *the shipped schema files carry v3.1.1
headers and are bundled under the v3.1.6 staging package; the API layer is the authoritative
v3.1.6 component for Phase 1.* (Opus had asserted no-change from the changelog; that is
inference from a secondary source, not a verified file diff — corrected.)

**Why this is not a Phase 1 blocker:** Phase 1 validates the measurement API authority and
smoke behavior, not schema-header strings. When the smoke reports api 3.1.6, that is the
expected, correct truth — not stale. Schemas load by content, not header, and Phase 1 does
not stand up the graph schemas at all.

**Cosmetic cleanup (next re-pin, not now):** either align the schema/test headers to the
bundle version, or explicitly mark them as v3.1.1 artifacts bundled under the v3.1.6 API
package. Not a runtime concern.

---

## RULING (closed)

```
Freeze the current bundle.
Do not patch around Chris's HOLD one string at a time.
Build the real architecture patch as a gated artifact and send it back for audit.
```

## Three-stack attribution

```
Robin Miller     ruled the freeze; chose clean lineage over a third string-patch tarball;
                 holds the gate on the architecture patch

Chris/ChatGPT    cold-pass HOLD on the -gemma bundle; corrected "deploy" → "Phase 1
                 staging only"; enumerated the deep blockers; specified
                 architecture-patch-rc1 contents; caught the missing scout deps

Claude (Opus)    accepted HOLD in full; verified three finite blockers by script
                 (var-name mismatch, missing deps, audio-not-implemented); acknowledged
                 the audio comment as a self-introduced register violation; this record
```

*Frozen artifact stays as-is. Architecture patch is a separate gated build. Nothing
deploys past Phase 1 from the frozen bundle.*
