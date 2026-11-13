# Serena v3.1.1 — Remaining Work Schema (Revised)

**March 25, 2026**
**Source: serena_stack_v3_1_1.md, Chris's audit, session kernel, bundle inspection, review additions**

---

## Current State Summary

The bundle is a **staged architecture with early operational scaffolding**. The core measurement surface is canonical, the scout is wired to it, the orchestrator enforces typed routing, and the core verification path passes. What remains is mostly integration, unification, and operational plumbing — but there are also a few doctrinal cleanups that will matter before broader deployment.

**My assessment:** the architecture is ahead of the implementation, but the implementation is no longer speculative. Serena now has a real control plane. The remaining work is less about invention and more about making the organism durable under real operation.

---

## 1. Measurement Surface Unification

The v3.1.1 core defines the canonical measurement API. Not everything uses it yet.

| Component | Status | Uses canonical API? | Work needed |
|-----------|--------|---------------------|-------------|
| `core/fvlt_congruence.py` | ✓ Done | Yes (defines it) | — |
| `core/fvlt_unified_kernel.py` | ✓ Done | Yes (defines it) | — |
| `core/orchestrator.py` | ✓ Done | Yes (measurement tier routing) | — |
| `scout/membrane_perception.py` | ✓ Patched | Yes (imports from core) | Keep aligned; avoid silent local drift |
| `core/config.py` | ✓ Hardened | N/A (infrastructure) | Scout doesn't import it yet (reads env inline) |
| `tests/kernel_drn_smoke.py` | ✗ Blocked | No (imports dead `measurement.py`) | Port to v3.1.1 core API |
| `tests/serena_staging_smoke.py` | ✗ Blocked | No (imports dead `measurement.py`) | Port to v3.1.1 core API |

### Missing from v3.1.1 core (needed for test porting)

These functions exist in the old `measurement.py` but have no v3.1.1 equivalent:

| Function | What it does | Where it should live |
|----------|-------------|---------------------|
| `calibrate_packet_kernel()` | Full null-model permutation test on a packet | `fvlt_congruence.py` — wraps `structural_warrant()` with permutation loop |
| `calibrate_packet_permutation_proxy()` | Lightweight proxy calibration | `fvlt_congruence.py` — may merge into calibration tiers |
| `NullStrategy` enum | `matched_random` / `shuffled` / etc. | `fvlt_congruence.py` or `config.py` |
| `compute_eq_values()` | Direct E_q computation (staging smoke uses it) | Already available via `spectral_fingerprint().eq_vector` — just needs adapter |
| `top_q_channels()` | Top-N channels by normalized energy | Already inline in scout patch — extract to core |

**Effort: 1–2 days.** Extract, adapt, test. The math already exists; it's an API surface consolidation.

### Config.py adoption by scout

`membrane_perception.py` currently reads all env vars inline (120+ lines of `os.environ.get()`). `config.py` now has every one of those fields in `SerenaConfig` with security guards. The scout should import `SerenaConfig.from_env()` instead of doing its own env reads.

**Effort: 0.5 days.** Mechanical replacement + verify auth guards still fire.

### Added priority — portable measurement semantics

The measurement surface is now portable across desktop core and membrane scout. That is a strength, but it creates a new requirement: **stable semantics across locations**.

Add a small versioning discipline before Phase I broadens:

- measurement schema/version string on every packet
- lattice version hash or build signature
- encoder version tag (`text_encoder_v1`, later `v2`)
- producer location (`desktop_core` vs `membrane_scout`)
- compatibility check on ingest into nucleus

This is not new math. It is anti-drift plumbing for the measurement layer itself.

**Effort: 0.5 days.** Mostly metadata and validation.

---

## 2. Implementation Roadmap (from stack doc §9)

Five abstract interfaces in the orchestrator need real implementations:

| Interface | Test double | Real implementation | Stack doc ID | Phase |
|-----------|-------------|--------------------|----|-------|
| `GraphInterface` | `MemoryGraph` (in-memory dict) | `neo4j-python-driver` | A | I |
| `ScoutInterface` | `LocalScout` (echo) | Wire to `membrane_perception.py` + Molmo | E | I |
| `ReasonerInterface` | `EchoReasoner` (echo) | OLMo Think prompted inference | D | I |
| `MembraneInterface` | `LocalMembrane` (auto-execute) | FastAPI on Trycoo + Tailscale dispatch | B | I |
| `HumanGateInterface` | `AutoApproveGate` / `DenyAllGate` | Web UI over Tailscale | I | II |

