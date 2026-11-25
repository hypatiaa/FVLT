import CoherentEnergyMeasure
import Mathlib.Algebra.Polynomial.Roots

/-! Root multiplicity of the arithmetic Möbius lift when all prime phases agree. -/

noncomputable section

open Polynomial

namespace RHConnections.CoherentEnergyMeasure

/-- The polynomial obtained by giving each prime direction the same variable. -/
def diagonalLift (N : ℕ) : ℂ[X] :=
  ∏ p ∈ N.primeFactors, X ^ (N.factorization p - 1) * (X - 1)

/-- The exponent left over after taking one vanishing factor per prime direction. -/
def residualExponent (N : ℕ) : ℕ :=
  ∑ p ∈ N.primeFactors, (N.factorization p - 1)

/-- On the unit circle this polynomial evaluates to the original divisor-sum lift. -/
theorem diagonalLift_eval (N : ℕ) (hN : N ≠ 0) (t : ℝ) :
    (diagonalLift N).eval (Complex.exp (Complex.I * (t : ℂ))) =
      mobiusLift N (fun _ => t) := by
  rw [mobiusLift_eq_prod hN]
  simp [diagonalLift, phasor, Polynomial.eval_prod]

theorem diagonalLift_factorization (N : ℕ) :
    diagonalLift N = X ^ residualExponent N * (X - 1) ^ N.primeFactors.card := by
  unfold diagonalLift residualExponent
  rw [Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum, Finset.prod_const]

/-- Every nonzero diagonal phase away from alignment gives a nonzero value. -/
theorem diagonalLift_eval_ne_zero (N : ℕ) {z : ℂ} (hz : z ≠ 0) (hz1 : z ≠ 1) :
    (diagonalLift N).eval z ≠ 0 := by
  simpa [diagonalLift_factorization] using
    (mul_ne_zero (pow_ne_zero (residualExponent N) hz)
      (pow_ne_zero N.primeFactors.card (sub_ne_zero.mpr hz1)))

/-- The order of the diagonal polynomial at 1 is the number of distinct prime divisors. -/
theorem diagonalLift_rootMultiplicity_one (N : ℕ) :
    (diagonalLift N).rootMultiplicity 1 = N.primeFactors.card := by
  rw [diagonalLift_factorization]
  have hX : (X ^ residualExponent N : ℂ[X]) ≠ 0 := pow_ne_zero _ X_ne_zero
  have hu : ¬ (X ^ residualExponent N : ℂ[X]).IsRoot 1 := by
    simp [Polynomial.IsRoot]
  simpa only [map_one, rootMultiplicity_eq_zero hu, Nat.zero_add] using
    (rootMultiplicity_mul_X_sub_C_pow (a := (1 : ℂ)) (n := N.primeFactors.card) hX)

private theorem exponents_720 :
    residualExponent 720 = 4 ∧ (720 : ℕ).primeFactors.card = 3 := by
  let factors : List ℕ := [2, 2, 2, 2, 3, 3, 5]
  have h : (720 : ℕ).primeFactorsList.Perm factors := by
    apply List.Perm.symm
    apply Nat.primeFactorsList_unique (by decide)
    intro p hp
    change p ∈ [2, 2, 2, 2, 3, 3, 5] at hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with h | h | h | h | h | h | h <;> subst p <;> decide
  have hs : (720 : ℕ).primeFactors = factors.toFinset := by
    ext p
    simpa only [← Nat.toFinset_factors, List.mem_toFinset] using h.mem_iff (a := p)
  have hc (p : ℕ) : (720 : ℕ).factorization p = factors.count p := by
    rw [← Nat.primeFactorsList_count_eq]
    exact h.count_eq p
  simp only [residualExponent, hs, hc]
  decide

theorem diagonalLift_720 :
    diagonalLift 720 = X ^ 4 * (X - 1) ^ 3 := by
  rw [diagonalLift_factorization]
  rw [exponents_720.1, exponents_720.2]

theorem diagonalLift_720_rootMultiplicity :
    (diagonalLift 720).rootMultiplicity 1 = 3 := by
  rw [diagonalLift_rootMultiplicity_one]
  exact exponents_720.2

end RHConnections.CoherentEnergyMeasure

namespace StepanovCounting

/-- If each point of a finite set has multiplicity at least m in a nonzero
polynomial, the degree pays at least m for each point. -/
theorem card_mul_order_le_natDegree {K : Type*} [Field K] {P : K[X]} (hP : P ≠ 0)
    (S : Finset K) (m : ℕ) (hm : ∀ a ∈ S, m ≤ P.rootMultiplicity a) :
    m * S.card ≤ P.natDegree := by
  classical
  calc
    m * S.card = ∑ a ∈ S, m := by simp [Nat.mul_comm]
    _ ≤ ∑ a ∈ S, P.roots.count a := Finset.sum_le_sum fun a ha => by
      simpa only [Polynomial.count_roots] using hm a ha
    _ ≤ ∑ a ∈ S ∪ P.roots.toFinset, P.roots.count a :=
      Finset.sum_le_sum_of_subset_of_nonneg Finset.subset_union_left (by simp)
    _ = P.roots.card := Multiset.sum_count_eq_card (by
      intro a ha
      exact Finset.mem_union_right _ (Multiset.mem_toFinset.mpr ha))
    _ ≤ P.natDegree := WithBot.coe_le_coe.mp
      ((Polynomial.card_roots hP).trans_eq (Polynomial.degree_eq_natDegree hP))

end StepanovCounting
