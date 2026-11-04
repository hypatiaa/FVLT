import FVLTS4kCoreV1
import Ruliology.CellularAutomata.Rule30ZeroBoundary

/-! PRIVATE S4l Part 1 SOURCE ONLY; not elaborated. The single-black / QP
reduction is credited to R30-20261022-0cac94 and its authors. No novelty,
mortality instance, potential inequality, or Part 2 clearance is claimed.
S4k inclusive Surv and actual Rule30DrivenLeft.L are used unchanged. -/
set_option autoImplicit false

namespace FVLT.S4lZeroBoundaryV1

open Ruliology.CellularAutomata Rule30DrivenLeft Rule30ZeroBoundary
open FVLT.S4kCoreV1
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1

/-- A black boundary entry is always followed by a white entry. -/
def IsolatedBlack (c : Nat → Bool) : Prop :=
  ∀ t : Nat, c t = true → c (t + 1) = false

/-- One black residue per period; Fin P permits every cyclic position. -/
def singleBlack (P : Nat) (b : Fin P) (t : Nat) : Bool :=
  decide (t % P = b.val)

/-- Inclusive horizon K, but zero-driver samples rather than driven pins. -/
def ZeroSamples (c : Nat → Bool) (s : Int → Bool) (K : Nat) : Prop :=
  ∀ t : Nat, t ≤ K → c t = true → L (fun _ => false) s t (-1) = true

/-- The natural depth-zero coordinate is ignored by zrow. -/
def depthRow (s : Int → Bool) (d : Nat) : Bool := s (-(d : Int))

theorem singleBlack_isolated {P : Nat} (hP : 2 ≤ P) (b : Fin P) :
    IsolatedBlack (singleBlack P b) := by
  intro t ht
  have hm : t % P = b.val := by simpa only [singleBlack, decide_eq_true_eq] using ht
  have hn : (t + 1) % P ≠ b.val := by
    rw [Nat.add_mod, hm, Nat.mod_eq_of_lt (by omega : 1 < P)]
    by_cases hb : b.val + 1 < P
    · rw [Nat.mod_eq_of_lt hb]
      omega
    · have he : b.val + 1 = P := by omega
      rw [he, Nat.mod_self]
      omega
  simp [singleBlack, hn]

theorem singleBlack_phase_isolated {P : Nat} (hP : 2 ≤ P)
    (b φ : Fin P) : IsolatedBlack (phase (singleBlack P b) φ) := by
  intro t ht
  have hh : singleBlack P b (t + φ.val) = true := ht
  have hn := singleBlack_isolated hP b (t + φ.val) hh
  change singleBlack P b ((t + 1) + φ.val) = false
  rw [show (t + 1) + φ.val = (t + φ.val) + 1 by omega]
  exact hn

/-- At the wall-adjacent update, either run's black head masks the boundary.
All other negative positions use exactly the same three negative inputs. -/
theorem negative_eq_zero_of_masking (c : Nat → Bool) (s : Int → Bool) (N : Nat)
    (hm : ∀ t : Nat, t < N → c t = true →
      L c s t (-1) = true ∨ L (fun _ => false) s t (-1) = true) :
    ∀ t : Nat, t ≤ N → ∀ p : Int, p < 0 →
      L c s t p = L (fun _ => false) s t p := by
  intro t
  induction t with
  | zero =>
    intro ht p hp
    rw [L_zero hp, L_zero hp]
  | succ t ih =>
    intro ht p hp
    have htn : t < N := by omega
    have hi := ih (by omega : t ≤ N)
    rw [L_succ hp, L_succ hp, hi (p - 1) (by omega), hi p hp]
    by_cases hb : p + 1 = 0
    · have he : p = -1 := by omega
      subst p
      rw [show (-1 : Int) + 1 = 0 by omega, L_col0, L_col0]
      by_cases hc : c t = true
      · have hz : L (fun _ => false) s t (-1) = true := by
          rcases hm t htn hc with hleft | hright
          · rw [← hi (-1) (by omega)]
            exact hleft
          · exact hright
        rw [hz, hc]
        rfl
      · have hw : c t = false := by
          cases h : c t with
          | false => rfl
          | true => exact False.elim (hc h)
        rw [hw]
    · rw [hi (p + 1) (by omega)]

theorem surv_eq_zero (c : Nat → Bool) (s : Int → Bool) (K : Nat)
    (hc : IsolatedBlack c) (hs : Surv c s K) :
    ∀ t : Nat, t ≤ K + 1 → ∀ p : Int, p < 0 →
      L c s t p = L (fun _ => false) s t p := by
  apply negative_eq_zero_of_masking c s (K + 1)
  intro t ht hb
  left
  have hp := hs t (by omega) hb
  simpa only [hc t hb, Bool.not_false] using hp

