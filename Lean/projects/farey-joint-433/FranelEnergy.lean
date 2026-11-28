import FranelGrids
import FranelRank
import FranelBernoulli
import FranelPair
import FranelDiagonal

noncomputable section
namespace Ratioque.Franel
open RHConnections

/-- The exact Franel identity, in the coherent-energy normalization of spec F1. -/
theorem franelEnergy_eq_coherent_energy {N : ℕ} (hN : 1 ≤ N) :
    franelEnergy N =
      CoherentEnergyBounds.energy (ArithmeticFourierInversion.S 1) 1 N / 12 := by
  have geom := rank_energy_pair (fareySet N) (farey_nonempty hN)
    (fun x hx => ⟨(farey_mem_iff.mp hx).1, (farey_mem_iff.mp hx).2.1⟩)
    (farey_first_moment hN)
  calc
    franelEnergy N = (∑ x ∈ fareySet N, ∑ y ∈ fareySet N, bTwo (x-y))/2 := geom
    _ = _ := (weighted_pair_gcd (fareySet N) (Finset.Icc 1 N)
      (fun i => ArithmeticFourierInversion.M (N/i))
      (farey_grid_disintegration hN)
      (fun _ hi _ hj => bTwo_grid_pair (Finset.mem_Icc.mp hi).1 (Finset.mem_Icc.mp hj).1)).trans
      (congrArg (· / (12 : ℝ)) (gcd_form_eq_energy N))

/-- F2: Franel's criterion. The Farey energy grows like `N^(1+δ)` for every `δ > 0` iff RH. -/
theorem franel_growth_iff_RH :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ N : ℕ, 1 ≤ N → franelEnergy N ≤ C * (N : ℝ) ^ (1 + δ)) ↔
      RiemannHypothesis := by
  rw [← ArithmeticFourierInversion.coherent_energy_growth_iff_RH 1]
  constructor
  · intro h δ hδ
    obtain ⟨C, hC, hb⟩ := h δ hδ
    refine ⟨12 * C, by positivity, fun X hX => ?_⟩
    have := hb X hX
    rw [franelEnergy_eq_coherent_energy hX] at this
    linarith
  · intro h δ hδ
    obtain ⟨C, hC, hb⟩ := h δ hδ
    refine ⟨C / 12, by positivity, fun N hN => ?_⟩
    rw [franelEnergy_eq_coherent_energy hN]
    have := hb N hN
    have h12 : (0 : ℝ) < 12 := by norm_num
    rw [div_mul_eq_mul_div]
    exact div_le_div_of_nonneg_right this h12.le

end Ratioque.Franel

#print axioms Ratioque.Franel.franelEnergy_eq_coherent_energy
#print axioms Ratioque.Franel.franel_growth_iff_RH
