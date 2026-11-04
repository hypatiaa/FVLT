import FVLTS4nShellTransportV1
import FVLTConductorProjectorsV1

/-! Descriptive signal transport. Historical projectors remain external to v9.
Complex blocks are not claims about a complex bilinear energy being a norm. -/
namespace FVLT.S4nHarmonicTransportV1
open WovenCanonicalV1 S4nShellTransportV1
open Ruliology.CellularAutomata.FVLTPeriodProjectorsV1
open Ruliology.CellularAutomata.FVLTConductorProjectorsV1
open scoped BigOperators

local instance windowDecidable (L : ℕ) (i : ℤ) : Decidable (InWindow L i) :=
  inferInstanceAs (Decidable (lower L ≤ i ∧ i ≤ upper L))

def sampleIndex (L : ℕ) (i : ℤ) : ℕ := (i % (L : ℤ)).toNat
def J {K : Type} [Field K] (L M : ℕ) (x : ℕ → K) (n : ℕ) : K :=
  let j := rep M (n : ℤ)
  if InWindow L j then x (sampleIndex L j) else 0
def block {K : Type} [Field K] (L M q r : ℕ) (x : ℕ → K) : ℕ → K :=
  P M r (J L M (P L q x))

theorem sampleIndex_lt (L : ℕ) (hL : 0<L) (i : ℤ) : sampleIndex L i<L := by
  have hz : 0 ≤ i % (L : ℤ) := Int.emod_nonneg _ (by exact_mod_cast Nat.ne_of_gt hL)
  have hl := Int.emod_lt_of_pos i (show 0<(L : ℤ) by exact_mod_cast hL)
  unfold sampleIndex
  omega

theorem J_add {K : Type} [Field K] (L M : ℕ) (x y : ℕ → K) :
    J L M (fun n => x n+y n) = fun n => J L M x n+J L M y n := by
  funext n
  by_cases h : InWindow L (rep M (n : ℤ)) <;> simp [J,h]

theorem J_mul {K : Type} [Field K] (L M : ℕ) (a : K) (x : ℕ → K) :
    J L M (fun n => a*x n) = fun n => a*J L M x n := by
  funext n
  by_cases h : InWindow L (rep M (n : ℤ)) <;> simp [J,h]

theorem project_sum {K : Type} [Field K] (N q : ℕ) (s : Finset ℕ)
    (x : ℕ → ℕ → K) (k : ℕ) :
    P N q (fun n => ∑ j ∈ s, x j n) k = ∑ j ∈ s, P N q (x j) k := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [P,Q]
  | @insert a s ha ih =>
    simp only [Finset.sum_insert ha]
    rw [P_add,ih]

theorem J_reconstruct {K : Type} [Field K] (L M : ℕ) (hL : 0<L)
    (x : ℕ → K) (n : ℕ) :
    ∑ q ∈ L.divisors, J L M (P L q x) n = J L M x n := by
  by_cases h : InWindow L (rep M (n : ℤ))
  · simp only [J,h,ite_true]
    exact sum_P_divisors_eq_self_on_range hL x (sampleIndex_lt L hL _)
  · simp [J,h]

theorem blocks_reconstruct {K : Type} [Field K] (L M r : ℕ) (hL : 0<L)
    (x : ℕ → K) (k : ℕ) :
    ∑ q ∈ L.divisors, block L M q r x k = P M r (J L M x) k := by
  unfold block
  rw [←project_sum]
  congr 1
  funext n
  exact J_reconstruct L M hL x n

theorem rep_sampleIndex (L : ℕ) (hL : 0<L) (i : ℤ) :
    rep L (sampleIndex L i : ℤ)=rep L i := by
  apply (rep_eq_iff_mod L hL _ _).mpr
  have hz : 0 ≤ i % (L : ℤ) := Int.emod_nonneg _ (by exact_mod_cast Nat.ne_of_gt hL)
  have hc : (sampleIndex L i : ℤ)=i%(L : ℤ) := Int.toNat_of_nonneg hz
  rw [hc,Int.emod_emod]

theorem J_step_samples (L M : ℕ) (hL : 0<L) (x : ℤ → Bool) (n : ℕ) :
    J L M (fun k => bit (step L x (k : ℤ))) n =
      realCompare L M (fun i => bit (step L x i)) (n : ℤ) := by
  by_cases h : InWindow L (rep M (n : ℤ))
  · simp only [J,realCompare,h,ite_true,step,periodize]
    rw [rep_sampleIndex L hL]
  · simp [J,realCompare,h]

/-- Full projected signal identity; no energy transfer or nonlinear commutation. -/
theorem projected_transport (L Lnext M Mnext r k : ℕ) (hn : 0<Lnext)
    (x : ℤ → Bool) :
    P Mnext r (fun n => bit (step Mnext (compare L M x) (n : ℤ))) k =
      P Mnext r (J Lnext Mnext (fun n => bit (step Lnext x (n : ℤ)))) k +
      P Mnext r (fun n => defect L Lnext M Mnext x (n : ℤ)) k := by
  have he : (fun n : ℕ => bit (step Mnext (compare L M x) (n : ℤ))) =
      fun n => J Lnext Mnext (fun m => bit (step Lnext x (m : ℤ))) n +
        defect L Lnext M Mnext x (n : ℤ) := by
    funext n
    rw [J_step_samples Lnext Mnext hn]
    exact transport_with_defect L Lnext M Mnext hn x (n : ℤ)
  rw [he,P_add]

theorem projected_halo_defect_zero (L Lnext M Mnext t r k : ℕ)
    (hL : 0<L) (hn : 0<Lnext) (hM : 0<M) (hmn : 0<Mnext)
    (hcL : 2*t+1≤L) (hcM : 2*t+1≤M) (hcNext : 2*(t+1)+1≤Lnext)
    (hgL : Lnext/2+t+1<L) (hgM : Mnext/2+t+1<M)
    (f : ℤ → Bool) (hs : Supported t f) :
    P Mnext r (fun n => defect L Lnext M Mnext (periodize L f) (n : ℤ)) k=0 := by
  have he : (fun n : ℕ => defect L Lnext M Mnext (periodize L f) (n : ℤ)) =
      fun _ => (0 : ℝ) := by
    funext n
    exact halo_defect_zero L Lnext M Mnext t hL hn hM hmn hcL hcM hcNext hgL hgM f hs _
  rw [he]
  simp [P,Q]

end FVLT.S4nHarmonicTransportV1
