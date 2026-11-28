import S4h
import S4h_G_CantorShiftV1

/-!
# STUDY ORDER S4i-G UNIFORM-IN-P (`#1118`, `#1125`, `#1129`, `#1136`):
# Universal Top-Row OR-Latch Erasure Theorems, All-Period Shift Monotonicity,
# and Phase-`01` Sideways Pair Latch Specialization
-/

namespace FVLT.S4iUniformLatchV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1
open FVLT.S4hCantorShiftV1

/-! ## Section 1: Universal Top-Row Sideways Step for Any Driver `c` -/

theorem s_neg_two_of_c0_false (c : Nat -> Bool) (s : Int -> Bool) (hc0 : c 0 = false) :
    s (-2) = xor (L c s 1 (-1)) (s (-1)) := by
  have h := L_left (c := c) (s := s) 0 (p := -1) (by omega)
  have h1 : (-1 : Int) - 1 = -2 := by omega
  have h2 : (-1 : Int) + 1 = 0 := by omega
  rw [h1, h2, L_zero (by omega), L_zero (by omega), L_col0, hc0] at h
  simpa using h

theorem s_neg_succ_step (c : Nat -> Bool) (s : Int -> Bool) (k : Nat) :
    s (-((k + 3 : Nat) : Int)) =
      xor (L c s 1 (-((k + 2 : Nat) : Int)))
        (s (-((k + 2 : Nat) : Int)) || s (-((k + 1 : Nat) : Int))) := by
  have hp : (-((k + 2 : Nat) : Int)) < 0 := by omega
  have h := L_left (c := c) (s := s) 0 (p := -((k + 2 : Nat) : Int)) hp
  have h1 : (-((k + 2 : Nat) : Int)) - 1 = -((k + 3 : Nat) : Int) := by omega
  have h2 : (-((k + 2 : Nat) : Int)) + 1 = -((k + 1 : Nat) : Int) := by omega
  rw [h1, h2, L_zero (by omega), L_zero hp, L_zero (by omega)] at h
  exact h

/-- Two seeds that agree at two consecutive negative positions `-(a+1)` and `-(a+2)` and have
identical `t = 1` rows from `-(a+2)` leftward agree at all deeper negative positions `-(a + m + 1)`. -/
theorem topRow_agree_from (c : Nat -> Bool) (s0 s1 : Int -> Bool) (a : Nat)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (ha1 : s0 (-((a + 1 : Nat) : Int)) = s1 (-((a + 1 : Nat) : Int)))
    (ha2 : s0 (-((a + 2 : Nat) : Int)) = s1 (-((a + 2 : Nat) : Int))) :
    forall m : Nat,
      s0 (-((a + m + 1 : Nat) : Int)) = s1 (-((a + m + 1 : Nat) : Int)) /\
      s0 (-((a + m + 2 : Nat) : Int)) = s1 (-((a + m + 2 : Nat) : Int)) := by
  intro m
  induction m with
  | zero =>
    exact ⟨ha1, ha2⟩
  | succ m ih =>
    refine ⟨ih.2, ?_⟩
    have hpos3 : a + (m + 1) + 2 = (a + m) + 3 := by omega
    rw [hpos3, s_neg_succ_step c s0 (a + m), s_neg_succ_step c s1 (a + m)]
    have hY_step := hY (a + m + 1)
    have hpos2 : a + m + 1 + 1 = a + m + 2 := by omega
    rw [hpos2] at hY_step
    rw [hY_step, ih.2, ih.1]

/-! ## Section 2: Theorem U1a — Universal 2-Cell Top-Row OR-Latch (`m >= 3`) -/

theorem topRow_latch_s3_true (c : Nat -> Bool) (s : Int -> Bool)
    (hc0 : c 0 = false)
    (hY1 : L c s 1 (-1) = true)
    (hY2 : L c s 1 (-2) = false) :
    s (-3) = true := by
  have hs2 := s_neg_two_of_c0_false c s hc0
  rw [hY1] at hs2
  have hs3 := s_neg_succ_step c s 0
  change s (-3) = xor (L c s 1 (-2)) (s (-2) || s (-1)) at hs3
  rw [hs3, hY2, hs2]
  cases s (-1) <;> rfl

