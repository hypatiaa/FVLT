import FVLTConductorProjectorsV1
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-! Real sum-scale conductor readout for arbitrary Boolean ring rows.
No reachability, center-period exclusion or uniqueness-of-readout claim. -/
noncomputable section
namespace FVLT.S4nPrimeReadoutV1
open Ruliology.CellularAutomata.FVLTPeriodProjectorsV1
open Ruliology.CellularAutomata.FVLTConductorProjectorsV1
open scoped BigOperators

def spin (b : ℕ → Bool) (j : ℕ) : ℝ := if b j then 1 else -1
def blackCount (p : ℕ) (b : ℕ → Bool) : ℕ :=
  ∑ j ∈ Finset.range p, if b j then 1 else 0
def mean (p : ℕ) (b : ℕ → Bool) : ℝ := (2*(blackCount p b : ℝ)-(p : ℝ))/(p : ℝ)
def swapped (h : ℕ) (b : ℕ → Bool) (j : ℕ) : Bool := b ((Equiv.swap 0 h) j)

theorem spin_square (b : ℕ → Bool) (j : ℕ) : spin b j*spin b j=1 := by
  cases h : b j <;> norm_num [spin,h]

theorem spin_sum (p : ℕ) (b : ℕ → Bool) :
    ∑ j ∈ Finset.range p, spin b j = 2*(blackCount p b : ℝ)-(p : ℝ) := by
  have ht : ∀ j, spin b j=2*(if b j then (1 : ℝ) else 0)-1 := by
    intro j
    cases h : b j <;> norm_num [spin,h]
  simp_rw [ht]
  rw [Finset.sum_sub_distrib,←Finset.mul_sum]
  simp [blackCount]

theorem project_one (p : ℕ) (hp : 0<p) (b : ℕ → Bool) (k : ℕ) :
    P p 1 (spin b) k=mean p b := by
  rw [P_one_eq_Q_one,Q_one_eq_mean hp,spin_sum]
  simp [mean,div_eq_mul_inv,mul_comm]

theorem project_prime (p : ℕ) (hp : Nat.Prime p) (b : ℕ → Bool)
    (k : ℕ) (hk : k<p) : P p p (spin b) k=spin b k-mean p b := by
  have h := sum_P_divisors_eq_self_on_range hp.pos (spin b) hk
  rw [hp.divisors] at h
  have he : P p 1 (spin b) k+P p p (spin b) k=spin b k := by
    simpa [hp.ne_one,Ne.symm hp.ne_one] using h
  rw [project_one p hp.pos b k] at he
  linarith

theorem energy_one (p : ℕ) (hp : 0<p) (b : ℕ → Bool) :
    E_full p 1 (spin b)=(2*(blackCount p b : ℝ)-(p : ℝ))^2/(p : ℝ) := by
  have hn : (p : ℝ)≠0 := by exact_mod_cast Nat.ne_of_gt hp
  simp only [E_full,sumInner,project_one p hp]
  simp only [Finset.sum_const,Finset.card_range,nsmul_eq_mul]
  unfold mean
  field_simp

theorem energy_prime (p : ℕ) (hp : Nat.Prime p) (b : ℕ → Bool) :
    E_full p p (spin b)=4*(blackCount p b : ℝ)*((p : ℝ)-(blackCount p b : ℝ))/(p : ℝ) := by
  have h := sum_E_full_eq_norm_sq hp.pos (spin b)
  rw [hp.divisors] at h
  have he : E_full p 1 (spin b)+E_full p p (spin b)=(p : ℝ) := by
    simpa [hp.ne_one,Ne.symm hp.ne_one,spin_square] using h
  rw [energy_one p hp.pos b] at he
  have hn : (p : ℝ)≠0 := by exact_mod_cast hp.ne_zero
  field_simp at he ⊢
  nlinarith

theorem mean_energy_one (p : ℕ) (hp : 0<p) (b : ℕ → Bool) :
    E_full p 1 (spin b)/(p : ℝ)=
      (2*(blackCount p b : ℝ)-(p : ℝ))^2/(p : ℝ)^2 := by
  simp only [energy_one p hp,div_div,pow_two]

theorem mean_energy_prime (p : ℕ) (hp : Nat.Prime p) (b : ℕ → Bool) :
    E_full p p (spin b)/(p : ℝ)=
      4*(blackCount p b : ℝ)*((p : ℝ)-(blackCount p b : ℝ))/(p : ℝ)^2 := by
  rw [energy_prime p hp,div_div,pow_two]

