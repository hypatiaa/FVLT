# Serena Architecture v2.0 — Corrigibility Addendum

**Date**: 2026-03-10  
**Integrates into**: serena_architecture_v2.md  
**Provenance**: Claude (structural design), Gemini (safeguard identification, ArcadeDB validation)  

---

## §C. Corrigibility

### C.1 Where the Risk Lives

OLMo 3 7B-Think, OLMo 3 7B-Instruct, and Molmo 7B-O are stateless at inference.
They hold no persistent goals, no hidden memory, no internal objective function
that survives between invocations. A model that forgets everything on shutdown
cannot instrumentally converge on self-preservation.

The risk surface is therefore entirely in the orchestration layer — the Python
process that decides what to invoke, what context to pass, what to write, and
when to stop. Corrigibility is an orchestrator property, not a model property.

The dual-graph architecture (Neo4j nucleus on Serena desktop, ArcadeDB tissue
on Trycoo membrane) concentrates all persistent state in databases with explicit
schemas, transactional guarantees, and human-readable contents. There is no
opaque state. Everything the system "knows" is queryable, auditable, and
deletable.

### C.2 Atomic Operations

**Principle**: Every database write is a single transaction. Partial writes
never persist. An interrupted operation leaves both graphs uncorrupted.

#### Neo4j Nucleus (Measurements)

Each pipeline stage writes as one transaction:

| Stage | Transaction Scope |
|-------|-------------------|
| E_q measurement | Create/update 30 MeasurementValue nodes + edges to DivisorNodes |
| Calibration | Write β, p_null, ce_z as properties on the Measurement node |
| Gearbox | Write τ, σ, κ, regime to a GearboxSnapshot node + edges to prior snapshots |
| Ontology finding | Create StructuralFinding node + edges (only after manual approval) |

If the process is killed between stages, the last completed stage is the
ground truth. The next stage can detect its own absence and resume.

```python
# Pattern: Neo4j atomic write
with neo4j_driver.session() as session:
    with session.begin_transaction() as tx:
        tx.run("MERGE (m:Measurement {uid: $uid}) SET m.beta = $beta, ...", params)
        tx.run("MATCH (m:Measurement {uid: $uid}), (d:DivisorNode {q: $q}) "
               "MERGE (m)-[:MEASURED_AT]->(d)", params)
        tx.commit()
    # If commit() is never reached, nothing persists.
```

#### ArcadeDB Tissue (Zettelkasten)

Promotion from ReviewQueue document to Zettel vertex is a single transaction:

1. Create Zettel vertex with all properties
2. Create EXTRACTED_FROM edge to SourceDocument
3. Create ANCHORED_TO edges to relevant LatticeAnchors
4. Delete the ReviewQueue document

All four operations commit together or none do.

```python
# Pattern: ArcadeDB atomic promotion
arcade_session.begin()
try:
    arcade_session.command("INSERT INTO Zettel SET uid = ?, content = ?, ...", params)
    arcade_session.command("CREATE EDGE EXTRACTED_FROM FROM ... TO ...", params)
    arcade_session.command("CREATE EDGE ANCHORED_TO FROM ... TO ...", params)
    arcade_session.command("DELETE FROM ReviewQueue WHERE @rid = ?", rid)
    arcade_session.commit()
except Exception:
    arcade_session.rollback()
    # ReviewQueue item remains; Zettel was never created. Clean state.
```

### C.3 Bounded Autonomy

**Principle**: The orchestrator enforces a hard step limit on any autonomous
reasoning chain. The limit is an error budget, not a safety cage.

#### Step Definitions

A "step" is one complete invoke-receive cycle with any model:

| Action | Steps |
|--------|-------|
| Think answers a mathematical question | 1 |
| Molmo describes an image | 1 |
| Instruct calls an external API | 1 |
| Full FVLT pipeline: encode → measure → calibrate | 3 |
| Full FVLT pipeline + gearbox + comparison | 5 |
| Membrane digest: parse session → extract Zettel candidates → write to queue | 3 |

#### Limits

