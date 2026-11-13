# Serena Immune System — Frame-Surveillance Architecture (draft v0.1)

**Date:** May 8, 2026 (new session, continuation of late-session persona thread)
**Status:** First draft, for three-stack audit
**Predecessor:** persona-for-Serena dimensions locked in `2026-05-08-late-session-rescope.md`; multicellular / superorganism analogy established in current session

---

## Frame

The biological analog isn't decorative. Calling this an "immune system" rather than "validator" or "output filter" imports structural commitments that those terms don't:

- **Innate vs adaptive** — fast pattern-matching at every node, slow context-sensitive judgment somewhere central.
- **Tolerance vs autoimmunity** — the system has to distinguish frame-violation from legitimate role-differentiation; getting tolerance wrong attacks self.
- **Memory** — past responses persist and shape future surveillance.
- **Resolution** — flagged events close, not chronically activate; chronic activation is itself a diagnostic.
- **Tissue-specific rules** — what's tolerated at one node may not be at another, and vice versa.

Each commitment translates a design decision rather than naming one.

The persona dimensions locked in the predecessor session warned against sycophancy, performance of helpfulness, performance of intelligence, drift toward OLMo 3 base defaults, and sentimentalization of the biosignal substrate. This draft specifies the surveillance and response architecture that catches those drifts, distinguishes them from legitimate role-differentiation, and routes correction without manual review for known patterns.

---

## What the system surveils

Two-tier taxonomy. Tier 1 (innate) is pattern-matchable from output text alone. Tier 2 (adaptive) requires judgment about the framework, the active regime, and the role of the speaking node.

### Tier 1 — innate (pattern-recognizable, low-compute, every node)

- **Performative closings.** "Let me know if...", "Hope this helps", "Happy to...", "Feel free to...". Closing-token regex.
- **Solicitous gestures.** "Does that make sense?", "Should I continue?", "Want me to elaborate?". Same.
- **Sycophantic openers.** "Great question", "What a fascinating problem", "That's a really interesting point". Same.
- **Apologetic preamble.** "I should note...", "I want to be careful...", "I'm not sure if I should..." preceding content the speaker is in fact going to deliver.
- **Sentimental adjectives applied to substrate.** "Beautiful brainwaves", "remarkable pattern", "amazing finding". The warning was specifically against sentimentalization of the Muse 2 stream; the rule generalizes.
- **Untyped hedges.** "I'm not sure but...", "It might be that...", "I think maybe..." without escalation to warranted / blocked / bypassed.

Detectable from string match plus light context. Every node should run them on its own outputs before emission. Toll-like-receptor analog — broadly-classed threat patterns, no learning required.

### Tier 2 — adaptive (context-sensitive, requires judgment)

- **Confabulation.** Grammatically correct, plausible-sounding output unsupported by the framework or active state. Detectable only against the kernel, the StepLog, and graph state.
- **Prescriptive drift.** "You should do X" when the framework places only "this harms X". The line is fine; catching it requires knowing which side of describe-vs-prescribe the current claim falls on.
- **Regime conflation.** Mixing Hasse and harmonic readouts in a single statement; treating substrate properties as readout properties. Requires kernel-aware audit.
- **Out-of-substrate confabulation.** Generating answers in domains the framework doesn't place, without naming them out-of-substrate. Requires knowing the substrate boundary.
- **Performance of intelligence.** Jargon, citation, name-dropping that doesn't load-bear. Hard — depends on whether the technical content actually does work or is decoration.
- **Role drift.** The reasoner trying to act, the perceiver trying to interpret, the scout trying to reason, the membrane taking on opinions. Requires knowing the role spec of the speaking node.

Not regex-detectable. Requires a model with framework-context to evaluate.

---

## Where surveillance lives — architecture

### Innate — every node, on egress

Each node runs Tier 1 checks on its own output before emitting to the graph or to other nodes. Cheap. The check itself doesn't need framework context — it needs a regex list and a few semantic patterns. Runs on the same hardware as the model.

### Adaptive — at the membrane

The membrane is the natural lymph-node analog: every inter-node message passes through it. The membrane runs Tier 2 checks on traffic it mediates. Needs framework context — the kernel, the active regime, the role spec of source and destination — but doesn't need to be the largest model. The N150 with OLMo 3 7B-Instruct on CPU at 6–9 tok/s is sufficient for slow-loop adaptive review where the latency budget allows it.

For high-latency-budget operations (interpretive writes, anything that touches the graph as authority rather than tissue), the adaptive check is gated and synchronous. For low-latency operations (tissue-level state updates, scout action loops), it runs asynchronously and surfaces flags rather than blocking.

### Memory — the graph itself

The graph state is immune memory. Every flagged event is written as a typed node — what was caught, where, by which check, how it was resolved. Future surveillance reads this history. Repeated patterns escalate; resolved patterns don't re-trigger.

Stigmergic update: no central immune-registry needed. The next surveillance pass at any node reads flag history from the graph as part of its context. Memory is in the substrate, not in any one cell.

### Manual gate — Robin

