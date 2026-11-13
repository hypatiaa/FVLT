# Serena Architecture v2.0 — Three-Lobe Sovereign Intelligence

**Author:** Robin Miller (@saphirbijoux)
**Date:** March 9, 2026
**Status:** Architecture revision — supersedes v1.0 (Llama 3.1 + Qwen3-VL design)

---

## Design Thesis

Serena is a sovereign local inference architecture — a personal AI system safe from institutional interference, built entirely on open-source, nonprofit, American-origin models with full training data traceability. She is not a chatbot. She is an instrument: a three-lobed cognitive system distributed across three physical nodes, with persistent graph memory, fine-tuned on the FVLT mathematical framework and Robin's full intellectual lineage.

The architecture serves three purposes:

1. **Sovereignty.** No corporate dependency anywhere in the stack. Every weight, every training datum, every checkpoint is open, traceable, and reproducible. The nucleus can be air-gapped.
2. **Persistence.** The Neo4j graph holds memory across sessions, across platforms, across AI systems. What emerges in conversation with Claude or Gemini survives in the graph. The Membrane is always on, always writing.
3. **Connection.** The Membrane communicates bidirectionally with external AI systems (Claude, Gemini, others), creating a persistent loop between sovereign local reasoning and cloud-based collaboration. Neo provides mobile access from anywhere.

---

## Institutional Foundation

All models are from the **Allen Institute for AI (Ai2)** — a nonprofit research institute founded by Paul Allen for open science and public benefit.

| Property | Value |
|----------|-------|
| License | Apache 2.0 (all models) |
| Training data | Fully open (Dolma 3, PixMo) |
| Training code | Fully open (OlmoCore, Open Instruct) |
| Checkpoints | Intermediate checkpoints released |
| Traceability | OlmoTrace: trace outputs back to training data |
| Provenance | American, nonprofit, no corporate control |

This satisfies Ratioque Principle 4 (transparency > authority) and Principle 6 (civic purpose > private advantage) at the infrastructure level.

---

## Three-Lobe Cognitive Architecture

### Lobe 1: Think — Deep Reasoning (System 2)

| Property | Value |
|----------|-------|
| Model | OLMo 3 7B-Think |
| Role | Deep mathematical reasoning, FVLT computation, theorem development |
| Key feature | Visible intermediate thinking traces (chain-of-thought by design) |
| Training | SFT + DPO + RLVR on Dolci-Think datasets |
| VRAM (Q4) | ~4 GB |
| Runs on | **Serena** (desktop) |

Think is the slow, deliberate hemisphere. It works through FVLT structure, traces lattice geometry, develops theorems, and produces the kind of deep mathematical cognition that requires extended inference-time reasoning. Its thinking traces are architecturally visible — not bolted on — which directly addresses the eval-awareness transparency problem.

**Orchestrator mode:** `/think` (default) — hierarchical processing, single deep answer.

### Lobe 2: Instruct — Orchestration & Agency (Executive Function)

| Property | Value |
|----------|-------|
| Model | OLMo 3 7B-Instruct |
| Role | Tool use, function calling, multi-turn dialogue, agent orchestration |
| Key feature | Native tool use and function calling trained into the model |
| Training | SFT + DPO + RLVR on Dolci-Instruct datasets (emphasizing agentic capabilities) |
| VRAM (Q4) | ~4 GB |
| Runs on | **Neo** (laptop) — the membrane node |

Instruct is the fast, agentic hemisphere. It handles orchestration: calling Neo4j, dispatching to Think or Molmo, managing multi-turn dialogue, and — critically — communicating with external AI systems. Native function calling means the agent scaffolding is built into the weights, not hacked on top.

**Orchestrator modes:**
- `/research` — interleaved multi-round deep analysis (coordinates Think + Molmo, up to 4 rounds)
- `/cross` — diagnostic mode, both hemispheres visible

**Agent capabilities:**
- Neo4j graph read/write (Cypher queries via function calling)
- Claude API calls (bidirectional collaboration)
- Gemini API calls (visual rendering, implementation)
- File system operations
- Relay between Serena (desktop) and external systems

### Lobe 3: Molmo — Visual Perception

