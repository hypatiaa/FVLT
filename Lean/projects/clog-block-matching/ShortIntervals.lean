import OffsetMatching
namespace AtlasLog
open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

def residues : Finset ℕ := {1,5,7,11}
def apSum (r t h : ℕ) : ℝ :=
  ∑ n ∈ Ioc t (t+h), if n%12=r then (μ n:ℝ) else 0

private theorem signed_expansion (tw : Bool) (t h : ℕ) :
    (blockSum tw t h:ℝ) = apSum 1 t h + apSum 5 t h +
      (if tw then -(apSum 7 t h) else apSum 7 t h) +
      (if tw then -(apSum 11 t h) else apSum 11 t h) := by
  have cop (n : ℕ) : n.Coprime 6 ↔ (n%12).Coprime 6 := by
    simp only [Nat.coprime_iff_gcd_eq_one]
    rw [Nat.gcd_comm n 6,Nat.gcd_comm (n%12) 6,Nat.gcd_rec 6 n,Nat.gcd_rec 6 (n%12),Nat.mod_mod_of_dvd _ (by decide : 6 ∣ 12)]
  have four (n : ℕ) : n%4=(n%12)%4 := (Nat.mod_mod_of_dvd _ (by decide : 4∣12)).symm
  cases tw <;> unfold blockSum apSum <;> push_cast <;>
    simp only [ite_true,←sum_neg_distrib,←sum_add_distrib] <;>
    apply sum_congr rfl <;> intro n _ <;> unfold bandWeight <;> simp only [cop n, four n] <;>
    generalize eq : n%12 = r at * <;> have hr : r<12 := eq ▸ Nat.mod_lt _ (by decide) <;>
    interval_cases r <;> norm_num

theorem block_from_progressions (K : ℝ) (t h : ℕ)
    (H : ∀ r ∈ residues, |apSum r t h| ≤ K) : blockCost t h ≤ 4*K := by
  have a := H 1 (by decide); have b := H 5 (by decide)
  have c := H 7 (by decide); have d := H 11 (by decide)
  unfold blockCost; apply max_le <;> rw [signed_expansion] <;>
    simp only [Bool.false_eq_true,ite_false,ite_true] <;> rw [abs_le] <;>
    rw [abs_le] at a b c d <;> constructor <;> linarith

private theorem block_trivial (t h : ℕ) : blockCost t h ≤ h := by
  have unit (tw : Bool) (n : ℕ) : |(bandWeight tw n:ℝ)| ≤ 1 := by
    unfold bandWeight; split_ifs <;> rcases moebius_eq_or n with z|z|z <;> norm_num [z]
  apply max_le <;> unfold blockSum <;> push_cast <;>
    apply (abs_sum_le_sum_abs ..).trans <;>
    exact (sum_le_sum (fun n (_ : n ∈ Ioc t (t+h)) => unit _ n)).trans_eq (by simp)

def badStarts (X h : ℕ) (k : ℝ) := (starts X h).filter fun t => ∃ r ∈ residues, k < |apSum r t h|

/-- Exact analytic input. One finite bad set covers all four progressions. -/
def AP12Exceptional : Prop := ∃ K : ℝ, 0 < K ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀,
    ((badStarts X X.sqrt (K*X.sqrt/Real.log X)).card:ℝ) ≤ K*X/Real.log X

theorem signed_bad_subset (tw : Bool) (X h : ℕ) (k : ℝ) :
    (starts X h).filter (fun t => 4*k < |(blockSum tw t h:ℝ)|) ⊆ badStarts X h k := by
  intro t ht; obtain ⟨hs,large⟩ := mem_filter.mp ht
  apply mem_filter.mpr; refine ⟨hs,?_⟩
  by_contra! small
  have bound := block_from_progressions k t h small
  cases tw <;> unfold blockCost at bound <;> grind