theorem topRow_latch_s4_eq (c : Nat -> Bool) (s : Int -> Bool)
    (hc0 : c 0 = false)
    (hY1 : L c s 1 (-1) = true)
    (hY2 : L c s 1 (-2) = false) :
    s (-4) = !(L c s 1 (-3)) := by
  have hs3 := topRow_latch_s3_true c s hc0 hY1 hY2
  have hs4 := s_neg_succ_step c s 1
  change s (-4) = xor (L c s 1 (-3)) (s (-3) || s (-2)) at hs4
  rw [hs4, hs3]
  cases L c s 1 (-3) <;> cases s (-2) <;> rfl

/-- **Theorem U1a (Universal 2-Cell Top-Row OR-Latch Erasure):**
For EVERY driver `c : Nat -> Bool` with `c 0 = false`, if two seeds `s0, s1` have the same
`t = 1` row on `p < 0` and satisfy `L c s0 1 (-1) = true` and `L c s0 1 (-2) = false`,
then `s0` and `s1` agree at every depth `-(m + 3)` (`m >= 0`), regardless of `s0 (-1)` and `s1 (-1)`. -/
theorem topRow_or_latch_depth3 (c : Nat -> Bool) (s0 s1 : Int -> Bool)
    (hc0 : c 0 = false)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (hY1 : L c s0 1 (-1) = true)
    (hY2 : L c s0 1 (-2) = false) :
    forall m : Nat, s0 (-((m + 3 : Nat) : Int)) = s1 (-((m + 3 : Nat) : Int)) := by
  have hY1' : L c s1 1 (-1) = true := (hY 0).symm.trans hY1
  have hY2' : L c s1 1 (-2) = false := (hY 1).symm.trans hY2
  have hs3_0 := topRow_latch_s3_true c s0 hc0 hY1 hY2
  have hs3_1 := topRow_latch_s3_true c s1 hc0 hY1' hY2'
  have hs4_0 := topRow_latch_s4_eq c s0 hc0 hY1 hY2
  have hs4_1 := topRow_latch_s4_eq c s1 hc0 hY1' hY2'
  have ha1 : s0 (-3) = s1 (-3) := hs3_0.trans hs3_1.symm
  have ha2 : s0 (-4) = s1 (-4) := by
    rw [hs4_0, hs4_1]
    exact congrArg Bool.not (hY 2)
  intro m
  have h := (topRow_agree_from c s0 s1 2 hY ha1 ha2 m).1
  have hpos : 2 + m + 1 = m + 3 := by omega
  rw [hpos] at h
  exact h

/-! ## Section 3: Theorem U1b — Universal 3-Cell Black-Run OR-Latch (`m >= 4`) -/

theorem topRow_blackRun_s4_true (c : Nat -> Bool) (s : Int -> Bool)
    (hc0 : c 0 = false)
    (hY1 : L c s 1 (-1) = false)
    (hY2 : L c s 1 (-2) = true)
    (hY3 : L c s 1 (-3) = false) :
    s (-4) = true := by
  have hs2 := s_neg_two_of_c0_false c s hc0
  rw [hY1] at hs2
  have hs3 := s_neg_succ_step c s 0
  change s (-3) = xor (L c s 1 (-2)) (s (-2) || s (-1)) at hs3
  rw [hY2, hs2] at hs3
  have hs4 := s_neg_succ_step c s 1
  change s (-4) = xor (L c s 1 (-3)) (s (-3) || s (-2)) at hs4
  rw [hs4, hY3, hs3, hs2]
  cases s (-1) <;> rfl

theorem topRow_blackRun_s5_eq (c : Nat -> Bool) (s : Int -> Bool)
    (hc0 : c 0 = false)
    (hY1 : L c s 1 (-1) = false)
    (hY2 : L c s 1 (-2) = true)
    (hY3 : L c s 1 (-3) = false) :
    s (-5) = !(L c s 1 (-4)) := by
  have hs4 := topRow_blackRun_s4_true c s hc0 hY1 hY2 hY3
  have hs5 := s_neg_succ_step c s 2
  change s (-5) = xor (L c s 1 (-4)) (s (-4) || s (-3)) at hs5
  rw [hs5, hs4]
  cases L c s 1 (-4) <;> cases s (-3) <;> rfl

