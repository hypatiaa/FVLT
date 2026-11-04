# Work order: the Vernier-phasor-to-Ford-arc map (FF-3), v0.1

2026-11-03. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request ("It's worth an order"). **Status: draft for design review by the formalization owner.** Nothing is preregistered, built or dispatched until the owner accepts this exact order and saphir gives a separate execution go.

## 1. Purpose

The kernel marks this bridge as missing. Kernel v3.3.1, Part II / II.5, §9.4 Ford-circles row: "A map sending Vernier phasor paths to Ford-circle arcs has not been defined; this is an interpretive comparison only." This order **defines** that map exactly, states its laws, and puts them into Lean on top of FF-1 (Ford tangency, kiss points) and the computable bridge (exact rational kiss points). If the laws are proved, the kernel line can be corrected through an Idea Catalog candidate (Lean over prose, saphir 2026-10-30), never by editing the kernel.

## 2. Governing inputs

| Input | Pin |
|---|---|
| FVLT kernel v3.3.1 (II.5a rosette and contact identity, II.5b Farey/Ford law, II.5f Ford chains, §9.4 row) | `.agent/skills/fvlt/kernel_v3_3_1.md`, SHA-256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| FF-1 F1 PASS (Ford distance identity, kiss membership) | `farey_ford_contact_v0_1_20261102/F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md`, `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526` |
| Computable bridge signature freeze (exact `kissQ`, `boundaryCheckQ`) | `farey_ford_contact_v0_1_20261102/BRIDGE_SIGNATURE_FREEZE_DRAFT_v0_1.md`, `4c9c80e59664bf91f2b558611bd764e8e5f58c8286b4db7cebdc00e4e61f4f8d` |
| Lemma 6a (Farey input from the phase law), **candidate, unaudited** | `candidates/ANL4_S2_FAREY_INPUT_LEMMA_v0_1_CLAUDE_OPUS_20260925.md`, `220a481905da2767379318d4960d08713ca821f1c6fcee944d6eed598f10bb3b` |
| Library, toolchain, Mathlib, checker | as frozen for FF-1, re-observed at this order's own input freeze |

## 3. Definitions

Rosette notation as in II.5a: integer spin s ≥ 0, n₃ ≥ 1, gearbox t₁, t₂ with t₁ an integer, phasor z₁ = r·e^{iθ₁}, θ₁ = π·k₁s/n₃, k₁ = n₃t₁ − t₂.

