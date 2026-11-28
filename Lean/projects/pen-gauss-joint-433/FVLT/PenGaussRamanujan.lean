import FVLT.PenGaussCore
import Mathlib.NumberTheory.ArithmeticFunction.Moebius

/-! The principal-character pen and its Möbius-weighted comb realization. -/

open scoped BigOperators ArithmeticFunction.Moebius ArithmeticFunction.zeta
open FourierHelix

noncomputable section

namespace FVLT.PenGaussV1

/-- An equal-weight divisor comb with unit initial tooth and the pen's phase stride. -/
def divisorComb (d : ℕ) (x : ℤ) : ℂ :=
  walk d (-(offset d 0 * (2 / stride d) / d)) (2 / stride d) 1 x d d

/-- The same normalized endpoint in the centered-kernel form of `full_comb`. -/
theorem divisorComb_eq_full_comb {d : ℕ} (hd : 0 < d) (x : ℤ) :
    divisorComb d x =
      phase (-(offset d 0 * (2 / stride d) / d) * (x : ℝ)) *
        (kernel d ((2 / stride d) * (x : ℝ) / d) : ℂ) := by
  have hd' : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hd.ne'
  unfold divisorComb
  rw [full_comb hd', Complex.ofReal_one, one_mul]

theorem divisorComb_eq_pen_constant {d : ℕ} (hd : 0 < d) (x : ℤ) :
    divisorComb d x = pen (fun _ : ZMod d => 1) x := by
  have hd' : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hd.ne'
  have hs : stride d ≠ 0 := by
    unfold stride
    split <;> norm_num
  have htt : tooth d (-(offset d 0 * (2 / stride d) / d)) (2 / stride d) 1
      (x : ℝ) (offset d 0) = 1 := by
    rw [split_tooth hd']
    have h : -(offset d 0 * (2 / stride d) / d) * (x : ℝ) +
        offset d 0 * ((2 / stride d) * (x : ℝ) / d) = 0 := by ring
    rw [Complex.ofReal_one, one_mul, ← phase_add, h]
    simp [phase]
  unfold divisorComb pen
  rw [walk_geometric hd', htt, one_mul]
  apply Finset.sum_congr rfl
  intro i _
  have hp : ∀ j : ℕ, phase (2 * (x : ℝ) / d) ^ j = phase (2 * ((j : ℝ) * x) / d) := by
    intro j
    induction j with
    | zero => simp [phase]
    | succ j ih =>
      rw [pow_succ, ih, ← phase_add, Nat.cast_succ]
      congr 1
      ring
  have hr : stride d * (2 / stride d * (x : ℝ) / d) = 2 * (x : ℝ) / d := by
    field_simp <;> ring
  rw [ratio, hr, hp, one_mul]

theorem pen_constant_eq_indicator {d : ℕ} (hd : 0 < d) (x : ℤ) :
    pen (fun _ : ZMod d => 1) x = if (d : ℤ) ∣ x then (d : ℂ) else 0 := by
  letI : NeZero d := ⟨hd.ne'⟩
  rw [pen_eq_sum_std]
  simp only [one_mul]
  rw [AddChar.sum_mulShift _ (ZMod.isPrimitive_stdAddChar d)]
  simp [ZMod.card, ZMod.intCast_zmod_eq_zero_iff_dvd]

/-- The unweighted comb of the full modulus differs already at modulus two and frequency zero. -/
theorem pen_one_ne_divisorComb_two_zero :
    pen (1 : DirichletCharacter ℂ 2) 0 ≠ divisorComb 2 0 := by
  letI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  rw [pen_one_prime, divisorComb_eq_pen_constant (by decide), pen_constant_eq_indicator (by decide)]
  norm_num

private theorem principal_eq_moebius_sum {N : ℕ} (hN : 0 < N) (y : ℕ) :
    (1 : DirichletCharacter ℂ N) (y : ZMod N) =
      ∑ k ∈ N.divisors, if k ∣ y then (μ k : ℂ) else 0 := by
  classical
  have hg : N.gcd y ≠ 0 := (Nat.gcd_pos_of_pos_left y hN).ne'
  have hf : N.divisors.filter (fun k => k ∣ y) = (N.gcd y).divisors := by
    ext k
    simp only [Finset.mem_filter, Nat.mem_divisors, Nat.dvd_gcd_iff]
    exact ⟨fun h => ⟨⟨h.1.1, h.2⟩, hg⟩, fun h => ⟨⟨h.1.1, hN.ne'⟩, h.1.2⟩⟩
  have hm := congrArg (fun f : ArithmeticFunction ℤ => f (N.gcd y))
    ArithmeticFunction.moebius_mul_coe_zeta
  change (μ * ζ : ArithmeticFunction ℤ) (N.gcd y) = (1 : ArithmeticFunction ℤ) (N.gcd y) at hm
  rw [ArithmeticFunction.coe_mul_zeta_apply, ArithmeticFunction.one_apply] at hm
  rw [← Finset.sum_filter, hf, ← Int.cast_sum, hm]
  by_cases hy : IsUnit (y : ZMod N)
  · have hc := (ZMod.isUnit_iff_coprime y N).mp hy
    simp [MulChar.one_apply hy, hc.symm.gcd_eq_one]
  · have hc : N.gcd y ≠ 1 := by
      intro hg'
      exact hy ((ZMod.isUnit_iff_coprime y N).mpr (Nat.Coprime.symm hg'))
    rw [MulChar.map_nonunit (1 : DirichletCharacter ℂ N) hy]
    simp [hc]

private theorem pen_sum_multiples {N k : ℕ} (hk : k ∈ N.divisors) (x : ℤ) :
    (∑ y ∈ (Finset.range N).filter (fun y => k ∣ y), phase (2 * ((y : ℝ) * x) / N)) =
      pen (fun _ : ZMod (N / k) => 1) x := by
  have hkd : k ∣ N := Nat.dvd_of_mem_divisors hk
  have hkpos : 0 < k := Nat.pos_of_mem_divisors hk
  have heq : N / k * k = N := Nat.div_mul_cancel hkd
  have hk' : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hkpos.ne'
  have hd' : ((N / k : ℕ) : ℝ) ≠ 0 := by
    apply Nat.cast_ne_zero.mpr
    intro hz
    exact (Nat.ne_zero_of_mem_divisors hk) (by simpa [hz] using heq.symm)
  unfold pen
  symm
  refine Finset.sum_nbij' (fun j => j * k) (fun y => y / k) ?_ ?_ ?_ ?_ ?_
  · intro j hj
    simp only [Finset.mem_coe, Finset.mem_range] at hj
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range]
    exact ⟨heq ▸ Nat.mul_lt_mul_of_pos_right hj hkpos, Nat.dvd_mul_left _ _⟩
  · intro y hy
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range] at hy
    simpa only [Finset.mem_coe, Finset.mem_range] using (Nat.div_lt_iff_lt_mul hkpos).2 (heq.symm ▸ hy.1)
  · intro j _
    exact Nat.mul_div_cancel j hkpos
  · intro y hy
    exact Nat.div_mul_cancel (Finset.mem_filter.mp hy).2
  · intro j _
    rw [one_mul, Nat.cast_mul]
    congr 1
    have hr : ((N / k : ℕ) : ℝ) * (k : ℝ) = (N : ℝ) := by exact_mod_cast heq
    rw [← hr]
    field_simp <;> ring

private theorem pen_one_eq_moebius_comb' {N : ℕ} (hN : 0 < N) (x : ℤ) :
    pen (1 : DirichletCharacter ℂ N) x = ∑ k ∈ N.divisors, (μ k : ℂ) *
      pen (fun _ : ZMod (N / k) => 1) x := by
  classical
  change (∑ y ∈ Finset.range N, (1 : DirichletCharacter ℂ N) (y : ZMod N) *
    phase (2 * ((y : ℝ) * x) / N)) = _
  simp_rw [principal_eq_moebius_sum hN, Finset.sum_mul]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun k hk => ?_
  simp_rw [ite_mul, zero_mul]
  rw [← Finset.sum_filter, ← Finset.mul_sum, pen_sum_multiples hk]

/-- The principal pen is a Möbius-weighted sum of full, normalized divisor combs. -/
theorem pen_one_eq_moebius_comb {N : ℕ} (hN : 0 < N) (x : ℤ) :
    pen (1 : DirichletCharacter ℂ N) x =
      ∑ d ∈ N.divisors, (μ (N / d) : ℂ) * divisorComb d x := by
  rw [pen_one_eq_moebius_comb' hN,
    ← Nat.sum_div_divisors N (fun d => (μ (N / d) : ℂ) * divisorComb d x)]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : 0 < N / k := Nat.pos_of_mem_divisors
    (Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.dvd_of_mem_divisors hk), hN.ne'⟩)
  rw [divisorComb_eq_pen_constant hk', Nat.div_div_self (Nat.dvd_of_mem_divisors hk) hN.ne']

/-- The principal pen is the Ramanujan sum for all positive moduli and integer frequencies. -/
theorem pen_one_ramanujan {N : ℕ} (hN : 0 < N) (x : ℤ) :
    pen (1 : DirichletCharacter ℂ N) x =
      ∑ d ∈ (N.gcd x.natAbs).divisors, (d : ℂ) * (μ (N / d) : ℂ) := by
  classical
  rw [pen_one_eq_moebius_comb hN]
  have h : N.divisors.filter (fun d : ℕ => (d : ℤ) ∣ x) = (N.gcd x.natAbs).divisors := by
    ext k
    simp only [Finset.mem_filter, Int.natCast_dvd, Nat.mem_divisors, Nat.dvd_gcd_iff]
    exact ⟨fun h => ⟨⟨h.1.1, h.2⟩, (Nat.gcd_pos_of_pos_left _ hN).ne'⟩,
      fun h => ⟨⟨h.1.1, hN.ne'⟩, h.1.2⟩⟩
  calc
    _ = ∑ d ∈ N.divisors, if (d : ℤ) ∣ x then (d : ℂ) * (μ (N / d) : ℂ) else 0 := by
      refine Finset.sum_congr rfl fun d hd => ?_
      rw [divisorComb_eq_pen_constant (Nat.pos_of_mem_divisors hd),
        pen_constant_eq_indicator (Nat.pos_of_mem_divisors hd)]
      split <;> simp [mul_comm]
    _ = _ := by rw [← Finset.sum_filter, h]

end FVLT.PenGaussV1
