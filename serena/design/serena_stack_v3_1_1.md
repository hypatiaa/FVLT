# Serena Stack Discipline Architecture v3.1.1

**Robin Miller — Ratioque / March 2026**
**Apache 2.0**

---

## 0. Design Principle

Serena is not a chatbot. She is a sovereign measurement-first organism with bounded autonomy and structural discipline.

The stack has four layers. Each layer has one job. Each layer communicates with its neighbors through typed messages. No layer may bypass the congruence stage. Some percepts may pass through it in logged bypass mode when structural measurement is not applicable.

```
┌─────────────────────────────────────────────────┐
│  SCOUT / PERCEPTION                             │
│  Molmo 7B-O (visual) · OLMo Instruct (text)    │
│  Local document ingest · authorized fetch input │
│  Output: Percept                                │
├─────────────────────────────────────────────────┤
│  CONGRUENCE / MEASUREMENT                       │
│  fvlt_congruence.py · fvlt_unified_kernel.py    │
│  Spectral fingerprint · Structural warrant      │
│  Output: MeasuredPercept                        │
├─────────────────────────────────────────────────┤
│  REASONER / MEMORY / PROPOSAL AUTHORIZATION     │
│  OLMo 3 7B-Think · Neo4j nucleus queries        │
│  ArcadeDB tissue (Zettelkasten)                 │
│  Output: ActionProposal                         │
├─────────────────────────────────────────────────┤
│  MEMBRANE                                       │
│  Trycoo N150 · OLMo Instruct (agent)            │
│  Tailscale · External API dispatch              │
│  Output: ActionResult                           │
└─────────────────────────────────────────────────┘
```

Percepts flow downward. Refusals, abstentions, and requests for more information flow upward. The membrane never initiates reasoning. The reasoner never bypasses measurement. The scout never authorizes action.

**Epistemic control plane.** Current AI mostly represents uncertainty as style, score, or refusal. Serena represents uncertainty as state. State changes routing. Routing changes authority.

**Shared measurement substrate.** FVLT is Serena's nervous system, not a tollbooth. It binds the lobes into a commensurable organism by placing percepts, parses, and signals into a common structural space. Without it, you have three models and a database. With it, you have an organism. FVLT adds local measurement cost in order to reduce global coordination cost — exactly what a nervous system does.

**The "I don't know" gate.** Serena has three epistemic verdicts, not two: warranted, blocked, and bypassed. Each is a typed state that changes what the system is allowed to do next. The congruence layer does not need to measure everything. It needs to know — and say — when it cannot measure.

**Measurement tiers.** Not every operation pays full measurement cost:
- *Cheap path:* local, low-risk, already-grounded operations — no FVLT invocation.
- *FVLT path:* lobe boundary crossings, reference comparisons, action proposals — spectral fingerprint and warrant check.
- *Full calibration path:* ambiguous or high-stakes cases — null-model permutation test, bridge depth calibration, drift monitoring.

---

## 1. Layer Specifications

### 1.1 Scout / Perception

**Hardware:** Serena desktop (Molmo GPU), Membrane node (OLMo Instruct CPU), external API outputs routed inward through membrane

**Responsibility:** Acquire raw input and produce structured percepts. The scout observes; it does not interpret.

**Models:**
- **Molmo 7B-O** — visual perception. Receives images, returns structural geometry descriptions. System prompt: *"Analyze structural geometry. Do not interpret; describe discrete mechanics."*
- **OLMo 3 7B-Instruct** — text/document perception. Parses documents, extracts entities, identifies structure.
- **Authorized fetch outputs** — data returned from external APIs, browser scouting, or sensors.

**External contact model:**
- The scout is a full perceiving agent. It can browse, fetch, read, interact, and observe in the external world.
- The scout acts under **membrane direction** for autonomous missions. The membrane sends the scout into the world; the scout does not self-authorize missions.
- The membrane communicates with the scout to dispatch observation tasks and receive structured percepts back.
- The reasoner proposes missions. The membrane authorizes and dispatches them. The scout executes and returns percepts.
- The scout observes and perceives. It does not transact, commit, or mutate external state on its own authority.

