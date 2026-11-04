import FVLTS4hInfinitePinsV1

/-! Finite negative support is exactly eventual zero in NATURAL TIME-indexed
initial seed coordinates. Subtype enumeration indices are never used.
No assertion that Phi sends zero to zero is made.
-/

namespace FVLT.S4hFiniteTailV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLBEImplicationV1 FVLT.S4hInfinitePinsV1

def EventuallyZero (a : Nat → Bool) : Prop :=
  ∃ N : Nat, ∀ n : Nat, N ≤ n → a n = false

def WhiteEventuallyZero (c : Nat → Bool) (u : WhiteInfinite c → Bool) : Prop :=
  ∃ N : Nat, ∀ i : WhiteInfinite c, N ≤ i.val → u i = false

def BlackEventuallyZero (c : Nat → Bool) (v : BlackInfinite c → Bool) : Prop :=
  ∃ N : Nat, ∀ i : BlackInfinite c, N ≤ i.val → v i = false

theorem eventuallyZero_iff_projections (c : Nat → Bool) (a : Nat → Bool) :
    EventuallyZero a ↔ WhiteEventuallyZero c (whiteProjection c a) ∧
      BlackEventuallyZero c (blackProjection c a) := by
  constructor
  · rintro ⟨N, hN⟩
    exact ⟨⟨N, fun i hi => hN i.val hi⟩, ⟨N, fun i hi => hN i.val hi⟩⟩
  · rintro ⟨⟨N, hN⟩, ⟨M, hM⟩⟩
    refine ⟨max N M, fun n hn => ?_⟩
    cases hc : c n with
    | false => exact hN ⟨n, hc⟩ (Nat.le_trans (Nat.le_max_left N M) hn)
    | true => exact hM ⟨n, hc⟩ (Nat.le_trans (Nat.le_max_right N M) hn)

theorem infiniteBits_eventuallyZero_iff (c : Nat → Bool) (u : WhiteInfinite c → Bool) :
    EventuallyZero (infiniteBits c u) ↔
      WhiteEventuallyZero c u ∧ BlackEventuallyZero c (Phi c u) := by
  have hw : whiteProjection c (infiniteBits c u) = u := by
    funext i
    exact infiniteBits_white c u i
  simpa only [hw, Phi] using eventuallyZero_iff_projections c (infiniteBits c u)

theorem finiteLeft_bitRow_iff (a : Nat → Bool) :
    FiniteLeft (bitRow a) ↔ EventuallyZero a := by
  constructor
  · rintro ⟨W, hW⟩
    refine ⟨W, fun n hn => ?_⟩
    have h := hW (-((n + 1 : Nat) : Int)) (by omega)
    rw [bitRow_at] at h
    exact h
  · rintro ⟨N, hN⟩
    refine ⟨N, fun p hp => ?_⟩
    have hn : p < 0 := by omega
    rw [bitRow, ite_eq_left hn]
    exact hN (-p - 1).toNat (by omega)

theorem pins_congr_negative (c : Nat → Bool) {s r : Int → Bool}
    (h : ∀ p : Int, p < 0 → s p = r p) : Pins c s ↔ Pins c r := by
  have hh (t : Nat) : L c s t (-1) = L c r t (-1) :=
    light_cone (c := c) (k := t) (fun p _ hn => h p hn)
      t (Nat.le_refl _) (-1) (by omega) (by omega)
  constructor
  · intro hs t ht
    rw [← hh t]
    exact hs t ht
  · intro hr t ht
    rw [hh t]
    exact hr t ht

def bitsOfRow (s : Int → Bool) (n : Nat) : Bool := s (-((n + 1 : Nat) : Int))

theorem bitRow_bitsOfRow_negative (s : Int → Bool) (p : Int) (hp : p < 0) :
    bitRow (bitsOfRow s) p = s p := by
  rw [bitRow, ite_eq_left hp]
  unfold bitsOfRow
  congr 1
  omega

theorem finiteLeft_bitsOfRow_iff (s : Int → Bool) :
    FiniteLeft s ↔ EventuallyZero (bitsOfRow s) := by
  have hf : FiniteLeft s ↔ FiniteLeft (bitRow (bitsOfRow s)) := by
    constructor
    · rintro ⟨W, hW⟩
      refine ⟨W, fun p hp => ?_⟩
      rw [bitRow_bitsOfRow_negative s p (by omega)]
      exact hW p hp
    · rintro ⟨W, hW⟩
      refine ⟨W, fun p hp => ?_⟩
      rw [← bitRow_bitsOfRow_negative s p (by omega)]
      exact hW p hp
  exact hf.trans (finiteLeft_bitRow_iff (bitsOfRow s))

/-- All-time black pins always have an infinite initial-row completion.
This does not assert that its negative support is finite. -/
theorem exists_all_pins (c : Nat → Bool) : ∃ s : Int → Bool, Pins c s :=
  ⟨bitRow (infiniteBits c (fun _ => false)), infiniteBits_pins c (fun _ => false)⟩

/-- A finite pin-compatible initial row exists exactly when Phi carries some
eventually-zero white input to an eventually-zero black output. Both cutoffs
refer to the original natural indices, not enumerations of white/black sets. -/
theorem finite_pinned_iff_zero_to_zero (c : Nat → Bool) :
    (∃ s : Int → Bool, FiniteLeft s ∧ Pins c s) ↔
      ∃ u : WhiteInfinite c → Bool,
        WhiteEventuallyZero c u ∧ BlackEventuallyZero c (Phi c u) := by
  constructor
  · rintro ⟨s, hs, hp⟩
    let a := bitsOfRow s
    have ha : EventuallyZero a := (finiteLeft_bitsOfRow_iff s).mp hs
    have hpa : Pins c (bitRow a) :=
      (pins_congr_negative c (bitRow_bitsOfRow_negative s)).mpr hp
    have he : a = infiniteBits c (whiteProjection c a) :=
      infiniteBits_unique c (whiteProjection c a) a hpa (fun _ => rfl)
    refine ⟨whiteProjection c a, ?_⟩
    apply (infiniteBits_eventuallyZero_iff c (whiteProjection c a)).mp
    rw [← he]
    exact ha
  · rintro ⟨u, hu, hv⟩
    refine ⟨bitRow (infiniteBits c u), ?_, infiniteBits_pins c u⟩
    apply (finiteLeft_bitRow_iff _).mpr
    exact (infiniteBits_eventuallyZero_iff c u).mpr ⟨hu, hv⟩

theorem no_finite_pins_iff_no_zero_to_zero (c : Nat → Bool) :
    (∀ s : Int → Bool, FiniteLeft s → ¬ Pins c s) ↔
      (∀ u : WhiteInfinite c → Bool, WhiteEventuallyZero c u →
        ¬ BlackEventuallyZero c (Phi c u)) := by
  constructor
  · intro h u hu hv
    obtain ⟨s, hs, hp⟩ := (finite_pinned_iff_zero_to_zero c).mpr ⟨u, hu, hv⟩
    exact h s hs hp
  · intro h s hs hp
    obtain ⟨u, hu, hv⟩ := (finite_pinned_iff_zero_to_zero c).mp ⟨s, hs, hp⟩
    exact h u hu hv

end FVLT.S4hFiniteTailV1
