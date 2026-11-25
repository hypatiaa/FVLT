# Schema addendum 5: v0.1.1, S³ orbit branches, cyclotomic field, lift branch data

Date: 2026-10-13. Owner: Opus (B1-viewer owner session). This extends SCHEMA.md and addenda 1–4.

**Authority.** saphir, 2026-10-13. saphir was asked whether to go ahead with v0.1.1 (orbit-branch card, cyclotomic-field readout, branch data in Lift JSON) and answered: "yes, in fact I want to keep the base functionality of the entire instrument, but simplify it".

**Reference.** The old viewer's export at m = 7, N = 4, s = 4/7, t₁ = t₂ = 1 (`fvlt_fourier_m7_fact-4-24_s0.5714285714285714_1791886895936.json`, saphir's Downloads). It contains `orbitBranches`, `exactRationalLift.branches`, `currentState.teeth[].cliffordOrbit` and `cyclotomic_field_detail`. The host code is the frozen host `buildCliffordActualPoints` L9249 and the orbit/knot group HC-8 in `HOST_LIBRARY_MAP.md`. Read it only by line range.

## 1. Orbit branches (exact; `host-core/orbit-core.js`, BigInt)

For each tooth c, with exact t₁, t₂ and N > 0, the s-orbit on the Clifford leaf has a carrier rate t₁ and an offset rate c·t₂/N, per unit s in units of π.

1. **Raw rate pair:** (N·t₁, −c·t₂). Clear denominators by L = lcm(denominators) and record `denominator_scale` = L. The cleared rate is (L·N·t₁, −L·c·t₂), as integers.
2. **Common factor and primitive winding:** g = gcd(|a|, |b|), where (a, b) is the cleared rate. The primitive winding is (a/g, b/g). If b = 0, then g = |a| and the primitive winding is (±1, 0). The branch multiplicity is d_c = g.
3. **Closure period in s:** the least s > 0 at which both phases return mod 2. That is 2N/g when L = 1; in general, compute it exactly from the rates. Check it against the export: c = −3 → 8, c = −2 → 4, c = 0 → 2.
4. **Knot class** of the primitive winding (p, q):
   - UNKNOT if |p| ≤ 1 or |q| ≤ 1;
   - otherwise NONTRIVIAL_TORUS_KNOT, with canonical type T(min(|p|,|q|), max(|p|,|q|)) and chirality the sign of p·q. That gives "+" or "−", written into the type as in the export: "T(3,4)+".
   - The presentation χ is the sign of p·q, or "0" when q = 0.
5. **Undefined cases:** a zero rate for both phases, N ≤ 0, or t₁ = 0 with c·t₂ = 0. Label the branch "stationary" or "undefined"; never omit it.

**Test.** At the reference state, reproduce every field of `orbitBranches` and `exactRationalLift.branches` in the export exactly: raw winding, divisor, primitive winding, closure period, k_c, knot class, canonical type and χ. Also add property tests on random states: the period is the least such s, checked by brute force over multiples of 1/(L·N); a primitive winding has gcd 1.

## 2. Cyclotomic field readout (exact)

At the current exact spin, the phase of tooth c is e^{iπ·φ_c}, with φ_c = k_c·s/N mod 2.

- **Generated field:** ℚ(ζ_n), where n = lcm over nonzero-amplitude teeth of the order of e^{iπφ_c}. At the reference state that is ℚ(ζ₁₄).
- **Ambient field:** the field containing the carrier and offset phases separately, that is, the lcm of the orders of the carrier phases and the offset phases. The reference gives ℚ(ζ₅₆). Derive this from the definitions and test it against the reference. If your derivation disagrees with the export, report it; do not force agreement.
- **Shell reference:** ℚ(ζ_B) for the factorial shell, ℚ(ζ₂₄) here.
- **ρ = 0:** "zero amplitude — no generated field".
- Show it in the Phasors card as one line: `field ℚ(ζ₁₄) · ambient ℚ(ζ₅₆) (exact)`.

## 3. Card and drawing (Clifford tab)

**"S³ orbit branches" card**, in the Clifford tab's controls area, with one chip per branch. Each chip reads `c·raw (a,b)·primitive (p,q) ×d·TYPE`, in the branch's tooth colour. Buttons:
- **All:** show every branch.
- **None:** hide every branch.
- **Tap a chip:** toggle that branch.
- **Long-press (or shift-click):** isolate that branch.

**Drawing.** Hidden branches hide both their s-orbit and their tooth dot on the Clifford tab. Branch visibility is drawing register: it goes in the URL address, not in the exact export.

**s-orbit colour.** Each orbit is drawn in its tooth colour, so chip and curve match. Orbits are drawn for exactly one closure period, as in fix round 4.

## 4. Lift JSON

Add `branches[]` with the fields of §1 as exact strings, under schema id `fv-comb-hopf-lift/0.2`.

## 5. Out of scope here

The wider "keep base functionality, simplify" programme is being inventoried separately, in `FUNCTIONALITY_LEDGER.md`, pending.
