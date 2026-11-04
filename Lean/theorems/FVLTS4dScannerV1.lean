import FVLTS4dSpanReductionV1
import Mathlib.Tactic.ByContra

/-! Additive S4d: a right-white inverse and its four-state finite-tail test.
The scanner reads from right to left. No exclusion of eventually periodic
columns is asserted here. -/

namespace FVLT.S4dScannerV1

open Ruliology.CellularAutomata
open Rule30Jen Rule30Realization Rule30PeriodTwoSideways

def transition (c : Bool) (s : Bool × Bool) : Bool × Bool :=
  (xor c (s.1 || s.2), s.1)

def scan (c : Nat → Bool) (n : Nat) : Bool × Bool :=
  Nat.rec (false, false) (fun k s => transition (c k) s) n

theorem scan_zero (c : Nat → Bool) : scan c 0 = (false, false) := rfl

theorem scan_succ (c : Nat → Bool) (n : Nat) :
    scan c (n + 1) = transition (c n) (scan c n) := rfl

theorem zero_step_stable : transition false (false, false) = (false, false) := rfl

theorem zero_step_nonzero (s : Bool × Bool) (hs : s ≠ (false, false)) :
    transition false (transition false s) = (true, true) := by
  rcases s with ⟨a,b⟩
  cases a <;> cases b <;> simp_all [transition]

theorem scan_zero_tail {c : Nat → Bool} {L : Nat}
    (hc : ∀ n, L ≤ n → c n = false) (hL : scan c L = (false, false)) :
    ∀ j, scan c (L + j) = (false, false) := by
  intro j
  induction j with
  | zero => simpa using hL
  | succ j ih =>
    rw [show L + (j + 1) = (L + j) + 1 by omega, scan_succ, hc _ (by omega), ih]
    rfl

theorem scan_nonzero_tail {c : Nat → Bool} {L : Nat}
    (hc : ∀ n, L ≤ n → c n = false) (hL : scan c L ≠ (false, false)) :
    ∀ j, scan c (L + 2 + j) = (true, true) := by
  have h2 : scan c (L + 2) = (true, true) := by
    rw [show L + 2 = (L + 1) + 1 by omega, scan_succ, scan_succ,
      hc (L + 1) (by omega), hc L (by omega)]
    exact zero_step_nonzero _ hL
  intro j
  induction j with
  | zero => simpa using h2
  | succ j ih =>
    rw [show L + 2 + (j + 1) = (L + 2 + j) + 1 by omega,
      scan_succ, hc _ (by omega), ih]
    rfl

def input (y : Int → Bool) (hi : Int) (n : Nat) : Bool := y (hi - n)

/-- The unique inverse with a white right tail, anchored just above `hi`. -/
def rightWhiteInverse (y : Int → Bool) (hi : Int) (p : Int) : Bool :=
  if p ≤ hi then (scan (input y hi) (hi - p).toNat).1 else false

theorem inverse_at (y : Int → Bool) (hi : Int) (n : Nat) :
    rightWhiteInverse y hi (hi - n) = (scan (input y hi) n).1 := by
  have h : (hi - (hi - (n : Int))).toNat = n := by omega
  unfold rightWhiteInverse
  rw [ite_eq_left (show hi - (n : Int) ≤ hi by omega), h]

theorem inverse_pair (y : Int → Bool) (hi : Int) (n : Nat) :
    (rightWhiteInverse y hi (hi - n), rightWhiteInverse y hi (hi - n + 1)) =
      scan (input y hi) n := by
  cases n with
  | zero =>
    rw [scan_zero]
    apply Prod.ext
    · change rightWhiteInverse y hi (hi - (0 : Nat)) = false
      rw [inverse_at]
      rfl
    · change rightWhiteInverse y hi (hi - (0 : Nat) + 1) = false
      unfold rightWhiteInverse
      rw [ite_eq_right (by omega)]
  | succ n =>
    have hp : hi - ((n + 1 : Nat) : Int) + 1 = hi - (n : Int) := by omega
    rw [hp]
    simp only [inverse_at, scan_succ, transition]

