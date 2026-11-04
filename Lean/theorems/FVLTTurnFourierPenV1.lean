import FVLTTurnFourierV1
import FVLTNaturalFanV1

/-!
Natural-time Fourier pen, sampled at complete turns. The character has positive
phase; plusDFT labels Mathlib's negative-sign DFT at the negative frequency.
All statements use actual complex coefficients, not only magnitudes or support.
No late-variation or Rule 30 dynamical theorem is asserted.
-/

noncomputable section
namespace FVLT.TurnFourierPenV1

open scoped BigOperators
open NaturalFanV1 TurnFourierV1

variable {P : ℕ} [NeZero P]

def zeta : ℂ := ZMod.stdAddChar (1 : ZMod P)

def natCharacter (k : ZMod P) (t : ℕ) : ℂ :=
  ZMod.stdAddChar (k * (t : ZMod P))

theorem zeta_eq_exp : zeta (P := P) = Complex.exp (2 * Real.pi * Complex.I / (P : ℂ)) := by
  simpa [zeta] using (ZMod.stdAddChar_coe (N := P) (1 : ℤ))

theorem natCharacter_eq_zeta_power (k : ZMod P) (t : ℕ) :
    natCharacter k t = zeta (P := P) ^ (k.val * t) := by
  simpa [natCharacter, zeta, nsmul_eq_mul, Nat.cast_mul] using
    (ZMod.stdAddChar (N := P)).map_nsmul_eq_pow (k.val * t) (1 : ZMod P)

def pen (c : ℕ → ℂ) (k : ZMod P) (n : ℕ) : ℂ :=
  ∑ t ∈ Finset.range n, c t * natCharacter k t

def step (c : ℕ → ℂ) (k : ZMod P) (x : ℕ) : ℂ :=
  pen c k (P * (x + 1)) - pen c k (P * x)

theorem pen_zero (c : ℕ → ℂ) (k : ZMod P) : pen c k 0 = 0 := by
  simp [pen]

theorem natCharacter_turn (k : ZMod P) (x b : ℕ) :
    natCharacter k (P * x + b) = natCharacter k b := by
  simp [natCharacter, Nat.cast_add, Nat.cast_mul]

theorem finEquiv_val (b : Fin P) : (ZMod.finEquiv P b).val = b.val := by
  cases P with
  | zero => exact (NeZero.ne 0 rfl).elim
  | succ n => rfl

theorem sum_range_eq_zmod (f : ℕ → ℂ) :
    (∑ b ∈ Finset.range P, f b) = ∑ b : ZMod P, f b.val := by
  rw [← Fin.sum_univ_eq_sum_range]
  exact Fintype.sum_equiv (ZMod.finEquiv P).toEquiv
    (fun b : Fin P => f b.val) (fun b : ZMod P => f b.val)
    (fun b => by congr 1; exact (finEquiv_val b).symm)

theorem step_eq_residue_sum (c : ℕ → ℂ) (k : ZMod P) (x : ℕ) :
    step c k x = ∑ b ∈ Finset.range P, c (P * x + b) * natCharacter k b := by
  unfold step pen
  rw [Nat.mul_succ, Finset.sum_range_add, add_sub_cancel_left]
  apply Finset.sum_congr rfl
  intro b _
  rw [natCharacter_turn]

/-- Exact complex step, with positive character phase and no 1/P normalization. -/
theorem step_eq_plusDFT (c : ℕ → ℂ) (k : ZMod P) (x : ℕ) :
    step c k x = plusDFT (turn P c x) k := by
  rw [step_eq_residue_sum, sum_range_eq_zmod, plusDFT_apply]
  apply Finset.sum_congr rfl
  intro b _
  simp [turn, natCharacter]

theorem second_step_difference (c : ℕ → ℂ) (k : ZMod P) (x : ℕ) :
    step c k (x + 1) - step c k x =
      plusDFT (turn P c (x + 1) - turn P c x) k := by
  simp only [step_eq_plusDFT, plusDFT_apply, Pi.sub_apply, sub_mul,
    Finset.sum_sub_distrib]

