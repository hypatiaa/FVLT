import FVLTS4hInfinitePinsV1

/-! Explicit infinite left profiles for alternating drivers.
White INITIAL bits and white OUTPUT coordinates are different parameters.
These examples are not finite-left starts and do not prove or refute LBE.
-/
namespace FVLT.S4hAlternatingZeroV1

open Ruliology.CellularAutomata Rule30Jen Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1 FVLT.S4hInfinitePinsV1

def oddProfile (p : Int) : Bool := decide (p % 2 = 1)
def evenProfile (p : Int) : Bool := decide (p % 2 = 0)

theorem oddProfile_rule (p : Int) :
    rule (oddProfile (p - 1)) (oddProfile p) (oddProfile (p + 1)) = oddProfile p := by
  have hh : p % 2 = 0 ∨ p % 2 = 1 := by omega
  rcases hh with hp | hp
  · have hm : (p - 1) % 2 = 1 := by omega
    have hn : (p + 1) % 2 = 1 := by omega
    simp [oddProfile, hp, hm, hn, rule]
  · have hm : (p - 1) % 2 = 0 := by omega
    have hn : (p + 1) % 2 = 0 := by omega
    simp [oddProfile, hp, hm, hn, rule]

theorem evenProfile_rule (p : Int) :
    rule (evenProfile (p - 1)) (evenProfile p) (evenProfile (p + 1)) = evenProfile p := by
  have hh : p % 2 = 0 ∨ p % 2 = 1 := by omega
  rcases hh with hp | hp
  · have hm : (p - 1) % 2 = 1 := by omega
    have hn : (p + 1) % 2 = 1 := by omega
    simp [evenProfile, hp, hm, hn, rule]
  · have hm : (p - 1) % 2 = 0 := by omega
    have hn : (p + 1) % 2 = 0 := by omega
    simp [evenProfile, hp, hm, hn, rule]

/-- The odd-black profile is stationary on the entire negative half for ANY driver. -/
theorem oddProfile_stationary (c : Nat → Bool) :
    ∀ t : Nat, ∀ p : Int, p < 0 → L c oddProfile t p = oddProfile p := by
  intro t
  induction t with
  | zero => intro p hp; exact L_zero hp
  | succ t ih =>
    intro p hp
    rw [L_succ hp, ih (p - 1) (by omega), ih p hp]
    by_cases hn : p + 1 < 0
    · rw [ih (p + 1) hn]
      exact oddProfile_rule p
    · have he : p = -1 := by omega
      subst p
      rw [show (-1 : Int) + 1 = 0 by omega, L_col0]
      simp [oddProfile, rule]

theorem oddProfile_pins (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) : Pins c oddProfile := by
  intro t ht
  rw [oddProfile_stationary c t (-1) (by omega), hc t, ht]
  rfl

/-- For a white-first alternating driver, the even-black profile has the actual
head c(t), while every cell at or left of -2 stays at its initial value. -/
theorem evenProfile_evolution (c : Nat → Bool) (h0 : c 0 = false)
    (hc : ∀ t, c (t + 1) = !c t) :
    ∀ t : Nat, L c evenProfile t (-1) = c t ∧
      ∀ p : Int, p ≤ -2 → L c evenProfile t p = evenProfile p := by
  intro t
  induction t with
  | zero =>
    refine ⟨?_, fun p hp => L_zero (by omega)⟩
    rw [L_zero (by omega), h0]
    rfl
  | succ t ih =>
    refine ⟨?_, ?_⟩
    · rw [L_succ (by omega)]
      change rule (L c evenProfile t (-2)) (L c evenProfile t (-1))
        (L c evenProfile t 0) = c (t + 1)
      rw [ih.2 (-2) (by omega), ih.1, L_col0, hc t]
      change xor true (c t || c t) = !c t
      cases c t <;> rfl
    · intro p hp
      rw [L_succ (by omega), ih.2 (p - 1) (by omega), ih.2 p hp]
      by_cases hn : p + 1 ≤ -2
      · rw [ih.2 (p + 1) hn]
        exact evenProfile_rule p
      · have he : p = -2 := by omega
        subst p
        rw [show (-2 : Int) + 1 = -1 by omega, ih.1]
        simp [evenProfile, rule]

theorem evenProfile_pins (c : Nat → Bool) (h0 : c 0 = false)
    (hc : ∀ t, c (t + 1) = !c t) : Pins c evenProfile := by
  intro t ht
  rw [(evenProfile_evolution c h0 hc t).1, hc t, ht]
  rfl

theorem oddProfile_not_finiteLeft : ¬ FiniteLeft oddProfile := by
  rintro ⟨W, hW⟩
  let p : Int := -(2 * (W : Int) + 1)
  have hp : p < -(W : Int) := by dsimp [p]; omega
  have hm : p % 2 = 1 := by dsimp [p]; omega
  have hh := hW p hp
  have hb : oddProfile p = true := by simp [oddProfile, hm]
  rw [hb] at hh
  cases hh

theorem evenProfile_not_finiteLeft : ¬ FiniteLeft evenProfile := by
  rintro ⟨W, hW⟩
  let p : Int := -(2 * (W : Int) + 2)
  have hp : p < -(W : Int) := by dsimp [p]; omega
  have hm : p % 2 = 0 := by dsimp [p]; omega
  have hh := hW p hp
  have hb : evenProfile p = true := by simp [evenProfile, hm]
  rw [hb] at hh
  cases hh