theorem matching_from_exception (X h : ℕ) (hh : 0<h) (room : X/2+h ≤ X)
    (k : ℝ) (hk : 0 ≤ k) :
    Fits (Ioc (X/2) X) h (2*h + 4*k*X/h + ((badStarts X h k).card:ℝ)) := by
  have hcard : ((starts X h).card:ℝ) ≤ X := by
    unfold starts; rw [Nat.card_Icc]; exact_mod_cast (show X-h+1-X/2 ≤ X by omega)
  have point (t : ℕ) (ht : t ∈ starts X h) :
      blockCost t h ≤ 4*k + if t ∈ badStarts X h k then (h:ℝ) else 0 := by
    split_ifs with H
    · linarith [block_trivial t h]
    · have small : ∀ r ∈ residues, |apSum r t h| ≤ k := by
        intro r hr; by_contra! hg; exact H (mem_filter.mpr ⟨ht,r,hr,hg⟩)
      simpa using block_from_progressions k t h small
  have ss := sum_le_sum point
  have ff : (starts X h).filter (· ∈ badStarts X h k) = badStarts X h k := by ext; simp [badStarts]
  rw [sum_add_distrib,←sum_filter,ff] at ss; simp only [sum_const,nsmul_eq_mul] at ss
  apply fits_mono (averaged_block_matching X h hh room)
  have hp : (0:ℝ)<h := by exact_mod_cast hh
  have v := mul_le_mul_of_nonneg_right hcard (show 0 ≤ 4*k by positivity)
  have lhs : (∑ t ∈ starts X h, blockCost t h)/h ≤ 4*k*X/h+(badStarts X h k).card := by
    rw [div_le_iff₀ hp]; field_simp; nlinarith
  linarith

/-- The analytic specialization gives one actual simultaneous matching for every
large cutoff, with a single logarithm saved. -/
theorem actual_matching_log (analytic : AP12Exceptional) :
    ∃ C : ℝ, 0<C ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀,
      Fits (Ioc (X/2) X) X.sqrt (C*X/Real.log X) := by
  obtain ⟨K,hK,X₀,H⟩ := analytic
  refine ⟨4+5*K,by positivity,max X₀ 16,?_⟩
  intro X hX
  have hx0 := (le_max_left X₀ 16).trans hX
  have hx := (le_max_right X₀ 16).trans hX
  have s2 := Nat.sqrt_le X
  have hs : 0<X.sqrt := Nat.sqrt_pos.mpr (by omega)
  have room : X/2+X.sqrt ≤ X := by
    have : 2 ≤ X.sqrt := Nat.le_sqrt.mpr (by omega)
    nlinarith [Nat.div_mul_le_self X 2]
  have xp : (1:ℝ)<X := by exact_mod_cast (show 1<X by omega)
  have L := Real.log_pos xp
  have sp : (0:ℝ)<X.sqrt := by exact_mod_cast hs
  have sqrtLe : (X.sqrt:ℝ) ≤ Real.sqrt X := (Real.le_sqrt (by positivity) (by positivity)).mpr (by rw [sq]; exact_mod_cast s2)
  have logLe : Real.log X ≤ 2*Real.sqrt X := by
    have h := Real.log_le_sub_one_of_pos (Real.sqrt_pos.mpr (by linarith : (0:ℝ)<X))
    rw [Real.log_sqrt (by positivity)] at h; linarith
  have edge : (X.sqrt:ℝ)*Real.log X ≤ 2*X := by
    have h := mul_le_mul sqrtLe logLe L.le (Real.sqrt_nonneg _)
    nlinarith [Real.sq_sqrt (show 0 ≤ (X:ℝ) by positivity)]
  apply fits_mono (matching_from_exception X _ hs room (K*X.sqrt/Real.log X) (by positivity))
  have he := H X hx0
  calc _ ≤ 2*X.sqrt + 4*(K*X.sqrt/Real.log X)*X/X.sqrt + K*X/Real.log X := by linarith
       _ ≤ _ := by field_simp; nlinarith [mul_le_mul_of_nonneg_right edge sp.le]

end
end AtlasLog
