import Ruliology.CellularAutomata.Rule30DrivenLeft
import Ruliology.CellularAutomata.Rule30Realization
import Mathlib.Data.Fintype.Card

/-! Actual driven-left screening, black-phase pins, and finite prefix coordinates.
The black pin requires an actual consistent center, not an arbitrary prescribed driver.
The finite prefix bijection repackages the pinned kit's light cone and permutivity.
-/

namespace FVLT.S4gLeftScreenV1

open Ruliology.CellularAutomata
open Rule30Jen Rule30Realization Rule30DrivenLeft

theorem left_screen (x s : Int → Bool) (c : Nat → Bool)
    (hseed : ∀ p, p < 0 → s p = x p)
    (hc : ∀ t, c t = evol x t 0) :
    ∀ t : Nat, ∀ p : Int, p ≤ 0 → L c s t p = evol x t p := by
  intro t
  induction t with
  | zero =>
    intro p hp
    by_cases hn : p < 0
    · rw [L_zero hn]
      exact hseed p hn
    · have hz : p = 0 := by omega
      subst p
      exact (L_col0 0).trans (hc 0)
  | succ t ih =>
    intro p hp
    by_cases hn : p < 0
    · rw [L_succ hn, ih (p - 1) (by omega), ih p hp, ih (p + 1) (by omega)]
      rfl
    · have hz : p = 0 := by omega
      subst p
      exact (L_col0 (t + 1)).trans (hc (t + 1))

theorem right_independence (x y : Int → Bool)
    (hleft : ∀ p, p < 0 → x p = y p)
    (hcenter : ∀ t, evol x t 0 = evol y t 0) :
    ∀ t : Nat, ∀ p : Int, p ≤ 0 → evol x t p = evol y t p := by
  intro t p hp
  have hx := left_screen x x (fun t => evol x t 0) (fun _ _ => rfl)
    (fun _ => rfl) t p hp
  have hy := left_screen y x (fun t => evol x t 0) hleft hcenter t p hp
  exact hx.symm.trans hy

theorem actual_black_pin (x s : Int → Bool) (c : Nat → Bool)
    (hseed : ∀ p, p < 0 → s p = x p)
    (hc : ∀ t, c t = evol x t 0) (t : Nat) (hblack : c t = true) :
    L c s t (-1) = !c (t + 1) := by
  have he := left_screen x s c hseed hc t (-1) (by omega)
  have hb : evol x t 0 = true := (hc t).symm.trans hblack
  have hn : c (t + 1) = rule (evol x t (-1)) true (evol x t 1) := by
    rw [hc (t + 1)]
    change rule (evol x t (0 - 1)) (evol x t 0) (evol x t (0 + 1)) = _
    rw [hb]
    rfl
  rw [he, hn]
  cases evol x t (-1) <;> cases evol x t 1 <;> rfl

def seedRow {W : Nat} (v : Fin W → Bool) (p : Int) : Bool :=
  if _hp : p < 0 then
    if hk : (-p - 1).toNat < W then v ⟨(-p - 1).toNat, hk⟩ else false
  else false

def prefixTrace (c : Nat → Bool) (W : Nat) (v : Fin W → Bool) : Fin W → Bool :=
  fun t => L c (seedRow v) t.val (-1)

theorem seedRow_read {W : Nat} (v : Fin W → Bool) {p : Int} (hp : p < 0)
    (hk : (-p - 1).toNat < W) : seedRow v p = v ⟨(-p - 1).toNat, hk⟩ := by
  simp only [seedRow, dite_eq_left hp, dite_eq_left hk]

theorem seedRow_at {W : Nat} (v : Fin W → Bool) (k : Fin W) :
    seedRow v (-((k.val + 1 : Nat) : Int)) = v k := by
  have hp : -((k.val + 1 : Nat) : Int) < 0 := by omega
  have hi : (-(-((k.val + 1 : Nat) : Int)) - 1).toNat = k.val := by omega
  have hk : (-(-((k.val + 1 : Nat) : Int)) - 1).toNat < W := by
    rw [hi]
    exact k.isLt
  rw [seedRow_read v hp hk]
  congr 1
  apply Fin.ext
  exact hi

