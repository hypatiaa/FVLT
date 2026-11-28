import FVLTRule30LiftedBaselineV1

/-! Supporting interface between the audited actual-trace reconstruction and the frozen kit Psi.
Black-first altCol only. Arbitrary right row R; no finite-support hypothesis is needed
for these identities. No shifted-r or parity corollaries, global support result or prize claim. -/

open Ruliology.CellularAutomata
open Rule30PeriodTwoCoupled Rule30PeriodTwoSideways Rule30ZeroBoundary
open Rule30Ether (drv)
open FVLT.Rule30FiniteReconstructionV1 FVLT.Rule30LiftedBaselineV1

namespace FVLT.Rule30PsiSupportBridgeV1

private theorem actual_traceColumn_positive (R : Nat → Bool) (m k : Nat)
    (hk : 1 ≤ k) (hkm : k ≤ m) :
    traceColumn altCol ((List.range m).map (fun t => drv altCol R t 1)) k 0 = Psi R k := by
  let x : Int → Bool := glue (Psi R) R
  have he (t : Nat) (p : Int) : Rule30Realization.evol x t p = gluedRun (Psi R) R t p :=
    evol_glue (Psi R) R (Psi_inX R) (Psi_free R) t p
  have hc : ∀ t : Nat, t ≤ m → altCol t = Rule30Realization.evol x t 0 := by
    intro t _
    rw [he, gluedRun_zero]
  have hu : ∀ t : Nat, t < m →
      ((List.range m).map (fun t => drv altCol R t 1)).getD t false = Rule30Realization.evol x t 1 := by
    intro t ht
    rw [he, gluedRun_one]
    simp [List.getD_eq_getElem?_getD, ht]
  have ht := traceColumn_eq_evol x altCol
    ((List.range m).map (fun t => drv altCol R t 1)) m (by simp) hc hu k 0 (by omega)
  simpa [Rule30Realization.evol, x, glue, show -(k : Int) < 0 by omega, show 0 < k by omega] using ht

private theorem actual_nextCell_eq_psi (R : Nat → Bool) (m : Nat) :
    nextCell altCol ((List.range m).map (fun t => drv altCol R t 1))
      (drv altCol R m 1) = Psi R (m + 1) := by
  unfold nextCell
  simp only [List.length_map, List.length_range]
  have hl : ((List.range m).map (fun t => drv altCol R t 1)) ++ [drv altCol R m 1] =
      (List.range (m + 1)).map (fun t => drv altCol R t 1) := by
    simp [List.range_succ]
  rw [hl]
  exact actual_traceColumn_positive R (m + 1) (m + 1) (by omega) (by omega)

theorem baseline_actual_trace_eq_psi (R : Nat → Bool) (m : Nat) :
    baseline altCol ((List.range m).map (fun t => drv altCol R t 1)) =
      xor (Psi R (m + 1)) ((!(altCol m)) && drv altCol R m 1) := by
  have h := nextCell_affine altCol ((List.range m).map (fun t => drv altCol R t 1))
    (drv altCol R m 1)
  rw [actual_nextCell_eq_psi, List.length_map, List.length_range] at h
  have cancel (a b : Bool) : xor (xor a b) b = a := by
    cases a <;> cases b <;> rfl
  have hc := congrArg (fun z : Bool => xor z ((!(altCol m)) && drv altCol R m 1)) h
  simp only [cancel] at hc
  exact hc.symm

theorem prefixDepth_actual_trace_eq_psi_sup (R : Nat → Bool) (m : Nat) :
    prefixDepth altCol ((List.range m).map (fun t => drv altCol R t 1)) =
      ((Finset.range (m + 1)).filter
        (fun k => 1 ≤ k ∧ Psi R k = true)).sup id := by
  unfold prefixDepth
  simp only [List.length_map, List.length_range]
  apply Nat.le_antisymm
  · apply Finset.sup_le_iff.mpr
    intro k hk
    obtain ⟨hr, hb⟩ := Finset.mem_filter.mp hk
    by_cases hz : k = 0
    · subst k
      exact Nat.zero_le _
    · have hpos : 1 ≤ k := by omega
      have hkm : k ≤ m := by have := Finset.mem_range.mp hr; omega
      have hp := actual_traceColumn_positive R m k hpos hkm
      have hpsi : Psi R k = true := hp.symm.trans hb
      exact Finset.le_sup (f := id) (Finset.mem_filter.mpr ⟨hr, hpos, hpsi⟩)
  · apply Finset.sup_le_iff.mpr
    intro k hk
    obtain ⟨hr, hpos, hb⟩ := Finset.mem_filter.mp hk
    have hkm : k ≤ m := by have := Finset.mem_range.mp hr; omega
    have hp := actual_traceColumn_positive R m k hpos hkm
    have htrace : traceColumn altCol ((List.range m).map (fun t => drv altCol R t 1)) k 0 = true :=
      hp.trans hb
    exact Finset.le_sup (f := id) (Finset.mem_filter.mpr ⟨hr, htrace⟩)

end FVLT.Rule30PsiSupportBridgeV1
