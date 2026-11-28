import S4k_G_DecreasingMeasureV1

/-!
# S4l-G: Single-Black to Zero-Boundary Masking Reduction, Amortized Cycle-Potential Schema,
# Zero-Boundary Black-Run Hollowing, and Defect-Span Obstructions

Formalizes the theorem suite for Study `S4l-G` (`#1185`, `WORK_ORDER.md` `e00e0fd9...`)
against Theorem Library `v6` (`#1182`, `SHA256SUMS` `91887e63...`):

1. **Part 1b — Single-Black to Zero-Boundary Masking Reduction (`stepSeed_eq_zero_of_pin`,
   `L_eq_L_zero_of_no_adjacent_black`, `survivesPinsUpTo_iff_L_zero`,
   `singleBlackDriver_no_adjacent_black`, `singleBlack_survives_iff_L_zero`,
   `QP_bounded_iff_singleBlack_death`, `allPhase_singleBlack_from_phase0`, Theorems L1a–L1f):**
   - On any driver `c` without adjacent black cells (`c t = true -> c (t + 1) = false`),
     a black step `c t = true` under `SurvivesPinsUpTo c K s` forces `L c s t (-1) = !c (t + 1) = true`,
     which masks `c t` inside the boundary OR gate (`true || c t = true = true || false`).
   - Consequently, any seed `s` surviving up to `K` evolves identically to the zero-boundary
     system `L c_zero s t p` (`c_zero := fun _ => false`) on `p < 0` through `t <= K + 1`, and
     `SurvivesPinsUpTo c K s` is logically equivalent (`↔`) to `L c_zero s t (-1) = true` at
     every black step `t <= K`.
   - Specializing to `singleBlackDriver P phi t := decide ((t + phi) % P = 0)` for `P >= 2`
     establishes the standalone half-line version of the `0cac94` reduction against Library `v6`
     (citing `R30-20261022-0cac94` with no novelty claim).

2. **Part 2 — Amortized Cycle-Potential Reduction (`amortized_cycle_potential_bounded_death`,
   `amortized_cycle_implies_boundedDeath`, Theorems L2a–L2b):**
   - Formalizes the four-part amortized cycle-potential conditions `(i)` white-gap bound `A`,
     `(ii)–(iii)` net decrease `delta >= 1` per complete period-`P` cycle above floor `mu_min`,
     and `(iv)` floor pin failure within `K_min` steps, proving that `(i)–(iv)` plus initial
     width bound `mu s <= g W` imply `D_c(W) <= P * g(W) + K_min` and `BoundedDeath c`.

3. **Zero-Boundary Black-Run Hollowing & Cycle Failure (`blackRun_hollow_step`,
   `blackRun_gt_P_fails_cycle`, Theorems L3a–L3b):**
   - On `L_zero`, a boundary black run of length `r >= 2` (`s (-1) = ... = s (-r) = true`,
     `s (-(r+1)) = false`) hollows out in one step to `InnerDefect zeroRow (stepSeed c_zero s) r`
     (jumping the innermost defect `D_1` from `1` to `r`), and then drifts inward at speed `1`
     via `innerDefect_iterStepSeed`.
   - Any seed with initial boundary black-run length `r >= P + 1` therefore has
     `L c_zero s P (-1) = false` and fails the black-step pin at `t = P` on `singleBlackDriver P 0`.

4. **Defect-Span Cycle Growth & Barrier Survivor Existence (`defectSpan_cycle_increases`,
   `exists_survivor_of_width_add_two`, Theorems L4a–L4b):**
   - At every surviving cycle boundary `t = P * k` on `singleBlackDriver P 0`, a seed of exact
     width `W >= 1` has `InnerDefect zeroRow s_{P*k} 1` and `HasExactWidth (W + P * k) s_{P*k}`,
     so its active defect span increases by `+P` per cycle.
   - By `Rule30DrivenLeft.barrier_exists`, for every driver `c` and horizon `K`, there exists
     a seed `s` of exact width `K + 2` satisfying `SurvivesPinsUpTo c K s`.
-/

namespace FVLT.S4lZeroBoundaryPotentialsV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1
open FVLT.S4hCantorShiftV1
open FVLT.S4iUniformLatchV1
open FVLT.S4jUniformCascadeV1
open FVLT.S4kDecreasingMeasureV1