theorem inverse_step (y : Int → Bool) (hi : Int)
    (hy : ∀ p, hi < p → y p = false) :
    (fun p => evol (rightWhiteInverse y hi) 1 p) = y := by
  funext p
  by_cases hp : p ≤ hi
  · let n := (hi - p).toNat
    have hn : p = hi - (n : Int) := by dsimp [n]; omega
    have hn1 : p - 1 = hi - ((n + 1 : Nat) : Int) := by omega
    have hs := inverse_pair y hi n
    have hsa := congrArg Prod.fst hs
    have hsb := congrArg Prod.snd hs
    change rightWhiteInverse y hi (hi - n) = (scan (input y hi) n).1 at hsa
    change rightWhiteInverse y hi (hi - n + 1) = (scan (input y hi) n).2 at hsb
    change xor (rightWhiteInverse y hi (p - 1))
      (rightWhiteInverse y hi p || rightWhiteInverse y hi (p + 1)) = y p
    rw [hn1, inverse_at, scan_succ]
    rw [← hn] at hsa hsb
    rw [hsa, hsb]
    rw [hn]
    change xor (xor (y (hi - n))
      ((scan (input y hi) n).1 || (scan (input y hi) n).2))
      ((scan (input y hi) n).1 || (scan (input y hi) n).2) = y (hi - n)
    cases y (hi - n) <;>
      cases ((scan (input y hi) n).1 || (scan (input y hi) n).2) <;> rfl
  · have h1 : rightWhiteInverse y hi p = false := by simp [rightWhiteInverse, hp]
    have h2 : rightWhiteInverse y hi (p + 1) = false := by
      simp [rightWhiteInverse, show ¬p + 1 ≤ hi by omega]
    by_cases he : p - 1 ≤ hi
    · have heq : p - 1 = hi := by omega
      have h0 : rightWhiteInverse y hi (p - 1) = false := by
        rw [heq]
        have hz := inverse_at y hi 0
        rw [show hi - (0 : Nat) = hi by omega] at hz
        exact hz
      change xor (rightWhiteInverse y hi (p - 1))
        (rightWhiteInverse y hi p || rightWhiteInverse y hi (p + 1)) = y p
      rw [h0, h1, h2, hy p (by omega)]; rfl
    · have h0 : rightWhiteInverse y hi (p - 1) = false := by
        simp [rightWhiteInverse, he]
      change xor (rightWhiteInverse y hi (p - 1))
        (rightWhiteInverse y hi p || rightWhiteInverse y hi (p + 1)) = y p
      rw [h0, h1, h2, hy p (by omega)]; rfl

theorem inverse_unique {y z : Int → Bool} {hi : Int}
    (hz : ∀ p, hi ≤ p → z p = false)
    (hstep : (fun p => evol z 1 p) = y) :
    z = rightWhiteInverse y hi := by
  have hs : ∀ n : Nat, (z (hi - n), z (hi - n + 1)) = scan (input y hi) n := by
    intro n
    induction n with
    | zero =>
      rw [scan_zero]
      apply Prod.ext
      · exact hz _ (by omega)
      · exact hz _ (by omega)
    | succ n ih =>
      have ha := congrArg Prod.fst ih
      have hb := congrArg Prod.snd ih
      change z (hi - n) = (scan (input y hi) n).1 at ha
      change z (hi - n + 1) = (scan (input y hi) n).2 at hb
      have hlocal := congrFun hstep (hi - n)
      change xor (z (hi - n - 1)) (z (hi - n) || z (hi - n + 1)) =
        y (hi - n) at hlocal
      have hinv : z (hi - n - 1) =
          xor (y (hi - n)) (z (hi - n) || z (hi - n + 1)) := by
        rw [← hlocal]
        cases z (hi - n - 1) <;> cases (z (hi - n) || z (hi - n + 1)) <;> rfl
      rw [scan_succ]
      change (_, _) = (_, _)
      apply Prod.ext
      · change z (hi - ((n + 1 : Nat) : Int)) =
          xor (y (hi - n)) ((scan (input y hi) n).1 || (scan (input y hi) n).2)
        rw [show hi - ((n + 1 : Nat) : Int) = hi - n - 1 by omega, hinv, ha, hb]
      · change z (hi - ((n + 1 : Nat) : Int) + 1) = (scan (input y hi) n).1
        rw [show hi - ((n + 1 : Nat) : Int) + 1 = hi - (n : Int) by omega]
        exact ha
  funext p
  by_cases hp : p ≤ hi
  · let n := (hi - p).toNat
    have hn : p = hi - (n : Int) := by dsimp [n]; omega
    rw [hn, inverse_at]
    exact congrArg Prod.fst (hs n)
  · rw [hz p (by omega)]
    simp [rightWhiteInverse, hp]