**Dual access — Robin can talk to the scout directly:**
- Robin may converse with the scout on the Serena desktop or via Tailscale, without routing through the membrane.
- Direct scout conversations produce percepts that still flow through the full stack: congruence → reasoner → membrane.
- Direct access is a perception shortcut, not an authorization shortcut. Action proposals from direct scout sessions still require the standard pipeline and gating.
- The membrane remains the always-on standing contact point (phone, remote, async). The scout is the direct conversational partner when Robin is present.

**Output type:** `Percept`

```python
@dataclass
class Percept:
    """Raw structured observation from the scout layer."""
    percept_id: str              # UUID
    timestamp: str               # ISO 8601
    source: str                  # "molmo" | "instruct" | "web:{url}" | "api:{name}" | "local:{name}" | "robin:{session}"
    modality: str                # "visual" | "text" | "tabular" | "signal"
    content_type: str            # subtype/schema tag for content payload
    content: dict                # source-specific payload
    raw_signal: Optional[np.ndarray]  # if signal-typed, the numeric array
    signal_length: Optional[int]      # len(raw_signal)
    metadata: dict               # provenance, source URL, model version
```

**Constraints:**
- The scout NEVER produces interpretations, recommendations, or actions.
- If `modality == "signal"` or content can be encoded as a signal, `raw_signal` MUST be populated.
- If raw_signal cannot be extracted, the percept still passes through the congruence stage in `warrant_bypass=True` mode with a logged reason.

**Bypass reason classes:**
- `not_structurally_representable`
- `adapter_not_implemented`
- `source_payload_incomplete`
- `measurement_temporarily_unavailable`

---

### 1.2 Congruence / Measurement

**Hardware:** Serena desktop (CPU — numpy only, no GPU required)

**Responsibility:** Measure the structural content of each percept. Compare it against known references. Return a verdict: warrant, no warrant, or bypass. The congruence layer is the shared measurement substrate that makes cross-modal comparison possible — it is the price of coherence.

**Code:** `fvlt_congruence.py` + `fvlt_unified_kernel.py`

**Input type:** `Percept` + optional `ReferenceProfile` from Neo4j

**Output type:** `MeasuredPercept`

```python
@dataclass
class MeasuredPercept:
    """Percept enriched with structural measurement and warrant."""
    percept: Percept
    fingerprint: Optional[SpectralFingerprint]      # None if bypass
    verdict: Optional[WarrantVerdict]               # None if first-encounter or bypass
    warrant_bypass: bool                            # True if percept was not measurable
    bypass_reason: str                              # "" if not bypassed
    reference_id: Optional[str]                     # Neo4j node ID of reference used
    measurement_ms: float                           # wall-clock time for measurement
    structural_confidence_index: Optional[float]    # from verdict if available
```

**Constraints:**
- Every percept with a `raw_signal` MUST be measured.
- If no reference profile exists for this signal class, the congruence layer computes and logs the fingerprint but sets `verdict=None` (first-encounter mode).
- The congruence layer NEVER modifies the percept. It only annotates.
- Measurement results are logged to Neo4j regardless of verdict or bypass.
- If congruence is unavailable, the stack enters degraded mode as defined in §6.

**Congruence layer functions (from fvlt_congruence.py):**

| Function | Input | Output | When |
|----------|-------|--------|------|
| `spectral_fingerprint()` | signal, lattice | `SpectralFingerprint` | Every measurable percept |
| `congruence_score()` | two fingerprints | `CongruenceResult` | When reference exists |
| `structural_warrant()` | signal, reference | `WarrantVerdict` | Gate decision |
| `spectral_anomaly_map()` | test, reference | `AnomalyMap` | Detailed diagnostics |
| `drift_monitor()` | signal sequence, reference | `DriftReport` | Temporal monitoring |
| `build_reference_profile()` | signal population | `ReferenceProfile` | Learning new anchors |

---

### 1.3 Reasoner / Memory / Proposal Authorization

**Hardware:** Serena desktop (OLMo Think GPU), Neo4j on desktop, ArcadeDB on Trycoo

**Responsibility:** Given a measured percept, reason about it, query memory, and propose an action. The reasoner proposes; it does not execute.

