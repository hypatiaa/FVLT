import FourierHelix
import Mathlib.NumberTheory.DirichletCharacter.GaussSum
import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar

/-!
# Pen endpoints and Gauss sums

The character laws and CRT proof are adapted from Alpöge's
`DirichletCharFiniteFourierTransformProperties.lean`, pinned at
`40e56bab026552e089d7afcfeff08d2defb9c005`.
The endpoint uses Robin Miller's `FourierHelix.phase`.
-/

open Complex Real
open scoped BigOperators Real

noncomputable section

namespace FVLT.PenGaussV1

def pen {N : ℕ} (φ : ZMod N → ℂ) (d : ℤ) : ℂ :=
  ∑ y ∈ Finset.range N, φ y * FourierHelix.phase (2 * ((y : ℝ) * d) / N)

/-- Evaluate a Dirichlet character on an integer representative. -/
def ch {N : ℕ} (χ : DirichletCharacter ℂ N) (d : ℤ) : ℂ :=
  χ (d : ZMod N)

/-- The endpoint written with the exponential used in Alpöge's transform. -/
theorem pen_eq_hatForm {N : ℕ} (φ : ZMod N → ℂ) (d : ℤ) :
    pen φ d = ∑ y ∈ Finset.range N, φ y * cexp (2 * π * Complex.I * ((y : ℂ) * (d : ℂ)) / N) := by
  unfold pen
  refine Finset.sum_congr rfl (fun y _ => ?_)
  congr 1
  unfold FourierHelix.phase
  congr 1
  push_cast
  ring

theorem pen_eq_sum_std {N : ℕ} [NeZero N] (φ : ZMod N → ℂ) (d : ℤ) :
    pen φ d = ∑ y : ZMod N, φ y * ZMod.stdAddChar (y * (d : ZMod N)) := by
  rw [pen_eq_hatForm]
  have step : ∀ i ∈ Finset.range N, φ (i : ZMod N) * cexp (2 * π * Complex.I * ((i : ℂ) * (d : ℂ)) / N)
      = φ (i : ZMod N) * ZMod.stdAddChar ((i : ZMod N) * (d : ZMod N)) := by
    intro i _
    congr 1
    have : ((i : ZMod N)) * (d : ZMod N) = (((i : ℤ) * d : ℤ) : ZMod N) := by push_cast; rfl
    rw [this, ZMod.stdAddChar_coe]
    push_cast
    ring_nf
  rw [Finset.sum_congr rfl step]
  refine Finset.sum_nbij' (fun i => (i : ZMod N)) (fun y => y.val) ?_ ?_ ?_ ?_ ?_
  · intro i _; simp
  · intro y _; simp [ZMod.val_lt]
  · intro i hi; simp only [Finset.mem_coe, Finset.mem_range] at hi; simp [ZMod.val_cast_of_lt hi]
  · intro y _; simp
  · intro i _; rfl

