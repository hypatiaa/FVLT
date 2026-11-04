import FVLTS4gLeftScreenV1
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Fintype.BigOperators

/-!
S4g T1: count the black-centre pin constraints on a finite initial left screen.
The first equivalence uses WHITE OUTPUT coordinates of prefixTrace.
A separate triangular argument below proves that WHITE INITIAL SEED
coordinates also parameterize the pinned rows; the two maps are distinct.
The screen has width at most W; zero and leading-zero rows are included.
No claim of a nonzero seed with exact support width W is made.
-/

namespace FVLT.S4gForcedBitCountV1

open FVLT.S4gLeftScreenV1

noncomputable section

abbrev WhiteIndex (c : Nat → Bool) (W : Nat) := {i : Fin W // c i.val = false}

def whiteCount (c : Nat → Bool) (W : Nat) : Nat :=
  Fintype.card (WhiteIndex c W)

abbrev BlackPins (c : Nat → Bool) (W : Nat) (w : Fin W → Bool) : Prop :=
  ∀ i : Fin W, c i.val = true → w i = !(c (i.val + 1))

abbrev PinnedOutputs (c : Nat → Bool) (W : Nat) :=
  {w : Fin W → Bool // BlackPins c W w}

abbrev PinnedSeeds (c : Nat → Bool) (W : Nat) :=
  {v : Fin W → Bool // BlackPins c W (prefixTrace c W v)}

def completeOutput (c : Nat → Bool) (W : Nat)
    (f : WhiteIndex c W → Bool) (i : Fin W) : Bool :=
  if h : c i.val = false then f ⟨i, h⟩ else !(c (i.val + 1))

theorem completeOutput_blackPins (c : Nat → Bool) (W : Nat)
    (f : WhiteIndex c W → Bool) : BlackPins c W (completeOutput c W f) := by
  intro i hi
  simp [completeOutput, hi]

/-- Fill all black output times with their prescribed bits and leave precisely
the white output times free. This is not a claim about free seed coordinates. -/
def pinnedOutputEquivWhite (c : Nat → Bool) (W : Nat) :
    PinnedOutputs c W ≃ (WhiteIndex c W → Bool) where
  toFun w := fun i => w.val i.val
  invFun f := ⟨completeOutput c W f, completeOutput_blackPins c W f⟩
  left_inv w := by
    apply Subtype.ext
    funext i
    change completeOutput c W (fun j => w.val j.val) i = w.val i
    by_cases hc : c i.val = false
    · simp [completeOutput, hc]
    · have ht : c i.val = true := by
        cases he : c i.val <;> simp_all
      rw [completeOutput, dite_eq_right hc]
      exact (w.property i ht).symm
  right_inv f := by
    funext i
    change completeOutput c W f i.val = f i
    simp [completeOutput, i.property]

def prefixTraceEquiv (c : Nat → Bool) (W : Nat) :
    (Fin W → Bool) ≃ (Fin W → Bool) :=
  Equiv.ofBijective (prefixTrace c W) (prefixTrace_bijective c W)

theorem prefixTraceEquiv_apply (c : Nat → Bool) (W : Nat) (v : Fin W → Bool) :
    prefixTraceEquiv c W v = prefixTrace c W v := rfl

def pinnedSeedEquivOutput (c : Nat → Bool) (W : Nat) :
    PinnedSeeds c W ≃ PinnedOutputs c W where
  toFun v := ⟨prefixTrace c W v.val, v.property⟩
  invFun w := ⟨(prefixTraceEquiv c W).symm w.val, by
    change BlackPins c W ((prefixTraceEquiv c W) ((prefixTraceEquiv c W).symm w.val))
    rw [Equiv.apply_symm_apply]
    exact w.property⟩
  left_inv v := by
    apply Subtype.ext
    exact (prefixTraceEquiv c W).symm_apply_apply v.val
  right_inv w := by
    apply Subtype.ext
    exact (prefixTraceEquiv c W).apply_symm_apply w.val

/-- Exact parametrization by arbitrary white output coordinates. -/
def pinnedSeedEquivWhite (c : Nat → Bool) (W : Nat) :
    PinnedSeeds c W ≃ (WhiteIndex c W → Bool) :=
  (pinnedSeedEquivOutput c W).trans (pinnedOutputEquivWhite c W)

/-- Restrict a pinned initial row to seed positions indexed by white times.
This differs from restricting its output trace to those times. -/
def restrictPinnedSeedToWhite (c : Nat → Bool) (W : Nat)
    (v : PinnedSeeds c W) : WhiteIndex c W → Bool :=
  fun i => v.val i.val

/-- Earlier seed bits and a black pin determine the next seed bit. White
seed bits instead agree by the specified restriction. -/
theorem restrictPinnedSeedToWhite_injective (c : Nat → Bool) (W : Nat) :
    Function.Injective (restrictPinnedSeedToWhite c W) := by
  intro v u hwhite
  have key : ∀ k : Nat, k ≤ W → ∀ i : Fin W, i.val < k → v.val i = u.val i := by
    intro k
    induction k with
    | zero => intro _ i hi; omega
    | succ k ih =>
      intro hk i hi
      by_cases hik : i.val < k
      · exact ih (by omega) i hik
      have hik' : i.val = k := by omega
      by_cases hc : c i.val = false
      · exact congrFun hwhite ⟨i, hc⟩
      · have hblack : c i.val = true := by
          cases he : c i.val <;> simp_all
        have hag : ∀ p : Int, -(k : Int) ≤ p → p < 0 →
            seedRow v.val p = seedRow u.val p := by
          intro p hp hn
          have hj : (-p - 1).toNat < k := by omega
          have hjW : (-p - 1).toNat < W := by omega
          rw [seedRow_read v.val hn hjW, seedRow_read u.val hn hjW]
          exact ih (by omega) ⟨(-p - 1).toNat, hjW⟩ hj
        have ht : prefixTrace c W v.val i = prefixTrace c W u.val i :=
          (v.property i hblack).trans (u.property i hblack).symm
        change Ruliology.CellularAutomata.Rule30DrivenLeft.L c (seedRow v.val) i.val (-1) =
          Ruliology.CellularAutomata.Rule30DrivenLeft.L c (seedRow u.val) i.val (-1) at ht
        rw [hik'] at ht
        have hb := (head_equal_iff_next_seed c k hag).mp ht
        have hpos : -((k + 1 : Nat) : Int) = -((i.val + 1 : Nat) : Int) := by rw [hik']
        rw [hpos, seedRow_at, seedRow_at] at hb
        exact hb
  apply Subtype.ext
  funext i
  exact key W (Nat.le_refl W) i i.isLt

/-- Equal finite cardinality comes from the independently constructed output
coordinate equivalence; injectivity then gives arbitrary white-seed completion. -/
theorem restrictPinnedSeedToWhite_surjective (c : Nat → Bool) (W : Nat) :
    Function.Surjective (restrictPinnedSeedToWhite c W) := by
  let e := pinnedSeedEquivWhite c W
  have hi : Function.Injective (fun v : PinnedSeeds c W =>
      e.symm (restrictPinnedSeedToWhite c W v)) :=
    e.symm.injective.comp (restrictPinnedSeedToWhite_injective c W)
  have hs : Function.Surjective (fun v : PinnedSeeds c W =>
      e.symm (restrictPinnedSeedToWhite c W v)) :=
    Finite.injective_iff_surjective.mp hi
  intro f
  obtain ⟨v, hv⟩ := hs (e.symm f)
  exact ⟨v, e.symm.injective hv⟩

/-- Every choice of white INITIAL seed bits has one and only one completion
satisfying all black pins, for every finite width including zero. -/
def pinnedSeedEquivWhiteSeed (c : Nat → Bool) (W : Nat) :
    PinnedSeeds c W ≃ (WhiteIndex c W → Bool) :=
  Equiv.ofBijective (restrictPinnedSeedToWhite c W)
    ⟨restrictPinnedSeedToWhite_injective c W, restrictPinnedSeedToWhite_surjective c W⟩

theorem pinnedSeedEquivWhiteSeed_apply (c : Nat → Bool) (W : Nat)
    (v : PinnedSeeds c W) (i : WhiteIndex c W) :
    pinnedSeedEquivWhiteSeed c W v i = v.val i.val := rfl

theorem white_seed_completion_unique (c : Nat → Bool) (W : Nat)
    (f : WhiteIndex c W → Bool) :
    ∃! v : PinnedSeeds c W, restrictPinnedSeedToWhite c W v = f := by
  let e := pinnedSeedEquivWhiteSeed c W
  refine ⟨e.symm f, ?_, ?_⟩
  · exact e.apply_symm_apply f
  · intro v hv
    exact e.injective (hv.trans (e.apply_symm_apply f).symm)

theorem pinned_output_count (c : Nat → Bool) (W : Nat) :
    Fintype.card (PinnedOutputs c W) = 2 ^ whiteCount c W := by
  classical
  rw [Fintype.card_congr (pinnedOutputEquivWhite c W)]
  simp [whiteCount]

/-- For every W, including zero: exactly one binary choice per white output
time remains after imposing all black-centre pins. -/
theorem pinned_seed_count (c : Nat → Bool) (W : Nat) :
    Fintype.card (PinnedSeeds c W) = 2 ^ whiteCount c W := by
  classical
  rw [Fintype.card_congr (pinnedSeedEquivOutput c W)]
  exact pinned_output_count c W

theorem pinned_seed_count_explicit (c : Nat → Bool) (W : Nat) :
    Fintype.card {v : Fin W → Bool //
      ∀ t : Fin W, c t.val = true → prefixTrace c W v t = !(c (t.val + 1))} =
      2 ^ Fintype.card {t : Fin W // c t.val = false} :=
  pinned_seed_count c W

theorem whiteCount_zero (c : Nat → Bool) : whiteCount c 0 = 0 := by
  classical
  simp [whiteCount, WhiteIndex]

theorem pinned_seed_count_zero (c : Nat → Bool) :
    Fintype.card (PinnedSeeds c 0) = 1 := by
  rw [pinned_seed_count, whiteCount_zero]
  rfl

end

end FVLT.S4gForcedBitCountV1
