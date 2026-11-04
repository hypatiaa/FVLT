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

private def asPoint (p : ℕ × ℕ) : Point := (p.1, p.2)

private def residue (a : ℕ) (x : ℤ) : ℕ := (x % (2 * (a : ℤ))).toNat

private def rawKey (a b x y : ℕ) : PillowKey :=
  let r := if x ≤ a then x else 2 * a - x
  if r = 0 ∨ r = a ∨ y = 0 ∨ y = b then .boundary r y
  else if x < a then .front r y else .back r y

private def decode (a : ℕ) (k : PillowKey) : ℕ × ℕ :=
  match k with
  | .boundary r y => (r, y)
  | .front r y => (r, y)
  | .back r y => (2 * a - r, y)

private def canonical (a b : ℕ) (p : Point) : Prop :=
  0 ≤ p.1 ∧ p.1 < 2 * (a : ℤ) ∧ 0 ≤ p.2 ∧ p.2 ≤ (b : ℤ) ∧
    ((p.2 = 0 ∨ p.2 = (b : ℤ)) → p.1 ≤ (a : ℤ))

private theorem residue_lt (a : ℕ) (ha : 0 < a) (x : ℤ) : residue a x < 2 * a := by
  have h0 := Int.emod_nonneg x (by omega : (2 * (a : ℤ)) ≠ 0)
  have hlt := Int.emod_lt_of_pos x (by omega : 0 < 2 * (a : ℤ))
  unfold residue
  omega

private theorem residue_coord (a : ℕ) (ha : 0 < a) (x : ℤ) :
    (residue a x : ℤ) = x + 2 * (-(x / (2 * (a : ℤ)))) * (a : ℤ) := by
  have h0 := Int.emod_nonneg x (by omega : (2 * (a : ℤ)) ≠ 0)
  have hc : (residue a x : ℤ) = x % (2 * (a : ℤ)) := by unfold residue; omega
  rw [hc]
  have h := Int.mul_ediv_add_emod x (2 * (a : ℤ))
  calc
    x % (2 * (a : ℤ)) = x - (2 * (a : ℤ)) * (x / (2 * (a : ℤ))) := by omega
    _ = x + 2 * (-(x / (2 * (a : ℤ)))) * (a : ℤ) := by ring

