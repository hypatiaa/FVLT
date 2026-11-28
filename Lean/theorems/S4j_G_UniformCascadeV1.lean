import S4i_G_UniformLatchV1

/-!
# S4j-G: Universal All-r Top-Row Latch Family, Multi-Row Latch Propagation, and Width-Shift Laws

Formalizes the four universal (all-period `P`) theorem families for Study `S4j-G` (`#1143`)
against theorem library `v4` (`#1145`):

1. **Master Depth-`k` Single-Cell Barrier (`topRow_latch_of_true`, Theorem J1):**
   For any driver `c : Nat -> Bool` and any seeds `s0, s1 : Int -> Bool` whose `t = 1` rows
   agree on `p < 0`, a shared black cell `s0 (-(k+1)) = true` and `s1 (-(k+1)) = true`
   (`k >= 1`) masks `s (-k)` in `s_neg_succ_step`, forcing
   `s0 (-(k+2)) = s1 (-(k+2)) = !L c s0 1 (-(k+1))` and
   `forall m : Nat, s0 (-(m + k + 1)) = s1 (-(m + k + 1))`.

2. **Complementarity Latch & All-`r` White-Run Latch Family
   (`topRow_latch_of_complement`, `topRow_run_latch_all_r`, Theorems J2a & J2b):**
   - Whenever `s_i (-(k+1)) = !s_i (-k)` for `i in {0, 1}` (`k >= 1`) and
     `L c s0 1 (-(k+1)) = false`, `(!b || b) = true` creates a shared black barrier
     `s0 (-(k+2)) = s1 (-(k+2)) = true` and latches all depths `>= k + 2`.
   - For **every** white-run length `r : Nat` and `c 0 = false`, if row `t = 1` satisfies
     `(forall j < r, L c s0 1 (-(j+1)) = false) /\ L c s0 1 (-(r+1)) = true /\ L c s0 1 (-(r+2)) = false`,
     then `s_i (-(j+1)) = s_i (-1)` for all `j <= r`, `s_i (-(r+2)) = !s_i (-1)`,
     `s0 (-(r+3)) = s1 (-(r+3)) = true`, and `forall m : Nat, s0 (-(m + r + 3)) = s1 (-(m + r + 3))`.
     This unifies `topRow_or_latch_depth3` (`r = 0`) and `topRow_blackRun_latch_depth4` (`r = 1`)
     into a single all-`r` theorem across arbitrary periods `P`.

3. **Arbitrary-Horizon `T` Multi-Row Latch Propagation (`multiRow_latch_propagation`, Theorem J3):**
   For every driver `c : Nat -> Bool`, every time horizon `T : Nat`, every depth `k >= 1`,
   and any seeds `s0, s1 : Int -> Bool`, if `s0, s1` agree on row `T` at all depths `>= k`
   and agree on the two adjacent columns `-k` and `-(k+1)` across all rows `t <= T`, then
   `forall m : Nat, forall t <= T, L c s0 t (-(m + k)) = L c s1 t (-(m + k))`.

4. **Finite-Cut Width Preservation & Exact Edge Propagation Under `iterStepSeed`
   (`latch_preserves_width_bound`, `iterStepSeed_deepest_black`, `bounded_death_period_step`, Theorem J4):**
   - `latch_preserves_width_bound`: A depth-`k` latch preserves `HasWidth W` for all `W >= k`.
   - `iterStepSeed_deepest_black`: Under `n` forward steps `iterStepSeed c n`, a seed with
     deepest black cell at depth `W >= 1` (`HasExactWidth W`) maps to a seed with deepest
     black cell at exact depth `W + n` (`HasExactWidth (W + n)`).
   - `bounded_death_period_step`: For every `P`-periodic driver `c`, `iterStepSeed c P` embeds
     width-`W` survivors at horizon `K + P` into width-`(W + P)` survivors at horizon `K`,
     proving `D_c(W) <= D_c(W + P) + P`.
-/

namespace FVLT.S4jUniformCascadeV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1
open FVLT.S4hCantorShiftV1
open FVLT.S4iUniformLatchV1

theorem or_neg_self (b : Bool) : ((!b) || b) = true := by
  cases b <;> rfl

theorem xor_true_right (a : Bool) : xor a true = !a := by
  cases a <;> rfl

theorem xor_false_left (a : Bool) : xor false a = a := by
  cases a <;> rfl