theorem head_equal_iff_next_seed (c : Nat → Bool) {s s' : Int → Bool} (k : Nat)
    (hag : ∀ p : Int, -(k : Int) ≤ p → p < 0 → s p = s' p) :
    (L c s k (-1) = L c s' k (-1)) ↔
      s (-((k + 1 : Nat) : Int)) = s' (-((k + 1 : Nat) : Int)) := by
  constructor
  · intro ht
    apply Classical.byContradiction
    intro hne
    have hd : s (-((k + 1 : Nat) : Int)) = !s' (-((k + 1 : Nat) : Int)) := by
      have flip : ∀ a b : Bool, a ≠ b → a = !b := by decide
      exact flip _ _ hne
    have hf := permutive (c := c) hag hd
    rw [ht] at hf
    have not_self : ∀ a : Bool, a ≠ !a := by decide
    exact not_self _ hf
  · intro hd
    apply light_cone (c := c) (k := k) ?_ k (Nat.le_refl k) (-1)
      (by omega) (by omega)
    intro p hp hn
    by_cases he : p = -((k + 1 : Nat) : Int)
    · rw [he]
      exact hd
    · exact hag p (by omega) hn

def truncateSeed (s : Int → Bool) (k : Nat) (p : Int) : Bool :=
  if -(k : Int) ≤ p ∧ p < 0 then s p else false

/-- The next deepest bit enters with XOR coefficient one. -/
theorem head_triangular_xor (c : Nat → Bool) (s : Int → Bool) (k : Nat) :
    L c s k (-1) = xor (s (-((k + 1 : Nat) : Int)))
      (L c (truncateSeed s k) k (-1)) := by
  have hag : ∀ p : Int, -(k : Int) ≤ p → p < 0 → s p = truncateSeed s k p := by
    intro p hp hn
    simp [truncateSeed, hp, hn]
  have hz : truncateSeed s k (-((k + 1 : Nat) : Int)) = false := by
    simp only [truncateSeed]
    rw [ite_eq_right (by omega)]
  cases hb : s (-((k + 1 : Nat) : Int)) with
  | false =>
    have hd : s (-((k + 1 : Nat) : Int)) = truncateSeed s k (-((k + 1 : Nat) : Int)) :=
      hb.trans hz.symm
    have he := (head_equal_iff_next_seed c k hag).mpr hd
    rw [he]
    cases L c (truncateSeed s k) k (-1) <;> rfl
  | true =>
    have hd : s (-((k + 1 : Nat) : Int)) = !truncateSeed s k (-((k + 1 : Nat) : Int)) := by
      rw [hb, hz]
      rfl
    have hf := permutive (c := c) hag hd
    rw [hf]
    cases L c (truncateSeed s k) k (-1) <;> rfl

/-- Given the earlier seed prefix, any specified head bit forces exactly this
next deepest bit. The residual is computed with that new bit set to zero. -/
theorem head_pin_iff_seed_forced (c : Nat → Bool) (s : Int → Bool) (k : Nat) (b : Bool) :
    (L c s k (-1) = b) ↔
      s (-((k + 1 : Nat) : Int)) = xor b (L c (truncateSeed s k) k (-1)) := by
  rw [head_triangular_xor]
  cases s (-((k + 1 : Nat) : Int)) <;>
    cases L c (truncateSeed s k) k (-1) <;> cases b <;> decide

theorem black_pin_iff_seed_forced (c : Nat → Bool) (s : Int → Bool) (k : Nat)
    (_hblack : c k = true) :
    (L c s k (-1) = !c (k + 1)) ↔
      s (-((k + 1 : Nat) : Int)) =
        xor (!c (k + 1)) (L c (truncateSeed s k) k (-1)) :=
  head_pin_iff_seed_forced c s k (!c (k + 1))

theorem prefixTrace_surjective (c : Nat → Bool) (W : Nat) :
    Function.Surjective (prefixTrace c W) := by
  intro b
  let bn : Nat → Bool := fun k => if hk : k < W then b ⟨k, hk⟩ else false
  obtain ⟨s, _, hpre⟩ := exists_prefix (c := c) bn W
  let v : Fin W → Bool := fun i => s (-((i.val + 1 : Nat) : Int))
  refine ⟨v, ?_⟩
  funext t
  have hag : ∀ p : Int, -((t.val + 1 : Nat) : Int) ≤ p → p < 0 → seedRow v p = s p := by
    intro p hp hn
    have hk : (-p - 1).toNat < W := by have ht := t.isLt; omega
    rw [seedRow_read v hn hk]
    change s (-((((-p - 1).toNat) + 1 : Nat) : Int)) = s p
    congr 1
    omega
  have he := light_cone (c := c) (k := t.val) hag t.val (Nat.le_refl _)
    (-1) (by omega) (by omega)
  change L c (seedRow v) t.val (-1) = b t
  calc
    _ = L c s t.val (-1) := he
    _ = b t := by simpa [bn, t.isLt] using hpre t.val t.isLt

theorem prefixTrace_injective (c : Nat → Bool) (W : Nat) :
    Function.Injective (prefixTrace c W) := by
  intro v u htrace
  have key : ∀ k : Nat, k ≤ W → ∀ i : Fin W, i.val < k → v i = u i := by
    intro k
    induction k with
    | zero => intro _ i hi; omega
    | succ k ih =>
      intro hk i hi
      by_cases hik : i.val < k
      · exact ih (by omega) i hik
      have hik' : i.val = k := by omega
      have hag : ∀ p : Int, -(k : Int) ≤ p → p < 0 → seedRow v p = seedRow u p := by
        intro p hp hn
        have hj : (-p - 1).toNat < k := by omega
        have hjW : (-p - 1).toNat < W := by omega
        rw [seedRow_read v hn hjW, seedRow_read u hn hjW]
        exact ih (by omega) ⟨(-p - 1).toNat, hjW⟩ hj
      have ht := congrFun htrace (⟨k, by omega⟩ : Fin W)
      change L c (seedRow v) k (-1) = L c (seedRow u) k (-1) at ht
      have hb := (head_equal_iff_next_seed c k hag).mp ht
      have hpos : -((k + 1 : Nat) : Int) = -((i.val + 1 : Nat) : Int) := by rw [hik']
      rw [hpos, seedRow_at, seedRow_at] at hb
      exact hb
  funext i
  exact key W (Nat.le_refl W) i i.isLt

theorem prefixTrace_bijective (c : Nat → Bool) (W : Nat) :
    Function.Bijective (prefixTrace c W) :=
  ⟨prefixTrace_injective c W, prefixTrace_surjective c W⟩

end FVLT.S4gLeftScreenV1
