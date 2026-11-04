# FF-4 pre-draft evidence (Sage 10.9 on nucleus, exact; finite checks, not proofs)

2026-11-04. Skeleton (Claude Opus 5.5). Sage session `6f4b63be…`. This redoes the 2026-11-03 checks properly, as the queue note required. The 2026-11-03 numeric checks (rotation numbers and a bulb-depth estimate) are superseded and not relied on.

## 1. Root of the p/q bulb

For every coprime 0 < p < q ≤ 12 (45 pairs), worked exactly in the UniversalCyclotomicField:
- λ = E(q)^p;
- c = λ/2 − λ²/4;
- z₀ = λ/2.

z₀² + c = z₀ holds, and the multiplier 2z₀ = λ: **45/45 for both, with 0 failures.**

## 2. Rotation sets of the doubling map t ↦ 2t mod 1

**Unique cycle.** Every period-q cycle among k/(2^q − 1) was enumerated, for q ≤ 12. For each coprime p/q, **exactly one** cycle is mapped by doubling with rotation p/q: sorting its points, doubling sends index i to i + p mod q. That is 45/45. Its unique shortest gap has length 1/(2^q − 1): 45/45.

The endpoints of that gap are the characteristic angles θ₋ < θ₊. They match the classical values:
- 1/2: (1/3, 2/3);
- 1/3: (1/7, 2/7);
- 2/3: (5/7, 6/7);
- 1/4: (1/15, 2/15);
- 2/5: (9/31, 10/31);
- 3/7: (41/127, 42/127).

**Closed form.** A parameter search over digit rules found it, and two equivalent forms agree for every pair. With digits b_j for j = 1…q, the angle is θ = (Σ b_j 2^{q−j}) / (2^q − 1):
- **θ₊:** b_j = 1 iff (j·p mod q) ≥ q − p;
- **θ₋:** b_j = 1 iff ((j·p − 1) mod q) ≥ q − p.

Two first guesses at the rule failed on all 45 pairs and were discarded.

**Closed form confirmed for every coprime p/q with q ≤ 16 (79 pairs):**
- θ₊ − θ₋ = 1/(2^q − 1): 79/79;
- both angles have exact period q: 158/158;
- the cycle's rotation number is p/q: 158/158;
- θ₊ lies in θ₋'s cycle: 79/79;
- (θ₋, θ₊) is the cycle's unique shortest gap: 79/79.

## 3. Farey order and mediants

- **Wakes ordered like the fractions.** Consecutive p/q < p′/q′ (with q, q′ ≤ 16) satisfy θ₊(p/q) < θ₋(p′/q′), so the wakes are disjoint and ordered as the fractions: 78/78.
- **Mediant wake between the neighbours.** For Farey neighbours a/b < c/d with b + d ≤ 16, the mediant's wake lies strictly between theirs: 50/50.
- **Mediant has the smallest denominator.** The mediant is the unique fraction of smallest denominator strictly between the two neighbours: 50/50. This replaces the 2026-11-03 "mediant deepest" test, which covered only 4 cases.

## Not checked here

- That the **parameter rays** at θ± land at the root of the p/q bulb. This is a classical theorem (Douady–Hubbard; Goldberg; Milnor), cited and not formalized.
- Bulb sizes and depths.
- Anything toward MLC.