/-- A generic tail is constant exactly when its successive differences vanish. -/
theorem tail_constant_iff_adjacent {α : Type*} (f : ℕ → α) :
    (∃ X, ∀ x, X ≤ x → f x = f X) ↔
      ∃ X, ∀ x, X ≤ x → f (x + 1) = f x := by
  constructor
  · rintro ⟨X, hX⟩
    refine ⟨X, ?_⟩
    intro x hx
    exact (hX (x + 1) (by omega)).trans (hX x hx).symm
  · rintro ⟨X, hX⟩
    refine ⟨X, ?_⟩
    have hall : ∀ n : ℕ, f (X + n) = f X := by
      intro n
      induction n with
      | zero => simp
      | succ n ih =>
        calc
          f (X + (n + 1)) = f ((X + n) + 1) := by rfl
          _ = f (X + n) := hX (X + n) (by omega)
          _ = f X := ih
    intro x hx
    have he : X + (x - X) = x := by omega
    simpa only [he] using hall (x - X)

def UniformConstantSteps (c : ℕ → ℂ) : Prop :=
  ∃ X, ∀ x, X ≤ x → ∀ k : ZMod P, step c k x = step c k X

def PointwiseConstantSteps (c : ℕ → ℂ) : Prop :=
  ∀ k : ZMod P, ∃ X, ∀ x, X ≤ x → step c k x = step c k X

theorem uniform_constant_steps_iff_adjacent (c : ℕ → ℂ) :
    UniformConstantSteps (P := P) c ↔
      ∃ X, ∀ x, X ≤ x → ∀ k : ZMod P, step c k (x + 1) = step c k x := by
  have h := tail_constant_iff_adjacent (fun (x : ℕ) (k : ZMod P) => step c k x)
  simpa only [UniformConstantSteps, funext_iff] using h

theorem eventually_periodic_iff_uniform_constant_steps (c : ℕ → ℂ) :
    EventuallyPPeriodic P c ↔ UniformConstantSteps (P := P) c := by
  rw [eventual_period_iff_turns_stabilize,
    uniform_constant_steps_iff_adjacent]
  constructor
  · rintro ⟨X, hX⟩
    refine ⟨X, ?_⟩
    intro x hx k
    rw [step_eq_plusDFT, step_eq_plusDFT, hX x hx]
  · rintro ⟨X, hX⟩
    refine ⟨X, ?_⟩
    intro x hx
    apply plusDFT_injective
    funext k
    simpa only [step_eq_plusDFT] using hX x hx k

/-- Finiteness of the frequency set permits one uniform turn threshold. -/
theorem pointwise_constant_steps_iff_uniform (c : ℕ → ℂ) :
    PointwiseConstantSteps (P := P) c ↔ UniformConstantSteps (P := P) c := by
  constructor
  · intro h
    have ha : ∀ k : ZMod P, ∃ X, ∀ x, X ≤ x →
        step c k (x + 1) = step c k x := by
      intro k
      exact (tail_constant_iff_adjacent (fun x => step c k x)).mp (h k)
    obtain ⟨X, hX⟩ := (uniform_threshold_iff
      (fun (k : ZMod P) (x : ℕ) => step c k (x + 1) = step c k x)).mp ha
    exact (uniform_constant_steps_iff_adjacent c).mpr ⟨X, hX⟩
  · rintro ⟨X, hX⟩ k
    exact ⟨X, fun x hx => hX x hx k⟩

theorem eventually_periodic_iff_pointwise_constant_steps (c : ℕ → ℂ) :
    EventuallyPPeriodic P c ↔ PointwiseConstantSteps (P := P) c := by
  rw [eventually_periodic_iff_uniform_constant_steps,
    pointwise_constant_steps_iff_uniform]

def bitSignal (c : ℕ → Bool) (t : ℕ) : ℂ := if c t then 1 else 0

/-- T7 convention: true is +1 and false is -1. -/
def spinSignal (c : ℕ → Bool) (t : ℕ) : ℂ := if c t then 1 else -1

