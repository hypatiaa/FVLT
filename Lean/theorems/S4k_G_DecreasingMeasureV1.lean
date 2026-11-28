import S4j_G_UniformCascadeV1

/-!
# S4k-G: Decreasing-Measure Reduction, Left-vs-Right Chirality Reversal,
# White-Step Defect-Pair Annihilation, and the Measure Collapse Lemma

Formalizes the theorem suite for Study `S4k-G` (`#1161` and Addendum 1 `#1164`)
against Theorem Library `v5` (`#1159`):

1. **General Decreasing-Measure Reduction (`measure_linear_death_bound`,
   `measure_implies_boundedDeath`, `allPhase_measure_linear_death_bound`, Theorems K-M1a–c):**
   For any driver `c : Nat -> Bool`, window length `M >= 1`, terminal horizon `K_min`,
   initial bound `g : Nat -> Nat`, and measure `mu : Nat -> (Int -> Bool) -> Nat`:
   if `(a)` `HasWidth W s -> mu 0 s <= g W`, `(b)` `mu` strictly decreases over every
   surviving window of length `M` whenever `0 < mu`, and `(c)` `mu = 0` forces pin failure
   within `K_min` steps, then every seed of width `W` fails a black-step pin by time
   `M * g W + K_min`, implying `BoundedDeath c` (and uniformly across all phases `phi < P`
   per Addendum 1 A2).

2. **Left-Half-Line Innermost Defect Erosion (`innerDefect_step_sub_one`,
   `innerDefect_iterStepSeed`, `innerDefect_one_black_fails`,
   `innerDefect_blackRun_death`, Theorems K-M2a–c):**
   Because the left half-line `Rule30DrivenLeft` places the deeper neighbor `-(m+1)` in
   the linear `xor` slot of `rule a b r = xor a (b || r)`, any seed `s` whose innermost
   difference from a reference row `E` sits at depth `D >= 2` (`InnerDefect E s D`)
   moves its innermost defect to exact depth `D - 1` in one step unconditionally for
   **every** driver `c` (`innerDefect_step_sub_one`). When `D = 1` arrives at a black
   step `c 0 = true` where `E (-1) = !c 1`, `s` fails the black-step pin immediately
   (`innerDefect_one_black_fails`), establishing linear erosion across any black-step
   window (`innerDefect_blackRun_death`).

3. **White-Step Defect-Pair Annihilation & Strict Defect Increase (`innerDefect_white_annihilation`,
   `innerDefect_white_strict_increase`, `outerWidth_strictly_increases`, Theorems K-M2d & K-M3):**
   - At a white step `c 0 = false`, column `-1` is unpinned and `c 0` acts as the identity
     for `||`, so a defect pair `s (-1) = !E (-1)`, `s (-2) = !E (-2)` cancels at column `-1`
     in `stepSeed c s (-1) = stepSeed c E (-1)` (`innerDefect_white_annihilation`) and
     can strictly increase the innermost defect depth from `D = 1` to `D' = 2`
     (`innerDefect_white_strict_increase`).
   - Meanwhile, the outer support width `HasExactWidth W s` (`W >= 1`) strictly increases
     to `W + M` over every window `M >= 1` (`outerWidth_strictly_increases`).

4. **Measure Collapse Lemma & Fixed-Phase Domination Collapse (`measure_collapse_iff_linear_death`,
   `fixedPhase_dom_collapse_iff_bound`, Theorems K-M4a & K-M4b, Addendum 1 A3):**
   - Existence of a step-countdown measure at width `W` is logically equivalent (`↔`) to
     the explicit death bound `forall s, HasWidth W s -> ¬ SurvivesPinsUpTo c (g W) s`.
   - For fixed source phase `c_phi` and target phase `c_psi` where width `W` has exact
     death horizon `D`, the uniform-in-`K` existential domination statement (with `s'`
     chosen once per `s` for all `K`) is logically equivalent (`↔`) to the death-time
     inequality at horizon `D + Delta`.
-/

namespace FVLT.S4kDecreasingMeasureV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1
open FVLT.S4hCantorShiftV1
open FVLT.S4iUniformLatchV1
open FVLT.S4jUniformCascadeV1

-- ============================================================================
-- 1. General Decreasing-Measure Reduction (Theorems K-M1a, K-M1b, K-M1c)
-- ============================================================================

