import FVLTRule30FiniteReconstructionV1
import Mathlib.Data.Fintype.Pi
import Mathlib.Tactic

open Ruliology.CellularAutomata Rule30Jen Rule30Realization
open FVLT.Rule30FiniteReconstructionV1

namespace FVLT.Rule30RightStripV1

-- BEGIN FROZEN DEFINITIONS
abbrev StripState (K : Nat) := Fin K → Bool

def stripStep (K : Nat) (cbit b : Bool) (s : StripState K) : StripState K :=
  fun i => rule
    (if i.val = 0 then cbit else
      s ⟨i.val - 1, Nat.lt_of_le_of_lt (Nat.sub_le i.val 1) i.isLt⟩)
    (s i)
    (if h : i.val + 1 < K then s ⟨i.val + 1, h⟩ else b)

def stripRun (K : Nat) (hK : 0 < K) (c : Nat → Bool) (u : List Bool) : Prop :=
  ∃ s : Nat → StripState K,
    (∀ t : Nat, t < u.length → s t ⟨0, hK⟩ = u.getD t false) ∧
    (∀ t : Nat, t + 1 < u.length →
      ∃ b : Bool, s (t + 1) = stripStep K (c t) b (s t))

def reachable (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (u : List Bool) : Finset (StripState K) :=
  match u with
  | [] => Finset.univ
  | b :: bs =>
    (bs.foldl (fun (acc : Nat × Finset (StripState K)) bit =>
      (acc.1 + 1,
        (acc.2.biUnion (fun s =>
          ({stripStep K (c acc.1) false s,
            stripStep K (c acc.1) true s} : Finset (StripState K)))).filter
              (fun s => s ⟨0, hK⟩ = bit)))
      (0, (Finset.univ : Finset (StripState K)).filter
        (fun s => s ⟨0, hK⟩ = b))).2

def traceLevel (K : Nat) (hK : 0 < K) (c : Nat → Bool) (m : Nat) :
    List (List Bool × Finset (StripState K)) :=
  Nat.rec (motive := fun _ => List (List Bool × Finset (StripState K)))
    [([], Finset.univ)]
    (fun n previous =>
      if n = 0 then
        ([false, true] : List Bool).filterMap (fun b =>
          let states := (Finset.univ : Finset (StripState K)).filter
            (fun s => s ⟨0, hK⟩ = b)
          if states.Nonempty then some ([b], states) else none)
      else previous.flatMap (fun pair =>
        ([false, true] : List Bool).filterMap (fun b =>
          let states := (pair.2.biUnion (fun s =>
            ({stripStep K (c (n - 1)) false s,
              stripStep K (c (n - 1)) true s} : Finset (StripState K)))).filter
                (fun s => s ⟨0, hK⟩ = b)
          if states.Nonempty then some (pair.1 ++ [b], states) else none))) m

-- END FROZEN DEFINITIONS

private def initial (K : Nat) (hK : 0 < K) (b : Bool) : Finset (StripState K) :=
  Finset.univ.filter (fun s => s ⟨0, hK⟩ = b)

private def advance (K : Nat) (hK : 0 < K) (cbit : Bool)
    (S : Finset (StripState K)) (b : Bool) : Finset (StripState K) :=
  (S.biUnion (fun s => ({stripStep K cbit false s,
    stripStep K cbit true s} : Finset (StripState K)))).filter (fun s => s ⟨0, hK⟩ = b)

private def foldStep (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (acc : Nat × Finset (StripState K)) (b : Bool) : Nat × Finset (StripState K) :=
  (acc.1 + 1, advance K hK (c acc.1) acc.2 b)

private theorem fold_count (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (bs : List Bool) (acc : Nat × Finset (StripState K)) :
    (bs.foldl (foldStep K hK c) acc).1 = acc.1 + bs.length := by
  induction bs generalizing acc with
  | nil => simp
  | cons b bs ih =>
    simp only [List.foldl_cons]
    rw [ih]
    simp [foldStep, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm]

private theorem reachable_nil (K : Nat) (hK : 0 < K) (c : Nat → Bool) :
    reachable K hK c [] = Finset.univ := by rfl

private theorem reachable_single (K : Nat) (hK : 0 < K) (c : Nat → Bool) (b : Bool) :
    reachable K hK c [b] = initial K hK b := by rfl

private theorem reachable_cons (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (b : Bool) (bs : List Bool) :
    reachable K hK c (b :: bs) = (bs.foldl (foldStep K hK c) (0, initial K hK b)).2 := by rfl

private theorem reachable_append (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (u : List Bool) (b : Bool) (hne : u ≠ []) :
    reachable K hK c (u ++ [b]) =
      advance K hK (c (u.length - 1)) (reachable K hK c u) b := by
  cases u with
  | nil => contradiction
  | cons a bs =>
    simp only [List.cons_append, reachable_cons, List.foldl_append,
      List.foldl_cons, List.foldl_nil]
    change advance K hK (c ((bs.foldl (foldStep K hK c) (0, initial K hK a)).1))
      (bs.foldl (foldStep K hK c) (0, initial K hK a)).2 b = _
    rw [fold_count]
    simp

private theorem mem_advance (K : Nat) (hK : 0 < K) (cbit : Bool)
    (S : Finset (StripState K)) (b : Bool) (q : StripState K) :
    q ∈ advance K hK cbit S b ↔
      q ⟨0, hK⟩ = b ∧ ∃ s ∈ S, ∃ a : Bool, q = stripStep K cbit a s := by
  constructor
  · intro h
    obtain ⟨hU, hhead⟩ := Finset.mem_filter.mp h
    obtain ⟨s, hs, hq⟩ := Finset.mem_biUnion.mp hU
    simp only [Finset.mem_insert, Finset.mem_singleton] at hq
    rcases hq with hq | hq
    · exact ⟨hhead, s, hs, false, hq⟩
    · exact ⟨hhead, s, hs, true, hq⟩
  · rintro ⟨hhead, s, hs, a, hq⟩
    apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_biUnion.mpr ⟨s, hs, ?_⟩, hhead⟩
    cases a <;> simp [hq]

private theorem getD_prefix (u : List Bool) (b : Bool) (t : Nat) (ht : t < u.length) :
    (u ++ [b]).getD t false = u.getD t false := by
  simp only [List.getD_eq_getElem?_getD, List.getElem?_append_left ht]

private theorem getD_last (u : List Bool) (b : Bool) :
    (u ++ [b]).getD u.length false = b := by
  simp [List.getElem?_append]

private def ending (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (u : List Bool) (q : StripState K) : Prop :=
  ∃ f : Nat → StripState K,
    (∀ t : Nat, t < u.length → f t ⟨0, hK⟩ = u.getD t false) ∧
    (∀ t : Nat, t + 1 < u.length → ∃ a : Bool,
      f (t + 1) = stripStep K (c t) a (f t)) ∧ f (u.length - 1) = q

private theorem mem_reachable_ending (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (u : List Bool) (q : StripState K) :
    q ∈ reachable K hK c u ↔ ending K hK c u q := by
  induction u using List.reverseRecOn generalizing q with
  | nil =>
    constructor
    · intro _
      refine ⟨fun _ => q, ?_, ?_, rfl⟩ <;> intro t ht <;> simp at ht
    · intro _; exact Finset.mem_univ q
  | append_singleton u b ih =>
    by_cases he : u = []
    · subst u
      constructor
      · intro h
        have hhead : q ⟨0, hK⟩ = b := (Finset.mem_filter.mp h).2
        refine ⟨fun _ => q, ?_, ?_, rfl⟩
        · intro t ht
          have : t = 0 := by simpa using ht
          subst t
          simpa using hhead
        · intro t ht; simp at ht
      · rintro ⟨f, hheads, hsteps, hend⟩
        apply Finset.mem_filter.mpr
        refine ⟨Finset.mem_univ q, ?_⟩
        have hh := hheads 0 (by simp)
        have heq : f 0 = q := by simpa using hend
        simpa [heq] using hh
    · rw [reachable_append K hK c u b he, mem_advance]
      constructor
      · rintro ⟨hhead, s, hs, a, hq⟩
        obtain ⟨f, hheads, hsteps, hend⟩ := (ih s).mp hs
        let g : Nat → StripState K := fun t => if t < u.length then f t else q
        refine ⟨g, ?_, ?_, ?_⟩
        · intro t ht
          by_cases hold : t < u.length
          · rw [getD_prefix u b t hold]
            simpa [g, hold] using hheads t hold
          · have htl : t = u.length := by simp only [List.length_append, List.length_singleton] at ht; omega
            subst t
            simpa [g, getD_last] using hhead
        · intro t ht
          have htold : t < u.length := by simp only [List.length_append, List.length_singleton] at ht; omega
          by_cases hnext : t + 1 < u.length
          · obtain ⟨a', ha⟩ := hsteps t hnext
            exact ⟨a', by simpa [g, htold, hnext] using ha⟩
          · have hlast : t + 1 = u.length := by simp only [List.length_append, List.length_singleton] at ht; omega
            refine ⟨a, ?_⟩
            change (if t + 1 < u.length then f (t + 1) else q) =
              stripStep K (c t) a (if t < u.length then f t else q)
            rw [if_neg hnext, if_pos htold]
            have htl : t = u.length - 1 := by omega
            rw [htl, hend]
            exact hq
        · simp [g]
      · rintro ⟨f, hheads, hsteps, hend⟩
        have hlen : 0 < u.length := by
          by_contra hh
          exact he (List.length_eq_zero_iff.mp (by omega))
        have hfinal : f u.length = q := by simpa using hend
        have hhead := hheads u.length (by simp)
        have hs : f (u.length - 1) ∈ reachable K hK c u := by
          apply (ih _).mpr
          refine ⟨f, ?_, ?_, rfl⟩
          · intro t ht
            rw [← getD_prefix u b t ht]
            exact hheads t (by simp only [List.length_append, List.length_singleton]; omega)
          · intro t ht
            exact hsteps t (by simp only [List.length_append, List.length_singleton]; omega)
        obtain ⟨a, ha⟩ := hsteps (u.length - 1)
          (by simp only [List.length_append, List.length_singleton]; omega)
        refine ⟨?_, f (u.length - 1), hs, a, ?_⟩
        · simpa [hfinal, getD_last] using hhead
        · have heq : u.length - 1 + 1 = u.length := by omega
          simpa [heq, hfinal] using ha

private theorem initial_nonempty (K : Nat) (hK : 0 < K) (b : Bool) :
    (initial K hK b).Nonempty := by
  exact ⟨fun _ => b, Finset.mem_filter.mpr ⟨Finset.mem_univ _, rfl⟩⟩

private def extendPairs (K : Nat) (hK : 0 < K) (cbit : Bool)
    (pair : List Bool × Finset (StripState K)) :
    List (List Bool × Finset (StripState K)) :=
  ([false, true] : List Bool).filterMap (fun b =>
    let states := advance K hK cbit pair.2 b
    if states.Nonempty then some (pair.1 ++ [b], states) else none)

private theorem mem_extendPairs (K : Nat) (hK : 0 < K) (cbit : Bool)
    (v u : List Bool) (T S : Finset (StripState K)) :
    (u, S) ∈ extendPairs K hK cbit (v, T) ↔
      ∃ b : Bool, u = v ++ [b] ∧ S = advance K hK cbit T b ∧ S.Nonempty := by
  constructor
  · intro h
    obtain ⟨b, hb, hout⟩ := List.mem_filterMap.mp h
    dsimp only at hout
    by_cases hn : (advance K hK cbit T b).Nonempty
    · rw [if_pos hn] at hout
      have hp := Prod.mk.inj (Option.some.inj hout)
      exact ⟨b, hp.1.symm, hp.2.symm, hp.2 ▸ hn⟩
    · rw [if_neg hn] at hout
      contradiction
  · rintro ⟨b, rfl, rfl, hn⟩
    apply List.mem_filterMap.mpr
    exact ⟨b, by cases b <;> simp, by simp [hn]⟩

private theorem level_zero (K : Nat) (hK : 0 < K) (c : Nat → Bool) :
    traceLevel K hK c 0 = [([], Finset.univ)] := by rfl

private theorem level_one (K : Nat) (hK : 0 < K) (c : Nat → Bool) :
    traceLevel K hK c 1 = [([false], initial K hK false), ([true], initial K hK true)] := by
  change ([false, true] : List Bool).filterMap (fun b =>
    if (initial K hK b).Nonempty then some ([b], initial K hK b) else none) = _
  simp only [initial_nonempty, ite_true, List.filterMap_cons, List.filterMap_nil]

private theorem level_more (K : Nat) (hK : 0 < K) (c : Nat → Bool) (n : Nat) :
    traceLevel K hK c (n + 2) =
      (traceLevel K hK c (n + 1)).flatMap (extendPairs K hK (c n)) := by
  simp [traceLevel] <;> rfl

private theorem split_last (u : List Bool) (hne : u ≠ []) :
    ∃ v : List Bool, ∃ b : Bool, u = v ++ [b] := by
  induction u with
  | nil => contradiction
  | cons a us ih =>
    by_cases he : us = []
    · subst us; exact ⟨[], a, rfl⟩
    · obtain ⟨v, b, hv⟩ := ih he
      exact ⟨a :: v, b, by simp [hv]⟩

theorem stripStep_eq_projection (K : Nat) (hK : 0 < K)
    (x : Int → Bool) (t : Nat) :
    stripStep K (evol x t 0) (evol x t ((K : Int) + 1))
      (fun i : Fin K => evol x t ((i.val : Int) + 1)) =
      (fun i : Fin K => evol x (t + 1) ((i.val : Int) + 1)) := by
  funext i
  change rule
    (if i.val = 0 then evol x t 0 else
      evol x t (((i.val - 1 : Nat) : Int) + 1))
    (evol x t ((i.val : Int) + 1))
    (if h : i.val + 1 < K then evol x t (((i.val + 1 : Nat) : Int) + 1)
      else evol x t ((K : Int) + 1)) =
    rule (evol x t ((i.val : Int) + 1 - 1))
      (evol x t ((i.val : Int) + 1)) (evol x t ((i.val : Int) + 1 + 1))
  congr 1
  · split_ifs with h <;> congr 1 <;> omega
  · split_ifs with h <;> congr 1 <;> omega

theorem reachable_nonempty_iff_run (K : Nat) (hK : 0 < K)
    (c : Nat → Bool) (u : List Bool) :
    (reachable K hK c u).Nonempty ↔ stripRun K hK c u := by
  constructor
  · rintro ⟨q, hq⟩
    obtain ⟨f, hheads, hsteps, hend⟩ := (mem_reachable_ending K hK c u q).mp hq
    exact ⟨f, hheads, hsteps⟩
  · rintro ⟨f, hheads, hsteps⟩
    refine ⟨f (u.length - 1), ?_⟩
    exact (mem_reachable_ending K hK c u _).mpr ⟨f, hheads, hsteps, rfl⟩

theorem rightRealizable_implies_strip (K : Nat) (hK : 0 < K)
    (c : Nat → Bool) (u : List Bool) (hu : rightRealizable c u) :
    (reachable K hK c u).Nonempty := by
  obtain ⟨R, hR⟩ := hu
  apply (reachable_nonempty_iff_run K hK c u).mpr
  refine ⟨fun t i => evol (conf R c) t ((i.val : Int) + 1), ?_, ?_⟩
  · intro t ht
    change evol (conf R c) t 1 = u.getD t false
    rw [evol_conf]
    simpa using (hR t ht).symm
  · intro t ht
    refine ⟨evol (conf R c) t ((K : Int) + 1), ?_⟩
    rw [← (realize R c).2 t]
    exact (stripStep_eq_projection K hK (conf R c) t).symm

theorem traceLevel_complete (K : Nat) (hK : 0 < K) (c : Nat → Bool)
    (m : Nat) (u : List Bool) (S : Finset (StripState K)) :
    (u, S) ∈ traceLevel K hK c m ↔
      u.length = m ∧ S = reachable K hK c u ∧ S.Nonempty := by
  induction m using Nat.twoStepInduction generalizing u S with
  | zero =>
    constructor
    · intro h
      have hp : u = [] ∧ S = Finset.univ := by simpa [level_zero] using h
      obtain ⟨rfl, rfl⟩ := hp
      exact ⟨rfl, rfl, ⟨fun _ => false, Finset.mem_univ _⟩⟩
    · rintro ⟨hlen, rfl, hn⟩
      have hu : u = [] := List.length_eq_zero_iff.mp hlen
      subst u
      simp [level_zero, reachable_nil]
  | one =>
    constructor
    · intro h
      have hp : (u = [false] ∧ S = initial K hK false) ∨
          (u = [true] ∧ S = initial K hK true) := by simpa [level_one] using h
      rcases hp with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;>
        exact ⟨rfl, rfl, initial_nonempty K hK _⟩
    · rintro ⟨hlen, rfl, hn⟩
      obtain ⟨b, rfl⟩ := List.length_eq_one_iff.mp hlen
      cases b <;> simp [level_one, reachable_single]
  | more n ih0 ih1 =>
    rw [level_more]
    constructor
    · intro h
      obtain ⟨⟨v, T⟩, hv, hext⟩ := List.mem_flatMap.mp h
      obtain ⟨b, rfl, rfl, hn⟩ := (mem_extendPairs K hK (c n) v u T S).mp hext
      obtain ⟨hlen, rfl, hT⟩ := (ih1 v T).mp hv
      have hne : v ≠ [] := by intro he; simp [he] at hlen
      refine ⟨by simp [hlen], ?_, hn⟩
      rw [reachable_append K hK c v b hne]
      simp [hlen]
    · rintro ⟨hlen, hS, hn⟩
      have hne : u ≠ [] := by intro he; simp [he] at hlen
      obtain ⟨v, b, rfl⟩ := split_last u hne
      have hvlen : v.length = n + 1 := by simp only [List.length_append, List.length_singleton] at hlen; omega
      have hvne : v ≠ [] := by intro he; simp [he] at hvlen
      have hs : S = advance K hK (c n) (reachable K hK c v) b := by
        rw [hS, reachable_append K hK c v b hvne]
        simp [hvlen]
      have hsave := hn
      obtain ⟨q, hq⟩ := hn
      rw [hs] at hq
      obtain ⟨_, r, hr, a, ha⟩ := (mem_advance K hK (c n) (reachable K hK c v) b q).mp hq
      apply List.mem_flatMap.mpr
      refine ⟨(v, reachable K hK c v), (ih1 v _).mpr ⟨hvlen, rfl, r, hr⟩, ?_⟩
      exact (mem_extendPairs K hK (c n) v (v ++ [b]) (reachable K hK c v) S).mpr ⟨b, rfl, hs, hsave⟩

end FVLT.Rule30RightStripV1
