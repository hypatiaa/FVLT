import FVLTRule30GateTrapWords33CertV1
import Mathlib.Tactic

namespace FVLT.Rule30GateTrapWordsV1
open Ruliology.CellularAutomata
open Rule30GateTrap Rule30StripCertificates Certificate

private def word3553 : List Bool :=
  [true, false, false, true, false, false, false, false,
    true, false, false, false, false, true, false, false, true]

private def word33 : List Bool :=
  [true, false, false, true, false, false, true]

private def observations33 (n : Nat) : List (Option Bool) :=
  List.replicate n none ++ word33.map some

private theorem mem_mask_true (ws : List (List Bool)) (w : List Bool)
    (hw : w ∈ ws) : inM (mask ws) w = true := by
  induction ws with
  | nil => simp at hw
  | cons v vs ih =>
    change (mask (v :: vs)).testBit (encList w) = true
    simp only [mask, Nat.testBit_or, Bool.or_eq_true]
    rcases List.mem_cons.1 hw with h | h
    · subst w
      left
      rw [Nat.testBit_two_pow]
      simp
    · exact Or.inr (ih h)

private theorem any_successor_true (m : Nat) (w : List Bool) (a b : Bool)
    (h : inM m (step2 w a b) = true) : anySuccessor m w = true := by
  cases a <;> cases b <;> simp [anySuccessor, h]

private theorem trap_at (R : Nat → Bool) (t0 s : Nat)
    (hodd : t0 % 2 = 1) (hentry : win R t0 ∈ trap)
    (hs : t0 ≤ 2 * s + 1) : win R (2 * s + 1) ∈ trap := by
  have he : t0 + 2 * ((2 * s + 1 - t0) / 2) = 2 * s + 1 := by omega
  rw [← he]
  exact win_mem_trap R hodd hentry _

private theorem trace_retained (R : Nat → Bool) (t0 : Nat)
    (hodd : t0 % 2 = 1) (hentry : win R t0 ∈ trap)
    (obs : List (Option Bool)) (L : Nat → List Nat) (s : Nat)
    (hs : t0 ≤ 2 * s + 1) (hEnd : L obs.length = trapCodes)
    (hchecks : ∀ i : Nat, i < obs.length →
      layerCheck (obs.getD i none) (L i) (L (i + 1)) = true)
    (hobs : ∀ i : Nat, i < obs.length →
      slotMatches (obs.getD i none) (Rule30PeriodTwoSideways.u R (s + i)) = true) :
    inM (codeMask (L 0)) (win R (2 * s + 1)) = true := by
  induction obs generalizing L s with
  | nil =>
    have he : L 0 = trapCodes := hEnd
    rw [he]
    exact mem_mask_true trap _ (trap_at R t0 s hodd hentry hs)
  | cons o obs ih =>
    have htail : ∀ i : Nat, i < obs.length →
        slotMatches (obs.getD i none) (Rule30PeriodTwoSideways.u R (s + 1 + i)) = true := by
      intro i hi
      have h := hobs (i + 1) (by simpa using Nat.succ_lt_succ hi)
      rw [show s + (i + 1) = s + 1 + i by omega] at h
      simpa only [List.getD_cons_succ] using h
    have htailChecks : ∀ i : Nat, i < obs.length →
        layerCheck (obs.getD i none) (L (i + 1)) (L (i + 1 + 1)) = true := by
      intro i hi
      simpa only [List.getD_cons_succ] using
        hchecks (i + 1) (by simpa using Nat.succ_lt_succ hi)
    have hn := ih (fun i => L (i + 1)) (s + 1) (by omega) hEnd htailChecks htail
    obtain ⟨a, b, he⟩ := win_step2 R (2 * s + 1) (by omega)
    change inM (codeMask (L 1)) (win R (2 * (s + 1) + 1)) = true at hn
    rw [show 2 * (s + 1) + 1 = (2 * s + 1) + 2 by omega, he] at hn
    have hany := any_successor_true _ _ a b hn
    have hh := hobs 0 (by simp)
    rw [Nat.add_zero, u_eq_head] at hh
    have hslot : slotMatches o ((win R (2 * s + 1)).headD false) = true := by
      simpa only [List.getD_cons_zero] using hh
    have hall : trap.all (fun w =>
        !slotMatches o (w.headD false) || !anySuccessor (codeMask (L 1)) w ||
          inM (codeMask (L 0)) w) = true :=
      hchecks 0 (by simp)
    have hp := List.all_eq_true.1 hall _ (trap_at R t0 s hodd hentry hs)
    change (!slotMatches o ((win R (2 * s + 1)).headD false) ||
      !anySuccessor (codeMask (L 1)) (win R (2 * s + 1)) ||
        inM (codeMask (L 0)) (win R (2 * s + 1))) = true at hp
    rw [hslot, hany] at hp
    simpa using hp