**Models:**
- **OLMo 3 7B-Think** — deliberative reasoning. Receives measured percepts, produces structured proposals.
- **Neo4j** (nucleus) — rigorous graph of measurements, fingerprints, warrants, relations. 7 zones (see §3).
- **ArcadeDB** (tissue / Zettelkasten) — associative memory, notes, conversation digests, interpretive context.

**Input type:** `MeasuredPercept`

**Output type:** `ActionProposal`

```python
@dataclass
class ActionProposal:
    """Reasoner's proposed action, awaiting authorization/execution."""
    proposal_id: str                 # UUID
    timestamp: str                   # ISO 8601
    measured_percept_id: str         # link to MeasuredPercept
    action_type: str                 # "store" | "query" | "respond" | "dispatch" | "abstain"
    action_payload: dict             # type-specific content
    reasoning_summary: str           # concise nucleus-safe summary
    reasoning_trace_ref: Optional[str]  # pointer to full trace in tissue/log store
    reasoner_confidence_index: float    # reasoner's self-assessed index [0, 1]
    structural_confidence_index: Optional[float]  # from congruence verdict
    requires_human_gate: bool        # True for interpretive writes and external dispatch
    graph_writes: List[dict]         # proposed Neo4j/ArcadeDB mutations
    bypass_acknowledged: bool        # True if proceeding from congruence bypass
```

**Constraints:**
- If `measured_percept.verdict.warrant == False`, the reasoner MUST choose `action_type = "abstain"` or `action_type = "query"`.
- If `measured_percept.warrant_bypass == True`, the reasoner proceeds only with `bypass_acknowledged=True`.
- Interpretive writes to Neo4j always require manual gate.
- The reasoner NEVER executes external actions.
- `graph_writes` is a list of proposed Cypher/SQL statements with human-readable descriptions.

**Action types:**

| Type | Meaning | Requires gate? |
|------|---------|----------------|
| `store` | Write fingerprint/measurement to graph | Yes (nucleus), No (tissue append) |
| `query` | Request additional information (loops back to scout via membrane/scout path) | No |
| `respond` | Generate response text for Robin | No |
| `dispatch` | Send external API call via membrane | Yes |
| `abstain` | Do nothing; log reason | No |

---

### 1.4 Membrane

**Hardware:** Trycoo N150 mini PC (always-on, headless, Tailscale)

**Responsibility:** Execute authorized actions and direct the scout into the world. The membrane is the boundary between Serena and the external world. It authorizes, dispatches, and receives — it does not decide what to pursue (the reasoner proposes that).

**Model:** OLMo 3 7B-Instruct (CPU, ~6–9 tok/s) — agent/orchestrator for API calls, scheduling, scout mission dispatch, and conversation digestion.

**Input type:** `ActionProposal` (authorized)

**Output type:** `ActionResult`

```python
@dataclass
class ActionResult:
    """Result of an executed action."""
    result_id: str               # UUID
    proposal_id: str             # link back to ActionProposal
    timestamp: str               # ISO 8601
    success: bool
    result_payload: dict         # type-specific result
    error: Optional[str]         # None if success
    execution_ms: float          # wall-clock time
    external_response: Optional[dict]  # raw API/browser response if dispatch
```

**Constraints:**
- The membrane NEVER initiates actions on its own. It executes authorized proposals.
- The membrane **directs the scout** into the external world: authorizes browse/fetch/observe missions and receives percepts back.
- The membrane **executes dispatch actions**: API calls, transactions, external writes — things that mutate the world.
- The membrane NEVER modifies the nucleus graph directly outside logged result insertion paths defined by the stack.
- The membrane MAY append raw logs and conversation digests to ArcadeDB tissue without gate approval.
- The membrane MAY append model-authored interpretive notes only as `draft` status in tissue.
- Promotion of tissue content into nucleus requires manual approval.

---

## 2. Message Flow

### 2.1 Normal Path (signal-bearing percept with existing reference)

```
Scout ──[Percept]──► Congruence ──[MeasuredPercept]──► Reasoner ──[ActionProposal]──► Membrane
                         │                                  │                            │
                         ▼                                  ▼                            ▼
                      Neo4j:                             Neo4j:                       Neo4j:
                    log fingerprint                   log proposal                 log result
                    log verdict                       log reasoning summary
```

