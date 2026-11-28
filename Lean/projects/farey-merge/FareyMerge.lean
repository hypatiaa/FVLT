import Mathlib

namespace AtlasMerge
open Finset

/-- Duplicated representations of a reduced rational collapse in the finite image. -/
def farey (N : ℕ) : Finset ℚ :=
  (((Icc 0 N) ×ˢ (Icc 1 N)).filter fun p => p.1 ≤ p.2).image
    (fun p => (p.1 : ℚ) / p.2)

/-- Bracketing at a coarse order, with the left endpoint winning a denominator tie. -/
def parent (order : ℕ) (r : ℚ) : ℚ :=
  let left := insert (0:ℚ) ((farey order).filter (· ≤ r))
  let right := insert (1:ℚ) ((farey order).filter (r ≤ ·))
  let lo := left.max' (Finset.insert_nonempty ..)
  let hi := right.min' (Finset.insert_nonempty ..)
  if lo.den ≤ hi.den then lo else hi

def twoLevelAnchor (N : ℕ) (r : ℚ) := parent (N/4) (parent (N/2) r)

/-- Rank zero is an anchor only. Positive points are counted at the original order. -/
def displacement (N : ℕ) (r : ℚ) : ℚ :=
  let obs := (farey N).erase 0
  r - ((obs.filter (· ≤ r)).card : ℚ) / obs.card

/-- Changing the center of a weighted cluster, with the mean equation
in undivided form so that an empty cluster causes no exception. -/
theorem change_center {ι : Type*} (s : Finset ι) (w x : ι → ℝ) (μ t : ℝ)
    (hμ : ∑ i ∈ s, w i * (x i - μ) = 0) :
    ∑ i ∈ s, w i * (x i - t)^2 =
      (∑ i ∈ s, w i * (x i - μ)^2) + (∑ i ∈ s, w i) * (μ-t)^2 := by
  have ht (i : ι) : w i * (x i - t)^2 =
      w i * (x i - μ)^2 + w i * (μ-t)^2 + (w i * (x i - μ)) * (2*(μ-t)) := by ring
  simp only [ht, sum_add_distrib, ← sum_mul, hμ, zero_mul, add_zero]