theorem alternating_has_infinite_pin_profile (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) :
    ∃ s : Int → Bool, Pins c s ∧ ¬ FiniteLeft s := by
  cases h0 : c 0 with
  | false => exact ⟨evenProfile, evenProfile_pins c h0 hc, evenProfile_not_finiteLeft⟩
  | true => exact ⟨oddProfile, oddProfile_pins c hc, oddProfile_not_finiteLeft⟩

/-- Alternation determines all times from the initial phase and parity. -/
theorem alternating_parity (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) (n : Nat) :
    c n = if n % 2 = 0 then c 0 else !c 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [hc n, ih]
    by_cases hn : n % 2 = 0
    · have hs : (n + 1) % 2 ≠ 0 := by omega
      simp [hn, hs]
    · have hs : (n + 1) % 2 = 0 := by omega
      simp [hn, hs]

theorem bitRow_black_first (c : Nat → Bool) (h0 : c 0 = true)
    (hc : ∀ t, c (t + 1) = !c t) (p : Int) (hp : p < 0) :
    bitRow c p = oddProfile p := by
  let n := (-p - 1).toNat
  have hn : (n : Int) = -p - 1 := by dsimp [n]; omega
  have he := alternating_parity c hc n
  rw [h0] at he
  have hh : p % 2 = 0 ∨ p % 2 = 1 := by omega
  rcases hh with hm | hm
  · have hnm : n % 2 ≠ 0 := by omega
    have hnval : c n = false := by simpa [hnm] using he
    simpa only [bitRow, ite_eq_left hp] using
      (show c n = oddProfile p by rw [hnval]; simp [oddProfile, hm])
  · have hnm : n % 2 = 0 := by omega
    have hnval : c n = true := by simpa [hnm] using he
    simpa only [bitRow, ite_eq_left hp] using
      (show c n = oddProfile p by rw [hnval]; simp [oddProfile, hm])

theorem bitRow_white_first (c : Nat → Bool) (h0 : c 0 = false)
    (hc : ∀ t, c (t + 1) = !c t) (p : Int) (hp : p < 0) :
    bitRow c p = evenProfile p := by
  let n := (-p - 1).toNat
  have hn : (n : Int) = -p - 1 := by dsimp [n]; omega
  have he := alternating_parity c hc n
  rw [h0] at he
  have hh : p % 2 = 0 ∨ p % 2 = 1 := by omega
  rcases hh with hm | hm
  · have hnm : n % 2 ≠ 0 := by omega
    have hnval : c n = true := by simpa [hnm] using he
    simpa only [bitRow, ite_eq_left hp] using
      (show c n = evenProfile p by rw [hnval]; simp [evenProfile, hm])
  · have hnm : n % 2 = 0 := by omega
    have hnval : c n = false := by simpa [hnm] using he
    simpa only [bitRow, ite_eq_left hp] using
      (show c n = evenProfile p by rw [hnval]; simp [evenProfile, hm])

/-- The initial bit at depth n+1 is c(n): white INITIAL bits are zero and black
INITIAL bits are one. This claim is about the Phi addendum's coordinates. -/
theorem alternating_bitRow_pins (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) : Pins c (bitRow c) := by
  intro t ht
  cases h0 : c 0 with
  | false =>
    have hag : ∀ p : Int, -((t + 1 : Nat) : Int) ≤ p → p < 0 →
        bitRow c p = evenProfile p := fun p _ hp => bitRow_white_first c h0 hc p hp
    have hh := light_cone (c := c) (k := t) hag t (Nat.le_refl _)
      (-1) (by omega) (by omega)
    exact hh.trans (evenProfile_pins c h0 hc t ht)
  | true =>
    have hag : ∀ p : Int, -((t + 1 : Nat) : Int) ≤ p → p < 0 →
        bitRow c p = oddProfile p := fun p _ hp => bitRow_black_first c h0 hc p hp
    have hh := light_cone (c := c) (k := t) hag t (Nat.le_refl _)
      (-1) (by omega) (by omega)
    exact hh.trans (oddProfile_pins c hc t ht)

/-- In both alternating phases, white INITIAL zero controls complete to the
initial seed c(n). No statement about zero white OUTPUT controls is intended. -/
theorem alternating_infiniteBits_zero (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) :
    infiniteBits c (fun _ : WhiteInfinite c => false) = c := by
  symm
  apply infiniteBits_unique c (fun _ : WhiteInfinite c => false) c
  · exact alternating_bitRow_pins c hc
  · intro i
    exact i.property

/-- The black INITIAL output is all ones, not an eventually zero tail. -/
theorem alternating_Phi_zero (c : Nat → Bool)
    (hc : ∀ t, c (t + 1) = !c t) :
    Phi c (fun _ : WhiteInfinite c => false) = fun _ : BlackInfinite c => true := by
  funext i
  change infiniteBits c (fun _ : WhiteInfinite c => false) i.val = true
  rw [alternating_infiniteBits_zero c hc]
  exact i.property

end FVLT.S4hAlternatingZeroV1
