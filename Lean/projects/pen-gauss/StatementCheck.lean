import FVLT.PenGaussV1

/-! Independent statement pin transcribed from the source conjunction named in SPEC §2. -/

namespace FVLT.PenGaussV1.StatementCheck

open FVLT.PenGaussV1

theorem expected : (∀ (N : ℕ) (θ : DirichletCharacter ℂ N), 0 < N → (∀ x : ℤ, pen θ (x + N) = pen θ x) ∧ (∀ d x : ℤ, IsCoprime d N → pen θ (x * d) = ch θ⁻¹ d * pen θ x) ∧ (θ ≠ 1 → pen θ 0 = 0)) ∧ (∀ (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l) (φ : DirichletCharacter ℂ (N * l)), 0 < N → 0 < l → N.Coprime l → (∀ d : ℤ, ch φ d = ch θ d * ch ψ d) → ∀ x, pen φ x = ch θ l * ch ψ N * (pen θ x * pen ψ x)) ∧ ∀ (l : ℕ) (ψ : DirichletCharacter ℂ l), l.Prime → (ψ ≠ 1 → pen ψ 1 ≠ 0 ∧ ∀ x, pen ψ x = pen ψ 1 * ch ψ⁻¹ x) ∧ (ψ = 1 → ∀ x : ℤ, pen ψ x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1) := pen_char_props

end FVLT.PenGaussV1.StatementCheck