/-- Every left-half seed width `W` has a uniform finite pin-failure horizon `K`. -/
def BoundedDeath (c : Nat -> Bool) : Prop :=
  forall W : Nat, exists K : Nat, forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c K s

/-- Monotonicity of `SurvivesPinsUpTo` in the time horizon `K`. -/
theorem survivesPinsUpTo_mono (c : Nat -> Bool) {K1 K2 : Nat} (hle : K1 <= K2)
    (s : Int -> Bool) (h : SurvivesPinsUpTo c K2 s) :
    SurvivesPinsUpTo c K1 s := by
  intro t ht hct
  exact h t (by omega) hct

/--
Decreasing-measure specification at a given width `W` with initial bound `B`:
- `init_bound`: `(a)` every seed `s` of width `W` has `mu 0 s <= B`;
- `window_decrease`: `(b)` over every surviving window of length `M`, `mu` strictly decreases
  whenever `0 < mu`;
- `min_forces_death`: `(c)` reaching `mu = 0` forces pin failure within `K_min` steps.
-/
structure DecreasingMeasureAtWidth (c : Nat -> Bool) (W M K_min B : Nat)
    (mu : Nat -> (Int -> Bool) -> Nat) : Prop where
  init_bound :
    forall s : Int -> Bool, HasWidth W s -> mu 0 s <= B
  window_decrease :
    forall (t : Nat) (s : Int -> Bool),
      HasWidth W s ->
      SurvivesPinsUpTo c (t + M) s ->
      0 < mu t (iterStepSeed c t s) ->
      mu (t + M) (iterStepSeed c (t + M) s) < mu t (iterStepSeed c t s)
  min_forces_death :
    forall (t : Nat) (s : Int -> Bool),
      HasWidth W s ->
      mu t (iterStepSeed c t s) = 0 ->
      ¬ SurvivesPinsUpTo c (t + K_min) s

/--
Global decreasing-measure specification across all widths `W : Nat` with initial bound `g W`.
-/
structure DecreasingMeasureSpec (c : Nat -> Bool) (M K_min : Nat)
    (g : Nat -> Nat) (mu : Nat -> (Int -> Bool) -> Nat) : Prop where
  init_bound :
    forall (W : Nat) (s : Int -> Bool), HasWidth W s -> mu 0 s <= g W
  window_decrease :
    forall (t : Nat) (s : Int -> Bool),
      SurvivesPinsUpTo c (t + M) s ->
      0 < mu t (iterStepSeed c t s) ->
      mu (t + M) (iterStepSeed c (t + M) s) < mu t (iterStepSeed c t s)
  min_forces_death :
    forall (t : Nat) (s : Int -> Bool),
      mu t (iterStepSeed c t s) = 0 ->
      ¬ SurvivesPinsUpTo c (t + K_min) s

theorem DecreasingMeasureSpec.toAtWidth {c : Nat -> Bool} {M K_min : Nat}
    {g : Nat -> Nat} {mu : Nat -> (Int -> Bool) -> Nat}
    (h : DecreasingMeasureSpec c M K_min g mu) (W : Nat) :
    DecreasingMeasureAtWidth c W M K_min (g W) mu where
  init_bound s hw := h.init_bound W s hw
  window_decrease t s _ hsurv hpos := h.window_decrease t s hsurv hpos
  min_forces_death t s _ hz := h.min_forces_death t s hz