private theorem residue_related (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    pillowRel a b v (asPoint (residue a v.1, residue b v.2)) := by
  refine ⟨-(v.1 / (2 * (a : ℤ))), -(v.2 / (2 * (b : ℤ))), Or.inl ?_⟩
  exact Prod.ext (residue_coord a ha v.1) (residue_coord b hb v.2)

private theorem neg_residue (a x : ℕ) (ha : 0 < a) (hx : x < 2 * a) :
    (2 * a - x) % (2 * a) = if x = 0 then 0 else 2 * a - x := by
  by_cases h : x = 0
  · simp [h]
  · rw [if_neg h, Nat.mod_eq_of_lt (by omega)]

private theorem net_bounds (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    (net a b v).1 < 2 * a ∧ (net a b v).2 ≤ b := by
  have hx := residue_lt a ha v.1
  have hy := residue_lt b hb v.2
  change (if b < residue b v.2 then
    ((2 * a - residue a v.1) % (2 * a), 2 * b - residue b v.2)
    else (residue a v.1, residue b v.2)).1 < 2 * a ∧ _
  by_cases h : b < residue b v.2
  · simp only [if_pos h, Prod.fst, Prod.snd]
    exact ⟨Nat.mod_lt _ (by omega), by omega⟩
  · simp only [if_neg h, Prod.fst, Prod.snd]
    exact ⟨hx, by omega⟩

private theorem net_related (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    pillowRel a b v (asPoint (net a b v)) := by
  let x := residue a v.1
  let y := residue b v.2
  have hx : x < 2 * a := residue_lt a ha v.1
  have hy : y < 2 * b := residue_lt b hb v.2
  have hr := residue_related a b ha hb v
  change pillowRel a b v (asPoint
    (if b < y then ((2 * a - x) % (2 * a), 2 * b - y) else (x, y)))
  by_cases h : b < y
  · rw [if_pos h]
    apply (pillowRel_equivalence a b ha hb).trans hr
    refine ⟨(if x = 0 then 0 else 1), 1, Or.inr ?_⟩
    apply Prod.ext
    · dsimp [asPoint, halfTurn]
      rw [neg_residue a x ha hx]
      by_cases hx0 : x = 0 <;> simp [hx0] <;> omega
    · dsimp [asPoint, halfTurn]
      omega
  · simpa only [if_neg h] using hr

private theorem decode_spec (a b x y : ℕ) (ha : 0 < a) (hx : x < 2 * a) (hy : y ≤ b) :
    (decode a (rawKey a b x y) = (x, y) ∧ ((y = 0 ∨ y = b) → x ≤ a)) ∨
      (decode a (rawKey a b x y) = (2 * a - x, y) ∧ (y = 0 ∨ y = b) ∧ a < x) := by
  by_cases hxa : x ≤ a
  · left
    refine ⟨?_, by omega⟩
    by_cases hbd : x = 0 ∨ x = a ∨ y = 0 ∨ y = b
    · simp [rawKey, hxa, hbd, decode]
    · have hlt : x < a := by omega
      simp [rawKey, hxa, hbd, hlt, decode]
  · have hlt : ¬x < a := by omega
    have hr0 : 2 * a - x ≠ 0 := by omega
    have hra : 2 * a - x ≠ a := by omega
    by_cases hbd : y = 0 ∨ y = b
    · right
      refine ⟨?_, hbd, by omega⟩
      simp [rawKey, hxa, hr0, hra, hbd, decode]
    · left
      refine ⟨?_, by omega⟩
      have hrestore : 2 * a - (2 * a - x) = x := by omega
      simp [rawKey, hxa, hr0, hra, hbd, hlt, decode, hrestore]

private theorem decode_domain (a b x y : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hx : x < 2 * a) (hy : y ≤ b) : canonical a b (asPoint (decode a (rawKey a b x y))) := by
  rcases decode_spec a b x y ha hx hy with ⟨h, hbd⟩ | ⟨h, hbd, hxa⟩
  · rw [h]
    dsimp [canonical, asPoint]
    omega
  · rw [h]
    dsimp [canonical, asPoint]
    omega

private theorem rawKey_decode (a b x y : ℕ) (ha : 0 < a) (hx : x < 2 * a) (hy : y ≤ b) :
    rawKey a b (decode a (rawKey a b x y)).1 (decode a (rawKey a b x y)).2 =
      rawKey a b x y := by
  rcases decode_spec a b x y ha hx hy with ⟨h, _⟩ | ⟨h, hbd, hxa⟩
  · rw [h]
  · rw [h]
    have hna : ¬x ≤ a := by omega
    have hflip : 2 * a - x ≤ a := by omega
    rcases hbd with rfl | rfl <;> simp [rawKey, hna, hflip]

private theorem decode_related (a b x y : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hx : x < 2 * a) (hy : y ≤ b) :
    pillowRel a b (asPoint (x, y)) (asPoint (decode a (rawKey a b x y))) := by
  rcases decode_spec a b x y ha hx hy with ⟨h, _⟩ | ⟨h, hbd, hxa⟩
  · rw [h]
    exact (pillowRel_equivalence a b ha hb).refl _
  · rw [h]
    rcases hbd with h0 | hb'
    · refine ⟨1, 0, Or.inr ?_⟩
      apply Prod.ext <;> dsimp [asPoint, halfTurn] <;> omega
    · refine ⟨1, 1, Or.inr ?_⟩
      apply Prod.ext <;> dsimp [asPoint, halfTurn] <;> omega

private theorem net_of_bounded (a b x y : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hx : x < 2 * a) (hy : y ≤ b) : net a b (asPoint (x, y)) = (x, y) := by
  have hxm : (x : ℤ) % (2 * (a : ℤ)) = x := Int.emod_eq_of_lt (by omega) (by omega)
  have hym : (y : ℤ) % (2 * (b : ℤ)) = y := Int.emod_eq_of_lt (by omega) (by omega)
  simp [net, asPoint, hxm, hym, show ¬b < y by omega]

private theorem key_of_bounded (a b x y : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hx : x < 2 * a) (hy : y ≤ b) : key a b (asPoint (x, y)) = rawKey a b x y := by
  simp only [key, net_of_bounded a b x y ha hb hx hy, rawKey]

private theorem canonical_related (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    pillowRel a b v (asPoint (decode a (key a b v))) := by
  have h := net_bounds a b ha hb v
  exact (pillowRel_equivalence a b ha hb).trans (net_related a b ha hb v)
    (decode_related a b (net a b v).1 (net a b v).2 ha hb h.1 h.2)

private theorem canonical_domain (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    canonical a b (asPoint (decode a (key a b v))) := by
  have h := net_bounds a b ha hb v
  exact decode_domain a b (net a b v).1 (net a b v).2 ha hb h.1 h.2

private theorem key_decode (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : Point) :
    key a b (asPoint (decode a (key a b v))) = key a b v := by
  have hn := net_bounds a b ha hb v
  have hd := canonical_domain a b ha hb v
  have hx : (decode a (key a b v)).1 < 2 * a := by dsimp [canonical, asPoint] at hd; omega
  have hy : (decode a (key a b v)).2 ≤ b := by dsimp [canonical, asPoint] at hd; omega
  rw [key_of_bounded a b _ _ ha hb hx hy]
  exact rawKey_decode a b (net a b v).1 (net a b v).2 ha hn.1 hn.2

private theorem bounded_translate_unique (m x y i : ℤ) (hm : 0 < m)
    (hx0 : 0 ≤ x) (hxm : x < m) (hy0 : 0 ≤ y) (hym : y < m)
    (h : y = x + i * m) : y = x := by
  have he : y % m = x % m := by rw [h]; simp [Int.add_emod, Int.mul_emod]
  simpa only [Int.emod_eq_of_lt hy0 hym, Int.emod_eq_of_lt hx0 hxm] using he

private theorem bounded_mod_zero (m x : ℤ) (hm : 0 < m) (hx0 : 0 ≤ x)
    (hxm : x ≤ m) (hmod : x % m = 0) : x = 0 ∨ x = m := by
  by_cases hlt : x < m
  · left
    simpa only [Int.emod_eq_of_lt hx0 hlt] using hmod
  · right
    omega

private theorem canonical_unique (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (p q : Point) (hp : canonical a b p) (hq : canonical a b q)
    (hr : pillowRel a b p q) : p = q := by
  rcases hp with ⟨hp0, hpa, hpy0, hpyb, hpb⟩
  rcases hq with ⟨hq0, hqa, hqy0, hqyb, hqb⟩
  rcases hr with ⟨i, j, h | h⟩
  · have hx : q.1 = p.1 + i * (2 * (a : ℤ)) := by
      calc
        q.1 = p.1 + 2 * i * (a : ℤ) := congrArg Prod.fst h
        _ = p.1 + i * (2 * (a : ℤ)) := by ring
    have hy : q.2 = p.2 + j * (2 * (b : ℤ)) := by
      calc
        q.2 = p.2 + 2 * j * (b : ℤ) := congrArg Prod.snd h
        _ = p.2 + j * (2 * (b : ℤ)) := by ring
    exact Prod.ext
      (bounded_translate_unique _ _ _ _ (by omega) hp0 hpa hq0 hqa hx).symm
      (bounded_translate_unique _ _ _ _ (by omega) hpy0 (by omega) hqy0 (by omega) hy).symm
  · have hx : p.1 + q.1 = i * (2 * (a : ℤ)) := by
      calc
        p.1 + q.1 = p.1 + (2 * i * (a : ℤ) - p.1) := congrArg (fun q => p.1 + q.1) h
        _ = i * (2 * (a : ℤ)) := by ring
    have hy : p.2 + q.2 = j * (2 * (b : ℤ)) := by
      calc
        p.2 + q.2 = p.2 + (2 * j * (b : ℤ) - p.2) := congrArg (fun q => p.2 + q.2) h
        _ = j * (2 * (b : ℤ)) := by ring
    have hym : (p.2 + q.2) % (2 * (b : ℤ)) = 0 := by rw [hy]; simp [Int.mul_emod]
    have hys := bounded_mod_zero (2 * (b : ℤ)) (p.2 + q.2) (by omega) (by omega) (by omega) hym
    have hpbd : p.2 = 0 ∨ p.2 = (b : ℤ) := by omega
    have hqbd : q.2 = 0 ∨ q.2 = (b : ℤ) := by omega
    have hpx := hpb hpbd
    have hqx := hqb hqbd
    have hxm : (p.1 + q.1) % (2 * (a : ℤ)) = 0 := by rw [hx]; simp [Int.mul_emod]
    have hxs := bounded_mod_zero (2 * (a : ℤ)) (p.1 + q.1) (by omega) (by omega) (by omega) hxm
    exact Prod.ext (by omega) (by omega)

theorem key_classifies
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v w : Point) :
    key a b v = key a b w ↔ pillowRel a b v w := by
  have he := pillowRel_equivalence a b ha hb
  constructor
  · intro h
    have hv := canonical_related a b ha hb v
    have hw := canonical_related a b ha hb w
    rw [h] at hv
    exact he.trans hv (he.symm hw)
  · intro h
    have hv := canonical_related a b ha hb v
    have hw := canonical_related a b ha hb w
    have hr := he.trans (he.symm hv) (he.trans h hw)
    have hc := canonical_unique a b ha hb _ _
      (canonical_domain a b ha hb v) (canonical_domain a b ha hb w) hr
    have hk := congrArg (key a b) hc
    rw [key_decode a b ha hb v, key_decode a b ha hb w] at hk
    exact hk

end FVLT.PillowcaseV1


