import FVLT.PenGaussV1
import Development.AbelianVarietyTheory.Definitions.Foundations.PetIPSmulRight
import Development.AbelianVarietyTheory.Definitions.Foundations.RepL
import Development.AbelianVarietyTheory.Statements.CuspidalUnitaryTwists.Chapter
import CompanionTheory.EightfoldTheory.VariationTheory.AutomorphicForms.Newform

open UpperHalfPlane Complex MeasureTheory CongruenceSubgroup GlobalTheory.EisM UpperTheory.V.Af Filter Topology
open scoped MatrixGroups Real ComplexConjugate Manifold ModularForm

/-!
Additive variant overlay for
`Development.AbelianVarietyTheory.Proofs.FoundationProofs.DirichletCharFiniteFourierTransformProperties`.
Proves all 10 original declarations in `GlobalTheory.EisM` directly from `FVLT.PenGaussV1`.
-/

noncomputable section

namespace GlobalTheory.EisM

private theorem hat_eq_pen_overlay {N : ℕ} (φ : ZMod N → ℂ) (d : ℤ) :
    hat φ d = FVLT.PenGaussV1.pen φ d := by
  unfold hat
  exact (FVLT.PenGaussV1.pen_eq_hatForm φ d).symm

private theorem ch_eq_pen_overlay {N : ℕ} (χ : DirichletCharacter ℂ N) (d : ℤ) :
    ch χ d = FVLT.PenGaussV1.ch χ d :=
  rfl

theorem hat_eq_sum_std {N : ℕ} [NeZero N] (φ : ZMod N → ℂ) (d : ℤ) :
    hat φ d = ∑ y : ZMod N, φ y * ZMod.stdAddChar (y * (d : ZMod N)) := by
  rw [hat_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_eq_sum_std φ d

theorem hat_add_period {N : ℕ} [NeZero N] (φ : ZMod N → ℂ) (x : ℤ) :
    hat φ (x + N) = hat φ x := by
  rw [hat_eq_pen_overlay, hat_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_add_period φ x

theorem hat_mul_unit {N : ℕ} [NeZero N] (θ : DirichletCharacter ℂ N) (d x : ℤ)
    (hd : IsUnit (d : ZMod N)) :
    hat θ (x * d) = ch θ⁻¹ d * hat θ x := by
  rw [hat_eq_pen_overlay, hat_eq_pen_overlay, ch_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_mul_unit θ d x hd

theorem hat_zero_of_ne_one {N : ℕ} [NeZero N] (θ : DirichletCharacter ℂ N) (h : θ ≠ 1) :
    hat θ 0 = 0 := by
  rw [hat_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_zero_of_ne_one θ h

theorem isUnit_of_isCoprime {N : ℕ} (d : ℤ) (h : IsCoprime d N) : IsUnit (d : ZMod N) :=
  FVLT.PenGaussV1.isUnit_of_isCoprime d h

theorem hat_prime_one {l : ℕ} [Fact l.Prime] (x : ℤ) :
    hat (1 : DirichletCharacter ℂ l) x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1 := by
  rw [hat_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_one_prime x

theorem hat_prime_ne_one {l : ℕ} [Fact l.Prime] (ψ : DirichletCharacter ℂ l) (hψ : ψ ≠ 1) :
    hat ψ 1 ≠ 0 ∧ ∀ x, hat ψ x = hat ψ 1 * ch ψ⁻¹ x := by
  simp only [hat_eq_pen_overlay, ch_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_prime_ne_one ψ hψ

theorem stdAddChar_nat_mul_int {M : ℕ} [NeZero M] (a : ZMod M) (x : ℤ) :
    (ZMod.stdAddChar (a * (x : ZMod M)) : ℂ) = cexp (2 * π * Complex.I * ((a.val : ℂ) * x) / M) :=
  FVLT.PenGaussV1.stdAddChar_nat_mul_int a x

theorem hat_mul_coprime (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
    (φ : DirichletCharacter ℂ (N * l)) (hN : 0 < N) (hl : 0 < l) (hc : N.Coprime l)
    (hφ : ∀ d : ℤ, ch φ d = ch θ d * ch ψ d) (x : ℤ) :
    hat φ x = ch θ l * ch ψ N * (hat θ x * hat ψ x) := by
  simp only [hat_eq_pen_overlay, ch_eq_pen_overlay] at *
  exact FVLT.PenGaussV1.pen_mul_coprime N l θ ψ φ hN hl hc hφ x

theorem hat_char_props :
    (∀ (N : ℕ) (θ : DirichletCharacter ℂ N), 0 < N →
      (∀ x : ℤ, hat θ (x + N) = hat θ x) ∧
      (∀ d x : ℤ, IsCoprime d N → hat θ (x * d) = ch θ⁻¹ d * hat θ x) ∧
      (θ ≠ 1 → hat θ 0 = 0)) ∧
    (∀ (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
        (φ : DirichletCharacter ℂ (N * l)),
      0 < N → 0 < l → N.Coprime l → (∀ d : ℤ, ch φ d = ch θ d * ch ψ d) →
      ∀ x, hat φ x = ch θ l * ch ψ N * (hat θ x * hat ψ x)) ∧
    ∀ (l : ℕ) (ψ : DirichletCharacter ℂ l), l.Prime →
      (ψ ≠ 1 → hat ψ 1 ≠ 0 ∧ ∀ x, hat ψ x = hat ψ 1 * ch ψ⁻¹ x) ∧
      (ψ = 1 → ∀ x : ℤ, hat ψ x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1) := by
  simp only [hat_eq_pen_overlay, ch_eq_pen_overlay]
  exact FVLT.PenGaussV1.pen_char_props

end GlobalTheory.EisM
