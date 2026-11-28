import FranelEnergy
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Complex

noncomputable section
namespace Ratioque.Franel

open Finset RHConnections.ArithmeticFourierInversion

/-- The first cosine harmonic sums to zero on each nontrivial complete grid. -/
theorem grid_cos_zero {n : ℕ} (hn : 2 ≤ n) :
    (∑ a ∈ Finset.Icc 1 n, Real.cos (2 * Real.pi * ((a : ℝ) / n))) = 0 := by
  have hn' : (1:ℝ) < n := by exact_mod_cast hn
  have hp : (0:ℝ) < n := by linarith
  let t : ℝ := 2 * Real.pi / n
  have hs : Real.sin (t/2) ≠ 0 := by
    apply (Real.sin_pos_of_pos_of_lt_pi ?_ ?_).ne'
    · dsimp [t]; positivity
    · dsimp [t]
      have h : Real.pi / n < Real.pi := div_lt_self Real.pi_pos hn'
      convert h using 1
      ring
  have ht : (n:ℝ) * t / 2 = Real.pi := by dsimp [t]; field_simp
  have hz := Real.sin_mul_sum_cos n t t
  rw [ht, Real.sin_pi, zero_mul] at hz
  have hz' := (mul_eq_zero.mp hz).resolve_left hs
  have hh : Icc 1 n = Ico 1 (n+1) := by ext; simp
  rw [hh, sum_Ico_eq_sum_range]
  convert hz' using 1
  apply sum_congr (by simp)
  intro k _
  congr 1
  dsimp [t]
  push_cast
  ring

/-- The first position harmonic measures the summatory Möbius function exactly. -/
theorem farey_position_cos {N : ℕ} (hN : 1 ≤ N) :
    (∑ r ∈ fareySet N, Real.cos (2 * Real.pi * (r:ℝ))) = M N := by
  rw [farey_grid_disintegration hN (fun r => Real.cos (2 * Real.pi * (r:ℝ)))]
  push_cast
  rw [sum_eq_single 1]
  · simp [Real.cos_two_pi]
  · intro k hk hk1
    have h := (mem_Icc.mp hk).1
    rw [grid_cos_zero (by omega : 2 ≤ k), mul_zero]
  · simp [hN]

end Ratioque.Franel