### 2.2 Warrant Failure Path

```
Scout ──[Percept]──► Congruence ──[MeasuredPercept: warrant=False]──► Reasoner
                         │                                                │
                         ▼                                                ▼
                      Neo4j:                                        action_type="abstain"
                    log fingerprint                                 OR "query"
                    log failure flags
```

### 2.3 First Encounter Path (no reference exists)

```
Scout ──[Percept]──► Congruence ──[MeasuredPercept: verdict=None]──► Reasoner
                         │                                               │
                         ▼                                               ▼
                      Neo4j:                                   propose: store as new reference
                    log fingerprint                            (requires manual gate)
                    (no comparison)
```

### 2.4 Bypass Path (non-signal or not-yet-measurable percept)

```
Scout ──[Percept]──► Congruence ──[MeasuredPercept: warrant_bypass=True]──► Reasoner
                         │                                                     │
                         ▼                                                     ▼
                      Neo4j:                                         proceeds only with
                    log bypass reason                               bypass_acknowledged=True
```

### 2.5 Robin → Scout Direct Path

```
Robin ──[conversation]──► Scout ──[Percept(source="robin:{session}")]──► Congruence ──► Reasoner
                                                                             │              │
                                                                             ▼              ▼
                                                                          Neo4j:      if action required:
                                                                        log as normal    standard pipeline
                                                                                        (gating applies)
```

Direct access is a perception shortcut, not an authorization shortcut.

### 2.6 Membrane-Dispatched Scout Mission

```
Reasoner ──[ActionProposal(type="query")]──► Membrane ──[dispatch]──► Scout ──[world]──► Percept
                                                                                            │
                                                                                            ▼
                                                                                      Congruence ──► Reasoner
```

The membrane sends the scout. The scout returns percepts. Percepts flow through the full stack.

### 2.7 Drift Monitoring (background process)

```
Neo4j (fingerprint history) ──► Congruence: drift_monitor() ──► DriftReport ──► Neo4j
                                                                                   │
                                                                              if drift_detected:
                                                                              alert Robin
```

---

## 3. Neo4j Logging Schema (Nucleus)

The nucleus graph has 7 zones. Every typed message in the stack becomes a node or edge.

### 3.1 Zone Map

| Zone | Content | Write authority |
|------|---------|-----------------|
| Z1: Percepts | Scout observations | Scout (auto) |
| Z2: Measurements | Fingerprints, verdicts, anomaly maps | Congruence (auto) |
| Z3: References | Reference profiles, population statistics | Reasoner (gated) |
| Z4: Proposals | Action proposals, reasoning summaries | Reasoner (auto-log) |
| Z5: Results | Action results, external responses | Membrane (auto-log) |
| Z6: Drift | Drift reports, cosine trends, warrant failure sequences | Congruence (auto) |
| Z7: Ontology | Signal classes, type definitions, relations | Reasoner (gated) |

### 3.2 Node Types

