import FVLTS4jBoundedDeathV1

/-! PRIVATE S4k source preparation. Inclusive survival uses the actual Rule 30
left evolution. G2 admissibility of an explicit finite-description algorithm
is an external guard, not a consequence of the proposition DOMContract. -/
set_option autoImplicit false

namespace FVLT.S4kCoreV1

open Ruliology.CellularAutomata Rule30DrivenLeft
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1 FVLT.S4hFiniteTailV1

/-- Physical negative support through depth W; positive coordinates are irrelevant. -/
def HasWidth (W : Nat) (s : Int → Bool) : Prop :=
  ∀ p : Int, p < -(W : Int) → s p = false

theorem hasWidth_iff_depth (W : Nat) (s : Int → Bool) :
    HasWidth W s ↔ ∀ d : Nat, W < d → s (-(d : Int)) = false := by
  constructor
  · intro hs d hd
    exact hs (-(d : Int)) (by omega)
  · intro hs p hp
    have hn : 0 ≤ -p := by omega
    have he : ((-p).toNat : Int) = -p := Int.toNat_of_nonneg hn
    have hd : W < (-p).toNat := by omega
    have hz := hs (-p).toNat hd
    have he' : -(((-p).toNat : Nat) : Int) = p := by omega
    rw [he'] at hz
    exact hz

def Surv (c : Nat → Bool) (s : Int → Bool) (K : Nat) : Prop :=
  ∀ t : Nat, t ≤ K → c t = true → L c s t (-1) = !c (t + 1)

def DeadBy (c : Nat → Bool) (W D : Nat) : Prop :=
  ∀ s : Int → Bool, HasWidth W s → ¬ Surv c s D

/-- Local finite least-death certificate, with no default for infinite death. -/
def ExactDeath (c : Nat → Bool) (W D : Nat) : Prop :=
  DeadBy c W D ∧ ∀ K : Nat, K < D → ¬ DeadBy c W K

def phase (c : Nat → Bool) {P : Nat} (φ : Fin P) (t : Nat) : Bool :=
  c (t + φ.val)

def BaseFinite (c : Nat → Bool) (P W0 : Nat) : Prop :=
  ∀ φ : Fin P, ∀ W : Nat, W < W0 + P → ∃ D : Nat, DeadBy (phase c φ) W D

/-- The semantic contract only. G2 must separately certify F and ψ as fixed,
explicit computable finite-description rules; arbitrary choice is not G2. -/
def DOMContract (c : Nat → Bool) (P Δ W0 : Nat)
    (F : Fin P → Nat → (Int → Bool) → Int → Bool)
    (ψ : Fin P → Fin P) : Prop :=
  ∀ φ : Fin P, ∀ W : Nat, W0 ≤ W → ∀ s : Int → Bool,
    HasWidth (W + P) s →
      HasWidth W (F φ W s) ∧
      ∀ K : Nat, Surv (phase c φ) s (K + Δ) →
        Surv (phase c (ψ φ)) (F φ W s) K

theorem hasWidth_zero (W : Nat) : HasWidth W (fun _ => false) := by
  intro p hp
  rfl

theorem exists_hasWidth (W : Nat) : ∃ s : Int → Bool, HasWidth W s :=
  ⟨fun _ => false, hasWidth_zero W⟩

theorem hasWidth_mono {V W : Nat} {s : Int → Bool}
    (hVW : V ≤ W) (hs : HasWidth V s) : HasWidth W s := by
  intro p hp
  exact hs p (by omega)

theorem surv_mono {c : Nat → Bool} {s : Int → Bool} {K J : Nat}
    (hKJ : K ≤ J) (hs : Surv c s J) : Surv c s K := by
  intro t ht hc
  exact hs t (Nat.le_trans ht hKJ) hc

theorem deadBy_mono {c : Nat → Bool} {W D E : Nat}
    (hDE : D ≤ E) (hd : DeadBy c W D) : DeadBy c W E := by
  intro s hs he
  exact hd s hs (surv_mono hDE he)

theorem exactDeath_deadBy_iff_le {c : Nat → Bool} {W D E : Nat}
    (hd : ExactDeath c W D) : DeadBy c W E ↔ D ≤ E := by
  constructor
  · intro he
    by_contra hn
    exact hd.2 E (by omega) he
  · intro hDE
    exact deadBy_mono hDE hd.1

/-- The inherited finite-support convention supplies a physical width. -/
theorem finiteLeft_hasWidth {s : Int → Bool} (hs : FiniteLeft s) :
    ∃ W : Nat, HasWidth W s := by
  obtain ⟨W, hW⟩ := hs
  exact ⟨W, hW⟩

/-- All-time pins restrict to every inclusive survival horizon. -/
theorem pins_surv {c : Nat → Bool} {s : Int → Bool} (hp : Pins c s)
    (K : Nat) : Surv c s K := by
  intro t ht hc
  exact hp t hc

/-- Exact bridge to the predecessor BlackFailure form, with inclusive K. -/
theorem surv_iff_no_blackFailure (c : Nat → Bool) (a : Nat → Bool) (K : Nat) :
    Surv c (bitRow a) K ↔
      ∀ t : Nat, t ≤ K → ¬ FVLT.S4jBoundedDeathV1.BlackFailure c a t := by
  constructor
  · intro hs t ht hf
    exact hf.2 (hs t ht hf.1)
  · intro hn t ht hc
    by_contra hb
    exact hn t ht ⟨hc, hb⟩

end FVLT.S4kCoreV1


