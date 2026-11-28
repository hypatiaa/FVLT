import CoprimeSquarefree

namespace AtlasPairs
open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

/-- The implied constant depends only on the exponent. -/
theorem prime_weight {e : ℝ} (he : 0 < e) :
    ∃ K : ℝ, 0 < K ∧ ∀ m : ℕ, 0 < m → (2:ℝ)^m.primeFactors.card ≤ K*(m:ℝ)^e := by
  classical
  obtain ⟨A,hA⟩ := exists_nat_gt ((2:ℝ)^(1/e))
  refine ⟨2^(A+1),by positivity,?_⟩
  intro m hm
  have per (p : ℕ) (hp : p ∈ m.primeFactors) :
      (2:ℝ) ≤ (if p ≤ A then 2 else 1)*(p:ℝ)^e := by
    have h1 : (1:ℝ) ≤ p := by exact_mod_cast (Nat.prime_of_mem_primeFactors hp).one_le
    split_ifs with small
    · have := Real.one_le_rpow h1 he.le; linarith
    · rw [one_mul]
      have hh : (2:ℝ)^(1/e) ≤ p := hA.le.trans (by exact_mod_cast (Nat.le_of_lt (Nat.lt_of_not_ge small)))
      have h := Real.rpow_le_rpow (by positivity) hh he.le
      simpa [← Real.rpow_mul (by norm_num : (0:ℝ)≤2),he.ne'] using h
  let s := m.primeFactors
  have hc : (s.filter (· ≤ A)).card ≤ A+1 := by
    calc _ ≤ (range (A+1)).card := card_le_card (fun p hp => mem_range.mpr (by have := (mem_filter.mp hp).2; omega))
         _ = _ := card_range _
  have hprod : (∏ p ∈ s, (if p ≤ A then (2:ℝ) else 1)) ≤ 2^(A+1) := by
    rw [← prod_filter,prod_const]; exact pow_le_pow_right₀ (by norm_num) hc
  have radical : (∏ p ∈ s, (p:ℝ)) ≤ m := by
    rw [← Nat.cast_prod]; exact_mod_cast Nat.le_of_dvd hm (Nat.prod_primeFactors_dvd m)
  calc (2:ℝ)^s.card = ∏ _p ∈ s, (2:ℝ) := (prod_const ..).symm
       _ ≤ _ := prod_le_prod₀ (fun _ _ => by norm_num) per
       _ = _ := prod_mul_distrib
       _ ≤ _ := by
         rw [Real.finsetProd_rpow s (fun p : ℕ => (p:ℝ)) (fun _ _ => by positivity) e]
         exact mul_le_mul hprod (Real.rpow_le_rpow (by positivity) radical he.le) (by positivity) (by positivity)

def rows (b : ℕ) := (Ico 1 b).filter fun a => b < 2*a ∧ a.Coprime b ∧ (a*b).Coprime 6

/-- Both orders of the low denominator pairs, in reduced coordinates. -/
def lowPairs (X : ℝ) (Y : ℕ) : ℝ :=
  ∑ b ∈ Icc 1 Y, ∑ a ∈ rows b, 2*(μ a:ℝ)*(μ b:ℝ)*
    (count (6*a*b) (X/b)-count (6*a*b) (X/(2*a)))

def pairCoefficient (Y : ℕ) : ℝ :=
  ∑ b ∈ Icc 1 Y, ∑ a ∈ rows b, 2*(μ a:ℝ)*(μ b:ℝ)*
    (1/(b:ℝ)-1/(2*(a:ℝ)))*density (6*a*b)

private theorem expand_low (X : ℝ) (Y : ℕ) : lowPairs X Y-X*pairCoefficient Y =
    ∑ b ∈ Icc 1 Y, ∑ a ∈ rows b, 2*(μ a:ℝ)*(μ b:ℝ)*
      (count (6*a*b) (X/b)-count (6*a*b) (X/(2*a))-
      (X/b-X/(2*a))*density (6*a*b)) := by
  unfold lowPairs pairCoefficient
  simp only [mul_sum,← sum_sub_distrib]
  apply sum_congr rfl; intro b _; apply sum_congr rfl; intro a _; ring

/-- The pre-specialization estimate, uniform in the height as well as the cutoff. -/
theorem height_error {e : ℝ} (he : 0 < e) :
    ∃ A : ℝ, 0 < A ∧ ∀ (X : ℝ) (Y : ℕ), 2*(Y:ℝ) ≤ X →
      |lowPairs X Y-X*pairCoefficient Y| ≤ A*Real.sqrt X*(Y:ℝ)^(3/2+e:ℝ) := by
  obtain ⟨K,hK,w⟩ := prime_weight (half_pos he)
  refine ⟨48*K*(6:ℝ)^(e/2),by positivity,?_⟩
  intro X Y hXY
  have hx : 0 ≤ X := (by positivity : 0 ≤ 2*(Y:ℝ)).trans hXY
  let W := K*((6:ℝ)*(Y:ℝ)^2)^(e/2)
  have wt (b : ℕ) (hb : b ∈ Icc 1 Y) (a : ℕ) (ha : a ∈ Ico 1 b) :
      (2:ℝ)^(6*a*b).primeFactors.card ≤ W := by
    obtain ⟨b1,by'⟩ := mem_Icc.mp hb
    obtain ⟨a1,ab⟩ := mem_Ico.mp ha
    apply (w _ (by positivity : 0<6*a*b)).trans
    apply mul_le_mul_of_nonneg_left _ hK.le
    apply Real.rpow_le_rpow (by positivity) _ (half_pos he).le
    have hr : (a:ℝ)*b ≤ (Y:ℝ)*Y := by exact_mod_cast Nat.mul_le_mul (ab.le.trans by') by'
    push_cast; nlinarith
  rw [expand_low]
  apply (ratio_budget X 12 W Y hXY (by norm_num)
    (mul_nonneg hK.le (Real.rpow_nonneg (by positivity) _)) uniform_squarefree wt).trans
  by_cases zero : Y=0
  · subst Y; simp [Real.zero_rpow (by linarith : (3/2:ℝ)+e ≠ 0)]
  have yp : 0 < (Y:ℝ) := by exact_mod_cast Nat.pos_of_ne_zero zero
  have hh : ((Y:ℝ)^2)^(e/2) = (Y:ℝ)^e := by
    rw [← Real.rpow_natCast,← Real.rpow_mul yp.le]; congr 1; push_cast; ring
  have yy : (Y:ℝ)^(3/2+e:ℝ) = (Y:ℝ)*Real.sqrt Y*(Y:ℝ)^e := by
    rw [show (3/2:ℝ) = 1+1/2 by norm_num,Real.rpow_add yp,Real.rpow_add yp,
      Real.rpow_one,Real.sqrt_eq_rpow]
  dsimp [W]; rw [Real.mul_rpow (by norm_num) (by positivity),hh,yy]; ring_nf; rfl

/-- Uniform in the cutoff and every height through its cube root. -/
theorem cube_height_error {e : ℝ} (he : 0 < e) :
    ∃ A : ℝ, 0 < A ∧ ∀ (X : ℝ) (Y : ℕ), 2*(Y:ℝ) ≤ X → (Y:ℝ)^3 ≤ X →
      |lowPairs X Y-X*pairCoefficient Y| ≤ A*X^(1+e) := by
  obtain ⟨K,hK,w⟩ := prime_weight he
  refine ⟨48*K*(6:ℝ)^e,by positivity,?_⟩
  intro X Y hXY hcube
  have hx : 0 ≤ X := (by positivity : 0 ≤ 2*(Y:ℝ)).trans hXY
  let W := K*((6:ℝ)*X)^e
  have wt (b : ℕ) (hb : b ∈ Icc 1 Y) (a : ℕ) (ha : a ∈ Ico 1 b) :
      (2:ℝ)^(6*a*b).primeFactors.card ≤ W := by
    obtain ⟨b1,by'⟩ := mem_Icc.mp hb
    obtain ⟨a1,ab⟩ := mem_Ico.mp ha
    have mpos : 0 < 6*a*b := by positivity
    apply (w _ mpos).trans
    apply mul_le_mul_of_nonneg_left _ hK.le
    apply Real.rpow_le_rpow (by positivity) _ he.le
    push_cast
    have hy : 1 ≤ Y := b1.trans by'
    have h : a*b ≤ Y^3 := by
      calc a*b ≤ Y*Y := Nat.mul_le_mul (ab.le.trans by') by'
           _ ≤ (Y*Y)*Y := Nat.le_mul_of_pos_right _ hy
           _ = _ := by ring
    have hr : (a:ℝ)*b ≤ (Y:ℝ)^3 := by exact_mod_cast h
    linarith
  have bound := ratio_budget X 12 W Y hXY (by norm_num)
    (mul_nonneg hK.le (Real.rpow_nonneg (by positivity) _)) uniform_squarefree wt
  rw [expand_low]
  apply bound.trans
  have squ : (Y:ℝ)*Real.sqrt Y ≤ Real.sqrt X := by
    have h1 := Real.sq_sqrt (show 0 ≤ (Y:ℝ) by positivity)
    have h2 := Real.sq_sqrt hx
    have hh : ((Y:ℝ)*Real.sqrt Y)^2 ≤ (Real.sqrt X)^2 := by rw [mul_pow,h1,h2]; nlinarith
    exact (sq_le_sq₀ (by positivity) (Real.sqrt_nonneg X)).mp hh
  have key : (Y:ℝ)*Real.sqrt Y*Real.sqrt X ≤ X := by
    simpa [←sq, Real.sq_sqrt hx] using mul_le_mul_of_nonneg_right squ (Real.sqrt_nonneg X)
  by_cases x0 : X=0
  · subst X; simp [Real.zero_rpow (by linarith : 1+e ≠ 0)]
  dsimp [W]; rw [Real.mul_rpow (by norm_num) hx,Real.rpow_add (lt_of_le_of_ne hx (Ne.symm x0)),Real.rpow_one]
  calc _ = (48*K*(6:ℝ)^e*X^e)*((Y:ℝ)*Real.sqrt Y*Real.sqrt X) := by ring
       _ ≤ (48*K*(6:ℝ)^e*X^e)*X := mul_le_mul_of_nonneg_left key (by positivity)
       _ = _ := by ring
end
end AtlasPairs