```cypher
// Z1: Percept
CREATE (p:Percept {
  percept_id: $id,
  timestamp: datetime($ts),
  source: $source,
  modality: $modality,
  content_type: $content_type,
  signal_length: $len
})

// Z2: Fingerprint
CREATE (f:Fingerprint {
  fingerprint_id: $id,
  timestamp: datetime($ts),
  total_energy: $total_e,
  bridge_depth: $beta,
  herfindahl: $herf,
  shell: $shell,
  n_channels: $n_ch,
  eq_vector: $eq_vec,
  status: $status   // "observed" | "validated" | "rejected" | "degenerate" | "bypass"
})

// Z2: Verdict
CREATE (v:Verdict {
  verdict_id: $id,
  timestamp: datetime($ts),
  warrant: $warrant,
  confidence_index: $confidence_index,
  cosine: $cosine,
  jensen_shannon: $jsd,
  max_deviation: $max_dev,
  max_deviation_q: $q,
  bridge_match: $beta_match,
  herfindahl_ratio: $herf_ratio,
  flags: $flags
})

// Z3: Reference
CREATE (r:Reference {
  reference_id: $id,
  created: datetime($ts),
  signal_class: $class,
  n_samples: $n,
  mean_energy: $mean_e,
  mean_beta: $beta,
  mean_herfindahl: $herf,
  mean_vector: $mean_vec,
  std_vector: $std_vec
})

// Z4: Proposal
CREATE (a:Proposal {
  proposal_id: $id,
  timestamp: datetime($ts),
  action_type: $type,
  reasoner_confidence_index: $reasoner_conf,
  structural_confidence_index: $struct_conf,
  requires_gate: $gate,
  reasoning_summary: $summary,
  reasoning_trace_ref: $trace_ref,
  bypass_acknowledged: $bypass_ack
})

// Z5: Result
CREATE (x:Result {
  result_id: $id,
  timestamp: datetime($ts),
  success: $success,
  execution_ms: $ms,
  error: $err
})

// Z6: DriftPoint
CREATE (d:DriftPoint {
  window_idx: $w,
  timestamp: datetime($ts),
  cosine: $cos,
  jensen_shannon: $jsd,
  confidence_index: $conf,
  warrant: $warrant
})
```

### 3.3 Edge Types

```cypher
// Percept → Fingerprint (measurement produced)
CREATE (p)-[:MEASURED_AS {measurement_ms: $ms}]->(f)

// Fingerprint → Reference (comparison target)
CREATE (f)-[:COMPARED_TO {cosine: $cos, jsd: $jsd}]->(r)

// Fingerprint → Verdict (gate result)
CREATE (f)-[:YIELDED]->(v)

// Percept → Proposal (reasoning chain)
CREATE (p)-[:PROMPTED]->(a)

// Verdict → Proposal (warrant carried forward)
CREATE (v)-[:WARRANTED]->(a)   // only if warrant=True
CREATE (v)-[:BLOCKED]->(a)     // if warrant=False
CREATE (p)-[:BYPASSED_TO {reason: $bypass_reason}]->(a)  // if warrant_bypass=True

// Proposal → Result (execution)
CREATE (a)-[:EXECUTED]->(x)

// DriftPoint → DriftPoint (temporal sequence)
CREATE (d1)-[:NEXT {cosine_delta: $delta}]->(d2)

// Reference ← Fingerprint (population membership)
CREATE (f)-[:MEMBER_OF]->(r)
```

### 3.4 Indexes

```cypher
CREATE INDEX percept_time FOR (p:Percept) ON (p.timestamp);
CREATE INDEX fingerprint_time FOR (f:Fingerprint) ON (f.timestamp);
CREATE INDEX verdict_warrant FOR (v:Verdict) ON (v.warrant);
CREATE INDEX proposal_type FOR (a:Proposal) ON (a.action_type);
CREATE INDEX reference_class FOR (r:Reference) ON (r.signal_class);
CREATE INDEX drift_window FOR (d:DriftPoint) ON (d.window_idx);
```

---

## 4. ArcadeDB Tissue Schema (Zettelkasten)

The tissue is append-only associative memory on the Trycoo membrane node. It stores conversation digests, interpretive notes, and context that the nucleus does not need to gate.

```sql
-- Conversation digest (membrane writes without gate)
CREATE DOCUMENT TYPE ConversationDigest;
-- Fields: digest_id, timestamp, source, summary, key_entities[], references[], percept_ids[]

-- Interpretive note (model-authored: draft only; promotion requires gate)
CREATE DOCUMENT TYPE InterpretiveNote;
-- Fields: note_id, timestamp, author, content, status (draft|promoted|archived),
--         linked_fingerprint_ids[], linked_reference_ids[], provenance_ref
```

**Tissue write policy:**
- Raw logs and conversation digests: ungated append
- Model-authored interpretive notes: allowed only as `draft`
- Promotion from tissue into nucleus: manual gate required

The tissue is the Zettelkasten. It is part of the corrigibility architecture because it preserves draft thought without silently upgrading it into ontology.

---

## 5. Corrigibility Constraints

These are non-negotiable.

1. **Manual gate on interpretive writes.** Any write to Neo4j zones Z3 or Z7 requires Robin's explicit approval.