-- ============================================================================
-- 1. Part 1b: Single-Black to Zero-Boundary Masking Reduction (Theorems L1a–L1f)
-- ============================================================================

/-- The zero-boundary (all-white) driver `c_zero(t) = false`. -/
def c_zero : Nat -> Bool := fun _ => false

/-- The period-`P` single-black driver at phase `phi`, black iff `(t + phi) % P = 0`. -/
def singleBlackDriver (P phi t : Nat) : Bool :=
  decide ((t + phi) % P = 0)

/-- The all-white left-half reference row `zeroRow(p) = false`. -/
def zeroRow : Int -> Bool := fun _ => false

/--
**Theorem L1a (`stepSeed_eq_zero_of_pin`):**
If `c 0 = false`, or if `c 0 = true` is masked by `s (-1) = true` in the boundary OR gate,
one step of `stepSeed c s` agrees with the zero-boundary step `stepSeed c_zero s` on `p < 0`.
-/
theorem stepSeed_eq_zero_of_pin (c : Nat -> Bool) (s : Int -> Bool)
    (hmask : c 0 = false \/ (c 0 = true /\ s (-1) = true)) :
    forall p : Int, p < 0 -> stepSeed c s p = stepSeed c_zero s p := by
  intro p hp
  change L c s 1 p = L c_zero s 1 p
  have hpm1 : p - 1 < 0 := by omega
  rw [L_succ hp, L_succ hp,
      L_zero (c := c) hpm1, L_zero (c := c_zero) hpm1,
      L_zero (c := c) hp, L_zero (c := c_zero) hp]
  by_cases hp1 : p + 1 < 0
  · rw [L_zero (c := c) hp1, L_zero (c := c_zero) hp1]
  · have hp0 : p + 1 = 0 := by omega
    have hp_neg1 : p = -1 := by omega
    rw [hp0, L_col0, L_col0, hp_neg1]
    rcases hmask with hc0 | ⟨hc0, hs1⟩
    · rw [hc0]
      rfl
    · rw [hc0, hs1]
      rfl

/--
Trajectory equality with `L c_zero` whenever `L c_zero s t (-1) = true` at all black steps `t <= K`.
-/
theorem L_eq_L_zero_of_black_samples (c : Nat -> Bool) (K : Nat) (s : Int -> Bool)
    (hsamp : forall t : Nat, t <= K -> c t = true -> L c_zero s t (-1) = true) :
    forall t : Nat, t <= K + 1 -> forall p : Int, p < 0 -> L c s t p = L c_zero s t p := by
  intro t
  induction t with
  | zero =>
      intro _ p hp
      rw [L_zero hp, L_zero hp]
  | succ t ih =>
      intro ht p hp
      have ih_t := ih (by omega)
      rw [L_succ hp, L_succ hp, ih_t (p - 1) (by omega), ih_t p hp]
      by_cases hp1 : p + 1 < 0
      · rw [ih_t (p + 1) hp1]
      · have hp0 : p + 1 = 0 := by omega
        have hp_neg1 : p = -1 := by omega
        rw [hp0, L_col0, L_col0, hp_neg1]
        cases hct : c t
        · rfl
        · have hpin0 : L c_zero s t (-1) = true := hsamp t (by omega) hct
          rw [hpin0]
          rfl

/--
**Theorem L1b (`L_eq_L_zero_of_no_adjacent_black`):**
For any driver `c` without adjacent black steps up to `K` (`c t = true -> c (t + 1) = false`),
any seed `s` satisfying `SurvivesPinsUpTo c K s` evolves identically to `L c_zero s` on `p < 0`
for all steps `t <= K + 1`.
-/
theorem L_eq_L_zero_of_no_adjacent_black (c : Nat -> Bool) (K : Nat) (s : Int -> Bool)
    (hnoadj : forall t : Nat, t <= K -> c t = true -> c (t + 1) = false)
    (hsurv : SurvivesPinsUpTo c K s) :
    forall t : Nat, t <= K + 1 -> forall p : Int, p < 0 -> L c s t p = L c_zero s t p := by
  intro t
  induction t with
  | zero =>
      intro _ p hp
      rw [L_zero hp, L_zero hp]
  | succ t ih =>
      intro ht p hp
      have ih_t := ih (by omega)
      rw [L_succ hp, L_succ hp, ih_t (p - 1) (by omega), ih_t p hp]
      by_cases hp1 : p + 1 < 0
      · rw [ih_t (p + 1) hp1]
      · have hp0 : p + 1 = 0 := by omega
        have hp_neg1 : p = -1 := by omega
        rw [hp0, L_col0, L_col0, hp_neg1]
        cases hct : c t
        · rfl
        · have hnext : c (t + 1) = false := hnoadj t (by omega) hct
          have hpin : L c s t (-1) = !c (t + 1) := hsurv t (by omega) hct
          rw [hnext] at hpin
          have hpin0 : L c_zero s t (-1) = true := by
            rw [<- ih_t (-1) (by omega)]
            exact hpin
          rw [hpin0]
          rfl