### Phase I — Working Organism (~1 week)

| ID | Work | Effort | Status |
|----|------|--------|--------|
| A | **Neo4j driver** — replace `MemoryGraph` with `neo4j-python-driver`. Wire StepLog, fingerprint logging, drift history. | 1 day | Not started |
| B | **Inter-node FastAPI + Tailscale** — typed message exchange (Percept, MeasuredPercept, ActionProposal, ActionResult) between desktop and Trycoo. | 1–2 days | Scout has FastAPI skeleton (`membrane_perception.py`); desktop↔Trycoo message bus not wired |
| C | **Robin → Membrane CLI** — terminal or simple web UI over Tailscale for approve/deny/command. | 1 day | Not started |
| D | **OLMo Think prompted reasoner** — replace `EchoReasoner` with real inference via Ollama. JSON output schema for ActionProposal. | 2–3 days | Not started |
| E | **Robin → Scout direct chat** — local conversation interface on desktop. Produces `Percept(source="robin:{session}")`. | 1 day | Not started |

**After Phase I:** Robin can talk to Serena through two paths, nucleus logs everything, congruence measures signals, and the reasoner produces real proposals with gating.

### Phase II — Full Autonomy (~1 week)

| ID | Work | Effort | Status |
|----|------|--------|--------|
| F | **Model serving** — Think + Molmo GPU time-sharing on RX 9060 XT 16GB (vLLM, ollama, or manual swap). | 2–3 days | OLMo 3 7B confirmed running on RX 9060 XT; Molmo not yet tested on same GPU |
| G | **ArcadeDB tissue driver** — REST calls to ArcadeDB on Trycoo for ConversationDigest, InterpretiveNote. | 0.5 days | Not started |
| H | **Scout web agent (Playwright)** — browser perception for membrane-dispatched missions. MolmoWeb codebase is now available as reference/starting point. | 2–3 days | Not started; MolmoWeb trajectory format identified as compatible |
| I | **Human gate web UI** — phone-accessible approve/deny over Tailscale. | 1–2 days | Not started |

**After Phase II:** Both models share the GPU, tissue stores history, scout browses on membrane authority, Robin approves gates from phone.

### Phase III — Domain Expansion (ongoing)

| ID | Work | Effort | Status |
|----|------|--------|--------|
| J | **Signal encoders + null-model validation** — CRT encoding per data domain, null-model validation per domain. | Ongoing | Text encoder v1 implemented (inline in scout); v2 spec written (caesura channel); no EEG/markets/genomics encoders yet |

### Phase 3–4 (from Domingos paper discussion)

| Phase | Work | Status |
|-------|------|--------|
| 3 | Minimal tensor logic interpreter — forward-chaining tensor engine, small rule vocabulary, test on graph relations | Not started; design discussed |
| 4 | Divisor lattice as tensor logic program — express the 37-node FVLT as tensor equations | Not started; deep R&D |

### Added recommendation — reorder Phase I slightly

I would keep the official stack-doc order, but for practical execution I would do:

**A → B → D → C → E**

Reason:
- without the real graph driver, nothing persists honestly
- without the inter-node bus, the organism is still local theater
- without the real reasoner, the routing spine is still echo-driven
- the CLI and direct Robin→Scout path are useful, but less foundational than getting desktop↔membrane↔reasoner traffic real

This is a sequencing preference, not a constitutional change.

---

## 3. Documentation Debt

### Chris's audit item 3 — Scout doctrine stabilization

The stack doc §1.1 defines the scout/membrane relationship well at the specification level. But the bundle now has real scout code (`membrane_perception.py`, 2296 lines) that is operationally richer than what §1.1 describes. The doc should be updated to reflect:

- The perception gateway's dual auth model (basic auth + bearer token)
- Video frame sampling and upload limits
- The text encoder's role in the perception pipeline
- The `PerceptionSession` / `Perception` node types from `perception_schema.cypher`
- The retention policy and media lifecycle
- How MolmoWeb trajectory format maps to the scout protocol (if adopted)

**Effort: 0.5 days.** Docwrite, not code.