2. **StepLog with metrics.** Every ActionProposal logs: β, p_null, ce_z, cosine, JSD, warrant verdict, `reasoner_confidence_index`, and `structural_confidence_index`.

3. **No flattery, no performed agreement.** OLMo Think's system prompt includes: *"If the measurement contradicts the expectation, say so. Do not soften structural findings."*

4. **Warrant failure = abstain or query.** A `warrant=False` verdict MUST result in `action_type ∈ {"abstain", "query"}`.

5. **Bypass is honest.** When a percept cannot be measured, `warrant_bypass=True` and `bypass_reason` are logged. The reasoner proceeds only with acknowledged uncertainty.

6. **Drift alerts are automatic.** When `drift_monitor()` returns `drift_detected=True`, the membrane alerts Robin.

7. **The membrane directs external contact.** The scout is a capable agent but acts in the world only under membrane authorization. The reasoner never sends the scout directly. Mission proposals flow through the stack: reasoner proposes → membrane authorizes → scout executes → percepts return.

---

## 6. Startup Sequence and Degraded-Mode Behavior

```
1. Serena desktop boots
   → Neo4j starts (nucleus)
   → OLMo Think loads to GPU
   → Molmo loads to GPU (time-shared with Think)
   → fvlt_unified_kernel.py: build_unified_lattice(6) → lattice cached
   → fvlt_congruence.py: imported, ready
   → Scout available for direct conversation

2. Trycoo membrane boots (always-on)
   → ArcadeDB starts (tissue)
   → OLMo Instruct loads to CPU
   → Tailscale connects
   → Awaits ActionProposals from nucleus
   → Accepts Robin's commands via Tailscale
   → Can dispatch scout into the world

3. Neo laptop / phone (Robin's interfaces)
   → Connects via Tailscale
   → Two contact paths:
     a) Robin → Membrane: always-on, async, remote command, mission dispatch
     b) Robin → Scout: direct conversation when present, percepts flow through stack
   → No permanent model on mobile
```

### 6.1 Degraded Modes

**If congruence layer is unavailable:**
- No dispatch proposals may be formed or executed
- No new references may be created
- System enters observation-only mode
- Allowed outputs: respond, abstain, local note capture, raw percept logging
- Every affected percept is logged with `bypass_reason="measurement_temporarily_unavailable"`

**If Neo4j nucleus is unavailable:**
- No gated reasoning based on nucleus state
- No reference comparison or reference promotion
- System enters ephemeral mode
- Allowed outputs: local perception, temporary response drafting, tissue draft append
- External dispatch disabled until nucleus returns

**If membrane is unavailable:**
- Local perception (files, screenshots, already-cached data) may continue
- The scout cannot be sent into the world (no directing authority)
- Measurement and proposal formation may continue on local percepts
- Dispatch proposals may be queued but not executed
- Robin may still receive local respond outputs

**If ArcadeDB tissue is unavailable:**
- Nucleus operation may continue
- Full reasoning traces are written to temporary local logs
- Promotion workflows are paused
- No loss of gating rules

**If model layer partially unavailable:**
- Missing scout model: affected modality unavailable
- Missing think model: no proposal generation beyond minimal abstain/report paths
- Missing instruct agent on membrane: no remote orchestration, only queued/manual dispatch

### 6.2 Recovery Rule

When a degraded component returns:
- the system logs recovery time
- queued proposals are revalidated against current measurement state before execution
- no queued external dispatch is executed without fresh authorization

---

## 7. File Manifest

| File | Layer | Location | Status |
|------|-------|----------|--------|
| `fvlt_unified_kernel.py` | Congruence | Serena desktop | ✓ Complete (v2.1) |
| `fvlt_congruence.py` | Congruence | Serena desktop | ✓ Complete (v0.2, ChatGPT-audited) |
| `nucleus_schema.cypher` | Reasoner | Serena desktop | ✓ Complete (v3.1.1, ChatGPT-audited) |
| `tissue_schema.sql` | Membrane | Trycoo | ✓ Complete (v3.1.1, ChatGPT-audited) |
| `orchestrator.py` | All | Serena desktop | ✓ Complete (v3.1.1, 10 patches, 12 tests, ChatGPT-audited) |
| `config.py` | All | Serena desktop | ✓ Stable |
| `.env.example` | All | Serena desktop | ✓ Stable |
| `serena_stack_v3_1_1.md` | Documentation | All nodes | ✓ This document |