/--
**Theorem L1c (`survivesPinsUpTo_iff_L_zero`):**
On any driver `c` without adjacent black steps up to `K`, `SurvivesPinsUpTo c K s` is logically
equivalent (`↔`) to `L c_zero s t (-1) = true` at every black step `t <= K`.
-/
theorem survivesPinsUpTo_iff_L_zero (c : Nat -> Bool) (K : Nat) (s : Int -> Bool)
    (hnoadj : forall t : Nat, t <= K -> c t = true -> c (t + 1) = false) :
    SurvivesPinsUpTo c K s ↔
    (forall t : Nat, t <= K -> c t = true -> L c_zero s t (-1) = true) := by
  constructor
  · intro hsurv t ht hct
    have heq := L_eq_L_zero_of_no_adjacent_black c K s hnoadj hsurv t (by omega) (-1) (by omega)
    have hpin := hsurv t ht hct
    have hnext := hnoadj t ht hct
    rw [hnext] at hpin
    rw [<- heq]
    exact hpin
  · intro hsamp t ht hct
    have heq := L_eq_L_zero_of_black_samples c K s hsamp t (by omega) (-1) (by omega)
    have hnext := hnoadj t ht hct
    rw [heq, hsamp t ht hct, hnext]
    rfl

/--
**Theorem L1d (`singleBlackDriver_no_adjacent_black`):**
For every period `P >= 2` and phase `phi : Nat`, `singleBlackDriver P phi` never has two
consecutive black steps.
-/
theorem singleBlackDriver_no_adjacent_black (P phi : Nat) (hP : 2 <= P) (t : Nat)
    (hct : singleBlackDriver P phi t = true) :
    singleBlackDriver P phi (t + 1) = false := by
  have h0 : (t + phi) % P = 0 := by simpa [singleBlackDriver] using hct
  have h_eq : t + 1 + phi = (t + phi) + 1 := by omega
  have h1 : 1 % P = 1 := Nat.mod_eq_of_lt (by omega)
  have h_next : (t + 1 + phi) % P = 1 := by
    rw [h_eq, Nat.add_mod, h0, h1, Nat.zero_add, h1]
  unfold singleBlackDriver
  rw [h_next]
  rfl

/--
**Theorem L1d' (`singleBlack_survives_iff_L_zero`):**
For every period `P >= 2` and phase `phi : Nat`, `SurvivesPinsUpTo (singleBlackDriver P phi) K s`
holds iff the zero-boundary trajectory `L c_zero s` is black at column `-1` at every step `t <= K`
satisfying `(t + phi) % P = 0`.
-/
theorem singleBlack_survives_iff_L_zero (P phi K : Nat) (hP : 2 <= P) (s : Int -> Bool) :
    SurvivesPinsUpTo (singleBlackDriver P phi) K s ↔
    (forall t : Nat, t <= K -> (t + phi) % P = 0 -> L c_zero s t (-1) = true) := by
  have hnoadj : forall t : Nat, t <= K ->
      singleBlackDriver P phi t = true -> singleBlackDriver P phi (t + 1) = false := by
    intro t _ hct
    exact singleBlackDriver_no_adjacent_black P phi hP t hct
  rw [survivesPinsUpTo_iff_L_zero (singleBlackDriver P phi) K s hnoadj]
  constructor
  · intro h t ht hmod
    apply h t ht
    simp [singleBlackDriver, hmod]
  · intro h t ht hct
    apply h t ht
    simpa [singleBlackDriver] using hct