private theorem checks3553 (i : Nat) (hi : i < (word3553.map some).length) :
    layerCheck ((word3553.map some).getD i none) (layers3553.getD i trapCodes)
      (layers3553.getD (i + 1) trapCodes) = true := by
  have hi' : i < 17 := by simpa [word3553, observations33, word33] using hi
  interval_cases i
  · exact check3553_00
  · exact check3553_01
  · exact check3553_02
  · exact check3553_03
  · exact check3553_04
  · exact check3553_05
  · exact check3553_06
  · exact check3553_07
  · exact check3553_08
  · exact check3553_09
  · exact check3553_10
  · exact check3553_11
  · exact check3553_12
  · exact check3553_13
  · exact check3553_14
  · exact check3553_15
  · exact check3553_16

private theorem checks33 (i : Nat) (hi : i < (observations33 6).length) :
    layerCheck ((observations33 6).getD i none) (layers33.getD i trapCodes)
      (layers33.getD (i + 1) trapCodes) = true := by
  have hi' : i < 13 := by simpa [word3553, observations33, word33] using hi
  interval_cases i
  · exact check33_00
  · exact check33_01
  · exact check33_02
  · exact check33_03
  · exact check33_04
  · exact check33_05
  · exact check33_06
  · exact check33_07
  · exact check33_08
  · exact check33_09
  · exact check33_10
  · exact check33_11
  · exact check33_12

theorem no_gap_word_3553_after_entry
    (R : Nat → Bool) (t0 s : Nat)
    (hodd : t0 % 2 = 1)
    (hentry : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap)
    (hstart : t0 ≤ 2 * s + 1) :
    ¬ (∀ i : Fin 17,
      Rule30PeriodTwoSideways.u R (s + i.val) =
        ([true, false, false, true, false, false, false, false,
          true, false, false, false, false, true, false, false, true]
          : List Bool).getD i.val false) := by
  intro hword
  have hw := trace_retained R t0 hodd hentry (word3553.map some) (fun i => layers3553.getD i trapCodes) s hstart
    (by rfl) checks3553 (by
    intro i hi
    have hi' : i < 17 := by simpa [word3553] using hi
    have hbit := hword ⟨i, hi'⟩
    interval_cases i <;> simpa [word3553, slotMatches] using hbit)
  change inM (codeMask []) _ = true at hw
  simp [codeMask, mask, inM, Nat.zero_testBit] at hw

theorem no_gap_word_33_after_six_double_steps
    (R : Nat → Bool) (t0 s : Nat)
    (hodd : t0 % 2 = 1)
    (hentry : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap)
    (hstart : t0 + 12 ≤ 2 * s + 1) :
    ¬ (Rule30PeriodTwoSideways.u R s = true ∧
       Rule30PeriodTwoSideways.u R (s + 3) = true ∧
       Rule30PeriodTwoSideways.u R (s + 6) = true) := by
  rintro ⟨hb0, hb3, hb6⟩
  obtain ⟨h1, h2⟩ : Rule30PeriodTwoSideways.u R (s + 1) = false ∧
      Rule30PeriodTwoSideways.u R (s + 2) = false := by
    rcases gaps_of_entry R hodd hentry s (by omega) hb0 with h | h
    · exact ⟨h.1, h.2.1⟩
    · simp [hb3] at h
  obtain ⟨h4, h5⟩ : Rule30PeriodTwoSideways.u R (s + 4) = false ∧
      Rule30PeriodTwoSideways.u R (s + 5) = false := by
    have hb : Rule30PeriodTwoSideways.u R (s + 3 + 3) = true := by
      rw [show s + 3 + 3 = s + 6 by omega, hb6]
    rcases gaps_of_entry R hodd hentry (s + 3) (by omega) hb3 with h | h
    · simpa only [Nat.add_assoc] using And.intro h.1 h.2.1
    · simp [hb] at h
  have hw := trace_retained R t0 hodd hentry (observations33 6) (fun i => layers33.getD i trapCodes) (s - 6)
    (by omega) (by rfl) checks33 (by
    intro i hi
    have hi' : i < 13 := by simpa [observations33, word33] using hi
    by_cases hp : i < 6
    · interval_cases i <;> simp [observations33, word33, slotMatches]
    · have hlo : 6 ≤ i := by omega
      rw [show s - 6 + i = s + (i - 6) by omega]
      interval_cases i <;>
        simp [observations33, word33, slotMatches, hb0, h1, h2, hb3, h4, h5, hb6])
  change inM (codeMask []) _ = true at hw
  simp [codeMask, mask, inM, Nat.zero_testBit] at hw

end FVLT.Rule30GateTrapWordsV1
