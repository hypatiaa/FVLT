# Ruling Note — The Product Bar: Wide Margin Over the Average LLM

**Date:** 2026-07-02
**Ruling (Robin, verbatim in substance):** *"I don't care about FVLT — it needs to be
better than the average LLM, and by a wide margin."*
**Status:** STAGED — records the terminal success criterion for the Serena system.
Supersedes nothing; re-ranks everything: FVLT specificity is **instrumental**, not
terminal. Research-track outcomes (BUILD-2, annealers, detector work) affect how good
the pieces get; the product claim stands or dies on this bar.
**Gate:** Robin.

---

## Scope ruling first (Robin, 2026-07-02, appended same day)

> *"We aren't trying to beat supercomputer-level frontier intelligence. What we are
> doing is making intelligence usable at small scale. It will also scale to frontier
> so it won't matter — frontier will certainly pick up the optimizations and will
> still be better."*

This bounds the claim: **not a race with the frontier.** The comparison class is what
an SMB can actually deploy within its envelope — cost, ownership, privacy — not
frontier-scale intelligence at unlimited budget. Frontier absorbing these
optimizations and remaining better is the *expected* outcome and consistent with the
open-source endgame; it does not touch the claim. The class boundary is drawn by
**deployment envelope, not model name.**

**Sharpened same day (Robin, third ruling):**

> *"We want to outperform, by a significant margin, other similar-sized LLMs on a
> gaming computer box — so people can own their compute."*

This names the head-to-head precisely: the adjudicating peers are **similar-sized
open-weights LLMs running on the same gaming-class hardware** (Nucleus-class: one
consumer GPU, 16 GB). The mission line is part of the claim: **owned compute** — no
per-token rent, data never leaves the box, the machine is the customer's. API-based
arms remain as commercial context (the "why not just use ChatGPT" answer), but the
margin that decides the product is peer-vs-peer on the same box, where the only
difference that can explain a win is the architecture.

## The claim, made falsifiable

**Terminal claim:** the Serena system (small local model + exact witness gates +
receipts + derived-ontology layer, on Nucleus-class hardware) makes intelligence
**usable at small scale**: it beats the **average LLM as actually available inside
the SMB deployment envelope** — prompt-driven API usage at SMB budgets, no
verification harness — by a **wide, pre-registered margin** on the small/medium-
business intelligence and ontology workload, and clears **absolute usability
thresholds** (near-zero surviving errors, honest refusal, receipts) that make the
system dependable rather than merely better.

Per standing discipline (adjudication must match the claim), "wide margin" is not
allowed to stay vibes. Before any product claim is made, a benchmark is pre-registered
with per-dimension margins. The dimensions below are where the margin is *claimed*;
the exclusions are where it is *not* — both are part of the claim.

## Where the wide margin is claimed (measurable, categorical in kind)

1. **Error survival to artifact.** On witnessable outputs — tables, ledgers, schemas,
   calculations, structured records, citations-of-record — the gated system's rate of
   errors *surviving into the delivered artifact* vs the baseline LLM's. The gate is
   deterministic and fail-closed; this is the dimension where the difference is
   architectural, not statistical. Target register: approaching zero-survival vs a
   persistent nonzero baseline. This is the headline margin.
2. **Refusal honesty.** On unanswerable, corrupted, or out-of-scope inputs:
   UNREPAIRABLE / flag-for-human vs the baseline's confident wrongness. Measured as
   calibration on a deliberately unrepairable battery (the ANNEALER-1 refusal
   curriculum, product-shaped).
3. **Cost per verified artifact.** Local small model + free exact verifier vs API
   tokens + human double-checking. Wall-clock, joules, and dollars, on equal task
   batteries — the systems-claim falsifier (ANNEALER-1, pre-registered 6/09)
   generalized to the product.
4. **Ontology stability.** Derived-and-audited coordinates (fit ledger, permutation
   controls, trust tiers — book-crystal grammar) vs LLM freeform taxonomy: measured as
   reproducibility across re-runs and drift under document additions.
5. **Auditability.** Receipts end-to-end vs none. Demonstrable rather than scored;
   enters the benchmark as a binary the baseline cannot satisfy.

## Where the margin is NOT claimed (register discipline)

Open-ended prose fluency, general-knowledge breadth, and conversational range: a
small local model does not beat a frontier model there and the product must never
imply it does. The honest sentence is the differentiator: *exact where exact gates
exist; flagged where they don't; silent about nothing.* The SMB workload core — the
repeatable, structured, checkable substrate — is where the system lives.

## Kill condition (the bar cuts both ways)

If, on the pre-registered benchmark, the gated system does not clear the wide margins
on dimensions 1–4 against the average-LLM baseline, **the product claim dies** —
independent of any research-track result, and regardless of how elegant the
architecture is. A system that is merely *as good with extra steps* is a failure of
this bar.

## Relation to the research tracks (the re-ranking)

- BUILD-2 and all FVLT-specificity questions decide **proposer and instrument
  quality** — they can raise the margins, they cannot substitute for them. Consistent
  with Robin's predeclared BUILD-2 prior (prediction note, 7/2): the bar does not
  care which register wins inside the model.
- The annealer family, if Phase A ever earns it, attacks dimension 3 directly.
- The witness architecture (SERENA-BOOT-1) already carries dimensions 1, 2, and 5 at
  boot — the bar is largely an architecture claim, which is why it is winnable.
- The roadmap (installation↔kernel parity, 7/2) is the path to the system this bar
  measures; Phase 2's boot is the first moment the benchmark *can* run.

## Three-stack attribution

```
Robin Miller     the bar itself and its width; the re-ranking of FVLT to instrumental;
                 all gates
Chris/ChatGPT    invited: cold-pass the benchmark spec when drafted — especially the
                 margin numbers and the average-LLM baseline definition, which must
                 be fair to the baseline or the win is worthless
Claude (Fable 5) operationalization into five margin dimensions + exclusions + kill
                 condition; this note
```

*Staged only. The bar is recorded; the benchmark that enforces it is the next
artifact, pre-registered before any product claim ships.*
