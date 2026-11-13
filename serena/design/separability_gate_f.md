# Serena Persistent-State Separability Gate

**Subject:** A design-principle gate determining when a normalized persistent-state channel may count as live persistent memory rather than a static register profile / calibration prior.
**Type:** Design-principle artifact — for Robin + Chris audit.
**Status:** DESIGN PRINCIPLE CLEARED — Chris audit PASS (May 18, 2026; required order-sensitivity amendment applied) + Robin sign-off (May 18, 2026).
**Date:** May 18, 2026. Drafted by Claude.
**Relation:** Motivated by the FE-collapse finding in `c2_reference_a.py` (C2-reference-A). Separate from C3e-II; **not** part of the C3e-II run, build chain, or audit trail. C2-reference-A supplies the motivating example; this artifact states the general rule.
**Sources:** `kernel_v3_1_full_fold.md` — Def 5.1a (persistent state $\pi_t$, EMA update, $\pi_t$ as a probability distribution over channels), Def 5.1i / Rmk 5.1o ($\delta$ perturbation depth), Rmk 5.1k ($\pi_t$ in the same channel coordinates as $e(x_t)$; the limited proprioceptive analogue), Rmk 5.7a (χ-type $E_q$ closed form). Motivating artifact: C2-reference-A and its FE-collapse finding; C3e V2 readout $\widetilde E_q$.

---

## §1 — Purpose

The persistent state $\pi_t$ (Def 5.1a) is an EMA over a stream of observation vectors. Whether $\pi_t$ functions as *memory* — something that integrates a sequence of changing evidence — or merely as a *static register profile* depends entirely on the stream feeding it. This artifact formalizes the structural condition that separates the two, and the gate Serena applies before installing any channel as persistent memory.

The principle in one sentence:

> **Persistence is not created by the EMA; persistence is permitted by rank > 1 observation structure. A normalized persistent state records shape, not scale.**

---

## §2 — Motivation: the C2-reference-A FE-collapse

C2-reference-A computes the C3e-II $\pi_t$ driver under two ambient conventions. Under the **formula-extended (FE)** convention every χ-type sample's per-channel energy is the Rmk 5.7a closed form

$$E_q(\chi_d) = \frac{\mu(q)^2\,\varphi(d)^2}{d^2\,\varphi(q)} = \underbrace{\frac{\varphi(d)^2}{d^2}}_{a(x_t)} \cdot \underbrace{\frac{\mu(q)^2}{\varphi(q)}}_{b(q)}.$$

The expression **factors**: a sample-part $a(x_t)$ depending only on $d_t$ (in fact only on $\mathrm{rad}(d_t)$ — radical invariance, Rmk 5.7a) times a channel-part $b(q)$ that is the same for every sample. Normalization to a probability vector divides out the scalar $a(x_t)$, so **every normalized observation is the identical vector**. The EMA has nothing to integrate: $\pi_t$ is static and $\delta_t = 0$ across the whole stream — exactly what the C2-reference-A run shows for all eight witnesses under FE.

Two consequences fix the framing:

- The static vector $\pi_t$ collapses to is not arbitrary — $b(q) = \mu(q)^2/\varphi(q)$ is precisely $\widetilde E_q$, the normalized channel profile from C3e's V2. **FE $\pi_t$ reproduces an existing C3e V2 readout; it is not a new persistent-state quantity.**
- Nothing about χ-type signals or FVLT does the work. The collapse is linear algebra on the observation stream: a separable observation matrix, once row-normalized, has no temporal content.

---

## §3 — The general rule

Let $E[t, q] \ge 0$ be the **observation matrix**: rows indexed by time / event $t$, columns by channel $q$; row $t$ is the per-event observation vector $e(x_t)$ before normalization. Assume every row is normalizable (nonzero); a zero observation row carries no shape, cannot be normalized, and is a separate degenerate case (no evidence) handled outside this gate.

**Separable stream.** $E$ is *separable* when $\mathrm{rank}(E) = 1$. For a nonnegative matrix with normalizable rows this is equivalent to: $E = a\,b^{\mathsf T}$ for nonnegative vectors $a, b$; equivalently, **every normalized row is the identical vector** $b / \lVert b \rVert_1$.

- **Separable ($\mathrm{rank}(E) = 1$, or normalized rows identical).** The normalized stream is constant, so the EMA output is constant. The channel is a **register profile / calibration prior**, not persistent memory. Stream order, event sequence, and update rate $\eta$ are all irrelevant: any permutation of the stream yields the same $\pi_t$.
- **Non-separable ($\mathrm{rank}(E) > 1$, or normalized-row variation above threshold).** The normalized observation stream genuinely varies, so $\pi_t$ moves. For ordinary non-degenerate streams and $0 < \eta < 1$, the EMA's geometric weighting can make the endpoint order-sensitive: permuting the stream can change which observation carries the heavy late weight. Thus $\pi_t$ is structurally capable of recording sequence structure. This is a **live persistent-state candidate**.

```
Serena Persistent-State Separability Gate — core rule

A normalized persistent state is a SHAPE-memory channel, not a
MAGNITUDE-memory channel.

Given a nonnegative observation matrix E[t, q] with normalizable rows:

  rank(E) = 1   (normalized rows identical)
      -> separable stream
      -> register profile / calibration prior
      -> NOT persistent memory

  rank(E) > 1   (normalized rows vary above threshold)
      -> non-separable stream
      -> live persistent-state candidate
      -> EMA can integrate sequence structure

Scale information discarded by normalization must be stored
separately if it is architecturally meaningful (see sec.5).
```

