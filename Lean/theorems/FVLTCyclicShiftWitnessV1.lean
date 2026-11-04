import FVLTTurnFourierV1

/-!
Positive-sign, unnormalized DFT shift law and a phase-loss witness.
This is a statement about deliberately chosen cyclic signals. It makes no
assertion that Rule30 produces the example or forces variation at late times.
-/
namespace FVLT.CyclicShiftWitnessV1
open TurnFourierV1 AddChar
noncomputable section
variable {P : ℕ} [NeZero P]

def shift (a : ZMod P) (f : ZMod P → ℂ) (b : ZMod P) : ℂ := f (b+a)

theorem plusDFT_shift (a : ZMod P) (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (shift a f) k =
      ZMod.stdAddChar (-(k*a))*plusDFT f k := by
  rw [plusDFT_apply,plusDFT_apply,Finset.mul_sum]
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

theorem character_normSq (z : ZMod P) :
    Complex.normSq (ZMod.stdAddChar z) = 1 := by
  simp [Complex.normSq_eq_norm_sq,ZMod.stdAddChar_apply]

theorem plusDFT_shift_normSq (a : ZMod P) (f : ZMod P → ℂ) (k : ZMod P) :
    Complex.normSq (plusDFT (shift a f) k) = Complex.normSq (plusDFT f k) := by
  rw [plusDFT_shift,map_mul,character_normSq,one_mul]

theorem plusDFT_shift_zero_iff (a : ZMod P) (f : ZMod P → ℂ) (k : ZMod P) :
    plusDFT (shift a f) k = 0 ↔ plusDFT f k = 0 := by
  have hc : ZMod.stdAddChar (-(k*a)) ≠ 0 := by
    intro h
    have hn := character_normSq (-(k*a))
    simp [h] at hn
  rw [plusDFT_shift]
  simp [hc]

theorem plusDFT_shift_support (a : ZMod P) (f : ZMod P → ℂ) :
    {k | plusDFT (shift a f) k ≠ 0} = {k | plusDFT f k ≠ 0} := by
  ext k
  simp only [Set.mem_ofPred_eq,ne_eq,plusDFT_shift_zero_iff]

/-- Sum-scale full conductor energy for the positive-sign unnormalized transform. -/
def conductorEnergy (q : ℕ) (f : ZMod P → ℂ) : ℝ :=
  (∑ k : ZMod P, if addOrderOf k=q then Complex.normSq (plusDFT f k) else 0)/(P : ℝ)

theorem conductorEnergy_shift (q : ℕ) (a : ZMod P) (f : ZMod P → ℂ) :
    conductorEnergy q (shift a f) = conductorEnergy q f := by
  simp only [conductorEnergy,plusDFT_shift_normSq]

def spike (b : ZMod 2) : ℂ := if b=0 then 1 else 0

theorem plusDFT_spike (k : ZMod 2) : plusDFT spike k = 1 := by
  simp [plusDFT_apply,spike]

theorem shifted_spike_ne : shift (1 : ZMod 2) spike ≠ spike := by
  intro h
  have he := congrFun h 0
  norm_num [shift,spike] at he

theorem shifted_spike_same_magnitudes (k : ZMod 2) :
    Complex.normSq (plusDFT (shift (1 : ZMod 2) spike) k) =
      Complex.normSq (plusDFT spike k) :=
  plusDFT_shift_normSq 1 spike k

def alternatingTurns (x : ℕ) : ZMod 2 → ℂ := shift (x : ZMod 2) spike

theorem alternatingTurns_magnitudes (x : ℕ) (k : ZMod 2) :
    Complex.normSq (plusDFT (alternatingTurns x) k) = 1 := by
  unfold alternatingTurns
  rw [plusDFT_shift_normSq,plusDFT_spike]
  simp

theorem alternatingTurns_at_own (x : ℕ) :
    alternatingTurns x (-(x : ZMod 2)) = 1 := by
  change spike (-(x : ZMod 2) + (x : ZMod 2)) = 1
  rw [neg_add_cancel]
  norm_num [spike]

theorem alternatingTurns_next_at_own (x : ℕ) :
    alternatingTurns (x+1) (-(x : ZMod 2)) = 0 := by
  have hi : -(x : ZMod 2)+((x+1 : ℕ) : ZMod 2) = 1 := by
    push_cast
    ring
  change spike (-(x : ZMod 2)+((x+1 : ℕ) : ZMod 2)) = 0
  rw [hi]
  norm_num [spike]

theorem alternatingTurns_next_ne (x : ℕ) :
    alternatingTurns (x+1) ≠ alternatingTurns x := by
  intro h
  have he := congrFun h (-(x : ZMod 2))
  rw [alternatingTurns_next_at_own,alternatingTurns_at_own] at he
  exact zero_ne_one he

theorem alternatingTurns_not_eventually_stabilized :
    ¬ ∃ X : ℕ, ∀ x : ℕ, X≤x → alternatingTurns (x+1)=alternatingTurns x := by
  rintro ⟨X,hX⟩
  exact alternatingTurns_next_ne X (hX X le_rfl)

/-- Flatten the alternating turns into one actual natural-time 0/1-valued signal. -/
def alternatingSignal (t : ℕ) : ℂ := alternatingTurns (t / 2) (t : ZMod 2)

theorem turn_alternatingSignal (x : ℕ) :
    NaturalFanV1.turn 2 alternatingSignal x = alternatingTurns x := by
  funext b
  have hx := (NaturalFanV1.quotient_remainder_of_address 2 x b.val b.val_lt).1
  change alternatingTurns ((2 * x + b.val) / 2) ((2 * x + b.val : ℕ) : ZMod 2) =
    alternatingTurns x b
  rw [hx]
  simp [Nat.cast_add, Nat.cast_mul, show (2 : ZMod 2) = 0 from rfl]

theorem alternatingSignal_constant_fourier_magnitudes (x : ℕ) (k : ZMod 2) :
    Complex.normSq (plusDFT (NaturalFanV1.turn 2 alternatingSignal x) k) = 1 := by
  rw [turn_alternatingSignal]
  exact alternatingTurns_magnitudes x k

theorem alternatingSignal_constant_conductor_energy (q x : ℕ) :
    conductorEnergy q (NaturalFanV1.turn 2 alternatingSignal x) = conductorEnergy q spike := by
  rw [turn_alternatingSignal]
  exact conductorEnergy_shift q (x : ZMod 2) spike

theorem alternatingSignal_not_eventually_period_two :
    ¬NaturalFanV1.EventuallyPPeriodic 2 alternatingSignal := by
  intro h
  obtain ⟨X, hX⟩ := (NaturalFanV1.eventual_period_iff_turns_stabilize 2 alternatingSignal).mp h
  exact alternatingTurns_next_ne X (by simpa only [turn_alternatingSignal] using hX X le_rfl)

end
end FVLT.CyclicShiftWitnessV1
