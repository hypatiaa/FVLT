import FVLTS4kCoreV1

/-! PRIVATE source only. G3 proves the unrestricted existential collapse for
fixed drivers and finite least-death certificates. It constructs no G2 map.
The chosen target seed is fixed for all horizons, and can even be shared
by all source seeds. No unbounded-driver instance is asserted. -/
set_option autoImplicit false

namespace FVLT.S4kCollapseV1

open FVLT.S4kCoreV1

/-- One target seed for every horizon, not a separately chosen seed per K. -/
def ChoiceTransport (cs ct : Nat → Bool) (Vs Vt Δ : Nat) : Prop :=
  ∀ s : Int → Bool, HasWidth Vs s →
    ∃ r : Int → Bool, HasWidth Vt r ∧
      ∀ K : Nat, Surv cs s (K + Δ) → Surv ct r K

/-- At positive exact death there is a single seed surviving through D-1. -/
theorem exactDeath_has_predecessor_survivor
    {c : Nat → Bool} {W D : Nat} (hd : ExactDeath c W D) (hpos : 0 < D) :
    ∃ s : Int → Bool, HasWidth W s ∧ Surv c s (D - 1) := by
  classical
  have hn : ¬ DeadBy c W (D - 1) := hd.2 (D - 1) (by omega)
  by_contra hnone
  apply hn
  intro s hs hsurv
  exact hnone ⟨s, hs, hsurv⟩

/-- A longest-lived target survivor realizes the choice form whenever source
seeds all fail by target death plus delay. Target death zero is handled by
the zero seed and a contradictory source antecedent, with no predecessor. -/
theorem choiceTransport_iff_deadBy
    (cs ct : Nat → Bool) (Vs Vt Δ Dt : Nat)
    (ht : ExactDeath ct Vt Dt) :
    ChoiceTransport cs ct Vs Vt Δ ↔ DeadBy cs Vs (Dt + Δ) := by
  constructor
  · intro hc s hs hsurv
    obtain ⟨r, hr, htr⟩ := hc s hs
    exact ht.1 r hr (htr Dt hsurv)
  · intro hd
    by_cases hz : Dt = 0
    · intro s hs
      refine ⟨fun _ => false, hasWidth_zero Vt, ?_⟩
      intro K hsurv
      have hle : Dt + Δ ≤ K + Δ := by omega
      exact False.elim (hd s hs (surv_mono hle hsurv))
    · have hpos : 0 < Dt := by omega
      obtain ⟨r, hr, hsurv⟩ := exactDeath_has_predecessor_survivor ht hpos
      intro s hs
      refine ⟨r, hr, ?_⟩
      intro K hsource
      by_cases hK : K < Dt
      · exact surv_mono (by omega : K ≤ Dt - 1) hsurv
      · have hle : Dt + Δ ≤ K + Δ := by omega
        exact False.elim (hd s hs (surv_mono hle hsource))

/-- G3, finite version: fixed source and target drivers, with local finite
least-death certificates. This is not an equivalence for a specified F. -/
theorem choiceTransport_iff_exactDeath_le
    (cs ct : Nat → Bool) (Vs Vt Δ Ds Dt : Nat)
    (hs : ExactDeath cs Vs Ds) (ht : ExactDeath ct Vt Dt) :
    ChoiceTransport cs ct Vs Vt Δ ↔ Ds ≤ Dt + Δ := by
  exact (choiceTransport_iff_deadBy cs ct Vs Vt Δ Dt ht).trans
    (exactDeath_deadBy_iff_le hs)

/-- A3 specialization, retaining the actual source and target phases. -/
theorem phase_choiceTransport_iff_exactDeath_le
    (c : Nat → Bool) (P W Δ Ds Dt : Nat) (φ ψ : Fin P)
    (hs : ExactDeath (phase c φ) (W + P) Ds)
    (ht : ExactDeath (phase c ψ) W Dt) :
    ChoiceTransport (phase c φ) (phase c ψ) (W + P) W Δ ↔
      Ds ≤ Dt + Δ :=
  choiceTransport_iff_exactDeath_le (phase c φ) (phase c ψ)
    (W + P) W Δ Ds Dt hs ht

end FVLT.S4kCollapseV1
