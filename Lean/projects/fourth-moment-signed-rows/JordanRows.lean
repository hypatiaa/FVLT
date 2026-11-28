import FirstRow

open Finset ArithmeticFunction
noncomputable section
namespace FourthMoment

def squareFn : ArithmeticFunction ℝ := ⟨fun n => (n:ℝ)^2, by simp⟩
/-- The Jordan totient of order two, defined by Dirichlet inversion of n². -/
def jordan : ArithmeticFunction ℝ := squareFn * (moebius : ArithmeticFunction ℝ)
theorem jordan_sum (g : ℕ) : ∑ u ∈ g.divisors, jordan u = (g:ℝ)^2 := by
  rw [← coe_mul_zeta_apply,jordan,mul_assoc,coe_moebius_mul_coe_zeta,mul_one]
  rfl

theorem signed_row_energy (X : ℕ) :
    H X = ∑ u ∈ I (X*X), jordan u*(signedRow X u)^2 := by
  let c (u : ℕ) (i : ℕ × ℕ) : ℝ := if u ∣ label i then w X i / (label i:ℝ) else 0
  have pair (i) (hi : i ∈ pairs X) (j) (hj : j ∈ pairs X) :
      w X i*w X j*K (label i) (label j) =
        ∑ u ∈ I (X*X), jordan u*c u i*c u j := by
    let g := (label i).gcd (label j)
    have pi := mem_Icc.mp (label_mem X hi)
    have pj := mem_Icc.mp (label_mem X hj)
    have pg : 0 < g := Nat.gcd_pos_of_pos_left _ pi.1
    have sizes : ((I (X*X)).filter (· ∣ g)) = g.divisors := by
      ext u
      simp only [mem_filter,I,mem_Icc,Nat.mem_divisors]
      constructor
      · exact fun h => ⟨h.2,pg.ne'⟩
      · intro h
        exact ⟨⟨Nat.pos_of_dvd_of_pos h.1 pg, (Nat.le_of_dvd pg h.1).trans
          ((Nat.gcd_le_left _ pi.1).trans pi.2)⟩,h.1⟩
    unfold K
    change w X i*w X j*((g:ℝ)^2/_) = _
    rw [← jordan_sum,← sizes, sum_filter, sum_div,mul_sum]
    apply sum_congr rfl; intro u _
    dsimp only [c,g]
    by_cases hiu : u ∣ label i <;> by_cases hju : u ∣ label j
    all_goals simp [Nat.dvd_gcd_iff,hiu,hju,div_eq_mul_inv]
    all_goals ring
  rw [phaseGram]
  calc
    _ = ∑ i ∈ pairs X, ∑ j ∈ pairs X, ∑ u ∈ I (X*X), jordan u*c u i*c u j :=
      sum_congr rfl fun i hi => sum_congr rfl fun j hj => pair i hi j hj
    _ = ∑ u ∈ I (X*X), ∑ i ∈ pairs X, ∑ j ∈ pairs X, jordan u*c u i*c u j := by
      conv_lhs => arg 2; intro i; rw [sum_comm]
      rw [sum_comm]
    _ = _ := by
      apply sum_congr rfl; intro u _
      change _ = jordan u*(∑ i ∈ pairs X, c u i)^2
      simp only [sq,sum_mul,mul_sum]
      apply sum_congr rfl; intro i _
      apply sum_congr rfl; intro j _
      ring

#print axioms signed_row_energy
end FourthMoment