theorem swap_lt (p h j : ℕ) (hp : 0<p) (hh : h<p) (hj : j<p) :
    (Equiv.swap 0 h) j<p := by
  by_cases h0 : j=0
  · subst j
    simpa using hh
  · by_cases he : j=h
    · subst j
      simpa using hp
    · simpa [Equiv.swap_apply_def,h0,he] using hj

theorem blackCount_swap (p h : ℕ) (hp : 0<p) (hh : h<p) (b : ℕ → Bool) :
    blackCount p (swapped h b)=blackCount p b := by
  unfold blackCount swapped
  refine Finset.sum_bij (fun j _ => (Equiv.swap 0 h) j) ?_ ?_ ?_ ?_
  · intro j hj
    exact Finset.mem_range.mpr (swap_lt p h j hp hh (Finset.mem_range.mp hj))
  · intro a ha c hc he
    exact (Equiv.swap 0 h).injective he
  · intro j hj
    refine ⟨(Equiv.swap 0 h) j, Finset.mem_range.mpr
      (swap_lt p h j hp hh (Finset.mem_range.mp hj)), ?_⟩
    simp
  · intro j hj
    rfl

theorem swap_energies (p h : ℕ) (hp : Nat.Prime p) (hh : h<p) (b : ℕ → Bool) :
    E_full p 1 (spin (swapped h b))=E_full p 1 (spin b) ∧
    E_full p p (spin (swapped h b))=E_full p p (spin b) := by
  rw [energy_one p hp.pos,energy_one p hp.pos,energy_prime p hp,energy_prime p hp,
    blackCount_swap p h hp.pos hh b]
  exact ⟨rfl,rfl⟩

theorem swap_center_projection_ne (p h : ℕ) (hp : Nat.Prime p) (hh : h<p)
    (b : ℕ → Bool) (hopp : b h≠b 0) :
    P p p (spin (swapped h b)) 0≠P p p (spin b) 0 := by
  rw [project_prime p hp (swapped h b) 0 hp.pos,project_prime p hp b 0 hp.pos]
  have hm : mean p (swapped h b)=mean p b := by
    simp only [mean,blackCount_swap p h hp.pos hh b]
  rw [hm]
  have hs : spin (swapped h b) 0=spin b h := by simp [spin,swapped]
  rw [hs]
  intro he
  have heq : spin b h=spin b 0 := by linarith
  have hne : spin b h≠spin b 0 := by
    cases hb : b h <;> cases hz : b 0
    · exact False.elim (hopp (by simp only [hb,hz]))
    · norm_num [spin,hb,hz]
    · norm_num [spin,hb,hz]
    · exact False.elim (hopp (by simp only [hb,hz]))
  exact hne heq

theorem center_reconstruct (p : ℕ) (hp : Nat.Prime p) (b : ℕ → Bool) :
    P p 1 (spin b) 0+P p p (spin b) 0=spin b 0 := by
  rw [project_one p hp.pos,project_prime p hp b 0 hp.pos]
  ring

theorem constant_project_one (p : ℕ) (hp : 0<p) (v : Bool) (k : ℕ) :
    P p 1 (spin (fun _ => v)) k=(if v then (1 : ℝ) else -1) := by
  rw [P_one_eq_Q_one,Q_one_eq_mean hp]
  have hn : (p : ℝ)≠0 := by exact_mod_cast Nat.ne_of_gt hp
  cases v <;> simp [spin,hn]

theorem constant_project_prime_zero (p : ℕ) (hp : Nat.Prime p) (v : Bool)
    (k : ℕ) (hk : k<p) : P p p (spin (fun _ => v)) k=0 := by
  rw [project_prime p hp (fun _ => v) k hk]
  have hm := project_one p hp.pos (fun _ => v) k
  rw [constant_project_one p hp.pos v k] at hm
  rw [←hm]
  simp [spin]

theorem uniform_dc_distinguishes (p : ℕ) (hp : 0<p) :
    P p 1 (spin (fun _ => true)) 0≠P p 1 (spin (fun _ => false)) 0 := by
  rw [constant_project_one p hp true 0,constant_project_one p hp false 0]
  norm_num

end FVLT.S4nPrimeReadoutV1