def length (lo hi : Int) : Nat := (hi - lo + 1).toNat

/-- Any preimage with an eventually white right tail is already white at and
above the output's right bound. No assumption on its left tail is used. -/
theorem right_white_anchor {y z : Int → Bool} {hi : Int}
    (hy : ∀ p, hi < p → y p = false)
    (hstep : (fun p => evol z 1 p) = y)
    (hz : ∃ B : Int, ∀ p, B < p → z p = false) :
    ∀ p, hi ≤ p → z p = false := by
  obtain ⟨B, hB⟩ := hz
  let M : Int := B + 1
  have hMB : B < M := by dsimp [M]; omega
  have hs : ∀ n : Nat, hi ≤ M - n →
      z (M - n) = false ∧ z (M - n + 1) = false := by
    intro n
    induction n with
    | zero =>
      intro _
      exact ⟨hB _ (by omega), hB _ (by omega)⟩
    | succ n ih =>
      intro hn
      obtain ⟨ha,hb⟩ := ih (by omega)
      have he := congrFun hstep (M - n)
      change xor (z (M - n - 1)) (z (M - n) || z (M - n + 1)) =
        y (M - n) at he
      rw [ha, hb, hy _ (by omega)] at he
      have hc : z (M - n - 1) = false := by simpa using he
      refine ⟨?_, ?_⟩
      · rw [show M - ((n + 1 : Nat) : Int) = M - n - 1 by omega]
        exact hc
      · rw [show M - ((n + 1 : Nat) : Int) + 1 = M - (n : Int) by omega]
        exact ha
  intro p hp
  by_cases hpM : p ≤ M
  · have hn : M - ((M - p).toNat : Int) = p := by omega
    have hh := (hs (M - p).toNat (by omega)).1
    rwa [hn] at hh
  · exact hB p (by omega)

theorem inverse_unique_right_tail {y z : Int → Bool} {hi : Int}
    (hy : ∀ p, hi < p → y p = false)
    (hstep : (fun p => evol z 1 p) = y)
    (hz : ∃ B : Int, ∀ p, B < p → z p = false) :
    z = rightWhiteInverse y hi :=
  inverse_unique (right_white_anchor hy hstep hz) hstep

theorem input_tail {y : Int → Bool} {lo hi : Int} (hle : lo ≤ hi)
    (hy : ∀ p, p < lo → y p = false) :
    ∀ n, length lo hi ≤ n → input y hi n = false := by
  intro n hn
  apply hy
  dsimp [length] at hn
  omega

theorem inverse_finite_of_terminal {y : Int → Bool} {lo hi : Int}
    (hle : lo ≤ hi) (hy : ∀ p, p < lo → y p = false)
    (ht : scan (input y hi) (length lo hi) = (false, false)) :
    FinConfig (rightWhiteInverse y hi) := by
  let W := hi.natAbs + (length lo hi) + 1
  refine ⟨W, fun p hp => ?_⟩
  by_cases hphi : p ≤ hi
  · let n := (hi - p).toNat
    have hn : length lo hi ≤ n := by dsimp [W, n] at *; omega
    have hpEq : p = hi - (n : Int) := by dsimp [n]; omega
    rw [hpEq, inverse_at]
    have hh := scan_zero_tail (input_tail hle hy) ht (n - length lo hi)
    rw [show length lo hi + (n - length lo hi) = n by omega] at hh
    rw [hh]
  · simp [rightWhiteInverse, hphi]

/-- Every rejected terminal state yields an all-black left tail in the right-white inverse. -/
theorem inverse_infinite_left_tail {y : Int → Bool} {lo hi : Int}
    (hle : lo ≤ hi) (hy : ∀ p, p < lo → y p = false)
    (ht : scan (input y hi) (length lo hi) ≠ (false, false)) :
    ∀ j : Nat, rightWhiteInverse y hi (hi - (length lo hi + 2 + j : Nat)) = true := by
  intro j
  rw [inverse_at, scan_nonzero_tail (input_tail hle hy) ht j]