/--
Trajectory identity on `singleBlackDriver P phi` (`P >= 2`): any surviving seed up to `K`
evolves identically to `L c_zero` on `p < 0` through `t <= K + 1`.
-/
theorem singleBlack_L_eq_L_zero (P phi K : Nat) (hP : 2 <= P) (s : Int -> Bool)
    (hsurv : SurvivesPinsUpTo (singleBlackDriver P phi) K s) :
    forall t : Nat, t <= K + 1 -> forall p : Int, p < 0 ->
      L (singleBlackDriver P phi) s t p = L c_zero s t p := by
  have hnoadj : forall t : Nat, t <= K ->
      singleBlackDriver P phi t = true -> singleBlackDriver P phi (t + 1) = false := by
    intro t _ hct
    exact singleBlackDriver_no_adjacent_black P phi hP t hct
  exact L_eq_L_zero_of_no_adjacent_black (singleBlackDriver P phi) K s hnoadj hsurv

/--
**Theorem L1e (`QP_bounded_iff_singleBlack_death`):**
At phase `phi = 0` and period `P >= 2`, bounded `Q_P` at width `W` and cycle horizon `M`
(`forall s, HasWidth W s -> exists k <= M, L c_zero s (P * k) (-1) = false`) is logically
equivalent (`↔`) to bounded death `¬ SurvivesPinsUpTo (singleBlackDriver P 0) (P * M) s`
for all seeds `s` of width `W`.
-/
theorem QP_bounded_iff_singleBlack_death (P W M : Nat) (hP : 2 <= P) :
    (forall s : Int -> Bool, HasWidth W s ->
      exists k : Nat, k <= M /\ L c_zero s (P * k) (-1) = false) ↔
    (forall s : Int -> Bool, HasWidth W s ->
      ¬ SurvivesPinsUpTo (singleBlackDriver P 0) (P * M) s) := by
  constructor
  · intro hQP s hw hsurv
    have hsamp := (singleBlack_survives_iff_L_zero P 0 (P * M) hP s).mp hsurv
    rcases hQP s hw with ⟨k, hkM, hfalse⟩
    have hle : P * k <= P * M := Nat.mul_le_mul_left P hkM
    have hmod : (P * k + 0) % P = 0 := by
      rw [Nat.add_zero, Nat.mul_mod_right]
    have htrue := hsamp (P * k) hle hmod
    rw [htrue] at hfalse
    contradiction
  · intro hdeath s hw
    refine Classical.byContradiction fun hno => ?_
    apply hdeath s hw
    rw [singleBlack_survives_iff_L_zero P 0 (P * M) hP s]
    intro t ht hmod
    rw [Nat.add_zero] at hmod
    have hdiv_le : t / P <= M := by
      have h1 : t / P <= (P * M) / P := Nat.div_le_div_right ht
      have h2 : (P * M) / P = M := Nat.mul_div_right M (by omega)
      omega
    have ht_eq : P * (t / P) = t := by
      have hd := Nat.div_add_mod t P
      rw [hmod, Nat.add_zero] at hd
      exact hd
    cases hval : L c_zero s t (-1)
    · exfalso
      apply hno
      refine ⟨t / P, hdiv_le, ?_⟩
      rw [ht_eq]
      exact hval
    · rfl

theorem shiftDriver_c_zero (d : Nat) : shiftDriver c_zero d = c_zero := rfl