/-- Well-founded descent along `v >= mu t (iterStepSeed c t s)`. -/
theorem measure_descent_at_width (c : Nat -> Bool) (W M K_min B : Nat)
    (mu : Nat -> (Int -> Bool) -> Nat)
    (hspec : DecreasingMeasureAtWidth c W M K_min B mu) (v : Nat) :
    forall (t : Nat) (s : Int -> Bool),
      HasWidth W s ->
      mu t (iterStepSeed c t s) <= v ->
      ¬ SurvivesPinsUpTo c (t + M * v + K_min) s := by
  induction v with
  | zero =>
      intro t s hw hle hsurv
      have hz : mu t (iterStepSeed c t s) = 0 := by omega
      have hfail := hspec.min_forces_death t s hw hz
      have hsurv' : SurvivesPinsUpTo c (t + K_min) s :=
        survivesPinsUpTo_mono c (by omega) s hsurv
      exact hfail hsurv'
  | succ v ih =>
      intro t s hw hle hsurv
      have h_mul : M * (v + 1) = M * v + M := Nat.mul_succ M v
      by_cases hz : mu t (iterStepSeed c t s) = 0
      · have hfail := hspec.min_forces_death t s hw hz
        have hsurv' : SurvivesPinsUpTo c (t + K_min) s :=
          survivesPinsUpTo_mono c (by omega) s hsurv
        exact hfail hsurv'
      · have hpos : 0 < mu t (iterStepSeed c t s) := by omega
        have hsurvM : SurvivesPinsUpTo c (t + M) s :=
          survivesPinsUpTo_mono c (by omega) s hsurv
        have hdec := hspec.window_decrease t s hw hsurvM hpos
        have hle' : mu (t + M) (iterStepSeed c (t + M) s) <= v := by omega
        have hfail := ih (t + M) s hw hle'
        have h_eq : t + M + M * v + K_min = t + M * (v + 1) + K_min := by omega
        rw [h_eq] at hfail
        exact hfail hsurv

theorem measure_at_width_bound (c : Nat -> Bool) (W M K_min B : Nat)
    (mu : Nat -> (Int -> Bool) -> Nat)
    (hspec : DecreasingMeasureAtWidth c W M K_min B mu) :
    forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c (M * B + K_min) s := by
  intro s hw
  have hinit : mu 0 (iterStepSeed c 0 s) <= B := hspec.init_bound s hw
  have hdesc := measure_descent_at_width c W M K_min B mu hspec B 0 s hw hinit
  have h_eq : 0 + M * B + K_min = M * B + K_min := by omega
  rwa [h_eq] at hdesc

/--
**Theorem K-M1a (`measure_linear_death_bound`):**
Under `DecreasingMeasureSpec c M K_min g mu`, every seed `s` of width `W` fails a black-step
pin by time `M * g W + K_min`.
-/
theorem measure_linear_death_bound (c : Nat -> Bool) (M K_min : Nat)
    (g : Nat -> Nat) (mu : Nat -> (Int -> Bool) -> Nat)
    (hspec : DecreasingMeasureSpec c M K_min g mu) (W : Nat) :
    forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c (M * g W + K_min) s :=
  measure_at_width_bound c W M K_min (g W) mu (hspec.toAtWidth W)

/--
**Theorem K-M1b (`measure_implies_boundedDeath`):**
Existence of a decreasing measure satisfying `(a)`, `(b)`, and `(c)` implies `BoundedDeath c`.
-/
theorem measure_implies_boundedDeath (c : Nat -> Bool) (M K_min : Nat)
    (g : Nat -> Nat) (mu : Nat -> (Int -> Bool) -> Nat)
    (hspec : DecreasingMeasureSpec c M K_min g mu) :
    BoundedDeath c := by
  intro W
  exact ⟨M * g W + K_min, measure_linear_death_bound c M K_min g mu hspec W⟩

/--
**Theorem K-M1c (`allPhase_measure_linear_death_bound`, Addendum 1 A2):**
If every phase `phi < P` of a `P`-periodic driver `c` admits a decreasing measure with bound
`g`, then the uniform bound `M * g W + K_min` holds across **all** phases `phi < P`
(`D*_c(W) <= M * g(W) + K_min`).
-/
theorem allPhase_measure_linear_death_bound (c : Nat -> Bool) (P M K_min : Nat)
    (g : Nat -> Nat) (mu : Nat -> Nat -> (Int -> Bool) -> Nat)
    (hall : forall phi : Nat, phi < P ->
      DecreasingMeasureSpec (shiftDriver c phi) M K_min g (mu phi)) :
    forall (phi : Nat), phi < P ->
      forall (W : Nat) (s : Int -> Bool),
        HasWidth W s -> ¬ SurvivesPinsUpTo (shiftDriver c phi) (M * g W + K_min) s := by
  intro phi hphi W s hw
  exact measure_linear_death_bound (shiftDriver c phi) M K_min g (mu phi) (hall phi hphi) W s hw

-- ============================================================================
-- 2. Left-Half-Line Innermost Defect Erosion (Theorems K-M2a, K-M2b, K-M2c)
-- ============================================================================

