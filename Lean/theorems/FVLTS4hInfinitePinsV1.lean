import FVLTS4gForcedBitCountV1
import FVLTS4gLBEImplicationV1

/-! Infinite causal completion of the black pins from white INITIAL seed bits.
This uses the actual driven-left evolution, not the kit's specialized Psi map.
-/

namespace FVLT.S4hInfinitePinsV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1

abbrev WhiteInfinite (c : Nat → Bool) := {n : Nat // c n = false}
abbrev BlackInfinite (c : Nat → Bool) := {n : Nat // c n = true}

def restrictSeed {W V : Nat} (hWV : W ≤ V) (v : Fin V → Bool) : Fin W → Bool :=
  fun i => v ⟨i.val, Nat.lt_of_lt_of_le i.isLt hWV⟩

theorem prefixTrace_restrict (c : Nat → Bool) {W V : Nat} (hWV : W ≤ V)
    (v : Fin V → Bool) (i : Fin W) :
    prefixTrace c W (restrictSeed hWV v) i =
      prefixTrace c V v ⟨i.val, Nat.lt_of_lt_of_le i.isLt hWV⟩ := by
  have hag : ∀ p : Int, -((i.val + 1 : Nat) : Int) ≤ p → p < 0 →
      seedRow (restrictSeed hWV v) p = seedRow v p := by
    intro p hp hn
    have hkW : (-p - 1).toNat < W := by have hi := i.isLt; omega
    have hkV : (-p - 1).toNat < V := Nat.lt_of_lt_of_le hkW hWV
    rw [seedRow_read _ hn hkW, seedRow_read _ hn hkV]
    rfl
  exact light_cone (c := c) (k := i.val) hag i.val (Nat.le_refl _)
    (-1) (by omega) (by omega)

def restrictPinned {c : Nat → Bool} {W V : Nat} (hWV : W ≤ V)
    (v : PinnedSeeds c V) : PinnedSeeds c W :=
  ⟨restrictSeed hWV v.val, by
    intro i hi
    rw [prefixTrace_restrict]
    exact v.property ⟨i.val, Nat.lt_of_lt_of_le i.isLt hWV⟩ hi⟩

noncomputable def prefixSeed (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W : Nat) : PinnedSeeds c W :=
  (pinnedSeedEquivWhiteSeed c W).symm (fun i => u ⟨i.val.val, i.property⟩)

theorem prefixSeed_white (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W : Nat) (i : WhiteIndex c W) :
    (prefixSeed c u W).val i.val = u ⟨i.val.val, i.property⟩ := by
  exact congrFun ((pinnedSeedEquivWhiteSeed c W).apply_symm_apply
    (fun j => u ⟨j.val.val, j.property⟩)) i

theorem prefixSeed_compatible (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    {W V : Nat} (hWV : W ≤ V) (i : Fin W) :
    (prefixSeed c u W).val i =
      (prefixSeed c u V).val ⟨i.val, Nat.lt_of_lt_of_le i.isLt hWV⟩ := by
  have he : restrictPinned hWV (prefixSeed c u V) = prefixSeed c u W := by
    apply restrictPinnedSeedToWhite_injective c W
    funext j
    change (prefixSeed c u V).val
      ⟨j.val.val, Nat.lt_of_lt_of_le j.val.isLt hWV⟩ =
      (prefixSeed c u W).val j.val
    rw [prefixSeed_white c u V
      ⟨⟨j.val.val, Nat.lt_of_lt_of_le j.val.isLt hWV⟩, j.property⟩,
      prefixSeed_white c u W j]
  have hv := congrFun (congrArg Subtype.val he) i
  exact hv.symm

noncomputable def infiniteBits (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (n : Nat) : Bool := (prefixSeed c u (n + 1)).val ⟨n, by omega⟩

theorem infiniteBits_prefix (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W : Nat) (i : Fin W) :
    infiniteBits c u i.val = (prefixSeed c u W).val i := by
  exact prefixSeed_compatible c u (W := i.val + 1) (V := W)
    (by have hi := i.isLt; omega) ⟨i.val, by omega⟩

def bitRow (a : Nat → Bool) (p : Int) : Bool :=
  if p < 0 then a (-p - 1).toNat else false

theorem bitRow_at (a : Nat → Bool) (n : Nat) :
    bitRow a (-((n + 1 : Nat) : Int)) = a n := by
  have hn : -((n + 1 : Nat) : Int) < 0 := by omega
  have hi : (-(-((n + 1 : Nat) : Int)) - 1).toNat = n := by omega
  unfold bitRow
  rw [ite_eq_left hn, hi]

theorem bitRow_prefix_agree (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (W : Nat) (p : Int) (hp : -(W : Int) ≤ p) (hn : p < 0) :
    bitRow (infiniteBits c u) p = seedRow (prefixSeed c u W).val p := by
  have hk : (-p - 1).toNat < W := by omega
  rw [bitRow, ite_eq_left hn, seedRow_read _ hn hk]
  exact infiniteBits_prefix c u W ⟨(-p - 1).toNat, hk⟩

theorem infiniteBits_white (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (i : WhiteInfinite c) : infiniteBits c u i.val = u i := by
  exact prefixSeed_white c u (i.val + 1) ⟨⟨i.val, by omega⟩, i.property⟩

theorem infiniteBits_pins (c : Nat → Bool) (u : WhiteInfinite c → Bool) :
    Pins c (bitRow (infiniteBits c u)) := by
  intro t ht
  have hag : ∀ p : Int, -((t + 1 : Nat) : Int) ≤ p → p < 0 →
      bitRow (infiniteBits c u) p = seedRow (prefixSeed c u (t + 1)).val p :=
    fun p hp hn => bitRow_prefix_agree c u (t + 1) p hp hn
  have he := light_cone (c := c) (k := t) hag t (Nat.le_refl _)
    (-1) (by omega) (by omega)
  exact he.trans ((prefixSeed c u (t + 1)).property ⟨t, by omega⟩ ht)

theorem bitRow_finite_trace (c : Nat → Bool) (a : Nat → Bool) (W : Nat)
    (i : Fin W) :
    prefixTrace c W (fun j => a j.val) i = L c (bitRow a) i.val (-1) := by
  have hag : ∀ p : Int, -((i.val + 1 : Nat) : Int) ≤ p → p < 0 →
      seedRow (fun j : Fin W => a j.val) p = bitRow a p := by
    intro p hp hn
    have hk : (-p - 1).toNat < W := by have hi := i.isLt; omega
    rw [seedRow_read _ hn hk, bitRow, ite_eq_left hn]
  exact light_cone (c := c) (k := i.val) hag i.val (Nat.le_refl _)
    (-1) (by omega) (by omega)

theorem infiniteBits_unique (c : Nat → Bool) (u : WhiteInfinite c → Bool)
    (a : Nat → Bool) (hp : Pins c (bitRow a))
    (hw : ∀ i : WhiteInfinite c, a i.val = u i) : a = infiniteBits c u := by
  funext n
  let W := n + 1
  let v : PinnedSeeds c W := ⟨fun i => a i.val, by
    intro i hi
    rw [bitRow_finite_trace]
    exact hp i.val hi⟩
  have he : v = prefixSeed c u W := by
    apply restrictPinnedSeedToWhite_injective c W
    funext i
    change a i.val.val = (prefixSeed c u W).val i.val
    rw [prefixSeed_white c u W i]
    exact hw ⟨i.val.val, i.property⟩
  have hn := congrFun (congrArg Subtype.val he) (⟨n, by dsimp [W]; omega⟩ : Fin W)
  exact hn

theorem infiniteBits_causal (c : Nat → Bool) (u v : WhiteInfinite c → Bool)
    (W : Nat) (h : ∀ i : WhiteInfinite c, i.val < W → u i = v i)
    (n : Nat) (hn : n < W) : infiniteBits c u n = infiniteBits c v n := by
  have hfree : (fun i : WhiteIndex c W => u ⟨i.val.val, i.property⟩) =
      (fun i : WhiteIndex c W => v ⟨i.val.val, i.property⟩) := by
    funext i
    exact h ⟨i.val.val, i.property⟩ i.val.isLt
  have he : prefixSeed c u W = prefixSeed c v W :=
    congrArg (pinnedSeedEquivWhiteSeed c W).symm hfree
  rw [infiniteBits_prefix c u W ⟨n, hn⟩, infiniteBits_prefix c v W ⟨n, hn⟩]
  exact congrFun (congrArg Subtype.val he) ⟨n, hn⟩

def whiteProjection (c : Nat → Bool) (a : Nat → Bool) : WhiteInfinite c → Bool :=
  fun i => a i.val

def blackProjection (c : Nat → Bool) (a : Nat → Bool) : BlackInfinite c → Bool :=
  fun i => a i.val

noncomputable def Phi (c : Nat → Bool) (u : WhiteInfinite c → Bool) :
    BlackInfinite c → Bool := blackProjection c (infiniteBits c u)

theorem graph_reconstruct (c : Nat → Bool) (a : Nat → Bool)
    (h : blackProjection c a = Phi c (whiteProjection c a)) :
    a = infiniteBits c (whiteProjection c a) := by
  funext n
  cases hc : c n with
  | false =>
    exact (infiniteBits_white c (whiteProjection c a) ⟨n, hc⟩).symm
  | true => exact congrFun h ⟨n, hc⟩

/-- The all-time pin set is the graph of Phi in initial seed coordinates. -/
theorem pins_iff_graph (c : Nat → Bool) (a : Nat → Bool) :
    Pins c (bitRow a) ↔ blackProjection c a = Phi c (whiteProjection c a) := by
  constructor
  · intro hp
    have he := infiniteBits_unique c (whiteProjection c a) a hp (fun _ => rfl)
    exact congrArg (blackProjection c) he
  · intro hg
    rw [graph_reconstruct c a hg]
    exact infiniteBits_pins c (whiteProjection c a)

end FVLT.S4hInfinitePinsV1