/--
**Theorem L1f (`allPhase_singleBlack_from_phase0`):**
For any period `P >= 2`, phase `phi : Nat`, and alignment offset `d : Nat` with `(d + phi) % P = 0`,
if every seed of width `W + d` at phase `0` dies by `P * M`, then every seed of width `W` at
phase `phi` dies by `d + P * M`.
-/
theorem allPhase_singleBlack_from_phase0 (P phi d W M : Nat) (hP : 2 <= P)
    (hd : (d + phi) % P = 0)
    (h0 : forall s' : Int -> Bool, HasWidth (W + d) s' ->
      ¬ SurvivesPinsUpTo (singleBlackDriver P 0) (P * M) s') :
    forall s : Int -> Bool, HasWidth W s ->
      ¬ SurvivesPinsUpTo (singleBlackDriver P phi) (d + P * M) s := by
  intro s hw hsurv
  have hsamp := (singleBlack_survives_iff_L_zero P phi (d + P * M) hP s).mp hsurv
  have hw' : HasWidth (W + d) (iterStepSeed c_zero d s) := hasWidth_iterStepSeed d c_zero W s hw
  apply h0 (iterStepSeed c_zero d s) hw'
  rw [singleBlack_survives_iff_L_zero P 0 (P * M) hP (iterStepSeed c_zero d s)]
  intro t ht hmod
  rw [Nat.add_zero] at hmod
  have hL := L_iterStepSeed d c_zero s t (-1) (by omega)
  rw [shiftDriver_c_zero] at hL
  rw [hL]
  apply hsamp (t + d) (by omega)
  have h_eq : t + d + phi = t + (d + phi) := by omega
  rw [h_eq, Nat.add_mod, hmod, hd, Nat.add_zero, Nat.zero_mod]

-- ============================================================================
-- 2. Part 2: Amortized Cycle-Potential Reduction (Theorems L2a & L2b)
-- ============================================================================

/--
Amortized cycle-potential specification over a complete period-`P` cycle (`WORK_ORDER.md` §Part 2):
- `init_bound`: for any seed `s` of width `W`, `mu s <= g W`;
- `white_gap_bound`: `(i)` across the `P - 1` white steps of a cycle, `mu` rises by at most `A`;
- `cycle_net_decrease`: `(ii)–(iii)` across a complete surviving `P`-step cycle with
  `mu_min < mu`, `mu` decreases by at least `delta`;
- `floor_forces_death`: `(iv)` whenever `mu <= mu_min`, pin failure occurs within `K_min` steps.
-/
structure AmortizedCyclePotentialSpec (c : Nat -> Bool) (P A delta mu_min K_min : Nat)
    (g : Nat -> Nat) (mu : (Int -> Bool) -> Nat) : Prop where
  init_bound :
    forall (W : Nat) (s : Int -> Bool), HasWidth W s -> mu s <= g W
  white_gap_bound :
    forall (t : Nat) (s : Int -> Bool),
      SurvivesPinsUpTo c (t + P) s ->
      mu (iterStepSeed c (t + (P - 1)) s) <= mu (iterStepSeed c t s) + A
  cycle_net_decrease :
    forall (t : Nat) (s : Int -> Bool),
      SurvivesPinsUpTo c (t + P) s ->
      mu_min < mu (iterStepSeed c t s) ->
      mu (iterStepSeed c (t + P) s) + delta <= mu (iterStepSeed c t s)
  floor_forces_death :
    forall (t : Nat) (s : Int -> Bool),
      mu (iterStepSeed c t s) <= mu_min ->
      ¬ SurvivesPinsUpTo c (t + K_min) s

/-- Well-founded cycle-by-cycle descent along `v >= mu (iterStepSeed c t s)`. -/
theorem amortized_cycle_descent (c : Nat -> Bool) (P A delta mu_min K_min : Nat)
    (g : Nat -> Nat) (mu : (Int -> Bool) -> Nat)
    (hdelta : 1 <= delta)
    (hspec : AmortizedCyclePotentialSpec c P A delta mu_min K_min g mu) (v : Nat) :
    forall (t : Nat) (s : Int -> Bool),
      mu (iterStepSeed c t s) <= v ->
      ¬ SurvivesPinsUpTo c (t + P * v + K_min) s := by
  induction v with
  | zero =>
      intro t s hle hsurv
      have hfloor : mu (iterStepSeed c t s) <= mu_min := by omega
      have hfail := hspec.floor_forces_death t s hfloor
      have hsurv' : SurvivesPinsUpTo c (t + K_min) s :=
        survivesPinsUpTo_mono c (by omega) s hsurv
      exact hfail hsurv'
  | succ v ih =>
      intro t s hle hsurv
      have h_mul : P * (v + 1) = P * v + P := Nat.mul_succ P v
      by_cases hfloor : mu (iterStepSeed c t s) <= mu_min
      · have hfail := hspec.floor_forces_death t s hfloor
        have hsurv' : SurvivesPinsUpTo c (t + K_min) s :=
          survivesPinsUpTo_mono c (by omega) s hsurv
        exact hfail hsurv'
      · have hgt : mu_min < mu (iterStepSeed c t s) := by omega
        have hsurvP : SurvivesPinsUpTo c (t + P) s :=
          survivesPinsUpTo_mono c (by omega) s hsurv
        have hdec := hspec.cycle_net_decrease t s hsurvP hgt
        have hle' : mu (iterStepSeed c (t + P) s) <= v := by omega
        have hfail := ih (t + P) s hle'
        have h_eq : t + P + P * v + K_min = t + P * (v + 1) + K_min := by omega
        rw [h_eq] at hfail
        exact hfail hsurv

/--
**Theorem L2a (`amortized_cycle_potential_bounded_death`):**
Under `AmortizedCyclePotentialSpec c P A delta mu_min K_min g mu` with `1 <= delta`,
every seed `s` of width `W` fails a black-step pin by time `P * g W + K_min`.
-/
theorem amortized_cycle_potential_bounded_death (c : Nat -> Bool) (P A delta mu_min K_min : Nat)
    (g : Nat -> Nat) (mu : (Int -> Bool) -> Nat)
    (hdelta : 1 <= delta)
    (hspec : AmortizedCyclePotentialSpec c P A delta mu_min K_min g mu) (W : Nat) :
    forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c (P * g W + K_min) s := by
  intro s hw
  have hinit : mu (iterStepSeed c 0 s) <= g W := hspec.init_bound W s hw
  have hdesc := amortized_cycle_descent c P A delta mu_min K_min g mu hdelta hspec (g W) 0 s hinit
  have h_eq : 0 + P * g W + K_min = P * g W + K_min := by omega
  rwa [h_eq] at hdesc

/--
**Theorem L2b (`amortized_cycle_implies_boundedDeath`):**
Existence of an amortized cycle potential with `1 <= delta` implies `BoundedDeath c`.
-/
theorem amortized_cycle_implies_boundedDeath (c : Nat -> Bool) (P A delta mu_min K_min : Nat)
    (g : Nat -> Nat) (mu : (Int -> Bool) -> Nat)
    (hdelta : 1 <= delta)
    (hspec : AmortizedCyclePotentialSpec c P A delta mu_min K_min g mu) :
    BoundedDeath c := by
  intro W
  exact ⟨P * g W + K_min,
    amortized_cycle_potential_bounded_death c P A delta mu_min K_min g mu hdelta hspec W⟩

-- ============================================================================
-- 3. Zero-Boundary Black-Run Hollowing & Cycle Failure (Theorems L3a & L3b)
-- ============================================================================

theorem stepSeed_c_zero_zeroRow : stepSeed c_zero zeroRow = zeroRow := by
  funext p
  by_cases hp : p < 0
  · change L c_zero zeroRow 1 p = false
    rw [L_succ hp, L_zero (by omega), L_zero hp]
    by_cases hp1 : p + 1 < 0
    · rw [L_zero hp1]; rfl
    · rw [show p + 1 = 0 by omega, L_col0]; rfl
  · change L c_zero zeroRow 1 p = false
    simp [L, hp, c_zero]

theorem iterStepSeed_c_zero_zeroRow (n : Nat) : iterStepSeed c_zero n zeroRow = zeroRow := by
  induction n with
  | zero => rfl
  | succ n ih =>
      simp only [iterStepSeed, shiftDriver_c_zero, stepSeed_c_zero_zeroRow]
      exact ih

/--
**Theorem L3a (`blackRun_hollow_step`):**
On the zero-boundary left half-line `c_zero`, if `s` begins with a boundary black run of length
`r >= 2` (`s (-1) = ... = s (-r) = true` and `s (-(r+1)) = false`), then in one step the run
hollows out to `false` on `-1, ..., -(r-1)` with a black cell at `-r`, jumping the innermost
defect depth against `zeroRow` from `D_1 = 1` to `D_1' = r`.
-/
theorem blackRun_hollow_step (s : Int -> Bool) (r : Nat) (hr : 2 <= r)
    (hrun : forall m : Nat, 1 <= m -> m <= r -> s (-(m : Int)) = true)
    (hnext : s (-((r + 1 : Nat) : Int)) = false) :
    InnerDefect zeroRow s 1 /\ InnerDefect zeroRow (stepSeed c_zero s) r := by
  refine ⟨⟨by omega, ?_, ?_⟩, ⟨by omega, ?_, ?_⟩⟩
  · have hs1 : s (-((1 : Nat) : Int)) = true := hrun 1 (by omega) (by omega)
    change s (-((1 : Nat) : Int)) = !false
    rw [hs1]
    rfl
  · intro m hm1 hmlt
    omega
  · rw [stepSeed_neg_ge2 c_zero s r hr]
    have hs_r : s (-(r : Int)) = true := hrun r (by omega) (by omega)
    change xor (s (-((r + 1 : Nat) : Int))) (s (-(r : Int)) || s (-((r - 1 : Nat) : Int))) = !false
    rw [hnext, hs_r, Bool.true_or]
    rfl
  · intro m hm1 hmlt
    by_cases hm_eq : m = 1
    · subst hm_eq
      change stepSeed c_zero s (-1) = false
      rw [stepSeed_neg_one c_zero s]
      have hs2 : s (-((2 : Nat) : Int)) = true := hrun 2 (by omega) hr
      have hs1 : s (-((1 : Nat) : Int)) = true := hrun 1 (by omega) (by omega)
      have h_idx2 : (-2 : Int) = -((2 : Nat) : Int) := rfl
      have h_idx1 : (-1 : Int) = -((1 : Nat) : Int) := rfl
      rw [h_idx2, h_idx1, hs2, hs1]
      rfl
    · have hm2 : 2 <= m := by omega
      change stepSeed c_zero s (-(m : Int)) = false
      rw [stepSeed_neg_ge2 c_zero s m hm2]
      have hs_l : s (-((m + 1 : Nat) : Int)) = true := hrun (m + 1) (by omega) (by omega)
      have hs_m : s (-(m : Int)) = true := hrun m (by omega) (by omega)
      rw [hs_l, hs_m, Bool.true_or]
      rfl

/--
**Theorem L3b (`blackRun_gt_P_fails_cycle`):**
For any period `P >= 2` and any seed `s` whose boundary black run has length `r >= P + 1`
(`s (-1) = ... = s (-r) = true`, `s (-(r+1)) = false`), the hollowed white run keeps column `-1`
white at step `t = P` (`L c_zero s P (-1) = false`), so `s` fails the black-step pin at `t = P`
on `singleBlackDriver P 0`.
-/
theorem blackRun_gt_P_fails_cycle (P r : Nat) (s : Int -> Bool)
    (hP : 2 <= P) (hrP : P + 1 <= r)
    (hrun : forall m : Nat, 1 <= m -> m <= r -> s (-(m : Int)) = true)
    (hnext : s (-((r + 1 : Nat) : Int)) = false) :
    L c_zero s P (-1) = false /\ ¬ SurvivesPinsUpTo (singleBlackDriver P 0) P s := by
  have hhollow := (blackRun_hollow_step s r (by omega) hrun hnext).2
  have hdrift := innerDefect_iterStepSeed (P - 1) c_zero zeroRow (stepSeed c_zero s) r (by omega) hhollow
  rw [iterStepSeed_c_zero_zeroRow (P - 1)] at hdrift
  have hwhite1 : iterStepSeed c_zero (P - 1) (stepSeed c_zero s) (-1) = false :=
    hdrift.2.2 1 (by omega) (by omega)
  have h_iter_eq : iterStepSeed c_zero P s = iterStepSeed c_zero (P - 1) (stepSeed c_zero s) := by
    obtain ⟨k, hk⟩ : exists k, P = k + 1 := ⟨P - 1, by omega⟩
    rw [hk, show k + 1 - 1 = k by omega]
    rfl
  have hL_iter := L_iterStepSeed P c_zero s 0 (-1) (by omega)
  rw [shiftDriver_c_zero, Nat.zero_add] at hL_iter
  have hL0 : L c_zero (iterStepSeed c_zero P s) 0 (-1) =
      iterStepSeed c_zero P s (-1) := L_zero (by omega)
  have hLP : L c_zero s P (-1) = false := by
    rw [<- hL_iter, hL0, h_iter_eq, hwhite1]
  refine ⟨hLP, ?_⟩
  intro hsurv
  have hsamp := (singleBlack_survives_iff_L_zero P 0 P hP s).mp hsurv
  have hmod : (P + 0) % P = 0 := by
    rw [Nat.add_zero, Nat.mod_self]
  have htrue := hsamp P (by omega) hmod
  rw [htrue] at hLP
  contradiction

-- ============================================================================
-- 4. Defect-Span Cycle Growth & Barrier Survivor Existence (Theorems L4a & L4b)
-- ============================================================================

/--
**Theorem L4a (`defectSpan_cycle_increases`):**
For every period `P >= 2`, initial exact width `W >= 1`, and cycle index `k : Nat`,
any seed `s` with `HasExactWidth W s` that survives up to `t = P * k` on `singleBlackDriver P 0`
has its innermost defect pinned at depth `1` (`InnerDefect zeroRow ... 1`) while its outermost
defect sits at exact depth `W + P * k` (`HasExactWidth (W + P * k) ...`).
-/
theorem defectSpan_cycle_increases (P W k : Nat) (s : Int -> Bool)
    (hP : 2 <= P) (hW : 1 <= W) (hex : HasExactWidth W s)
    (hsurv : SurvivesPinsUpTo (singleBlackDriver P 0) (P * k) s) :
    InnerDefect zeroRow (iterStepSeed c_zero (P * k) s) 1 /\
    HasExactWidth (W + P * k) (iterStepSeed c_zero (P * k) s) := by
  refine ⟨⟨by omega, ?_, ?_⟩, iterStepSeed_deepest_black (P * k) c_zero W s hW hex⟩
  · have hsamp := (singleBlack_survives_iff_L_zero P 0 (P * k) hP s).mp hsurv
    have hmod : (P * k + 0) % P = 0 := by
      rw [Nat.add_zero, Nat.mul_mod_right]
    have htrue := hsamp (P * k) (by omega) hmod
    have hL_iter := L_iterStepSeed (P * k) c_zero s 0 (-1) (by omega)
    rw [shiftDriver_c_zero, Nat.zero_add] at hL_iter
    have hL0 : L c_zero (iterStepSeed c_zero (P * k) s) 0 (-1) =
        iterStepSeed c_zero (P * k) s (-1) := L_zero (by omega)
    have hs1 : iterStepSeed c_zero (P * k) s (-1) = true := by
      rw [<- hL0, hL_iter, htrue]
    change iterStepSeed c_zero (P * k) s (-1) = !false
    rw [hs1]
    rfl
  · intro m hm1 hmlt
    omega

/--
**Theorem L4b (`exists_survivor_of_width_add_two`):**
For every driver `c : Nat -> Bool` and every horizon `K : Nat`, there exists a left-half seed
`s` of exact width `K + 2` (`HasExactWidth (K + 2) s`) that satisfies `SurvivesPinsUpTo c K s`.
-/
theorem exists_survivor_of_width_add_two (c : Nat -> Bool) (K : Nat) :
    exists s : Int -> Bool, HasExactWidth (K + 2) s /\ SurvivesPinsUpTo c K s := by
  obtain ⟨s, hs0, hs1, hx⟩ :=
    Rule30DrivenLeft.barrier_exists (c := c) (fun t => !c (t + 1)) (n := K + 2) (by omega)
  refine ⟨s, ⟨hs1, ?_⟩, ?_⟩
  · intro m hm
    exact hs0 (-(m : Int)) (by omega)
  · intro t ht _
    exact hx t (by omega)

#print axioms stepSeed_eq_zero_of_pin
#print axioms L_eq_L_zero_of_no_adjacent_black
#print axioms survivesPinsUpTo_iff_L_zero
#print axioms singleBlackDriver_no_adjacent_black
#print axioms singleBlack_survives_iff_L_zero
#print axioms singleBlack_L_eq_L_zero
#print axioms QP_bounded_iff_singleBlack_death
#print axioms allPhase_singleBlack_from_phase0
#print axioms amortized_cycle_potential_bounded_death
#print axioms amortized_cycle_implies_boundedDeath
#print axioms blackRun_hollow_step
#print axioms blackRun_gt_P_fails_cycle
#print axioms defectSpan_cycle_increases
#print axioms exists_survivor_of_width_add_two

end FVLT.S4lZeroBoundaryPotentialsV1