theorem pen_eq_gaussSum {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (x : ℤ) :
    pen χ x = gaussSum χ (ZMod.stdAddChar.mulShift (x : ZMod N)) := by
  rw [pen_eq_sum_std, gaussSum]
  exact Fintype.sum_congr _ _ (fun y => by
    rw [AddChar.mulShift_apply, mul_comm (x : ZMod N) y])

theorem pen_add_period {N : ℕ} [NeZero N] (φ : ZMod N → ℂ) (x : ℤ) : pen φ (x + N) = pen φ x := by
  rw [pen_eq_sum_std, pen_eq_sum_std]
  push_cast
  simp

theorem pen_mul_unit {N : ℕ} [NeZero N] (θ : DirichletCharacter ℂ N) (d x : ℤ) (hd : IsUnit (d : ZMod N)) :
    pen θ (x * d) = ch θ⁻¹ d * pen θ x := by
  have h := gaussSum_mulShift_eq θ ((ZMod.stdAddChar (N := N)).mulShift (x : ZMod N)) hd.unit
  simp only [gaussSum, AddChar.mulShift_apply, IsUnit.unit_spec] at h
  rw [pen_eq_sum_std, pen_eq_sum_std]
  unfold ch
  calc ∑ y : ZMod N, θ y * ZMod.stdAddChar (y * ((x * d : ℤ) : ZMod N))
      = ∑ y : ZMod N, θ y * ZMod.stdAddChar ((x : ZMod N) * ((d : ZMod N) * y)) := by
        refine Fintype.sum_congr _ _ (fun y => ?_); push_cast; ring_nf
    _ = θ⁻¹ (d : ZMod N) * ∑ y : ZMod N, θ y * ZMod.stdAddChar ((x : ZMod N) * y) := h
    _ = _ := by
        congr 1; refine Fintype.sum_congr _ _ (fun y => ?_); ring_nf

theorem pen_zero_of_ne_one {N : ℕ} [NeZero N] (θ : DirichletCharacter ℂ N) (h : θ ≠ 1) : pen θ 0 = 0 := by
  rw [pen_eq_sum_std]
  simp only [Int.cast_zero, mul_zero, AddChar.map_zero_eq_one, mul_one]
  exact MulChar.sum_eq_zero_of_ne_one h

theorem isUnit_of_isCoprime {N : ℕ} (d : ℤ) (h : IsCoprime d N) : IsUnit (d : ZMod N) := by
  obtain ⟨a, b, hab⟩ := h
  have : ((a * d + b * N : ℤ) : ZMod N) = 1 := by rw [hab]; simp
  push_cast at this
  rw [ZMod.natCast_self, mul_zero, add_zero] at this
  exact IsUnit.of_mul_eq_one (a : ZMod N) (by rw [mul_comm]; exact this)

theorem pen_one_prime {l : ℕ} [Fact l.Prime] (x : ℤ) :
    pen (1 : DirichletCharacter ℂ l) x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1 := by
  classical
  rw [pen_eq_sum_std]
  have hterm : ∀ y : ZMod l, (1 : DirichletCharacter ℂ l) y * ZMod.stdAddChar (y * (x : ZMod l))
      = ZMod.stdAddChar (y * (x : ZMod l)) - if y = 0 then 1 else 0 := by
    intro y
    by_cases hy : y = 0
    · subst hy; rw [MulChar.map_zero]; simp
    · rw [MulChar.one_apply (isUnit_iff_ne_zero.mpr hy)]; simp [hy]
  rw [Fintype.sum_congr _ _ hterm, Finset.sum_sub_distrib, AddChar.sum_mulShift _ (ZMod.isPrimitive_stdAddChar l)]
  simp [ZMod.card, ZMod.intCast_zmod_eq_zero_iff_dvd]

theorem pen_prime_ne_one {l : ℕ} [Fact l.Prime] (ψ : DirichletCharacter ℂ l) (hψ : ψ ≠ 1) :
    pen ψ 1 ≠ 0 ∧ ∀ x, pen ψ x = pen ψ 1 * ch ψ⁻¹ x := by
  constructor
  · have h := gaussSum_mul_gaussSum_eq_card hψ (ZMod.isPrimitive_stdAddChar l)
    rw [pen_eq_sum_std]
    intro h0
    simp only [Int.cast_one, mul_one] at h0
    rw [gaussSum, h0, zero_mul, ZMod.card] at h
    exact (Nat.cast_ne_zero.mpr (Fact.out : l.Prime).ne_zero) h.symm
  · intro x
    by_cases hx : (x : ZMod l) = 0
    · have h1 : pen ψ x = 0 := by
        rw [pen_eq_sum_std, hx]
        simp only [mul_zero, AddChar.map_zero_eq_one, mul_one]
        exact MulChar.sum_eq_zero_of_ne_one hψ
      rw [h1]; unfold ch; rw [hx, MulChar.map_zero, mul_zero]
    · have := pen_mul_unit ψ x 1 (isUnit_iff_ne_zero.mpr hx)
      rw [one_mul] at this
      rw [this, mul_comm]

theorem stdAddChar_nat_mul_int {M : ℕ} [NeZero M] (a : ZMod M) (x : ℤ) :
    (ZMod.stdAddChar (a * (x : ZMod M)) : ℂ) = cexp (2 * π * Complex.I * ((a.val : ℂ) * x) / M) := by
  have : a * (x : ZMod M) = (((a.val : ℤ) * x : ℤ) : ZMod M) := by push_cast; simp
  rw [this, ZMod.stdAddChar_coe]; push_cast; ring_nf

theorem pen_mul_coprime (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
    (φ : DirichletCharacter ℂ (N * l)) (hN : 0 < N) (hl : 0 < l) (hc : N.Coprime l)
    (hφ : ∀ d : ℤ, ch φ d = ch θ d * ch ψ d) (x : ℤ) :
    pen φ x = ch θ l * ch ψ N * (pen θ x * pen ψ x) := by
  haveI : NeZero N := ⟨hN.ne'⟩
  haveI : NeZero l := ⟨hl.ne'⟩
  haveI : NeZero (N * l) := ⟨(Nat.mul_pos hN hl).ne'⟩
  let f : ZMod N × ZMod l → ZMod (N * l) := fun p => ((p.1.val * l + p.2.val * N : ℕ) : ZMod (N * l))
  have hcN : ∀ k : ℕ, ZMod.castHom (Dvd.intro l rfl : N ∣ N * l) (ZMod N) (k : ZMod (N * l)) = (k : ZMod N) :=
    fun k => map_natCast _ k
  have hcl : ∀ k : ℕ, ZMod.castHom (Dvd.intro_left N rfl : l ∣ N * l) (ZMod l) (k : ZMod (N * l)) = (k : ZMod l) :=
    fun k => map_natCast _ k
  have hlu : IsUnit (l : ZMod N) := (ZMod.unitOfCoprime l hc.symm).isUnit
  have hNu : IsUnit (N : ZMod l) := (ZMod.unitOfCoprime N hc).isUnit
  have hinj : Function.Injective f := by
    intro p q hpq
    have h1 := congrArg (ZMod.castHom (Dvd.intro l rfl : N ∣ N * l) (ZMod N)) hpq
    have h2 := congrArg (ZMod.castHom (Dvd.intro_left N rfl : l ∣ N * l) (ZMod l)) hpq
    simp only [f, hcN, hcl] at h1 h2
    push_cast at h1 h2
    simp only [ZMod.natCast_self, mul_zero, add_zero, zero_add, ZMod.natCast_zmod_val] at h1 h2
    exact Prod.ext (hlu.mul_right_cancel h1) (hNu.mul_right_cancel h2)
  have hbij : Function.Bijective f := by
    rw [Fintype.bijective_iff_injective_and_card]
    exact ⟨hinj, by simp [ZMod.card]⟩
  rw [pen_eq_sum_std, pen_eq_sum_std, pen_eq_sum_std, ← Fintype.sum_bijective f hbij _ _ (fun _ => rfl),
    Finset.sum_mul_sum, ← Finset.univ_product_univ, Finset.sum_product, Finset.mul_sum]
  refine Fintype.sum_congr _ _ (fun a => ?_)
  rw [Finset.mul_sum]
  refine Fintype.sum_congr _ _ (fun b => ?_)
  have hf : f (a, b) = (((a.val * l + b.val * N : ℕ) : ℤ) : ZMod (N * l)) := by simp [f]
  have hval : φ (f (a, b)) = θ a * θ l * (ψ b * ψ N) := by
    have := hφ ((a.val * l + b.val * N : ℕ) : ℤ)
    unfold ch at this
    rw [hf, this]
    push_cast
    simp only [ZMod.natCast_self, mul_zero, add_zero, zero_add, ZMod.natCast_zmod_val, map_mul]
  have he : (ZMod.stdAddChar (f (a, b) * (x : ZMod (N * l))) : ℂ)
      = ZMod.stdAddChar (a * (x : ZMod N)) * ZMod.stdAddChar (b * (x : ZMod l)) := by
    have : f (a, b) * (x : ZMod (N * l)) = ((((a.val * l + b.val * N : ℕ) : ℤ) * x : ℤ) : ZMod (N * l)) := by
      rw [hf]; push_cast; rfl
    rw [this, ZMod.stdAddChar_coe, stdAddChar_nat_mul_int a x, stdAddChar_nat_mul_int b x, ← Complex.exp_add]
    congr 1
    have hN' : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
    have hl' : (l : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hl.ne'
    push_cast
    field_simp
  rw [hval, he]
  unfold ch
  simp only [Int.cast_natCast]
  ring

theorem pen_char_props :
    (∀ (N : ℕ) (θ : DirichletCharacter ℂ N), 0 < N →
      (∀ x : ℤ, pen θ (x + N) = pen θ x) ∧
      (∀ d x : ℤ, IsCoprime d N → pen θ (x * d) = ch θ⁻¹ d * pen θ x) ∧
      (θ ≠ 1 → pen θ 0 = 0)) ∧
    (∀ (N l : ℕ) (θ : DirichletCharacter ℂ N) (ψ : DirichletCharacter ℂ l)
        (φ : DirichletCharacter ℂ (N * l)),
      0 < N → 0 < l → N.Coprime l → (∀ d : ℤ, ch φ d = ch θ d * ch ψ d) →
      ∀ x, pen φ x = ch θ l * ch ψ N * (pen θ x * pen ψ x)) ∧
    ∀ (l : ℕ) (ψ : DirichletCharacter ℂ l), l.Prime →
      (ψ ≠ 1 → pen ψ 1 ≠ 0 ∧ ∀ x, pen ψ x = pen ψ 1 * ch ψ⁻¹ x) ∧
      (ψ = 1 → ∀ x : ℤ, pen ψ x = (if (l : ℤ) ∣ x then (l : ℂ) else 0) - 1) := by
  refine ⟨?_, ?_, ?_⟩
  · intro N θ hN
    haveI : NeZero N := ⟨hN.ne'⟩
    exact ⟨fun x => pen_add_period _ x, fun d x hd => pen_mul_unit θ d x (isUnit_of_isCoprime d hd),
      pen_zero_of_ne_one θ⟩
  · intro N l θ ψ φ hN hl hc hφ x
    exact pen_mul_coprime N l θ ψ φ hN hl hc hφ x
  · intro l ψ hl
    haveI : Fact l.Prime := ⟨hl⟩
    refine ⟨pen_prime_ne_one ψ, ?_⟩
    rintro rfl x
    exact pen_one_prime x

end FVLT.PenGaussV1