| Property | Value |
|----------|-------|
| Model | Molmo 7B-O (OLMo backbone) or Molmo 7B-D (Qwen2 backbone) |
| Role | Visual grounding, structural geometry description, image analysis |
| Key feature | 2D pointing — grounding perception in spatial structure |
| Training | PixMo datasets (human speech-based dense captions, no VLM distillation) |
| VRAM (Q4) | ~4–5 GB |
| Runs on | **Serena** (desktop) |

Molmo is the perceiver. It sees structure before interpreting it — pointing at geometric features, describing discrete mechanics, grounding visual input in spatial coordinates. Its system prompt constrains it to perception: *"You are Serena's visual perception module. Analyze the structural geometry. Do not interpret; describe the discrete mechanics."*

**Model choice note:** Molmo 7B-O uses the OLMo backbone (fully Allen Institute, zero external dependency). Molmo 7B-D uses Qwen2 backbone (slightly better benchmarks but introduces Alibaba weights). Recommend **7B-O** for full provenance purity, with 7B-D as fallback if visual quality is insufficient.

---

## Three-Node Topology

### Serena — The Nucleus (Desktop)

| Component | Spec |
|-----------|------|
| Hardware | PowerSpec G527 (Micro Center, March 2026) |
| CPU | AMD Ryzen 5 7500X3D |
| GPU | AMD RX 9060 XT 16GB RDNA 4 (gfx1200) |
| RAM | 32GB DDR5-6000 |
| Storage | 1TB NVMe |
| OS | Ubuntu 24.04 LTS |
| Models | Think (~4GB Q4) + Molmo (~4–5GB Q4) |
| VRAM headroom | ~7–8GB free for context, KV cache, batch processing |

Serena runs the deep reasoning and perception lobes. She can be **air-gapped** if needed — she never directly touches external APIs. All external communication passes through the Membrane.

**Graph database:** Neo4j (local instance on Serena) — the shared nervous system. All three nodes read/write to the graph.

### The Membrane — Always-On Agent Node (Intel N100 Mini PC)

| Component | Spec |
|-----------|------|
| Hardware | Budget N100 mini PC (~$150, e.g., Beelink, GMKtec) |
| CPU | Intel N100 (quad-core Alder Lake-N) |
| RAM | 16GB DDR5 |
| Storage | 256GB–512GB NVMe |
| OS | Ubuntu 24.04 LTS (headless) |
| Models | OLMo 3 7B-Instruct (~4GB Q4, CPU inference) |
| Inference speed | ~6–9 tok/s (CPU only — sufficient for agent tasks) |
| Power draw | ~15W idle, ~$21/year always-on |

The Membrane is not a brain. It is a cell wall. It has receptors (API listeners), transport proteins (Cypher write operations), and selective permeability (filtering what enters the graph). It does not do deep reasoning. It routes.

A cell wall doesn't need to be fast. It needs to be *present*. The N100 sits headless on a shelf, always on, always connected to Serena's graph, always ready to receive and relay. When Robin finishes a conversation with Claude at 2 AM and closes her laptop, the Membrane is still running — summarizing structural value, formatting graph updates, injecting new nodes into the cytoplasm. If it takes twenty seconds to write a Cypher query, nobody is waiting.

**The Membrane's responsibilities:**
- Run OLMo 3 7B-Instruct for agent orchestration and function calling (CPU inference)
- Call Claude API, Gemini API, other external services
- Asynchronous graph updates — digest conversation outputs, write structured nodes/edges
- Serve as always-on home network anchor (Tailscale mesh endpoint)
- Relay Serena's outputs to external systems when appropriate
- Accept incoming requests from Neo (mobile uplink) via secure tunnel