/--
`InnerDefect E s D` states that `D >= 1` is the **innermost** left-half depth (`p = -D`)
at which seed `s` differs from reference row `E`.
-/
def InnerDefect (E s : Int -> Bool) (D : Nat) : Prop :=
  1 <= D /\
  s (-(D : Int)) = !E (-(D : Int)) /\
  (forall m : Nat, 1 <= m -> m < D -> s (-(m : Int)) = E (-(m : Int)))

theorem stepSeed_neg_one (c : Nat -> Bool) (s : Int -> Bool) :
    stepSeed c s (-1) = xor (s (-2)) (s (-1) || c 0) := by
  change L c s 1 (-1) = _
  have hp : (-1 : Int) < 0 := by omega
  have h1 : (-1 : Int) - 1 = -2 := by omega
  have h2 : (-1 : Int) + 1 = 0 := by omega
  rw [L_succ hp, h1, h2, L_zero (by omega), L_zero hp, L_col0]
  rfl

theorem stepSeed_neg_ge2 (c : Nat -> Bool) (s : Int -> Bool) (m : Nat) (hm : 2 <= m) :
    stepSeed c s (-(m : Int)) =
      xor (s (-((m + 1 : Nat) : Int))) (s (-(m : Int)) || s (-((m - 1 : Nat) : Int))) := by
  change L c s 1 (-(m : Int)) = _
  have hp : (-(m : Int)) < 0 := by omega
  have h1 : (-(m : Int)) - 1 = -((m + 1 : Nat) : Int) := by omega
  have h2 : (-(m : Int)) + 1 = -((m - 1 : Nat) : Int) := by omega
  rw [L_succ hp, h1, h2, L_zero (by omega), L_zero hp, L_zero (by omega)]
  rfl

theorem xor_not_left (a b : Bool) : xor (!a) b = !(xor a b) := by
  cases a <;> cases b <;> rfl

/--
**Theorem K-M2a (`innerDefect_step_sub_one`):**
On the left half-line `Rule30DrivenLeft`, for **every** driver `c : Nat -> Bool`,
whenever `s` has innermost defect at depth `D >= 2` against `E`, one forward step
moves the innermost defect to exact depth `D - 1` unconditionally (`D' = D - 1`).
-/
theorem innerDefect_step_sub_one (c : Nat -> Bool) (E s : Int -> Bool) (D : Nat)
    (hD : 2 <= D) (hdef : InnerDefect E s D) :
    InnerDefect (stepSeed c E) (stepSeed c s) (D - 1) := by
  refine ⟨by omega, ?_, ?_⟩
  · by_cases hD2 : D = 2
    · subst hD2
      have h_idx : (-((2 - 1 : Nat) : Int)) = -1 := rfl
      rw [h_idx, stepSeed_neg_one c s, stepSeed_neg_one c E]
      have hd2 : s (-2) = !E (-2) := hdef.2.1
      have hd1 : s (-1) = E (-1) := hdef.2.2 1 (by omega) (by omega)
      rw [hd2, hd1, xor_not_left]
    · have hm : 2 <= D - 1 := by omega
      rw [stepSeed_neg_ge2 c s (D - 1) hm, stepSeed_neg_ge2 c E (D - 1) hm]
      have h_add : D - 1 + 1 = D := by omega
      rw [h_add]
      have hdD : s (-(D : Int)) = !E (-(D : Int)) := hdef.2.1
      have hd_mid : s (-((D - 1 : Nat) : Int)) = E (-((D - 1 : Nat) : Int)) :=
        hdef.2.2 (D - 1) (by omega) (by omega)
      have hd_rgt : s (-((D - 1 - 1 : Nat) : Int)) = E (-((D - 1 - 1 : Nat) : Int)) :=
        hdef.2.2 (D - 1 - 1) (by omega) (by omega)
      rw [hdD, hd_mid, hd_rgt, xor_not_left]
  · intro m hm1 hmlt
    by_cases hm_eq : m = 1
    · subst hm_eq
      change stepSeed c s (-1) = stepSeed c E (-1)
      rw [stepSeed_neg_one c s, stepSeed_neg_one c E]
      have ha2 : s (-2) = E (-2) := hdef.2.2 2 (by omega) (by omega)
      have ha1 : s (-1) = E (-1) := hdef.2.2 1 (by omega) (by omega)
      rw [ha2, ha1]
    · have hm2 : 2 <= m := by omega
      rw [stepSeed_neg_ge2 c s m hm2, stepSeed_neg_ge2 c E m hm2]
      have ha_l : s (-((m + 1 : Nat) : Int)) = E (-((m + 1 : Nat) : Int)) :=
        hdef.2.2 (m + 1) (by omega) (by omega)
      have ha_m : s (-(m : Int)) = E (-(m : Int)) :=
        hdef.2.2 m (by omega) (by omega)
      have ha_r : s (-((m - 1 : Nat) : Int)) = E (-((m - 1 : Nat) : Int)) :=
        hdef.2.2 (m - 1) (by omega) (by omega)
      rw [ha_l, ha_m, ha_r]