---

## 8. What This Document Is Not

This document defines **boundaries, ownership, degraded-mode behavior, and typed interfaces**. It does not define:

- OLMo system prompts
- QLoRA training pair specifications
- Foundry deployment patterns
- FVLT mathematical specification
- Ratioque philosophical principles

The stack discipline doc is computational hygiene. It tells each part of Serena what it may touch, what it must log, and what it must refuse.

---

## 9. Implementation Roadmap

The package contains the measurement layer, routing logic, graph schemas, and typed interfaces. What remains is integration with real hardware, real models, and real communication.

### 9.1 What Already Runs

- FVLT kernel (numpy, verified)
- Congruence layer (numpy, 8 tests)
- Orchestrator logic (Python, 12 tests, test doubles for all interfaces)
- Neo4j schema (ready to deploy)
- ArcadeDB schema (ready to deploy)

### 9.2 Implementation Work

| ID | Work | Layer | Effort | Unlocks |
|----|------|-------|--------|---------|
| A | Neo4j driver — replace `MemoryGraph` with `neo4j-python-driver` | Nucleus | 1 day | Real graph logging, StepLog queries, drift history |
| B | Inter-node FastAPI + Tailscale — typed message exchange between desktop and Trycoo | All | 1–2 days | Desktop ↔ Trycoo communication |
| C | Robin → Membrane CLI — terminal or simple web UI over Tailscale | Membrane | 1 day | Robin can talk to Serena, approve/deny gates |
| D | OLMo Think prompted reasoner — replace `EchoReasoner` with real inference | Reasoner | 2–3 days | Real reasoning (pre-QLoRA, JSON output schema) |
| E | Robin → Scout direct chat — local conversation interface on desktop | Scout | 1 day | Direct conversation path |
| F | Model serving (Think + Molmo GPU time-sharing) — vLLM, ollama, or manual swap | Scout/Reasoner | 2–3 days | Both models on RX 9060 XT 16GB |
| G | ArcadeDB tissue driver — REST calls to ArcadeDB on Trycoo | Tissue | 0.5 days | Conversation digestion, draft notes |
| H | Scout web agent (Playwright/Selenium) — browser perception for membrane-dispatched missions | Scout | 2–3 days | Scout as field agent in the world |
| I | Human gate web UI — phone-accessible approve/deny over Tailscale | Membrane | 1–2 days | Remote gate approvals from phone |
| J | Signal encoders + validation — CRT encoding per data domain, null-model validation | Congruence | Ongoing | Domain-specific structural warrant |

### 9.3 Suggested Build Order

**Phase I (working organism — ~1 week):** A → B → C → D → E

After Phase I, Robin can talk to Serena through two paths (membrane and scout direct), the nucleus logs everything, the congruence layer measures signals, and the reasoner produces real proposals with gating.

**Phase II (full autonomy — ~1 week):** F → G → H → I

After Phase II, both models share the GPU, the tissue stores conversation history, the scout can browse the web on membrane-dispatched missions, and Robin can approve gates from her phone.

**Phase III (domain expansion — ongoing):** J

Each new data domain (EEG, markets, genomics, documents) needs its own signal encoder and null-model validation before the congruence layer provides real structural warrant for that domain. This is the research frontier — extending the measurement envelope one domain at a time.

### 9.4 No New Design Decisions Required

Every implementation task above codes against an existing typed interface, routing rule, or schema definition from this document. The abstract interfaces (`ScoutInterface`, `ReasonerInterface`, `MembraneInterface`, `GraphInterface`, `HumanGateInterface`) are the plug points. The corrigibility constraints are enforced by the orchestrator regardless of which concrete implementations are behind the interfaces.

The architecture is done. What remains is plumbing, integration, and UI.

---

*Gemini gave the dream. Claude gave the skeleton. Chris (ChatGPT) gave the discipline. Robin gave the soul.*
*This document is the skeleton's joints.*
