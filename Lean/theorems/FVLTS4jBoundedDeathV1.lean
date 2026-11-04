import FVLTS4iUniformPaddingV1
import FVLTS4hFiniteTailV1

/-! S4j1142 source preparation only. This generic equivalence supplies no
bounded-death instance, quantitative bound, or periodic-driver exclusion.
Compilation and axiom checks are reserved to the root's prospective gate. -/
set_option autoImplicit false

namespace FVLT.S4jBoundedDeathV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1 FVLT.S4hFiniteTailV1 FVLT.S4iUniformPaddingV1

/-- White INITIAL coordinates below W, not time-evolved white outputs. -/
abbrev FiniteWhiteInputs (c : Nat → Bool) (W : Nat) :=
  ({i : Fin W // c i.val = false} → Bool)

def extendWhite (c : Nat → Bool) (W : Nat) (q : FiniteWhiteInputs c W) :
    WhiteInfinite c → Bool := fun i =>
  if h : i.val < W then q ⟨⟨i.val, h⟩, i.property⟩ else false

def restrictWhite (c : Nat → Bool) (W : Nat) (u : WhiteInfinite c → Bool) :
    FiniteWhiteInputs c W := fun i => u ⟨i.val.val, i.property⟩

noncomputable def completed (c : Nat → Bool) (W : Nat)
    (q : FiniteWhiteInputs c W) : Nat → Bool :=
  zeroCompleted c (extendWhite c W q) W

def NoFinitePins (c : Nat → Bool) : Prop :=
  ∀ s : Int → Bool, FiniteLeft s → ¬ Pins c s

def BlackFailure (c : Nat → Bool) (a : Nat → Bool) (t : Nat) : Prop :=
  c t = true ∧ L c (bitRow a) t (-1) ≠ !c (t + 1)

def BoundedDeath (c : Nat → Bool) : Prop :=
  ∀ W : Nat, ∃ K : Nat, ∀ q : FiniteWhiteInputs c W,
    ∃ t : Nat, W ≤ t ∧ t < W + K ∧ BlackFailure c (completed c W q) t

/-- Finite inputs cover every infinite white parameter's width-W completion. -/
theorem completed_restrictWhite (c : Nat → Bool) (W : Nat)
    (u : WhiteInfinite c → Bool) :
    completed c W (restrictWhite c W u) = zeroCompleted c u W := by
  have he : prefixSeed c (extendWhite c W (restrictWhite c W u)) W =
      prefixSeed c u W := by
    apply restrictPinnedSeedToWhite_injective c W
    funext j
    change (prefixSeed c (extendWhite c W (restrictWhite c W u)) W).val j.val =
      (prefixSeed c u W).val j.val
    rw [prefixSeed_white, prefixSeed_white]
    simp only [extendWhite, dif_pos j.val.isLt, restrictWhite]
  funext n
  unfold completed zeroCompleted
  rw [he]

theorem completed_finiteLeft (c : Nat → Bool) (W : Nat)
    (q : FiniteWhiteInputs c W) : FiniteLeft (bitRow (completed c W q)) := by
  apply (finiteLeft_bitRow_iff _).mpr
  exact ⟨W, fun n hn => by
    unfold completed zeroCompleted
    rw [dif_neg (by omega : ¬ n < W)]⟩

/-- Eventual failure is a consequence of the actual finite-row obstruction. -/
theorem noFinitePins_failure (c : Nat → Bool) (h : NoFinitePins c)
    (W : Nat) (q : FiniteWhiteInputs c W) :
    ∃ t : Nat, W ≤ t ∧ BlackFailure c (completed c W q) t := by
  classical
  have hn : ¬ Pins c (bitRow (completed c W q)) :=
    h _ (completed_finiteLeft c W q)
  have hf : ∃ t : Nat, BlackFailure c (completed c W q) t := by
    by_contra hnone
    apply hn
    intro t ht
    by_contra hbad
    exact hnone ⟨t, ht, hbad⟩
  obtain ⟨t, ht, hbad⟩ := hf
  refine ⟨t, ?_, ht, hbad⟩
  by_contra hsmall
  exact hbad (zeroCompleted_pins_before c (extendWhite c W q) W t
    (by omega) ht)

/-- The maximum is over all finite INITIAL white assignments. K uses the
successor of each failure time, because the slab's right end is excluded. -/
theorem noFinitePins_boundedDeath (c : Nat → Bool) (h : NoFinitePins c) :
    BoundedDeath c := by
  classical
  intro W
  have hf := noFinitePins_failure c h W
  let t : FiniteWhiteInputs c W → Nat := fun q => Classical.choose (hf q)
  have ht (q : FiniteWhiteInputs c W) :
      W ≤ t q ∧ BlackFailure c (completed c W q) (t q) :=
    Classical.choose_spec (hf q)
  let K : Nat := Finset.univ.sup (fun q : FiniteWhiteInputs c W => t q + 1 - W)
  refine ⟨K, fun q => ⟨t q, (ht q).1, ?_, (ht q).2⟩⟩
  have hmax : t q + 1 - W ≤ K :=
    Finset.le_sup (f := fun q : FiniteWhiteInputs c W => t q + 1 - W)
      (Finset.mem_univ q)
  have hstart := (ht q).1
  omega

/-- Every finite pinned row is its width-W finite white completion after
zero extension. Positive coordinates are irrelevant to the pin light cones. -/
theorem finitePinned_completed (c : Nat → Bool) (s : Int → Bool)
    (hs : FiniteLeft s) (hp : Pins c s) :
    ∃ W : Nat, ∃ q : FiniteWhiteInputs c W,
      completed c W q = bitsOfRow s := by
  obtain ⟨W, hW⟩ := (finiteLeft_bitsOfRow_iff s).mp hs
  let a := bitsOfRow s
  have ha : Pins c (bitRow a) :=
    (pins_congr_negative c (bitRow_bitsOfRow_negative s)).mpr hp
  let v : PinnedSeeds c W := ⟨fun i => a i.val, by
    intro i hi
    rw [bitRow_finite_trace]
    exact ha i.val hi⟩
  let q : FiniteWhiteInputs c W := fun i => a i.val.val
  have he : v = prefixSeed c (extendWhite c W q) W := by
    apply restrictPinnedSeedToWhite_injective c W
    funext j
    change a j.val.val = (prefixSeed c (extendWhite c W q) W).val j.val
    rw [prefixSeed_white]
    simp only [extendWhite, dif_pos j.val.isLt, q]
  refine ⟨W, q, ?_⟩
  funext n
  by_cases hn : n < W
  · have hv := congrFun (congrArg Subtype.val he) (⟨n, hn⟩ : Fin W)
    change a n = (prefixSeed c (extendWhite c W q) W).val ⟨n, hn⟩ at hv
    change zeroCompleted c (extendWhite c W q) W n = a n
    rw [zeroCompleted, dif_pos hn]
    exact hv.symm
  · change zeroCompleted c (extendWhite c W q) W n = bitsOfRow s n
    rw [zeroCompleted, dif_neg hn]
    exact (hW n (by omega)).symm

theorem boundedDeath_noFinitePins (c : Nat → Bool) (h : BoundedDeath c) :
    NoFinitePins c := by
  intro s hs hp
  obtain ⟨W, q, he⟩ := finitePinned_completed c s hs hp
  obtain ⟨K, hK⟩ := h W
  obtain ⟨t, _, _, ht, hbad⟩ := hK q
  have ha : Pins c (bitRow (bitsOfRow s)) :=
    (pins_congr_negative c (bitRow_bitsOfRow_negative s)).mpr hp
  rw [he] at hbad
  exact hbad (ha t ht)

/-- Logical reformulation only, valid for arbitrary c including constants. -/
theorem noFinitePins_iff_boundedDeath (c : Nat → Bool) :
    NoFinitePins c ↔ BoundedDeath c :=
  ⟨noFinitePins_boundedDeath c, boundedDeath_noFinitePins c⟩

theorem noFinitePins_iff_zeroTailObstruction (c : Nat → Bool) :
    NoFinitePins c ↔
      ∀ u : WhiteInfinite c → Bool, WhiteEventuallyZero c u →
        ¬ BlackEventuallyZero c (Phi c u) :=
  no_finite_pins_iff_no_zero_to_zero c

end FVLT.S4jBoundedDeathV1