"Candidate" is exact: rank > 1 **permits** persistence, it does not **guarantee** that the channel carries meaningful memory. The gate is a necessary structural check, not a sufficient one.

---

## §4 — Diagnostic hierarchy

The two diagnostics answer different questions and must not be substituted for one another.

**Primary — the separability gate.** Computed directly on the normalized observation stream: the **rank of the stacked normalized observation matrix**, or the **maximum pairwise $L^1$ distance among normalized rows**. This is a single computation on $E$, independent of the EMA, its rate $\eta$, and its initialization. Exact rank 1 (zero pairwise variation) is the unambiguous separable case; a threshold on the pairwise distance handles the near-separable regime and is context-set (§7).

**Secondary — the liveness / readiness readout.** $\delta(e_t, \pi_t)$ (Def 5.1i) — the state-observation lag, the perturbation depth. This measures whether the *state has caught up to the current observation*, which is a different question from whether the observations vary at all.

**Warning — $\delta$ near zero is ambiguous.** $\delta_t$ goes small for two distinct reasons: genuine separability (the stream never varied), or ordinary **convergence** (the EMA has settled onto a varying-but-stationary stream). A real memory stream that changes shape early and settles late shows $\delta_t \to 0$ at the tail despite having done genuine integration. $\delta$ *identically zero across the entire stream* does certify collapse — given the $\pi_0 = e(x_0)$ initialization, $\delta \equiv 0$ forces every observation equal — but that is a derived test on a trajectory. The primary gate is preferred because it reads the observations directly, does not conflate collapse with convergence, and does not depend on the EMA's initialization. Use $\delta$ for liveness, not for separability.

---

## §5 — Normalization corollary

Def 5.1a treats $\pi_t$ as a probability distribution over channels, so normalization is mandatory — and normalization is precisely the operation that discards total scale. The architecture has therefore already chosen, structurally, that **persistent state records shape and not magnitude**.

The corollary for Serena: if intensity or strength of evidence carries architectural meaning, that information **cannot** live in the normalized persistent channel — normalization will remove it regardless of stream design. It must be stored in a separate register: an un-normalized magnitude track, or a total-energy scalar carried alongside the shape distribution. Do not expect a normalized persistent state to preserve scale, and do not route a scale-only signal into one expecting it to be remembered.

---

## §6 — Serena mapping

The gate maps onto the Nucleus / Membrane / Scout architecture as a routing rule.

**Scout.** May report an intensity increase within an unchanged channel shape — "same evidence, more of it." This is a scale-only, separable signal. It updates the magnitude / calibration track, **not** Nucleus memory.

**Membrane.** Applies the separability gate (§4 primary diagnostic) to candidate observation streams. Streams that fail the gate — normalized shape constant within threshold — are routed to the calibration / magnitude track. Streams that pass are forwarded as live persistent-state candidates.

**Nucleus.** Updates persistent memory **only** on a redistribution of evidence *shape*: which channels are active, which relations cohere, which bridge patterns appear, which residuals persist, how coherence structure changes. A stronger signal at an unchanged shape is not grounds for a Nucleus update.

---

## §7 — Status and scope

**What is exact.** The separability fact — a rank-1 nonnegative observation matrix, once row-normalized, collapses to a constant stream, so its EMA is static — is exact linear algebra. It holds for any normalized observation stream; FVLT and the χ-type closed form are only the example that surfaced it.

**What is a design principle.** The *gate* — the architectural policy that refuses the "persistent memory" label below a variation threshold and routes the channel as a register profile instead — is a design principle, with a context-set threshold. It is **not** a theorem about all possible forms of memory. It states a necessary structural condition for *normalized EMA* persistent state specifically; other memory mechanisms (un-normalized, non-EMA, or coupling-based) are out of its scope.

**Refusal of overclaim.** Passing the gate (rank > 1) means a channel *can* carry persistent memory, not that it *does* carry useful memory. The gate is one structural check; it does not certify that the integrated sequence is meaningful, only that there is a sequence to integrate.

---

## §8 — State

```
status:   DESIGN PRINCIPLE CLEARED. Chris audit PASS (May 18, 2026) --
          required order-sensitivity amendment applied (sec.3, softened
          from unconditional to "structurally capable" for ordinary
          non-degenerate streams, 0 < eta < 1). Robin sign-off May 18,
          2026. Separability fact (rank-1 -> normalized collapse) is
          exact linear algebra; the gate is a design principle with a
          context-set threshold, not a theorem about all memory.
relation: motivated by C2-reference-A FE-collapse; NOT part of the
          C3e-II run, build chain, or audit trail. Standalone Serena-
          side artifact.
three-    Robin (architect; specified the artifact, the core "permitted
  stack:  not created" principle, the Scout/Membrane/Nucleus mapping;
          sign-off May 18, 2026), Claude (draft; the primary-vs-
          secondary diagnostic split and the delta convergence-vs-
          collapse caveat; applied the Chris amendment), Chris (audit
          PASS with one required precision amendment, May 18, 2026).
next:     optional Serena integration note (not yet commissioned).
          C3e-II gated items (chamber-side C2, C1) remain parked under
          their own gates.
```

*— end Serena Persistent-State Separability Gate (cleared), May 18, 2026 —*