theorem spinSignal_eq (c : ℕ → Bool) (t : ℕ) :
    spinSignal c t = 2 * bitSignal c t - 1 := by
  cases h : c t <;> norm_num [spinSignal, bitSignal, h]

theorem spin_step_all (c : ℕ → Bool) (k : ZMod P) (x : ℕ) :
    step (spinSignal c) k x = 2 * step (bitSignal c) k x -
      (if k = 0 then (P : ℂ) else 0) := by
  have hc : (∑ b : ZMod P, ZMod.stdAddChar (k * b)) =
      if k = 0 then (P : ℂ) else 0 := by
    simpa only [plusDFT_apply, one_mul] using (plusDFT_const_one k)
  rw [step_eq_plusDFT, step_eq_plusDFT]
  simp only [plusDFT_apply, turn, spinSignal_eq, sub_mul, one_mul,
    mul_assoc, Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [hc]

theorem spin_step_nonDC (c : ℕ → Bool) (k : ZMod P) (hk : k ≠ 0) (x : ℕ) :
    step (spinSignal c) k x = 2 * step (bitSignal c) k x := by
  simp [spin_step_all, hk]

def bitCount (c : ℕ → Bool) (x : ℕ) : ℕ :=
  ∑ b : ZMod P, if c (P * x + b.val) then 1 else 0

theorem bit_step_DC (c : ℕ → Bool) (x : ℕ) :
    step (bitSignal c) (0 : ZMod P) x = (bitCount (P := P) c x : ℂ) := by
  simp [step_eq_plusDFT, plusDFT_apply, turn, bitSignal, bitCount,
    AddChar.map_zero_eq_one]

theorem spin_step_DC (c : ℕ → Bool) (x : ℕ) :
    step (spinSignal c) (0 : ZMod P) x =
      2 * (bitCount (P := P) c x : ℂ) - (P : ℂ) := by
  rw [spin_step_all, bit_step_DC]
  simp

omit [NeZero P] in
/-- The 0/1 embedding reflects, rather than merely preserves, Boolean periodicity. -/
theorem bitSignal_eventual_period_iff (c : ℕ → Bool) :
    EventuallyPPeriodic P (bitSignal c) ↔ EventuallyPPeriodic P c := by
  constructor
  · rintro ⟨T, hT⟩
    refine ⟨T, ?_⟩
    intro t ht
    have he := hT t ht
    cases h : c (t + P) <;> cases g : c t
    all_goals first | rfl | norm_num [bitSignal, h, g] at he
  · rintro ⟨T, hT⟩
    exact ⟨T, fun t ht => by simp [bitSignal, hT t ht]⟩

omit [NeZero P] in
/-- The T7 spin embedding also reflects Boolean periodicity. -/
theorem spinSignal_eventual_period_iff (c : ℕ → Bool) :
    EventuallyPPeriodic P (spinSignal c) ↔ EventuallyPPeriodic P c := by
  constructor
  · rintro ⟨T, hT⟩
    refine ⟨T, ?_⟩
    intro t ht
    have he := hT t ht
    cases h : c (t + P) <;> cases g : c t
    all_goals first | rfl | norm_num [spinSignal, h, g] at he
  · rintro ⟨T, hT⟩
    exact ⟨T, fun t ht => by simp [spinSignal, hT t ht]⟩

theorem boolean_period_iff_uniform_bit_steps (c : ℕ → Bool) :
    EventuallyPPeriodic P c ↔ UniformConstantSteps (P := P) (bitSignal c) := by
  rw [← bitSignal_eventual_period_iff, eventually_periodic_iff_uniform_constant_steps]

theorem boolean_period_iff_uniform_spin_steps (c : ℕ → Bool) :
    EventuallyPPeriodic P c ↔ UniformConstantSteps (P := P) (spinSignal c) := by
  rw [← spinSignal_eventual_period_iff, eventually_periodic_iff_uniform_constant_steps]

end FVLT.TurnFourierPenV1
