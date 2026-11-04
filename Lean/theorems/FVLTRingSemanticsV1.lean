import FVLTWovenEvolutionV1
import Mathlib.Data.ZMod.Basic

/-! The independently generated integer recurrence descends to actual ZMod rings.
The current cell is canonicalized BEFORE casting its parents into the old ring. -/
namespace FVLT.RingSemanticsV1
open WovenCanonicalV1 WovenEvolutionV1

def ring (L : ℕ → ℕ) (t : ℕ) (z : ZMod (L t)) : Bool := weave L t z.val

theorem ring_read (L : ℕ → ℕ) (hpos : ∀t,0<L t) (t : ℕ) (i : ℤ) :
    ring L t (i : ZMod (L t))=weave L t i := by
  let : NeZero (L t) := ⟨Nat.ne_of_gt (hpos t)⟩
  apply weave_respects_mod L t (hpos t)
  rw [ZMod.val_intCast, Int.emod_emod]

theorem ring_seed (L : ℕ → ℕ) (hpos : ∀t,0<L t) (z : ZMod (L 0)) :
    ring L 0 z=decide (z=0) := by
  let : NeZero (L 0) := ⟨Nat.ne_of_gt (hpos 0)⟩
  have hz : rep (L 0) (z.val : ℤ)=0 ↔ z=0 := by
    have hr0 : rep (L 0) 0=0 := rep_eq_self _ (hpos 0) _ (zero_in_window _)
    rw [← hr0, rep_eq_iff_mod _ (hpos 0)]
    rw [← ZMod.intCast_eq_intCast_iff']
    simp
  change decide (rep (L 0) (z.val : ℤ)=0)=decide (z=0)
  simp only [hz]

theorem ring_step (L : ℕ → ℕ) (hpos : ∀t,0<L t) (t : ℕ)
    (z : ZMod (L (t+1))) :
    ring L (t+1) z=
      let j := rep (L (t+1)) (z.val : ℤ)
      rule (ring L t ((j-1 : ℤ) : ZMod (L t)))
        (ring L t (j : ZMod (L t))) (ring L t ((j+1 : ℤ) : ZMod (L t))) := by
  simp only [ring_read L hpos]
  rfl

theorem ring_core_eq_infinite (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t)
    (t : ℕ) (i : ℤ) (hi : |i|≤(t : ℤ)) :
    ring L t (i : ZMod (L t))=infinite t i := by
  rw [ring_read L hpos, weave_eq_infinite_core L hpos hcap hgap t i hi]

end FVLT.RingSemanticsV1