/-- Iterated `k`-step inward drift of the innermost defect (`D -> D - k`). -/
theorem innerDefect_iterStepSeed (k : Nat) :
    forall (c : Nat -> Bool) (E s : Int -> Bool) (D : Nat),
      k + 1 <= D -> InnerDefect E s D ->
      InnerDefect (iterStepSeed c k E) (iterStepSeed c k s) (D - k) := by
  induction k with
  | zero =>
      intro c E s D _ hdef
      have h0 : D - 0 = D := by omega
      rw [h0]
      exact hdef
  | succ k ih =>
      intro c E s D hkD hdef
      simp only [iterStepSeed]
      have hstep := innerDefect_step_sub_one c E s D (by omega) hdef
      have h_ih := ih (shiftDriver c 1) (stepSeed c E) (stepSeed c s) (D - 1) (by omega) hstep
      have h_sub : D - 1 - k = D - (k + 1) := by omega
      rwa [h_sub] at h_ih

/--
**Theorem K-M2b (`innerDefect_one_black_fails`):**
When the innermost defect reaches `D = 1` at a black step (`c 0 = true`) where the reference
row satisfies the pin `E (-1) = !c 1`, seed `s` immediately fails the black-step pin at `t = 0`.
-/
theorem innerDefect_one_black_fails (c : Nat -> Bool) (E s : Int -> Bool)
    (hdef : InnerDefect E s 1) (hc0 : c 0 = true) (hE : E (-1) = !c 1) :
    ¬ SurvivesPinsUpTo c 0 s := by
  intro hsurv
  have hpin := hsurv 0 (by omega) hc0
  have hL0 : L c s 0 (-1) = s (-1) := L_zero (by omega)
  rw [hL0] at hpin
  have hs1 : s (-1) = !E (-1) := hdef.2.1
  rw [hE] at hs1
  revert hpin hs1
  cases c 1 <;> cases s (-1) <;> decide

/--
**Theorem K-M2c (`innerDefect_blackRun_death`):**
If `s` has `InnerDefect E s D` (`D >= 1`), step `t = D - 1` is a black step (`c (D - 1) = true`),
and the reference trajectory `E` satisfies the pin at `t = D - 1`, then `s` fails a black-step
pin by time `D - 1`.
-/
theorem innerDefect_blackRun_death (c : Nat -> Bool) (E s : Int -> Bool) (D : Nat)
    (hdef : InnerDefect E s D)
    (hc : c (D - 1) = true)
    (hE_pin : L c E (D - 1) (-1) = !c D) :
    ¬ SurvivesPinsUpTo c (D - 1) s := by
  intro hsurv
  have hD1 : 1 <= D := hdef.1
  have hiter := innerDefect_iterStepSeed (D - 1) c E s D (by omega) hdef
  have h_sub : D - (D - 1) = 1 := by omega
  rw [h_sub] at hiter
  have hLs := L_iterStepSeed (D - 1) c s 0 (-1) (by omega)
  have hLE := L_iterStepSeed (D - 1) c E 0 (-1) (by omega)
  have h0s : L (shiftDriver c (D - 1)) (iterStepSeed c (D - 1) s) 0 (-1) =
      iterStepSeed c (D - 1) s (-1) := L_zero (by omega)
  have h0E : L (shiftDriver c (D - 1)) (iterStepSeed c (D - 1) E) 0 (-1) =
      iterStepSeed c (D - 1) E (-1) := L_zero (by omega)
  have h_add : 0 + (D - 1) = D - 1 := by omega
  rw [h0s, h_add] at hLs
  rw [h0E, h_add] at hLE
  have hs_flip : L c s (D - 1) (-1) = !L c E (D - 1) (-1) := by
    rw [<- hLs, <- hLE]
    exact hiter.2.1
  have hpin := hsurv (D - 1) (by omega) hc
  have h_succ : D - 1 + 1 = D := by omega
  rw [h_succ] at hpin
  rw [hE_pin] at hs_flip
  revert hpin hs_flip
  cases c D <;> cases L c s (D - 1) (-1) <;> decide