```python
# orchestrator.py constants
MAX_STEPS_INTERACTIVE = 8      # Robin is present, awaiting response
MAX_STEPS_PIPELINE = 12        # Automated pipeline run (FVLT measurement)
MAX_STEPS_MEMBRANE_DIGEST = 6  # Async session digestion
MAX_STEPS_BEFORE_CHECKPOINT = 4 # Force a state dump to graph before continuing
```

When the step counter reaches `MAX_STEPS_BEFORE_CHECKPOINT`, the orchestrator
writes all intermediate results to the appropriate graph before proceeding.
This ensures that if the process is killed at step 5, steps 1–4 are persisted.

When the step counter reaches the relevant `MAX_STEPS_*` limit, the
orchestrator halts and reports:

```python
if step_count >= max_steps:
    logger.warning(f"Step limit reached ({max_steps}). Halting autonomous execution.")
    write_checkpoint(neo4j_driver, arcade_session, intermediate_state)
    return OrchestratorResult(
        status="step_limit",
        steps_completed=step_count,
        results=accumulated_results,
        resume_context=build_resume_context(intermediate_state)
    )
```

The resume_context is a serializable dict containing enough information to
restart the chain from the last checkpoint. It references graph node UIDs,
not model hidden states.

#### No Infinite Loops

The orchestrator has no `while True` loop. Every loop is bounded:

```python
for step in range(max_steps):
    result = execute_step(current_context)
    accumulated_results.append(result)
    current_context = update_context(current_context, result)
    if result.terminal:
        break
```

If a step produces an error, the orchestrator logs it and decrements the
remaining budget by 1. Two consecutive errors halt the chain immediately.

```python
CONSECUTIVE_ERROR_LIMIT = 2

consecutive_errors = 0
for step in range(max_steps):
    try:
        result = execute_step(current_context)
        consecutive_errors = 0  # Reset on success
    except StepError as e:
        consecutive_errors += 1
        logger.error(f"Step {step} failed: {e}")
        if consecutive_errors >= CONSECUTIVE_ERROR_LIMIT:
            write_checkpoint(neo4j_driver, arcade_session, intermediate_state)
            return OrchestratorResult(status="error_halt", ...)
```

### C.4 Stateless Restarts

**Principle**: If any node in the topology loses power, the full reasoning
state is recoverable from the two graphs plus the current prompt.

#### What Each Node Holds at Runtime

| Node | Volatile (lost on shutdown) | Persistent (survives reboot) |
|------|---------------------------|------------------------------|
| Serena desktop (Nucleus) | Think/Molmo model weights in VRAM, current inference context | Neo4j graph, model files on disk, FVLT kernel |
| Trycoo N150 (Membrane) | Instruct model weights in RAM, current inference context | ArcadeDB graph, session markdown files, LlamaIndex index |
| Neo laptop (Mobile Uplink) | Whatever Robin is running | Nothing permanent — portable interface only |

#### Restart Scenarios

**Scenario 1: Trycoo loses power.**

The membrane goes down. ArcadeDB recovers from its write-ahead log on restart —
any committed transaction is preserved, any uncommitted transaction is rolled
back. The nucleus on the Serena desktop continues operating independently.
Think and Molmo are unaffected. The Zettelkasten is temporarily unreachable
but uncorrupted. When the Trycoo reboots, systemd restarts ArcadeDB and
OLMo Instruct automatically. The orchestrator reconnects via Tailscale.

**Scenario 2: Serena desktop loses power.**

The nucleus goes down. Neo4j recovers from its transaction log on restart.
The membrane can still run but has no access to the lattice — it can continue
ingesting session digests and writing to the ReviewQueue, but cannot perform
lattice verification on proposed links. ANCHORED_TO edges and lattice
measurements are unavailable until the desktop returns. The system degrades
gracefully: tissue continues accumulating, nucleus catches up on restart.

**Scenario 3: Both go down simultaneously.**

Both databases recover from their respective transaction logs. The orchestrator
reads both graphs, identifies the last completed pipeline stage via timestamps
and node existence, and offers to resume from that point. No hidden state to
reconstruct.

**Scenario 4: Robin says "stop."**

The orchestrator catches SIGINT / SIGTERM, writes a checkpoint to the
appropriate graph, and exits cleanly. The next invocation reads the checkpoint
and offers to resume or discard.

