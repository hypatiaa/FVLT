import FourthMomentRH
open Finset RHConnections.CoherentEnergyMeasure
open RHConnections.ArithmeticFourierInversion
noncomputable section
namespace FourthMoment

def signedRow (X u : ℕ) : ℝ :=
  ∑ i ∈ pairs X, if u ∣ label i then w X i / (label i:ℝ) else 0

theorem firstRow (X : ℕ) : signedRow X 1 = (S 1 X)^2 := by
  rw [← scalarS_eq_S]
  have hf : (Icc 1 X).filter (fun k => k.Coprime 1) = I X := Finset.filter_true_of_mem fun k _ => Nat.coprime_one_right k
  simp only [signedRow,one_dvd,ite_true,pairs,sum_product,scalarS,hf, sq, sum_mul]
  apply sum_congr rfl; intro d _
  rw [mul_sum]
  apply sum_congr rfl; intro j _
  simp [w,label,a]; ring

theorem firstRow_growth_iff_RH :
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      (signedRow X 1)^2 ≤ C*(X:ℝ)^(2+ε)) ↔ RiemannHypothesis := by
  have scalar := (RHConnections.CoherentEnergyBounds.all_epsilon_iff (S 1) 1).trans
    (coherent_energy_growth_iff_RH 1)
  constructor
  · intro h
    apply scalar.mp
    intro e he
    obtain ⟨C,hC,hb⟩ := h (4*e) (by positivity)
    refine ⟨1+C, by positivity, ?_⟩
    intro X hX
    have hx : 0<(X:ℝ) := by exact_mod_cast hX
    have hh := hb X hX
    rw [firstRow] at hh
    have hpow : ((X:ℝ)^(1/2+e))^4=(X:ℝ)^(2+4*e) := by
      rw [← Real.rpow_mul_natCast hx.le]; norm_num; ring_nf
    have hc : C ≤ (1+C)^4 := by nlinarith [sq_nonneg C, pow_nonneg hC 3, pow_nonneg hC 4]
    apply le_of_pow_le_pow_left₀ (n:=4) (by decide) (by positivity)
    rw [mul_pow,hpow,show |S 1 X|^4=((S 1 X)^2)^2 by rw [show (4:ℕ)=2*2 by decide,pow_mul,sq_abs]]
    exact hh.trans (mul_le_mul_of_nonneg_right hc (by positivity))
  · intro h e he
    obtain ⟨A,hA,ha⟩ := scalar.mpr h (e/4) (by positivity)
    refine ⟨A^4,by positivity,?_⟩
    intro X hX
    have hx : 0<(X:ℝ) := by exact_mod_cast hX
    have hh := pow_le_pow_left₀ (abs_nonneg _) (ha X hX) 4
    rw [mul_pow,← Real.rpow_mul_natCast hx.le] at hh
    rw [firstRow]
    convert hh using 1
    · rw [show (4:ℕ)=2*2 by decide,pow_mul,sq_abs]
    · congr 2; norm_num; ring

/-- In the outer third each supported factor has quotient one or two. -/
theorem outer_weights (X : ℕ) {i : ℕ × ℕ} (hi : i ∈ pairs X)
    (h : X*(X/3) < label i) : w X i = 0 ∨ w X i = 1 := by
  obtain ⟨ha,hb⟩ := mem_product.mp hi
  obtain ⟨ha1,ha2⟩ := mem_Icc.mp ha
  obtain ⟨hb1,hb2⟩ := mem_Icc.mp hb
  have fac (d m : ℕ) (hd : 1≤d) (hle : d≤X) (hmore : X*(X/3) < d*m) (hm : m≤X) :
      a X d = 0 ∨ a X d=1 := by
    have hd3 : X/3<d := by
      by_contra! hn
      exact (not_le_of_gt hmore) ((Nat.mul_le_mul hn hm).trans_eq (Nat.mul_comm ..))
    have lt3 : X/d<3 := (Nat.div_lt_iff_lt_mul hd).mpr (by omega)
    have pos := Nat.div_pos hle hd
    have cases : X/d=1 ∨ X/d=2 := by omega
    rcases cases with h1|h2
    · right; rw [a,h1]; norm_num [mertens,ArithmeticFunction.moebius]
    · left; rw [a,h2]; rw [mertens, show Finset.Ioc 0 2 = {1,2} by decide]; simp [ArithmeticFunction.moebius_apply_prime Nat.prime_two]
  have h1 := fac _ _ ha1 ha2 h hb2
  have h2 := fac _ _ hb1 hb2 (show X*(X/3) < i.2*i.1 by simpa [label,Nat.mul_comm] using h) ha2
  unfold w
  rcases h1 with h1|h1 <;> rcases h2 with h2|h2 <;> simp [h1,h2]

#print axioms firstRow_growth_iff_RH
end FourthMoment