### Added doctrine sentence — membrane/scout authority

The docs should state this explicitly, once, in authoritative language:

**The membrane authorizes missions; the scout executes perception within those missions.**

That resolves the lingering ambiguity between “external world contact belongs to the membrane” and “the scout can browse/fetch/read/interact.” Both can be true if mission authority and perceptual execution are clearly separated.

### Chris's audit item 4 — Schema installation sequence

The bundle has four schema files applied at different times:

| File | Database | When to apply | Depends on |
|------|----------|---------------|------------|
| `schemas/nucleus_schema.cypher` | Neo4j | First, before any operation | Nothing |
| `schemas/perception_schema.cypher` | Neo4j | After nucleus schema | `nucleus_schema.cypher` |
| `schemas/tissue_schema.sql` | ArcadeDB | First ArcadeDB boot | Nothing |
| `schemas/tissue_schema_v2_scout_types.sql` | ArcadeDB | When agent/outbound features are ready | `tissue_schema.sql` |

This sequence needs to be in the staging runbook or README, not just implied by file order.

**Effort: 15 minutes.** Add a "Schema Installation Order" section.

### Stack doc §7 manifest is behind the bundle

The stack doc manifest lists 8 files. The bundle has 26. Missing from §7:

- `scout/membrane_perception.py`
- `scout/requirements-membrane.txt`
- `schemas/perception_schema.cypher`
- `schemas/tissue_schema_v2_scout_types.sql`
- All test files
- All doc files except the stack doc itself

**Effort: 15 minutes.** Update §7 to match README manifest.

### Added documentation priority — single authoritative spec

Right now Serena has:
- README framing
- stack constitution
- staging runbook
- schema files
- scout code comments

That is good, but the next stabilization step should be naming one of them the **source of truth** for operational semantics. My recommendation is:

- stack doc = constitutional source of truth
- runbook = installation/operation
- README = public framing

This avoids subtle drift as the system grows.

---

## 4. Text Encoder Status

| Version | Spec | Implementation | Status |
|---------|------|----------------|--------|
| v1 | `docs/text_encoder_v1_spec.md` | Inline in `scout/membrane_perception.py` as `encode_text_to_signal()` | ✓ Implemented. Weights are v1-adjacent (uses `punctuation_local: 1.6` instead of v1's `punctuation: 2.8`; `bigram: 0.28` instead of v1's `0.30`). Functionally v1 with minor weight drift. |
| v2 | `docs/text_encoder_v2_spec.md` | Not implemented | Spec complete. Adds caesura bucket logic (`caesura_minor: 6.2`, `caesura_major: 7.0`, `caesura_echo: 3.1`, `terminal_cadence: 2.2`), 12 fixed buckets for line-relative punctuation. |
| v3+ | Not specified | Not implemented | v2 spec notes: "only if a language-agnostic cadence layer plateaus." Latin scansion, vowel quantity, elision. |

