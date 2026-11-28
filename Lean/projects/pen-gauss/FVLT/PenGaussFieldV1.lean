import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar
import Mathlib.NumberTheory.GaussSum
import Mathlib.NumberTheory.LegendreSymbol.QuadraticChar.Basic
import Mathlib.NumberTheory.LegendreSymbol.Basic
import Mathlib.NumberTheory.LegendreSymbol.ZModChar
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic

/-!
# FVLT.PenGaussFieldV1 — Stage 2: Twist Square Roots over Prime Finite Fields

Transports the quadratic Legendre pen (`quadPen (legendreChar q)`, matching `FVLT.PenGaussV1.pen _ 1`
and Alpöge's `hat _ 1` at prime level `q`) along `ZMod.ringEquivOfPrime` to any finite field `F`
of prime cardinality `q`, connecting directly to the quadratic Gauss sums in
`Formalism.L2.Col.ciSq` / `ciSq_sq`.

No recursive `def`, zero `sorry`, standard axioms `[propext, Classical.choice, Quot.sound]` only.
-/

namespace FVLT.PenGaussFieldV1

noncomputable section

open Complex Real

/-- Explicit right-hand side of B0 (`pen φ 1`) over `ZMod q`. -/
def quadPen {q : ℕ} (φ : ZMod q → ℂ) : ℂ :=
  ∑ y ∈ Finset.range q, φ y * Complex.exp (2 * Real.pi * Complex.I * (y : ℂ) / (q : ℂ))

/-- The quadratic Legendre character on `ZMod q` with values in `ℂ`. -/
def legendreChar (q : ℕ) [Fact q.Prime] : MulChar (ZMod q) ℂ :=
  (quadraticChar (ZMod q)).ringHomComp (Int.castRingHom ℂ)

/-- The quadratic character on any finite field `F` with values in `ℂ`. -/
def fieldQuadChar (F : Type*) [Field F] [Fintype F] [DecidableEq F] : MulChar F ℂ :=
  (quadraticChar F).ringHomComp (Int.castRingHom ℂ)

/-- Additive character on a prime field `F` obtained by transporting `ZMod.stdAddChar`
along `ZMod.ringEquivOfPrime`. -/
def transportedAddChar {F : Type*} [Field F] [Fintype F] {q : ℕ}
    (hq : q.Prime) (hcard : Fintype.card F = q) : AddChar F ℂ :=
  letI : NeZero q := ⟨hq.ne_zero⟩
  (ZMod.stdAddChar (N := q)).compAddMonoidHom
    (ZMod.ringEquivOfPrime F hq hcard).symm.toAddMonoidHom

/-- The exponential factor in `quadPen` matches `FourierHelix.phase (2 * y / q)`. -/
theorem quadPen_eq_phase {q : ℕ} (φ : ZMod q → ℂ) :
    quadPen φ = ∑ y ∈ Finset.range q,
      φ y * Complex.exp (((Real.pi * (2 * (y : ℝ) / q) : ℝ) : ℂ) * Complex.I) := by
  unfold quadPen
  refine Finset.sum_congr rfl fun y _ => ?_
  congr 2
  push_cast
  ring

/-- `legendreChar q` agrees with `legendreSym q` on integer casts. -/
theorem legendreChar_apply_int (q : ℕ) [Fact q.Prime] (a : ℤ) :
    legendreChar q (a : ZMod q) = (legendreSym q a : ℂ) := by
  simp [legendreChar, legendreSym]

/-- `quadraticChar` is invariant under ring equivalences between finite fields. -/
theorem quadraticChar_ringEquiv {R F : Type*} [Field R] [Fintype R] [DecidableEq R]
    [Field F] [Fintype F] [DecidableEq F] (e : R ≃+* F) (x : R) :
    quadraticChar F (e x) = quadraticChar R x := by
  by_cases hx : x = 0
  · simp [hx]
  · have hex : e x ≠ 0 := by
      intro h0
      exact hx (e.injective (h0.trans (map_zero e).symm))
    by_cases hsq : IsSquare x
    · have hsq' : IsSquare (e x) := by
        rcases hsq with ⟨y, hy⟩
        exact ⟨e y, by rw [hy, map_mul]⟩
      rw [(quadraticChar_one_iff_isSquare hex).mpr hsq',
          (quadraticChar_one_iff_isSquare hx).mpr hsq]
    · have hnsq' : ¬ IsSquare (e x) := by
        rintro ⟨y, hy⟩
        apply hsq
        refine ⟨e.symm y, ?_⟩
        apply e.injective
        simpa [map_mul] using hy
      rw [quadraticChar_neg_one_iff_not_isSquare.mpr hnsq',
          quadraticChar_neg_one_iff_not_isSquare.mpr hsq]

private lemma ringChar_eq_prime_of_card {F : Type*} [Field F] [Fintype F] {q : ℕ}
    (hq : q.Prime) (hcard : Fintype.card F = q) : ringChar F = q := by
  let e : ZMod q ≃+* F := ZMod.ringEquivOfPrime F hq hcard
  have hq0 : ((q : ℕ) : F) = 0 := by
    rw [← map_natCast e, ZMod.natCast_self, map_zero]
  rcases (Nat.dvd_prime hq).mp (ringChar.dvd hq0) with h1 | hq'
  · exact absurd h1 CharP.ringChar_ne_one
  · exact hq'

/-- The transported additive character on `F` is primitive. -/
theorem transportedAddChar_isPrimitive {F : Type*} [Field F] [Fintype F] {q : ℕ}
    (hq : q.Prime) (hcard : Fintype.card F = q) :
    (transportedAddChar hq hcard).IsPrimitive := by
  refine AddChar.IsPrimitive.of_ne_one ?_
  intro h1
  haveI : NeZero q := ⟨hq.ne_zero⟩
  let e : ZMod q ≃+* F := ZMod.ringEquivOfPrime F hq hcard
  have hev := congrArg (fun (ψ : AddChar F ℂ) => ψ (e 1)) h1
  have hstd1 : (ZMod.stdAddChar (N := q)) 1 = (1 : ℂ) := by
    simpa [transportedAddChar, e] using hev
  have h01 : (ZMod.stdAddChar (N := q)) 1 = (ZMod.stdAddChar (N := q)) 0 := by
    rw [hstd1, (ZMod.stdAddChar (N := q)).map_zero_eq_one]
  have h10 : (1 : ZMod q) = 0 := ZMod.injective_stdAddChar h01
  haveI : Fact q.Prime := ⟨hq⟩
  exact one_ne_zero h10

/-- Over `ZMod q`, `quadPen (legendreChar q)` equals `gaussSum (legendreChar q) ZMod.stdAddChar`. -/
theorem quadPen_eq_gaussSum_zmod (q : ℕ) [Fact q.Prime] :
    quadPen (legendreChar q) = gaussSum (legendreChar q) (ZMod.stdAddChar (N := q)) := by
  unfold quadPen gaussSum
  have step : ∀ i ∈ Finset.range q,
      legendreChar q (i : ZMod q) * Complex.exp (2 * Real.pi * Complex.I * (i : ℂ) / (q : ℂ)) =
        legendreChar q (i : ZMod q) * ZMod.stdAddChar (i : ZMod q) := by
    intro i _
    congr 1
    have hcoe : ((i : ZMod q) : ZMod q) = ((i : ℤ) : ZMod q) := by push_cast; rfl
    rw [hcoe, ZMod.stdAddChar_coe]
    push_cast
    ring_nf
  rw [Finset.sum_congr rfl step]
  refine Finset.sum_nbij' (fun i => (i : ZMod q)) (fun y => y.val) ?_ ?_ ?_ ?_ ?_
  · intro i _; simp
  · intro y _; simp [ZMod.val_lt]
  · intro i hi
    simp only [Finset.mem_range] at hi
    simp [ZMod.val_cast_of_lt hi]
  · intro y _; simp
  · intro i _; rfl

/-- Transported along `ZMod.ringEquivOfPrime`, `quadPen (legendreChar q)` equals the Gauss sum
of `quadraticChar F` with the transported additive character on `F`. -/
theorem quadPen_eq_gaussSum_field {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {q : ℕ} [Fact q.Prime] (hcard : Fintype.card F = q) :
    quadPen (legendreChar q) =
      gaussSum (fieldQuadChar F) (transportedAddChar (Fact.out : q.Prime) hcard) := by
  rw [quadPen_eq_gaussSum_zmod]
  let e : ZMod q ≃+* F := ZMod.ringEquivOfPrime F (Fact.out : q.Prime) hcard
  unfold gaussSum
  refine Fintype.sum_equiv e.toEquiv _ _ fun x => ?_
  have hchar : fieldQuadChar F (e x) = legendreChar q x := by
    simp [fieldQuadChar, legendreChar, quadraticChar_ringEquiv e x]
  have hadd : transportedAddChar (Fact.out : q.Prime) hcard (e x) = ZMod.stdAddChar x := by
    simp [transportedAddChar, e]
  change legendreChar q x * ZMod.stdAddChar x =
    fieldQuadChar F (e x) * transportedAddChar (Fact.out : q.Prime) hcard (e x)
  rw [hchar, hadd]

/-- Quadratic Gauss sum square identity via field transport for odd primes `q ≠ 2`. -/
theorem quadPen_sq_field_eq_fieldChar {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {q : ℕ} [Fact q.Prime] (hq2 : q ≠ 2) (hcard : Fintype.card F = q) :
    quadPen (legendreChar q) ^ 2 = fieldQuadChar F (-1) * (q : ℂ) := by
  have hq : q.Prime := Fact.out
  have hrchar : ringChar F = q := ringChar_eq_prime_of_card hq hcard
  have hF2 : ringChar F ≠ 2 := by rw [hrchar]; exact hq2
  have hχ₁ : fieldQuadChar F ≠ 1 := by
    obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one' hF2
    refine MulChar.ne_one_iff.mpr ⟨a, ?_⟩
    show ((quadraticChar F a : ℤ) : ℂ) ≠ 1
    rw [ha]
    norm_num
  have hχ₂ : (fieldQuadChar F).IsQuadratic :=
    MulChar.IsQuadratic.comp (quadraticChar_isQuadratic F) _
  have hψ : (transportedAddChar hq hcard).IsPrimitive :=
    transportedAddChar_isPrimitive hq hcard
  rw [quadPen_eq_gaussSum_field hcard, gaussSum_sq hχ₁ hχ₂ hψ, hcard]

/-- Over any finite field `F` of odd prime order `q`, `quadPen (legendreChar q) ^ 2 = legendreChar q (-1) * q`. -/
theorem quadPen_sq_field {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {q : ℕ} [Fact q.Prime] (hq2 : q ≠ 2) (hcard : Fintype.card F = q) :
    quadPen (legendreChar q) ^ 2 = legendreChar q (-1) * (q : ℂ) := by
  rw [quadPen_sq_field_eq_fieldChar hq2 hcard]
  let e : ZMod q ≃+* F := ZMod.ringEquivOfPrime F (Fact.out : q.Prime) hcard
  have hneg : fieldQuadChar F (-1) = legendreChar q (-1) := by
    have he1 : e (-1) = (-1 : F) := by simp
    have hq_eq : quadraticChar F (e (-1)) = quadraticChar (ZMod q) (-1) :=
      quadraticChar_ringEquiv e (-1)
    rw [he1] at hq_eq
    simp [fieldQuadChar, legendreChar, hq_eq]
  rw [hneg]

/-- When `q ≡ 1 (mod 4)`, `quadPen (legendreChar q) ^ 2 = q` (matching `Formalism.L2.Col.ciSq_sq`). -/
theorem quadPen_sq_of_mod_four_eq_one {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {q : ℕ} [Fact q.Prime] (h4 : q % 4 = 1) (hcard : Fintype.card F = q) :
    quadPen (legendreChar q) ^ 2 = (q : ℂ) := by
  have hq2 : q ≠ 2 := by omega
  have hrchar : ringChar F = q := ringChar_eq_prime_of_card (Fact.out : q.Prime) hcard
  have hF2 : ringChar F ≠ 2 := by rw [hrchar]; exact hq2
  rw [quadPen_sq_field_eq_fieldChar hq2 hcard]
  have hneg1 : fieldQuadChar F (-1) = 1 := by
    show ((quadraticChar F (-1) : ℤ) : ℂ) = 1
    rw [quadraticChar_neg_one hF2, hcard, ZMod.χ₄_nat_one_mod_four h4]
    norm_num
  rw [hneg1, one_mul]

/-- Characteristic-0 field version matching `Formalism.L2.Col.ciSq_sq` directly. -/
theorem field_gaussSum_sq_polymorphic {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {K : Type*} [Field K] [CharZero K] {q : ℕ} [Fact q.Prime]
    (h4 : q % 4 = 1) (hcard : Fintype.card F = q) {ψ : AddChar F K} (hψ : ψ ≠ 1) :
    gaussSum ((quadraticChar F).ringHomComp (Int.castRingHom K)) ψ ^ 2 = (q : K) := by
  have hrchar : ringChar F = q := ringChar_eq_prime_of_card (Fact.out : q.Prime) hcard
  have hF2 : ringChar F ≠ 2 := by rw [hrchar]; omega
  have hχ₁ : (quadraticChar F).ringHomComp (Int.castRingHom K) ≠ 1 := by
    obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one' hF2
    refine MulChar.ne_one_iff.mpr ⟨a, ?_⟩
    show ((quadraticChar F a : ℤ) : K) ≠ 1
    rw [ha]
    norm_num
  have hχ₂ : ((quadraticChar F).ringHomComp (Int.castRingHom K)).IsQuadratic :=
    MulChar.IsQuadratic.comp (quadraticChar_isQuadratic F) _
  have hψp : ψ.IsPrimitive := AddChar.IsPrimitive.of_ne_one hψ
  rw [gaussSum_sq hχ₁ hχ₂ hψp, hcard]
  have hneg1 : ((quadraticChar F).ringHomComp (Int.castRingHom K)) (-1) = 1 := by
    show ((quadraticChar F (-1) : ℤ) : K) = 1
    rw [quadraticChar_neg_one hF2, hcard, ZMod.χ₄_nat_one_mod_four h4]
    norm_num
  rw [hneg1, one_mul]

end

end FVLT.PenGaussFieldV1
