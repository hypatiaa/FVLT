import FVLTProductConvolutionV1

/-!
Exact complex spectrum of the cubic spin polynomial in a fixed cyclic register.
The positive-sign transform is unnormalized; every product introduces 1/P.
The cubic term below retains its inner product transform explicitly, so it does
not conceal a second normalization when that inner transform is expanded later.
Identification with actual Boolean Rule30 is a separate interface.
-/
namespace FVLT.NonlinearSpectralV1
open TurnFourierV1 ProductConvolutionV1
noncomputable section
variable {P : ℕ} [NeZero P]

def left (s : ZMod P → ℂ) (b : ZMod P) : ℂ := s (b-1)
def right (s : ZMod P → ℂ) (b : ZMod P) : ℂ := s (b+1)

def polyUpdate (s : ZMod P → ℂ) (b : ZMod P) : ℂ :=
  -left s b * (1+s b+right s b-s b*right s b)/2

theorem doubled_polyUpdate (s : ZMod P → ℂ) (b : ZMod P) :
    2*polyUpdate s b =
      -left s b-left s b*s b-left s b*right s b+(left s b*s b)*right s b := by
  unfold polyUpdate
  ring

theorem doubled_transform (s : ZMod P → ℂ) (k : ZMod P) :
    2*plusDFT (polyUpdate s) k =
      -plusDFT (left s) k
      -plusDFT (fun b => left s b*s b) k
      -plusDFT (fun b => left s b*right s b) k
      +plusDFT (fun b => (left s b*s b)*right s b) k := by
  calc
    2*plusDFT (polyUpdate s) k =
        ∑ b : ZMod P, (2*polyUpdate s b)*ZMod.stdAddChar (k*b) := by
      rw [plusDFT_apply, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro b _
      ring
    _ = ∑ b : ZMod P,
        (-left s b-left s b*s b-left s b*right s b+(left s b*s b)*right s b)*
          ZMod.stdAddChar (k*b) := by
      simp_rw [doubled_polyUpdate]
    _ = _ := by
      simp only [plusDFT_apply, add_mul, sub_mul, neg_mul,
        Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_neg_distrib]

/-- The inner transform in the cubic term is intentionally left visible.
Expanding it by plusDFT_mul introduces the second factor 1/P. -/
theorem doubled_product_convolution (s : ZMod P → ℂ) (k : ZMod P) :
    2*plusDFT (polyUpdate s) k =
      -plusDFT (left s) k
      -(1/(P : ℂ))*convolution (plusDFT (left s)) (plusDFT s) k
      -(1/(P : ℂ))*convolution (plusDFT (left s)) (plusDFT (right s)) k
      +(1/(P : ℂ))*convolution
        (plusDFT (fun b => left s b*s b)) (plusDFT (right s)) k := by
  rw [doubled_transform,
    plusDFT_mul (left s) s k,
    plusDFT_mul (left s) (right s) k,
    plusDFT_mul (fun b => left s b*s b) (right s) k]

theorem left_spectrum (s : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (left s) k = ZMod.stdAddChar k*plusDFT s k :=
  plusDFT_neighbor_left s k

theorem right_spectrum (s : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (right s) k = ZMod.stdAddChar (-k)*plusDFT s k :=
  plusDFT_neighbor_right s k

/-- All neighbor phases are retained as complex character factors. -/
theorem doubled_phase_convolution (s : ZMod P → ℂ) (k : ZMod P) :
    2*plusDFT (polyUpdate s) k =
      -(ZMod.stdAddChar k*plusDFT s k)
      -(1/(P : ℂ))*convolution
        (fun a => ZMod.stdAddChar a*plusDFT s a) (plusDFT s) k
      -(1/(P : ℂ))*convolution
        (fun a => ZMod.stdAddChar a*plusDFT s a)
        (fun a => ZMod.stdAddChar (-a)*plusDFT s a) k
      +(1/(P : ℂ))*convolution
        (plusDFT (fun b => left s b*s b))
        (fun a => ZMod.stdAddChar (-a)*plusDFT s a) k := by
  have hl : plusDFT (left s) = fun a => ZMod.stdAddChar a*plusDFT s a :=
    funext (left_spectrum s)
  have hr : plusDFT (right s) = fun a => ZMod.stdAddChar (-a)*plusDFT s a :=
    funext (right_spectrum s)
  rw [doubled_product_convolution, hl, hr]

end
end FVLT.NonlinearSpectralV1
