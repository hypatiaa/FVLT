import FranelKernel

noncomputable section

namespace Ratioque.Franel

open Finset

/-- Sum over one equally spaced grid, translated by `x`. -/
private def gridSum (n : ℕ) (f : ℚ → ℝ) (x : ℚ) : ℝ :=
  ∑ k ∈ range n, f (x + k / (n : ℚ))

private theorem gridSum_comm (i j : ℕ) (f : ℚ → ℝ) :
    gridSum i (gridSum j f) = gridSum j (gridSum i f) := by
  funext x
  unfold gridSum
  rw [sum_comm]
  simp_rw [add_right_comm]

private theorem gridSum_preserves {c : ℚ} {f : ℚ → ℝ} (hf : Function.Periodic f c)
    (n : ℕ) : Function.Periodic (gridSum n f) c := by
  intro x
  unfold gridSum
  apply sum_congr rfl
  intro k _
  rw [add_right_comm, hf]

private theorem gridSum_period {f : ℚ → ℝ} (hf : Function.Periodic f 1)
    {n : ℕ} (hn : 0 < n) : Function.Periodic (gridSum n f) (1 / (n : ℚ)) := by
  intro x
  let g : ℕ → ℝ := fun k => f (x + (k : ℚ) / n)
  have hgn : g n = g 0 := by
    have hn' : (n : ℚ) ≠ 0 := by exact_mod_cast hn.ne'
    simpa [g, hn'] using hf x
  calc
    gridSum n f (x + 1 / (n : ℚ)) = ∑ k ∈ range n, g (k + 1) := by
      apply sum_congr rfl
      intro k _
      simp only [g, Nat.cast_add, Nat.cast_one]
      congr 1
      ring
    _ = gridSum n f x := by
      change _ = ∑ k ∈ range n, g k
      have hs := (sum_range_succ' g n).symm.trans (sum_range_succ g n)
      rw [hgn] at hs
      linarith

private theorem gridSum_at_period {f : ℚ → ℝ} {n : ℕ}
    (hf : Function.Periodic f (1 / (n : ℚ))) (x : ℚ) :
    gridSum n f x = n * f x := by
  unfold gridSum
  calc
    _ = ∑ _k ∈ range n, f x := by
      apply sum_congr rfl
      intro k _
      simpa [div_eq_mul_inv] using hf.nat_mul k x
    _ = _ := by simp

private theorem gridSum_common_period {i j : ℕ} (hi : 0 < i) (hj : 0 < j)
    {f : ℚ → ℝ} (hf : Function.Periodic f 1) :
    Function.Periodic (gridSum i (gridSum j f)) (1 / (Nat.lcm i j : ℚ)) := by
  have p := gridSum_period (gridSum_preserves hf j) hi
  have q := gridSum_preserves (gridSum_period hf hj) i
  have comb := (q.int_mul (Nat.gcdA i j)).add_period (p.int_mul (Nat.gcdB i j))
  refine (show ((Nat.gcdA i j : ℤ) : ℚ) * (1 / (j : ℚ)) +
      ((Nat.gcdB i j : ℤ) : ℚ) * (1 / (i : ℚ)) = 1 / (Nat.lcm i j : ℚ) from ?_) ▸ comb
  have hi' : (i : ℚ) ≠ 0 := by exact_mod_cast hi.ne'
  have hj' : (j : ℚ) ≠ 0 := by exact_mod_cast hj.ne'
  have hl' : (Nat.lcm i j : ℚ) ≠ 0 := by exact_mod_cast Nat.lcm_ne_zero hi.ne' hj.ne'
  have hBez : (Nat.gcd i j : ℚ) =
      i * ((Nat.gcdA i j : ℤ) : ℚ) + j * ((Nat.gcdB i j : ℤ) : ℚ) := by
    exact_mod_cast Nat.gcd_eq_gcd_ab i j
  have hgl : (Nat.gcd i j : ℚ) * (Nat.lcm i j : ℚ) = i * (j : ℚ) := by
    exact_mod_cast Nat.gcd_mul_lcm i j
  field_simp
  linear_combination (Nat.lcm i j : ℚ) * (-hBez) + hgl

private theorem period_dvd_grid {n m : ℕ} (hn : 0 < n) (hm : 0 < m) (hdiv : n ∣ m)
    {f : ℚ → ℝ} (hf : Function.Periodic f (1 / (m : ℚ))) :
    Function.Periodic f (1 / (n : ℚ)) := by
  obtain ⟨k, rfl⟩ := hdiv
  have hk : k ≠ 0 := by rintro rfl; simp at hm
  have hk' : (k : ℚ) ≠ 0 := by exact_mod_cast hk
  have hn' : (n : ℚ) ≠ 0 := by exact_mod_cast hn.ne'
  convert hf.nat_mul k using 1
  all_goals try with_reducible_and_instances rfl
  push_cast
  field_simp

private theorem bTwo_period : Function.Periodic bTwo 1 := by
  intro x
  simp [bTwo, Int.fract_add_one]

private theorem sum_real_linear (n : ℕ) :
    ∑ k ∈ range n, (k : ℝ) = (n : ℝ) * (n - 1) / 2 := by
  induction n with
  | zero => simp
  | succ n ih => rw [sum_range_succ, ih, Nat.cast_succ]; ring

private theorem sum_real_square (n : ℕ) :
    ∑ k ∈ range n, (k : ℝ)^2 = (n : ℝ) * (n - 1) * (2 * n - 1) / 6 := by
  induction n with
  | zero => simp
  | succ n ih => rw [sum_range_succ, ih, Nat.cast_succ]; ring

private theorem gridSum_bTwo {n : ℕ} (hn : 0 < n) :
    gridSum n bTwo 0 = 1 / (6 * (n : ℝ)) := by
  have hnq : (0 : ℚ) < n := by exact_mod_cast hn
  have hnr : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  calc
    _ = ∑ k ∈ range n, ((k : ℝ)^2 / (n : ℝ)^2 - (k : ℝ) / n + 1 / 6) := by
      apply sum_congr rfl
      intro k hk
      have hk' : (k : ℚ) < n := by exact_mod_cast (mem_range.mp hk)
      have hfract : Int.fract ((k : ℚ) / n) = (k : ℚ) / n :=
        Int.fract_eq_self.mpr ⟨by positivity, (div_lt_one hnq).mpr hk'⟩
      simp [bTwo, hfract, div_pow]
    _ = _ := by
      rw [sum_add_distrib, sum_sub_distrib, ← sum_div, ← sum_div, sum_real_linear, sum_real_square]
      simp only [sum_const, card_range, nsmul_eq_mul]
      field_simp
      ring

/-- The full pair of grids samples every point of their common grid uniformly. -/
private theorem pair_grid_bTwo {i j : ℕ} (hi : 0 < i) (hj : 0 < j) :
    gridSum i (gridSum j bTwo) 0 = (Nat.gcd i j : ℝ)^2 / (6 * i * j) := by
  let L := Nat.lcm i j
  have hl : 0 < L := Nat.pos_of_ne_zero (Nat.lcm_ne_zero hi.ne' hj.ne')
  have pL := gridSum_period bTwo_period hl
  have pi := period_dvd_grid hi hl (Nat.dvd_lcm_left i j) pL
  have pj := period_dvd_grid hj hl (Nat.dvd_lcm_right i j) pL
  have hf := gridSum_common_period hi hj bTwo_period
  have hsum : (L : ℝ) * gridSum i (gridSum j bTwo) 0 =
      (i : ℝ) * ((j : ℝ) * (1 / (6 * (L : ℝ)))) := by
    rw [← gridSum_at_period hf]
    rw [gridSum_comm L i, gridSum_comm L j, gridSum_at_period (gridSum_preserves pi j),
        gridSum_at_period pj, gridSum_bTwo hl]
  have hgl : (Nat.gcd i j : ℝ) * (L : ℝ) = i * (j : ℝ) := by
    exact_mod_cast Nat.gcd_mul_lcm i j
  have hir : (i : ℝ) ≠ 0 := by exact_mod_cast hi.ne'
  have hjr : (j : ℝ) ≠ 0 := by exact_mod_cast hj.ne'
  have hlr : (L : ℝ) ≠ 0 := by exact_mod_cast hl.ne'
  apply (eq_div_iff (by positivity : (6 * (i : ℝ) * j) ≠ 0)).2
  apply (mul_left_cancel₀ (pow_ne_zero 2 hlr))
  field_simp at hsum
  linear_combination (i : ℝ) * j * hsum - ((Nat.gcd i j : ℝ) * L + i * j) * hgl

private theorem Icc_grid_shift (n : ℕ) (g : ℕ → ℝ) :
    ∑ k ∈ Icc 1 n, g k = ∑ k ∈ range n, g (k+1) := by
  have he : Icc 1 n = Ico 1 (n+1) := by ext; simp
  rw [he, sum_Ico_eq_sum_range]
  simp [Nat.add_comm]

private theorem positive_grid {n : ℕ} (hn : 0 < n) {f : ℚ → ℝ}
    (hf : Function.Periodic f 1) (x : ℚ) :
    ∑ k ∈ Icc 1 n, f (x + (k : ℚ)/n) = gridSum n f x := by
  rw [Icc_grid_shift, ← gridSum_period hf hn x]
  apply sum_congr rfl
  intro k _
  congr 1
  push_cast
  ring

private theorem negative_grid {n : ℕ} (hn : 0 < n) {f : ℚ → ℝ}
    (hf : Function.Periodic f 1) (x : ℚ) :
    ∑ k ∈ Icc 1 n, f (x - (k : ℚ)/n) = gridSum n f x := by
  rw [Icc_grid_shift]
  unfold gridSum
  rw [← sum_range_reflect (fun k : ℕ => f (x + (k : ℚ)/n)) n]
  apply sum_congr rfl
  intro k hk
  have hk' := mem_range.mp hk
  have hn' : (n : ℚ) ≠ 0 := by exact_mod_cast hn.ne'
  rw [← hf (x - ((k+1 : ℕ) : ℚ) / n)]
  congr 1
  push_cast [Nat.cast_sub (by omega : k ≤ n-1), Nat.cast_sub (by omega : 1 ≤ n)]
  field_simp
  ring

/-- The pair of denominator grids contributes exactly the squared-gcd kernel. -/
theorem bTwo_grid_pair {i j : ℕ} (hi : 0 < i) (hj : 0 < j) :
    (∑ a ∈ Icc 1 i, ∑ b ∈ Icc 1 j, bTwo ((a : ℚ)/i - (b : ℚ)/j)) =
        (Nat.gcd i j : ℝ)^2 / (6 * i * j) := by
  simp_rw [negative_grid hj bTwo_period]
  simpa only [zero_add] using
    (positive_grid hi (gridSum_preserves bTwo_period j) 0).trans (pair_grid_bTwo hi hj)

end Ratioque.Franel