/-- **Theorem U1b (Universal 3-Cell Black-Run OR-Latch Erasure):**
For EVERY driver `c : Nat -> Bool` with `c 0 = false`, if two seeds `s0, s1` have the same
`t = 1` row on `p < 0` and satisfy `L c s0 1 (-1) = false`, `L c s0 1 (-2) = true`, and
`L c s0 1 (-3) = false`, then `s0` and `s1` agree at every depth `-(m + 4)` (`m >= 0`). -/
theorem topRow_blackRun_latch_depth4 (c : Nat -> Bool) (s0 s1 : Int -> Bool)
    (hc0 : c 0 = false)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (hY1 : L c s0 1 (-1) = false)
    (hY2 : L c s0 1 (-2) = true)
    (hY3 : L c s0 1 (-3) = false) :
    forall m : Nat, s0 (-((m + 4 : Nat) : Int)) = s1 (-((m + 4 : Nat) : Int)) := by
  have hY1' : L c s1 1 (-1) = false := (hY 0).symm.trans hY1
  have hY2' : L c s1 1 (-2) = true := (hY 1).symm.trans hY2
  have hY3' : L c s1 1 (-3) = false := (hY 2).symm.trans hY3
  have hs4_0 := topRow_blackRun_s4_true c s0 hc0 hY1 hY2 hY3
  have hs4_1 := topRow_blackRun_s4_true c s1 hc0 hY1' hY2' hY3'
  have hs5_0 := topRow_blackRun_s5_eq c s0 hc0 hY1 hY2 hY3
  have hs5_1 := topRow_blackRun_s5_eq c s1 hc0 hY1' hY2' hY3'
  have ha1 : s0 (-4) = s1 (-4) := hs4_0.trans hs4_1.symm
  have ha2 : s0 (-5) = s1 (-5) := by
    rw [hs5_0, hs5_1]
    exact congrArg Bool.not (hY 3)
  intro m
  have h := (topRow_agree_from c s0 s1 3 hY ha1 ha2 m).1
  have hpos : 3 + m + 1 = m + 4 := by omega
  rw [hpos] at h
  exact h

/-! ## Section 4: Theorem U4 — All-Period Shift Monotonicity (`iterStepSeed` & `pins_periodStepSeed`) -/

def iterStepSeed (c : Nat -> Bool) : Nat -> (Int -> Bool) -> (Int -> Bool)
  | 0, s => s
  | d + 1, s => iterStepSeed (shiftDriver c 1) d (stepSeed c s)

theorem shiftDriver_add (c : Nat -> Bool) (a b : Nat) :
    shiftDriver (shiftDriver c a) b = shiftDriver c (a + b) := by
  funext t
  simp only [shiftDriver]
  congr 1
  omega

theorem pins_iterStepSeed (d : Nat) :
    forall (c : Nat -> Bool) (s : Int -> Bool),
      Pins c s -> Pins (shiftDriver c d) (iterStepSeed c d s) := by
  induction d with
  | zero =>
    intro c s hpins t hblack
    exact hpins t hblack
  | succ d ih =>
    intro c s hpins
    have h1 := ih (shiftDriver c 1) (stepSeed c s) (pins_stepSeed c s hpins)
    rw [shiftDriver_add c 1 d, show 1 + d = d + 1 by omega] at h1
    exact h1

/-- **Theorem U4 (All-Period Shift Invariance on `Pins c`):**
For every period `P : Nat` and every `P`-periodic driver `c` (`forall t, c (t + P) = c t`),
if `s` satisfies `Pins c s`, then the `P`-step evolved seed `iterStepSeed c P s` also
satisfies `Pins c`. -/
theorem pins_periodStepSeed (P : Nat) (c : Nat -> Bool)
    (hper : forall t : Nat, c (t + P) = c t) (s : Int -> Bool) (hpins : Pins c s) :
    Pins c (iterStepSeed c P s) := by
  have h := pins_iterStepSeed P c s hpins
  have hshift : shiftDriver c P = c := by
    funext t
    exact hper t
  rwa [hshift] at h