theorem rejected_preimage_left_tail {y z : Int → Bool} {lo hi : Int}
    (hle : lo ≤ hi) (hleft : ∀ p, p < lo → y p = false)
    (hright : ∀ p, hi < p → y p = false)
    (ht : scan (input y hi) (length lo hi) ≠ (false, false))
    (hstep : (fun p => evol z 1 p) = y)
    (hz : ∃ B : Int, ∀ p, B < p → z p = false) :
    ∀ j : Nat, z (hi - (length lo hi + 2 + j : Nat)) = true := by
  rw [inverse_unique_right_tail hright hstep hz]
  exact inverse_infinite_left_tail hle hleft ht

theorem terminal_of_inverse_finite {y : Int → Bool} {lo hi : Int}
    (hle : lo ≤ hi) (hy : ∀ p, p < lo → y p = false)
    (hfin : FinConfig (rightWhiteInverse y hi)) :
    scan (input y hi) (length lo hi) = (false, false) := by
  by_contra ht
  obtain ⟨W, hW⟩ := hfin
  have hh := inverse_infinite_left_tail hle hy ht (W + hi.natAbs + 1)
  rw [hW _ (by omega)] at hh
  contradiction

/-- Precise full-line criterion for nonempty, endpoint-trimmed output words.
The anchor is the actual rightmost black cell; the observed spatial origin is
not translated. -/
theorem finite_predecessor_iff_terminal
    {y : Int → Bool} {lo hi : Int}
    (_hlo : y lo = true) (hhi : y hi = true)
    (hleft : ∀ p, p < lo → y p = false)
    (hright : ∀ p, hi < p → y p = false) :
    (∃ z : Int → Bool, FinConfig z ∧ (fun p => evol z 1 p) = y) ↔
      scan (input y hi) (length lo hi) = (false, false) := by
  have hle : lo ≤ hi := by
    by_contra h
    rw [hleft hi (by omega)] at hhi
    contradiction
  constructor
  · rintro ⟨z, hz, hstep⟩
    have hne : ∃ p, z p = true := by
      by_contra hn
      have hall : ∀ p, z p = false := by
        intro p
        cases hc : z p
        · rfl
        · exact False.elim (hn ⟨p, hc⟩)
      have hh := congrFun hstep hi
      change xor (z (hi - 1)) (z hi || z (hi + 1)) = y hi at hh
      rw [hall, hall, hall, hhi] at hh
      contradiction
    obtain ⟨r, hr, hrzero⟩ := FVLT.S4dSpanReductionV1.exists_rightmost hz hne
    have hbound : r + 1 ≤ hi := by
      have hedge := (Rule30ZeroBoundaryBarriers.right_edge hr hrzero 1).1
      have heq : y (r + 1) = true := by
        rw [← hstep]
        simpa using hedge
      by_contra hn
      rw [hright _ (by omega)] at heq
      contradiction
    have hzright : ∀ p, hi ≤ p → z p = false := by
      intro p hp
      exact hrzero p (by omega)
    have heq := inverse_unique hzright hstep
    apply terminal_of_inverse_finite hle hleft
    rwa [← heq]
  · intro ht
    exact ⟨rightWhiteInverse y hi, inverse_finite_of_terminal hle hleft ht,
      inverse_step y hi hright⟩

/-- The scanner's rejected words are precisely the finite-predecessor-free
seeds used by the separate CQ01 reduction. -/
theorem no_finite_predecessor_iff_rejected
    {y : Int → Bool} {lo hi : Int}
    (hlo : y lo = true) (hhi : y hi = true)
    (hleft : ∀ p, p < lo → y p = false)
    (hright : ∀ p, hi < p → y p = false) :
    FVLT.S4dSpanReductionV1.NoFinitePredecessor y ↔
      scan (input y hi) (length lo hi) ≠ (false, false) := by
  exact not_congr (finite_predecessor_iff_terminal hlo hhi hleft hright)

end FVLT.S4dScannerV1
