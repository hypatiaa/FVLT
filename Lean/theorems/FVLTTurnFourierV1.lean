import FVLTNaturalFanV1
import Mathlib.Analysis.Fourier.ZMod

/-!
Exact positive-sign, unnormalized Fourier readout of one turn.
Mathlib's native DFT has negative phase, so the frequency argument is -k.
Stabilization is tested on complex coefficient differences, not magnitudes.
-/

namespace FVLT.TurnFourierV1
open NaturalFanV1 AddChar
noncomputable section
variable {P : ℕ} [NeZero P]

def plusDFT (f : ZMod P → ℂ) (k : ZMod P) : ℂ := ZMod.dft f (-k)

theorem plusDFT_apply (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT f k = ∑ b : ZMod P, f b * ZMod.stdAddChar (k * b) := by
  simp only [plusDFT, ZMod.dft_apply, mul_neg, neg_neg, smul_eq_mul]
  apply Finset.sum_congr rfl
  intro b _
  rw [mul_comm b k, mul_comm]

theorem plusDFT_injective : Function.Injective (plusDFT (P := P)) := by
  intro f g h
  apply ZMod.dft.injective
  funext k
  have he := congrFun h (-k)
  simpa [plusDFT] using he

theorem dft_plusDFT (f : ZMod P → ℂ) (b : ZMod P) :
    ZMod.dft (plusDFT f) b = (P : ℂ) * f b := by
  change ZMod.dft (fun k => ZMod.dft f (-k)) b = _
  rw [ZMod.dft_comp_neg, ZMod.dft_dft]
  simp [smul_eq_mul]

theorem plusDFT_inverse_normalization (f : ZMod P → ℂ) (b : ZMod P) :
    ZMod.dft (plusDFT f) b / (P : ℂ) = f b := by
  rw [dft_plusDFT]
  exact mul_div_cancel_left₀ _ (by exact_mod_cast NeZero.ne P)

theorem plusDFT_sub (f g : ZMod P → ℂ) :
    plusDFT (fun b => f b - g b) = fun k => plusDFT f k - plusDFT g k := by
  funext k
  exact congrFun (ZMod.dft.map_sub f g) (-k)

theorem plusDFT_zero : plusDFT (0 : ZMod P → ℂ) = 0 := by
  funext k
  simp [plusDFT]

theorem plusDFT_eq_zero_iff (f : ZMod P → ℂ) : plusDFT f = 0 ↔ f = 0 := by
  constructor
  · intro h
    apply plusDFT_injective
    simpa only [plusDFT_zero] using h
  · rintro rfl
    exact plusDFT_zero

theorem plusDFT_difference_zero_iff (f g : ZMod P → ℂ) :
    (∀ k, plusDFT (fun b => f b - g b) k = 0) ↔ f = g := by
  constructor
  · intro h
    have he : plusDFT (fun b => f b - g b) = 0 := funext h
    have hz := (plusDFT_eq_zero_iff _).mp he
    funext b
    exact sub_eq_zero.mp (congrFun hz b)
  · rintro rfl
    intro k
    simp [plusDFT_apply]

theorem plusDFT_const_one (k : ZMod P) :
    plusDFT (fun _ : ZMod P => (1 : ℂ)) k = if k = 0 then (P : ℂ) else 0 := by
  rw [plusDFT_apply]
  simp only [one_mul]
  split_ifs with hk
  · subst k
    simp
  · exact AddChar.sum_eq_zero_of_ne_one (ZMod.isPrimitive_stdAddChar P hk)

def turnDifference (c : ℕ → ℂ) (x : ℕ) : ZMod P → ℂ :=
  fun b => turn P c (x + 1) b - turn P c x b

theorem turn_difference_fourier_zero_iff (c : ℕ → ℂ) (x : ℕ) :
    (∀ k, plusDFT (turnDifference (P := P) c x) k = 0) ↔
      turn P c (x + 1) = turn P c x :=
  plusDFT_difference_zero_iff _ _

theorem eventual_period_iff_eventual_fourier_difference_zero (c : ℕ → ℂ) :
    EventuallyPPeriodic P c ↔
      ∃ X, ∀ x, X ≤ x → ∀ k, plusDFT (turnDifference (P := P) c x) k = 0 := by
  rw [eventual_period_iff_turns_stabilize]
  constructor
  · rintro ⟨X, hX⟩
    exact ⟨X, fun x hx => (turn_difference_fourier_zero_iff c x).mpr (hX x hx)⟩
  · rintro ⟨X, hX⟩
    exact ⟨X, fun x hx => (turn_difference_fourier_zero_iff c x).mp (hX x hx)⟩

/-- A finite set of frequencies permits one uniform natural-time threshold. -/
theorem uniform_threshold_iff {ι : Type*} [Fintype ι] (Q : ι → ℕ → Prop) :
    (∀ i, ∃ X, ∀ x, X ≤ x → Q i x) ↔ ∃ X, ∀ x, X ≤ x → ∀ i, Q i x := by
  classical
  constructor
  · intro h
    choose bound hbound using h
    refine ⟨Finset.univ.sup bound, ?_⟩
    intro x hx i
    apply hbound i x
    exact le_trans (Finset.le_sup (Finset.mem_univ i)) hx
  · rintro ⟨X, hX⟩ i
    exact ⟨X, fun x hx => hX x hx i⟩

end
end FVLT.TurnFourierV1
