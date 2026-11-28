import Mathlib.RingTheory.RootsOfUnity.Complex
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.FieldTheory.Finite.Basic
import Mathlib.Data.Nat.Factorial.Basic
import Mathlib.Data.Nat.Factorial.BigOperators
import Mathlib.Tactic.NormNum

/-! Wilson's theorem via reflection of the roots of unity and a generator of the residue units. -/

namespace WilsonMechanism
open Complex

/-- Vertex `k` of the regular `n`-gon, as a phasor. -/
noncomputable def vertex (n k : ℕ) : ℂ := exp (2 * Real.pi * I * k / n)

theorem vertex_eq_pow (n k : ℕ) :
    vertex n k = exp (2 * Real.pi * I / n) ^ k := by
  rw [vertex, ← Complex.exp_nat_mul]
  congr 1
  ring

/-- Mirror partners multiply to the identity. -/
theorem mirror_pair (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) :
    vertex n k * vertex n (n - k) = 1 := by
  rw [vertex_eq_pow, vertex_eq_pow, ← pow_add, Nat.add_sub_of_le hk]
  exact (Complex.isPrimitiveRoot_exp n hn.ne').pow_eq_one

/-- Reflection of the index acts by complex conjugation on the unit circle. -/
theorem conjugate_vertex (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) :
    (starRingEnd ℂ) (vertex n k) = vertex n (n - k) := by
  have hnorm : ‖vertex n k‖ = 1 := by
    rw [vertex_eq_pow, norm_pow, (Complex.isPrimitiveRoot_exp n hn.ne').norm'_eq_one hn.ne',
      one_pow]
  rw [← Complex.inv_eq_conj hnorm]
  exact (mul_eq_one_iff_inv_eq₀ (Complex.exp_ne_zero _)).mp (mirror_pair n k hn hk)

/-- Only index zero and the half-turn can pair with themselves. -/
theorem self_paired_iff (n k : ℕ) (hn : 0 < n) (hk : k < n) :
    vertex n k * vertex n k = 1 ↔ k = 0 ∨ 2 * k = n := by
  rw [vertex_eq_pow, ← pow_add, (Complex.isPrimitiveRoot_exp n hn.ne').pow_eq_one_iff_dvd]
  constructor
  · rintro ⟨d, hd⟩
    rcases d with _ | _ | d
    · simp at hd
      omega
    · simp at hd
      omega
    · have hbound := Nat.mul_le_mul_left n (show 2 ≤ d + 2 by omega)
      rw [← hd] at hbound
      omega
  · rintro (rfl | heq)
    · simp
    · simp [← two_mul, heq]

/-- Split an even polygon at the half-turn and reverse its second open arc.
The two endpoints remain after each pair of interior vertices cancels. -/
theorem prod_mirror_even {M : Type*} [CommMonoid M] (f : ℕ → M) (m : ℕ)
    (hm : 0 < m) (hpair : ∀ k, 0 < k → k < m → f k * f (m + m - k) = 1) :
    (∏ k ∈ Finset.range (m + m), f k) = f 0 * f m := by
  obtain ⟨t, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hm.ne'
  have hcancel : (∏ i ∈ Finset.range t, f (i + 1)) *
      (∏ i ∈ Finset.range t, f (t + 1 + (i + 1))) = 1 := by
    rw [← Finset.prod_range_reflect (fun i => f (t + 1 + (i + 1))) t,
      ← Finset.prod_mul_distrib]
    apply Finset.prod_eq_one
    intro i hi
    have hi' := Finset.mem_range.mp hi
    have hindex : t + 1 + (t - 1 - i + 1) = t + 1 + (t + 1) - (i + 1) := by omega
    rw [hindex]
    exact hpair (i + 1) (by omega) (by omega)
  rw [Finset.prod_range_add, Finset.prod_range_succ' f,
    Finset.prod_range_succ' (fun i => f (t + 1 + i))]
  simp only [Nat.add_zero]
  calc
    _ = ((∏ i ∈ Finset.range t, f (i + 1)) *
        (∏ i ∈ Finset.range t, f (t + 1 + (i + 1)))) * (f 0 * f (t + 1)) := by ac_rfl
    _ = _ := by rw [hcancel, one_mul]

/-- An even complex polygon has product minus one. -/
theorem prod_vertices_even (n : ℕ) (hn : 0 < n) (he : Even n) :
    ∏ k ∈ Finset.range n, vertex n k = -1 := by
  obtain ⟨m, rfl⟩ := he
  have hm : 0 < m := by omega
  rw [prod_mirror_even _ m hm (fun k _ hk => mirror_pair _ k hn (by omega))]
  have hm' : (m : ℂ) ≠ 0 := by exact_mod_cast hm.ne'
  have hhalf : 2 * (Real.pi : ℂ) * I * m / (↑(m + m : ℕ) : ℂ) = Real.pi * I := by
    push_cast
    field_simp [show (m : ℂ) + m ≠ 0 by rw [← two_mul]; exact mul_ne_zero (by norm_num) hm']
    ring
  rw [vertex, vertex, hhalf, Complex.exp_pi_mul_I]
  simp

theorem units_are_polygon (p : ℕ) [Fact p.Prime] :
    ∃ g : (ZMod p)ˣ, orderOf g = p - 1 := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := (ZMod p)ˣ)
  exact ⟨g, hg.trans (Nat.card_eq_fintype_card.trans (ZMod.card_units p))⟩

theorem inverse_is_mirror (p : ℕ) [Fact p.Prime] (g : (ZMod p)ˣ) (hg : orderOf g = p - 1)
    (k : ℕ) (hk : k ≤ p - 1) :
    (g ^ k)⁻¹ = g ^ (p - 1 - k) := by
  apply inv_eq_of_mul_eq_one_right
  rw [← pow_add, Nat.add_sub_of_le hk, ← hg, pow_orderOf_eq_one]

theorem self_inverse_units (p : ℕ) [Fact p.Prime] (u : (ZMod p)ˣ) :
    u * u = 1 ↔ u = 1 ∨ u = -1 := by
  simpa only [← Units.val_inj, Units.val_mul, Units.val_one, Units.val_neg] using
    (mul_self_eq_one_iff (a := (u : ZMod p)))

/-- A full injective list of units has the same product as the unit group. -/
private theorem prod_units_by_index (p : ℕ) [Fact p.Prime]
    (f : Fin (p - 1) → (ZMod p)ˣ) (hf : Function.Injective f) :
    (∏ i, (f i : ZMod p)) = ∏ u : (ZMod p)ˣ, (u : ZMod p) := by
  have hb : Function.Bijective f :=
    (Fintype.bijective_iff_injective_and_card f).mpr
      ⟨hf, by rw [Fintype.card_fin, ZMod.card_units]⟩
  exact Fintype.prod_equiv (Equiv.ofBijective f hb) _ _ (fun _ => rfl)

/-- The lists of positive residues and of generator powers enumerate the same units. -/
private theorem factorial_eq_generator_product (p : ℕ) [Fact p.Prime]
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) :
    ((p - 1).factorial : ZMod p) = ↑(∏ k ∈ Finset.range (p - 1), g ^ k) := by
  let residue (i : Fin (p - 1)) : (ZMod p)ˣ := Units.mk0 ((i.val + 1 : ℕ) : ZMod p) (by
    intro h
    have hval := congrArg ZMod.val h
    rw [ZMod.val_natCast_of_lt (by have := i.isLt; omega), ZMod.val_zero] at hval
    omega)
  have hir : Function.Injective residue := by
    intro i j hij
    have h := congrArg (fun u : (ZMod p)ˣ => (u : ZMod p).val) hij
    change (((i.val + 1 : ℕ) : ZMod p).val) = (((j.val + 1 : ℕ) : ZMod p).val) at h
    rw [ZMod.val_natCast_of_lt (by have := i.isLt; omega),
      ZMod.val_natCast_of_lt (by have := j.isLt; omega)] at h
    exact Fin.ext (by omega)
  have hig : Function.Injective (fun i : Fin (p - 1) => g ^ i.val) := by
    intro i j h
    apply Fin.ext
    apply pow_injOn_Iio_orderOf _ _ h
    · exact hg.symm ▸ i.isLt
    · exact hg.symm ▸ j.isLt
  calc
    ((p - 1).factorial : ZMod p) = ∏ i : Fin (p - 1), (residue i : ZMod p) := by
      change ((p - 1).factorial : ZMod p) = ∏ i : Fin (p - 1), ((i.val + 1 : ℕ) : ZMod p)
      rw [Nat.factorial_eq_prod_range_add_one, Finset.prod_natCast,
        Fin.prod_univ_eq_prod_range (fun i : ℕ => ((i + 1 : ℕ) : ZMod p))]
    _ = ∏ u : (ZMod p)ˣ, (u : ZMod p) := prod_units_by_index p residue hir
    _ = ∏ i : Fin (p - 1), ((g ^ i.val : (ZMod p)ˣ) : ZMod p) :=
      (prod_units_by_index p _ hig).symm
    _ = ↑(∏ k ∈ Finset.range (p - 1), g ^ k) := by
      rw [Fin.prod_univ_eq_prod_range (fun i : ℕ => ((g ^ i : (ZMod p)ˣ) : ZMod p))]
      exact (map_prod (Units.coeHom (ZMod p)) (fun k : ℕ => g ^ k) (Finset.range (p - 1))).symm

/-- Multiplying the complex vertices adds their indices modulo the polygon size. -/
private theorem polygon_product_index (n : ℕ) (hn : 0 < n) :
    vertex n ((∑ k ∈ Finset.range n, k) % n) = ∏ k ∈ Finset.range n, vertex n k := by
  let z := Complex.exp (2 * Real.pi * Complex.I / n)
  have hpow (k : ℕ) : vertex n k = z ^ k := vertex_eq_pow n k
  have ho : n = orderOf z := (Complex.isPrimitiveRoot_exp n hn.ne').eq_orderOf
  simp only [hpow]
  rw [Finset.prod_pow_eq_pow_sum, ho, pow_mod_orderOf]

/-- (C) Wilson, derived from the polygon (no Mathlib Wilson lemma in the closure). -/
theorem wilson_from_polygon (p : ℕ) (hp : p.Prime) :
    ((p - 1).factorial : ZMod p) = -1 := by
  have : Fact p.Prime := ⟨hp⟩
  rcases hp.eq_two_or_odd' with rfl | hodd
  · decide
  let n := p - 1
  have hn : 0 < n := by have := hp.two_le; dsimp [n]; omega
  have he : Even n := by obtain ⟨m, hm⟩ := hodd; exact ⟨m, by dsimp [n]; omega⟩
  let total := ∑ k ∈ Finset.range n, k
  let j := total % n
  have hj : j < n := Nat.mod_lt _ hn
  have hv : vertex n j = -1 := (polygon_product_index n hn).trans (prod_vertices_even n hn he)
  have hj0 : j ≠ 0 := by
    intro h
    rw [h] at hv
    norm_num [vertex] at hv
  have hhalf : 2 * j = n :=
    ((self_paired_iff n j hn hj).mp (by rw [hv]; norm_num)).resolve_left hj0
  obtain ⟨g, hg⟩ := units_are_polygon p
  have hinv : (g ^ j)⁻¹ = g ^ j := by
    rw [inverse_is_mirror p g hg j hj.le]
    congr 1
    change n - j = j
    omega
  have hu : g ^ j = -1 :=
    ((self_inverse_units p (g ^ j)).mp (by
      calc
        g ^ j * g ^ j = (g ^ j)⁻¹ * g ^ j := congrArg (· * g ^ j) hinv.symm
        _ = 1 := inv_mul_cancel _)).resolve_left
      (pow_ne_one_of_lt_orderOf hj0 (hg.symm ▸ hj))
  have htotal : g ^ total = g ^ j := by
    change g ^ total = g ^ (total % (p - 1))
    rw [← hg, pow_mod_orderOf]
  calc
    ((p - 1).factorial : ZMod p) = ↑(∏ k ∈ Finset.range n, g ^ k) :=
      factorial_eq_generator_product p g hg
    _ = ((g ^ total : (ZMod p)ˣ) : ZMod p) := by rw [Finset.prod_pow_eq_pow_sum]
    _ = -1 := by rw [htotal, hu, Units.val_neg, Units.val_one]

theorem active_gate_iff_prime_via_polygon {n : ℕ} (hn : 1 ≤ n) :
    (n + 1) ∣ n.factorial + 1 ↔ (n + 1).Prime := by
  constructor
  · intro h
    refine Nat.prime_def_lt'.2 ⟨by omega, ?_⟩
    intro d hd hlt hdvd
    have hfac : d ∣ n.factorial := Nat.dvd_factorial (by omega) (by omega)
    have hone : d ∣ 1 := (Nat.dvd_add_iff_right hfac).2 (hdvd.trans h)
    have := Nat.le_of_dvd Nat.one_pos hone
    omega
  · intro hp
    apply (ZMod.natCast_eq_zero_iff _ _).1
    have hfac : (n.factorial : ZMod (n + 1)) = -1 := by
      simpa only [Nat.add_sub_cancel] using wilson_from_polygon (n + 1) hp
    rw [Nat.cast_add, Nat.cast_one, hfac, neg_add_cancel]

end WilsonMechanism
