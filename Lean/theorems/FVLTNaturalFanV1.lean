import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic

/-!
Natural-time fan addresses and uniform eventual stabilization of whole turns.
This file is Stage A's combinatorial interface only: no Fourier transform,
geometric cone, Rule 30 evolution, or forced-late-variation assertion.
-/

namespace FVLT.NaturalFanV1

def turn {α : Type*} (P : ℕ) (c : ℕ → α) (x : ℕ) (b : ZMod P) : α :=
  c (P * x + b.val)

def EventuallyPPeriodic {α : Type*} (P : ℕ) (c : ℕ → α) : Prop :=
  ∃ T, ∀ t, T ≤ t → c (t + P) = c t

def TurnsStabilize {α : Type*} (P : ℕ) (c : ℕ → α) : Prop :=
  ∃ X, ∀ x, X ≤ x → turn P c (x + 1) = turn P c x

theorem period_pos (P : ℕ) [NeZero P] : 0 < P :=
  Nat.pos_of_ne_zero (NeZero.ne P)

/-- Natural quotient and remainder give every time an exact address. -/
theorem natural_address (P t : ℕ) [NeZero P] :
    P * (t / P) + t % P = t ∧ t % P < P := by
  constructor
  · have h := Nat.mod_add_div t P
    omega
  · exact Nat.mod_lt t (period_pos P)

/-- Uniqueness is in the natural fan, before any cyclic/Fourier interpretation. -/
theorem natural_address_unique (P : ℕ) [NeZero P]
    {x y b d : ℕ} (hb : b < P) (hd : d < P)
    (h : P * x + b = P * y + d) : x = y ∧ b = d := by
  have hbd : b = d := by
    have hm := congrArg (fun t : ℕ => t % P) h
    simpa [Nat.add_mod, Nat.mul_mod, Nat.mod_eq_of_lt hb,
      Nat.mod_eq_of_lt hd] using hm
  have hxy : P * x = P * y := by omega
  exact ⟨mul_left_cancel₀ (NeZero.ne P) hxy, hbd⟩

theorem quotient_remainder_of_address (P : ℕ) [NeZero P]
    (x b : ℕ) (hb : b < P) :
    (P * x + b) / P = x ∧ (P * x + b) % P = b := by
  have ha := natural_address P (P * x + b)
  exact natural_address_unique P ha.2 hb ha.1

/-- Exact cyclic-residue representative; the natural time itself is not quotiented. -/
theorem zmod_address (P t : ℕ) [NeZero P] :
    P * (t / P) + (t : ZMod P).val = t := by
  rw [ZMod.val_natCast]
  exact (natural_address P t).1

/-- A genuine bijection between times and turn/residue addresses. -/
def naturalAddressEquiv (P : ℕ) [NeZero P] : (ℕ × Fin P) ≃ ℕ where
  toFun q := P * q.1 + q.2.val
  invFun t := (t / P, ⟨t % P, (natural_address P t).2⟩)
  left_inv q := by
    apply Prod.ext
    · exact (quotient_remainder_of_address P q.1 q.2.val q.2.isLt).1
    · apply Fin.ext
      exact (quotient_remainder_of_address P q.1 q.2.val q.2.isLt).2
  right_inv t := (natural_address P t).1

/-- A bounded residue advances locally or carries exactly one turn. -/
theorem address_carry (P : ℕ) [NeZero P] (x b : ℕ) (hb : b < P) :
    P * x + b + 1 =
      if b + 1 < P then P * x + (b + 1) else P * (x + 1) := by
  split_ifs with h
  · omega
  · have he : b + 1 = P := by omega
    calc
      P * x + b + 1 = P * x + (b + 1) := by omega
      _ = P * x + P := by rw [he]
      _ = P * (x + 1) := by ring

theorem sample_carry {α : Type*} (P : ℕ) [NeZero P]
    (c : ℕ → α) (x b : ℕ) (hb : b < P) :
    c (P * x + b + 1) =
      if b + 1 < P then c (P * x + (b + 1)) else c (P * (x + 1)) := by
  rw [address_carry P x b hb]
  split_ifs <;> rfl

/-- The threshold in natural time yields a uniform lower bound on its turn index. -/
theorem quotient_ge_of_turn_threshold (P X t : ℕ) [NeZero P]
    (ht : P * X ≤ t) : X ≤ t / P := by
  have ha := natural_address P t
  by_contra hn
  have hx : t / P + 1 ≤ X := by omega
  have hm := Nat.mul_le_mul_left P hx
  nlinarith [ha.1, ha.2]

/-- Uniform equality of successive whole turns is exactly eventual P-periodicity.
The reverse direction uses one threshold X for all residues, not pointwise
residue-dependent thresholds and not just equality of turn energies. -/
theorem eventual_period_iff_turns_stabilize {α : Type*}
    (P : ℕ) [NeZero P] (c : ℕ → α) :
    EventuallyPPeriodic P c ↔ TurnsStabilize P c := by
  constructor
  · rintro ⟨T, hT⟩
    refine ⟨T, ?_⟩
    intro x hx
    funext b
    have hxmul : x ≤ P * x := by
      have hp : 1 ≤ P := period_pos P
      simpa using Nat.mul_le_mul_right x hp
    have htime : T ≤ P * x + b.val := by omega
    have he := hT (P * x + b.val) htime
    simpa [turn, Nat.mul_add, Nat.add_assoc, Nat.add_left_comm,
      Nat.add_comm] using he
  · rintro ⟨X, hX⟩
    refine ⟨P * X, ?_⟩
    intro t ht
    have hx : X ≤ t / P := quotient_ge_of_turn_threshold P X t ht
    have he := congrFun (hX (t / P) hx) (t : ZMod P)
    have ha := zmod_address P t
    have hnext : P * (t / P + 1) + (t : ZMod P).val = t + P := by
      calc
        P * (t / P + 1) + (t : ZMod P).val =
            (P * (t / P) + (t : ZMod P).val) + P := by ring
        _ = t + P := by rw [ha]
    simpa only [turn, hnext, ha] using he

end FVLT.NaturalFanV1
