import FVLTFiniteStateObstructionV1
import FVLTRingSemanticsV1
import Mathlib.Data.ZMod.Basic

/-! The fixed-length specialization of the actual woven recurrence is a finite
autonomous ring. No separate evolution is introduced. The target obstruction
is explicit here; the kit-specific Jen adapter is a separate module. -/
namespace FVLT.WovenCylinderV1
open WovenCanonicalV1 WovenEvolutionV1 RingSemanticsV1
open FiniteStateObstructionV1

abbrev RingState (L : ℕ) := ZMod L → Bool

def ringStep (L : ℕ) (s : RingState L) (z : ZMod L) : Bool :=
  rule (s (z-1)) (s z) (s (z+1))

theorem fixed_ring_step (L : ℕ) [NeZero L] (t : ℕ) :
    ring (fun _ => L) (t+1) = ringStep L (ring (fun _ => L) t) := by
  have hL : 0<L := Nat.pos_of_ne_zero (NeZero.ne L)
  funext z
  have hr : ((rep L (z.val : ℤ) : ℤ) : ZMod L) = ((z.val : ℤ) : ZMod L) := by
    rw [ZMod.intCast_eq_intCast_iff']
    exact rep_mod L (z.val : ℤ)
  have hz : ((rep L (z.val : ℤ) : ℤ) : ZMod L) = z := by simpa using hr
  have hs := ring_step (fun _ => L) (fun _ => hL) t z
  simpa only [ringStep, Int.cast_sub, Int.cast_add, Int.cast_one, hz] using hs

/-- Every positive fixed circumference has arbitrarily late labelled cone
mismatches against a target whose columns 0 and 1 cannot both be periodic.
This includes L=1 and both parities; no readout injectivity is assumed. -/
theorem fixed_cylinder_arbitrarily_late_mismatch (L : ℕ) [NeZero L]
    (target : ℕ → ℤ → Bool)
    (hno : ¬ (EventuallyPeriodic (fun t => target t 0) ∧
      EventuallyPeriodic (fun t => target t 1))) (T : ℕ) :
    ∃ t, T≤t ∧ ∃ i : ℤ, |i|≤(t : ℤ) ∧
      weave (fun _ => L) t i ≠ target t i := by
  have hL : 0<L := Nat.pos_of_ne_zero (NeZero.ne L)
  obtain ⟨t,ht,i,hi,he⟩ := arbitrarily_late_cone_mismatch
    (ringStep L) (fun t => ring (fun _ => L) t) (fixed_ring_step L)
    (fun s i => s (i : ZMod L)) target hno T
  refine ⟨t,ht,i,hi,?_⟩
  rw [ring_read (fun _ => L) (fun _ => hL) t i] at he
  exact he

end FVLT.WovenCylinderV1
