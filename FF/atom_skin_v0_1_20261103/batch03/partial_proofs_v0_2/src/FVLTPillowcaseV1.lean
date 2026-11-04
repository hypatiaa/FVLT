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

private def parityBit (c : Bool) : ℤ := if c then 1 else 0

private theorem parityBit_mul (c : Bool) (x : ℤ) :
    parityBit c * x = (if c then x else 0) := by
  cases c <;> simp [parityBit]

private theorem corner_fst_scaled (a b : ℕ) (c : Bool × Bool) :
    (corner a b c).1 = parityBit c.1 * (a : ℤ) := by
  exact (parityBit_mul c.1 (a : ℤ)).symm

private theorem corner_snd_scaled (a b : ℕ) (c : Bool × Bool) :
    (corner a b c).2 = parityBit c.2 * (b : ℤ) := by
  exact (parityBit_mul c.2 (b : ℤ)).symm

private theorem parity_decompose (z : ℤ) :
    parityBit (decide (z % 2 = 1)) = z + 2 * (-(z / 2)) := by
  by_cases h : z % 2 = 1
  · simp [parityBit, h]
    omega
  · have h0 : z % 2 = 0 := by omega
    simp [parityBit, h]
    omega

private theorem parity_translation (c d : Bool) (i : ℤ)
    (h : parityBit d = parityBit c + 2 * i) : c = d := by
  cases c <;> cases d <;> simp [parityBit] at h ⊢ <;> omega

private theorem parity_halfTurn (c d : Bool) (i : ℤ)
    (h : parityBit d = 2 * i - parityBit c) : c = d := by
  cases c <;> cases d <;> simp [parityBit] at h ⊢ <;> omega

theorem fixingHalfTurn_iff_corner_class
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    HasFixingHalfTurn a b v ↔
      ∃ c : Bool × Bool, pillowRel a b v (corner a b c) := by
  constructor
  · intro h
    rcases (fixingHalfTurn_iff_multiples a b ha hb v).mp h with ⟨i, j, rfl⟩
    let c : Bool × Bool := (decide (i % 2 = 1), decide (j % 2 = 1))
    refine ⟨c, -(i / 2), -(j / 2), Or.inl ?_⟩
    apply Prod.ext
    · change (corner a b c).1 = i * (a : ℤ) + 2 * (-(i / 2)) * (a : ℤ)
      rw [corner_fst_scaled]
      change parityBit (decide (i % 2 = 1)) * (a : ℤ) = _
      rw [parity_decompose]
      ring
    · change (corner a b c).2 = j * (b : ℤ) + 2 * (-(j / 2)) * (b : ℤ)
      rw [corner_snd_scaled]
      change parityBit (decide (j % 2 = 1)) * (b : ℤ) = _
      rw [parity_decompose]
      ring
  · rintro ⟨c, i, j, h | h⟩
    · apply (fixingHalfTurn_iff_multiples a b ha hb v).mpr
      have hx := congrArg Prod.fst h
      have hy := congrArg Prod.snd h
      simp only [translation, Prod.fst, corner_fst_scaled] at hx
      simp only [translation, Prod.snd, corner_snd_scaled] at hy
      refine ⟨parityBit c.1 - 2 * i, parityBit c.2 - 2 * j, Prod.ext ?_ ?_⟩
      · calc
          v.1 = parityBit c.1 * (a : ℤ) - 2 * i * (a : ℤ) := by omega
          _ = (parityBit c.1 - 2 * i) * (a : ℤ) := by ring
      · calc
          v.2 = parityBit c.2 * (b : ℤ) - 2 * j * (b : ℤ) := by omega
          _ = (parityBit c.2 - 2 * j) * (b : ℤ) := by ring
    · apply (fixingHalfTurn_iff_multiples a b ha hb v).mpr
      have hx := congrArg Prod.fst h
      have hy := congrArg Prod.snd h
      simp only [halfTurn, Prod.fst, corner_fst_scaled] at hx
      simp only [halfTurn, Prod.snd, corner_snd_scaled] at hy
      refine ⟨2 * i - parityBit c.1, 2 * j - parityBit c.2, Prod.ext ?_ ?_⟩
      · calc
          v.1 = 2 * i * (a : ℤ) - parityBit c.1 * (a : ℤ) := by omega
          _ = (2 * i - parityBit c.1) * (a : ℤ) := by ring
      · calc
          v.2 = 2 * j * (b : ℤ) - parityBit c.2 * (b : ℤ) := by omega
          _ = (2 * j - parityBit c.2) * (b : ℤ) := by ring

theorem four_corner_classes_distinct
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (c d : Bool × Bool) :
    pillowRel a b (corner a b c) (corner a b d) ↔ c = d := by
  have ha' : (a : ℤ) ≠ 0 := by omega
  have hb' : (b : ℤ) ≠ 0 := by omega
  constructor
  · rintro ⟨i, j, h | h⟩
    · have hx := congrArg Prod.fst h
      have hy := congrArg Prod.snd h
      simp only [translation, Prod.fst, corner_fst_scaled] at hx
      simp only [translation, Prod.snd, corner_snd_scaled] at hy
      have hx' : parityBit d.1 = parityBit c.1 + 2 * i := by
        apply mul_right_cancel₀ ha'
        calc
          parityBit d.1 * (a : ℤ) = parityBit c.1 * (a : ℤ) + 2 * i * (a : ℤ) := hx
          _ = (parityBit c.1 + 2 * i) * (a : ℤ) := by ring
      have hy' : parityBit d.2 = parityBit c.2 + 2 * j := by
        apply mul_right_cancel₀ hb'
        calc
          parityBit d.2 * (b : ℤ) = parityBit c.2 * (b : ℤ) + 2 * j * (b : ℤ) := hy
          _ = (parityBit c.2 + 2 * j) * (b : ℤ) := by ring
      exact Prod.ext (parity_translation c.1 d.1 i hx') (parity_translation c.2 d.2 j hy')
    · have hx := congrArg Prod.fst h
      have hy := congrArg Prod.snd h
      simp only [halfTurn, Prod.fst, corner_fst_scaled] at hx
      simp only [halfTurn, Prod.snd, corner_snd_scaled] at hy
      have hx' : parityBit d.1 = 2 * i - parityBit c.1 := by
        apply mul_right_cancel₀ ha'
        calc
          parityBit d.1 * (a : ℤ) = 2 * i * (a : ℤ) - parityBit c.1 * (a : ℤ) := hx
          _ = (2 * i - parityBit c.1) * (a : ℤ) := by ring
      have hy' : parityBit d.2 = 2 * j - parityBit c.2 := by
        apply mul_right_cancel₀ hb'
        calc
          parityBit d.2 * (b : ℤ) = 2 * j * (b : ℤ) - parityBit c.2 * (b : ℤ) := hy
          _ = (2 * j - parityBit c.2) * (b : ℤ) := by ring
      exact Prod.ext (parity_halfTurn c.1 d.1 i hx') (parity_halfTurn c.2 d.2 j hy')
  · intro h
    subst d
    exact (pillowRel_equivalence a b ha hb).refl (corner a b c)

end FVLT.PillowcaseV1


