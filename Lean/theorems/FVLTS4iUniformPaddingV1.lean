import FVLTS4hInfinitePinsV1

/-! Prepared under scope1128. Execution standing is recorded separately;
this source alone makes no acceptance claim.
This file is separate from the frozen S4i source and aggregate. No periodicity
or nonerasure assumption is used. The conditional hypothesis is exactly the
finite added slab of black pins. -/
set_option autoImplicit false

namespace FVLT.S4iUniformPaddingV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1

def cutWhite (c : Nat → Bool) (u : WhiteInfinite c → Bool) (W : Nat) :
    WhiteInfinite c → Bool := fun i => if i.val < W then u i else false

noncomputable def zeroCompleted (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W : Nat) (n : Nat) : Bool :=
  if h : n < W then (prefixSeed c u W).val ⟨n, h⟩ else false

def SlabOK (c : Nat → Bool) (a : Nat → Bool) (W K : Nat) : Prop :=
  ∀ t, W ≤ t → t < W + K → c t = true →
    L c (bitRow a) t (-1) = !c (t + 1)

theorem zeroCompleted_pins_before (c : Nat → Bool)
    (u : WhiteInfinite c → Bool) (W t : Nat) (ht : t < W) (hc : c t = true) :
    L c (bitRow (zeroCompleted c u W)) t (-1) = !c (t + 1) := by
  have he : (fun j : Fin W => zeroCompleted c u W j.val) =
      (prefixSeed c u W).val := by
    funext j
    simp only [zeroCompleted, dif_pos j.isLt]
  have hh := bitRow_finite_trace c (zeroCompleted c u W) W ⟨t, ht⟩
  rw [he] at hh
  exact hh.symm.trans ((prefixSeed c u W).property ⟨t, ht⟩ hc)

/-- On successful added black pins, the larger finite completion, with added
white coordinates set zero and then ZERO-EXTENDED, is the same full row. -/
theorem conditional_zero_padding (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W K : Nat) (hslab : SlabOK c (zeroCompleted c u W) W K) :
    zeroCompleted c (cutWhite c u W) (W + K) = zeroCompleted c u W := by
  let a := zeroCompleted c u W
  let V := W + K
  let v : PinnedSeeds c V := ⟨fun i => a i.val, by
    intro i hi
    rw [bitRow_finite_trace]
    by_cases hw : i.val < W
    · exact zeroCompleted_pins_before c u W i.val hw hi
    · exact hslab i.val (by omega) i.isLt hi⟩
  have he : v = prefixSeed c (cutWhite c u W) V := by
    apply restrictPinnedSeedToWhite_injective c V
    funext j
    change a j.val.val = (prefixSeed c (cutWhite c u W) V).val j.val
    rw [prefixSeed_white c (cutWhite c u W) V j]
    by_cases hw : j.val.val < W
    · change zeroCompleted c u W j.val.val =
        cutWhite c u W ⟨j.val.val, j.property⟩
      simp only [zeroCompleted, dif_pos hw, cutWhite, if_pos hw]
      exact prefixSeed_white c u W ⟨⟨j.val.val, hw⟩, j.property⟩
    · simp only [a, zeroCompleted, dif_neg hw, cutWhite, if_neg hw]
  funext n
  by_cases hn : n < V
  · have hv := congrFun (congrArg Subtype.val he) (⟨n, hn⟩ : Fin V)
    change a n = (prefixSeed c (cutWhite c u W) V).val ⟨n, hn⟩ at hv
    change zeroCompleted c (cutWhite c u W) V n = a n
    rw [zeroCompleted, dif_pos hn]
    exact hv.symm
  · have hnW : ¬ n < W := by dsimp [V] at hn; omega
    change zeroCompleted c (cutWhite c u W) V n = zeroCompleted c u W n
    simp only [zeroCompleted, dif_neg hn, dif_neg hnW]

/-- All future head values agree because BOTH compared finite seeds are
zero-extended; there is no time shift and no driver change. -/
theorem conditional_padding_all_heads (c : Nat → Bool)
    (u : WhiteInfinite c → Bool) (W K : Nat)
    (hslab : SlabOK c (zeroCompleted c u W) W K) (t : Nat) :
    L c (bitRow (zeroCompleted c (cutWhite c u W) (W + K))) t (-1) =
      L c (bitRow (zeroCompleted c u W)) t (-1) := by
  rw [conditional_zero_padding c u W K hslab]

/-- For the INFINITE completion only the bounded seed-prefix agreement is
claimed. No all-future equality with the finite zero extension is asserted. -/
theorem conditional_infinite_prefix (c : Nat → Bool)
    (u : WhiteInfinite c → Bool) (W K : Nat)
    (hslab : SlabOK c (zeroCompleted c u W) W K) (n : Nat) (hn : n < W + K) :
    infiniteBits c (cutWhite c u W) n = zeroCompleted c u W n := by
  have he := congrFun (conditional_zero_padding c u W K hslab) n
  rw [infiniteBits_prefix c (cutWhite c u W) (W + K) ⟨n, hn⟩]
  simpa only [zeroCompleted, dif_pos hn] using he

end FVLT.S4iUniformPaddingV1
