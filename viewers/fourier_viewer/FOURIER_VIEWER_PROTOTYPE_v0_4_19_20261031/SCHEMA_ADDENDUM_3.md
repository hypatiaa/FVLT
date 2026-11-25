# Schema addendum 3: fraction stack in v0.1 (Clifford tab)

Date: 2026-10-13. Owner: Opus (B1-viewer owner session).

**Authority.** saphir, 2026-10-13: "yes, add the fraction stack to v0.1". This moves the fraction stack out of addendum 2's deferred list. The other stacks stay deferred.

**Source.** Host v0.8.7 / v0.8.7-fix.1. See the changelog at L752–800 and the code at L9112–9200 (`fractionSpinSpreadZero`, `fractionStackLattice`, `fractionStackGateReason`, `buildFractionStackPointsCached`) and L11830 (caption). Read only these ranges.

## Meaning

The full stack plots integer spins only. The fraction stack plots the **current shell's** row on a fraction lattice:
- every spin s = j/q with j = 0 … q·(B+1);
- every tooth c of the comb.

Each (s, c) pair is lifted to S³ by the same lift as the live teeth (addendum 1 §B) and drawn on the Clifford tab. These are generated points, not display copies. They fan across the 2q azimuth pages u = jπ/q, so the Farey align→spread morph is drawn as a population.

## Lattice (exact, in `host-core/fraction-stack-core.js`)

- **Non-integer spin.** Let s_typed = p/q in lowest terms, with q > 1. The lattice is (1/q)ℤ. Its source is "slider lattice".
- **Integer spin.** Fall back to the shell's SPREAD lattice. Its source is "shell spread lattice (integer spin)".
  - Odd m: q = m|t₂| / gcd(2N, m|t₂|).
  - Even m: q = m|t₂| / gcd(N, m|t₂|).
- **Gate reasons.** The stack is idle when any gate fails. The caption then reads "fraction stack idle — <reason>".
  - "no current shell": N ≤ 0.
  - "integer gearbox required for the certified fraction-stack register": the integer gearbox is inactive (non-integer t₁ or t₂, or a zero gear).
  - "this shell's spread stops are integers — the full stack already carries them": the fallback q is 1.
  - "lattice ζ_q beyond draw cap 60": q > 60.
- **Which spin.** Use s_typed. The exact spin drives every exact readout (R21.1).

## Spread-zero columns (exact)

A column j/q is spread-zero when the full m-comb sum vanishes exactly at s = j/q. That is the exact SPREAD flag of addendum 1 §A, evaluated at that s:
- odd m: m·x/2 ∈ ℤ and x/2 ∉ ℤ;
- even m: m·x ∈ ℤ and x ∉ ℤ;

where x = t₂·s/N.

The host's `fractionSpinSpreadZero` (L9132) is the same test. Test that the two agree.

**Fixture (host Playwright route).**
- Setup: B = 4! = 24 (span B + 1 = 25), N = 9, m = 5, t₁ = t₂ = 1, s = 72/5, so q = 5 and j runs over 0…125.
- Azimuth pages: exactly the 10 pages jπ/5.
- Spread-zero columns: exactly 18/5, 36/5, 54/5, 72/5 and 108/5. These are the s = 18k/5 ≤ 25 with 5 ∤ k; 126/5 > 25 is outside the span.
- 90/5 = 18 is the alignment pole, not a zero.
- Raw heads: (5·25 + 1)·5 = 630. The host drew 630/630.

## Drawing (Clifford tab; drawing register only)

**Toggle:**
- The button reads "○ Fraction stack" when off and "⅟ Fraction stack" when on. It is off by default and sits in the Clifford toggle row.

**Budget:**
- At most 4,000 points (`FRACTION_STACK_MAX_HEADS`).
- The raw count is (q·(B+1) + 1)·m. Select indices evenly: index_i = floor(i·raw/4000) for i = 0 … 3999, in the order j outer, c inner.
- Never materialise all the raw specs. At 13! the raw count is huge.

**Colours:**
- Ordinary points are amber `--accent-spine`, at alpha about 0.55 and radius 1.6.
- Spread-zero points are bright white-cyan `#e0faff`, at radius 2.2.

**Caption** (Clifford overlay):
- `fraction stack s ∈ (1/q)·ℤ · <source> · current shell · <drawn>/<raw> heads · spread-zero columns bright`.

**Excluded** from the live teeth, the s-orbits, the Hopf tab, the trail and every export, as in the host. It is display only, and the caption says so.

**Cost:** the points are cached on the key (shellMode, B, φ₃, N, q, source, α, n₆, t₁, t₂, m).

## Tests

- The lattice q for:
  - s = 136/25, which gives q = 25;
  - integer s with the fallback, for odd and even m;
  - N = 10, m = 5, which is idle with the integer-stops reason;
  - q = 61, which is idle at the cap.
- The gate reasons.
- The fixture above.
- Exact spread-zero against numerical |K_m| < 1e-9 for every column of 200 random lattices.
- The selection count is min(raw, 4000).