/-! ## Section 5: Phase-`01` Sideways Pair Recurrence Latch (`zblPair`, matching `Rule30SpacingRenormalization.pair`) -/

def zblPair (G : Nat -> Bool) : Nat -> Nat -> Bool × Bool
  | 0, _ => (false, false)
  | 1, r => (!G r, true)
  | k + 2, r =>
      (xor (zblPair G (k + 1) r).2 ((zblPair G (k + 1) r).1 || (zblPair G k r).1),
       xor (zblPair G (k + 1) (r + 1)).1 ((zblPair G (k + 1) r).2 || (zblPair G k r).2))

theorem zblPair_congr_ge (G1 G2 : Nat -> Bool) :
    forall (k r : Nat),
      (forall s : Nat, r <= s -> G1 s = G2 s) ->
      zblPair G1 k r = zblPair G2 k r
  | 0, _, _ => rfl
  | 1, r, h => by
    simp [zblPair, h r (Nat.le_refl r)]
  | k + 2, r, h => by
    have ih1 := zblPair_congr_ge G1 G2 (k + 1) r h
    have ih2 := zblPair_congr_ge G1 G2 (k + 1) (r + 1) (fun s hs => h s (by omega))
    have ih0 := zblPair_congr_ge G1 G2 k r h
    simp [zblPair, ih1, ih2, ih0]

theorem zblPair_three_zero_latch (G1 G2 : Nat -> Bool)
    (h1 : G1 1 = G2 1) :
    zblPair G1 3 0 = zblPair G2 3 0 := by
  simp only [zblPair, Nat.zero_add, h1]
  cases G1 0 <;> cases G2 0 <;> cases G2 1 <;> rfl

theorem zblPair_four_zero_latch (G1 G2 : Nat -> Bool)
    (hlatch : G1 1 = false)
    (h1 : G1 1 = G2 1) (h2 : G1 2 = G2 2) :
    zblPair G1 4 0 = zblPair G2 4 0 := by
  have hlatch2 : G2 1 = false := h1.symm.trans hlatch
  simp only [zblPair, Nat.zero_add, hlatch, hlatch2, h2]
  cases G1 0 <;> cases G2 0 <;> cases G2 2 <;> rfl

theorem boundary_or_latch_depth3 (G1 G2 : Nat -> Bool)
    (hlatch : G1 1 = false)
    (hag : forall s : Nat, 1 <= s -> G1 s = G2 s) :
    forall m : Nat,
      zblPair G1 (m + 3) 0 = zblPair G2 (m + 3) 0 /\
      zblPair G1 (m + 4) 0 = zblPair G2 (m + 4) 0 := by
  intro m
  induction m with
  | zero =>
    exact ⟨zblPair_three_zero_latch G1 G2 (hag 1 (by omega)),
           zblPair_four_zero_latch G1 G2 hlatch (hag 1 (by omega)) (hag 2 (by omega))⟩
  | succ m ih =>
    refine ⟨ih.2, ?_⟩
    change
      (xor (zblPair G1 (m + 4) 0).2 ((zblPair G1 (m + 4) 0).1 || (zblPair G1 (m + 3) 0).1),
       xor (zblPair G1 (m + 4) 1).1 ((zblPair G1 (m + 4) 0).2 || (zblPair G1 (m + 3) 0).2)) =
      (xor (zblPair G2 (m + 4) 0).2 ((zblPair G2 (m + 4) 0).1 || (zblPair G2 (m + 3) 0).1),
       xor (zblPair G2 (m + 4) 1).1 ((zblPair G2 (m + 4) 0).2 || (zblPair G2 (m + 3) 0).2))
    have h_r1 := zblPair_congr_ge G1 G2 (m + 4) 1 hag
    rw [ih.2, ih.1, h_r1]

#print axioms topRow_or_latch_depth3
#print axioms topRow_blackRun_latch_depth4
#print axioms pins_periodStepSeed
#print axioms boundary_or_latch_depth3

end FVLT.S4iUniformLatchV1