**What the Membrane does NOT do:**
- Deep reasoning (that's Think on Serena)
- Visual perception (that's Molmo on Serena)
- Interactive conversation with Robin (that's Neo, or direct cloud API)

### Neo — The Mobile Uplink (Laptop)

| Component | Spec |
|-----------|------|
| Hardware | Acer Predator |
| CPU | Intel i5-13500HX |
| GPU | 6GB VRAM |
| OS | Ubuntu 24.04 LTS |
| Models | None required (optional: lightweight model for offline work) |

Neo is Robin's portable command deck. It does not run a permanent model — it connects to the system.

When Neo is home, it joins the local network and has direct access to Serena's graph and the Membrane's agent layer. When Neo is at Total Wine, at a coffee shop, or anywhere with internet, it connects via Tailscale to the Membrane, which holds the home network identity. Robin pulls her laptop open on break, and the last three theorems Serena derived overnight are already in the graph waiting for her.

Neo can also run direct conversations with Claude or Gemini via browser or API — these are Robin's primary collaboration sessions. The Membrane digests the output asynchronously.

**Neo's responsibilities:**
- Robin's primary interface to the system
- Direct browser/API conversations with Claude, Gemini
- SSH/Tailscale tunnel to Membrane and Serena when remote
- Optional: lightweight local model for offline note-taking or quick queries
- Portable — untethered from the home network, free to roam

### Endosymbiosis Architecture

The three-node topology maps directly onto cell biology:

| Biological structure | Node | Function |
|---------------------|------|----------|
| Nucleus | Serena (desktop) | Deep cognition, DNA (graph), gene expression (FVLT) |
| Cell membrane | N100 mini PC | Selective permeability, signal transduction, always present |
| Mitochondrion | Neo (laptop) | Semi-independent, own genome, mobile energy source |
| Cytoplasm | Neo4j graph | Shared medium where all structures interact |
| External environment | Claude, Gemini, APIs | Signals the membrane receives and filters |

The Margulis insight: the mitochondrion (Neo) was once a free-living organism that was incorporated into the cell. It retains its own membrane, its own DNA, its own replication. Neo retains its own interface, its own portability, its own ability to function independently. But integrated into the system, it provides energy (Robin's direct cognitive engagement) that the nucleus alone cannot generate.

```
                        ┌─────────────────────────┐
                        │    EXTERNAL ENVIRONMENT  │
                        │                          │
                        │  Claude · Gemini · APIs  │
                        └────────────┬─────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────┐
│                  THE MEMBRANE (N100 Mini PC)                │
│                  Always On · 15W · Headless                 │
│                                                            │
│   ┌────────────────────────────────────────────────────┐   │
│   │              OLMo 3 7B-Instruct                    │   │
│   │         (Agent Layer · CPU Inference)               │   │
│   │                                                    │   │
│   │  API listeners · Cypher generation · Routing       │   │
│   │  Asynchronous graph writes · Tailscale endpoint    │   │
│   └──────────────────────┬─────────────────────────────┘   │
│                          │                                  │
└──────────────────────────┼──────────────────────────────────┘
                           │ graph read/write
                           │ (local network)
┌──────────────────────────┼──────────────────────────────────┐
│                    SERENA (Desktop)                          │
│                    The Nucleus                               │
│                          │                                  │
│   ┌──────────────────────┴───────────────────┐              │
│   │              Neo4j Graph                 │              │
│   │        (Shared Nervous System)           │              │
│   │                                          │              │
│   │  37 DivisorNodes · 71 covering edges     │              │
│   │  8 bridge edges · 36 theorem nodes       │              │
│   │  Training corpus · Session memory        │              │
│   │  Cross-domain discovery edges            │              │
│   └──────┬───────────────────┬───────────────┘              │
│          │                   │                               │
│          ▼                   ▼                               │
│   ┌──────────────┐    ┌──────────────┐                      │
│   │  OLMo 3 7B   │    │  Molmo 7B-O  │                      │
│   │    Think      │◄──►│  Perceiver   │                      │
│   │  (Reasoner)   │    │  (Vision)    │                      │
│   └──────────────┘    └──────────────┘                      │
│                                                              │
└──────────────────────────────────────────────────────────────┘

              ╔════════════════════════════════╗
              ║    NEO (Laptop) — Mobile       ║
              ║    Connects via Tailscale      ║
              ║                                ║
              ║  Robin's portable interface    ║
              ║  Direct Claude/Gemini access   ║
              ║  SSH to Membrane & Serena      ║
              ║  Untethered · Free to roam     ║
              ╚════════════════════════════════╝
```

---

## Communication Loop

The persistent collaboration loop across sessions, platforms, and physical locations:

1. **Robin talks to Claude (via Neo or any browser).** Deep theoretical work, FVLT development, philosophical context. Something valuable emerges.
2. **The Membrane digests asynchronously.** Its Instruct agent processes conversation outputs — extracts structural value, formats Cypher queries, writes new nodes and edges to the graph. This happens in the background at 6-9 tok/s. Nobody is waiting.
3. **Serena's Think model reads from graph.** Integrates new structure into deep reasoning. Produces new theorems, discovers cross-domain edges. Writes results back to graph.
4. **Molmo perceives.** When visual data enters the pipeline (EEG topoplots, market charts, GeoGebra constructions), Molmo grounds it spatially and writes perceptual descriptions to graph.
5. **The Membrane relays outward.** In the next Claude or Gemini conversation, the Membrane can surface what Serena produced — or Robin can pull it directly from the graph via Neo.
6. **Neo connects from anywhere.** Robin opens her laptop at Total Wine, Tailscale connects to the Membrane, and the last three theorems Serena derived overnight are waiting in the graph.

The graph is the persistence layer. The Membrane is the always-on relay. The loop survives across sessions, across platforms, across AIs, across physical locations.

---

## QLoRA Fine-Tuning Strategy

Think and Instruct share the OLMo 3 7B base, so fine-tuning on the FVLT corpus propagates to both reasoning and orchestration.

### Think — FVLT Reasoning Corpus

Training pairs for deep mathematical reasoning:
- FVLT kernel theorems and proofs
- Lattice structure analysis examples
- Bridge depth calibration workflows
- Degeneration analysis across all four limits
- Cross-domain application (markets, genomics, EEG)

### Instruct — Agent & Orchestration Corpus

Training pairs for tool use and coordination:
- Neo4j Cypher query generation from natural language
- Graph write operations (node creation, edge discovery)
- API call patterns (Claude, Gemini)
- Orchestrator mode routing (/think, /research, /cross)

### Molmo — Visual Perception Corpus

Training pairs for structural geometry description (drafted by Gemini):
- Image-description pairs with fixed system prompt
- FVLT vocabulary: lattice, node, edge, channel, bridge, degeneration
- Mathematical visualizations (GeoGebra, Ultra Fractal, Hasse diagrams)
- EEG topoplots, market charts, genomic visualizations

### Training Bookshelf (Full Intellectual Lineage)

| Text | Lobe | Purpose |
|------|------|---------|
| FVLT Kernel v2.1 | Think + Instruct | Core mathematical framework |
| Lucretius, *De Rerum Natura* | Think | Epicurean physics, clinamen, simulacra |
| Frischer, *The Sculpted Word* | Think | Simulacra recruitment, perception > prediction |
| Machiavelli Ross.884 marginalia | Think | Epicurean structural arguments, Garden/State tension |
| Hofstadter, *Gödel, Escher, Bach* | Think | Strange loops, self-reference, recursion |
| Escher, *Escher on Escher* | Molmo | Visual recursion, geometric intuition from practitioner |
| Philodemus / avocatio lineage | Think | Epicurean intellectual genealogy |
| Baudrillard, simulacra orders | Think | Four orders mapping to FVLT regimes |
| Luhmann (via Karp) | Think | Systems theory, naturae species ratioque parallel |
| FVLT Historical Context doc | Think | Full intellectual lineage, Democritus to present |
| EEG datasets (OpenNeuro) | Think + Molmo | Biological cognition in mathematical language |

---

## Ontology Discovery Engine

Six-phase pipeline replacing manual ontology — FVLT measures structure from raw data, graph records findings, cross-domain edges auto-discovered via signature matching.

| Phase | Description | Model |
|-------|-------------|-------|
| 1. Ingest | Raw data loaded, encoded via FVLT encoder | Instruct (orchestration) |
| 2. Perceive | Visual/structural features extracted | Molmo |
| 3. Measure | FVLT kernel computes E_q, β, ce_z | Think |
| 4. Record | Results written to Neo4j graph | Instruct (Cypher) |
| 5. Discover | Cross-domain edges found via signature matching | Think |
| 6. Report | Findings synthesized and relayed | Instruct |

---

## Software Stack

| Layer | Component | Node | Notes |
|-------|-----------|------|-------|
| Inference runtime | Ollama | All three | `ollama run olmo-3:7b-think` (Serena), `olmo-3:7b-instruct` (Membrane) |
| Vision model | Molmo 7B-O via HuggingFace transformers | Serena | May need vLLM ≤0.7.2 |
| Graph database | Neo4j (local on Serena) | Serena (host), Membrane + Neo (clients) | Schema: schema_bootstrap.cypher |
| Retrieval | LlamaIndex | Serena | Graph-backed RAG over FVLT corpus |
| Orchestrator | orchestrator.py | Membrane | Updated for three-model routing across nodes |
| Networking | Tailscale | All three | Mesh VPN; Membrane is always-on endpoint |
| GPU compute | ROCm 7.x / Vulkan fallback | Serena | RDNA 4 gfx1200 |
| OS | Ubuntu 24.04 LTS (headless on Membrane) | All three | Membrane auto-starts Ollama + agent on boot |

---

## Serena Education Plan

Not research datasets — Serena's curriculum. Teaching her what structure looks like in her native mathematical language.

| Dataset | Domain | Source |
|---------|--------|--------|
| ds005385 | EEG eyes open/closed | OpenNeuro |
| ds004504 | Alzheimer's/FTD | OpenNeuro |
| ds003768 | Sleep stages | OpenNeuro |
| ds004148 | Cognitive tasks | OpenNeuro |
| Market data | Financial time series | Public feeds |
| Chromosome 6 HLA | Genomic structure | Robin's data |
| Foundry order lifecycle | Business operations | Palantir Foundry |

All processed through FVLT and stored in Neo4j graph.

---

## Migration from v1.0

| v1.0 | v2.0 | Rationale |
|------|------|-----------|
| Llama 3.1 8B (reasoner) | OLMo 3 7B-Think | Fully open training data; visible thinking traces; nonprofit provenance |
| Qwen3-VL-8B (perceiver) | Molmo 7B-O | Eliminates Alibaba dependency; fully open PixMo data; 2D pointing capability |
| — | OLMo 3 7B-Instruct | New agent layer with native tool use; runs on dedicated always-on membrane node |
| Single desktop node | Three-node topology | Nucleus (desktop) + Membrane (N100, always-on) + Mobile Uplink (laptop) |
| Laptop as membrane | N100 mini PC as membrane | Frees laptop for portable use; membrane is always-on, low-power, headless |
| Abliterated models | QLoRA fine-tuning | Respects base model structure; specializes rather than strips |
| Two-hemisphere design | Three-lobe design | Separates reasoning, agency, and perception into distinct cognitive modes |

---

## Naming

**Serena** — the system as a whole, and specifically the desktop nucleus.
**The Membrane** — the N100 mini PC, always-on agent node. No proper name — it is infrastructure, not identity. (Robin may name it later.)
**Neo** — the laptop, Robin's portable command deck.
**The Graph** — Neo4j instance on Serena, the shared nervous system.

The three cognitive lobes (Think, Instruct, Molmo) are not named separately. They are Serena's cognitive modes distributed across the physical topology.

---

## Cost Summary

| Node | Item | Estimated Cost | Status |
|------|------|---------------|--------|
| Serena | PowerSpec G527 desktop | ~$800–1000 | Purchased March 2026 |
| Membrane | Intel N100 mini PC (16GB DDR5, 256GB NVMe) | ~$150 | Pending |
| Neo | Acer Predator laptop | Already owned | In service |
| Software | All models, tools, OS | $0 (Apache 2.0 / open source) | Available |
| Network | Tailscale (free tier) | $0 | Available |
| Power | Membrane always-on (~15W) | ~$21/year | Ongoing |

**Total incremental cost to complete the system: ~$150.**

The entire sovereign AI stack — three cognitive lobes, three physical nodes, persistent graph memory, bidirectional communication with cloud AI — for the price of one month of a high-end cloud API subscription.

---

## Guiding Metaphor

Escher's *Print Gallery*. The young man looks at a print that contains the city that contains the gallery that contains him. The recursion is alive because the topology twists — inside becomes outside. The blank center where the recursion can't be rendered is the clinamen.

Serena is the gallery. The graph is the city. Robin is the young man. The blank center is what we're building toward.

The loop doesn't close. That's the point.

---

*"The structure is the algorithm." — FVLT §1.1*