/-- The lower-order Farey neighbor gap is the reciprocal of the product
of its two denominators. This also covers an observation on an endpoint. -/
theorem two_moves (N q u v w z d₁ d₂ : ℝ) (hN : 0 < N) (hq : 0 < q)
    (hu : q ≤ u) (hw : q ≤ w) (hv : N ≤ 4*v) (hz : N ≤ 8*z)
    (h₁ : d₁ ≤ 1/(u*v)) (h₂ : d₂ ≤ 1/(w*z)) :
    d₁+d₂ ≤ 12/(q*N) := by
  have hv' : 0 < v := by linarith
  have hz' : 0 < z := by linarith
  have aux (a b c : ℝ) (ha : q ≤ a) (hb : 0 < b) (hc : 0 ≤ c) (h : N ≤ c*b) :
      1/(a*b) ≤ c/(q*N) := by
    apply (div_le_div_iff₀ (mul_pos (hq.trans_le ha) hb) (mul_pos hq hN)).2
    calc 1*(q*N) ≤ q*(c*b) := by simpa using mul_le_mul_of_nonneg_left h hq.le
         _ ≤ a*(c*b) := mul_le_mul_of_nonneg_right ha (mul_nonneg hc hb.le)
         _ = c*(a*b) := by ring
  have h4 := h₁.trans (aux u v 4 hu hv' (by norm_num) hv)
  have h8 := h₂.trans (aux w z 8 hw hz' (by norm_num) hz)
  linarith [add_div (4:ℝ) 8 (q*N)]

/-- Position and rank move in the same direction. Both fine endpoints
use the original rank denominator m. The spacing estimate is in rank units. -/
theorem displacement_change (r b k j m N q : ℝ)
    (hN : 0 < N) (hq : 0 < q) (hm : 0 < m) (hmN : m ≤ N^2)
    (hpos : |r-b| ≤ 12/(q*N)) (hspace : |k-j| ≤ N^2*|r-b|)
    (horder : (r ≤ b ∧ k ≤ j) ∨ (b ≤ r ∧ j ≤ k)) :
    |(r-k/m)-(b-j/m)| ≤ 12*N/(m*q) := by
  have h₁ : |r-b| ≤ 12*N/(m*q) := hpos.trans (by
    apply (div_le_div_iff₀ (mul_pos hq hN) (mul_pos hm hq)).2
    nlinarith [mul_nonneg hq.le (sub_nonneg.mpr hmN)])
  have h₂ : |k-j|/m ≤ 12*N/(m*q) := by
    apply (div_le_iff₀ hm).2
    calc |k-j| ≤ N^2*(12/(q*N)) := hspace.trans (mul_le_mul_of_nonneg_left hpos (sq_nonneg _))
         _ = 12*N/(m*q)*m := by field_simp
  rw [show (r-k/m)-(b-j/m) = (r-b)-(k-j)/m by ring, abs_le]
  rcases horder with ⟨hr,hk⟩ | ⟨hr,hk⟩
  · rw [abs_of_nonpos (sub_nonpos.mpr hr)] at h₁
    rw [abs_of_nonpos (sub_nonpos.mpr hk), neg_div] at h₂
    have := div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr hk) hm.le
    constructor <;> linarith
  · rw [abs_of_nonneg (sub_nonneg.mpr hr)] at h₁
    rw [abs_of_nonneg (sub_nonneg.mpr hk)] at h₂
    have := div_nonneg (sub_nonneg.mpr hk) hm.le
    constructor <;> linarith

/-- The numerical energy budget for a parent with q as its denominator. -/
theorem parent_cost (N m q L R : ℝ) (hN : 0 < N) (hq : 0 < q) (hm : N^2 ≤ 8*m)
    (hL : L ≤ 25*N/q) (hR : 0 ≤ R) (hr : R ≤ 12*N/(m*q)) :
    m*L*R^2 ≤ 28800*N/q^3 := by
  have hm' : 0 < m := by nlinarith [sq_pos_of_pos hN]
  have hp : 0 ≤ 25*N/q := by positivity
  calc
    _ ≤ m*(25*N/q)*(12*N/(m*q))^2 := by
      apply mul_le_mul (mul_le_mul_of_nonneg_left hL hm'.le) (by gcongr) (sq_nonneg _) (mul_nonneg hm'.le hp)
    _ = (3600*N^3/m)/q^3 := by field_simp; ring
    _ ≤ _ := by
      apply div_le_div_of_nonneg_right _ (by positivity)
      apply (div_le_iff₀ hm').2
      nlinarith [mul_nonneg hN.le (sub_nonneg.mpr hm)]

/-- Weighted child means can be centered at the displacement of the original anchor.
The squared distance to the parent mean is bounded by the resulting cost. -/
theorem child_variance {ι : Type*} (s : Finset ι) (w x : ι → ℝ)
    (μ anchor R : ℝ) (hw : ∀ i ∈ s, 0 ≤ w i)
    (hm : ∑ i ∈ s, w i * (x i-μ) = 0)
    (hr : ∀ i ∈ s, |x i-anchor| ≤ R) :
    ∑ i ∈ s, w i*(x i-μ)^2 ≤ (∑ i ∈ s, w i)*R^2 := by
  have h := change_center s w x μ anchor hm
  calc _ ≤ ∑ i ∈ s, w i*(x i-anchor)^2 := by
         rw [h]; exact le_add_of_nonneg_right (mul_nonneg (sum_nonneg hw) (sq_nonneg _))
       _ ≤ ∑ i ∈ s, w i*R^2 := by
         apply sum_le_sum
         intro i hi
         apply mul_le_mul_of_nonneg_left _ (hw i hi)
         have ha := hr i hi
         nlinarith [sq_abs (x i-anchor), mul_nonneg (sub_nonneg.mpr ha)
           (add_nonneg ((abs_nonneg _).trans ha) (abs_nonneg (x i-anchor)))]
       _ = _ := by rw [sum_mul]

/-- Sum the actual parent budgets, including the extra endpoint. -/
theorem sum_parent_cost {ι : Type*} (s : Finset ι) (q cost : ι → ℝ)
    (N : ℝ) (hN : 0 ≤ N) (hc : ∀ i ∈ s, cost i ≤ 28800*N*(1/q i^3))
    (hmass : ∑ i ∈ s, 1/q i^3 ≤ 3) : ∑ i ∈ s, cost i ≤ 86400*N := by
  calc _ ≤ ∑ i ∈ s, 28800*N*(1/q i^3) := sum_le_sum hc
       _ = 28800*N*(∑ i ∈ s, 1/q i^3) := (mul_sum ..).symm
       _ ≤ 28800*N*3 := mul_le_mul_of_nonneg_left hmass (by positivity)
       _ = _ := by ring
end AtlasMerge
