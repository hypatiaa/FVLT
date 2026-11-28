import FranelPosition
import Mathlib.Algebra.Order.Chebyshev
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

noncomputable section

namespace Ratioque.Franel

open RHConnections Finset

/-- Each rank from one through the cardinality occurs exactly once. -/
private theorem sum_rank_eq_grid (A : Finset ℚ) (f : ℕ → ℝ) :
    (∑ x ∈ A, f ((A.filter (· ≤ x)).card)) = ∑ k ∈ Icc 1 A.card, f k := by
  induction A using Finset.induction_on_max with
  | empty => simp
  | insert a A hm ih =>
    have hna : a ∉ A := fun h => lt_irrefl _ (hm _ h)
    have hmax : (insert a A).filter (· ≤ a) = insert a A := by
      apply filter_true_of_mem
      intro x hx
      rcases mem_insert.mp hx with rfl | hx
      · rfl
      · exact (hm _ hx).le
    have hprev (x : ℚ) (hx : x ∈ A) : (insert a A).filter (· ≤ x) = A.filter (· ≤ x) := by
      ext y
      simp only [mem_filter, mem_insert]
      constructor
      · rintro ⟨rfl | hy, hyx⟩
        · exact False.elim (not_le.mpr (hm x hx) hyx)
        · exact ⟨hy, hyx⟩
      · exact fun h => ⟨Or.inr h.1,h.2⟩
    have hLast : Icc 1 (A.card+1) = insert (A.card+1) (Icc 1 A.card) := by
      ext k
      simp only [mem_Icc, mem_insert]; omega
    rw [sum_insert hna, hmax, card_insert_of_notMem hna, hLast, sum_insert (by simp)]
    rw [sum_congr rfl fun x hx => congrArg (fun z : Finset ℚ => f z.card) (hprev x hx), ih]

private theorem phi_two_le {N : ℕ} (hN : 2 ≤ N) : 2 ≤ Phi N := by
  have h₁ : (1 : ℚ) ∈ fareySet N := farey_mem_iff.mpr (by simpa using (show 1 ≤ N by omega))
  have h₂ : (1/2 : ℚ) ∈ fareySet N := farey_mem_iff.mpr (by norm_num; exact hN)
  have hsub : ({1,1/2} : Finset ℚ) ⊆ fareySet N := by
    intro r hr
    rcases Finset.mem_insert.mp hr with h | h
    · simpa [h] using h₁
    · rw [Finset.mem_singleton.mp h]; exact h₂
  exact (show ({1,1/2} : Finset ℚ).card = 2 by norm_num).symm ▸ card_le_card hsub

/-- M1: Astra's elementary bound linking the Mertens function to the Franel energy. -/
theorem abs_mertens_le_franel {N : ℕ} (hN : 2 ≤ N) :
    |(ArithmeticFourierInversion.M N : ℝ)| ≤ 2 * Real.pi * Real.sqrt (franelEnergy N - 1 / 12) := by
  let m := Phi N
  let d (r : ℚ) : ℝ := (r:ℝ) - (rank N r:ℝ) / m
  have hC : 0 ≤ 2 * Real.pi := by positivity
  let c (r : ℚ) := Real.cos (2 * Real.pi * (r:ℝ))
  let u (r : ℚ) := Real.cos (2 * Real.pi * ((rank N r:ℝ)/m))
  have hU : (∑ r ∈ fareySet N, u r) = 0 :=
    (sum_rank_eq_grid (fareySet N) (fun k => Real.cos (2 * Real.pi * ((k:ℝ)/m)))).trans
      (grid_cos_zero (phi_two_le hN))
  have hM : (∑ r ∈ fareySet N, (c r - u r)) = ArithmeticFourierInversion.M N := by
    rw [sum_sub_distrib, hU, sub_zero]
    exact farey_position_cos (by omega)
  have hLip (r : ℚ) : |c r-u r| ≤ (2*Real.pi) * |d r| := by
    calc
      _ ≤ |2*Real.pi*(r:ℝ) - 2*Real.pi*((rank N r:ℝ)/m)| := Real.abs_cos_sub_cos_le _ _
      _ = _ := by rw [← mul_sub, abs_mul, abs_of_nonneg hC]
  have hSq : (∑ r ∈ fareySet N, |d r|)^2 ≤
      (m:ℝ) * ∑ r ∈ fareySet N, (d r)^2 := by
    simpa only [sq_abs, m, Phi] using (sq_sum_le_card_mul_sum_sq (s := fareySet N) (f := fun r => |d r|))
  have hRoot : ∑ r ∈ fareySet N, |d r| ≤ Real.sqrt ((m:ℝ) * ∑ r ∈ fareySet N, (d r)^2) := by
    exact Real.le_sqrt_of_sq_le hSq
  have hE : franelEnergy N - 1 / 12 = (m:ℝ) * ∑ r ∈ fareySet N, (d r)^2 := by
    unfold franelEnergy
    exact add_sub_cancel_right _ _
  rw [← hM, hE]
  calc
    _ ≤ ∑ r ∈ fareySet N, |c r - u r| := abs_sum_le_sum_abs _ _
    _ ≤ ∑ r ∈ fareySet N, (2*Real.pi) * |d r| := sum_le_sum fun r _ => hLip r
    _ = (2*Real.pi) * ∑ r ∈ fareySet N, |d r| := (mul_sum ..).symm
    _ ≤ (2*Real.pi) * Real.sqrt ((m:ℝ) * ∑ r ∈ fareySet N, (d r)^2) :=
      mul_le_mul_of_nonneg_left hRoot hC

end Ratioque.Franel

#print axioms Ratioque.Franel.abs_mertens_le_franel
