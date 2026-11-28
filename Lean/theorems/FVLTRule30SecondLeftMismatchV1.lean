import FVLTRule30LeftTemporalEnergyV1

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
namespace FVLT.Rule30SecondLeftMismatchV1
open Ruliology.CellularAutomata
open Rule30Realization
open FVLT.TemporalMismatchEnergyV1 FVLT.Rule30LeftTemporalEnergyV1

private theorem xor_true_ne (a b : Bool) : xor a b = true ↔ a ≠ b := by
  cases a <;> cases b <;> decide

private theorem unequal_has_true (a b : Bool) (h : a ≠ b) : a=true ∨ b=true := by
  cases a <;> cases b <;> simp_all

private theorem mask_fixed (c d : Bool) : ((!c) && ((!c) && d)) = ((!c) && d) := by
  cases c <;> cases d <;> decide

private theorem pair_difference (a a' b b' c : Bool) :
    xor (xor a (b || c)) (xor a' (b' || c)) =
      xor (xor a a') ((!c) && xor b b') := by
  cases a <;> cases a' <;> cases b <;> cases b' <;> cases c <;> decide

private theorem window_ne_iff_lag (x : Int → Bool) (P : Nat) (i : Int) (t0 j : Nat) :
    (evol x (t0+j) i ≠ evol x (t0+P+j) i) ↔ lag x P i (t0+j) = true := by
  simpa only [lag, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
    (xor_true_ne (evol x (t0+j) i) (evol x (t0+P+j) i)).symm

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem second_left_lag_eq_xor (x : Int → Bool) (T P t : Nat)
    (hP : 0 < P) (ht : T ≤ t)
    (hper : ∀ s : Nat, T ≤ s → evol x (s + P) 0 = evol x s 0) :
    lag x P (-2) t = xor (lag x P (-1) t) (lag x P (-1) (t + 1)) := by
  have hc := hper t ht
  have hn : evol x (t+P+1) 0=evol x (t+1) 0 := by
    simpa only [Nat.add_assoc,Nat.add_comm,Nat.add_left_comm] using hper (t+1) (by omega)
  have hm := left_lag_eq_white_right_lag x t P hc hn
  have hg : ((!evol x t 0) && lag x P (-1) t)=lag x P (-1) t := by
    rw [hm]
    exact mask_fixed _ _
  have h0 : evol x t (-2)=xor (evol x (t+1) (-1)) (evol x t (-1) || evol x t 0) := by
    simpa using Rule30FiniteConfigs.evol_left x t (-1)
  have h1 : evol x (t+P) (-2)=xor (evol x (t+P+1) (-1))
      (evol x (t+P) (-1) || evol x (t+P) 0) := by
    simpa using Rule30FiniteConfigs.evol_left x (t+P) (-1)
  calc
    lag x P (-2) t = xor
        (xor (evol x (t+1) (-1)) (evol x t (-1) || evol x t 0))
        (xor (evol x (t+P+1) (-1)) (evol x (t+P) (-1) || evol x t 0)) := by
      unfold lag
      rw [h0,h1,hc]
    _ = xor (lag x P (-1) (t+1)) ((!evol x t 0) && lag x P (-1) t) := by
      unfold lag
      rw [show t+1+P=t+P+1 by omega]
      exact pair_difference _ _ _ _ _
    _ = xor (lag x P (-1) t) (lag x P (-1) (t+1)) := by
      rw [hg]
      exact Bool.xor_comm _ _

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. Interval edge count: retain the real endpoint, without cyclic wrapping. -/
theorem second_left_mismatchCount_eq_edges (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    mismatchCount P (fun t => evol x t (-2)) t0 =
      ((Finset.range P).filter (fun j =>
        lag x P (-1) (t0 + j) ≠ lag x P (-1) (t0 + j + 1))).card := by
  unfold mismatchCount
  congr 1
  ext j
  simp only [Finset.mem_filter]
  constructor
  · rintro ⟨hj,hm⟩
    have hl := (window_ne_iff_lag x P (-2) t0 j).mp hm
    rw [second_left_lag_eq_xor x T P (t0+j) hP (by omega) hper] at hl
    exact ⟨hj,(xor_true_ne _ _).mp hl⟩
  · rintro ⟨hj,hm⟩
    refine ⟨hj,(window_ne_iff_lag x P (-2) t0 j).mpr ?_⟩
    rw [second_left_lag_eq_xor x T P (t0+j) hP (by omega) hper]
    exact (xor_true_ne _ _).mpr hm

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. -/
theorem second_left_mismatchCount_le_adjacent (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    mismatchCount P (fun t => evol x t (-2)) t0 ≤
      mismatchCount P (fun t => evol x t (-1)) t0 +
        mismatchCount P (fun t => evol x t (-1)) (t0 + 1) := by
  let A : Finset Nat := (Finset.range P).filter (fun j =>
    evol x (t0+j) (-1) ≠ evol x (t0+P+j) (-1))
  let B : Finset Nat := (Finset.range P).filter (fun j =>
    evol x (t0+1+j) (-1) ≠ evol x (t0+1+P+j) (-1))
  let E : Finset Nat := (Finset.range P).filter (fun j =>
    lag x P (-1) (t0+j) ≠ lag x P (-1) (t0+j+1))
  have hs : E ⊆ A ∪ B := by
    intro j hj
    obtain ⟨hrange,he⟩ := Finset.mem_filter.mp hj
    rcases unequal_has_true _ _ he with ha | hb
    · apply Finset.mem_union.mpr
      left
      exact Finset.mem_filter.mpr ⟨hrange,(window_ne_iff_lag x P (-1) t0 j).mpr ha⟩
    · apply Finset.mem_union.mpr
      right
      have hh : lag x P (-1) (t0+1+j)=true := by
        simpa only [Nat.add_assoc,Nat.add_comm,Nat.add_left_comm] using hb
      exact Finset.mem_filter.mpr ⟨hrange,(window_ne_iff_lag x P (-1) (t0+1) j).mpr hh⟩
  rw [second_left_mismatchCount_eq_edges x T P t0 hP ht0 hper]
  change E.card ≤ A.card+B.card
  exact (Finset.card_le_card hs).trans (Finset.card_union_le A B)

/-- Conditional on the explicit centre-period equalities; no existence claim for such a tail. Count bound may exceed P and is not a cancellation estimate; energy bound would be 4*w_P. -/
theorem second_left_mismatchCount_le_twice_whiteCount
    (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    mismatchCount P (fun t => evol x t (-2)) t0 ≤
      2 * whiteCount P (fun t => evol x t 0) T := by
  have bound (s : Nat) (hs : T≤s) :
      mismatchCount P (fun t => evol x t (-1)) s ≤ whiteCount P (fun t => evol x t 0) T := by
    have he := left_off_energy_le_whiteCount x T P s hP hs hper
    rw [off_energy_eq_twice_mismatchCount P hP] at he
    have hh : (mismatchCount P (fun t => evol x t (-1)) s : Real) ≤
        (whiteCount P (fun t => evol x t 0) T : Real) := by linarith
    exact_mod_cast hh
  have h0 := bound t0 ht0
  have h1 := bound (t0+1) (by omega)
  have he := second_left_mismatchCount_le_adjacent x T P t0 hP ht0 hper
  omega

end FVLT.Rule30SecondLeftMismatchV1
end
