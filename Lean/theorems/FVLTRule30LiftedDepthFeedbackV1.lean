import FVLTRule30LiftedBaselineV1

open FVLT.Rule30FiniteReconstructionV1

namespace FVLT.Rule30LiftedBaselineV1

/-- General finite-depth update and nonlinear baseline feedback.
The audited chunk1 definitions and lemmas are imported, not restated.
The same-centre comparison does not identify different centre streams.
The shifted-history term is retained; lifted-state closure is open. -/
private theorem trace_next (c : Nat → Bool) (u : List Bool) (k t : Nat) :
    traceColumn c u (k + 2) t = xor (traceColumn c u (k + 1) (t + 1))
      (traceColumn c u (k + 1) t || traceColumn c u k t) := by
  rfl

private theorem prefixDepth_le_iff (c : Nat → Bool) (u : List Bool) (L : Nat) :
    prefixDepth c u ≤ L ↔
      ∀ k : Nat, k ≤ u.length → traceColumn c u k 0 = true → k ≤ L := by
  simp only [prefixDepth, Finset.sup_le_iff, Finset.mem_filter,
    Finset.mem_range, Nat.lt_succ_iff, and_imp, id]

private theorem prefixDepth_le_length (c : Nat → Bool) (u : List Bool) :
    prefixDepth c u ≤ u.length := by
  apply (prefixDepth_le_iff c u u.length).2
  intro k hk _
  exact hk

private theorem prefixDepth_black_le (c : Nat → Bool) (u : List Bool)
    (k : Nat) (hk : k ≤ u.length) (hb : traceColumn c u k 0 = true) :
    k ≤ prefixDepth c u := by
  exact (prefixDepth_le_iff c u (prefixDepth c u)).1 (le_refl _) k hk hb

private theorem trace_tail_append (u : List Bool) (b : Bool) :
    ((u ++ [b]) ++ [false]).tail = (u ++ [b]).tail ++ [false] := by
  exact List.tail_append_of_ne_nil (by simp)

theorem prefixDepth_append (c : Nat → Bool) (u : List Bool) (b : Bool) :
    prefixDepth c (u ++ [b]) =
      if nextCell c u b then u.length + 1 else prefixDepth c u := by
  have hold : prefixDepth c u ≤ prefixDepth c (u ++ [b]) := by
    apply (prefixDepth_le_iff c u _).2
    intro k hk hb
    apply prefixDepth_black_le c (u ++ [b]) k
    · simp only [List.length_append, List.length_singleton]
      omega
    · rw [traceColumn_append_local c u b k 0 (by omega)]
      exact hb
  cases hn : nextCell c u b with
  | false =>
    have hup : prefixDepth c (u ++ [b]) ≤ prefixDepth c u := by
      apply (prefixDepth_le_iff c (u ++ [b]) _).2
      intro k hk hb
      by_cases hko : k ≤ u.length
      · apply prefixDepth_black_le c u k hko
        rw [← traceColumn_append_local c u b k 0 (by omega)]
        exact hb
      · have heq : k = u.length + 1 := by
          simp only [List.length_append, List.length_singleton] at hk
          omega
        subst k
        have hnew : traceColumn c (u ++ [b]) (u.length + 1) 0 = false := hn
        cases (hnew.symm.trans hb)
    simpa [hn] using (le_antisymm hup hold)
  | true =>
    have hnew : traceColumn c (u ++ [b]) (u.length + 1) 0 = true := hn
    have hlo : u.length + 1 ≤ prefixDepth c (u ++ [b]) := by
      apply prefixDepth_black_le c (u ++ [b]) (u.length + 1)
      · simp
      · exact hnew
    have hup : prefixDepth c (u ++ [b]) ≤ u.length + 1 := by
      simpa using prefixDepth_le_length c (u ++ [b])
    simpa [hn] using (le_antisymm hup hlo)

theorem lifted_same_next_depth (c : Nat → Bool) (u v : List Bool)
    (b : Bool) (hlen : u.length = v.length)
    (hdepth : prefixDepth c u = prefixDepth c v)
    (hbaseline : baseline c u = baseline c v) :
    prefixDepth c (u ++ [b]) = prefixDepth c (v ++ [b]) := by
  have hn : nextCell c u b = nextCell c v b := by
    rw [nextCell_affine c u b, nextCell_affine c v b, hlen, hbaseline]
  rw [prefixDepth_append c u b, prefixDepth_append c v b, hn, hlen, hdepth]

theorem baseline_feedback (c : Nat → Bool) (u : List Bool) (b : Bool) :
    baseline c (u ++ [b]) =
      xor (baseline (fun t => c (t + 1)) (u ++ [b]).tail)
        (nextCell c u b || traceColumn c u u.length 0) := by
  have hlen : (u ++ [b]).length = u.length + 1 := by simp
  have htail : (u ++ [b]).tail.length = u.length := by simp
  change traceColumn c ((u ++ [b]) ++ [false]) ((u ++ [b]).length + 1) 0 =
    xor (traceColumn (fun t => c (t + 1)) ((u ++ [b]).tail ++ [false])
        ((u ++ [b]).tail.length + 1) 0)
      (traceColumn c (u ++ [b]) (u.length + 1) 0 || traceColumn c u u.length 0)
  rw [hlen, htail, trace_next,
    traceColumn_time_shift c ((u ++ [b]) ++ [false]) (u.length + 1) 0,
    trace_tail_append,
    traceColumn_append_local c (u ++ [b]) false (u.length + 1) 0 (by simp),
    traceColumn_append_local c (u ++ [b]) false u.length 0 (by simp),
    traceColumn_append_local c u b u.length 0 (by omega)]

end FVLT.Rule30LiftedBaselineV1
