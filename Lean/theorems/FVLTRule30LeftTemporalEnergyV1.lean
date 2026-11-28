import FVLTTemporalMismatchEnergyV1
import FVLTS4fMaskedLeakV1
import Ruliology.CellularAutomata.Rule30Realization
import Ruliology.CellularAutomata.Rule30FiniteConfigs

/-!
A2: exact real complete-residue SUM energies on length-2P temporal windows.
The left-neighbour bounds apply to the left only; no right <= 2*w_P assertion.
Period and synchronization hypotheses stay explicit; the equivalence assumes
neither side. No existence of such a finite-seed tail is claimed. Coexistence of
centre zero energy and neighbour positive energy
is not a contradiction. No nonperiodicity, Q01/CQ01, prize, density, bounded-wait
or further-propagation conclusion; O1/O2/O3 stay open. No kernel change.
-/
set_option autoImplicit false
noncomputable section
namespace FVLT.Rule30LeftTemporalEnergyV1
open Ruliology.CellularAutomata
open Rule30Realization Rule30PeriodTwoSideways
open FVLT.TemporalMismatchEnergyV1

-- BEGIN FROZEN DEFINITIONS
def lag (x : Int → Bool) (P : Nat) (i : Int) (t : Nat) : Bool :=
  xor (evol x t i) (evol x (t + P) i)

def whiteCount (P : Nat) (f : Nat → Bool) (t0 : Nat) : Nat :=
  ((Finset.range P).filter (fun j => f (t0 + j) = false)).card

def whiteRightMismatchCount (x : Int → Bool) (P t0 : Nat) : Nat :=
  ((Finset.range P).filter (fun j =>
    evol x (t0 + j) 0 = false ∧ lag x P 1 (t0 + j) = true)).card
-- END FROZEN DEFINITIONS

private theorem xor_true_ne (a b : Bool) : xor a b = true ↔ a ≠ b := by
  cases a <;> cases b <;> decide

private theorem xor_false_eq (a b : Bool) : xor a b = false ↔ a = b := by
  cases a <;> cases b <;> decide

private theorem gate_true (a b : Bool) : ((!a) && b) = true ↔ a = false ∧ b = true := by
  cases a <;> cases b <;> decide