theorem zeroSamples_eq_zero (c : Nat → Bool) (s : Int → Bool) (K : Nat)
    (hs : ZeroSamples c s K) :
    ∀ t : Nat, t ≤ K + 1 → ∀ p : Int, p < 0 →
      L c s t p = L (fun _ => false) s t p := by
  apply negative_eq_zero_of_masking c s (K + 1)
  intro t ht hb
  exact Or.inr (hs t (by omega) hb)

theorem surv_iff_zeroSamples (c : Nat → Bool) (s : Int → Bool) (K : Nat)
    (hc : IsolatedBlack c) : Surv c s K ↔ ZeroSamples c s K := by
  constructor
  · intro hs t ht hb
    rw [← surv_eq_zero c s K hc hs t (by omega) (-1) (by omega)]
    have hp := hs t ht hb
    simpa only [hc t hb, Bool.not_false] using hp
  · intro hs t ht hb
    rw [zeroSamples_eq_zero c s K hs t (by omega) (-1) (by omega), hs t ht hb, hc t hb]
    rfl

theorem all_surv_iff_zeroSamples (c : Nat → Bool) (s : Int → Bool)
    (hc : IsolatedBlack c) :
    (∀ K : Nat, Surv c s K) ↔
      ∀ t : Nat, c t = true → L (fun _ => false) s t (-1) = true := by
  constructor
  · intro hs t ht
    exact (surv_iff_zeroSamples c s t hc).mp (hs t) t (Nat.le_refl t) ht
  · intro hs K
    exact (surv_iff_zeroSamples c s K hc).mpr (fun t ht hb => hs t hb)

theorem all_surv_eq_zero (c : Nat → Bool) (s : Int → Bool)
    (hc : IsolatedBlack c) (hs : ∀ K : Nat, Surv c s K) :
    ∀ t : Nat, ∀ p : Int, p < 0 → L c s t p = L (fun _ => false) s t p := by
  intro t p hp
  exact surv_eq_zero c s t hc (hs t) t (by omega) p hp

/-- All negative depths, not merely the sampled wall-adjacent column. -/
theorem surv_eq_zrow (c : Nat → Bool) (s : Int → Bool) (K : Nat)
    (hc : IsolatedBlack c) (hs : Surv c s K) :
    ∀ t : Nat, t ≤ K + 1 → ∀ d : Nat, 1 ≤ d →
      L c s t (-(d : Int)) = zrow (depthRow s) t d := by
  intro t ht d hd
  rw [surv_eq_zero c s K hc hs t ht (-(d : Int)) (by omega)]
  exact L_eq_zrow s t d hd

/-- Every phase is explicit: sample exactly those t with (t+φ)%P=b. -/
theorem singleBlack_phase_surv_iff (P : Nat) (hP : 2 ≤ P)
    (b φ : Fin P) (s : Int → Bool) (K : Nat) :
    Surv (phase (singleBlack P b) φ) s K ↔
      ∀ t : Nat, t ≤ K → (t + φ.val) % P = b.val →
        zrow (depthRow s) t 1 = true := by
  rw [surv_iff_zeroSamples _ _ _ (singleBlack_phase_isolated hP b φ)]
  constructor
  · intro hs t ht hm
    have hb : phase (singleBlack P b) φ t = true := by simp [phase, singleBlack, hm]
    have hh := hs t ht hb
    have he := L_eq_zrow s t 1 (Nat.le_refl 1)
    change L (fun _ => false) s t (-1) = zrow (depthRow s) t 1 at he
    rw [he] at hh
    exact hh
  · intro hs t ht hb
    have hm : (t + φ.val) % P = b.val := by
      simpa only [phase, singleBlack, decide_eq_true_eq] using hb
    have he := L_eq_zrow s t 1 (Nat.le_refl 1)
    change L (fun _ => false) s t (-1) = zrow (depthRow s) t 1 at he
    rw [he]
    exact hs t ht hm

theorem singleBlack_phase_all_surv_iff (P : Nat) (hP : 2 ≤ P)
    (b φ : Fin P) (s : Int → Bool) :
    (∀ K : Nat, Surv (phase (singleBlack P b) φ) s K) ↔
      ∀ t : Nat, (t + φ.val) % P = b.val → zrow (depthRow s) t 1 = true := by
  constructor
  · intro hs t hm
    exact (singleBlack_phase_surv_iff P hP b φ s t).mp (hs t) t (Nat.le_refl t) hm
  · intro hs K
    exact (singleBlack_phase_surv_iff P hP b φ s K).mpr (fun t ht hm => hs t hm)

end FVLT.S4lZeroBoundaryV1