-- ============================================================================
-- 3. White-Step Defect-Pair Annihilation & Outer-Edge Increase (Theorems K-M2d & K-M3)
-- ============================================================================

/--
**Theorem K-M2d (`innerDefect_white_annihilation`):**
At any white step `c 0 = false`, if `s` and `E` differ at both adjacent boundary columns
`-1` and `-2` (`s (-1) = !E (-1)` and `s (-2) = !E (-2)`), the two defects annihilate in
column `-1` at the next step: `stepSeed c s (-1) = stepSeed c E (-1)`.
-/
theorem innerDefect_white_annihilation (c : Nat -> Bool) (E s : Int -> Bool)
    (hc0 : c 0 = false)
    (hs1 : s (-1) = !E (-1))
    (hs2 : s (-2) = !E (-2)) :
    stepSeed c s (-1) = stepSeed c E (-1) := by
  rw [stepSeed_neg_one c s, stepSeed_neg_one c E, hc0, hs1, hs2]
  cases E (-1) <;> cases E (-2) <;> rfl

/--
**Theorem K-M2e (`innerDefect_white_strict_increase`):**
At a white step `c 0 = false`, a pair of defects at `(-1, -2)` against a white reference
background (`E (-1) = false`, `E (-2) = false`, `s (-1) = true`, `s (-2) = true`, `s (-3) = E (-3)`)
causes the innermost defect depth to **strictly increase** from `D = 1` to `D' = 2` in one step!
-/
theorem innerDefect_white_strict_increase (c : Nat -> Bool) (E s : Int -> Bool)
    (hc0 : c 0 = false)
    (hE1 : E (-1) = false) (hE2 : E (-2) = false)
    (hs1 : s (-1) = true) (hs2 : s (-2) = true)
    (hs3 : s (-3) = E (-3)) :
    InnerDefect E s 1 /\ InnerDefect (stepSeed c E) (stepSeed c s) 2 := by
  refine ⟨⟨by omega, by change s (-1) = !E (-1); rw [hs1, hE1]; rfl, ?_⟩, ⟨by omega, ?_, ?_⟩⟩
  · intro m hm1 hmlt
    omega
  · rw [stepSeed_neg_ge2 c s 2 (by omega), stepSeed_neg_ge2 c E 2 (by omega)]
    change xor (s (-3)) (s (-2) || s (-1)) = !(xor (E (-3)) (E (-2) || E (-1)))
    rw [hs3, hs2, hs1, hE2, hE1]
    cases E (-3) <;> rfl
  · intro m hm1 hmlt
    have hm_eq : m = 1 := by omega
    subst hm_eq
    change stepSeed c s (-1) = stepSeed c E (-1)
    apply innerDefect_white_annihilation c E s hc0
    · rw [hs1, hE1]; rfl
    · rw [hs2, hE2]; rfl

/--
**Theorem K-M3 (`outerWidth_strictly_increases`):**
For every driver `c`, every window length `M >= 1`, every width `W >= 1`, and every seed `s`
with `HasExactWidth W s`, `iterStepSeed c M s` has exact width `W + M > W`.
-/
theorem outerWidth_strictly_increases (c : Nat -> Bool) (M W : Nat) (s : Int -> Bool)
    (hM : 1 <= M) (hW : 1 <= W) (hex : HasExactWidth W s) :
    HasExactWidth (W + M) (iterStepSeed c M s) /\ W < W + M :=
  ⟨iterStepSeed_deepest_black M c W s hW hex, by omega⟩

-- ============================================================================
-- 4. Measure Collapse Lemma & Fixed-Phase Domination Collapse (Theorems K-M4a & K-M4b)
-- ============================================================================

