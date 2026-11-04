import FVLTTurnFourierV1

/-!
Phase-preserving product/convolution law in one fixed finite cyclic register.
plusDFT has positive phase and no forward normalization. Pointwise products
therefore transform to frequency convolution divided by P. These statements
do not authorize cyclic treatment of an unpadded infinite row.
-/
namespace FVLT.ProductConvolutionV1
open TurnFourierV1 AddChar
noncomputable section
variable {P : ℕ} [NeZero P]

def convolution (F G : ZMod P → ℂ) (k : ZMod P) : ℂ :=
  ∑ a : ZMod P, F a * G (k-a)

/-- The unnormalized frequency convolution is P times the product transform. -/
theorem convolution_transforms (f g : ZMod P → ℂ) (k : ZMod P) :
    convolution (plusDFT f) (plusDFT g) k =
      (P : ℂ) * plusDFT (fun b => f b * g b) k := by
  have hc (a b : ZMod P) :
      ZMod.stdAddChar ((k-a)*b) =
        ZMod.stdAddChar (k*b) * ZMod.stdAddChar (-(a*b)) := by
    rw [← map_add_eq_mul]
    congr 1
    ring
  have hinv (b : ZMod P) :
      (∑ a : ZMod P, ZMod.stdAddChar (-(a*b)) * plusDFT f a) =
        (P : ℂ) * f b := by
    simpa only [ZMod.dft_apply, smul_eq_mul] using dft_plusDFT f b
  unfold convolution
  calc
    (∑ a : ZMod P, plusDFT f a * plusDFT g (k-a)) =
        ∑ a : ZMod P, ∑ b : ZMod P,
          plusDFT f a * (g b * ZMod.stdAddChar ((k-a)*b)) := by
      apply Finset.sum_congr rfl
      intro a _
      rw [plusDFT_apply g (k-a), Finset.mul_sum]
    _ = ∑ b : ZMod P, ∑ a : ZMod P,
        (g b * ZMod.stdAddChar (k*b)) *
          (ZMod.stdAddChar (-(a*b)) * plusDFT f a) := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro b _
      apply Finset.sum_congr rfl
      intro a _
      rw [hc]
      ring
    _ = ∑ b : ZMod P, (g b * ZMod.stdAddChar (k*b)) * ((P : ℂ)*f b) := by
      apply Finset.sum_congr rfl
      intro b _
      rw [← Finset.mul_sum, hinv]
    _ = (P : ℂ) * plusDFT (fun b => f b*g b) k := by
      rw [plusDFT_apply, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro b _
      ring

/-- Exact positive-sign transform; the inverse normalization is explicitly 1/P. -/
theorem plusDFT_mul (f g : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (fun b => f b*g b) k =
      (1/(P : ℂ)) * convolution (plusDFT f) (plusDFT g) k := by
  have hP : (P : ℂ) ≠ 0 := by exact_mod_cast NeZero.ne P
  rw [convolution_transforms]
  simp only [one_div, ← mul_assoc, inv_mul_cancel₀ hP, one_mul]

theorem plusDFT_mul_sum (f g : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (fun b => f b*g b) k =
      (1/(P : ℂ)) * ∑ a : ZMod P, plusDFT f a * plusDFT g (k-a) :=
  plusDFT_mul f g k

def translate (a : ZMod P) (f : ZMod P → ℂ) (b : ZMod P) : ℂ := f (b+a)

/-- For f(b+a), a positive-sign transform gains the negative phase -k*a. -/
theorem plusDFT_translate (a : ZMod P) (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (translate a f) k =
      ZMod.stdAddChar (-(k*a)) * plusDFT f k := by
  rw [plusDFT_apply, plusDFT_apply, Finset.mul_sum]
  refine Fintype.sum_equiv (Equiv.addRight a) _ _ ?_
  intro b
  change f (b+a)*ZMod.stdAddChar (k*b) =
    ZMod.stdAddChar (-(k*a))*(f (b+a)*ZMod.stdAddChar (k*(b+a)))
  have hc : ZMod.stdAddChar (k*b) =
      ZMod.stdAddChar (-(k*a))*ZMod.stdAddChar (k*(b+a)) := by
    rw [← map_add_eq_mul]
    congr 1
    ring
  rw [hc]
  ring

theorem plusDFT_neighbor_right (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (fun b => f (b+1)) k = ZMod.stdAddChar (-k) * plusDFT f k := by
  have h := plusDFT_translate (1 : ZMod P) f k
  change plusDFT (fun b => f (b+1)) k = _ at h
  simpa only [mul_one] using h

theorem plusDFT_neighbor_left (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (fun b => f (b-1)) k = ZMod.stdAddChar k * plusDFT f k := by
  have h := plusDFT_translate (-1 : ZMod P) f k
  change plusDFT (fun b => f (b + -1)) k = _ at h
  simpa only [mul_neg, mul_one, neg_neg, sub_eq_add_neg] using h

end
end FVLT.ProductConvolutionV1
