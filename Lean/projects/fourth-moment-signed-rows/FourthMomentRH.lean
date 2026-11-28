import PhaseGram
open Finset MeasureTheory RHConnections.CoherentEnergyMeasure
noncomputable section
namespace FourthMoment

def FourthGrowth := ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
  H X ≤ C*(X:ℝ)^(2+ε)

theorem massBound {A θ : ℝ} (hA : 0≤A) (hθ : 1/2 < θ)
    (hb : ∀ n : ℕ, 1 ≤ n → |mertens n| ≤ A*(n:ℝ)^θ) (X : ℕ) :
    ∑ d ∈ I X, (a X d)^2 ≤ A^2*(X:ℝ)^(2*θ)*zsum (2*θ) := by
  have hs := Real.summable_one_div_nat_rpow.mpr (show 1<2*θ by linarith)
  calc
    _ ≤ ∑ d ∈ I X, (A^2*(X:ℝ)^(2*θ))*(1/(d:ℝ)^(2*θ)) := by
      apply sum_le_sum; intro d hd
      obtain ⟨h1,h2⟩ := mem_Icc.mp hd
      have hp : 0<(d:ℝ) := by exact_mod_cast h1
      have hquot : ((X/d:ℕ):ℝ) ≤ (X:ℝ)/d := by
        apply (le_div_iff₀ hp).mpr; exact_mod_cast Nat.div_mul_le_self X d
      have hb' := (hb _ (Nat.div_pos h2 h1)).trans <|
        mul_le_mul_of_nonneg_left (Real.rpow_le_rpow (Nat.cast_nonneg _) hquot (by linarith)) hA
      have hpw (x : ℝ) (hx : 0 ≤ x) : (x^θ)^2=x^(2*θ) := by
        rw [mul_comm (2:ℝ),Real.rpow_mul hx,Real.rpow_two]
      calc
        _ ≤ (A * ((X:ℝ)/d)^θ)^2 := by simpa [a,sq_abs] using pow_le_pow_left₀ (abs_nonneg _) hb' 2
        _ = _ := by rw [mul_pow,hpw _ (by positivity),Real.div_rpow (by positivity) hp.le]; ring
    _ ≤ _ := by
      rw [← mul_sum]
      exact mul_le_mul_of_nonneg_left (hs.sum_le_tsum _ (fun _ _ => by positivity)) (by positivity)

theorem fourth_of_RH (hRH : RiemannHypothesis) : FourthGrowth := by
  intro δ hδ
  let e := δ/10
  have he : 0<e := by dsimp [e]; positivity
  let θ := 1/2+e
  obtain ⟨B,hB,hτ⟩ := divisorPower he
  obtain ⟨A,hA,hM⟩ := RHConnections.MertensCriterion.natural_mertens_bounds_of_RH hRH e he
  have hz (s : ℝ) : 0 ≤ zsum s := tsum_nonneg fun n => by positivity
  let L := A^2*zsum (2*θ)
  refine ⟨B^2*zsum (1+e)*L^2, by positivity [hz (1+e)], ?_⟩
  intro X hX
  let N := X*X
  let T := B*(N:ℝ)^e
  have ht (l) (hl : l ∈ I N) : (l.divisors.card:ℝ) ≤ T :=
    (hτ _ (mem_Icc.mp hl).1).trans (mul_le_mul_of_nonneg_left
      (Real.rpow_le_rpow (Nat.cast_nonneg _) (by exact_mod_cast (mem_Icc.mp hl).2) he.le) hB)
  have hmass := massBound hA (show 1/2 < θ by dsimp [θ]; linarith)
    (fun n hn => by simpa [mertens_eq_M,θ] using hM n hn) X
  have hpair : ∑ i ∈ pairs X, w X i^2 = (∑ d ∈ I X, a X d^2)^2 := by
    rw [pairs,sum_product,sq, Finset.sum_mul]
    apply sum_congr rfl; intro i _; rw [mul_sum]
    simp [w,mul_pow]
  have hr := schur (pairs X) (w X) (fun i j => K (label i) (label j))
    (fun i j => by unfold K; positivity) (fun i j => by simp [K,Nat.gcd_comm,mul_comm]) _
    (fun i hi => pairRow X _ (label_mem _ hi) ht)
  rw [← phaseGram, hpair] at hr
  have hmass' : ∑ d ∈ I X, a X d^2 ≤ L * (X:ℝ)^(2*θ) := by dsimp [L]; linarith
  have hsum : 0 ≤ ∑ d ∈ I X, a X d^2 := sum_nonneg (fun _ _ => sq_nonneg _)
  calc
    _ ≤ _ := hr
    _ ≤ (T^2*((N:ℝ)^e*zsum (1+e))) * (L*(X:ℝ)^(2*θ))^2 := by
      exact mul_le_mul (mul_le_mul_of_nonneg_left (harm_bound _ he) (sq_nonneg _))
        (pow_le_pow_left₀ hsum hmass' 2) (sq_nonneg _) (by positivity [hz (1+e)])
    _ = _ := by
      have hx : 0<(X:ℝ) := by exact_mod_cast hX
      have hpow (s : ℝ) : ((X:ℝ)^s)^2=(X:ℝ)^(s+s) := by rw [Real.rpow_add hx,sq]
      dsimp only [T,N]
      push_cast
      rw [Real.mul_rpow hx.le hx.le,mul_pow,mul_pow,hpow]
      have hδ' : (2+δ:ℝ) = (e+e)+(e+e)+(e+e)+(2*θ+2*θ) := by dsimp [θ,e]; ring
      simp only [hδ',Real.rpow_add hx]
      ring

theorem RH_of_fourth (h : FourthGrowth) : RiemannHypothesis := by
  apply (coherent_energy_measure_growth_iff_RH (B:=1) (by decide)).mp
  intro ε hε
  obtain ⟨C,hC,hh⟩ := h (2*ε) (by positivity)
  refine ⟨1+C,by positivity,?_⟩
  intro X hX
  have hx : 0<(X:ℝ) := by exact_mod_cast hX
  let t := (X:ℝ)^(1+ε)
  have ht : 0<t := by dsimp [t]; positivity
  have h4 : H X ≤ C*(t*t) := by
    have he : (2+2*ε:ℝ)=(1+ε)+(1+ε) := by ring
    simpa only [he,Real.rpow_add hx,t] using hh X hX
  calc
    _ ≤ t+H X/t := energy_le X ht
    _ ≤ t+C*t := add_le_add_right ((div_le_iff₀ ht).mpr (by linarith)) _
    _ = _ := by dsimp [t]; ring

theorem fourth_moment_growth_iff_RH :
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      (∫ ω, ‖D 1 X ω‖^4 ∂primeTorusMeasure) ≤ C*(X:ℝ)^(2+ε)) ↔ RiemannHypothesis :=
  ⟨RH_of_fourth, fourth_of_RH⟩

#print axioms fourth_moment_growth_iff_RH
end FourthMoment