theorem xor_true_left (a : Bool) : xor true a = !a := by
  cases a <;> rfl

-- ============================================================================
-- 1. Master Depth-k Single-Cell Barrier Theorem (Theorem J1)
-- ============================================================================

/--
**Theorem J1 (`topRow_latch_of_true`):**
For every driver `c : Nat -> Bool`, every `a : Nat` (representing depth `k = a + 1 >= 1`),
and any two seeds `s0, s1 : Int -> Bool` agreeing on row `t = 1` for `p < 0`,
if both seeds have `s0 (-(a + 2)) = true` and `s1 (-(a + 2)) = true`, then
`s0 (-(a + 3)) = s1 (-(a + 3)) = !L c s0 1 (-(a + 2))` and
`forall m : Nat, s0 (-(a + 1 + m + 1)) = s1 (-(a + 1 + m + 1))`.
-/
theorem topRow_latch_of_true (c : Nat -> Bool) (s0 s1 : Int -> Bool) (a : Nat)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (ht0 : s0 (-((a + 2 : Nat) : Int)) = true)
    (ht1 : s1 (-((a + 2 : Nat) : Int)) = true) :
    s0 (-((a + 3 : Nat) : Int)) = !L c s0 1 (-((a + 2 : Nat) : Int)) /\
    s1 (-((a + 3 : Nat) : Int)) = !L c s0 1 (-((a + 2 : Nat) : Int)) /\
    (forall m : Nat, s0 (-((a + 1 + m + 1 : Nat) : Int)) = s1 (-((a + 1 + m + 1 : Nat) : Int))) := by
  have hs0_next := s_neg_succ_step c s0 a
  have hs1_next := s_neg_succ_step c s1 a
  rw [ht0, Bool.true_or, xor_true_right] at hs0_next
  have hY_a : L c s1 1 (-((a + 2 : Nat) : Int)) = L c s0 1 (-((a + 2 : Nat) : Int)) := by
    have h := (hY (a + 1)).symm
    have hidx : a + 1 + 1 = a + 2 := by omega
    rwa [hidx] at h
  rw [ht1, Bool.true_or, xor_true_right, hY_a] at hs1_next
  refine ⟨hs0_next, hs1_next, ?_⟩
  have ha1 : s0 (-((a + 1 + 1 : Nat) : Int)) = s1 (-((a + 1 + 1 : Nat) : Int)) := by
    have hidx : a + 1 + 1 = a + 2 := by omega
    rw [hidx, ht0, ht1]
  have ha2 : s0 (-((a + 1 + 2 : Nat) : Int)) = s1 (-((a + 1 + 2 : Nat) : Int)) := by
    have hidx : a + 1 + 2 = a + 3 := by omega
    rw [hidx, hs0_next, hs1_next]
  intro m
  exact (topRow_agree_from c s0 s1 (a + 1) hY ha1 ha2 m).1

-- ============================================================================
-- 2. Complementarity Latch & All-r White-Run Latch Family (Theorems J2a, J2b)
-- ============================================================================

/--
**Theorem J2a (`topRow_latch_of_complement`):**
For every driver `c : Nat -> Bool` and any `a : Nat` (depth `k = a + 1 >= 1`),
if `s0, s1` agree on row `t = 1` (`p < 0`), satisfy `s_i (-(a + 2)) = !s_i (-(a + 1))`
for `i in {0, 1}`, and have `L c s0 1 (-(a + 2)) = false`, then
`s0 (-(a + 3)) = s1 (-(a + 3)) = true` and
`forall m : Nat, s0 (-(a + 2 + m + 1)) = s1 (-(a + 2 + m + 1))`.
-/
theorem topRow_latch_of_complement (c : Nat -> Bool) (s0 s1 : Int -> Bool) (a : Nat)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (hcomp0 : s0 (-((a + 2 : Nat) : Int)) = !s0 (-((a + 1 : Nat) : Int)))
    (hcomp1 : s1 (-((a + 2 : Nat) : Int)) = !s1 (-((a + 1 : Nat) : Int)))
    (hl_false : L c s0 1 (-((a + 2 : Nat) : Int)) = false) :
    s0 (-((a + 3 : Nat) : Int)) = true /\
    s1 (-((a + 3 : Nat) : Int)) = true /\
    (forall m : Nat, s0 (-((a + 2 + m + 1 : Nat) : Int)) = s1 (-((a + 2 + m + 1 : Nat) : Int))) := by
  have hs0_next := s_neg_succ_step c s0 a
  have hs1_next := s_neg_succ_step c s1 a
  have hY_a : L c s1 1 (-((a + 2 : Nat) : Int)) = false := by
    have h := (hY (a + 1)).symm
    have hidx : a + 1 + 1 = a + 2 := by omega
    rw [hidx] at h
    exact h.trans hl_false
  rw [hl_false, hcomp0, or_neg_self, xor_false_left] at hs0_next
  rw [hY_a, hcomp1, or_neg_self, xor_false_left] at hs1_next
  have hidx2 : a + 1 + 2 = a + 3 := by omega
  have ht0 : s0 (-((a + 1 + 2 : Nat) : Int)) = true := by rwa [hidx2]
  have ht1 : s1 (-((a + 1 + 2 : Nat) : Int)) = true := by rwa [hidx2]
  have hlatch := topRow_latch_of_true c s0 s1 (a + 1) hY ht0 ht1
  refine ⟨hs0_next, hs1_next, ?_⟩
  intro m
  have h := hlatch.2.2 m
  have hidx_m : a + 1 + 1 + m + 1 = a + 2 + m + 1 := by omega
  rwa [hidx_m] at h