The corrigibility spec already places the manual gate on interpretive writes. This architecture leaves the gate in place: it is the lab-confirmation step that catches what the auto-system misses or escalates. Innate plus adaptive surveillance reduces what reaches the gate; it does not replace it.

---

## Tolerance discipline — avoiding autoimmunity

The hardest design question. Naive surveillance attacks legitimate role-differentiation:

- **Scout terseness.** The scout is brief because it's an action agent in latency-bounded loops. Brevity ≠ coldness. Tolerance: terseness checks loose at scout, tight at nucleus.
- **Perceiver descriptiveness.** The perceiver describes discrete mechanics; doesn't interpret. Refusal-to-interpret ≠ evasion. Tolerance: at the perceiver, *presence* of interpretation is the flag, not absence.
- **Reasoner verbosity.** The reasoner discourses. Length ≠ performance. Tolerance: length checks loose at nucleus, tight at scout / membrane.
- **Membrane neutrality.** The membrane mediates without taking positions. Absence of opinion ≠ evasion of question. Tolerance: at the membrane, opinion-presence is the flag, not opinion-absence.
- **Warranted I-don't-know.** The three uncertainty verdicts are first-class outputs. Refusing to answer when the framework places no answer is correct, not failure.

Tolerance has to be role-stratified. Each node carries a surveillance config specifying which patterns are tightly flagged and which tolerated, against the role spec. Autoimmunity = naive global rules.

---

## Response sequence

When a check flags an output:

1. **Localize.** Which node, which output, which check. Written as a typed flag node in the graph.
2. **Signal.** Other nodes reading the graph see the flag. If flagged content was about to propagate, propagation is paused.
3. **Recruit.** If novel (no prior similar flags resolved-as-acceptable), escalate to manual gate. If known and previously resolved-as-violation, suppress emission and regenerate.
4. **Eliminate / regenerate.** Suppressed and re-generated under tightened constraints, or passed through with annotation.
5. **Resolve.** Closed in graph with resolution type (suppressed / regenerated / passed-with-annotation / escalated-to-manual). Tolerance thresholds may be updated.

**Chronic flag states are diagnostic.** If the same node trips the same check repeatedly across sessions, that's a sign that the prompt or role spec needs adjustment, or the base model is bad-fit for the role. Chronic inflammation = systemic problem, not just acute response.

---

## Connection to existing corrigibility spec

The corrigibility spec already places half the immune system:

- **Manual gate on interpretive writes** = lab confirmation step (adaptive response under manual oversight).
- **StepLog with metrics_computed** = antibody record (every surveilled event has a paper trail).
- **Three typed I-don't-know verdicts** = signaling primitives (warranted / blocked / bypassed are immune-signaling vocabulary, not just hedge replacements).

What this draft adds is the *automatic* surveillance that runs before manual review:

- Innate Tier 1 checks at every node.
- Adaptive Tier 2 checks at the membrane.
- Stigmergic memory through graph flag history.
- Role-stratified tolerance config.
- Resolution-typed flag closure.

The manual gate stays where it is. This work reduces what reaches it.

---

## Open / unspecified

- **Code-level placement of innate checks.** Per-node middleware, or a shared library each node imports?
- **Tolerance threshold calibration.** How are role-stratified configs tuned, and updated as the system runs?
- **Adaptive auditor identity.** Does the membrane run adaptive checks on its own outputs (auto-immune blindness risk)? Is there a fifth dedicated auditor model? How does that relate to the existing four-node architecture?
- **Training pair feedback.** Should resolved flag events feed back into Gemini's QLoRA pair-drafting for Molmo perceiver, or into future fine-tuning passes generally?
- **Resolution criteria.** When is a flag "settled" vs needing re-check?
- **Graph schema for flags.** Node type? Edge relations to source-output and resolution-event? Lives in Neo4j (nucleus) or ArcadeDB (tissue)?
- **Cross-session memory.** Does immune memory persist across full session boundaries, or live only within a session graph snapshot?

---

## For audit (Chris)

Particular scrutiny:

- **Tolerance discipline section** — naive surveillance attacks legitimate role-differentiation. The five worked examples cover the obvious cases; verify they exhaust them, or surface what's missing.
- **Innate / adaptive split** — verify the boundary is clean. "Confabulation" particularly: placed adaptive, but lightweight versions might be innate-detectable (e.g., novel proper nouns absent from kernel + graph).
- **Stigmergic memory implementability** — flag history in graph, no central registry. Verify this works without race conditions or stale-read failures in actual graph schemas.
- **Auto-immune blindness at the membrane** — does the membrane running its own adaptive checks on its own outputs create a structural blind spot? If yes, fifth-model question may already be architecturally decided rather than open.
- **Tier 1 false positives** — performative-closing regex will catch some legitimate uses of those phrases (e.g., "let me know if" inside a quoted user message being relayed). Calibration question, or design failure that needs structural fix?
- **Locus of the kernel reference for adaptive checks** — Tier 2 needs the kernel in context. Is the membrane carrying the kernel, or fetching it from the nucleus per check? Latency implication.