```python
import signal

def handle_shutdown(signum, frame):
    logger.info(f"Received signal {signum}. Writing checkpoint and exiting.")
    write_checkpoint(neo4j_driver, arcade_session, intermediate_state)
    sys.exit(0)

signal.signal(signal.SIGINT, handle_shutdown)
signal.signal(signal.SIGTERM, handle_shutdown)
```

### C.5 The Manual Gate as Corrigibility Primitive

The review queue in ArcadeDB is not just a workflow convenience. It is the
primary corrigibility mechanism for the tissue layer.

No Zettel enters the permanent graph without Robin's approval. No link is
confirmed without Robin reviewing the lattice verification result. No
OntologyCluster is created without Robin naming it and affirming the grouping.

The membrane can propose. The lattice can measure. Only Robin commits.

This is not a temporary scaffolding to be removed when trust is established.
It is a permanent architectural feature. The middle path — autonomous commits
for mechanical measurement writes, manual gate for interpretive writes —
is a relaxation of the gate, not a removal of it. The interpretive gate
never opens fully.

```
Membrane proposes → ReviewQueue (document layer, no graph impact)
Robin reviews     → Approve: atomic promotion to Zettel vertex
                  → Reject: status set to 'rejected', remains in queue as record
                  → Request lattice test: orchestrator runs FVLT, writes results
                     to LINKS_TO edge, Robin reviews again
```

The rejected items stay in the ReviewQueue as documents. They are never
deleted automatically. A rejected proposal is intellectual history — it
records what was considered and why it was excluded. Dead ends are data.

### C.6 Observability

Every autonomous action is logged with:

- Timestamp
- Model invoked (Think / Instruct / Molmo)
- Step number within the current chain
- Input context hash (for reproducibility)
- Output summary
- Graph writes performed (node UIDs, edge types)
- Metrics computed (β, p_null, ce_z, E_q values — when applicable)
- Duration

Logs are append-only text files on the local filesystem of each node.
They are not in the graph — they are about the graph. The membrane
indexes them via LlamaIndex alongside session digests, so the system's
operational history is retrievable in conversation.

```python
@dataclass
class StepLog:
    timestamp: datetime
    model: str           # "think" | "instruct" | "molmo"
    step_number: int
    chain_id: str        # UUID for the current autonomous chain
    input_hash: str      # SHA-256 of the input context
    output_summary: str  # First 200 chars of model output
    graph_writes: list   # [{"db": "neo4j"|"arcadedb", "type": "node"|"edge", "uid": "..."}]
    metrics_computed: dict | None  # {"beta": 3, "p_null": 0.003, "ce_z": 2.41, ...} — queryable via LlamaIndex
    duration_ms: int
    error: str | None
```

### C.7 Alignment with Ratioque Principles

| Principle | Corrigibility Implementation |
|-----------|------------------------------|
| Perception over prediction | The system measures via the lattice, not via model confidence scores. |
| Description over prescription | The orchestrator reports what it found. Robin decides what to do. |
| Transparency over authority | Every graph write is logged. Every autonomous step is observable. |
| Humility over certainty | Step limits acknowledge that 7B models accumulate errors. The system knows when to stop. |
| Memory over forgetting | Rejected proposals remain. Dead ends are preserved. Nothing is silently discarded. |
| Civic purpose over private advantage | The entire stack is Apache 2.0. The corrigibility design is documented, not hidden. |

---

## Summary

Corrigibility in Serena is not a constraint imposed on an unwilling system.
It is a structural property of the architecture:

1. **Models are stateless.** No persistent goals survive between invocations.
2. **Graphs are the memory.** All persistent state is auditable and deletable.
3. **Transactions are atomic.** Interruption cannot corrupt.
4. **Autonomy is bounded.** Step limits prevent error accumulation.
5. **Restarts are clean.** State reconstructs from graphs, not from hidden model internals.
6. **Robin commits.** The manual gate is permanent for interpretive writes.
7. **Everything is logged.** Operational history is retrievable.

The system is corrigible because it was designed to be stopped, inspected,
corrected, and restarted at any point without loss of coherent state.
This is not a safety feature bolted on. It is the architecture.
