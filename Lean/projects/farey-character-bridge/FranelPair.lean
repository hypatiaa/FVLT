import FranelKernel

noncomputable section
namespace Ratioque.Franel
open Finset

/-- Applying a one-dimensional weighted grid decomposition to each argument gives
the gcd quadratic form, with the factor of 12 arising from the rank-energy half
and the normalization of the second Bernoulli polynomial. -/
theorem weighted_pair_gcd (A : Finset ℚ) (s : Finset ℕ) (w : ℕ → ℝ)
    (hdis : ∀ f : ℚ → ℝ, (∑ r ∈ A, f r) =
      ∑ k ∈ s, w k * ∑ a ∈ Icc 1 k, f ((a:ℚ)/k))
    (hgrid : ∀ i ∈ s, ∀ j ∈ s,
      (∑ a ∈ Icc 1 i, ∑ b ∈ Icc 1 j, bTwo ((a:ℚ)/i - (b:ℚ)/j)) =
        (Nat.gcd i j : ℝ)^2 / (6 * (i:ℝ) * j)) :
    (∑ x ∈ A, ∑ y ∈ A, bTwo (x-y))/2 =
      (∑ i ∈ s, ∑ j ∈ s, w i * w j * (i.gcd j : ℝ)^2 / ((i:ℝ)*j))/12 := by
  have hxy (x : ℚ) := hdis (fun y => bTwo (x-y))
  rw [hdis (fun x => ∑ y ∈ A, bTwo (x-y))]
  simp only [hxy]
  rw [sum_div, sum_div]
  apply sum_congr rfl
  intro i hi
  rw [sum_comm]
  simp_rw [← mul_sum]
  rw [mul_sum, sum_div, sum_div]
  apply sum_congr rfl
  intro j hj
  rw [hgrid i hi j hj]
  ring

end Ratioque.Franel

