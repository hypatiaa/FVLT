import Verified
import Mathlib.NumberTheory.ArithmeticFunction.Moebius

noncomputable section
namespace Ratioque.Franel
open Finset RHConnections ArithmeticFourierInversion CoherentEnergyBounds
open ArithmeticFunction

private def sqAr : ArithmeticFunction ℝ := ↑(ArithmeticFunction.pow 2)
private def jordan : ArithmeticFunction ℝ := sqAr.pmul
  (prodPrimeFactors fun p => 1 - 1/(p:ℝ)^2)

private theorem sqAr_apply (n : ℕ) : sqAr n = (n:ℝ)^2 := by
  simp [sqAr, ArithmeticFunction.pow_apply]

private theorem jordan_apply {n : ℕ} (hn : n ≠ 0) :
    jordan n = (n:ℝ)^2 * j n := by
  simp [jordan, sqAr_apply, pmul_apply, prodPrimeFactors_apply hn, j]

theorem sum_jordan_divisors (n : ℕ) :
    ∑ r ∈ n.divisors, (r:ℝ)^2 * j r = (n:ℝ)^2 := by
  have hs : sqAr.IsMultiplicative := isMultiplicative_pow.natCast
  have hj : jordan.IsMultiplicative :=
    hs.pmul (IsMultiplicative.prodPrimeFactors _)
  have he : jordan * (↑ArithmeticFunction.zeta : ArithmeticFunction ℝ) = sqAr := by
    apply (IsMultiplicative.eq_iff_eq_on_prime_powers _ (hj.mul isMultiplicative_zeta.natCast) _ hs).mpr
    intro p k hp
    rw [coe_mul_zeta_apply, Nat.sum_divisors_prime_pow hp, sqAr_apply]
    induction k with
    | zero => simp [jordan_apply]
    | succ k ih =>
      rw [Finset.sum_range_succ, ih, jordan_apply (pow_ne_zero _ hp.ne_zero)]
      simp only [j, Nat.primeFactors_prime_pow (Nat.succ_ne_zero k) hp, prod_singleton,
        Nat.cast_pow]
      rw [pow_succ (p:ℝ) k]
      field_simp [show (p:ℝ) ≠ 0 by exact_mod_cast hp.ne_zero]
      ring
  rw [← sqAr_apply n, ← he, coe_mul_zeta_apply]
  exact sum_congr rfl fun r hr => (jordan_apply (Nat.pos_of_mem_divisors hr).ne').symm


private theorem sum_multiples {N r : ℕ} (hr : 0 < r) (f : ℕ → ℝ) :
    ∑ a ∈ (Icc 1 N).filter (r ∣ ·), f a =
      ∑ k ∈ Icc 1 (N/r), f (r*k) := by
  have hi : (Icc 1 N).filter (r ∣ ·) = (Icc 1 (N/r)).image (r * ·) := by
    ext a
    simp only [mem_filter, mem_Icc, mem_image]
    constructor
    · rintro ⟨⟨ha,haN⟩, k, rfl⟩
      exact ⟨k, ⟨by by_contra! h; interval_cases k; simp_all,
        (Nat.le_div_iff_mul_le hr).mpr (by rwa [Nat.mul_comm])⟩, rfl⟩
    · rintro ⟨k, ⟨hk, hkN⟩, rfl⟩
      exact ⟨⟨Nat.mul_pos hr hk, by simpa [Nat.mul_comm] using (Nat.le_div_iff_mul_le hr).mp hkN⟩,
        dvd_mul_right _ _⟩
  rw [hi, sum_image]
  exact fun _ _ _ _ h => Nat.eq_of_mul_eq_mul_left hr h

private theorem multiples_M {N r : ℕ} (hr : 0 < r) :
    (∑ a ∈ (Icc 1 N).filter (r ∣ ·), M (N/a)/(a:ℝ)) = S 1 (N/r)/r := by
  rw [sum_multiples hr, S_from_M, Finset.sum_div]
  have hidx : Finset.Ioc 0 (N/r) = Icc 1 (N/r) := by ext k; simp; omega
  rw [hidx]
  apply sum_congr rfl
  intro k hk
  simp only [g_apply, if_pos (Nat.coprime_one_right k), Nat.div_div_eq_div_mul, Nat.cast_mul]
  ring

private theorem gcd_square_expansion {N a b : ℕ} (ha : a ∈ Icc 1 N) (_hb : b ∈ Icc 1 N) :
    (a.gcd b : ℝ)^2 = ∑ r ∈ Icc 1 N, if r ∣ a ∧ r ∣ b then (r:ℝ)^2 * j r else 0 := by
  have h0 : a.gcd b ≠ 0 := Nat.gcd_ne_zero_left (by have := (mem_Icc.mp ha).1; omega)
  have he : (Icc 1 N).filter (fun r => r ∣ a ∧ r ∣ b) = (a.gcd b).divisors := by
    ext r
    rw [mem_filter, Nat.mem_divisors]
    constructor
    · rintro ⟨_,h₁,h₂⟩
      exact ⟨Nat.dvd_gcd h₁ h₂, h0⟩
    · rintro ⟨h,_⟩
      have hra := h.trans (Nat.gcd_dvd_left a b)
      have hrb := h.trans (Nat.gcd_dvd_right a b)
      exact ⟨mem_Icc.mpr ⟨Nat.pos_of_dvd_of_pos hra (mem_Icc.mp ha).1,
        (Nat.le_of_dvd (mem_Icc.mp ha).1 hra).trans (mem_Icc.mp ha).2⟩, hra, hrb⟩
  rw [← Finset.sum_filter, he, sum_jordan_divisors (a.gcd b)]

/-- Exact diagonalization of the finite gcd quadratic form at B = 1. -/
theorem gcd_form_eq_energy (N : ℕ) :
    (∑ a ∈ Icc 1 N, ∑ b ∈ Icc 1 N,
      M (N/a) * M (N/b) * (a.gcd b : ℝ)^2 / ((a:ℝ)*b)) = energy (S 1) 1 N := by
  classical
  let s := Icc 1 N
  let w (a : ℕ) := M (N/a)/(a:ℝ)
  let v (r a : ℕ) : ℝ := if r ∣ a then w a else 0
  have entry (a : ℕ) (ha : a ∈ s) (b : ℕ) (hb : b ∈ s) :
      M (N/a) * M (N/b) * (a.gcd b:ℝ)^2 / ((a:ℝ)*b) =
      ∑ r ∈ s, ((r:ℝ)^2 * j r) * (v r a * v r b) := by
    rw [gcd_square_expansion ha hb]
    simp only [mul_sum, sum_div]
    apply sum_congr rfl
    intro r _
    by_cases h₁ : r ∣ a <;> by_cases h₂ : r ∣ b <;> simp [h₁, h₂, v, w]
    ring
  change (∑ a ∈ s, ∑ b ∈ s, _) = _
  calc
    _ = ∑ a ∈ s, ∑ b ∈ s, ∑ r ∈ s, ((r:ℝ)^2 * j r) * (v r a * v r b) :=
      sum_congr rfl fun a ha => sum_congr rfl fun b hb => entry a ha b hb
    _ = ∑ r ∈ s, ((r:ℝ)^2 * j r) * (∑ a ∈ s, v r a)^2 := by
      conv_lhs => arg 2; ext a; rw [sum_comm]
      rw [sum_comm]
      apply sum_congr rfl
      intro r _
      simp only [sq (∑ a ∈ s, v r a), Finset.sum_mul, Finset.mul_sum, mul_assoc]
      exact sum_congr rfl fun x _ => sum_congr rfl fun y _ => by rw [mul_comm (v r x) (v r y)]
    _ = energy (S 1) 1 N := by
      have idx : indices 1 N = s := by simp [indices,s]
      rw [energy,idx]
      apply sum_congr rfl
      intro r hr
      have rp : 0 < r := (mem_Icc.mp hr).1
      have hv : (∑ a ∈ s, v r a) = S 1 (N/r)/r := by
        simpa only [s, v, w, Finset.sum_filter] using (multiples_M (N:=N) rp)
      rw [hv]
      field_simp [show (r:ℝ) ≠ 0 by exact_mod_cast rp.ne']

end Ratioque.Franel
