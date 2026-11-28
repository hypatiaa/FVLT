import WilsonMechanism

/-! These signatures and the vertex definition come from the original target. -/

namespace WilsonMechanismStatementPins
open Complex

/-- Vertex `k` of the regular `n`-gon, as a phasor. -/
noncomputable def vertex (n k : ℕ) : ℂ := exp (2 * Real.pi * I * k / n)

/-- (A1) Mirror pairs multiply to one: vertex `k` and vertex `n - k` are conjugate. -/
theorem mirror_pair (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) :
    vertex n k * vertex n (n - k) = 1 :=
  WilsonMechanism.mirror_pair n k hn hk

/-- (A2) The self-paired vertices are exactly the real ones: `k = 0` and, for even `n`,
`2k = n`. -/
theorem self_paired_iff (n k : ℕ) (hn : 0 < n) (hk : k < n) :
    vertex n k * vertex n k = 1 ↔ k = 0 ∨ 2 * k = n :=
  WilsonMechanism.self_paired_iff n k hn hk

/-- (A3) Phasor Wilson: the product of all vertices of an even polygon is `-1`. -/
theorem prod_vertices_even (n : ℕ) (hn : 0 < n) (he : Even n) :
    ∏ k ∈ Finset.range n, vertex n k = -1 :=
  WilsonMechanism.prod_vertices_even n hn he

/-- (B1) For a prime `p`, the units of `ZMod p` form a `(p-1)`-gon: one generator lists
them all. -/
theorem units_are_polygon (p : ℕ) [Fact p.Prime] :
    ∃ g : (ZMod p)ˣ, orderOf g = p - 1 :=
  WilsonMechanism.units_are_polygon p

/-- (B2) On that polygon the multiplicative inverse is the mirror `k ↦ (p-1) - k`. -/
theorem inverse_is_mirror (p : ℕ) [Fact p.Prime] (g : (ZMod p)ˣ) (hg : orderOf g = p - 1)
    (k : ℕ) (hk : k ≤ p - 1) :
    (g ^ k)⁻¹ = g ^ (p - 1 - k) :=
  WilsonMechanism.inverse_is_mirror p g hg k hk

/-- (B3) The two self-paired units are `1` and `-1`. -/
theorem self_inverse_units (p : ℕ) [Fact p.Prime] (u : (ZMod p)ˣ) :
    u * u = 1 ↔ u = 1 ∨ u = -1 :=
  WilsonMechanism.self_inverse_units p u

/-- (C) Wilson, derived from the polygon (no Mathlib Wilson lemma in the closure). -/
theorem wilson_from_polygon (p : ℕ) (hp : p.Prime) :
    ((p - 1).factorial : ZMod p) = -1 :=
  WilsonMechanism.wilson_from_polygon p hp

/-- (D) The oracle gate of WilsonOracle.lean, re-derived through the polygon:
on the shell `n! + 1`, the candidate `n + 1` divides it exactly when it is prime. -/
theorem active_gate_iff_prime_via_polygon {n : ℕ} (hn : 1 ≤ n) :
    (n + 1) ∣ n.factorial + 1 ↔ (n + 1).Prime :=
  WilsonMechanism.active_gate_iff_prime_via_polygon hn

end WilsonMechanismStatementPins

#print axioms WilsonMechanism.mirror_pair
#print axioms WilsonMechanism.self_paired_iff
#print axioms WilsonMechanism.prod_vertices_even
#print axioms WilsonMechanism.units_are_polygon
#print axioms WilsonMechanism.inverse_is_mirror
#print axioms WilsonMechanism.self_inverse_units
#print axioms WilsonMechanism.wilson_from_polygon
#print axioms WilsonMechanism.active_gate_iff_prime_via_polygon