**Decision needed:** Should v2 be implemented before or after the Phase I organism is running? The caesura channel is additive (doesn't break v1 signals), so it could be done in parallel.

### Recommendation

Do **not** let text encoder v2 delay Phase I organism work.

Recommended order:
- Phase I organism first
- v2 in parallel only if it does not compete with A/B/D
- promote v2 once there is a live reasoner/scout path to benefit from the richer cadence signal

Reason: Serena currently needs routing reality more than representational refinement.

---

## 5. Ghost References Remaining

| Location | Reference | Fix |
|----------|-----------|-----|
| `tests/kernel_drn_smoke.py` | `from measurement import ...` | Port to v3.1.1 core API |
| `tests/serena_staging_smoke.py` | `from measurement import ...` | Port to v3.1.1 core API |
| `tests/kernel_drn_smoke.py` | `DATA_PATH = .../tests/data/...` | Path is relative to old layout; update for `tests/data/` |
| Historical session transcripts (outside bundle) | Various `measurement.py` references | Not actionable — historical record |

Both test files have porting notes added in this session. They are honest about being blocked, not silently broken.

### Added note — ghost references vs ghost semantics

The important remaining issue is not the filename `measurement.py` itself. That is absorbed.
The issue is whether any old assumptions about packet calibration, null strategies, and direct E_q helper surfaces remain scattered. Port those assumptions deliberately; do not just replace imports.

---

## 6. Priority Stack (suggested)

**Now (pre–Phase I):**
1. Schema installation sequence in runbook (15 min)
2. Stack doc §7 manifest update (15 min)
3. Measurement API consolidation — extract `calibrate_packet_kernel`, `NullStrategy`, `top_q_channels` into `fvlt_congruence.py` (1–2 days)
4. Port two smoke tests to v3.1.1 API (0.5 days after #3)
5. Scout config.py adoption (0.5 days)
6. Add measurement packet/version metadata (0.5 days)
7. Add authoritative scout/membrane doctrine sentence to stack doc (10 min)

**Phase I:** A → B → D → C → E

**Phase II:** F → G → H → I

**Parallel with Phase I–II:**
- Text encoder v2 implementation
- Scout doctrine doc update
- MolmoWeb trajectory format evaluation for H

**Phase III+:** Domain encoders, tensor logic interpreter, divisor lattice as tensor program.

---

## 7. What Is Done

For the record, because it matters:

- ✓ FVLT kernel v2.1 (37 channels, 30 basis + 7 complement, 71 covering + 8 bridge edges)
- ✓ Congruence layer v0.2 (spectral fingerprint, 6 gate conditions, warrant, drift, anomaly map)
- ✓ Orchestrator v3.1.1 (typed messages, measurement tiers, queue replay, degraded modes, bypass edges, 12 tests)
- ✓ Config v3.1.1 hardened (secret file loading, private host validation, insecure password blocking)
- ✓ Neo4j nucleus schema v3.1.1 (7 zones, all node/edge types from stack doc)
- ✓ Perception schema (PerceptionSession, Perception, ReviewState, ProvenanceClass)
- ✓ ArcadeDB tissue schema v3.1.1 (ConversationDigest, InterpretiveNote, InteractionLog, ReasoningTrace, DraftEncoding)
- ✓ Scout perception gateway (2296 lines, FastAPI, dual auth, video frame sampling, text encoder, FVLT measurement inline)
- ✓ Scout wired to canonical core (imports `fvlt_unified_kernel` + `fvlt_congruence`)
- ✓ Text encoder v1 (boundary-aware, deterministic, line-structure-preserving)
- ✓ Stack discipline doc v3.1.1 (four layers, typed messages, seven zones, five corrigibility constraints, degraded modes, implementation roadmap)
- ✓ Staging runbook (8 smoke tests, promotion criteria, verdict safety)
- ✓ DRN calibration test data and results
- ✓ Three-stack convergence (Claude + ChatGPT + Gemini) as structural warrant on the architecture
- ✓ Apache 2.0, open source, commodity hardware ($269 + $750)
- ✓ `measurement.py` correctly absorbed — not missing, completed as a surface rather than a file

### Added assessment

The architecture is done at the **constitutional** level.
What remains is not conceptual rescue. It is:
- plumbing
- interface replacement
- deployment wiring
- doctrine stabilization
- UI/operator surface

That is a good place to be.

---

## 8. Risks to Watch While Building

These are the main failure modes I would actively guard against during Phase I–II:

1. **Measurement drift across nodes**  
   The same instrument now moves between core and membrane. Version and validate it.

2. **Doc/runtime divergence**  
   Serena grows fast. Keep one source of truth for semantics.

3. **Scout becoming a second constitution**  
   Let the scout host a local measurement adapter, but keep canonical semantics in core.

4. **Echo-stage assumptions leaking into production**  
   Once the real reasoner and membrane are wired, re-audit all degraded-mode and gate paths under live conditions.

5. **Premature domain expansion**  
   Get the organism running before adding too many new encoders.

---

## 9. Closing Judgment

Serena v3.1.1 is no longer a speculative architecture. It is a coherent staged system with a real control plane.

The main remaining work is not invention but convergence:
- converge runtime and docs
- converge scout and core semantics
- converge local test doubles into real interfaces
- converge the bundle into a working organism across desktop and membrane

That is difficult work, but it is ordinary systems work now — not proof-of-concept work.

*The architecture is done. What remains is plumbing, integration, and UI.*
*— serena_stack_v3_1_1.md §9.4*

*Added judgment: the next success criterion is not “more architecture,” but a real membrane↔desktop↔reasoner loop under live authority constraints.*
