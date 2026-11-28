import Mathlib.NumberTheory.LegendreSymbol.QuadraticChar.Basic
import Mathlib.NumberTheory.DirichletCharacter.GaussSum
import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar
import Mathlib.Tactic.LinearCombination

/-! The two Gaussian periods on the quadratic residues and nonresidues of an
odd prime field. At seven these are the viewer's two triangles. -/
namespace FareyPrimePeriods

variable {p : ℕ} [Fact p.Prime]

/-- Actual sum of additive phasors with quadratic sign `e`. -/
noncomputable def period (ψ : AddChar (ZMod p) ℂ) (e : ℤ) : ℂ :=
  ∑ a : ZMod p, if quadraticChar (ZMod p) a = e then ψ a else 0

private noncomputable def signChar (p : ℕ) [Fact p.Prime] : MulChar (ZMod p) ℂ :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

theorem periods_add {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive) :
    period ψ 1 + period ψ (-1) = -1 := by
  have hne : ψ ≠ 1 := by simpa using hψ (a := 1) one_ne_zero
  rw [← gaussSum_one_left hne, gaussSum, period, period, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro a _
  by_cases ha : a = 0
  · subst a
    simp [MulChar.map_zero]
  · rw [MulChar.one_apply (isUnit_iff_ne_zero.mpr ha), one_mul]
    rcases quadraticChar_dichotomy ha with h | h <;> simp [h]

theorem periods_sub {ψ : AddChar (ZMod p) ℂ} :
    period ψ 1 - period ψ (-1) =
      gaussSum ((quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)) ψ := by
  rw [gaussSum, period, period, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro a _
  change _ = ((quadraticChar (ZMod p) a : ℤ) : ℂ) * ψ a
  by_cases ha : a = 0
  · subst a
    simp
  · rcases quadraticChar_dichotomy ha with h | h <;> simp [h]

theorem periods_sub_sq {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive) (hp : p ≠ 2) :
    (period ψ 1 - period ψ (-1))^2 = (quadraticChar (ZMod p) (-1) : ℂ) * p := by
  have hc : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hn : signChar p ≠ 1 := by
    obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one' hc
    refine MulChar.ne_one_iff.mpr ⟨a, ?_⟩
    change (quadraticChar (ZMod p) a : ℂ) ≠ 1
    rw [ha]
    norm_num
  have hq : (signChar p).IsQuadratic :=
    MulChar.IsQuadratic.comp (quadraticChar_isQuadratic _) _
  rw [periods_sub]
  change (gaussSum (signChar p) ψ)^2 = _
  rw [gaussSum_sq hn hq hψ, ZMod.card]
  rfl

theorem periods_mul {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive) (hp : p ≠ 2) :
    period ψ 1 * period ψ (-1) = (1 - (quadraticChar (ZMod p) (-1) : ℂ) * p) / 4 := by
  have ha := periods_add hψ
  have hs := periods_sub_sq hψ hp
  linear_combination ((period ψ 1 + period ψ (-1) - 1) / 4) * ha - hs / 4

end FareyPrimePeriods
