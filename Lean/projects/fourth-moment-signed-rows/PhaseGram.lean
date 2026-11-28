import GramBound
import CoherentEnergyRHBridge
open Finset MeasureTheory RHConnections.CoherentEnergyMeasure
noncomputable section
namespace FourthMoment

abbrev Ω := ℕ → ℝ
def a (X d : ℕ) := mertens (X/d)
def w (X : ℕ) (i : ℕ × ℕ) := a X i.1 * a X i.2
def H (X : ℕ) := ∫ ω, ‖D 1 X ω‖ ^ 4 ∂primeTorusMeasure

theorem z_cont (k : ℕ) : Continuous (Z k) := by unfold Z phasor; fun_prop
theorem z_norm (k : ℕ) (ω : Ω) : ‖Z k ω‖=1 := by
  unfold Z phasor
  simp [norm_prod,Complex.norm_exp]

theorem expandD (X : ℕ) (ω : Ω) :
    D 1 X ω = ∑ d ∈ I X, (a X d:ℂ)*Z d ω := by
  simpa [I,a] using D_eq_mertens_sum (B:=1) (by decide) X ω

theorem intD (X k : ℕ) : Integrable (fun ω => ‖D 1 X ω‖^k) primeTorusMeasure := by
  have cont : Continuous (D 1 X) := by simp_rw [funext (expandD X)]; exact continuous_finsetSum _ fun i _ => continuous_const.mul (z_cont i)
  apply Integrable.of_bound (cont.norm.pow k).aestronglyMeasurable ((∑ i ∈ I X, |a X i|)^k)
  apply ae_of_all; intro ω
  change ‖‖D 1 X ω‖ ^ k‖ ≤ _
  rw [Real.norm_of_nonneg (by positivity),expandD]
  apply pow_le_pow_left₀ (norm_nonneg _)
  exact (norm_sum_le ..).trans_eq (by simp [z_norm,Real.norm_eq_abs])

theorem squareD (X : ℕ) (ω : Ω) :
    D 1 X ω ^ 2 = ∑ i ∈ pairs X, (w X i:ℂ)*Z (label i) ω := by
  rw [expandD,sq,sum_mul,pairs,sum_product]
  apply sum_congr rfl
  intro i hi
  rw [mul_sum]
  apply sum_congr rfl
  intro j hj
  rw [label,Z_mul (show i ≠ 0 from (show 0 < i from (mem_Icc.mp hi).1).ne')
    (show j ≠ 0 from (show 0 < j from (mem_Icc.mp hj).1).ne')]
  simp [w]; ring

theorem phaseGram (X : ℕ) : H X =
    ∑ i ∈ pairs X, ∑ j ∈ pairs X, w X i*w X j*K (label i) (label j) := by
  let P := pairs X
  let term (i j : ℕ × ℕ) (ω : Ω) : ℂ :=
    ((w X i*w X j:ℝ):ℂ)*(Z (label i) ω * starRingEnd ℂ (Z (label j) ω))
  have ht (i j) : Integrable (term i j) primeTorusMeasure := by
    have cont : Continuous (term i j) := continuous_const.mul ((z_cont _).mul
      (Complex.continuous_conj.comp (z_cont _)))
    apply Integrable.of_bound cont.aestronglyMeasurable |w X i*w X j|
    apply ae_of_all; intro ω
    simp [term,z_norm,Real.norm_eq_abs,abs_mul]
  have termInt (i) (hi : i ∈ P) (j) (hj : j ∈ P) :
      ∫ ω, term i j ω ∂primeTorusMeasure = ((w X i*w X j*K (label i) (label j):ℝ):ℂ) := by
    have hp (i) (hi : i ∈ P) : label i ≠ 0 := (show 0<label i from (mem_Icc.mp (label_mem X hi)).1).ne'
    unfold term
    rw [integral_const_mul,← innerNu,innerNu_Z (hp _ hi) (hp _ hj)]
    push_cast [K]; rfl
  apply Complex.ofReal_injective
  calc
    ((H X:ℝ):ℂ) = ∫ ω, ((‖D 1 X ω‖^4:ℝ):ℂ) ∂primeTorusMeasure :=
      by simpa [H] using (Complex.ofRealCLM.integral_comp_comm (intD X 4)).symm
    _ = ∫ ω, ∑ i ∈ P, ∑ j ∈ P, term i j ω ∂primeTorusMeasure := by
      apply integral_congr_ae; apply ae_of_all; intro ω
      dsimp only
      rw [show ‖D 1 X ω‖^4 = ‖D 1 X ω^2‖^2 by rw [norm_pow]; ring]
      push_cast
      rw [← Complex.mul_conj',squareD,map_sum,sum_mul]
      apply sum_congr rfl; intro i _
      rw [mul_sum]; apply sum_congr rfl; intro j _
      simp only [term,map_mul,Complex.conj_ofReal,Complex.ofReal_mul]; ring
    _ = ∑ i ∈ P, ∑ j ∈ P, ((w X i*w X j*K (label i) (label j):ℝ):ℂ) := by
      rw [integral_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ => ht i j]
      apply sum_congr rfl; intro i hi
      rw [integral_finsetSum _ fun j _ => ht i j]
      exact sum_congr rfl fun j hj => termInt i hi j hj
    _ = _ := by push_cast; rfl

theorem energy_le (X : ℕ) {t : ℝ} (ht : 0<t) :
    (∫ ω, ‖D 1 X ω‖^2 ∂primeTorusMeasure) ≤ t + H X/t := by
  have hi := integral_mono (intD X 2) ((integrable_const t).add ((intD X 4).div_const t))
    (show ∀ ω, ‖D 1 X ω‖^2 ≤ t + ‖D 1 X ω‖^4/t by
      intro ω
      field_simp; nlinarith [sq_nonneg (‖D 1 X ω‖^2-t)])
  simpa [H, integral_add (integrable_const t) ((intD X 4).div_const t),integral_div] using hi
end FourthMoment