- **Ford address.** x(s, n₃) := t₂s/n₃ ∈ ℚ, kept as a rational (not reduced mod anything). Then θ₁ = π(t₁s − x), so e^{iθ₁} = (−1)^{t₁s}·e^{−iπx} is determined by x and the parity of t₁s, and the phasor lies on the real axis iff x ∈ ℤ (II.5a contact identity). Reference case t₁ = t₂ = 1: x = s/n₃.
- **The map.** Φ(s, n₃) := the Ford circle C(x(s, n₃)), centre x + i/(2q²), radius 1/(2q²), where q is the reduced denominator of x (F1's `centre`, `radius`).
- **Paths.** A path is a finite sequence of rosette points, giving addresses x₀, x₁, …, x_m. Three named paths:
  - **column** at fixed s: n₃ = n, n + 1, …;
  - **row** at fixed n₃ = N: s = 0, 1, …, N;
  - **shell sweep**: the ordered contact addresses over shells N = 2, …, B + 1 in the Lemma 6a setting.
- **Ford arc.** If C(x_{k−1}), C(x_k) and C(x_{k+1}) are pairwise consecutive-tangent, the arc of step k is the arc of C(x_k) from kiss(x_{k−1}, x_k) to kiss(x_k, x_{k+1}) (FF-1 `kiss`, exact via `kissQ`). The path's Ford arc is the concatenation.
- **Events, drawn and labelled (never hidden):** a **break** where consecutive circles are not tangent, labelled with |det| ≥ 2; a **stall** where x_k = x_{k+1}; a **contact** where x_k ∈ ℤ, i.e. the circle has radius 1/2.

## 4. Part A: statements to prove

Write g(a, q) = gcd(a, q). All binders explicit; positivity and integrality hypotheses explicit.

| # | Statement |
|---|---|
| P1 | **Contact.** For integers t₂, s and n₃ ≥ 1: den(x) = 1 ⇔ n₃ ∣ t₂s. In the reference case the contact circles in column s are exactly those with n₃ ∈ Div(s) (II.5a, read through Φ). |
| P2 | **Reduced determinant.** For integers a, c and positive q, r: |det(a/q, c/r)| = |ar − cq| / (g(a,q)·g(c,r)), with the reduced fractions on the left. |
| P3 | **Row law.** At fixed N ≥ 1 and 0 ≤ s < N: |det(s/N, (s+1)/N)| = N / (g(s,N)·g(s+1,N)). So the step is tangent iff N = g(s,N)·g(s+1,N). |
| P4 | **Column law.** At fixed s ≥ 1 and n ≥ 1, with u = t₂s: |det(u/n, u/(n+1))| = u / (g(u,n)·g(u,n+1)). So the step is tangent iff u = g(u,n)·g(u,n+1); for t₂ = 1 this holds iff s ∣ n(n+1). The case s = 1 is the unit-fraction spine of II.5b and II.5f: every step is tangent. |
| P5 | **Shell sweep is unbroken.** In the Lemma 6a setting, the ordered contact addresses over shells 2, …, B+1 equal the Farey sequence F_B, and consecutive terms have determinant 1 (Haros–Cauchy). So the shell-sweep Ford arc has no breaks. Lemma 6a is an unaudited candidate: P5 **proves** what it needs, and assumes nothing from it. |
| P6 | **Arcs are exact.** For each tangent step, both arc endpoints are the exact rational kiss points (`kissQ`), and each lies on the boundary of its circle (`adjacent_kissQ`). |

**Event counts (finite, evidence only).** Per column s ≤ S and n ≤ M: the number of breaks and the multiset of break determinants. These are reported as finite readouts, never as theorems.

## 5. Pre-review evidence (producer evidence, skeleton, Sage 10.9 on nucleus)

All **True** on the ranges given (finite; not proofs):
- P3 for all 1 ≤ N < 200 and 0 ≤ s < N: the exact |det| formula and the tangency criterion.
- P4 for 1 ≤ s, n < 200 (t₂ = 1), including "tangent iff s ∣ n(n+1)"; general t₂ ≤ 7 with s, n < 60 for the |det| formula; s = 1 tangent for every n < 500.
- P5 at B = 30: the ordered addresses equal F₃₀ (279 fractions) and all consecutive determinants are 1.
- P1 for integer t₂ ∈ [−4, 4], 0 ≤ s < 40, 1 ≤ n₃ < 40; P2 for |a|, |c| ≤ 15 and 1 ≤ q, r < 16.
- The phase identity e^{iπk₁s/n₃} = (−1)^{t₁s}·e^{−iπt₂s/n₃}, exactly in the cyclotomic field ℚ(ζ_{2n₃}), for t₁ ∈ [−2, 2], t₂ ≤ 3, s < 8, n₃ < 8: 0 mismatches. (A first symbolic attempt with `exp(…).simplify()` returned False because the simplifier did not close; the exact cyclotomic comparison is the recorded check.)
- Example: column s = 6 is tangent exactly at n ∈ {2, 3, 5, 6, 8, 9, 11, 12, …} (n(n+1) is always even, so 6 ∣ n(n+1) iff n ≢ 1 mod 3).

## 6. Not claimed

- No map from **continuous** phasor motion to arcs: paths are sequences of rosette points, and the arc between tangent circles is a choice of drawing, not a dynamical claim.
- No factoring or computational advantage (II.5a scope and the S2 closed-negative record stand).
- No statement about non-reference gearboxes beyond P1, P4 and the explicit t₂ formula.
- No viewer work: drawing Ford arcs on the rosette belongs to the viewer track and needs saphir's direct go there.
- No kernel edit: a proved P1–P6 supports an Idea Catalog correction candidate for the §9.4 row, after review.

## 7. Prior art

- Ford (1938); Haros–Cauchy (consecutive Farey terms have determinant 1); paths in the Farey graph and continued fractions (classical, recalled).
- In this project: II.5b (Opus/Chris, v3.1.23) and II.5f are the s = 1 column; Lemma 6a (Opus, 2026-09-25, unaudited) is the shell sweep; FF-1 and the bridge give the circles and exact kiss points.
- Kit check 2026-11-03: `Rule30PrizeKit/` has no Ford, Haros or Farey material (three hits for "Oxford"/"Stanford" only), and `sources/submissions.json` has none. No novelty claim.

## 8. Gates, rules, sequencing

As FF-1 `WORK_ORDER_v0_3.md` (`43560b88…`): input and signature freezes before proofs, a job template, the §6–7 gates, §9 rules and §10 outputs; verify by script and in Sage. **Sequencing:** after FF-1 Stage A and the computable bridge (P6 depends on it). Its place relative to FF-2 is set at dispatch by saphir. No compute on Neo; G1 excluded; no commits; library sync only as separately authorized.

**Credit.** The question of the map, the rosette, and the instruments: saphir. Lemma 6a and this draft: skeleton (Claude Opus 5.5). "The framework was assembled by Robin Miller; its components are classical results of others."
