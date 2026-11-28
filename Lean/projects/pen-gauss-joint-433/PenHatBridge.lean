import FVLT.PenGaussV1
import FVLT.PenGaussFieldV1
import Development.AbelianVarietyTheory.Definitions.Foundations.PetIPSmulRight
import Development.AbelianVarietyTheory.Proofs.FoundationProofs.DirichletCharFiniteFourierTransformProperties

/-!
Joint cross-check on Lean 4.33.1 (`~/alpoge_rh_audit_20261120/x/lean`) against the
original compiled `DirichletCharFiniteFourierTransformProperties.olean`.
Connects Codex's `FVLT.PenGaussV1` and Vision's `FVLT.PenGaussFieldV1` to
Alpöge's `GlobalTheory.EisM.hat`, `ch`, and `hat_char_props`.
-/

namespace FVLT.PenGaussJoint

open Complex

theorem hat_eq_pen {N : ℕ} (φ : ZMod N → ℂ) (d : ℤ) :
    GlobalTheory.EisM.hat φ d = FVLT.PenGaussV1.pen φ d := by
  unfold GlobalTheory.EisM.hat
  exact (FVLT.PenGaussV1.pen_eq_hatForm φ d).symm

theorem quadPen_eq_pen_one {q : ℕ} (φ : ZMod q → ℂ) :
    FVLT.PenGaussFieldV1.quadPen φ = FVLT.PenGaussV1.pen φ 1 := by
  rw [FVLT.PenGaussV1.pen_eq_hatForm]
  unfold FVLT.PenGaussFieldV1.quadPen
  refine Finset.sum_congr rfl fun y _ => ?_
  congr 2
  push_cast
  ring

theorem quadPen_eq_hat_one {q : ℕ} (φ : ZMod q → ℂ) :
    FVLT.PenGaussFieldV1.quadPen φ = GlobalTheory.EisM.hat φ 1 :=
  (quadPen_eq_pen_one φ).trans (hat_eq_pen φ 1).symm

theorem ch_eq {N : ℕ} (χ : DirichletCharacter ℂ N) (d : ℤ) :
    GlobalTheory.EisM.ch χ d = FVLT.PenGaussV1.ch χ d :=
  rfl

theorem hat_char_props_from_pen :
    (∀ (N : ℕ) (θ : DirichletCharacter ℂ N), 0 < N →
      (∀ x : ℤ, GlobalTheory.EisM.hat θ (x + N) = GlobalTheory.EisM.hat θ x) ∧
      (∀ d x : ℤ, IsCoprime d N →
        GlobalTheory.EisM.hat θ (x * d) = GlobalTheory.EisM.ch θ⁻¹ d * GlobalTheory.EisM.hat θ x) ∧
      (θ ≠ 1 → GlobalTheory.EisM.hat θ 0 = 0)) ∧
    (∀ (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
        (φ : DirichletCharacter ℂ (N * l)),
      0 < N → 0 < l → N.Coprime l →
      (∀ d : ℤ, GlobalTheory.EisM.ch φ d = GlobalTheory.EisM.ch θ d * GlobalTheory.EisM.ch ψ d) →
      ∀ x, GlobalTheory.EisM.hat φ x =
        GlobalTheory.EisM.ch θ l * GlobalTheory.EisM.ch ψ N *
          (GlobalTheory.EisM.hat θ x * GlobalTheory.EisM.hat ψ x)) ∧
    ∀ (l : ℕ) (ψ : DirichletCharacter ℂ l), l.Prime →
      (ψ ≠ 1 → GlobalTheory.EisM.hat ψ 1 ≠ 0 ∧
        ∀ x, GlobalTheory.EisM.hat ψ x = GlobalTheory.EisM.hat ψ 1 * GlobalTheory.EisM.ch ψ⁻¹ x) ∧
      (ψ = 1 → ∀ x : ℤ, GlobalTheory.EisM.hat ψ x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1) := by
  have hpen := FVLT.PenGaussV1.pen_char_props
  simp only [hat_eq_pen, ch_eq]
  exact hpen

/-- Definitional type equality check against original `GlobalTheory.EisM.hat_char_props`. -/
theorem original_and_pen_props_same_type :
    (fun (p : (∀ (N : ℕ) (θ : DirichletCharacter ℂ N), 0 < N →
      (∀ x : ℤ, GlobalTheory.EisM.hat θ (x + N) = GlobalTheory.EisM.hat θ x) ∧
      (∀ d x : ℤ, IsCoprime d N →
        GlobalTheory.EisM.hat θ (x * d) = GlobalTheory.EisM.ch θ⁻¹ d * GlobalTheory.EisM.hat θ x) ∧
      (θ ≠ 1 → GlobalTheory.EisM.hat θ 0 = 0)) ∧
    (∀ (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
        (φ : DirichletCharacter ℂ (N * l)),
      0 < N → 0 < l → N.Coprime l →
      (∀ d : ℤ, GlobalTheory.EisM.ch φ d = GlobalTheory.EisM.ch θ d * GlobalTheory.EisM.ch ψ d) →
      ∀ x, GlobalTheory.EisM.hat φ x =
        GlobalTheory.EisM.ch θ l * GlobalTheory.EisM.ch ψ N *
          (GlobalTheory.EisM.hat θ x * GlobalTheory.EisM.hat ψ x)) ∧
    ∀ (l : ℕ) (ψ : DirichletCharacter ℂ l), l.Prime →
      (ψ ≠ 1 → GlobalTheory.EisM.hat ψ 1 ≠ 0 ∧
        ∀ x, GlobalTheory.EisM.hat ψ x = GlobalTheory.EisM.hat ψ 1 * GlobalTheory.EisM.ch ψ⁻¹ x) ∧
      (ψ = 1 → ∀ x : ℤ, GlobalTheory.EisM.hat ψ x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1)) => p)
      @GlobalTheory.EisM.hat_char_props =
    @hat_char_props_from_pen → True :=
  fun _ => trivial

#print axioms hat_eq_pen
#print axioms quadPen_eq_pen_one
#print axioms quadPen_eq_hat_one
#print axioms hat_char_props_from_pen

end FVLT.PenGaussJoint
