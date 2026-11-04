import FVLTWovenFiniteHorizonV1
import FVLTRingSemanticsV1

/-!
Actual fixed-ring computation of an independently defined infinite Rule30 cone
through a finite horizon. Padding is a proved guard, not an assumption that a
nonperiodic infinite row is globally periodic. False background is zero in bits
and minus one in the T7 spin convention; only spin+1 has finite support.
-/
namespace FVLT.NoWrapPaddingV1
open WovenCanonicalV1 WovenEvolutionV1 WovenFiniteHorizonV1 RingSemanticsV1

theorem padding_pos (N T : ℕ) (hpad : 2 * T + 3 ≤ N) : 0 < N := by omega

theorem padding_cap (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (s : ℕ) (hs : s ≤ T) : 2 * s + 1 ≤ N := by omega

theorem padding_gap (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (s : ℕ) (hs : s < T) : N / 2 + s + 1 < N := by omega

/-- All queries are interpreted by the actual fixed-ring recurrence. -/
theorem fixed_weave_eq_infinite_rep_up_to (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) :
    weave (fun _ => N) t i = infinite t (rep N i) := by
  exact weave_eq_infinite_rep_up_to (fun _ => N) T
    (fun _ => padding_pos N T hpad)
    (fun s hs => padding_cap N T hpad s hs)
    (fun s hs => padding_gap N T hpad s hs) t ht i

theorem fixed_weave_eq_infinite_window (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : InWindow N i) :
    weave (fun _ => N) t i = infinite t i := by
  rw [fixed_weave_eq_infinite_rep_up_to N T hpad t ht i,
    rep_eq_self N (padding_pos N T hpad) i hi]

theorem fixed_weave_eq_infinite_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    weave (fun _ => N) t i = infinite t i :=
  fixed_weave_eq_infinite_window N T hpad t ht i
    (core_in_window N t (padding_cap N T hpad t ht) i hi)

theorem padded_ring_eq_infinite_rep (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (z : ZMod N) :
    ring (fun _ => N) t z = infinite t (rep N (z.val : ℤ)) := by
  exact fixed_weave_eq_infinite_rep_up_to N T hpad t ht z.val

theorem padded_ring_eq_infinite_window (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : InWindow N i) :
    ring (fun _ => N) t (i : ZMod N) = infinite t i := by
  rw [ring_read (fun _ => N) (fun _ => padding_pos N T hpad)]
  exact fixed_weave_eq_infinite_window N T hpad t ht i hi

theorem padded_ring_eq_infinite_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    ring (fun _ => N) t (i : ZMod N) = infinite t i :=
  padded_ring_eq_infinite_window N T hpad t ht i
    (core_in_window N t (padding_cap N T hpad t ht) i hi)

/-- Outside-core zero is asserted for represented canonical cells, not arbitrary aliases. -/
theorem padded_ring_outside_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : InWindow N i)
    (hout : (t : ℤ) < |i|) : ring (fun _ => N) t (i : ZMod N) = false := by
  rw [padded_ring_eq_infinite_window N T hpad t ht i hi]
  exact infinite_support t i hout

def bitLift (b : Bool) : ℂ := if b then 1 else 0

def spinLift (b : Bool) : ℂ := if b then 1 else -1

theorem spin_plus_one_eq_two_bit (b : Bool) : spinLift b + 1 = 2 * bitLift b := by
  cases b <;> norm_num [spinLift, bitLift]

def rowBit (t : ℕ) (i : ℤ) : ℂ := bitLift (infinite t i)

def rowSpin (t : ℕ) (i : ℤ) : ℂ := spinLift (infinite t i)

def cyclicBit (N t : ℕ) (z : ZMod N) : ℂ := bitLift (ring (fun _ => N) t z)

def cyclicSpin (N t : ℕ) (z : ZMod N) : ℂ := spinLift (ring (fun _ => N) t z)

theorem row_spin_plus_one (t : ℕ) (i : ℤ) : rowSpin t i + 1 = 2 * rowBit t i :=
  spin_plus_one_eq_two_bit _

theorem cyclic_spin_plus_one (N t : ℕ) (z : ZMod N) :
    cyclicSpin N t z + 1 = 2 * cyclicBit N t z := spin_plus_one_eq_two_bit _

theorem row_bit_outside (t : ℕ) (i : ℤ) (hout : (t : ℤ) < |i|) : rowBit t i = 0 := by
  simp [rowBit, bitLift, infinite_support t i hout]

theorem row_spin_outside (t : ℕ) (i : ℤ) (hout : (t : ℤ) < |i|) : rowSpin t i = -1 := by
  simp [rowSpin, spinLift, infinite_support t i hout]

theorem row_spin_plus_one_outside (t : ℕ) (i : ℤ) (hout : (t : ℤ) < |i|) :
    rowSpin t i + 1 = 0 := by
  rw [row_spin_outside t i hout]
  norm_num

theorem support_spin_plus_one_subset (t : ℕ) :
    Function.support (fun i : ℤ => rowSpin t i + 1) ⊆ Set.Icc (-(t : ℤ)) (t : ℤ) := by
  intro i hi
  by_contra hnot
  have hout : (t : ℤ) < |i| := by
    by_contra h
    have hab : |i| ≤ (t : ℤ) := by omega
    exact hnot (abs_le.mp hab)
  exact hi (row_spin_plus_one_outside t i hout)

theorem finite_support_spin_plus_one (t : ℕ) :
    (Function.support (fun i : ℤ => rowSpin t i + 1)).Finite :=
  (Set.finite_Icc (-(t : ℤ)) (t : ℤ)).subset (support_spin_plus_one_subset t)

theorem cyclic_bit_eq_row_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    cyclicBit N t (i : ZMod N) = rowBit t i := by
  simp only [cyclicBit, rowBit, padded_ring_eq_infinite_core N T hpad t ht i hi]

theorem cyclic_spin_eq_row_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    cyclicSpin N t (i : ZMod N) = rowSpin t i := by
  simp only [cyclicSpin, rowSpin, padded_ring_eq_infinite_core N T hpad t ht i hi]

theorem cyclic_bit_outside_window_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : InWindow N i) (hout : (t : ℤ) < |i|) :
    cyclicBit N t (i : ZMod N) = 0 := by
  simp [cyclicBit, bitLift, padded_ring_outside_core N T hpad t ht i hi hout]

theorem cyclic_spin_outside_window_core (N T : ℕ) (hpad : 2 * T + 3 ≤ N)
    (t : ℕ) (ht : t ≤ T) (i : ℤ) (hi : InWindow N i) (hout : (t : ℤ) < |i|) :
    cyclicSpin N t (i : ZMod N) = -1 := by
  simp [cyclicSpin, spinLift, padded_ring_outside_core N T hpad t ht i hi hout]

end FVLT.NoWrapPaddingV1