/-- Countdown measure `B - t` used in the Measure Collapse Lemma. -/
def countdownMeasure (B : Nat) (t : Nat) (_ : Int -> Bool) : Nat :=
  B - t

/--
**Theorem K-M4a (`measure_collapse_iff_linear_death`):**
At any width `W : Nat` and bound `B : Nat`, the existence of a measure
`mu : Nat -> (Int -> Bool) -> Nat` satisfying `DecreasingMeasureAtWidth c W 1 0 B mu`
is **logically equivalent** to the death-time bound
`forall s, HasWidth W s -> ¬ SurvivesPinsUpTo c B s`.
-/
theorem measure_collapse_iff_linear_death (c : Nat -> Bool) (W B : Nat) :
    (exists mu : Nat -> (Int -> Bool) -> Nat, DecreasingMeasureAtWidth c W 1 0 B mu) ↔
    (forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c B s) := by
  constructor
  · rintro ⟨mu, hspec⟩
    have hbound := measure_at_width_bound c W 1 0 B mu hspec
    have h_eq : 1 * B + 0 = B := by omega
    rwa [h_eq] at hbound
  · intro hbound
    refine ⟨countdownMeasure B, ?_⟩
    refine ⟨?_, ?_, ?_⟩
    · intro s _
      simp [countdownMeasure]
    · intro t s _ _ hpos
      simp only [countdownMeasure] at hpos ⊢
      omega
    · intro t s hw hz hsurv
      simp only [countdownMeasure] at hz
      have hle : B <= t + 0 := by omega
      exact hbound s hw (survivesPinsUpTo_mono c hle s hsurv)

/--
**Theorem K-M4b (`fixedPhase_dom_collapse_iff_bound`, Addendum 1 A3):**
For fixed source driver/phase `c_phi` and fixed target driver/phase `c_psi`, suppose width `W`
on `c_psi` has exact finite death horizon `D` (every width-`W` seed fails by `D`, and a witness
seed `s_wit` of width `W` survives for all `K < D`). Then the uniform-in-`K` existential
domination statement (with `s'` chosen **once** per `s` for all horizons `K`) is logically
equivalent (`↔`) to the death-time bound `D_{c_phi}(W + P) <= D + Delta`.
-/
theorem fixedPhase_dom_collapse_iff_bound (c_phi c_psi : Nat -> Bool) (W P D Delta : Nat)
    (hD_upper : forall s' : Int -> Bool, HasWidth W s' -> ¬ SurvivesPinsUpTo c_psi D s')
    (s_wit : Int -> Bool) (hw_wit : HasWidth W s_wit)
    (hD_lower : forall K : Nat, K < D -> SurvivesPinsUpTo c_psi K s_wit) :
    (forall s : Int -> Bool, HasWidth (W + P) s ->
      exists s' : Int -> Bool, HasWidth W s' /\
        (forall K : Nat, SurvivesPinsUpTo c_phi (K + Delta) s -> SurvivesPinsUpTo c_psi K s')) ↔
    (forall s : Int -> Bool, HasWidth (W + P) s -> ¬ SurvivesPinsUpTo c_phi (D + Delta) s) := by
  constructor
  · intro hdom s hw hsurv
    rcases hdom s hw with ⟨s', hw', himp⟩
    exact hD_upper s' hw' (himp D hsurv)
  · intro hbound s hw
    refine ⟨s_wit, hw_wit, ?_⟩
    intro K hsurv
    by_cases hlt : K < D
    · exact hD_lower K hlt
    · have hle : D + Delta <= K + Delta := by omega
      exact False.elim (hbound s hw (survivesPinsUpTo_mono c_phi hle s hsurv))

#print axioms measure_linear_death_bound
#print axioms measure_implies_boundedDeath
#print axioms allPhase_measure_linear_death_bound
#print axioms innerDefect_step_sub_one
#print axioms innerDefect_iterStepSeed
#print axioms innerDefect_one_black_fails
#print axioms innerDefect_blackRun_death
#print axioms innerDefect_white_annihilation
#print axioms innerDefect_white_strict_increase
#print axioms outerWidth_strictly_increases
#print axioms measure_collapse_iff_linear_death
#print axioms fixedPhase_dom_collapse_iff_bound

end FVLT.S4kDecreasingMeasureV1