private theorem window_ne_iff_lag (x : Int → Bool) (P : Nat) (i : Int) (t0 j : Nat) :
    (evol x (t0+j) i ≠ evol x (t0+P+j) i) ↔ lag x P i (t0+j) = true := by
  simpa only [lag, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
    (xor_true_ne (evol x (t0+j) i) (evol x (t0+P+j) i)).symm

private theorem slide_sum (g : Nat → Nat) (a n : Nat) :
    (Finset.sum (Finset.range n) (fun j => g (a+j))) + g (a+n) =
      g a + Finset.sum (Finset.range n) (fun j => g (a+1+j)) := by
  induction n with
  | zero => simp
  | succ n ih =>
    simp only [Finset.sum_range_succ]
    rw [show a+(n+1)=a+1+n by omega]
    omega

private theorem white_step (P : Nat) (f : Nat → Bool) (a : Nat)
    (hp : f (a+P)=f a) : whiteCount P f (a+1)=whiteCount P f a := by
  have hs := slide_sum (fun t => if f t = false then 1 else 0) a P
  simp only [hp] at hs
  unfold whiteCount
  simp only [Finset.card_filter]
  omega

private theorem tail_reduce (f : Nat → Bool) (T P : Nat) (hP : 0<P)
    (hp : ∀ t : Nat, T≤t → f (t+P)=f t) (n : Nat) :
    f (T+n)=f (T+n%P) := by
  induction n using Nat.strong_induction_on with
  | h n ih =>
    by_cases hn : n<P
    · rw [Nat.mod_eq_of_lt hn]
    · have hge : P≤n := by omega
      have hlt : n-P<n := by omega
      have hr : (n-P)%P=n%P := by
        conv_rhs => rw [show n=(n-P)+P by omega, Nat.add_mod_right]
      calc
        f (T+n)=f (T+(n-P)) := by
          simpa only [show T+(n-P)+P=T+n by omega] using hp (T+(n-P)) (by omega)
        _ = f (T+(n-P)%P) := ih (n-P) hlt
        _ = f (T+n%P) := by rw [hr]

private theorem forward_difference (l c r l' r' : Bool) :
    xor (Rule30Jen.rule l c r) (Rule30Jen.rule l' c r') =
      xor (xor l l') ((!c) && xor r r') := by
  cases l <;> cases c <;> cases r <;> cases l' <;> cases r' <;> decide

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem left_lag_eq_white_right_lag (x : Int → Bool) (t P : Nat)
    (hc : evol x (t + P) 0 = evol x t 0)
    (hn : evol x (t + P + 1) 0 = evol x (t + 1) 0) :
    lag x P (-1) t = ((!evol x t 0) && lag x P 1 t) := by
  have h := FVLT.S4fMaskedLeakV1.actual_masked_difference x t P hc hn
  simpa only [lag, Bool.xor_comm] using h

private theorem mask_on_tail (x : Int → Bool) (T P : Nat)
    (hp : ∀ t : Nat, T≤t → evol x (t+P) 0=evol x t 0)
    (t : Nat) (ht : T≤t) :
    lag x P (-1) t = ((!evol x t 0) && lag x P 1 t) := by
  apply left_lag_eq_white_right_lag x t P (hp t ht)
  simpa only [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hp (t+1) (by omega)

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem left_mismatchCount_eq_gated (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    mismatchCount P (fun t => evol x t (-1)) t0 = whiteRightMismatchCount x P t0 := by
  unfold mismatchCount whiteRightMismatchCount
  congr 1
  ext j
  simp only [Finset.mem_filter]
  constructor
  · rintro ⟨hj, hm⟩
    have hl := (window_ne_iff_lag x P (-1) t0 j).mp hm
    rw [mask_on_tail x T P hper (t0+j) (by omega)] at hl
    exact ⟨hj, (gate_true _ _).mp hl⟩
  · rintro ⟨hj, hc, hr⟩
    refine ⟨hj, (window_ne_iff_lag x P (-1) t0 j).mpr ?_⟩
    rw [mask_on_tail x T P hper (t0+j) (by omega)]
    exact (gate_true _ _).mpr ⟨hc,hr⟩

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem whiteCount_tail_anchor (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    whiteCount P (fun t => evol x t 0) t0 = whiteCount P (fun t => evol x t 0) T := by
  have hi : ∀ n : Nat, whiteCount P (fun t => evol x t 0) (T+n) =
      whiteCount P (fun t => evol x t 0) T := by
    intro n
    induction n with
    | zero => rfl
    | succ n ih =>
      have hs := white_step P (fun t => evol x t 0) (T+n) (hper (T+n) (by omega))
      simpa only [Nat.add_assoc] using hs.trans ih
  simpa only [show T+(t0-T)=t0 by omega] using hi (t0-T)

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem left_off_energy_le_right (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    offEnergy (2 * P) P (window (fun t => evol x t (-1)) t0) ≤
      offEnergy (2 * P) P (window (fun t => evol x t 1) t0) := by
  have hh : whiteRightMismatchCount x P t0 ≤
      mismatchCount P (fun t => evol x t 1) t0 := by
    unfold whiteRightMismatchCount mismatchCount
    apply Finset.card_le_card
    intro j hj
    obtain ⟨hrange, _, hr⟩ := Finset.mem_filter.mp hj
    exact Finset.mem_filter.mpr ⟨hrange, (window_ne_iff_lag x P 1 t0 j).mpr hr⟩
  have hm : mismatchCount P (fun t => evol x t (-1)) t0 ≤
      mismatchCount P (fun t => evol x t 1) t0 := by
    rw [left_mismatchCount_eq_gated x T P t0 hP ht0 hper]
    exact hh
  simp only [off_energy_eq_twice_mismatchCount P hP]
  exact_mod_cast Nat.mul_le_mul_left 2 hm

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem left_off_energy_le_whiteCount (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    offEnergy (2 * P) P (window (fun t => evol x t (-1)) t0) ≤
      2 * (whiteCount P (fun t => evol x t 0) T : Real) := by
  have hh : whiteRightMismatchCount x P t0 ≤ whiteCount P (fun t => evol x t 0) t0 := by
    unfold whiteRightMismatchCount whiteCount
    apply Finset.card_le_card
    intro j hj
    obtain ⟨hrange, hc, _⟩ := Finset.mem_filter.mp hj
    exact Finset.mem_filter.mpr ⟨hrange,hc⟩
  have hm : mismatchCount P (fun t => evol x t (-1)) t0 ≤ whiteCount P (fun t => evol x t 0) T := by
    rw [left_mismatchCount_eq_gated x T P t0 hP ht0 hper]
    rw [whiteCount_tail_anchor x T P t0 hP ht0 hper] at hh
    exact hh
  rw [off_energy_eq_twice_mismatchCount P hP]
  exact_mod_cast Nat.mul_le_mul_left 2 hm

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem finite_whiteCount_le_pred (x : Int → Bool) (T P : Nat)
    (hfin : FinConfig x) (hne : ∃ p : Int, x p = true) (hP : 0 < P)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    whiteCount P (fun t => evol x t 0) T ≤ P - 1 := by
  by_contra hn
  have hle : whiteCount P (fun t => evol x t 0) T ≤ P := by
    unfold whiteCount
    exact (Finset.card_le_card (Finset.filter_subset _ _)).trans (by simp)
  have heq : whiteCount P (fun t => evol x t 0) T = P := by omega
  have hset : (Finset.range P).filter (fun j => evol x (T+j) 0=false) = Finset.range P := by
    apply Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _)
    simpa only [Finset.card_range, whiteCount] using heq.ge
  have hall (j : Nat) (hj : j<P) : evol x (T+j) 0=false := by
    have hm : j ∈ (Finset.range P).filter (fun j => evol x (T+j) 0=false) := by
      rw [hset]
      exact Finset.mem_range.mpr hj
    exact (Finset.mem_filter.mp hm).2
  apply Rule30FiniteConfigs.no_column_eventually_constant_finite hfin hne 0
  refine ⟨T,false,?_⟩
  intro t ht
  have hr := tail_reduce (fun s => evol x s 0) T P hP hper (t-T)
  have hw := hall ((t-T)%P) (Nat.mod_lt _ hP)
  have hh := hr.trans hw
  simpa only [show T+(t-T)=t by omega] using hh

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem left_off_energy_arbitrarily_late (x : Int → Bool) (T P : Nat)
    (hfin : FinConfig x) (hne : ∃ p : Int, x p = true) (hP : 0 < P)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0)
    (B : Nat) :
    ∃ t0 : Nat, B ≤ t0 ∧ T ≤ t0 ∧ evol x t0 0 = false ∧
      2 ≤ offEnergy (2 * P) P (window (fun t => evol x t (-1)) t0) := by
  obtain ⟨t0,hB,hT,hw,hr⟩ := FVLT.S4fMaskedLeakV1.white_leak_arbitrarily_late hfin hne hP hper B
  have hrl : lag x P 1 t0=true := (xor_true_ne _ _).mpr (Ne.symm hr)
  have hll : lag x P (-1) t0=true := by
    rw [mask_on_tail x T P hper t0 hT]
    simp only [hw, hrl, Bool.not_false, Bool.true_and]
  refine ⟨t0,hB,hT,hw,?_⟩
  apply mismatch_forces_off_energy P hP (fun t => evol x t (-1)) t0 0 hP
  exact (window_ne_iff_lag x P (-1) t0 0).mpr (by simpa using hll)

/-- One-step rule identity under a current centre match; no finite-support premise. -/
theorem center_next_lag_eq_sync_difference (x : Int → Bool) (t P : Nat)
    (hc : evol x (t + P) 0 = evol x t 0) :
    lag x P 0 (t + 1) =
      xor (lag x P (-1) t) ((!evol x t 0) && lag x P 1 t) := by
  unfold lag
  rw [show t+1+P=t+P+1 by omega]
  change xor (Rule30Jen.rule (evol x t (-1)) (evol x t 0) (evol x t 1))
      (Rule30Jen.rule (evol x (t+P) (-1)) (evol x (t+P) 0) (evol x (t+P) 1)) = _
  rw [hc]
  exact forward_difference _ _ _ _ _

/-- Initial centre match plus continuing pointwise synchronization implies the periodic tail. -/
theorem center_tail_period_of_initial_match_and_sync
    (x : Int → Bool) (T P : Nat)
    (hstart : evol x (T + P) 0 = evol x T 0)
    (hsync : ∀ t : Nat, T ≤ t →
      lag x P (-1) t = ((!evol x t 0) && lag x P 1 t)) :
    ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0 := by
  have hi : ∀ n : Nat, evol x (T+n+P) 0=evol x (T+n) 0 := by
    intro n
    induction n with
    | zero => simpa only [Nat.add_zero] using hstart
    | succ n ih =>
      have hs : lag x P 0 (T+n+1)=false := by
        rw [center_next_lag_eq_sync_difference x (T+n) P ih, hsync (T+n) (by omega)]
        simp
      have he : evol x (T+n+1) 0=evol x (T+n+1+P) 0 := (xor_false_eq _ _).mp hs
      simpa only [Nat.add_assoc] using he.symm
  intro t ht
  simpa only [show T+(t-T)=t by omega] using hi (t-T)

/-- Exact equivalence for positive P: initial match AND pointwise synchronization, not aggregate-energy equality; no contradiction. -/
theorem center_tail_period_iff_initial_match_and_sync
    (x : Int → Bool) (T P : Nat) (hP : 0 < P) :
    (∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) ↔
      (evol x (T + P) 0 = evol x T 0 ∧
        ∀ t : Nat, T ≤ t →
          lag x P (-1) t = ((!evol x t 0) && lag x P 1 t)) := by
  constructor
  · intro hp
    refine ⟨hp T (by omega),?_⟩
    intro t ht
    exact mask_on_tail x T P hp t ht
  · rintro ⟨hs,hm⟩
    exact center_tail_period_of_initial_match_and_sync x T P hs hm

end FVLT.Rule30LeftTemporalEnergyV1
end
