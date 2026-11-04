import FVLTPillowcaseDataV1
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

namespace FVLT.PillowcaseV1

theorem pillowRel_equivalence
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) : Equivalence (pillowRel a b) := by
  refine ⟨?_, ?_, ?_⟩
  · intro v
    refine ⟨0, 0, Or.inl ?_⟩
    simp [translation]
  · rintro v w ⟨i, j, hw | hw⟩
    · refine ⟨-i, -j, Or.inl ?_⟩
      subst w
      apply Prod.ext <;> dsimp [translation] <;> ring
    · refine ⟨i, j, Or.inr ?_⟩
      subst w
      apply Prod.ext <;> dsimp [halfTurn] <;> ring
  · rintro u v w ⟨i, j, hv | hv⟩ ⟨k, l, hw | hw⟩
    · refine ⟨i + k, j + l, Or.inl ?_⟩
      subst w
      subst v
      apply Prod.ext <;> dsimp [translation] <;> ring
    · refine ⟨k - i, l - j, Or.inr ?_⟩
      subst w
      subst v
      apply Prod.ext <;> dsimp [translation, halfTurn] <;> ring
    · refine ⟨i + k, j + l, Or.inr ?_⟩
      subst w
      subst v
      apply Prod.ext <;> dsimp [translation, halfTurn] <;> ring
    · refine ⟨k - i, l - j, Or.inl ?_⟩
      subst w
      subst v
      apply Prod.ext <;> dsimp [halfTurn, translation] <;> ring

theorem halfTurn_not_identity (a b : ℕ) (i j : ℤ) :
    ∃ u : Point, halfTurn a b i j u ≠ u := by
  refine ⟨(i * (a : ℤ) + 1, j * (b : ℤ)), ?_⟩
  intro h
  have hx := congrArg Prod.fst h
  dsimp [halfTurn] at hx
  ring_nf at hx
  omega

theorem fixingHalfTurn_iff_multiples
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    HasFixingHalfTurn a b v ↔
      ∃ i j : ℤ, v = (i * (a : ℤ), j * (b : ℤ)) := by
  constructor
  · rintro ⟨i, j, h⟩
    have hx : 2 * (i * (a : ℤ)) - v.1 = v.1 := by
      simpa [halfTurn, mul_assoc] using congrArg Prod.fst h
    have hy : 2 * (j * (b : ℤ)) - v.2 = v.2 := by
      simpa [halfTurn, mul_assoc] using congrArg Prod.snd h
    refine ⟨i, j, Prod.ext ?_ ?_⟩ <;> omega
  · rintro ⟨i, j, rfl⟩
    refine ⟨i, j, ?_⟩
    apply Prod.ext <;> simp [halfTurn, mul_assoc] <;> omega

theorem nonzero_translation_fixes_nothing
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (i j : ℤ) (hij : i ≠ 0 ∨ j ≠ 0) (v : Point) :
    translation a b i j v ≠ v := by
  intro h
  have hx := congrArg Prod.fst h
  have hy := congrArg Prod.snd h
  dsimp [translation] at hx hy
  have hxa : 2 * i * (a : ℤ) = 0 := by omega
  have hyb : 2 * j * (b : ℤ) = 0 := by omega
  have ha' : (a : ℤ) ≠ 0 := by omega
  have hb' : (b : ℤ) ≠ 0 := by omega
  rcases hij with hi | hj
  · exact (mul_ne_zero (mul_ne_zero (by decide : (2 : ℤ) ≠ 0) hi) ha') hxa
  · exact (mul_ne_zero (mul_ne_zero (by decide : (2 : ℤ) ≠ 0) hj) hb') hyb

end FVLT.PillowcaseV1