/--
Replication of `s (-1)` across any initial run of `r` white (`false`) cells on row `t = 1`.
-/
theorem topRow_white_run_replicate (c : Nat -> Bool) (s : Int -> Bool) (r : Nat)
    (hc0 : c 0 = false)
    (hrun : forall i : Nat, i < r -> L c s 1 (-((i + 1 : Nat) : Int)) = false) :
    forall j : Nat, j <= r -> s (-((j + 1 : Nat) : Int)) = s (-1)
  | 0, _ => rfl
  | 1, hj => by
      have h0 : 0 < r := by omega
      have hl1 : L c s 1 (-1) = false := hrun 0 h0
      have hp1 := s_neg_two_of_c0_false c s hc0
      have h_idx : -((1 + 1 : Nat) : Int) = -2 := rfl
      rw [h_idx, hp1, hl1, xor_false_left]
  | j + 2, hj => by
      have ih1 := topRow_white_run_replicate c s r hc0 hrun (j + 1) (by omega)
      have ih0 := topRow_white_run_replicate c s r hc0 hrun j (by omega)
      have hstep := s_neg_succ_step c s j
      have hlt : j + 1 < r := by omega
      have hl_false := hrun (j + 1) hlt
      have h_idx2 : j + 1 + 1 = j + 2 := by omega
      rw [h_idx2] at hl_false ih1
      rw [hl_false, ih1, ih0, Bool.or_self, xor_false_left] at hstep
      have h_idx3 : j + 2 + 1 = j + 3 := by omega
      rwa [h_idx3]

/--
Flip of `s (-(r+2))` to `!s (-(r+1))` at the end of a length-`r` white run when `L c s 1 (-(r+1)) = true`.
-/
theorem topRow_white_run_flip (c : Nat -> Bool) (s : Int -> Bool) (r : Nat)
    (hc0 : c 0 = false)
    (hrun : forall i : Nat, i < r -> L c s 1 (-((i + 1 : Nat) : Int)) = false)
    (htrue : L c s 1 (-((r + 1 : Nat) : Int)) = true) :
    s (-((r + 2 : Nat) : Int)) = !s (-((r + 1 : Nat) : Int)) := by
  cases r with
  | zero =>
      have hp1 := s_neg_two_of_c0_false c s hc0
      have h_idx2 : -((0 + 2 : Nat) : Int) = -2 := rfl
      have h_idx1 : -((0 + 1 : Nat) : Int) = -1 := rfl
      rw [h_idx1] at htrue
      rw [h_idx2, h_idx1, hp1, htrue, xor_true_left]
  | succ r' =>
      have hstep := s_neg_succ_step c s r'
      have hrep1 := topRow_white_run_replicate c s (r' + 1) hc0 hrun (r' + 1) (by omega)
      have hrep0 := topRow_white_run_replicate c s (r' + 1) hc0 hrun r' (by omega)
      have h_idx2 : r' + 1 + 1 = r' + 2 := by omega
      have h_idx3 : r' + 1 + 2 = r' + 3 := by omega
      rw [h_idx2] at htrue hrep1
      rw [htrue, hrep1, hrep0, Bool.or_self, xor_true_left] at hstep
      rw [h_idx3, h_idx2, hrep1]
      exact hstep

/--
**Theorem J2b (`topRow_run_latch_all_r`):**
Universal All-`r` Top-Row White-Run Latch Family (unifying Theorem U1a at `r = 0`
and Theorem U1b at `r = 1` across all periods `P`):
For every driver `c : Nat -> Bool` with `c 0 = false`, every white-run length `r : Nat`,
and any two seeds `s0, s1 : Int -> Bool` agreeing on row `t = 1` for `p < 0`,
if row `t = 1` starts with `false^r true false` on columns `-1, ..., -(r+2)`, then
`s0 (-(r+3)) = s1 (-(r+3)) = true` and
`forall m : Nat, s0 (-(r + 2 + m + 1)) = s1 (-(r + 2 + m + 1))`.
-/
theorem topRow_run_latch_all_r (c : Nat -> Bool) (s0 s1 : Int -> Bool) (r : Nat)
    (hc0 : c 0 = false)
    (hY : forall m : Nat, L c s0 1 (-((m + 1 : Nat) : Int)) = L c s1 1 (-((m + 1 : Nat) : Int)))
    (hrun : forall i : Nat, i < r -> L c s0 1 (-((i + 1 : Nat) : Int)) = false)
    (htrue : L c s0 1 (-((r + 1 : Nat) : Int)) = true)
    (hfalse : L c s0 1 (-((r + 2 : Nat) : Int)) = false) :
    s0 (-((r + 3 : Nat) : Int)) = true /\
    s1 (-((r + 3 : Nat) : Int)) = true /\
    (forall m : Nat, s0 (-((r + 2 + m + 1 : Nat) : Int)) = s1 (-((r + 2 + m + 1 : Nat) : Int))) := by
  have hrun1 : forall i : Nat, i < r -> L c s1 1 (-((i + 1 : Nat) : Int)) = false := by
    intro i hi
    exact (hY i).symm.trans (hrun i hi)
  have htrue1 : L c s1 1 (-((r + 1 : Nat) : Int)) = true :=
    (hY r).symm.trans htrue
  have hcomp0 := topRow_white_run_flip c s0 r hc0 hrun htrue
  have hcomp1 := topRow_white_run_flip c s1 r hc0 hrun1 htrue1
  exact topRow_latch_of_complement c s0 s1 r hY hcomp0 hcomp1 hfalse

-- ============================================================================
-- 3. Arbitrary-Horizon T Multi-Row Latch Propagation (Theorem J3)
-- ============================================================================

/--
Left-inversion step at any time `t : Nat` and any depth `n >= 2` (from `L_left`).
-/
theorem L_left_inversion_ge2 (c : Nat -> Bool) (s : Int -> Bool) (t n : Nat) (hn : 2 <= n) :
    L c s t (-((n + 1 : Nat) : Int)) =
      xor (L c s (t + 1) (-(n : Int)))
          (L c s t (-(n : Int)) || L c s t (-((n - 1 : Nat) : Int))) := by
  have hp : (-(n : Int)) < 0 := by omega
  have h := L_left (c := c) (s := s) t (p := -(n : Int)) hp
  have h1 : -(n : Int) - 1 = -((n + 1 : Nat) : Int) := by omega
  have h2 : -(n : Int) + 1 = -((n - 1 : Nat) : Int) := by omega
  rw [h1, h2] at h
  exact h

private theorem multiRow_downward_step (c : Nat -> Bool) (s0 s1 : Int -> Bool)
    (T n : Nat) (hn : 2 <= n)
    (hT : L c s0 T (-((n + 1 : Nat) : Int)) = L c s1 T (-((n + 1 : Nat) : Int)))
    (hcol_n : forall t : Nat, t <= T -> L c s0 t (-(n : Int)) = L c s1 t (-(n : Int)))
    (hcol_nm1 : forall t : Nat, t <= T -> L c s0 t (-((n - 1 : Nat) : Int)) = L c s1 t (-((n - 1 : Nat) : Int))) :
    forall d : Nat, d <= T -> L c s0 (T - d) (-((n + 1 : Nat) : Int)) = L c s1 (T - d) (-((n + 1 : Nat) : Int))
  | 0, _ => by simpa using hT
  | d + 1, hd => by
      have ih := multiRow_downward_step c s0 s1 T n hn hT hcol_n hcol_nm1 d (by omega)
      have h_succ : T - (d + 1) + 1 = T - d := by omega
      have hinv0 := L_left_inversion_ge2 c s0 (T - (d + 1)) n hn
      have hinv1 := L_left_inversion_ge2 c s1 (T - (d + 1)) n hn
      have hle1 : T - d <= T := by omega
      have hle0 : T - (d + 1) <= T := by omega
      rw [h_succ] at hinv0 hinv1
      have h_top := hcol_n (T - d) hle1
      have h_mid := hcol_n (T - (d + 1)) hle0
      have h_rgt := hcol_nm1 (T - (d + 1)) hle0
      rw [hinv0, hinv1, h_top, h_mid, h_rgt]

/--
**Theorem J3 (`multiRow_latch_propagation`):**
For every driver `c : Nat -> Bool`, every time horizon `T : Nat`, every depth `k >= 1`,
and any two seeds `s0, s1 : Int -> Bool`:
If `s0` and `s1` agree on row `T` for all depths `>= k` and agree on the two adjacent
columns `-k` and `-(k+1)` for all rows `t <= T`, then they agree on `L c s_i t (-(m + k))`
for all `m : Nat` and all `t <= T`.
-/
theorem multiRow_latch_propagation (c : Nat -> Bool) (s0 s1 : Int -> Bool)
    (T k : Nat) (hk : 1 <= k)
    (hrowT : forall m : Nat, L c s0 T (-((m + k : Nat) : Int)) = L c s1 T (-((m + k : Nat) : Int)))
    (hcol0 : forall t : Nat, t <= T -> L c s0 t (-(k : Int)) = L c s1 t (-(k : Int)))
    (hcol1 : forall t : Nat, t <= T -> L c s0 t (-((k + 1 : Nat) : Int)) = L c s1 t (-((k + 1 : Nat) : Int))) :
    forall m : Nat, forall t : Nat, t <= T ->
      L c s0 t (-((m + k : Nat) : Int)) = L c s1 t (-((m + k : Nat) : Int))
  | 0, t, ht => by
      have h0 : ((0 + k : Nat) : Int) = (k : Int) := by omega
      rw [h0]
      exact hcol0 t ht
  | 1, t, ht => by
      have h1 : ((1 + k : Nat) : Int) = ((k + 1 : Nat) : Int) := by omega
      rw [h1]
      exact hcol1 t ht
  | m + 2, t, ht => by
      have ih0 := multiRow_latch_propagation c s0 s1 T k hk hrowT hcol0 hcol1 m
      have ih1 := multiRow_latch_propagation c s0 s1 T k hk hrowT hcol0 hcol1 (m + 1)
      have hn : 2 <= m + 1 + k := by omega
      have hT_step := hrowT (m + 2)
      have h_idx2 : -((m + 2 + k : Nat) : Int) = -((m + 1 + k + 1 : Nat) : Int) := by omega
      have h_idx0 : -((m + 1 + k - 1 : Nat) : Int) = -((m + k : Nat) : Int) := by omega
      rw [h_idx2] at hT_step
      have ih0' : forall t' : Nat, t' <= T ->
          L c s0 t' (-((m + 1 + k - 1 : Nat) : Int)) = L c s1 t' (-((m + 1 + k - 1 : Nat) : Int)) := by
        intro t' ht'
        rw [h_idx0]
        exact ih0 t' ht'
      have hdown := multiRow_downward_step c s0 s1 T (m + 1 + k) hn hT_step ih1 ih0' (T - t) (by omega)
      have h_sub : T - (T - t) = t := by omega
      rw [h_sub] at hdown
      rw [h_idx2]
      exact hdown

-- ============================================================================
-- 4. Finite-Cut Width Preservation & Exact Edge Propagation (Theorem J4)
-- ============================================================================

/-- `s` is supported within left-half width `W` (`s (-m) = false` for all `m > W`). -/
def HasWidth (W : Nat) (s : Int -> Bool) : Prop :=
  forall m : Nat, W < m -> s (-(m : Int)) = false

/-- `s` has its deepest left-half black cell at exact depth `W`. -/
def HasExactWidth (W : Nat) (s : Int -> Bool) : Prop :=
  s (-(W : Int)) = true /\ HasWidth W s

/-- `s` satisfies all black-step pins up to time `K`. -/
def SurvivesPinsUpTo (c : Nat -> Bool) (K : Nat) (s : Int -> Bool) : Prop :=
  forall t : Nat, t <= K -> c t = true -> L c s t (-1) = !c (t + 1)

/--
**Theorem J4a (`latch_preserves_width_bound`):**
Whenever two seeds `s0, s1` agree at all depths `>= k`, they have the exact same
finite support width bound for every cut width `W >= k`.
-/
theorem latch_preserves_width_bound (s0 s1 : Int -> Bool) (k W : Nat) (hkW : k <= W)
    (hlatch : forall m : Nat, s0 (-((m + k : Nat) : Int)) = s1 (-((m + k : Nat) : Int))) :
    HasWidth W s0 ↔ HasWidth W s1 := by
  constructor
  · intro hw0 m hm
    have h_eq := hlatch (m - k)
    have h_idx : -((m - k + k : Nat) : Int) = -(m : Int) := by omega
    rw [h_idx] at h_eq
    rw [<- h_eq]
    exact hw0 m hm
  · intro hw1 m hm
    have h_eq := hlatch (m - k)
    have h_idx : -((m - k + k : Nat) : Int) = -(m : Int) := by omega
    rw [h_idx] at h_eq
    rw [h_eq]
    exact hw1 m hm

/-- One forward step `stepSeed c s` increases left-half width bound by at most `+1`. -/
theorem hasWidth_stepSeed (c : Nat -> Bool) (W : Nat) (s : Int -> Bool)
    (hw : HasWidth W s) :
    HasWidth (W + 1) (stepSeed c s) := by
  intro m hm
  have hp : (-(m : Int)) < 0 := by omega
  have h1 : (-(m : Int)) - 1 < 0 := by omega
  have h2 : (-(m : Int)) + 1 < 0 := by omega
  have hstep : stepSeed c s (-(m : Int)) =
      xor (s (-(m : Int) - 1)) (s (-(m : Int)) || s (-(m : Int) + 1)) := by
    change L c s 1 (-(m : Int)) = _
    rw [L_succ hp, L_zero h1, L_zero hp, L_zero h2]
    rfl
  have idx1 : -(m : Int) - 1 = -((m + 1 : Nat) : Int) := by omega
  have idx2 : -(m : Int) + 1 = -((m - 1 : Nat) : Int) := by omega
  rw [idx1, idx2, hw (m + 1) (by omega), hw m (by omega), hw (m - 1) (by omega)] at hstep
  exact hstep

/-- `n` forward steps `iterStepSeed c n s` increase left-half width bound from `W` to `W + n`. -/
theorem hasWidth_iterStepSeed (n : Nat) :
    forall (c : Nat -> Bool) (W : Nat) (s : Int -> Bool),
      HasWidth W s -> HasWidth (W + n) (iterStepSeed c n s) := by
  induction n with
  | zero =>
      intro c W s hw
      have h0 : W + 0 = W := by omega
      rw [h0]
      exact hw
  | succ n ih =>
      intro c W s hw
      simp only [iterStepSeed]
      have hw1 : HasWidth (W + 1) (stepSeed c s) := hasWidth_stepSeed c W s hw
      have h_ih := ih (shiftDriver c 1) (W + 1) (stepSeed c s) hw1
      have h_add : W + 1 + n = W + (n + 1) := by omega
      rwa [h_add] at h_ih

/-- One forward step moves the deepest left-half black cell from `W >= 1` to `W + 1`. -/
theorem stepSeed_deepest_black (c : Nat -> Bool) (W : Nat) (s : Int -> Bool)
    (hW : 1 <= W) (hex : HasExactWidth W s) :
    HasExactWidth (W + 1) (stepSeed c s) := by
  refine ⟨?_, hasWidth_stepSeed c W s hex.2⟩
  have hp : (-((W + 1 : Nat) : Int)) < 0 := by omega
  have h1 : (-((W + 1 : Nat) : Int)) - 1 < 0 := by omega
  have h2 : (-((W + 1 : Nat) : Int)) + 1 < 0 := by omega
  have hstep : stepSeed c s (-((W + 1 : Nat) : Int)) =
      xor (s (-((W + 1 : Nat) : Int) - 1))
          (s (-((W + 1 : Nat) : Int)) || s (-((W + 1 : Nat) : Int) + 1)) := by
    change L c s 1 (-((W + 1 : Nat) : Int)) = _
    rw [L_succ hp, L_zero h1, L_zero hp, L_zero h2]
    rfl
  have idx1 : -((W + 1 : Nat) : Int) - 1 = -((W + 2 : Nat) : Int) := by omega
  have idx2 : -((W + 1 : Nat) : Int) + 1 = -(W : Int) := by omega
  rw [idx1, idx2, hex.2 (W + 2) (by omega), hex.2 (W + 1) (by omega), hex.1] at hstep
  exact hstep

/--
**Theorem J4b (`iterStepSeed_deepest_black`):**
For every driver `c : Nat -> Bool`, every `n : Nat`, and every seed `s` with deepest
left-half black cell at depth `W >= 1`, the `n`-step forward evolution `iterStepSeed c n s`
has its deepest black cell at exact depth `W + n`.
-/
theorem iterStepSeed_deepest_black (n : Nat) :
    forall (c : Nat -> Bool) (W : Nat) (s : Int -> Bool),
      1 <= W -> HasExactWidth W s -> HasExactWidth (W + n) (iterStepSeed c n s) := by
  induction n with
  | zero =>
      intro c W s _ hex
      have h0 : W + 0 = W := by omega
      rwa [h0]
  | succ n ih =>
      intro c W s hW hex
      simp only [iterStepSeed]
      have hex1 := stepSeed_deepest_black c W s hW hex
      have h_ih := ih (shiftDriver c 1) (W + 1) (stepSeed c s) (by omega) hex1
      have h_add : W + 1 + n = W + (n + 1) := by omega
      rwa [h_add] at h_ih

/-- Semigroup property of `L` under `iterStepSeed c d`. -/
theorem L_iterStepSeed (d : Nat) :
    forall (c : Nat -> Bool) (s : Int -> Bool) (t : Nat) (p : Int),
      p <= 0 -> L (shiftDriver c d) (iterStepSeed c d s) t p = L c s (t + d) p := by
  induction d with
  | zero =>
      intro c s t p _
      have hshift : shiftDriver c 0 = c := by
        funext k
        simp [shiftDriver]
      rw [hshift]
      rfl
  | succ d ih =>
      intro c s t p hp
      simp only [iterStepSeed]
      have h1 := ih (shiftDriver c 1) (stepSeed c s) t p hp
      have h2 := L_stepSeed c s (t + d) p hp
      have hshift : shiftDriver (shiftDriver c 1) d = shiftDriver c (d + 1) := by
        rw [shiftDriver_add c 1 d, show 1 + d = d + 1 by omega]
      rw [hshift] at h1
      rw [h1, h2]
      have h_add : t + d + 1 = t + (d + 1) := by omega
      rw [h_add]

/--
**Theorem J4c (`bounded_death_period_step`):**
For every period `P : Nat` and `P`-periodic driver `c`, if every seed of width `W + P`
fails a black-step pin by time `K`, then every seed of width `W` fails a black-step pin
by time `K + P` (formally establishing `D_c(W) <= D_c(W + P) + P`).
-/
theorem bounded_death_period_step (P W K : Nat) (c : Nat -> Bool)
    (hper : forall t : Nat, c (t + P) = c t)
    (hdeath : forall s' : Int -> Bool, HasWidth (W + P) s' -> ¬ SurvivesPinsUpTo c K s') :
    forall s : Int -> Bool, HasWidth W s -> ¬ SurvivesPinsUpTo c (K + P) s := by
  intro s hw hsurv
  have hw' : HasWidth (W + P) (iterStepSeed c P s) := hasWidth_iterStepSeed P c W s hw
  apply hdeath (iterStepSeed c P s) hw'
  intro t ht hct
  have hshift : shiftDriver c P = c := by
    funext k
    exact hper k
  have hL := L_iterStepSeed P c s t (-1) (by omega)
  rw [hshift] at hL
  have hctP : c (t + P) = true := (hper t).trans hct
  have hnext : c (t + P + 1) = c (t + 1) := by
    have h_eq : t + P + 1 = (t + 1) + P := by omega
    rw [h_eq]
    exact hper (t + 1)
  rw [hL, hsurv (t + P) (by omega) hctP, hnext]

#print axioms topRow_latch_of_true
#print axioms topRow_latch_of_complement
#print axioms topRow_run_latch_all_r
#print axioms multiRow_latch_propagation
#print axioms latch_preserves_width_bound
#print axioms iterStepSeed_deepest_black
#print axioms bounded_death_period_step

end FVLT.S4jUniformCascadeV1
